--------------------------------------------------------
--  DDL for Package Body GL_MANAGEMENT_SEGMENT_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_MANAGEMENT_SEGMENT_UPGRADE" AS
/* $Header: glumsupb.pls 120.3 2005/05/05 01:41:16 kvora ship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  api_name         CONSTANT VARCHAR2(30) := 'GL_MANAGEMENT_SEGMENT_UPGRADE';
  lock_name_prefix CONSTANT VARCHAR2(15) := 'GL_MGT_SEG_';

  --
  -- PRIVATE EXCEPTIONS
  --
  assign_complete_error  EXCEPTION;  -- assignment already completed for COA
  user_lock_error        EXCEPTION;  -- error related to the user name lock
  request_error          EXCEPTION;  -- request submission failed

  --
  -- PUBLIC FUNCTIONS
  --

  FUNCTION request_lock(
    X_Chart_Of_Accounts_Id NUMBER,
    X_Lock_Mode            INTEGER,
    X_Timeout_Secs         INTEGER DEFAULT 1,
    X_Keep_Trying          BOOLEAN DEFAULT FALSE,
    X_Try_Times            NUMBER DEFAULT 1,
    X_Wait_Secs            NUMBER DEFAULT 60) RETURN BOOLEAN
  IS
    lock_handle   VARCHAR2(128);
    lock_result   INTEGER;
  BEGIN
    DBMS_LOCK.allocate_unique(lock_name_prefix ||
                              to_char(X_Chart_Of_Accounts_Id),
                              lock_handle);

    FOR i IN 1..X_Try_Times LOOP
      lock_result := DBMS_LOCK.request(lock_handle, X_Lock_Mode,
                                       X_Timeout_Secs);

      IF (lock_result IN (0, 4)) THEN
        -- succeeded
        RETURN TRUE;
      ELSIF (lock_result = 1) THEN
        IF (X_Keep_Trying AND i < X_Try_Times) THEN
          DBMS_LOCK.sleep(X_Wait_Secs);
        ELSE
          RETURN FALSE;
        END IF;
      ELSE
        RETURN FALSE;
      END IF;
    END LOOP;

    -- Correct call shouldn't ever reach here
    RETURN FALSE;
  END request_lock;


  FUNCTION release_lock(X_Chart_Of_Accounts_Id NUMBER) RETURN BOOLEAN
  IS
    lock_handle   VARCHAR2(128);
    lock_result   INTEGER;
  BEGIN
    DBMS_LOCK.allocate_unique(lock_name_prefix ||
                              to_char(X_Chart_Of_Accounts_Id),
                              lock_handle);
    lock_result := DBMS_LOCK.release(lock_handle);

    IF (lock_result IN (0, 4)) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END release_lock;


  PROCEDURE Setup_Upgrade(
    X_Errbuf                OUT NOCOPY VARCHAR2,
    X_Retcode               OUT NOCOPY VARCHAR2,
    X_Chart_Of_Accounts_Id  NUMBER,
    X_Mgt_Seg_Column_Name   VARCHAR2)
  IS
    fn_name       CONSTANT VARCHAR2(30) := 'Setup_Upgrade';

    status                 VARCHAR2(1);
    industry               VARCHAR2(1);
    schema                 VARCHAR2(30);
    seq_in_order           VARCHAR2(1);

    lock_name              VARCHAR2(30);
    lock_op_succeeded      BOOLEAN;

    rerun_flag             VARCHAR2(1);
    l_mgt_seg_column_name  VARCHAR2(30);
    l_assign_complete_flag VARCHAR2(1);
    new_max_batch_id       NUMBER;
    request_id             NUMBER;

    l_user_id              NUMBER;
    l_login_id             NUMBER;

    sequence_order_error   EXCEPTION;
    get_sequence_error     EXCEPTION;
    assign_different_error EXCEPTION;
  BEGIN
    GL_MESSAGE.func_ent(api_name || '.' || fn_name);

    l_user_id := FND_GLOBAL.user_id;
    l_login_id := FND_GLOBAL.login_id;

    -- Check je_batch_id in gl_je_batches table in order or not.
    IF (FND_INSTALLATION.get_app_info('SQLGL', status, industry, schema)) THEN

      SELECT order_flag
      INTO   seq_in_order
      FROM   dba_sequences
      WHERE  sequence_owner = schema
      AND    sequence_name = 'GL_JE_BATCHES_S';

      IF (seq_in_order = 'N') THEN
        RAISE sequence_order_error;
      END IF;
    ELSE
      RAISE sequence_order_error;
    END IF;

    -- Acquire user name lock GL_MGT_SEG_<coa_id> in exclusive mode
    lock_name := lock_name_prefix || to_char(X_Chart_Of_Accounts_Id);

    lock_op_succeeded := request_lock(X_Chart_Of_Accounts_Id, DBMS_LOCK.x_mode,
                                      60, TRUE, 10, 120);
    IF (NOT lock_op_succeeded) THEN
      RAISE user_lock_error;
    END IF;

    GL_MESSAGE.write_log('SHRD0209', 1, 'USERLOCK', lock_name);

    -- Check existing record in GL_MGT_SEG_UPGRADE_H
    SELECT decode(min(chart_of_accounts_id), null, 'N', 'Y'),
           min(mgt_seg_column_name),
           min(assign_complete_flag)
    INTO   rerun_flag, l_mgt_seg_column_name, l_assign_complete_flag
    FROM   GL_MGT_SEG_UPGRADE_H
    WHERE  chart_of_accounts_id = X_Chart_Of_Accounts_Id;

    -- If the upgrade is complate for the COA, or the management segment
    -- selected is different, stop
    IF (l_assign_complete_flag = 'Y') THEN
      RAISE assign_complete_error;
    ELSIF (l_mgt_seg_column_name <> X_Mgt_Seg_Column_Name) THEN
      RAISE assign_different_error;
    END IF;

    -- Get a new max_batch_id and insert/update the history record
    BEGIN
      SELECT GL_JE_BATCHES_S.nextval
      INTO   new_max_batch_id
      FROM   dual;
    EXCEPTION
      WHEN others THEN
        RAISE get_sequence_error;
    END;

    IF (rerun_flag = 'N') THEN
      INSERT INTO GL_MGT_SEG_UPGRADE_H
        (chart_of_accounts_id,
         mgt_seg_column_name,
         assign_complete_flag,
         max_processed_batch_id,
         max_batch_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login)
      VALUES
        (X_Chart_Of_Accounts_Id,
         X_Mgt_Seg_Column_Name,
         'N',
         null,
         new_max_batch_id,
         sysdate,
         l_user_id,
         sysdate,
         l_user_id,
         l_login_id);
    ELSE
      UPDATE GL_MGT_SEG_UPGRADE_H
      SET    max_batch_id = new_max_batch_id
      WHERE  chart_of_accounts_id = X_Chart_Of_Accounts_Id;
    END IF;

    -- Submit concurrent program
    request_id := FND_REQUEST.submit_request(
                    application => 'SQLGL',
                    program => 'GLMGT2',
                    argument1 => X_Chart_Of_Accounts_Id);

    IF (request_id = 0) THEN
      RAISE request_error;
    ELSE
      GL_MESSAGE.write_log('SHRD0121', 1, 'REQ_ID', to_char(request_id));
    END IF;

    COMMIT;

    -- Release user name lock GL_MGT_SEG_<coa_id>
    lock_op_succeeded := release_lock(X_Chart_Of_Accounts_Id);

    GL_MESSAGE.func_succ(api_name || '.' || fn_name);

  EXCEPTION
    WHEN sequence_order_error THEN
      GL_MESSAGE.write_log('MGTS0001', 0);
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
    WHEN get_sequence_error THEN
      lock_op_succeeded := release_lock(X_Chart_Of_Accounts_Id);
      GL_MESSAGE.write_log('SHRD0050', 2, 'ROUTINE', fn_name,
                                          'SEQUENCE', 'GL_JE_BATCHES_S');
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
    WHEN user_lock_error THEN
      GL_MESSAGE.write_log('MGTS0005', 1, 'USERLOCK', lock_name);
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
    WHEN assign_complete_error THEN
      lock_op_succeeded := release_lock(X_Chart_Of_Accounts_Id);
      GL_MESSAGE.write_log('MGTS0002');
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '1';
    WHEN assign_different_error THEN
      lock_op_succeeded := release_lock(X_Chart_Of_Accounts_Id);
      GL_MESSAGE.write_log('MGTS0003');
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
    WHEN request_error THEN
      lock_op_succeeded := release_lock(X_Chart_Of_Accounts_Id);
      GL_MESSAGE.write_log('SHRD0055', 1, 'ROUTINE', fn_name);
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
    WHEN others THEN
      lock_op_succeeded := release_lock(X_Chart_Of_Accounts_Id);
      FND_FILE.put_line(FND_FILE.LOG, SQLERRM);
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
  END Setup_Upgrade;



  PROCEDURE Process_Incremental_Data(
    X_Errbuf                OUT NOCOPY VARCHAR2,
    X_Retcode               OUT NOCOPY VARCHAR2,
    X_Chart_Of_Accounts_Id  NUMBER)
  IS
    fn_name       CONSTANT VARCHAR2(30) := 'Process_Incremental_Data';

    l_assign_complete_flag VARCHAR2(1);
    l_mgt_seg_column_name  VARCHAR2(30);
    l_max_proc_batch_id    NUMBER;
    l_max_batch_id         NUMBER;
    low_batch_id           NUMBER;
    high_batch_id          NUMBER;
    batch_size             NUMBER := 10000;

    l_user_id              NUMBER;
    l_login_id             NUMBER;
  BEGIN
    GL_MESSAGE.func_ent(api_name || '.' || fn_name);

    l_user_id := FND_GLOBAL.user_id;
    l_login_id := FND_GLOBAL.login_id;

    -- Check the record in GL_MGT_SEG_UPGRADE_H
    SELECT min(assign_complete_flag),
           min(mgt_seg_column_name),
           nvl(min(max_processed_batch_id), 0),
           min(max_batch_id)
    INTO   l_assign_complete_flag, l_mgt_seg_column_name,
           l_max_proc_batch_id, l_max_batch_id
    FROM   GL_MGT_SEG_UPGRADE_H
    WHERE  chart_of_accounts_id = X_Chart_Of_Accounts_Id;

    IF (l_assign_complete_flag <> 'N') THEN
      RAISE assign_complete_error;
    END IF;

    -- Process posted batches that were recorded as unposted in previous run:
    -- Move posted batch id to _GT
    INSERT INTO GL_MGT_SEG_UPGRADE_GT
      (je_batch_id)
    SELECT msu.je_batch_id
    FROM   GL_MGT_SEG_UPGRADE MSU,
           GL_JE_BATCHES B
    WHERE  msu.chart_of_accounts_id = X_Chart_Of_Accounts_Id
    AND    b.je_batch_id = msu.je_batch_id
    AND    b.status || '' = 'P';

    -- Process batches in _GT
    INSERT INTO GL_JE_SEGMENT_VALUES
      (je_header_id, segment_type_code, segment_value, creation_date,
       created_by, last_update_date, last_updated_by, last_update_login)
    SELECT l.je_header_id, 'M',
           decode(l_mgt_seg_column_name, 'SEGMENT1', cc.segment1,
                                         'SEGMENT2', cc.segment2,
                                         'SEGMENT3', cc.segment3,
                                         'SEGMENT4', cc.segment4,
                                         'SEGMENT5', cc.segment5,
                                         'SEGMENT6', cc.segment6,
                                         'SEGMENT7', cc.segment7,
                                         'SEGMENT8', cc.segment8,
                                         'SEGMENT9', cc.segment9,
                                         'SEGMENT10', cc.segment10,
                                         'SEGMENT11', cc.segment11,
                                         'SEGMENT12', cc.segment12,
                                         'SEGMENT13', cc.segment13,
                                         'SEGMENT14', cc.segment14,
                                         'SEGMENT15', cc.segment15,
                                         'SEGMENT16', cc.segment16,
                                         'SEGMENT17', cc.segment17,
                                         'SEGMENT18', cc.segment18,
                                         'SEGMENT19', cc.segment19,
                                         'SEGMENT20', cc.segment20,
                                         'SEGMENT21', cc.segment21,
                                         'SEGMENT22', cc.segment22,
                                         'SEGMENT23', cc.segment23,
                                         'SEGMENT24', cc.segment24,
                                         'SEGMENT25', cc.segment25,
                                         'SEGMENT26', cc.segment26,
                                         'SEGMENT27', cc.segment27,
                                         'SEGMENT28', cc.segment28,
                                         'SEGMENT29', cc.segment29,
                                         'SEGMENT30', cc.segment30),
           sysdate, l_user_id, sysdate, l_user_id, l_login_id
    FROM   GL_MGT_SEG_UPGRADE_GT GT,
           GL_JE_HEADERS H,
           GL_JE_LINES L,
           GL_CODE_COMBINATIONS CC
    WHERE  h.je_batch_id = gt.je_batch_id
    AND    l.je_header_id = h.je_header_id
    AND    cc.code_combination_id = l.code_combination_id
    GROUP BY
           l.je_header_id,
           decode(l_mgt_seg_column_name, 'SEGMENT1', cc.segment1,
                                         'SEGMENT2', cc.segment2,
                                         'SEGMENT3', cc.segment3,
                                         'SEGMENT4', cc.segment4,
                                         'SEGMENT5', cc.segment5,
                                         'SEGMENT6', cc.segment6,
                                         'SEGMENT7', cc.segment7,
                                         'SEGMENT8', cc.segment8,
                                         'SEGMENT9', cc.segment9,
                                         'SEGMENT10', cc.segment10,
                                         'SEGMENT11', cc.segment11,
                                         'SEGMENT12', cc.segment12,
                                         'SEGMENT13', cc.segment13,
                                         'SEGMENT14', cc.segment14,
                                         'SEGMENT15', cc.segment15,
                                         'SEGMENT16', cc.segment16,
                                         'SEGMENT17', cc.segment17,
                                         'SEGMENT18', cc.segment18,
                                         'SEGMENT19', cc.segment19,
                                         'SEGMENT20', cc.segment20,
                                         'SEGMENT21', cc.segment21,
                                         'SEGMENT22', cc.segment22,
                                         'SEGMENT23', cc.segment23,
                                         'SEGMENT24', cc.segment24,
                                         'SEGMENT25', cc.segment25,
                                         'SEGMENT26', cc.segment26,
                                         'SEGMENT27', cc.segment27,
                                         'SEGMENT28', cc.segment28,
                                         'SEGMENT29', cc.segment29,
                                         'SEGMENT30', cc.segment30);

    -- Delete from the tracking table the je_batch_id processed
    DELETE FROM GL_MGT_SEG_UPGRADE MSU
    WHERE  MSU.chart_of_accounts_id = X_Chart_Of_Accounts_Id
    AND    MSU.je_batch_id IN (SELECT gt.je_batch_id
                               FROM   GL_MGT_SEG_UPGRADE_GT gt);

    -- Commit
    COMMIT;

    GL_MESSAGE.write_log('MGTS0006', 1,
                         'BATCHID', to_char(l_max_proc_batch_id));

    -- Batch processing the journals between max_processed_ and max_ batch id:
    LOOP
      low_batch_id := l_max_proc_batch_id + 1;
      high_batch_id := least(l_max_proc_batch_id + batch_size, l_max_batch_id);

      INSERT INTO GL_MGT_SEG_UPGRADE
        (chart_of_accounts_id, je_batch_id, creation_date,
         created_by, last_update_date, last_updated_by, last_update_login)
      SELECT b.chart_of_accounts_id, b.je_batch_id,
             sysdate, l_user_id, sysdate, l_user_id, l_login_id
      FROM   GL_JE_BATCHES B
      WHERE  b.je_batch_id BETWEEN low_batch_id AND high_batch_id
      AND    b.status <> 'P'
      AND    b.chart_of_accounts_id = X_Chart_Of_Accounts_Id;

      INSERT INTO GL_JE_SEGMENT_VALUES
        (je_header_id, segment_type_code, segment_value, creation_date,
         created_by, last_update_date, last_updated_by, last_update_login)
      SELECT l.je_header_id, 'M',
             decode(l_mgt_seg_column_name, 'SEGMENT1', cc.segment1,
                                           'SEGMENT2', cc.segment2,
                                           'SEGMENT3', cc.segment3,
                                           'SEGMENT4', cc.segment4,
                                           'SEGMENT5', cc.segment5,
                                           'SEGMENT6', cc.segment6,
                                           'SEGMENT7', cc.segment7,
                                           'SEGMENT8', cc.segment8,
                                           'SEGMENT9', cc.segment9,
                                           'SEGMENT10', cc.segment10,
                                           'SEGMENT11', cc.segment11,
                                           'SEGMENT12', cc.segment12,
                                           'SEGMENT13', cc.segment13,
                                           'SEGMENT14', cc.segment14,
                                           'SEGMENT15', cc.segment15,
                                           'SEGMENT16', cc.segment16,
                                           'SEGMENT17', cc.segment17,
                                           'SEGMENT18', cc.segment18,
                                           'SEGMENT19', cc.segment19,
                                           'SEGMENT20', cc.segment20,
                                           'SEGMENT21', cc.segment21,
                                           'SEGMENT22', cc.segment22,
                                           'SEGMENT23', cc.segment23,
                                           'SEGMENT24', cc.segment24,
                                           'SEGMENT25', cc.segment25,
                                           'SEGMENT26', cc.segment26,
                                           'SEGMENT27', cc.segment27,
                                           'SEGMENT28', cc.segment28,
                                           'SEGMENT29', cc.segment29,
                                           'SEGMENT30', cc.segment30),
             sysdate, l_user_id, sysdate, l_user_id, l_login_id
      FROM   GL_JE_BATCHES B,
             GL_JE_HEADERS H,
             GL_JE_LINES L,
             GL_CODE_COMBINATIONS CC
      WHERE  b.je_batch_id BETWEEN low_batch_id AND high_batch_id
      AND    b.status || '' = 'P'
      AND    b.chart_of_accounts_id = X_Chart_Of_Accounts_Id
      AND    NOT EXISTS
             (SELECT msu.je_batch_id
              FROM   GL_MGT_SEG_UPGRADE MSU
              WHERE  msu.chart_of_accounts_id = X_Chart_Of_Accounts_Id
              AND    msu.je_batch_id = b.je_batch_id)
      AND    h.je_batch_id = b.je_batch_id
      AND    l.je_header_id = h.je_header_id
      AND    cc.code_combination_id = l.code_combination_id
      GROUP BY
             l.je_header_id,
             decode(l_mgt_seg_column_name, 'SEGMENT1', cc.segment1,
                                           'SEGMENT2', cc.segment2,
                                           'SEGMENT3', cc.segment3,
                                           'SEGMENT4', cc.segment4,
                                           'SEGMENT5', cc.segment5,
                                           'SEGMENT6', cc.segment6,
                                           'SEGMENT7', cc.segment7,
                                           'SEGMENT8', cc.segment8,
                                           'SEGMENT9', cc.segment9,
                                           'SEGMENT10', cc.segment10,
                                           'SEGMENT11', cc.segment11,
                                           'SEGMENT12', cc.segment12,
                                           'SEGMENT13', cc.segment13,
                                           'SEGMENT14', cc.segment14,
                                           'SEGMENT15', cc.segment15,
                                           'SEGMENT16', cc.segment16,
                                           'SEGMENT17', cc.segment17,
                                           'SEGMENT18', cc.segment18,
                                           'SEGMENT19', cc.segment19,
                                           'SEGMENT20', cc.segment20,
                                           'SEGMENT21', cc.segment21,
                                           'SEGMENT22', cc.segment22,
                                           'SEGMENT23', cc.segment23,
                                           'SEGMENT24', cc.segment24,
                                           'SEGMENT25', cc.segment25,
                                           'SEGMENT26', cc.segment26,
                                           'SEGMENT27', cc.segment27,
                                           'SEGMENT28', cc.segment28,
                                           'SEGMENT29', cc.segment29,
                                           'SEGMENT30', cc.segment30);

      l_max_proc_batch_id := high_batch_id;

      UPDATE GL_MGT_SEG_UPGRADE_H
      SET    max_processed_batch_id = high_batch_id
      WHERE  chart_of_accounts_id = X_Chart_Of_Accounts_Id;

      COMMIT;

      GL_MESSAGE.write_log('MGTS0007', 2,
                           'LOWID', low_batch_id, 'HIGHID', high_batch_id);

      EXIT WHEN (l_max_proc_batch_id = l_max_batch_id);
    END LOOP;

    GL_MESSAGE.func_succ(api_name || '.' || fn_name);

  EXCEPTION
    WHEN assign_complete_error THEN
      GL_MESSAGE.write_log('MGTS0002');
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '1';
    WHEN others THEN
      FND_FILE.put_line(FND_FILE.LOG, SQLERRM);
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
  END Process_Incremental_Data;


  PROCEDURE Assign_Management_Segment(
    X_Errbuf                OUT NOCOPY VARCHAR2,
    X_Retcode               OUT NOCOPY VARCHAR2,
    X_Chart_Of_Accounts_Id  NUMBER)
  IS
    fn_name       CONSTANT VARCHAR2(30) := 'Assign_Management_Segment';

    l_mgt_seg_column_name  VARCHAR2(30);
    l_assign_complete_flag VARCHAR2(1);
    l_max_proc_batch_id    NUMBER;

    l_user_id         NUMBER;
    l_login_id        NUMBER;

    lock_name         VARCHAR2(30);
    lock_op_succeeded BOOLEAN;

    struct_code VARCHAR2(30);
    seg_name    VARCHAR2(30);
    flexfield   FND_FLEX_KEY_API.flexfield_type;
    structure   FND_FLEX_KEY_API.structure_type;
    segment     FND_FLEX_KEY_API.segment_type;

    request_id  NUMBER;

    max_processed_error EXCEPTION;
  BEGIN
    GL_MESSAGE.func_ent(api_name || '.' || fn_name);

    l_user_id := FND_GLOBAL.user_id;
    l_login_id := FND_GLOBAL.login_id;

    -- Check the record in GL_MGT_SEG_UPGRADE_H
    SELECT min(mgt_seg_column_name),
           min(assign_complete_flag),
           min(max_processed_batch_id)
    INTO   l_mgt_seg_column_name, l_assign_complete_flag, l_max_proc_batch_id
    FROM   GL_MGT_SEG_UPGRADE_H
    WHERE  chart_of_accounts_id = X_Chart_Of_Accounts_id;

    IF (l_assign_complete_flag <> 'N') THEN
      RAISE assign_complete_error;
    ELSIF (l_max_proc_batch_id IS NULL) THEN
      RAISE max_processed_error;
    END IF;

    -- Acquire user name lock GL_MGT_SEG_<coa_id> in exclusive mode
    lock_name := lock_name_prefix || to_char(X_Chart_Of_Accounts_Id);

    lock_op_succeeded := request_lock(X_Chart_Of_Accounts_Id, DBMS_LOCK.x_mode,
                                      60, TRUE, 10, 120);
    IF (NOT lock_op_succeeded) THEN
      RAISE user_lock_error;
    END IF;

    GL_MESSAGE.write_log('SHRD0209', 1, 'USERLOCK', lock_name);

    -- Process batches in GL_MGT_SEG_UPGRADE
    INSERT INTO GL_JE_SEGMENT_VALUES
      (je_header_id, segment_type_code, segment_value, creation_date,
       created_by, last_update_date, last_updated_by, last_update_login)
    SELECT l.je_header_id, 'M',
           decode(l_mgt_seg_column_name, 'SEGMENT1', cc.segment1,
                                         'SEGMENT2', cc.segment2,
                                         'SEGMENT3', cc.segment3,
                                         'SEGMENT4', cc.segment4,
                                         'SEGMENT5', cc.segment5,
                                         'SEGMENT6', cc.segment6,
                                         'SEGMENT7', cc.segment7,
                                         'SEGMENT8', cc.segment8,
                                         'SEGMENT9', cc.segment9,
                                         'SEGMENT10', cc.segment10,
                                         'SEGMENT11', cc.segment11,
                                         'SEGMENT12', cc.segment12,
                                         'SEGMENT13', cc.segment13,
                                         'SEGMENT14', cc.segment14,
                                         'SEGMENT15', cc.segment15,
                                         'SEGMENT16', cc.segment16,
                                         'SEGMENT17', cc.segment17,
                                         'SEGMENT18', cc.segment18,
                                         'SEGMENT19', cc.segment19,
                                         'SEGMENT20', cc.segment20,
                                         'SEGMENT21', cc.segment21,
                                         'SEGMENT22', cc.segment22,
                                         'SEGMENT23', cc.segment23,
                                         'SEGMENT24', cc.segment24,
                                         'SEGMENT25', cc.segment25,
                                         'SEGMENT26', cc.segment26,
                                         'SEGMENT27', cc.segment27,
                                         'SEGMENT28', cc.segment28,
                                         'SEGMENT29', cc.segment29,
                                         'SEGMENT30', cc.segment30),
           sysdate, l_user_id, sysdate, l_user_id, l_login_id
    FROM   GL_MGT_SEG_UPGRADE MSU,
           GL_JE_HEADERS H,
           GL_JE_LINES L,
           GL_CODE_COMBINATIONS CC
    WHERE  msu.chart_of_accounts_id = X_Chart_Of_Accounts_Id
    AND    h.je_batch_id = msu.je_batch_id
    AND    l.je_header_id = h.je_header_id
    AND    cc.code_combination_id = l.code_combination_id
    GROUP BY
           l.je_header_id,
           decode(l_mgt_seg_column_name, 'SEGMENT1', cc.segment1,
                                         'SEGMENT2', cc.segment2,
                                         'SEGMENT3', cc.segment3,
                                         'SEGMENT4', cc.segment4,
                                         'SEGMENT5', cc.segment5,
                                         'SEGMENT6', cc.segment6,
                                         'SEGMENT7', cc.segment7,
                                         'SEGMENT8', cc.segment8,
                                         'SEGMENT9', cc.segment9,
                                         'SEGMENT10', cc.segment10,
                                         'SEGMENT11', cc.segment11,
                                         'SEGMENT12', cc.segment12,
                                         'SEGMENT13', cc.segment13,
                                         'SEGMENT14', cc.segment14,
                                         'SEGMENT15', cc.segment15,
                                         'SEGMENT16', cc.segment16,
                                         'SEGMENT17', cc.segment17,
                                         'SEGMENT18', cc.segment18,
                                         'SEGMENT19', cc.segment19,
                                         'SEGMENT20', cc.segment20,
                                         'SEGMENT21', cc.segment21,
                                         'SEGMENT22', cc.segment22,
                                         'SEGMENT23', cc.segment23,
                                         'SEGMENT24', cc.segment24,
                                         'SEGMENT25', cc.segment25,
                                         'SEGMENT26', cc.segment26,
                                         'SEGMENT27', cc.segment27,
                                         'SEGMENT28', cc.segment28,
                                         'SEGMENT29', cc.segment29,
                                         'SEGMENT30', cc.segment30);

    GL_MESSAGE.write_log('MGTS0008', 1, 'BATCHID', l_max_proc_batch_id);

    -- Process batches beyond max_processed_batch_id
    INSERT INTO GL_JE_SEGMENT_VALUES
      (je_header_id, segment_type_code, segment_value, creation_date,
       created_by, last_update_date, last_updated_by, last_update_login)
    SELECT l.je_header_id, 'M',
           decode(l_mgt_seg_column_name, 'SEGMENT1', cc.segment1,
                                         'SEGMENT2', cc.segment2,
                                         'SEGMENT3', cc.segment3,
                                         'SEGMENT4', cc.segment4,
                                         'SEGMENT5', cc.segment5,
                                         'SEGMENT6', cc.segment6,
                                         'SEGMENT7', cc.segment7,
                                         'SEGMENT8', cc.segment8,
                                         'SEGMENT9', cc.segment9,
                                         'SEGMENT10', cc.segment10,
                                         'SEGMENT11', cc.segment11,
                                         'SEGMENT12', cc.segment12,
                                         'SEGMENT13', cc.segment13,
                                         'SEGMENT14', cc.segment14,
                                         'SEGMENT15', cc.segment15,
                                         'SEGMENT16', cc.segment16,
                                         'SEGMENT17', cc.segment17,
                                         'SEGMENT18', cc.segment18,
                                         'SEGMENT19', cc.segment19,
                                         'SEGMENT20', cc.segment20,
                                         'SEGMENT21', cc.segment21,
                                         'SEGMENT22', cc.segment22,
                                         'SEGMENT23', cc.segment23,
                                         'SEGMENT24', cc.segment24,
                                         'SEGMENT25', cc.segment25,
                                         'SEGMENT26', cc.segment26,
                                         'SEGMENT27', cc.segment27,
                                         'SEGMENT28', cc.segment28,
                                         'SEGMENT29', cc.segment29,
                                         'SEGMENT30', cc.segment30),
           sysdate, l_user_id, sysdate, l_user_id, l_login_id
    FROM   GL_JE_BATCHES B,
           GL_JE_HEADERS H,
           GL_JE_LINES L,
           GL_CODE_COMBINATIONS CC
    WHERE  b.je_batch_id > l_max_proc_batch_id
    AND    b.chart_of_accounts_id = X_Chart_Of_Accounts_Id
    AND    h.je_batch_id = b.je_batch_id
    AND    l.je_header_id = h.je_header_id
    AND    cc.code_combination_id = l.code_combination_id
    GROUP BY
           l.je_header_id,
           decode(l_mgt_seg_column_name, 'SEGMENT1', cc.segment1,
                                         'SEGMENT2', cc.segment2,
                                         'SEGMENT3', cc.segment3,
                                         'SEGMENT4', cc.segment4,
                                         'SEGMENT5', cc.segment5,
                                         'SEGMENT6', cc.segment6,
                                         'SEGMENT7', cc.segment7,
                                         'SEGMENT8', cc.segment8,
                                         'SEGMENT9', cc.segment9,
                                         'SEGMENT10', cc.segment10,
                                         'SEGMENT11', cc.segment11,
                                         'SEGMENT12', cc.segment12,
                                         'SEGMENT13', cc.segment13,
                                         'SEGMENT14', cc.segment14,
                                         'SEGMENT15', cc.segment15,
                                         'SEGMENT16', cc.segment16,
                                         'SEGMENT17', cc.segment17,
                                         'SEGMENT18', cc.segment18,
                                         'SEGMENT19', cc.segment19,
                                         'SEGMENT20', cc.segment20,
                                         'SEGMENT21', cc.segment21,
                                         'SEGMENT22', cc.segment22,
                                         'SEGMENT23', cc.segment23,
                                         'SEGMENT24', cc.segment24,
                                         'SEGMENT25', cc.segment25,
                                         'SEGMENT26', cc.segment26,
                                         'SEGMENT27', cc.segment27,
                                         'SEGMENT28', cc.segment28,
                                         'SEGMENT29', cc.segment29,
                                         'SEGMENT30', cc.segment30);

    GL_MESSAGE.write_log('MGTS0009', 1, 'BATCHID', l_max_proc_batch_id);

    -- Get COA structure code and management segment name
    SELECT st.id_flex_structure_code, sg.segment_name
    INTO   struct_code, seg_name
    FROM   FND_ID_FLEX_STRUCTURES ST,
           FND_ID_FLEX_SEGMENTS   SG
    WHERE  st.application_id = 101
    AND    st.id_flex_code = 'GL#'
    AND    st.id_flex_num = X_Chart_Of_Accounts_Id
    AND    sg.application_id = 101
    AND    sg.id_flex_code = 'GL#'
    AND    sg.id_flex_num = X_Chart_Of_Accounts_Id
    AND    sg.application_column_name = l_mgt_seg_column_name;

    -- Setup FND info and assign the management segment qualifier
    FND_FLEX_KEY_API.set_session_mode('customer_data');
    flexfield := FND_FLEX_KEY_API.find_flexfield('SQLGL', 'GL#');
    structure := FND_FLEX_KEY_API.find_structure(flexfield, struct_code);
    segment   := FND_FLEX_KEY_API.find_segment(flexfield, structure, seg_name);
    FND_FLEX_KEY_API.assign_qualifier(flexfield, structure, segment,
                                      'GL_MANAGEMENT', 'Y');

    -- Update GL_LEDGERS
    UPDATE GL_LEDGERS
    SET    mgt_seg_column_name = l_mgt_seg_column_name,
           mgt_seg_value_set_id = segment.value_set_id
    WHERE  chart_of_accounts_id = X_Chart_Of_Accounts_Id;

    -- Assignment completed
    UPDATE GL_MGT_SEG_UPGRADE_H
    SET    assign_complete_flag = 'Y',
           max_processed_batch_id = null,
           max_batch_id = null
    WHERE  chart_of_accounts_id = X_Chart_Of_Accounts_Id;

    COMMIT;

    -- Submit the Compile Flexfield program
    request_id := FND_REQUEST.submit_request(
                    application => 'FND',
                    program => 'FDFCMPK',
                    argument1 => 'K',
                    argument2 => 'SQLGL',
                    argument3 => 'GL#',
                    argument4 => X_Chart_Of_Accounts_Id);

    IF (request_id = 0) THEN
      RAISE request_error;
    ELSE
      GL_MESSAGE.write_log('SHRD0121', 1, 'REQ_ID', to_char(request_id));
    END IF;

    -- Release user name lock GL_MGT_SEG_<coa_id>
    lock_op_succeeded := release_lock(X_Chart_Of_Accounts_Id);

    -- Clean up tracking data in GL_MGT_SEG_UPGRADE
    DELETE FROM GL_MGT_SEG_UPGRADE
    WHERE  chart_of_accounts_id = X_Chart_Of_Accounts_Id;

    GL_MESSAGE.func_succ(api_name || '.' || fn_name);
  EXCEPTION
    WHEN max_processed_error THEN
      GL_MESSAGE.write_log('MGTS0004');
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
    WHEN assign_complete_error THEN
      GL_MESSAGE.write_log('MGTS0002');
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '1';
    WHEN user_lock_error THEN
      GL_MESSAGE.write_log('MGTS0005', 1, 'USERLOCK', lock_name);
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
    WHEN request_error THEN
      lock_op_succeeded := release_lock(X_Chart_Of_Accounts_Id);
      GL_MESSAGE.write_log('SHRD0055', 1, 'ROUTINE', fn_name);
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
    WHEN others THEN
      lock_op_succeeded := release_lock(X_Chart_Of_Accounts_Id);
      FND_FILE.put_line(FND_FILE.LOG, SQLERRM);
      GL_MESSAGE.func_fail(api_name || '.' || fn_name);
      X_Retcode := '2';
  END Assign_Management_Segment;


END GL_MANAGEMENT_SEGMENT_UPGRADE;

/
