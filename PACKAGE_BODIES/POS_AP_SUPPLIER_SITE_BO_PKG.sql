--------------------------------------------------------
--  DDL for Package Body POS_AP_SUPPLIER_SITE_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_AP_SUPPLIER_SITE_BO_PKG" AS
/* $Header: POSSPSTB.pls 120.0.12010000.8 2014/04/14 20:11:36 dalu noship $ */
  /*#
  * Use this routine to create supplier contact
  * @param p_api_version The version of API
  * @param p_init_msg_list The Initialization message list
  * @param p_vendor_contact_rec The supplier contact record
  * @param x_vendor_contact_id The Vendor Contact Id
  * @param x_per_party_id  The Person Party ID
  * @param x_rel_party_id  The Rel Party Id
  * @param x_org_contact_id  The Organization contact id
  * @param x_party_site_id The Party Site Id
  * @param x_return_status The return status
  * @param x_msg_count The message count
  * @param x_msg_data The message data
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Create Vendor Site
  * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
  */
  PROCEDURE create_vendor_site
  (
    p_site_rec      IN ap_vendor_pub_pkg.r_vendor_site_rec_type,
    ext_payee_rec   IN OUT NOCOPY iby_disbursement_setup_pub.external_payee_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'CREATE_VENDOR_SITE';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status  VARCHAR2(2000);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_vendor_site_id NUMBER;
    l_party_site_id  NUMBER;
    l_location_id    NUMBER;

    /* Variable Declaration for IBY */

    ext_payee_tab iby_disbursement_setup_pub.external_payee_tab_type;

    ext_payee_id_tab iby_disbursement_setup_pub.ext_payee_id_tab_type;

    ext_payee_create_tab iby_disbursement_setup_pub.ext_payee_create_tab_type;
    l_temp_ext_acct_id   NUMBER;
    ext_response_rec     iby_fndcpt_common_pub.result_rec_type;

    l_ext_payee_id NUMBER;
    l_bank_acct_id NUMBER;

    CURSOR iby_ext_accts_cur(p_unique_ref IN NUMBER) IS
      SELECT temp_ext_bank_acct_id
      FROM   iby_temp_ext_bank_accts
      WHERE  calling_app_unique_ref2 = p_unique_ref
      AND    nvl(status, 'NEW') <> 'PROCESSED';

    l_debug_info           VARCHAR2(500);
    l_rollback_vendor_site VARCHAR2(1) := 'N';
    l_payee_msg_count      NUMBER;
    l_payee_msg_data       VARCHAR2(4000);
    l_error_code           VARCHAR2(4000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE CREATE_VENDOR_SITE' ||
                      ' Parameters  vendor_id: ' || p_site_rec.vendor_id ||
                      ' vendor_site_interface_id: ' ||
                      p_site_rec.vendor_site_interface_id);

    SAVEPOINT import_vendor_sites_pub2;

    ap_vendor_pub_pkg.create_vendor_site(p_api_version      => 1.0,
                                         p_init_msg_list    => fnd_api.g_false,
                                         p_commit           => fnd_api.g_false,
                                         p_validation_level => fnd_api.g_valid_level_full,
                                         x_return_status    => l_return_status,
                                         x_msg_count        => l_msg_count,
                                         x_msg_data         => l_msg_data,
                                         p_vendor_site_rec  => p_site_rec,
                                         x_vendor_site_id   => l_vendor_site_id,
                                         x_party_site_id    => l_party_site_id,
                                         x_location_id      => l_location_id);

    IF l_return_status = fnd_api.g_ret_sts_success THEN

      ext_payee_rec.supplier_site_id    := l_vendor_site_id;
      ext_payee_rec.payee_party_site_id := l_party_site_id;

      SELECT org_id
      INTO   ext_payee_rec.payer_org_id
      FROM   po_vendor_sites_all
      WHERE  vendor_site_id = l_vendor_site_id;

      SELECT party_id,
             'PAYABLES_DISB'
      INTO   ext_payee_rec.payee_party_id,
             ext_payee_rec.payment_function
      FROM   po_vendors
      WHERE  vendor_id = p_site_rec.vendor_id;

      /* Calling IBY Payee Validation API */
      iby_disbursement_setup_pub.validate_external_payee(p_api_version   => 1.0,
                                                         p_init_msg_list => fnd_api.g_false,
                                                         p_ext_payee_rec => ext_payee_rec,
                                                         x_return_status => l_return_status,
                                                         x_msg_count     => l_msg_count,
                                                         x_msg_data      => l_msg_data);

      IF l_return_status = fnd_api.g_ret_sts_success THEN
        ext_payee_tab(1) := ext_payee_rec;

        /* Calling IBY Payee Creation API */
        iby_disbursement_setup_pub.create_external_payee(p_api_version          => 1.0,
                                                         p_init_msg_list        => fnd_api.g_false,
                                                         p_ext_payee_tab        => ext_payee_tab,
                                                         x_return_status        => l_return_status,
                                                         x_msg_count            => l_msg_count,
                                                         x_msg_data             => l_msg_data,
                                                         x_ext_payee_id_tab     => ext_payee_id_tab,
                                                         x_ext_payee_status_tab => ext_payee_create_tab);

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          l_ext_payee_id := ext_payee_id_tab(1).ext_payee_id;

          UPDATE iby_temp_ext_bank_accts
          SET    ext_payee_id           = l_ext_payee_id,
                 account_owner_party_id = ext_payee_rec.payee_party_id --bug 6753331
          WHERE  calling_app_unique_ref2 =
                 p_site_rec.vendor_site_interface_id;

          -- Cursor processing for iby temp bank account record
          OPEN iby_ext_accts_cur(p_site_rec.vendor_site_interface_id);
          LOOP

            FETCH iby_ext_accts_cur
              INTO l_temp_ext_acct_id;
            EXIT WHEN iby_ext_accts_cur%NOTFOUND;

            /* Calling IBY Bank Account Validation API */
            iby_disbursement_setup_pub.validate_temp_ext_bank_acct(p_api_version      => 1.0,
                                                                   p_init_msg_list    => fnd_api.g_false,
                                                                   x_return_status    => l_return_status,
                                                                   x_msg_count        => l_msg_count,
                                                                   x_msg_data         => l_msg_data,
                                                                   p_temp_ext_acct_id => l_temp_ext_acct_id);

            IF l_return_status = fnd_api.g_ret_sts_success THEN
              /* Calling IBY Bank Account Creation API */

              iby_disbursement_setup_pub.create_temp_ext_bank_acct(p_api_version       => 1.0,
                                                                   p_init_msg_list     => fnd_api.g_false,
                                                                   x_return_status     => l_return_status,
                                                                   x_msg_count         => l_msg_count,
                                                                   x_msg_data          => l_msg_data,
                                                                   p_temp_ext_acct_id  => l_temp_ext_acct_id,
                                                                   p_association_level => 'SS',
                                                                   p_supplier_site_id  => l_vendor_site_id,
                                                                   p_party_site_id     => ext_payee_rec.payee_party_site_id,
                                                                   p_org_id            => ext_payee_rec.payer_org_id,
                                                                   p_org_type          => 'OPERATING_UNIT',
                                                                   x_bank_acc_id       => l_bank_acct_id,
                                                                   x_response          => ext_response_rec);

              IF l_return_status = fnd_api.g_ret_sts_success THEN
                UPDATE iby_temp_ext_bank_accts
                SET    status = 'PROCESSED'
                WHERE  temp_ext_bank_acct_id = l_temp_ext_acct_id;

              ELSE
                l_rollback_vendor_site := 'Y';

                fnd_message.set_name('SQLAP', 'AP_BANK_ACCT_CREATION');
                fnd_msg_pub.add;

              END IF; -- Bank Account Creation API

            ELSE
              l_rollback_vendor_site := 'Y';

              fnd_message.set_name('SQLAP', 'AP_INVALID_BANK_ACCT_INFO');
              fnd_msg_pub.add;

            END IF; -- Bank Account Validation API

          END LOOP;
          CLOSE iby_ext_accts_cur;

          /*Rollback if bank account creation fails*/
          IF l_rollback_vendor_site = 'Y' THEN

            ROLLBACK TO import_vendor_sites_pub2;

          END IF;

          -- Payee Creation API

        END IF;

      END IF;
    END IF; -- Supplier Site Creation API
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
  END;
  /* $Header: POSSPSTB.pls 120.0.12010000.8 2014/04/14 20:11:36 dalu noship $ */
  /*#
  * Use this routine to create supplier contact
  * @param p_api_version The version of API
  * @param p_init_msg_list The Initialization message list
  * @param p_vendor_contact_rec The supplier contact record
  * @param x_vendor_contact_id The Vendor Contact Id
  * @param x_per_party_id  The Person Party ID
  * @param x_rel_party_id  The Rel Party Id
  * @param x_org_contact_id  The Organization contact id
  * @param x_party_site_id The Party Site Id
  * @param x_return_status The return status
  * @param x_msg_count The message count
  * @param x_msg_data The message data
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Supplier Sites
  * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
  */
  PROCEDURE get_pos_supplier_sites_bo_tbl
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_ap_supplier_sites_bo  OUT NOCOPY pos_supplier_sites_all_bo_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS

    l_pos_ap_supplier_sites_bo_tbl pos_supplier_sites_all_bo_tbl := pos_supplier_sites_all_bo_tbl();
    l_pos_supplier_uda             pos_supplier_uda_bo;
    l_party_id                     NUMBER := 0;

  BEGIN
    IF p_party_id IS NULL THEN
      l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                         p_orig_system_reference);
      --l_party_id:=p_party_id;
    ELSE

      l_party_id := p_party_id;
    END IF;
    SELECT pos_supplier_sites_all_bo(aps.vendor_site_id,
                                     aps.last_update_date,
                                     aps.last_updated_by,
                                     aps.vendor_id,
                                     aps.vendor_site_code,
                                     aps.vendor_site_code_alt,
                                     aps.last_update_login,
                                     aps.creation_date,
                                     aps.created_by,
                                     aps.purchasing_site_flag,
                                     aps.rfq_only_site_flag,
                                     aps.pay_site_flag,
                                     aps.attention_ar_flag,
                                     aps.address_line1,
                                     aps.address_lines_alt,
                                     aps.address_line2,
                                     aps.address_line3,
                                     aps.city,
                                     aps.state,
                                     aps.zip,
                                     aps.province,
                                     aps.country,
                                     aps.area_code,
                                     aps.phone,
                                     aps.customer_num,
                                     aps.ship_to_location_id,
                                     aps.bill_to_location_id,
                                     aps.ship_via_lookup_code,
                                     aps.freight_terms_lookup_code,
                                     aps.fob_lookup_code,
                                     aps.inactive_date,
                                     aps.fax,
                                     aps.fax_area_code,
                                     aps.telex,
                                     aps.payment_method_lookup_code,
                                     aps.bank_account_name,
                                     aps.bank_account_num,
                                     aps.bank_num,
                                     aps.bank_account_type,
                                     aps.terms_date_basis,
                                     aps.current_catalog_num,
                                     aps.vat_code,
                                     aps.distribution_set_id,
                                     aps.accts_pay_code_combination_id,
                                     aps.prepay_code_combination_id,
                                     aps.pay_group_lookup_code,
                                     aps.payment_priority,
                                     aps.terms_id,
                                     aps.invoice_amount_limit,
                                     aps.pay_date_basis_lookup_code,
                                     aps.always_take_disc_flag,
                                     aps.invoice_currency_code,
                                     aps.payment_currency_code,
                                     aps.hold_all_payments_flag,
                                     aps.hold_future_payments_flag,
                                     aps.hold_reason,
                                     aps.hold_unmatched_invoices_flag,
                                     aps.ap_tax_rounding_rule,
                                     aps.auto_tax_calc_flag,
                                     aps.auto_tax_calc_override,
                                     aps.amount_includes_tax_flag,
                                     aps.exclusive_payment_flag,
                                     aps.tax_reporting_site_flag,
                                     aps.attribute_category,
                                     aps.attribute1,
                                     aps.attribute2,
                                     aps.attribute3,
                                     aps.attribute4,
                                     aps.attribute5,
                                     aps.attribute6,
                                     aps.attribute7,
                                     aps.attribute8,
                                     aps.attribute9,
                                     aps.attribute10,
                                     aps.attribute11,
                                     aps.attribute12,
                                     aps.attribute13,
                                     aps.attribute14,
                                     aps.attribute15,
                                     aps.request_id,
                                     aps.program_application_id,
                                     aps.program_id,
                                     aps.program_update_date,
                                     aps.validation_number,
                                     aps.exclude_freight_from_discount,
                                     aps.vat_registration_num,
                                     aps.offset_vat_code,
                                     aps.org_id,
                                     aps.check_digits,
                                     aps.bank_number,
                                     aps.address_line4,
                                     aps.county,
                                     aps.address_style,
                                     aps.language,
                                     aps.allow_awt_flag,
                                     aps.awt_group_id,
                                     aps.global_attribute1,
                                     aps.global_attribute2,
                                     aps.global_attribute3,
                                     aps.global_attribute4,
                                     aps.global_attribute5,
                                     aps.global_attribute6,
                                     aps.global_attribute7,
                                     aps.global_attribute8,
                                     aps.global_attribute9,
                                     aps.global_attribute10,
                                     aps.global_attribute11,
                                     aps.global_attribute12,
                                     aps.global_attribute13,
                                     aps.global_attribute14,
                                     aps.global_attribute15,
                                     aps.global_attribute16,
                                     aps.global_attribute17,
                                     aps.global_attribute18,
                                     aps.global_attribute19,
                                     aps.global_attribute20,
                                     aps.global_attribute_category,
                                     aps.edi_transaction_handling,
                                     aps.edi_id_number,
                                     aps.edi_payment_method,
                                     aps.edi_payment_format,
                                     aps.edi_remittance_method,
                                     aps.bank_charge_bearer,
                                     aps.edi_remittance_instruction,
                                     aps.bank_branch_type,
                                     aps.pay_on_code,
                                     aps.default_pay_site_id,
                                     aps.pay_on_receipt_summary_code,
                                     aps.tp_header_id,
                                     aps.ece_tp_location_code,
                                     aps.pcard_site_flag,
                                     aps.match_option,
                                     aps.country_of_origin_code,
                                     aps.future_dated_payment_ccid,
                                     aps.create_debit_memo_flag,
                                     aps.offset_tax_flag,
                                     aps.supplier_notif_method,
                                     aps.email_address,
                                     aps.remittance_email,
                                     aps.primary_pay_site_flag,
                                     aps.shipping_control,
                                     aps.selling_company_identifier,
                                     aps.gapless_inv_num_flag,
                                     decode(aps.duns_number, chr(0), NULL, aps.duns_number), -- Bug 18548652: to avoid XML parsing error
                                     aps.tolerance_id,
                                     aps.location_id,
                                     aps.party_site_id,
                                     NULL,
                                     NULL,
                                     aps.services_tolerance_id,
                                     aps.retainage_rate,
                                     aps.tca_sync_state,
                                     aps.tca_sync_province,
                                     aps.tca_sync_county,
                                     aps.tca_sync_city,
                                     aps.tca_sync_zip,
                                     aps.tca_sync_country,
                                     aps.pay_awt_group_id,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     sloc.location_code,  -- Bug 16444377: Add 4 fields
                                     bloc.location_code,
                                     apds.distribution_set_name,
                                     op.name,
                                     NULL,
                                     NULL,
                                     terms.name,  -- Bug 12979867: Add term's name
                                     NULL,
                                     NULL,
                                     /* NULL,*/
                                     pos_supplier_uda_bo_pkg.get_uda_for_supplier_site(l_party_id,
                                                                                      --Bug 15992883: change the positions of the following two arguments
                                                                                       aps.party_site_id,
                                                                                       aps.vendor_site_id,
                                                                                      --end of Bug 15992883
                                                                                       'SUPP_ADDR_SITE_LEVEL')) BULK COLLECT
    INTO   x_ap_supplier_sites_bo
    FROM   ap_supplier_sites_all aps,
           ap_suppliers          ap,
           ap_terms              terms,
           hr_locations_all      sloc,
           hr_locations_all      bloc,
           hr_operating_units    op,
           ap_distribution_sets_all  apds
    WHERE  ap.party_id = l_party_id
    AND    aps.vendor_id = ap.vendor_id
    AND    aps.terms_id = terms.term_id(+)  -- Bug 12979867/16067074: OUTER Join ap_terms to get term's name
    AND    aps.ship_to_location_id = sloc.location_id(+)
    AND    aps.bill_to_location_id = bloc.location_id(+)
    AND    aps.org_id = op.organization_id(+)
    AND    aps.distribution_set_id = apds.distribution_set_id(+);

 --Commented by BVAMSI on 07/Oct/2010 as it is already handled in the above Select query
  /*
    FOR i IN x_ap_supplier_sites_bo.first .. x_ap_supplier_sites_bo.last LOOP

      x_ap_supplier_sites_bo(i).p_pos_supp_uda_obj_tbl := pos_supplier_uda_bo_pkg.get_uda_for_supplier_site(l_party_id,
                                                                                                            x_ap_supplier_sites_bo(i)
                                                                                                            .vendor_site_id,
                                                                                                            x_ap_supplier_sites_bo(i)
                                                                                                            .party_site_id,
                                                                                                            'SUPP_ADDR_SITE_LEVEL');

    END LOOP;
    */
  -- Comment by BVAMSI Ends here

    /*pos_supplier_uda_bo_pkg.get_uda_data(p_api_version,
                                             p_init_msg_list,
                                             NULL,
                                             NULL,
                                             p_party_id,
                                             'SUPP_ADDR_SITE_LEVEL',
                                             l_pos_supplier_uda,
                                             x_return_status,
                                             x_msg_count,
                                             x_msg_data);
    */
    --    x_ap_supplier_sites_bo := l_pos_ap_supplier_sites_bo_tbl; /* pos_supplier_sites_all_bo(l_pos_ap_supplier_sites_bo_tbl,
    --                                                                      l_pos_supplier_uda);*/
    /* x_ap_supplier_sites_bo.p_pos_supplier_sites_obj := pos_supplier_sites_all_bo_tbl();
    x_ap_supplier_sites_bo.p_pos_supplier_sites_obj  := l_pos_ap_supplier_sites_bo_tbl;*/

    -- SELECT pos_supplier_sites_all_object(l_pos_ap_supplier_sites_bo_tbl) INTO x_ap_supplier_sites_bo FROM dual;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

  END get_pos_supplier_sites_bo_tbl;
  /*#
  * Use this routine to create supplier contact
  * @param p_api_version The version of API
  * @param p_init_msg_list The Initialization message list
  * @param p_vendor_contact_rec The supplier contact record
  * @param x_vendor_contact_id The Vendor Contact Id
  * @param x_per_party_id  The Person Party ID
  * @param x_rel_party_id  The Rel Party Id
  * @param x_org_contact_id  The Organization contact id
  * @param x_party_site_id The Party Site Id
  * @param x_return_status The return status
  * @param x_msg_count The message count
  * @param x_msg_data The message data
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Create Supplier Site
  * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
  */
  PROCEDURE create_pos_supplier_site_bo
  (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 := fnd_api.g_false,
    p_pos_supp_sites_all_bo_tbl IN pos_supplier_sites_all_bo_tbl,
    p_party_id                  IN NUMBER,
    p_orig_system               IN VARCHAR2,
    p_orig_system_reference     IN VARCHAR2,
    p_create_update_flag        IN VARCHAR2,
    x_vendor_site_id            OUT NOCOPY NUMBER,
    x_party_site_id             OUT NOCOPY NUMBER,
    x_location_id               OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
  ) IS
    v_row_exists    NUMBER := 0;
    l_party_id      NUMBER;
    vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
  BEGIN
    v_row_exists := 0;
    IF p_party_id IS NULL THEN
      l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                         p_orig_system_reference);
    ELSE
      l_party_id := p_party_id;
    END IF;

    FOR i IN p_pos_supp_sites_all_bo_tbl.first .. p_pos_supp_sites_all_bo_tbl.last LOOP
      /* FOR i IN p_vendor_site_rec.first..p_vendor_site_rec.last LOOP*/
      /*  BEGIN

          SELECT 1
          INTO   v_row_exists
          FROM   ap_supplier_sites_all
          WHERE  vendor_id = p_vendor_site_rec.vendor_id
          AND    rownum < 2;
      EXCEPTION
          WHEN OTHERS THEN
              v_row_exists := 0;
      END;*/

      vendor_site_rec.area_code                     := p_pos_supp_sites_all_bo_tbl(i)
                                                       .area_code;
      vendor_site_rec.phone                         := p_pos_supp_sites_all_bo_tbl(i)
                                                       .phone;
      vendor_site_rec.customer_num                  := p_pos_supp_sites_all_bo_tbl(i)
                                                       .customer_num;
      vendor_site_rec.ship_to_location_id           := p_pos_supp_sites_all_bo_tbl(i)
                                                       .ship_to_location_id;
      vendor_site_rec.bill_to_location_id           := p_pos_supp_sites_all_bo_tbl(i)
                                                       .bill_to_location_id;
      vendor_site_rec.ship_via_lookup_code          := p_pos_supp_sites_all_bo_tbl(i)
                                                       .ship_via_lookup_code;
      vendor_site_rec.freight_terms_lookup_code     := p_pos_supp_sites_all_bo_tbl(i)
                                                       .freight_terms_lookup_code;
      vendor_site_rec.fob_lookup_code               := p_pos_supp_sites_all_bo_tbl(i)
                                                       .fob_lookup_code;
      vendor_site_rec.inactive_date                 := p_pos_supp_sites_all_bo_tbl(i)
                                                       .inactive_date;
      vendor_site_rec.fax                           := p_pos_supp_sites_all_bo_tbl(i).fax;
      vendor_site_rec.fax_area_code                 := p_pos_supp_sites_all_bo_tbl(i)
                                                       .fax_area_code;
      vendor_site_rec.telex                         := p_pos_supp_sites_all_bo_tbl(i)
                                                       .telex;
      vendor_site_rec.terms_date_basis              := p_pos_supp_sites_all_bo_tbl(i)
                                                       .terms_date_basis;
      vendor_site_rec.distribution_set_id           := p_pos_supp_sites_all_bo_tbl(i)
                                                       .distribution_set_id;
      vendor_site_rec.accts_pay_code_combination_id := p_pos_supp_sites_all_bo_tbl(i)
                                                       .accts_pay_code_combination_id;
      vendor_site_rec.prepay_code_combination_id    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .prepay_code_combination_id;
      vendor_site_rec.pay_group_lookup_code         := p_pos_supp_sites_all_bo_tbl(i)
                                                       .pay_group_lookup_code;
      vendor_site_rec.payment_priority              := p_pos_supp_sites_all_bo_tbl(i)
                                                       .payment_priority;
      vendor_site_rec.terms_id                      := p_pos_supp_sites_all_bo_tbl(i)
                                                       .terms_id;
      vendor_site_rec.invoice_amount_limit          := p_pos_supp_sites_all_bo_tbl(i)
                                                       .invoice_amount_limit;
      vendor_site_rec.pay_date_basis_lookup_code    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .pay_date_basis_lookup_code;
      vendor_site_rec.always_take_disc_flag         := p_pos_supp_sites_all_bo_tbl(i)
                                                       .always_take_disc_flag;
      vendor_site_rec.invoice_currency_code         := p_pos_supp_sites_all_bo_tbl(i)
                                                       .invoice_currency_code;
      vendor_site_rec.payment_currency_code         := p_pos_supp_sites_all_bo_tbl(i)
                                                       .payment_currency_code;
      vendor_site_rec.vendor_site_id                := p_pos_supp_sites_all_bo_tbl(i)
                                                       .vendor_site_id;
      vendor_site_rec.last_update_date              := p_pos_supp_sites_all_bo_tbl(i)
                                                       .last_update_date;
      vendor_site_rec.last_updated_by               := p_pos_supp_sites_all_bo_tbl(i)
                                                       .last_updated_by;
      vendor_site_rec.vendor_id                     := p_pos_supp_sites_all_bo_tbl(i)
                                                       .vendor_id;
      IF (vendor_site_rec.vendor_id IS NULL) THEN
        BEGIN
          SELECT vendor_id
          INTO   vendor_site_rec.vendor_id
          FROM   ap_suppliers supp
          WHERE  supp.party_id = l_party_id;

        EXCEPTION
          WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
            RETURN;
        END;
      END IF;

      vendor_site_rec.vendor_site_code              := p_pos_supp_sites_all_bo_tbl(i)
                                                       .vendor_site_code;
      vendor_site_rec.vendor_site_code_alt          := p_pos_supp_sites_all_bo_tbl(i)
                                                       .vendor_site_code_alt;
      vendor_site_rec.purchasing_site_flag          := p_pos_supp_sites_all_bo_tbl(i)
                                                       .purchasing_site_flag;
      vendor_site_rec.rfq_only_site_flag            := p_pos_supp_sites_all_bo_tbl(i)
                                                       .rfq_only_site_flag;
      vendor_site_rec.pay_site_flag                 := p_pos_supp_sites_all_bo_tbl(i)
                                                       .pay_site_flag;
      vendor_site_rec.attention_ar_flag             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attention_ar_flag;
      vendor_site_rec.hold_all_payments_flag        := p_pos_supp_sites_all_bo_tbl(i)
                                                       .hold_all_payments_flag;
      vendor_site_rec.hold_future_payments_flag     := p_pos_supp_sites_all_bo_tbl(i)
                                                       .hold_future_payments_flag;
      vendor_site_rec.hold_reason                   := p_pos_supp_sites_all_bo_tbl(i)
                                                       .hold_reason;
      vendor_site_rec.hold_unmatched_invoices_flag  := p_pos_supp_sites_all_bo_tbl(i)
                                                       .hold_unmatched_invoices_flag;
      vendor_site_rec.tax_reporting_site_flag       := p_pos_supp_sites_all_bo_tbl(i)
                                                       .tax_reporting_site_flag;
      vendor_site_rec.attribute_category            := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute_category;
      vendor_site_rec.attribute1                    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute1;
      vendor_site_rec.attribute2                    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute2;
      vendor_site_rec.attribute3                    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute3;
      vendor_site_rec.attribute4                    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute4;
      vendor_site_rec.attribute5                    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute5;
      vendor_site_rec.attribute6                    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute6;
      vendor_site_rec.attribute7                    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute7;
      vendor_site_rec.attribute8                    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute8;
      vendor_site_rec.attribute9                    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute9;
      vendor_site_rec.attribute10                   := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute10;
      vendor_site_rec.attribute11                   := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute11;
      vendor_site_rec.attribute12                   := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute12;
      vendor_site_rec.attribute13                   := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute13;
      vendor_site_rec.attribute14                   := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute14;
      vendor_site_rec.attribute15                   := p_pos_supp_sites_all_bo_tbl(i)
                                                       .attribute15;
      vendor_site_rec.validation_number             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .validation_number;
      vendor_site_rec.exclude_freight_from_discount := p_pos_supp_sites_all_bo_tbl(i)
                                                       .exclude_freight_from_discount;
      vendor_site_rec.bank_charge_bearer            := p_pos_supp_sites_all_bo_tbl(i)
                                                       .bank_charge_bearer;
      vendor_site_rec.org_id                        := p_pos_supp_sites_all_bo_tbl(i)
                                                       .org_id;
      vendor_site_rec.check_digits                  := p_pos_supp_sites_all_bo_tbl(i)
                                                       .check_digits;
      vendor_site_rec.allow_awt_flag                := p_pos_supp_sites_all_bo_tbl(i)
                                                       .allow_awt_flag;
      vendor_site_rec.awt_group_id                  := p_pos_supp_sites_all_bo_tbl(i)
                                                       .awt_group_id;
      vendor_site_rec.pay_awt_group_id              := p_pos_supp_sites_all_bo_tbl(i)
                                                       .pay_awt_group_id;
      vendor_site_rec.default_pay_site_id           := p_pos_supp_sites_all_bo_tbl(i)
                                                       .default_pay_site_id;
      vendor_site_rec.pay_on_code                   := p_pos_supp_sites_all_bo_tbl(i)
                                                       .pay_on_code;
      vendor_site_rec.pay_on_receipt_summary_code   := p_pos_supp_sites_all_bo_tbl(i)
                                                       .pay_on_receipt_summary_code;
      vendor_site_rec.global_attribute_category     := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute_category;
      vendor_site_rec.global_attribute1             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute1;
      vendor_site_rec.global_attribute2             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute2;
      vendor_site_rec.global_attribute3             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute3;
      vendor_site_rec.global_attribute4             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute4;
      vendor_site_rec.global_attribute5             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute5;
      vendor_site_rec.global_attribute6             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute6;
      vendor_site_rec.global_attribute7             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute7;
      vendor_site_rec.global_attribute8             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute8;
      vendor_site_rec.global_attribute9             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute9;
      vendor_site_rec.global_attribute1             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute1;
      vendor_site_rec.global_attribute1             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute1;
      vendor_site_rec.global_attribute1             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute1;
      vendor_site_rec.global_attribute1             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute1;
      vendor_site_rec.global_attribute1             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute1;
      vendor_site_rec.global_attribute1             := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute1;
      vendor_site_rec.global_attribute16            := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute16;
      vendor_site_rec.global_attribute17            := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute17;
      vendor_site_rec.global_attribute18            := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute18;
      vendor_site_rec.global_attribute19            := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute19;
      vendor_site_rec.global_attribute20            := p_pos_supp_sites_all_bo_tbl(i)
                                                       .global_attribute20;
      vendor_site_rec.tp_header_id                  := p_pos_supp_sites_all_bo_tbl(i)
                                                       .tp_header_id;
      vendor_site_rec.ece_tp_location_code          := p_pos_supp_sites_all_bo_tbl(i)
                                                       .ece_tp_location_code;
      vendor_site_rec.pcard_site_flag               := p_pos_supp_sites_all_bo_tbl(i)
                                                       .pcard_site_flag;
      vendor_site_rec.match_option                  := p_pos_supp_sites_all_bo_tbl(i)
                                                       .match_option;
      vendor_site_rec.country_of_origin_code        := p_pos_supp_sites_all_bo_tbl(i)
                                                       .country_of_origin_code;
      vendor_site_rec.future_dated_payment_ccid     := p_pos_supp_sites_all_bo_tbl(i)
                                                       .future_dated_payment_ccid;
      vendor_site_rec.create_debit_memo_flag        := p_pos_supp_sites_all_bo_tbl(i)
                                                       .create_debit_memo_flag;
      vendor_site_rec.supplier_notif_method         := p_pos_supp_sites_all_bo_tbl(i)
                                                       .supplier_notif_method;
      vendor_site_rec.email_address                 := p_pos_supp_sites_all_bo_tbl(i)
                                                       .email_address;
      vendor_site_rec.primary_pay_site_flag         := p_pos_supp_sites_all_bo_tbl(i)
                                                       .primary_pay_site_flag;
      vendor_site_rec.shipping_control              := p_pos_supp_sites_all_bo_tbl(i)
                                                       .shipping_control;
      vendor_site_rec.selling_company_identifier    := p_pos_supp_sites_all_bo_tbl(i)
                                                       .selling_company_identifier;
      vendor_site_rec.gapless_inv_num_flag          := p_pos_supp_sites_all_bo_tbl(i)
                                                       .gapless_inv_num_flag;
      vendor_site_rec.location_id                   := p_pos_supp_sites_all_bo_tbl(i)
                                                       .location_id;
      vendor_site_rec.party_site_id                 := p_pos_supp_sites_all_bo_tbl(i)
                                                       .party_site_id;
      /* Suchita Change */
      IF (vendor_site_rec.party_site_id IS NULL) THEN
        BEGIN
          SELECT owner_table_id
          INTO   vendor_site_rec.party_site_id
          FROM   hz_orig_sys_references hr
          WHERE  hr.owner_table_name = 'HZ_PARTY_SITES'
          AND    hr.orig_system = p_pos_supp_sites_all_bo_tbl(i)
                .party_site_orig_system
          AND    hr.orig_system_reference = p_pos_supp_sites_all_bo_tbl(i)
                .party_site_orig_sys_ref
          AND    hr.status = 'A'
          AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE;

        EXCEPTION
          WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := 'Party Site ID Invalid';
            RETURN;
        END;
      END IF;

      vendor_site_rec.org_name                                   := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .org_name;
      vendor_site_rec.duns_number                                := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .duns_number;
      vendor_site_rec.address_style                              := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .address_style;
      vendor_site_rec.language                                   := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .language;
      vendor_site_rec.province                                   := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .province;
      vendor_site_rec.country                                    := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .country;
      vendor_site_rec.address_line1                              := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .address_line1;
      vendor_site_rec.address_line2                              := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .address_line2;
      vendor_site_rec.address_line3                              := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .address_line3;
      vendor_site_rec.address_line4                              := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .address_line4;
      vendor_site_rec.address_lines_alt                          := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .address_lines_alt;
      vendor_site_rec.county                                     := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .county;
      vendor_site_rec.city                                       := p_pos_supp_sites_all_bo_tbl(i).city;
      vendor_site_rec.state                                      := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .state;
      vendor_site_rec.zip                                        := p_pos_supp_sites_all_bo_tbl(i).zip;
      vendor_site_rec.terms_name                                 := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .terms_name;
      vendor_site_rec.default_terms_id                           := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .default_terms_id;
      vendor_site_rec.awt_group_name                             := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .awt_group_name;
      vendor_site_rec.pay_awt_group_name                         := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .pay_awt_group_name;
      vendor_site_rec.distribution_set_name                      := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .distribution_set_name;
      vendor_site_rec.ship_to_location_code                      := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .ship_to_location_code;
      vendor_site_rec.bill_to_location_code                      := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .bill_to_location_code;
      vendor_site_rec.default_dist_set_id                        := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .default_dist_set_id;
      vendor_site_rec.default_ship_to_loc_id                     := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .default_ship_to_loc_id;
      vendor_site_rec.default_bill_to_loc_id                     := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .default_bill_to_loc_id;
      vendor_site_rec.tolerance_id                               := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .tolerance_id;
      vendor_site_rec.tolerance_name                             := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .tolerance_name;
      vendor_site_rec.vendor_interface_id                        := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .vendor_interface_id;
      vendor_site_rec.vendor_site_interface_id                   := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .vendor_site_interface_id;
      vendor_site_rec.ext_payee_rec.payee_party_id               := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.payee_party_id;
      vendor_site_rec.ext_payee_rec.payment_function             := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.payment_function;
      vendor_site_rec.ext_payee_rec.exclusive_pay_flag           := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.exclusive_pay_flag;
      vendor_site_rec.ext_payee_rec.payee_party_site_id          := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.payee_party_site_id;
      vendor_site_rec.ext_payee_rec.supplier_site_id             := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.supplier_site_id;
      vendor_site_rec.ext_payee_rec.payer_org_id                 := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.payer_org_id;
      vendor_site_rec.ext_payee_rec.payer_org_type               := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.payer_org_type;
      vendor_site_rec.ext_payee_rec.default_pmt_method           := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.default_pmt_method;
      vendor_site_rec.ext_payee_rec.ece_tp_loc_code              := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.ece_tp_loc_code;
      vendor_site_rec.ext_payee_rec.bank_charge_bearer           := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.bank_charge_bearer;
      vendor_site_rec.ext_payee_rec.bank_instr1_code             := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.bank_instr1_code;
      vendor_site_rec.ext_payee_rec.bank_instr2_code             := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.bank_instr2_code;
      vendor_site_rec.ext_payee_rec.bank_instr_detail            := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.bank_instr_detail;
      vendor_site_rec.ext_payee_rec.pay_reason_code              := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.pay_reason_code;
      vendor_site_rec.ext_payee_rec.pay_reason_com               := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.pay_reason_com;
      vendor_site_rec.ext_payee_rec.inactive_date                := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.inactive_date;
      vendor_site_rec.ext_payee_rec.pay_message1                 := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.pay_message1;
      vendor_site_rec.ext_payee_rec.pay_message2                 := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.pay_message2;
      vendor_site_rec.ext_payee_rec.pay_message3                 := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.pay_message3;
      vendor_site_rec.ext_payee_rec.delivery_channel             := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.delivery_channel;
      vendor_site_rec.ext_payee_rec.pmt_format                   := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.pmt_format;
      vendor_site_rec.ext_payee_rec.settlement_priority          := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.settlement_priority;
      vendor_site_rec.ext_payee_rec.remit_advice_delivery_method := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.remit_advice_delivery_method;
      vendor_site_rec.ext_payee_rec.remit_advice_email           := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.remit_advice_email;
      vendor_site_rec.ext_payee_rec.edi_payment_format           := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.edi_payment_format;
      vendor_site_rec.ext_payee_rec.edi_transaction_handling     := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.edi_transaction_handling;
      vendor_site_rec.ext_payee_rec.edi_payment_method           := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.edi_payment_method;
      vendor_site_rec.ext_payee_rec.edi_remittance_method        := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.edi_remittance_method;
      vendor_site_rec.ext_payee_rec.edi_remittance_instruction   := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .p_pos_external_payee_bo.edi_remittance_instruction;
      vendor_site_rec.retainage_rate                             := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .retainage_rate;
      vendor_site_rec.services_tolerance_id                      := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .services_tolerance_id;
      vendor_site_rec.services_tolerance_name                    := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .services_tolerance_name;
      vendor_site_rec.shipping_location_id                       := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .shipping_location_id;
      vendor_site_rec.vat_code                                   := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .vat_code;
      vendor_site_rec.vat_registration_num                       := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .vat_registration_num;
      vendor_site_rec.edi_id_number                              := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .edi_id_number;
      vendor_site_rec.edi_payment_format                         := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .edi_payment_format;
      vendor_site_rec.edi_transaction_handling                   := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .edi_transaction_handling;
      vendor_site_rec.edi_payment_method                         := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .edi_payment_method;
      vendor_site_rec.edi_remittance_method                      := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .edi_remittance_method;
      vendor_site_rec.edi_remittance_instruction                 := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .edi_remittance_instruction;
      vendor_site_rec.party_site_name                            := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .party_site_name;
      vendor_site_rec.offset_tax_flag                            := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .offset_tax_flag;
      vendor_site_rec.auto_tax_calc_flag                         := p_pos_supp_sites_all_bo_tbl(i)
                                                                    .auto_tax_calc_flag;
      --vendor_site_rec

      IF p_create_update_flag = 'C' THEN

        create_vendor_site(vendor_site_rec,
                           vendor_site_rec.ext_payee_rec,
                           x_return_status,
                           x_msg_count,
                           x_msg_data);

      ELSIF p_create_update_flag = 'U' THEN
        ap_vendor_pub_pkg.update_vendor_site(p_api_version,
                                             p_init_msg_list,
                                             fnd_api.g_false,
                                             fnd_api.g_valid_level_full,
                                             x_return_status,
                                             x_msg_count,
                                             x_msg_data,
                                             vendor_site_rec,
                                             vendor_site_rec.vendor_site_id,
                                             'NOT ISETUP');
      ELSE
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        x_msg_data      := 'Create update flag is neither C nor U, exiting';
        RETURN;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
  END create_pos_supplier_site_bo;

END pos_ap_supplier_site_bo_pkg;

/
