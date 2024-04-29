--------------------------------------------------------
--  DDL for Package PA_AP_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AP_INTEGRATION" AUTHID CURRENT_USER AS
--$Header: PAAPINTS.pls 120.3.12010000.2 2009/12/23 11:26:59 rrambati ship $


PROCEDURE upd_pa_details_supplier_merge
			   ( p_old_vendor_id   IN po_vendors.vendor_id%type,
			     p_new_vendor_id   IN po_vendors.vendor_id%type,
			     p_paid_inv_flag   IN ap_invoices_all.PAYMENT_STATUS_FLAG%type,
			     p_invoice_id      IN ap_invoices_all.invoice_id%TYPE DEFAULT NULL, /* Bug# 8845025 */
			     x_stage          OUT NOCOPY VARCHAR2,
			     x_status         OUT NOCOPY VARCHAR2);


FUNCTION Allow_Supplier_Merge ( p_vendor_id         IN po_vendors.vendor_id%type)
RETURN varchar2;

PROCEDURE get_asset_addition_flag
             (p_project_id           IN  pa_projects_all.project_id%TYPE,
              x_asset_addition_flag  OUT NOCOPY ap_invoice_distributions_all.assets_addition_flag%TYPE);

FUNCTION Get_Project_Type ( p_project_id IN pa_projects_all.project_id%TYPE)
RETURN varchar2;

-- ==========================================================================================================================================
-- Bug 5201382 R12.PJ:XB3:DEV:NEW API TO RETRIEVE THE DATES FOR PROFILE PA_AP_EI_DATE_DEFAULT
-- p_transaction_date : API would return transaction date when profile value was set to 'Transaction Date'
--                       a. For Invoice transaction invoice_date should be passed as parameter
--                       b. For PO or Receipt Matched Invoice  Transactions invoice_date should be passed as parameter
--                       c. For RCV Transactions transaction_date should be passed.
--                       d. For payments and discounts ap dist exp_item_date should be passed.
-- p_gl_date          : API would return transaction date when profile value was set to 'Transaction GL Date'
--                      a. For Invoice transactions gl_date should be passed b. For payments and discounts the accounting date must be passed
--                      c. for RCV transactions accounting date should be passed.
-- p_po_exp_item_date : API would return the purchase order expenditure item date for po matched cases when profile value was set to
--                      'PO Expenditure Item Date/Transaction Date'. This is used for PO matched cases. It may be NULL when
--                       p_po_distribution_id was passed to the API.
-- p_po_distribution_id: The parameter value is used to determine the purchase order expenditure item date for po matched cases when profile
--                        value was set to 'PO Expenditure Item Date/Transaction Date'. when p_po_exp_item_date was passed  then
--                        p_po_distribution_id is not used to derive the expenditure item date.
-- p_creation_date : API would return this date when profile value was set to 'Transaction System Date'
-- p_calling_program : a. when called during the PO Match case : PO-MATCH b. When called from Invoice form        : APXINWKB
--                     c. When called from supplier cost xface for discounts : DISCOUNT d. When called from supplier cost xface for Payment: PAYMENT
--                     e. When called from supplier cost xface for Receipts  : RECEIPT
-- ==========================================================================================================================================
FUNCTION Get_si_cost_exp_item_date ( p_transaction_date      IN pa_expenditure_items_all.expenditure_item_date%TYPE,
                                     p_gl_date               IN pa_cost_distribution_lines_all.gl_date%TYPE,
                                     p_po_exp_item_date      IN pa_expenditure_items_all.expenditure_item_date%TYPE,
                                     p_creation_date         IN pa_expenditure_items_all.creation_date%TYPE,
                                     p_po_distribution_id    IN pa_expenditure_items_all.document_distribution_id%TYPE,
                                     p_calling_program       IN varchar2  )
RETURN date ;

FUNCTION Get_si_default_exp_org RETURN varchar2 ;

END pa_ap_integration;

/
