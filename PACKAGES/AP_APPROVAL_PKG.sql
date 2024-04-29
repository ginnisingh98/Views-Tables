--------------------------------------------------------
--  DDL for Package AP_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APPROVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: apaprvls.pls 120.16.12010000.10 2009/08/16 07:21:54 sbonala ship $ */

/*=============================================================================
 | Global variable Spec
 *===========================================================================*/

 g_debug_mode	VARCHAR2(1):= 'N';

 ---
 TYPE g_org_holds_rec IS RECORD(
		hold_lookup_code	ap_holds_all.hold_lookup_code%type,
		holds_placed		NUMBER,
		holds_released		NUMBER,
                org_id                  ap_invoices_all.org_id%type);

 TYPE g_org_holds_tab IS TABLE OF g_org_holds_rec
 INDEX BY BINARY_INTEGER;

 g_org_holds g_org_holds_tab;
 ---

 TYPE HoldsArray IS TABLE OF ap_holds.hold_lookup_code%TYPE
 INDEX BY BINARY_INTEGER;

 TYPE CountArray IS TABLE OF NUMBER
 INDEX BY BINARY_INTEGER;
 ---

 TYPE Goods_Tolerance_Rec Is RECORD(
	 price_tolerance		ap_tolerance_templates.price_tolerance%type,
	 quantity_tolerance		ap_tolerance_templates.quantity_tolerance%type,
	 qty_received_tolerance		ap_tolerance_templates.qty_received_tolerance%type,
	 max_qty_ord_tolerance		ap_tolerance_templates.max_qty_ord_tolerance%type,
	 max_qty_rec_tolerance		ap_tolerance_templates.max_qty_rec_tolerance%type,
	 ship_amt_tolerance		ap_tolerance_templates.ship_amt_tolerance%type,
	 rate_amt_tolerance		ap_tolerance_templates.rate_amt_tolerance%type,
	 total_amt_tolerance		ap_tolerance_templates.total_amt_tolerance%type);

 TYPE GOODS_TOLERANCES_TAB IS TABLE OF Goods_Tolerance_Rec
 INDEX BY PLS_INTEGER;

 G_GOODS_TOLERANCES GOODS_TOLERANCES_TAB;
 ---

 TYPE Services_Tolerances_Rec IS RECORD(
		 amount_tolerance		ap_tolerance_templates.price_tolerance%type,
                 amt_received_tolerance		ap_tolerance_templates.quantity_tolerance%type,
                 max_amt_ord_tolerance		ap_tolerance_templates.max_qty_ord_tolerance%type,
                 max_amt_rec_tolerance		ap_tolerance_templates.max_qty_rec_tolerance%type,
                 ser_ship_amt_tolerance		ap_tolerance_templates.ship_amt_tolerance%type,
                 ser_rate_amt_tolerance		ap_tolerance_templates.rate_amt_tolerance%type,
                 ser_total_amt_tolerance	ap_tolerance_templates.total_amt_tolerance%type);

 TYPE SERVICES_TOLERANCES_TAB IS TABLE OF Services_Tolerances_Rec
 INDEX BY PLS_INTEGER;

 G_SERVICES_TOLERANCES SERVICES_TOLERANCES_TAB;
 ---

 TYPE Options_Record Is RECORD(
		chart_of_accounts_id                 gl_sets_of_books.chart_of_accounts_id%type,
		set_of_books_id                      gl_sets_of_books.set_of_books_id%type,
		automatic_offsets_flag               ap_system_parameters.automatic_offsets_flag%type,
		recalc_pay_schedule_flag             ap_system_parameters.recalc_pay_schedule_flag%type,
		liability_post_lookup_code           ap_system_parameters.liability_post_lookup_code%type,
		rate_var_gain_ccid                   ap_system_parameters.rate_var_gain_ccid%type,
		rate_var_loss_ccid                   ap_system_parameters.rate_var_loss_ccid%type,
		base_currency_code                   ap_system_parameters.base_currency_code%type,
		match_on_tax_flag                    ap_system_parameters.match_on_tax_flag%type,
		enforce_tax_from_account             ap_system_parameters.enforce_tax_from_account%type,
		inv_encumbrance_type_id              financials_system_parameters.inv_encumbrance_type_id%type,
		purch_encumbrance_type_id            financials_system_parameters.purch_encumbrance_type_id%type,
		receipt_acceptance_days              financials_system_parameters.receipt_acceptance_days%type,
		gl_date_from_receipt_flag            ap_system_parameters.gl_date_from_receipt_flag%type,
		accounting_method_option             ap_system_parameters.accounting_method_option%type,
		secondary_accounting_method          ap_system_parameters.secondary_accounting_method%type,
		cash_basis_enc_nr_tax                financials_system_parameters.cash_basis_enc_nr_tax%type,
		non_recoverable_tax_flag             financials_system_parameters.non_recoverable_tax_flag%type,
		disc_is_inv_less_tax_flag            ap_system_parameters.disc_is_inv_less_tax_flag%type,
		org_id                               financials_system_parameters.org_id%type,
		System_User                          NUMBER,
		User_ID                              NUMBER);

 TYPE Options_Table IS TABLE OF Options_Record
 INDEX BY PLS_INTEGER;

 G_OPTIONS_TABLE	Options_Table;
 ---

 TYPE Invoice_Rec IS RECORD(
		invoice_id 			ap_invoices_all.invoice_id%type,
		invoice_num 			ap_invoices_all.invoice_num%type,
		org_id 				ap_invoices_all.org_id%type,
		invoice_amount 			ap_invoices_all.invoice_amount%type,
		base_amount 			ap_invoices_all.base_amount%type,
		exchange_rate 			ap_invoices_all.exchange_rate%type,
		invoice_currency_code 		ap_invoices_all.invoice_currency_code%type,
		invoice_amount_limit 		ap_supplier_sites_all.invoice_amount_limit%type,
		hold_future_payments_flag 	ap_supplier_sites_all.hold_future_payments_flag%type,
		invoice_type_lookup_code 	ap_invoices_all.invoice_type_lookup_code%type,
		exchange_date 			ap_invoices_all.exchange_date%type,
		exchange_rate_type 		ap_invoices_all.exchange_rate_type%type,
		vendor_id 			ap_invoices_all.vendor_id%type,
		invoice_date 			ap_invoices_all.invoice_date%type,
		disc_is_inv_less_tax_flag 	ap_invoices_all.disc_is_inv_less_tax_flag%type,
		exclude_freight_from_discount 	ap_invoices_all.exclude_freight_from_discount%type,
		tolerance_id 			ap_supplier_sites_all.tolerance_id%type,
		services_tolerance_id 		ap_supplier_sites_all.services_tolerance_id%type);

 TYPE Invoices_Table IS TABLE OF Invoice_Rec
 INDEX BY PLS_INTEGER;

 G_INVOICES_TABLE		Invoices_Table;
 G_SELECTED_INVOICES		Invoices_Table;
 G_VALIDATION_REQUEST_ID	NUMBER;
 ---

/*=============================================================================
 | Public Procedure Specification
 *============================================================================*/

PROCEDURE Cache_Options
            (p_calling_sequence              IN VARCHAR2);

PROCEDURE Cache_Tolerance_Templates
            (p_tolerance_id                  IN NUMBER,
             p_services_tolerance_id         IN NUMBER,
             p_calling_sequence              IN VARCHAR2);

PROCEDURE Generate_Distributions
                (p_invoice_rec          IN AP_APPROVAL_PKG.Invoice_Rec,
                 p_base_currency_code   IN VARCHAR2,
                 p_inv_batch_id         IN NUMBER,
                 p_run_option           IN VARCHAR2,
                 p_calling_sequence     IN VARCHAR2,
                 x_error_code           IN VARCHAR2,
                 p_calling_mode	        IN VARCHAR2 DEFAULT NULL ); --bug6833543
--Bug 8346277
PROCEDURE Generate_Manual_Awt_Dist
                (p_invoice_rec          IN AP_APPROVAL_PKG.Invoice_Rec,
                 p_base_currency_code   IN VARCHAR2,
                 p_inv_batch_id         IN NUMBER,
                 p_run_option           IN VARCHAR2,
                 p_calling_sequence     IN VARCHAR2,
                 x_error_code           IN VARCHAR2,
                 p_calling_mode	        IN VARCHAR2 DEFAULT NULL );

PROCEDURE Process_Inv_Hold_Status(
              p_invoice_id          IN            NUMBER,
              p_line_location_id    IN            NUMBER,
              p_rcv_transaction_id  IN            NUMBER,
              p_hold_lookup_code    IN            VARCHAR2,
              p_should_have_hold    IN            VARCHAR2,
              p_hold_reason         IN            VARCHAR2,
              p_system_user         IN            NUMBER,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_holds_count         IN OUT NOCOPY COUNTARRAY,
              p_release_count       IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2);

PROCEDURE Get_Hold_Status(
              p_invoice_id          IN            NUMBER,
              p_line_location_id    IN            NUMBER,
              p_rcv_transaction_id  IN            NUMBER,
              p_hold_lookup_code    IN            VARCHAR2,
              p_system_user         IN            NUMBER,
              p_status              IN OUT NOCOPY VARCHAR2,
              p_return_hold_reason  IN OUT NOCOPY VARCHAR2,
              p_user_id             IN OUT NOCOPY VARCHAR2,
              p_resp_id             IN OUT NOCOPY VARCHAR2,
              p_calling_sequence    IN            VARCHAR2);

PROCEDURE Approve(
              p_run_option          IN            VARCHAR2,
              p_invoice_batch_id    IN            NUMBER,
              p_begin_invoice_date  IN            DATE DEFAULT NULL,
              p_end_invoice_date    IN            DATE DEFAULT NULL,
              p_vendor_id           IN            NUMBER,
              p_pay_group           IN            VARCHAR2,
              p_invoice_id          IN            NUMBER,
              p_entered_by          IN            NUMBER,
              p_set_of_books_id     IN            NUMBER,
              p_trace_option        IN            VARCHAR2,
              p_conc_flag           IN            VARCHAR2,
              p_holds_count         IN OUT NOCOPY NUMBER,
              p_approval_status     IN OUT NOCOPY VARCHAR2,
              p_funds_return_code   OUT NOCOPY    VARCHAR2, -- 4276409 (3462325)
	      p_calling_mode	    IN		  VARCHAR2 DEFAULT 'APPROVE',
              p_calling_sequence    IN            VARCHAR2,
              p_debug_switch        IN            VARCHAR2 DEFAULT 'N',
              p_budget_control      IN            VARCHAR2 DEFAULT 'Y',
              p_commit              IN            VARCHAR2 DEFAULT 'Y');

PROCEDURE Release_Hold(
              p_invoice_id          IN            NUMBER,
              p_line_location_id    IN            NUMBER,
              p_rcv_transaction_id  IN            NUMBER,
              p_hold_lookup_code    IN            VARCHAR2,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_release_count       IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2);

PROCEDURE Check_Insufficient_Line_Data(
              p_inv_line_rec            IN AP_INVOICES_PKG.r_invoice_line_rec,
	      p_system_user             IN            NUMBER,
	      p_holds                   IN OUT NOCOPY HOLDSARRAY,
	      p_holds_count             IN OUT NOCOPY COUNTARRAY,
	      p_release_count           IN OUT NOCOPY COUNTARRAY,
	      p_insufficient_data_exist    OUT NOCOPY BOOLEAN,
              --ETAX: Validation
	      p_calling_mode		IN	      VARCHAR2,
	      p_calling_sequence        IN            VARCHAR2);

FUNCTION  Execute_Dist_Generation_Check(
              p_batch_id                IN            NUMBER,
	      p_invoice_date            IN            DATE,
	      p_vendor_id               IN            NUMBER,
	      p_invoice_currency        IN            VARCHAR2,
	      p_exchange_rate           IN            NUMBER,
	      p_exchange_rate_type      IN            VARCHAR2,
	      p_exchange_date           IN            DATE,
	      p_inv_line_rec            IN AP_INVOICES_PKG.r_invoice_line_rec,
	      p_system_user             IN            NUMBER,
	      p_holds                   IN OUT NOCOPY HOLDSARRAY,
	      p_holds_count             IN OUT NOCOPY COUNTARRAY,
	      p_release_count           IN OUT NOCOPY COUNTARRAY,
	      p_generate_permanent      IN            VARCHAR2,
              --ETAX: Validation
	      p_calling_mode            IN VARCHAR2 DEFAULT 'VALIDATION',
	      p_error_code              OUT NOCOPY    VARCHAR2,
	      p_curr_calling_sequence   IN            VARCHAR2) RETURN BOOLEAN;

--Bugfix:4673607
FUNCTION Is_Product_Registered(P_Application_Id      IN         NUMBER,
			       X_Registration_Api    OUT NOCOPY VARCHAR2,
			       X_Registration_View   OUT NOCOPY VARCHAR2,
			       P_Calling_Sequence    IN         VARCHAR2) RETURN BOOLEAN;

--Bugfix:4673607
FUNCTION  Gen_Dists_From_Registration(
                 P_Batch_Id            IN  NUMBER,
		 P_Invoice_Line_Rec    IN  AP_INVOICES_PKG.r_invoice_line_rec,
		 P_Registration_Api    IN  VARCHAR2,
		 P_Registration_View   IN  VARCHAR2,
		 P_Generate_Permanent  IN  VARCHAR2,
		 X_Error_Code          OUT NOCOPY VARCHAR2,
		 P_Calling_Sequence    IN  VARCHAR2) RETURN BOOLEAN;

--BugFix: 3489536
FUNCTION Batch_Approval
                (p_run_option           IN VARCHAR2,
                 p_sob_id               IN NUMBER,
                 p_inv_start_date       IN DATE,
                 p_inv_end_date         IN DATE,
                 p_inv_batch_id         IN NUMBER,
                 p_vendor_id            IN NUMBER,
                 p_pay_group            IN VARCHAR2,
                 p_invoice_id           IN NUMBER,
                 p_entered_by           IN NUMBER,
                 p_debug_switch         IN VARCHAR2,
                 p_conc_request_id      IN NUMBER,
                 p_commit_size          IN NUMBER,
                 p_org_id               IN NUMBER,
                 p_report_holds_count   OUT NOCOPY NUMBER,
		 p_transaction_num      IN NUMBER DEFAULT NULL) RETURN BOOLEAN; -- Bug 8234569
		-- Bug 8647857
		-- Added DEFAULT value as NULL to parameter p_transaction_num

-- added for bug 6892789
--This function returns base amount after rouding.
--Also calculates the rounding amount for the next line
FUNCTION get_adjusted_base_amount(p_base_amount IN NUMBER,
                                  p_rounding_amt OUT NOCOPY NUMBER,
                                  p_next_line_rounding_amt IN OUT NOCOPY NUMBER)
RETURN NUMBER;

--Start 8691645
  PROCEDURE CHECK_CCR_VENDOR(
              P_INVOICE_ID                IN     AP_INVOICES.INVOICE_ID%TYPE,
              P_VENDOR_ID                 IN     AP_INVOICES.VENDOR_ID%TYPE,
              P_VENDOR_SITE_ID            IN     AP_INVOICES.VENDOR_SITE_ID%TYPE,
	      P_REMIT_TO_SUPPLIER_SITE_ID IN     AP_INVOICES.REMIT_TO_SUPPLIER_SITE_ID%TYPE,
              P_SYSTEM_USER               IN     NUMBER,
              P_HOLDS                     IN OUT NOCOPY HOLDSARRAY,
              P_HOLDS_COUNT               IN OUT NOCOPY COUNTARRAY,
              P_RELEASE_COUNT             IN OUT NOCOPY COUNTARRAY,
	      P_VENDOR_SITE_REG_EXPIRED   OUT    NOCOPY VARCHAR2,
              P_CALLING_SEQUENCE          IN     VARCHAR2);


PROCEDURE UPDATE_SCHEDULES(P_INVOICE_ID       IN AP_INVOICES.INVOICE_ID%TYPE,
                           P_CALLING_SEQUENCE IN VARCHAR2);

PROCEDURE BATCH_APPROVAL_FOR_VENDOR(P_VENDOR_ID        IN AP_INVOICES.VENDOR_ID%TYPE,
                                   P_CALLING_SEQUENCE IN VARCHAR2);
--End 8691645

END AP_APPROVAL_PKG;

/
