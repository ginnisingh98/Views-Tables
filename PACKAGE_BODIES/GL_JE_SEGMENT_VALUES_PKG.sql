--------------------------------------------------------
--  DDL for Package Body GL_JE_SEGMENT_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JE_SEGMENT_VALUES_PKG" as
/* $Header: glijesvb.pls 120.12.12010000.3 2009/07/03 11:51:24 dthakker ship $ */

  --
  -- PRIVATE VARIABLES
  --

  -- Dynamic sql buffers
  insert_stmt     VARCHAR2(2000);  -- Buffer for insert dynamic sql
  delete_bsv_stmt VARCHAR2(2000);  -- Buffer for delete bsv dynamic sql
  delete_msv_stmt VARCHAR2(2000);  -- Buffer for delete msv dynamic sql

  -- Column names of bsv and msv columns
  bsv_colname     VARCHAR2(30);  -- BSV column name
  msv_colname     VARCHAR2(30);  -- MSV column name


  --
  -- PUBLIC FUNCTIONS
  --
  FUNCTION insert_segment_values( x_je_header_id       NUMBER )
  RETURN NUMBER
  IS
    num_rows    NUMBER;
    user_id     NUMBER;
    login_id    NUMBER;
  BEGIN

    user_id := fnd_profile.value('USER_ID');
    login_id := fnd_profile.value('LOGIN_ID');

    -- Delete all the existing values
    DELETE FROM GL_JE_SEGMENT_VALUES
    WHERE je_header_id = x_je_header_id;

    -- Insert distinct segment values
    INSERT INTO GL_JE_SEGMENT_VALUES
    (je_header_id, segment_type_code, segment_value,
     creation_date, created_by, last_update_date, last_updated_by,
     last_update_login)
    SELECT LINE.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30),
           sysdate, user_id, sysdate, user_id, login_id
    FROM gl_code_combinations CC,
         gl_ledgers LDG,
         gl_je_lines LINE,
         gl_row_multipliers X
    WHERE CC.code_combination_id = LINE.code_combination_id
      AND LDG.ledger_id = LINE.ledger_id
      AND LINE.je_header_id = x_je_header_id
      AND X.multiplier IN (1,Decode(LDG.mgt_seg_column_name,NULL,NULL,2))
    GROUP by LINE.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30);

    -- Return the number of distinct balancing and management segment values inserted.
    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_segment_values_pkg.insert_segment_values');
      RAISE;
  END insert_segment_values;

-- **********************************************************************

  FUNCTION insert_segment_values( x_je_header_id       NUMBER,
                                  x_je_line_num        NUMBER,
                                  x_user_id            NUMBER,
                                  x_login_id           NUMBER)
  RETURN NUMBER
  IS
    num_rows    NUMBER;
  BEGIN
    -- Insert new values only if needed
    INSERT INTO GL_JE_SEGMENT_VALUES
    (je_header_id, segment_type_code, segment_value,
     creation_date, created_by, last_update_date, last_updated_by,
     last_update_login)
    SELECT LINE.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30),
           sysdate, x_user_id, sysdate, x_user_id, x_login_id
    FROM gl_code_combinations CC,
         gl_ledgers LDG,
         gl_je_lines LINE,
         gl_row_multipliers X
    WHERE CC.code_combination_id = LINE.code_combination_id
      AND LDG.ledger_id = LINE.ledger_id
      AND LINE.je_header_id = x_je_header_id
      AND LINE.je_line_num = x_je_line_num
      AND X.multiplier IN (1,Decode(LDG.mgt_seg_column_name,NULL,NULL,2))
      AND NOT EXISTS (SELECT 'X'
                      FROM GL_JE_SEGMENT_VALUES SV
                      WHERE SV.je_header_id = LINE.je_header_id
                        AND SV.segment_type_code = DECODE(X.multiplier,
                                                          1,'B',
                                                          2,'M')
                        AND SV.segment_value = DECODE(DECODE(X.multiplier,
                                                             1,LDG.bal_seg_column_name,
                                                             2,LDG.mgt_seg_column_name),
                                                     'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30));

    -- Return the number of distinct balancing and management segment values inserted.
    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_segment_values_pkg.insert_segment_values');
      RAISE;
  END insert_segment_values;

-- **********************************************************************

  FUNCTION insert_batch_segment_values( x_je_batch_id       NUMBER)
  RETURN NUMBER
  IS
    num_rows    NUMBER;
    user_id     NUMBER;
    login_id    NUMBER;
  BEGIN

    user_id := fnd_profile.value('USER_ID');
    login_id := fnd_profile.value('LOGIN_ID');

    -- Delete all the existing values
    DELETE FROM GL_JE_SEGMENT_VALUES
    WHERE je_header_id IN (SELECT je_header_id
                           FROM GL_JE_HEADERS
                           WHERE je_batch_id = x_je_batch_id);

    -- Insert distinct segment values
    INSERT INTO GL_JE_SEGMENT_VALUES
    (je_header_id, segment_type_code, segment_value,
     creation_date, created_by, last_update_date, last_updated_by,
     last_update_login)
    SELECT LINE.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30),
           sysdate, user_id, sysdate, user_id, login_id
    FROM gl_code_combinations CC,
         gl_ledgers LDG,
         gl_je_lines LINE,
         gl_je_headers JH,
         gl_row_multipliers X
    WHERE CC.code_combination_id = LINE.code_combination_id
      AND LDG.ledger_id = LINE.ledger_id
      AND LINE.je_header_id = JH.je_header_id
      AND JH.je_batch_id = x_je_batch_id
      AND X.multiplier IN (1,Decode(LDG.mgt_seg_column_name,NULL,NULL,2))
    GROUP by LINE.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30);

    -- Return the number of distinct balancing and management segment values inserted.
    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_segment_values_pkg.insert_batch_segment_values');
      RAISE;
  END insert_batch_segment_values;

-- **********************************************************************

  PROCEDURE insert_ccid_segment_values(
              header_id    NUMBER,
              ccid         NUMBER,
              user_id      NUMBER,
              login_id     NUMBER) IS
    temp VARCHAR2(30);
    asid NUMBER;
  BEGIN

    -- Build the statements for the current
    -- chart of accounts
    IF (insert_stmt IS NULL) THEN
      fnd_profile.get('GL_ACCESS_SET_ID', temp);
      asid := to_number(temp);

      SELECT bal_seg_column_name,
             mgt_seg_column_name
      INTO bsv_colname,
           msv_colname
      FROM gl_access_sets acs, gl_ledgers lgr
      WHERE acs.access_set_id = asid
      AND   lgr.chart_of_accounts_id = acs.chart_of_accounts_id
      AND   rownum <= 1;

      IF (bsv_colname IS NOT NULL) AND
            (msv_colname IS NOT NULL) THEN
      insert_stmt :=
        'INSERT INTO gl_je_segment_values ' ||
        '(je_header_id, segment_type_code, ' ||
        ' segment_value, creation_date, created_by, last_update_date, ' ||
        ' last_updated_by, last_update_login) ' ||
        'SELECT :header_id, ' ||
               'decode(ml.multiplier, ' ||
                 '1, ''B'', ''M''), ' ||
               'decode(ml.multiplier, ' ||
                 '1, '|| bsv_colname || ',' ||
                 msv_colname ||
               '), sysdate, :user_id, sysdate, :user_id, :login_id ' ||
        'FROM gl_code_combinations cc, gl_row_multipliers ml '||
        'WHERE cc.code_combination_id = :cc ' ||
        'AND   ml.multiplier between 1 and 2' ||
        'AND NOT EXISTS ' ||
           '(SELECT 1 ' ||
            'FROM gl_je_segment_values sv '||
            'WHERE sv.je_header_id = :header_id '||
            'AND   sv.segment_type_code =  ' ||
                    'decode(ml.multiplier, ' ||
                       '1, ''B'', ''M'') ' ||
            'AND   sv.segment_value = ' ||
                    'decode(ml.multiplier, ' ||
                       '1, '|| bsv_colname || ',' ||
                       msv_colname || ')) ';

      ELSIF (bsv_colname IS NOT NULL) AND
            (msv_colname IS NULL) THEN

       insert_stmt :=
         'INSERT INTO gl_je_segment_values ' ||
         '(je_header_id, segment_type_code, ' ||
        ' segment_value, creation_date, created_by, last_update_date, ' ||
        ' last_updated_by, last_update_login) ' ||
         'SELECT :header_id, ' ||'''B'''||', '
                  ||bsv_colname || ' ' ||
               ', sysdate, :user_id, sysdate, :user_id, :login_id ' ||
         'FROM gl_code_combinations cc '||
         'WHERE cc.code_combination_id = :cc ' ||
         'AND NOT EXISTS ' ||
            '(SELECT 1 ' ||
            'FROM gl_je_segment_values sv '||
            'WHERE sv.je_header_id = :header_id '||
            'AND   sv.segment_type_code =  ''B''' ||
            'AND   sv.segment_value =  '
                       || bsv_colname || ')';

      END IF;
    END IF;

    EXECUTE IMMEDIATE insert_stmt USING header_id, user_id, user_id,
                      login_id, ccid, header_id;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_segment_values.add_segment_value');
      RAISE;
  END insert_ccid_segment_values;

-- **********************************************************************

  FUNCTION delete_segment_values(x_je_header_id       NUMBER)
  RETURN NUMBER
  IS
    num_rows    NUMBER;
  BEGIN
    DELETE FROM GL_JE_SEGMENT_VALUES sv
    WHERE sv.je_header_id = x_je_header_id;

    -- Return the number of distinct balancing and management segment values deleted
    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_segment_values_pkg.delete_header_segment_values');
      RAISE;
  END delete_segment_values;

-- **********************************************************************

  FUNCTION delete_batch_segment_values(x_je_batch_id       NUMBER)
  RETURN NUMBER
  IS
    num_rows    NUMBER;
  BEGIN
    DELETE FROM GL_JE_SEGMENT_VALUES SV
    WHERE SV.je_header_id IN (SELECT JH.je_header_id
                              FROM GL_JE_HEADERS JH
                              WHERE JH.je_batch_id = x_je_batch_id);

    -- Return the number of distinct balancing and management segment values deleted
    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_segment_values_pkg.delete_batch_segment_values');
      RAISE;
  END delete_batch_segment_values;

-- **********************************************************************

  PROCEDURE cleanup_segment_values(
              header_id NUMBER) IS
  BEGIN
    -- Build the statements for the current
    -- chart of accounts
    IF (delete_bsv_stmt IS NULL) THEN
      SELECT bal_seg_column_name,
             mgt_seg_column_name
      INTO bsv_colname,
           msv_colname
      FROM gl_je_headers jeh, gl_ledgers lgr
      WHERE jeh.je_header_id = header_id
      AND   lgr.ledger_id = jeh.ledger_id;

      -- Bug fix 6761820.
      -- Modified the statement to handle the balancing segment value ' '.
      delete_bsv_stmt :=
        'DELETE FROM gl_je_segment_values sv ' ||
        'WHERE sv.segment_type_code = ''B'' ' ||
        'AND   sv.je_header_id = :header_id ' ||
        'AND ((sv.segment_value <> '' '' AND NOT EXISTS ' ||
               '(SELECT 1 '||
               'FROM gl_je_lines jel, gl_code_combinations cc '||
               'WHERE jel.je_header_id = :header_id '||
               'AND   cc.code_combination_id = jel.code_combination_id '||
               'AND   cc.'|| bsv_colname || ' = sv.segment_value)) ' ||
              'OR (sv.segment_value = '' '' and NOT EXISTS ' ||
                   '(SELECT 1 FROM gl_je_lines jel ' ||
                    'WHERE jel.je_header_id = :header_id ' ||
                    'AND   jel.code_combination_id in (-1,-2,-3))))';

    END IF;

    EXECUTE IMMEDIATE delete_bsv_stmt USING header_id, header_id, header_id;

    IF (msv_colname IS NOT NULL) THEN
      -- Bug fix 6761820.
      -- Modified the statement to handle the management segment value ' '.
      delete_msv_stmt :=
        'DELETE FROM gl_je_segment_values sv ' ||
        'WHERE sv.segment_type_code = ''M'' ' ||
        'AND   sv.je_header_id = :header_id ' ||
        'AND ((sv.segment_value <> '' '' AND NOT EXISTS ' ||
               '(SELECT 1 ' ||
               'FROM gl_je_lines jel, gl_code_combinations cc ' ||
               'WHERE jel.je_header_id = :header_id ' ||
               'AND   cc.code_combination_id = jel.code_combination_id ' ||
               'AND   cc.'|| msv_colname || ' = sv.segment_value)) ' ||
              'OR (sv.segment_value = '' '' and NOT EXISTS ' ||
                   '(SELECT 1 FROM gl_je_lines jel ' ||
                    'WHERE jel.je_header_id = :header_id ' ||
                    'AND   jel.code_combination_id in (-1,-2,-3))))';

      EXECUTE IMMEDIATE delete_msv_stmt USING header_id, header_id, header_id;

    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_segment_values.add_segment_value');
      RAISE;
  END cleanup_segment_values;

-- **********************************************************************

  FUNCTION insert_alc_segment_values( x_prun_id            NUMBER,
                                      x_last_updated_by    NUMBER,
                                      x_last_update_login  NUMBER )
  RETURN NUMBER
  IS
    num_rows    NUMBER;
  BEGIN

    -- Insert distinct segment values
    INSERT INTO GL_JE_SEGMENT_VALUES
    (je_header_id, segment_type_code, segment_value, creation_date,
     created_by, last_update_date, last_updated_by, last_update_login)
    SELECT LINE.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30),
           sysdate, x_last_updated_by, sysdate,
           x_last_updated_by, x_last_update_login
    FROM gl_je_batches JB,
         gl_je_headers JH,
         gl_je_lines LINE,
         gl_code_combinations CC,
         gl_ledgers LDG,
         gl_row_multipliers X
    WHERE JB.posting_run_id = x_prun_id
      AND JB.status = 'I'
      AND JH.je_batch_id = JB.je_batch_id
      AND JH.display_alc_journal_flag = 'N'
      AND JH.parent_je_header_id IS NOT NULL
      AND LINE.je_header_id = JH.je_header_id
      AND LDG.ledger_id = JH.ledger_id
      AND CC.code_combination_id = LINE.code_combination_id
      AND X.multiplier IN (1,Decode(LDG.mgt_seg_column_name,NULL,NULL,2))
    GROUP by LINE.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30);

    -- Return the number of distinct balancing and management segment values inserted.
    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_segment_values_pkg.insert_alc_segment_values');
      RAISE;
  END insert_alc_segment_values;

-- **********************************************************************

  FUNCTION insert_gen_line_segment_values( x_je_header_id       NUMBER,
                                           x_from_je_line_num   NUMBER,
                                           x_last_updated_by    NUMBER,
                                           x_last_update_login  NUMBER )
  RETURN NUMBER
  IS
    num_rows    NUMBER;
  BEGIN
    -- Insert new values only if needed
    INSERT INTO GL_JE_SEGMENT_VALUES
    (je_header_id, segment_type_code, segment_value, creation_date,
     created_by, last_update_date, last_updated_by, last_update_login)
    SELECT LINE.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30),
           sysdate, x_last_updated_by, sysdate,
           x_last_updated_by, x_last_update_login
    FROM gl_je_headers JH,
         gl_je_lines LINE,
         gl_ledgers LDG,
         gl_code_combinations CC,
         gl_row_multipliers X
    WHERE JH.je_header_id = x_je_header_id
      AND JH.display_alc_journal_flag IS NULL
      AND LINE.je_header_id = x_je_header_id
      AND LINE.je_line_num >= x_from_je_line_num
      AND LDG.ledger_id = LINE.ledger_id
      AND CC.code_combination_id = LINE.code_combination_id
      AND X.multiplier IN (1,Decode(LDG.mgt_seg_column_name,NULL,NULL,2))
      AND NOT EXISTS (SELECT 'X'
                      FROM GL_JE_SEGMENT_VALUES SV
                      WHERE SV.je_header_id = LINE.je_header_id
                        AND SV.segment_type_code = DECODE(X.multiplier,
                                                          1,'B',
                                                          2,'M')
                        AND SV.segment_value = DECODE(DECODE(X.multiplier,
                                                             1,LDG.bal_seg_column_name,
                                                             2,LDG.mgt_seg_column_name),
                                                     'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30))
    GROUP by LINE.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30);


    -- Return the number of distinct balancing and management segment values inserted.
    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_segment_values_pkg.insert_gen_line_segment_values');
      RAISE;
  END insert_gen_line_segment_values;

-- **********************************************************************

  FUNCTION insert_sl_segment_values( x_prun_id           NUMBER,
                                     x_last_updated_by   NUMBER,
                                     x_last_update_login NUMBER )
  RETURN NUMBER
  IS
    num_rows    NUMBER;
  BEGIN

    -- Insert distinct segment values
    INSERT INTO GL_JE_SEGMENT_VALUES
    (je_header_id, segment_type_code, segment_value, creation_date,
     created_by, last_update_date, last_updated_by, last_update_login)
    SELECT SLJEL.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30),
           sysdate, x_last_updated_by, sysdate,
           x_last_updated_by, x_last_update_login
    FROM gl_je_batches JEB,
         gl_je_headers JEH,
         gl_je_headers SLJEH,
         gl_je_lines SLJEL,
         gl_code_combinations CC,
         gl_ledgers LDG,
         gl_row_multipliers X
    WHERE JEB.posting_run_id = x_prun_id
      AND JEB.status = 'I'
      AND JEH.je_batch_id = JEB.je_batch_id
      AND JEH.reversed_je_header_id IS NULL -- added for bug8611602
      AND SLJEH.parent_je_header_id = JEH.je_header_id
      AND SLJEH.display_alc_journal_flag IS NULL
      AND SLJEL.je_header_id = SLJEH.je_header_id
      AND LDG.ledger_id = SLJEH.ledger_id
      AND CC.code_combination_id = SLJEL.code_combination_id
      AND X.multiplier IN (1,Decode(LDG.mgt_seg_column_name,NULL,NULL,2))
    GROUP by SLJEL.je_header_id,
           DECODE(X.multiplier,
                  1,'B',
                  2,'M'),
           DECODE(DECODE(X.multiplier,
                         1,LDG.bal_seg_column_name,
                         2,LDG.mgt_seg_column_name), 'SEGMENT1',cc.SEGMENT1,
                                                     'SEGMENT2',cc.SEGMENT2,
                                                     'SEGMENT3',cc.SEGMENT3,
                                                     'SEGMENT4',cc.SEGMENT4,
                                                     'SEGMENT5',cc.SEGMENT5,
                                                     'SEGMENT6',cc.SEGMENT6,
                                                     'SEGMENT7',cc.SEGMENT7,
                                                     'SEGMENT8',cc.SEGMENT8,
                                                     'SEGMENT9',cc.SEGMENT9,
                                                     'SEGMENT10',cc.SEGMENT10,
                                                     'SEGMENT11',cc.SEGMENT11,
                                                     'SEGMENT12',cc.SEGMENT12,
                                                     'SEGMENT13',cc.SEGMENT13,
                                                     'SEGMENT14',cc.SEGMENT14,
                                                     'SEGMENT15',cc.SEGMENT15,
                                                     'SEGMENT16',cc.SEGMENT16,
                                                     'SEGMENT17',cc.SEGMENT17,
                                                     'SEGMENT18',cc.SEGMENT18,
                                                     'SEGMENT19',cc.SEGMENT19,
                                                     'SEGMENT20',cc.SEGMENT20,
                                                     'SEGMENT21',cc.SEGMENT21,
                                                     'SEGMENT22',cc.SEGMENT22,
                                                     'SEGMENT23',cc.SEGMENT23,
                                                     'SEGMENT24',cc.SEGMENT24,
                                                     'SEGMENT25',cc.SEGMENT25,
                                                     'SEGMENT26',cc.SEGMENT26,
                                                     'SEGMENT27',cc.SEGMENT27,
                                                     'SEGMENT28',cc.SEGMENT28,
                                                     'SEGMENT29',cc.SEGMENT29,
                                                     'SEGMENT30',cc.SEGMENT30);


    -- Return the number of distinct balancing and management segment values inserted.
    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_segment_values_pkg.insert_sl_segment_values');
      RAISE;
  END insert_sl_segment_values;

END GL_JE_SEGMENT_VALUES_PKG;

/
