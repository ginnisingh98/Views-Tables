--------------------------------------------------------
--  DDL for Package Body AP_IMPORT_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_IMPORT_INVOICES_PKG" AS
/* $Header: apiimptb.pls 120.64.12010000.25 2010/10/27 12:52:17 dawasthi ship $ */

--==============================================================
-- delete attachment association
-- called by import_purge
-- (this function is also called by APXIIPRG.rdf)
--
--==============================================================
FUNCTION delete_attachments(p_invoice_id IN NUMBER)
        RETURN NUMBER IS
  l_attachments_count   NUMBER := 0;
  debug_info            VARCHAR2(500);
BEGIN
   select count(1)
   into   l_attachments_count
   from   fnd_attached_documents
   where  entity_name = 'AP_INVOICES_INTERFACE'
   and    pk1_value = p_invoice_id;

   -- only delete if there is an attachment
   if ( l_attachments_count > 0 ) then
     -- assuming deleting only the association with related documents
     -- need to see if that's always the case
     fnd_attached_documents2_pkg.delete_attachments(
                X_entity_name           => 'AP_INVOICES_INTERFACE',
                X_pk1_value             => p_invoice_id,
                X_delete_document_flag  => 'N' );
   end if;
   return l_attachments_count;

EXCEPTION

 WHEN OTHERS then
    IF (SQLCODE < 0) then
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;
    RETURN 0;
END delete_attachments;


--Payment Request: Added p_invoice_interface_id and p_needs_invoice_approval
--for importing payment request type invoices
FUNCTION IMPORT_INVOICES(
        p_batch_name              IN            VARCHAR2,
        p_gl_date                 IN            DATE,
        p_hold_code               IN            VARCHAR2,
        p_hold_reason             IN            VARCHAR2,
        p_commit_cycles           IN            NUMBER,
        p_source                  IN            VARCHAR2,
        p_group_id                IN            VARCHAR2,
        p_conc_request_id         IN            NUMBER,
        p_debug_switch            IN            VARCHAR2,
        p_org_id                  IN            NUMBER,
        p_batch_error_flag           OUT NOCOPY VARCHAR2,
        p_invoices_fetched           OUT NOCOPY NUMBER,
        p_invoices_created           OUT NOCOPY NUMBER,
        p_total_invoice_amount       OUT NOCOPY NUMBER,
        p_print_batch                OUT NOCOPY VARCHAR2,
        p_calling_sequence        IN            VARCHAR2,
        p_invoice_interface_id    IN            NUMBER DEFAULT NULL,
        p_needs_invoice_approval  IN            VARCHAR2 DEFAULT 'N',
        p_commit                  IN            VARCHAR2 DEFAULT 'Y')
RETURN BOOLEAN IS

-- Define invoice cursor

/* For bug3988118.
 * Need to add UPPER for the flag values as the user can populate any
 * value in the import tables and we do not validate if it is
 * directly populated with 'y' or 'Y' or 'n' or 'N'
 * Added UPPER for exclusive_payment_flag and invoice_includes_prepay_flag
 * */

/* For bug 3972507
 * Changed trim to rtrim in order to rtrim only
 * trailing spaces */

-- Bug 4145391. Modified the select for the cursor to improve performance.
-- Removed the p_group_id where clause and added it to the cursor
-- import_invoices_group

/* Bug 6349739- Modified cursors import_invoices and
 * import_invoices_group for RETEK invoices to set
 * calc_tax_during_import_flag to 'N' for RETEK invoices */

 --Modified below cursor for bug #9254176
  --Added rtrim for all varchar2 fields.

CURSOR  import_invoices is
SELECT  invoice_id,
        rtrim(invoice_num) invoice_num,
        rtrim(invoice_type_lookup_code) invoice_type_lookup_code,
        invoice_date,
        po_number,
        vendor_id,
        vendor_num,
        vendor_name,
        vendor_site_id,
        vendor_site_code,
        invoice_amount,
        rtrim(invoice_currency_code) invoice_currency_code,
        exchange_rate,
        rtrim(exchange_rate_type) exchange_rate_type,
        exchange_date,
        terms_id,
        terms_name,
        terms_date,
        rtrim(description) description,
        awt_group_id,
        awt_group_name,
        pay_awt_group_id,--bug6639866
        pay_awt_group_name,--bug6639866
        amount_applicable_to_discount,
        sysdate,
        last_updated_by,
        last_update_login,
        sysdate,
        created_by,
        rtrim(status) status,
        rtrim(attribute_category) attribute_category,
        rtrim(attribute1) attribute1,
        rtrim(attribute2) attribute2,
        rtrim(attribute3) attribute3,
        rtrim(attribute4) attribute4,
        rtrim(attribute5) attribute5,
        rtrim(attribute6) attribute6,
        rtrim(attribute7) attribute7,
        rtrim(attribute8) attribute8,
        rtrim(attribute9) attribute9,
        rtrim(attribute10) attribute10,
        rtrim(attribute11) attribute11,
        rtrim(attribute12) attribute12,
        rtrim(attribute13) attribute13,
        rtrim(attribute14) attribute14,
        rtrim(attribute15) attribute15,
        rtrim(global_attribute_category) global_attribute_category,
        rtrim(global_attribute1) global_attribute1,
        rtrim(global_attribute2) global_attribute2,
        rtrim(global_attribute3) global_attribute3,
        rtrim(global_attribute4) global_attribute4,
        rtrim(global_attribute5) global_attribute5,
        rtrim(global_attribute6) global_attribute6,
        rtrim(global_attribute7) global_attribute7,
        rtrim(global_attribute8) global_attribute8,
        rtrim(global_attribute9) global_attribute9,
        rtrim(global_attribute10) global_attribute10,
        rtrim(global_attribute11) global_attribute11,
        rtrim(global_attribute12) global_attribute12,
        rtrim(global_attribute13) global_attribute13,
        rtrim(global_attribute14) global_attribute14,
        rtrim(global_attribute15) global_attribute15,
        rtrim(global_attribute16) global_attribute16,
        rtrim(global_attribute17) global_attribute17,
        rtrim(global_attribute18) global_attribute18,
        rtrim(global_attribute19) global_attribute19,
        rtrim(global_attribute20) global_attribute20,
        rtrim(payment_currency_code) payment_currency_code,
        payment_cross_rate,
        rtrim(payment_cross_rate_type) payment_cross_rate_type,
        payment_cross_rate_date,
        doc_category_code,
        rtrim(voucher_num) voucher_num,
        rtrim(payment_method_code) payment_method_code,
        rtrim(pay_group_lookup_code) pay_group_lookup_code,
        goods_received_date,
        invoice_received_date,
        gl_date,
        accts_pay_code_combination_id,
        -- bug 6509776
        RTRIM(accts_pay_code_concatenated,'-'),
     -- ussgl_transaction_code,  - Bug 4277744
        UPPER(exclusive_payment_flag),
        prepay_num,
        prepay_line_num,
        prepay_apply_amount,
        prepay_gl_date,
        UPPER(invoice_includes_prepay_flag),
        no_xrate_base_amount,
        requester_id,
        org_id,
        operating_unit,
        rtrim(source) source,
        group_id,
        request_id,
        workflow_flag,
        vendor_email_address,
        NVL(calc_tax_during_import_flag, 'N'), -- bug 6349739,bug6328293
        control_amount,
        add_tax_to_inv_amt_flag,
        tax_related_invoice_id,
	rtrim(taxation_country) taxation_country,
        rtrim(document_sub_type) document_sub_type,
        rtrim(supplier_tax_invoice_number) supplier_tax_invoice_number,
        supplier_tax_invoice_date,
        supplier_tax_exchange_rate,
        tax_invoice_recording_date,
        tax_invoice_internal_seq,
        legal_entity_id,
        null,
        ap_import_utilities_pkg.get_tax_only_rcv_matched_flag(invoice_id),
        ap_import_utilities_pkg.get_tax_only_flag(invoice_id),
        apply_advances_flag,
	application_id,
	product_table,
	reference_key1,
	reference_key2,
	reference_key3,
	reference_key4,
	reference_key5,
	reference_1,
	reference_2,
	net_of_retainage_flag,
        rtrim(cust_registration_code) cust_registration_code,
        rtrim(cust_registration_number) cust_registration_number,
	paid_on_behalf_employee_id,
        party_id,  -- Added for Payment Requests
        party_site_id,
	rtrim(pay_proc_trxn_type_code) pay_proc_trxn_type_code,
        rtrim(payment_function) payment_function,
        rtrim(payment_priority) payment_priority,
        rtrim(BANK_CHARGE_BEARER) BANK_CHARGE_BEARER,
        rtrim(REMITTANCE_MESSAGE1) REMITTANCE_MESSAGE1,
        rtrim(REMITTANCE_MESSAGE2) REMITTANCE_MESSAGE2,
        rtrim(REMITTANCE_MESSAGE3) REMITTANCE_MESSAGE3,
        rtrim(UNIQUE_REMITTANCE_IDENTIFIER) UNIQUE_REMITTANCE_IDENTIFIER,
        URI_CHECK_DIGIT,
        SETTLEMENT_PRIORITY,
        rtrim(PAYMENT_REASON_CODE) PAYMENT_REASON_CODE,
        rtrim(PAYMENT_REASON_COMMENTS) PAYMENT_REASON_COMMENTS,
        rtrim(DELIVERY_CHANNEL_CODE) DELIVERY_CHANNEL_CODE,
        EXTERNAL_BANK_ACCOUNT_ID,
        --Bug 7357218 Quick Pay and Dispute Resolution Project
        ORIGINAL_INVOICE_AMOUNT ,
        DISPUTE_REASON,
	--Third Party Payments
	rtrim(REMIT_TO_SUPPLIER_NAME) REMIT_TO_SUPPLIER_NAME,
	REMIT_TO_SUPPLIER_ID	,
	rtrim(REMIT_TO_SUPPLIER_SITE) REMIT_TO_SUPPLIER_SITE,
	REMIT_TO_SUPPLIER_SITE_ID,
	RELATIONSHIP_ID,
	REMIT_TO_SUPPLIER_NUM
	/* Added for bug 10226070 */
	,REQUESTER_LAST_NAME
    	,REQUESTER_FIRST_NAME
  FROM  ap_invoices_interface
 WHERE  ((status is NULL) OR (status = 'REJECTED'))
   AND  source = p_source
   AND  ((p_invoice_interface_id IS NULL AND
          NVL(invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST')
          OR (invoice_id = p_invoice_interface_id))
   AND  NVL(workflow_flag,'D') = 'D'
   AND  (    (p_commit_cycles IS NULL)
          OR (rownum <= p_commit_cycles))
   AND  (    (org_id   IS NOT NULL AND
              p_org_id IS NOT NULL AND
              org_id   = p_org_id)
          OR (p_org_id IS NULL     AND
              org_id   IS NOT NULL AND
              (mo_global.check_access(org_id)= 'Y'))
          OR (p_org_id is NOT NULL AND  org_id IS NULL)
          OR (p_org_id is NULL     AND  org_id IS NULL))
 ORDER BY org_id,
          invoice_id,
          vendor_id,
          vendor_num,
          vendor_name,
          vendor_site_id,
          vendor_site_code,
          invoice_num
 For UPDATE of invoice_id NOWAIT;


--Modified below cursor for bug #9254176
--Added rtrim for all varchar2 fields.

CURSOR  import_invoices_group is
SELECT  invoice_id,
        rtrim(invoice_num) invoice_num,
        rtrim(invoice_type_lookup_code) invoice_type_lookup_code,
        invoice_date,
        po_number,
        vendor_id,
        vendor_num,
        vendor_name,
        vendor_site_id,
        vendor_site_code,
        invoice_amount,
        rtrim(invoice_currency_code) invoice_currency_code,
        exchange_rate,
        rtrim(exchange_rate_type) exchange_rate_type,
        exchange_date,
        terms_id,
        terms_name,
        terms_date,
        rtrim(description) description,
        awt_group_id,
        awt_group_name,
        pay_awt_group_id,--bug6639866
        pay_awt_group_name,--bug6639866
        amount_applicable_to_discount,
        sysdate,
        last_updated_by,
        last_update_login,
        sysdate,
        created_by,
        rtrim(status) status,
        rtrim(attribute_category) attribute_category,
        rtrim(attribute1) attribute1,
        rtrim(attribute2) attribute2,
        rtrim(attribute3) attribute3,
        rtrim(attribute4) attribute4,
        rtrim(attribute5) attribute5,
        rtrim(attribute6) attribute6,
        rtrim(attribute7) attribute7,
        rtrim(attribute8) attribute8,
        rtrim(attribute9) attribute9,
        rtrim(attribute10) attribute10,
        rtrim(attribute11) attribute11,
        rtrim(attribute12) attribute12,
        rtrim(attribute13) attribute13,
        rtrim(attribute14) attribute14,
        rtrim(attribute15) attribute15,
        rtrim(global_attribute_category) global_attribute_category,
        rtrim(global_attribute1) global_attribute1,
        rtrim(global_attribute2) global_attribute2,
        rtrim(global_attribute3) global_attribute3,
        rtrim(global_attribute4) global_attribute4,
        rtrim(global_attribute5) global_attribute5,
        rtrim(global_attribute6) global_attribute6,
        rtrim(global_attribute7) global_attribute7,
        rtrim(global_attribute8) global_attribute8,
        rtrim(global_attribute9) global_attribute9,
        rtrim(global_attribute10) global_attribute10,
        rtrim(global_attribute11) global_attribute11,
        rtrim(global_attribute12) global_attribute12,
        rtrim(global_attribute13) global_attribute13,
        rtrim(global_attribute14) global_attribute14,
        rtrim(global_attribute15) global_attribute15,
        rtrim(global_attribute16) global_attribute16,
        rtrim(global_attribute17) global_attribute17,
        rtrim(global_attribute18) global_attribute18,
        rtrim(global_attribute19) global_attribute19,
        rtrim(global_attribute20) global_attribute20,
        rtrim(payment_currency_code) payment_currency_code,
        payment_cross_rate,
        rtrim(payment_cross_rate_type) payment_cross_rate_type,
        payment_cross_rate_date,
        doc_category_code,
        rtrim(voucher_num) voucher_num,
        rtrim(payment_method_code) payment_method_code,
        rtrim(pay_group_lookup_code) pay_group_lookup_code,
        goods_received_date,
        invoice_received_date,
        gl_date,
        accts_pay_code_combination_id,
        -- bug 6509776
        RTRIM(accts_pay_code_concatenated,'-'),
     -- ussgl_transaction_code,  - Bug 4277744
        UPPER(exclusive_payment_flag),
        prepay_num,
        prepay_line_num,
        prepay_apply_amount,
        prepay_gl_date,
        UPPER(invoice_includes_prepay_flag),
        no_xrate_base_amount,
        requester_id,
        org_id,
        operating_unit,
        rtrim(source) source,
        group_id,
        request_id,
        workflow_flag,
        vendor_email_address,
        NVL(calc_tax_during_import_flag, 'N'), -- bug 6349739,bug6328293
        control_amount,
        add_tax_to_inv_amt_flag,
        tax_related_invoice_id,
	rtrim(taxation_country) taxation_country,
        rtrim(document_sub_type) document_sub_type,
        rtrim(supplier_tax_invoice_number) supplier_tax_invoice_number,
        supplier_tax_invoice_date,
        supplier_tax_exchange_rate,
        tax_invoice_recording_date,
        tax_invoice_internal_seq,
        legal_entity_id,
        null,
        ap_import_utilities_pkg.get_tax_only_rcv_matched_flag(invoice_id),
        ap_import_utilities_pkg.get_tax_only_flag(invoice_id),
        apply_advances_flag,
        application_id,
        product_table,
        reference_key1,
        reference_key2,
        reference_key3,
        reference_key4,
        reference_key5,
        reference_1,
        reference_2,
        net_of_retainage_flag,
        rtrim(cust_registration_code) cust_registration_code,
        rtrim(cust_registration_number) cust_registration_number,
        paid_on_behalf_employee_id,
        party_id,  -- Added for Payment Requests
        party_site_id,
        rtrim(pay_proc_trxn_type_code) pay_proc_trxn_type_code,
        rtrim(payment_function) payment_function,
        rtrim(payment_priority) payment_priority,
        rtrim(BANK_CHARGE_BEARER) BANK_CHARGE_BEARER,
        rtrim(REMITTANCE_MESSAGE1) REMITTANCE_MESSAGE1,
        rtrim(REMITTANCE_MESSAGE2) REMITTANCE_MESSAGE2,
        rtrim(REMITTANCE_MESSAGE3) REMITTANCE_MESSAGE3,
        rtrim(UNIQUE_REMITTANCE_IDENTIFIER) UNIQUE_REMITTANCE_IDENTIFIER,
        URI_CHECK_DIGIT,
        SETTLEMENT_PRIORITY,
        rtrim(PAYMENT_REASON_CODE) PAYMENT_REASON_CODE,
        rtrim(PAYMENT_REASON_COMMENTS) PAYMENT_REASON_COMMENTS,
        rtrim(DELIVERY_CHANNEL_CODE) DELIVERY_CHANNEL_CODE,
        EXTERNAL_BANK_ACCOUNT_ID,
        --Bug 7357218 Quick Pay and Dispute Resolution Project
        ORIGINAL_INVOICE_AMOUNT,
        DISPUTE_REASON,
	--Third Party Payments
	rtrim(REMIT_TO_SUPPLIER_NAME) REMIT_TO_SUPPLIER_NAME,
	REMIT_TO_SUPPLIER_ID,
	rtrim(REMIT_TO_SUPPLIER_SITE) REMIT_TO_SUPPLIER_SITE,
	REMIT_TO_SUPPLIER_SITE_ID,
	RELATIONSHIP_ID,
	REMIT_TO_SUPPLIER_NUM
	/* Added for bug 10226070 */
	,REQUESTER_LAST_NAME
    	,REQUESTER_FIRST_NAME
  FROM  ap_invoices_interface
 WHERE  ((status is NULL) OR (status = 'REJECTED'))
   AND  source = p_source
   AND  group_id = p_group_id
   AND  ((p_invoice_interface_id IS NULL AND
          NVL(invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST')
          OR (invoice_id = p_invoice_interface_id))
   AND  NVL(workflow_flag,'D') = 'D'
   AND  (    (p_commit_cycles IS NULL)
          OR (rownum <= p_commit_cycles))
   AND  (    (org_id   IS NOT NULL AND
              p_org_id IS NOT NULL AND
              org_id   = p_org_id)
          OR (p_org_id IS NULL     AND
              org_id   IS NOT NULL AND
              (mo_global.check_access(org_id)= 'Y'))
          OR (p_org_id is NOT NULL AND  org_id IS NULL)
          OR (p_org_id is NULL     AND  org_id IS NULL))
 ORDER BY org_id,
          invoice_id,
          vendor_id,
          vendor_num,
          vendor_name,
          vendor_site_id,
          vendor_site_code,
          invoice_num
 For UPDATE of invoice_id NOWAIT;

    l_invoice_rec                   AP_IMPORT_INVOICES_PKG.r_invoice_info_rec;
    l_invoice_lines_tab             AP_IMPORT_INVOICES_PKG.t_lines_table;
    l_default_last_updated_by       NUMBER;
    l_default_last_update_login     NUMBER;
    l_multi_currency_flag           VARCHAR2(1);
    l_make_rate_mandatory_flag      VARCHAR2(1);
    l_default_exchange_rate_type    VARCHAR2(30);
    l_base_currency_code            VARCHAR2(15);
    l_batch_control_flag            VARCHAR2(1);
    l_base_min_acct_unit            NUMBER;
    l_base_precision                NUMBER;
    l_sequence_numbering            VARCHAR2(1);
    l_awt_include_tax_amt           VARCHAR2(1);
    l_gl_date_from_get_info         DATE;
 -- l_ussgl_transcation_code        VARCHAR2(30);  - Bug 4277744
    l_transfer_po_desc_flex_flag    VARCHAR2(1);
    l_gl_date_from_receipt_flag     VARCHAR2(25);
    l_purch_encumbrance_flag        VARCHAR2(1);
    l_retainage_ccid		    NUMBER;
    l_pa_installed                  VARCHAR2(1):='N';
    l_chart_of_accounts_id          NUMBER;
    l_positive_price_tolerance      NUMBER;
    l_negative_price_tolerance      NUMBER;
    l_qty_tolerance                 NUMBER;
    l_qty_rec_tolerance             NUMBER;
    l_amt_tolerance		    NUMBER;
    l_amt_rec_tolerance		    NUMBER;
    l_max_qty_ord_tolerance         NUMBER;
    l_max_qty_rec_tolerance         NUMBER;
    l_max_amt_ord_tolerance	    NUMBER;
    l_max_amt_rec_tolerance	    NUMBER;
    l_goods_ship_amt_tolerance      NUMBER;
    l_goods_rate_amt_tolerance      NUMBER;
    l_goods_total_amt_tolerance     NUMBER;
    l_services_ship_amt_tolerance   NUMBER;
    l_services_rate_amt_tolerance   NUMBER;
    l_services_total_amt_tolerance  NUMBER;
    l_inv_doc_cat_override          VARCHAR2(1):='N';
    l_pay_curr_invoice_amount       NUMBER;
    l_invoice_amount_limit          NUMBER;
    l_hold_future_payments_flag     VARCHAR2(1);
    l_supplier_hold_reason          VARCHAR2(240);
    l_invoice_status                VARCHAR2(1) :='Y';
    l_gl_date                       DATE;
    l_min_acct_unit                 NUMBER;
    l_precision                     NUMBER;
    l_payment_priority              NUMBER;
    l_batch_id                      NUMBER;
    l_batch_name                    VARCHAR2(50);
    l_continue_flag                 VARCHAR2(1) := 'Y';
    l_fatal_error_flag              VARCHAR2(1) := 'N';
    l_base_invoice_id               NUMBER(15);
    l_invoice_currency_code         VARCHAR2(15);
    l_batch_exists_flag             VARCHAR2(1) := 'N';
    l_batch_type                    VARCHAR2(30);
    l_valid_invoices_count          NUMBER:=0;
    l_match_mode                    VARCHAR2(25);
    l_dbseqnm                       VARCHAR2(30);
    l_dbseqid                       NUMBER;
    l_seqval                        NUMBER;
    l_apply_prepay_log              LONG;
    l_invoices_fetched              NUMBER:=0;
    l_actual_invoice_total          NUMBER:=0;
    import_invoice_failure          EXCEPTION;
    current_calling_sequence        VARCHAR2(2000);
    debug_info                      VARCHAR2(500);
    l_total_invoice_amount          NUMBER :=0;
    l_calc_user_xrate               VARCHAR2(1);
    l_approval_workflow_flag        VARCHAR2(1);
    l_freight_code_combination_id   NUMBER;
    l_old_org_id                    NUMBER;
    l_default_org_id                NUMBER;
    l_ou_count                      NUMBER;
    l_default_ou_name               VARCHAR2(240);
    l_derived_operating_unit        VARCHAR2(240);
    l_null_org_id                   BOOLEAN;
    l_total_count                   NUMBER := 0;
    l_set_of_books_id               NUMBER;
    l_error_code                    VARCHAR2(500);

    l_prepay_appl_log               ap_prepay_pkg.Prepay_Appl_Log_Tab;
    l_prepay_period_name            VARCHAR2(25);
    --Contract Payments
    l_prepay_invoice_id		    NUMBER;
    l_prepay_case_name		    VARCHAR2(50);
    l_inv_amount_unpaid		    NUMBER;
    l_amount_to_apply		    NUMBER;

    l_allow_interest_invoices	    VARCHAR2(1); --bugfix:4113223
    l_option_defined_org            NUMBER;   -- bug 5140002

    TYPE numlist is TABLE OF ap_interface_rejections.parent_id%TYPE;

    enums numlist;
    --bug:4930111
    l_add_days_settlement_date  NUMBER;
    --bug 4931755
    l_disc_is_inv_less_tax_flag VARCHAR2(1);
    l_exclude_freight_from_disc VARCHAR2(1);

    l_exclusive_tax_amount	NUMBER;
    l_inv_hdr_amount		NUMBER;
    l_payment_status_flag	VARCHAR2(50);
    l_message1			VARCHAR2(50);
    l_message2			VARCHAR2(50);
    l_reset_match_status	VARCHAR2(50);
    l_liability_adjusted_flag	VARCHAR2(50);
    l_revalidate_ps       	VARCHAR2(50);
    -- Bug 5448579
    l_moac_org_table             AP_IMPORT_INVOICES_PKG.moac_ou_tab_type;
    l_fsp_org_table              AP_IMPORT_INVOICES_PKG.fsp_org_tab_type;
    l_index_org_id              NUMBER;
    l_asset_book_type           FA_BOOK_CONTROLS.book_type_code%TYPE;

     -- Bug 5645581.
    l_inv_gl_date                DATE;   --Bug 5382889. LE Timezone
    l_rts_txn_le_date            DATE;   --Bug 5382889. LE Timezone
    l_inv_le_date                DATE;   --Bug 5382889. LE Timezone
    l_sys_le_date                DATE;   --Bug 5382889. LE Timezone

    -- Bug 7282839 start added variables to calculate tax for base currency.
    l_base_exclusive_tax_amount number;
    l_exchange_rate             number;
    -- Bug 7282839 end

    -- added for bug 8237318
    l_stmt      varchar2(5000);

    --7567527
    l_parameter_list	        wf_parameter_list_t;
    l_event_key			VARCHAR2(100);
    l_event_name		VARCHAR2(100) := 'oracle.apps.ap.invoice.import';

    --Bug8876668
    l_reject_status_code  VARCHAR2(1) :='Y';


BEGIN

  -- Update the calling sequence and initialize variables

  current_calling_sequence := 'Import_invoices<- '||p_calling_sequence;

  p_batch_error_flag                      := 'N';
  l_gl_date_from_get_info                 := TRUNC(p_gl_date);

  AP_IMPORT_INVOICES_PKG.g_debug_switch   := p_debug_switch;
  AP_IMPORT_INVOICES_PKG.g_source         := p_source;
  AP_IMPORT_INVOICES_PKG.g_program_application_id := FND_GLOBAL.prog_appl_id;
  AP_IMPORT_INVOICES_PKG.g_program_id := FND_GLOBAL.conc_program_id;
  AP_IMPORT_INVOICES_PKG.g_conc_request_id := p_conc_request_id;

 debug_info := 'Request_id'||p_conc_request_id;
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
  -- Retropricing
  IF AP_IMPORT_INVOICES_PKG.g_source = 'PPA' THEN
     AP_IMPORT_INVOICES_PKG.g_invoices_table      := 'AP_PPA_INVOICES_GT';
     AP_IMPORT_INVOICES_PKG.g_invoice_lines_table := 'AP_PPA_INVOICE_LINES_GT';
     AP_IMPORT_INVOICES_PKG.g_instructions_table  := 'AP_PPA_INSTRUCTIONS_GT';
  ELSE
     AP_IMPORT_INVOICES_PKG.g_invoices_table      := 'AP_INVOICES_INTERFACE';
     AP_IMPORT_INVOICES_PKG.g_invoice_lines_table := 'AP_INVOICE_LINES_INTERFACE';
     AP_IMPORT_INVOICES_PKG.g_instructions_table  := NULL;
  END IF;

   -- Bug 5448579
  ----------------------------------------------------------------
  debug_info := '(Import_invoice 0.1) Calling Caching Function for Org Id/Name';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
  IF (AP_IMPORT_UTILITIES_PKG.Cache_Org_Id_Name (
           P_Moac_Org_Table      => AP_IMPORT_INVOICES_PKG.g_moac_ou_tab,
           P_Fsp_Org_Table       => AP_IMPORT_INVOICES_PKG.g_fsp_ou_tab,
           P_Calling_Sequence    => current_calling_sequence ) <> TRUE) THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'Cache_Org_Id_Name <-'||current_calling_sequence);
    END IF;
    Raise import_invoice_failure;
  END IF;

  debug_info := '(Import_Invoices 0.2)  Calling Caching Function for Currency';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
  IF (AP_IMPORT_UTILITIES_PKG.Cache_Fnd_Currency (
           P_Fnd_Currency_Table   =>  AP_IMPORT_INVOICES_PKG.g_fnd_currency_tab,
           P_Calling_Sequence     => current_calling_sequence ) <> TRUE) THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'Cache_Fnd_Currency <-'||current_calling_sequence);
    END IF;
    Raise import_invoice_failure;
  END IF;


  debug_info := '(Import_Invoices 0.3) Calling Caching Function for Payment Method';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
     AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
  IF (AP_IMPORT_UTILITIES_PKG.Cache_Payment_Method (
           P_Payment_Method_Table => AP_IMPORT_INVOICES_PKG.g_payment_method_tab,
           P_Calling_Sequence      => current_calling_sequence ) <> TRUE) THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'Cache_Payment_Method <-'||current_calling_sequence);
    END IF;
    Raise import_invoice_failure;
  END IF;

  debug_info := '(Import_Invoices 0.4) Calling Caching Function for Payment Group';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
  IF (AP_IMPORT_UTILITIES_PKG.Cache_Pay_Group (
           P_Pay_Group_Table      => AP_IMPORT_INVOICES_PKG.g_pay_group_tab,
           P_Calling_Sequence     => current_calling_sequence ) <> TRUE) THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'Cache_Pay_Group <-'||current_calling_sequence);
    END IF;
    Raise import_invoice_failure;
  END IF;

  debug_info :=  '(Import_Invoices 0.5) Caching Structure Id';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  BEGIN

      SELECT structure_id
      INTO   AP_IMPORT_INVOICES_PKG.g_structure_id
      FROM   mtl_default_sets_view
      WHERE  functional_area_id = 2;

  EXCEPTION WHEN OTHERS THEN
    NULL;

  END;


  fnd_plsql_cache.generic_1tom_init(
             'PeriodName',
             lg_many_controller,
             lg_generic_storage);

  fnd_plsql_cache.generic_1tom_init(
             'ValidateSegs',
             lg_many_controller1,
             lg_generic_storage1);

  fnd_plsql_cache.generic_1tom_init(
             'CodeCombinations',
             lg_many_controller2,
             lg_generic_storage2);

  -- Bug 5572876
  fnd_plsql_cache.generic_1tom_init(
             'IncomeTaxType',
             lg_incometax_controller,
             lg_incometax_storage);

  -- 5572876
  fnd_plsql_cache.generic_1tom_init(
             'IncomeTaxRegion',
             lg_incometaxr_controller,
             lg_incometaxr_storage);

  --------------------------------------------------------
  -- Step 1
  -- Check control table for the import batch
  --------------------------------------------------------

  debug_info := '(Import_invoice 1) Check control table for the import batch';

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
/*
  IF (AP_IMPORT_UTILITIES_PKG.check_control_table(
    p_source,
    p_group_id,
    current_calling_sequence) <> TRUE) THEN

    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,'check_control_table<-'
           ||current_calling_sequence);
    END IF;
    Raise import_invoice_failure;
  END IF;
 */
  --------------------------------------------------------
  -- Step 2
  -- AP_IMPORT_UTILITIES_PKG.Print source if debug is turned on and
  -- get default last updated by and last update login information.
  --------------------------------------------------------
  debug_info := '(Import_invoice 2) Print Source';

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch, 'p_source' || p_source);
  END IF;

  l_default_last_updated_by   := to_number(FND_GLOBAL.USER_ID);
  l_default_last_update_login := to_number(FND_GLOBAL.LOGIN_ID);

  ----------------------------------------------------------------
  --  Step 3  Delete any rejections from previous failed imports
  --  of this invoice line
  ----------------------------------------------------------------

  debug_info := '(Import Invoice 3) Delete Rejections from previous failed '||
                'imports';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  debug_info := '(Check_lines 3a) Select all the Rejected Invoices';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- Bug 4145391. To improve the performance of the import program coding two
  -- different select stmts based on the parameter p_group_id

/* BUG 8237318 - Begin modified the existing query to dynamic sql to skip the null checks
   for passing parameters in the query. */
   l_stmt := 'SELECT invoice_id '
            ||' FROM ap_invoices_interface WHERE source = ''' ||p_source || ''' '
	    ||' AND ((status is NULL) or (status = ''REJECTED'')) ';



   IF p_group_id IS NOT NULL THEN
    l_stmt := l_stmt || ' AND group_id = '''|| p_group_id || ''' ';
   END IF;

   IF p_invoice_interface_id IS NULL THEN
    l_stmt := l_stmt || ' AND NVL(invoice_type_lookup_code, ''STANDARD'') <> ''PAYMENT REQUEST'' ';
   ELSE
    l_stmt := l_stmt || ' AND invoice_id = ' || p_invoice_interface_id || ' ';
   END IF;

   IF p_org_id IS NULL THEN
    l_stmt := l_stmt || ' AND ( (org_id IS NULL) OR (org_id IS NOT NULL AND mo_global.check_access(org_id)= ''Y'' ) ) ';
   ELSE
    l_stmt := l_stmt || ' AND ( (org_id IS NULL) OR (org_id IS NOT NULL AND org_id  = ' || p_org_id || ') ) ';
   END IF;

   l_stmt := l_stmt || ' AND nvl(workflow_flag,''D'') = ''D'' ';

   EXECUTE IMMEDIATE l_stmt BULK COLLECT INTO enums;

/*  IF (p_group_id IS NULL) THEN
      SELECT invoice_id
        BULK COLLECT INTO enums
        FROM ap_invoices_interface
       WHERE ((status is NULL) or (status = 'REJECTED'))
         AND source = p_source
         AND ((p_invoice_interface_id IS NULL AND
               NVL(invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST')
                 OR (invoice_id = p_invoice_interface_id))
         AND nvl(workflow_flag,'D') = 'D'
         AND ((org_id      is NOT NULL  AND
               p_org_id    is NOT NULL  AND
               org_id  = p_org_id)
              or (p_org_id is     NULL  AND
                  org_id   is NOT NULL  AND
                 (mo_global.check_access(org_id)= 'Y'))
              or (p_org_id is NOT NULL  AND
                  org_id   is     NULL)
              or (p_org_id is     NULL  AND
                  org_id   is     NULL));
  ELSE
      SELECT invoice_id
        BULK COLLECT INTO enums
        FROM ap_invoices_interface
       WHERE ((status is NULL) or (status = 'REJECTED'))
         AND source = p_source
         AND group_id = p_group_id
         AND ((p_invoice_interface_id IS NULL AND
               NVL(invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST')
                 OR (invoice_id = p_invoice_interface_id))
         AND nvl(workflow_flag,'D') = 'D'
         AND ((org_id      is NOT NULL  AND
               p_org_id    is NOT NULL  AND
               org_id  = p_org_id)
              or (p_org_id is     NULL  AND
                  org_id   is NOT NULL  AND
                 (mo_global.check_access(org_id)= 'Y'))
              or (p_org_id is NOT NULL  AND
                  org_id   is     NULL)
              or (p_org_id is     NULL  AND
                  org_id   is     NULL));
  END IF; */

/* BUG 8237318 - End modified the existing query to dynamic sql to skip the null checks
   for passing parameters in the query. */
  debug_info := '(Check_lines 3b) Delete invoices from ap_interface_rejections';

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- Retropricing
  --The PPA Rejections will be deleted from ap_interface_rejections
  -- in the After Report Trigger of APXIIMPT.
  IF enums.COUNT > 0 THEN

    ForALL i IN enums.FIRST .. enums.LAST
      DELETE FROM ap_interface_rejections
       WHERE parent_table = 'AP_INVOICES_INTERFACE'
         AND parent_id = enums(i);

    ForALL i IN enums.FIRST .. enums.LAST
      DELETE FROM ap_interface_rejections
       WHERE parent_table = 'AP_INVOICE_LINES_INTERFACE'
         AND parent_id IN (SELECT invoice_line_id
                             FROM ap_invoice_lines_interface
                            WHERE invoice_id = enums(i));
  END IF;
 --Start of Bug 6801046
  debug_info := '(Check_lines 3c) Update requestid on the Selected Invoices';

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  IF enums.COUNT > 0 THEN
      ForALL i IN enums.FIRST .. enums.LAST
      UPDATE  AP_INVOICES_INTERFACE
         SET request_id = AP_IMPORT_INVOICES_PKG.g_conc_request_id
       WHERE invoice_id = enums(i);
  END IF;
  --End of Bug 6801046
  ----------------------------------------------------------------
  -- Step 4  Update the org_id whenever null IF operating unit
  -- is not null.
  ----------------------------------------------------------------
  debug_info := '(Import Invoice 4) Update the org_id';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  debug_info := '(Import_Invoices 4a) Updating Interface WHERE org_id '||
                'is null but operating unit is not null';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;


  --Bug 6839034 Added additional filters to the update below
  -- Coding 2 different update stmts based on p_group_id to improve performance
/* BUG 8237318 - begin modified the existing query to dynamic sql to skip the null checks
   for passing parameters in the query. */

    l_stmt := 'UPDATE ap_invoices_interface i '
            ||' SET org_id =  (SELECT hr.organization_id org_id '
	    ||' FROM   hr_operating_units hr,per_business_groups per  '
            ||' WHERE  hr.business_group_id = per.business_group_id '
	    ||'  AND    mo_global.check_access(hr.organization_id) = ''Y'' '
            ||'  AND    hr.name = i.operating_unit) '
	    ||' WHERE i.org_id is null AND i.operating_unit is not null '
            ||' AND ((status is NULL) OR (status = ''REJECTED'')) AND   source = ''' || p_source || ''' '
	    ||' AND   NVL(workflow_flag,''D'') = ''D'' ';



   IF p_group_id IS NOT NULL THEN
    l_stmt := l_stmt || ' AND group_id = ''' || p_group_id || ''' ';
   END IF;

   IF p_invoice_interface_id IS NULL THEN
    l_stmt := l_stmt || ' AND NVL(invoice_type_lookup_code, ''STANDARD'') <> ''PAYMENT REQUEST'' ';
   ELSE
    l_stmt := l_stmt || ' AND invoice_id = ' || p_invoice_interface_id || ' ';
   END IF;

  EXECUTE IMMEDIATE l_stmt;

/*  IF (p_group_id IS NULL) THEN
    UPDATE ap_invoices_interface i
     SET org_id =  (SELECT hr.organization_id org_id
		    FROM   hr_operating_units hr,
			   per_business_groups per
		    WHERE  hr.business_group_id = per.business_group_id
		    AND    mo_global.check_access(hr.organization_id) = 'Y'
                    AND    hr.name = i.operating_unit)
     WHERE i.org_id is null
     AND i.operating_unit is not null
     AND ((status is NULL) OR (status = 'REJECTED'))
     AND   source = p_source
     AND ((p_invoice_interface_id IS NULL AND
         NVL(invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST')
         OR (invoice_id = p_invoice_interface_id))
     AND   NVL(workflow_flag,'D') = 'D' ;

  --Bug 6839034 Added ELSE part
  ELSE

    UPDATE ap_invoices_interface i
     SET org_id =  (SELECT hr.organization_id org_id
                    FROM   hr_operating_units hr,
                           per_business_groups per
                    WHERE  hr.business_group_id = per.business_group_id
                    AND    mo_global.check_access(hr.organization_id) = 'Y'
                    AND    hr.name = i.operating_unit)
     WHERE i.org_id is null
     AND   i.operating_unit is not null
     AND ((status is NULL) OR (status = 'REJECTED'))
     AND   source = p_source
     AND  group_id = p_group_id
     AND ((p_invoice_interface_id IS NULL AND
         NVL(invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST')
         OR (invoice_id = p_invoice_interface_id))
     AND   NVL(workflow_flag,'D') = 'D' ;

  END IF;
 */
/* BUG 8237318 - END modified the existing query to dynamic sql to skip the null checks
   for passing parameters in the query. */

  debug_info := '(Import_Invoices 4b) Getting Deafult Operating Unit '||
                'Information';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;


  Mo_Utils.get_default_ou(
    l_default_org_id,
    l_default_ou_name,
    l_ou_count);

  ----------------------------------------------------------------
  -- Step 5  Get number of invoices to process.
  ----------------------------------------------------------------
  debug_info := '(Import Invoices 5) Get The Total Number of Invoices '||
                'In Interface';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- Bug 4145391. To improve the performance of the import program coding two
  -- different select stmts based on the parameter p_group_id
/* BUG 8237318 - Begin modified the existing query to dynamic sql to skip the null checks
   for passing parameters in the query. */

  l_stmt := 'SELECT count(*) FROM ap_invoices_interface '
            ||'  WHERE source = ''' || p_source || ''' '
	    ||' AND ((status is NULL) or (status = ''REJECTED'')) ';



   IF p_group_id IS NOT NULL THEN
    l_stmt := l_stmt || ' AND group_id =  ''' || p_group_id || ''' ';
   END IF;

   IF p_invoice_interface_id IS NULL THEN
    l_stmt := l_stmt || ' AND NVL(invoice_type_lookup_code, ''STANDARD'') <> ''PAYMENT REQUEST'' ';
   ELSE
    l_stmt := l_stmt || ' AND invoice_id = ' || p_invoice_interface_id || ' ';
   END IF;

   IF p_org_id IS NULL THEN
    l_stmt := l_stmt || ' AND ( (org_id IS NULL) OR (org_id IS NOT NULL AND mo_global.check_access(org_id)= ''Y'' ) ) ';
   ELSE
    l_stmt := l_stmt || ' AND ( (org_id IS NULL) OR ( org_id  = ' || p_org_id || ') ) ';
   END IF;

   l_stmt := l_stmt || ' AND nvl(workflow_flag,''D'') = ''D'' AND  ROWNUM = 1 ';


   BEGIN
    EXECUTE IMMEDIATE l_stmt INTO l_total_count;

        IF (l_total_count = 0) THEN
          l_continue_flag := 'N';
        END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_continue_flag := 'N';
   END;


/*  IF (p_group_id IS NULL) THEN
      BEGIN
        SELECT count(*)
          INTO l_total_count
          FROM ap_invoices_interface
         WHERE ((status is NULL) or (status = 'REJECTED'))
           AND  source = p_source
           AND  ((p_invoice_interface_id IS NULL AND
                  NVL(invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST')
                      OR (invoice_id = p_invoice_interface_id))
           AND  nvl(workflow_flag,'D') = 'D'
           AND ((org_id      is NOT NULL AND
                 p_org_id    is NOT NULL AND
                org_id  = p_org_id)
                or (p_org_id is     NULL AND
                    org_id   is NOT NULL AND
                   (mo_global.check_access(org_id)= 'Y'))
                or (p_org_id is NOT NULL AND
                    org_id   is     NULL)
                or (p_org_id is     NULL AND
                    org_id   is     NULL))
           AND  ROWNUM = 1;

        IF (l_total_count = 0) THEN
          l_continue_flag := 'N';
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_continue_flag := 'N';
      END;

  ELSE
      BEGIN
        SELECT count(*)
          INTO l_total_count
          FROM ap_invoices_interface
         WHERE ((status is NULL) or (status = 'REJECTED'))
           AND  source = p_source
           AND  group_id = p_group_id
           AND  ((p_invoice_interface_id IS NULL AND
                  NVL(invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST')
                      OR (invoice_id = p_invoice_interface_id))
           AND  nvl(workflow_flag,'D') = 'D'
           AND ((org_id      is NOT NULL AND
                 p_org_id    is NOT NULL AND
                org_id  = p_org_id)
                or (p_org_id is     NULL AND
                    org_id   is NOT NULL AND
                   (mo_global.check_access(org_id)= 'Y'))
                or (p_org_id is NOT NULL AND
                    org_id   is     NULL)
                or (p_org_id is     NULL AND
                    org_id   is     NULL))
           AND  ROWNUM = 1;

        IF (l_total_count = 0) THEN
          l_continue_flag := 'N';
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_continue_flag := 'N';
      END;
  END IF;
*/

/* BUG 8237318 - End modified the existing query to dynamic sql to skip the null checks
   for passing parameters in the query. */

  -- Bug 5448579
  debug_info := '(Import_invoice 5.5)  Unwinding Caching Org Id/Name';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  FOR i IN 1..g_moac_ou_tab.COUNT
  LOOP
    l_index_org_id := g_moac_ou_tab(i).org_id;
    l_moac_org_table(l_index_org_id).org_id := g_moac_ou_tab(i).org_id;
    l_moac_org_table(l_index_org_id).org_name := g_moac_ou_tab(i).org_name;

   debug_info := 'Index Value: '||l_index_org_id
                 ||', MOAC Cached Org_Id: '||l_moac_org_table(l_index_org_id).org_id
                 ||', MOAC Cached Operating Unit: '|| l_moac_org_table(l_index_org_id).org_name;

   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;
  END LOOP;

  FOR i IN 1..g_fsp_ou_tab.COUNT
  LOOP
    l_index_org_id := g_fsp_ou_tab(i).org_id;
    l_fsp_org_table(l_index_org_id).org_id := g_fsp_ou_tab(i).org_id;

    debug_info := 'Index Value: '||l_index_org_id
                 ||', FSP Cached Org_Id: '||l_fsp_org_table(l_index_org_id).org_id;

   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;

  END LOOP;

  ----------------------------------------------------------------
  -- Step 6  LOOP through invoices/Instructions(Retropricing)
  ----------------------------------------------------------------
  WHILE (l_continue_flag = 'Y') LOOP

    debug_info := '(Import_invoice 6) Open import_invoices cursor';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- Bug 4145391. To improve the performance of the import program coding two
    -- different cursors based on the parameter p_group_id
    IF (p_group_id IS NULL) THEN
        OPEN import_invoices;
    ELSE
        OPEN import_invoices_group;
    END IF;

    LOOP
    BEGIN --veramach bug 7121842
      -- Retropricing:
      -- Invoice/Instructions LOOP, cursor size always be less or equal to p_commit_cycle
      ---------------------------------------------------------------
      -- Step 7 FETCH invoice interface record INTO invoice record
      ---------------------------------------------------------------

      debug_info := '(Import_invoice 7) FETCH import_invoices';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      -- Bug 4145391
      IF (p_group_id IS NULL) THEN
          FETCH import_invoices INTO l_invoice_rec;
          EXIT WHEN import_invoices%NOTFOUND
                 OR import_invoices%NOTFOUND IS NULL;
      ELSE
          FETCH import_invoices_group INTO l_invoice_rec;
          EXIT WHEN import_invoices_group%NOTFOUND
                 OR import_invoices_group%NOTFOUND IS NULL;
      END IF;

      --
      AP_IMPORT_INVOICES_PKG.g_inv_sysdate := TRUNC(sysdate);

      -- Set invoice counter to get invoice count for fetched invoices

      l_invoices_fetched := l_invoices_fetched + 1;
      -- show output values (only IF debug_switch = 'Y')

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,
         '------------------> invoice_id = '
         ||to_char(l_invoice_rec.invoice_id)
         ||' invoice_num  = '      ||l_invoice_rec.invoice_num
         ||' invoice_type_lookup_code  = '
         ||  l_invoice_rec.invoice_type_lookup_code
         ||' invoice_date  = '     ||to_char(l_invoice_rec.invoice_date)
         ||' po_number  = '        ||l_invoice_rec.po_number
         ||' vendor_id  = '        ||to_char(l_invoice_rec.vendor_id)
         ||' vendor_num  = '       ||l_invoice_rec.vendor_num
         ||' vendor_name  = '      ||l_invoice_rec.vendor_name
         ||' vendor_site_id  = '   ||to_char(l_invoice_rec.vendor_site_id)
         ||' vendor_site_code  = ' ||l_invoice_rec.vendor_site_code
         ||' party_id   = '        ||to_char(l_invoice_rec.party_id)
         ||' party_site_id  = '    ||to_char(l_invoice_rec.party_site_id)
         ||' pay_proc_trxn_type_code = ' ||l_invoice_rec.pay_proc_trxn_type_code
         ||' payment_function = '  ||l_invoice_rec.payment_function
         ||' invoice_amount = '    ||to_char(l_invoice_rec.invoice_amount)
         ||' base_currency_code = '    ||l_base_currency_code
         ||' invoice_currency_code  = '||l_invoice_rec.invoice_currency_code
         ||' payment_currency_code  = '||l_invoice_rec.payment_currency_code
         ||' exchange_rate  = '    ||to_char(l_invoice_rec.exchange_rate)
         ||' exchange_rate_type = '||l_invoice_rec.exchange_rate_type
         ||' exchange_date  = '    ||to_char(l_invoice_rec.exchange_date)
         ||' terms_id  = '         ||to_char(l_invoice_rec.terms_id)
         ||' terms_name  = '       ||l_invoice_rec.terms_name
         ||' description  = '      ||l_invoice_rec.description
         ||' awt_group_id  = '     ||to_char(l_invoice_rec.awt_group_id)
         ||' awt_group_name  = '   ||l_invoice_rec.awt_group_name
         ||' pay_awt_group_id  = '     ||to_char(l_invoice_rec.pay_awt_group_id)
         ||' pay_awt_group_name  = '   ||l_invoice_rec.pay_awt_group_name  --bug6639866
         ||' last_update_date  = ' ||to_char(l_invoice_rec.last_update_date)
         ||' last_updated_by  = '  ||to_char(l_invoice_rec.last_updated_by)
         ||' last_update_login  = '||to_char(l_invoice_rec.last_update_login)
         ||' creation_date  = '    ||to_char(l_invoice_rec.creation_date)
         ||' attribute_category = '||l_invoice_rec.attribute_category
         ||' attribute1 = '        ||l_invoice_rec.attribute1
         ||' attribute2 = '        ||l_invoice_rec.attribute2
         ||' attribute3 = '        ||l_invoice_rec.attribute3
         ||' attribute4 = '        ||l_invoice_rec.attribute4
         ||' attribute5 = '        ||l_invoice_rec.attribute5
         ||' attribute6 = '        ||l_invoice_rec.attribute6
         ||' attribute7 = '        ||l_invoice_rec.attribute7
         ||' attribute8 = '        ||l_invoice_rec.attribute8
         ||' attribute9 = '        ||l_invoice_rec.attribute9
         ||' attribute10 = '       ||l_invoice_rec.attribute10
         ||' attribute11 = '       ||l_invoice_rec.attribute11
         ||' attribute12 = '       ||l_invoice_rec.attribute12
         ||' attribute13 = '       ||l_invoice_rec.attribute13
         ||' attribute14 = '       ||l_invoice_rec.attribute14
         ||' attribute15 = '       ||l_invoice_rec.attribute15
         ||' global_attribute_category = '
         ||  l_invoice_rec.global_attribute_category
         ||' global_attribute1 = ' ||l_invoice_rec.global_attribute1
         ||' global_attribute2 = ' ||l_invoice_rec.global_attribute2
         ||' global_attribute3 = ' ||l_invoice_rec.global_attribute3
         ||' global_attribute4 = ' ||l_invoice_rec.global_attribute4
         ||' global_attribute5 = ' ||l_invoice_rec.global_attribute5
         ||' global_attribute6 = ' ||l_invoice_rec.global_attribute6
         ||' global_attribute7 = ' ||l_invoice_rec.global_attribute7
         ||' global_attribute8 = ' ||l_invoice_rec.global_attribute8
         ||' global_attribute9 = ' ||l_invoice_rec.global_attribute9
         ||' global_attribute10 = '||l_invoice_rec.global_attribute10
         ||' global_attribute11 = '||l_invoice_rec.global_attribute11
         ||' global_attribute12 = '||l_invoice_rec.global_attribute12
         ||' global_attribute13 = '||l_invoice_rec.global_attribute13
         ||' global_attribute14 = '||l_invoice_rec.global_attribute14
         ||' global_attribute15 = '||l_invoice_rec.global_attribute15
         ||' global_attribute16 = '||l_invoice_rec.global_attribute16
         ||' global_attribute17 = '||l_invoice_rec.global_attribute17
         ||' global_attribute18 = '||l_invoice_rec.global_attribute18
         ||' global_attribute19 = '||l_invoice_rec.global_attribute19
         ||' global_attribute20 = '||l_invoice_rec.global_attribute20
         ||' doc_category_code  = '||l_invoice_rec.doc_category_code
         ||' voucher_num  = '      ||l_invoice_rec.voucher_num
         ||' payment_method_code = '
         ||  l_invoice_rec.payment_method_code
         ||' pay_group_lookup_code = '||l_invoice_rec.pay_group_lookup_code
         ||' goods_received_date = '
         ||  to_char(l_invoice_rec.goods_received_date)
         ||' invoice_received_date = '
         ||  to_char(l_invoice_rec.invoice_received_date)
         ||' exclusive_payment_flag = '
         ||  l_invoice_rec.exclusive_payment_flag
         ||' prepay_num = '         ||l_invoice_rec.prepay_num
         ||' prepay_line_num = '    ||l_invoice_rec.prepay_line_num
         ||' prepay_apply_amount = '||l_invoice_rec.prepay_apply_amount
         ||' prepay_gl_date = '     ||l_invoice_rec.prepay_gl_date
         ||' set_of_books_id = '||l_invoice_rec.set_of_books_id
         ||' legal_entity_id = '||l_invoice_rec.legal_entity_id
         ||' tax_only_flag = '||l_invoice_rec.tax_only_flag
         ||' tax_only_rcv_matched_flag = '||l_invoice_rec.tax_only_rcv_matched_flag
	 --Third Party Payments
	 ||' remit_to_supplier_name = '||l_invoice_rec.remit_to_supplier_name
	 ||' remit_to_supplier_id = '||l_invoice_rec.remit_to_supplier_id
	 ||' remit_to_supplier_site = '||l_invoice_rec.remit_to_supplier_site
	 ||' remit_to_supplier_site_id = '||l_invoice_rec.remit_to_supplier_site_id
	 ||' relationship_id = '||l_invoice_rec.relationship_id
	 ||' remit_to_supplier_num = '||l_invoice_rec.remit_to_supplier_num
	);
      END IF;

      ---------------------------------------------------------------
      -- Step 8 Check for inconsistent OU
      ----------------------------------------------------------------
      debug_info := '(Import Invoices 8) Checking for Inconsistent OU';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF l_invoice_rec.org_id is NULL THEN
        IF (l_ou_count > 1 AND p_org_id is NULL) THEN
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                 l_invoice_rec.invoice_id,
                'NO OPERATING UNIT',
                l_default_last_updated_by,
                l_default_last_update_login,
                current_calling_sequence) <>  TRUE) THEN

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<- '||current_calling_sequence);
            END IF;
            Raise import_invoice_failure;
          END IF; --Insert rejections

          l_invoice_status := 'N';
          l_null_org_id    := TRUE;

        ELSIF (l_ou_count = 1 AND p_org_id is NULL) THEN

          UPDATE ap_invoices_interface
             SET org_id     =  l_default_org_id
           WHERE invoice_id =  l_invoice_rec.invoice_id ;

          l_invoice_rec.org_id := l_default_org_id;
          l_invoice_status     := 'Y';
          l_null_org_id        := TRUE;

        ELSIF (p_org_id is NOT NULL) THEN

          UPDATE ap_invoices_interface
             SET org_id     =  p_org_id
           WHERE invoice_id =  l_invoice_rec.invoice_id ;

          l_invoice_rec.org_id := p_org_id;
          l_invoice_status     := 'Y';
          l_null_org_id        := TRUE;

        END IF; -- OU count AND p_org_id

      ELSE -- invoice_rec.org_id is not null

      /* Following block is for bug 5140002 */
      /*  BEGIN

          SELECT org_id
          INTO  l_option_defined_org
          FROM  financials_system_parameters
          WHERE org_id = l_invoice_rec.org_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                 l_invoice_rec.invoice_id,
                 'UNDEFINED OPERATING UNIT',
                 l_default_last_updated_by,
                 l_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<- '||current_calling_sequence);
              END IF;
              Raise import_invoice_failure;
            END IF; -- Insert rejections

            l_invoice_status := 'N';
            l_null_org_id    := FALSE;

        END ; */

        -- Big 5448579. Replace the above lock
        IF l_fsp_org_table.exists(l_invoice_rec.org_id) THEN

          Null;

        ELSE

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
             (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                 l_invoice_rec.invoice_id,
                 'UNDEFINED OPERATING UNIT',
                 l_default_last_updated_by,
                 l_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<- '||current_calling_sequence);
              END IF;
              Raise import_invoice_failure;
           END IF; -- Insert rejections

            l_invoice_status := 'N';
            l_null_org_id    := FALSE;

        END IF;

        IF l_invoice_rec.operating_unit is NOT NULL THEN
         -- Bug 5448579
         -- l_derived_operating_unit :=
         --     mo_global.get_ou_name(l_invoice_rec.org_id);
         l_derived_operating_unit := l_moac_org_table(l_invoice_rec.org_id).org_name;

          debug_info := ' Derived Operating Unit: '||l_derived_operating_unit;
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
          END IF;

          IF l_invoice_rec.operating_unit <> l_derived_operating_unit THEN
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                 l_invoice_rec.invoice_id,
                 'INCONSISTENT OPERATING UNITS',
                 l_default_last_updated_by,
                 l_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<- '||current_calling_sequence);
              END IF;
              Raise import_invoice_failure;
            END IF; -- Insert rejections

            l_invoice_status := 'N';
            l_null_org_id    := FALSE;

          ELSE -- operating units are consistent

            l_invoice_status := 'Y';
            l_null_org_id    := FALSE;

          END IF;

        ELSE -- operating unit name was null in invoice rec

          l_invoice_status := 'Y';
          l_null_org_id    := FALSE;

        END IF;

      END IF; -- invoice rec org id is null


      -----------------------------------------------------
      -- Step 9 Set the org context AND cache lookup codes
      -- AND parameters.  IF batch control enabled, get batch
      -- id IF org id has changed.
      -----------------------------------------------------
      debug_info := '(Import Invoice 9a) Setting the org Context';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      -- Commented l_invoice_status condition for Bug 9452076.
      -- AP_IMPORT_UTILITIES_PKG.get_info needs to be invoked to fetch
      -- the setup information even though org exception exists.
      --IF l_invoice_status = 'Y' THEN
        IF l_invoice_rec.org_id <> NVL(l_old_org_id, -3115) THEN
          Mo_Global.set_policy_context('S', l_invoice_rec.org_id);

          -- bug7531219 setting the ledger context to get only
          -- valid Balancing and Management segments for the ledger
          begin
                GL_GLOBAL.set_aff_validation(context_type => 'OU',
                                               context_id => l_invoice_rec.org_id);
          exception
                when others then
                 null;
          end;

          debug_info := '(Import_invoice 9b) Call get_info to get '||
                        'required info';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.get_info(
                l_invoice_rec.org_id,              -- IN
                l_set_of_books_id,                 -- OUT NOCOPY
                l_multi_currency_flag,             -- OUT NOCOPY
                l_make_rate_mandatory_flag,        -- OUT NOCOPY
                l_default_exchange_rate_type,      -- OUT NOCOPY
                l_base_currency_code,              -- OUT NOCOPY
                l_batch_control_flag,              -- OUT NOCOPY
                l_invoice_currency_code,           -- OUT NOCOPY
                l_base_min_acct_unit,              -- OUT NOCOPY
                l_base_precision,                  -- OUT NOCOPY
                l_sequence_numbering,              -- OUT NOCOPY
                l_awt_include_tax_amt,             -- OUT NOCOPY
                l_gl_date_from_get_info,           -- IN OUT NOCOPY
             -- l_ussgl_transcation_code,          -- OUT NOCOPY  -Bug 4277744
                l_transfer_po_desc_flex_flag,      -- OUT NOCOPY
                l_gl_date_from_receipt_flag,       -- OUT NOCOPY
                l_purch_encumbrance_flag,          -- OUT NOCOPY
		l_retainage_ccid,		   -- OUT NOCOPY
                l_pa_installed,                    -- OUT NOCOPY
                l_chart_of_accounts_id,            -- OUT NOCOPY
                l_inv_doc_cat_override,            -- OUT NOCOPY
                l_calc_user_xrate,                 -- OUT NOCOPY
                current_calling_sequence,
                l_approval_workflow_flag,          -- OUT NOCOPY
                l_freight_code_combination_id,     -- OUT NOCOPY
		l_allow_interest_invoices,	   -- OUT NOCOPY
		l_add_days_settlement_date,	   -- OUT NOCOPY  --bug4930111
                l_disc_is_inv_less_tax_flag,       -- OUT NOCOPY  --bug4931755
                AP_IMPORT_INVOICES_PKG.g_source,   -- IN          --bug5382889 LE TimeZone
                l_invoice_rec.invoice_date,        -- IN          --bug5382889 LE TimeZone
                l_invoice_rec.goods_received_date, -- IN          --bug5382889 LE TimeZone
                l_asset_book_type                  -- OUT NOCOPY  --Bug 5448579
		) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'get_info<-'||current_calling_sequence);
            END IF;
            Raise import_invoice_failure;
          END IF;
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '------------------> '
            ||' p_org_id = '||to_char(l_invoice_rec.org_id)
            ||' p_set_of_books_id = '|| to_char(l_set_of_books_id)
            ||' l_multi_currency_flag  = '||l_multi_currency_flag
            ||' l_make_rate_mANDatory_flag  = '||l_make_rate_mandatory_flag
            ||' l_default_exchange_rate_type  = '
            ||  l_default_exchange_rate_type
            ||' l_base_currency_code  = '  ||l_base_currency_code
            ||' l_batch_control_flag  = '  ||l_batch_control_flag
            ||' l_payment_cross_rate  = '
            ||  to_char(l_invoice_rec.payment_cross_rate)
            ||' l_base_min_acct_unit  = '  ||to_char(l_base_min_acct_unit)
            ||' l_base_precision  = '      ||to_char(l_base_precision)
            ||' l_sequence_numbering  = '  ||l_sequence_numbering
            ||' l_awt_include_tax_amt  = ' ||l_awt_include_tax_amt
            ||' l_gl_date_from_get_info = ' ||to_char(l_gl_date_from_get_info)
         -- Removed for bug 4277744
         -- ||' l_ussgl_transcation_code  = '||l_ussgl_transcation_code
            ||' l_gl_date_from_receipt_flag = '||l_gl_date_from_receipt_flag
            ||' l_purch_encumbrance_flag = '||l_purch_encumbrance_flag
            ||' l_chart_of_accounts_id  = ' ||to_char(l_chart_of_accounts_id)
            ||' l_pa_installed  = '         ||l_pa_installed
            ||' l_positive_price_tolerance = '
            ||  to_char(l_positive_price_tolerance)
            ||' l_negative_price_tolerance  = '
            ||  to_char(l_negative_price_tolerance)
            ||' l_qty_tolerance  = '        ||to_char(l_qty_tolerance)
            ||' l_max_qty_ord_tolerance = ' ||to_char(l_max_qty_ord_tolerance)
            ||' l_inv_doc_cat_override  = '     ||l_inv_doc_cat_override
	    ||' l_allow_interest_invoices = '   ||l_allow_interest_invoices);
          END IF;

  -- Retek Integration bug 6349739
  IF AP_IMPORT_INVOICES_PKG.g_source = 'RETEK' THEN
      -- get the segment delimiter
      AP_IMPORT_INVOICES_PKG.g_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                                    'SQLGL',
                                                    'GL#',
                                                    l_chart_of_accounts_id);
  END IF;

          --------------------------------------------------------
          -- Step 9c
          -- Get batch_id first IF batch_control is on
          -- This batch_id is for the Invoice Batch Name
          -- Retropricing: It seems the get_batch_id will be called
          -- again and again for new batches creating a gap in the
          -- batch sequence
          --------------------------------------------------------
          IF (NVL(l_batch_control_flag,'N') = 'Y'
              AND l_batch_id IS NULL /* Added for bug#7294733 */
             )
          THEN
            debug_info := '(Import_invoice 9c) Get batch_id IF '||
                          'batch_control is on';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

              IF (AP_IMPORT_UTILITIES_PKG.get_batch_id(
                    p_batch_name,
                    l_batch_id,
                    l_batch_type,
                    current_calling_sequence) <> TRUE) THEN

                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,
                     'get_batch_id<-'||current_calling_sequence);
                END IF;
                Raise import_invoice_failure;

              END IF;
            --
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   '------------------> l_batch_id = '  || to_char(l_batch_id)
                  ||' l_batch_type = '||l_batch_type);
            END IF;

            ----------------------------------------------------------------
            -- IF there is no batch id AND batch control is turned on
            -- batch error is raised AND STOP PROCESSING. Fatal error message
            -- should be Printed on the report in this case.We do not have
            -- a reject code in this case.
            ----------------------------------------------------------------
            IF ( l_batch_id is NULL )  THEN
              p_batch_error_flag := 'Y';
              RETURN(TRUE);
            ELSE
              p_print_batch := 'Y';
            END IF;

          END IF; -- NVL(l_batch_control_flag,'N') = 'Y'
        END IF; -- org id is <> old org id
      --END IF; -- invoice status = Y. Commented for bug 9452076.


      ----------------------------------------------------------------
      -- Retropricing:  IF source = 'PPA' Go to Step 16.
      ----------------------------------------------------------------
      IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN
      --
          -----------------------------------------------------
          -- Step 10 Get GL Date
          -----------------------------------------------------
          --
          IF (l_invoice_rec.gl_date is NOT NULL) THEN
                debug_info := '(Import Invoice 10a) Default GL Date From Invoice ';
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                END IF;
          ELSE
            debug_info := '(Import Invoice 10b) Default GL Date Based on Calculation ';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            -- Bug 5654581. Moving Gl_Date Related code here
	     /* Added AND condition to following IF for bug 9804420 */
            IF  (AP_IMPORT_INVOICES_PKG.g_source = 'ERS'
		 AND p_gl_date IS NULL) THEN     -- bug 5382889, LE TimeZone

              debug_info := 'Determine gl_date for ERS invoice';

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                 AP_IMPORT_UTILITIES_PKG.Print
                  (AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
              END IF;

              l_rts_txn_le_date :=  INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Ou(
                          p_trxn_date    => nvl(l_invoice_rec.goods_received_date,
                                                l_invoice_rec.invoice_date)
                         ,p_ou_id        => l_invoice_rec.org_id);

              l_inv_le_date :=  INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Ou(
                          p_trxn_date    => l_invoice_rec.invoice_date
                         ,p_ou_id        => l_invoice_rec.org_id);

              l_sys_le_date :=  INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Ou(
                          p_trxn_date    => sysdate
                         ,p_ou_id        => l_invoice_rec.org_id);


             /* The gl_date id determined from the flag gl_date_from_receipt_flag
              If the flag = 'I' -- take Invoice_date
                    = 'S' -- take System date
                   = 'N' -- take nvl(receipt_date, invoice_date)
                   = 'Y' -- take nvl(receipt_date, sysdate)
              Note here that the Invoice date is no longer the same as the receipt_date,
              i.e. the RETURN tranasaction_date , so case I and N are no longer the same */

              debug_info := 'Determine invoice gl_date from LE Timezone API ';
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print
                  (AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
              END IF;

              If (l_gl_date_from_receipt_flag = 'I') Then
                l_inv_gl_date := l_inv_le_date;
              Elsif (l_gl_date_from_receipt_flag = 'N') Then
                l_inv_gl_date := nvl(l_rts_txn_le_date, l_inv_le_date);
              Elsif (l_gl_date_from_receipt_flag = 'S') Then
                l_inv_gl_date := l_sys_le_date;
              Elsif (l_gl_date_from_receipt_flag = 'Y') Then
                l_inv_gl_date := nvl(l_rts_txn_le_date, l_sys_le_date);
              End if;

              l_invoice_rec.gl_date  := l_inv_gl_date;

            ELSE

              IF p_gl_date IS NULL THEN

                IF (l_gl_date_from_receipt_flag IN ('S', 'Y')) THEN
                  debug_info := ' GL Date is Sysdate based on gl_date_reciept_flaf option';
                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                    AP_IMPORT_UTILITIES_PKG.Print
                      (AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                  END IF;

                  l_invoice_rec.gl_date := AP_IMPORT_INVOICES_PKG.g_inv_sysdate;

                ELSE

                  IF l_invoice_rec.invoice_date is NOT NULL THEN
                    debug_info := ' GL Date is Invoice Date';
                    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                      AP_IMPORT_UTILITIES_PKG.Print
                      (AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                    END IF;

                    l_invoice_rec.gl_date := l_invoice_rec.invoice_date;
                  ELSE
                    debug_info := ' GL Date is Sysdate Date';
                    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                      AP_IMPORT_UTILITIES_PKG.Print
                      (AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                    END IF;

                    l_invoice_rec.gl_date := AP_IMPORT_INVOICES_PKG.g_inv_sysdate;
                  END IF;

                END IF;

              ELSE

                debug_info := ' GL Date is Parameter Gl Date';
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print
                      (AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                END IF;

                l_invoice_rec.gl_date := p_gl_date;
              END IF;

            END IF;   --- end g_source = 'ERS'

            /*
            IF l_gl_date_from_get_info is NULL THEN
              IF l_invoice_rec.invoice_date is NOT NULL THEN
                l_invoice_rec.gl_date := l_invoice_rec.invoice_date;
              ELSE
                l_invoice_rec.gl_date := AP_IMPORT_INVOICES_PKG.g_inv_sysdate;
              END IF;
            ELSIF l_gl_date_from_get_info is NOT NULL THEN
              l_invoice_rec.gl_date := l_gl_date_from_get_info;
            END IF; */
          END IF;

          l_invoice_rec.invoice_date := TRUNC(l_invoice_rec.invoice_date);
          l_invoice_rec.gl_date      := TRUNC(l_invoice_rec.gl_date);

        -- For bug 2984396. Added by LGOPALSA.
        -- Added trunc for all date variables.

         If l_invoice_rec.exchange_date is not null Then
              l_invoice_rec.exchange_date :=
                    trunc(l_invoice_rec.exchange_date);
         End if;

         If l_invoice_rec.goods_received_date is not null Then
              l_invoice_rec.goods_received_date :=
                    trunc(l_invoice_rec.goods_received_date);
         End if;

         If l_invoice_rec.invoice_received_date is not null Then
              l_invoice_rec.invoice_received_date :=
                    trunc(l_invoice_rec.invoice_received_date);
         End if;

         If l_invoice_rec.terms_date is not null Then
              l_invoice_rec.terms_date := trunc(l_invoice_rec.terms_date);
         End if;

      -- End for bug2984396.

          ----------------------------
          -- Step 11
          -- Validate invoice level
          ----------------------------

          debug_info := '(Import_invoice 11) Validate invoice ';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
          END IF;
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, 'SOBID is :'||
                    l_invoice_rec.set_of_books_id);

          IF (AP_IMPORT_VALIDATION_PKG.v_check_invoice_validation
                   (l_invoice_rec,                  -- IN OUT
                    l_match_mode,                   -- OUT
                    l_min_acct_unit,                -- OUT
                    l_precision,                    -- OUT
		    l_positive_price_tolerance,     -- OUT
		    l_negative_price_tolerance,     -- OUT
		    l_qty_tolerance,                -- OUT
		    l_qty_rec_tolerance,            -- OUT
		    l_max_qty_ord_tolerance,        -- OUT
		    l_max_qty_rec_tolerance,        -- OUT
		    l_amt_tolerance,		    -- OUT
		    l_amt_rec_tolerance,	    -- OUT
		    l_max_amt_ord_tolerance,	    -- OUT
		    l_max_amt_rec_tolerance,	    -- OUT
		    l_goods_ship_amt_tolerance,     -- OUT
		    l_goods_rate_amt_tolerance,     -- OUT
		    l_goods_total_amt_tolerance,    -- OUT
		    l_services_ship_amt_tolerance,  -- OUT
		    l_services_rate_amt_tolerance,  -- OUT
		    l_services_total_amt_tolerance, -- OUT
                    l_base_currency_code,           -- IN
                    l_multi_currency_flag,          -- IN
                    l_set_of_books_id,              -- IN
                    l_default_exchange_rate_type,   -- IN
                    l_make_rate_mandatory_flag,     -- IN
                    l_default_last_updated_by,      -- IN
                    l_default_last_update_login,    -- IN
                    l_fatal_error_flag,             -- OUT
                    l_invoice_status,               -- OUT
                    l_calc_user_xrate,              -- IN
                    l_prepay_period_name,	    -- IN OUT
		    l_prepay_invoice_id,	    -- OUT  --Contract Payments
		    l_prepay_case_name,		    -- OUT  --Contract Payments
                    p_conc_request_id,
		    l_allow_interest_invoices,	    -- IN
                    current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'v_check_invoice_validation<-'||current_calling_sequence);
            END IF;
            Raise import_invoice_failure;
          END IF;
          --
          -- show output values (only IF debug_switch = 'Y')
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print( AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '------------------> vendor_id = '||to_char(l_invoice_rec.vendor_id)
            ||' vendor_site_id = '          ||to_char(l_invoice_rec.vendor_site_id)
            ||' invoice_status = '          ||l_invoice_status
            ||' terms_id = '                ||to_char(l_invoice_rec.terms_id)
            ||' fatal_error_flag = '        ||l_fatal_error_flag
            ||' invoice_type_lookup_code = '
            ||l_invoice_rec.invoice_type_lookup_code
            ||' match_mode  = '             ||l_match_mode);
          END IF;

          IF (( l_invoice_status = 'Y') AND
              (NVL(l_fatal_error_flag,'N') = 'N')) THEN

            --------------------------
            -- Step 12
            -- Validate invoice lines
            --------------------------
            debug_info := '(Import_invoice 12) Validate line';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, 'SOBID is :'||l_invoice_rec.set_of_books_id);

            IF (AP_IMPORT_VALIDATION_PKG.v_check_lines_validation (
                    l_invoice_rec,                    -- IN
                    l_invoice_lines_tab,              -- OUT NOCOPY
                    l_invoice_rec.gl_date,            -- IN
                    l_gl_date_from_receipt_flag,      -- IN
                    l_positive_price_tolerance,       -- IN
                    l_pa_installed,                   -- IN
                    l_qty_tolerance,                  -- IN
		    l_amt_tolerance,		      -- IN
                    l_max_qty_ord_tolerance,          -- IN
		    l_max_amt_ord_tolerance,	      -- IN
                    l_min_acct_unit,                  -- IN
                    l_precision,                      -- IN
                    l_base_currency_code,             -- IN
                    l_base_min_acct_unit,             -- IN
                    l_base_precision,                 -- IN
                    l_set_of_books_id,                -- IN
                    l_asset_book_type,                -- IN -- Bug 5448579
                    l_chart_of_accounts_id,           -- IN
                    l_freight_code_combination_id,    -- IN
                    l_purch_encumbrance_flag,         -- IN
		    l_retainage_ccid,		      -- IN
                    l_default_last_updated_by,        -- IN
                    l_default_last_update_login,      -- IN
                    l_invoice_status,                 -- OUT NOCOPY
                    current_calling_sequence) <> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'v_check_lines_validation<-'||current_calling_sequence);
              END IF;
            Raise import_invoice_failure;
            END IF;
          END IF;

          AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, 'invoice_status is:'||l_invoice_status);

          -- Payment Request: Do not call eTax API for Payment Requests
          IF ((l_invoice_status = 'Y') AND
                 (l_invoice_rec.invoice_type_lookup_code <> 'PAYMENT REQUEST')) THEN
            --------------------------------------------------------------
            -- Step 13.  Call validate eTax API.  This API will validate
            -- tax information for taxable and tax lines.
            --------------------------------------------------------------
            debug_info := '(Import_invoice 13) Validate tax info for '||
                          'tax and taxable lines';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;


            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, 'SOBID is :'||l_invoice_rec.set_of_books_id);
            -- assigning the following variable that was included in the
            -- header rec (denormalized)
            -- this variable will be used by Tax
            l_invoice_rec.set_of_books_id := l_set_of_books_id;

            --------------------------------------------------------------
            -- Call validate eTax API.  This API will validate tax info
            -- for taxable and tax lines.
            --------------------------------------------------------------

            IF NOT (ap_etax_services_pkg.validate_default_import(
                      p_invoice_rec             => l_invoice_rec,
                      p_invoice_lines_tab       => l_invoice_lines_tab,
                      p_calling_mode            => 'VALIDATE IMPORT',
                      p_all_error_messages      => 'Y',
                      p_invoice_status          => l_invoice_status,
                      p_error_code              => l_error_code,
                      p_calling_sequence        => current_calling_sequence)) THEN

                IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y'  THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'ap_etax_services_pkg.validate_default_import<-'||current_calling_sequence);

                END IF;

                -- If the validation call fails the import process fails.
                -- The validate_default_import will populate the rejections table
                -- for the import if required.
                -- If the API fails because the call to the eTax service fails
                -- the following code will get the messages from the message
                -- stack

                IF (l_error_code IS NOT NULL) THEN
                  -- Print the error returned from the service even if the debug
                  -- mode is off
                  AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);

                ELSE
                  -- If the l_error_code is null is because the service returned
                  -- more than one error.  The calling module will need to get
                  -- them from the message stack
                  LOOP
                    l_error_code := FND_MSG_PUB.Get;

                    IF l_error_code IS NULL THEN
                      EXIT;
                    ELSE
                      AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);
                    END IF;
                  END LOOP;

                END IF;
                Raise import_invoice_failure;

            END IF;

          END IF;

          IF (l_invoice_status = 'Y') THEN

            ------------------------------------
            -- Step 14
            -- Call Sequential Numbering Routine
            ------------------------------------
            debug_info := '(Import_invoice 14) Get Doc Sequence';
            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, 'SOBID is :'||l_invoice_rec.set_of_books_id);

            IF (AP_IMPORT_UTILITIES_PKG.get_doc_sequence (
                l_invoice_rec,                       -- IN OUT
                l_inv_doc_cat_override,              -- IN
                l_set_of_books_id,                   -- IN
                l_sequence_numbering,                -- IN
                l_default_last_updated_by,           -- IN
                l_default_last_update_login,         -- IN
                l_seqval,                            -- OUT NOCOPY
                l_dbseqnm,                           -- OUT NOCOPY
                l_dbseqid,                           -- OUT NOCOPY
                l_invoice_status,                    -- OUT NOCOPY
                current_calling_sequence)<> TRUE) THEN

              IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y'  THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'get_doc_sequence<-'||current_calling_sequence);
              END IF;
              Raise import_invoice_failure;
            END IF;

            -- show output values (only IF debug_switch = 'Y')

            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    '------------------> l_invoice_status = '|| l_invoice_status
                    ||' l_seqval =  '||to_char(l_seqval)
                    ||' l_dbseqnm = '||l_dbseqnm
                    ||' l_dbseqid = '||to_char(l_dbseqid));
            END IF;
          END IF;  -- Invoice Status = 'Y'before get_doc_sequence

          ---------------------------------------------------------------
          -- Step 15 Process invoice AND lines IF l_invoice_status is 'Y'
          --          or skip these steps
          ----------------------------------------------------------------
          IF (l_invoice_status = 'Y') THEN

            -----------------------------------------------------
            -- Step 15.1a
            -- Get some required fields for creating invoices
            --  most of them are from po_vendor_sites
            -----------------------------------------------------
            debug_info := '(Import_invoice 15.1a) Call get_invoice_info';
            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            IF (AP_IMPORT_UTILITIES_PKG.get_invoice_info(
                    l_invoice_rec,               --  IN OUT NOCOPY
                    l_default_last_updated_by,   -- IN
                    l_default_last_update_login, -- IN
                    l_pay_curr_invoice_amount,   --  OUT NOCOPY
                    l_payment_priority,          --  OUT NOCOPY
                    l_invoice_amount_limit,      --  OUT NOCOPY
                    l_hold_future_payments_flag, --  OUT NOCOPY
                    l_supplier_hold_reason,      --  OUT NOCOPY
                    l_exclude_freight_from_disc, --  OUT NOCOPY /* bug 4931755 */
                    current_calling_sequence ) <> TRUE) THEN
              IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'get_invoice_info<-'||current_calling_sequence);
              END IF;
              Raise import_invoice_failure;

            END IF;

            -- show output values (only IF debug_switch = 'Y')

            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y'  THEN
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
               '------------------> l_pay_curr_invoice_amount  = '
              ||to_char(l_pay_curr_invoice_amount)
              ||' l_payment_priority  = '         ||to_char(l_payment_priority)
              ||' l_invoice_amount_limit  = '     ||to_char(l_invoice_amount_limit)
              ||' l_hold_future_payments_flag  = '||l_hold_future_payments_flag
              ||' l_supplier_hold_reason  = '     ||l_supplier_hold_reason );
            END IF;

-- Bug 7588730: Start: Uncommenting the code which is required to initiliaze GDF for JG.
-- Bug 4014019: Commenting the call to jg_globe_flex_val due to build issues.

            -----------------------------------------------------
            -- Step 15.1b
            -- Update global_context_code with the right
            -- value corresponding to flexfield JG_AP_INVOICES
            -----------------------------------------------------
            debug_info := '(Import_invoice 15.1b) Update global context code';
            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            -- > IN   global context code in interface table
            -- > OUT NOCOPY  global context code in base table


            IF ( jg_globe_flex_val.reassign_context_code(
                    l_invoice_rec.global_attribute_category) <> TRUE) THEN
              --Bug8876668
		jg_globe_flex_val.reject_invalid_context_code(
		'APXIIMPT',
		AP_IMPORT_INVOICES_PKG.g_invoices_table,
                l_invoice_rec.invoice_id,
                l_default_last_updated_by,
                l_default_last_update_login,
		l_invoice_rec.global_attribute_category,
		l_reject_status_code,
                current_calling_sequence);

		IF (l_reject_status_code <>  'Y') THEN
		    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
				AP_IMPORT_UTILITIES_PKG.Print(
	                        AP_IMPORT_INVOICES_PKG.g_debug_switch,
		                'reassign_context_code<-'||current_calling_sequence);
		    END IF;
	            Raise import_invoice_failure;
		END IF;
		--End of Bug8876668
            END IF;

-- Bug 7588730: End: Uncommenting the code which is required to initiliaze GDF for JG.

            ----------------------------------------------------------
            -- Step 15.2
            -- Insert record INTO ap_invoices
            ----------------------------------------------------------
            debug_info := '(Import_invoice 15.2) Insert record INTO ap_invoices';
            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

            -- Payment Request: Added p_needs_invoice_approval for payment requests
            IF (AP_IMPORT_UTILITIES_PKG.insert_ap_invoices(
                    l_invoice_rec,               --  IN OUT
                    l_base_invoice_id,           --  OUT NOCOPY
                    l_set_of_books_id,           --  IN
                    l_dbseqid,                   --  IN
                    l_seqval,                    --  IN
                    l_batch_id,                  --  IN
                    l_pay_curr_invoice_amount,   --  IN
                    l_approval_workflow_flag,    --  IN
                    p_needs_invoice_approval,
		    l_add_days_settlement_date,   --  IN --bug 4930111
                    l_disc_is_inv_less_tax_flag,  --  IN --bug 4931755
                    l_exclude_freight_from_disc,  --  IN --bug 4931755
                    current_calling_sequence) <> TRUE) THEN
              IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    '<-'||current_calling_sequence);
              END IF;

              Raise import_invoice_failure;
            END IF;

            -- Set counter for created invoices
            l_valid_invoices_count := l_valid_invoices_count +1;

            l_total_invoice_amount := l_total_invoice_amount +
                          NVL(l_invoice_rec.no_xrate_base_amount,
                              l_invoice_rec.invoice_amount);
            l_actual_invoice_total := l_actual_invoice_total +
                          l_invoice_rec.invoice_amount;

            g_invoice_id := l_base_invoice_id;

            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y'  THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  '------------------> l_base_invoice_id = '
                  || to_char(l_base_invoice_id)
                  ||' l_valid_invoices_count = '||to_char(l_valid_invoices_count));
            END IF;

            ---------------------------------------------------------------
            -- Step 15.3: Call AP_CREATE_PAY_SCHEDS_PKG.AP_Create_From_Terms
            -- Insert payment schedules FROM term
            ---------------------------------------------------------------

            debug_info := '(Import_invoice 15.3) Insert payment schedules '||
                          'from terms';
            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            AP_CREATE_PAY_SCHEDS_PKG.Create_payment_schedules(
             p_invoice_id               =>l_base_invoice_id,
             p_terms_id                 =>l_invoice_rec.terms_id,
             p_last_updated_by          =>l_invoice_rec.last_updated_by,
             p_created_by               =>l_invoice_rec.created_by,
             p_payment_priority         =>l_payment_priority,
             p_batch_id                 =>l_batch_id,
             p_terms_date               =>l_invoice_rec.terms_date,
             p_invoice_amount           =>l_invoice_rec.invoice_amount,
             p_pay_curr_invoice_amount  =>l_pay_curr_invoice_amount,
             p_payment_cross_rate       =>l_invoice_rec.payment_cross_rate,
             p_amount_for_discount      =>
                         l_invoice_rec.amount_applicable_to_discount,
             p_payment_method           =>l_invoice_rec.payment_method_code,
             p_invoice_currency         =>l_invoice_rec.invoice_currency_code,
             p_payment_currency         =>l_invoice_rec.payment_currency_code,
             p_calling_sequence         =>current_calling_sequence);


            -------------------------------------------------------------
            -- Step 15.4: Insert holds for this invoice.
            --  There are 2 holds FROM supplier site AND 1 hold FROM input
            --  parameter.
            -------------------------------------------------------------
            debug_info := '(Import_invoice 15.4) Insert holds for this invoice';
            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            IF (AP_IMPORT_UTILITIES_PKG.insert_holds(
                    l_base_invoice_id,
                    p_hold_code,
                    p_hold_reason,
                    l_hold_future_payments_flag,
                    l_supplier_hold_reason,
                    l_invoice_amount_limit,
                    /*bug fix:3022381 Added the NVL condition*/
                    nvl(l_invoice_rec.no_xrate_base_amount,   -- Bug 4692091. Added ap_round_currency
		     ap_utilities_pkg.ap_round_currency(
                l_invoice_rec.invoice_amount*nvl(l_invoice_rec.exchange_rate,1),
                l_invoice_rec.invoice_currency_code)),
                    l_invoice_rec.last_updated_by,
                    current_calling_sequence ) <> TRUE) THEN

              IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,'<-'||
                  current_calling_sequence);
              END IF;
              Raise import_invoice_failure;
            END IF;

            --------------------------------------------------------------
            -- Step 15.5:
            -- Create invoice lines
            --------------------------------------------------------------
            debug_info := '(Import_invoice 15.5) Create invoice lines';
            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;


            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, 'SOBID is :'||l_invoice_rec.set_of_books_id);

            IF (AP_IMPORT_UTILITIES_PKG.create_lines(
                    l_batch_id,
                    l_base_invoice_id,
                    l_invoice_lines_tab,
                    l_base_currency_code,
                    l_set_of_books_id,
                    l_approval_workflow_flag,
		    l_invoice_rec.tax_only_flag,
		    l_invoice_rec.tax_only_rcv_matched_flag,
                    l_default_last_updated_by,
                 l_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN

              IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'create_lines<-'||current_calling_sequence);
                Raise import_invoice_failure;
              END IF;
            END IF;

            --------------------------------------------------------------
            -- Step 15.6:
            -- Execute the Argentine/Colombian defaulting procedure
            --------------------------------------------------------------
            debug_info := '(Import_invoice 15.6) Execute the '||
                          'Argentine/Colombian defaulting procedure';
            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

	    --Bugfix:4674229
            DECLARE
              l_awt_success   Varchar2(1000);
            BEGIN
              AP_EXTENDED_WITHHOLDING_PKG.Ap_Ext_Withholding_Default(
                   P_Invoice_Id => l_base_invoice_id,
		   P_Inv_Line_Num => NULL,
		   P_Inv_Dist_Id  => NULL,
		   P_calling_module => 'IMPORT',
		   P_Parent_Dist_Id => NULL,
                   P_Awt_Success => l_awt_success);
              IF (l_awt_success <> 'SUCCESS') THEN
                IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'ap_ext_withholding_default<-'||current_calling_sequence);
                END IF;
                Raise import_invoice_failure;
              END IF;
            END;

            --------------------------------------------------------------
            -- Step 15.7:
            -- If the user intention is to import TAX, eTax will be call to
            -- import the lines previous to any prepayment application.
            -- If the user intention is calculate and there is a prepayment
            -- application tax will be calculated during the prepayment
            -- application for the whole invoice.   If there is no prepayment
            -- application, eTax will be called to calculate.
            --------------------------------------------------------------

            debug_info := '(Import_invoice 15.7) Call import before any prepayment '||
                          'application if the user intention is to import TAX';

            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;


            IF ( l_invoice_rec.calc_tax_during_import_flag = 'N') THEN
              --------------------------------------------------------------
              -- Step 15.7a. Call import document with tax.
              -- If it is a tax only invoice and has a receipt matched tax
              -- line, call calculate instead of import and call determine
              -- recovery right after because tax-only lines had been created
              --------------------------------------------------------------
              debug_info := '(Import_invoice 15.7a) User intention is to import TAX';

              IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
              END IF;

              IF ( NVL(l_invoice_rec.tax_only_rcv_matched_flag, 'N') = 'Y') THEN
                -----------------------------------------------------------------
                -- Step 15.7b.  Invoice is tax only and is matched to receipt
                -- call to  calculate tax is required
                -----------------------------------------------------------------

                debug_info := '(Import_invoice 15.7b) Invoice is tax only and is matched to receipt '||
                              'so calculate shoould be called instead of import';

                IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                END IF;

                IF NOT (ap_etax_pkg.calling_etax(
                        p_invoice_id             => l_base_invoice_id,
                        p_calling_mode           => 'CALCULATE IMPORT',
                        p_override_status        => NULL,
                        p_line_number_to_delete  => NULL,
                        P_Interface_Invoice_Id   => l_invoice_rec.invoice_id,
                        p_all_error_messages     => 'Y',
                        p_error_code             => l_error_code,
                        p_calling_sequence       => current_calling_sequence)) THEN

                  -- If the call to calculate fails,  the import process will
                  -- fail.  In this case the invoice cannot be imported since
                  -- user is trying to import tax lines
                  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y'  THEN
                    AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      'ap_etax_pkg.calling_etax(CALCULATE IMPORT)<-'||current_calling_sequence);

                  END IF;

                  -- If the API fails because the call to the eTax service fails
                  -- the following code will get the messages from the message
                  -- stack

                  IF (l_error_code IS NOT NULL) THEN
                    -- Print the error returned from the service even if the debug
                    -- mode is off
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);

                  ELSE
                    -- If the l_error_code is null is because the service returned
                    -- more than one error.  The calling module will need to get
                    -- them from the message stack
                    LOOP
                      l_error_code := FND_MSG_PUB.Get;
                      IF l_error_code IS NULL THEN
                        EXIT;
                      ELSE
                        AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);
                      END IF;
                    END LOOP;
                  END IF;  -- if l_error_code is not null

                  RAISE import_invoice_failure;
                END IF;

              ELSE -- tax_only_rcv_matched_flag is N.  We will call import tax service
                --------------------------------------------------------------
                -- Step 15.7c. For any other case call import document with tax.
                -- In this case could be necesary to populate a pseudo trx line
                -- in the global temp tables to pass to eTax the additional
                -- info in the tax line. This is handled in the population of
                -- the temp tables in the validation API since we are using the
                -- same information provided at that time.
                --------------------------------------------------------------

                IF (NVL(l_invoice_rec.tax_only_flag, 'N') = 'Y') THEN -- tax_only_flag is Y.

                  debug_info := '(Import_invoice 15.7c) Invoice is tax only '||
                                'but not matched to receipt so call IMPORT TAX';

                  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                    AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                  END IF;

                  IF NOT (ap_etax_pkg.calling_etax(
                          p_invoice_id             => l_base_invoice_id,
                          p_calling_mode           => 'IMPORT INTERFACE',
                          p_override_status        => NULL,
                          p_line_number_to_delete  => NULL,
                          P_Interface_Invoice_Id   => l_invoice_rec.invoice_id,
                          p_all_error_messages     => 'Y',
                          p_error_code             => l_error_code,
                          p_calling_sequence       => current_calling_sequence)) THEN

                    -- If the import of tax fails, the import process will fail.
                    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y'  THEN
                      AP_IMPORT_UTILITIES_PKG.Print(
                        AP_IMPORT_INVOICES_PKG.g_debug_switch,
                        'ap_etax_pkg.calling_etax(IMPORT INTERFACE)<-'||current_calling_sequence);

                    END IF;

                    -- If the API fails because the call to the eTax service fails
                    -- the following code will get the messages from the message
                    -- stack

                    IF (l_error_code IS NOT NULL) THEN
                      -- Print the error returned from the service even if the debug
                      -- mode is off
                      AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);

                    ELSE
                      -- If the l_error_code is null is because the service returned
                      -- more than one error.  The calling module will need to get
                      -- them from the message stack
                      LOOP
                        l_error_code := FND_MSG_PUB.Get;
                        IF l_error_code IS NULL THEN
                          EXIT;
                        ELSE
                          AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);
                        END IF;
                      END LOOP;
                    END IF;  -- if l_error_code is not null
                    RAISE import_invoice_failure;
                  END IF;  -- end of call to IMPORT INTERFACE
                END IF; -- End of tax_only_flag
              END IF;  -- End of if for tax_only_rcv_matched_flag

              --------------------------------------------------------------------
              -- Step 15.7d. Call determine_recovery if the invoice is tax-only.
              --------------------------------------------------------------------

              IF (NVL(l_invoice_rec.tax_only_flag, 'N') = 'Y') THEN
                debug_info := '(Import_invoice 15.7d) Invoice is tax only so we will '||
                              'call determine_recovery';

                IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                END IF;

                IF NOT (ap_etax_pkg.calling_etax(
                        p_invoice_id             => l_base_invoice_id,
                        p_calling_mode           => 'DISTRIBUTE IMPORT',
                        p_override_status        => NULL,
                        p_line_number_to_delete  => NULL,
                        P_Interface_Invoice_Id   => l_invoice_rec.invoice_id,
                        p_all_error_messages     => 'Y',
                        p_error_code             => l_error_code,
                        p_calling_sequence       => current_calling_sequence)) THEN

                  -- If the call to determine recovery fails,  the import process
                  -- will fail.  In this case the invoice cannot be imported since
                  -- user is trying to import tax lines
                  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y'  THEN
                    AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      'ap_etax_pkg.calling_etax(DISTRIBUTE IMPORT)<-'||current_calling_sequence);

                  END IF;

                  -- If the API fails because the call to the eTax service fails
                  -- the following code will get the messages from the message
                  -- stack

                  IF (l_error_code IS NOT NULL) THEN
                    -- Print the error returned from the service even if the debug
                    -- mode is off
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);

                  ELSE
                    -- If the l_error_code is null is because the service returned
                    -- more than one error.  The calling module will need to get
                    -- them from the message stack
                    LOOP
                      l_error_code := FND_MSG_PUB.Get;
                       IF l_error_code IS NULL THEN
                        EXIT;
                      ELSE
                        AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);
                      END IF;
                    END LOOP;
                  END IF;  -- if l_error_code is not null

                  RAISE import_invoice_failure;

                END IF;
              END IF; -- call distribute if tax-only invoice

            END IF; -- calc_tax_during_import_flag is N.  User expects import TAX
                    -- to be called

            --------------------------------------------------------------
            -- Step 15.8:
            -- If the invoice does not have prepayment applications, call
            -- calculate tax if the user intention was to calculate.  The case
            -- where the user wants to import was handle previously.
            -- Also verify that the invoice is not AWT or INTEREST previous to
            -- calling etax to calculate.
            --------------------------------------------------------------

            debug_info := '(Import_invoice 15.8) Call calculate or the prepayment '||
                          'application';

            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            IF  ( l_invoice_rec.prepay_num IS NULL AND
                  l_invoice_rec.prepay_line_num IS NULL AND
                  l_invoice_rec.prepay_apply_amount IS NULL )   THEN

              IF ( l_invoice_rec.invoice_type_lookup_code
                   NOT IN ('AWT', 'INTEREST')) THEN

                IF ( l_invoice_rec.calc_tax_during_import_flag = 'Y') THEN
                  --------------------------------------------------------------
                  -- Step 15.8a: calc_tax_during_import_flag = Y.  User intention is
                  -- calculate. To minimize the calls to the eTax service, we will exclude
                  -- calling tax for invoices that will have any prepayment application.
                  -- Tax calculation will be done during the prepayment application
                  -- for those invoices.
                  -- Call calculate tax.
                  -- The big difference between this call here and the one done
                  -- during the prepayment application is the source of the data.
                  -- Here we will use the pl/sql tables populated during validation
                  -- in the prepayment case, the API will select the lines from the
                  -- ap_invoice_lines_all table
                  --------------------------------------------------------------
                  debug_info := '(Import_invoice 15.8a) Call calculate tax';

                  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                    AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                  END IF;

                  IF NOT (ap_etax_pkg.calling_etax(
                            p_invoice_id              => l_base_invoice_id,
                            p_calling_mode            => 'CALCULATE IMPORT',
                            p_override_status         => NULL,
                            p_line_number_to_delete   => NULL,
                            P_Interface_Invoice_Id    => l_invoice_rec.invoice_id,
                            p_all_error_messages      => 'Y',
                            p_error_code              => l_error_code,
                            p_calling_sequence        => current_calling_sequence)) THEN

                    -- If the calculation of tax fails the invoice will be imported
                    -- anyway, and the error(s) will be included in the log file.
                    -- Tax can be later be calculated from the invoice workbench or
                    -- during the validation of the invoice.

                    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y'  THEN
                      AP_IMPORT_UTILITIES_PKG.Print(
                        AP_IMPORT_INVOICES_PKG.g_debug_switch,
                        'ap_etax_pkg.calling_etax(CALCULATE IMPORT)<-'||current_calling_sequence);

                    END IF;

                    -- If the API fails because the call to the eTax service fails
                    -- the following code will get the messages from the message
                    -- stack

                    IF (l_error_code IS NOT NULL) THEN
                      -- Print the error returned from the service even if the debug
                      -- mode is off
                      AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);

                    ELSE
                      -- If the l_error_code is null is because the service returned
                      -- more than one error.  The calling module will need to get
                      -- them from the message stack
                      LOOP
                        l_error_code := FND_MSG_PUB.Get;

                        IF l_error_code IS NULL THEN
                          EXIT;
                        ELSE
                          AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);
                        END IF;
                      END LOOP;
                    END IF;  -- if l_error_code is not null
                  END IF; -- end call to ap_etax_pkg.calling_etax
                END IF;  -- if for the calc_tax_during_import_flag
              END IF; -- invoice is not AWT or INTEREST.  There is no tax
                      -- calculation for invoices of this type

            ELSE  -- if invoice has prepayment applications tax will be called in
                  -- the prepay application package.

              --------------------------------------------------------------
              -- Step 15.8b:
              -- Apply Prepayment(s) to invoice.
              -- Fix using invoice record
              --------------------------------------------------------------
              debug_info := '(Import_invoice 15.8b) Apply Prepayment(s) to invoice.';

              IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
              END IF;


	      SELECT sum(nvl(amount_remaining,0))
	      INTO l_inv_amount_unpaid
	      FROM ap_payment_schedules
	      WHERE invoice_id = l_base_invoice_id;

	      IF (nvl(l_inv_amount_unpaid,0) < l_invoice_rec.prepay_apply_amount) THEN
	         l_amount_to_apply := l_inv_amount_unpaid;
              ELSE
                 l_amount_to_apply := l_invoice_rec.prepay_apply_amount;
	      END IF;

              -- Prepayments project - 11ix
              AP_PREPAY_PKG.APPLY_PREPAY_IMPORT(
                           p_prepay_invoice_id  => l_prepay_invoice_id,
			   p_prepay_num		=> l_invoice_rec.prepay_num,
			   p_prepay_line_num    => l_invoice_rec.prepay_line_num,
			   p_prepay_apply_amount => l_amount_to_apply,
			   p_prepay_case_name   => l_prepay_case_name,
			   p_import_invoice_id  => l_invoice_rec.invoice_id,
			   p_request_id		=> p_conc_request_id,
                           p_invoice_id         => l_base_invoice_id,
                           p_vendor_id          => l_invoice_rec.vendor_id,
                           p_prepay_gl_date     => l_invoice_rec.prepay_gl_date,
                           p_prepay_period_name => l_prepay_period_name,
                           p_prepay_included    => l_invoice_rec.invoice_includes_prepay_flag,
                           p_user_id		=> l_default_last_updated_by,
                           p_last_update_login  => l_default_last_update_login,
                           p_calling_sequence   => current_calling_sequence,
                           p_prepay_appl_log    => l_prepay_appl_log);

            END IF;

            --------------------------------------------------------------
            -- Step 15.9:
            -- Update the invoice amount if flag add_tax_to_inv_amt_flag is
            -- set
            --------------------------------------------------------------
            debug_info := '(Import_invoice 15.9) Update the invoice amount '||
                          'if flag add_tax_to_inv_amt_flag is set with the '||
                          'total of the exclusive tax lines created for the '||
                          'invoice';

            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            IF (NVL(l_invoice_rec.add_tax_to_inv_amt_flag, 'N') = 'Y') THEN

	       SELECT ai.invoice_amount,
		      (SELECT NVL(SUM(NVL(ail.amount, 0)), 0)
                       FROM   ap_invoice_lines_all ail
                       WHERE  ail.invoice_id = l_base_invoice_id
                       AND    ail.line_type_lookup_code = 'TAX')
                 INTO l_inv_hdr_amount, l_exclusive_tax_amount
 		 FROM ap_invoices_all ai
		WHERE ai.invoice_id = l_base_invoice_id;

               --Bug 8513242 Added code to add tax amount to the control amount of the batch created.
               l_actual_invoice_total := l_actual_invoice_total + l_exclusive_tax_amount;
               --End Bug 8513242

               l_payment_status_flag := AP_INVOICES_UTILITY_PKG.get_payment_status (l_base_invoice_id);

               AP_PAYMENT_SCHEDULES_PKG.adjust_pay_schedule(
		                 X_invoice_id			=> l_base_invoice_id,
                                 X_invoice_amount		=> l_inv_hdr_amount + l_exclusive_tax_amount ,
                                 X_payment_status_flag		=> l_payment_status_flag,
                                 X_invoice_type_lookup_code	=> l_invoice_rec.invoice_type_lookup_code,
                                 X_last_updated_by		=> l_default_last_updated_by,
                                 X_message1			=> l_message1,
                                 X_message2			=> l_message2,
                                 X_reset_match_status		=> l_reset_match_status,
                                 X_liability_adjusted_flag	=> l_liability_adjusted_flag,
                                 X_calling_sequence		=> 'APXIIMPT',
				 X_calling_mode			=> 'APXIIMPT',
                                 X_revalidate_ps		=> l_revalidate_ps);

                --  Bug 7282839 start
                -- Calculate the tax amount in base currency
                l_base_exclusive_tax_amount := 0;
                IF (l_base_currency_code <> l_invoice_rec.invoice_currency_code) THEN

                  -- Retreive the exchange rate for the invoice from record
                  IF ( l_invoice_rec.exchange_rate IS NOT NULL) THEN
                    l_exchange_rate := l_invoice_rec.exchange_rate;
                  ELSE
                    -- Retreive exchange rate from ap_invoices_all for the invoice
                    select exchange_rate into l_exchange_rate
                    from ap_invoices_all
                    where invoice_id=l_base_invoice_id;
                  END IF;

                  IF ( l_exchange_rate IS NOT NULL
                         AND l_base_currency_code IS NOT NULL ) THEN
                    l_base_exclusive_tax_amount :=AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                                                 l_exclusive_tax_amount * l_exchange_rate,
                                                 l_base_currency_code);
                  END IF;
                END IF;

                UPDATE ap_invoices_all ai
                   SET ai.invoice_amount = ai.invoice_amount + l_exclusive_tax_amount,
                       ai.amount_applicable_to_discount = ai.amount_applicable_to_discount + l_exclusive_tax_amount,
                       ai.base_amount=ai.base_amount+l_base_exclusive_tax_amount
                 WHERE ai.invoice_id = l_base_invoice_id;

                 -- Bug 7282839 end

	       IF ( l_invoice_rec.payment_cross_rate is NOT NULL) THEN

		  UPDATE ap_invoices_all ai
                     SET ai.pay_curr_invoice_amount = ai.pay_curr_invoice_amount +
							      gl_currency_api.convert_amount(
							          	ai.invoice_currency_code,
							          	ai.payment_currency_code,
							          	ai.payment_cross_rate_date,
							          	ai.payment_cross_rate_type,
							          	l_exclusive_tax_amount)
		   WHERE ai.invoice_id = l_base_invoice_id;

	       END IF;


            END IF;

            --------------------------------------------------------------
            -- Step 15.10:
            -- Delete the contents of the l_invoice_lines_tab Lines Table
            --------------------------------------------------------------
            debug_info := '(Import_invoice 15.10) Delete the contents of '||
                          'the l_invoice_lines_tab Lines Table';

            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            l_invoice_lines_tab.DELETE;

            --------------------------------------------------------------
            -- Step 15.11:
            -- Delete the contents of the eTax global temporary tables
            --------------------------------------------------------------
            debug_info := '(Import_invoice 15.11) Delete the contents of '||
                          'the eTax global temp tables';

            IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            BEGIN DELETE zx_trx_headers_gt;
            EXCEPTION WHEN NO_DATA_FOUND THEN null;
            END;

            BEGIN DELETE zx_transaction_lines_gt;
            EXCEPTION WHEN NO_DATA_FOUND THEN null;
            END;

            BEGIN DELETE zx_import_tax_lines_gt;
            EXCEPTION WHEN NO_DATA_FOUND THEN null;
            END;

            BEGIN DELETE zx_trx_tax_link_gt;
            EXCEPTION WHEN NO_DATA_FOUND THEN null;
            END;

          END IF;   -- Invoice Status = 'Y' before call to get_invoice_info

      ----------------------------------------------------------------
      --  Step 16. Retropricing.
      ----------------------------------------------------------------
      ELSE
          debug_info := '(Import Invoice 16) Import_Retroprice_Adjustments';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
          END IF;
          --
          IF  (AP_RETRO_PRICING_PKG.Import_Retroprice_Adjustments(
                   l_invoice_rec,                   --  IN p_instr_header_rec
                   l_base_currency_code,            --  IN
                   l_multi_currency_flag,           --  IN
                   l_set_of_books_id,               --  IN
                   l_default_exchange_rate_type,    --  IN
                   l_make_rate_mandatory_flag,      --  IN
                   l_invoice_rec.gl_date,           --  IN
                   l_gl_date_from_receipt_flag,     --  IN
                   l_positive_price_tolerance,      --  IN
                   l_pa_installed,                  --  IN
                   l_qty_tolerance,                 --  IN
                   l_max_qty_ord_tolerance,         --  IN
                   l_base_min_acct_unit,            --  IN
                   l_base_precision,                --  IN
                   l_chart_of_accounts_id,          --  IN
                   l_freight_code_combination_id,   --  IN
                   l_purch_encumbrance_flag,        --  IN
                   l_calc_user_xrate,               --  IN
                   l_default_last_updated_by,       --  IN
                   l_default_last_update_login,     --  IN
                   l_invoice_status,                --     OUT instr_status_flag
                   l_valid_invoices_count,          --     OUT p_invoices_count
                   l_total_invoice_amount,         --     OUT p_invoices_total
                   current_calling_sequence)  <> TRUE) THEN
                 --
                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                       AP_IMPORT_UTILITIES_PKG.Print(
                         AP_IMPORT_INVOICES_PKG.g_debug_switch,
                         'Import_Retroprice_Adjustments<-'||current_calling_sequence);
                 END IF;
                 Raise import_invoice_failure;
                 --
          END IF;
          --
          --     NOTE : The logic based on l_actual_invoice_total doesn't make sense.
          --     l_total_invoices_amount -- is the out parameter for import_invoices
          --     l_actual_invoice_total  -- is used in
          --     AP_IMPORT_UTILITIES_PKG.Insert_ap_batches  and
          --     AP_IMPORT_UTILITIES_PKG.Update_ap_batches.
          --     Ideally they shud be the same.
          l_actual_invoice_total := l_total_invoice_amount;
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '------------------> l_instruction_id = '
              || to_char(l_invoice_rec.invoice_id));
          END IF;
        --
      END IF; --Retropricing
                --veramach bug 7121842 start
                EXCEPTION
                  WHEN import_invoice_failure THEN
                    l_invoice_status := 'N';
                END;
                --veramach bug 7121842 end
      -------------------------------------------------
      -- Step 17
      -- Change temporary status in ap_invoice_interface
      -------------------------------------------------
      BEGIN--veramach bug 7121842
      IF (l_invoice_status = 'N') THEN
        -----------------------------------------------------
        -- Step 17.1. Change the invoice status to 'REJECTING'
        -----------------------------------------------------
        debug_info := '(Import_invoice 17.1) Change the invoice status to '||
                      'REJECTING';
        IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.change_invoice_status(
                'REJECTING',
                l_invoice_rec.invoice_id,
                current_calling_sequence) <> TRUE) THEN
          IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'change_invoice_status<-'||current_calling_sequence);
          END IF;
          Raise import_invoice_failure;
        END IF;
      ELSE
        ------------------------------------------------------
        -- Step 17.2 Change the invoice status to 'PROCESSING'
        ------------------------------------------------------
        debug_info := '(Import_invoice 17.2) Change the invoice status to '||
                      'PROCESSIPRNG';
        IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.change_invoice_status(
                'PROCESSING',
                l_invoice_rec.invoice_id,
                current_calling_sequence) <> TRUE) THEN
          IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'change_invoice_status<-'||current_calling_sequence);
          END IF;
          Raise import_invoice_failure;
        END IF;
      END IF;
      --veramach bug 7121842 start
      EXCEPTION
         WHEN import_invoice_failure THEN
           NULL;
      END;
      --veramach bug 7121842 end
      l_old_org_id := nvl(l_invoice_rec.org_id, nvl(p_org_id, NULL));

    END LOOP;   -- invoice LOOP

    debug_info := '(Import_invoice) CLOSE import_invoices';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- Bug 4145391
    IF (p_group_id IS NULL) THEN
        CLOSE import_invoices;
    ELSE
        CLOSE import_invoices_group;
    END IF;

    ---------------------------------------------------------------------
    -- Step18
    -- Create batch IF batch_control is on AND has invoices created.
    -- Create batch only the first time, in subsequent commit cycles
    -- do not try to create the batch again.
    ---------------------------------------------------------------------
    debug_info := '(Import_invoice 18a) Get/Initialize batch name';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
BEGIN--veramach bug 7121842
    IF (p_batch_name IS NULL AND
    l_batch_name IS NULL AND
    NVL(l_batch_control_flag, 'N') = 'Y' AND
    l_valid_invoices_count > 0) THEN
      IF ( AP_IMPORT_UTILITIES_PKG.get_auto_batch_name(
                  p_source,
                  l_batch_name,
                  current_calling_sequence) <> TRUE ) THEN
        Raise import_invoice_failure;
      END IF;

    ELSIF (p_batch_name IS NOT NULL AND
           l_batch_name IS NULL AND
       NVL(l_batch_control_flag, 'N') = 'Y' AND
       l_valid_invoices_count > 0) THEN
      l_batch_name := p_batch_name;
    END IF;

    IF (NVL(l_batch_control_flag,'N') = 'Y' AND
     (l_batch_id is NOT NULL)         AND
    (l_batch_name IS NOT NULL)       AND
        (l_batch_exists_flag = 'N')      AND
        (l_valid_invoices_count >0 )     AND
        (l_batch_type = 'NEW BATCH')) THEN

      debug_info := '(Import_invoice 18b) Create ap_batches';
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.Insert_ap_batches(
            l_batch_id,
            l_batch_name,
            l_invoice_rec.invoice_currency_code,
            l_invoice_rec.payment_currency_code,
            l_valid_invoices_count,-- bug1721820
            l_actual_invoice_total,-- bug1721820
            l_default_last_updated_by,
            current_calling_sequence) <> TRUE) THEN
        IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'Insert_ap_batches<-'||current_calling_sequence);
        END IF;
        Raise import_invoice_failure;
      END IF;

      debug_info := '(Import_invoice 18c) Set batch exists flag to Y';
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      l_batch_exists_flag := 'Y';

    ELSIF (NVL(l_batch_control_flag,'N') = 'Y' AND
           (l_batch_id is NOT NULL)            AND
           (l_batch_name is NOT NULL)          AND
           ((l_batch_exists_flag = 'Y') OR
        (l_batch_type = 'OLD BATCH'))      AND
           (l_valid_invoices_count >0 )) THEN

      debug_info := '(Import_invoice 18d) Create ap_batches';
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.Update_Ap_Batches(
              l_batch_id,
              p_batch_name,
              l_valid_invoices_count,
              l_actual_invoice_total,
              l_default_last_updated_by,
              current_calling_sequence) <> TRUE) THEN
        IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'Update_Ap_Batches<-'||current_calling_sequence);
        END IF;
        Raise import_invoice_failure;
      END IF;

      debug_info := '(Import_invoice 18e) Set batch exists flag to Y';
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      l_batch_exists_flag := 'Y';
    ELSE
      debug_info := '(Import_invoice 18f) Do Not create batch';
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;
    END IF;

    -----------------------------------------------------------
    -- Step 19
    -- For each commit cycle, do a commit.
    -----------------------------------------------------------
    debug_info := '(Import_invoice 19) COMMIT to the database';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF NVL(p_commit,'Y') = 'Y' THEN
       COMMIT;
    END IF;

    -----------------------------------------------------
    -- Step 20 Check IF there's still any record left
    --
    -----------------------------------------------------
    debug_info := '(Import_purge 20) Check IF there is still any record left';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF l_total_count > l_invoices_fetched THEN
      l_continue_flag := 'Y';
    ELSE
      l_continue_flag := 'N';
    END IF;

    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------------> l_continue_flag = '|| l_continue_flag);
    END IF;
  --veramach bug 7121842 start
  EXCEPTION
    WHEN import_invoice_failure THEN
      IF l_total_count > l_invoices_fetched THEN  --Bug8587808 Start
        l_continue_flag := 'Y';
       ELSE
        l_continue_flag := 'N';
       END IF; --Bug8587808 End
  END;
  --veramach bug 7121842 end
  END LOOP;  -- invoice group LOOP

  ----------------------------------------------------------------------
  -- Step 21
  -- Update temporary status in ap_invoices_interface for all invoices
  --        FROM 'PROCESSING' to 'PROCESSED' AND,
  --             'REJECTING' to 'REJECTED'
  ----------------------------------------------------------------------

  debug_info := '(Import_invoice 21) Update temporary status';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
     AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
BEGIN--veramach bug 7121842
  IF (AP_IMPORT_UTILITIES_PKG.Update_temp_invoice_status(
                p_source,
                p_group_id,
                current_calling_sequence) <> TRUE) THEN
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'Update_temp_invoice_statu<-'||current_calling_sequence);
    END IF;
    Raise import_invoice_failure;
  END IF;
  --veramach bug 7121842 start
  EXCEPTION
    WHEN import_invoice_failure THEN
      NULL;
  END;
  --veramach bug 7121842 end
  p_invoices_created      := nvl(l_valid_invoices_count,0);
  p_invoices_fetched      := l_invoices_fetched;
  p_total_invoice_amount  := l_total_invoice_amount; -- for bug 989221

  debug_info := '(Import_invoice 22) Return No of invoices fetched '||
                'during process ,p_invoices_fetched'||l_invoices_fetched;
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;


debug_info := 'Now Block to Raise the Business event to pass the Concurrent request_id'
               ||AP_IMPORT_INVOICES_PKG.g_conc_request_id;
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

--7567527 PL/SQL Block for Enhancement to raise Business events after invoices are imported
 BEGIN


  l_parameter_list := wf_parameter_list_t( wf_parameter_t('REQUEST_ID',
					                   to_char(AP_IMPORT_INVOICES_PKG.g_conc_request_id)
							   )
					     );


 --bug 7636400
 /*
 SELECT	to_char(ap_invoice_import_wfevent_s.nextval)
 INTO	l_event_key
 FROM 	dual;
 */

 SELECT to_char(AP_INV_IMPORT_EVENT_S.nextval)
 INTO   l_event_key
 FROM   dual;

 wf_event.raise( p_event_name => l_event_name,
		p_event_key  => l_event_key,
		p_parameters => l_parameter_list);

 debug_info := 'After raising workflow event : '
		        || 'event_name = ' || l_event_name
		        || ' event_key = ' || l_event_key ;
 IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
 END IF;

 EXCEPTION


  WHEN OTHERS THEN
   debug_info := 'Error Was Raised in raising event';
 IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
 END IF;
	       WF_CORE.CONTEXT('AP_IMPORT_INVOICES_PKG', 'IMPORT_INVOICES', l_event_name,
                                	                  l_event_key);
		RAISE;
 END;

RETURN (TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE < 0) THEN
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    IF (SQLCODE = -54) THEN
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(Import_invoice:EXCEPTION) The invoices to be SELECTed by this ' ||
          'process are locked');
      END IF;
    END IF;

    IF import_invoices%isOPEN THEN
      CLOSE import_invoices;
    ELSIF import_invoices_group%ISOPEN THEN
      CLOSE import_invoices_group;
    END IF;

    RETURN (FALSE);

END Import_INVOICES;


--===============================================================
-- Main functions: Import_purge
--
--===============================================================
FUNCTION IMPORT_PURGE(
         p_source                IN  VARCHAR2,
         p_group_id              IN  VARCHAR2,
         p_org_id                IN  NUMBER,
         p_commit_cycles         IN  NUMBER,
         p_calling_sequence      IN  VARCHAR2)
RETURN BOOLEAN IS

  -- Bug 4145391. Modified the select for the cursor to improve performance.
  -- Removed the p_group_id where clause and added it to the cursor
  -- purge_invoices_group
  CURSOR  purge_invoices IS
  SELECT  invoice_id
    FROM  ap_invoices_interface
   WHERE  source = p_source
     AND  status = 'PROCESSED'
     AND  ((p_commit_cycles IS NULL) OR
          (ROWNUM <= p_commit_cycles))
     AND  ((org_id IS NOT NULL and  p_org_id IS NOT NULL and
           org_id  = p_org_id)
         OR (p_org_id IS NULL and  org_id is NOT NULL and
            (mo_global.check_access(org_id)= 'Y'))
         OR (p_org_id IS NOT NULL and  org_id IS NULL)
         OR (p_org_id IS NULL and  org_id IS NULL))
  ORDER BY vendor_id,
           vendor_num,
           vendor_name,
           vendor_site_id,
           vendor_site_code,
           invoice_num;

  CURSOR  purge_invoices_group IS
  SELECT  invoice_id
    FROM  ap_invoices_interface
   WHERE  source = p_source
     AND  group_id = p_group_id
     AND  status = 'PROCESSED'
     AND  ((p_commit_cycles IS NULL) OR
          (ROWNUM <= p_commit_cycles))
     AND  ((org_id IS NOT NULL and  p_org_id IS NOT NULL and
           org_id  = p_org_id)
         OR (p_org_id IS NULL and  org_id is NOT NULL and
            (mo_global.check_access(org_id)= 'Y'))
         OR (p_org_id IS NOT NULL and  org_id IS NULL)
         OR (p_org_id IS NULL and  org_id IS NULL))
  ORDER BY vendor_id,
           vendor_num,
           vendor_name,
           vendor_site_id,
           vendor_site_code,
           invoice_num;

  l_continue_flag           VARCHAR2(1) := 'Y';
  l_invoice_id              NUMBER;
  import_purge_failure      EXCEPTION;
  current_calling_sequence  VARCHAR2(2000);
  debug_info                VARCHAR2(500);  /* Bug 4166583 */
  l_total_count             NUMBER := 0;
  l_counter                 NUMBER := 0;
  l_attachments_count       NUMBER;


BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'Import_purge<- '||p_calling_sequence;

  debug_info := '(Import_purge ) Deleting records in interface tables...';

  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- Outside while loop for commit cycle

  IF p_group_id IS NULL THEN
     BEGIN
       SELECT  count(*)
         INTO  l_total_count
         FROM  ap_invoices_interface
        WHERE  source = p_source
          AND  status = 'PROCESSED'
          AND  (   (org_id   IS NOT NULL AND
                    p_org_id IS NOT NULL AND
                    org_id   = p_org_id)
                OR (p_org_id IS NULL AND
                    org_id is NOT NULL and
                   (mo_global.check_access(org_id)= 'Y'))
                OR (p_org_id IS NOT NULL and  org_id IS NULL)
                OR (p_org_id IS NULL and  org_id IS NULL));
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_continue_flag := 'N';
     END;
  ELSE
     BEGIN
       SELECT  count(*)
         INTO  l_total_count
         FROM  ap_invoices_interface
        WHERE  source = p_source
          AND  group_id = p_group_id
          AND  status = 'PROCESSED'
          AND  (   (org_id   IS NOT NULL AND
                    p_org_id IS NOT NULL AND
                    org_id   = p_org_id)
                OR (p_org_id IS NULL AND
                    org_id is NOT NULL and
                   (mo_global.check_access(org_id)= 'Y'))
                OR (p_org_id IS NOT NULL and  org_id IS NULL)
                OR (p_org_id IS NULL and  org_id IS NULL));
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_continue_flag := 'N';
     END;
  END IF;

  WHILE (l_continue_flag = 'Y') LOOP

    ---------------------------------------------------------------
    -- Step 1, Open cursor
    ---------------------------------------------------------------

    debug_info := '(Import_purge 1) Open purge_invoices cursor';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- Bug 4145391. To improve the performance of the import program coding two
    -- different cursors based on the parameter p_group_id
    IF (p_group_id IS NULL) THEN
        OPEN purge_invoices;
    ELSE
        OPEN purge_invoices_group;
    END IF;


    LOOP
    -- Invoice loop

    ---------------------------------------------------------------
    -- Step 2, Fetch invoice interface record into local variables
    --
    ----------------------------------------------------------------
    debug_info := '(Import_puege 2) Fetch purge_invoices';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- Bug 4145391
    IF (p_group_id IS NULL) THEN
        FETCH purge_invoices INTO l_invoice_id;
        EXIT WHEN purge_invoices%NOTFOUND OR
                  purge_invoices%NOTFOUND IS NULL;
    ELSE
        FETCH purge_invoices_group INTO l_invoice_id;
        EXIT WHEN purge_invoices_group%NOTFOUND OR
                  purge_invoices_group%NOTFOUND IS NULL;
    END IF;

    --
    -- show output values (only if debug_switch = 'Y')
    --
    debug_info := '---------> l_invoice_id = '|| to_char(l_invoice_id);
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    ------------------------------------------------------------------------
    -- Step 3, Delete records for ap_invoice_lines_interface
    --         Multiple lines
    ------------------------------------------------------------------------
    debug_info := '(Import_purge 3) Delete records in ' ||
                  'ap_invoice_lines_interface...';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    DELETE FROM AP_INVOICE_LINES_INTERFACE
    WHERE invoice_id = l_invoice_id;

    ------------------------------------------------------------------------
    -- Step 4, Delete records for ap_invoices_interface
    --         Only one line
    ------------------------------------------------------------------------
    -- also delete attachments if any
    debug_info := '(Import_purge 4.1) Delete attachments if any...';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    --  delete attachments for the invoice
    debug_info := '(Import_purge 4.2) before delete attachments: '||
        'source = ' || p_source || ', invoice_id = ' || l_invoice_id;
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- not necessary to restrict to souce
    l_attachments_count := delete_attachments(l_invoice_id);
    debug_info := '(Import_purge 4.2) delete attachments done: '||
                l_attachments_count;
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- delete the invoice_interface record now
    debug_info := '(Import_purge 4) Delete records in ' ||
                  'ap_invoices_interface...';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    DELETE FROM AP_INVOICES_INTERFACE
    WHERE invoice_id = l_invoice_id
      AND (   (org_id    IS NOT NULL AND
               p_org_id  IS NOT NULL AND
               org_id    = p_org_id)
           OR (p_org_id  IS NULL AND
               org_id is NOT NULL AND
               (mo_global.check_access(org_id)= 'Y'))
           OR (p_org_id  IS NOT NULL AND
               org_id    IS NULL)
           OR (p_org_id  IS NULL AND
               org_id    IS NULL));

    l_counter := l_counter + 1;

    END LOOP;  -- invoice loop

    debug_info := '(Import_purge ) Close purge_invoices cursor';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- Bug 4145391
    IF (p_group_id IS NULL) THEN
        CLOSE purge_invoices;
    ELSE
        CLOSE purge_invoices_group;
    END IF;

    -----------------------------------------------------
    -- Step 5,  COMMIT for each commit cycle
    -----------------------------------------------------
    debug_info := '(Import_purge 5) Commit to the database';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    COMMIT;

    -----------------------------------------------------
    -- Step 6, Check if there's still any record left
    -----------------------------------------------------
    debug_info := '(Import_purge 6) Check if there is still any record left';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    If l_total_count > l_counter THEN
      l_continue_flag := 'Y';
    Else
      l_continue_flag := 'N';
    End If;

    debug_info := '---------> l_continue_flag = '|| l_continue_flag;
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
  END LOOP; -- Outside commit cycle loop
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN

    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    IF (purge_invoices%ISOPEN) THEN
      CLOSE purge_invoices;
    ELSIF (purge_invoices_group%ISOPEN) THEN
      CLOSE purge_invoices_group;
    END IF;

    RETURN (FALSE);
END IMPORT_PURGE;

--===============================================================
-- Private functions: xml_import_purge
--
--===============================================================
FUNCTION XML_IMPORT_PURGE(
             p_group_id              IN  VARCHAR2,
             p_calling_sequence      IN  VARCHAR2) RETURN BOOLEAN IS

  TYPE headerlist IS TABLE OF ap_invoices_interface.invoice_id%TYPE;

  h_list                          HEADERLIST;
  current_calling_sequence        VARCHAR2(2000);
  debug_info                      VARCHAR2(500); /* Bug 4166583 */

BEGIN

  -- update calling_sequence
  current_calling_sequence := 'xml_import_purge<--'||p_calling_sequence;

  debug_info := '(XML Import Purge 1) before getting list of invoice_id';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- get all XML invoices with supplier rejections

  -- Bug 4145391. To improve the performance of the import program coding two
  -- different select stmts based on the parameter p_group_id
  IF (p_group_id IS NULL) THEN
      SELECT h.invoice_id BULK COLLECT
        INTO h_list
        FROM ap_invoices_interface h,
             ap_invoice_lines_interface l,
             ap_interface_rejections r
       WHERE DECODE(r.parent_table, 'AP_INVOICES_INTERFACE',
                    h.invoice_id,
                    'AP_INVOICE_LINES_INTERFACE', l.invoice_line_id)
                                           = r.parent_id
         AND h.invoice_id                  = l.invoice_id
         AND nvl(r.notify_vendor_flag,'N') = 'Y'
         AND h.status                      = 'REJECTED'
         AND h.source                      = 'XML GATEWAY'
         AND nvl(h.ORG_ID,
                 to_number(nvl(decode(SUBSTR(USERENV('CLIENT_INFO'),1,1),
                      ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10)), '-99')) )
             =   to_number(nvl(decode(SUBSTR(USERENV('CLIENT_INFO'),1,1),
                      ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10)), '-99'))
      GROUP BY h.invoice_id;
  ELSE
      SELECT h.invoice_id BULK COLLECT
        INTO h_list
        FROM ap_invoices_interface h,
             ap_invoice_lines_interface l,
             ap_interface_rejections r
       WHERE DECODE(r.parent_table, 'AP_INVOICES_INTERFACE',
                    h.invoice_id,
                    'AP_INVOICE_LINES_INTERFACE', l.invoice_line_id)
                                           = r.parent_id
         AND h.invoice_id                  = l.invoice_id
         AND nvl(r.notify_vendor_flag,'N') = 'Y'
         AND h.status                      = 'REJECTED'
         AND h.source                      = 'XML GATEWAY'
         AND h.group_id                    = p_group_id
         AND nvl(h.ORG_ID,
                 to_number(nvl(decode(SUBSTR(USERENV('CLIENT_INFO'),1,1),
                      ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10)), '-99')) )
             =   to_number(nvl(decode(SUBSTR(USERENV('CLIENT_INFO'),1,1),
                      ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10)), '-99'))
      GROUP BY h.invoice_id;
  END IF;


  debug_info := '(XML Import Purge 1.1) number of invoices to delete: '
                || nvl(h_list.count,0);
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  debug_info := '(XML Import Purge 2) before deleting header rejections';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  FORALL i IN nvl(h_list.FIRST,0) .. nvl(h_list.LAST,-1)
    DELETE FROM ap_interface_rejections r
    WHERE r.parent_id = h_list(i)
    AND   r.parent_table = 'AP_INVOICES_INTERFACE';

  debug_info := '(XML Import Purge 3) before deleting line rejections';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  FORALL i IN nvl(h_list.FIRST,0) .. nvl(h_list.LAST,-1)
    DELETE FROM ap_interface_rejections r
    WHERE r.parent_id IN (SELECT l.invoice_line_id
                          FROM   ap_invoice_lines_interface l
                          WHERE  l.invoice_id  = h_list(i) )
    AND   r.parent_table = 'AP_INVOICE_LINES_INTERFACE';

  debug_info := '(XML Import Purge 4) before deleting header interface';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- Delete from ap_invoice_lines_interface table
  FORALL i IN nvl(h_list.FIRST,0) .. nvl(h_list.LAST,-1)
    DELETE FROM ap_invoice_lines_interface l
    WHERE  l.invoice_id = h_list(i);

  debug_info       := '(XML Import Purge 5) before deleting line interface';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- Delete from ap_invoices_interface table
  FORALL i IN nvl(h_list.FIRST,0) .. nvl(h_list.LAST,-1)
    DELETE FROM ap_invoices_interface h
    WHERE  h.invoice_id = h_list(i);

  debug_info := '(XML Import Purge 6) COMMIT';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  COMMIT;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN

    debug_info := 'Failed after ' || debug_info;
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    RETURN(false);

END xml_import_purge;


PROCEDURE SUBMIT_PAYMENT_REQUEST(
    p_api_version             IN          VARCHAR2 DEFAULT '1.0',
    p_invoice_interface_id    IN          NUMBER,
    p_budget_control          IN          VARCHAR2 DEFAULT 'Y',
    p_needs_invoice_approval  IN          VARCHAR2 DEFAULT 'N',
    p_invoice_id              OUT NOCOPY  NUMBER,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    x_rejection_list          OUT NOCOPY  rejection_tab_type,
    p_calling_sequence        IN          VARCHAR2,
    p_commit                  IN          VARCHAR2 DEFAULT 'Y',
    p_batch_name              IN          VARCHAR2 DEFAULT NULL, --Bug 8361660
    p_conc_request_id         IN          NUMBER   DEFAULT NULL  --Bug 8492591
) IS


  l_batch_error_flag              VARCHAR2(1);
  l_invoices_fetched              NUMBER;
  l_invoices_created              NUMBER;
  l_total_invoice_amount          NUMBER;
  l_print_batch                   VARCHAR2(1);

  payment_request_failure         EXCEPTION;
  current_calling_sequence        VARCHAR2(2000);
  debug_info                      VARCHAR2(500);

  l_invoice_id                    NUMBER;
  l_source                        VARCHAR2(80);
  l_holds_count                   NUMBER;
  l_approval_status               VARCHAR2(30);
  l_funds_return_code             VARCHAR2(30);

  CURSOR c_rejections IS
  SELECT parent_table,
         parent_id,
         reject_lookup_code
  FROM   ap_interface_rejections
  WHERE  parent_table = 'AP_INVOICES_INTERFACE'
  AND    parent_id = p_invoice_interface_id
  UNION
  SELECT parent_table,
         parent_id,
         reject_lookup_code
  FROM   ap_interface_rejections
  WHERE  parent_table = 'AP_INVOICE_LINES_INTERFACE'
  AND    parent_id IN (SELECT invoice_line_id
                       FROM   ap_invoice_lines_interface
                       WHERE  invoice_id = p_invoice_interface_id);

BEGIN

  -- Update the calling sequence and initialize variables
  current_calling_sequence := 'Submit_Payment_Request<- '||p_calling_sequence;


  -- Give error message if the interface invoice id is not provided
  IF p_invoice_interface_id IS NULL THEN

     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
         AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'No invoice_id<- '||current_calling_sequence);
     END IF;

     FND_MESSAGE.Set_Name('SQLAP', 'AP_IMP_NO_INVOICE_ID');
     x_msg_data := FND_MESSAGE.Get;

     x_return_status := 'F';
     return;

  ELSE

     SELECT source
     INTO   l_source
     FROM   ap_invoices_interface
     WHERE  invoice_id = p_invoice_interface_id;


     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
         AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'Calling Import_Invoices<- '||current_calling_sequence);
     END IF;

     -- Calling the import invoices routine to import the payment request
     -- invoices
     IF (IMPORT_INVOICES(
            p_batch_name,  --p_batch_name Bug 8361660
            NULL,  --p_gl_date
            NULL,  --p_hold_code
            NULL,  --p_hold_reason
            NULL,     --p_commit_cycles
            l_source,  --p_source
            NULL,  --p_group_id
            p_conc_request_id, --Bug 8492591
            'N',   --p_debug_switch
            NULL,  --p_org_id,
            l_batch_error_flag,
            l_invoices_fetched,
            l_invoices_created,
            l_total_invoice_amount,
            l_print_batch,
            current_calling_sequence,
            p_invoice_interface_id,
            p_needs_invoice_approval,
            p_commit) <> TRUE) THEN

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'Error during import<- '||current_calling_sequence);
          END IF;

          Raise payment_request_failure;
     END IF; -- Import Invoices


     -- If no invoices are created then get the list of rejections and
     -- send rejections to the calling routine
     IF l_invoices_created = 0 THEN

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'No invoices created<- '||current_calling_sequence);
        END IF;

        x_return_status := 'R';

        OPEN c_rejections;
        FETCH c_rejections BULK COLLECT INTO x_rejection_list;
        CLOSE c_rejections;

     ELSE
        x_return_status := 'S';

     END IF;


     IF g_invoice_id IS NOT NULL THEN

        l_invoice_id := g_invoice_id;
        p_invoice_id := g_invoice_id;

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'Calling invoice validation<- '||current_calling_sequence);
        END IF;


        -- Calling the approve routine to validate the invoices that are
        -- imported
        ap_approval_pkg.approve
                 ('',  -- p_run_option
                  '',  -- p_invoice_batch_id
                  '',  -- p_begin_invoice_date
                  '',  -- p_end_invoice_date
                  '',  -- p_vendor_id
                  '',  -- p_pay_group
                  l_invoice_id,
                  '',  -- p_entered_by
                  '',  -- p_set_of_books_id
                  '',  -- p_trace_option
                  '',  -- p_conc_flag
                  l_holds_count,
                  l_approval_status,
                  l_funds_return_code,
                  'PAYMENT REQUEST',
                  current_calling_sequence,
                  'N',
                  p_budget_control,
                  p_commit);

        x_return_status := 'S';

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'Validation complete<- '||current_calling_sequence);
        END IF;

     END IF;

  END IF;

  g_invoice_id := null;

EXCEPTION
  WHEN no_data_found THEN
     FND_MESSAGE.Set_Name('SQLAP', 'AP_IMP_NO_INVOICE_ID');
     x_msg_data := FND_MESSAGE.Get;
     x_return_status := 'F';

  WHEN OTHERS THEN
    IF (SQLCODE < 0) THEN
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
      x_msg_data := SQLERRM;
      x_return_status := 'F';
    END IF;

END SUBMIT_PAYMENT_REQUEST;



END AP_IMPORT_INVOICES_PKG;

/
