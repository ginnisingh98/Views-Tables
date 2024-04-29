--------------------------------------------------------
--  DDL for Package Body GL_CONS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONS_HISTORY_PKG" AS
/* $Header: glicohib.pls 120.23 2005/12/08 10:31:30 mikeward ship $ */


--+
--+ PUBLIC FUNCTIONS
--+

  PROCEDURE Check_Calendar(X_To_Ledger_Id    NUMBER,
                           X_From_Ledger_Id  NUMBER) IS
    CURSOR C1 IS
      SELECT 'x' FROM GL_LEDGERS L1
      WHERE  L1.LEDGER_ID = X_To_Ledger_Id
      AND    L1.PERIOD_SET_NAME =
                (SELECT L2.PERIOD_SET_NAME FROM GL_LEDGERS L2
                 WHERE  L2.LEDGER_ID = X_From_Ledger_Id);

    dummy  VARCHAR(1);

  BEGIN
    OPEN C1;
    FETCH C1 INTO dummy;
    IF (C1%NOTFOUND) THEN
      CLOSE C1;
      fnd_message.set_name('SQLGL','GL_SAME_CALENDAR');
      app_exception.raise_exception;
    END IF;
    CLOSE C1;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','Unhandled Exception');
      fnd_message.set_token('PROCEDURE', 'Check_Unique_User_Type');
      RAISE;
  END Check_Calendar;

  PROCEDURE Get_New_Id(next_val IN OUT NOCOPY NUMBER) IS

  BEGIN
    select GL_CONSOLIDATION_HISTORY_S.NEXTVAL
    into   next_val
    from   dual;

  END Get_New_Id;


/* Name: first_period_of_quarter
 * Desc: Returns the first non-adjusting period of the specified quarter
 */
PROCEDURE first_period_of_quarter(
            LedgerId             NUMBER,
            QuarterNum           NUMBER,
            QuarterYear          NUMBER,
            PeriodName    IN OUT NOCOPY VARCHAR2,
            StartDate     IN OUT NOCOPY DATE,
            ClosingStatus IN OUT NOCOPY VARCHAR2
            ) IS
BEGIN
  SELECT period_name, start_date, closing_status
  INTO   PeriodName, StartDate, ClosingStatus
  FROM   gl_period_statuses
  WHERE  application_id = 101
  AND    ledger_id = LedgerId
  AND    adjustment_period_flag = 'N'
  AND    quarter_num = QuarterNum
  AND    period_year = QuarterYear
  AND    quarter_start_date = start_date;
END first_period_of_quarter;


/* Name: first_period_of_year
 * Desc: Returns the first non-adjusting period of the specified year
 */
PROCEDURE first_period_of_year(
            LedgerId             NUMBER,
            PeriodYear           NUMBER,
            PeriodName    IN OUT NOCOPY VARCHAR2,
            StartDate     IN OUT NOCOPY DATE,
            ClosingStatus IN OUT NOCOPY VARCHAR2
            ) IS
BEGIN
  SELECT period_name, start_date, closing_status
  INTO   PeriodName, StartDate, ClosingStatus
  FROM   gl_period_statuses
  WHERE  application_id = 101
  AND    ledger_id = LedgerId
  AND    adjustment_period_flag = 'N'
  AND    period_year = PeriodYear
  AND    year_start_date = start_date;
END first_period_of_year;


/* Name: insert_average_record
 * Desc: Copy the standard consolidation record for average consolidation.
 */
PROCEDURE insert_average_record(
            SourceRunId         NUMBER,
            TargetRunId         NUMBER,
            AverageToPeriodName VARCHAR2,
            AvgAmountType       VARCHAR2,
            FromDateEntered     DATE
          ) IS
BEGIN
    INSERT INTO GL_CONSOLIDATION_HISTORY(
              consolidation_run_id,
              consolidation_id,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by,
              from_period_name,
              to_period_name,
              to_currency_code,
              method_flag,
              run_easylink_flag,
              run_posting_flag,
              actual_flag,
              from_budget_name,
              to_budget_name,
              from_budget_version_id,
              to_budget_version_id,
              average_consolidation_flag,
              amount_type,
              from_date,
              target_resp_name,
              target_user_name,
              target_database_name
            ) SELECT
              TargetRunId,
              consolidation_id,
              last_update_date,
              last_updated_by,
              last_updated_by,
              last_update_date,
              last_updated_by,
              from_period_name,
              AverageToPeriodName,
              to_currency_code,
              method_flag,
              run_easylink_flag,
              run_posting_flag,
              actual_flag,
              NULL,
              NULL,
              NULL,
              NULL,
              'Y',
              AvgAmountType,
              FromDateEntered,
              target_resp_name,
              target_user_name,
              target_database_name
            FROM  gl_consolidation_history
            WHERE NOT EXISTS (SELECT 1
                              FROM   gl_consolidation_history
                              WHERE  consolidation_run_id = TargetRunId)
            AND   consolidation_run_id = SourceRunId;
END insert_average_record;


/* Name: insert_row
 * Desc: Table handler for insertion.
 */
PROCEDURE Insert_Row(
                       X_Usage_Code                     VARCHAR2,
                       X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Consolidation_Run_Id           NUMBER,
                       X_StdRunId                       IN OUT NOCOPY NUMBER,
                       X_AvgRunId                       IN OUT NOCOPY NUMBER,
                       X_Consolidation_Id               NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_From_Period_Name               VARCHAR2,
                       X_Standard_To_Period_Name        VARCHAR2,
                       X_To_Period_Name                 IN OUT NOCOPY VARCHAR2,
                       X_To_Currency_Code               VARCHAR2,
                       X_Method_Flag                    VARCHAR2,
                       X_Run_Easylink_Flag              VARCHAR2,
                       X_Run_Posting_Flag               VARCHAR2,
                       X_Actual_Flag                    VARCHAR2,
                       X_From_Budget_Name               VARCHAR2,
                       X_To_Budget_Name                 VARCHAR2,
                       X_From_Budget_Version_Id         NUMBER,
                       X_To_Budget_Version_Id           NUMBER,
                       X_Amount_Type_Code               VARCHAR2,
                       X_Amount_Type                    VARCHAR2,
                       X_StdAmountType                  VARCHAR2,
                       X_AvgAmountType                  VARCHAR2,
                       X_From_Date_Entered              DATE,
                       X_From_Date                      IN OUT NOCOPY DATE,
                       X_Average_To_Period_Name         VARCHAR2,
                       X_Target_Resp_Name               VARCHAR2,
                       X_Target_User_Name               VARCHAR2,
                       X_Target_DB_Name                 VARCHAR2
  ) IS
    CURSOR C(Run_Id NUMBER) IS SELECT rowid FROM GL_CONSOLIDATION_HISTORY
                 WHERE consolidation_run_id = Run_Id;
      CURSOR C2 IS SELECT gl_consolidation_history_s.nextval FROM sys.dual;
    TempRowid     VARCHAR2(60);
    TempRunId     NUMBER;
BEGIN
  X_To_Period_Name := X_Standard_To_Period_Name;
  IF (X_StdAmountType = 'EOD') THEN
    X_From_Date := X_From_Date_Entered;
  ELSE
    X_From_Date := NULL;
  END IF;

  IF (X_Usage_Code IN ('S', 'B')) THEN
      INSERT INTO GL_CONSOLIDATION_HISTORY(
              consolidation_run_id,
              consolidation_id,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by,
              from_period_name,
              to_period_name,
              to_currency_code,
              method_flag,
              run_easylink_flag,
              run_posting_flag,
              actual_flag,
              from_budget_name,
              to_budget_name,
              from_budget_version_id,
              to_budget_version_id,
              average_consolidation_flag,
              amount_type,
              from_date,
              target_resp_name,
              target_user_name,
              target_database_name
            ) VALUES (
              X_Consolidation_Run_Id,
              X_Consolidation_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_From_Period_Name,
              X_Standard_To_Period_Name,
              X_To_Currency_Code,
              X_Method_Flag,
              X_Run_Easylink_Flag,
              X_Run_Posting_Flag,
              X_Actual_Flag,
              X_From_Budget_Name,
              X_To_Budget_Name,
              X_From_Budget_Version_Id,
              X_To_Budget_Version_Id,
              'N',
              X_StdAmountType,
              X_From_Date,
              X_Target_Resp_Name,
              X_Target_User_Name,
              X_Target_DB_Name
            );

    OPEN C(X_Consolidation_Run_Id);
    FETCH C INTO X_Rowid;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      Raise NO_DATA_FOUND;
    END IF;
    CLOSE C;

    X_StdRunId := X_Consolidation_Run_Id;
  END IF;

  IF (X_Usage_Code IN ('A', 'B')) THEN
    IF (X_Usage_Code = 'B') THEN
      OPEN C2;
      FETCH C2 INTO TempRunId;
      CLOSE C2;
    ELSE
      TempRunId := X_Consolidation_Run_Id;
    END IF;

    X_AvgRunId := TempRunId;
  END IF;

  IF (X_Usage_Code = 'A') THEN
    INSERT INTO GL_CONSOLIDATION_HISTORY(
              consolidation_run_id,
              consolidation_id,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by,
              from_period_name,
              to_period_name,
              to_currency_code,
              method_flag,
              run_easylink_flag,
              run_posting_flag,
              actual_flag,
              from_budget_name,
              to_budget_name,
              from_budget_version_id,
              to_budget_version_id,
              average_consolidation_flag,
              amount_type,
              from_date,
              target_resp_name,
              target_user_name,
              target_database_name
            ) VALUES (
              TempRunId,
              X_Consolidation_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_From_Period_Name,
              X_Average_To_Period_Name,
              X_To_Currency_Code,
              X_Method_Flag,
              X_Run_Easylink_Flag,
              X_Run_Posting_Flag,
              X_Actual_Flag,
              NULL,
              NULL,
              NULL,
              NULL,
              'Y',
              X_AvgAmountType,
              X_From_Date_Entered,
              X_Target_Resp_Name,
              X_Target_User_Name,
              X_Target_DB_Name
            );

    OPEN C(TempRunId);
    FETCH C INTO TempRowid;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      Raise NO_DATA_FOUND;
    END IF;
    CLOSE C;

    X_Rowid := TempRowId;
    X_From_Date := X_From_Date_Entered;
    X_To_Period_Name := X_Average_To_Period_Name;
  END IF;

END Insert_Row;


  PROCEDURE Insert_Cons_Set_Row(
                        X_Usage_Code                    VARCHAR2,
                        X_Rowid                         VARCHAR2,
                        X_Std_Amounttype                VARCHAR2,
                        X_Avg_Amounttype                VARCHAR2,
                        X_Consolidation_Id              NUMBER,
                        X_Consolidation_Set_Id          NUMBER,
                        X_Last_Updated_By               NUMBER,
                        X_From_Period_Name              VARCHAR2,
                        X_Standard_To_Period_Name       VARCHAR2,
                        X_Average_To_Period_Name        VARCHAR2,
                        X_Average_To_Start_Date         DATE,
                        X_To_Currency_Code              VARCHAR2,
                        X_Method_Flag                   VARCHAR2,
                        X_Run_Journal_Import_Flag       VARCHAR2,
                        X_Audit_Mode_Flag               VARCHAR2,
                        X_Summary_Journals_Flag         VARCHAR2,
                        X_Run_Posting_Flag              VARCHAR2,
                        X_Actual_Flag                   VARCHAR2,
                        X_Consolidation_Name            VARCHAR2,
                        X_From_Date_Entered             DATE,
                        X_From_Ledger_Id                NUMBER,
                        X_To_Ledger_Id                  NUMBER,
                        X_Check_Batches                 IN OUT NOCOPY VARCHAR2,
                        X_num_conc_requests             IN OUT NOCOPY NUMBER,
                        X_Target_Resp_Name              VARCHAR2,
                        X_Target_User_Name              VARCHAR2,
                        X_Target_DB_Name                VARCHAR2,
                        X_first_request_Id              IN OUT NOCOPY number,
                        X_last_request_Id               IN OUT NOCOPY number,
			X_access_set_id			NUMBER
                        ) IS
        CURSOR Select_Rowid(Runid NUMBER) IS
                SELECT rowid
                FROM  GL_CONSOLIDATION_HISTORY
                WHERE consolidation_run_id = Runid;
        temp_rowid         ROWID;
        std_runid          NUMBER;
        avg_runid          NUMBER;
        std_request_id     NUMBER;
        avg_request_id     NUMBER;
        remote_flag        VARCHAR2(1);
        valid_return       VARCHAR2(100);
        wait_result        VARCHAR2(200);
        source_group_id    NUMBER;
        CIRequestId        NUMBER;
        msgbuf             VARCHAR2(200) := '';
  BEGIN
    --+ Get the consolidation run id for standard usage
    GL_CONS_HISTORY_PKG.Get_New_Id(std_runid);

    --+ The remote flag should be Y if it is a cross-instance consolidation,
    --+ that is, when the target dabase is not null.
    IF (X_Target_DB_Name IS NOT NULL) THEN
      remote_flag := 'Y';
    ELSE
      remote_flag := 'N';
    END IF;

    --+ Submit the request for consolidation program

    IF (X_Usage_Code IN ('S', 'B')) THEN

      --+ For Transactions method check to see whether
      --+ unconsolidated batches have been successfully inserted
      --+ in GL_CONS_BATCHES.

      IF ((X_method_flag = 'T') AND (X_Check_Batches = 'Y')) THEN
        IF NOT(GL_CONS_BATCHES_PKG.Insert_Consolidation_Batches(
                'U',
                X_Consolidation_Id,
                std_runid,
                X_Last_Updated_By,
                X_From_Ledger_Id,
                X_To_Ledger_Id,
                X_From_Period_Name,
                X_To_Currency_Code)) THEN

           X_Check_Batches := 'N';
           Return;
        END IF;

      END IF;

      --+ submit a standard request.
      std_request_id := FND_REQUEST.SUBMIT_REQUEST(
        'SQLGL',
        'GLCCON',
        '',
        '',
        FALSE,
        To_Char(X_consolidation_id),
        'S',
        X_From_Period_Name,
        To_Char(X_From_Date_Entered, 'YYYY/MM/DD'),
        X_Standard_To_Period_Name,
        NULL,
        NULL,
        X_Std_Amounttype,
        X_Run_Journal_Import_Flag,
        X_Method_Flag,
        to_char(std_runid),
        X_Actual_Flag,
        NULL,
        NULL,
        X_Audit_Mode_Flag,
        X_Summary_Journals_Flag,
        'Y',
        X_Run_Posting_Flag,
        remote_flag,
	X_access_set_id,
        chr(0),'','','','','','','','','',
        '','','','','','','','','','','','','','','','',
        '','','','','','','','','','','','','','','','',
        '','','','','','','','','','','','','','','','',
        '','','','','','','','','','','','','','','','',
        '','','','','','');
      IF (Std_Request_Id = 0) THEN

        --+ submission failed
        FND_MESSAGE.set_name('SQLGL', 'GL_CONS_SET_REQUEST_FAILED');
        FND_MESSAGE.set_token('CONSOLIDATION',X_Consolidation_Name, FALSE);
        APP_EXCEPTION.RAISE_EXCEPTION;

      ELSE
        --+ Set the conc_request variable
        X_num_conc_requests := X_num_conc_requests + 1;
        IF X_first_request_Id = 0 THEN
           X_first_request_Id := Std_Request_Id;
        END IF;

        IF remote_flag = 'N' THEN
           IF X_last_request_Id < Std_Request_Id THEN
              X_last_request_Id := Std_Request_Id;
           END IF;
        END IF;

        --+ insert into gl_consolidation_history
        INSERT INTO GL_CONSOLIDATION_HISTORY(
              consolidation_run_id,
              consolidation_id,
              consolidation_set_id,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by,
              from_period_name,
              to_period_name,
              to_currency_code,
              method_flag,
              run_easylink_flag,
              run_posting_flag,
              actual_flag,
              average_consolidation_flag,
              amount_type,
              from_date,
              status,
              request_id,
              target_resp_name,
              target_user_name,
              target_database_name
            ) VALUES (
              std_runid,
              X_Consolidation_Id,
              X_Consolidation_Set_Id,
              sysdate,
              X_Last_Updated_By,
              X_Last_Updated_By,
              sysdate,
              X_Last_Updated_By,
              X_From_Period_Name,
              X_Standard_To_Period_Name,
              X_To_Currency_Code,
              X_Method_Flag,
              X_Run_Journal_Import_Flag,
              X_Run_Posting_Flag,
              X_Actual_Flag,
              'N',
              X_Std_AmountType,
              X_From_Date_Entered,
              'TS',
              Std_Request_Id,
              X_Target_Resp_Name,
              X_Target_User_Name,
              X_Target_DB_Name
            );

             --+ check whether rows inserted successfully
             OPEN Select_Rowid(std_runid);
             FETCH Select_Rowid INTO temp_rowid;
             IF (Select_Rowid%NOTFOUND) THEN
               CLOSE Select_Rowid;
               Raise NO_DATA_FOUND;
             END IF;
             CLOSE Select_Rowid;
             commit;
        END IF;  --+ request id is NOT 0

      END IF;  --+ Usage in 'S', 'B'

      IF (X_Usage_Code IN ('A', 'B')) THEN
        IF (X_Usage_Code = 'B') THEN

          --+ If the AvgAmounttype IS NULL then the consolidation
          --+ corresponds to a standard ledger, so don't
          --+ submit an average consolidation.
          IF (X_Avg_Amounttype IS NULL) THEN
            RETURN;
          ELSE
            --+ Get the consolidation run id for average usage
            GL_CONS_HISTORY_PKG.Get_New_Id(avg_runid);
          END IF;
        ELSE
          avg_runid := std_runid;
        END IF;

        --+ submit a average request.
        avg_request_id := FND_REQUEST.SUBMIT_REQUEST(
          'SQLGL',
          'GLCCON',
          '',
          '',
          FALSE,
          To_Char(X_consolidation_id),
          'A',
          X_From_Period_Name,
          To_Char(X_From_Date_Entered, 'YYYY/MM/DD'),
          X_Average_To_Period_Name,
          To_Char(X_Average_To_Start_Date, 'YYYY/MM/DD'),
          NULL,
          X_Avg_Amounttype,
          X_Run_Journal_Import_Flag,
          X_Method_Flag,
          to_char(avg_runid),
          X_Actual_Flag,
          NULL,
          NULL,
          X_Audit_Mode_Flag,
          X_Summary_Journals_Flag,
          'Y',
          X_Run_Posting_Flag,
          remote_flag,
	  X_access_set_id,
          chr(0),'','','','','','','','','',
          '','','','','','','','','','','','','','','','',
          '','','','','','','','','','','','','','','','',
          '','','','','','','','','','','','','','','','',
          '','','','','','','','','','','','','','','','',
          '','','','','','');

        IF (avg_request_id = 0) THEN
          --+ submission failed
          FND_MESSAGE.set_name('SQLGL', 'GL_CONS_SET_REQUEST_FAILED');
          FND_MESSAGE.set_token('CONSOLIDATION',X_Consolidation_Name, FALSE);
          APP_EXCEPTION.RAISE_EXCEPTION;

        ELSE

           --+ Set the conc_request variable
           X_num_conc_requests := X_num_conc_requests + 1;
           IF X_first_request_Id = 0 THEN
              X_first_request_Id := avg_Request_Id;
           END IF;

           IF remote_flag = 'N' THEN
              IF X_last_request_Id < avg_Request_Id THEN
                 X_last_request_Id := avg_Request_Id;
              END IF;
           END IF;
          --+ insert into gl_consolidation_history

          INSERT INTO GL_CONSOLIDATION_HISTORY(
              consolidation_run_id,
              consolidation_id,
              consolidation_set_id,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by,
              from_period_name,
              to_period_name,
              to_currency_code,
              method_flag,
              run_easylink_flag,
              run_posting_flag,
              actual_flag,
              average_consolidation_flag,
              amount_type,
              from_date,
              status,
              request_id,
              target_resp_name,
              target_user_name,
              target_database_name
            ) VALUES (
              avg_runid,
              X_Consolidation_Id,
              X_Consolidation_Set_Id,
              sysdate,
              X_Last_Updated_By,
              X_Last_Updated_By,
              sysdate,
              X_Last_Updated_By,
              X_From_Period_Name,
              X_Average_To_Period_Name,
              X_To_Currency_Code,
              X_Method_Flag,
              X_Run_Journal_Import_Flag,
              X_Run_Posting_Flag,
              X_Actual_Flag,
              'Y',
              X_Avg_AmountType,
              X_From_Date_Entered,
              'TS',
              avg_request_id,
              X_Target_Resp_Name,
              X_Target_User_Name,
              X_Target_DB_Name
            );

             --+ check whether rows inserted successfully
             OPEN Select_Rowid(avg_runid);
             FETCH Select_Rowid INTO temp_rowid;
             IF (Select_Rowid%NOTFOUND) THEN
               CLOSE Select_Rowid;
               Raise NO_DATA_FOUND;
             END IF;
             CLOSE Select_Rowid;
             commit;
        END IF; --+ request_id is not 0

     END IF; --+ usage is 'B' or 'A'

     IF (remote_flag = 'Y') and (X_Usage_Code IN ('S', 'B')) AND (std_request_id <> 0) THEN
--+        GL_CI_REMOTE_INVOKE_PKG.Wait_For_Request(Std_Request_Id, wait_result);
--+        IF wait_result = 'COMPLETE:PASS' THEN
--+          source_group_id := GL_CI_DATA_TRANSFER_PKG.Get_Source_Group_ID(
--+                      X_consolidation_id, Std_RunId);
          source_group_id := 0;
          CIRequestId := FND_REQUEST.SUBMIT_REQUEST(
          'SQLGL',
          'GLCCIPRE',
          '',
          '',
          FALSE,
          X_Target_Resp_Name,
          Std_Request_Id,
          X_consolidation_id,
          Std_RunId,
          X_Standard_To_Period_Name,
          X_To_Ledger_Id,
          X_Target_User_Name,
          X_Target_DB_Name,
          source_group_id,
          X_From_Ledger_Id,
          X_Standard_To_Period_Name,
	  NULL,
          X_Run_Journal_Import_Flag,
          X_Run_Posting_Flag,
          X_Actual_Flag,
          Std_Request_Id,
          X_Summary_Journals_Flag,
          'N',
          chr(0),'','','','','','','','','','',  --+ 24 arguments so far
          '','','','','','','','','','','','','','','','',
          '','','','','','','','','','','','','','','','',
          '','','','','','','','','','','','','','','','',
          '','','','','','','','','','','','','','','','',  --+ 16 in a row
          '','','','','','','');

          IF CIRequestId <> 0 THEN
          --+ get program name
          --+  gl_message.get(msgbuf, 'GL_US_CI_CROSSINSTANCE');
            X_num_conc_requests := X_num_conc_requests + 1;
            IF X_last_request_Id < CIRequestId THEN
               X_last_request_Id := CIRequestId;
            END IF;
            FND_MESSAGE.set_name('SQLGL', 'GL_CONC_REQUEST_SUBMITTED');
            FND_MESSAGE.set_token('MODULE',msgbuf, FALSE);
            FND_MESSAGE.set_token('REQUEST_ID', TO_CHAR(CIRequestId), FALSE);

          ELSE
            FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_PRE_FAIL');
            APP_EXCEPTION.RAISE_EXCEPTION;
--+            FND_MESSAGE.show;
          END IF;
--+       END IF;  --+if wait_result is complete:pass
     END IF;
     IF (remote_flag = 'Y') and (X_Usage_Code IN ('A', 'B')) AND (avg_request_id <> 0) THEN
--+        GL_CI_REMOTE_INVOKE_PKG.Wait_For_Request(Avg_Request_Id, wait_result);
--+        IF wait_result = 'COMPLETE:PASS' THEN
--+          source_group_id := GL_CI_DATA_TRANSFER_PKG.Get_Source_Group_ID(
--+                      X_consolidation_id, Avg_RunId);
          --+MESSAGE('Average source group_id is ' || source_group_id);
          source_group_id := 0;
          CIRequestId := FND_REQUEST.SUBMIT_REQUEST(
          'SQLGL',
          'GLCCIPRE',
          '',
          '',
          FALSE,
          X_Target_Resp_Name,
          Avg_Request_Id,
          X_consolidation_id,
          Avg_RunId,
          X_Average_To_Period_Name,
          X_To_Ledger_Id,
          X_Target_User_Name,
          X_Target_DB_Name,
          source_group_id,
          X_From_Ledger_Id,
          X_Average_To_Period_Name,
	  NULL,
          X_Run_Journal_Import_Flag,
          X_Run_Posting_Flag,
          X_Actual_Flag,
          Avg_Request_Id,
          X_Summary_Journals_Flag,
          'N',
          chr(0),'','','','','','','','','','',  --+ 24 arguments so far
          '','','','','','','','','','','','','','','','',
          '','','','','','','','','','','','','','','','',
          '','','','','','','','','','','','','','','','',
          '','','','','','','','','','','','','','','','',  --+ 16 in a row
          '','','','','','','');

          IF CIRequestId <> 0 THEN
             X_num_conc_requests := X_num_conc_requests + 1;
             IF X_last_request_Id < CIRequestId THEN
                X_last_request_Id := CIRequestId;
             END IF;
          --+ get program name
          --+  gl_message.get(msgbuf, 'GL_US_CI_CROSSINSTANCE');
            FND_MESSAGE.set_name('SQLGL', 'GL_CONC_REQUEST_SUBMITTED');
            FND_MESSAGE.set_token('MODULE',msgbuf, FALSE);
            FND_MESSAGE.set_token('REQUEST_ID', TO_CHAR(CIRequestId), FALSE);
          ELSE
            FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_PRE_FAIL');
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
--+       END IF;  --+if wait_result is complete:pass
     END IF;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','Unhandled Exception');
      fnd_message.set_token('PROCEDURE', 'Insert_Cons_Set_Row');
      RAISE;

  END Insert_Cons_Set_Row;


  PROCEDURE Insert_For_Budgetyear(
                       X_Consolidation_Run_Id           NUMBER,
                       X_Consolidation_Id               NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_From_Period_Name               VARCHAR2,
                       X_To_Period_Name                 VARCHAR2,
                       X_To_Currency_Code               VARCHAR2,
                       X_Method_Flag                    VARCHAR2,
                       X_Run_Easylink_Flag              VARCHAR2,
                       X_Run_Posting_Flag               VARCHAR2,
                       X_Actual_Flag                    VARCHAR2,
                       X_From_Budget_Name               VARCHAR2,
                       X_To_Budget_Name                 VARCHAR2,
                       X_From_Budget_Version_Id         NUMBER,
                       X_To_Budget_Version_Id           NUMBER,
                       X_Consolidation_Set_Id           NUMBER,
                       X_Status                         VARCHAR2,
                       X_Request_Id                     NUMBER,
                       X_Amount_Type_Code               VARCHAR2,
                       X_ledger_id                      NUMBER,
                       X_Period_Year                    NUMBER,
                       X_Target_Resp_Name               VARCHAR2,
                       X_Target_User_Name               VARCHAR2,
                       X_Target_DB_Name                 VARCHAR2) IS
  BEGIN
        INSERT INTO GL_CONSOLIDATION_HISTORY(
              consolidation_run_id,
              consolidation_id,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by,
              from_period_name,
              to_period_name,
              to_currency_code,
              method_flag,
              run_easylink_flag,
              run_posting_flag,
              actual_flag,
              from_budget_name,
              to_budget_name,
              from_budget_version_id,
              to_budget_version_id,
              consolidation_set_id,
              status,
              request_id,
              average_consolidation_flag,
              amount_type,
              target_resp_name,
              target_user_name,
              target_database_name
             )
       SELECT   X_Consolidation_Run_Id,
                X_Consolidation_Id,
                X_Last_Update_Date,
                X_Last_Updated_By,
                X_Last_Updated_By,
                X_Last_Update_Date,
                X_Last_Updated_By,
                PS.period_name,
                PS.period_name,
                X_To_Currency_Code,
                X_Method_Flag,
                X_Run_Easylink_Flag,
                X_Run_Posting_Flag,
                X_Actual_Flag,
                X_From_Budget_Name,
                X_To_Budget_Name,
                X_From_Budget_Version_Id,
                X_To_Budget_Version_Id,
                X_Consolidation_Set_Id,
                X_Status,
                X_Request_Id,
                'N',
                X_Amount_Type_Code,
                X_Target_Resp_Name,
                X_Target_User_Name,
                X_Target_DB_Name
        FROM
                GL_PERIOD_STATUSES PS,
                GL_BUDGET_PERIOD_RANGES BPR
        WHERE   BPR.budget_version_id = X_From_Budget_Version_Id
        AND     BPR.period_year = X_Period_Year
        AND     BPR.open_flag = 'O'
        AND     BPR.period_year = ps.period_year
        AND     PS.application_id = 101
        AND     PS.ledger_id = X_ledger_id
        AND     PS.effective_period_num
                        BETWEEN BPR.period_year * 10000 + BPR.start_period_num
                        AND BPR.period_year * 10000 + BPR.end_period_num ;

  END Insert_For_Budgetyear;


  PROCEDURE Insert_Status_ReqId(
                       X_StdRunId                       NUMBER,
                       X_AvgRunId                       NUMBER,
                       X_StdReqId                       NUMBER,
                       X_AvgReqId                       NUMBER) IS
  BEGIN
    IF (X_StdRunId IS NOT NULL) THEN
      UPDATE GL_CONSOLIDATION_HISTORY
      SET status = 'TS',
          request_id = X_StdReqId
      WHERE consolidation_run_id = X_StdRunId;
    END IF;

    IF (X_AvgRunId IS NOT NULL) THEN
      UPDATE GL_CONSOLIDATION_HISTORY
      SET status = 'TS',
          request_id = X_AvgReqId
      WHERE consolidation_run_id = X_AvgRunId;
    END IF;

  END Insert_Status_ReqId;

END GL_CONS_HISTORY_PKG;

/
