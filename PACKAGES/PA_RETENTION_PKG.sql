--------------------------------------------------------
--  DDL for Package PA_RETENTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RETENTION_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXIRTNS.pls 120.3 2005/08/19 17:14:44 mwasowic noship $ */
--- Retention Invoice Format Structure

TYPE InvRetnLineFormat IS RECORD (
				   column_code		VARCHAR2(30),
				   usertext		varchar2(80),
				   start_position	NUMBER,
				   end_position		NUMBER,
				   right_justify_flag	VARCHAR2(1));

TYPE TabInvRetnLineFormat IS TABLE OF InvRetnLineFormat
INDEX BY BINARY_INTEGER;

-- Function	Get_Invoice_Max_Line
-- Purpose	Get the Maximum Invoice Line Number

FUNCTION Get_Invoice_Max_Line(p_project_id IN NUMBER,
                              p_draft_invoice_num IN NUMBER) RETURN NUMBER;

-- Function	Get_NetZero_Line
-- Purpose	Get the NetZero Invoice Line Number

FUNCTION Get_NetZero_Line(p_project_id IN NUMBER,
                              p_draft_invoice_num IN NUMBER) RETURN NUMBER;

-- Procdure	Proj_Invoice_Retn_PRocessing
-- Purpose	To retain the retention amount.
--		This will be called after project invoice generation

PROCEDURE Proj_Invoice_Retn_Processing(	p_project_id	IN 	NUMBER,
				       	p_request_id 	IN 	NUMBER,
				        x_return_status OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Create_Proj_Inv_Retn_Lines(	p_project_id  		IN  	NUMBER,
					p_customer_id		IN	NUMBER,
					p_agreement_id		IN	NUMBER,
                           		p_draft_invoice_num 	IN 	NUMBER,
 					p_cust_retn_level       IN      VARCHAR2,
                           		p_request_id		IN 	NUMBER,
                                        p_output_tax_code       IN     VARCHAR2,
                                        p_Output_tax_exempt_flag    IN VARCHAR2,
                                        p_Output_tax_exempt_number  IN VARCHAR2,
                                        p_Output_exempt_reason_code IN VARCHAR2);
-- Function Get_Proj_Inv_Retn_Format
-- Purpose  Function to return the project invoice retention line format

Function Get_Proj_Inv_Retn_Format(p_project_id IN NUMBER) RETURN pa_retention_pkg.TabInvRetnLineFormat;

-- Procedure Update_Retention_Balances
-- Purpose   Called from retention package and retention billing package
--	     Used to update the retained and billed balances

PROCEDURE Update_Retention_Balances(	p_retention_rule_id 	IN NUMBER DEFAULT NULL,
				  	p_project_id	  	IN NUMBER,
				  	p_task_id	  	IN NUMBER DEFAULT NULL,
				  	p_agreement_id	  	IN NUMBER,
				  	p_customer_id	  	IN NUMBER,
				  	p_amount		IN NUMBER,
				 	p_change_type 	  	IN VARCHAR2,
					p_request_id      	IN NUMBER ,
					p_invproc_currency	IN VARCHAR2,
					p_project_currency	IN VARCHAR2,
					p_project_amount 	IN NUMBER,
					p_projfunc_currency	IN VARCHAR2,
					p_projfunc_amount	IN NUMBER,
					p_funding_currency	IN VARCHAR2,
					p_funding_amount	IN NUMBER);

PROCEDURE Proj_Invoice_Credit_Memo(p_request_id			IN NUMBER,
				   p_project_id			IN NUMBER,
				   x_return_status	       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Invoice_Cancel_Action(p_request_id                    IN NUMBER,
                                p_invoice_type                  IN VARCHAR2,
                                p_project_id                    IN NUMBER,
                                p_draft_invoice_num             IN NUMBER,
                                x_return_status                 OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Invoice_Delete_Action(p_request_id                    IN NUMBER,
                                p_invoice_type                  IN VARCHAR2,
                                p_project_id                    IN NUMBER,
                                p_draft_invoice_num             IN NUMBER,
                                x_return_status                 OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Retn_Bill_Trans_Amount(p_project_id 		IN NUMBER,
                                        p_draft_invoice_num 	IN NUMBER,
                                        p_bill_trans_currency 	IN VARCHAR2,
                                        p_request_id       	IN NUMBER);

/* Procedure added for bug 2770738 */
PROCEDURE update_credit_retn_balances(p_request_id              IN NUMBER,
                                p_invoice_type                  IN VARCHAR2,
                                p_credit_action                 IN VARCHAR2,
                                p_project_id                    IN NUMBER,
                                p_draft_invoice_num             IN NUMBER,
                                x_return_status                 OUT NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

/* Procedure added for bug 3889175 */
PROCEDURE Delete_Unused_Retention_Lines(
	P_Project_ID            IN NUMBER,
	P_Task_ID               IN NUMBER,
	X_Return_Status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_retention_pkg;

 

/
