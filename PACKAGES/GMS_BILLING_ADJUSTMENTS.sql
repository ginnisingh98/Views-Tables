--------------------------------------------------------
--  DDL for Package GMS_BILLING_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_BILLING_ADJUSTMENTS" AUTHID CURRENT_USER AS
-- $Header: gmsinads.pls 120.2 2005/12/23 22:12:11 appldev ship $

p_msg_count NUMBER;

Procedure PERFORM_REV_BILL_ADJS(X_Adj_Action                 IN VARCHAR2,
                                X_Calling_Process            IN VARCHAR2,
                                X_Award_Project_Id           IN NUMBER   DEFAULT NULL,
                                X_Draft_Invoice_Num          IN NUMBER   DEFAULT NULL,
			        X_Start_Award_Project_Number IN VARCHAR2 DEFAULT NULL,
			        X_End_Award_Project_Number   IN VARCHAR2 DEFAULT NULL,
			        X_Mass_Gen_Flag              IN VARCHAR2 DEFAULT NULL,
                                X_Adj_Amount                 IN NUMBER DEFAULT NULL,
                                RETCODE                      OUT NOCOPY VARCHAR2,
                                ERRBUF                       OUT NOCOPY VARCHAR2);

Procedure DELINV(X_project_id 		IN NUMBER,
                 X_top_Task_id 		IN NUMBER DEFAULT NULL,
                 X_calling_process 	IN VARCHAR2 DEFAULT NULL,
                 X_calling_place 	IN VARCHAR2 DEFAULT NULL,
                 X_amount 		IN NUMBER DEFAULT NULL,
                 X_percentage 		IN NUMBER DEFAULT NULL,
                 X_rev_or_bill_date 	IN DATE DEFAULT NULL,
                 X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                 X_bill_extension_id 	IN NUMBER DEFAULT NULL,
                 X_request_id 		IN NUMBER DEFAULT NULL);

Procedure CANINV(X_project_id 		IN NUMBER,
                 X_top_Task_id 		IN NUMBER DEFAULT NULL,
                 X_calling_process 	IN VARCHAR2 DEFAULT NULL,
                 X_calling_place 	IN VARCHAR2 DEFAULT NULL,
                 X_amount 		IN NUMBER DEFAULT NULL,
                 X_percentage 		IN NUMBER DEFAULT NULL,
                 X_rev_or_bill_date 	IN DATE DEFAULT NULL,
                 X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                 X_bill_extension_id 	IN NUMBER DEFAULT NULL,
                 X_request_id 		IN NUMBER DEFAULT NULL);

Procedure WRIINV(X_project_id 	IN NUMBER,
                 X_top_Task_id 		IN NUMBER DEFAULT NULL,
                 X_calling_process 	IN VARCHAR2 DEFAULT NULL,
                 X_calling_place 	IN VARCHAR2 DEFAULT NULL,
                 X_amount 		IN NUMBER DEFAULT NULL,
                 X_percentage 		IN NUMBER DEFAULT NULL,
                 X_rev_or_bill_date 	IN DATE DEFAULT NULL,
                 X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                 X_bill_extension_id 	IN NUMBER DEFAULT NULL,
                 X_request_id 		IN NUMBER DEFAULT NULL);

Procedure DELREV(X_project_id 		IN NUMBER,
                 X_top_Task_id 		IN NUMBER DEFAULT NULL,
                 X_calling_process 	IN VARCHAR2 DEFAULT NULL,
                 X_calling_place 	IN VARCHAR2 DEFAULT NULL,
                 X_amount 		IN NUMBER DEFAULT NULL,
                 X_percentage 		IN NUMBER DEFAULT NULL,
                 X_rev_or_bill_date 	IN DATE DEFAULT NULL,
                 X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                 X_bill_extension_id 	IN NUMBER DEFAULT NULL,
                 X_request_id 		IN NUMBER DEFAULT NULL);

-- ## Following procedure, procedure INSERT_BILL_CANCEL is referred in gms_billing.billing_rollback

PROCEDURE INSERT_BILL_CANCEL(X_Award_Project_Id    IN NUMBER,
			     X_Event_Num 	   IN NUMBER,
			     X_Expenditure_item_id IN NUMBER DEFAULT null,
			     X_Adl_Line_No	   IN NUMBER DEFAULT null,
			     X_Bill_Amount	   IN NUMBER,
			     X_Calling_Process	   IN VARCHAR2,
			     X_Burden_Exp_Type     IN VARCHAR2 DEFAULT null,
			     X_Burden_Cost_Code    IN VARCHAR2 DEFAULT null,
			     X_Creation_Date	   IN DATE,
			     X_Actual_Project_Id   IN NUMBER,
			     X_Actual_Task_Id      IN NUMBER,
			     X_Expenditure_Org_Id  IN NUMBER,
			     X_Deletion_Date       IN DATE,
			     X_Resource_List_Member_Id IN NUMBER DEFAULT null,
			     X_Err_Code            IN OUT NOCOPY NUMBER,
			     X_Err_Buff           IN OUT NOCOPY VARCHAR2);

-- ## procedure HANDLE_NET_ZERO_EVENTS is referred in gms_billing.billing_rollback
-- ## Added for bug 4594090

PROCEDURE HANDLE_NET_ZERO_EVENTS (P_AWARD_PROJECT_ID IN NUMBER,
                                  P_REQUEST_ID       IN NUMBER,
                                  P_CALLING_PROCESS  IN VARCHAR2);


End GMS_BILLING_ADJUSTMENTS;

 

/
