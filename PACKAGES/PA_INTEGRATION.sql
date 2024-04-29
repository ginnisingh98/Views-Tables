--------------------------------------------------------
--  DDL for Package PA_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INTEGRATION" AUTHID CURRENT_USER AS
--$Header: PAXPINTS.pls 120.1 2005/08/08 10:51:04 sbharath noship $


    /**global variables related to get_raw_cdl_pa_date() and get_raw_cdl_recvr_pa_date() caching **/
    g_prvdr_org_id                  pa_expenditure_items_all.org_id%TYPE;
    g_p_earliest_pa_start_date      pa_cost_distribution_lines_all.pa_date%TYPE;
    g_p_earliest_pa_end_date        pa_cost_distribution_lines_all.pa_date%TYPE;
    g_p_earliest_pa_period_name     pa_cost_distribution_lines_all.pa_period_name%TYPE;
    g_prvdr_pa_start_date           pa_cost_distribution_lines_all.pa_date%TYPE;
    g_prvdr_pa_end_date             pa_cost_distribution_lines_all.pa_date%TYPE;
    g_prvdr_pa_period_name          pa_cost_distribution_lines_all.pa_period_name%TYPE;
    g_prvdr_pa_date                 pa_cost_distribution_lines_all.pa_date%TYPE;

    g_recvr_org_id                  pa_expenditure_items_all.recvr_org_id%TYPE;
    g_r_earliest_pa_start_date      pa_cost_distribution_lines_all.recvr_pa_date%TYPE;
    g_r_earliest_pa_end_date        pa_cost_distribution_lines_all.recvr_pa_date%TYPE;
    g_r_earliest_pa_period_name     pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE;
    g_recvr_pa_start_date           pa_cost_distribution_lines_all.recvr_pa_date%TYPE;
    g_recvr_pa_end_date             pa_cost_distribution_lines_all.recvr_pa_date%TYPE;
    g_recvr_pa_period_name          pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE;
    g_recvr_pa_date                 pa_cost_distribution_lines_all.recvr_pa_date%TYPE;

    /**global variables related to pa_date caching **/

FUNCTION get_period_name return pa_cost_distribution_lines_all.pa_period_name%TYPE;/*2835063*/


/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : pending_vi_adjustments_exists
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : checks for any transfers/splits/recalc raw costs in
--                 Oracle Projects.  If adjustments exists in Orcale Projects
--                 It returns the appropriate message_name, else it returns 'N'.
--                 Since this function will be used in select statements, the
--                 purity level is WNDS and WNPS.
-- Parameters    :
-- IN              P_Invoice_id          IN   NUMBER     Required
--                          Invoice Identifier, Corresponds to column
--                          INVOICE_ID of AP_INVOICES_ALL Table
-- RETURNS       : Message_Name, if adjustments exists in Orcale Projects
--                 'N'           if no adjustments exists.
--
-- Version       : 1.0  Initial version
-- End of Comments
/*----------------------------------------------------------------------------*/

FUNCTION pending_vi_adjustments_exists(p_invoice_id IN NUMBER)
RETURN varchar2;
pragma RESTRICT_REFERENCES (pending_vi_adjustments_exists,WNDS,WNPS);

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : check_ap_invoices
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Calls Oracle Payables API(AP_PA_API_PKG.get_invoice_status).
--                 The AP API returns the message_name if adjustments on this
--		   invoice have to be prevented. The message_name's returned
--                 by this function are as follows.
--
--  	1) PA_INV_CANCELLED: If the invoice has already been cancelled.
--   	2) PA_INV_PREPAY: If the prepayment associated with this item has
--     	   been partially or fully paid.
--  	3) PA_INV_NOADJUST: If the invoice associated with this
--         item has been partially or fully paid and the payables options
--     	   setting does not allow you to adjust paid invoices.
--  	4) PA_INV_DISC_PRORATE: If the invoice associated with
--     	   this item has been partially or fully paid and there are discount
--     	   payment distributions associated with the invoice.
--  	5) PA_INV_PREPAY_AMOUNT: If a prepayment has been applied to the
--     	   supplier invoice associated with this item.
--  	6) PA_INV_CASH: If you are running cash basis accounting.
--  	7) PA_INV_SEL_PAYMENT: If the invoice associated with this
--     	   item has been selected for payment.
--  	   ELSE returns 'N'
-- Purity        : WNDS, WNPS.
-- Parameters    :
-- IN              P_Invoice_id          IN   NUMBER     Required
--                          Invoice Identifier, Corresponds to column
--                          INVOICE_ID of AP_INVOICES_ALL Table
--                 P_status_type         IN VARCHAR2     Required
--                          Valid values are 'ADJUSTMENTS' and 'TRANSFER'
--                          TRANSFER = Checks if invoice is selected for
--				       payment
--			    ADJUSTMENTS= Checks if invoice is selected for
--                                       payment + all other invoice statuses
--                                       that should prevent Orcale projects
--                                       from doing any kind of adjustments.
--
-- RETURNS         Message_Name, if adjustments are to be prevented for this
--  	    	                 Invoice.
--                 'N'           if adjustments are allowed for this invoice.
-- End of Comments
/*---------------------------------------------------------------------------*/


FUNCTION check_ap_invoices(p_invoice_id IN NUMBER,
			   p_status_type IN VARCHAR2) RETURN VARCHAR2;
pragma RESTRICT_REFERENCES(check_ap_invoices,WNDS,WNPS);

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : init_ap_invoices
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Initializes package body global variable l_invoice_id,
--		   l_invoice_status and l_status_type.  This function is used by
--                  pro*c programs
--                 to improve performance.
-- Parameters    : None
/*----------------------------------------------------------------------------*/

PROCEDURE init_ap_invoices;
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : ap_invoice_status
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : The functionality of this function is exactly same as
-- 		   check_ap_invoices. It has some performance enhancements for
--		   batch and pro*c programs. Another difference is it returns
--                 'Y' instead of message_name.
-- Parameters    :
-- IN              P_Invoice_id          IN   NUMBER     Required
--                          Invoice Identifier, Corresponds to column
--                          INVOICE_ID of AP_INVOICES_ALL Table
--                 P_status_type         IN VARCHAR2     Required
--                          Valid values are 'ADJUSTMENTS' and 'TRANSFER'
--                          TRANSFER = Checks if invoice is selected for
--                                     payment
--                          ADJUSTMENTS= Checks if invoice is selected for
--                                       payment + all other invoice statuses
--                                       that should prevent Orcale projects
--                                       from doing any kind of adjustments.
/*----------------------------------------------------------------------------*/
FUNCTION ap_invoice_status(p_invoice_id IN NUMBER,
			   p_status_type IN VARCHAR2) RETURN VARCHAR2;
pragma RESTRICT_REFERENCES(ap_invoice_status,WNDS);
/*----------------------------------------------------------------------------*/
PROCEDURE refresh_pa_cache ( p_org_id   IN NUMBER ,
                             p_expenditure_item_date  IN DATE ,
                             p_accounting_date IN DATE,
                             p_caller_flag     IN VARCHAR2
                           );
pragma RESTRICT_REFERENCES(refresh_pa_cache ,WNDS) ;
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_raw_cdl_pa_date
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : This function is used by PAVVIT ( transfer supplier Invoices)
--                 to Projects, process. Based on the expenditure item date and
--                 Accounting date, this function derives PA_DATE for the Raw
--                 CDLs to be populated.
-- Parameters    :
--                 P_Expenditure_Item_date   IN   DATE  Required
--                       Expenditure Item date
--                 P_Accounting_date  IN DATE  required.
--                       The GL Date on which the raw cost was posted from
--                       payables module to GL Module
--  Since this function will be used in Select the
--  Purity level will be WNDS, WNPS.
--- FUnction Created for Bug no : 1103257
/*----------------------------------------------------------------------------*/
FUNCTION   get_raw_cdl_pa_date ( p_expenditure_item_date  IN DATE,
                                 p_accounting_date        IN DATE,
                                 p_org_id                    NUMBER
                               ) RETURN DATE;
pragma RESTRICT_REFERENCES(get_raw_cdl_pa_date,WNDS) ;         /** removed WNPS **/
/*----------------------------------------------------------------------------*/
FUNCTION   get_raw_cdl_recvr_pa_date ( p_expenditure_item_date  IN DATE,
                                 p_accounting_date   IN DATE,
                                 p_org_id               NUMBER
                               ) RETURN DATE;
pragma RESTRICT_REFERENCES(get_raw_cdl_recvr_pa_date,WNDS) ;
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_burden_cdl_pa_date
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : This function is used by FCODTBC ( Distribute burden cost )
--                 process. Based on the PA_DATE date for corresponding
--                 RAw CDL. This function will be called only if the raw cost
--                 type is Supplier invoices.
-- Parameters    :
--                 P_raw_cdl_pa_date   IN   DATE  Required
--                       PA_DATE for corresponding Raw CDL
-- Since this function will be used in Select the
-- Purity level will be WNDS, WNPS.
-- FUnction created for Bug No : 1103257
/*----------------------------------------------------------------------------*/
FUNCTION   get_burden_cdl_pa_date ( p_raw_cdl_date IN DATE )
                    RETURN DATE;
pragma RESTRICT_REFERENCES(get_burden_cdl_pa_date,WNDS,WNPS);
/*----------------------------------------------------------------------------*/
PROCEDURE get_period_information ( p_expenditure_item_date IN pa_expenditure_items_all.expenditure_item_date%TYPE
                                  ,p_prvdr_gl_date IN pa_cost_distribution_lines_all.gl_date%TYPE
                                  ,p_line_type IN pa_cost_distribution_lines_all.line_type%TYPE
                                  ,p_prvdr_org_id IN pa_expenditure_items_all.org_id%TYPE
                                  ,p_recvr_org_id IN pa_expenditure_items_all.org_id%TYPE
                                  ,p_prvdr_sob_id IN pa_implementations_all.set_of_books_id%TYPE
                                  ,p_recvr_sob_id IN pa_implementations_all.set_of_books_id%TYPE
                                  ,x_prvdr_pa_date OUT NOCOPY pa_cost_distribution_lines_all.pa_date%TYPE
                                  ,x_prvdr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.pa_period_name%TYPE
                                  ,x_prvdr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.gl_period_name%TYPE
                                  ,x_recvr_pa_date OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_date%TYPE
                                  ,x_recvr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE
                                  ,x_recvr_gl_date OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_date%TYPE
                                  ,x_recvr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE
                                  ,x_return_status OUT NOCOPY NUMBER
                                  ,x_error_code OUT NOCOPY VARCHAR2
                                  ,x_error_stage OUT NOCOPY NUMBER
                                 );
/*----------------------------------------------------------------------------*/
FUNCTION get_gl_period_name ( p_gl_date         IN pa_cost_distribution_lines_all.gl_date%TYPE
                             ,p_set_of_books_id IN pa_implementations_all.set_of_books_id%TYPE
                            ) RETURN pa_cost_distribution_lines_all.gl_period_name%TYPE;
/*----------------------------------------------------------------------------*/
END pa_integration;

 

/
