--------------------------------------------------------
--  DDL for Package AP_IMPORT_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_IMPORT_VALIDATION_PKG" AUTHID CURRENT_USER AS
/* $Header: apiimvts.pls 120.29.12010000.6 2009/07/16 11:25:08 dcshanmu ship $ */

TYPE r_dset_line_info IS RECORD
  (
   dist_code_combination_id
                   AP_DISTRIBUTION_SET_LINES.dist_code_combination_id%TYPE
  ,percent_distribution AP_DISTRIBUTION_SET_LINES.percent_distribution%TYPE
  ,type_1099            AP_DISTRIBUTION_SET_LINES.type_1099%TYPE
  ,description          AP_DISTRIBUTION_SET_LINES.description%TYPE
  ,distribution_set_line_number
                   AP_DISTRIBUTION_SET_LINES.distribution_set_line_number%TYPE
  ,attribute_category   AP_DISTRIBUTION_SET_LINES.attribute_category%TYPE
  ,attribute1           AP_DISTRIBUTION_SET_LINES.attribute1%TYPE
  ,attribute2           AP_DISTRIBUTION_SET_LINES.attribute2%TYPE
  ,attribute3           AP_DISTRIBUTION_SET_LINES.attribute3%TYPE
  ,attribute4           AP_DISTRIBUTION_SET_LINES.attribute4%TYPE
  ,attribute5           AP_DISTRIBUTION_SET_LINES.attribute5%TYPE
  ,attribute6           AP_DISTRIBUTION_SET_LINES.attribute6%TYPE
  ,attribute7           AP_DISTRIBUTION_SET_LINES.attribute7%TYPE
  ,attribute8           AP_DISTRIBUTION_SET_LINES.attribute8%TYPE
  ,attribute9           AP_DISTRIBUTION_SET_LINES.attribute9%TYPE
  ,attribute10          AP_DISTRIBUTION_SET_LINES.attribute10%TYPE
  ,attribute11          AP_DISTRIBUTION_SET_LINES.attribute11%TYPE
  ,attribute12          AP_DISTRIBUTION_SET_LINES.attribute12%TYPE
  ,attribute13          AP_DISTRIBUTION_SET_LINES.attribute13%TYPE
  ,attribute14          AP_DISTRIBUTION_SET_LINES.attribute14%TYPE
  ,attribute15          AP_DISTRIBUTION_SET_LINES.attribute15%TYPE
  ,project_source       VARCHAR2(30)
  ,project_accounting_context
                    AP_DISTRIBUTION_SET_LINES.project_accounting_context%TYPE
  ,project_id           AP_DISTRIBUTION_SET_LINES.project_id%TYPE
  ,task_id              AP_DISTRIBUTION_SET_LINES.task_id%TYPE
  ,expenditure_organization_id
                    AP_DISTRIBUTION_SET_LINES.expenditure_organization_id%TYPE
  ,expenditure_type     AP_DISTRIBUTION_SET_LINES.expenditure_type%TYPE
  ,pa_quantity          AP_INVOICE_DISTRIBUTIONS.pa_quantity%TYPE
  ,pa_addition_flag     AP_INVOICE_DISTRIBUTIONS.pa_addition_flag%TYPE
  ,org_id               AP_DISTRIBUTION_SET_LINES.org_id%TYPE
  ,award_id             AP_DISTRIBUTION_SET_LINES.award_id%TYPE
  ,amount               AP_INVOICE_DISTRIBUTIONS.amount%TYPE
  ,base_amount          AP_INVOICE_DISTRIBUTIONS.base_amount%TYPE);

  TYPE dset_line_tab_type IS TABLE OF r_dset_line_info
              INDEX BY BINARY_INTEGER;

  /*========================================================================*/
  /*                                                                        */
  /* Function V_CHECK_INVOICE_VALIDATION performs the following             */
  /* invoice level validations:                                             */
  /* 1. Invalid PO                                                          */
  /* 2. Invalid Supplier (only if no PO)                                    */
  /* 3. Invalid Supplier Site (only if no PO)                               */
  /* 4. Invalid Invoice Num                                                 */
  /* 5. Invalid Invoice Type and Amount                                     */
  /* 6. Invalid AWT Group                                                   */
  /* 7. Invalid pay AWT Group                                               */
  /* 7. Invalid Exchange Rate Type                                          */
  /* 8. Invalid Invoice Currency Code                                       */
  /* 9. Invalid Terms Info                                                  */
  /* 10. Check Misc Info (Liablilty, Pay Method, Pay Group.                 */
  /* 11. Invalid Payment Currency info                                      */
  /* 12. Invalid GDFF info                                                  */
  /* IN OUT invoice record is updated with data as the data is validated.   */
  /* Fatal error flag is set if there is no valid supplier or supplier site.*/
  /*                                                                        */
  /*========================================================================*/
  FUNCTION v_check_invoice_validation(
    p_invoice_rec      IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_match_mode                     OUT NOCOPY VARCHAR2,
    p_min_acct_unit_inv_curr         OUT NOCOPY NUMBER,
    p_precision_inv_curr             OUT NOCOPY NUMBER,
    p_positive_price_tolerance       OUT NOCOPY      NUMBER,
    p_negative_price_tolerance       OUT NOCOPY      NUMBER,
    p_qty_tolerance                  OUT NOCOPY      NUMBER,
    p_qty_rec_tolerance              OUT NOCOPY      NUMBER,
    p_max_qty_ord_tolerance          OUT NOCOPY      NUMBER,
    p_max_qty_rec_tolerance          OUT NOCOPY      NUMBER,
    p_amt_tolerance		     OUT NOCOPY	     NUMBER,
    p_amt_rec_tolerance		     OUT NOCOPY	     NUMBER,
    p_max_amt_ord_tolerance          OUT NOCOPY      NUMBER,
    p_max_amt_rec_tolerance          OUT NOCOPY      NUMBER,
    p_goods_ship_amt_tolerance       OUT NOCOPY      NUMBER,
    p_goods_rate_amt_tolerance       OUT NOCOPY      NUMBER,
    p_goods_total_amt_tolerance      OUT NOCOPY      NUMBER,
    p_services_ship_amt_tolerance    OUT NOCOPY      NUMBER,
    p_services_rate_amt_tolerance    OUT NOCOPY      NUMBER,
    p_services_total_amt_tolerance   OUT NOCOPY      NUMBER,
    p_base_currency_code             IN         VARCHAR2,
    p_multi_currency_flag            IN         VARCHAR2,
    p_set_of_books_id                IN         NUMBER,
    p_default_exchange_rate_type     IN         VARCHAR2,
    p_make_rate_mandatory_flag       IN         VARCHAR2,
    p_default_last_updated_by        IN         NUMBER,
    p_default_last_update_login      IN         NUMBER,
    p_fatal_error_flag               OUT NOCOPY VARCHAR2,
    p_current_invoice_status         IN OUT NOCOPY VARCHAR2,
    p_calc_user_xrate                IN         VARCHAR2,
    p_prepay_period_name          IN OUT NOCOPY VARCHAR2,
    p_prepay_invoice_id		     OUT NOCOPY NUMBER,	 --Contract Payments
    p_prepay_case_name		     OUT NOCOPY VARCHAR2, --Contract Payments
    p_request_id                  IN            NUMBER,
    p_allow_interest_invoices	     IN		VARCHAR2,  --bug4113223
    p_calling_sequence               IN         VARCHAR2)   RETURN BOOLEAN;

  /*========================================================================*/
  /*                                                                        */
  /* Function V_CHECK_INVALID_PO performs the following validations related */
  /* to PO information and rejects if appropriate:                          */
  /* 1. PO is closed                                                        */
  /* 2. PO number is invalid                                                */
  /* 3. PO vendor information is inconsistent                               */
  /*                                                                        */
  /*========================================================================*/
  FUNCTION v_check_invalid_po (
    p_invoice_rec                IN   AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_default_last_updated_by    IN            NUMBER,
    p_default_last_update_login  IN            NUMBER,
    p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
    p_po_vendor_id                  OUT NOCOPY NUMBER,
    p_po_vendor_site_id             OUT NOCOPY NUMBER,
    p_po_exists_flag                OUT NOCOPY VARCHAR2,
    p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN;

  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_INVALID_SUPPLIER performs the following validations    */
  /* to supplier information and rejects if appropriate:                     */
  /* 1. No Supplier provided                                                 */
  /* 2. Inconsistent Supplier information provided between ID, Supplier Num  */
  /*    and/or Supplier Name                                                 */
  /* 3. Invalid Supplier provided                                            */
  /*                                                                         */
  /*=========================================================================*/
  FUNCTION v_check_invalid_supplier (
    p_invoice_rec                 IN   AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_default_last_updated_by     IN            NUMBER,
    p_default_last_update_login   IN            NUMBER,
    p_return_vendor_id               OUT NOCOPY NUMBER,
    p_current_invoice_status      IN OUT NOCOPY VARCHAR2,
    p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;


  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_INVALID_SUPPLIER_SITE performs the following           */
  /* validations to supplier site information and rejects if appropriate:    */
  /* 1. No Supplier Site provided                                            */
  /* 2. Inconsistent Supplier Site information provided between ID, and Site */
  /*    Code and/or Supplier                                                 */
  /* 3. Supplier Site is not a pay site                                      */
  /* 4. Supplier Site is invalid                                             */
  /*                                                                         */
  /*=========================================================================*/
  FUNCTION v_check_invalid_supplier_site (
    p_invoice_rec                IN
    AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_vendor_site_id_per_po      IN               NUMBER,
    p_default_last_updated_by    IN               NUMBER,
    p_default_last_update_login  IN               NUMBER,
    p_return_vendor_site_id         OUT NOCOPY    NUMBER,
    p_terms_date_basis              OUT NOCOPY    VARCHAR2,
    p_current_invoice_status     IN OUT NOCOPY    VARCHAR2,
    p_calling_sequence           IN               VARCHAR2) RETURN BOOLEAN;


  /*=========================================================================*/
  /* Added for Payment Requests project                                      */
  /* Function V_CHECK_INVALID_PARTY performs the following validations       */
  /* to party information for payment request invoices and rejects if        */
  /* appropriate:                                                            */
  /* 1. No party provided                                                    */
  /* 2. Invalid Party provided                                               */
  /*                                                                         */
  /*=========================================================================*/
FUNCTION v_check_invalid_party(
         p_invoice_rec   IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_default_last_updated_by     IN            NUMBER,
         p_default_last_update_login   IN            NUMBER,
         p_current_invoice_status      IN OUT NOCOPY VARCHAR2,
         p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;


  /*=========================================================================*/
  /* Added for Payment Requests project                                      */
  /* Function V_CHECK_INVALID_PARTY_SITE performs the following              */
  /* validations to party site information for payment request type of       */
  /* invoices and rejects if appropriate:                                    */
  /* 1. No Party Site provided                                            */
  /* 4. Party Site is invalid                                             */
  /*                                                                         */
  /*=========================================================================*/
FUNCTION v_check_invalid_party_site (
         p_invoice_rec  IN  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_default_last_updated_by    IN            NUMBER,
         p_default_last_update_login  IN            NUMBER,
         p_return_party_site_id       OUT NOCOPY    NUMBER,
         p_terms_date_basis           OUT NOCOPY    VARCHAR2,
         p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
         p_calling_sequence           IN VARCHAR2) RETURN BOOLEAN;


  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_INVALID_INVOICE_NUM performs the following             */
  /* validations to the invoice number and rejects if appropriate:           */
  /* 1. NULL Invoice Number                                                  */
  /* 2. Duplicate Invoice Number either in permanent transaction system or   */
  /*    the interface.                                                       */
  /*                                                                         */
  /*=========================================================================*/
    FUNCTION v_check_invalid_invoice_num (
      p_invoice_rec             IN   AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
      p_allow_interest_invoices    IN VARCHAR2, --Bug4113223
      p_invoice_num                   OUT NOCOPY VARCHAR2,
      p_default_last_updated_by    IN            NUMBER,
      p_default_last_update_login  IN            NUMBER,
      p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
      p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN;


  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_INVALID_INV_CURR_CODE performs the following           */
  /* validations to the invoice and rejects if appropriate:                  */
  /* 1. Invoice Currency Code is Inactive                                    */
  /* 2. Invoice Currency Code is Invalid                                     */
  /* Function gets currency code from Supplier Site if NULL.  It also reads  */
  /* minimum accountable unit and precision for the currency.                */
  /*                                                                         */
  /*=========================================================================*/
  FUNCTION v_check_invalid_inv_curr_code (
    p_invoice_rec             IN     AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_inv_currency_code            OUT NOCOPY VARCHAR2,
    p_min_acc_unit_inv_curr        OUT NOCOPY NUMBER,
    p_precision_inv_curr           OUT NOCOPY NUMBER,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER,
    p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;

  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_INVOICE_TYPE_AMOUNT performs the following             */
  /* validations to the invoice and rejects if appropriate:                  */
  /* 1. Invoice type other than STANDARD OR CREDIT                           */
  /* 2. Invoice amount is null                                               */
  /* 3. Invoice type is STANDARD but amount is <0                            */
  /* 4. Invoice type is CREDI but amount >=0                                 */
  /* 5. Invoice amount is <> sum of lines amount and source is EDI GATEWAY   */
  /* 6. Number of invoice lines is 0                                         */
  /* 7. Invoice amount exceeds invoice currency precision                    */
  /* If invoice type is null and amount <0, set type to CREDIT.              */
  /* If invoice type is null and amount >=0, set type to STANDARD            */
  /* If invoice type is STANDARD set match mode to MI                        */
  /* If invoice type is CREDIT set match mode to MC                          */
  /*                                                                         */
  /*=========================================================================*/
  FUNCTION v_check_invoice_type_amount (
    p_invoice_rec               IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_invoice_type_lookup_code     OUT NOCOPY VARCHAR2,
    p_match_mode                   OUT NOCOPY VARCHAR2,
    p_precision_inv_curr        IN            NUMBER,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER,
    p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;

  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_INVALID_AWT_GROUP performs the following               */
  /* validations to awt group data and rejects if appropriate:               */
  /* 1. AWT Group Id and AWT Group Name are inconsistent                     */
  /* 2. AWT Group is Invalid                                                 */
  /* 3. AWT Group is Inactive                                                */
  /* Returns the awt_group_id if any read from either the awt_group_id in    */
  /* the record or the awt_group_id from the awt_group_name if awt_group_id  */
  /* in the record was null.                                                 */
  /*                                                                         */
  /*=========================================================================*/
  FUNCTION v_check_invalid_awt_group (
    p_invoice_rec               IN  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_awt_group_id                 OUT NOCOPY NUMBER,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER,
    p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;
  --bug6639866
  /*=================================================================================*/
  /*                                                                                 */
  /* Function V_CHECK_INVALID_PAY_AWT_GROUP performs the following                   */
  /* validations to awt group data and rejects if appropriate:                       */
  /* 1. Pay AWT Group Id and Pay AWT Group Name are inconsistent                     */
  /* 2. Pay AWT Group is Invalid                                                     */
  /* 3. Pay AWT Group is Inactive                                                    */
  /* Returns the pay_awt_group_id if any read from either the pay_awt_group_id in    */
  /* the record or the pay_awt_group_id from the awt_group_name if pay_awt_group_id  */
  /* in the record was null.                                                         */
  /*                                                                                 */
  /*=================================================================================*/
  FUNCTION v_check_invalid_pay_awt_group (
    p_invoice_rec               IN  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_pay_awt_group_id             OUT NOCOPY NUMBER,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER,
    p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;


  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_EXCHANGE_RATE_TYPE performs the following              */
  /* validations to exchange rate information and rejects if needed:         */
  /* 1. Conversion Type does not exist in gl_daily_conversion_types and      */
  /*    rate is required.                                                    */
  /* 2. Conversion Type is other than User and an Exchange Rate is provided. */
  /* Returns the exchange rate and exchange date.                            */
  /*                                                                         */
  /*=========================================================================*/
  FUNCTION v_check_exchange_rate_type (
    p_invoice_rec                IN    AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_exchange_rate                 OUT NOCOPY NUMBER,
    p_exchange_date                 OUT NOCOPY DATE,
    p_base_currency_code         IN            VARCHAR2,
    p_multi_currency_flag        IN            VARCHAR2,
    p_set_of_books_id            IN            NUMBER,
    p_default_exchange_rate_type IN            VARCHAR2,
    p_make_rate_mandatory_flag   IN            VARCHAR2,
    p_default_last_updated_by    IN            NUMBER,
    p_default_last_update_login  IN            NUMBER,
    p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
    p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN;

  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_INVALID_TERMS performs the following validations       */
  /* relative to Payment terms and rejects if necessary:                     */
  /* 1. Inconsistent Terms Name and Terms ID                                 */
  /* 2. Invalid Terms                                                        */
  /* 3. Inactive Terms                                                       */
  /* 4. Terms Date Basis is Invoice received date but invoice received date  */
  /*    is null.                                                             */
  /* 5. Terms Date Basis is Goods received date but goods received date is   */
  /*    null.                                                                */
  /* If neither terms name nor terms id are provided in the invoice, then    */
  /* obtain based on PO Information either at header or line level or        */
  /* from supplier site.                                                     */
  /*                                                                         */
  /*=========================================================================*/
    FUNCTION v_check_invalid_terms (
      p_invoice_rec               IN
                    AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
      p_terms_id                     OUT NOCOPY NUMBER,
      p_terms_date                   OUT NOCOPY DATE,
      p_terms_date_basis          IN            VARCHAR2,
      p_default_last_updated_by   IN            NUMBER,
      p_default_last_update_login IN            NUMBER,
      p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
      p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;

  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_MISC_INVOICE_INFO performs the following validations   */
  /* relative to the invoice and rejects if necessary:                       */
  /* 1. Is Liability Account Valid?                                          */
  /* 2. Is Payment Method Valid?                                             */
  /* 3. Is Pay Group Valid?                                                  */
  /* 4. Is Voucher Num a duplicate Num?                                      */
  /* 5. Is Requester a valid employee?                                       */
  /*                                                                         */
  /*=========================================================================*/
  FUNCTION v_check_misc_invoice_info (
    p_invoice_rec            IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    -- Bug 6509776
    p_set_of_books_id           IN            NUMBER,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER,
    p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;

  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_LEGAL_ENTITY_INFO performs the following validations   */
  /* relative to the invoice and rejects if necessary:                       */
  /* 1. Is LegalEntity ID Valid?                                             */
  /* 2. REG Code and Number Derive Valid LE                                  */
  /*                                                                         */
  /*=========================================================================*/
  FUNCTION v_check_legal_entity_info (
    p_invoice_rec               IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_set_of_books_id           IN            NUMBER,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER,
    p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;

  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_INVALID_PAY_CURR performs the following validations    */
  /* relative to the payment currency and rejects if necessary:              */
  /* 1. Is Payment Currency inactive?                                        */
  /* 2. Is Payment Currency Valid?                                           */
  /* 3. Is Invoice to Payment Currency fixed rate?                           */
  /* Set payment currency to invoice currency if payment currency is null    */
  /* Set payment cross rate date to invoice date if payment cross rate date  */
  /* is null.                                                                */
  /*                                                                         */
  /*=========================================================================*/
  FUNCTION v_check_invalid_pay_curr (
         p_invoice_rec               IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_pay_currency_code            OUT NOCOPY VARCHAR2,
         p_payment_cross_rate_date      OUT NOCOPY DATE,
         p_payment_cross_rate           OUT NOCOPY NUMBER,
         p_payment_cross_rate_type      OUT NOCOPY VARCHAR2,
         p_default_last_updated_by   IN            NUMBER,
         p_default_last_update_login IN            NUMBER,
         p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
         p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;
  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_PREPAY_INFO is intended to verify prepayment           */
  /* application information but will remain a placeholder during Uptake     */
  /* Stage I of Lines.                                                       */
  /*                                                                         */
  /*=========================================================================*/

  FUNCTION v_check_prepay_info(
    p_invoice_rec               IN OUT NOCOPY
                                AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_base_currency_code        IN            VARCHAR2,
    p_prepay_period_name        IN OUT NOCOPY VARCHAR2,
    p_prepay_invoice_id		OUT    NOCOPY NUMBER,	--Contract Payments
    p_prepay_case_name		OUT    NOCOPY VARCHAR2, --Contract Payments
    p_request_id                IN            NUMBER,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER,
    p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;

  /*=========================================================================*/
  /*                                                                         */
  /* Function V_CHECK_NO_XRATE_BASE_AMOUNT performs the following validations*/
  /* relative to the rate information vs. base amount information provided   */
  /* in the invoice.  It rejects if needed:                                  */
  /* 1. Is Calculation of rate based on base amount allowed?  If not, is the */
  /*    base amount provided?                                                */
  /* 2. Is Calculation of rate based on base amount allowed and the base     */
  /*    amount and rate (including rate type)information if any consistent?  */
  /* 3. Derives base amount if possible.
  /*                                                                         */
  /*=========================================================================*/
  FUNCTION v_check_no_xrate_base_amount (
    p_invoice_rec               IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_base_currency_code        IN            VARCHAR2,
    p_multi_currency_flag       IN            VARCHAR2,
    p_calc_user_xrate           IN            VARCHAR2,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER,
    p_invoice_base_amount          OUT NOCOPY NUMBER,
    p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;

/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_LINES_VALIDATION reads interface lines into a plsql    */
/* table and performs the following validations relative to each line:     */
/* 1. Is org_id populated on the line?  If so, is it consistent with the   */
/*    invoice org_id?                                                      */
/* 2. Read employee id from vendor.                                        */
/* 3. Validate line amount not to exceed invoice currency precision.       */
/* 4. For ITEM type lines, validate PO information.                        */
/*                                                                         */
/*=========================================================================*/
  FUNCTION v_check_lines_validation (
    -- bug 8495005 fix : changed as IN OUT NOCOPY
    p_invoice_rec       IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_invoice_lines_tab IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.t_lines_table,  --Retropricing
    p_gl_date_from_get_info        IN            DATE,
    p_gl_date_from_receipt_flag    IN            VARCHAR2,
    p_positive_price_tolerance     IN            NUMBER,
    p_pa_installed                 IN            VARCHAR2,
    p_qty_ord_tolerance            IN            NUMBER,
    p_amt_ord_tolerance		   IN		 NUMBER,
    p_max_qty_ord_tolerance        IN            NUMBER,
    p_max_amt_ord_tolerance        IN            NUMBER,
    p_min_acct_unit_inv_curr       IN            NUMBER,
    p_precision_inv_curr           IN            NUMBER,
    p_base_currency_code           IN            VARCHAR2,
    p_base_min_acct_unit           IN            NUMBER,
    p_base_precision               IN            NUMBER,
    p_set_of_books_id              IN            NUMBER,
    p_asset_book_type              IN            VARCHAR2,  -- Bug 5448579
    p_chart_of_accounts_id         IN            NUMBER,
    p_freight_code_combination_id  IN            NUMBER,
    p_purch_encumbrance_flag       IN            VARCHAR2,
    p_retainage_ccid		   IN		 NUMBER,
    p_default_last_updated_by      IN            NUMBER,
    p_default_last_update_login    IN            NUMBER,
    p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
    p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;



  /*=======================================================================*/
  /*                                                                       */
  /* Function V_CHECK_INVOICE_LINES_AMOUNT performs the following          */
  /* validation for the line amount.  It rejects if necessary.             */
  /* 1. Does the line amount exceed the invoice currency precision?        */
  /*                                                                       */
  /*=======================================================================*/
  FUNCTION v_check_invoice_line_amount (
    p_invoice_lines_rec      IN AP_IMPORT_INVOICES_PKG.r_line_info_rec,
    p_precision_inv_curr           IN            NUMBER,
    p_default_last_updated_by      IN            NUMBER,
    p_default_last_update_login    IN            NUMBER,
    p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
    p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;


  /*=======================================================================*/
  /*                                                                       */
  /* Function V_CHECK_LINE_PO_INFO performs validation on all PO data for  */
  /* validity and consistency.  It rejects if necessary.                   */
  /*                                                                       */
  /*=======================================================================*/
  FUNCTION v_check_line_po_info (
    p_invoice_rec       IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_invoice_lines_rec IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
    p_set_of_books_id              IN            NUMBER,
    p_positive_price_tolerance     IN            NUMBER,
    p_qty_ord_tolerance            IN            NUMBER,
    p_amt_ord_tolerance		   IN		 NUMBER,
    p_max_qty_ord_tolerance        IN            NUMBER,
    p_max_amt_ord_tolerance	   IN		 NUMBER,
    p_default_last_updated_by      IN            NUMBER,
    p_default_last_update_login    IN            NUMBER,
    p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
    p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;


  /*=======================================================================*/
  /*                                                                       */
  /* Function V_CHECK_LINE_PO_INFO2 performs validation on PO data as      */
  /* follows.  Rejects if necessary.                                       */
  /* 1.Unit Price Variance for both Shipment/Line level matching           */
  /*   (uses tolerances)                                                   */
  /* 2.Quantity Variance for both Shipment/Line level matching             */
  /*   (uses tolerances)                                                   */
  /* 3.Unit of Measure consistency                                         */
  /* 4.Line Price Break for allowing Line level match                      */
  /* 5.Invalid Shipment Type for unapproved PO's                           */
  /* 6.Shipment is not Finally Closed                                      */
  /*                                                                       */
  /*=======================================================================*/

  FUNCTION v_check_line_po_info2 (
    p_invoice_rec         IN  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_invoice_lines_rec   IN  AP_IMPORT_INVOICES_PKG.r_line_info_rec,
    p_positive_price_tolerance     IN             NUMBER,
    p_qty_ord_tolerance            IN             NUMBER,
    p_amt_ord_tolerance		   IN		  NUMBER,
    p_max_qty_ord_tolerance        IN             NUMBER,
    p_max_amt_ord_tolerance	   IN		  NUMBER,
    p_po_header_id                 IN             NUMBER,
    p_po_line_id                   IN             NUMBER,
    p_po_line_location_id          IN             NUMBER,
    p_po_distribution_id           IN             NUMBER,
    p_match_option                    OUT NOCOPY  VARCHAR2,
    p_calc_quantity_invoiced          OUT NOCOPY  NUMBER,
    p_calc_unit_price                 OUT NOCOPY  NUMBER,
    p_calc_line_amount                OUT NOCOPY  NUMBER, /* Amount Based Matching */
    p_default_last_updated_by      IN             NUMBER,
    p_default_last_update_login    IN             NUMBER,
    p_current_invoice_status       IN OUT NOCOPY  VARCHAR2,
    p_match_basis                  IN             VARCHAR2, /* Amount Based Matching */
    p_calling_sequence             IN             VARCHAR2) RETURN BOOLEAN;

/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_PO_OVERLAY performs validation relative to overlay     */
/* information for PO matched lines.                                       */
/*                                                                         */
/*=========================================================================*/
--Contract Payments: Added the p_invoice_rec to the signature.
FUNCTION v_check_po_overlay (
   p_invoice_rec		IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec          IN AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_po_line_id                 IN            NUMBER,
   p_po_line_location_id        IN            NUMBER,
   p_po_distribution_id         IN            NUMBER,
   p_set_of_books_id            IN            NUMBER,
   p_default_last_updated_by    IN            NUMBER,
   p_default_last_update_login  IN            NUMBER,
   p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
   p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN;

/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_RECEIPT_INFO performs validation relative to receipt   */
/* information for RCV matched lines.                                      */
/*                                                                         */
/*=========================================================================*/
FUNCTION v_check_receipt_info (
   p_invoice_rec	IN	      AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec  IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by    IN            NUMBER,
   p_default_last_update_login  IN            NUMBER,
   p_temp_line_status              OUT NOCOPY VARCHAR2,
   p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN;


/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_LINE_ACCOUNTING_DATE performs validation relative to   */
/* accounting date information.                                            */
/* Populates line record with accounting date and period name if possible  */
/* and validated.                                                          */
/*                                                                         */
/*=========================================================================*/
FUNCTION v_check_line_accounting_date (
   p_invoice_rec        IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec  IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_gl_date_from_get_info        IN            DATE,
   p_gl_date_from_receipt_flag    IN            VARCHAR2,
   p_set_of_books_id              IN            NUMBER,
   p_purch_encumbrance_flag       IN            VARCHAR2,
   p_default_last_updated_by      IN            NUMBER,
   p_default_last_update_login    IN            NUMBER,
   p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
   p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;

/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_LINE_PROJECT_INFO performs validation relative to line */
/* level project information.                                              */
/*                                                                         */
/*=========================================================================*/
FUNCTION v_check_line_project_info (
   p_invoice_rec          IN     AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec    IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_accounting_date           IN            DATE,
   p_pa_installed              IN            VARCHAR2,
   p_employee_id               IN            NUMBER,
   p_base_currency_code        IN            VARCHAR2,
   p_set_of_books_id           IN            NUMBER,
   p_chart_of_accounts_id      IN            NUMBER,
   p_default_last_updated_by   IN            NUMBER,
   p_default_last_update_login IN            NUMBER,
   p_pa_built_account          OUT NOCOPY NUMBER,
   p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
   p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;


/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_LINE_ACCOUNT_INFO performs validation relative to line */
/* accounting information.                                                 */
/* If possible it builds account by overlaying and stores in line record.  */
/*                                                                         */
/*=========================================================================*/
FUNCTION v_check_line_account_info (
   p_invoice_lines_rec    IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_freight_code_combination_id  IN            NUMBER,
   p_pa_built_account             IN            NUMBER,
   p_accounting_date              IN            DATE,
   p_set_of_books_id              IN            NUMBER,
   p_chart_of_accounts_id         IN            NUMBER,
   p_default_last_updated_by      IN            NUMBER,
   p_default_last_update_login    IN            NUMBER,
   p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
   p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;



/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_DEFERRED_ACCOUNTING performs validation relative to    */
/* line level deferred accounting information.                             */
/* It validates that:                                                      */
/* 1) DEFERRED ACCTG FLAG has one of 2 possible values: Yes (Y) or No (N). */
/*    If other value provided, reject with 'INVALID DEFERRED FLAG'         */
/*    rejection reason.                                                    */
/* 2) If DEFERRED ACCT FLAG is set to N but other deferred related data    */
/*    is provided, reject with 'INVALID DEFERRED FLAG'.                    */
/* 2) DEF ACCTG START DATE is populated if DEFERRED ACCTG FLAG is set      */
/*    to Y. Must fall in the same Open Period as the GL DATE, which        */
/*    should be common to all distributions for the line. If validation    */
/*    fails, reject with 'INVALID DEF START DATE'                          */
/* 3) DEF ACCTG END DATE must be larger than DEF ACCTG START DATE.   If    */
/*    validation fails, reject with 'INVALID DEF END DATE'.                */
/* 4) DEF ACCTG NUMBER OF PERIODS must be populated if DEF ACCTG PERIOD    */
/*    TYPE is populated.  Value must be a positive integer.  If validation */
/*    fails, reject with 'INVALID DEF NUM OF PER'                          */
/* 5) DEF ACCTG PERIOD TYPE must be provided if DEF ACCTG NUMBER OF        */
/*    PERIODS is populated.  It is validated against the set of lookup     */
/*    codes with lookup type =  'XLA_DEFERRED_PERIOD_TYPE'. Mutually       */
/*    Exclusive Field: DEF ACCTG END DATE.  If validation fails, reject    */
/*    with 'INVALID DEF PER TYPE'                                          */
/* 6) A check for complete deferred accounting information will be         */
/*    performed to ensure that proper deferred accounting can be generated.*/
/*    The check will validate that the DEF ACCTG START DATE and either the */
/*    DEF ACCTG END DATE or the DEF ACCTG NUMBER OF PERIODS were provided. */
/*    If this validation fails,reject with 'INCOMPLETE DEF ACCTG INFO'.    */
/*                                                                         */
/*=========================================================================*/
FUNCTION v_check_deferred_accounting (
         p_invoice_lines_rec
           IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
         p_set_of_books_id              IN            NUMBER,
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;



/*========================================================================*/
/*                                                                        */
/* Function V_CHECK_LINE_DIST_SET performs validation relative to dist    */
/* set information.                                                       */
/*                                                                        */
/*========================================================================*/
 FUNCTION v_check_line_dist_set (
         p_invoice_rec                  IN
         AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_invoice_lines_rec            IN OUT NOCOPY
     AP_IMPORT_INVOICES_PKG.r_line_info_rec,
         p_base_currency_code           IN            VARCHAR2,
         p_employee_id                  IN            NUMBER,
         p_gl_date_from_get_info        IN            DATE,
         p_set_of_books_id              IN            NUMBER,
         p_chart_of_accounts_id         IN            NUMBER,
         p_pa_installed                 IN            VARCHAR2,
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;

 /*=========================================================================*/
 /*                                                                         */
 /* Function V_CHECK_QTY_UOM_NON_PO performs validation relative to qty and */
 /* UOM information whenever a line is not PO matched.                      */
 /* The following checks are performed:                                     */
 /* 1) If QUANTITY INVOICED AND/OR UNIT PRICE is provided but the UNIT OF   */
 /*    MEAS LOOKUP CODE is not provided reject with 'INCOMPLETE QTY INFO'   */
 /* 2) If UNIT OF MEAS LOOKUP CODE is provided, validate against active set */
 /*    of units of measure as per validation stated in the Invoice Solution */
 /*    Component.  If validation fails, reject with 'INVALID UOM'.          */
 /* 3) If QUANTITY INVOICED OR UNIT OF MEAS LOOKUP CODE is provided for non */
 /*    Item lines, reject with 'INVALID QTY INFO'.                          */
 /* 4) If QUANTITY INVOICED is 0 reject with 'INVALID QTY INFO'             */
 /* 5) If QUANTITY INVOICED * UNIT_PRICE is OTHER THAN AMOUNT then reject   */
 /*    with 'INCONSISTENT QTY RELATED INFO'                                 */
 /* If UNIT PRICE was not provided, default based on AMOUNT and QUANTITY    */
 /* INVOICED if possible.  If QUANTITY INVOICED was not provided, default   */
 /* based on AMOUNT and UNIT PRICE if possible.                             */
 /*                                                                         */
 /*=========================================================================*/
FUNCTION v_check_qty_uom_non_po (
     p_invoice_rec
       IN            AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_invoice_lines_rec
           IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;

/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_INVALID_LINE_AWT_GROUP performs validation relative to */
/* awt group information at the line level.                                */
/* If awt group data not available at the line level, default from header  */
/* Line record should be populated with awt information at the end of this */
/* function  unless an error or rejection occurs.                          */
/*                                                                         */
/*=========================================================================*/
FUNCTION v_check_invalid_line_awt_group (
   p_invoice_rec        IN          AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec  IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by    IN            NUMBER,
   p_default_last_update_login  IN            NUMBER,
   p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
   p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN;
--bug6639866
/*=============================================================================*/
/*                                                                             */
/* Function V_CHECK_INVALID_LINE_PAY_AWT_G performs validation relative to     */
/* pay awt group information at the line level.                                */
/* If pay awt group data not available at the line level, default from header  */
/* Line record should be populated with pay awt information at the end of this */
/* function  unless an error or rejection occurs.                              */
/*                                                                             */
/*=============================================================================*/
FUNCTION v_check_invalid_line_pay_awt_g (
   p_invoice_rec        IN          AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec  IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by    IN            NUMBER,
   p_default_last_update_login  IN            NUMBER,
   p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
   p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN;


/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_DUPLICATE_LINE_NUM verifies that there is no duplicate */
/* line number for the invoice in the interface.                           */
/* If null, the line number is populated after this call in the lines      */
/* validation function.                                                    */
/*                                                                         */
/*=========================================================================*/
FUNCTION v_check_duplicate_line_num (
   p_invoice_rec          IN        AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec    IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by    IN            NUMBER,
   p_default_last_update_login  IN            NUMBER,
   p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
   p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN;


/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_MISC_LINE_INFO verifies several pieces of data on the  */
/* line including type 1099, etc.                                          */
/*                                                                         */
/*=========================================================================*/

FUNCTION v_check_misc_line_info (
   p_invoice_rec          		  IN
						AP_IMPORT_INVOICES_PKG.r_invoice_info_rec, -- bug 7599916
   p_invoice_lines_rec  IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by      IN            NUMBER,
   p_default_last_update_login    IN            NUMBER,
   p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
   p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;


/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_PRORATE_INFO verifies proration information for non    */
/* item lines.                                                             */
/*                                                                         */
/*=========================================================================*/
FUNCTION v_check_prorate_info (
   p_invoice_rec                  IN
    AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec   IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by      IN            NUMBER,
   p_default_last_update_login    IN            NUMBER,
   p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
   p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN ;

/*=========================================================================*/
/*                                                                         */
/* Function V_CHECK_ASSET_INFO verifies proper population of the following */
/* pieces of asset information:                                            */
/* 1. Serial Number                                                        */
/* 2. Manufactuer                                                          */
/* 3. Model Number                                                         */
/* 4. Warranty Number                                                      */
/* If any of the above is populated for a non-item line, the same will be  */
/* rejected with an appropriate rejection.                                 */
/* It also validates asset_book_type_code and asset_category.  It populates*/
/* asset book type code if possible.                                       */
/*                                                                         */
/*=========================================================================*/
FUNCTION v_check_asset_info (
     p_invoice_lines_rec IN OUT NOCOPY
         AP_IMPORT_INVOICES_PKG.r_line_info_rec,
         p_set_of_books_id              IN            NUMBER,
         p_asset_book_type              IN            VARCHAR2, -- Bug 5448579
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - V_Check_Tax_Info()
 |
 |  DESCRIPTION
 |      This function will validate the following fields included in the
 |      ap_invoices_interface table as part of the eTax Uptake project:
 |        control_amount
 |        tax_related_invoice_id
 |        calc_tax_during_import_flag
 |        will not validate it.
 |
 |      The other tax fields will be validated by the eTax API.  See DLD for
 |      details.
 |
 |  PARAMETERS
 |    p_invoice_rec - record for invoice header
 |    p_default_last_updated_by - default last updated by
 |    p_default_last_update_login - default last update login
 |    p_current_invoice_status - return the status of the invoice after the
 |                               validation
 |    P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    20-JAN-2004   SYIDNER        Created
 |
 *============================================================================*/

FUNCTION v_check_tax_info(
     p_invoice_rec               IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
     p_default_last_updated_by   IN            NUMBER,
     p_default_last_update_login IN            NUMBER,
     p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
     p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - V_Check_Tax_Line_Info()
 |
 |  DESCRIPTION
 |      This function will validate the following fields included in the
 |      ap_invoice_lines_interface table as part of the eTax Uptake project:
 |        control_amount
 |        assessable_value
 |        incl_in_taxable_line_flag
 |        ship_to_location_id
 |
 |      The other tax fields will be validated by the eTax API.  See DLD for
 |      details.
 |
 |  PARAMETERS
 |    p_invoice_rec - record for invoice header
 |    p_default_last_updated_by - default last updated by
 |    p_default_last_update_login - default last update login
 |    p_current_invoice_status - return the status of the invoice after the
 |                               validation
 |    P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    20-JAN-2004   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION v_check_tax_line_info (
     p_invoice_lines_rec   IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
     p_default_last_updated_by      IN            NUMBER,
     p_default_last_update_login    IN            NUMBER,
     p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
     p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;



/*=============================================================================
 |  FUNCTION - V_Check_Line_Purch_Category_Info()
 |
 |  DESCRIPTION
 |      This function will validate the following fields included in the
 |      ap_invoice_lines_interface table as part of the Invoice Lines project:
 |
 |	Purchasing_Category_Id
 |	Purchasing_Category
 |
 |  PARAMETERS
 |    p_invoice_rec - record for invoice header
 |    p_default_last_updated_by - default last updated by
 |    p_default_last_update_login - default last update login
 |    p_current_invoice_status - return the status of the invoice after the
 |                               validation
 |    P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    20-JAN-2005   SMYADAM        Created
 |
 *============================================================================*/

 FUNCTION v_check_line_purch_category(
        p_invoice_lines_rec   IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
        p_default_last_updated_by      IN            NUMBER,
        p_default_last_update_login    IN            NUMBER,
        p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
        p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;



/*=============================================================================
 |  FUNCTION - V_Check_Line_Cost_Factor
 |
 |  DESCRIPTION
 |      This function will validate the following fields included in the
 |      ap_invoice_lines_interface table as part of the Invoice Lines project:
 |
 |	Cost_Factor_Id
 |	Cost_Factor_Name
 |
 |  PARAMETERS
 |    p_invoice_rec - record for invoice header
 |    p_default_last_updated_by - default last updated by
 |    p_default_last_update_login - default last update login
 |    p_current_invoice_status - return the status of the invoice after the
 |                               validation
 |    P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    07-MAR-2005   SMYADAM        Created
 |
 *============================================================================*/

 FUNCTION v_check_line_cost_factor(
        p_invoice_lines_rec   IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
        p_default_last_updated_by      IN            NUMBER,
        p_default_last_update_login    IN            NUMBER,
        p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
        p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - V_Check_Line_Retainage()
 |
 |  DESCRIPTION
 |      This function will fetch the retainage amount for a po shipment. This
 |      will be used for creating retainage distributions during invoice match.
 |      It will reject the invoice if there is no retainage account defined and
 |      the po shipment has retainage.
 |
 *============================================================================*/

  FUNCTION v_check_line_retainage(
        p_invoice_lines_rec		IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
	p_retainage_ccid		IN            NUMBER,
	p_default_last_updated_by	IN            NUMBER,
	p_default_last_update_login	IN            NUMBER,
	p_current_invoice_status	IN OUT NOCOPY VARCHAR2,
	p_calling_sequence		IN            VARCHAR2) RETURN BOOLEAN;


  FUNCTION v_check_payment_defaults(
    p_invoice_rec               IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_current_invoice_status	IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER
    ) return boolean;


  FUNCTION v_check_party_vendor(
    p_invoice_rec               IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_current_invoice_status	IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER
    ) return boolean;


  --bugfix:5565310
  -- bug 8495005 fix: changed p_invoice_rec as IN OUT NOCOPY
  FUNCTION v_check_line_get_po_tax_attr(p_invoice_rec IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
                                        p_invoice_lines_rec IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
			                p_calling_sequence IN VARCHAR2) return boolean;

  --bugfix:6989166
  FUNCTION v_check_ship_to_location_code(
		p_invoice_rec	IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
		p_invoice_line_rec  IN AP_IMPORT_INVOICES_PKG.r_line_info_rec,
                p_default_last_updated_by      IN            NUMBER,
		p_default_last_update_login    IN            NUMBER,
		p_current_invoice_status	IN OUT NOCOPY VARCHAR2,
	        p_calling_sequence IN VARCHAR2) return boolean;

--For third party payments project

   /*=========================================================================*/
   /*                                                                         */
   /* Function V_CHECK_INVALID_REMIT_TO_SUPPLIER performs the following       */
   /* validations on remit to supplier columns and rejects if appropriate:    */
   /*                                                                         */
   /*=========================================================================*/

  FUNCTION v_check_invalid_remit_supplier(
		 p_invoice_rec      IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
		 p_default_last_updated_by     IN            NUMBER,
		 p_default_last_update_login   IN            NUMBER,
		 p_current_invoice_status      IN OUT NOCOPY VARCHAR2,
		 p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN;


END AP_IMPORT_VALIDATION_PKG;


/
