--------------------------------------------------------
--  DDL for Package AP_PREPAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PREPAY_PKG" AUTHID CURRENT_USER AS
/*$Header: aprepays.pls 120.8.12010000.3 2010/02/18 01:07:11 manjayar ship $*/

--==================================================================================
--  This record has two types of information
--  1) Prepayment Invoice's distribution information (Source)
--  2) PREPAY distribution's amounts/quantities information (Target)
--     all with the same prepay distribution id as its key. This should be declared
--     in the package spec.
--==================================================================================

TYPE Prepay_Dist_Record IS RECORD(

  PREPAY_DISTRIBUTION_ID  ap_invoice_distributions_all.invoice_distribution_id%TYPE,
  PPAY_AMOUNT             ap_invoice_distributions_all.amount%TYPE,
  PPAY_BASE_AMOUNT        ap_invoice_distributions_all.base_amount%TYPE,
  PPAY_AMOUNT_REMAINING   ap_invoice_distributions_all.prepay_amount_remaining%TYPE,
  PPAY_PO_DISTRIBUTION_ID ap_invoice_distributions_all.po_distribution_id%TYPE,
  PPAY_RCV_TRANSACTION_ID ap_invoice_distributions_all.rcv_transaction_id%TYPE,
  PPAY_QUANTITY_INVOICED  ap_invoice_distributions_all.quantity_invoiced%TYPE,
  PPAY_STAT_AMOUNT        ap_invoice_distributions_all.stat_amount%TYPE,
  PPAY_PA_QUANTITY        ap_invoice_distributions_all.pa_quantity%TYPE,
  PREPAY_APPLY_AMOUNT     ap_invoice_distributions_all.amount%TYPE,
  PREPAY_BASE_AMOUNT      ap_invoice_distributions_all.base_amount%TYPE,
  PREPAY_BASE_AMT_PPAY_XRATE ap_invoice_distributions_all.base_amount%TYPE,
  PREPAY_BASE_AMT_PPAY_PAY_XRATE ap_invoice_distributions_all.base_amount%TYPE,
  PREPAY_QUANTITY_INVOICED ap_invoice_distributions_all.quantity_invoiced%TYPE,
  PREPAY_STAT_AMOUNT      ap_invoice_distributions_all.stat_amount%TYPE,
  PREPAY_PA_QUANTITY      ap_invoice_distributions_all.pa_quantity%TYPE,
  PREPAY_ACCOUNTING_DATE  ap_invoice_distributions_all.accounting_date%TYPE,
  PREPAY_PERIOD_NAME      ap_invoice_distributions_all.period_name%TYPE,
  PREPAY_DIST_LINE_NUMBER ap_invoice_distributions_all.distribution_line_number%TYPE,
  PREPAY_GLOBAL_ATTR_CATEGORY ap_invoice_distributions_all.global_attribute_category%TYPE,
  PREPAY_MATCHING_BASIS   po_line_types.matching_basis%TYPE,
  LINE_TYPE_LOOKUP_CODE   ap_invoice_distributions.line_type_lookup_code%TYPE,
  CHARGE_APPLICABLE_TO_DIST_ID  ap_invoice_distributions_all.invoice_distribution_id%TYPE,
  RELATED_ID		  ap_invoice_distributions_all.invoice_distribution_id%TYPE,
  PARENT_CHRG_APPL_TO_DIST_ID ap_invoice_distributions_all.invoice_distribution_id%TYPE,
  PARENT_RELATED_ID	  ap_invoice_distributions_all.invoice_distribution_id%TYPE,
  INVOICE_DISTRIBUTION_ID ap_invoice_distributions_all.invoice_distribution_id%TYPE);

--================================================================================
--  This is the GLOBAL PL/SQL table type to be declared in the Package Spec
--================================================================================

TYPE Prepay_Dist_Tab_Type IS TABLE OF Prepay_Dist_Record
  INDEX BY BINARY_INTEGER;

--================================================================================
--  PL/SQL table will have the prepayment invoice_id, line number and apply amount
--  information. This will be used by the application logic to apply the prepayment.
--================================================================================

TYPE Prepay_Appl_Rec IS RECORD (
          PREPAY_INVOICE_ID ap_invoices_all.invoice_id%TYPE,
          PREPAY_LINE_NUM ap_invoice_lines_all.line_number%TYPE,
          PREPAY_APPLY_AMOUNT ap_invoice_lines_all.amount%TYPE);

TYPE Prepay_Appl_Tab IS TABLE of Prepay_Appl_Rec INDEX BY BINARY_INTEGER;

TYPE Prepay_Appl_Log_Rec IS RECORD (
          PREPAY_INVOICE_ID     AP_INVOICES_ALL.INVOICE_ID%TYPE,
          PREPAY_LINE_NUM       AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE,
          PREPAY_APPLY_AMOUNT   AP_INVOICE_LINES_ALL.AMOUNT%TYPE,
          SUCCESS               VARCHAR2(1),
          ERROR_MESSAGE         VARCHAR2(2000));

TYPE Prepay_Appl_Log_Tab IS TABLE OF Prepay_Appl_Log_Rec INDEX BY BINARY_INTEGER;


FUNCTION Check_Supplier_Consistency (
          p_prepay_num   IN VARCHAR2,
          p_vendor_id    IN NUMBER) RETURN VARCHAR2;

FUNCTION Check_Currency_Consistency (
          p_prepay_num                    IN VARCHAR2,
          p_vendor_id                     IN NUMBER,
          p_base_currency_code            IN VARCHAR2,
          p_invoice_currency_code         IN VARCHAR2,
          p_payment_currency_code         IN VARCHAR2) RETURN VARCHAR2 ;


FUNCTION Check_Prepayment_Invoice (
          p_prepay_num           IN VARCHAR2,
          p_vendor_id            IN VARCHAR2,
          p_prepay_invoice_id    OUT NOCOPY NUMBER) RETURN VARCHAR2 ;


FUNCTION Check_Prepayment_Line (
          p_prepay_num       IN VARCHAR2,
          p_prepay_line_num  IN NUMBER,
          p_vendor_id        IN NUMBER) RETURN VARCHAR2 ;

FUNCTION Check_Nothing_To_Apply_Line (
          p_prepay_invoice_id   IN NUMBER,
          p_prepay_line_num     IN NUMBER) RETURN VARCHAR2 ;


FUNCTION Check_Nothing_To_Apply_Invoice (
          p_prepay_invoice_id   IN NUMBER) RETURN VARCHAR2 ;


FUNCTION Check_Nothing_To_Apply_Vendor (
          p_vendor_id    IN NUMBER) RETURN VARCHAR2 ;


FUNCTION Check_Period_Status (
          p_prepay_gl_date       IN OUT NOCOPY DATE,
          p_prepay_period_name   IN OUT NOCOPY VARCHAR2) RETURN VARCHAR2 ;

FUNCTION Validate_Prepay_Info (
          p_prepay_case_name        IN         VARCHAR2,
          p_prepay_num              IN         OUT NOCOPY VARCHAR2,
          p_prepay_line_num         IN         OUT NOCOPY NUMBER,
          p_prepay_apply_amount     IN         OUT NOCOPY NUMBER, -- Bug 7004765
          p_invoice_amount          IN         NUMBER,
          p_prepay_gl_date          IN         OUT NOCOPY DATE,
          p_prepay_period_name      IN         OUT NOCOPY VARCHAR2,
          p_vendor_id               IN         NUMBER,
          p_import_invoice_id       IN         NUMBER,
          p_source                  IN         VARCHAR2,
          p_apply_advances_flag     IN         VARCHAR2,
          p_invoice_date            IN         DATE,
          p_base_currency_code      IN         VARCHAR2,
          p_invoice_currency_code   IN         VARCHAR2,
          p_payment_currency_code   IN         VARCHAR2,
          p_calling_sequence        IN         VARCHAR2,
          p_prepay_invoice_id       OUT NOCOPY NUMBER,
	  p_invoice_type_lookup_code IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 ; -- Bug 7004765

FUNCTION Get_Prepay_Case_Name (
          p_prepay_num              IN VARCHAR2,
          p_prepay_line_num         IN NUMBER,
          p_prepay_apply_amount     IN NUMBER,
          p_source                  IN VARCHAR2,
          p_apply_advances_flag     IN VARCHAR2,
          p_calling_sequence        IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_prepay_apply_amount(
          p_prepay_case_name        IN VARCHAR2,
          p_prepay_invoice_id       IN NUMBER,
          P_prepay_line_num         IN NUMBER,
          p_prepay_apply_amount     IN NUMBER,
          p_invoice_id              IN NUMBER,
          p_vendor_id               IN NUMBER,
          p_prepay_included         IN VARCHAR2) RETURN NUMBER;

PROCEDURE Select_Lines_For_Application (
          p_prepay_case_name        IN VARCHAR2,
          p_prepay_invoice_id       IN NUMBER,
          p_prepay_line_num         IN NUMBER,
          p_apply_amount            IN NUMBER,
          p_vendor_id               IN NUMBER,
          p_calling_sequence        IN VARCHAR2,
          p_request_id              IN NUMBER,
          p_invoice_id              IN NUMBER, -- Bug 6394865
          p_prepay_appl_info        OUT NOCOPY ap_prepay_pkg.prepay_appl_tab);

FUNCTION Check_Prepay_Info_Import (
          p_prepay_num              IN OUT NOCOPY  VARCHAR2,
          p_prepay_line_num         IN OUT NOCOPY NUMBER,
          p_prepay_apply_amount     IN OUT NOCOPY NUMBER, -- Bug 7004765
          p_invoice_amount          IN NUMBER,
          p_prepay_gl_date          IN OUT NOCOPY DATE,
          p_prepay_period_name      IN OUT NOCOPY VARCHAR2,
          p_vendor_id               IN NUMBER,
          p_prepay_included         IN VARCHAR2,
          p_import_invoice_id       IN NUMBER,
          p_source                  IN VARCHAR2,
          p_apply_advances_flag     IN VARCHAR2,
          p_invoice_date            IN DATE,
          p_base_currency_code      IN VARCHAR2,
          p_invoice_currency_code   IN VARCHAR2,
          p_payment_currency_code   IN VARCHAR2,
          p_calling_sequence        IN VARCHAR2,
          p_request_id              IN NUMBER,
          p_prepay_case_name        OUT NOCOPY VARCHAR2,
          p_prepay_invoice_id        OUT NOCOPY NUMBER,
	  p_invoice_type_lookup_code IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2; -- Bug 7004765

PROCEDURE Get_Prepay_Info_Import (
	  p_prepay_case_name	IN	      VARCHAR2,
	  p_prepay_invoice_id   IN	      NUMBER,
          p_prepay_num          IN            VARCHAR2,
          p_prepay_line_num     IN            NUMBER,
          p_prepay_apply_amount IN            NUMBER,
	  p_prepay_included	IN	      VARCHAR2,
          p_import_invoice_id   IN	      NUMBER,
	  p_vendor_id		IN	      NUMBER,
	  p_request_id		IN	      NUMBER,
	  p_prepay_appl_info    OUT NOCOPY    ap_prepay_pkg.prepay_appl_tab,
	  p_calling_sequence	IN	      VARCHAR2);

PROCEDURE Apply_Prepay_Import (
          p_prepay_invoice_id      IN NUMBER,
	  p_prepay_num		   IN VARCHAR2,
	  p_prepay_line_num	   IN NUMBER,
	  p_prepay_apply_amount    IN NUMBER,
	  p_prepay_case_name	   IN VARCHAR2,
	  p_import_invoice_id	   IN NUMBER,
	  p_request_id             IN NUMBER,
          p_invoice_id             IN NUMBER,
          p_vendor_id              IN NUMBER,
          p_prepay_gl_date         IN DATE,
          p_prepay_period_name     IN VARCHAR2,
          p_prepay_included        IN VARCHAR2,
          p_user_id                IN NUMBER,
          p_last_update_login      IN NUMBER,
          p_calling_sequence       IN VARCHAR2,
          p_prepay_appl_log        OUT NOCOPY ap_prepay_pkg.Prepay_Appl_Log_Tab);


FUNCTION Apply_Prepay_Line (
          P_PREPAY_INVOICE_ID IN         NUMBER,
          P_PREPAY_LINE_NUM   IN         NUMBER,
          P_PREPAY_DIST_INFO  IN OUT NOCOPY AP_PREPAY_PKG.PREPAY_DIST_TAB_TYPE,
          P_PRORATE_FLAG      IN         VARCHAR2,
          P_INVOICE_ID        IN         NUMBER,
	  P_INVOICE_LINE_NUMBER IN 	 NUMBER DEFAULT NULL,
          P_APPLY_AMOUNT      IN         NUMBER,
          P_GL_DATE           IN         DATE,
          P_PERIOD_NAME       IN         VARCHAR2,
          P_PREPAY_INCLUDED   IN         VARCHAR2,
          P_USER_ID           IN         NUMBER,
          P_LAST_UPDATE_LOGIN IN         NUMBER,
          P_CALLING_SEQUENCE  IN         VARCHAR2,
	  P_CALLING_MODE      IN         VARCHAR2 DEFAULT 'PREPAYMENT APPLICATION',
          P_ERROR_MESSAGE     OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


FUNCTION Insert_Prepay_Line(
          p_prepay_invoice_id         IN      NUMBER,
          p_prepay_line_num           IN      NUMBER,
          p_invoice_id                IN      NUMBER,
          p_prepay_line_number        IN      NUMBER,
          p_amount_to_apply           IN      NUMBER,
          p_base_amount_to_apply      IN      NUMBER,
          p_gl_date                   IN      DATE,
          p_period_name               IN      VARCHAR2,
          p_prepay_included           IN      VARCHAR2,
          p_quantity_invoiced         IN      NUMBER,
          p_stat_amount               IN      NUMBER,
          p_pa_quantity               IN      NUMBER,
          p_user_id                   IN      NUMBER,
          p_last_update_login         IN      NUMBER,
          p_calling_sequence          IN      VARCHAR2,
          p_error_message             OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


FUNCTION Insert_Prepay_Dists(
          P_prepay_invoice_id         IN      NUMBER,
          P_prepay_line_num           IN      NUMBER,
          P_invoice_id                IN      NUMBER,
          P_batch_id                  IN      NUMBER,
          P_line_number               IN      NUMBER,
          P_prepay_dist_info          IN OUT NOCOPY AP_PREPAY_PKG.Prepay_Dist_Tab_Type,
          P_user_id                   IN      NUMBER,
          P_last_update_login         IN      NUMBER,
          P_calling_sequence          IN      VARCHAR2,
          P_error_message             OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


FUNCTION Update_Prepayment(
          P_prepay_dist_info    IN      AP_PREPAY_PKG.Prepay_Dist_Tab_Type,
          P_prepay_invoice_id   IN      NUMBER,
          P_prepay_line_num     IN      NUMBER,
          P_invoice_id          IN      NUMBER,
          P_invoice_line_num    IN      NUMBER,
          P_appl_type           IN      VARCHAR2,
	  P_calling_mode        IN      VARCHAR2  DEFAULT 'PREPAYMENT APPLICATION',
          P_calling_sequence    IN      VARCHAR2,
          P_error_message       OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


FUNCTION Update_PO_Receipt_Info(
          P_prepay_dist_info          IN      AP_PREPAY_PKG.Prepay_Dist_Tab_Type,
          p_prepay_invoice_id         IN      NUMBER,
          p_prepay_line_num           IN      NUMBER,
          P_invoice_id                IN      NUMBER,
          P_invoice_line_num          IN      NUMBER,
          P_po_line_location_id       IN      NUMBER,
          P_matched_UOM_lookup_code   IN      VARCHAR2,
          P_appl_type                 IN      VARCHAR2,
          P_match_basis               IN      VARCHAR2,
          P_calling_sequence          IN      VARCHAR2,
          P_error_message             OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

-- Bug 4935951
-- Added a new paremeter p_calling_mode so that the updates to ap_invoices
-- will be skipped when invoked in the context of Recoupment. These updates
-- will be handled in the invoice workbench after the control returns from
-- the matching form.

FUNCTION Update_Payment_Schedule(
          P_invoice_id                IN      NUMBER,
          P_prepay_invoice_id         IN      NUMBER,
          P_prepay_line_num           IN      NUMBER,
          P_apply_amount              IN      NUMBER,
          P_appl_type                 IN      VARCHAR2,
          P_payment_currency_code     IN      VARCHAR2,
          P_user_id                   IN      NUMBER,
          P_last_update_login         IN      NUMBER,
          P_calling_sequence          IN      VARCHAR2,
	  P_calling_mode	      IN      VARCHAR2 DEFAULT NULL,
          P_error_message             OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

-- Bug 5056104 -- remove obsolete function Update_Rounding_Amounts
--FUNCTION Update_Rounding_Amounts (
--          P_prepay_invoice_id         IN      NUMBER,
--         P_prepay_line_num           IN      NUMBER,
--          P_invoice_id                IN      NUMBER,
--          P_line_number               IN      NUMBER,
--          P_final_application         IN      VARCHAR2,
--	  P_Calling_Sequence	      IN      VARCHAR2 DEFAULT NULL,
--          P_error_message             OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


FUNCTION Unapply_Prepay_Line (
          P_PREPAY_INVOICE_ID         IN      NUMBER,
          P_PREPAY_LINE_NUM           IN      NUMBER,
          P_INVOICE_ID                IN      NUMBER,
          P_LINE_NUM                  IN      NUMBER,
          P_UNAPPLY_AMOUNT            IN      NUMBER,
          P_GL_DATE                   IN      DATE,
          P_PERIOD_NAME               IN      VARCHAR2,
          P_PREPAY_INCLUDED           IN      VARCHAR2,
          P_USER_ID                   IN      NUMBER,
          P_LAST_UPDATE_LOGIN         IN      NUMBER,
          P_CALLING_SEQUENCE          IN      VARCHAR2,
          P_ERROR_MESSAGE             OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


FUNCTION Apply_Prepay_FR_Prepay(
          p_invoice_id                IN      NUMBER,
          p_prepay_num                IN      VARCHAR2,
          p_vendor_id                 IN      NUMBER,
          p_prepay_apply_amount       IN      NUMBER,
          p_prepay_gl_date            IN      DATE,
          p_prepay_period_name        IN      VARCHAR2,
          p_user_id                   IN      NUMBER,
          p_last_update_login         IN      NUMBER,
          p_calling_sequence          IN      VARCHAR2,
          p_error_message             OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


END AP_PREPAY_PKG;

/
