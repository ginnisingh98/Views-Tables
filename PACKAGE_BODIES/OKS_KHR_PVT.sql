--------------------------------------------------------
--  DDL for Package Body OKS_KHR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_KHR_PVT" AS
/* $Header: OKSSKHRB.pls 120.10.12010000.2 2008/11/07 10:17:06 serukull ship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
    PROCEDURE load_error_tbl (
                              px_error_rec IN OUT NOCOPY OKC_API.ERROR_REC_TYPE,
                              px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    j INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx INTEGER := FND_MSG_PUB.G_NEXT;
    BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
        IF (last_msg_idx = 1) THEN
            l_msg_idx := FND_MSG_PUB.G_FIRST;
        END IF;
        LOOP
            fnd_msg_pub.get(
                            p_msg_index => l_msg_idx,
                            p_encoded => fnd_api.g_false,
                            p_data => px_error_rec.msg_data,
                            p_msg_index_out => px_error_rec.msg_count);
            px_error_tbl(j) := px_error_rec;
            j := j + 1;
            EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
        END LOOP;
    END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a OKC_API.ERROR_TBL_TYPE, and returns it.
    FUNCTION find_highest_exception(
                                    p_error_tbl IN OKC_API.ERROR_TBL_TYPE
                                    ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i INTEGER := 1;
    BEGIN
        IF (p_error_tbl.COUNT > 0) THEN
            i := p_error_tbl.FIRST;
            LOOP
                IF (p_error_tbl(i).error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        l_return_status := p_error_tbl(i).error_type;
                    END IF;
                END IF;
                EXIT WHEN (i = p_error_tbl.LAST);
                i := p_error_tbl.NEXT(i);
            END LOOP;
        END IF;
        RETURN(l_return_status);
    END find_highest_exception;
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
    FUNCTION get_seq_id RETURN NUMBER IS
    BEGIN
        RETURN(okc_p_util.raw_to_number(sys_guid()));
    END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
    PROCEDURE qc IS
    BEGIN
        NULL;
    END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
    PROCEDURE change_version IS
    BEGIN
        NULL;
    END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
    PROCEDURE api_copy IS
    BEGIN
        NULL;
    END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_K_HEADERS_V
  ---------------------------------------------------------------------------
    FUNCTION get_rec (
                      p_khrv_rec IN khrv_rec_type,
                      x_no_data_found OUT NOCOPY BOOLEAN
                      ) RETURN khrv_rec_type IS
    CURSOR oks_khrv_pk_csr (p_id IN NUMBER) IS
        SELECT
                ID,
                CHR_ID,
                ACCT_RULE_ID,
                PAYMENT_TYPE,
                CC_NO,
                CC_EXPIRY_DATE,
                CC_BANK_ACCT_ID,
                CC_AUTH_CODE,
                COMMITMENT_ID,
                GRACE_DURATION,
                GRACE_PERIOD,
                EST_REV_PERCENT,
                EST_REV_DATE,
                TAX_AMOUNT,
                TAX_STATUS,
                TAX_CODE,
                TAX_EXEMPTION_ID,
                BILLING_PROFILE_ID,
                RENEWAL_STATUS,
                ELECTRONIC_RENEWAL_FLAG,
                QUOTE_TO_CONTACT_ID,
                QUOTE_TO_SITE_ID,
                QUOTE_TO_EMAIL_ID,
                QUOTE_TO_PHONE_ID,
                QUOTE_TO_FAX_ID,
                RENEWAL_PO_REQUIRED,
                RENEWAL_PO_NUMBER,
                RENEWAL_PRICE_LIST,
                RENEWAL_PRICING_TYPE,
                RENEWAL_MARKUP_PERCENT,
                RENEWAL_GRACE_DURATION,
                RENEWAL_GRACE_PERIOD,
                RENEWAL_EST_REV_PERCENT,
                RENEWAL_EST_REV_DURATION,
                RENEWAL_EST_REV_PERIOD,
                RENEWAL_PRICE_LIST_USED,
                RENEWAL_TYPE_USED,
                RENEWAL_NOTIFICATION_TO,
                RENEWAL_PO_USED,
                RENEWAL_PRICING_TYPE_USED,
                RENEWAL_MARKUP_PERCENT_USED,
                REV_EST_PERCENT_USED,
                REV_EST_DURATION_USED,
                REV_EST_PERIOD_USED,
                BILLING_PROFILE_USED,
                ERN_FLAG_USED_YN,
                EVN_THRESHOLD_AMT,
                EVN_THRESHOLD_CUR,
                ERN_THRESHOLD_AMT,
                ERN_THRESHOLD_CUR,
                RENEWAL_GRACE_DURATION_USED,
                RENEWAL_GRACE_PERIOD_USED,
                INV_TRX_TYPE,
                INV_PRINT_PROFILE,
                AR_INTERFACE_YN,
                HOLD_BILLING,
                SUMMARY_TRX_YN,
                SERVICE_PO_NUMBER,
                SERVICE_PO_REQUIRED,
                BILLING_SCHEDULE_TYPE,
                OBJECT_VERSION_NUMBER,
                SECURITY_GROUP_ID,
                REQUEST_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
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
		RENEWAL_COMMENT
          FROM Oks_K_Headers_V
         WHERE oks_k_headers_v.id = p_id;
    l_oks_khrv_pk oks_khrv_pk_csr%ROWTYPE;
    l_khrv_rec khrv_rec_type;
    BEGIN
        x_no_data_found := TRUE;
    -- Get current database values
        OPEN oks_khrv_pk_csr (p_khrv_rec.id);
        FETCH oks_khrv_pk_csr INTO
        l_khrv_rec.id,
        l_khrv_rec.chr_id,
        l_khrv_rec.acct_rule_id,
        l_khrv_rec.payment_type,
        l_khrv_rec.cc_no,
        l_khrv_rec.cc_expiry_date,
        l_khrv_rec.cc_bank_acct_id,
        l_khrv_rec.cc_auth_code,
        l_khrv_rec.commitment_id,
        l_khrv_rec.grace_duration,
        l_khrv_rec.grace_period,
        l_khrv_rec.est_rev_percent,
        l_khrv_rec.est_rev_date,
        l_khrv_rec.tax_amount,
        l_khrv_rec.tax_status,
        l_khrv_rec.tax_code,
        l_khrv_rec.tax_exemption_id,
        l_khrv_rec.billing_profile_id,
        l_khrv_rec.renewal_status,
        l_khrv_rec.electronic_renewal_flag,
        l_khrv_rec.quote_to_contact_id,
        l_khrv_rec.quote_to_site_id,
        l_khrv_rec.quote_to_email_id,
        l_khrv_rec.quote_to_phone_id,
        l_khrv_rec.quote_to_fax_id,
        l_khrv_rec.renewal_po_required,
        l_khrv_rec.renewal_po_number,
        l_khrv_rec.renewal_price_list,
        l_khrv_rec.renewal_pricing_type,
        l_khrv_rec.renewal_markup_percent,
        l_khrv_rec.renewal_grace_duration,
        l_khrv_rec.renewal_grace_period,
        l_khrv_rec.renewal_est_rev_percent,
        l_khrv_rec.renewal_est_rev_duration,
        l_khrv_rec.renewal_est_rev_period,
        l_khrv_rec.renewal_price_list_used,
        l_khrv_rec.renewal_type_used,
        l_khrv_rec.renewal_notification_to,
        l_khrv_rec.renewal_po_used,
        l_khrv_rec.renewal_pricing_type_used,
        l_khrv_rec.renewal_markup_percent_used,
        l_khrv_rec.rev_est_percent_used,
        l_khrv_rec.rev_est_duration_used,
        l_khrv_rec.rev_est_period_used,
        l_khrv_rec.billing_profile_used,
        l_khrv_rec.ern_flag_used_yn,
        l_khrv_rec.evn_threshold_amt,
        l_khrv_rec.evn_threshold_cur,
        l_khrv_rec.ern_threshold_amt,
        l_khrv_rec.ern_threshold_cur,
        l_khrv_rec.renewal_grace_duration_used,
        l_khrv_rec.renewal_grace_period_used,
        l_khrv_rec.inv_trx_type,
        l_khrv_rec.inv_print_profile,
        l_khrv_rec.ar_interface_yn,
        l_khrv_rec.hold_billing,
        l_khrv_rec.summary_trx_yn,
        l_khrv_rec.service_po_number,
        l_khrv_rec.service_po_required,
        l_khrv_rec.billing_schedule_type,
        l_khrv_rec.object_version_number,
        l_khrv_rec.security_group_id,
        l_khrv_rec.request_id,
        l_khrv_rec.created_by,
        l_khrv_rec.creation_date,
        l_khrv_rec.last_updated_by,
        l_khrv_rec.last_update_date,
        l_khrv_rec.last_update_login,
        l_khrv_rec.period_type,
        l_khrv_rec.period_start,
        l_khrv_rec.price_uom,
        l_khrv_rec.follow_up_action,
        l_khrv_rec.follow_up_date,
        l_khrv_rec.trxn_extension_id,
        l_khrv_rec.date_accepted,
        l_khrv_rec.accepted_by,
        l_khrv_rec.rmndr_suppress_flag,
        l_khrv_rec.rmndr_sent_flag,
        l_khrv_rec.quote_sent_flag,
        l_khrv_rec.process_request_id,
        l_khrv_rec.wf_item_key,
        l_khrv_rec.person_party_id,
        l_khrv_rec.tax_classification_code,
        l_khrv_rec.exempt_certificate_number,
        l_khrv_rec.exempt_reason_code,
        l_khrv_rec.approval_type_used,
        l_khrv_rec.renewal_comment;
        x_no_data_found := oks_khrv_pk_csr%NOTFOUND;
        CLOSE oks_khrv_pk_csr;
        RETURN(l_khrv_rec);
    END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
    FUNCTION get_rec (
                      p_khrv_rec IN khrv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2
                      ) RETURN khrv_rec_type IS
    l_khrv_rec khrv_rec_type;
    l_row_notfound BOOLEAN := TRUE;
    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        l_khrv_rec := get_rec(p_khrv_rec, l_row_notfound);
        IF (l_row_notfound) THEN
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'ID');
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        RETURN(l_khrv_rec);
    END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
    FUNCTION get_rec (
                      p_khrv_rec IN khrv_rec_type
                      ) RETURN khrv_rec_type IS
    l_row_not_found BOOLEAN := TRUE;
    BEGIN
        RETURN(get_rec(p_khrv_rec, l_row_not_found));
    END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_K_HEADERS_B
  ---------------------------------------------------------------------------
    FUNCTION get_rec (
                      p_khr_rec IN khr_rec_type,
                      x_no_data_found OUT NOCOPY BOOLEAN
                      ) RETURN khr_rec_type IS
    CURSOR oks_k_headers_b_pk_csr (p_id IN NUMBER) IS
        SELECT
                ID,
                CHR_ID,
                ACCT_RULE_ID,
                PAYMENT_TYPE,
                CC_NO,
                CC_EXPIRY_DATE,
                CC_BANK_ACCT_ID,
                CC_AUTH_CODE,
                COMMITMENT_ID,
                GRACE_DURATION,
                GRACE_PERIOD,
                EST_REV_PERCENT,
                EST_REV_DATE,
                TAX_AMOUNT,
                TAX_STATUS,
                TAX_CODE,
                TAX_EXEMPTION_ID,
                BILLING_PROFILE_ID,
                RENEWAL_STATUS,
                ELECTRONIC_RENEWAL_FLAG,
                QUOTE_TO_CONTACT_ID,
                QUOTE_TO_SITE_ID,
                QUOTE_TO_EMAIL_ID,
                QUOTE_TO_PHONE_ID,
                QUOTE_TO_FAX_ID,
                RENEWAL_PO_REQUIRED,
                RENEWAL_PO_NUMBER,
                RENEWAL_PRICE_LIST,
                RENEWAL_PRICING_TYPE,
                RENEWAL_MARKUP_PERCENT,
                RENEWAL_GRACE_DURATION,
                RENEWAL_GRACE_PERIOD,
                RENEWAL_EST_REV_PERCENT,
                RENEWAL_EST_REV_DURATION,
                RENEWAL_EST_REV_PERIOD,
                RENEWAL_PRICE_LIST_USED,
                RENEWAL_TYPE_USED,
                RENEWAL_NOTIFICATION_TO,
                RENEWAL_PO_USED,
                RENEWAL_PRICING_TYPE_USED,
                RENEWAL_MARKUP_PERCENT_USED,
                REV_EST_PERCENT_USED,
                REV_EST_DURATION_USED,
                REV_EST_PERIOD_USED,
                BILLING_PROFILE_USED,
                EVN_THRESHOLD_AMT,
                EVN_THRESHOLD_CUR,
                ERN_THRESHOLD_AMT,
                ERN_THRESHOLD_CUR,
                RENEWAL_GRACE_DURATION_USED,
                RENEWAL_GRACE_PERIOD_USED,
                INV_TRX_TYPE,
                INV_PRINT_PROFILE,
                AR_INTERFACE_YN,
                HOLD_BILLING,
                SUMMARY_TRX_YN,
                SERVICE_PO_NUMBER,
                SERVICE_PO_REQUIRED,
                BILLING_SCHEDULE_TYPE,
                OBJECT_VERSION_NUMBER,
                REQUEST_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
                ERN_FLAG_USED_YN,
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
                PERIOD_START,
                PERIOD_TYPE,
                PRICE_UOM,
                PERSON_PARTY_ID,
                TAX_CLASSIFICATION_CODE,
                EXEMPT_CERTIFICATE_NUMBER,
                EXEMPT_REASON_CODE,
                APPROVAL_TYPE_USED,
		RENEWAL_COMMENT
          FROM Oks_K_Headers_B
         WHERE oks_k_headers_b.id = p_id;
    l_oks_k_headers_b_pk oks_k_headers_b_pk_csr%ROWTYPE;
    l_khr_rec khr_rec_type;
    BEGIN
        x_no_data_found := TRUE;
    -- Get current database values
        OPEN oks_k_headers_b_pk_csr (p_khr_rec.id);
        FETCH oks_k_headers_b_pk_csr INTO
        l_khr_rec.id,
        l_khr_rec.chr_id,
        l_khr_rec.acct_rule_id,
        l_khr_rec.payment_type,
        l_khr_rec.cc_no,
        l_khr_rec.cc_expiry_date,
        l_khr_rec.cc_bank_acct_id,
        l_khr_rec.cc_auth_code,
        l_khr_rec.commitment_id,
        l_khr_rec.grace_duration,
        l_khr_rec.grace_period,
        l_khr_rec.est_rev_percent,
        l_khr_rec.est_rev_date,
        l_khr_rec.tax_amount,
        l_khr_rec.tax_status,
        l_khr_rec.tax_code,
        l_khr_rec.tax_exemption_id,
        l_khr_rec.billing_profile_id,
        l_khr_rec.renewal_status,
        l_khr_rec.electronic_renewal_flag,
        l_khr_rec.quote_to_contact_id,
        l_khr_rec.quote_to_site_id,
        l_khr_rec.quote_to_email_id,
        l_khr_rec.quote_to_phone_id,
        l_khr_rec.quote_to_fax_id,
        l_khr_rec.renewal_po_required,
        l_khr_rec.renewal_po_number,
        l_khr_rec.renewal_price_list,
        l_khr_rec.renewal_pricing_type,
        l_khr_rec.renewal_markup_percent,
        l_khr_rec.renewal_grace_duration,
        l_khr_rec.renewal_grace_period,
        l_khr_rec.renewal_est_rev_percent,
        l_khr_rec.renewal_est_rev_duration,
        l_khr_rec.renewal_est_rev_period,
        l_khr_rec.renewal_price_list_used,
        l_khr_rec.renewal_type_used,
        l_khr_rec.renewal_notification_to,
        l_khr_rec.renewal_po_used,
        l_khr_rec.renewal_pricing_type_used,
        l_khr_rec.renewal_markup_percent_used,
        l_khr_rec.rev_est_percent_used,
        l_khr_rec.rev_est_duration_used,
        l_khr_rec.rev_est_period_used,
        l_khr_rec.billing_profile_used,
        l_khr_rec.evn_threshold_amt,
        l_khr_rec.evn_threshold_cur,
        l_khr_rec.ern_threshold_amt,
        l_khr_rec.ern_threshold_cur,
        l_khr_rec.renewal_grace_duration_used,
        l_khr_rec.renewal_grace_period_used,
        l_khr_rec.inv_trx_type,
        l_khr_rec.inv_print_profile,
        l_khr_rec.ar_interface_yn,
        l_khr_rec.hold_billing,
        l_khr_rec.summary_trx_yn,
        l_khr_rec.service_po_number,
        l_khr_rec.service_po_required,
        l_khr_rec.billing_schedule_type,
        l_khr_rec.object_version_number,
        l_khr_rec.request_id,
        l_khr_rec.created_by,
        l_khr_rec.creation_date,
        l_khr_rec.last_updated_by,
        l_khr_rec.last_update_date,
        l_khr_rec.last_update_login,
        l_khr_rec.ern_flag_used_yn,
        l_khr_rec.follow_up_action,
        l_khr_rec.follow_up_date,
        l_khr_rec.trxn_extension_id,
        l_khr_rec.date_accepted,
        l_khr_rec.accepted_by,
        l_khr_rec.rmndr_suppress_flag,
        l_khr_rec.rmndr_sent_flag,
        l_khr_rec.quote_sent_flag,
        l_khr_rec.process_request_id,
        l_khr_rec.wf_item_key,
        l_khr_rec.period_start,
        l_khr_rec.period_type,
        l_khr_rec.price_uom,
        l_khr_rec.person_party_id,
        l_khr_rec.tax_classification_code,
        l_khr_rec.exempt_certificate_number,
        l_khr_rec.exempt_reason_code,
        l_khr_rec.approval_type_used,
        l_khr_rec.RENEWAL_COMMENT;
        x_no_data_found := oks_k_headers_b_pk_csr%NOTFOUND;
        CLOSE oks_k_headers_b_pk_csr;
        RETURN(l_khr_rec);
    END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
    FUNCTION get_rec (
                      p_khr_rec IN khr_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2
                      ) RETURN khr_rec_type IS
    l_khr_rec khr_rec_type;
    l_row_notfound BOOLEAN := TRUE;
    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        l_khr_rec := get_rec(p_khr_rec, l_row_notfound);
        IF (l_row_notfound) THEN
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'ID');
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        RETURN(l_khr_rec);
    END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
    FUNCTION get_rec (
                      p_khr_rec IN khr_rec_type
                      ) RETURN khr_rec_type IS
    l_row_not_found BOOLEAN := TRUE;
    BEGIN
        RETURN(get_rec(p_khr_rec, l_row_not_found));
    END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_K_HEADERS_V
  ---------------------------------------------------------------------------
    FUNCTION null_out_defaults (
                                p_khrv_rec IN khrv_rec_type
                                ) RETURN khrv_rec_type IS
    l_khrv_rec khrv_rec_type := p_khrv_rec;
    BEGIN
        IF (l_khrv_rec.id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.id := NULL;
        END IF;
        IF (l_khrv_rec.chr_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.chr_id := NULL;
        END IF;
        IF (l_khrv_rec.acct_rule_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.acct_rule_id := NULL;
        END IF;
        IF (l_khrv_rec.payment_type = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.payment_type := NULL;
        END IF;
        IF (l_khrv_rec.cc_no = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.cc_no := NULL;
        END IF;
        IF (l_khrv_rec.cc_expiry_date = OKC_API.G_MISS_DATE ) THEN
            l_khrv_rec.cc_expiry_date := NULL;
        END IF;
        IF (l_khrv_rec.cc_bank_acct_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.cc_bank_acct_id := NULL;
        END IF;
        IF (l_khrv_rec.cc_auth_code = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.cc_auth_code := NULL;
        END IF;
        IF (l_khrv_rec.commitment_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.commitment_id := NULL;
        END IF;
        IF (l_khrv_rec.grace_duration = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.grace_duration := NULL;
        END IF;
        IF (l_khrv_rec.grace_period = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.grace_period := NULL;
        END IF;
        IF (l_khrv_rec.est_rev_percent = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.est_rev_percent := NULL;
        END IF;
        IF (l_khrv_rec.est_rev_date = OKC_API.G_MISS_DATE ) THEN
            l_khrv_rec.est_rev_date := NULL;
        END IF;
        IF (l_khrv_rec.tax_amount = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.tax_amount := NULL;
        END IF;
        IF (l_khrv_rec.tax_status = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.tax_status := NULL;
        END IF;
        IF (l_khrv_rec.tax_code = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.tax_code := NULL;
        END IF;
        IF (l_khrv_rec.tax_exemption_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.tax_exemption_id := NULL;
        END IF;
        IF (l_khrv_rec.billing_profile_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.billing_profile_id := NULL;
        END IF;
        IF (l_khrv_rec.renewal_status = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_status := NULL;
        END IF;
        IF (l_khrv_rec.electronic_renewal_flag = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.electronic_renewal_flag := NULL;
        END IF;
        IF (l_khrv_rec.quote_to_contact_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.quote_to_contact_id := NULL;
        END IF;
        IF (l_khrv_rec.quote_to_site_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.quote_to_site_id := NULL;
        END IF;
        IF (l_khrv_rec.quote_to_email_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.quote_to_email_id := NULL;
        END IF;
        IF (l_khrv_rec.quote_to_phone_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.quote_to_phone_id := NULL;
        END IF;
        IF (l_khrv_rec.quote_to_fax_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.quote_to_fax_id := NULL;
        END IF;
        IF (l_khrv_rec.renewal_po_required = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_po_required := NULL;
        END IF;
        IF (l_khrv_rec.renewal_po_number = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_po_number := NULL;
        END IF;
        IF (l_khrv_rec.renewal_price_list = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.renewal_price_list := NULL;
        END IF;
        IF (l_khrv_rec.renewal_pricing_type = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_pricing_type := NULL;
        END IF;
        IF (l_khrv_rec.renewal_markup_percent = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.renewal_markup_percent := NULL;
        END IF;
        IF (l_khrv_rec.renewal_grace_duration = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.renewal_grace_duration := NULL;
        END IF;
        IF (l_khrv_rec.renewal_grace_period = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_grace_period := NULL;
        END IF;
        IF (l_khrv_rec.renewal_est_rev_percent = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.renewal_est_rev_percent := NULL;
        END IF;
        IF (l_khrv_rec.renewal_est_rev_duration = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.renewal_est_rev_duration := NULL;
        END IF;
        IF (l_khrv_rec.renewal_est_rev_period = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_est_rev_period := NULL;
        END IF;
        IF (l_khrv_rec.renewal_price_list_used = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.renewal_price_list_used := NULL;
        END IF;
        IF (l_khrv_rec.renewal_type_used = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_type_used := NULL;
        END IF;
        IF (l_khrv_rec.renewal_notification_to = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.renewal_notification_to := NULL;
        END IF;
        IF (l_khrv_rec.renewal_po_used = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_po_used := NULL;
        END IF;
        IF (l_khrv_rec.renewal_pricing_type_used = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_pricing_type_used := NULL;
        END IF;
        IF (l_khrv_rec.renewal_markup_percent_used = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.renewal_markup_percent_used := NULL;
        END IF;
        IF (l_khrv_rec.rev_est_percent_used = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.rev_est_percent_used := NULL;
        END IF;
        IF (l_khrv_rec.rev_est_duration_used = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.rev_est_duration_used := NULL;
        END IF;
        IF (l_khrv_rec.rev_est_period_used = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.rev_est_period_used := NULL;
        END IF;
        IF (l_khrv_rec.billing_profile_used = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.billing_profile_used := NULL;
        END IF;
        IF (l_khrv_rec.ern_flag_used_yn = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.ern_flag_used_yn := NULL;
        END IF;
        IF (l_khrv_rec.evn_threshold_amt = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.evn_threshold_amt := NULL;
        END IF;
        IF (l_khrv_rec.evn_threshold_cur = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.evn_threshold_cur := NULL;
        END IF;
        IF (l_khrv_rec.ern_threshold_amt = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.ern_threshold_amt := NULL;
        END IF;
        IF (l_khrv_rec.ern_threshold_cur = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.ern_threshold_cur := NULL;
        END IF;
        IF (l_khrv_rec.renewal_grace_duration_used = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.renewal_grace_duration_used := NULL;
        END IF;
        IF (l_khrv_rec.renewal_grace_period_used = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_grace_period_used := NULL;
        END IF;
        IF (l_khrv_rec.inv_trx_type = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.inv_trx_type := NULL;
        END IF;
        IF (l_khrv_rec.inv_print_profile = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.inv_print_profile := NULL;
        END IF;
        IF (l_khrv_rec.ar_interface_yn = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.ar_interface_yn := NULL;
        END IF;
        IF (l_khrv_rec.hold_billing = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.hold_billing := NULL;
        END IF;
        IF (l_khrv_rec.summary_trx_yn = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.summary_trx_yn := NULL;
        END IF;
        IF (l_khrv_rec.service_po_number = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.service_po_number := NULL;
        END IF;
        IF (l_khrv_rec.service_po_required = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.service_po_required := NULL;
        END IF;
        IF (l_khrv_rec.billing_schedule_type = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.billing_schedule_type := NULL;
        END IF;
        IF (l_khrv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.object_version_number := NULL;
        END IF;
        IF (l_khrv_rec.security_group_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.security_group_id := NULL;
        END IF;
        IF (l_khrv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.request_id := NULL;
        END IF;
        IF (l_khrv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.created_by := NULL;
        END IF;
        IF (l_khrv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
            l_khrv_rec.creation_date := NULL;
        END IF;
        IF (l_khrv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.last_updated_by := NULL;
        END IF;
        IF (l_khrv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
            l_khrv_rec.last_update_date := NULL;
        END IF;
        IF (l_khrv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.last_update_login := NULL;
        END IF;
        IF (l_khrv_rec.period_type = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.period_type := NULL;
        END IF;
        IF (l_khrv_rec.period_start = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.period_start := NULL;
        END IF;
        IF (l_khrv_rec.price_uom = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.price_uom := NULL;
        END IF;
        IF (l_khrv_rec.follow_up_action = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.follow_up_action := NULL;
        END IF;
        IF (l_khrv_rec.follow_up_date = OKC_API.G_MISS_DATE ) THEN
            l_khrv_rec.follow_up_date := NULL;
        END IF;
        IF (l_khrv_rec.trxn_extension_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.trxn_extension_id := NULL;
        END IF;
        IF (l_khrv_rec.date_accepted = OKC_API.G_MISS_DATE ) THEN
            l_khrv_rec.date_accepted := NULL;
        END IF;
        IF (l_khrv_rec.accepted_by = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.accepted_by := NULL;
        END IF;
        IF (l_khrv_rec.rmndr_suppress_flag = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.rmndr_suppress_flag := NULL;
        END IF;
        IF (l_khrv_rec.rmndr_sent_flag = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.rmndr_sent_flag := NULL;
        END IF;
        IF (l_khrv_rec.quote_sent_flag = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.quote_sent_flag := NULL;
        END IF;
        IF (l_khrv_rec.process_request_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.process_request_id := NULL;
        END IF;
        IF (l_khrv_rec.wf_item_key = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.wf_item_key := NULL;
        END IF;
        IF (l_khrv_rec.person_party_id = OKC_API.G_MISS_NUM ) THEN
            l_khrv_rec.person_party_id := NULL;
        END IF;
        IF (l_khrv_rec.tax_classification_code = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.tax_classification_code := NULL;
        END IF;
        IF (l_khrv_rec.exempt_certificate_number = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.exempt_certificate_number := NULL;
        END IF;
        IF (l_khrv_rec.exempt_reason_code = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.exempt_reason_code := NULL;
        END IF;
        IF (l_khrv_rec.approval_type_used = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.approval_type_used := NULL;
        END IF;
       IF (l_khrv_rec.renewal_comment = OKC_API.G_MISS_CHAR ) THEN
            l_khrv_rec.renewal_comment := NULL;
        END IF;
        RETURN(l_khrv_rec);
    END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
    PROCEDURE validate_id(
                          x_return_status OUT NOCOPY VARCHAR2,
                          p_id IN NUMBER) IS
    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        IF (p_id = OKC_API.G_MISS_NUM OR
            p_id IS NULL)
            THEN
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
            x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME
                                , p_msg_name => G_UNEXPECTED_ERROR
                                , p_token1 => G_SQLCODE_TOKEN
                                , p_token1_value => SQLCODE
                                , p_token2 => G_SQLERRM_TOKEN
                                , p_token2_value => SQLERRM);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_id;
  -------------------------------------
  -- Validate_Attributes for: CHR_ID --
  -------------------------------------
    PROCEDURE validate_chr_id(
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_chr_id IN NUMBER) IS
    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        IF (p_chr_id = OKC_API.G_MISS_NUM OR
            p_chr_id IS NULL)
            THEN
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'chr_id');
            x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME
                                , p_msg_name => G_UNEXPECTED_ERROR
                                , p_token1 => G_SQLCODE_TOKEN
                                , p_token1_value => SQLCODE
                                , p_token2 => G_SQLERRM_TOKEN
                                , p_token2_value => SQLERRM);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_chr_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
    PROCEDURE validate_object_version_number(
                                             x_return_status OUT NOCOPY VARCHAR2,
                                             p_object_version_number IN NUMBER) IS
    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        IF (p_object_version_number = OKC_API.G_MISS_NUM OR
            p_object_version_number IS NULL)
            THEN
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
            x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME
                                , p_msg_name => G_UNEXPECTED_ERROR
                                , p_token1 => G_SQLCODE_TOKEN
                                , p_token1_value => SQLCODE
                                , p_token2 => G_SQLERRM_TOKEN
                                , p_token2_value => SQLERRM);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKS_K_HEADERS_V --
  ---------------------------------------------
    FUNCTION Validate_Attributes (
                                  p_khrv_rec IN khrv_rec_type
                                  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
        validate_id(x_return_status, p_khrv_rec.id);
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    -- ***
    -- chr_id
    -- ***
        validate_chr_id(x_return_status, p_khrv_rec.chr_id);
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    -- ***
    -- object_version_number
    -- ***
        validate_object_version_number(x_return_status, p_khrv_rec.object_version_number);
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        RETURN(l_return_status);
    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            RETURN(l_return_status);
        WHEN OTHERS THEN
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME
                                , p_msg_name => G_UNEXPECTED_ERROR
                                , p_token1 => G_SQLCODE_TOKEN
                                , p_token1_value => SQLCODE
                                , p_token2 => G_SQLERRM_TOKEN
                                , p_token2_value => SQLERRM);
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);
    END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate Record for:OKS_K_HEADERS_V --
  -----------------------------------------
    FUNCTION Validate_Record (
                              p_khrv_rec IN khrv_rec_type,
                              p_db_khrv_rec IN khrv_rec_type
                              ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
                                    p_khrv_rec IN khrv_rec_type,
                                    p_db_khrv_rec IN khrv_rec_type
                                    ) RETURN VARCHAR2 IS
    item_not_found_error EXCEPTION;
    CURSOR oks_khrv_chrv_fk1_csr (p_id IN NUMBER) IS
        SELECT 'x'
          FROM Okc_K_Headers_V
         WHERE okc_k_headers_v.id = p_id;
    l_oks_khrv_chrv_fk1 oks_khrv_chrv_fk1_csr%ROWTYPE;

    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_row_notfound BOOLEAN := TRUE;
    BEGIN
        IF ((p_khrv_rec.CHR_ID IS NOT NULL)
            AND
            (p_khrv_rec.CHR_ID <> p_db_khrv_rec.CHR_ID))
            THEN
            OPEN oks_khrv_chrv_fk1_csr (p_khrv_rec.CHR_ID);
            FETCH oks_khrv_chrv_fk1_csr INTO l_oks_khrv_chrv_fk1;
            l_row_notfound := oks_khrv_chrv_fk1_csr%NOTFOUND;
            CLOSE oks_khrv_chrv_fk1_csr;
            IF (l_row_notfound) THEN
                OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'CHR_ID');
                RAISE item_not_found_error;
            END IF;
        END IF;
        RETURN (l_return_status);
    EXCEPTION
        WHEN item_not_found_error THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN (l_return_status);
    END validate_foreign_keys;
    BEGIN
        l_return_status := validate_foreign_keys(p_khrv_rec, p_db_khrv_rec);
        RETURN (l_return_status);
    END Validate_Record;
    FUNCTION Validate_Record (
                              p_khrv_rec IN khrv_rec_type
                              ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_khrv_rec khrv_rec_type := get_rec(p_khrv_rec);
    BEGIN
        l_return_status := Validate_Record(p_khrv_rec => p_khrv_rec,
                                           p_db_khrv_rec => l_db_khrv_rec);
        RETURN (l_return_status);
    END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
    PROCEDURE migrate (
                       p_from IN khrv_rec_type,
                       p_to IN OUT NOCOPY khr_rec_type
                       ) IS
    BEGIN
        p_to.id := p_from.id;
        p_to.chr_id := p_from.chr_id;
        p_to.acct_rule_id := p_from.acct_rule_id;
        p_to.payment_type := p_from.payment_type;
        p_to.cc_no := p_from.cc_no;
        p_to.cc_expiry_date := p_from.cc_expiry_date;
        p_to.cc_bank_acct_id := p_from.cc_bank_acct_id;
        p_to.cc_auth_code := p_from.cc_auth_code;
        p_to.commitment_id := p_from.commitment_id;
        p_to.grace_duration := p_from.grace_duration;
        p_to.grace_period := p_from.grace_period;
        p_to.est_rev_percent := p_from.est_rev_percent;
        p_to.est_rev_date := p_from.est_rev_date;
        p_to.tax_amount := p_from.tax_amount;
        p_to.tax_status := p_from.tax_status;
        p_to.tax_code := p_from.tax_code;
        p_to.tax_exemption_id := p_from.tax_exemption_id;
        p_to.billing_profile_id := p_from.billing_profile_id;
        p_to.renewal_status := p_from.renewal_status;
        p_to.electronic_renewal_flag := p_from.electronic_renewal_flag;
        p_to.quote_to_contact_id := p_from.quote_to_contact_id;
        p_to.quote_to_site_id := p_from.quote_to_site_id;
        p_to.quote_to_email_id := p_from.quote_to_email_id;
        p_to.quote_to_phone_id := p_from.quote_to_phone_id;
        p_to.quote_to_fax_id := p_from.quote_to_fax_id;
        p_to.renewal_po_required := p_from.renewal_po_required;
        p_to.renewal_po_number := p_from.renewal_po_number;
        p_to.renewal_price_list := p_from.renewal_price_list;
        p_to.renewal_pricing_type := p_from.renewal_pricing_type;
        p_to.renewal_markup_percent := p_from.renewal_markup_percent;
        p_to.renewal_grace_duration := p_from.renewal_grace_duration;
        p_to.renewal_grace_period := p_from.renewal_grace_period;
        p_to.renewal_est_rev_percent := p_from.renewal_est_rev_percent;
        p_to.renewal_est_rev_duration := p_from.renewal_est_rev_duration;
        p_to.renewal_est_rev_period := p_from.renewal_est_rev_period;
        p_to.renewal_price_list_used := p_from.renewal_price_list_used;
        p_to.renewal_type_used := p_from.renewal_type_used;
        p_to.renewal_notification_to := p_from.renewal_notification_to;
        p_to.renewal_po_used := p_from.renewal_po_used;
        p_to.renewal_pricing_type_used := p_from.renewal_pricing_type_used;
        p_to.renewal_markup_percent_used := p_from.renewal_markup_percent_used;
        p_to.rev_est_percent_used := p_from.rev_est_percent_used;
        p_to.rev_est_duration_used := p_from.rev_est_duration_used;
        p_to.rev_est_period_used := p_from.rev_est_period_used;
        p_to.billing_profile_used := p_from.billing_profile_used;
        p_to.evn_threshold_amt := p_from.evn_threshold_amt;
        p_to.evn_threshold_cur := p_from.evn_threshold_cur;
        p_to.ern_threshold_amt := p_from.ern_threshold_amt;
        p_to.ern_threshold_cur := p_from.ern_threshold_cur;
        p_to.renewal_grace_duration_used := p_from.renewal_grace_duration_used;
        p_to.renewal_grace_period_used := p_from.renewal_grace_period_used;
        p_to.inv_trx_type := p_from.inv_trx_type;
        p_to.inv_print_profile := p_from.inv_print_profile;
        p_to.ar_interface_yn := p_from.ar_interface_yn;
        p_to.hold_billing := p_from.hold_billing;
        p_to.summary_trx_yn := p_from.summary_trx_yn;
        p_to.service_po_number := p_from.service_po_number;
        p_to.service_po_required := p_from.service_po_required;
        p_to.billing_schedule_type := p_from.billing_schedule_type;
        p_to.object_version_number := p_from.object_version_number;
        p_to.request_id := p_from.request_id;
        p_to.created_by := p_from.created_by;
        p_to.creation_date := p_from.creation_date;
        p_to.last_updated_by := p_from.last_updated_by;
        p_to.last_update_date := p_from.last_update_date;
        p_to.last_update_login := p_from.last_update_login;
        p_to.ern_flag_used_yn := p_from.ern_flag_used_yn;
        p_to.follow_up_action := p_from.follow_up_action;
        p_to.follow_up_date := p_from.follow_up_date;
        p_to.trxn_extension_id := p_from.trxn_extension_id;
        p_to.date_accepted := p_from.date_accepted;
        p_to.accepted_by := p_from.accepted_by;
        p_to.rmndr_suppress_flag := p_from.rmndr_suppress_flag;
        p_to.rmndr_sent_flag := p_from.rmndr_sent_flag;
        p_to.quote_sent_flag := p_from.quote_sent_flag;
        p_to.process_request_id := p_from.process_request_id;
        p_to.wf_item_key := p_from.wf_item_key;
        p_to.period_start := p_from.period_start;
        p_to.period_type := p_from.period_type;
        p_to.price_uom := p_from.price_uom;
        p_to.person_party_id := p_from.person_party_id;
        p_to.tax_classification_code := p_from.tax_classification_code;
        p_to.exempt_certificate_number := p_from.exempt_certificate_number;
        p_to.exempt_reason_code := p_from.exempt_reason_code;
        p_to.approval_type_used := p_from.approval_type_used;
        p_to.renewal_comment := p_from. renewal_comment;
    END migrate;
    PROCEDURE migrate (
                       p_from IN khr_rec_type,
                       p_to IN OUT NOCOPY khrv_rec_type
                       ) IS
    BEGIN
        p_to.id := p_from.id;
        p_to.chr_id := p_from.chr_id;
        p_to.acct_rule_id := p_from.acct_rule_id;
        p_to.payment_type := p_from.payment_type;
        p_to.cc_no := p_from.cc_no;
        p_to.cc_expiry_date := p_from.cc_expiry_date;
        p_to.cc_bank_acct_id := p_from.cc_bank_acct_id;
        p_to.cc_auth_code := p_from.cc_auth_code;
        p_to.commitment_id := p_from.commitment_id;
        p_to.grace_duration := p_from.grace_duration;
        p_to.grace_period := p_from.grace_period;
        p_to.est_rev_percent := p_from.est_rev_percent;
        p_to.est_rev_date := p_from.est_rev_date;
        p_to.tax_amount := p_from.tax_amount;
        p_to.tax_status := p_from.tax_status;
        p_to.tax_code := p_from.tax_code;
        p_to.tax_exemption_id := p_from.tax_exemption_id;
        p_to.billing_profile_id := p_from.billing_profile_id;
        p_to.renewal_status := p_from.renewal_status;
        p_to.electronic_renewal_flag := p_from.electronic_renewal_flag;
        p_to.quote_to_contact_id := p_from.quote_to_contact_id;
        p_to.quote_to_site_id := p_from.quote_to_site_id;
        p_to.quote_to_email_id := p_from.quote_to_email_id;
        p_to.quote_to_phone_id := p_from.quote_to_phone_id;
        p_to.quote_to_fax_id := p_from.quote_to_fax_id;
        p_to.renewal_po_required := p_from.renewal_po_required;
        p_to.renewal_po_number := p_from.renewal_po_number;
        p_to.renewal_price_list := p_from.renewal_price_list;
        p_to.renewal_pricing_type := p_from.renewal_pricing_type;
        p_to.renewal_markup_percent := p_from.renewal_markup_percent;
        p_to.renewal_grace_duration := p_from.renewal_grace_duration;
        p_to.renewal_grace_period := p_from.renewal_grace_period;
        p_to.renewal_est_rev_percent := p_from.renewal_est_rev_percent;
        p_to.renewal_est_rev_duration := p_from.renewal_est_rev_duration;
        p_to.renewal_est_rev_period := p_from.renewal_est_rev_period;
        p_to.renewal_price_list_used := p_from.renewal_price_list_used;
        p_to.renewal_type_used := p_from.renewal_type_used;
        p_to.renewal_notification_to := p_from.renewal_notification_to;
        p_to.renewal_po_used := p_from.renewal_po_used;
        p_to.renewal_pricing_type_used := p_from.renewal_pricing_type_used;
        p_to.renewal_markup_percent_used := p_from.renewal_markup_percent_used;
        p_to.rev_est_percent_used := p_from.rev_est_percent_used;
        p_to.rev_est_duration_used := p_from.rev_est_duration_used;
        p_to.rev_est_period_used := p_from.rev_est_period_used;
        p_to.billing_profile_used := p_from.billing_profile_used;
        p_to.ern_flag_used_yn := p_from.ern_flag_used_yn;
        p_to.evn_threshold_amt := p_from.evn_threshold_amt;
        p_to.evn_threshold_cur := p_from.evn_threshold_cur;
        p_to.ern_threshold_amt := p_from.ern_threshold_amt;
        p_to.ern_threshold_cur := p_from.ern_threshold_cur;
        p_to.renewal_grace_duration_used := p_from.renewal_grace_duration_used;
        p_to.renewal_grace_period_used := p_from.renewal_grace_period_used;
        p_to.inv_trx_type := p_from.inv_trx_type;
        p_to.inv_print_profile := p_from.inv_print_profile;
        p_to.ar_interface_yn := p_from.ar_interface_yn;
        p_to.hold_billing := p_from.hold_billing;
        p_to.summary_trx_yn := p_from.summary_trx_yn;
        p_to.service_po_number := p_from.service_po_number;
        p_to.service_po_required := p_from.service_po_required;
        p_to.billing_schedule_type := p_from.billing_schedule_type;
        p_to.object_version_number := p_from.object_version_number;
        p_to.request_id := p_from.request_id;
        p_to.created_by := p_from.created_by;
        p_to.creation_date := p_from.creation_date;
        p_to.last_updated_by := p_from.last_updated_by;
        p_to.last_update_date := p_from.last_update_date;
        p_to.last_update_login := p_from.last_update_login;
        p_to.period_type := p_from.period_type;
        p_to.period_start := p_from.period_start;
        p_to.price_uom := p_from.price_uom;
        p_to.follow_up_action := p_from.follow_up_action;
        p_to.follow_up_date := p_from.follow_up_date;
        p_to.trxn_extension_id := p_from.trxn_extension_id;
        p_to.date_accepted := p_from.date_accepted;
        p_to.accepted_by := p_from.accepted_by;
        p_to.rmndr_suppress_flag := p_from.rmndr_suppress_flag;
        p_to.rmndr_sent_flag := p_from.rmndr_sent_flag;
        p_to.quote_sent_flag := p_from.quote_sent_flag;
        p_to.process_request_id := p_from.process_request_id;
        p_to.wf_item_key := p_from.wf_item_key;
        p_to.person_party_id := p_from.person_party_id;
        p_to.tax_classification_code := p_from.tax_classification_code;
        p_to.exempt_certificate_number := p_from.exempt_certificate_number;
        p_to.exempt_reason_code := p_from.exempt_reason_code;
        p_to.approval_type_used := p_from.approval_type_used;
        p_to.renewal_comment := p_from.renewal_comment;
    END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKS_K_HEADERS_V --
  --------------------------------------
    PROCEDURE validate_row(
                           p_api_version IN NUMBER,
                           p_init_msg_list IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2,
                           p_khrv_rec IN khrv_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khrv_rec khrv_rec_type := p_khrv_rec;
    l_khr_rec khr_rec_type;
    l_khr_rec khr_rec_type;
    BEGIN
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    --- Validate all non-missing attributes (Item Level Validation)
        l_return_status := Validate_Attributes(l_khrv_rec);
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := Validate_Record(l_khrv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        x_return_status := l_return_status;
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END validate_row;
  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_K_HEADERS_V --
  -------------------------------------------------
    PROCEDURE validate_row(
                           p_api_version IN NUMBER,
                           p_init_msg_list IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2,
                           p_khrv_tbl IN khrv_tbl_type,
                           px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i NUMBER := 0;
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_khrv_tbl.COUNT > 0) THEN
            i := p_khrv_tbl.FIRST;
            LOOP
                DECLARE
                l_error_rec OKC_API.ERROR_REC_TYPE;
                BEGIN
                    l_error_rec.api_name := l_api_name;
                    l_error_rec.api_package := G_PKG_NAME;
                    l_error_rec.idx := i;
                    validate_row (
                                  p_api_version => p_api_version,
                                  p_init_msg_list => OKC_API.G_FALSE,
                                  x_return_status => l_error_rec.error_type,
                                  x_msg_count => l_error_rec.msg_count,
                                  x_msg_data => l_error_rec.msg_data,
                                  p_khrv_rec => p_khrv_tbl(i));
                    IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    ELSE
                        x_msg_count := l_error_rec.msg_count;
                        x_msg_data := l_error_rec.msg_data;
                    END IF;
                EXCEPTION
                    WHEN OKC_API.G_EXCEPTION_ERROR THEN
                        l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                        l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    WHEN OTHERS THEN
                        l_error_rec.error_type := 'OTHERS';
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                END;
                EXIT WHEN (i = p_khrv_tbl.LAST);
                i := p_khrv_tbl.NEXT(i);
            END LOOP;
        END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
        x_return_status := find_highest_exception(px_error_tbl);
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END validate_row;

  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_K_HEADERS_V --
  -------------------------------------------------
    PROCEDURE validate_row(
                           p_api_version IN NUMBER,
                           p_init_msg_list IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2,
                           p_khrv_tbl IN khrv_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl OKC_API.ERROR_TBL_TYPE;
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_khrv_tbl.COUNT > 0) THEN
            validate_row (
                          p_api_version => p_api_version,
                          p_init_msg_list => OKC_API.G_FALSE,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_khrv_tbl => p_khrv_tbl,
                          px_error_tbl => l_error_tbl);
        END IF;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- insert_row for:OKS_K_HEADERS_B --
  ------------------------------------
    PROCEDURE insert_row(
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khr_rec IN khr_rec_type,
                         x_khr_rec OUT NOCOPY khr_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khr_rec khr_rec_type := p_khr_rec;
    l_def_khr_rec khr_rec_type;
    l_contract_number OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_contract_number_modifier OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE;

-- HANDCODED FOR PROCESS WORKFLOW

    CURSOR csr_check_entered (p_chr_id IN NUMBER) IS
        SELECT CONTRACT_NUMBER, CONTRACT_NUMBER_MODIFIER, ORG_ID
             FROM OKC_K_HEADERS_ALL_B okck,
                  OKC_STATUSES_B sts
              WHERE okck.id = p_chr_id
                AND sts.ste_code = 'ENTERED'
                AND NVL(TEMPLATE_YN, 'N') = 'N'
                AND sts.code = okck.sts_code;

    CURSOR csr_quote_to_person (p_contact_id IN NUMBER, p_org_id IN NUMBER) IS
        SELECT
          P.PARTY_ID
        FROM HZ_CUST_ACCOUNT_ROLES CAR,
             HZ_PARTIES P,
             HZ_RELATIONSHIPS R
         WHERE CAR.ROLE_TYPE = 'CONTACT'
            AND R.PARTY_ID = CAR.PARTY_ID
            AND R.CONTENT_SOURCE_TYPE = 'USER_ENTERED'
            AND P.PARTY_ID = R.SUBJECT_ID
            AND R.DIRECTIONAL_FLAG = 'F'
            AND CAR.CUST_ACCOUNT_ROLE_ID = p_contact_id
            AND EXISTS (SELECT 'X' FROM HZ_CUST_ACCT_SITES CAS
                        WHERE CAS.CUST_ACCOUNT_ID = CAR.CUST_ACCOUNT_ID
                        AND CAS.ORG_ID = P_ORG_ID);


    l_org_id NUMBER ;
    l_person_party_id NUMBER ;
    l_entered VARCHAR2(1) := 'N';
    l_rowfound BOOLEAN := FALSE;
    l_personfound BOOLEAN := FALSE;
    l_defered_YN VARCHAR2(1) := 'N'; -- This will be used to launch WF or not.
    l_wf_attributes OKS_WF_K_PROCESS_PVT.WF_ATTR_DETAILS;
    ----------------------------------------
    -- Set_Attributes for:OKS_K_HEADERS_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
                             p_khr_rec IN khr_rec_type,
                             x_khr_rec OUT NOCOPY khr_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
        x_khr_rec := p_khr_rec;
        RETURN(l_return_status);
    END Set_Attributes;
    BEGIN
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  p_init_msg_list,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    --- Setting item atributes
        l_return_status := Set_Attributes(
                                          p_khr_rec,  -- IN
                                          l_khr_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

-- HANDCODE:Launching WF and Certain WF related design attributes are needed to be populated only for entered K.
-- Also we do not want to launch the workflow if the creation of contract has happened becuase of copy API invoked
-- from renewal flow as the whole contract creation is not complete till the renewal is complete.
-- To determine whether called from renewal-copy, we use the negotiation status as PREDRAFT which is populated by the
-- Copy API depending on renew_reference_yn = Y

        OPEN csr_check_entered(l_khr_rec.chr_id);
        FETCH csr_check_entered INTO l_contract_number, l_contract_number_modifier, l_org_id;
        l_rowfound := csr_check_entered%FOUND;
        CLOSE csr_check_entered;
        IF l_rowfound THEN
            IF l_khr_rec.RENEWAL_STATUS = 'PREDRAFT' THEN
                l_khr_rec.RENEWAL_STATUS := 'DRAFT';
                l_defered_YN := 'Y';
            ELSIF l_khr_rec.RENEWAL_STATUS IS NULL THEN
                l_khr_rec.RENEWAL_STATUS := 'DRAFT';
                l_defered_YN := 'N';
            END IF;
            IF l_khr_rec.WF_ITEM_KEY IS NULL THEN
                l_khr_rec.WF_ITEM_KEY := l_khr_rec.chr_id || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
            END IF;
            IF l_khr_rec.quote_to_contact_id IS NOT NULL THEN
                OPEN csr_quote_to_person(l_khr_rec.quote_to_contact_id, l_org_id);
                FETCH csr_quote_to_person INTO l_person_party_id;
                l_personfound := csr_quote_to_person%FOUND;
                CLOSE csr_quote_to_person;
                IF l_personfound THEN
                    l_khr_rec.person_party_id := l_person_party_id;
                ELSE
                    OKC_API.set_message(G_APP_NAME, 'OKS_INV_PERSON_PARTY_ID');
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;
            END IF;
        END IF;

        INSERT INTO OKS_K_HEADERS_B(
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
                                    ern_flag_used_yn,
                                    follow_up_action,
                                    follow_up_date,
                                    trxn_extension_id,
                                    date_accepted,
                                    accepted_by,
                                    rmndr_suppress_flag,
                                    rmndr_sent_flag,
                                    quote_sent_flag,
                                    process_request_id,
                                    wf_item_key,
                                    period_start,
                                    period_type,
                                    price_uom,
                                    person_party_id,
                                    tax_classification_code,
                                    exempt_certificate_number,
                                    exempt_reason_code,
                                    approval_type_used,
                                    renewal_comment)
        VALUES (
                l_khr_rec.id,
                l_khr_rec.chr_id,
                l_khr_rec.acct_rule_id,
                l_khr_rec.payment_type,
                l_khr_rec.cc_no,
                l_khr_rec.cc_expiry_date,
                l_khr_rec.cc_bank_acct_id,
                l_khr_rec.cc_auth_code,
                l_khr_rec.commitment_id,
                l_khr_rec.grace_duration,
                l_khr_rec.grace_period,
                l_khr_rec.est_rev_percent,
                l_khr_rec.est_rev_date,
                l_khr_rec.tax_amount,
                l_khr_rec.tax_status,
                l_khr_rec.tax_code,
                l_khr_rec.tax_exemption_id,
                l_khr_rec.billing_profile_id,
                l_khr_rec.renewal_status,
                l_khr_rec.electronic_renewal_flag,
                l_khr_rec.quote_to_contact_id,
                l_khr_rec.quote_to_site_id,
                l_khr_rec.quote_to_email_id,
                l_khr_rec.quote_to_phone_id,
                l_khr_rec.quote_to_fax_id,
                l_khr_rec.renewal_po_required,
                l_khr_rec.renewal_po_number,
                l_khr_rec.renewal_price_list,
                l_khr_rec.renewal_pricing_type,
                l_khr_rec.renewal_markup_percent,
                l_khr_rec.renewal_grace_duration,
                l_khr_rec.renewal_grace_period,
                l_khr_rec.renewal_est_rev_percent,
                l_khr_rec.renewal_est_rev_duration,
                l_khr_rec.renewal_est_rev_period,
                l_khr_rec.renewal_price_list_used,
                l_khr_rec.renewal_type_used,
                l_khr_rec.renewal_notification_to,
                l_khr_rec.renewal_po_used,
                l_khr_rec.renewal_pricing_type_used,
                l_khr_rec.renewal_markup_percent_used,
                l_khr_rec.rev_est_percent_used,
                l_khr_rec.rev_est_duration_used,
                l_khr_rec.rev_est_period_used,
                l_khr_rec.billing_profile_used,
                l_khr_rec.evn_threshold_amt,
                l_khr_rec.evn_threshold_cur,
                l_khr_rec.ern_threshold_amt,
                l_khr_rec.ern_threshold_cur,
                l_khr_rec.renewal_grace_duration_used,
                l_khr_rec.renewal_grace_period_used,
                l_khr_rec.inv_trx_type,
                l_khr_rec.inv_print_profile,
                l_khr_rec.ar_interface_yn,
                l_khr_rec.hold_billing,
                l_khr_rec.summary_trx_yn,
                l_khr_rec.service_po_number,
                l_khr_rec.service_po_required,
                l_khr_rec.billing_schedule_type,
                l_khr_rec.object_version_number,
                l_khr_rec.request_id,
                l_khr_rec.created_by,
                l_khr_rec.creation_date,
                l_khr_rec.last_updated_by,
                l_khr_rec.last_update_date,
                l_khr_rec.last_update_login,
                l_khr_rec.ern_flag_used_yn,
                l_khr_rec.follow_up_action,
                l_khr_rec.follow_up_date,
                l_khr_rec.trxn_extension_id,
                l_khr_rec.date_accepted,
                l_khr_rec.accepted_by,
                l_khr_rec.rmndr_suppress_flag,
                l_khr_rec.rmndr_sent_flag,
                l_khr_rec.quote_sent_flag,
                l_khr_rec.process_request_id,
                l_khr_rec.wf_item_key,
                l_khr_rec.period_start,
                l_khr_rec.period_type,
                l_khr_rec.price_uom,
                l_khr_rec.person_party_id,
                l_khr_rec.tax_classification_code,
                l_khr_rec.exempt_certificate_number,
                l_khr_rec.exempt_reason_code,
                l_khr_rec.approval_type_used,
		l_khr_rec.RENEWAL_COMMENT );

-- HANDCODE:Launching WF and Certain WF related design attributes are needed to be populated only for entered K.
-- Also we do not want to launch the workflow if the creation of contract has happened becuase of copy API invoked
-- from renewal flow as the whole contract creation is not complete till the renewal is complete.
-- To determine whether called from renewal-copy, we use the negotiation status as PREDRAFT which is populated by the
-- Copy API depending on renew_reference_yn = Y

        IF l_rowfound AND
           nvl(l_defered_YN, 'N') <> 'Y' THEN
            l_wf_attributes.CONTRACT_ID := l_khr_rec.chr_id;
            l_wf_attributes.CONTRACT_NUMBER := l_contract_number;
            l_wf_attributes.CONTRACT_MODIFIER := l_contract_number_modifier;
            l_wf_attributes.NEGOTIATION_STATUS := l_khr_rec.renewal_status;
            l_wf_attributes.ITEM_KEY := l_khr_rec.wf_item_key;
            l_wf_attributes.IRR_FLAG := 'Y';
            l_wf_attributes.PROCESS_TYPE := 'MANUAL';
            x_return_status := 'S';
            OKS_WF_K_PROCESS_PVT.launch_k_process_wf
            (
             p_api_version => 1.0,
             p_init_msg_list => 'T',
             p_wf_attributes => l_wf_attributes,
             x_return_status => l_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data
             ) ;
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
        END IF;
    -- Set OUT values
        x_khr_rec := l_khr_rec;
        x_return_status := l_return_status;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END insert_row;
  -------------------------------------
  -- insert_row for :OKS_K_HEADERS_V --
  -------------------------------------
    PROCEDURE insert_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khrv_rec IN khrv_rec_type,
                         x_khrv_rec OUT NOCOPY khrv_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khrv_rec khrv_rec_type := p_khrv_rec;
    l_def_khrv_rec khrv_rec_type;
    l_khr_rec khr_rec_type;
    lx_khr_rec khr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
                               p_khrv_rec IN khrv_rec_type
                               ) RETURN khrv_rec_type IS
    l_khrv_rec khrv_rec_type := p_khrv_rec;
    BEGIN
        l_khrv_rec.CREATION_DATE := SYSDATE;
        l_khrv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
        l_khrv_rec.LAST_UPDATE_DATE := l_khrv_rec.CREATION_DATE;
        l_khrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_khrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_khrv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKS_K_HEADERS_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
                             p_khrv_rec IN khrv_rec_type,
                             x_khrv_rec OUT NOCOPY khrv_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
        x_khrv_rec := p_khrv_rec;
        x_khrv_rec.OBJECT_VERSION_NUMBER := 1;
        RETURN(l_return_status);
    END Set_Attributes;
    BEGIN
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_khrv_rec := null_out_defaults(p_khrv_rec);
    -- Set primary key value
        l_khrv_rec.ID := get_seq_id;
    -- Setting item attributes
        l_return_Status := Set_Attributes(
                                          l_khrv_rec,  -- IN
                                          l_def_khrv_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_def_khrv_rec := fill_who_columns(l_def_khrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
        l_return_status := Validate_Attributes(l_def_khrv_rec);
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := Validate_Record(l_def_khrv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
        migrate(l_def_khrv_rec, l_khr_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
        insert_row(
                   p_init_msg_list,
                   l_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_khr_rec,
                   lx_khr_rec
                   );
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        migrate(lx_khr_rec, l_def_khrv_rec);
    -- Set OUT values
        x_khrv_rec := l_def_khrv_rec;
        x_return_status := l_return_status;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:KHRV_TBL --
  ----------------------------------------
    PROCEDURE insert_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khrv_tbl IN khrv_tbl_type,
                         x_khrv_tbl OUT NOCOPY khrv_tbl_type,
                         px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i NUMBER := 0;
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_khrv_tbl.COUNT > 0) THEN
            i := p_khrv_tbl.FIRST;
            LOOP
                DECLARE
                l_error_rec OKC_API.ERROR_REC_TYPE;
                BEGIN
                    l_error_rec.api_name := l_api_name;
                    l_error_rec.api_package := G_PKG_NAME;
                    l_error_rec.idx := i;
                    insert_row (
                                p_api_version => p_api_version,
                                p_init_msg_list => OKC_API.G_FALSE,
                                x_return_status => l_error_rec.error_type,
                                x_msg_count => l_error_rec.msg_count,
                                x_msg_data => l_error_rec.msg_data,
                                p_khrv_rec => p_khrv_tbl(i),
                                x_khrv_rec => x_khrv_tbl(i));
                    IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    ELSE
                        x_msg_count := l_error_rec.msg_count;
                        x_msg_data := l_error_rec.msg_data;
                    END IF;
                EXCEPTION
                    WHEN OKC_API.G_EXCEPTION_ERROR THEN
                        l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                        l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    WHEN OTHERS THEN
                        l_error_rec.error_type := 'OTHERS';
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                END;
                EXIT WHEN (i = p_khrv_tbl.LAST);
                i := p_khrv_tbl.NEXT(i);
            END LOOP;
        END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
        x_return_status := find_highest_exception(px_error_tbl);
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END insert_row;

  ----------------------------------------
  -- PL/SQL TBL insert_row for:KHRV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
    PROCEDURE insert_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khrv_tbl IN khrv_tbl_type,
                         x_khrv_tbl OUT NOCOPY khrv_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl OKC_API.ERROR_TBL_TYPE;
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_khrv_tbl.COUNT > 0) THEN
            insert_row (
                        p_api_version => p_api_version,
                        p_init_msg_list => OKC_API.G_FALSE,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_khrv_tbl => p_khrv_tbl,
                        x_khrv_tbl => x_khrv_tbl,
                        px_error_tbl => l_error_tbl);
        END IF;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ----------------------------------
  -- lock_row for:OKS_K_HEADERS_B --
  ----------------------------------
    PROCEDURE lock_row(
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_khr_rec IN khr_rec_type) IS

    E_Resource_Busy EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy,  - 00054);
    CURSOR lock_csr (p_khr_rec IN khr_rec_type) IS
        SELECT OBJECT_VERSION_NUMBER
          FROM OKS_K_HEADERS_B
         WHERE ID = p_khr_rec.id
           AND OBJECT_VERSION_NUMBER = p_khr_rec.object_version_number
        FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_khr_rec IN khr_rec_type) IS
        SELECT OBJECT_VERSION_NUMBER
          FROM OKS_K_HEADERS_B
         WHERE ID = p_khr_rec.id;
    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number OKS_K_HEADERS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number OKS_K_HEADERS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound BOOLEAN := FALSE;
    lc_row_notfound BOOLEAN := FALSE;
    BEGIN
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  p_init_msg_list,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        BEGIN
            OPEN lock_csr(p_khr_rec);
            FETCH lock_csr INTO l_object_version_number;
            l_row_notfound := lock_csr%NOTFOUND;
            CLOSE lock_csr;
        EXCEPTION
            WHEN E_Resource_Busy THEN
                IF (lock_csr%ISOPEN) THEN
                    CLOSE lock_csr;
                END IF;
                OKC_API.set_message(G_FND_APP, G_FORM_UNABLE_TO_RESERVE_REC);
                RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
        END;

        IF (l_row_notfound ) THEN
            OPEN lchk_csr(p_khr_rec);
            FETCH lchk_csr INTO lc_object_version_number;
            lc_row_notfound := lchk_csr%NOTFOUND;
            CLOSE lchk_csr;
        END IF;
        IF (lc_row_notfound) THEN
            OKC_API.set_message(G_FND_APP, G_FORM_RECORD_DELETED);
            RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSIF lc_object_version_number > p_khr_rec.object_version_number THEN
            OKC_API.set_message(G_FND_APP, G_FORM_RECORD_CHANGED);
            RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSIF lc_object_version_number <> p_khr_rec.object_version_number THEN
            OKC_API.set_message(G_FND_APP, G_FORM_RECORD_CHANGED);
            RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSIF lc_object_version_number =  - 1 THEN
            OKC_API.set_message(G_APP_NAME, G_RECORD_LOGICALLY_DELETED);
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        x_return_status := l_return_status;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END lock_row;
  -----------------------------------
  -- lock_row for: OKS_K_HEADERS_V --
  -----------------------------------
    PROCEDURE lock_row(
                       p_api_version IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_khrv_rec IN khrv_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khr_rec khr_rec_type;
    BEGIN
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
        migrate(p_khrv_rec, l_khr_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
        lock_row(
                 p_init_msg_list,
                 l_return_status,
                 x_msg_count,
                 x_msg_data,
                 l_khr_rec
                 );
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        x_return_status := l_return_status;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:KHRV_TBL --
  --------------------------------------
    PROCEDURE lock_row(
                       p_api_version IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_khrv_tbl IN khrv_tbl_type,
                       px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i NUMBER := 0;
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
        IF (p_khrv_tbl.COUNT > 0) THEN
            i := p_khrv_tbl.FIRST;
            LOOP
                DECLARE
                l_error_rec OKC_API.ERROR_REC_TYPE;
                BEGIN
                    l_error_rec.api_name := l_api_name;
                    l_error_rec.api_package := G_PKG_NAME;
                    l_error_rec.idx := i;
                    lock_row(
                             p_api_version => p_api_version,
                             p_init_msg_list => OKC_API.G_FALSE,
                             x_return_status => l_error_rec.error_type,
                             x_msg_count => l_error_rec.msg_count,
                             x_msg_data => l_error_rec.msg_data,
                             p_khrv_rec => p_khrv_tbl(i));
                    IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    ELSE
                        x_msg_count := l_error_rec.msg_count;
                        x_msg_data := l_error_rec.msg_data;
                    END IF;
                EXCEPTION
                    WHEN OKC_API.G_EXCEPTION_ERROR THEN
                        l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                        l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    WHEN OTHERS THEN
                        l_error_rec.error_type := 'OTHERS';
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                END;
                EXIT WHEN (i = p_khrv_tbl.LAST);
                i := p_khrv_tbl.NEXT(i);
            END LOOP;
        END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
        x_return_status := find_highest_exception(px_error_tbl);
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:KHRV_TBL --
  --------------------------------------
    PROCEDURE lock_row(
                       p_api_version IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_khrv_tbl IN khrv_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl OKC_API.ERROR_TBL_TYPE;
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
        IF (p_khrv_tbl.COUNT > 0) THEN
            lock_row(
                     p_api_version => p_api_version,
                     p_init_msg_list => OKC_API.G_FALSE,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data,
                     p_khrv_tbl => p_khrv_tbl,
                     px_error_tbl => l_error_tbl);
        END IF;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END lock_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- update_row for:OKS_K_HEADERS_B --
  ------------------------------------
    PROCEDURE update_row(
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khr_rec IN khr_rec_type,
                         x_khr_rec OUT NOCOPY khr_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khr_rec khr_rec_type := p_khr_rec;
    l_def_khr_rec khr_rec_type;
    l_row_notfound BOOLEAN := TRUE;

-- HANDCODED FOR PROCESS WORKFLOW

    CURSOR csr_check_entered (p_chr_id IN NUMBER) IS
        SELECT ORG_ID
             FROM OKC_K_HEADERS_ALL_B okck,
                  OKC_STATUSES_B sts
              WHERE okck.id = p_chr_id
                AND sts.ste_code = 'ENTERED'
                AND NVL(TEMPLATE_YN, 'N') = 'N'
                AND sts.code = okck.sts_code;

    CURSOR csr_quote_to_person (p_contact_id IN NUMBER, p_org_id IN NUMBER) IS
        SELECT
          P.PARTY_ID
        FROM HZ_CUST_ACCOUNT_ROLES CAR,
             HZ_PARTIES P,
             HZ_RELATIONSHIPS R
         WHERE CAR.ROLE_TYPE = 'CONTACT'
            AND R.PARTY_ID = CAR.PARTY_ID
            AND R.CONTENT_SOURCE_TYPE = 'USER_ENTERED'
            AND P.PARTY_ID = R.SUBJECT_ID
            AND R.DIRECTIONAL_FLAG = 'F'
            AND CAR.CUST_ACCOUNT_ROLE_ID = p_contact_id
            AND EXISTS (SELECT 'X' FROM HZ_CUST_ACCT_SITES CAS
                        WHERE CAS.CUST_ACCOUNT_ID = CAR.CUST_ACCOUNT_ID
                        AND CAS.ORG_ID = P_ORG_ID);


    l_org_id NUMBER ;
    l_person_party_id NUMBER ;
    l_rowfound BOOLEAN := FALSE;
    l_wf_attributes OKS_WF_K_PROCESS_PVT.WF_ATTR_DETAILS;
    l_quote_changed VARCHAR2(1) := 'N';
    l_credit_card_changed VARCHAR2(1) := 'N';
    l_entered VARCHAR2(1) := 'N';
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------

--  HANDCODED TO CHECK FOR QUOTE CHANGED

    FUNCTION populate_new_record (
                                  p_khr_rec IN khr_rec_type,
                                  x_khr_rec OUT NOCOPY khr_rec_type,
                                  x_quote_changed OUT NOCOPY VARCHAR2,
                                  x_credit_card_changed OUT NOCOPY VARCHAR2
                                  ) RETURN VARCHAR2 IS
    l_khr_rec khr_rec_type;
    l_row_notfound BOOLEAN := TRUE;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
        x_khr_rec := p_khr_rec;
        x_quote_changed := 'N';
      -- Get current database values
        l_khr_rec := get_rec(p_khr_rec, l_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
            IF (x_khr_rec.id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.id := l_khr_rec.id;
            END IF;
            IF (x_khr_rec.chr_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.chr_id := l_khr_rec.chr_id;
            END IF;
            IF (x_khr_rec.acct_rule_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.acct_rule_id := l_khr_rec.acct_rule_id;
            END IF;
            IF (x_khr_rec.payment_type = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.payment_type := l_khr_rec.payment_type;
            END IF;
            IF (x_khr_rec.cc_no = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.cc_no := l_khr_rec.cc_no;
            END IF;
            IF (x_khr_rec.cc_expiry_date = OKC_API.G_MISS_DATE)
                THEN
                x_khr_rec.cc_expiry_date := l_khr_rec.cc_expiry_date;
            END IF;
            IF (x_khr_rec.cc_bank_acct_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.cc_bank_acct_id := l_khr_rec.cc_bank_acct_id;
            END IF;
            IF (x_khr_rec.cc_auth_code = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.cc_auth_code := l_khr_rec.cc_auth_code;
            END IF;
            IF (x_khr_rec.commitment_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.commitment_id := l_khr_rec.commitment_id;
            END IF;
            IF (x_khr_rec.grace_duration = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.grace_duration := l_khr_rec.grace_duration;
            END IF;
            IF (x_khr_rec.grace_period = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.grace_period := l_khr_rec.grace_period;
            END IF;
            IF (x_khr_rec.est_rev_percent = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.est_rev_percent := l_khr_rec.est_rev_percent;
            END IF;
            IF (x_khr_rec.est_rev_date = OKC_API.G_MISS_DATE)
                THEN
                x_khr_rec.est_rev_date := l_khr_rec.est_rev_date;
            END IF;
            IF (x_khr_rec.tax_amount = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.tax_amount := l_khr_rec.tax_amount;
            END IF;
            IF (x_khr_rec.tax_status = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.tax_status := l_khr_rec.tax_status;
            END IF;
            IF (x_khr_rec.tax_code = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.tax_code := l_khr_rec.tax_code;
            END IF;
            IF (x_khr_rec.tax_exemption_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.tax_exemption_id := l_khr_rec.tax_exemption_id;
            END IF;
            IF (x_khr_rec.billing_profile_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.billing_profile_id := l_khr_rec.billing_profile_id;
            END IF;
            IF (x_khr_rec.renewal_status = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_status := l_khr_rec.renewal_status;
            END IF;
            IF (x_khr_rec.electronic_renewal_flag = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.electronic_renewal_flag := l_khr_rec.electronic_renewal_flag;
            END IF;

-- HANDCODE: Check if quote to contact has changed

            IF (x_khr_rec.quote_to_contact_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.quote_to_contact_id := l_khr_rec.quote_to_contact_id;

                x_quote_changed := 'N';
            ELSIF
                nvl(x_khr_rec.quote_to_contact_id,  - 9999) <>
                nvl(l_khr_rec.quote_to_contact_id,  - 9999) THEN
                x_quote_changed := 'Y';
            ELSE
                x_quote_changed := 'N';
            END IF;

            IF (x_khr_rec.quote_to_site_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.quote_to_site_id := l_khr_rec.quote_to_site_id;
            END IF;
            IF (x_khr_rec.quote_to_email_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.quote_to_email_id := l_khr_rec.quote_to_email_id;
            END IF;
            IF (x_khr_rec.quote_to_phone_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.quote_to_phone_id := l_khr_rec.quote_to_phone_id;
            END IF;
            IF (x_khr_rec.quote_to_fax_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.quote_to_fax_id := l_khr_rec.quote_to_fax_id;
            END IF;
            IF (x_khr_rec.renewal_po_required = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_po_required := l_khr_rec.renewal_po_required;
            END IF;
            IF (x_khr_rec.renewal_po_number = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_po_number := l_khr_rec.renewal_po_number;
            END IF;
            IF (x_khr_rec.renewal_price_list = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.renewal_price_list := l_khr_rec.renewal_price_list;
            END IF;
            IF (x_khr_rec.renewal_pricing_type = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_pricing_type := l_khr_rec.renewal_pricing_type;
            END IF;
            IF (x_khr_rec.renewal_markup_percent = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.renewal_markup_percent := l_khr_rec.renewal_markup_percent;
            END IF;
            IF (x_khr_rec.renewal_grace_duration = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.renewal_grace_duration := l_khr_rec.renewal_grace_duration;
            END IF;
            IF (x_khr_rec.renewal_grace_period = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_grace_period := l_khr_rec.renewal_grace_period;
            END IF;
            IF (x_khr_rec.renewal_est_rev_percent = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.renewal_est_rev_percent := l_khr_rec.renewal_est_rev_percent;
            END IF;
            IF (x_khr_rec.renewal_est_rev_duration = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.renewal_est_rev_duration := l_khr_rec.renewal_est_rev_duration;
            END IF;
            IF (x_khr_rec.renewal_est_rev_period = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_est_rev_period := l_khr_rec.renewal_est_rev_period;
            END IF;
            IF (x_khr_rec.renewal_price_list_used = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.renewal_price_list_used := l_khr_rec.renewal_price_list_used;
            END IF;
            IF (x_khr_rec.renewal_type_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_type_used := l_khr_rec.renewal_type_used;
            END IF;
            IF (x_khr_rec.renewal_notification_to = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.renewal_notification_to := l_khr_rec.renewal_notification_to;
            END IF;
            IF (x_khr_rec.renewal_po_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_po_used := l_khr_rec.renewal_po_used;
            END IF;
            IF (x_khr_rec.renewal_pricing_type_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_pricing_type_used := l_khr_rec.renewal_pricing_type_used;
            END IF;
            IF (x_khr_rec.renewal_markup_percent_used = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.renewal_markup_percent_used := l_khr_rec.renewal_markup_percent_used;
            END IF;
            IF (x_khr_rec.rev_est_percent_used = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.rev_est_percent_used := l_khr_rec.rev_est_percent_used;
            END IF;
            IF (x_khr_rec.rev_est_duration_used = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.rev_est_duration_used := l_khr_rec.rev_est_duration_used;
            END IF;
            IF (x_khr_rec.rev_est_period_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.rev_est_period_used := l_khr_rec.rev_est_period_used;
            END IF;
            IF (x_khr_rec.billing_profile_used = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.billing_profile_used := l_khr_rec.billing_profile_used;
            END IF;
            IF (x_khr_rec.evn_threshold_amt = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.evn_threshold_amt := l_khr_rec.evn_threshold_amt;
            END IF;
            IF (x_khr_rec.evn_threshold_cur = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.evn_threshold_cur := l_khr_rec.evn_threshold_cur;
            END IF;
            IF (x_khr_rec.ern_threshold_amt = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.ern_threshold_amt := l_khr_rec.ern_threshold_amt;
            END IF;
            IF (x_khr_rec.ern_threshold_cur = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.ern_threshold_cur := l_khr_rec.ern_threshold_cur;
            END IF;
            IF (x_khr_rec.renewal_grace_duration_used = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.renewal_grace_duration_used := l_khr_rec.renewal_grace_duration_used;
            END IF;
            IF (x_khr_rec.renewal_grace_period_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_grace_period_used := l_khr_rec.renewal_grace_period_used;
            END IF;
            IF (x_khr_rec.inv_trx_type = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.inv_trx_type := l_khr_rec.inv_trx_type;
            END IF;
            IF (x_khr_rec.inv_print_profile = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.inv_print_profile := l_khr_rec.inv_print_profile;
            END IF;
            IF (x_khr_rec.ar_interface_yn = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.ar_interface_yn := l_khr_rec.ar_interface_yn;
            END IF;
            IF (x_khr_rec.hold_billing = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.hold_billing := l_khr_rec.hold_billing;
            END IF;
            IF (x_khr_rec.summary_trx_yn = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.summary_trx_yn := l_khr_rec.summary_trx_yn;
            END IF;
            IF (x_khr_rec.service_po_number = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.service_po_number := l_khr_rec.service_po_number;
            END IF;
            IF (x_khr_rec.service_po_required = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.service_po_required := l_khr_rec.service_po_required;
            END IF;
            IF (x_khr_rec.billing_schedule_type = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.billing_schedule_type := l_khr_rec.billing_schedule_type;
            END IF;
            IF (x_khr_rec.object_version_number = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.object_version_number := l_khr_rec.object_version_number;
            END IF;
            IF (x_khr_rec.request_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.request_id := l_khr_rec.request_id;
            END IF;
            IF (x_khr_rec.created_by = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.created_by := l_khr_rec.created_by;
            END IF;
            IF (x_khr_rec.creation_date = OKC_API.G_MISS_DATE)
                THEN
                x_khr_rec.creation_date := l_khr_rec.creation_date;
            END IF;
            IF (x_khr_rec.last_updated_by = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.last_updated_by := l_khr_rec.last_updated_by;
            END IF;
            IF (x_khr_rec.last_update_date = OKC_API.G_MISS_DATE)
                THEN
                x_khr_rec.last_update_date := l_khr_rec.last_update_date;
            END IF;
            IF (x_khr_rec.last_update_login = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.last_update_login := l_khr_rec.last_update_login;
            END IF;
            IF (x_khr_rec.ern_flag_used_yn = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.ern_flag_used_yn := l_khr_rec.ern_flag_used_yn;
            END IF;
            IF (x_khr_rec.follow_up_action = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.follow_up_action := l_khr_rec.follow_up_action;
            END IF;
            IF (x_khr_rec.follow_up_date = OKC_API.G_MISS_DATE)
                THEN
                x_khr_rec.follow_up_date := l_khr_rec.follow_up_date;
            END IF;
            /**
            IF (x_khr_rec.trxn_extension_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.trxn_extension_id := l_khr_rec.trxn_extension_id;
            END IF;
            **/

            --bug 4656532 (QA updates cc_auth_code after authorization which we need to null out if credit card changes
            IF (x_khr_rec.trxn_extension_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.trxn_extension_id := l_khr_rec.trxn_extension_id;

                x_credit_card_changed := 'N';
            ELSIF
                nvl(x_khr_rec.trxn_extension_id,  - 9999) <>
                nvl(l_khr_rec.trxn_extension_id,  - 9999) THEN
                x_credit_card_changed := 'Y';
            ELSE
                x_credit_card_changed := 'N';
            END IF;

            IF (x_khr_rec.date_accepted = OKC_API.G_MISS_DATE)
                THEN
                x_khr_rec.date_accepted := l_khr_rec.date_accepted;
            END IF;

            IF (x_khr_rec.accepted_by = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.accepted_by := l_khr_rec.accepted_by;
            END IF;
            IF (x_khr_rec.rmndr_suppress_flag = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.rmndr_suppress_flag := l_khr_rec.rmndr_suppress_flag;
            END IF;
            IF (x_khr_rec.rmndr_sent_flag = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.rmndr_sent_flag := l_khr_rec.rmndr_sent_flag;
            END IF;
            IF (x_khr_rec.quote_sent_flag = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.quote_sent_flag := l_khr_rec.quote_sent_flag;
            END IF;
            IF (x_khr_rec.process_request_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.process_request_id := l_khr_rec.process_request_id;
            END IF;
            IF (x_khr_rec.wf_item_key = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.wf_item_key := l_khr_rec.wf_item_key;
            END IF;
            IF (x_khr_rec.period_start = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.period_start := l_khr_rec.period_start;
            END IF;
            IF (x_khr_rec.period_type = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.period_type := l_khr_rec.period_type;
            END IF;
            IF (x_khr_rec.price_uom = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.price_uom := l_khr_rec.price_uom;
            END IF;
            IF (x_khr_rec.person_party_id = OKC_API.G_MISS_NUM)
                THEN
                x_khr_rec.person_party_id := l_khr_rec.person_party_id;
            END IF;
            IF (x_khr_rec.tax_classification_code = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.tax_classification_code := l_khr_rec.tax_classification_code;
            END IF;
            IF (x_khr_rec.exempt_certificate_number = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.exempt_certificate_number := l_khr_rec.exempt_certificate_number;
            END IF;
            IF (x_khr_rec.exempt_reason_code = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.exempt_reason_code := l_khr_rec.exempt_reason_code;
            END IF;
            IF (x_khr_rec.approval_type_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.approval_type_used := l_khr_rec.approval_type_used;
            END IF;
           IF (x_khr_rec.renewal_comment = OKC_API.G_MISS_CHAR)
                THEN
                x_khr_rec.renewal_comment := l_khr_rec.renewal_comment;
            END IF;
        END IF;
        RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKS_K_HEADERS_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
                             p_khr_rec IN khr_rec_type,
                             x_khr_rec OUT NOCOPY khr_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


    BEGIN
        x_khr_rec := p_khr_rec;
        x_khr_rec.OBJECT_VERSION_NUMBER := p_khr_rec.OBJECT_VERSION_NUMBER + 1;
        RETURN(l_return_status);
    END Set_Attributes;

    BEGIN
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  p_init_msg_list,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    --- Setting item attributes
        l_return_status := Set_Attributes(
                                          p_khr_rec,  -- IN
                                          l_khr_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

-- HANDCODED to check for quote changed and update person party id

        --l_return_status := populate_new_record(l_khr_rec, l_def_khr_rec, l_quote_changed);
        l_return_status := populate_new_record(l_khr_rec, l_def_khr_rec, l_quote_changed, l_credit_card_changed);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        IF l_quote_changed = 'Y' THEN
            OPEN csr_check_entered (l_def_khr_rec.chr_id);
            FETCH csr_check_entered INTO l_org_id;
            l_rowfound := csr_check_entered%FOUND;
            CLOSE csr_check_entered;
            IF l_rowfound THEN
              l_entered := 'Y';
            END IF;
            IF l_def_khr_rec.quote_to_contact_id IS NULL THEN
               l_def_khr_rec.person_party_id := NULL;
            ELSE
               OPEN csr_quote_to_person(l_def_khr_rec.quote_to_contact_id, l_org_id);
               FETCH csr_quote_to_person INTO l_person_party_id;
               l_rowfound := csr_quote_to_person%FOUND;
               CLOSE csr_quote_to_person;
               IF l_rowfound THEN
                  l_def_khr_rec.person_party_id := l_person_party_id;
               ELSE
                  OKC_API.set_message(G_APP_NAME, 'OKS_INV_PERSON_PARTY_ID');
               END IF;
            END IF;
        END IF;


        --bug 4656532 (QA updates cc_auth_code after authorization which we need to null out if credit card changes
        IF l_credit_card_changed = 'Y' THEN
           l_def_khr_rec.cc_auth_code := NULL;
        END IF;


        UPDATE OKS_K_HEADERS_B
        SET CHR_ID = l_def_khr_rec.chr_id,
            ACCT_RULE_ID = l_def_khr_rec.acct_rule_id,
            PAYMENT_TYPE = l_def_khr_rec.payment_type,
            CC_NO = l_def_khr_rec.cc_no,
            CC_EXPIRY_DATE = l_def_khr_rec.cc_expiry_date,
            CC_BANK_ACCT_ID = l_def_khr_rec.cc_bank_acct_id,
            CC_AUTH_CODE = l_def_khr_rec.cc_auth_code,
            COMMITMENT_ID = l_def_khr_rec.commitment_id,
            GRACE_DURATION = l_def_khr_rec.grace_duration,
            GRACE_PERIOD = l_def_khr_rec.grace_period,
            EST_REV_PERCENT = l_def_khr_rec.est_rev_percent,
            EST_REV_DATE = l_def_khr_rec.est_rev_date,
            TAX_AMOUNT = l_def_khr_rec.tax_amount,
            TAX_STATUS = l_def_khr_rec.tax_status,
            TAX_CODE = l_def_khr_rec.tax_code,
            TAX_EXEMPTION_ID = l_def_khr_rec.tax_exemption_id,
            BILLING_PROFILE_ID = l_def_khr_rec.billing_profile_id,
            RENEWAL_STATUS = l_def_khr_rec.renewal_status,
            ELECTRONIC_RENEWAL_FLAG = l_def_khr_rec.electronic_renewal_flag,
            QUOTE_TO_CONTACT_ID = l_def_khr_rec.quote_to_contact_id,
            QUOTE_TO_SITE_ID = l_def_khr_rec.quote_to_site_id,
            QUOTE_TO_EMAIL_ID = l_def_khr_rec.quote_to_email_id,
            QUOTE_TO_PHONE_ID = l_def_khr_rec.quote_to_phone_id,
            QUOTE_TO_FAX_ID = l_def_khr_rec.quote_to_fax_id,
            RENEWAL_PO_REQUIRED = l_def_khr_rec.renewal_po_required,
            RENEWAL_PO_NUMBER = l_def_khr_rec.renewal_po_number,
            RENEWAL_PRICE_LIST = l_def_khr_rec.renewal_price_list,
            RENEWAL_PRICING_TYPE = l_def_khr_rec.renewal_pricing_type,
            RENEWAL_MARKUP_PERCENT = l_def_khr_rec.renewal_markup_percent,
            RENEWAL_GRACE_DURATION = l_def_khr_rec.renewal_grace_duration,
            RENEWAL_GRACE_PERIOD = l_def_khr_rec.renewal_grace_period,
            RENEWAL_EST_REV_PERCENT = l_def_khr_rec.renewal_est_rev_percent,
            RENEWAL_EST_REV_DURATION = l_def_khr_rec.renewal_est_rev_duration,
            RENEWAL_EST_REV_PERIOD = l_def_khr_rec.renewal_est_rev_period,
            RENEWAL_PRICE_LIST_USED = l_def_khr_rec.renewal_price_list_used,
            RENEWAL_TYPE_USED = l_def_khr_rec.renewal_type_used,
            RENEWAL_NOTIFICATION_TO = l_def_khr_rec.renewal_notification_to,
            RENEWAL_PO_USED = l_def_khr_rec.renewal_po_used,
            RENEWAL_PRICING_TYPE_USED = l_def_khr_rec.renewal_pricing_type_used,
            RENEWAL_MARKUP_PERCENT_USED = l_def_khr_rec.renewal_markup_percent_used,
            REV_EST_PERCENT_USED = l_def_khr_rec.rev_est_percent_used,
            REV_EST_DURATION_USED = l_def_khr_rec.rev_est_duration_used,
            REV_EST_PERIOD_USED = l_def_khr_rec.rev_est_period_used,
            BILLING_PROFILE_USED = l_def_khr_rec.billing_profile_used,
            EVN_THRESHOLD_AMT = l_def_khr_rec.evn_threshold_amt,
            EVN_THRESHOLD_CUR = l_def_khr_rec.evn_threshold_cur,
            ERN_THRESHOLD_AMT = l_def_khr_rec.ern_threshold_amt,
            ERN_THRESHOLD_CUR = l_def_khr_rec.ern_threshold_cur,
            RENEWAL_GRACE_DURATION_USED = l_def_khr_rec.renewal_grace_duration_used,
            RENEWAL_GRACE_PERIOD_USED = l_def_khr_rec.renewal_grace_period_used,
            INV_TRX_TYPE = l_def_khr_rec.inv_trx_type,
            INV_PRINT_PROFILE = l_def_khr_rec.inv_print_profile,
            AR_INTERFACE_YN = l_def_khr_rec.ar_interface_yn,
            HOLD_BILLING = l_def_khr_rec.hold_billing,
            SUMMARY_TRX_YN = l_def_khr_rec.summary_trx_yn,
            SERVICE_PO_NUMBER = l_def_khr_rec.service_po_number,
            SERVICE_PO_REQUIRED = l_def_khr_rec.service_po_required,
            BILLING_SCHEDULE_TYPE = l_def_khr_rec.billing_schedule_type,
            OBJECT_VERSION_NUMBER = l_def_khr_rec.object_version_number,
            REQUEST_ID = l_def_khr_rec.request_id,
            CREATED_BY = l_def_khr_rec.created_by,
            CREATION_DATE = l_def_khr_rec.creation_date,
            LAST_UPDATED_BY = l_def_khr_rec.last_updated_by,
            LAST_UPDATE_DATE = l_def_khr_rec.last_update_date,
            LAST_UPDATE_LOGIN = l_def_khr_rec.last_update_login,
            ERN_FLAG_USED_YN = l_def_khr_rec.ern_flag_used_yn,
            FOLLOW_UP_ACTION = l_def_khr_rec.follow_up_action,
            FOLLOW_UP_DATE = l_def_khr_rec.follow_up_date,
            TRXN_EXTENSION_ID = l_def_khr_rec.trxn_extension_id,
            DATE_ACCEPTED = l_def_khr_rec.date_accepted,
            ACCEPTED_BY = l_def_khr_rec.accepted_by,
            RMNDR_SUPPRESS_FLAG = l_def_khr_rec.rmndr_suppress_flag,
            RMNDR_SENT_FLAG = l_def_khr_rec.rmndr_sent_flag,
            QUOTE_SENT_FLAG = l_def_khr_rec.quote_sent_flag,
            PROCESS_REQUEST_ID = l_def_khr_rec.process_request_id,
            WF_ITEM_KEY = l_def_khr_rec.wf_item_key,
            PERIOD_START = l_def_khr_rec.period_start,
            PERIOD_TYPE = l_def_khr_rec.period_type,
            PRICE_UOM = l_def_khr_rec.price_uom,
            PERSON_PARTY_ID = l_def_khr_rec.person_party_id,
            TAX_CLASSIFICATION_CODE = l_def_khr_rec.tax_classification_code,
            EXEMPT_CERTIFICATE_NUMBER = l_def_khr_rec.exempt_certificate_number,
            EXEMPT_REASON_CODE = l_def_khr_rec.exempt_reason_code,
            APPROVAL_TYPE_USED = l_def_khr_rec.approval_type_used,
	    renewal_comment = l_def_khr_rec.renewal_comment
        WHERE ID = l_def_khr_rec.id;

-- HANDCODED to check for quote changed only for entered contracts waiting for cust acceptance

        IF l_quote_changed = 'Y' AND
            l_entered = 'Y' AND
            l_def_khr_rec.RENEWAL_STATUS = 'SNT' THEN

            OKS_WF_K_PROCESS_PVT.ASSIGN_NEW_QTO_CONTACT
            (
             p_api_version => 1.0,
             p_init_msg_list => 'F',
             p_contract_id => l_def_khr_rec.chr_id,
             p_item_key => l_def_khr_rec.wf_item_key,
             x_return_status => l_return_status,
             x_msg_data => x_msg_data,
             x_msg_count => x_msg_count
             ) ;
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
        END IF;
        x_khr_rec := l_khr_rec;
        x_return_status := l_return_status;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END update_row;
  ------------------------------------
  -- update_row for:OKS_K_HEADERS_V --
  ------------------------------------
    PROCEDURE update_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khrv_rec IN khrv_rec_type,
                         x_khrv_rec OUT NOCOPY khrv_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khrv_rec khrv_rec_type := p_khrv_rec;
    l_def_khrv_rec khrv_rec_type;
    l_db_khrv_rec khrv_rec_type;
    l_khr_rec khr_rec_type;
    lx_khr_rec khr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
                               p_khrv_rec IN khrv_rec_type
                               ) RETURN khrv_rec_type IS
    l_khrv_rec khrv_rec_type := p_khrv_rec;
    BEGIN
        l_khrv_rec.LAST_UPDATE_DATE := SYSDATE;
        l_khrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_khrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_khrv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
                                  p_khrv_rec IN khrv_rec_type,
                                  x_khrv_rec OUT NOCOPY khrv_rec_type
                                  ) RETURN VARCHAR2 IS
    l_row_notfound BOOLEAN := TRUE;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
        x_khrv_rec := p_khrv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
        l_db_khrv_rec := get_rec(p_khrv_rec, l_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
            IF (x_khrv_rec.id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.id := l_db_khrv_rec.id;
            END IF;
            IF (x_khrv_rec.chr_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.chr_id := l_db_khrv_rec.chr_id;
            END IF;
            IF (x_khrv_rec.acct_rule_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.acct_rule_id := l_db_khrv_rec.acct_rule_id;
            END IF;
            IF (x_khrv_rec.payment_type = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.payment_type := l_db_khrv_rec.payment_type;
            END IF;
            IF (x_khrv_rec.cc_no = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.cc_no := l_db_khrv_rec.cc_no;
            END IF;
            IF (x_khrv_rec.cc_expiry_date = OKC_API.G_MISS_DATE)
                THEN
                x_khrv_rec.cc_expiry_date := l_db_khrv_rec.cc_expiry_date;
            END IF;
            IF (x_khrv_rec.cc_bank_acct_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.cc_bank_acct_id := l_db_khrv_rec.cc_bank_acct_id;
            END IF;
            IF (x_khrv_rec.cc_auth_code = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.cc_auth_code := l_db_khrv_rec.cc_auth_code;
            END IF;
            IF (x_khrv_rec.commitment_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.commitment_id := l_db_khrv_rec.commitment_id;
            END IF;
            IF (x_khrv_rec.grace_duration = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.grace_duration := l_db_khrv_rec.grace_duration;
            END IF;
            IF (x_khrv_rec.grace_period = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.grace_period := l_db_khrv_rec.grace_period;
            END IF;
            IF (x_khrv_rec.est_rev_percent = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.est_rev_percent := l_db_khrv_rec.est_rev_percent;
            END IF;
            IF (x_khrv_rec.est_rev_date = OKC_API.G_MISS_DATE)
                THEN
                x_khrv_rec.est_rev_date := l_db_khrv_rec.est_rev_date;
            END IF;
            IF (x_khrv_rec.tax_amount = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.tax_amount := l_db_khrv_rec.tax_amount;
            END IF;
            IF (x_khrv_rec.tax_status = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.tax_status := l_db_khrv_rec.tax_status;
            END IF;
            IF (x_khrv_rec.tax_code = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.tax_code := l_db_khrv_rec.tax_code;
            END IF;
            IF (x_khrv_rec.tax_exemption_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.tax_exemption_id := l_db_khrv_rec.tax_exemption_id;
            END IF;
            IF (x_khrv_rec.billing_profile_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.billing_profile_id := l_db_khrv_rec.billing_profile_id;
            END IF;
            IF (x_khrv_rec.renewal_status = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_status := l_db_khrv_rec.renewal_status;
            END IF;
            IF (x_khrv_rec.electronic_renewal_flag = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.electronic_renewal_flag := l_db_khrv_rec.electronic_renewal_flag;
            END IF;
            IF (x_khrv_rec.quote_to_contact_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.quote_to_contact_id := l_db_khrv_rec.quote_to_contact_id;
            END IF;
            IF (x_khrv_rec.quote_to_site_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.quote_to_site_id := l_db_khrv_rec.quote_to_site_id;
            END IF;
            IF (x_khrv_rec.quote_to_email_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.quote_to_email_id := l_db_khrv_rec.quote_to_email_id;
            END IF;
            IF (x_khrv_rec.quote_to_phone_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.quote_to_phone_id := l_db_khrv_rec.quote_to_phone_id;
            END IF;
            IF (x_khrv_rec.quote_to_fax_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.quote_to_fax_id := l_db_khrv_rec.quote_to_fax_id;
            END IF;
            IF (x_khrv_rec.renewal_po_required = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_po_required := l_db_khrv_rec.renewal_po_required;
            END IF;
            IF (x_khrv_rec.renewal_po_number = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_po_number := l_db_khrv_rec.renewal_po_number;
            END IF;
            IF (x_khrv_rec.renewal_price_list = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.renewal_price_list := l_db_khrv_rec.renewal_price_list;
            END IF;
            IF (x_khrv_rec.renewal_pricing_type = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_pricing_type := l_db_khrv_rec.renewal_pricing_type;
            END IF;
            IF (x_khrv_rec.renewal_markup_percent = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.renewal_markup_percent := l_db_khrv_rec.renewal_markup_percent;
            END IF;
            IF (x_khrv_rec.renewal_grace_duration = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.renewal_grace_duration := l_db_khrv_rec.renewal_grace_duration;
            END IF;
            IF (x_khrv_rec.renewal_grace_period = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_grace_period := l_db_khrv_rec.renewal_grace_period;
            END IF;
            IF (x_khrv_rec.renewal_est_rev_percent = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.renewal_est_rev_percent := l_db_khrv_rec.renewal_est_rev_percent;
            END IF;
            IF (x_khrv_rec.renewal_est_rev_duration = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.renewal_est_rev_duration := l_db_khrv_rec.renewal_est_rev_duration;
            END IF;
            IF (x_khrv_rec.renewal_est_rev_period = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_est_rev_period := l_db_khrv_rec.renewal_est_rev_period;
            END IF;
            IF (x_khrv_rec.renewal_price_list_used = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.renewal_price_list_used := l_db_khrv_rec.renewal_price_list_used;
            END IF;
            IF (x_khrv_rec.renewal_type_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_type_used := l_db_khrv_rec.renewal_type_used;
            END IF;
            IF (x_khrv_rec.renewal_notification_to = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.renewal_notification_to := l_db_khrv_rec.renewal_notification_to;
            END IF;
            IF (x_khrv_rec.renewal_po_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_po_used := l_db_khrv_rec.renewal_po_used;
            END IF;
            IF (x_khrv_rec.renewal_pricing_type_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_pricing_type_used := l_db_khrv_rec.renewal_pricing_type_used;
            END IF;
            IF (x_khrv_rec.renewal_markup_percent_used = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.renewal_markup_percent_used := l_db_khrv_rec.renewal_markup_percent_used;
            END IF;
            IF (x_khrv_rec.rev_est_percent_used = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.rev_est_percent_used := l_db_khrv_rec.rev_est_percent_used;
            END IF;
            IF (x_khrv_rec.rev_est_duration_used = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.rev_est_duration_used := l_db_khrv_rec.rev_est_duration_used;
            END IF;
            IF (x_khrv_rec.rev_est_period_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.rev_est_period_used := l_db_khrv_rec.rev_est_period_used;
            END IF;
            IF (x_khrv_rec.billing_profile_used = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.billing_profile_used := l_db_khrv_rec.billing_profile_used;
            END IF;
            IF (x_khrv_rec.ern_flag_used_yn = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.ern_flag_used_yn := l_db_khrv_rec.ern_flag_used_yn;
            END IF;
            IF (x_khrv_rec.evn_threshold_amt = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.evn_threshold_amt := l_db_khrv_rec.evn_threshold_amt;
            END IF;
            IF (x_khrv_rec.evn_threshold_cur = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.evn_threshold_cur := l_db_khrv_rec.evn_threshold_cur;
            END IF;
            IF (x_khrv_rec.ern_threshold_amt = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.ern_threshold_amt := l_db_khrv_rec.ern_threshold_amt;
            END IF;
            IF (x_khrv_rec.ern_threshold_cur = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.ern_threshold_cur := l_db_khrv_rec.ern_threshold_cur;
            END IF;
            IF (x_khrv_rec.renewal_grace_duration_used = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.renewal_grace_duration_used := l_db_khrv_rec.renewal_grace_duration_used;
            END IF;
            IF (x_khrv_rec.renewal_grace_period_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_grace_period_used := l_db_khrv_rec.renewal_grace_period_used;
            END IF;
            IF (x_khrv_rec.inv_trx_type = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.inv_trx_type := l_db_khrv_rec.inv_trx_type;
            END IF;
            IF (x_khrv_rec.inv_print_profile = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.inv_print_profile := l_db_khrv_rec.inv_print_profile;
            END IF;
            IF (x_khrv_rec.ar_interface_yn = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.ar_interface_yn := l_db_khrv_rec.ar_interface_yn;
            END IF;
            IF (x_khrv_rec.hold_billing = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.hold_billing := l_db_khrv_rec.hold_billing;
            END IF;
            IF (x_khrv_rec.summary_trx_yn = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.summary_trx_yn := l_db_khrv_rec.summary_trx_yn;
            END IF;
            IF (x_khrv_rec.service_po_number = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.service_po_number := l_db_khrv_rec.service_po_number;
            END IF;
            IF (x_khrv_rec.service_po_required = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.service_po_required := l_db_khrv_rec.service_po_required;
            END IF;
            IF (x_khrv_rec.billing_schedule_type = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.billing_schedule_type := l_db_khrv_rec.billing_schedule_type;
            END IF;
            IF (x_khrv_rec.security_group_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.security_group_id := l_db_khrv_rec.security_group_id;
            END IF;
            IF (x_khrv_rec.request_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.request_id := l_db_khrv_rec.request_id;
            END IF;
            IF (x_khrv_rec.created_by = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.created_by := l_db_khrv_rec.created_by;
            END IF;
            IF (x_khrv_rec.creation_date = OKC_API.G_MISS_DATE)
                THEN
                x_khrv_rec.creation_date := l_db_khrv_rec.creation_date;
            END IF;
            IF (x_khrv_rec.last_updated_by = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.last_updated_by := l_db_khrv_rec.last_updated_by;
            END IF;
            IF (x_khrv_rec.last_update_date = OKC_API.G_MISS_DATE)
                THEN
                x_khrv_rec.last_update_date := l_db_khrv_rec.last_update_date;
            END IF;
            IF (x_khrv_rec.last_update_login = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.last_update_login := l_db_khrv_rec.last_update_login;
            END IF;
            IF (x_khrv_rec.period_type = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.period_type := l_db_khrv_rec.period_type;
            END IF;
            IF (x_khrv_rec.period_start = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.period_start := l_db_khrv_rec.period_start;
            END IF;
            IF (x_khrv_rec.price_uom = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.price_uom := l_db_khrv_rec.price_uom;
            END IF;
            IF (x_khrv_rec.follow_up_action = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.follow_up_action := l_db_khrv_rec.follow_up_action;
            END IF;
            IF (x_khrv_rec.follow_up_date = OKC_API.G_MISS_DATE)
                THEN
                x_khrv_rec.follow_up_date := l_db_khrv_rec.follow_up_date;
            END IF;
            IF (x_khrv_rec.trxn_extension_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.trxn_extension_id := l_db_khrv_rec.trxn_extension_id;
            END IF;
            IF (x_khrv_rec.date_accepted = OKC_API.G_MISS_DATE)
                THEN
                x_khrv_rec.date_accepted := l_db_khrv_rec.date_accepted;
            END IF;
            IF (x_khrv_rec.accepted_by = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.accepted_by := l_db_khrv_rec.accepted_by;
            END IF;
            IF (x_khrv_rec.rmndr_suppress_flag = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.rmndr_suppress_flag := l_db_khrv_rec.rmndr_suppress_flag;
            END IF;
            IF (x_khrv_rec.rmndr_sent_flag = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.rmndr_sent_flag := l_db_khrv_rec.rmndr_sent_flag;
            END IF;
            IF (x_khrv_rec.quote_sent_flag = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.quote_sent_flag := l_db_khrv_rec.quote_sent_flag;
            END IF;
            IF (x_khrv_rec.process_request_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.process_request_id := l_db_khrv_rec.process_request_id;
            END IF;
            IF (x_khrv_rec.wf_item_key = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.wf_item_key := l_db_khrv_rec.wf_item_key;
            END IF;
            IF (x_khrv_rec.person_party_id = OKC_API.G_MISS_NUM)
                THEN
                x_khrv_rec.person_party_id := l_db_khrv_rec.person_party_id;
            END IF;
            IF (x_khrv_rec.tax_classification_code = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.tax_classification_code := l_db_khrv_rec.tax_classification_code;
            END IF;
            IF (x_khrv_rec.exempt_certificate_number = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.exempt_certificate_number := l_db_khrv_rec.exempt_certificate_number;
            END IF;
            IF (x_khrv_rec.exempt_reason_code = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.exempt_reason_code := l_db_khrv_rec.exempt_reason_code;
            END IF;
            IF (x_khrv_rec.approval_type_used = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.approval_type_used := l_db_khrv_rec.approval_type_used;
            END IF;
            IF (x_khrv_rec. renewal_comment = OKC_API.G_MISS_CHAR)
                THEN
                x_khrv_rec.renewal_comment := l_db_khrv_rec.renewal_comment;
            END IF;
        END IF;
        RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKS_K_HEADERS_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
                             p_khrv_rec IN khrv_rec_type,
                             x_khrv_rec OUT NOCOPY khrv_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
        x_khrv_rec := p_khrv_rec;
        RETURN(l_return_status);
    END Set_Attributes;
    BEGIN
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    --- Setting item attributes
        l_return_status := Set_Attributes(
                                          p_khrv_rec,  -- IN
                                          x_khrv_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := populate_new_record(l_khrv_rec, l_def_khrv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_def_khrv_rec := fill_who_columns(l_def_khrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
        l_return_status := Validate_Attributes(l_def_khrv_rec);
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := Validate_Record(l_def_khrv_rec, l_db_khrv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    -- Lock the Record
        lock_row(
                 p_api_version => p_api_version,
                 p_init_msg_list => p_init_msg_list,
                 x_return_status => l_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data,
                 p_khrv_rec => p_khrv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
        migrate(l_def_khrv_rec, l_khr_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
        update_row(
                   p_init_msg_list,
                   l_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_khr_rec,
                   lx_khr_rec
                   );
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        migrate(lx_khr_rec, l_def_khrv_rec);
        x_khrv_rec := l_def_khrv_rec;
        x_return_status := l_return_status;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:khrv_tbl --
  ----------------------------------------
    PROCEDURE update_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khrv_tbl IN khrv_tbl_type,
                         x_khrv_tbl OUT NOCOPY khrv_tbl_type,
                         px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i NUMBER := 0;
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_khrv_tbl.COUNT > 0) THEN
            i := p_khrv_tbl.FIRST;
            LOOP
                DECLARE
                l_error_rec OKC_API.ERROR_REC_TYPE;
                BEGIN
                    l_error_rec.api_name := l_api_name;
                    l_error_rec.api_package := G_PKG_NAME;
                    l_error_rec.idx := i;
                    update_row (
                                p_api_version => p_api_version,
                                p_init_msg_list => OKC_API.G_FALSE,
                                x_return_status => l_error_rec.error_type,
                                x_msg_count => l_error_rec.msg_count,
                                x_msg_data => l_error_rec.msg_data,
                                p_khrv_rec => p_khrv_tbl(i),
                                x_khrv_rec => x_khrv_tbl(i));
                    IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    ELSE
                        x_msg_count := l_error_rec.msg_count;
                        x_msg_data := l_error_rec.msg_data;
                    END IF;
                EXCEPTION
                    WHEN OKC_API.G_EXCEPTION_ERROR THEN
                        l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                        l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    WHEN OTHERS THEN
                        l_error_rec.error_type := 'OTHERS';
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                END;
                EXIT WHEN (i = p_khrv_tbl.LAST);
                i := p_khrv_tbl.NEXT(i);
            END LOOP;
        END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
        x_return_status := find_highest_exception(px_error_tbl);
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END update_row;

  ----------------------------------------
  -- PL/SQL TBL update_row for:KHRV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
    PROCEDURE update_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khrv_tbl IN khrv_tbl_type,
                         x_khrv_tbl OUT NOCOPY khrv_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl OKC_API.ERROR_TBL_TYPE;
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_khrv_tbl.COUNT > 0) THEN
            update_row (
                        p_api_version => p_api_version,
                        p_init_msg_list => OKC_API.G_FALSE,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_khrv_tbl => p_khrv_tbl,
                        x_khrv_tbl => x_khrv_tbl,
                        px_error_tbl => l_error_tbl);
        END IF;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- delete_row for:OKS_K_HEADERS_B --
  ------------------------------------
    PROCEDURE delete_row(
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khr_rec IN khr_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khr_rec khr_rec_type := p_khr_rec;
    l_row_notfound BOOLEAN := TRUE;
    l_chr_id NUMBER := NULL;
    l_wf_item_key VARCHAR2(240) := NULL;
    CURSOR csr_chr_rec (p_id IN NUMBER) IS
        SELECT oksk.chr_id, oksk.wf_item_key
        FROM OKS_K_HEADERS_B oksk
        WHERE oksk.id = p_id;

    BEGIN
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  p_init_msg_list,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

-- HANDCODE FOR WORKFLOW ABORT
-- Unfortunately only id is passed so we will have to get chr_id and wf_item_key with sql access

        OPEN csr_chr_rec(p_khr_rec.id);
        FETCH csr_chr_rec INTO l_chr_id, l_wf_item_key;
        l_row_notfound := csr_chr_rec%NOTFOUND;
        CLOSE csr_chr_rec;

        IF l_row_notfound OR
            l_wf_item_key IS NULL THEN
            NULL;
        ELSE
            OKS_WF_K_PROCESS_PVT.clean_wf
            (
             p_api_version => 1.0,
             p_init_msg_list => 'F',
             p_contract_id => l_chr_id,
             p_item_key => l_wf_item_key,
             x_return_status => l_return_status,
             x_msg_data => x_msg_data,
             x_msg_count => x_msg_count
             ) ;

            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
        END IF;

        DELETE FROM OKS_K_HEADERS_B
         WHERE ID = p_khr_rec.id;

        x_return_status := l_return_status;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END delete_row;
  ------------------------------------
  -- delete_row for:OKS_K_HEADERS_V --
  ------------------------------------
    PROCEDURE delete_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khrv_rec IN khrv_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khrv_rec khrv_rec_type := p_khrv_rec;
    l_khr_rec khr_rec_type;
    BEGIN
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
        migrate(l_khrv_rec, l_khr_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
        delete_row(
                   p_init_msg_list,
                   l_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_khr_rec
                   );
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        x_return_status := l_return_status;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END delete_row;
  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_K_HEADERS_V --
  -----------------------------------------------
    PROCEDURE delete_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khrv_tbl IN khrv_tbl_type,
                         px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i NUMBER := 0;
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_khrv_tbl.COUNT > 0) THEN
            i := p_khrv_tbl.FIRST;
            LOOP
                DECLARE
                l_error_rec OKC_API.ERROR_REC_TYPE;
                BEGIN
                    l_error_rec.api_name := l_api_name;
                    l_error_rec.api_package := G_PKG_NAME;
                    l_error_rec.idx := i;
                    delete_row (
                                p_api_version => p_api_version,
                                p_init_msg_list => OKC_API.G_FALSE,
                                x_return_status => l_error_rec.error_type,
                                x_msg_count => l_error_rec.msg_count,
                                x_msg_data => l_error_rec.msg_data,
                                p_khrv_rec => p_khrv_tbl(i));
                    IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    ELSE
                        x_msg_count := l_error_rec.msg_count;
                        x_msg_data := l_error_rec.msg_data;
                    END IF;
                EXCEPTION
                    WHEN OKC_API.G_EXCEPTION_ERROR THEN
                        l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                        l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                    WHEN OTHERS THEN
                        l_error_rec.error_type := 'OTHERS';
                        l_error_rec.SQLCODE := SQLCODE;
                        load_error_tbl(l_error_rec, px_error_tbl);
                END;
                EXIT WHEN (i = p_khrv_tbl.LAST);
                i := p_khrv_tbl.NEXT(i);
            END LOOP;
        END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
        x_return_status := find_highest_exception(px_error_tbl);
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END delete_row;

  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_K_HEADERS_V --
  -----------------------------------------------
    PROCEDURE delete_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_khrv_tbl IN khrv_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl OKC_API.ERROR_TBL_TYPE;
    BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_khrv_tbl.COUNT > 0) THEN
            delete_row (
                        p_api_version => p_api_version,
                        p_init_msg_list => OKC_API.G_FALSE,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_khrv_tbl => p_khrv_tbl,
                        px_error_tbl => l_error_tbl);
        END IF;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT'
             );
    END delete_row;

END OKS_KHR_PVT;

/
