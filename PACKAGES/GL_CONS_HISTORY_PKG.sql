--------------------------------------------------------
--  DDL for Package GL_CONS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONS_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: glicohis.pls 120.14 2005/05/05 01:05:15 kvora ship $ */
--+
--+ Package
--+   gl_consolidation_history_pkg
--+ Purpose
--+   Package procedures for Consolidation RUN form,
--+     Submit block
--+ History
--+   20-APR-94  E Wilson        Created
--+

  --+
  --+ Procedure
  --+   Check_Calendar
  --+ Purpose
  --+   Compare the calendar types of the parent ledger and the
  --+   subsidiary ledger
  --+ Arguments
  --+   to_ledger_id
  --+   from_ledger_id
  --+ Example
  --+   GL_CONSOLIDATION_HISTORY_PKG.Check_Calendar(
  --+     :SUBMIT.to_ledger_id,
  --+     :SUBMIT.from_ledger_id)
  --+ Notes
  --+
  PROCEDURE  Check_Calendar(X_To_Ledger_Id    NUMBER,
                            X_From_Ledger_Id  NUMBER);

  --+
  --+ Procedure
  --+   Get_New_Id
  --+ Purpose
  --+   Get next value from GL_CONSOLIDATION_HISTORY_S
  --+ Arguments
  --+   next_val   Return next value in sequence
  --+ Example
  --+   GL_CONSOLIDATION_HISTORY_PKG.Get_New_Id(:SUBMIT.consolidation_run_id)
  --+ Notes
  --+
  PROCEDURE Get_New_Id(next_val IN OUT NOCOPY NUMBER);

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
              );

  /* Name: first_period_of_year
   * Desc: Returns the first non-adjusting period of the specified year
   */
  PROCEDURE first_period_of_year(
              LedgerId             NUMBER,
              PeriodYear           NUMBER,
              PeriodName    IN OUT NOCOPY VARCHAR2,
              StartDate     IN OUT NOCOPY DATE,
              ClosingStatus IN OUT NOCOPY VARCHAR2
              );

  /* Name: insert_average_record
   * Desc: Copy the standard consolidation record for average consolidation.
   */
  PROCEDURE insert_average_record(
              SourceRunId NUMBER,
              TargetRunId NUMBER,
              AverageToPeriodName VARCHAR2,
              AvgAmountType       VARCHAR2,
              FromDateEntered     DATE
            );

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
                      );

  --+
  --+ Procedure
  --+   Insert_Cons_Set_Row
  --+ Purpose
  --+   Handle the pre-update logic for each selected consolidation in the
  --+   Transfer Consolidation Set form.
  --+ Example
  --+   GL_CONS_HISTORY_PKG.Insert_Cons_Set_Row(
  --+      arg1,
  --+      arg2, ....... )
  --+ Notes
  --+

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
                        );



  --+
  --+ Procedure
  --+   Insert_For_Budgetyear
  --+ Purpose
  --+   Inserts a year worth of rows for budget consolidations for a year
  --+   for the Consolidation Workbench functionality
  --+ Example
  --+   GL_CONS_HISTORY_PKG.Insert_For_Budgetyear(
  --+      arg1,
  --+      arg2, ....... )
  --+ Notes
  --+

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
                       X_Target_DB_Name                 VARCHAR2);

  --+
  --+ Procedure
  --+   Insert_Status_ReqId
  --+ Purpose
  --+   Inserts the status and request id columns in GL_CONSOLIDATION_HISTORY
  --+   for the Transfer Consolidation form.
  --+ Example
  --+   GL_CONS_HISTORY_PKG.Insert_Status_ReqId(
  --+      arg1,
  --+      arg2, ....... )
  --+ Notes
  --+

PROCEDURE Insert_Status_ReqId(
                       X_StdRunId                       NUMBER,
                       X_AvgRunId                       NUMBER,
                       X_StdReqId                       NUMBER,
                       X_AvgReqId                       NUMBER);


END GL_CONS_HISTORY_PKG;

 

/
