--------------------------------------------------------
--  DDL for Package AP_IMPORT_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_IMPORT_UTILITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: apiimuts.pls 120.19 2006/11/11 00:08:51 schitlap noship $ */

FUNCTION Check_control_table(
          p_source              IN     VARCHAR2,
          p_group_id            IN     VARCHAR2,
          p_calling_sequence    IN     VARCHAR2) RETURN BOOLEAN;

PROCEDURE Print (
          P_debug               IN     VARCHAR2,
          P_string              IN     VARCHAR2);

FUNCTION insert_rejections (
          p_parent_table        IN     VARCHAR2,
          p_parent_id           IN     NUMBER,
          p_reject_code         IN     VARCHAR2,
          p_last_updated_by     IN     NUMBER,
          p_last_update_login   IN     NUMBER,
          p_calling_sequence    IN     VARCHAR2,
          p_notify_vendor_flag  IN     VARCHAR2 DEFAULT NULL,
          p_token_name1         IN     VARCHAR2 DEFAULT NULL,
          p_token_value1        IN     VARCHAR2 DEFAULT NULL,
          p_token_name2         IN     VARCHAR2 DEFAULT NULL,
          p_token_value2        IN     VARCHAR2 DEFAULT NULL,
          p_token_name3         IN     VARCHAR2 DEFAULT NULL,
          p_token_value3        IN     VARCHAR2 DEFAULT NULL,
          p_token_name4         IN     VARCHAR2 DEFAULT NULL,
          p_token_value4        IN     VARCHAR2 DEFAULT NULL,
          p_token_name5         IN     VARCHAR2 DEFAULT NULL,
          p_token_value5        IN     VARCHAR2 DEFAULT NULL,
          p_token_name6         IN     VARCHAR2 DEFAULT NULL,
          p_token_value6        IN     VARCHAR2 DEFAULT NULL,
          p_token_name7         IN     VARCHAR2 DEFAULT NULL,
          p_token_value7        IN     VARCHAR2 DEFAULT NULL,
          p_token_name8         IN     VARCHAR2 DEFAULT NULL,
          p_token_value8        IN     VARCHAR2 DEFAULT NULL,
          p_token_name9         IN     VARCHAR2 DEFAULT NULL,
          p_token_value9        IN     VARCHAR2 DEFAULT NULL,
          p_token_name10        IN     VARCHAR2 DEFAULT NULL,
          p_token_value10       IN     VARCHAR2 DEFAULT NULL) RETURN BOOLEAN;


FUNCTION get_overbill_for_shipment (
          p_po_shipment_id         IN          NUMBER,
          p_quantity_invoiced      IN          NUMBER,
   	  p_amount_invoiced	   IN	       NUMBER,
          p_overbilled             OUT NOCOPY  VARCHAR2,
          p_quantity_outstanding   OUT NOCOPY  NUMBER,
          p_quantity_ordered       OUT NOCOPY  NUMBER,
          p_qty_already_billed     OUT NOCOPY  NUMBER,
  	  p_amount_outstanding     OUT NOCOPY  NUMBER,
  	  p_amount_ordered	   OUT NOCOPY  NUMBER,
  	  p_amt_already_billed	   OUT NOCOPY  NUMBER,
          p_calling_sequence       IN          VARCHAR2) RETURN BOOLEAN;

FUNCTION get_batch_id (
          p_batch_name          IN             VARCHAR2,
          P_batch_id               OUT NOCOPY  NUMBER,
          p_batch_type             OUT NOCOPY  VARCHAR2,
          P_calling_sequence    IN             VARCHAR2) RETURN BOOLEAN;

FUNCTION get_info (
          p_org_id                         IN         NUMBER,
          p_set_of_books_id                OUT NOCOPY NUMBER,
          p_multi_currency_flag            OUT NOCOPY VARCHAR2,
          p_make_rate_mandatory_flag       OUT NOCOPY VARCHAR2,
          p_default_exchange_rate_type     OUT NOCOPY VARCHAR2,
          p_base_currency_code             OUT NOCOPY VARCHAR2,
          p_batch_control_flag             OUT NOCOPY VARCHAR2,
          p_invoice_currency_code          OUT NOCOPY VARCHAR2,
          p_base_min_acct_unit             OUT NOCOPY NUMBER,
          p_base_precision                 OUT NOCOPY NUMBER,
          p_sequence_numbering             OUT NOCOPY VARCHAR2,
          p_awt_include_tax_amt            OUT NOCOPY VARCHAR2,
          p_gl_date                     IN OUT NOCOPY DATE,
       -- Removed for bug 4277744
       -- p_ussgl_transcation_code         OUT NOCOPY VARCHAR2,
          p_trnasfer_desc_flex_flag        OUT NOCOPY VARCHAR2,
          p_gl_date_from_receipt_flag      OUT NOCOPY VARCHAR2,
          p_purch_encumbrance_flag         OUT NOCOPY VARCHAR2,
	  p_retainage_ccid		   OUT NOCOPY NUMBER,
          P_pa_installed                   OUT NOCOPY VARCHAR2,
          p_chart_of_accounts_id           OUT NOCOPY NUMBER,
          p_inv_doc_cat_override           OUT NOCOPY VARCHAR2,
          p_calc_user_xrate                OUT NOCOPY VARCHAR2,
          p_calling_sequence            IN            VARCHAR2,
          p_approval_workflow_flag         OUT NOCOPY VARCHAR2,
          p_freight_code_combination_id    OUT NOCOPY NUMBER,
	  p_allow_interest_invoices	OUT NOCOPY    VARCHAR2, --bug4113223
	  p_add_days_settlement_date       OUT NOCOPY NUMBER,    --bug4930111
          p_disc_is_inv_less_tax_flag      OUT NOCOPY VARCHAR2,  /* bug4931755. Exc Tax fr Disc */
          p_source                         IN         VARCHAR2,  -- bug 5382889. LE TimeZone
          p_invoice_date                   IN         DATE,      -- bug 5382889. LE TimeZone
          p_goods_received_date            IN         DATE,      -- bug 5382889. LE TimeZone
          p_asset_book_type                OUT NOCOPY VARCHAR2   -- bug 5448579
) RETURN BOOLEAN;

FUNCTION get_tolerance_info(
	p_vendor_site_id		IN 		NUMBER,
	p_positive_price_tolerance      OUT NOCOPY      NUMBER,
	p_negative_price_tolerance      OUT NOCOPY      NUMBER,
	p_qty_tolerance                 OUT NOCOPY      NUMBER,
	p_qty_rec_tolerance             OUT NOCOPY      NUMBER,
	p_max_qty_ord_tolerance         OUT NOCOPY      NUMBER,
	p_max_qty_rec_tolerance         OUT NOCOPY      NUMBER,
	p_amt_tolerance                 OUT NOCOPY      NUMBER,
	p_amt_rec_tolerance             OUT NOCOPY      NUMBER,
	p_max_amt_ord_tolerance         OUT NOCOPY      NUMBER,
	p_max_amt_rec_tolerance         OUT NOCOPY      NUMBER,
	p_goods_ship_amt_tolerance      OUT NOCOPY      NUMBER,
        p_goods_rate_amt_tolerance      OUT NOCOPY      NUMBER,
        p_goods_total_amt_tolerance     OUT NOCOPY      NUMBER,
	p_services_ship_amt_tolerance   OUT NOCOPY      NUMBER,
        p_services_rate_amt_tolerance   OUT NOCOPY      NUMBER,
        p_services_total_amt_tolerance  OUT NOCOPY      NUMBER,
	p_calling_sequence		IN		VARCHAR2)
RETURN BOOLEAN;

FUNCTION find_vendor_primary_paysite(
          p_vendor_id                   IN            NUMBER,
          p_vendor_primary_paysite_id      OUT NOCOPY NUMBER,
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION get_employee_id(
          p_invoice_id                  IN            NUMBER,
          p_vendor_id                   IN            NUMBER,
          p_employee_id                    OUT NOCOPY NUMBER,
          p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
          p_current_invoice_status         OUT NOCOPY VARCHAR2,
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION get_overbill_for_po_line(
          p_po_line_id                  IN            NUMBER,
          p_quantity_invoiced           IN            NUMBER,
	  p_amount_invoiced		IN	      NUMBER,
          p_overbilled                  OUT NOCOPY    VARCHAR2,
          p_outstanding                 OUT NOCOPY    NUMBER,
          p_ordered               	OUT NOCOPY    NUMBER,
          p_already_billed              OUT NOCOPY    NUMBER,
	  p_po_line_matching_basis      OUT NOCOPY    VARCHAR2,
          P_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION pa_flexbuild (
          p_invoice_rec                 IN
             AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
          p_invoice_lines_rec           IN OUT NOCOPY
             AP_IMPORT_INVOICES_PKG.r_line_info_rec,
          p_accounting_date             IN            DATE,
          p_pa_installed                IN            VARCHAR2,
          p_employee_id                 IN            NUMBER,
          p_base_currency_code          IN            VARCHAR2,
          p_chart_of_accounts_id        IN            NUMBER,
          p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
          p_pa_default_dist_ccid           OUT NOCOPY NUMBER,
          p_pa_concatenated_segments       OUT NOCOPY VARCHAR2,
          p_current_invoice_status         OUT NOCOPY VARCHAR2,
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION get_doc_sequence(
          p_invoice_rec                 IN OUT
              AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
          p_inv_doc_cat_override        IN            VARCHAR2,
      p_set_of_books_id             IN            NUMBER,
      p_sequence_numbering          IN            VARCHAR2,
          p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
          p_db_sequence_value              OUT NOCOPY NUMBER,
          p_db_seq_name                    OUT NOCOPY VARCHAR2,
          p_db_sequence_id                 OUT NOCOPY NUMBER,
          p_current_invoice_status         OUT NOCOPY VARCHAR2,
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION get_invoice_info(
          p_invoice_rec                 IN OUT NOCOPY
              AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
      p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
          p_pay_curr_invoice_amount        OUT NOCOPY NUMBER,
          p_payment_priority               OUT NOCOPY NUMBER,
          p_invoice_amount_limit           OUT NOCOPY NUMBER,
          p_hold_future_payments_flag      OUT NOCOPY VARCHAR2,
          p_supplier_hold_reason           OUT NOCOPY VARCHAR2,
          p_exclude_freight_from_disc      OUT NOCOPY VARCHAR2, /*bug 4931755.Excl Tax fr Discount */
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

--Payment Request: Added p_needs_invoice_approval for payment request invoices
FUNCTION insert_ap_invoices(
          p_invoice_rec                 IN OUT
              AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
          p_base_invoice_id                OUT NOCOPY NUMBER,
          p_set_of_books_id             IN NUMBER,
          p_doc_sequence_id             IN
              AP_INVOICES.doc_sequence_id%TYPE,
          p_doc_sequence_value          IN
              AP_INVOICES.doc_sequence_value%TYPE,
          p_batch_id                    IN
          AP_INVOICES.batch_id%TYPE,
          p_pay_curr_invoice_amount     IN            NUMBER,
          p_approval_workflow_flag      IN            VARCHAR2,
          p_needs_invoice_approval      IN            VARCHAR2,
	  p_add_days_settlement_date    IN            NUMBER, --bugfix:4930111
          p_disc_is_inv_less_tax_flag   IN            VARCHAR2, /*bug 4931755.Excl Tax fr Discount */
          p_exclude_freight_from_disc   IN            VARCHAR2, /*bug 4931755.Excl Tax fr Discount */
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION change_invoice_status(
          p_status                      IN            VARCHAR2,
          p_import_invoice_id           IN            NUMBER,
          P_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION Update_temp_invoice_status(
          p_source                      IN            VARCHAR2,
          p_group_id                    IN            VARCHAR2,
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;
FUNCTION get_auto_batch_name(
          p_source                      IN            VARCHAR2,
          p_batch_name                     OUT NOCOPY VARCHAR2,
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION Insert_ap_batches(
          p_batch_id                    IN            NUMBER,
          p_batch_name                  IN            VARCHAR2,
          p_invoice_currency_code       IN            VARCHAR2,
          p_payment_currency_code       IN            VARCHAR2,
          p_actual_invoice_count        IN            NUMBER,
          p_actual_invoice_total        IN            NUMBER,
          p_last_updated_by             IN            NUMBER,
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION Update_Ap_Batches(
          p_batch_id                    IN            NUMBER,
          p_batch_name                  IN            VARCHAR2,
          p_actual_invoice_count        IN            NUMBER,
          p_actual_invoice_total        IN            NUMBER,
          p_last_updated_by             IN            NUMBER,
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION insert_ap_invoice_lines(
          p_base_invoice_id             IN            NUMBER,
          p_invoice_lines_tab           IN
                     AP_IMPORT_INVOICES_PKG.t_lines_table,
          p_set_of_books_id             IN            NUMBER,
          p_approval_workflow_flag      IN            VARCHAR2,
          p_tax_only_flag               IN            VARCHAR2,
          p_tax_only_rcv_matched_flag   IN            VARCHAR2,
          p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
        p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION Create_Lines(
          p_batch_id                    IN            NUMBER,
          p_base_invoice_id             IN            NUMBER,
          p_invoice_lines_tab           IN
                 AP_IMPORT_INVOICES_PKG.t_lines_table,
          p_base_currency_code          IN            VARCHAR2,
          p_set_of_books_id             IN            NUMBER,
          p_approval_workflow_flag      IN            VARCHAR2,
	  p_tax_only_flag		IN	      VARCHAR2,
	  p_tax_only_rcv_matched_flag   IN	      VARCHAR2,
          p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
          p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION insert_holds(
          p_base_invoice_id             IN            NUMBER,
          p_hold_code                   IN            VARCHAR2,
          p_hold_reason                 IN            VARCHAR2,
          p_hold_future_payments_flag   IN            VARCHAR2,
          p_supplier_hold_reason        IN            VARCHAR2,
          p_invoice_amount_limit        IN            NUMBER,
          p_invoice_base_amount         IN            NUMBER,
          p_last_updated_by             IN            NUMBER,
          P_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN ;

FUNCTION get_tax_only_rcv_matched_flag(
           P_invoice_id             IN NUMBER) RETURN VARCHAR2;

FUNCTION get_tax_only_flag(
           P_invoice_id             IN NUMBER) RETURN VARCHAR2;


/*  5039042. Function for Checking if Distribution Generation Event is rgeistered for the
   source application */
FUNCTION Is_Product_Registered(P_Application_Id      IN         NUMBER,
                               X_Registration_Api    OUT NOCOPY VARCHAR2,
                               X_Registration_View   OUT NOCOPY VARCHAR2,
                               P_Calling_Sequence    IN         VARCHAR2) RETURN BOOLEAN;

-- Bug 5448579. This function will be used for caching org_id, name
FUNCTION  Cache_Org_Id_Name (
          P_Moac_Org_Table     OUT NOCOPY   AP_IMPORT_INVOICES_PKG.moac_ou_tab_type,
          P_Fsp_Org_Table      OUT NOCOPY  AP_IMPORT_INVOICES_PKG.fsp_org_tab_type,
          P_Calling_Sequence   IN    VARCHAR2)  RETURN BOOLEAN;

-- Bug 5448579. This function will be used for checking term claendar based on terms_id
PROCEDURE Check_For_Calendar_Term
             (p_terms_id          IN       number,
              p_terms_date        IN       date,
              p_no_cal            IN OUT NOCOPY  varchar2,
              p_calling_sequence  IN       varchar2);

-- Bug 5448579. This function will be used for caching Pay Group
FUNCTION Cache_Pay_Group (
         P_Pay_Group_Table    OUT NOCOPY AP_IMPORT_INVOICES_PKG.pay_group_tab_type,
         P_Calling_Sequence   IN    VARCHAR2)  RETURN BOOLEAN;


-- Bug 5448579. This function will be used for caching Pay Group
FUNCTION Cache_Payment_Method (
         P_Payment_Method_Table    OUT NOCOPY AP_IMPORT_INVOICES_PKG.payment_method_tab_type,
         P_Calling_Sequence   IN    VARCHAR2)  RETURN BOOLEAN;

-- Bug 5448579. This function will be used for cachin Currency
FUNCTION Cache_Fnd_Currency (
         P_Fnd_Currency_Table    OUT  NOCOPY AP_IMPORT_INVOICES_PKG.fnd_currency_tab_type,
         P_Calling_Sequence      IN   VARCHAR2)  RETURN BOOLEAN;

END AP_IMPORT_UTILITIES_PKG;

 

/
