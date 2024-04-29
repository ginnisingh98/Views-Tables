--------------------------------------------------------
--  DDL for Package GMS_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_BILLING" AUTHID CURRENT_USER AS
-- $Header: gmsinbls.pls 120.0 2005/05/29 11:50:00 appldev noship $

  PROCEDURE AWARD_BILLING( X_project_id IN NUMBER,
                           X_top_Task_id IN NUMBER DEFAULT NULL,
                           X_calling_process IN VARCHAR2 DEFAULT NULL,
                           X_calling_place IN VARCHAR2 DEFAULT NULL,
                           X_amount IN NUMBER DEFAULT NULL,
                           X_percentage IN NUMBER DEFAULT NULL,
                           X_rev_or_bill_date IN DATE DEFAULT NULL,
                           X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                           X_bill_extension_id IN NUMBER DEFAULT NULL,
                           X_request_id IN NUMBER DEFAULT NULL)  ;
  TYPE Mark_Sel_Grp_Diff_Array IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE Selected_Values_Rows IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  TYPE Padding_Length_Array IS TABLE OF NUMBER(3) INDEX BY BINARY_INTEGER;
  TYPE Running_Total_Array IS TABLE OF NUMBER(10) INDEX BY BINARY_INTEGER;
  TYPE Free_Text_Array IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

   TYPE Burden_Component_Rec_Type IS RECORD(actual_project_id  NUMBER(15) := NULL,
                                           actual_task_id     NUMBER(15) := NULL,
                                           burden_expenditure_type  VARCHAR2(30) := NULL,
                                           burden_cost_code    VARCHAR2(30) := NULL,
                                           expenditure_org_id  NUMBER(15)   := NULL,
                                           burden_cost         NUMBER       := NULL);

  TYPE Burden_Component_Tab_Type  IS TABLE OF Burden_Component_Rec_Type
  INDEX BY BINARY_INTEGER;

--  PROCEDURE: INSERT_EVENT, new procedure to insert records into GMS_EVENT_ATTRIBUTE table

PROCEDURE  INSERT_EVENT(X_AWARD_PROJECT_ID      IN NUMBER	DEFAULT NULL,
                        X_EVENT_NUM             IN NUMBER	DEFAULT NULL,
                        X_INSTALLMENT_ID        IN NUMBER	DEFAULT NULL,
                        X_ACTUAL_PROJECT_ID     IN NUMBER	DEFAULT NULL,
                        X_ACTUAL_TASK_ID        IN NUMBER	DEFAULT NULL,
                        X_BURDEN_COST_CODE      IN VARCHAR2	DEFAULT NULL,
                        X_EXPENDITURE_ORG_ID    IN NUMBER	DEFAULT NULL,
                        X_BILL_AMOUNT           IN NUMBER	DEFAULT NULL,
                        X_REVENUE_AMOUNT        IN NUMBER	DEFAULT NULL,
			X_REQUEST_ID		IN NUMBER	DEFAULT NULL,
		        X_EXPENDITURE_TYPE      IN VARCHAR2	DEFAULT NULL,
                        X_Err_Code              IN OUT NOCOPY NUMBER,
                        X_Err_Buff              IN OUT NOCOPY VARCHAR2,
			X_Calling_Process	IN VARCHAR2	DEFAULT NULL);

-- PROCEDURE: UPDATE_EVENT, new procedure to update GMS_EVENT_ATTRIBUTE table records

 PROCEDURE UPDATE_EVENT(X_AWARD_PROJECT_ID      IN NUMBER       DEFAULT NULL,
                        X_EVENT_NUM             IN NUMBER       DEFAULT NULL,
                        X_INSTALLMENT_ID        IN NUMBER       DEFAULT NULL,
                        X_ACTUAL_PROJECT_ID     IN NUMBER       DEFAULT NULL,
                        X_ACTUAL_TASK_ID        IN NUMBER       DEFAULT NULL,
                        X_BURDEN_COST_CODE      IN VARCHAR2     DEFAULT NULL,
                        X_EXPENDITURE_ORG_ID    IN NUMBER       DEFAULT NULL,
                        X_BILL_AMOUNT           IN NUMBER       DEFAULT NULL,
                        X_REVENUE_AMOUNT        IN NUMBER       DEFAULT NULL,
                        X_REQUEST_ID            IN NUMBER       DEFAULT NULL,
                        X_EXPENDITURE_TYPE      IN VARCHAR2     DEFAULT NULL,
                        X_Err_Code              IN OUT NOCOPY NUMBER,
                        X_Err_Buff              IN OUT NOCOPY VARCHAR2);

-- PROCEDURE: DELETE_EVENT, new procedure to delete records from GMS_EVENT_ATTRIBUTE table

PROCEDURE DELETE_EVENT (X_AWARD_PROJECT_ID      IN NUMBER,
                        X_EVENT_NUM             IN NUMBER,
                        X_INSTALLMENT_ID        IN NUMBER,
                        X_Err_Code              IN OUT NOCOPY NUMBER,
                        X_Err_Buff              IN OUT NOCOPY VARCHAR2);

-- Function :  GET_TOTAL_ADL_RAW_COST to get the total billable amount
FUNCTION GET_TOTAL_ADL_RAW_COST(X_BILLING_TYPE IN VARCHAR2  , X_EXPENDITURE_ITEM_ID IN NUMBER ) RETURN NUMBER;

-- Function Is_Invoice_Format_Valid : This is called from :AWARDS form and gms_billing.award_billing
-- Function checks whether the invoice format (labor/non-labor) has any element (column) that is not
-- supported by Grants Accounting.
-- Calling context would be 'AWARDS_FORM' or 'BILLING_PROCESS'
-- Function returns TRUE is format is VALID else returns FALSE

Function Is_Invoice_Format_Valid(X_Award_project_id IN NUMBER,
				 X_Labor_format_id IN NUMBER,
			         X_Non_Labor_format_id IN NUMBER,
			         X_calling_context IN VARCHAR2)
RETURN BOOLEAN;

END GMS_BILLING;

 

/
