--------------------------------------------------------
--  DDL for Package Body GL_AUTOPOST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTOPOST_PKG" AS
/* $Header: glijeapb.pls 120.6 2006/05/25 15:24:59 abhjoshi noship $ */

  --
  -- PRIVATE FUNCTIONS
  --
  PROCEDURE Debug_Print_Var(X_Variable           IN VARCHAR2,
                            X_Value              IN VARCHAR2)
  IS
  BEGIN
    raise_application_error(-20000,X_Variable||' =' ||X_Value);
--+   dbms_output.put_line(X_Variable||' = '||X_Value);
    return;
  END Debug_Print_Var;

  PROCEDURE Debug_Print_Msg(X_Message   IN VARCHAR2)
  IS
  BEGIN
    raise_application_error(-20000, X_Message);
--+   dbms_output.put_line(X_Message);
    return;
  END Debug_Print_Msg;

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Procedure
  --   Post_Batches
  -- Purpose
  --   Post batches based on specified criteria.
  -- Details
  --   This API can be used to post batches based on many different criteria:
  --   batch id, source, category, actual_flag, period_name, batch name ...
  -- History
  --   11-11-01   O Monnier		Created
  -- Arguments
  --   X_Request_Id		The posting request id
  --   X_Count_Sel_Bat	        The number of batches selected for posting
  PROCEDURE Post_Batches(X_Request_Id           OUT NOCOPY NUMBER,
                         X_Count_Sel_Bat        OUT NOCOPY NUMBER,
                         X_Access_Set_Id        IN NUMBER,
                         X_Ledger_Id		IN NUMBER,
                         X_Je_Batch_Id          IN NUMBER DEFAULT NULL,
                         X_Je_Source_Name       IN VARCHAR2 DEFAULT NULL,
                         X_Je_Category_Name     IN VARCHAR2 DEFAULT NULL,
                         X_Actual_Flag          IN VARCHAR2 DEFAULT NULL,
                         X_Period_Name          IN VARCHAR2 DEFAULT NULL,
                         X_From_Day_Before      IN NUMBER DEFAULT NULL,
                         X_To_Day_After         IN NUMBER DEFAULT NULL,
                         X_Name                 IN VARCHAR2 DEFAULT NULL,
                         X_Description          IN VARCHAR2 DEFAULT NULL,
                         X_Debug_Mode           IN BOOLEAN DEFAULT FALSE
                        )
  IS
    CURSOR retrieve_ledger_info (p_ledger_id NUMBER) IS
      SELECT chart_of_accounts_id,
             enable_budgetary_control_flag,
             enable_automatic_tax_flag,
             enable_je_approval_flag,
             GL_JE_POSTING_S.nextval
      FROM GL_LEDGERS
      WHERE ledger_id = p_ledger_id;

   CURSOR single_ledger (p_posting_run_id NUMBER) IS
     SELECT max(JEH.ledger_id)
     FROM   GL_JE_BATCHES JEB,
            GL_JE_HEADERS JEH
     WHERE  JEB.status = 'S'
     AND    JEB.posting_run_id = p_posting_run_id
     AND    JEH.je_batch_id = JEB.je_batch_id
     GROUP BY JEB.posting_run_id
     HAVING count(distinct JEH.ledger_id) = 1;

   CURSOR alc_exists (p_posting_run_id NUMBER) IS
     SELECT '1'
     FROM   GL_JE_BATCHES JEB,
            GL_JE_HEADERS JEH
     WHERE  JEB.status = 'S'
     AND    JEB.posting_run_id = p_posting_run_id
     AND    JEH.je_batch_id = JEB.je_batch_id
     AND    JEH.actual_flag <> 'B'
     AND    JEH.reversed_je_header_id IS NULL
     AND EXISTS
       (SELECT 1
        FROM   GL_LEDGER_RELATIONSHIPS LRL
        WHERE  LRL.source_ledger_id = JEH.ledger_id
        AND    LRL.target_ledger_category_code = 'ALC'
        AND    LRL.relationship_type_code IN ('JOURNAL', 'SUBLEDGER')
        AND    LRL.application_id = 101
        AND    LRL.relationship_enabled_flag = 'Y'
        AND    JEH.je_source NOT IN
          (SELECT INC.je_source_name
           FROM   GL_JE_INCLUSION_RULES INC
           WHERE  INC.je_rule_set_id =
                     LRL.gl_je_conversion_set_id
           AND    INC.je_source_name = JEH.je_source
           AND    INC.je_category_name = 'Other'
           AND    INC.include_flag = 'N'
           AND    INC.user_updatable_flag = 'N'));

    TYPE EmpCurTyp IS REF CURSOR;     -- define weak REF CURSOR type
    get_batches_cur   EmpCurTyp;      -- declare cursor variable
    sqlstmt                           VARCHAR2(5000);

    v_ledger_id                       VARCHAR2(15);
    v_chart_of_accounts_id            NUMBER(15);
    v_enable_bc_flag                  VARCHAR2(1);
    v_automatic_tax_flag              VARCHAR2(1);
    v_je_approval_flag                VARCHAR2(1);
    v_posting_run_id                  NUMBER(15);
    v_single_ledger_id                NUMBER(15);
    v_debug_flag                      VARCHAR2(1) := '';

    add_or                            BOOLEAN;

    v_je_batch_id                     NUMBER(15);
    v_status                          VARCHAR2(1);
    v_default_period_name             VARCHAR2(15);
    v_actual_flag                     VARCHAR2(1);
    v_b_request_id                    NUMBER(15);

    call_status                       BOOLEAN;
    rphase                            VARCHAR2(80);
    rstatus                           VARCHAR2(80);
    dphase                            VARCHAR2(30);
    dstatus                           VARCHAR2(30);
    message                           VARCHAR2(240);
    dummy                             VARCHAR2(1);

    v_count_sel_bat                   NUMBER(15) := 0;
    v_request_id                      NUMBER(15) := 0;
    ok_to_update_batch                BOOLEAN;

    INVALID_LEDGER_ID                 EXCEPTION;
    REQUEST_FAILED                    EXCEPTION;

  BEGIN
    -- Debug Mode - Print the parameters passed
    IF (X_Debug_Mode) THEN
      Debug_Print_Var('X_Ledger_Id',X_Ledger_Id);
      Debug_Print_Var('X_Access_Set_Id',X_Access_Set_Id);
      Debug_Print_Var('X_Je_Batch_Id',X_Je_Batch_Id);
      Debug_Print_Var('X_Je_Source_Name',X_Je_Source_Name);
      Debug_Print_Var('X_Je_Category_Name',X_Je_Category_Name);
      Debug_Print_Var('X_Actual_Flag',X_Actual_Flag);
      Debug_Print_Var('X_Period_Name',X_Period_Name);
      Debug_Print_Var('X_From_Day_Before',X_From_Day_Before);
      Debug_Print_Var('X_To_Day_After',X_To_Day_After);
      Debug_Print_Var('X_Name',X_Name);
      Debug_Print_Var('X_Description',X_Description);
      Debug_Print_Msg('X_Debug_Mode = TRUE');
      Debug_Print_Msg('');
    END IF;

    -- Get the Ledger information and the posting_run_id
    OPEN retrieve_ledger_info (X_Ledger_Id);

    FETCH retrieve_ledger_info INTO v_chart_of_accounts_id,
                                 v_enable_bc_flag,
                                 v_automatic_tax_flag,
                                 v_je_approval_flag,
                                 v_posting_run_id;

    IF (retrieve_ledger_info%NOTFOUND) THEN
      CLOSE retrieve_ledger_info;
      RAISE INVALID_LEDGER_ID;
    ELSE
      CLOSE retrieve_ledger_info;
    END IF;

    -- Debug Mode
    IF (X_Debug_Mode) THEN
      Debug_Print_Var('v_chart_of_accounts_id',v_chart_of_accounts_id);
      Debug_Print_Var('v_enable_bc_flag',v_enable_bc_flag);
      Debug_Print_Var('v_automatic_tax_flag',v_automatic_tax_flag);
      Debug_Print_Var('v_je_approval_flag',v_je_approval_flag);
      Debug_Print_Var('v_posting_run_id',v_posting_run_id);
      Debug_Print_Msg('');
    END IF;

    -- Temp buffer for Ledger ID information
    v_ledger_id := TO_CHAR(X_Ledger_Id,'FM999999999999999');

    -- Construct the Dynamic SQL to select journal batches based on the
    -- parameter passed to the function.
    -- In order to be selected, all batches must be:
    -- unposted
    -- if defined, the control total must be the same as the running total
    -- added budgetary_control_status filter for the bug 5003755.
    sqlstmt := '
SELECT b.je_batch_id,
    b.status,
    b.default_period_name,
    b.actual_flag,
    b.request_id
FROM gl_je_batches b
WHERE (b.status < ''P'' OR b.status > ''P'')
AND b.status_verified = ''N''
AND b.budgetary_control_status != ''I''
AND greatest(nvl(b.running_total_dr,0),nvl(b.running_total_cr,0)) =
      decode(b.control_total,null, greatest(nvl(b.running_total_dr,0),
        nvl(b.running_total_cr,0)), b.control_total) ';

    -- If Journal Approval is enabled, the Journal must have been approved
    IF (v_je_approval_flag = 'Y') THEN
      sqlstmt := sqlstmt
                     ||'AND (b.approval_status_code IN (''A'',''Z'')) ';
    END IF;

    -- If the Batch_id is provided
    IF (X_Je_Batch_Id IS NOT NULL) THEN
      sqlstmt := sqlstmt
                     ||'AND b.je_batch_id = '||TO_CHAR(X_Je_Batch_Id,'FM999999999999999')||' ';
    END IF;

    -- If the actual flag is provided
    IF (X_Actual_Flag IS NOT NULL) THEN
      sqlstmt := sqlstmt
                     ||'AND b.actual_flag = '''||X_Actual_Flag||''' ';
    END IF;

    -- If the batch name is provided
    IF (X_Name IS NOT NULL) THEN
      sqlstmt := sqlstmt
                     ||'AND b.name like '''||X_Name||''' ';
    END IF;

    -- If the description is provided
    IF (X_Description IS NOT NULL) THEN
      sqlstmt := sqlstmt
                     ||'AND b.description like '''||X_Description||''' ';
    END IF;

    -- Check at the header level if :
    -- the period are valid
    sqlstmt := sqlstmt||'
AND b.je_batch_id IN
  (SELECT h.je_batch_id
   FROM GL_LEDGERS ledger,
        GL_JE_HEADERS h,
        GL_BUDGETS glb,
        GL_BUDGET_VERSIONS bv,
        GL_PERIOD_STATUSES ps1,
        GL_PERIOD_STATUSES ps2
   WHERE ps2.ledger_id = '||v_ledger_id||'
     AND ps2.application_id = 101
     AND ps1.ledger_id (+) = '||v_ledger_id||'
     AND ps1.application_id (+) = 101
     AND ledger.ledger_id = '||v_ledger_id||'
     AND h.ledger_id = '||v_ledger_id||'
     AND h.period_name = ps2.period_name
     AND ps2.period_year <=
           decode(h.actual_flag,
                  ''E'', ledger.latest_encumbrance_year,
                  ''B'', glb.latest_opened_year,
                  ''A'', decode (ps2.closing_status,''O'',ps2.period_year, -1))
     AND ps2.period_year >=
           decode(h.actual_flag,
                  ''B'', ps1.period_year,
                  ps2.period_year)
     AND b.je_batch_id = h.je_batch_id
     AND h.budget_version_id = bv.budget_version_id (+)
     AND bv.budget_name = glb.budget_name (+)
     AND glb.status (+) != ''F''
     AND ps1.period_name (+) = glb.first_valid_period_name ';

    -- If the actual flag is provided
    IF (X_Actual_Flag IS NOT NULL) THEN
      sqlstmt := sqlstmt
                     ||'AND h.actual_flag = '''||X_Actual_Flag||''' ';
    END IF;

    -- If the period name is provided
    IF (X_Period_Name IS NOT NULL) THEN
      sqlstmt := sqlstmt
                     ||'AND h.period_name = '''||X_Period_Name||''' ';
    END IF;

    -- If Journal Source is provided
    IF (X_Je_Source_Name IS NOT NULL) THEN
      sqlstmt := sqlstmt
                    ||'  AND h.je_source = '''||X_Je_Source_Name||''' ';

    END IF;

    -- Close Check at the header level
    sqlstmt := sqlstmt
                    ||' ) ';

    -- If some date range is provided, check that all the
    -- journal effective dates are within the ranges.
    IF (X_Je_Category_Name IS NOT NULL
        OR X_From_Day_Before IS NOT NULL
        OR X_To_Day_After IS NOT NULL) THEN

      add_or := FALSE;

      sqlstmt := sqlstmt||'
AND NOT EXISTS (SELECT 1
                FROM GL_JE_HEADERS h
                WHERE h.je_batch_id = b.je_batch_id
                  AND (';

      IF (X_Je_Category_Name IS NOT NULL) THEN
        sqlstmt := sqlstmt||'h.je_category <> '''||X_Je_Category_Name||''' ';
        add_or := TRUE;
      END IF;

      IF (X_From_Day_Before IS NOT NULL) THEN
        IF (add_or) THEN
          sqlstmt := sqlstmt||' OR ';
        END IF;

        sqlstmt := sqlstmt||'h.default_effective_date <
        (sysdate - '||TO_CHAR(X_From_Day_Before,'FM999999999999999')||') ';
        add_or := TRUE;
      END IF;

      IF (X_To_Day_After IS NOT NULL) THEN
        IF (add_or) THEN
          sqlstmt := sqlstmt||' OR ';
        END IF;

        sqlstmt := sqlstmt||'h.default_effective_date >
        (sysdate + '||TO_CHAR(X_From_Day_Before,'FM999999999999999')||') ';
      END IF;

      sqlstmt := sqlstmt||'))';

    END IF;

    -- Don't select taxable journals if journal tax is not calculated.
    IF (v_automatic_tax_flag = 'Y'
        AND X_Actual_flag = 'A'
        AND X_Je_Source_Name = 'Manual') THEN
      sqlstmt := sqlstmt||'
AND NOT EXISTS (SELECT 1
                FROM GL_JE_HEADERS glh
                WHERE glh.tax_status_code = ''R''
                  AND glh.je_batch_id = b.je_batch_id
                  AND b.actual_flag = ''A''
                  AND glh.currency_code != ''STAT''
                  AND glh.je_source = ''Manual'')';
    END IF;

    -- We need to lock the selected batches
    sqlstmt := sqlstmt
                     ||'
FOR UPDATE OF status, posting_run_id NOWAIT ';

    -- Debug Mode
    IF (X_Debug_Mode) THEN
      Debug_Print_Msg('SQL Statement to select batches:');
      FOR i IN 0..(LENGTHB(sqlstmt)/250) LOOP
        Debug_Print_Msg(SUBSTRB(sqlstmt,i*250+1,250));
      END LOOP;
      Debug_Print_Msg('');
    END IF;

    -- Open the Dynamic SQL to select journal batches
    OPEN get_batches_cur FOR  sqlstmt;

    -- Loop through the selected journal batches
    LOOP
        FETCH get_batches_cur INTO v_je_batch_id,
                                   v_status,
                                   v_default_period_name,
                                   v_actual_flag,
                                   v_b_request_id; -- fetch next row

        EXIT WHEN get_batches_cur%NOTFOUND;  -- exit loop when last row is fetched

        -- process row

        -- If the current batch is in status 'SELECTED' or 'UNDERWAY',
        -- check the Concurrent Request status.
        IF (v_status IN ('S','I')) THEN
          IF (v_b_request_id IS NULL) THEN
            -- This should not happen but just in case
            ok_to_update_batch := FALSE;
          ELSE
            call_status :=
            FND_CONCURRENT.GET_REQUEST_STATUS(v_b_request_id,
                                            null,
                                            null,
                                            rphase,
                                            rstatus,
                                            dphase,
                                            dstatus,
                                            message);

            IF (NOT call_status) THEN
              ok_to_update_batch := FALSE;

            ELSIF (v_status = 'S' AND
                   dphase = 'COMPLETE') THEN
              ok_to_update_batch := TRUE;

            ELSIF (v_status = 'I' AND
                   dphase <> 'RUNNING') THEN
              ok_to_update_batch := TRUE;

            ELSE
              ok_to_update_batch := FALSE;

            END IF;
          END IF;
        ELSE
            ok_to_update_batch := TRUE;
        END IF;

        -- Update Batch Status
        IF (ok_to_update_batch) THEN
          UPDATE gl_je_batches
          SET status = 'S',
              posting_run_id = v_posting_run_id
          WHERE je_batch_id = v_je_batch_id;

          v_count_sel_bat := v_count_sel_bat + 1;
        END IF;

        -- Debug Mode
        IF (X_Debug_Mode) THEN
          IF (ok_to_update_batch) THEN
            Debug_Print_Msg('Batch with ID '||v_je_batch_id||' selected for posting');
          ELSE
            Debug_Print_Msg('Batch with ID '||v_je_batch_id||' is not ok to post');
          END IF;
        END IF;

    END LOOP;

    -- Debug Mode
    IF (X_Debug_Mode) THEN
      Debug_Print_Msg('');
      Debug_Print_Msg('The number of batch selected for posting is :'||v_count_sel_bat);
      Debug_Print_Msg('');
    END IF;

    IF (v_count_sel_bat > 0) THEN

      -- Debug Mode
      IF (X_Debug_Mode) THEN
        v_debug_flag := 'Y';
      END IF;

      -- Set single_ledger_id to the journal ledger id if the batch
      -- has journals only for a single ledger which has no enabled
      -- journal or subledger RCs.
      OPEN single_ledger(v_posting_run_id);
      FETCH single_ledger INTO v_single_ledger_id;
      IF single_ledger%NOTFOUND THEN
        v_single_ledger_id := -99;
      ELSE
        OPEN alc_exists(v_posting_run_id);
        FETCH alc_exists INTO dummy;
        IF alc_exists%FOUND THEN
          v_single_ledger_id := -99;
        END IF;
        CLOSE alc_exists;
      END IF;
      CLOSE single_ledger;

      -- Submit Posting...
      IF (v_single_ledger_id = -99) THEN
          v_request_id :=
            fnd_request.submit_request(
	      'SQLGL', 'GLPPOS', '', '', FALSE,
                To_Char(v_single_ledger_id),
                To_Char(X_access_set_id),
                To_Char(v_chart_of_accounts_id),
                To_Char(v_posting_run_id),
                chr(0),
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','');
      ELSE
          v_request_id :=
            fnd_request.submit_request(
	      'SQLGL', 'GLPPOSS', '', '', FALSE,
                To_Char(v_single_ledger_id),
                To_Char(X_access_set_id),
                To_Char(v_chart_of_accounts_id),
                To_Char(v_posting_run_id),
                chr(0),
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','');
      END IF;

      IF (v_request_id = 0) THEN
        RAISE REQUEST_FAILED;
      END IF;

      -- Update the status of the consolidation batch to 'PS' in
      -- gl_consolidation_history for Consolidation Workbench.
      UPDATE GL_CONSOLIDATION_HISTORY
      SET   status = 'PS',
            request_id = v_request_id
      WHERE je_batch_id IN (SELECT je_batch_id
                            FROM gl_je_batches
                            WHERE posting_run_id = v_posting_run_id
                            AND status = 'S');

      UPDATE GL_ELIMINATION_HISTORY EH
      SET EH.status_code = 'PS',
          EH.request_id = v_request_id
      WHERE EH.je_batch_id IN (SELECT je_batch_id
                               FROM gl_je_batches
                               WHERE posting_run_id = v_posting_run_id
                               AND status = 'S');

    END IF;

    -- Debug Mode
    IF (X_Debug_Mode) THEN
      Debug_Print_Var('X_Request_Id',v_request_id);
      Debug_Print_Var('X_Count_Sel_Bat',v_count_sel_bat);
      Debug_Print_Msg('');
    END IF;

    X_Request_Id := v_request_id;
    X_Count_Sel_Bat := v_count_sel_bat;

  EXCEPTION
    WHEN INVALID_LEDGER_ID THEN
      fnd_message.set_name('SQLGL', 'GL_AUTOPOST_INVALID_LEDGER_ID');

      IF (X_Debug_Mode) THEN
        Debug_Print_Msg(fnd_message.get);
        Debug_Print_Msg(substrb(SQLERRM, 1, 2000));
      END IF;
      app_exception.raise_exception;

    WHEN REQUEST_FAILED THEN
      fnd_message.set_name('SQLGL', 'SHRD0148');

      IF (X_Debug_Mode) THEN
        Debug_Print_Msg(fnd_message.get);
        Debug_Print_Msg(substrb(SQLERRM, 1, 2000));
      END IF;
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_autopost_pkg.post_batches');

      IF (X_Debug_Mode) THEN
        Debug_Print_Msg(fnd_message.get);
        Debug_Print_Msg(substrb(SQLERRM, 1, 2000));
      END IF;
      app_exception.raise_exception;

  END Post_Batches;

END gl_autopost_pkg;


/
