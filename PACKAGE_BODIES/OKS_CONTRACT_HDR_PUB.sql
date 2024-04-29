--------------------------------------------------------
--  DDL for Package Body OKS_CONTRACT_HDR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CONTRACT_HDR_PUB" AS
/* $Header: OKSPKHRB.pls 120.4.12010000.2 2008/11/07 09:51:22 serukull ship $ */
    PROCEDURE create_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_rec IN khrv_rec_type,
                            x_khrv_rec OUT NOCOPY khrv_rec_type,
                            p_validate_yn IN VARCHAR2) IS

    l_init_msg_list VARCHAR2(10);
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
        IF p_validate_yn = 'Y' THEN
            validate_header
            (
             p_api_version => p_api_version,
             p_init_msg_list => l_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_rec => p_khrv_rec
             );
        END IF;
        IF x_return_status = G_RET_STS_SUCCESS THEN
            oks_khr_pvt.insert_row
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_rec => p_khrv_rec,
             x_khrv_rec => x_khrv_rec
             );
        END IF;
    END create_header;

    PROCEDURE create_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type,
                            x_khrv_tbl OUT NOCOPY khrv_tbl_type,
                            px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
                            p_validate_yn IN VARCHAR2) IS
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
        IF p_validate_yn = 'Y' THEN
            validate_header
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_tbl => p_khrv_tbl,
             px_error_tbl => px_error_tbl
             );
        END IF;
        IF x_return_status = G_RET_STS_SUCCESS THEN
            oks_khr_pvt.insert_row
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_tbl => p_khrv_tbl,
             x_khrv_tbl => x_khrv_tbl,
             px_error_tbl => px_error_tbl
             );
        END IF;
    END create_header;

    PROCEDURE create_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type,
                            x_khrv_tbl OUT NOCOPY khrv_tbl_type,
                            p_validate_yn IN VARCHAR2) IS
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
        IF p_validate_yn = 'Y' THEN
            validate_header
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_tbl => p_khrv_tbl
             );
        END IF;
        IF x_return_status = G_RET_STS_SUCCESS THEN
            oks_khr_pvt.insert_row
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_tbl => p_khrv_tbl,
             x_khrv_tbl => x_khrv_tbl
             );
        END IF;
    END create_header;

    PROCEDURE update_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_rec IN khrv_rec_type,
                            x_khrv_rec OUT NOCOPY khrv_rec_type,
                            p_validate_yn IN VARCHAR2) IS
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
        IF p_validate_yn = 'Y' THEN
            validate_header
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_rec => p_khrv_rec
             );
        END IF;
        IF x_return_status = G_RET_STS_SUCCESS THEN
            oks_khr_pvt.update_row
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_rec => p_khrv_rec,
             x_khrv_rec => x_khrv_rec
             );
        END IF;
    END update_header;

    PROCEDURE update_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type,
                            x_khrv_tbl OUT NOCOPY khrv_tbl_type,
                            px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
                            p_validate_yn IN VARCHAR2) IS
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
        IF p_validate_yn = 'Y' THEN
            validate_header
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_tbl => p_khrv_tbl,
             px_error_tbl => px_error_tbl
             );
        END IF;
        IF x_return_status = G_RET_STS_SUCCESS THEN
            oks_khr_pvt.update_row
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_tbl => p_khrv_tbl,
             x_khrv_tbl => x_khrv_tbl,
             px_error_tbl => px_error_tbl
             );
        END IF;
    END update_header;

    PROCEDURE update_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type,
                            x_khrv_tbl OUT NOCOPY khrv_tbl_type,
                            p_validate_yn IN VARCHAR2) IS
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
        IF p_validate_yn = 'Y' THEN
            validate_header
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_tbl => p_khrv_tbl
             );
        END IF;
        IF x_return_status = G_RET_STS_SUCCESS THEN
            oks_khr_pvt.update_row
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_khrv_tbl => p_khrv_tbl,
             x_khrv_tbl => x_khrv_tbl
             );
        END IF;
    END update_header;

    PROCEDURE lock_header(
                          p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          p_khrv_rec IN khrv_rec_type) IS
    BEGIN
        oks_khr_pvt.lock_row
        (
         p_api_version => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_khrv_rec => p_khrv_rec
         );
    END lock_header;

    PROCEDURE lock_header(
                          p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          p_khrv_tbl IN khrv_tbl_type,
                          px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS
    BEGIN
        oks_khr_pvt.lock_row
        (
         p_api_version => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_khrv_tbl => p_khrv_tbl,
         px_error_tbl => px_error_tbl
         );
    END lock_header;

    PROCEDURE lock_header(
                          p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          p_khrv_tbl IN khrv_tbl_type) IS
    BEGIN
        oks_khr_pvt.lock_row
        (
         p_api_version => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_khrv_tbl => p_khrv_tbl
         );
    END lock_header;

    PROCEDURE delete_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_rec IN khrv_rec_type) IS
    BEGIN
        oks_khr_pvt.delete_row
        (
         p_api_version => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_khrv_rec => p_khrv_rec
         );
    END delete_header;

    PROCEDURE delete_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type,
                            px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS
    BEGIN
        oks_khr_pvt.delete_row
        (
         p_api_version => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_khrv_tbl => p_khrv_tbl,
         px_error_tbl => px_error_tbl
         );
    END delete_header;

    PROCEDURE delete_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type) IS
    BEGIN
        oks_khr_pvt.delete_row
        (
         p_api_version => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_khrv_tbl => p_khrv_tbl
         );
    END delete_header;

    PROCEDURE validate_header(
                              p_api_version IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_khrv_rec IN khrv_rec_type) IS
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
    END validate_header;

    PROCEDURE validate_header(
                              p_api_version IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_khrv_tbl IN khrv_tbl_type,
                              px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
    END validate_header;

    PROCEDURE validate_header(
                              p_api_version IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_khrv_tbl IN khrv_tbl_type) IS
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
    END validate_header;

    PROCEDURE version_contract(
                               p_api_version IN NUMBER,
                               p_init_msg_list IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2,
                               p_chr_id IN NUMBER,
                               p_major_version IN NUMBER) IS
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        x_return_status := G_RET_STS_SUCCESS;

    -- Versioning OKS_K_HEADERS_B
    -- Inserting single record
        INSERT INTO oks_k_headers_bh
          (major_version,
           id,
           chr_id,
           acct_rule_id,
           payment_type,
           cc_no,
           cc_expiry_date,
           cc_bank_acct_id,
           cc_auth_code,
           commitment_id,
           grace_duration,
           grace_period,
           est_rev_percent,
           est_rev_date,
           tax_amount,
           tax_status,
           tax_code,
           tax_exemption_id,
           billing_profile_id,
           renewal_status,
           electronic_renewal_flag,
           quote_to_contact_id,
           quote_to_site_id,
           quote_to_email_id,
           quote_to_phone_id,
           quote_to_fax_id,
           renewal_po_required,
           renewal_po_number,
           renewal_price_list,
           renewal_pricing_type,
           renewal_markup_percent,
           renewal_grace_duration,
           renewal_grace_period,
           renewal_est_rev_percent,
           renewal_est_rev_duration,
           renewal_est_rev_period,
           renewal_price_list_used,
           renewal_type_used,
           renewal_notification_to,
           renewal_po_used,
           renewal_pricing_type_used,
           renewal_markup_percent_used,
           rev_est_percent_used,
           rev_est_duration_used,
           rev_est_period_used,
           billing_profile_used,
           ern_flag_used_yn,
           evn_threshold_amt,
           evn_threshold_cur,
           ern_threshold_amt,
           ern_threshold_cur,
           renewal_grace_duration_used,
           renewal_grace_period_used,
           inv_trx_type,
           inv_print_profile,
           ar_interface_yn,
           hold_billing,
           summary_trx_yn,
           service_po_number,
           service_po_required,
           billing_schedule_type,
           object_version_number,
           security_group_id,
           request_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           PERIOD_TYPE,
           PERIOD_START,
           PRICE_UOM,
           FOLLOW_UP_ACTION,
           FOLLOW_UP_DATE,
           TRXN_EXTENSION_ID,
           DATE_ACCEPTED,
           ACCEPTED_BY,
           RMNDR_SUPPRESS_FLAG,
           RMNDR_SENT_FLAG,
           QUOTE_SENT_FLAG,
           PROCESS_REQUEST_ID,
           WF_ITEM_KEY,
           PERSON_PARTY_ID,
           TAX_CLASSIFICATION_CODE,
           EXEMPT_CERTIFICATE_NUMBER,
           EXEMPT_REASON_CODE,
           APPROVAL_TYPE_USED,
           renewal_comment
           )
          SELECT
            p_major_version,
            id,
            chr_id,
            acct_rule_id,
            payment_type,
            cc_no,
            cc_expiry_date,
            cc_bank_acct_id,
            cc_auth_code,
            commitment_id,
            grace_duration,
            grace_period,
            est_rev_percent,
            est_rev_date,
            tax_amount,
            tax_status,
            tax_code,
            tax_exemption_id,
            billing_profile_id,
            renewal_status,
            electronic_renewal_flag,
            quote_to_contact_id,
            quote_to_site_id,
            quote_to_email_id,
            quote_to_phone_id,
            quote_to_fax_id,
            renewal_po_required,
            renewal_po_number,
            renewal_price_list,
            renewal_pricing_type,
            renewal_markup_percent,
            renewal_grace_duration,
            renewal_grace_period,
            renewal_est_rev_percent,
            renewal_est_rev_duration,
            renewal_est_rev_period,
            renewal_price_list_used,
            renewal_type_used,
            renewal_notification_to,
            renewal_po_used,
            renewal_pricing_type_used,
            renewal_markup_percent_used,
            rev_est_percent_used,
            rev_est_duration_used,
            rev_est_period_used,
            billing_profile_used,
            ern_flag_used_yn,
            evn_threshold_amt,
            evn_threshold_cur,
            ern_threshold_amt,
            ern_threshold_cur,
            renewal_grace_duration_used,
            renewal_grace_period_used,
            inv_trx_type,
            inv_print_profile,
            ar_interface_yn,
            hold_billing,
            summary_trx_yn,
            service_po_number,
            service_po_required,
            billing_schedule_type,
            object_version_number,
            security_group_id,
            request_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            PERIOD_TYPE,
            PERIOD_START,
            PRICE_UOM,
            FOLLOW_UP_ACTION,
            FOLLOW_UP_DATE,
            TRXN_EXTENSION_ID,
            DATE_ACCEPTED,
            ACCEPTED_BY,
            RMNDR_SUPPRESS_FLAG,
            RMNDR_SENT_FLAG,
            QUOTE_SENT_FLAG,
            PROCESS_REQUEST_ID,
            WF_ITEM_KEY,
            PERSON_PARTY_ID,
            TAX_CLASSIFICATION_CODE,
            EXEMPT_CERTIFICATE_NUMBER,
            EXEMPT_REASON_CODE,
            APPROVAL_TYPE_USED,
            renewal_comment
          FROM oks_k_headers_b
          WHERE chr_id = p_chr_id;

    -- Versioning OKS_K_LINES_B
    -- Inserting multiple records
        INSERT INTO oks_k_lines_bh
          (major_version,
           id,
           cle_id,
           dnz_chr_id,
           discount_list,
           acct_rule_id,
           payment_type,
           cc_no,
           cc_expiry_date,
           cc_bank_acct_id,
           cc_auth_code,
           commitment_id,
           locked_price_list_id,
           usage_est_yn,
           usage_est_method,
           usage_est_start_date,
           termn_method,
           ubt_amount,
           credit_amount,
           suppressed_credit,
           override_amount,
           cust_po_number_req_yn,
           cust_po_number,
           grace_duration,
           grace_period,
           inv_print_flag,
           -- price_uom ,
           tax_amount,
           tax_inclusive_yn,
           tax_status,
           tax_code,
           tax_exemption_id,
           ib_trans_type,
           ib_trans_date,
           prod_price,
           service_price,
           clvl_list_price,
           clvl_quantity,
           clvl_extended_amt,
           clvl_uom_code,
           toplvl_operand_code,
           toplvl_operand_val,
           toplvl_quantity,
           toplvl_uom_code,
           toplvl_adj_price,
           toplvl_price_qty,
           averaging_interval,
           settlement_interval,
           minimum_quantity,
           default_quantity,
           amcv_flag,
           fixed_quantity,
           usage_duration,
           usage_period,
           level_yn,
           usage_type,
           uom_quantified,
           base_reading,
           billing_schedule_type,
           full_credit,
           locked_price_list_line_id,
           break_uom,
           prorate,
           coverage_type,
           exception_cov_id,
           limit_uom_quantified,
           discount_amount,
           discount_percent,
           offset_duration,
           offset_period,
           incident_severity_id,
           pdf_id,
           work_thru_yn,
           react_active_yn,
           transfer_option,
           prod_upgrade_yn,
           inheritance_type,
           pm_program_id,
           pm_conf_req_yn,
           pm_sch_exists_yn,
           allow_bt_discount,
           apply_default_timezone,
           sync_date_install,
           object_version_number,
           security_group_id,
           request_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           /*** R12 Data Model Changes 27072005 Start ***/
           TRXN_EXTENSION_ID,
           TAX_CLASSIFICATION_CODE,
           EXEMPT_CERTIFICATE_NUMBER,
           EXEMPT_REASON_CODE,
           COVERAGE_ID,
           STANDARD_COV_YN
           /*** R12 Data Model Changes 27072005 End ***/
           )
          SELECT
            p_major_version,
            id,
            cle_id,
            dnz_chr_id,
            discount_list,
            acct_rule_id,
            payment_type,
            cc_no,
            cc_expiry_date,
            cc_bank_acct_id,
            cc_auth_code,
            commitment_id,
            locked_price_list_id,
            usage_est_yn,
            usage_est_method,
            usage_est_start_date,
            termn_method,
            ubt_amount,
            credit_amount,
            suppressed_credit,
            override_amount,
            cust_po_number_req_yn,
            cust_po_number,
            grace_duration,
            grace_period,
            inv_print_flag,
     --   price_uom ,
            tax_amount,
            tax_inclusive_yn,
            tax_status,
            tax_code,
            tax_exemption_id,
            ib_trans_type,
            ib_trans_date,
            prod_price,
            service_price,
            clvl_list_price,
            clvl_quantity,
            clvl_extended_amt,
            clvl_uom_code,
            toplvl_operand_code,
            toplvl_operand_val,
            toplvl_quantity,
            toplvl_uom_code,
            toplvl_adj_price,
            toplvl_price_qty,
            averaging_interval,
            settlement_interval,
            minimum_quantity,
            default_quantity,
            amcv_flag,
            fixed_quantity,
            usage_duration,
            usage_period,
            level_yn,
            usage_type,
            uom_quantified,
            base_reading,
            billing_schedule_type,
            full_credit,
            locked_price_list_line_id,
            break_uom,
            prorate,
            coverage_type,
            exception_cov_id,
            limit_uom_quantified,
            discount_amount,
            discount_percent,
            offset_duration,
            offset_period,
            incident_severity_id,
            pdf_id,
            work_thru_yn,
            react_active_yn,
            transfer_option,
            prod_upgrade_yn,
            inheritance_type,
            pm_program_id,
            pm_conf_req_yn,
            pm_sch_exists_yn,
            allow_bt_discount,
            apply_default_timezone,
            sync_date_install,
            object_version_number,
            security_group_id,
            request_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
/*** R12 Data Model Changes 27072005 Start ***/
            TRXN_EXTENSION_ID,
            TAX_CLASSIFICATION_CODE,
            EXEMPT_CERTIFICATE_NUMBER,
            EXEMPT_REASON_CODE,
            COVERAGE_ID,
            STANDARD_COV_YN
/*** R12 Data Model Changes 27072005 End ***/
          FROM oks_k_lines_b
          WHERE dnz_chr_id = p_chr_id;

    -- Versioning OKS_K_LINES_TL
    -- Inserting multiple records
        INSERT INTO oks_k_lines_tlh
          (major_version,
           id,
           language,
           source_lang,
           sfwt_flag,
           invoice_text,
           ib_trx_details,
           status_text,
           react_time_name,
           security_group_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
           )
          SELECT
            p_major_version,
            a.id,
            a.language,
            a.source_lang,
            a.sfwt_flag,
            a.invoice_text,
            a.ib_trx_details,
            a.status_text,
            a.react_time_name,
            a.security_group_id,
            a.created_by,
            a.creation_date,
            a.last_updated_by,
            a.last_update_date,
            a.last_update_login
          FROM oks_k_lines_tl a,
               oks_k_lines_b b
          WHERE a.id = b.id
            AND b.dnz_chr_id = p_chr_id;

    -- Versioning Coverage Related Tables
        oks_coverages_pub.version_coverage
        (
         p_api_version => p_api_version,
         p_init_msg_list => 'F',
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_chr_id => p_chr_id,
         p_major_version => p_major_version
         );

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM
                                );
    END version_contract;

    PROCEDURE create_version(
                             p_api_version IN NUMBER,
                             p_init_msg_list IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2,
                             p_chr_id IN NUMBER) IS

    CURSOR vers_cur IS
        SELECT major_version
        FROM okc_k_vers_numbers
        WHERE chr_id = p_chr_id;
    l_major_version NUMBER;
    invalid_version EXCEPTION;
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
        OPEN vers_cur;
        FETCH vers_cur INTO l_major_version;
        IF vers_cur%NOTFOUND THEN
            CLOSE vers_cur;
            RAISE invalid_version;
        END IF;
        CLOSE vers_cur;
        version_contract
        (p_api_version => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_chr_id => p_chr_id,
         p_major_version => l_major_version
         );
    EXCEPTION
        WHEN invalid_version THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM
                                );
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM
                                );
    END create_version;

    PROCEDURE create_version(
                             p_chr_id IN NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_version NUMBER := 1.0;
    l_init_msg_list VARCHAR2(3) := 'F';
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    BEGIN
        create_version
        (p_api_version => l_api_version,
         p_init_msg_list => l_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         p_chr_id => p_chr_id
         );
    END create_version;

    PROCEDURE save_version(
                           p_api_version IN NUMBER,
                           p_init_msg_list IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2,
                           p_chr_id IN NUMBER) IS
    BEGIN
        x_return_status := G_RET_STS_SUCCESS;
        version_contract
        (p_api_version => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_chr_id => p_chr_id,
         p_major_version =>  - 1
         );
    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM
                                );
    END save_version;

    PROCEDURE delete_saved_version(
                                   p_api_version IN NUMBER,
                                   p_init_msg_list IN VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER,
                                   x_msg_data OUT NOCOPY VARCHAR2,
                                   p_chr_id IN NUMBER) IS
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        x_return_status := G_RET_STS_SUCCESS;
        DELETE oks_k_lines_tlh
          WHERE id IN
               (SELECT id FROM oks_k_lines_bh
                WHERE dnz_chr_id = p_chr_id )
            AND major_version =  - 1;

        DELETE oks_k_lines_bh
        WHERE dnz_chr_id = p_chr_id
            AND major_version =  - 1;

        DELETE oks_k_headers_bh
        WHERE chr_id = p_chr_id
            AND major_version =  - 1;

        oks_coverages_pub.delete_saved_version
        (
         p_api_version => p_api_version,
         p_init_msg_list => 'F',
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_chr_id => p_chr_id
         );

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM
                                );
    END delete_saved_version;

    PROCEDURE delete_saved_version(
                                   p_chr_id IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_version NUMBER := 1.0;
    l_init_msg_list VARCHAR2(3) := 'F';
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    BEGIN
        delete_saved_version
        (p_api_version => l_api_version,
         p_init_msg_list => l_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         p_chr_id => p_chr_id
         );
    END delete_saved_version;

    PROCEDURE restore_version(
                              p_api_version IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_chr_id IN NUMBER) IS
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        x_return_status := G_RET_STS_SUCCESS;

        DELETE oks_k_lines_tl
          WHERE id IN
               (SELECT id FROM oks_k_lines_b
                WHERE dnz_chr_id = p_chr_id );
        DELETE oks_k_lines_b
        WHERE dnz_chr_id = p_chr_id;
        DELETE oks_k_headers_b
        WHERE chr_id = p_chr_id;

    -- Restoring OKS_K_HEADERS_B
    -- Inserting single record
        INSERT INTO oks_k_headers_b
          (id,
           chr_id,
           acct_rule_id,
           payment_type,
           cc_no,
           cc_expiry_date,
           cc_bank_acct_id,
           cc_auth_code,
           commitment_id,
           grace_duration,
           grace_period,
           est_rev_percent,
           est_rev_date,
           tax_amount,
           tax_status,
           tax_code,
           tax_exemption_id,
           billing_profile_id,
           renewal_status,
           electronic_renewal_flag,
           quote_to_contact_id,
           quote_to_site_id,
           quote_to_email_id,
           quote_to_phone_id,
           quote_to_fax_id,
           renewal_po_required,
           renewal_po_number,
           renewal_price_list,
           renewal_pricing_type,
           renewal_markup_percent,
           renewal_grace_duration,
           renewal_grace_period,
           renewal_est_rev_percent,
           renewal_est_rev_duration,
           renewal_est_rev_period,
           renewal_price_list_used,
           renewal_type_used,
           renewal_notification_to,
           renewal_po_used,
           renewal_pricing_type_used,
           renewal_markup_percent_used,
           rev_est_percent_used,
           rev_est_duration_used,
           rev_est_period_used,
           billing_profile_used,
           ern_flag_used_yn,
           evn_threshold_amt,
           evn_threshold_cur,
           ern_threshold_amt,
           ern_threshold_cur,
           renewal_grace_duration_used,
           renewal_grace_period_used,
           inv_trx_type,
           inv_print_profile,
           ar_interface_yn,
           hold_billing,
           summary_trx_yn,
           service_po_number,
           service_po_required,
           billing_schedule_type,
           object_version_number,
           security_group_id,
           request_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           PERIOD_TYPE,
           PERIOD_START,
           PRICE_UOM,
           FOLLOW_UP_ACTION,
           FOLLOW_UP_DATE,
           TRXN_EXTENSION_ID,
           DATE_ACCEPTED,
           ACCEPTED_BY,
           RMNDR_SUPPRESS_FLAG,
           RMNDR_SENT_FLAG,
           QUOTE_SENT_FLAG,
           PROCESS_REQUEST_ID,
           WF_ITEM_KEY,
           PERSON_PARTY_ID,
           TAX_CLASSIFICATION_CODE,
           EXEMPT_CERTIFICATE_NUMBER,
           EXEMPT_REASON_CODE,
           APPROVAL_TYPE_USED,
	   renewal_comment
           )
          SELECT
            id,
            chr_id,
            acct_rule_id,
            payment_type,
            cc_no,
            cc_expiry_date,
            cc_bank_acct_id,
            cc_auth_code,
            commitment_id,
            grace_duration,
            grace_period,
            est_rev_percent,
            est_rev_date,
            tax_amount,
            tax_status,
            tax_code,
            tax_exemption_id,
            billing_profile_id,
            renewal_status,
            electronic_renewal_flag,
            quote_to_contact_id,
            quote_to_site_id,
            quote_to_email_id,
            quote_to_phone_id,
            quote_to_fax_id,
            renewal_po_required,
            renewal_po_number,
            renewal_price_list,
            renewal_pricing_type,
            renewal_markup_percent,
            renewal_grace_duration,
            renewal_grace_period,
            renewal_est_rev_percent,
            renewal_est_rev_duration,
            renewal_est_rev_period,
            renewal_price_list_used,
            renewal_type_used,
            renewal_notification_to,
            renewal_po_used,
            renewal_pricing_type_used,
            renewal_markup_percent_used,
            rev_est_percent_used,
            rev_est_duration_used,
            rev_est_period_used,
            billing_profile_used,
            ern_flag_used_yn,
            evn_threshold_amt,
            evn_threshold_cur,
            ern_threshold_amt,
            ern_threshold_cur,
            renewal_grace_duration_used,
            renewal_grace_period_used,
            inv_trx_type,
            inv_print_profile,
            ar_interface_yn,
            hold_billing,
            summary_trx_yn,
            service_po_number,
            service_po_required,
            billing_schedule_type,
            object_version_number,
            security_group_id,
            request_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            PERIOD_TYPE,
            PERIOD_START,
            PRICE_UOM,
            FOLLOW_UP_ACTION,
            FOLLOW_UP_DATE,
            TRXN_EXTENSION_ID,
            DATE_ACCEPTED,
            ACCEPTED_BY,
            RMNDR_SUPPRESS_FLAG,
            RMNDR_SENT_FLAG,
            QUOTE_SENT_FLAG,
            PROCESS_REQUEST_ID,
            WF_ITEM_KEY,
            PERSON_PARTY_ID,
            TAX_CLASSIFICATION_CODE,
            EXEMPT_CERTIFICATE_NUMBER,
            EXEMPT_REASON_CODE,
            APPROVAL_TYPE_USED,
            renewal_comment
          FROM oks_k_headers_bh
          WHERE chr_id = p_chr_id
            AND major_version =  - 1;

    -- Restoring OKS_K_LINES_B
    -- Inserting multiple records
        INSERT INTO oks_k_lines_b
          (id,
           cle_id,
           dnz_chr_id,
           discount_list,
           acct_rule_id,
           payment_type,
           cc_no,
           cc_expiry_date,
           cc_bank_acct_id,
           cc_auth_code,
           commitment_id,
           locked_price_list_id,
           usage_est_yn,
           usage_est_method,
           usage_est_start_date,
           termn_method,
           ubt_amount,
           credit_amount,
           suppressed_credit,
           override_amount,
           cust_po_number_req_yn,
           cust_po_number,
           grace_duration,
           grace_period,
           inv_print_flag,
           --  price_uom ,
           tax_amount,
           tax_inclusive_yn,
           tax_status,
           tax_code,
           tax_exemption_id,
           ib_trans_type,
           ib_trans_date,
           prod_price,
           service_price,
           clvl_list_price,
           clvl_quantity,
           clvl_extended_amt,
           clvl_uom_code,
           toplvl_operand_code,
           toplvl_operand_val,
           toplvl_quantity,
           toplvl_uom_code,
           toplvl_adj_price,
           toplvl_price_qty,
           averaging_interval,
           settlement_interval,
           minimum_quantity,
           default_quantity,
           amcv_flag,
           fixed_quantity,
           usage_duration,
           usage_period,
           level_yn,
           usage_type,
           uom_quantified,
           base_reading,
           billing_schedule_type,
           full_credit,
           locked_price_list_line_id,
           break_uom,
           prorate,
           coverage_type,
           exception_cov_id,
           limit_uom_quantified,
           discount_amount,
           discount_percent,
           offset_duration,
           offset_period,
           incident_severity_id,
           pdf_id,
           work_thru_yn,
           react_active_yn,
           transfer_option,
           prod_upgrade_yn,
           inheritance_type,
           pm_program_id,
           pm_conf_req_yn,
           pm_sch_exists_yn,
           allow_bt_discount,
           apply_default_timezone,
           sync_date_install,
           object_version_number,
           security_group_id,
           request_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           /*** R12 Data Model Changes 27072005 Start ***/
           TRXN_EXTENSION_ID,
           TAX_CLASSIFICATION_CODE,
           EXEMPT_CERTIFICATE_NUMBER,
           EXEMPT_REASON_CODE,
           COVERAGE_ID,
           STANDARD_COV_YN
           /*** R12 Data Model Changes 27072005 End ***/
           )
          SELECT
            id,
            cle_id,
            dnz_chr_id,
            discount_list,
            acct_rule_id,
            payment_type,
            cc_no,
            cc_expiry_date,
            cc_bank_acct_id,
            cc_auth_code,
            commitment_id,
            locked_price_list_id,
            usage_est_yn,
            usage_est_method,
            usage_est_start_date,
            termn_method,
            ubt_amount,
            credit_amount,
            suppressed_credit,
            override_amount,
            cust_po_number_req_yn,
            cust_po_number,
            grace_duration,
            grace_period,
            inv_print_flag,
   --     price_uom ,
            tax_amount,
            tax_inclusive_yn,
            tax_status,
            tax_code,
            tax_exemption_id,
            ib_trans_type,
            ib_trans_date,
            prod_price,
            service_price,
            clvl_list_price,
            clvl_quantity,
            clvl_extended_amt,
            clvl_uom_code,
            toplvl_operand_code,
            toplvl_operand_val,
            toplvl_quantity,
            toplvl_uom_code,
            toplvl_adj_price,
            toplvl_price_qty,
            averaging_interval,
            settlement_interval,
            minimum_quantity,
            default_quantity,
            amcv_flag,
            fixed_quantity,
            usage_duration,
            usage_period,
            level_yn,
            usage_type,
            uom_quantified,
            base_reading,
            billing_schedule_type,
            full_credit,
            locked_price_list_line_id,
            break_uom,
            prorate,
            coverage_type,
            exception_cov_id,
            limit_uom_quantified,
            discount_amount,
            discount_percent,
            offset_duration,
            offset_period,
            incident_severity_id,
            pdf_id,
            work_thru_yn,
            react_active_yn,
            transfer_option,
            prod_upgrade_yn,
            inheritance_type,
            pm_program_id,
            pm_conf_req_yn,
            pm_sch_exists_yn,
            allow_bt_discount,
            apply_default_timezone,
            sync_date_install,
            object_version_number,
            security_group_id,
            request_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
/*** R12 Data Model Changes 27072005 Start ***/
            TRXN_EXTENSION_ID,
            TAX_CLASSIFICATION_CODE,
            EXEMPT_CERTIFICATE_NUMBER,
            EXEMPT_REASON_CODE,
            COVERAGE_ID,
            STANDARD_COV_YN
/*** R12 Data Model Changes 27072005 End ***/
          FROM oks_k_lines_bh
          WHERE dnz_chr_id = p_chr_id
            AND major_version =  - 1;

    -- Restoring OKS_K_LINES_TL
    -- Inserting multiple records
        INSERT INTO oks_k_lines_tl
          (id,
           language,
           source_lang,
           sfwt_flag,
           invoice_text,
           ib_trx_details,
           status_text,
           react_time_name,
           security_group_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
           )
          SELECT
            a.id,
            a.language,
            a.source_lang,
            a.sfwt_flag,
            a.invoice_text,
            a.ib_trx_details,
            a.status_text,
            a.react_time_name,
            a.security_group_id,
            a.created_by,
            a.creation_date,
            a.last_updated_by,
            a.last_update_date,
            a.last_update_login
          FROM oks_k_lines_tlh a,
               oks_k_lines_b b
          WHERE a.id = b.id
            AND b.dnz_chr_id = p_chr_id
            AND a.major_version =  - 1;

    -- Restoring Coverage Related Tables
        oks_coverages_pub.restore_coverage
        (
         p_api_version => p_api_version,
         p_init_msg_list => 'F',
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_chr_id => p_chr_id
         );

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM
                                );
    END restore_version;

    PROCEDURE delete_history(
                             p_api_version IN NUMBER,
                             p_init_msg_list IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2,
                             p_chr_id IN NUMBER) IS
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        x_return_status := G_RET_STS_SUCCESS;
        DELETE oks_k_lines_tlh
          WHERE id IN
               (SELECT id FROM oks_k_lines_bh
                WHERE dnz_chr_id = p_chr_id );

        DELETE oks_k_lines_bh
        WHERE dnz_chr_id = p_chr_id;

        DELETE oks_k_headers_bh
        WHERE chr_id = p_chr_id;
    -- Purging Coverage Related Tables
        oks_coverages_pub.delete_history
        (
         p_api_version => p_api_version,
         p_init_msg_list => 'F',
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_chr_id => p_chr_id
         );

    EXCEPTION
        WHEN OTHERS THEN
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM
                                );
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END delete_history;

---------------------------------------------------------------
-- Procedure for mass insert in OKS_K_HEADERS_B table
---------------------------------------------------------------
    PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,
                             p_khrv_tbl IN khrv_tbl_type) IS

    l_tabsize NUMBER := p_khrv_tbl.COUNT;
    l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
    in_id OKC_DATATYPES.NumberTabTyp;
    in_chr_id OKC_DATATYPES.NumberTabTyp;
    in_acct_rule_id OKC_DATATYPES.NumberTabTyp;
    in_payment_type OKC_DATATYPES.Var30TabTyp;
    in_cc_no OKC_DATATYPES.Var90TabTyp;
    in_cc_expiry_date OKC_DATATYPES.DateTabTyp;
    in_cc_bank_acct_id OKC_DATATYPES.NumberTabTyp;
    in_cc_auth_code OKC_DATATYPES.Var150TabTyp;
    in_commitment_id OKC_DATATYPES.NumberTabTyp;
    in_grace_duration OKC_DATATYPES.NumberTabTyp;
    in_grace_period OKC_DATATYPES.Var30TabTyp;
    in_est_rev_percent OKC_DATATYPES.NumberTabTyp;
    in_est_rev_date OKC_DATATYPES.DateTabTyp;
    in_tax_amount OKC_DATATYPES.NumberTabTyp;
    in_tax_status OKC_DATATYPES.Var30TabTyp;
    in_tax_code OKC_DATATYPES.NumberTabTyp;
    in_tax_exemption_id OKC_DATATYPES.NumberTabTyp;
    in_billing_profile_id OKC_DATATYPES.NumberTabTyp;
    in_renewal_status OKC_DATATYPES.Var30TabTyp;
    in_electronic_renewal_flag OKC_DATATYPES.Var30TabTyp;
    in_quote_to_contact_id OKC_DATATYPES.NumberTabTyp;
    in_quote_to_site_id OKC_DATATYPES.NumberTabTyp;
    in_quote_to_email_id OKC_DATATYPES.NumberTabTyp;
    in_quote_to_phone_id OKC_DATATYPES.NumberTabTyp;
    in_quote_to_fax_id OKC_DATATYPES.NumberTabTyp;
    in_renewal_po_required OKC_DATATYPES.Var3TabTyp;
    in_renewal_po_number OKC_DATATYPES.Var240TabTyp;
    in_renewal_price_list OKC_DATATYPES.NumberTabTyp;
    in_renewal_pricing_type OKC_DATATYPES.Var30TabTyp;
    in_renewal_markup_percent OKC_DATATYPES.NumberTabTyp;
    in_renewal_grace_duration OKC_DATATYPES.NumberTabTyp;
    in_renewal_grace_period OKC_DATATYPES.Var30TabTyp;
    in_renewal_est_rev_percent OKC_DATATYPES.NumberTabTyp;
    in_renewal_est_rev_duration OKC_DATATYPES.NumberTabTyp;
    in_renewal_est_rev_period OKC_DATATYPES.Var30TabTyp;
    in_renewal_price_list_used OKC_DATATYPES.NumberTabTyp;
    in_renewal_type_used OKC_DATATYPES.Var30TabTyp;
    in_renewal_notification_to OKC_DATATYPES.NumberTabTyp;
    in_renewal_po_used OKC_DATATYPES.Var3TabTyp;
    in_renewal_pricing_type_used OKC_DATATYPES.Var30TabTyp;
    in_renewal_markup_percent_used OKC_DATATYPES.NumberTabTyp;
    in_rev_est_percent_used OKC_DATATYPES.NumberTabTyp;
    in_rev_est_duration_used OKC_DATATYPES.NumberTabTyp;
    in_rev_est_period_used OKC_DATATYPES.Var30TabTyp;
    in_billing_profile_used OKC_DATATYPES.NumberTabTyp;
    in_ern_flag_used_yn OKC_DATATYPES.Var3TabTyp;
    in_evn_threshold_amt OKC_DATATYPES.NumberTabTyp;
    in_evn_threshold_cur OKC_DATATYPES.Var30TabTyp;
    in_ern_threshold_amt OKC_DATATYPES.NumberTabTyp;
    in_ern_threshold_cur OKC_DATATYPES.Var30TabTyp;
    in_renewal_grace_duration_used OKC_DATATYPES.NumberTabTyp;
    in_renewal_grace_period_used OKC_DATATYPES.Var30TabTyp;
    in_inv_trx_type OKC_DATATYPES.Var30TabTyp;
    in_inv_print_profile OKC_DATATYPES.Var3TabTyp;
    in_ar_interface_yn OKC_DATATYPES.Var3TabTyp;
    in_hold_billing OKC_DATATYPES.Var3TabTyp;
    in_summary_trx_yn OKC_DATATYPES.Var3TabTyp;
    in_service_po_number OKC_DATATYPES.Var240TabTyp;
    in_service_po_required OKC_DATATYPES.Var3TabTyp;
    in_billing_schedule_type OKC_DATATYPES.Var10TabTyp;
    in_object_version_number OKC_DATATYPES.NumberTabTyp;
    in_security_group_id OKC_DATATYPES.NumberTabTyp;
    in_request_id OKC_DATATYPES.NumberTabTyp;
    in_created_by OKC_DATATYPES.NumberTabTyp;
    in_creation_date OKC_DATATYPES.DateTabTyp;
    in_last_updated_by OKC_DATATYPES.NumberTabTyp;
    in_last_update_date OKC_DATATYPES.DateTabTyp;
    in_last_update_login OKC_DATATYPES.NumberTabTyp;
    in_period_type OKC_DATATYPES.Var10TabTyp;
    in_period_start OKC_DATATYPES.Var30TabTyp;
    in_price_uom OKC_DATATYPES.Var10TabTyp;
    in_follow_up_action OKC_DATATYPES.Var30TabTyp;
    in_follow_up_date OKC_DATATYPES.DateTabTyp;
    in_trxn_extension_id OKC_DATATYPES.NumberTabTyp;
    in_date_accepted OKC_DATATYPES.DateTabTyp;
    in_accepted_by OKC_DATATYPES.NumberTabTyp;
    in_rmndr_suppress_flag OKC_DATATYPES.Var3TabTyp;
    in_rmndr_sent_flag OKC_DATATYPES.Var3TabTyp;
    in_quote_sent_flag OKC_DATATYPES.Var3TabTyp;
    in_process_request_id OKC_DATATYPES.NumberTabTyp;
    in_wf_item_key OKC_DATATYPES.Var240TabTyp;
    in_person_party_id OKC_DATATYPES.NumberTabTyp;
    in_tax_classification_code OKC_DATATYPES.Var30TabTyp;
    in_exempt_certificate_number OKC_DATATYPES.Var90TabTyp;
    in_exempt_reason_code OKC_DATATYPES.Var30TabTyp;
    in_approval_type_used OKC_DATATYPES.Var30TabTyp;

    i NUMBER;
    j NUMBER;

    BEGIN
  -- Initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        i := p_khrv_tbl.FIRST; j := 0;
        WHILE i IS NOT NULL
            LOOP
            j := j + 1;
            in_id(j) := p_khrv_tbl(i).id;
            in_chr_id(j) := p_khrv_tbl(i).chr_id;
            in_acct_rule_id(j) := p_khrv_tbl(i).acct_rule_id;
            in_payment_type(j) := p_khrv_tbl(i).payment_type;
            in_cc_no(j) := p_khrv_tbl(i).cc_no;
            in_cc_expiry_date(j) := p_khrv_tbl(i).cc_expiry_date;
            in_cc_bank_acct_id(j) := p_khrv_tbl(i).cc_bank_acct_id;
            in_cc_auth_code(j) := p_khrv_tbl(i).cc_auth_code;
            in_commitment_id(j) := p_khrv_tbl(i).commitment_id;
            in_grace_duration(j) := p_khrv_tbl(i).grace_duration;
            in_grace_period(j) := p_khrv_tbl(i).grace_period;
            in_est_rev_percent(j) := p_khrv_tbl(i).est_rev_percent;
            in_est_rev_date(j) := p_khrv_tbl(i).est_rev_date;
            in_tax_amount(j) := p_khrv_tbl(i).tax_amount;
            in_tax_status(j) := p_khrv_tbl(i).tax_status;
            in_tax_code(j) := p_khrv_tbl(i).tax_code;
            in_tax_exemption_id(j) := p_khrv_tbl(i).tax_exemption_id;
            in_billing_profile_id(j) := p_khrv_tbl(i).billing_profile_id;
            in_renewal_status(j) := p_khrv_tbl(i).renewal_status;
            in_electronic_renewal_flag(j) := p_khrv_tbl(i).electronic_renewal_flag;
            in_quote_to_contact_id(j) := p_khrv_tbl(i).quote_to_contact_id;
            in_quote_to_site_id(j) := p_khrv_tbl(i).quote_to_site_id;
            in_quote_to_email_id(j) := p_khrv_tbl(i).quote_to_email_id;
            in_quote_to_phone_id(j) := p_khrv_tbl(i).quote_to_phone_id;
            in_quote_to_fax_id(j) := p_khrv_tbl(i).quote_to_fax_id;
            in_renewal_po_required(j) := p_khrv_tbl(i).renewal_po_required;
            in_renewal_po_number(j) := p_khrv_tbl(i).renewal_po_number;
            in_renewal_price_list(j) := p_khrv_tbl(i).renewal_price_list;
            in_renewal_pricing_type(j) := p_khrv_tbl(i).renewal_pricing_type;
            in_renewal_markup_percent(j) := p_khrv_tbl(i).renewal_markup_percent;
            in_renewal_grace_duration(j) := p_khrv_tbl(i).renewal_grace_duration;
            in_renewal_grace_period(j) := p_khrv_tbl(i).renewal_grace_period;
            in_renewal_est_rev_percent(j) := p_khrv_tbl(i).renewal_est_rev_percent;
            in_renewal_est_rev_duration(j) := p_khrv_tbl(i).renewal_est_rev_duration;
            in_renewal_est_rev_period(j) := p_khrv_tbl(i).renewal_est_rev_period;
            in_renewal_price_list_used(j) := p_khrv_tbl(i).renewal_price_list_used;
            in_renewal_type_used(j) := p_khrv_tbl(i).renewal_type_used;
            in_renewal_notification_to(j) := p_khrv_tbl(i).renewal_notification_to;
            in_renewal_po_used(j) := p_khrv_tbl(i).renewal_po_used;
            in_renewal_pricing_type_used(j) := p_khrv_tbl(i).renewal_pricing_type_used;
            in_renewal_markup_percent_used(j) := p_khrv_tbl(i).renewal_markup_percent_used;
            in_rev_est_percent_used(j) := p_khrv_tbl(i).rev_est_percent_used;
            in_rev_est_duration_used(j) := p_khrv_tbl(i).rev_est_duration_used;
            in_rev_est_period_used(j) := p_khrv_tbl(i).rev_est_period_used;
            in_billing_profile_used(j) := p_khrv_tbl(i).billing_profile_used;
            in_ern_flag_used_yn(j) := p_khrv_tbl(i).ern_flag_used_yn;
            in_evn_threshold_amt(j) := p_khrv_tbl(i).evn_threshold_amt;
            in_evn_threshold_cur(j) := p_khrv_tbl(i).evn_threshold_cur;
            in_ern_threshold_amt(j) := p_khrv_tbl(i).ern_threshold_amt;
            in_ern_threshold_cur(j) := p_khrv_tbl(i).ern_threshold_cur;
            in_renewal_grace_duration_used(j) := p_khrv_tbl(i).renewal_grace_duration_used;
            in_renewal_grace_period_used(j) := p_khrv_tbl(i).renewal_grace_period_used;
            in_inv_trx_type(j) := p_khrv_tbl(i).inv_trx_type;
            in_inv_print_profile(j) := p_khrv_tbl(i).inv_print_profile;
            in_ar_interface_yn(j) := p_khrv_tbl(i).ar_interface_yn;
            in_hold_billing(j) := p_khrv_tbl(i).hold_billing;
            in_summary_trx_yn(j) := p_khrv_tbl(i).summary_trx_yn;
            in_service_po_number(j) := p_khrv_tbl(i).service_po_number;
            in_service_po_required(j) := p_khrv_tbl(i).service_po_required;
            in_billing_schedule_type(j) := p_khrv_tbl(i).billing_schedule_type;
            in_object_version_number(j) := p_khrv_tbl(i).object_version_number;
            in_request_id(j) := p_khrv_tbl(i).request_id;
            in_created_by(j) := p_khrv_tbl(i).created_by;
            in_creation_date(j) := p_khrv_tbl(i).creation_date;
            in_last_updated_by(j) := p_khrv_tbl(i).last_updated_by;
            in_last_update_date(j) := p_khrv_tbl(i).last_update_date;
            in_last_update_login(j) := p_khrv_tbl(i).last_update_login;
            in_period_type(j) := p_khrv_tbl(i).period_type;
            in_period_start(j) := p_khrv_tbl(i).period_start;
            in_price_uom(j) := p_khrv_tbl(i).price_uom;
            in_follow_up_action(j) := p_khrv_tbl(i).follow_up_action;
            in_follow_up_date(j) := p_khrv_tbl(i).follow_up_date;
            in_trxn_extension_id(j) := p_khrv_tbl(i).trxn_extension_id;
            in_date_accepted(j) := p_khrv_tbl(i).date_accepted;
            in_accepted_by(j) := p_khrv_tbl(i).accepted_by;
            in_rmndr_suppress_flag(j) := p_khrv_tbl(i).rmndr_suppress_flag;
            in_rmndr_sent_flag(j) := p_khrv_tbl(i).rmndr_sent_flag;
            in_quote_sent_flag(j) := p_khrv_tbl(i).quote_sent_flag;
            in_process_request_id(j) := p_khrv_tbl(i).process_request_id;
            in_wf_item_key(j) := p_khrv_tbl(i).wf_item_key;
            in_person_party_id(j) := p_khrv_tbl(i).person_party_id;
            in_tax_classification_code(j) := p_khrv_tbl(i).tax_classification_code;
            in_exempt_certificate_number(j) := p_khrv_tbl(i).exempt_certificate_number;
            in_exempt_reason_code(j) := p_khrv_tbl(i).exempt_reason_code;
            in_approval_type_used(j) := p_khrv_tbl(i).approval_type_used;
            i := p_khrv_tbl.NEXT(i);
        END LOOP;

        FORALL i IN 1..l_tabsize
        INSERT
          INTO OKS_K_HEADERS_B
          (
           id,
           chr_id,
           acct_rule_id,
           payment_type,
           cc_no,
           cc_expiry_date,
           cc_bank_acct_id,
           cc_auth_code,
           commitment_id,
           grace_duration,
           grace_period,
           est_rev_percent,
           est_rev_date,
           tax_amount,
           tax_status,
           tax_code,
           tax_exemption_id,
           billing_profile_id,
           renewal_status,
           electronic_renewal_flag,
           quote_to_contact_id,
           quote_to_site_id,
           quote_to_email_id,
           quote_to_phone_id,
           quote_to_fax_id,
           renewal_po_required,
           renewal_po_number,
           renewal_price_list,
           renewal_pricing_type,
           renewal_markup_percent,
           renewal_grace_duration,
           renewal_grace_period,
           renewal_est_rev_percent,
           renewal_est_rev_duration,
           renewal_est_rev_period,
           renewal_price_list_used,
           renewal_type_used,
           renewal_notification_to,
           renewal_po_used,
           renewal_pricing_type_used,
           renewal_markup_percent_used,
           rev_est_percent_used,
           rev_est_duration_used,
           rev_est_period_used,
           billing_profile_used,
           ern_flag_used_yn,
           evn_threshold_amt,
           evn_threshold_cur,
           ern_threshold_amt,
           ern_threshold_cur,
           renewal_grace_duration_used,
           renewal_grace_period_used,
           inv_trx_type,
           inv_print_profile,
           ar_interface_yn,
           hold_billing,
           summary_trx_yn,
           service_po_number,
           service_po_required,
           billing_schedule_type,
           object_version_number,
           request_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           PERIOD_TYPE,
           PERIOD_START,
           PRICE_UOM,
           FOLLOW_UP_ACTION,
           FOLLOW_UP_DATE,
           TRXN_EXTENSION_ID,
           DATE_ACCEPTED,
           ACCEPTED_BY,
           RMNDR_SUPPRESS_FLAG,
           RMNDR_SENT_FLAG,
           QUOTE_SENT_FLAG,
           PROCESS_REQUEST_ID,
           WF_ITEM_KEY,
           PERSON_PARTY_ID,
           TAX_CLASSIFICATION_CODE,
           EXEMPT_CERTIFICATE_NUMBER,
           EXEMPT_REASON_CODE,
           APPROVAL_TYPE_USED
           )
        VALUES (
                in_id(i),
                in_chr_id(i),
                in_acct_rule_id(i),
                in_payment_type(i),
                in_cc_no(i),
                in_cc_expiry_date(i),
                in_cc_bank_acct_id(i),
                in_cc_auth_code(i),
                in_commitment_id(i),
                in_grace_duration(i),
                in_grace_period(i),
                in_est_rev_percent(i),
                in_est_rev_date(i),
                in_tax_amount(i),
                in_tax_status(i),
                in_tax_code(i),
                in_tax_exemption_id(i),
                in_billing_profile_id(i),
                in_renewal_status(i),
                in_electronic_renewal_flag(i),
                in_quote_to_contact_id(i),
                in_quote_to_site_id(i),
                in_quote_to_email_id(i),
                in_quote_to_phone_id(i),
                in_quote_to_fax_id(i),
                in_renewal_po_required(i),
                in_renewal_po_number(i),
                in_renewal_price_list(i),
                in_renewal_pricing_type(i),
                in_renewal_markup_percent(i),
                in_renewal_grace_duration(i),
                in_renewal_grace_period(i),
                in_renewal_est_rev_percent(i),
                in_renewal_est_rev_duration(i),
                in_renewal_est_rev_period(i),
                in_renewal_price_list_used(i),
                in_renewal_type_used(i),
                in_renewal_notification_to(i),
                in_renewal_po_used(i),
                in_renewal_pricing_type_used(i),
                in_renewal_markup_percent_used(i),
                in_rev_est_percent_used(i),
                in_rev_est_duration_used(i),
                in_rev_est_period_used(i),
                in_billing_profile_used(i),
                in_ern_flag_used_yn(i),
                in_evn_threshold_amt(i),
                in_evn_threshold_cur(i),
                in_ern_threshold_amt(i),
                in_ern_threshold_cur(i),
                in_renewal_grace_duration_used(i),
                in_renewal_grace_period_used(i),
                in_inv_trx_type(i),
                in_inv_print_profile(i),
                in_ar_interface_yn(i),
                in_hold_billing(i),
                in_summary_trx_yn(i),
                in_service_po_number(i),
                in_service_po_required(i),
                in_billing_schedule_type(i),
                in_object_version_number(i),
                in_request_id(i),
                in_created_by(i),
                in_creation_date(i),
                in_last_updated_by(i),
                in_last_update_date(i),
                in_last_update_login(i),
                in_period_type(i),
                in_period_start(i),
                in_price_uom(i),
                in_follow_up_action(i),
                in_follow_up_date(i),
                in_trxn_extension_id(i),
                in_date_accepted(i),
                in_accepted_by(i),
                in_rmndr_suppress_flag(i),
                in_rmndr_sent_flag(i),
                in_quote_sent_flag(i),
                in_process_request_id(i),
                in_wf_item_key(i),
                in_person_party_id(i),
                in_tax_classification_code(i),
                in_exempt_certificate_number(i),
                in_exempt_reason_code(i),
                in_approval_type_used(i)
                );


    EXCEPTION
        WHEN OTHERS THEN

    -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
    END INSERT_ROW_UPG;

---------------------------------------------------------------
-- Procedure for mass insert in OKS_K_HEADERS_BH
---------------------------------------------------------------
    PROCEDURE CREATE_HDR_VERSION_UPG(x_return_status OUT NOCOPY VARCHAR2,
                                     p_khrhv_tbl IN khrhv_tbl_type) IS

    l_tabsize NUMBER := p_khrhv_tbl.COUNT;
    l_request_id NUMBER;
    in_id OKC_DATATYPES.NumberTabTyp;
    in_chr_id OKC_DATATYPES.NumberTabTyp;
    in_acct_rule_id OKC_DATATYPES.NumberTabTyp;
    in_payment_type OKC_DATATYPES.Var30TabTyp;
    in_cc_no OKC_DATATYPES.Var90TabTyp;
    in_cc_expiry_date OKC_DATATYPES.DateTabTyp;
    in_cc_bank_acct_id OKC_DATATYPES.NumberTabTyp;
    in_cc_auth_code OKC_DATATYPES.Var150TabTyp;
    in_commitment_id OKC_DATATYPES.NumberTabTyp;
    in_grace_duration OKC_DATATYPES.NumberTabTyp;
    in_grace_period OKC_DATATYPES.Var30TabTyp;
    in_est_rev_percent OKC_DATATYPES.NumberTabTyp;
    in_est_rev_date OKC_DATATYPES.DateTabTyp;
    in_tax_amount OKC_DATATYPES.NumberTabTyp;
    in_tax_status OKC_DATATYPES.Var30TabTyp;
    in_tax_code OKC_DATATYPES.NumberTabTyp;
    in_tax_exemption_id OKC_DATATYPES.NumberTabTyp;
    in_billing_profile_id OKC_DATATYPES.NumberTabTyp;
    in_renewal_status OKC_DATATYPES.Var30TabTyp;
    in_electronic_renewal_flag OKC_DATATYPES.Var3TabTyp;
    in_quote_to_contact_id OKC_DATATYPES.NumberTabTyp;
    in_quote_to_site_id OKC_DATATYPES.NumberTabTyp;
    in_quote_to_email_id OKC_DATATYPES.NumberTabTyp;
    in_quote_to_phone_id OKC_DATATYPES.NumberTabTyp;
    in_quote_to_fax_id OKC_DATATYPES.NumberTabTyp;
    in_renewal_po_required OKC_DATATYPES.Var3TabTyp;
    in_renewal_po_number OKC_DATATYPES.Var240TabTyp;
    in_renewal_price_list OKC_DATATYPES.NumberTabTyp;
    in_renewal_pricing_type OKC_DATATYPES.Var30TabTyp;
    in_renewal_markup_percent OKC_DATATYPES.NumberTabTyp;
    in_renewal_grace_duration OKC_DATATYPES.NumberTabTyp;
    in_renewal_grace_period OKC_DATATYPES.Var30TabTyp;
    in_renewal_est_rev_percent OKC_DATATYPES.NumberTabTyp;
    in_renewal_est_rev_duration OKC_DATATYPES.NumberTabTyp;
    in_renewal_est_rev_period OKC_DATATYPES.Var30TabTyp;
    in_renewal_price_list_used OKC_DATATYPES.NumberTabTyp;
    in_renewal_type_used OKC_DATATYPES.Var30TabTyp;
    in_renewal_notification_to OKC_DATATYPES.NumberTabTyp;
    in_renewal_po_used OKC_DATATYPES.Var3TabTyp;
    in_renewal_pricing_type_used OKC_DATATYPES.Var30TabTyp;
    in_renewal_markup_percent_used OKC_DATATYPES.NumberTabTyp;
    in_rev_est_percent_used OKC_DATATYPES.NumberTabTyp;
    in_rev_est_duration_used OKC_DATATYPES.NumberTabTyp;
    in_rev_est_period_used OKC_DATATYPES.Var30TabTyp;
    in_billing_profile_used OKC_DATATYPES.NumberTabTyp;
    in_ern_flag_used_yn OKC_DATATYPES.Var3TabTyp;
    in_evn_threshold_amt OKC_DATATYPES.NumberTabTyp;
    in_evn_threshold_cur OKC_DATATYPES.Var30TabTyp;
    in_ern_threshold_amt OKC_DATATYPES.NumberTabTyp;
    in_ern_threshold_cur OKC_DATATYPES.Var30TabTyp;
    in_renewal_grace_duration_used OKC_DATATYPES.NumberTabTyp;
    in_renewal_grace_period_used OKC_DATATYPES.Var30TabTyp;
    in_inv_trx_type OKC_DATATYPES.Var30TabTyp;
    in_inv_print_profile OKC_DATATYPES.Var3TabTyp;
    in_ar_interface_yn OKC_DATATYPES.Var3TabTyp;
    in_hold_billing OKC_DATATYPES.Var3TabTyp;
    in_summary_trx_yn OKC_DATATYPES.Var3TabTyp;
    in_service_po_number OKC_DATATYPES.Var240TabTyp;
    in_service_po_required OKC_DATATYPES.Var3TabTyp;
    in_billing_schedule_type OKC_DATATYPES.Var10TabTyp;
    in_object_version_number OKC_DATATYPES.NumberTabTyp;
    in_security_group_id OKC_DATATYPES.NumberTabTyp;
    in_request_id OKC_DATATYPES.NumberTabTyp;
    in_created_by OKC_DATATYPES.NumberTabTyp;
    in_creation_date OKC_DATATYPES.DateTabTyp;
    in_last_updated_by OKC_DATATYPES.NumberTabTyp;
    in_last_update_date OKC_DATATYPES.DateTabTyp;
    in_last_update_login OKC_DATATYPES.NumberTabTyp;
    in_major_version OKC_DATATYPES.NumberTabTyp;
    in_period_type OKC_DATATYPES.Var10TabTyp;
    in_period_start OKC_DATATYPES.Var30TabTyp;
    in_price_uom OKC_DATATYPES.Var10TabTyp;
    in_follow_up_action OKC_DATATYPES.Var30TabTyp;
    in_follow_up_date OKC_DATATYPES.DateTabTyp;
    in_trxn_extension_id OKC_DATATYPES.NumberTabTyp;
    in_date_accepted OKC_DATATYPES.DateTabTyp;
    in_accepted_by OKC_DATATYPES.NumberTabTyp;
    in_rmndr_suppress_flag OKC_DATATYPES.Var3TabTyp;
    in_rmndr_sent_flag OKC_DATATYPES.Var3TabTyp;
    in_quote_sent_flag OKC_DATATYPES.Var3TabTyp;
    in_process_request_id OKC_DATATYPES.NumberTabTyp;
    in_wf_item_key OKC_DATATYPES.Var240TabTyp;
    in_person_party_id OKC_DATATYPES.NumberTabTyp;
    in_tax_classification_code OKC_DATATYPES.Var30TabTyp;
    in_exempt_certificate_number OKC_DATATYPES.Var90TabTyp;
    in_exempt_reason_code OKC_DATATYPES.Var30TabTyp;
    in_approval_type_used OKC_DATATYPES.Var30TabTyp;
    i NUMBER;
    j NUMBER;



    BEGIN
  -- Initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        i := p_khrhv_tbl.FIRST;
        j := 0;

        WHILE i IS NOT NULL
            LOOP
            j := j + 1;
            in_id(j) := p_khrhv_tbl(i).id;
            in_major_version(j) := p_khrhv_tbl(i).major_version;
            in_chr_id(j) := p_khrhv_tbl(i).chr_id;
            in_acct_rule_id(j) := p_khrhv_tbl(i).acct_rule_id;
            in_payment_type(j) := p_khrhv_tbl(i).payment_type;
            in_cc_no(j) := p_khrhv_tbl(i).cc_no;
            in_cc_expiry_date(j) := p_khrhv_tbl(i).cc_expiry_date;
            in_cc_bank_acct_id(j) := p_khrhv_tbl(i).cc_bank_acct_id;
            in_cc_auth_code(j) := p_khrhv_tbl(i).cc_auth_code;
            in_commitment_id(j) := p_khrhv_tbl(i).commitment_id;
            in_grace_duration(j) := p_khrhv_tbl(i).grace_duration;
            in_grace_period(j) := p_khrhv_tbl(i).grace_period;
            in_est_rev_percent(j) := p_khrhv_tbl(i).est_rev_percent;
            in_est_rev_date(j) := p_khrhv_tbl(i).est_rev_date;
            in_tax_amount(j) := p_khrhv_tbl(i).tax_amount;
            in_tax_status(j) := p_khrhv_tbl(i).tax_status;
            in_tax_code(j) := p_khrhv_tbl(i).tax_code;
            in_tax_exemption_id(j) := p_khrhv_tbl(i).tax_exemption_id;
            in_billing_profile_id(j) := p_khrhv_tbl(i).billing_profile_id;
            in_renewal_status(j) := p_khrhv_tbl(i).renewal_status;
            in_electronic_renewal_flag(j) := p_khrhv_tbl(i).electronic_renewal_flag;
            in_quote_to_contact_id(j) := p_khrhv_tbl(i).quote_to_contact_id;
            in_quote_to_site_id(j) := p_khrhv_tbl(i).quote_to_site_id;
            in_quote_to_email_id(j) := p_khrhv_tbl(i).quote_to_email_id;
            in_quote_to_phone_id(j) := p_khrhv_tbl(i).quote_to_phone_id;
            in_quote_to_fax_id(j) := p_khrhv_tbl(i).quote_to_fax_id;
            in_renewal_po_required(j) := p_khrhv_tbl(i).renewal_po_required;
            in_renewal_po_number(j) := p_khrhv_tbl(i).renewal_po_number;
            in_renewal_price_list(j) := p_khrhv_tbl(i).renewal_price_list;
            in_renewal_pricing_type(j) := p_khrhv_tbl(i).renewal_pricing_type;
            in_renewal_markup_percent(j) := p_khrhv_tbl(i).renewal_markup_percent;
            in_renewal_grace_duration(j) := p_khrhv_tbl(i).renewal_grace_duration;
            in_renewal_grace_period(j) := p_khrhv_tbl(i).renewal_grace_period;
            in_renewal_est_rev_percent(j) := p_khrhv_tbl(i).renewal_est_rev_percent;
            in_renewal_est_rev_duration(j) := p_khrhv_tbl(i).renewal_est_rev_duration;
            in_renewal_est_rev_period(j) := p_khrhv_tbl(i).renewal_est_rev_period;
            in_renewal_price_list_used(j) := p_khrhv_tbl(i).renewal_price_list_used;
            in_renewal_type_used(j) := p_khrhv_tbl(i).renewal_type_used;
            in_renewal_notification_to(j) := p_khrhv_tbl(i).renewal_notification_to;
            in_renewal_po_used(j) := p_khrhv_tbl(i).renewal_po_used;
            in_renewal_pricing_type_used(j) := p_khrhv_tbl(i).renewal_pricing_type_used;
            in_renewal_markup_percent_used(j) := p_khrhv_tbl(i).renewal_markup_percent_used;
            in_rev_est_percent_used(j) := p_khrhv_tbl(i).rev_est_percent_used;
            in_rev_est_duration_used(j) := p_khrhv_tbl(i).rev_est_duration_used;
            in_rev_est_period_used(j) := p_khrhv_tbl(i).rev_est_period_used;
            in_billing_profile_used(j) := p_khrhv_tbl(i).billing_profile_used;
            in_ern_flag_used_yn(j) := p_khrhv_tbl(i).ern_flag_used_yn;
            in_evn_threshold_amt(j) := p_khrhv_tbl(i).evn_threshold_amt;
            in_evn_threshold_cur(j) := p_khrhv_tbl(i).evn_threshold_cur;
            in_ern_threshold_amt(j) := p_khrhv_tbl(i).ern_threshold_amt;
            in_ern_threshold_cur(j) := p_khrhv_tbl(i).ern_threshold_cur;
            in_renewal_grace_duration_used(j) := p_khrhv_tbl(i).renewal_grace_duration_used;
            in_renewal_grace_period_used(j) := p_khrhv_tbl(i).renewal_grace_period_used;
            in_inv_trx_type(j) := p_khrhv_tbl(i).inv_trx_type;
            in_inv_print_profile(j) := p_khrhv_tbl(i).inv_print_profile;
            in_ar_interface_yn(j) := p_khrhv_tbl(i).ar_interface_yn;
            in_hold_billing(j) := p_khrhv_tbl(i).hold_billing;
            in_summary_trx_yn(j) := p_khrhv_tbl(i).summary_trx_yn;
            in_service_po_number(j) := p_khrhv_tbl(i).service_po_number;
            in_service_po_required(j) := p_khrhv_tbl(i).service_po_required;
            in_billing_schedule_type(j) := p_khrhv_tbl(i).billing_schedule_type;
            in_object_version_number(j) := p_khrhv_tbl(i).object_version_number;
            in_request_id(j) := p_khrhv_tbl(i).request_id;
            in_created_by(j) := p_khrhv_tbl(i).created_by;
            in_creation_date(j) := p_khrhv_tbl(i).creation_date;
            in_last_updated_by(j) := p_khrhv_tbl(i).last_updated_by;
            in_last_update_date(j) := p_khrhv_tbl(i).last_update_date;
            in_last_update_login(j) := p_khrhv_tbl(i).last_update_login;
            in_period_type(j) := p_khrhv_tbl(i).period_type;
            in_period_start(j) := p_khrhv_tbl(i).period_start;
            in_price_uom(j) := p_khrhv_tbl(i).price_uom;
            in_follow_up_action(j) := p_khrhv_tbl(i).follow_up_action;
            in_follow_up_date(j) := p_khrhv_tbl(i).follow_up_date;
            in_trxn_extension_id(j) := p_khrhv_tbl(i).trxn_extension_id;
            in_date_accepted(j) := p_khrhv_tbl(i).date_accepted;
            in_accepted_by(j) := p_khrhv_tbl(i).accepted_by;
            in_rmndr_suppress_flag(j) := p_khrhv_tbl(i).rmndr_suppress_flag;
            in_rmndr_sent_flag(j) := p_khrhv_tbl(i).rmndr_sent_flag;
            in_quote_sent_flag(j) := p_khrhv_tbl(i).quote_sent_flag;
            in_process_request_id(j) := p_khrhv_tbl(i).process_request_id;
            in_wf_item_key(j) := p_khrhv_tbl(i).wf_item_key;
            in_person_party_id(j) := p_khrhv_tbl(i).person_party_id;
            in_tax_classification_code(j) := p_khrhv_tbl(i).tax_classification_code;
            in_exempt_certificate_number(j) := p_khrhv_tbl(i).exempt_certificate_number;
            in_exempt_reason_code(j) := p_khrhv_tbl(i).exempt_reason_code;
            in_approval_type_used(j) := p_khrhv_tbl(i).approval_type_used;
            i := p_khrhv_tbl.NEXT(i);
        END LOOP;

        FORALL i IN 1..l_tabsize
        INSERT INTO OKS_K_HEADERS_BH
          (
           id,
           major_version,
           chr_id,
           acct_rule_id,
           payment_type,
           cc_no,
           cc_expiry_date,
           cc_bank_acct_id,
           cc_auth_code,
           commitment_id,
           grace_duration,
           grace_period,
           est_rev_percent,
           est_rev_date,
           tax_amount,
           tax_status,
           tax_code,
           tax_exemption_id,
           billing_profile_id,
           renewal_status,
           electronic_renewal_flag,
           quote_to_contact_id,
           quote_to_site_id,
           quote_to_email_id,
           quote_to_phone_id,
           quote_to_fax_id,
           renewal_po_required,
           renewal_po_number,
           renewal_price_list,
           renewal_pricing_type,
           renewal_markup_percent,
           renewal_grace_duration,
           renewal_grace_period,
           renewal_est_rev_percent,
           renewal_est_rev_duration,
           renewal_est_rev_period,
           renewal_price_list_used,
           renewal_type_used,
           renewal_notification_to,
           renewal_po_used,
           renewal_pricing_type_used,
           renewal_markup_percent_used,
           rev_est_percent_used,
           rev_est_duration_used,
           rev_est_period_used,
           billing_profile_used,
           ern_flag_used_yn,
           evn_threshold_amt,
           evn_threshold_cur,
           ern_threshold_amt,
           ern_threshold_cur,
           renewal_grace_duration_used,
           renewal_grace_period_used,
           inv_trx_type,
           inv_print_profile,
           ar_interface_yn,
           hold_billing,
           summary_trx_yn,
           service_po_number,
           service_po_required,
           billing_schedule_type,
           object_version_number,
           request_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           PERIOD_TYPE,
           PERIOD_START,
           PRICE_UOM,
           FOLLOW_UP_ACTION,
           FOLLOW_UP_DATE,
           TRXN_EXTENSION_ID,
           DATE_ACCEPTED,
           ACCEPTED_BY,
           RMNDR_SUPPRESS_FLAG,
           RMNDR_SENT_FLAG,
           QUOTE_SENT_FLAG,
           PROCESS_REQUEST_ID,
           WF_ITEM_KEY,
           PERSON_PARTY_ID,
           TAX_CLASSIFICATION_CODE,
           EXEMPT_CERTIFICATE_NUMBER,
           EXEMPT_REASON_CODE,
           APPROVAL_TYPE_USED
           )
        VALUES (
                in_id(i),
                in_major_version(i),
                in_chr_id(i),
                in_acct_rule_id(i),
                in_payment_type(i),
                in_cc_no(i),
                in_cc_expiry_date(i),
                in_cc_bank_acct_id(i),
                in_cc_auth_code(i),
                in_commitment_id(i),
                in_grace_duration(i),
                in_grace_period(i),
                in_est_rev_percent(i),
                in_est_rev_date(i),
                in_tax_amount(i),
                in_tax_status(i),
                in_tax_code(i),
                in_tax_exemption_id(i),
                in_billing_profile_id(i),
                in_renewal_status(i),
                in_electronic_renewal_flag(i),
                in_quote_to_contact_id(i),
                in_quote_to_site_id(i),
                in_quote_to_email_id(i),
                in_quote_to_phone_id(i),
                in_quote_to_fax_id(i),
                in_renewal_po_required(i),
                in_renewal_po_number(i),
                in_renewal_price_list(i),
                in_renewal_pricing_type(i),
                in_renewal_markup_percent(i),
                in_renewal_grace_duration(i),
                in_renewal_grace_period(i),
                in_renewal_est_rev_percent(i),
                in_renewal_est_rev_duration(i),
                in_renewal_est_rev_period(i),
                in_renewal_price_list_used(i),
                in_renewal_type_used(i),
                in_renewal_notification_to(i),
                in_renewal_po_used(i),
                in_renewal_pricing_type_used(i),
                in_renewal_markup_percent_used(i),
                in_rev_est_percent_used(i),
                in_rev_est_duration_used(i),
                in_rev_est_period_used(i),
                in_billing_profile_used(i),
                in_ern_flag_used_yn(i),
                in_evn_threshold_amt(i),
                in_evn_threshold_cur(i),
                in_ern_threshold_amt(i),
                in_ern_threshold_cur(i),
                in_renewal_grace_duration_used(i),
                in_renewal_grace_period_used(i),
                in_inv_trx_type(i),
                in_inv_print_profile(i),
                in_ar_interface_yn(i),
                in_hold_billing(i),
                in_summary_trx_yn(i),
                in_service_po_number(i),
                in_service_po_required(i),
                in_billing_schedule_type(i),
                in_object_version_number(i),
                in_request_id(i),
                in_created_by(i),
                in_creation_date(i),
                in_last_updated_by(i),
                in_last_update_date(i),
                in_last_update_login(i),
                in_period_type(i),
                in_period_start(i),
                in_price_uom(i),
                in_follow_up_action(i),
                in_follow_up_date(i),
                in_trxn_extension_id(i),
                in_date_accepted(i),
                in_accepted_by(i),
                in_rmndr_suppress_flag(i),
                in_rmndr_sent_flag(i),
                in_quote_sent_flag(i),
                in_process_request_id(i),
                in_wf_item_key(i),
                in_person_party_id(i),
                in_tax_classification_code(i),
                in_exempt_certificate_number(i),
                in_exempt_reason_code(i),
                in_approval_type_used(i)
                );

-- Launch bulk concurrent program for all new contracts created to uptake r12 workflow

        l_request_id := fnd_request.submit_request
        (
         APPLICATION => 'OKS',
         PROGRAM => 'OKSMIGKWF',
         DESCRIPTION => NULL,
         START_TIME => SYSDATE,
         SUB_REQUEST => FALSE
         );

    EXCEPTION
        WHEN OTHERS THEN
    -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END CREATE_HDR_VERSION_UPG;


END oks_contract_hdr_pub;


/
