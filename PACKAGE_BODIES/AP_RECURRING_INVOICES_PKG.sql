--------------------------------------------------------
--  DDL for Package Body AP_RECURRING_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_RECURRING_INVOICES_PKG" AS
/*$Header: aprecinb.pls 120.26.12010000.5 2010/12/20 12:25:55 sbonala ship $*/
--
-- Declare Local procedures
--
PROCEDURE ap_rec_inv_get_info(
    P_invoice_date          IN            DATE,
    P_invoice_amount        IN            NUMBER,
    P_accounting_date       IN            DATE,
    P_vendor_id             IN            NUMBER,
    P_vendor_site_id        IN            NUMBER,
    P_set_of_books_id       IN            NUMBER,
    P_tax_id                IN            NUMBER,
    P_invoice_currency_code IN            VARCHAR2,
    P_po_shipment_id        IN            NUMBER,
    P_terms_date               OUT NOCOPY DATE,
    P_gl_period_name           OUT NOCOPY VARCHAR2,
    P_tax_amount               OUT NOCOPY NUMBER,
    P_type_1099                OUT NOCOPY VARCHAR2,
    P_income_tax_region        OUT NOCOPY VARCHAR2,
    P_payment_priority         OUT NOCOPY NUMBER,
    P_min_unit                 OUT NOCOPY NUMBER,
    P_precision                OUT NOCOPY NUMBER,
    P_overbilled               OUT NOCOPY VARCHAR2,
    P_transfer_desc_flex_flag  OUT NOCOPY VARCHAR2,
    P_approval_workflow_flag   OUT NOCOPY VARCHAR2,
    P_inventory_org_id         OUT NOCOPY NUMBER,
    P_asset_bt_code            OUT NOCOPY VARCHAR2,
    P_Price                    OUT NOCOPY NUMBER,
    P_quantity                 OUT NOCOPY NUMBER, /* bug 5228301 */
    P_retained_amount          OUT NOCOPY NUMBER, /* bug 5228301 */
    P_match_type               OUT NOCOPY VARCHAR2, /* bug 5228301 */
    P_Description              OUT NOCOPY VARCHAR2,
    P_unit_meas_lookup_code    OUT NOCOPY VARCHAR2,
    P_ship_to_location_id      OUT NOCOPY NUMBER,
    P_calling_sequence      IN            VARCHAR2);

PROCEDURE ap_rec_inv_insert_ap_batches(
    P_batch_name            IN            VARCHAR2,
    P_batch_control_flag    IN            VARCHAR2,
    P_invoice_currency_code IN            VARCHAR2,
    P_payment_currency_code IN            VARCHAR2,
    P_last_update_date      IN            DATE,
    P_last_updated_by       IN            NUMBER,
    P_batch_id                 OUT NOCOPY NUMBER,
    P_calling_sequence      IN            VARCHAR2,
    P_Org_Id                IN            NUMBER);

PROCEDURE ap_rec_inv_insert_ap_invoices(
    P_batch_id              IN            NUMBER,
    P_last_update_date      IN            DATE,
    P_last_updated_by       IN            NUMBER,
    P_invoice_currency_code IN            VARCHAR2,
    P_payment_currency_code IN            VARCHAR2,
    P_base_currency_code    IN            VARCHAR2,
    P_invoice_id            IN OUT NOCOPY NUMBER,
    P_invoice_num           IN            VARCHAR2,
    P_invoice_amount        IN            NUMBER,
    P_vendor_id             IN            NUMBER,
    P_vendor_site_id        IN            NUMBER,
    P_invoice_date          IN            DATE,
    P_description           IN            VARCHAR2,
    P_tax_name              IN            VARCHAR2,
    P_tax_amount            IN            NUMBER,
    P_terms_id              IN            NUMBER,
    P_pay_group_lookup_code IN            VARCHAR2,
    P_set_of_books_id       IN            NUMBER,
    P_accts_pay_ccid        IN            NUMBER,
    P_payment_cross_rate    IN            NUMBER,
    P_exchange_date         IN            DATE,
    P_exchange_rate_type    IN            VARCHAR2,
    P_exchange_rate         IN            NUMBER,
    P_invoice_base_amount   IN            NUMBER,
    P_recurring_payment_id  IN            NUMBER,
    P_terms_date            IN            DATE,
    P_doc_sequence_id       IN            NUMBER,
    P_doc_sequence_value    IN            NUMBER,
    P_doc_category_code     IN            VARCHAR2,
    P_exclusive_payment_flag IN           VARCHAR2,
    P_awt_group_id          IN            NUMBER,
    P_pay_awt_group_id      IN            NUMBER,--bug6639866
    P_distribution_set_id   IN            NUMBER,
    P_accounting_date       IN            DATE,
 -- P_ussgl_txn_code        IN            VARCHAR2, - Bug 4277744
    P_attribute1            IN            VARCHAR2,
    P_attribute2            IN            VARCHAR2,
    P_attribute3            IN            VARCHAR2,
    P_attribute4            IN            VARCHAR2,
    P_attribute5            IN            VARCHAR2,
    P_attribute6            IN            VARCHAR2,
    P_attribute7            IN            VARCHAR2,
    P_attribute8            IN            VARCHAR2,
    P_attribute9            IN            VARCHAR2,
    P_attribute10           IN            VARCHAR2,
    P_attribute11           IN            VARCHAR2,
    P_attribute12           IN            VARCHAR2,
    P_attribute13           IN            VARCHAR2,
    P_attribute14           IN            VARCHAR2,
    P_attribute15           IN            VARCHAR2,
    P_attribute_category    IN            VARCHAR2,
    P_calling_sequence      IN            VARCHAR2,
    P_Org_Id                IN            NUMBER,
    P_Requester_Id          IN            NUMBER,
    P_Tax_Control_Amount    IN		  NUMBER,
    P_Trx_Business_Category IN		  VARCHAR2,
    P_User_Defined_Fisc_Class IN	  VARCHAR2,
    P_Taxation_Country      IN		  VARCHAR2,
    P_Legal_Entity_Id	    IN		  NUMBER,
    p_PAYMENT_METHOD_CODE   in            varchar2,
    p_PAYMENT_REASON_CODE   in            varchar2,
    p_remittance_message1   in            varchar2,
    p_remittance_message2   in            varchar2,
    p_remittance_message3   in            varchar2,
    p_bank_charge_bearer           in            varchar2,
    p_settlement_priority          in            varchar2,
    p_payment_reason_comments      in            varchar2,
    p_delivery_channel_code        in            varchar2,
    p_external_bank_account_id     in            number,
    p_party_id			   in		 number,
    p_party_site_id		   in		 number,
    /* bug 4931755 */
    p_disc_is_inv_less_tax_flag    in            varchar2,
    p_exclude_freight_from_disc    in            varchar2,
    P_REMIT_TO_SUPPLIER_NAME   in      VARCHAR2,
    P_REMIT_TO_SUPPLIER_ID    in       NUMBER,
    P_REMIT_TO_SUPPLIER_SITE   in      VARCHAR2,
    P_REMIT_TO_SUPPLIER_SITE_ID  in    NUMBER,
    P_RELATIONSHIP_ID       in         NUMBER);

Procedure Insert_Invoice_Line (
    P_Invoice_Id 	      IN     NUMBER,
    P_Invoice_line_number        OUT NOCOPY NUMBER,
    p_Invoice_Date            IN     DATE,
    p_Line_Type_Lookup_Code   IN     VARCHAR2,
    P_description             IN     VARCHAR2,
    P_Po_Line_Location_Id     IN     NUMBER   DEFAULT NULL,
    P_Amount		      IN     NUMBER,
    P_Quantity_Invoiced	      IN     NUMBER   DEFAULT NULL,
    P_Unit_Price	      IN     NUMBER   DEFAULT NULL,
    P_set_of_books_id         IN     NUMBER,
    P_exchange_rate           IN     NUMBER,
    P_base_currency_code      IN     VARCHAR2,
    P_accounting_date         IN     DATE,
    P_awt_group_id            IN     NUMBER,
    P_pay_awt_group_id        IN     NUMBER,--bug6639866
    P_gl_period_name          IN     VARCHAR2,
    P_income_tax_region       IN     VARCHAR2,
    P_transfer_flag           IN     VARCHAR2,
    P_approval_workflow_flag  IN     VARCHAR2,
    P_Inventory_org_id        IN     NUMBER,
    P_asset_bt_code           IN     VARCHAR2,
    P_Tax_Control_Amount      IN     NUMBER   DEFAULT NULL,
    P_Primary_Intended_Use    IN     VARCHAR2 DEFAULT NULL,
    P_Product_Fisc_Classification IN VARCHAR2 DEFAULT NULL,
    P_User_Defined_Fisc_Class IN     VARCHAR2 DEFAULT NULL,
    P_Trx_Business_Category   IN     VARCHAR2 DEFAULT NULL,
    P_retained_amount         IN     NUMBER   DEFAULT NULL, /*bug 5228301 */
    P_match_type              IN     VARCHAR2,             /* bug 5228301 */
    P_Tax_Classification_Code IN     VARCHAR2,
    P_PRODUCT_TYPE	      IN     VARCHAR2,   --Bug#8640313
    P_PRODUCT_CATEGORY	      IN     VARCHAR2,   --Bug#8640313
    P_Calling_Sequence	      IN     VARCHAR2);


Procedure Insert_Invoice_Line_Dset(
	P_invoice_id			IN	NUMBER,
	P_line_amount			IN	NUMBER,
	P_description			IN	VARCHAR2,
	P_distribution_set_id		IN     	NUMBER,
	P_requester_id			IN	NUMBER,
	P_set_of_books_id		IN     	NUMBER,
	P_exchange_rate           	IN     	NUMBER,
        P_base_currency_code      	IN     	VARCHAR2,
        P_accounting_date         	IN     	DATE,
	P_gl_period_name		IN	VARCHAR2,
	P_org_id			IN	NUMBER,
	P_item_description		IN	VARCHAR2,
	P_manufacturer			IN	VARCHAR2,
        P_model_number			IN	VARCHAR2,
	P_approval_workflow_flag	IN	VARCHAR2,
     -- P_ussgl_txn_code		IN	VARCHAR2, - Bug 4277744
	P_income_tax_region		IN	VARCHAR2,
	P_type_1099			IN	VARCHAR2,
	P_asset_bt_code			IN	VARCHAR2,
	P_awt_group_id			IN	NUMBER,
	P_pay_awt_group_id              IN      NUMBER,--bug6639866
	P_ship_to_location_id		IN	NUMBER,
	P_primary_intended_use		IN	VARCHAR2,
	P_product_fisc_classification	IN	VARCHAR2,
	P_trx_business_category		IN	VARCHAR2,
	P_user_defined_fisc_class	IN	VARCHAR2,
	P_tax_classification_code	IN	VARCHAR2,
	P_PRODUCT_TYPE	                IN      VARCHAR2,   --Bug#8640313
        P_PRODUCT_CATEGORY	        IN      VARCHAR2,   --Bug#8640313
	P_calling_sequence		IN	VARCHAR2
	);

/*========================================================================
 * Main Procedure: Create Recurring Invoices :ap_create_recurring_invoices
 * Step 1. Call ap_rec_inv_get_info to get some required fields
 * Step 2. Create ap_batches id it's a new batch
 * Step 3. Create ap_invoices
 * Step 4.1 Call ap_match to create ITEM invoice lines
 * Step 4.2 Call AP_INVOICES_PKG.insert_children insert all the corrsponding
            ap_invoice_lines
            ap_payment_schedules, ap_holds

 *========================================================================*/
PROCEDURE ap_create_recurring_invoices(
    P_batch_name                  IN            VARCHAR2 DEFAULT NULL,
    P_last_update_date            IN            DATE,
    P_last_updated_by             IN            NUMBER,
    P_invoice_currency_code       IN            VARCHAR2,
    P_payment_currency_code       IN            VARCHAR2,
    P_invoice_num                 IN            VARCHAR2,
    P_invoice_amount              IN OUT NOCOPY NUMBER,
    P_vendor_id                   IN            NUMBER,
    P_vendor_site_id              IN            NUMBER   Default NULL,
    P_invoice_date                IN            DATE     Default NULL,
    P_description                 IN            VARCHAR2 DEFAULT NULL,
    P_terms_id                    IN            NUMBER   Default NULL,
    P_pay_group_lookup_code       IN            VARCHAR2 DEFAULT NULL,
    P_set_of_books_id             IN            NUMBER,
    P_accts_pay_ccid              IN            NUMBER   Default NULL,
    P_payment_cross_rate          IN            NUMBER,
    P_exchange_date               IN            DATE     Default NULL,
    P_exchange_rate_type          IN            VARCHAR2 DEFAULT NULL,
    P_exchange_rate               IN            NUMBER   Default NULL,
    P_invoice_base_amount         IN            NUMBER   Default NULL,
    P_base_currency_code          IN            VARCHAR2 DEFAULT NULL,
    P_recurring_payment_id        IN            NUMBER   Default NULL,
    P_doc_sequence_id             IN            NUMBER   Default NULL,
    P_doc_sequence_value          IN            NUMBER   Default NULL,
    P_doc_category_code           IN            VARCHAR2 DEFAULT NULL,
    P_exclusive_payment_flag      IN            VARCHAR2 DEFAULT NULL,
    P_awt_group_id                IN            NUMBER   Default NULL,
    P_pay_awt_group_id            IN            NUMBER   Default NULL,--bug6639866
    P_distribution_set_id         IN            NUMBER   Default NULL,
    P_accounting_date             IN            DATE,
    P_po_shipment_id              IN            NUMBER   Default NULL,
    P_batch_control_flag          IN            VARCHAR2 DEFAULT NULL,
    P_multi_currency_flag         IN            VARCHAR2 Default NULL,
    P_po_match_flag               IN            VARCHAR2 Default NULL,
 -- Removed for bug 4277744
 -- P_ussgl_txn_code              IN            VARCHAR2 Default NULL,
    P_attribute1                  IN            VARCHAR2 DEFAULT NULL,
    P_attribute2                  IN            VARCHAR2 DEFAULT NULL,
    P_attribute3                  IN            VARCHAR2 Default NULL,
    P_attribute4                  IN            VARCHAR2 DEFAULT NULL,
    P_attribute5                  IN            VARCHAR2 DEFAULT NULL,
    P_attribute6                  IN            VARCHAR2 DEFAULT NULL,
    P_attribute7                  IN            VARCHAR2 DEFAULT NULL,
    P_attribute8                  IN            VARCHAR2 DEFAULT NULL,
    P_attribute9                  IN            VARCHAR2 DEFAULT NULL,
    P_attribute10                 IN            VARCHAR2 DEFAULT NULL,
    P_attribute11                 IN            VARCHAR2 DEFAULT NULL,
    P_attribute12                 IN            VARCHAR2 DEFAULT NULL,
    P_attribute13                 IN            VARCHAR2 DEFAULT NULL,
    P_attribute14                 IN            VARCHAR2 DEFAULT NULL,
    P_attribute15                 IN            VARCHAR2 DEFAULT NULL,
    P_attribute_category          IN            VARCHAR2 DEFAULT NULL,
    P_calling_sequence            IN            VARCHAR2 DEFAULT NULL,
    P_invoice_id                  OUT NOCOPY NUMBER,
    P_Org_Id                      IN  NUMBER Default mo_global.get_current_org_id,
    P_Requester_Id                IN            NUMBER Default NULL,
    P_Po_Release_Id               IN            NUMBER DEFAULT NULL,
    P_Item_Description            IN            VARCHAR2 DEFAULT NULL,
    P_Manufacturer                IN            VARCHAR2 DEFAULT NULL,
    P_Model_Number                IN            VARCHAR2 DEFAULT NULL,
    P_Tax_Control_Amount	  IN		NUMBER   DEFAULT NULL,
    P_Trx_Business_Category	  IN		VARCHAR2 DEFAULT NULL,
    P_User_Defined_Fisc_Class	  IN	  	VARCHAR2 DEFAULT NULL,
    P_Taxation_Country		  IN		VARCHAR2 DEFAULT NULL,
    P_Primary_Intended_Use	  IN		VARCHAR2 DEFAULT NULL,
    P_Product_Fisc_Classification IN		VARCHAR2 DEFAULT NULL,
    P_Tax_Amount		  IN		NUMBER   DEFAULT NULL,
    P_Tax_Amt_Exclusive		  IN		VARCHAR2 DEFAULT NULL,
    P_Legal_Entity_Id		  IN		NUMBER   DEFAULT NULL,
    p_PAYMENT_METHOD_CODE          in            varchar2 default null,
    p_PAYMENT_REASON_CODE          in            varchar2 default null,
    p_remittance_message1          in            varchar2 default null,
    p_remittance_message2          in            varchar2 default null,
    p_remittance_message3          in            varchar2 default null,
    p_bank_charge_bearer           in            varchar2 default null,
    p_settlement_priority          in            varchar2 default null,
    p_payment_reason_comments      in            varchar2 default null,
    p_delivery_channel_code        in            varchar2 default null,
    p_external_bank_account_id     in            number default null,
    p_party_id			   in		 number default null,
    p_party_site_id		   in		 number default null,
    /* bug 4931755. Exclude Tax From Discount */
    p_disc_is_inv_less_tax_flag    in            varchar2 default null,
    p_exclude_freight_from_disc    in            varchar2 default null,
    p_tax_classification_code	   in		 varchar2 default null,
    P_REMIT_TO_SUPPLIER_NAME         VARCHAR2 DEFAULT NULL,
    P_REMIT_TO_SUPPLIER_ID           NUMBER DEFAULT NULL,
    P_REMIT_TO_SUPPLIER_SITE         VARCHAR2 DEFAULT NULL,
    P_REMIT_TO_SUPPLIER_SITE_ID      NUMBER DEFAULT NULL,
    P_RELATIONSHIP_ID                NUMBER DEFAULT NULL,
    P_PRODUCT_TYPE		     VARCHAR2 DEFAULT NULL,   --Bug#8640313
    P_PRODUCT_CATEGORY		     VARCHAR2 DEFAULT NULL  --Bug#8640313
) IS

current_calling_sequence      VARCHAR2(2000);
debug_info                    VARCHAR2(100);
C_terms_date                  DATE;
C_gl_period_name              VARCHAR2(100);
C_tax_name                    AP_TAX_CODES.NAME%TYPE;
C_tax_id                      AP_TAX_CODES.TAX_ID%TYPE;
C_tax_type                    AP_TAX_CODES.TAX_TYPE%TYPE;
C_tax_description             AP_TAX_CODES.DESCRIPTION%TYPE;
C_allow_tax_override          GL_TAX_OPTION_ACCOUNTS.ALLOW_TAX_CODE_OVERRIDE_FLAG%TYPE;
C_tax_amount                  NUMBER;
C_type_1099                   VARCHAR2(10);
C_income_tax_region           VARCHAR2(10);
C_payment_priority            NUMBER;
C_min_unit                    NUMBER;
C_precision                   NUMBER;
C_batch_id                    NUMBER;
C_invoice_id                  NUMBER;
C_create_item_dist_flag       VARCHAR2(2) := 'Y';
C_Hold_count                  NUMBER;
C_Line_count                  NUMBER;
C_Line_Total                  NUMBER;
C_Distribution_Set_ID         NUMBER;
C_quantity_outstanding        NUMBER;
C_overbilled                  VARCHAR2(1);
C_Quantity                    NUMBER;
C_Transfer_desc_flex_Flag     ap_system_parameters.transfer_desc_flex_flag%TYPE;
C_Approval_Workflow_Flag      ap_system_parameters.approval_workflow_flag%TYPE;
C_Invoice_line_number         ap_invoice_lines_all.line_number%TYPE;
C_Price                       NUMBER;
C_Description                 ap_lookup_codes.description%TYPE;
C_unit_meas_lookup_code       po_line_locations_all.unit_meas_lookup_code%TYPE;
C_inventory_org_id            financials_system_parameters.inventory_organization_id%TYPE;
C_asset_bt_code               AP_INVOICE_LINES_ALL.ASSET_BOOK_TYPE_CODE%TYPE;
C_dist_tab                    AP_MATCHING_PKG.dist_tab_type;
C_ship_to_location_id	      PO_VENDOR_SITES.ship_to_location_id%TYPE;
C_retained_amount             Number; /*bug 5228301 */
C_match_type                  AP_INVOICE_LINES_ALL.Match_Type%TYPE;
C_sched_holds_count           NUMBER;  --bug 5452979

-- eTax Uptake
l_inv_hdr_amount	NUMBER;
l_line_amount		NUMBER;
l_base_line_amount	NUMBER;
l_inv_line_tax_atts	ap_invoice_lines%rowtype;

l_invoice_line_number	       AP_INVOICE_LINES.LINE_NUMBER%TYPE;

BEGIN
  -- Update the calling sequence
  --
    current_calling_sequence :=
      'AP_RECURRING_INVOICES_PKG.ap_create_recurring_invoices<-'
      ||P_calling_sequence;

C_dist_tab.DELETE;

/*---------------------------------------------------------------------------
 * Step 1:
 * Call ap_rec_inv_get_info to get some parameters
 *--------------------------------------------------------------------------*/
    debug_info := 'Call ap_rec_inv_get_info';
    AP_RECURRING_INVOICES_PKG.ap_rec_inv_get_info(
      P_invoice_date,
      P_invoice_amount,
      P_accounting_date,
      P_vendor_id,
      P_vendor_site_id,
      P_set_of_books_id,
      c_tax_id,
      P_invoice_currency_code,
      P_po_shipment_id,
      C_terms_date,
      C_gl_period_name,
      C_tax_amount,
      C_type_1099,
      C_income_tax_region,
      C_payment_priority,
      C_min_unit,
      C_precision,
      C_overbilled,
      C_Transfer_desc_flex_Flag,
      C_Approval_Workflow_Flag,
      C_inventory_org_id,
      C_asset_bt_code,
      C_Price,
      C_Quantity, /* bug 5228301 */
      C_Retained_Amount, /* bug 5228301 */
      C_Match_Type, /* bug 5228301 */
      C_Description,
      C_unit_meas_lookup_code,
      C_Ship_to_location_id,
      Current_calling_sequence);


/*---------------------------------------------------------------------------
 * Step 2:  Insert New AP_BATCHES IF it's a new batch
 * Call ap_rec_inv_insert_ap_batches: Insert AP_BATCHES
 *--------------------------------------------------------------------------*/
    debug_info := 'ap_rec_inv_insert_ap_batches';
    AP_RECURRING_INVOICES_PKG.ap_rec_inv_insert_ap_batches(
      P_batch_name,
      nvl(P_batch_control_flag,'N'),
      P_invoice_currency_code,
      P_payment_currency_code,
      P_last_update_date,
      P_last_updated_by,
      C_batch_id,
      Current_calling_sequence,
      P_Org_Id);


/*---------------------------------------------------------------------------
 * Step 3:  Insert New AP_INVOICES
 * Call ap_rec_inv_insert_ap_invoices: Insert AP_INVOICES
 *--------------------------------------------------------------------------*/

    IF (NVL(P_po_match_flag,'N') = 'Y') THEN
	IF P_Tax_Amount IS NOT NULL THEN

	   l_inv_hdr_amount := P_Invoice_Amount + P_Tax_Amount;

	END IF;
    ELSE
        l_inv_hdr_amount := NULL;
    END IF;

    debug_info := 'ap_rec_inv_insert_ap_invoices';
    AP_RECURRING_INVOICES_PKG.ap_rec_inv_insert_ap_invoices(
      C_batch_id,
      P_last_update_date,
      P_last_updated_by,
      P_invoice_currency_code,
      P_payment_currency_code,
      P_base_currency_code,
      C_invoice_id,
      P_invoice_num,
      nvl(l_inv_hdr_amount, P_invoice_amount),
      P_vendor_id,
      P_vendor_site_id,
      P_invoice_date,
      P_description,
      c_tax_name,
      C_tax_amount,
      P_terms_id,
      P_pay_group_lookup_code,
      P_set_of_books_id,
      P_accts_pay_ccid,
      P_payment_cross_rate,
      P_exchange_date,
      P_exchange_rate_type,
      P_exchange_rate,
      nvl(l_inv_hdr_amount, P_invoice_base_amount),
      P_recurring_payment_id,
      C_terms_date,
      P_doc_sequence_id,
      P_doc_sequence_value,
      P_doc_category_code,
      P_exclusive_payment_flag,
      P_awt_group_id,
      P_pay_awt_group_id,--bug6639866
      P_distribution_set_id,
      P_accounting_date,
   -- P_ussgl_txn_code, - Bug 4277744
      P_attribute1,
      P_attribute2,
      P_attribute3,
      P_attribute4,
      P_attribute5,
      P_attribute6,
      P_attribute7,
      P_attribute8,
      P_attribute9,
      P_attribute10,
      P_attribute11,
      P_attribute12,
      P_attribute13,
      P_attribute14,
      P_attribute15,
      P_attribute_category,
      Current_calling_sequence,
      P_Org_Id,
      P_Requester_Id,
      P_Tax_Control_Amount,
      P_Trx_Business_Category,
      P_User_Defined_Fisc_Class,
      P_Taxation_Country,
      P_Legal_Entity_Id,
      p_PAYMENT_METHOD_CODE,
      p_PAYMENT_REASON_CODE,
      p_remittance_message1,
      p_remittance_message2,
      p_remittance_message3,
      p_bank_charge_bearer,
      p_settlement_priority,
      p_payment_reason_comments,
      p_delivery_channel_code,
      p_external_bank_account_id,
      p_party_id,
      p_party_site_id,
      /* bug 4931755 */
      p_disc_is_inv_less_tax_flag,
      p_exclude_freight_from_disc,
      P_REMIT_TO_SUPPLIER_NAME,
      P_REMIT_TO_SUPPLIER_ID,
      P_REMIT_TO_SUPPLIER_SITE,
      P_REMIT_TO_SUPPLIER_SITE_ID,
      P_RELATIONSHIP_ID);

 P_invoice_id := C_Invoice_Id;
 C_Distribution_Set_ID := P_Distribution_Set_ID;

/*---------------------------------------------------------------------------
 * Step 4:  IF PO Matching
 *          *   Call Insert_Invoice_line
 *          *   Call AP_MATCHING_PKG.Base_Credit_PO_Match
 *--------------------------------------------------------------------------*/

  IF (NVL(P_po_match_flag,'N') = 'Y' AND P_invoice_amount >= 0) then

    -------------------------------------------------------------
    --Step 4.i : Insert the Invoice Line
    -------------------------------------------------------------
    debug_info := 'Create Invoice Line';
  	AP_RECURRING_INVOICES_PKG.Insert_Invoice_Line(
           P_Invoice_ID                => C_invoice_id,
           P_Invoice_line_Number       => C_Invoice_Line_Number,
           P_Invoice_Date              => P_Invoice_date,
           P_Line_Type_Lookup_Code     => 'ITEM',
           P_description               => C_description,
           P_Po_Line_Location_id       => P_po_shipment_id,
  	   P_Amount		       => P_invoice_amount,
  	   P_Quantity_Invoiced	       => C_quantity,
  	   P_Unit_Price		       => C_price,
           P_Set_of_Books_Id           => P_set_of_books_Id,
           P_exchange_rate             => P_exchange_rate,
           P_Base_currency_code        => P_Base_currency_code,
           P_Accounting_date           => P_Accounting_date,
           P_Awt_Group_Id              => P_Awt_Group_Id,
	   P_Pay_Awt_Group_Id          => P_Pay_Awt_Group_Id,--bug6639866
           P_gl_period_name            => C_gl_period_name,
           P_income_tax_region         => C_Income_tax_region,
           P_Transfer_Flag             => C_Transfer_desc_flex_Flag,
           P_Approval_Workflow_Flag    => C_Approval_Workflow_Flag,
           P_inventory_org_id          => C_inventory_org_id,
           P_asset_bt_code             => C_asset_bt_code,
           P_Tax_Control_Amount	       => P_Tax_Control_Amount,
           P_Primary_Intended_Use      => P_Primary_Intended_Use,
           P_Product_Fisc_Classification => P_Product_Fisc_Classification,
           P_User_Defined_Fisc_Class   => P_User_Defined_Fisc_Class,
           P_Trx_Business_Category     => P_Trx_Business_Category,
           P_Retained_Amount           => C_Retained_Amount, /* bug 5228301 */
           P_Match_Type                => C_Match_Type, /* bug 5228301 */
	   P_Tax_Classification_Code   => P_Tax_Classification_Code,
	   P_PRODUCT_TYPE	       => P_PRODUCT_TYPE,   --Bug#8640313
           P_PRODUCT_CATEGORY	       => P_PRODUCT_CATEGORY,  --Bug#8640313
  	   P_Calling_Sequence          => current_calling_sequence);

     -------------------------------------------------------
     -- Step 4.iv: Call  PO_MATCH to create ITEM dist lines
     -------------------------------------------------------
     debug_info := 'Calling PO Matching to create Item Dist Lines';
     /* bug 5228301 */
     AP_MATCHING_UTILS_PKG.Match_Invoice_Line(
        P_Invoice_Id          => C_invoice_id,
        P_Invoice_Line_Number => C_invoice_line_number,
        P_Overbill_Flag       => C_overbilled,
        P_Calling_Sequence    => Current_calling_sequence);
      /*
      AP_MATCHING_PKG.Base_Credit_PO_Match(
        X_match_mode          => 'STD-PS',
        X_invoice_id          => C_invoice_id,
        X_invoice_line_number => C_invoice_line_number,
        X_Po_Line_Location_id => P_po_shipment_id,
        X_Dist_Tab            => C_dist_tab,
        X_amount              => P_invoice_amount, --eTax - nvl(c_tax_amount,0),
        X_quantity            => C_quantity,
        X_unit_price          => C_price,
        X_uom_lookup_code     => C_unit_meas_lookup_code,
        X_final_match_flag    => 'N',
        X_overbill_flag       => C_overbilled,
        X_freight_amount      => NULL,
        X_freight_description => NULL,
        X_misc_amount         => NULL,
        X_misc_description    => NULL,
        X_calling_sequence    => Current_calling_sequence);
     */

     --
     -- Since ap_match has created the item dist lines. We need
     -- to prevent insert_children to create item dist lines.
     --
     -- If we set C_Distribution_Set_ID is NULL, insert_children
     --   won't create the ITEM lines.
     --
     C_Distribution_Set_ID := '';
   END IF;
   -------------------------------------------------------------------
   -- Step 5:  Call AP_INVOICES_PKG.insert_children()
   --          Inserts child records into AP_HOLDS,
   --          AP_PAYMENT_SCHEDULES
   --          If C_Disttribution_set_ID is not NULL
   --          Insert AP_INVOICE_LINES
   --    * If PO_match has been executed. Don't create ITEM lines
   -------------------------------------------------------------------

   IF C_Distribution_Set_ID IS NOT NULL THEN

      IF P_Tax_Amount IS NOT NULL	AND
         P_Tax_Amt_Exclusive = 'Y'	THEN
	 l_line_amount := P_Invoice_Amount - P_Tax_Amount;
      ELSE
	l_line_amount := P_Invoice_Amount;
      END IF;

      AP_RECURRING_INVOICES_PKG.Insert_Invoice_Line_Dset(
	P_invoice_id		=> p_invoice_id,
	P_line_amount		=> l_line_amount,
	P_description		=> c_description,
	P_distribution_set_id	=> c_distribution_set_id,
	P_requester_id		=> p_requester_id,
	P_set_of_books_id	=> p_set_of_books_id,
	P_exchange_rate		=> p_exchange_rate,
	P_base_currency_code	=> p_base_currency_code,
	P_accounting_date	=> p_accounting_date,
	P_gl_period_name	=> c_gl_period_name,
	P_org_id		=> p_org_id,
	P_item_description	=> p_item_description,
	P_manufacturer		=> p_manufacturer,
	P_model_number		=> p_model_number,
	P_approval_workflow_flag=> c_approval_workflow_flag,
     --	P_ussgl_txn_code	=> p_ussgl_txn_code, - Bug 4277744
	P_income_tax_region	=> c_income_tax_region,
	P_type_1099		=> c_type_1099,
	P_asset_bt_code		=> c_asset_bt_code,
	P_awt_group_id		=> p_awt_group_id,
	P_pay_awt_group_id      => p_pay_awt_group_id,--bug6639866
	P_ship_to_location_id	=> c_ship_to_location_id,
	P_primary_intended_use  => p_primary_intended_use,
	P_product_fisc_classification => p_product_fisc_classification,
	P_trx_business_category => p_trx_business_category,
	P_user_defined_fisc_class => p_user_defined_fisc_class,
	P_tax_classification_code => p_tax_classification_code,
        P_PRODUCT_TYPE	          => P_PRODUCT_TYPE,      --Bug#8640313
        P_PRODUCT_CATEGORY	  => P_PRODUCT_CATEGORY,  --Bug#8640313
	P_calling_sequence      => current_calling_sequence);


   END IF;   /* if c_distribution_set is not null */




   debug_info := 'Insert Holds, Payment Schedules ';
   AP_INVOICES_PKG.insert_children (
                X_invoice_id		=> C_invoice_id,
                X_Payment_Priority	=> C_Payment_Priority,
                X_Hold_count 		=> C_Hold_count,
                X_Line_count 		=> C_Line_count,
                X_Line_Total		=> C_Line_Total,
                X_calling_sequence	=> Current_calling_sequence,
                X_Sched_Hold_count      => C_sched_holds_count );    --bug 5452979

 EXCEPTION
 WHEN OTHERS then
   IF ((SQLCODE <> -20001) OR (SQLCODE <> -20002) ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
        'Invoice_date = '||TO_CHAR(P_invoice_date)
        ||' Accounting_date = '||TO_CHAR(P_accounting_date)
         ||' Currency_code = '||P_invoice_currency_code
        ||' P_recurring_payment_id = '||TO_CHAR(P_recurring_payment_id)
        ||' P_exclusive_payment_flag = '||P_exclusive_payment_flag
        ||' P_awt_group_id = '||TO_CHAR(P_awt_group_id)
	||' P_pay_awt_group_id = '||TO_CHAR(P_pay_awt_group_id)    --bug6639866
        ||' Invoice_date = '||TO_CHAR(P_invoice_date)
        ||' Vendor_id = '||TO_CHAR(P_vendor_id)
        ||' Vendor_site_id = '||TO_CHAR(P_vendor_site_id)
        ||' Invoice_num = '||P_invoice_num
        ||' Invoice Amount = '||TO_CHAR(P_invoice_amount)
        ||' P_doc_category_code = '||P_doc_category_code
        ||' Doc_sequence_value = '||TO_CHAR(P_doc_sequence_value)
        ||' Doc_sequence_id = '||TO_CHAR(P_doc_sequence_id)
        ||' Pay_group_lookup_code = '||P_pay_group_lookup_code
        ||' Invoice_currency_code = '||P_invoice_currency_code
        ||' Payment_currency_code = '||P_payment_currency_code
        ||' Terms_id = '||TO_CHAR(P_terms_id)
        ||' Payment_cross_rate = '||TO_CHAR(P_payment_cross_rate)
        ||' Exchange Rate = '||TO_CHAR(P_exchange_rate)
        ||' Exchange Rate Type = '||P_exchange_rate_type
        ||' Exchange Date = '||TO_CHAR(P_exchange_date)
        ||' Set 0f books id = '||TO_CHAR(P_set_of_books_id)
        ||' Last_updated_by = '||TO_CHAR(P_last_updated_by)
        ||' Last_updated_date = '||TO_CHAR(P_last_update_date)
        ||' P_po_match_flag = '||P_po_match_flag
        ||' P_batch_control_flag = '||P_batch_control_flag);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_create_recurring_invoices;



/*==========================================================================
 Private Procedure: Ap_rec_inv_get_info

  This PROCEDURE is responsible for getting values from several different
    database column.
 *=====================================================================*/
PROCEDURE ap_rec_inv_get_info(
    P_invoice_date          IN            DATE,
    P_invoice_amount        IN            NUMBER,
    P_accounting_date       IN            DATE,
    P_vendor_id             IN            NUMBER,
    P_vendor_site_id        IN            NUMBER,
    P_set_of_books_id       IN            NUMBER,
    P_tax_id                IN            NUMBER,
    P_invoice_currency_code IN            VARCHAR2,
    P_po_shipment_id        IN            NUMBER,
    P_terms_date               OUT NOCOPY DATE,
    P_gl_period_name           OUT NOCOPY VARCHAR2,
    P_tax_amount               OUT NOCOPY NUMBER,
    P_type_1099                OUT NOCOPY VARCHAR2,
    P_income_tax_region        OUT NOCOPY VARCHAR2,
    P_payment_priority         OUT NOCOPY NUMBER,
    P_min_unit                 OUT NOCOPY NUMBER,
    P_precision                OUT NOCOPY NUMBER,
    P_overbilled               OUT NOCOPY VARCHAR2,
    P_transfer_desc_flex_flag  OUT NOCOPY VARCHAR2,
    P_approval_workflow_flag   OUT NOCOPY VARCHAR2,
    P_inventory_org_id         OUT NOCOPY NUMBER,
    P_asset_bt_code            OUT NOCOPY VARCHAR2,
    P_Price                    OUT NOCOPY NUMBER,
    P_quantity                 OUT NOCOPY NUMBER, /* bug 5228301 */
    P_retained_amount          OUT NOCOPY NUMBER, /* bug 5228301 */
    P_Match_Type               OUT NOCOPY VARCHAR2, /* bug 5228301 */
    P_Description              OUT NOCOPY VARCHAR2,
    P_unit_meas_lookup_code    OUT NOCOPY VARCHAR2,
    P_ship_to_location_id      OUT NOCOPY NUMBER,
    P_calling_sequence      IN            VARCHAR2) IS

debug_info                    VARCHAR2(100);
current_calling_sequence      VARCHAR2(2000);
C_tax_amount                  NUMBER;
C_quantity_outstanding        NUMBER;
C_quantity                    NUMBER;
C_tax_rate                    NUMBER;
C_asset_book_count            NUMBER := 0;
l_matching_basis              po_line_types.matching_basis%type; /* bug 5228301 */

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'ap_rec_inv_get_info<-'||P_calling_sequence;

  -------------------------------------------
  -- get terms_date
  -------------------------------------------
  debug_info := 'Get terms date and rounding rule';
  SELECT decode(pvs.terms_date_basis, 'Current', SYSDATE,
                P_invoice_date)
    INTO P_terms_date
    FROM po_vendor_sites pvs
   WHERE vendor_site_id = P_vendor_site_id;


  -------------------------------------------
  -- get gl_period_name
  -------------------------------------------
  debug_info := 'Get period name';
  SELECT period_name
  INTO   P_gl_period_name
  FROM   gl_period_statuses
  WHERE  application_id = 200
  AND    set_of_books_id = P_set_of_books_id
  AND     (closing_status = 'O'
         OR
         closing_status = 'F'
         OR
         closing_status = 'N') --1569550
  AND    NVL(P_accounting_date, P_invoice_date)
             BETWEEN start_date AND end_date
  AND     NVL(adjustment_period_flag, 'N') = 'N';

  ---------------------------------------
  -- Get type_1099 and income_tax_region
  ---------------------------------------
  debug_info := 'Get type_1099 and income_tax_region';

/*
2645659 fbreslin: Remove the JOIN to AP_TAX_CODES in the following SQL.
*/

  BEGIN
    SELECT v.type_1099,
         decode(v.type_1099,
             '','',
               DECODE(sp.combined_filing_flag,
                      'N','',
                          DECODE(sp.income_tax_region_flag,
                            'Y',vs.state,
                                 sp.income_tax_region))),
         NVL(sp.transfer_desc_flex_flag, 'N'),
         NVL(sp.approval_workflow_flag, 'N'),
         fsp.inventory_organization_id,
	 vs.ship_to_location_id
    INTO P_type_1099,
         P_income_tax_region,
         P_transfer_desc_flex_flag,
         P_approval_workflow_flag,
         P_inventory_org_id,
	 P_ship_to_location_id
    FROM po_vendors v,
         ap_system_parameters sp,
         po_vendor_sites vs,
         financials_system_parameters fsp
   WHERE v.vendor_id = P_vendor_id
     AND vs.org_id = sp.org_id
     AND sp.org_id = fsp.org_id
     AND vs.vendor_site_id = P_vendor_site_id
     AND rownum < 2;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

    ---------------------------------------------------------------------
    -- Get the Min_unit and precision from fnd_currencies
    ---------------------------------------------------------------------
    debug_info := 'Get min_unit and precision';
    SELECT minimum_accountable_unit, nvl(precision,0)
    INTO P_min_unit, P_precision
    FROM fnd_currencies
    WHERE currency_code = P_invoice_currency_code;

    ---------------------------------------------------------------------
    -- Get the Payment Priority from po_vendor_site
    ---------------------------------------------------------------------
    debug_info := 'Get Payment Priority';
    SELECT pvs.payment_priority
      INTO P_payment_priority
      FROM po_vendors pv, po_vendor_sites pvs
     WHERE pv.vendor_id = P_vendor_id
       AND pvs.vendor_site_id = P_vendor_site_id;

    ----------------------------------------------------
    -- Get quantity_outstanding
    ----------------------------------------------------
    debug_info := 'Get quantity_outstanding';

  if(P_po_shipment_id is not null) then

    debug_info := 'Get asset book and set asset category '||
                   'information IF possible';
     BEGIN
       SELECT count(*)
         INTO c_asset_book_count
         FROM fa_book_controls bc
        WHERE bc.book_class = 'CORPORATE'
          AND bc.set_of_books_id = P_set_of_books_id
          AND bc.date_ineffective is null;

       IF (C_asset_book_count = 1) then
         SELECT bc.book_type_code
           INTO P_asset_bt_code
           FROM fa_book_controls bc
          WHERE bc.set_of_books_id = P_set_of_books_id
            AND bc.date_ineffective is null;

       ELSE

         P_asset_bt_code := NULL;

       END IF;

     EXCEPTION
       -- No need to error handle IF FA information not available.
       WHEN no_data_found THEN
         NULL;
       WHEN OTHERS THEN
         NULL;
     END;

    ------------------------------------------------------
    --  Retreive Unit Price and UOM Lookup Code
    --  from PO Shipment and
    -----------------------------------------------------
    SELECT pll.price_override,
           pl.unit_meas_lookup_code,
           pll.matching_basis
      INTO P_price,
           P_unit_meas_lookup_code,
           l_matching_basis  /* bug 5228301 */
      FROM po_line_locations pll, po_lines pl, po_line_types plt
     WHERE pll.line_location_id = P_po_shipment_id
       AND pl.po_line_id = pll.po_line_id
       AND pl.line_type_id = plt.line_type_id;

    IF l_matching_basis = 'QUANTITY' THEN
      C_quantity := round((P_invoice_amount)/P_price, 15);
      P_Quantity := C_quantity; /*bug 5228301 */
      P_Match_Type := 'ITEM_TO_PO';
    ELSE
      P_Match_Type := 'ITEM_TO_SERVICE_PO'; /*bug 5228301 */
    END IF;

    -------------------------------------------------------------
    -- Retreive description 'Created by Recurring Invoice'
    -- from ap_lookup_codes to enable translation Problem
    --------------------------------------------------------------
    debug_info := 'get new description';
    Begin
      SELECT description INTO P_Description
        FROM ap_lookup_codes
       WHERE lookup_type = 'SOURCE' and
             lookup_code = 'RECURRING INVOICE';
    EXCEPTION
      WHEN NO_DATA_FOUND Then
        NULL;
    End;

-- Bug 404997 has changed the following select Condition
/* bug 5228301, following statement has modified */
   SELECT  decode(l_matching_basis, 'QUANTITY',
            (sum(nvl(pd.quantity_ordered,0) - nvl(pd.quantity_billed,0) -
            nvl(pd.quantity_cancelled,0)) - ((p_invoice_amount - nvl(p_tax_amount,0))
            /pll.price_override)),
            (sum(nvl(pd.amount_ordered,0) - nvl(pd.amount_billed,0) -
            nvl(pd.amount_cancelled,0)) - (p_invoice_amount - nvl(p_tax_amount,0)))
            )
    INTO   C_quantity_outstanding
    FROM   po_distributions_ap_v pd,po_line_locations  pll
    WHERE   pd.line_location_id=pll.line_location_id
    AND     pd.line_location_id = P_po_shipment_id
    GROUP BY pll.line_location_id,pll.price_override;


    ----------------------------------------------------
    -- Decide IF overbilled
    ----------------------------------------------------
    IF l_matching_basis = 'QUANTITY' THEN
      IF ( C_quantity > C_quantity_outstanding ) then
         P_overbilled := 'Y';
      ELSE
         P_overbilled := 'N';
      END IF;
    ELSE  /* bug 5228301 */
      IF ( P_invoice_amount > C_quantity_outstanding ) then
         P_overbilled := 'Y';
      ELSE
         P_overbilled := 'N';
      END IF;
    END IF;


    /* bug 5228301. Retainage amount */
    P_retained_amount := AP_INVOICE_LINES_UTILITY_PKG.Get_Retained_Amount
                (p_po_shipment_id,
                 p_invoice_amount);

  END IF;

EXCEPTION
 WHEN NO_DATA_FOUND then

 IF (debug_info = 'get offset tax amount and name') then
   NULL;
 ELSE
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
        'Invoice_date = '||TO_CHAR(P_invoice_date)
        ||' Invoice_amount = '||TO_CHAR(P_invoice_amount)
        ||' Vendor_id = '||TO_CHAR(P_vendor_id)
        ||' Vendor_site_id = '||TO_CHAR(P_vendor_site_id)
        ||' Set_of_books_id = '||TO_CHAR(P_set_of_books_id)
        ||' Accounting_date = '||TO_CHAR(P_accounting_date)
        ||' Tax_id = '||TO_CHAR(P_tax_id)
         ||' Currency_code = '||P_invoice_currency_code);

   IF (debug_info = 'Get min_unit and precision') then
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO','No currency code for this invoice');
     APP_EXCEPTION.RAISE_EXCEPTION;
   elsif(debug_info ='Get period name') then
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO','the GL_date(sysdate) is not in an open period');
     APP_EXCEPTION.RAISE_EXCEPTION;
   else
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
     APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
 END IF;

 WHEN OTHERS then

   IF ((SQLCODE <> -20001) OR ((SQLCODE <> -20002))) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);

      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   END IF;
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
        'Invoice_date = '||TO_CHAR(P_invoice_date)
        ||' Invoice_amount = '||TO_CHAR(P_invoice_amount)
        ||' Vendor_id = '||TO_CHAR(P_vendor_id)
        ||' Vendor_site_id = '||TO_CHAR(P_vendor_site_id)
        ||' Set_of_books_id = '||TO_CHAR(P_set_of_books_id)
        ||' Accounting_date = '||TO_CHAR(P_accounting_date)
        ||' Tax_id = '||TO_CHAR(P_tax_id)
         ||' Currency_code = '||P_invoice_currency_code);
     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_rec_inv_get_info;


/*======================================================================
 Private Procedure: Insert new AP_BATCHES lines

 Insert New Batch line IF the batch name is new

========================================================================*/
PROCEDURE ap_rec_inv_insert_ap_batches(
    P_batch_name             IN            VARCHAR2,
    P_batch_control_flag     IN            VARCHAR2,
    P_invoice_currency_code  IN            VARCHAR2,
    P_payment_currency_code  IN            VARCHAR2,
    P_last_update_date       IN            DATE,
    P_last_updated_by        IN            NUMBER,
    P_batch_id                  OUT NOCOPY NUMBER,
    P_calling_sequence       IN            VARCHAR2,
    P_org_id                 IN            NUMBER) IS

current_calling_sequence      VARCHAR2(2000);
debug_info                    VARCHAR2(100);
C_batch_id                    NUMBER;
C_batch_date                  DATE;
C_old_batch_flag              VARCHAR2(20);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'ap_rec_inv_insert_ap_batches<-'
    ||P_calling_sequence;

  ---------------------------------------------
  -- Return IF batch control flag is N
  ---------------------------------------------
  IF (nvl(P_batch_control_flag,'N') <> 'Y') then
    RETURN;
  END IF;

  ---------------------------------------------
  -- Return IF batch_name was existed
  ---------------------------------------------
  debug_info := 'Check batch_name existance';

  BEGIN
    SELECT  'OLD BATCH',batch_id
    INTO    C_old_batch_flag, P_batch_id
    FROM    ap_batches_all
    WHERE   batch_name = P_batch_name;

    IF (C_old_batch_flag = 'OLD BATCH') then
      RETURN;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  ---------------------------------------------
  -- Get New batch_id and Batch_date
  ---------------------------------------------
  debug_info := 'Get New batch_id and batch_date';

  --Modified sysdate as to_date(to_char(sysdate,'MM/DD/YYYY'), 'MM/DD/YYYY')
  --for the bug 7383201/7371814

  SELECT  ap_batches_s.nextval, to_date(to_char(sysdate,'MM/DD/YYYY'), 'MM/DD/YYYY')
  INTO    C_batch_id, C_batch_date
  FROM    sys.dual;

  ---------------------------------------------
  -- Insert ap_batches
  ---------------------------------------------
  debug_info := 'Insert ap_batches';

  INSERT INTO ap_batches_all
             (batch_id,
             batch_name,
             batch_date,
             last_update_date,
             last_updated_by,
             invoice_currency_code,
             payment_currency_code,
             creation_date,
             created_by,
             org_id)
    VALUES(C_batch_id,
             P_batch_name,
             C_batch_date,
             P_last_update_date,
             P_last_updated_by,
             P_invoice_currency_code,
             P_payment_currency_code,
             P_last_update_date,
             P_last_updated_by,
             P_Org_Id);
   --
   -- Transfer batch_id
   --
   P_batch_id := C_batch_id;


EXCEPTION
 WHEN OTHERS then

   IF ((SQLCODE <> -20001) AND ((SQLCODE <> -20002))) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
    'P_batch_name = '||P_batch_name
    ||'P_batch_control_flag = '|| P_batch_control_flag
    ||'P_invoice_currency_code = '||P_invoice_currency_code
    ||'P_payment_currency_code = '||P_payment_currency_code
    ||'P_last_update_date = '||TO_CHAR(P_last_update_date)
    ||'P_last_updated_by = '||TO_CHAR(P_last_updated_by));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   END IF;

   APP_EXCEPTION.RAISE_EXCEPTION;

END ap_rec_inv_insert_ap_batches;



/*==========================================================================
 Private Procedure: ap_rec_inv_insert_ap_invoices

 Insert AP_INVOICES for these recurring invoices
 *=====================================================================*/
PROCEDURE ap_rec_inv_insert_ap_invoices(
    P_batch_id              IN            NUMBER,
    P_last_update_date      IN            DATE,
    P_last_updated_by       IN            NUMBER,
    P_invoice_currency_code IN            VARCHAR2,
    P_payment_currency_code IN            VARCHAR2,
    P_base_currency_code    IN            VARCHAR2,
    P_invoice_id            IN OUT NOCOPY NUMBER,
    P_invoice_num           IN            VARCHAR2,
    P_invoice_amount        IN            NUMBER,
    P_vendor_id             IN            NUMBER,
    P_vendor_site_id        IN            NUMBER,
    P_invoice_date          IN            DATE,
    P_description           IN            VARCHAR2,
    P_tax_name              IN            VARCHAR2,
    P_tax_amount            IN            NUMBER,
    P_terms_id              IN            NUMBER,
    P_pay_group_lookup_code IN            VARCHAR2,
    P_set_of_books_id       IN            NUMBER,
    P_accts_pay_ccid        IN            NUMBER,
    P_payment_cross_rate    IN            NUMBER,
    P_exchange_date         IN            DATE,
    P_exchange_rate_type    IN            VARCHAR2,
    P_exchange_rate         IN            NUMBER,
    P_invoice_base_amount   IN            NUMBER,
    P_recurring_payment_id  IN            NUMBER,
    P_terms_date            IN            DATE,
    P_doc_sequence_id       IN            NUMBER,
    P_doc_sequence_value    IN            NUMBER,
    P_doc_category_code     IN            VARCHAR2,
    P_exclusive_payment_flag IN           VARCHAR2,
    P_awt_group_id          IN            NUMBER,
    P_pay_awt_group_id      IN            NUMBER,--bug6639866
    P_distribution_set_id   IN            NUMBER,
    P_accounting_date       IN            DATE,
 -- P_ussgl_txn_code        IN            VARCHAR2, - Bug 4277744
    P_attribute1            IN            VARCHAR2,
    P_attribute2            IN            VARCHAR2,
    P_attribute3            IN            VARCHAR2,
    P_attribute4            IN            VARCHAR2,
    P_attribute5            IN            VARCHAR2,
    P_attribute6            IN            VARCHAR2,
    P_attribute7            IN            VARCHAR2,
    P_attribute8            IN            VARCHAR2,
    P_attribute9            IN            VARCHAR2,
    P_attribute10           IN            VARCHAR2,
    P_attribute11           IN            VARCHAR2,
    P_attribute12           IN            VARCHAR2,
    P_attribute13           IN            VARCHAR2,
    P_attribute14           IN            VARCHAR2,
    P_attribute15           IN            VARCHAR2,
    P_attribute_category    IN            VARCHAR2,
    P_calling_sequence      IN            VARCHAR2,
    P_Org_Id                IN            NUMBER,
    P_Requester_Id          IN            NUMBER,
    P_Tax_Control_Amount    IN		  NUMBER,
    P_Trx_Business_Category IN		  VARCHAR2,
    P_User_Defined_Fisc_Class IN	  VARCHAR2,
    P_Taxation_Country      IN		  VARCHAR2,
    P_Legal_Entity_Id	    IN		  NUMBER,
    p_PAYMENT_METHOD_CODE   in            varchar2,
    p_PAYMENT_REASON_CODE   in            varchar2,
    p_remittance_message1   in            varchar2,
    p_remittance_message2   in            varchar2,
    p_remittance_message3   in            varchar2,
    p_bank_charge_bearer           in            varchar2,
    p_settlement_priority          in            varchar2,
    p_payment_reason_comments      in            varchar2,
    p_delivery_channel_code        in            varchar2,
    p_external_bank_account_id     in            number,
    p_party_id			   in		 number,
    p_party_site_id		   in		 number,
    /* bug 4931755. Exclude Tax From Discount */
    p_disc_is_inv_less_tax_flag    in            varchar2,
    p_exclude_freight_from_disc    in            varchar2,
    P_REMIT_TO_SUPPLIER_NAME   in      VARCHAR2,
    P_REMIT_TO_SUPPLIER_ID     in      NUMBER,
    P_REMIT_TO_SUPPLIER_SITE    in     VARCHAR2,
    P_REMIT_TO_SUPPLIER_SITE_ID   in   NUMBER,
    P_RELATIONSHIP_ID       in         NUMBER
) IS

C_invoice_id                    NUMBER;
debug_info                      VARCHAR2(100);
current_calling_sequence        VARCHAR2(2000);
C_source            ap_lookup_codes.displayed_field%TYPE;
l_ready_for_wf                  VARCHAR2(1);
l_use_workflow_flag             VARCHAR2(1);
l_wfapproval_status             VARCHAR2(50);
l_approval_required_flag        VARCHAR2(1);
l_pay_curr_invoice_amount       NUMBER; --4392543

BEGIN
  -- Update the calling sequence
  --
    current_calling_sequence :=
      'ap_rec_inv_insert_ap_invoices<-'||P_calling_sequence;


  -------------------------------------------
  -- get new invoice_id
  -------------------------------------------
  debug_info := 'get new invoice_id';
  SELECT  ap_invoices_s.nextval
    INTO  C_invoice_id
    FROM  sys.dual;

  ---------------------------------------
  -- Get WFApproval option -- not done in get_info
    --because need recurring_payment_id
  ---------------------------------------
  debug_info := 'Get WF Approval option';
  BEGIN
  SELECT approval_workflow_flag
    INTO l_use_workflow_flag
  FROM ap_system_parameters;

  SELECT approval_required_flag
    INTO l_approval_required_flag
  FROM ap_recurring_payments_all
  WHERE recurring_payment_id = P_recurring_payment_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

   IF nvl(l_use_workflow_flag,'N') = 'Y' THEN
        IF nvl(l_approval_required_flag,'N') = 'Y'THEN
                l_wfapproval_status := 'REQUIRED';
        ELSE
                l_wfapproval_status := 'NOT REQUIRED';
        END IF;
   ELSE
        l_wfapproval_status := 'NOT REQUIRED';
   END IF;

   l_ready_for_wf := 'Y'; --bug 2333796

   --4392543
   l_pay_curr_invoice_amount:=
              ap_utilities_pkg.ap_round_currency(
                        (P_invoice_amount * nvl( P_payment_cross_rate,1)),
                        P_payment_currency_code);



  -------------------------------------------
  -- Insert ap_invoices
  -------------------------------------------
  debug_info := 'Insert ap_invoices';
  INSERT INTO ap_invoices_all(
    invoice_id,
    last_update_date,
    last_updated_by,
    last_update_login, -- 2888897
    vendor_id,
    invoice_num,
    invoice_amount,
    vendor_site_id,
    amount_paid,
    discount_amount_taken,
    invoice_date,
    invoice_type_lookup_code,
    description,
    batch_id,
    amount_applicable_to_discount,
    tax_amount,
    terms_id,
    approved_amount,
    approval_status,
    approval_description,
    pay_group_lookup_code,
    set_of_books_id,
    accts_pay_code_combination_id,
    invoice_currency_code,
    payment_currency_code,
    payment_cross_rate,
    exchange_date,
    exchange_rate_type,
    exchange_rate,
    base_amount,
    payment_status_flag,
    posting_status,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    creation_date,
    created_by,
    vendor_prepay_amount,
    prepay_flag,
    recurring_payment_id,
    vat_code,
    terms_date,
    source,
    doc_sequence_id,
    doc_sequence_value,
    doc_category_code,
    exclusive_payment_flag,
    awt_group_id,
    pay_awt_group_id,--bug6639866
    gl_date,
    wfapproval_status,
    approval_ready_flag,
 -- ussgl_transaction_code, - Bug 4277744
    org_Id,
    requester_id,
    distribution_set_id,
    control_amount,
    trx_business_category,
    user_defined_fisc_class,
    taxation_country,
    legal_entity_id,
    PAYMENT_METHOD_CODE,
    PAYMENT_REASON_CODE,
    remittance_message1,
    remittance_message2,
    remittance_message3,
    bank_charge_bearer,
    settlement_priority,
    payment_reason_comments,
    delivery_channel_code,
    external_bank_account_id,
    party_id,
    party_site_id,
    pay_curr_invoice_amount, -- 4992543
    disc_is_inv_less_tax_flag,  -- 4931755
    exclude_freight_from_discount,  -- 4931755
    REMIT_TO_SUPPLIER_NAME,
    REMIT_TO_SUPPLIER_ID,
    REMIT_TO_SUPPLIER_SITE,
    REMIT_TO_SUPPLIER_SITE_ID,
    RELATIONSHIP_ID
    )
   VALUES(
    C_invoice_id,
    P_last_update_date,
    P_last_updated_by,
    TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')), -- 2888897
    P_vendor_id,
    P_invoice_num,
    P_invoice_amount,
    P_vendor_site_id,
    0,
    0,
    P_invoice_date,
    DECODE(SIGN(P_invoice_amount),
           -1, 'CREDIT', 'STANDARD'),
    P_description,
    P_batch_id,
    P_invoice_amount,
    P_tax_amount,
    P_terms_id,
    NULL,
    NULL,
    NULL,
    P_pay_group_lookup_code,
    P_set_of_books_id,
    P_accts_pay_ccid,
    P_invoice_currency_code,
    P_payment_currency_code,
    P_payment_cross_rate,
    Decode(P_exchange_date, NULL,
           decode(P_base_currency_code, P_invoice_currency_code,
                  NULL,
                  NVL(P_accounting_date,P_invoice_date)
                  ), P_exchange_date),
    P_exchange_rate_type,
    P_exchange_rate,
    P_invoice_base_amount,
    'N',
    NULL,
    P_attribute_category,
    P_attribute1,
    P_attribute2,
    P_attribute3,
    P_attribute4,
    P_attribute5,
    P_attribute6,
    P_attribute7,
    P_attribute8,
    P_attribute9,
    P_attribute10,
    P_attribute11,
    P_attribute12,
    P_attribute13,
    P_attribute14,
    P_attribute15,
    P_last_update_date,
    P_last_updated_by,
     0,
    'N',
    P_recurring_payment_id,
    P_tax_name,
    P_terms_date,
    'RECURRING INVOICE', -- 1951771 Use RECURRING INVOICE
    P_doc_sequence_id,
    P_doc_sequence_value,
    P_doc_category_code,
    P_exclusive_payment_flag,
    P_awt_group_id,
    P_pay_awt_group_id,--bug6639866
    P_accounting_date,
    l_wfapproval_status,
    l_ready_for_wf,
 -- P_ussgl_txn_code, - Bug 4277744
    P_Org_Id,
    P_Requester_Id,
    P_Distribution_Set_Id,
    P_Tax_Control_Amount,
    P_Trx_Business_Category,
    P_User_Defined_Fisc_Class,
    P_Taxation_Country,
    P_Legal_Entity_Id,
    p_PAYMENT_METHOD_CODE,
    p_PAYMENT_REASON_CODE,
    p_remittance_message1,
    p_remittance_message2,
    p_remittance_message3,
    p_bank_charge_bearer,
    p_settlement_priority,
    p_payment_reason_comments,
    p_delivery_channel_code,
    p_external_bank_account_id,
    p_party_id,
    p_party_site_id,
    l_pay_curr_invoice_amount, --4392543
    /* bug 4931755. Exclude Tax From Discount */
    p_disc_is_inv_less_tax_flag,
    p_exclude_freight_from_disc,
    P_REMIT_TO_SUPPLIER_NAME,
    P_REMIT_TO_SUPPLIER_ID,
    P_REMIT_TO_SUPPLIER_SITE,
    P_REMIT_TO_SUPPLIER_SITE_ID,
    P_RELATIONSHIP_ID
    );

  --Bug 4539462 DBI logging
  AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'I',
               p_key_value1 => C_invoice_id,
                p_calling_sequence => current_calling_sequence);

  P_invoice_id := C_invoice_id;

EXCEPTION
 WHEN OTHERS then

   IF ((SQLCODE <> -20001) or ((SQLCODE <> -20002)) ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' batch_id = '||TO_CHAR(p_batch_id)
        ||' c_source  = '||c_source
        ||' P_invoice_id  = '||TO_CHAR(C_invoice_id)
        ||' P_tax_name = '||P_tax_name
        ||' P_tax_amount = '||TO_CHAR(P_tax_amount)
        ||' P_accts_pay_ccid = '||TO_CHAR(P_accts_pay_ccid)
        ||' P_invoice_base_amount = '||TO_CHAR(P_invoice_base_amount)
        ||' P_recurring_payment_id = '||TO_CHAR(P_recurring_payment_id)
        ||' P_exclusive_payment_flag = '||P_exclusive_payment_flag
        ||' P_awt_group_id = '||TO_CHAR(P_awt_group_id)
	||' P_pay_awt_group_id = '||TO_CHAR(P_pay_awt_group_id)  --bug6639866
        ||' Invoice_date = '||TO_CHAR(P_invoice_date)
        ||' accounting_date = '||TO_CHAR(P_accounting_date)
        ||' Vendor_id = '||TO_CHAR(P_vendor_id)
        ||' Vendor_site_id = '||TO_CHAR(P_vendor_site_id)
        ||' Invoice_num = '||P_invoice_num
        ||' Invoice Amount = '||TO_CHAR(P_invoice_amount)
        ||' P_doc_category_code = '||P_doc_category_code
        ||' Doc_sequence_value = '||TO_CHAR(P_doc_sequence_value)
        ||' Doc_sequence_id = '||TO_CHAR(P_doc_sequence_id)
        ||' Pay_group_lookup_code = '||P_pay_group_lookup_code
        ||' Invoice_currency_code = '||P_invoice_currency_code
        ||' Payment_currency_code = '||P_payment_currency_code
        ||' Base_currency_code = '||P_base_currency_code
        ||' Terms_date = '||TO_CHAR(P_terms_date)
        ||' Terms_id = '||TO_CHAR(P_terms_id)
        ||' Payment_cross_rate = '||TO_CHAR(P_payment_cross_rate)
        ||' Exchange Rate = '||TO_CHAR(P_exchange_rate)
        ||' Exchange Rate Type = '||P_exchange_rate_type
        ||' Exchange Date = '||TO_CHAR(P_exchange_date)
        ||' Set 0f books id = '||TO_CHAR(P_set_of_books_id)
        ||' Last_updated_by = '||TO_CHAR(P_last_updated_by)
        ||' Last_updated_date = '||TO_CHAR(P_last_update_date));

     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_rec_inv_insert_ap_invoices;



/*======================================================================
 Pubilc Function: Get Next available period Name

 The FUNCTION accept following parameter:

  +---------------------------------------------------------------------+
  | Variable            | NULL? | Type        | Description        |
  +=====================================================================+
  | P_period_type      | No    | VARCHAR2    | period_type        |
  +---------------------------------------------------------------------+
  | P_current_period    |    |        |            |
  |  _name          | No    | VARCHAR2    | Current Period_name    |
  +---------------------------------------------------------------------+


  There are 3 output parameter:
  +---------------------------------------------------------------------+
  | Variable            | NULL? | Type        | Description        |
  +=====================================================================+
  | P_next_period_name    | No    | VARCHAR2    | Next availbale period |
  |            |    |        | name            |
  +---------------------------------------------------------------------+
  | P_next_period_year  |    | NUMBER    | Period year for the   |
  |             | No    |         | new period        |
  +---------------------------------------------------------------------+
  | P_next_period_num    | No    | NUMBER    | Next Period_num     |
  +---------------------------------------------------------------------+


========================================================================*/
PROCEDURE ap_get_next_period(
    P_period_type         IN            VARCHAR2,
    P_current_period_name IN            VARCHAR2,
    P_next_period_name       OUT NOCOPY VARCHAR2,
    P_next_period_num        OUT NOCOPY NUMBER,
    P_next_period_year       OUT NOCOPY NUMBER,
    P_calling_sequence    IN            VARCHAR2) IS

current_calling_sequence      VARCHAR2(2000);
debug_info                    VARCHAR2(100);
C_current_period_num          NUMBER;
C_period_year                 NUMBER;
C_next_period_num             NUMBER;

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'ap_get_next_period<-'
                              ||P_calling_sequence;

  ---------------------------------------------
  -- Get the current period_num and period_year
  ---------------------------------------------
  debug_info := 'Get the current period_num and period_year';
  SELECT period_num, period_year
    INTO C_current_period_num, C_period_year
    FROM ap_other_periods
   WHERE period_name = P_current_period_name
     AND module = 'RECURRING PAYMENTS'
     AND period_type = P_period_type;

  ----------------------------------------------------------
  -- Get the Next period_num
  ----------------------------------------------------------
  BEGIN
  debug_info := 'Get next period_num';
  SELECT min(period_num)
    INTO C_next_period_num
    FROM ap_other_periods
   WHERE period_year = C_period_year
     AND to_number(period_num) > C_current_period_num
     AND module = 'RECURRING PAYMENTS'
     AND period_type = P_period_type;
  EXCEPTION
   WHEN NO_DATA_FOUND then
   NULL;
  END;

  -----------------------------------------------------------------
  -- Get the Next period_num IF there's no more period in this year
  -----------------------------------------------------------------
  IF (C_next_period_num IS NULL) then
   BEGIN
    debug_info := 'Get next year period_num';
    SELECT min(period_num), C_period_year + 1
      INTO C_next_period_num, C_period_year
      FROM ap_other_periods
     WHERE period_year = C_period_year + 1
       AND module = 'RECURRING PAYMENTS'
       AND period_type = P_period_type;
   EXCEPTION
    WHEN NO_DATA_FOUND then
    NULL;
   END;

 END IF;

  ----------------------------------------------------------
  -- Get the Next period_name
  ----------------------------------------------------------
  IF (C_next_period_num IS NULL) THEN
    P_next_period_name := '';
    P_next_period_num  := '';
    P_next_period_year := '';
    RETURN;
  END IF;

  ----------------------------------------------------------
  -- Get the Next period_name
  ----------------------------------------------------------
  debug_info := 'Get next period name';
  SELECT period_name
    INTO P_next_period_name
    FROM ap_other_periods
   WHERE period_year = C_period_year
     AND period_num = C_next_period_num
     AND period_type = P_period_type
     AND module = 'RECURRING PAYMENTS';

  ----------------------------------------------------------
  -- Get P_next_period_year P_next_period_num
  ----------------------------------------------------------
  debug_info := 'Get next period_num and period_year';

  P_next_period_num := C_next_period_num;
  P_next_period_year := C_period_year;


EXCEPTION

 WHEN NO_DATA_FOUND then
   IF (debug_info = 'Get next period_num') then
    NULL;

   ELSIF (debug_info = 'Get next year period_num') then
    NULL;
   else

   FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
   FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
   FND_MESSAGE.SET_TOKEN('PARAMETERS','Period_type = '||P_period_type
    ||' Current period name = '||P_current_period_name);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
     APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

 WHEN OTHERS then

   IF (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Period_type = '||P_period_type
    ||' Current period name = '||P_current_period_name);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_get_next_period;


/*======================================================================
 Pubilc Function: Calculate next payment amount

 The FUNCTION accept following parameter:

  +---------------------------------------------------------------------+
  | Variable            | NULL? | Type        | Description             |
  +=====================================================================+



  There are 2 output parameter:
  +---------------------------------------------------------------------+
  | Variable            | NULL? | Type        | Description             |
  +=====================================================================+
  | P_next_amount       | No    | NUMBER      | the next available      |
  |                     |       |             | amount                  |
  +---------------------------------------------------------------------+
  | P_next_amount_      | No    | NUMBER      | Next amount remaining   |
  |   exclude_special   |       |             | same IF in special      |
  |                     |       |             | period                  |
  +---------------------------------------------------------------------+


========================================================================*/

PROCEDURE ap_get_next_payment(
    P_next_period_name            IN            VARCHAR2,
    P_special_period_name1        IN            VARCHAR2,
    P_special_payment_amount1     IN            NUMBER,
    P_special_period_name2        IN            VARCHAR2,
    P_special_payment_amount2     IN            NUMBER,
    P_increment_percent           IN            NUMBER,
    P_currency_code               IN            VARCHAR2,
    P_current_amount              IN            NUMBER,
    P_next_amount                    OUT NOCOPY NUMBER,
    P_next_amount_exclude_special    OUT NOCOPY NUMBER,
    P_calling_sequence            IN            VARCHAR2) IS

current_calling_sequence      VARCHAR2(2000);
debug_info                    VARCHAR2(100);
C_next_amount                 NUMBER;

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'ap_get_next_payment<-'||P_calling_sequence;

  ---------------------------------------------
  -- Get next payment
  ---------------------------------------------
  debug_info := 'Get Next payment';

  IF (P_next_period_name = P_special_period_name1) then
    P_next_amount := P_special_payment_amount1;
    P_next_amount_exclude_special := P_current_amount;

  ELSIF (P_next_period_name = P_special_period_name2) then
    P_next_amount := P_special_payment_amount2;
    P_next_amount_exclude_special := P_current_amount;

  else
    C_next_amount := ap_utilities_pkg.ap_round_currency(
              P_current_amount * (1+ (NVL(P_increment_percent, 0)/100))
             , P_currency_code);
    P_next_amount := C_next_amount;
    P_next_amount_exclude_special := C_next_amount;

  END IF;


EXCEPTION

 WHEN OTHERS then

   IF (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
    'Increment_percent = '||TO_CHAR(P_increment_percent)
    ||' Next period name = '||P_next_period_name);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_get_next_payment;



/* ======================================================================
 Pubilc Function: Get the first_amount from control_total, or vice versa

 The FUNCTION accept following parameter:

  +---------------------------------------------------------------------+
  | Variable            | NULL? | Type        | Description        |
  +=====================================================================+
  ...
  +---------------------------------------------------------------------+
  | P_amount_source_flag| No    | VARCHAR2    | 'TOTAL' or "FIRST'     |
  +---------------------------------------------------------------------+
  | P_number_of_regular | No    | NUMBER    | Number of periods    |
  | _periods        |    |        | exclude special period|
  +---------------------------------------------------------------------+


  There are 3 output parameter:
  +---------------------------------------------------------------------+
  | Variable            | NULL? | Type        | Description        |
  +=====================================================================+
  | P_first_amount    | Maybe    | NUMBER    | get first amount IF    |
  |            |    |        | P_amount_source_flag     |
  |            |    |        | = 'TOTAL'
  +---------------------------------------------------------------------+
  | P_control_total      | Maybe    | NUMBER    |  get first amount IF  |
  |             |     |         |  P_amount_source_flag    |
  |            |    |        | = 'FIRST'        |
  +---------------------------------------------------------------------+

======================================================================== */

PROCEDURE ap_get_first_amount(
    P_first_period_name         IN            VARCHAR2,
    P_special_period_name1      IN            VARCHAR2,
    P_special_payment_amount1   IN            NUMBER,
    P_special_period_name2      IN            VARCHAR2,
    P_special_payment_amount2   IN            NUMBER,
    P_number_of_regular_periods IN            NUMBER,
    P_amount_source_flag        IN            VARCHAR2,
    P_increment_percent         IN            NUMBER,
    P_currency_code             IN            VARCHAR2,
    P_first_amount              IN OUT NOCOPY NUMBER,
    P_control_total             IN OUT NOCOPY NUMBER,
    P_calling_sequence          IN            VARCHAR2) IS

current_calling_sequence  VARCHAR2(2000);
debug_info                VARCHAR2(100);
i                         INTEGER;
C_total_percentage        NUMBER := 1;
C_percentage_factor       NUMBER := 1;
C_first_amount            NUMBER;
C_total                   NUMBER;

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'ap_get_first_amount<-'||P_calling_sequence;

  ---------------------------------------------
  -- Split case : calculate (i)  first_amount
  --                (ii) control total
  ---------------------------------------------

  IF (P_amount_source_flag = 'TOTAL') then
  ---------------------------------------------
  -- Case i: calculate first_amount
  ---------------------------------------------
      ---------------------------------------------
      -- Get total pencentage using NUMBER_of_regular_periods
      ---------------------------------------------
      debug_info := 'Get total_percentage';
      FOR i in 1..(P_number_of_regular_periods - 1)
      LOOP

        C_percentage_factor := C_percentage_factor *
                (1+ (NVL(P_increment_percent, 0)/100));
        C_total_percentage := C_total_percentage + C_percentage_factor;

      END LOOP;
      ---------------------------------------------
      -- Get first amount
      ---------------------------------------------
      debug_info := 'Get first amount';
      IF (P_first_period_name = P_special_period_name1) then
       C_first_amount := (P_control_total - NVL(P_special_payment_amount1,0)
                - NVL(P_special_payment_amount2,0))
               / C_total_percentage;

      ELSIF (P_first_period_name = P_special_period_name2) then
         C_first_amount := P_special_payment_amount2;

      else
       C_first_amount := (P_control_total - NVL(P_special_payment_amount1,0)
                - NVL(P_special_payment_amount2,0))
               / C_total_percentage;

      END IF;

      P_first_amount := ap_utilities_pkg.ap_round_currency(
              C_first_amount , P_currency_code);


  ELSIF (P_amount_source_flag = 'FIRST') then
  ---------------------------------------------
  -- Case ii: calculate control total
  ---------------------------------------------
      ---------------------------------------------
      -- Get total pencentage using NUMBER_of_regular_periods
      ---------------------------------------------
      debug_info := 'Get total_percentage';
      FOR i in 1..(P_number_of_regular_periods - 1) LOOP

        C_percentage_factor := C_percentage_factor *
                (1+ (NVL(P_increment_percent, 0)/100));
    C_total_percentage := C_total_percentage + C_percentage_factor;

      END LOOP;

      ---------------------------------------------
      -- Get control total
      ---------------------------------------------
      debug_info := 'Get control total';
      C_total := ap_utilities_pkg.ap_round_currency(
            (P_first_amount * C_total_percentage),P_currency_code);

      P_control_total := C_total + NVL(P_special_payment_amount1,0) +
                   NVL(P_special_payment_amount2,0);

  END IF;


EXCEPTION

 WHEN OTHERS then

   IF (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
    'first_period_name = '||P_first_period_name
    ||' P_special_period_name1 = '||P_special_period_name1
    ||' P_special_payment_amount1 = '||TO_CHAR(P_special_payment_amount1)
    ||' P_special_period_name2 = '||P_special_period_name2
    ||' P_special_payment_amount2 = '||TO_CHAR(P_special_payment_amount2)
    ||' P_number_of_regular_periods = '||TO_CHAR(P_number_of_regular_periods)
    ||' P_amount_source_flag = '||P_amount_source_flag
    ||' P_increment_percent = '||TO_CHAR(P_increment_percent)
    ||' P_currency_code = '||P_currency_code);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_get_first_amount;


Procedure Insert_Invoice_Line(
	    P_Invoice_Id 	      IN     NUMBER,
            P_Invoice_line_number        OUT NOCOPY NUMBER,
            P_Invoice_Date            IN     DATE,
            P_Line_Type_Lookup_Code   IN     VARCHAR2,
            P_description             IN     VARCHAR2,
       	    P_Po_Line_Location_Id     IN     NUMBER   DEFAULT NULL,
	    P_Amount		      IN     NUMBER,
	    P_Quantity_Invoiced	      IN     NUMBER   DEFAULT NULL,
	    P_Unit_Price	      IN     NUMBER   DEFAULT NULL,
            P_set_of_books_id         IN     NUMBER,
            P_exchange_rate           IN     NUMBER,
            P_base_currency_code      IN     VARCHAR2,
            P_accounting_date         IN     DATE,
            P_awt_group_id            IN     NUMBER,
	    P_pay_awt_group_id        IN     NUMBER,--bug6639866
            P_gl_period_name          IN     VARCHAR2,
            P_income_tax_region       IN     VARCHAR2,
            P_transfer_flag           IN     VARCHAR2,
            P_approval_workflow_flag  IN     VARCHAR2,
            P_inventory_org_id        IN     NUMBER,
            P_asset_bt_code           IN     VARCHAR2,
      	    P_Tax_Control_Amount      IN     NUMBER   DEFAULT NULL,
      	    P_Primary_Intended_Use    IN     VARCHAR2 DEFAULT NULL,
      	    P_Product_Fisc_Classification IN VARCHAR2 DEFAULT NULL,
      	    P_User_Defined_Fisc_Class IN     VARCHAR2 DEFAULT NULL,
      	    P_Trx_Business_Category   IN     VARCHAR2 DEFAULT NULL,
            P_retained_amount         IN     NUMBER   DEFAULT NULL, /*bug 5228301 */
            P_match_type              IN     VARCHAR2, /*bug 5228301 */
	    P_tax_classification_code IN     VARCHAR2,
	    P_PRODUCT_TYPE	      IN     VARCHAR2,   --Bug#8640313
            P_PRODUCT_CATEGORY	      IN     VARCHAR2,   --Bug#8640313
            P_Calling_Sequence	      IN     VARCHAR2) IS

 current_calling_sequence	VARCHAR2(2000);
 debug_info			VARCHAR2(100);
 l_User_Id                      number;
 l_Login_Id                     number;
 l_invoice_line_number          AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE;

BEGIN

   current_calling_sequence := 'Insert_Invoice_Line<-'||P_calling_sequence;

   l_user_id  := FND_PROFILE.VALUE('USER_ID');
   l_login_id := FND_PROFILE.VALUE('LOGIN_ID');

   debug_info := 'Get line NUMBER for generation of line';
   l_invoice_line_number := AP_INVOICES_PKG.get_max_line_number(P_invoice_id) + 1;

   debug_info := 'Inserting Item Line Matched to a PO';
	INSERT INTO AP_INVOICE_LINES (
	      INVOICE_ID,
	      LINE_NUMBER,
	      LINE_TYPE_LOOKUP_CODE,
	      REQUESTER_ID,
	      DESCRIPTION,
	      LINE_SOURCE,
	      ORG_ID,
	      INVENTORY_ITEM_ID,
	      ITEM_DESCRIPTION,
	      SERIAL_NUMBER,
	      MANUFACTURER,
	      MODEL_NUMBER,
	      GENERATE_DISTS,
	      MATCH_TYPE,
	      DISTRIBUTION_SET_ID,
	      ACCOUNT_SEGMENT,
	      BALANCING_SEGMENT,
	      COST_CENTER_SEGMENT,
	      OVERLAY_DIST_CODE_CONCAT,
	      DEFAULT_DIST_CCID,
	      PRORATE_ACROSS_ALL_ITEMS,
	      LINE_GROUP_NUMBER,
	      ACCOUNTING_DATE,
	      PERIOD_NAME,
	      DEFERRED_ACCTG_FLAG,
	      DEF_ACCTG_START_DATE,
	      DEF_ACCTG_END_DATE,
	      DEF_ACCTG_NUMBER_OF_PERIODS,
	      DEF_ACCTG_PERIOD_TYPE,
	      SET_OF_BOOKS_ID,
	      AMOUNT,
	      BASE_AMOUNT,
	      ROUNDING_AMT,
	      QUANTITY_INVOICED,
	      UNIT_MEAS_LOOKUP_CODE,
	      UNIT_PRICE,
	      WFAPPROVAL_STATUS,
	   -- USSGL_TRANSACTION_CODE, - Bug 4277744
	      DISCARDED_FLAG,
	      ORIGINAL_AMOUNT,
	      ORIGINAL_BASE_AMOUNT,
	      ORIGINAL_ROUNDING_AMT,
	      CANCELLED_FLAG,
	      INCOME_TAX_REGION,
	      TYPE_1099,
	      STAT_AMOUNT,
	      PREPAY_INVOICE_ID,
	      PREPAY_LINE_NUMBER,
	      INVOICE_INCLUDES_PREPAY_FLAG,
	      CORRECTED_INV_ID,
	      CORRECTED_LINE_NUMBER,
	      PO_HEADER_ID,
	      PO_LINE_ID,
	      PO_RELEASE_ID,
	      PO_LINE_LOCATION_ID,
	      PO_DISTRIBUTION_ID,
	      RCV_TRANSACTION_ID,
	      FINAL_MATCH_FLAG,
	      ASSETS_TRACKING_FLAG,
	      ASSET_BOOK_TYPE_CODE,
	      ASSET_CATEGORY_ID,
	      PROJECT_ID,
	      TASK_ID,
	      EXPENDITURE_TYPE,
	      EXPENDITURE_ITEM_DATE,
	      EXPENDITURE_ORGANIZATION_ID,
	      PA_QUANTITY,
	      PA_CC_AR_INVOICE_ID,
	      PA_CC_AR_INVOICE_LINE_NUM,
	      PA_CC_PROCESSED_CODE,
	      AWARD_ID,
	      AWT_GROUP_ID,
	      PAY_AWT_GROUP_ID,--bug6639866
	      REFERENCE_1,
	      REFERENCE_2,
	      RECEIPT_VERIFIED_FLAG,
	      RECEIPT_REQUIRED_FLAG,
	      RECEIPT_MISSING_FLAG,
	      JUSTIFICATION,
	      EXPENSE_GROUP,
	      START_EXPENSE_DATE,
	      END_EXPENSE_DATE,
	      RECEIPT_CURRENCY_CODE,
	      RECEIPT_CONVERSION_RATE,
	      RECEIPT_CURRENCY_AMOUNT,
	      DAILY_AMOUNT,
	      WEB_PARAMETER_ID,
	      ADJUSTMENT_REASON,
	      MERCHANT_DOCUMENT_NUMBER,
	      MERCHANT_NAME,
	      MERCHANT_REFERENCE,
	      MERCHANT_TAX_REG_NUMBER,
	      MERCHANT_TAXPAYER_ID,
	      COUNTRY_OF_SUPPLY,
	      CREDIT_CARD_TRX_ID,
	      COMPANY_PREPAID_INVOICE_ID,
	      CC_REVERSAL_FLAG,
	      ATTRIBUTE_CATEGORY,
	      ATTRIBUTE1,
      	      ATTRIBUTE2,
      	      ATTRIBUTE3,
      	      ATTRIBUTE4,
      	      ATTRIBUTE5,
      	      ATTRIBUTE6,
      	      ATTRIBUTE7,
      	      ATTRIBUTE8,
      	      ATTRIBUTE9,
      	      ATTRIBUTE10,
      	      ATTRIBUTE11,
      	      ATTRIBUTE12,
      	      ATTRIBUTE13,
      	      ATTRIBUTE14,
      	      ATTRIBUTE15,
      	      /* GLOBAL_ATTRIBUTE_CATEGORY,
	      GLOBAL_ATTRIBUTE1,
      	      GLOBAL_ATTRIBUTE2,
      	      GLOBAL_ATTRIBUTE3,
      	      GLOBAL_ATTRIBUTE4,
      	      GLOBAL_ATTRIBUTE5,
      	      GLOBAL_ATTRIBUTE6,
      	      GLOBAL_ATTRIBUTE7,
       	      GLOBAL_ATTRIBUTE8,
      	      GLOBAL_ATTRIBUTE9,
       	      GLOBAL_ATTRIBUTE10,
      	      GLOBAL_ATTRIBUTE11,
      	      GLOBAL_ATTRIBUTE12,
      	      GLOBAL_ATTRIBUTE13,
      	      GLOBAL_ATTRIBUTE14,
      	      GLOBAL_ATTRIBUTE15,
      	      GLOBAL_ATTRIBUTE16,
      	      GLOBAL_ATTRIBUTE17,
      	      GLOBAL_ATTRIBUTE18,
      	      GLOBAL_ATTRIBUTE19,
      	      GLOBAL_ATTRIBUTE20, */
      	      CREATION_DATE,
      	      CREATED_BY,
      	      LAST_UPDATED_BY,
      	      LAST_UPDATE_DATE,
      	      LAST_UPDATE_LOGIN,
      	      PROGRAM_APPLICATION_ID,
      	      PROGRAM_ID,
      	      PROGRAM_UPDATE_DATE,
      	      REQUEST_ID,
      	      CONTROL_AMOUNT,
      	      PRIMARY_INTENDED_USE,
      	      PRODUCT_FISC_CLASSIFICATION,
      	      USER_DEFINED_FISC_CLASS,
      	      TRX_BUSINESS_CATEGORY,
	      SHIP_TO_LOCATION_ID,
              RETAINED_AMOUNT, /*bug 5228301 */
              RETAINED_AMOUNT_REMAINING,
	      TAX_CLASSIFICATION_CODE,
	      PRODUCT_TYPE,        --Bug#8640313
              PRODUCT_CATEGORY)    --Bug#8640313
       SELECT P_INVOICE_ID,			--invoice_id
     	      L_INVOICE_LINE_NUMBER,		--invoice_line_number
     	      P_LINE_TYPE_LOOKUP_CODE,		--line_type_lookup_code
     	      NULL,                             --requester_id
    	      P_DESCRIPTION,	         	--description
     	      'AUTO INVOICE CREATION',		--line_source
    	      PLL.ORG_ID,			--org_id
    	      PLL.ITEM_ID,			--inventory_item_id
     	      PLL.ITEM_DESCRIPTION,		--item_description
     	      NULL,				--serial_number
     	      NULL,				--manufacturer
     	      NULL,				--model_number
     	      'D',				--generate_dists
     	      P_Match_Type,			--match_type  /* bug 5228301 */
     	      NULL,				--distribution_set_id
     	      NULL,				--account_segment
     	      NULL,				--balancing_segment
     	      NULL,				--cost_center_segment
     	      NULL,				--overlay_dist_code_concat
     	      --Bug6965650
     	      NULL,                             --default_dist_ccid
     	      'N',				--prorate_across_all_items
 	      NULL,				--line_group_number
 	      P_ACCOUNTING_DATE,		--accounting_date
 	      P_GL_PERIOD_NAME,			--period_name
 	      'N',				--deferred_acctg_flag
 	      NULL,				--def_acctg_start_date
 	      NULL,				--def_acctg_end_date
 	      NULL,				--def_acctg_number_of_periods
 	      NULL,				--def_acctg_period_type
 	      P_SET_OF_BOOKS_ID,		--set_of_books_id
 	      P_AMOUNT,				--amount
 	      AP_UTILITIES_PKG.Ap_Round_Currency(
                 NVL(P_AMOUNT, 0) * P_EXCHANGE_RATE,
               		 P_BASE_CURRENCY_CODE), --base_amount
 	      NULL,				--rounding_amount
 	      P_QUANTITY_INVOICED,		--quantity_invoiced
 	      PLL.UNIT_MEAS_LOOKUP_CODE,	--unit_meas_lookup_code
 	      P_UNIT_PRICE,			--unit_price
 	      decode(P_approval_workflow_flag,'Y'
	            ,'REQUIRED','NOT REQUIRED'),--wf_approval_status
          --  Removed for bug 4277744
 	  --  PLL.USSGL_TRANSACTION_CODE,	--ussgl_transaction_code
 	      'N',				--discarded_flag
 	      NULL,				--original_amount
 	      NULL,				--original_base_amount
 	      NULL,				--original_rounding_amt
 	      'N',				--cancelled_flag
 	      P_INCOME_TAX_REGION,		--income_tax_region
 	      PLL.TYPE_1099,			--type_1099
 	      NULL,				--stat_amount
 	      NULL,				--prepay_invoice_id
 	      NULL,				--prepay_line_number
 	      NULL,				--invoice_includes_prepay_flag
 	      NULL,				--corrected_inv_id
 	      NULL,				--corrected_line_number
 	      PLL.PO_HEADER_ID,			--po_header_id
 	      PLL.PO_LINE_ID,			--po_line_id
 	      PLL.PO_RELEASE_ID,		--po_release_id
 	      PLL.LINE_LOCATION_ID,		--po_line_location_id
 	      NULL,                             --po_distribution_id
    	      NULL,				--rcv_transaction_id
   	      'N',               		--final_match_flag
    	      'N',				--assets_tracking_flag
    	      P_asset_bt_code,   		--asset_book_type_code
    	      MSI.ASSET_CATEGORY_ID,		--asset_category_id
	      NULL,		                --project_id
	      NULL,	                	--task_id
 	      NULL,	                        --expenditure_type
     	      NULL,	                        --expenditure_item_date
 	      NULL,              		--expenditure_organization_id
 	      NULL,                             --pa_quantity
 	      NULL,				--pa_cc_ar_invoice_id
 	      NULL,				--pa_cc_ar_invoice_line_num
 	      NULL,				--pa_cc_processed_code
	      NULL,		                --award_id
 	      P_AWT_GROUP_ID,			--awt_group_id
	      P_PAY_AWT_GROUP_ID,               --pay_awt_group_id--bug6639866
 	      NULL,    	         		--reference_1
 	      NULL,				--reference_2
 	      NULL,				--receipt_verified_flag
 	      NULL,				--receipt_required_flag
 	      NULL,				--receipt_missing_flag
 	      NULL,				--justification
 	      NULL,				--expense_group
 	      NULL,				--start_expense_date
 	      NULL,				--end_expense_date
 	      NULL,				--receipt_currency_code
 	      NULL,				--receipt_conversion_rate
 	      NULL,				--receipt_currency_amount
 	      NULL,				--daily_amount
 	      NULL,				--web_parameter_id
 	      NULL,				--adjustment_reason
 	      NULL,				--merchant_document_number
 	      NULL,				--merchant_name
 	      NULL,				--merchant_reference
 	      NULL,				--merchant_tax_reg_number
 	      NULL,				--merchant_taxpayer_id
 	      NULL,				--country_of_supply
 	      NULL,				--credit_card_trx_id
 	      NULL,				--company_prepaid_invoice_id
 	      NULL,				--cc_reversal_flag
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute_category),''),--attribute_category
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute1),''),	--attribute1
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute2),''),	--attribute2
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute3),''),	--attribute3
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute4),''),	--attribute4
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute5),''),	--attribute5
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute6),''),	--attribute6
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute7),''),	--attribute7
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute8),''),	--attribute8
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute9),''),	--attribute9
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute10),''),	--attribute10
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute11),''),	--attribute11
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute12),''),	--attribute12
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute13),''),	--attribute13
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute14),''),	--attribute14
 	      NVL(DECODE(p_transfer_flag,'Y',PLL.attribute15),''),	--attribute15
 	      /* p_GLOBAL_ATTRIBUTE_CATEGORY,	--global_attribute_category
	       p_GLOBAL_ATTRIBUTE1,		--global_attribute1
      	       p_GLOBAL_ATTRIBUTE2,		--global_attribute2
	       p_GLOBAL_ATTRIBUTE3,		--global_attribute3
      	       p_GLOBAL_ATTRIBUTE4,		--global_attribute4
      	       p_GLOBAL_ATTRIBUTE5,		--global_attribute5
      	       p_GLOBAL_ATTRIBUTE6,		--global_attribute6
      	       p_GLOBAL_ATTRIBUTE7,		--global_attribute7
       	       p_GLOBAL_ATTRIBUTE8,		--global_attribute8
      	       p_GLOBAL_ATTRIBUTE9,		--global_attribute9
       	       p_GLOBAL_ATTRIBUTE10,		--global_attribute10
      	       p_GLOBAL_ATTRIBUTE11,		--global_attribute11
      	       p_GLOBAL_ATTRIBUTE12,		--global_attribute12
      	       p_GLOBAL_ATTRIBUTE13,		--global_attribute13
      	       p_GLOBAL_ATTRIBUTE14,		--global_attribute14
      	       p_GLOBAL_ATTRIBUTE15,		--global_attribute15
      	       p_GLOBAL_ATTRIBUTE16,		--global_attribute16
      	       p_GLOBAL_ATTRIBUTE17,		--global_attribute17
      	       p_GLOBAL_ATTRIBUTE18,		--global_attribute18
      	       p_GLOBAL_ATTRIBUTE19,		--global_attribute19
      	       p_GLOBAL_ATTRIBUTE20, */ 	--global_attribute20
      	       SYSDATE,				--creation_date
      	       l_USER_ID,			--created_by
      	       l_USER_ID,			--last_update_by
      	       SYSDATE,				--last_update_date
      	       l_LOGIN_ID,			--last_update_login
      	       NULL,				--program_application_id
	       NULL,				--program_id
      	       NULL,				--program_update_date
      	       NULL,  	      		       	--request_id
      	       P_TAX_CONTROL_AMOUNT,		--control_amount,
      	       P_PRIMARY_INTENDED_USE,	        --primary_intended_use
      	       P_PRODUCT_FISC_CLASSIFICATION,   --product_fisc_classification
      	       P_USER_DEFINED_FISC_CLASS,       --user_defined_fisc_class
      	       P_TRX_BUSINESS_CATEGORY,		--trx_business_category
	       PLL.SHIP_TO_LOCATION_ID,		--ship_to_location_id
               p_retained_amount,               --retained_amount /* bug 5228301 */
               (-1)*p_retained_amount,          --retained_amount_reamining
	       p_tax_classification_code,	--tax_classification_code
	       --Added below 2 columns forBug#8640313
	       P_PRODUCT_TYPE,	                --Product_type
               P_PRODUCT_CATEGORY	        --Product_category
 	  FROM PO_LINE_LOCATIONS_AP_V PLL,
 	       MTL_SYSTEM_ITEMS MSI
 	 WHERE PLL.LINE_LOCATION_ID = P_PO_LINE_LOCATION_ID
 	  AND  MSI.INVENTORY_ITEM_ID(+) = PLL.ITEM_ID
 	  AND  MSI.ORGANIZATION_ID(+) = P_INVENTORY_ORG_ID;
       --
       P_invoice_line_number := l_invoice_line_number;
       --
EXCEPTION

   WHEN OTHERS then
     IF ((SQLCODE <> -20001) OR ((SQLCODE <> -20002))) then
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
     END IF;
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
        ' Invoice_line_Number = '||TO_CHAR(l_invoice_line_number)
        ||' Asset_bt_code = '||P_asset_bt_code
        ||' Transfer_flag = '||p_transfer_flag
        ||' Approval_wf_flag  = '||P_approval_workflow_flag
        ||' Amount = '||TO_CHAR(P_Amount)
        ||' Quantity_Invoiced = '||TO_CHAR(P_Quantity_Invoiced)
         ||' Unit_Price = '||to_char(P_unit_price));
     APP_EXCEPTION.RAISE_EXCEPTION;
End Insert_Invoice_Line;


Procedure Insert_Invoice_Line_Dset(
	P_invoice_id			IN	NUMBER,
	P_line_amount			IN	NUMBER,
	P_description			IN	VARCHAR2,
	P_distribution_set_id		IN     	NUMBER,
	P_requester_id			IN	NUMBER,
	P_set_of_books_id		IN     	NUMBER,
	P_exchange_rate           	IN     	NUMBER,
        P_base_currency_code      	IN     	VARCHAR2,
        P_accounting_date         	IN     	DATE,
	P_gl_period_name		IN	VARCHAR2,
	P_org_id			IN	NUMBER,
	P_item_description		IN	VARCHAR2,
	P_manufacturer			IN	VARCHAR2,
        P_model_number			IN	VARCHAR2,
	P_approval_workflow_flag	IN	VARCHAR2,
     -- P_ussgl_txn_code		IN	VARCHAR2,  - Bug 4277744
	P_income_tax_region		IN	VARCHAR2,
	P_type_1099			IN	VARCHAR2,
	P_asset_bt_code			IN	VARCHAR2,
	P_awt_group_id			IN	NUMBER,
	P_pay_awt_group_id              IN      NUMBER,--bug6639866
	P_ship_to_location_id		IN	NUMBER,
	P_primary_intended_use		IN	VARCHAR2,
	P_product_fisc_classification	IN	VARCHAR2,
	P_trx_business_category		IN	VARCHAR2,
	P_user_defined_fisc_class	IN	VARCHAR2,
	P_tax_classification_code	IN	VARCHAR2,
	P_PRODUCT_TYPE	                IN	VARCHAR2, --Bug#8640313
        P_PRODUCT_CATEGORY	        IN	VARCHAR2, --Bug#8640313
	P_calling_sequence		IN	VARCHAR2
	) IS

l_asset_book_count	       NUMBER;
l_inv_line_asset_bt_code       NUMBER;
l_inv_line_asset_category_id   NUMBER;
l_base_line_amount	       NUMBER;
l_invoice_line_number          AP_INVOICE_LINES.LINE_NUMBER%TYPE;
l_dist_set_percent_number      NUMBER := 0;
l_dist_set_description         AP_DISTRIBUTION_SETS.DESCRIPTION%TYPE;
l_dist_set_attribute_category  AP_DISTRIBUTION_SETS.ATTRIBUTE_CATEGORY%TYPE;
l_dist_set_attribute1          AP_DISTRIBUTION_SETS.ATTRIBUTE1%TYPE;
l_dist_set_attribute2          AP_DISTRIBUTION_SETS.ATTRIBUTE2%TYPE;
l_dist_set_attribute3          AP_DISTRIBUTION_SETS.ATTRIBUTE3%TYPE;
l_dist_set_attribute4          AP_DISTRIBUTION_SETS.ATTRIBUTE4%TYPE;
l_dist_set_attribute5          AP_DISTRIBUTION_SETS.ATTRIBUTE5%TYPE;
l_dist_set_attribute6          AP_DISTRIBUTION_SETS.ATTRIBUTE6%TYPE;
l_dist_set_attribute7          AP_DISTRIBUTION_SETS.ATTRIBUTE7%TYPE;
l_dist_set_attribute8          AP_DISTRIBUTION_SETS.ATTRIBUTE8%TYPE;
l_dist_set_attribute9          AP_DISTRIBUTION_SETS.ATTRIBUTE9%TYPE;
l_dist_set_attribute10         AP_DISTRIBUTION_SETS.ATTRIBUTE10%TYPE;
l_dist_set_attribute11         AP_DISTRIBUTION_SETS.ATTRIBUTE11%TYPE;
l_dist_set_attribute12         AP_DISTRIBUTION_SETS.ATTRIBUTE12%TYPE;
l_dist_set_attribute13         AP_DISTRIBUTION_SETS.ATTRIBUTE13%TYPE;
l_dist_set_attribute14         AP_DISTRIBUTION_SETS.ATTRIBUTE14%TYPE;
l_dist_set_attribute15         AP_DISTRIBUTION_SETS.ATTRIBUTE15%TYPE;
l_inactive_date		       DATE;

debug_info		VARCHAR2(1000);
current_calling_sequence VARCHAR2(2000);

BEGIN

  current_calling_sequence := p_calling_sequence || ' -> Insert_Invoice_Line_Dset';
    --------------------------------------------------------------
       -- For the distribution set, obtain information required for
       -- validation and defaulting. Also verify that the distribution set
       -- is not inactive.
       --------------------------------------------------------------
       debug_info := 'Get total percent for distribution set';
       BEGIN
        SELECT total_percent_distribution,
           description,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           inactive_date
         INTO
           l_dist_set_percent_number,
           l_dist_set_description,
           l_dist_set_attribute_category,
           l_dist_set_attribute1,
           l_dist_set_attribute2,
           l_dist_set_attribute3,
           l_dist_set_attribute4,
           l_dist_set_attribute5,
           l_dist_set_attribute6,
           l_dist_set_attribute7,
           l_dist_set_attribute8,
           l_dist_set_attribute9,
           l_dist_set_attribute10,
           l_dist_set_attribute11,
           l_dist_set_attribute12,
           l_dist_set_attribute13,
           l_dist_set_attribute14,
           l_dist_set_attribute15,
           l_inactive_date
         FROM ap_distribution_sets
         WHERE distribution_set_id = p_distribution_set_id;

         IF (nvl(l_inactive_date, trunc(sysdate) + 1) <= trunc(sysdate)) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_VEN_DIST_SET_INVALID');
            APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;

         IF (l_dist_set_percent_number <> 100) then
            FND_MESSAGE.SET_NAME('SQLAP','AP_CANT_USE_SKELETON_DIST_SET');
            APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
         Debug_info := debug_info || ': Cannot read Dist Set';
         IF (SQLCODE <> -20001) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(p_invoice_id));
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;
     END;


     BEGIN
       debug_info := 'Get Asset Book count';
       SELECT count(*)
         INTO l_asset_book_count
         FROM fa_book_controls bc
        WHERE bc.book_class = 'CORPORATE'
          AND bc.set_of_books_id = p_set_of_books_id
          AND bc.date_ineffective is null;

       IF (l_asset_book_count = 1) then
         SELECT bc.book_type_code
           INTO l_inv_line_asset_bt_code
           FROM fa_book_controls bc
          WHERE bc.set_of_books_id = p_set_of_books_id
            AND bc.date_ineffective is null;

       ELSE

         l_inv_line_asset_bt_code := NULL;

       END IF;

       l_inv_line_asset_category_id := NULL;

     EXCEPTION
       -- No need to error handle IF FA information not available.
       WHEN OTHERS THEN
         NULL;
     END;


   debug_info := 'Calculate base_line_amount';
   l_base_line_amount := AP_UTILITIES_PKG.Ap_Round_Currency(
                         NVL(p_line_amount,0) * p_exchange_rate ,
                         p_base_currency_code);

   l_invoice_line_number := ap_invoices_pkg.get_max_line_number(p_invoice_id)+1;

   debug_info := 'Insert line into ap_invoice_lines';
    BEGIN
      INSERT INTO ap_invoice_lines(
                 invoice_id,
                 line_number,
                 line_type_lookup_code,
                 requester_id,
                 description,
                 line_source,
                 org_id,
                 inventory_item_id,
                 item_description,
                 serial_number,
                 manufacturer,
                 model_number,
                 warranty_number,
                 generate_dists,
                 match_type,
                 distribution_set_id,
                 account_segment,
                 balancing_segment,
                 cost_center_segment,
                 overlay_dist_code_concat,
                 default_dist_ccid,
                 prorate_across_all_items,
                 line_group_number,
                 accounting_date,
                 period_name,
                 deferred_acctg_flag,
                 def_acctg_start_date,
                 def_acctg_end_date,
                 def_acctg_number_of_periods,
                 def_acctg_period_type,
                 set_of_books_id,
                 amount,
                 base_amount,
                 rounding_amt,
                 quantity_invoiced,
                 unit_meas_lookup_code,
                 unit_price,
                 wfapproval_status,
              -- ussgl_transaction_code, - Bug 4277744
                 discarded_flag,
                 original_amount,
                 original_base_amount,
                 original_rounding_amt,
                 cancelled_flag,
                 income_tax_region,
                 type_1099,
                 stat_amount,
                 prepay_invoice_id,
                 prepay_line_number,
                 invoice_includes_prepay_flag,
                 corrected_inv_id,
                 corrected_line_number,
                 po_header_id,
                 po_line_id,
                 po_release_id,
                 po_line_location_id,
                 po_distribution_id,
                 rcv_transaction_id,
                 final_match_flag,
                 assets_tracking_flag,
                 asset_book_type_code,
                 asset_category_id,
                 project_id,
                 task_id,
                 expenditure_type,
                 expenditure_item_date,
                 expenditure_organization_id,
                 pa_quantity,
                 pa_cc_ar_invoice_id,
                 pa_cc_ar_invoice_line_num,
                 pa_cc_processed_code,
                 award_id,
                 awt_group_id,
		 pay_awt_group_id,--bug6639866
                 reference_1,
                 reference_2,
                 receipt_verified_flag,
                 receipt_required_flag,
                 receipt_missing_flag,
                 justification,
                 expense_group,
                 start_expense_date,
                 end_expense_date,
                 receipt_currency_code,
                 receipt_conversion_rate,
                 receipt_currency_amount,
                 daily_amount,
                 web_parameter_id,
                 adjustment_reason,
                 merchant_document_number,
                 merchant_name,
                 merchant_reference,
                 merchant_tax_reg_number,
                 merchant_taxpayer_id,
                 country_of_supply,
                 credit_card_trx_id,
                 company_prepaid_invoice_id,
                 cc_reversal_flag,
                 attribute_category,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 global_attribute_category,
                 global_attribute1,
                 global_attribute2,
                 global_attribute3,
                 global_attribute4,
                 global_attribute5,
                 global_attribute6,
                 global_attribute7,
                 global_attribute8,
                 global_attribute9,
                 global_attribute10,
                 global_attribute11,
                 global_attribute12,
                 global_attribute13,
                 global_attribute14,
                 global_attribute15,
                 global_attribute16,
                 global_attribute17,
                 global_attribute18,
                 global_attribute19,
                 global_attribute20,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 program_application_id,
                 program_id,
                 program_update_date,
                 request_id,
                 ship_to_location_id,
                 primary_intended_use,
                 product_fisc_classification,
                 trx_business_category,
                 user_defined_fisc_class,
                 product_type,
                 product_category,
		 tax_classification_code
                 )
      VALUES (   p_invoice_id,                  --  invoice_id
                 l_invoice_line_number,         --  line_number
                 'ITEM',                        --  line_type_lookup_code
                 p_requester_id,                --  requester_id
                 nvl(l_dist_set_description,p_description),     --  description
                 'AUTO INVOICE CREATION',       --  line_source
                 p_org_id,                      --  org_id
                 NULL,                          --  inventory_item_id
                 P_Item_description,            --  item_description
                 NULL,                          --  serial_number
                 P_Manufacturer,                --  manufacturer
                 P_Model_Number,                --  model_number
                 NULL,                          --  warranty_number
                 'Y',                           --  generate_dists
                 'NOT_MATCHED',                 --  match_type
                 P_distribution_set_id,         --  distribution_set_id
                 NULL,                          --  account_segment
                 NULL,                          --  balancing_segment
                 NULL,                          --  cost_center_segment
                 NULL,                          --  overlay_dist_code_concat
                 NULL,                          --  default_dist_ccid
                 'N',                           --  prorate_across_all_items
                 NULL,                          --  line_group_number
                 P_Accounting_Date,             --  accounting_date
                 P_gl_period_name,              --  period_name
                 'N',                           --  deferred_acctg_flag
                 NULL,                          --  def_acctg_start_date
                 NULL,                          --  def_acctg_end_date
                 NULL,                          --  def_acctg_number_of_periods
                 NULL,                          --  def_acctg_period_type
                 p_set_of_books_id,             --  set_of_books_id
                 P_line_amount,                 --  amount
                 l_base_line_amount,            --  base_amount
                 0,                             --  rounding_amt
                 NULL,                          --  quantity_invoiced
                 NULL,                          --  unit_meas_lookup_code
                 NULL,                          --  unit_price
                 Decode(P_Approval_Workflow_Flag,'Y','REQUIRED',
                        'NOT REQUIRED'),        --  wfapproval_status
              -- Removed for bug 4277744
              -- P_ussgl_txn_code,              --  ussgl_transaction_code
                 'N',                           --  discarded_flag
                 NULL,                          --  original_amount
                 NULL,                          --  original_base_amount
                 NULL,                          --  original_rounding_amt
                 'N',                           --  cancelled_flag
                 P_income_tax_region,           --  income_tax_region
                 P_type_1099,                   --  type_1099
                 NULL,                          --  stat_amount
                 NULL,                          --  prepay_invoice_id
                 NULL,                          --  prepay_line_number
                 NULL,                          --  invoice_includes_prepay_flag
                 NULL,                          --  corrected_inv_id
                 NULL,                          --  corrected_line_number
                 NULL,                          --  po_header_id
                 NULL,                          --  po_line_id
                 NULL,                          --  po_release_id
                 NULL,                          --  po_line_location_id
                 NULL,                          --  po_distribution_id
                 NULL,                          --  rcv_transaction_id
                 NULL,                          --  final_match_flag
                 'N',                           --  assets_tracking_flag
                 P_asset_bt_code,               --  asset_book_type_code,
                 l_inv_line_asset_category_id,  --  asset_category_id
                 NULL,                          --  project_id
                 NULL,                          --  task_id
                 NULL,                          --  expenditure_type
                 NULL,                          --  expenditure_item_date
                 NULL,                          --  expenditure_organization_id
                 NULL,                          --  pa_quantity
                 NULL,                          --  pa_cc_ar_invoice_id
                 NULL,                          --  pa_cc_ar_invoice_line_num
                 NULL,                          --  pa_cc_processed_code
                 NULL,                          --  award_id
                 P_awt_group_id,                --  awt_group_id
		 P_Pay_Awt_Group_Id,           --pay_awt_group_id--bug6639866
                 NULL,                          --  reference_1
                 NULL,                          --  reference_2
                 NULL,                          --  receipt_verified_flag
                 NULL,                          --  receipt_required_flag
                 NULL,                          --  receipt_missing_flag
                 NULL,                          --  justification
                 NULL,                          --  expense_group
                 NULL,                          --  start_expense_date
                 NULL,                          --  end_expense_date
                 NULL,                          --  receipt_currency_code
                 NULL,                          --  receipt_conversion_rate
                 NULL,                          --  receipt_currency_amount
                 NULL,                          --  daily_amount
                 NULL,                          --  web_parameter_id
                 NULL,                          --  adjustment_reason
                 NULL,                          --  merchant_document_number
                 NULL,                          --  merchant_name
                 NULL,                          --  merchant_reference
                 NULL,                          --  merchant_tax_reg_number
                 NULL,                          --  merchant_taxpayer_id
                 NULL,                          --  country_of_supply
                 NULL,                          --  credit_card_trx_id
                 NULL,                          --  company_prepaid_invoice_id
                 NULL,                          --  cc_reversal_flag
                 l_dist_set_attribute_category, --  attribute_category
                 l_dist_set_attribute1,         --  attribute1
                 l_dist_set_attribute2,         --  attribute2
                 l_dist_set_attribute3,         --  attribute3
                 l_dist_set_attribute4,         --  attribute4
                 l_dist_set_attribute5,         --  attribute5
                 l_dist_set_attribute6,         --  attribute6
                 l_dist_set_attribute7,         --  attribute7
                 l_dist_set_attribute8,         --  attribute8
                 l_dist_set_attribute9,         --  attribute9
                 l_dist_set_attribute10,        --  attribute10
                 l_dist_set_attribute11,        --  attribute11
                 l_dist_set_attribute12,        --  attribute12
                 l_dist_set_attribute13,        --  attribute13
                 l_dist_set_attribute14,        --  attribute14
                 l_dist_set_attribute15,        --  attribute15
                 NULL,                          -- global_attribute_category
                 NULL,                          -- global_attribute1
                 NULL,                          -- global_attribute2
                 NULL,                          -- global_attribute3
                 NULL,                          -- global_attribute4
                 NULL,                          -- global_attribute5
                 NULL,                          -- global_attribute6
                 NULL,                          -- global_attribute7
                 NULL,                          -- global_attribute8
                 NULL,                          -- global_attribute9
                 NULL,                          -- global_attribute10
                 NULL,                          -- global_attribute11
                 NULL,                          -- global_attribute12
                 NULL,                          -- global_attribute13
                 NULL,                          -- global_attribute14
                 NULL,                          -- global_attribute15
                 NULL,                          -- global_attribute16
                 NULL,                          -- global_attribute17
                 NULL,                          -- global_attribute18
                 NULL,                          -- global_attribute19
                 NULL,                          -- global_attribute20
                 sysdate,                       -- creation_date
                 FND_GLOBAL.user_id,            -- created_by
                 FND_GLOBAL.user_id,            -- last_updated_by
                 sysdate,                       -- last_update_date
                 FND_GLOBAL.login_id,           -- last_update_login
                 NULL,                          -- program_application_id
                 NULL,                          -- program_id
                 NULL,                          -- program_update_date
                 NULL,                          -- request_id
                 P_ship_to_location_id,         -- ship_to_location_id
                 P_primary_intended_use ,       -- primary_intended_use
                 P_product_fisc_classification, -- product_fisc_classification
                 P_trx_business_category,       -- trx_business_category
                 P_user_defined_fisc_class,     -- user_defined_fisc_class
                 P_PRODUCT_TYPE,                -- NULL  --product_type --Bug#8640313
                 P_PRODUCT_CATEGORY,            -- NULL  --product_category --Bug#8640313
		 P_tax_classification_code      -- tax_classification_code
                 );

    END;

 EXCEPTION
 WHEN OTHERS then
   IF ((SQLCODE <> -20001) OR (SQLCODE <> -20002) ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
        'Invoice_id = '||TO_CHAR(P_invoice_id)
	||' Distribution_Set_id = '||TO_CHAR(P_distribution_set_id)
	||' Line_Amount	= '||TO_CHAR(p_line_amount)
	||' Accounting_date = '||TO_CHAR(P_accounting_date)
        ||' P_awt_group_id = '||TO_CHAR(P_awt_group_id)
        ||' Exchange Rate = '||TO_CHAR(P_exchange_rate)
        ||' Set 0f books id = '||TO_CHAR(P_set_of_books_id));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   END IF;

  APP_EXCEPTION.RAISE_EXCEPTION;

END Insert_Invoice_Line_Dset;


END AP_RECURRING_INVOICES_PKG;

/
