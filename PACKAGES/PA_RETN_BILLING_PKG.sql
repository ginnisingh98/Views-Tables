--------------------------------------------------------
--  DDL for Package PA_RETN_BILLING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RETN_BILLING_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXIRTBS.pls 120.2 2005/08/19 17:14:34 mwasowic noship $ */

-- Struct to store the retention invoice format

G_Inv_By_Bill_Trans_Currency VARCHAR2(1);
G_error_code VARCHAR2(3) := 'N';


TYPE RetnBillingInvFmt IS RECORD (
                                   column_code          VARCHAR2(30),
                                   usertext             varchar2(80),
				   column_value		VARCHAR2(80),
				   start_position	NUMBER,
				   end_position		NUMBER,
				   right_justify_flag	VARCHAR2(1)
					);

TYPE TabRetnBillingInvFmt IS TABLE OF RetnBillingInvFmt
INDEX BY BINARY_INTEGER;

-- Function	Get_Retn_Billing_Inv_Format
-- Purpose	This is used to get the invoice format for a given project

Function Get_Retn_Billing_Inv_Format(p_project_id NUMBER)
			 RETURN pa_retn_billing_pkg.TabRetnBillingInvFmt;

-- Procedure	Retention_Billing_Processing
-- Purpose	This is used to process Retention invoices
--		This procedure will be called from invoice processing

Procedure Retention_Billing_Processing (p_request_id   		IN NUMBER,
					p_start_proj_number 	IN VARCHAR2,
					p_end_proj_number	IN VARCHAR2,
                                        x_return_status		OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
/*
                                        p_project_type_id       IN NUMBER,
                                        p_project_org_id        IN NUMBER,
                                        p_agreement_id          IN NUMBER,
                                        p_customer_id           IN NUMBER,
                                        p_mcb_flag              IN VARCHAR2,
*/

-- Procedure	Build_Retn_Invoice_Header
-- Purpose	This is used to build retention invoice header

PROCEDURE Build_Retn_Invoice_Header(p_project_id		 IN NUMBER,
                                    p_agreement_id		 IN NUMBER,
                                    p_customer_id		 IN NUMBER,
                                    p_request_id		 IN NUMBER,
				    x_draft_invoice_num		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_output_tax_code           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_Output_tax_exempt_flag    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_Output_tax_exempt_number  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_Output_exempt_reason_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Function	CheckInvoiceExists
-- Purpose	This is used to find for a project,agreement id, request id has an inovice

FUNCTION CheckInvoiceExists(	p_project_id 	IN 	NUMBER,
				p_agreement_id	IN	NUMBER,
                                p_request_id	IN	VARCHAR2) RETURN VARCHAR2;

-- Procedure	Create_Retn_Invoice_Lines
-- Purpose	This is used to create retention invoice lines

PROCEDURE Create_Retn_Invoice_Lines(   p_project_id             IN      NUMBER,
                                        p_customer_id           IN      NUMBER,
                                        p_task_id           	IN      NUMBER DEFAULT NULL,
                                        p_agreement_id          IN      NUMBER,
                                        p_draft_invoice_num     IN      NUMBER,
                                        p_request_id            IN      NUMBER,
                                        p_invproc_currency      IN      VARCHAR2,
                                        p_projfunc_currency     IN      VARCHAR2,
                                        p_project_currency      IN      VARCHAR2,
                                        p_funding_currency      IN      VARCHAR2,
                                        p_projfunc_amount       IN      NUMBER,
                                        p_project_amount        IN      NUMBER,
                                        p_funding_amount        IN      NUMBER,
                                        p_invproc_amount        IN      NUMBER,
                                        p_billing_method        IN      VARCHAR2,
                                        p_billing_method_code   IN      VARCHAR2,
                                        p_method_value          IN      VARCHAR2,
                                        p_total_retained        IN      NUMBER,
                                        p_billing_percentage    IN      NUMBER,
                                        p_billing_amount        IN      NUMBER,
                                        p_output_tax_code       IN      VARCHAR2,
                                        p_Output_tax_exempt_flag IN    VARCHAR2,
                                        p_Output_tax_exempt_number IN  VARCHAR2,
                                        p_Output_exempt_reason_code IN VARCHAR2,
 				        p_comp_percent          IN      NUMBER,
                                        p_bill_cycle_id         IN      NUMBER,
                                        p_TotRetenion           IN      NUMBER,
                                        p_client_extn_flag      IN VARCHAR2);

-- Procedure	Create_Retn_Invoice_Details
-- Purpose	This is used to create retention invoice details

PROCEDURE Create_Retn_Invoice_Details (
                                        p_project_id            IN      NUMBER,
                                        p_task_id               IN      NUMBER DEFAULT NULL,
                                        p_draft_invoice_num     IN      NUMBER,
                                        p_line_num              IN      NUMBER,
                                        p_agreement_id          IN      NUMBER,
                                        p_request_id            IN      NUMBER);

PROCEDURE Update_ProjFunc_Attributes( p_project_id   IN NUMBER,
				      p_draft_invoice_num IN NUMBER);

-- Update the invoice transaction attributes

PROCEDURE Update_Inv_Trans_Attributes(p_request_id   IN NUMBER);

PROCEDURE Invoice_Generation_Exceptions (p_request_id   	IN NUMBER,
				         p_start_proj_number 	IN VARCHAR2,
					 p_end_proj_number	IN VARCHAR2);

END pa_retn_billing_pkg;

 

/
