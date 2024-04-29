--------------------------------------------------------
--  DDL for Package Body POS_AP_SUPPLIER_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_AP_SUPPLIER_BO_PKG" AS
/* $Header: POSAPSPB.pls 120.0.12010000.7 2012/09/28 18:30:54 dalu noship $ */
  /*#
  * Use this routine to get ap suplier
  * @param p_api_version The version of API
  * @param p_init_msg_list The Initialization message list
  * @param p_party_id The Party id
  * @param p_orig_system The Orig System
  * @param p_orig_system_reference The Orig System Ref
  * @param x_ap_suplier_bo The Suppliers table
  * @param x_return_status The return status
  * @param x_msg_count The message count
  * @param x_msg_data The message data
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Supplier
  * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
  */
  PROCEDURE get_ap_supplier_bo
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_ap_suplier_bo         OUT NOCOPY pos_ap_supplier_bo,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS

    l_pos_ap_supplier_bo pos_ap_supplier_bo;
    -- l_pos_supplier_uda   pos_supplier_uda_bo;
    l_party_id NUMBER;
  BEGIN
    IF p_party_id IS NULL OR p_party_id = 0 THEN

      l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                         p_orig_system_reference);
    ELSE
      l_party_id := p_party_id;
    END IF;
    /* pos_supplier_uda_bo_pkg.get_uda_data(p_api_version,
    p_init_msg_list,
    p_party_id,
    'SUPP_LEVEL',
    l_pos_supplier_uda,
    x_return_status,
    x_msg_count,
    x_msg_data);*/

    SELECT pos_ap_supplier_bo(vendor_id,
                              last_update_date,
                              last_updated_by,
                              vendor_name,
                              vendor_name_alt,
                              segment1,
                              summary_flag,
                              enabled_flag,
                              segment2,
                              segment3,
                              segment4,
                              segment5,
                              last_update_login,
                              creation_date,
                              created_by,
                              employee_id,
                              vendor_type_lookup_code,
                              customer_num,
                              one_time_flag,
                              parent_vendor_id,
                              min_order_amount,
                              ship_to_location_id,
                              bill_to_location_id,
                              ship_via_lookup_code,
                              freight_terms_lookup_code,
                              fob_lookup_code,
                              terms_id,
                              set_of_books_id,
                              credit_status_lookup_code,
                              credit_limit,
                              always_take_disc_flag,
                              pay_date_basis_lookup_code,
                              pay_group_lookup_code,
                              payment_priority,
                              invoice_currency_code,
                              payment_currency_code,
                              invoice_amount_limit,
                              exchange_date_lookup_code,
                              hold_all_payments_flag,
                              hold_future_payments_flag,
                              hold_reason,
                              distribution_set_id,
                              accts_pay_code_combination_id,
                              disc_lost_code_combination_id,
                              disc_taken_code_combination_id,
                              expense_code_combination_id,
                              prepay_code_combination_id,
                              num_1099,
                              type_1099,
                              withholding_status_lookup_code,
                              withholding_start_date,
                              organization_type_lookup_code,
                              vat_code,
                              start_date_active,
                              end_date_active,
                              minority_group_lookup_code,
                              payment_method_lookup_code,
                              bank_account_name,
                              bank_account_num,
                              bank_num,
                              bank_account_type,
                              women_owned_flag,
                              small_business_flag,
			      -- Bug 9509201, 9535269
                              -- Added the decode funtion to avoid the ASCII 0 character present in the Standard industry class column for some suppliers,
                              -- as it is creating problems in the XML payload creation for SDH Generate Report and Publish Supplier functionality.
                              -- Bug 8246403 addressed this exact issue.  The error is considered to be a correct behavior, but a DB level option can be set by alter session to encode invalid characters.
                              decode(standard_industry_class, chr(0), NULL, standard_industry_class),
                              hold_flag,
                              purchasing_hold_reason,
                              hold_by,
                              hold_date,
                              terms_date_basis,
                              price_tolerance,
                              inspection_required_flag,
                              receipt_required_flag,
                              qty_rcv_tolerance,
                              qty_rcv_exception_code,
                              enforce_ship_to_location_code,
                              days_early_receipt_allowed,
                              days_late_receipt_allowed,
                              receipt_days_exception_code,
                              receiving_routing_id,
                              allow_substitute_receipts_flag,
                              allow_unordered_receipts_flag,
                              hold_unmatched_invoices_flag,
                              exclusive_payment_flag,
                              ap_tax_rounding_rule,
                              auto_tax_calc_flag,
                              auto_tax_calc_override,
                              amount_includes_tax_flag,
                              tax_verification_date,
                              name_control,
                              state_reportable_flag,
                              federal_reportable_flag,
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
                              request_id,
                              program_application_id,
                              program_id,
                              program_update_date,
                              offset_vat_code,
                              vat_registration_num,
                              auto_calculate_interest_flag,
                              validation_number,
                              exclude_freight_from_discount,
                              tax_reporting_name,
                              check_digits,
                              bank_number,
                              allow_awt_flag,
                              awt_group_id,
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
                              global_attribute_category,
                              edi_transaction_handling,
                              edi_payment_method,
                              edi_payment_format,
                              edi_remittance_method,
                              edi_remittance_instruction,
                              bank_charge_bearer,
                              bank_branch_type,
                              match_option,
                              future_dated_payment_ccid,
                              create_debit_memo_flag,
                              offset_tax_flag,
                              party_id,
                              parent_party_id,
                              -- nvl(ni_number, ' '),
                              tca_sync_num_1099,
                              tca_sync_vendor_name,
                              tca_sync_vat_reg_num,
                              individual_1099,
                              unique_tax_reference_num,
                              partnership_utr,
                              partnership_name,
                              cis_enabled_flag,
                              first_name,
                              second_name,
                              last_name,
                              salutation,
                              trading_name,
                              work_reference,
                              company_registration_number,
                              national_insurance_number,
                              verification_number,
                              verification_request_id,
                              match_status_flag,
                              cis_verification_date,
                              pay_awt_group_id,
                              cis_parent_vendor_id,
                              NULL,
                              pos_supplier_uda_bo_pkg.get_uda_for_supplier_site(l_party_id,
                                                                                NULL,
                                                                                NULL,
                                                                                'SUPP_LEVEL'))
    INTO   l_pos_ap_supplier_bo
    FROM   ap_suppliers
    WHERE  party_id = l_party_id;
    x_ap_suplier_bo                        := l_pos_ap_supplier_bo;
    x_ap_suplier_bo.p_pos_supp_uda_obj_tbl := pos_supplier_uda_bo_pkg.get_uda_for_supplier_site(l_party_id,
                                                                                                NULL,
                                                                                                NULL,
                                                                                                'SUPP_LEVEL');
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
  END get_ap_supplier_bo;

  /* Added to create HZ orig reference */
  PROCEDURE create_party_orig_ref
  (
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
    l_orig_sys_reference_rec hz_orig_system_ref_pub.orig_sys_reference_rec_type;

    l_exists        VARCHAR2(1);
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);

    CURSOR c_check_party_mapping IS
      SELECT 'Y'
      FROM   hz_orig_sys_references
      WHERE  owner_table_id = p_party_id
      AND    owner_table_name = 'HZ_PARTIES'
      AND    orig_system = p_orig_system
      AND    orig_system_reference = p_orig_system_reference
      AND    trunc(nvl(end_date_active, SYSDATE)) >= trunc(SYSDATE)
      AND    status = 'A';

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_orig_system IS NOT NULL AND p_orig_system <> fnd_api.g_miss_char THEN
      OPEN c_check_party_mapping;
      FETCH c_check_party_mapping
        INTO l_exists;
      IF c_check_party_mapping%NOTFOUND THEN
        l_orig_sys_reference_rec.orig_system           := p_orig_system;
        l_orig_sys_reference_rec.orig_system_reference := p_orig_system_reference;
        l_orig_sys_reference_rec.owner_table_name      := 'HZ_PARTIES';
        l_orig_sys_reference_rec.owner_table_id        := p_party_id;
        l_orig_sys_reference_rec.created_by_module     := 'AP_SUPPLIERS_API';

        hz_orig_system_ref_pub.create_orig_system_reference(fnd_api.g_false,
                                                            l_orig_sys_reference_rec,
                                                            l_return_status,
                                                            l_msg_count,
                                                            l_msg_data);
        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
  END create_party_orig_ref;

  /*#
  * Use this routine to create ap suplier
  * @param p_api_version The version of API
  * @param p_init_msg_list The Initialization message list
  * @param p_ap_suplier_bo The ap_vendor_pub_pkg.r_vendor_rec_type
  * @param p_party_id The party id
  * @param p_orig_system The Orig System
  * @param p_orig_system_reference The Orig System Ref
  * @param p_create_update_flag The Create Update flag
  * @param x_vendor_id The Supplier Created
  * @param x_party_id The Party Created
  * @param x_return_status The return status
  * @param x_msg_count The message count
  * @param x_msg_data The message data
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Create Supplier
  * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
  */
  PROCEDURE create_pos_ap_supplier
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_pos_ap_supplier_bo    IN pos_ap_supplier_bo,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    p_create_update_flag    IN VARCHAR2,
    x_vendor_id             OUT NOCOPY NUMBER,
    x_party_id              OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
    l_ap_suplier_bo ap_vendor_pub_pkg.r_vendor_rec_type;
    l_ext_payee_rec iby_disbursement_setup_pub.external_payee_rec_type;
    l_party_id      NUMBER;
    l_vendor_id     NUMBER;
  BEGIN
    IF p_party_id IS NULL OR p_party_id = 0 THEN

      l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                         p_orig_system_reference);
    ELSE
      l_party_id := p_party_id;
    END IF;

    IF l_party_id IS NULL OR l_party_id = 0 THEN
      IF p_create_update_flag = 'U' THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_count     := 1;
        x_msg_data      := 'Party to be updated doesnot exist.';
        RETURN;
      END IF;
      l_party_id := NULL;
      /* x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count     := 1;
      x_msg_data      := 'No Party Exist, can create party but the Orig System integrity cannot be maintained';*/
    END IF;

    l_ext_payee_rec.payee_party_id               := l_party_id;
    l_ext_payee_rec.payment_function             := p_pos_ap_supplier_bo.p_pos_external_payee_bo.payment_function;
    l_ext_payee_rec.exclusive_pay_flag           := p_pos_ap_supplier_bo.p_pos_external_payee_bo.exclusive_pay_flag;
    l_ext_payee_rec.payee_party_site_id          := p_pos_ap_supplier_bo.p_pos_external_payee_bo.payee_party_site_id;
    l_ext_payee_rec.supplier_site_id             := p_pos_ap_supplier_bo.p_pos_external_payee_bo.supplier_site_id;
    l_ext_payee_rec.payer_org_id                 := p_pos_ap_supplier_bo.p_pos_external_payee_bo.payer_org_id;
    l_ext_payee_rec.payer_org_type               := p_pos_ap_supplier_bo.p_pos_external_payee_bo.payer_org_type;
    l_ext_payee_rec.default_pmt_method           := p_pos_ap_supplier_bo.p_pos_external_payee_bo.default_pmt_method;
    l_ext_payee_rec.ece_tp_loc_code              := p_pos_ap_supplier_bo.p_pos_external_payee_bo.ece_tp_loc_code;
    l_ext_payee_rec.bank_charge_bearer           := p_pos_ap_supplier_bo.p_pos_external_payee_bo.bank_charge_bearer;
    l_ext_payee_rec.bank_instr1_code             := p_pos_ap_supplier_bo.p_pos_external_payee_bo.bank_instr1_code;
    l_ext_payee_rec.bank_instr2_code             := p_pos_ap_supplier_bo.p_pos_external_payee_bo.bank_instr2_code;
    l_ext_payee_rec.bank_instr_detail            := p_pos_ap_supplier_bo.p_pos_external_payee_bo.bank_instr_detail;
    l_ext_payee_rec.pay_reason_code              := p_pos_ap_supplier_bo.p_pos_external_payee_bo.pay_reason_code;
    l_ext_payee_rec.pay_reason_com               := p_pos_ap_supplier_bo.p_pos_external_payee_bo.pay_reason_com;
    l_ext_payee_rec.inactive_date                := p_pos_ap_supplier_bo.p_pos_external_payee_bo.inactive_date;
    l_ext_payee_rec.pay_message1                 := p_pos_ap_supplier_bo.p_pos_external_payee_bo.pay_message1;
    l_ext_payee_rec.pay_message2                 := p_pos_ap_supplier_bo.p_pos_external_payee_bo.pay_message2;
    l_ext_payee_rec.pay_message3                 := p_pos_ap_supplier_bo.p_pos_external_payee_bo.pay_message3;
    l_ext_payee_rec.delivery_channel             := p_pos_ap_supplier_bo.p_pos_external_payee_bo.delivery_channel;
    l_ext_payee_rec.pmt_format                   := p_pos_ap_supplier_bo.p_pos_external_payee_bo.pmt_format;
    l_ext_payee_rec.settlement_priority          := p_pos_ap_supplier_bo.p_pos_external_payee_bo.settlement_priority;
    l_ext_payee_rec.remit_advice_delivery_method := p_pos_ap_supplier_bo.p_pos_external_payee_bo.remit_advice_delivery_method;
    l_ext_payee_rec.remit_advice_email           := p_pos_ap_supplier_bo.p_pos_external_payee_bo.remit_advice_email;
    l_ext_payee_rec.edi_payment_format           := p_pos_ap_supplier_bo.p_pos_external_payee_bo.edi_payment_format;
    l_ext_payee_rec.edi_transaction_handling     := p_pos_ap_supplier_bo.p_pos_external_payee_bo.edi_transaction_handling;
    l_ext_payee_rec.edi_payment_method           := p_pos_ap_supplier_bo.p_pos_external_payee_bo.edi_payment_method;
    l_ext_payee_rec.edi_remittance_method        := p_pos_ap_supplier_bo.p_pos_external_payee_bo.edi_remittance_method;
    l_ext_payee_rec.edi_remittance_instruction   := p_pos_ap_supplier_bo.p_pos_external_payee_bo.edi_remittance_instruction;

    l_ap_suplier_bo.segment1                       := p_pos_ap_supplier_bo.segment1;
    l_ap_suplier_bo.vendor_name                    := p_pos_ap_supplier_bo.vendor_name;
    l_ap_suplier_bo.vendor_name_alt                := p_pos_ap_supplier_bo.vendor_name_alt;
    l_ap_suplier_bo.summary_flag                   := p_pos_ap_supplier_bo.summary_flag;
    l_ap_suplier_bo.enabled_flag                   := p_pos_ap_supplier_bo.enabled_flag;
    l_ap_suplier_bo.segment2                       := p_pos_ap_supplier_bo.segment2;
    l_ap_suplier_bo.segment3                       := p_pos_ap_supplier_bo.segment3;
    l_ap_suplier_bo.segment4                       := p_pos_ap_supplier_bo.segment4;
    l_ap_suplier_bo.segment5                       := p_pos_ap_supplier_bo.segment5;
    l_ap_suplier_bo.employee_id                    := p_pos_ap_supplier_bo.employee_id;
    l_ap_suplier_bo.vendor_type_lookup_code        := p_pos_ap_supplier_bo.vendor_type_lookup_code;
    l_ap_suplier_bo.customer_num                   := p_pos_ap_supplier_bo.customer_num;
    l_ap_suplier_bo.one_time_flag                  := p_pos_ap_supplier_bo.one_time_flag;
    l_ap_suplier_bo.parent_vendor_id               := p_pos_ap_supplier_bo.parent_vendor_id;
    l_ap_suplier_bo.min_order_amount               := p_pos_ap_supplier_bo.min_order_amount;
    l_ap_suplier_bo.terms_id                       := p_pos_ap_supplier_bo.terms_id;
    l_ap_suplier_bo.set_of_books_id                := p_pos_ap_supplier_bo.set_of_books_id;
    l_ap_suplier_bo.always_take_disc_flag          := p_pos_ap_supplier_bo.always_take_disc_flag;
    l_ap_suplier_bo.pay_date_basis_lookup_code     := p_pos_ap_supplier_bo.pay_date_basis_lookup_code;
    l_ap_suplier_bo.pay_group_lookup_code          := p_pos_ap_supplier_bo.pay_group_lookup_code;
    l_ap_suplier_bo.payment_priority               := p_pos_ap_supplier_bo.payment_priority;
    l_ap_suplier_bo.invoice_currency_code          := p_pos_ap_supplier_bo.invoice_currency_code;
    l_ap_suplier_bo.payment_currency_code          := p_pos_ap_supplier_bo.payment_currency_code;
    l_ap_suplier_bo.invoice_amount_limit           := p_pos_ap_supplier_bo.invoice_amount_limit;
    l_ap_suplier_bo.hold_all_payments_flag         := p_pos_ap_supplier_bo.hold_all_payments_flag;
    l_ap_suplier_bo.hold_future_payments_flag      := p_pos_ap_supplier_bo.hold_future_payments_flag;
    l_ap_suplier_bo.hold_reason                    := p_pos_ap_supplier_bo.hold_reason;
    l_ap_suplier_bo.type_1099                      := p_pos_ap_supplier_bo.type_1099;
    l_ap_suplier_bo.withholding_status_lookup_code := p_pos_ap_supplier_bo.withholding_status_lookup_code;
    l_ap_suplier_bo.withholding_start_date         := p_pos_ap_supplier_bo.withholding_start_date;
    l_ap_suplier_bo.organization_type_lookup_code  := p_pos_ap_supplier_bo.organization_type_lookup_code;
    l_ap_suplier_bo.start_date_active              := p_pos_ap_supplier_bo.start_date_active;
    l_ap_suplier_bo.end_date_active                := p_pos_ap_supplier_bo.end_date_active;
    l_ap_suplier_bo.minority_group_lookup_code     := p_pos_ap_supplier_bo.minority_group_lookup_code;
    l_ap_suplier_bo.women_owned_flag               := p_pos_ap_supplier_bo.women_owned_flag;
    l_ap_suplier_bo.small_business_flag            := p_pos_ap_supplier_bo.small_business_flag;
    l_ap_suplier_bo.hold_flag                      := p_pos_ap_supplier_bo.hold_flag;
    l_ap_suplier_bo.purchasing_hold_reason         := p_pos_ap_supplier_bo.purchasing_hold_reason;
    l_ap_suplier_bo.hold_by                        := p_pos_ap_supplier_bo.hold_by;
    l_ap_suplier_bo.hold_date                      := p_pos_ap_supplier_bo.hold_date;
    l_ap_suplier_bo.terms_date_basis               := p_pos_ap_supplier_bo.terms_date_basis;
    l_ap_suplier_bo.inspection_required_flag       := p_pos_ap_supplier_bo.inspection_required_flag;
    l_ap_suplier_bo.receipt_required_flag          := p_pos_ap_supplier_bo.receipt_required_flag;
    l_ap_suplier_bo.qty_rcv_tolerance              := p_pos_ap_supplier_bo.qty_rcv_tolerance;
    l_ap_suplier_bo.qty_rcv_exception_code         := p_pos_ap_supplier_bo.qty_rcv_exception_code;
    l_ap_suplier_bo.enforce_ship_to_location_code  := p_pos_ap_supplier_bo.enforce_ship_to_location_code;
    l_ap_suplier_bo.days_early_receipt_allowed     := p_pos_ap_supplier_bo.days_early_receipt_allowed;
    l_ap_suplier_bo.days_late_receipt_allowed      := p_pos_ap_supplier_bo.days_late_receipt_allowed;
    l_ap_suplier_bo.receipt_days_exception_code    := p_pos_ap_supplier_bo.receipt_days_exception_code;
    l_ap_suplier_bo.receiving_routing_id           := p_pos_ap_supplier_bo.receiving_routing_id;
    l_ap_suplier_bo.allow_substitute_receipts_flag := p_pos_ap_supplier_bo.allow_substitute_receipts_flag;
    l_ap_suplier_bo.allow_unordered_receipts_flag  := p_pos_ap_supplier_bo.allow_unordered_receipts_flag;
    l_ap_suplier_bo.hold_unmatched_invoices_flag   := p_pos_ap_supplier_bo.hold_unmatched_invoices_flag;
    l_ap_suplier_bo.tax_verification_date          := p_pos_ap_supplier_bo.tax_verification_date;
    l_ap_suplier_bo.name_control                   := p_pos_ap_supplier_bo.name_control;
    l_ap_suplier_bo.state_reportable_flag          := p_pos_ap_supplier_bo.state_reportable_flag;
    l_ap_suplier_bo.federal_reportable_flag        := p_pos_ap_supplier_bo.federal_reportable_flag;
    l_ap_suplier_bo.attribute_category             := p_pos_ap_supplier_bo.attribute_category;
    l_ap_suplier_bo.attribute1                     := p_pos_ap_supplier_bo.attribute1;
    l_ap_suplier_bo.attribute2                     := p_pos_ap_supplier_bo.attribute2;
    l_ap_suplier_bo.attribute3                     := p_pos_ap_supplier_bo.attribute3;
    l_ap_suplier_bo.attribute4                     := p_pos_ap_supplier_bo.attribute4;
    l_ap_suplier_bo.attribute5                     := p_pos_ap_supplier_bo.attribute5;
    l_ap_suplier_bo.attribute6                     := p_pos_ap_supplier_bo.attribute6;
    l_ap_suplier_bo.attribute7                     := p_pos_ap_supplier_bo.attribute7;
    l_ap_suplier_bo.attribute8                     := p_pos_ap_supplier_bo.attribute8;
    l_ap_suplier_bo.attribute9                     := p_pos_ap_supplier_bo.attribute9;
    l_ap_suplier_bo.attribute10                    := p_pos_ap_supplier_bo.attribute10;
    l_ap_suplier_bo.attribute11                    := p_pos_ap_supplier_bo.attribute11;
    l_ap_suplier_bo.attribute12                    := p_pos_ap_supplier_bo.attribute12;
    l_ap_suplier_bo.attribute13                    := p_pos_ap_supplier_bo.attribute13;
    l_ap_suplier_bo.attribute14                    := p_pos_ap_supplier_bo.attribute14;
    l_ap_suplier_bo.attribute15                    := p_pos_ap_supplier_bo.attribute15;
    l_ap_suplier_bo.auto_calculate_interest_flag   := p_pos_ap_supplier_bo.auto_calculate_interest_flag;
    l_ap_suplier_bo.validation_number              := p_pos_ap_supplier_bo.validation_number;
    l_ap_suplier_bo.exclude_freight_from_discount  := p_pos_ap_supplier_bo.exclude_freight_from_discount;
    l_ap_suplier_bo.tax_reporting_name             := p_pos_ap_supplier_bo.tax_reporting_name;
    l_ap_suplier_bo.check_digits                   := p_pos_ap_supplier_bo.check_digits;
    l_ap_suplier_bo.allow_awt_flag                 := p_pos_ap_supplier_bo.allow_awt_flag;
    l_ap_suplier_bo.awt_group_id                   := p_pos_ap_supplier_bo.awt_group_id;
    --l_ap_suplier_bo.awt_group_name                 := p_pos_ap_supplier_bo.awt_group_name;
    l_ap_suplier_bo.pay_awt_group_id := p_pos_ap_supplier_bo.pay_awt_group_id;
    -- l_ap_suplier_bo.pay_awt_group_name             := p_pos_ap_supplier_bo.pay_awt_group_name;
    l_ap_suplier_bo.global_attribute1         := p_pos_ap_supplier_bo.global_attribute1;
    l_ap_suplier_bo.global_attribute2         := p_pos_ap_supplier_bo.global_attribute2;
    l_ap_suplier_bo.global_attribute3         := p_pos_ap_supplier_bo.global_attribute3;
    l_ap_suplier_bo.global_attribute4         := p_pos_ap_supplier_bo.global_attribute4;
    l_ap_suplier_bo.global_attribute5         := p_pos_ap_supplier_bo.global_attribute5;
    l_ap_suplier_bo.global_attribute6         := p_pos_ap_supplier_bo.global_attribute6;
    l_ap_suplier_bo.global_attribute7         := p_pos_ap_supplier_bo.global_attribute7;
    l_ap_suplier_bo.global_attribute8         := p_pos_ap_supplier_bo.global_attribute8;
    l_ap_suplier_bo.global_attribute9         := p_pos_ap_supplier_bo.global_attribute9;
    l_ap_suplier_bo.global_attribute10        := p_pos_ap_supplier_bo.global_attribute10;
    l_ap_suplier_bo.global_attribute11        := p_pos_ap_supplier_bo.global_attribute11;
    l_ap_suplier_bo.global_attribute12        := p_pos_ap_supplier_bo.global_attribute12;
    l_ap_suplier_bo.global_attribute13        := p_pos_ap_supplier_bo.global_attribute13;
    l_ap_suplier_bo.global_attribute14        := p_pos_ap_supplier_bo.global_attribute14;
    l_ap_suplier_bo.global_attribute15        := p_pos_ap_supplier_bo.global_attribute15;
    l_ap_suplier_bo.global_attribute16        := p_pos_ap_supplier_bo.global_attribute16;
    l_ap_suplier_bo.global_attribute17        := p_pos_ap_supplier_bo.global_attribute17;
    l_ap_suplier_bo.global_attribute18        := p_pos_ap_supplier_bo.global_attribute18;
    l_ap_suplier_bo.global_attribute19        := p_pos_ap_supplier_bo.global_attribute19;
    l_ap_suplier_bo.global_attribute20        := p_pos_ap_supplier_bo.global_attribute20;
    l_ap_suplier_bo.global_attribute_category := p_pos_ap_supplier_bo.global_attribute_category;
    l_ap_suplier_bo.bank_charge_bearer        := p_pos_ap_supplier_bo.bank_charge_bearer;
    l_ap_suplier_bo.match_option              := p_pos_ap_supplier_bo.match_option;
    l_ap_suplier_bo.create_debit_memo_flag    := p_pos_ap_supplier_bo.create_debit_memo_flag;
    l_ap_suplier_bo.party_id                  := l_party_id;
    l_ap_suplier_bo.parent_party_id           := p_pos_ap_supplier_bo.parent_party_id;
    --l_ap_suplier_bo.jgzz_fiscal_code               := p_pos_ap_supplier_bo.jgzz_fiscal_code;
    -- l_ap_suplier_bo.sic_code                       := p_pos_ap_supplier_bo.sic_code;
    -- l_ap_suplier_bo.tax_reference                  := p_pos_ap_supplier_bo.tax_reference;
    -- l_ap_suplier_bo.inventory_organization_id      := p_pos_ap_supplier_bo.inventory_organization_id;
    -- l_ap_suplier_bo.terms_name                     := p_pos_ap_supplier_bo.terms_name;
    -- l_ap_suplier_bo.default_terms_id               := p_pos_ap_supplier_bo.default_terms_id;
    -- l_ap_suplier_bo.vendor_interface_id            := p_pos_ap_supplier_bo.vendor_interface_id;
    -- l_ap_suplier_bo.ni_number                  := p_pos_ap_supplier_bo.ni_number;
    l_ap_suplier_bo.ext_payee_rec              := l_ext_payee_rec;
    l_ap_suplier_bo.edi_payment_format         := p_pos_ap_supplier_bo.edi_payment_format;
    l_ap_suplier_bo.edi_transaction_handling   := p_pos_ap_supplier_bo.edi_transaction_handling;
    l_ap_suplier_bo.edi_payment_method         := p_pos_ap_supplier_bo.edi_payment_method;
    l_ap_suplier_bo.edi_remittance_method      := p_pos_ap_supplier_bo.edi_remittance_method;
    l_ap_suplier_bo.edi_remittance_instruction := p_pos_ap_supplier_bo.edi_remittance_instruction;

    IF p_create_update_flag = 'C' THEN
      x_msg_count := 0;
      x_msg_data  := '0';
      ap_vendor_pub_pkg.create_vendor(p_api_version      => 1.0,
                                      p_init_msg_list    => fnd_api.g_false,
                                      p_commit           => fnd_api.g_false,
                                      p_validation_level => fnd_api.g_valid_level_full,
                                      x_return_status    => x_return_status,
                                      x_msg_count        => x_msg_count,
                                      x_msg_data         => x_msg_data,
                                      p_vendor_rec       => l_ap_suplier_bo,
                                      x_vendor_id        => x_vendor_id,
                                      x_party_id         => x_party_id);
      IF x_return_status IS NULL THEN
        x_return_status := fnd_api.g_ret_sts_success;
      END IF;
      IF x_return_status = fnd_api.g_ret_sts_success THEN
        create_party_orig_ref(p_party_id              => x_party_id,
                              p_orig_system           => p_orig_system,
                              p_orig_system_reference => p_orig_system_reference,
                              x_return_status         => x_return_status,
                              x_msg_count             => x_msg_count,
                              x_msg_data              => x_msg_data);
      END IF;
    ELSIF p_create_update_flag = 'U' THEN
      IF p_pos_ap_supplier_bo.p_pos_external_payee_bo.payee_party_id IS NULL THEN
        l_ext_payee_rec.payee_party_id := l_party_id;
      ELSE

        l_ext_payee_rec.payee_party_id := p_pos_ap_supplier_bo.p_pos_external_payee_bo.payee_party_id;
      END IF;

      IF p_pos_ap_supplier_bo.vendor_id IS NULL OR
         p_pos_ap_supplier_bo.vendor_id = 0 THEN
        BEGIN
          SELECT vendor_id
          INTO   l_vendor_id
          FROM   ap_suppliers
          WHERE  party_id = l_party_id;
          l_ap_suplier_bo.vendor_id := l_vendor_id;
        EXCEPTION
          WHEN no_data_found THEN
            l_ap_suplier_bo.vendor_id := p_pos_ap_supplier_bo.vendor_id;
        END;

      ELSE
        l_ap_suplier_bo.vendor_id := p_pos_ap_supplier_bo.vendor_id;
      END IF;
      ap_vendor_pub_pkg.update_vendor(p_api_version      => 1.0,
                                      p_init_msg_list    => fnd_api.g_false,
                                      p_commit           => fnd_api.g_false,
                                      p_validation_level => fnd_api.g_valid_level_full,
                                      x_return_status    => x_return_status,
                                      x_msg_count        => x_msg_count,
                                      x_msg_data         => x_msg_data,
                                      p_vendor_rec       => l_ap_suplier_bo,
                                      p_vendor_id        => l_vendor_id);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
  END create_pos_ap_supplier;

  /*#
  * Use this routine to check whether the party is supplier or not
  * @param p_orig_system The Orignial System
  * @param p_orig_system_reference The Original System Reference
  * @param x_return_status The return status
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Is Supplier
  * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
  */
  PROCEDURE is_customer
  (
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
  ) IS
    l_party_id      NUMBER;
    l_party_id_supp NUMBER;

  BEGIN
    SELECT nvl(owner_table_id, -9999)
    INTO   l_party_id
    FROM   hz_orig_sys_references hr
    WHERE  hr.owner_table_name = 'HZ_PARTIES'
    AND    hr.orig_system = p_orig_system
    AND    hr.orig_system_reference = p_orig_system_reference
    AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE;

    -- Customer Check in ap_suppliers table
    IF l_party_id <> -9999 THEN
      SELECT nvl(party_id, -9999)
      INTO   l_party_id_supp
      FROM   ap_suppliers
      WHERE  party_id = l_party_id;
    ELSE
      l_party_id_supp := -9999;
    END IF;

    IF l_party_id_supp <> -9999 THEN
      x_return_status := 'Y';
    ELSE
      x_return_status := 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'N';
  END is_customer;

/*#
    * Use this routine to create ap suplier
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_ap_suplier_bo The ap_vendor_pub_pkg.r_vendor_rec_type
    * @param p_vendor_id The party id
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Supplier Contact
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */

/*PROCEDURE update_pos_ap_supplier(p_api_version           IN NUMBER DEFAULT NULL,
                                     p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                     p_pos_ap_supplier_bo    IN pos_ap_supplier_bo,
                                     p_pos_external_payee_bo IN pos_external_payee_bo,
                                     p_orig_system           IN VARCHAR2,
                                     p_orig_system_reference IN VARCHAR2,
                                     p_vendor_id             OUT NOCOPY NUMBER,
                                     x_return_status         OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2) IS
        l_exists_row    NUMBER;
        l_ap_suplier_bo ap_vendor_pub_pkg.r_vendor_rec_type;
        l_ext_payee_rec iby_disbursement_setup_pub.external_payee_rec_type;
        l_party_id      NUMBER;
        l_vendor_id     NUMBER;
    BEGIN
        l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                           p_orig_system_reference);

        SELECT vendor_id
        INTO   l_vendor_id
        FROM   ap_suppliers
        WHERE  party_id = l_party_id;

        l_ext_payee_rec.payee_party_id               := l_party_id;
        l_ext_payee_rec.payment_function             := p_pos_external_payee_bo.payment_function;
        l_ext_payee_rec.exclusive_pay_flag           := p_pos_external_payee_bo.exclusive_pay_flag;
        l_ext_payee_rec.payee_party_site_id          := p_pos_external_payee_bo.payee_party_site_id;
        l_ext_payee_rec.supplier_site_id             := p_pos_external_payee_bo.supplier_site_id;
        l_ext_payee_rec.payer_org_id                 := p_pos_external_payee_bo.payer_org_id;
        l_ext_payee_rec.payer_org_type               := p_pos_external_payee_bo.payer_org_type;
        l_ext_payee_rec.default_pmt_method           := p_pos_external_payee_bo.default_pmt_method;
        l_ext_payee_rec.ece_tp_loc_code              := p_pos_external_payee_bo.ece_tp_loc_code;
        l_ext_payee_rec.bank_charge_bearer           := p_pos_external_payee_bo.bank_charge_bearer;
        l_ext_payee_rec.bank_instr1_code             := p_pos_external_payee_bo.bank_instr1_code;
        l_ext_payee_rec.bank_instr2_code             := p_pos_external_payee_bo.bank_instr2_code;
        l_ext_payee_rec.bank_instr_detail            := p_pos_external_payee_bo.bank_instr_detail;
        l_ext_payee_rec.pay_reason_code              := p_pos_external_payee_bo.pay_reason_code;
        l_ext_payee_rec.pay_reason_com               := p_pos_external_payee_bo.pay_reason_com;
        l_ext_payee_rec.inactive_date                := p_pos_external_payee_bo.inactive_date;
        l_ext_payee_rec.pay_message1                 := p_pos_external_payee_bo.pay_message1;
        l_ext_payee_rec.pay_message2                 := p_pos_external_payee_bo.pay_message2;
        l_ext_payee_rec.pay_message3                 := p_pos_external_payee_bo.pay_message3;
        l_ext_payee_rec.delivery_channel             := p_pos_external_payee_bo.delivery_channel;
        l_ext_payee_rec.pmt_format                   := p_pos_external_payee_bo.pmt_format;
        l_ext_payee_rec.settlement_priority          := p_pos_external_payee_bo.settlement_priority;
        l_ext_payee_rec.remit_advice_delivery_method := p_pos_external_payee_bo.remit_advice_delivery_method;
        l_ext_payee_rec.remit_advice_email           := p_pos_external_payee_bo.remit_advice_email;
        l_ext_payee_rec.edi_payment_format           := p_pos_external_payee_bo.edi_payment_format;
        l_ext_payee_rec.edi_transaction_handling     := p_pos_external_payee_bo.edi_transaction_handling;
        l_ext_payee_rec.edi_payment_method           := p_pos_external_payee_bo.edi_payment_method;
        l_ext_payee_rec.edi_remittance_method        := p_pos_external_payee_bo.edi_remittance_method;
        l_ext_payee_rec.edi_remittance_instruction   := p_pos_external_payee_bo.edi_remittance_instruction;

        l_ap_suplier_bo.vendor_id                      := l_vendor_id;
        l_ap_suplier_bo.segment1                       := p_pos_ap_supplier_bo.segment1;
        l_ap_suplier_bo.vendor_name                    := p_pos_ap_supplier_bo.vendor_name;
        l_ap_suplier_bo.vendor_name_alt                := p_pos_ap_supplier_bo.vendor_name_alt;
        l_ap_suplier_bo.summary_flag                   := p_pos_ap_supplier_bo.summary_flag;
        l_ap_suplier_bo.enabled_flag                   := p_pos_ap_supplier_bo.enabled_flag;
        l_ap_suplier_bo.segment2                       := p_pos_ap_supplier_bo.segment2;
        l_ap_suplier_bo.segment3                       := p_pos_ap_supplier_bo.segment3;
        l_ap_suplier_bo.segment4                       := p_pos_ap_supplier_bo.segment4;
        l_ap_suplier_bo.segment5                       := p_pos_ap_supplier_bo.segment5;
        l_ap_suplier_bo.employee_id                    := p_pos_ap_supplier_bo.employee_id;
        l_ap_suplier_bo.vendor_type_lookup_code        := p_pos_ap_supplier_bo.vendor_type_lookup_code;
        l_ap_suplier_bo.customer_num                   := p_pos_ap_supplier_bo.customer_num;
        l_ap_suplier_bo.one_time_flag                  := p_pos_ap_supplier_bo.one_time_flag;
        l_ap_suplier_bo.parent_vendor_id               := p_pos_ap_supplier_bo.parent_vendor_id;
        l_ap_suplier_bo.min_order_amount               := p_pos_ap_supplier_bo.min_order_amount;
        l_ap_suplier_bo.terms_id                       := p_pos_ap_supplier_bo.terms_id;
        l_ap_suplier_bo.set_of_books_id                := p_pos_ap_supplier_bo.set_of_books_id;
        l_ap_suplier_bo.always_take_disc_flag          := p_pos_ap_supplier_bo.always_take_disc_flag;
        l_ap_suplier_bo.pay_date_basis_lookup_code     := p_pos_ap_supplier_bo.pay_date_basis_lookup_code;
        l_ap_suplier_bo.pay_group_lookup_code          := p_pos_ap_supplier_bo.pay_group_lookup_code;
        l_ap_suplier_bo.payment_priority               := p_pos_ap_supplier_bo.payment_priority;
        l_ap_suplier_bo.invoice_currency_code          := p_pos_ap_supplier_bo.invoice_currency_code;
        l_ap_suplier_bo.payment_currency_code          := p_pos_ap_supplier_bo.payment_currency_code;
        l_ap_suplier_bo.invoice_amount_limit           := p_pos_ap_supplier_bo.invoice_amount_limit;
        l_ap_suplier_bo.hold_all_payments_flag         := p_pos_ap_supplier_bo.hold_all_payments_flag;
        l_ap_suplier_bo.hold_future_payments_flag      := p_pos_ap_supplier_bo.hold_future_payments_flag;
        l_ap_suplier_bo.hold_reason                    := p_pos_ap_supplier_bo.hold_reason;
        l_ap_suplier_bo.type_1099                      := p_pos_ap_supplier_bo.type_1099;
        l_ap_suplier_bo.withholding_status_lookup_code := p_pos_ap_supplier_bo.withholding_status_lookup_code;
        l_ap_suplier_bo.withholding_start_date         := p_pos_ap_supplier_bo.withholding_start_date;
        l_ap_suplier_bo.organization_type_lookup_code  := p_pos_ap_supplier_bo.organization_type_lookup_code;
        l_ap_suplier_bo.start_date_active              := p_pos_ap_supplier_bo.start_date_active;
        l_ap_suplier_bo.end_date_active                := p_pos_ap_supplier_bo.end_date_active;
        l_ap_suplier_bo.minority_group_lookup_code     := p_pos_ap_supplier_bo.minority_group_lookup_code;
        l_ap_suplier_bo.women_owned_flag               := p_pos_ap_supplier_bo.women_owned_flag;
        l_ap_suplier_bo.small_business_flag            := p_pos_ap_supplier_bo.small_business_flag;
        l_ap_suplier_bo.hold_flag                      := p_pos_ap_supplier_bo.hold_flag;
        l_ap_suplier_bo.purchasing_hold_reason         := p_pos_ap_supplier_bo.purchasing_hold_reason;
        l_ap_suplier_bo.hold_by                        := p_pos_ap_supplier_bo.hold_by;
        l_ap_suplier_bo.hold_date                      := p_pos_ap_supplier_bo.hold_date;
        l_ap_suplier_bo.terms_date_basis               := p_pos_ap_supplier_bo.terms_date_basis;
        l_ap_suplier_bo.inspection_required_flag       := p_pos_ap_supplier_bo.inspection_required_flag;
        l_ap_suplier_bo.receipt_required_flag          := p_pos_ap_supplier_bo.receipt_required_flag;
        l_ap_suplier_bo.qty_rcv_tolerance              := p_pos_ap_supplier_bo.qty_rcv_tolerance;
        l_ap_suplier_bo.qty_rcv_exception_code         := p_pos_ap_supplier_bo.qty_rcv_exception_code;
        l_ap_suplier_bo.enforce_ship_to_location_code  := p_pos_ap_supplier_bo.enforce_ship_to_location_code;
        l_ap_suplier_bo.days_early_receipt_allowed     := p_pos_ap_supplier_bo.days_early_receipt_allowed;
        l_ap_suplier_bo.days_late_receipt_allowed      := p_pos_ap_supplier_bo.days_late_receipt_allowed;
        l_ap_suplier_bo.receipt_days_exception_code    := p_pos_ap_supplier_bo.receipt_days_exception_code;
        l_ap_suplier_bo.receiving_routing_id           := p_pos_ap_supplier_bo.receiving_routing_id;
        l_ap_suplier_bo.allow_substitute_receipts_flag := p_pos_ap_supplier_bo.allow_substitute_receipts_flag;
        l_ap_suplier_bo.allow_unordered_receipts_flag  := p_pos_ap_supplier_bo.allow_unordered_receipts_flag;
        l_ap_suplier_bo.hold_unmatched_invoices_flag   := p_pos_ap_supplier_bo.hold_unmatched_invoices_flag;
        l_ap_suplier_bo.tax_verification_date          := p_pos_ap_supplier_bo.tax_verification_date;
        l_ap_suplier_bo.name_control                   := p_pos_ap_supplier_bo.name_control;
        l_ap_suplier_bo.state_reportable_flag          := p_pos_ap_supplier_bo.state_reportable_flag;
        l_ap_suplier_bo.federal_reportable_flag        := p_pos_ap_supplier_bo.federal_reportable_flag;
        l_ap_suplier_bo.attribute_category             := p_pos_ap_supplier_bo.attribute_category;
        l_ap_suplier_bo.attribute1                     := p_pos_ap_supplier_bo.attribute1;
        l_ap_suplier_bo.attribute2                     := p_pos_ap_supplier_bo.attribute2;
        l_ap_suplier_bo.attribute3                     := p_pos_ap_supplier_bo.attribute3;
        l_ap_suplier_bo.attribute4                     := p_pos_ap_supplier_bo.attribute4;
        l_ap_suplier_bo.attribute5                     := p_pos_ap_supplier_bo.attribute5;
        l_ap_suplier_bo.attribute6                     := p_pos_ap_supplier_bo.attribute6;
        l_ap_suplier_bo.attribute7                     := p_pos_ap_supplier_bo.attribute7;
        l_ap_suplier_bo.attribute8                     := p_pos_ap_supplier_bo.attribute8;
        l_ap_suplier_bo.attribute9                     := p_pos_ap_supplier_bo.attribute9;
        l_ap_suplier_bo.attribute10                    := p_pos_ap_supplier_bo.attribute10;
        l_ap_suplier_bo.attribute11                    := p_pos_ap_supplier_bo.attribute11;
        l_ap_suplier_bo.attribute12                    := p_pos_ap_supplier_bo.attribute12;
        l_ap_suplier_bo.attribute13                    := p_pos_ap_supplier_bo.attribute13;
        l_ap_suplier_bo.attribute14                    := p_pos_ap_supplier_bo.attribute14;
        l_ap_suplier_bo.attribute15                    := p_pos_ap_supplier_bo.attribute15;
        l_ap_suplier_bo.auto_calculate_interest_flag   := p_pos_ap_supplier_bo.auto_calculate_interest_flag;
        l_ap_suplier_bo.validation_number              := p_pos_ap_supplier_bo.validation_number;
        l_ap_suplier_bo.exclude_freight_from_discount  := p_pos_ap_supplier_bo.exclude_freight_from_discount;
        l_ap_suplier_bo.tax_reporting_name             := p_pos_ap_supplier_bo.tax_reporting_name;
        l_ap_suplier_bo.check_digits                   := p_pos_ap_supplier_bo.check_digits;
        l_ap_suplier_bo.allow_awt_flag                 := p_pos_ap_supplier_bo.allow_awt_flag;
        l_ap_suplier_bo.awt_group_id                   := p_pos_ap_supplier_bo.awt_group_id;
        --        l_ap_suplier_bo.awt_group_name                 := p_pos_ap_supplier_bo.awt_group_name;
        l_ap_suplier_bo.pay_awt_group_id := p_pos_ap_supplier_bo.pay_awt_group_id;
        --        l_ap_suplier_bo.pay_awt_group_name             := p_pos_ap_supplier_bo.pay_awt_group_name;
        l_ap_suplier_bo.global_attribute1         := p_pos_ap_supplier_bo.global_attribute1;
        l_ap_suplier_bo.global_attribute2         := p_pos_ap_supplier_bo.global_attribute2;
        l_ap_suplier_bo.global_attribute3         := p_pos_ap_supplier_bo.global_attribute3;
        l_ap_suplier_bo.global_attribute4         := p_pos_ap_supplier_bo.global_attribute4;
        l_ap_suplier_bo.global_attribute5         := p_pos_ap_supplier_bo.global_attribute5;
        l_ap_suplier_bo.global_attribute6         := p_pos_ap_supplier_bo.global_attribute6;
        l_ap_suplier_bo.global_attribute7         := p_pos_ap_supplier_bo.global_attribute7;
        l_ap_suplier_bo.global_attribute8         := p_pos_ap_supplier_bo.global_attribute8;
        l_ap_suplier_bo.global_attribute9         := p_pos_ap_supplier_bo.global_attribute9;
        l_ap_suplier_bo.global_attribute10        := p_pos_ap_supplier_bo.global_attribute10;
        l_ap_suplier_bo.global_attribute11        := p_pos_ap_supplier_bo.global_attribute11;
        l_ap_suplier_bo.global_attribute12        := p_pos_ap_supplier_bo.global_attribute12;
        l_ap_suplier_bo.global_attribute13        := p_pos_ap_supplier_bo.global_attribute13;
        l_ap_suplier_bo.global_attribute14        := p_pos_ap_supplier_bo.global_attribute14;
        l_ap_suplier_bo.global_attribute15        := p_pos_ap_supplier_bo.global_attribute15;
        l_ap_suplier_bo.global_attribute16        := p_pos_ap_supplier_bo.global_attribute16;
        l_ap_suplier_bo.global_attribute17        := p_pos_ap_supplier_bo.global_attribute17;
        l_ap_suplier_bo.global_attribute18        := p_pos_ap_supplier_bo.global_attribute18;
        l_ap_suplier_bo.global_attribute19        := p_pos_ap_supplier_bo.global_attribute19;
        l_ap_suplier_bo.global_attribute20        := p_pos_ap_supplier_bo.global_attribute20;
        l_ap_suplier_bo.global_attribute_category := p_pos_ap_supplier_bo.global_attribute_category;
        l_ap_suplier_bo.bank_charge_bearer        := p_pos_ap_supplier_bo.bank_charge_bearer;
        l_ap_suplier_bo.match_option              := p_pos_ap_supplier_bo.match_option;
        l_ap_suplier_bo.create_debit_memo_flag    := p_pos_ap_supplier_bo.create_debit_memo_flag;
        l_ap_suplier_bo.party_id                  := l_party_id;
        l_ap_suplier_bo.parent_party_id           := p_pos_ap_supplier_bo.parent_party_id;
        --   l_ap_suplier_bo.jgzz_fiscal_code               := p_pos_ap_supplier_bo.jgzz_fiscal_code;
        --   l_ap_suplier_bo.sic_code                       := p_pos_ap_supplier_bo.sic_code;
        --  l_ap_suplier_bo.tax_reference                  := p_pos_ap_supplier_bo.tax_reference;
        --  l_ap_suplier_bo.inventory_organization_id      := p_pos_ap_supplier_bo.inventory_organization_id;
        -- l_ap_suplier_bo.terms_name                     := p_pos_ap_supplier_bo.terms_name;
        -- l_ap_suplier_bo.default_terms_id               := p_pos_ap_supplier_bo.default_terms_id;
        -- l_ap_suplier_bo.vendor_interface_id            := p_pos_ap_supplier_bo.vendor_interface_id;
        l_ap_suplier_bo.ni_number                  := p_pos_ap_supplier_bo.ni_number;
        l_ap_suplier_bo.ext_payee_rec              := l_ext_payee_rec;
        l_ap_suplier_bo.edi_payment_format         := p_pos_ap_supplier_bo.edi_payment_format;
        l_ap_suplier_bo.edi_transaction_handling   := p_pos_ap_supplier_bo.edi_transaction_handling;
        l_ap_suplier_bo.edi_payment_method         := p_pos_ap_supplier_bo.edi_payment_method;
        l_ap_suplier_bo.edi_remittance_method      := p_pos_ap_supplier_bo.edi_remittance_method;
        l_ap_suplier_bo.edi_remittance_instruction := p_pos_ap_supplier_bo.edi_remittance_instruction;

        ap_vendor_pub_pkg.update_vendor(p_api_version      => 1.0,
                                        p_init_msg_list    => fnd_api.g_false,
                                        p_commit           => fnd_api.g_false,
                                        p_validation_level => fnd_api.g_valid_level_full,
                                        x_return_status    => x_return_status,
                                        x_msg_count        => x_msg_count,
                                        x_msg_data         => x_msg_data,
                                        p_vendor_rec       => l_ap_suplier_bo,
                                        p_vendor_id        => l_vendor_id);

        p_vendor_id := l_vendor_id;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
    END update_pos_ap_supplier;
*/
END pos_ap_supplier_bo_pkg;

/
