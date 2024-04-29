--------------------------------------------------------
--  DDL for Package Body OKS_KLN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_KLN_PVT" AS
/* $Header: OKSSKLNB.pls 120.6.12000000.2 2007/02/15 07:30:42 npalepu ship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKC_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
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
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
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
    p_error_tbl                    IN OKC_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
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
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/* refer fnd bug# 3723612 for details and oks bug 4210278
/*
    DELETE FROM OKS_K_LINES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKS_K_LINES_B B
         WHERE B.ID =T.ID
        );

    UPDATE OKS_K_LINES_TL T SET(
        INVOICE_TEXT,
        IB_TRX_DETAILS,
        STATUS_TEXT,
        REACT_TIME_NAME) = (SELECT
                                  B.INVOICE_TEXT,
                                  B.IB_TRX_DETAILS,
                                  B.STATUS_TEXT,
                                  B.REACT_TIME_NAME
                                FROM OKS_K_LINES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKS_K_LINES_TL SUBB, OKS_K_LINES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.INVOICE_TEXT <> SUBT.INVOICE_TEXT
                      OR SUBB.IB_TRX_DETAILS <> SUBT.IB_TRX_DETAILS
                      OR SUBB.STATUS_TEXT <> SUBT.STATUS_TEXT
                      OR SUBB.REACT_TIME_NAME <> SUBT.REACT_TIME_NAME
                      OR (SUBB.INVOICE_TEXT IS NULL AND SUBT.INVOICE_TEXT IS NOT NULL)
                      OR (SUBB.IB_TRX_DETAILS IS NULL AND SUBT.IB_TRX_DETAILS IS NOT NULL)
                      OR (SUBB.STATUS_TEXT IS NULL AND SUBT.STATUS_TEXT IS NOT NULL)
                      OR (SUBB.REACT_TIME_NAME IS NULL AND SUBT.REACT_TIME_NAME IS NOT NULL)
              ));

    */

    INSERT /* append parallel (tt) */ INTO OKS_K_LINES_TL tt (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        INVOICE_TEXT,
        IB_TRX_DETAILS,
        STATUS_TEXT,
        REACT_TIME_NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)

	 select /* parallel(v) parallel(t) use_nl(t) */ v.* from
	   (select /*+ no_merge ordered parallel(b) */
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.INVOICE_TEXT,
            B.IB_TRX_DETAILS,
            B.STATUS_TEXT,
            B.REACT_TIME_NAME,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
         from  OKS_K_LINES_TL B, FND_LANGUAGES L
         where L.INSTALLED_FLAG IN ('I', 'B')
	    and B.LANGUAGE = USERENV('LANG')
	    ) v,
	 OKS_K_LINES_TL t
	WHERE t.ID(+) = v.ID
	AND t.LANGUAGE(+) = v.LANGUAGE_CODE
	and t.id is NULL;

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_K_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_klnv_rec                     IN klnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN klnv_rec_type IS
    CURSOR oks_klnv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            DNZ_CHR_ID,
            DISCOUNT_LIST,
            ACCT_RULE_ID,
            PAYMENT_TYPE,
            CC_NO,
            CC_EXPIRY_DATE,
            CC_BANK_ACCT_ID,
            CC_AUTH_CODE,
            COMMITMENT_ID,
            LOCKED_PRICE_LIST_ID,
            USAGE_EST_YN,
            USAGE_EST_METHOD,
            USAGE_EST_START_DATE,
            TERMN_METHOD,
            UBT_AMOUNT,
            CREDIT_AMOUNT,
            SUPPRESSED_CREDIT,
            OVERRIDE_AMOUNT,
            CUST_PO_NUMBER_REQ_YN,
            CUST_PO_NUMBER,
            GRACE_DURATION,
            GRACE_PERIOD,
            INV_PRINT_FLAG,
            PRICE_UOM,
            TAX_AMOUNT,
            TAX_INCLUSIVE_YN,
            TAX_STATUS,
            TAX_CODE,
            TAX_EXEMPTION_ID,
            IB_TRANS_TYPE,
            IB_TRANS_DATE,
            PROD_PRICE,
            SERVICE_PRICE,
            CLVL_LIST_PRICE,
            CLVL_QUANTITY,
            CLVL_EXTENDED_AMT,
            CLVL_UOM_CODE,
            TOPLVL_OPERAND_CODE,
            TOPLVL_OPERAND_VAL,
            TOPLVL_QUANTITY,
            TOPLVL_UOM_CODE,
            TOPLVL_ADJ_PRICE,
            TOPLVL_PRICE_QTY,
            AVERAGING_INTERVAL,
            SETTLEMENT_INTERVAL,
            MINIMUM_QUANTITY,
            DEFAULT_QUANTITY,
            AMCV_FLAG,
            FIXED_QUANTITY,
            USAGE_DURATION,
            USAGE_PERIOD,
            LEVEL_YN,
            USAGE_TYPE,
            UOM_QUANTIFIED,
            BASE_READING,
            BILLING_SCHEDULE_TYPE,
            FULL_CREDIT,
            LOCKED_PRICE_LIST_LINE_ID,
            BREAK_UOM,
            PRORATE,
            COVERAGE_TYPE,
            EXCEPTION_COV_ID,
            LIMIT_UOM_QUANTIFIED,
            DISCOUNT_AMOUNT,
            DISCOUNT_PERCENT,
            OFFSET_DURATION,
            OFFSET_PERIOD,
            INCIDENT_SEVERITY_ID,
            PDF_ID,
            WORK_THRU_YN,
            REACT_ACTIVE_YN,
            TRANSFER_OPTION,
            PROD_UPGRADE_YN,
            INHERITANCE_TYPE,
            PM_PROGRAM_ID,
            PM_CONF_REQ_YN,
            PM_SCH_EXISTS_YN,
            ALLOW_BT_DISCOUNT,
            APPLY_DEFAULT_TIMEZONE,
            SYNC_DATE_INSTALL,
            SFWT_FLAG,
            INVOICE_TEXT,
            IB_TRX_DETAILS,
            STATUS_TEXT,
            REACT_TIME_NAME,
            OBJECT_VERSION_NUMBER,
            SECURITY_GROUP_ID,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
-- R12 Data Model Changes 4485150 Start
            TRXN_EXTENSION_ID,
            TAX_CLASSIFICATION_CODE,
            EXEMPT_CERTIFICATE_NUMBER,
            EXEMPT_REASON_CODE,
            COVERAGE_ID,
            STANDARD_COV_YN,
            ORIG_SYSTEM_ID1,
            ORIG_SYSTEM_REFERENCE1,
            ORIG_SYSTEM_SOURCE_CODE
-- R12 Data Model Changes 4485150 End
      FROM Oks_K_Lines_V
     WHERE oks_k_lines_v.id     = p_id;
    l_oks_klnv_pk                  oks_klnv_pk_csr%ROWTYPE;
    l_klnv_rec                     klnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_klnv_pk_csr (p_klnv_rec.id);
    FETCH oks_klnv_pk_csr INTO
              l_klnv_rec.id,
              l_klnv_rec.cle_id,
              l_klnv_rec.dnz_chr_id,
              l_klnv_rec.discount_list,
              l_klnv_rec.acct_rule_id,
              l_klnv_rec.payment_type,
              l_klnv_rec.cc_no,
              l_klnv_rec.cc_expiry_date,
              l_klnv_rec.cc_bank_acct_id,
              l_klnv_rec.cc_auth_code,
              l_klnv_rec.commitment_id,
              l_klnv_rec.locked_price_list_id,
              l_klnv_rec.usage_est_yn,
              l_klnv_rec.usage_est_method,
              l_klnv_rec.usage_est_start_date,
              l_klnv_rec.termn_method,
              l_klnv_rec.ubt_amount,
              l_klnv_rec.credit_amount,
              l_klnv_rec.suppressed_credit,
              l_klnv_rec.override_amount,
              l_klnv_rec.cust_po_number_req_yn,
              l_klnv_rec.cust_po_number,
              l_klnv_rec.grace_duration,
              l_klnv_rec.grace_period,
              l_klnv_rec.inv_print_flag,
              l_klnv_rec.price_uom,
              l_klnv_rec.tax_amount,
              l_klnv_rec.tax_inclusive_yn,
              l_klnv_rec.tax_status,
              l_klnv_rec.tax_code,
              l_klnv_rec.tax_exemption_id,
              l_klnv_rec.ib_trans_type,
              l_klnv_rec.ib_trans_date,
              l_klnv_rec.prod_price,
              l_klnv_rec.service_price,
              l_klnv_rec.clvl_list_price,
              l_klnv_rec.clvl_quantity,
              l_klnv_rec.clvl_extended_amt,
              l_klnv_rec.clvl_uom_code,
              l_klnv_rec.toplvl_operand_code,
              l_klnv_rec.toplvl_operand_val,
              l_klnv_rec.toplvl_quantity,
              l_klnv_rec.toplvl_uom_code,
              l_klnv_rec.toplvl_adj_price,
              l_klnv_rec.toplvl_price_qty,
              l_klnv_rec.averaging_interval,
              l_klnv_rec.settlement_interval,
              l_klnv_rec.minimum_quantity,
              l_klnv_rec.default_quantity,
              l_klnv_rec.amcv_flag,
              l_klnv_rec.fixed_quantity,
              l_klnv_rec.usage_duration,
              l_klnv_rec.usage_period,
              l_klnv_rec.level_yn,
              l_klnv_rec.usage_type,
              l_klnv_rec.uom_quantified,
              l_klnv_rec.base_reading,
              l_klnv_rec.billing_schedule_type,
              l_klnv_rec.full_credit,
              l_klnv_rec.locked_price_list_line_id,
              l_klnv_rec.break_uom,
              l_klnv_rec.prorate,
              l_klnv_rec.coverage_type,
              l_klnv_rec.exception_cov_id,
              l_klnv_rec.limit_uom_quantified,
              l_klnv_rec.discount_amount,
              l_klnv_rec.discount_percent,
              l_klnv_rec.offset_duration,
              l_klnv_rec.offset_period,
              l_klnv_rec.incident_severity_id,
              l_klnv_rec.pdf_id,
              l_klnv_rec.work_thru_yn,
              l_klnv_rec.react_active_yn,
              l_klnv_rec.transfer_option,
              l_klnv_rec.prod_upgrade_yn,
              l_klnv_rec.inheritance_type,
              l_klnv_rec.pm_program_id,
              l_klnv_rec.pm_conf_req_yn,
              l_klnv_rec.pm_sch_exists_yn,
              l_klnv_rec.allow_bt_discount,
              l_klnv_rec.apply_default_timezone,
              l_klnv_rec.sync_date_install,
              l_klnv_rec.sfwt_flag,
              l_klnv_rec.invoice_text,
              l_klnv_rec.ib_trx_details,
              l_klnv_rec.status_text,
              l_klnv_rec.react_time_name,
              l_klnv_rec.object_version_number,
              l_klnv_rec.security_group_id,
              l_klnv_rec.request_id,
              l_klnv_rec.created_by,
              l_klnv_rec.creation_date,
              l_klnv_rec.last_updated_by,
              l_klnv_rec.last_update_date,
              l_klnv_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
              l_klnv_rec.trxn_extension_id,
              l_klnv_rec.tax_classification_code,
              l_klnv_rec.exempt_certificate_number,
              l_klnv_rec.exempt_reason_code,
              l_klnv_rec.coverage_id,
              l_klnv_rec.standard_cov_yn,
              l_klnv_rec.orig_system_id1,
              l_klnv_rec.orig_system_reference1,
              l_klnv_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
;
    x_no_data_found := oks_klnv_pk_csr%NOTFOUND;
    CLOSE oks_klnv_pk_csr;
    RETURN(l_klnv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_klnv_rec                     IN klnv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN klnv_rec_type IS
    l_klnv_rec                     klnv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_klnv_rec := get_rec(p_klnv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_klnv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_klnv_rec                     IN klnv_rec_type
  ) RETURN klnv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_klnv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_K_LINES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_kln_rec                      IN kln_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN kln_rec_type IS
    CURSOR oks_k_lines_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            DNZ_CHR_ID,
            DISCOUNT_LIST,
            ACCT_RULE_ID,
            PAYMENT_TYPE,
            CC_NO,
            CC_EXPIRY_DATE,
            CC_BANK_ACCT_ID,
            CC_AUTH_CODE,
            COMMITMENT_ID,
            LOCKED_PRICE_LIST_ID,
            USAGE_EST_YN,
            USAGE_EST_METHOD,
            USAGE_EST_START_DATE,
            TERMN_METHOD,
            UBT_AMOUNT,
            CREDIT_AMOUNT,
            SUPPRESSED_CREDIT,
            OVERRIDE_AMOUNT,
            CUST_PO_NUMBER_REQ_YN,
            CUST_PO_NUMBER,
            GRACE_DURATION,
            GRACE_PERIOD,
            INV_PRINT_FLAG,
            PRICE_UOM,
            TAX_AMOUNT,
            TAX_INCLUSIVE_YN,
            TAX_STATUS,
            TAX_CODE,
            TAX_EXEMPTION_ID,
            IB_TRANS_TYPE,
            IB_TRANS_DATE,
            PROD_PRICE,
            SERVICE_PRICE,
            CLVL_LIST_PRICE,
            CLVL_QUANTITY,
            CLVL_EXTENDED_AMT,
            CLVL_UOM_CODE,
            TOPLVL_OPERAND_CODE,
            TOPLVL_OPERAND_VAL,
            TOPLVL_QUANTITY,
            TOPLVL_UOM_CODE,
            TOPLVL_ADJ_PRICE,
            TOPLVL_PRICE_QTY,
            AVERAGING_INTERVAL,
            SETTLEMENT_INTERVAL,
            MINIMUM_QUANTITY,
            DEFAULT_QUANTITY,
            AMCV_FLAG,
            FIXED_QUANTITY,
            USAGE_DURATION,
            USAGE_PERIOD,
            LEVEL_YN,
            USAGE_TYPE,
            UOM_QUANTIFIED,
            BASE_READING,
            BILLING_SCHEDULE_TYPE,
            FULL_CREDIT,
            LOCKED_PRICE_LIST_LINE_ID,
            BREAK_UOM,
            PRORATE,
            COVERAGE_TYPE,
            EXCEPTION_COV_ID,
            LIMIT_UOM_QUANTIFIED,
            DISCOUNT_AMOUNT,
            DISCOUNT_PERCENT,
            OFFSET_DURATION,
            OFFSET_PERIOD,
            INCIDENT_SEVERITY_ID,
            PDF_ID,
            WORK_THRU_YN,
            REACT_ACTIVE_YN,
            TRANSFER_OPTION,
            PROD_UPGRADE_YN,
            INHERITANCE_TYPE,
            PM_PROGRAM_ID,
            PM_CONF_REQ_YN,
            PM_SCH_EXISTS_YN,
            ALLOW_BT_DISCOUNT,
            APPLY_DEFAULT_TIMEZONE,
            SYNC_DATE_INSTALL,
            OBJECT_VERSION_NUMBER,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
-- R12 Data Model Changes 4485150 Start
            TRXN_EXTENSION_ID,
            TAX_CLASSIFICATION_CODE,
            EXEMPT_CERTIFICATE_NUMBER,
            EXEMPT_REASON_CODE,
            COVERAGE_ID,
            STANDARD_COV_YN,
            ORIG_SYSTEM_ID1,
            ORIG_SYSTEM_REFERENCE1,
            ORIG_SYSTEM_SOURCE_CODE
-- R12 Data Model Changes 4485150 End
      FROM Oks_K_Lines_B
     WHERE oks_k_lines_b.id     = p_id;
    l_oks_k_lines_b_pk             oks_k_lines_b_pk_csr%ROWTYPE;
    l_kln_rec                      kln_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_k_lines_b_pk_csr (p_kln_rec.id);
    FETCH oks_k_lines_b_pk_csr INTO
              l_kln_rec.id,
              l_kln_rec.cle_id,
              l_kln_rec.dnz_chr_id,
              l_kln_rec.discount_list,
              l_kln_rec.acct_rule_id,
              l_kln_rec.payment_type,
              l_kln_rec.cc_no,
              l_kln_rec.cc_expiry_date,
              l_kln_rec.cc_bank_acct_id,
              l_kln_rec.cc_auth_code,
              l_kln_rec.commitment_id,
              l_kln_rec.locked_price_list_id,
              l_kln_rec.usage_est_yn,
              l_kln_rec.usage_est_method,
              l_kln_rec.usage_est_start_date,
              l_kln_rec.termn_method,
              l_kln_rec.ubt_amount,
              l_kln_rec.credit_amount,
              l_kln_rec.suppressed_credit,
              l_kln_rec.override_amount,
              l_kln_rec.cust_po_number_req_yn,
              l_kln_rec.cust_po_number,
              l_kln_rec.grace_duration,
              l_kln_rec.grace_period,
              l_kln_rec.inv_print_flag,
              l_kln_rec.price_uom,
              l_kln_rec.tax_amount,
              l_kln_rec.tax_inclusive_yn,
              l_kln_rec.tax_status,
              l_kln_rec.tax_code,
              l_kln_rec.tax_exemption_id,
              l_kln_rec.ib_trans_type,
              l_kln_rec.ib_trans_date,
              l_kln_rec.prod_price,
              l_kln_rec.service_price,
              l_kln_rec.clvl_list_price,
              l_kln_rec.clvl_quantity,
              l_kln_rec.clvl_extended_amt,
              l_kln_rec.clvl_uom_code,
              l_kln_rec.toplvl_operand_code,
              l_kln_rec.toplvl_operand_val,
              l_kln_rec.toplvl_quantity,
              l_kln_rec.toplvl_uom_code,
              l_kln_rec.toplvl_adj_price,
              l_kln_rec.toplvl_price_qty,
              l_kln_rec.averaging_interval,
              l_kln_rec.settlement_interval,
              l_kln_rec.minimum_quantity,
              l_kln_rec.default_quantity,
              l_kln_rec.amcv_flag,
              l_kln_rec.fixed_quantity,
              l_kln_rec.usage_duration,
              l_kln_rec.usage_period,
              l_kln_rec.level_yn,
              l_kln_rec.usage_type,
              l_kln_rec.uom_quantified,
              l_kln_rec.base_reading,
              l_kln_rec.billing_schedule_type,
              l_kln_rec.full_credit,
              l_kln_rec.locked_price_list_line_id,
              l_kln_rec.break_uom,
              l_kln_rec.prorate,
              l_kln_rec.coverage_type,
              l_kln_rec.exception_cov_id,
              l_kln_rec.limit_uom_quantified,
              l_kln_rec.discount_amount,
              l_kln_rec.discount_percent,
              l_kln_rec.offset_duration,
              l_kln_rec.offset_period,
              l_kln_rec.incident_severity_id,
              l_kln_rec.pdf_id,
              l_kln_rec.work_thru_yn,
              l_kln_rec.react_active_yn,
              l_kln_rec.transfer_option,
              l_kln_rec.prod_upgrade_yn,
              l_kln_rec.inheritance_type,
              l_kln_rec.pm_program_id,
              l_kln_rec.pm_conf_req_yn,
              l_kln_rec.pm_sch_exists_yn,
              l_kln_rec.allow_bt_discount,
              l_kln_rec.apply_default_timezone,
              l_kln_rec.sync_date_install,
              l_kln_rec.object_version_number,
              l_kln_rec.request_id,
              l_kln_rec.created_by,
              l_kln_rec.creation_date,
              l_kln_rec.last_updated_by,
              l_kln_rec.last_update_date,
              l_kln_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
              l_kln_rec.trxn_extension_id,
              l_kln_rec.tax_classification_code,
              l_kln_rec.exempt_certificate_number,
              l_kln_rec.exempt_reason_code,
              l_kln_rec.coverage_id,
              l_kln_rec.standard_cov_yn,
              l_kln_rec.orig_system_id1,
              l_kln_rec.orig_system_reference1,
              l_kln_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
;
    x_no_data_found := oks_k_lines_b_pk_csr%NOTFOUND;
    CLOSE oks_k_lines_b_pk_csr;
    RETURN(l_kln_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_kln_rec                      IN kln_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN kln_rec_type IS
    l_kln_rec                      kln_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_kln_rec := get_rec(p_kln_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_kln_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_kln_rec                      IN kln_rec_type
  ) RETURN kln_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_kln_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_K_LINES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_klt_rec                      IN klt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN klt_rec_type IS
    CURSOR oks_k_lines_tl_pk_csr (p_id       IN NUMBER,
                                  p_language IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            INVOICE_TEXT,
            IB_TRX_DETAILS,
            STATUS_TEXT,
            REACT_TIME_NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Oks_K_Lines_Tl
     WHERE oks_k_lines_tl.id    = p_id
       AND oks_k_lines_tl.language = p_language;
    l_oks_k_lines_tl_pk            oks_k_lines_tl_pk_csr%ROWTYPE;
    l_klt_rec                      klt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_k_lines_tl_pk_csr (p_klt_rec.id,
                                p_klt_rec.language);
    FETCH oks_k_lines_tl_pk_csr INTO
              l_klt_rec.id,
              l_klt_rec.language,
              l_klt_rec.source_lang,
              l_klt_rec.sfwt_flag,
              l_klt_rec.invoice_text,
              l_klt_rec.ib_trx_details,
              l_klt_rec.status_text,
              l_klt_rec.react_time_name,
              l_klt_rec.created_by,
              l_klt_rec.creation_date,
              l_klt_rec.last_updated_by,
              l_klt_rec.last_update_date,
              l_klt_rec.last_update_login;
    x_no_data_found := oks_k_lines_tl_pk_csr%NOTFOUND;
    CLOSE oks_k_lines_tl_pk_csr;
    RETURN(l_klt_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_klt_rec                      IN klt_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN klt_rec_type IS
    l_klt_rec                      klt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_klt_rec := get_rec(p_klt_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_klt_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_klt_rec                      IN klt_rec_type
  ) RETURN klt_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_klt_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_K_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_klnv_rec   IN klnv_rec_type
  ) RETURN klnv_rec_type IS
    l_klnv_rec                     klnv_rec_type := p_klnv_rec;
  BEGIN
    IF (l_klnv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.id := NULL;
    END IF;
    IF (l_klnv_rec.cle_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.cle_id := NULL;
    END IF;
    IF (l_klnv_rec.dnz_chr_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_klnv_rec.discount_list = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.discount_list := NULL;
    END IF;
    IF (l_klnv_rec.acct_rule_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.acct_rule_id := NULL;
    END IF;
    IF (l_klnv_rec.payment_type = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.payment_type := NULL;
    END IF;
    IF (l_klnv_rec.cc_no = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.cc_no := NULL;
    END IF;
    IF (l_klnv_rec.cc_expiry_date = OKC_API.G_MISS_DATE ) THEN
      l_klnv_rec.cc_expiry_date := NULL;
    END IF;
    IF (l_klnv_rec.cc_bank_acct_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.cc_bank_acct_id := NULL;
    END IF;
    IF (l_klnv_rec.cc_auth_code = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.cc_auth_code := NULL;
    END IF;
    IF (l_klnv_rec.commitment_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.commitment_id := NULL;
    END IF;
    IF (l_klnv_rec.locked_price_list_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.locked_price_list_id := NULL;
    END IF;
    IF (l_klnv_rec.usage_est_yn = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.usage_est_yn := NULL;
    END IF;
    IF (l_klnv_rec.usage_est_method = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.usage_est_method := NULL;
    END IF;
    IF (l_klnv_rec.usage_est_start_date = OKC_API.G_MISS_DATE ) THEN
      l_klnv_rec.usage_est_start_date := NULL;
    END IF;
    IF (l_klnv_rec.termn_method = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.termn_method := NULL;
    END IF;
    IF (l_klnv_rec.ubt_amount = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.ubt_amount := NULL;
    END IF;
    IF (l_klnv_rec.credit_amount = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.credit_amount := NULL;
    END IF;
    IF (l_klnv_rec.suppressed_credit = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.suppressed_credit := NULL;
    END IF;
    IF (l_klnv_rec.override_amount = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.override_amount := NULL;
    END IF;
    IF (l_klnv_rec.cust_po_number_req_yn = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.cust_po_number_req_yn := NULL;
    END IF;
    IF (l_klnv_rec.cust_po_number = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.cust_po_number := NULL;
    END IF;
    IF (l_klnv_rec.grace_duration = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.grace_duration := NULL;
    END IF;
    IF (l_klnv_rec.grace_period = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.grace_period := NULL;
    END IF;
    IF (l_klnv_rec.inv_print_flag = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.inv_print_flag := NULL;
    END IF;
    IF (l_klnv_rec.price_uom = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.price_uom := NULL;
    END IF;
    IF (l_klnv_rec.tax_amount = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.tax_amount := NULL;
    END IF;
    IF (l_klnv_rec.tax_inclusive_yn = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.tax_inclusive_yn := NULL;
    END IF;
    IF (l_klnv_rec.tax_status = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.tax_status := NULL;
    END IF;
    IF (l_klnv_rec.tax_code = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.tax_code := NULL;
    END IF;
    IF (l_klnv_rec.tax_exemption_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.tax_exemption_id := NULL;
    END IF;
    IF (l_klnv_rec.ib_trans_type = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.ib_trans_type := NULL;
    END IF;
    IF (l_klnv_rec.ib_trans_date = OKC_API.G_MISS_DATE ) THEN
      l_klnv_rec.ib_trans_date := NULL;
    END IF;
    IF (l_klnv_rec.prod_price = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.prod_price := NULL;
    END IF;
    IF (l_klnv_rec.service_price = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.service_price := NULL;
    END IF;
    IF (l_klnv_rec.clvl_list_price = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.clvl_list_price := NULL;
    END IF;
    IF (l_klnv_rec.clvl_quantity = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.clvl_quantity := NULL;
    END IF;
    IF (l_klnv_rec.clvl_extended_amt = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.clvl_extended_amt := NULL;
    END IF;
    IF (l_klnv_rec.clvl_uom_code = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.clvl_uom_code := NULL;
    END IF;
    IF (l_klnv_rec.toplvl_operand_code = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.toplvl_operand_code := NULL;
    END IF;
    IF (l_klnv_rec.toplvl_operand_val = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.toplvl_operand_val := NULL;
    END IF;
    IF (l_klnv_rec.toplvl_quantity = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.toplvl_quantity := NULL;
    END IF;
    IF (l_klnv_rec.toplvl_uom_code = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.toplvl_uom_code := NULL;
    END IF;
    IF (l_klnv_rec.toplvl_adj_price = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.toplvl_adj_price := NULL;
    END IF;
    IF (l_klnv_rec.toplvl_price_qty = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.toplvl_price_qty := NULL;
    END IF;
    IF (l_klnv_rec.averaging_interval = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.averaging_interval := NULL;
    END IF;
    IF (l_klnv_rec.settlement_interval = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.settlement_interval := NULL;
    END IF;
    IF (l_klnv_rec.minimum_quantity = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.minimum_quantity := NULL;
    END IF;
    IF (l_klnv_rec.default_quantity = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.default_quantity := NULL;
    END IF;
    IF (l_klnv_rec.amcv_flag = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.amcv_flag := NULL;
    END IF;
    IF (l_klnv_rec.fixed_quantity = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.fixed_quantity := NULL;
    END IF;
    IF (l_klnv_rec.usage_duration = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.usage_duration := NULL;
    END IF;
    IF (l_klnv_rec.usage_period = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.usage_period := NULL;
    END IF;
    IF (l_klnv_rec.level_yn = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.level_yn := NULL;
    END IF;
    IF (l_klnv_rec.usage_type = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.usage_type := NULL;
    END IF;
    IF (l_klnv_rec.uom_quantified = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.uom_quantified := NULL;
    END IF;
    IF (l_klnv_rec.base_reading = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.base_reading := NULL;
    END IF;
    IF (l_klnv_rec.billing_schedule_type = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.billing_schedule_type := NULL;
    END IF;
    IF (l_klnv_rec.full_credit = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.full_credit := NULL;
    END IF;
    IF (l_klnv_rec.locked_price_list_line_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.locked_price_list_line_id := NULL;
    END IF;
    IF (l_klnv_rec.break_uom = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.break_uom := NULL;
    END IF;
    IF (l_klnv_rec.prorate = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.prorate := NULL;
    END IF;
    IF (l_klnv_rec.coverage_type = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.coverage_type := NULL;
    END IF;
    IF (l_klnv_rec.exception_cov_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.exception_cov_id := NULL;
    END IF;
    IF (l_klnv_rec.limit_uom_quantified = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.limit_uom_quantified := NULL;
    END IF;
    IF (l_klnv_rec.discount_amount = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.discount_amount := NULL;
    END IF;
    IF (l_klnv_rec.discount_percent = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.discount_percent := NULL;
    END IF;
    IF (l_klnv_rec.offset_duration = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.offset_duration := NULL;
    END IF;
    IF (l_klnv_rec.offset_period = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.offset_period := NULL;
    END IF;
    IF (l_klnv_rec.incident_severity_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.incident_severity_id := NULL;
    END IF;
    IF (l_klnv_rec.pdf_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.pdf_id := NULL;
    END IF;
    IF (l_klnv_rec.work_thru_yn = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.work_thru_yn := NULL;
    END IF;
    IF (l_klnv_rec.react_active_yn = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.react_active_yn := NULL;
    END IF;
    IF (l_klnv_rec.transfer_option = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.transfer_option := NULL;
    END IF;
    IF (l_klnv_rec.prod_upgrade_yn = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.prod_upgrade_yn := NULL;
    END IF;
    IF (l_klnv_rec.inheritance_type = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.inheritance_type := NULL;
    END IF;
    IF (l_klnv_rec.pm_program_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.pm_program_id := NULL;
    END IF;
    IF (l_klnv_rec.pm_conf_req_yn = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.pm_conf_req_yn := NULL;
    END IF;
    IF (l_klnv_rec.pm_sch_exists_yn = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.pm_sch_exists_yn := NULL;
    END IF;
    IF (l_klnv_rec.allow_bt_discount = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.allow_bt_discount := NULL;
    END IF;
    IF (l_klnv_rec.apply_default_timezone = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.apply_default_timezone := NULL;
    END IF;
    IF (l_klnv_rec.sync_date_install = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.sync_date_install := NULL;
    END IF;
    IF (l_klnv_rec.sfwt_flag = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_klnv_rec.invoice_text = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.invoice_text := NULL;
    END IF;
    IF (l_klnv_rec.ib_trx_details = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.ib_trx_details := NULL;
    END IF;
    IF (l_klnv_rec.status_text = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.status_text := NULL;
    END IF;
    IF (l_klnv_rec.react_time_name = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.react_time_name := NULL;
    END IF;
    IF (l_klnv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.object_version_number := NULL;
    END IF;
    IF (l_klnv_rec.security_group_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.security_group_id := NULL;
    END IF;
    IF (l_klnv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.request_id := NULL;
    END IF;
    IF (l_klnv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.created_by := NULL;
    END IF;
    IF (l_klnv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_klnv_rec.creation_date := NULL;
    END IF;
    IF (l_klnv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_klnv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_klnv_rec.last_update_date := NULL;
    END IF;
    IF (l_klnv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.last_update_login := NULL;
    END IF;
-- R12 Data Model Changes 4485150 Start

    IF (l_klnv_rec.trxn_extension_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.trxn_extension_id := NULL;
    END IF;
    IF (l_klnv_rec.tax_classification_code = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.tax_classification_code := NULL;
    END IF;
    IF (l_klnv_rec.exempt_certificate_number = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.exempt_certificate_number := NULL;
    END IF;
    IF (l_klnv_rec.exempt_reason_code = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.exempt_reason_code := NULL;
    END IF;

    IF (l_klnv_rec.coverage_id = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.coverage_id := NULL;
    END IF;
    IF (l_klnv_rec.standard_cov_yn = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.standard_cov_yn := NULL;
    END IF;
    IF (l_klnv_rec.orig_system_id1 = OKC_API.G_MISS_NUM ) THEN
      l_klnv_rec.orig_system_id1 := NULL;
    END IF;
    IF (l_klnv_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.orig_system_reference1 := NULL;
    END IF;
    IF (l_klnv_rec.orig_system_source_code = OKC_API.G_MISS_CHAR ) THEN
      l_klnv_rec.orig_system_source_code := NULL;
    END IF;
-- R12 Data Model Changes 4485150 End
    RETURN(l_klnv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
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
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  -------------------------------------
  -- Validate_Attributes for: CLE_ID --
  -------------------------------------
  PROCEDURE validate_cle_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cle_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cle_id = OKC_API.G_MISS_NUM OR
        p_cle_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'cle_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_cle_id;
  -----------------------------------------
  -- Validate_Attributes for: DNZ_CHR_ID --
  -----------------------------------------
  PROCEDURE validate_dnz_chr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_dnz_chr_id                   IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_dnz_chr_id = OKC_API.G_MISS_NUM OR
        p_dnz_chr_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'dnz_chr_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_dnz_chr_id;
  ----------------------------------------
  -- Validate_Attributes for: SFWT_FLAG --
  ----------------------------------------
  PROCEDURE validate_sfwt_flag(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sfwt_flag                    IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_sfwt_flag = OKC_API.G_MISS_CHAR OR
        p_sfwt_flag IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sfwt_flag');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_sfwt_flag;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
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
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Attributes for:OKS_K_LINES_V --
  -------------------------------------------
  FUNCTION Validate_Attributes (
    p_klnv_rec                     IN klnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_klnv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- cle_id
    -- ***
    validate_cle_id(x_return_status, p_klnv_rec.cle_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- dnz_chr_id
    -- ***
    validate_dnz_chr_id(x_return_status, p_klnv_rec.dnz_chr_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(x_return_status, p_klnv_rec.sfwt_flag);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_klnv_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- Validate Record for:OKS_K_LINES_V --
  ---------------------------------------
  FUNCTION Validate_Record (
    p_klnv_rec IN klnv_rec_type,
    p_db_klnv_rec IN klnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_klnv_rec IN klnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_klnv_rec                  klnv_rec_type := get_rec(p_klnv_rec);
  BEGIN
    l_return_status := Validate_Record(p_klnv_rec => p_klnv_rec,
                                       p_db_klnv_rec => l_db_klnv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN klnv_rec_type,
    p_to   IN OUT NOCOPY kln_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.discount_list := p_from.discount_list;
    p_to.acct_rule_id := p_from.acct_rule_id;
    p_to.payment_type := p_from.payment_type;
    p_to.cc_no := p_from.cc_no;
    p_to.cc_expiry_date := p_from.cc_expiry_date;
    p_to.cc_bank_acct_id := p_from.cc_bank_acct_id;
    p_to.cc_auth_code := p_from.cc_auth_code;
    p_to.commitment_id := p_from.commitment_id;
    p_to.locked_price_list_id := p_from.locked_price_list_id;
    p_to.usage_est_yn := p_from.usage_est_yn;
    p_to.usage_est_method := p_from.usage_est_method;
    p_to.usage_est_start_date := p_from.usage_est_start_date;
    p_to.termn_method := p_from.termn_method;
    p_to.ubt_amount := p_from.ubt_amount;
    p_to.credit_amount := p_from.credit_amount;
    p_to.suppressed_credit := p_from.suppressed_credit;
    p_to.override_amount := p_from.override_amount;
    p_to.cust_po_number_req_yn := p_from.cust_po_number_req_yn;
    p_to.cust_po_number := p_from.cust_po_number;
    p_to.grace_duration := p_from.grace_duration;
    p_to.grace_period := p_from.grace_period;
    p_to.inv_print_flag := p_from.inv_print_flag;
    p_to.price_uom := p_from.price_uom;
    p_to.tax_amount := p_from.tax_amount;
    p_to.tax_inclusive_yn := p_from.tax_inclusive_yn;
    p_to.tax_status := p_from.tax_status;
    p_to.tax_code := p_from.tax_code;
    p_to.tax_exemption_id := p_from.tax_exemption_id;
    p_to.ib_trans_type := p_from.ib_trans_type;
    p_to.ib_trans_date := p_from.ib_trans_date;
    p_to.prod_price := p_from.prod_price;
    p_to.service_price := p_from.service_price;
    p_to.clvl_list_price := p_from.clvl_list_price;
    p_to.clvl_quantity := p_from.clvl_quantity;
    p_to.clvl_extended_amt := p_from.clvl_extended_amt;
    p_to.clvl_uom_code := p_from.clvl_uom_code;
    p_to.toplvl_operand_code := p_from.toplvl_operand_code;
    p_to.toplvl_operand_val := p_from.toplvl_operand_val;
    p_to.toplvl_quantity := p_from.toplvl_quantity;
    p_to.toplvl_uom_code := p_from.toplvl_uom_code;
    p_to.toplvl_adj_price := p_from.toplvl_adj_price;
    p_to.toplvl_price_qty := p_from.toplvl_price_qty;
    p_to.averaging_interval := p_from.averaging_interval;
    p_to.settlement_interval := p_from.settlement_interval;
    p_to.minimum_quantity := p_from.minimum_quantity;
    p_to.default_quantity := p_from.default_quantity;
    p_to.amcv_flag := p_from.amcv_flag;
    p_to.fixed_quantity := p_from.fixed_quantity;
    p_to.usage_duration := p_from.usage_duration;
    p_to.usage_period := p_from.usage_period;
    p_to.level_yn := p_from.level_yn;
    p_to.usage_type := p_from.usage_type;
    p_to.uom_quantified := p_from.uom_quantified;
    p_to.base_reading := p_from.base_reading;
    p_to.billing_schedule_type := p_from.billing_schedule_type;
    p_to.full_credit := p_from.full_credit;
    p_to.locked_price_list_line_id := p_from.locked_price_list_line_id;
    p_to.break_uom := p_from.break_uom;
    p_to.prorate := p_from.prorate;
    p_to.coverage_type := p_from.coverage_type;
    p_to.exception_cov_id := p_from.exception_cov_id;
    p_to.limit_uom_quantified := p_from.limit_uom_quantified;
    p_to.discount_amount := p_from.discount_amount;
    p_to.discount_percent := p_from.discount_percent;
    p_to.offset_duration := p_from.offset_duration;
    p_to.offset_period := p_from.offset_period;
    p_to.incident_severity_id := p_from.incident_severity_id;
    p_to.pdf_id := p_from.pdf_id;
    p_to.work_thru_yn := p_from.work_thru_yn;
    p_to.react_active_yn := p_from.react_active_yn;
    p_to.transfer_option := p_from.transfer_option;
    p_to.prod_upgrade_yn := p_from.prod_upgrade_yn;
    p_to.inheritance_type := p_from.inheritance_type;
    p_to.pm_program_id := p_from.pm_program_id;
    p_to.pm_conf_req_yn := p_from.pm_conf_req_yn;
    p_to.pm_sch_exists_yn := p_from.pm_sch_exists_yn;
    p_to.allow_bt_discount := p_from.allow_bt_discount;
    p_to.apply_default_timezone := p_from.apply_default_timezone;
    p_to.sync_date_install := p_from.sync_date_install;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
-- R12 Data Model Changes 4485150 Start
    p_to.trxn_extension_id             := p_from.trxn_extension_id   ;
    p_to.tax_classification_code       := p_from.tax_classification_code;
    p_to.exempt_certificate_number     := p_from.exempt_certificate_number;
    p_to.exempt_reason_code            := p_from.exempt_reason_code;

    p_to.coverage_id                    := p_from.coverage_id;
    p_to.standard_cov_yn                := p_from.standard_cov_yn;
    p_to.orig_system_id1                := p_from.orig_system_id1;
    p_to.orig_system_reference1         := p_from.orig_system_reference1;
    p_to.orig_system_source_code        := p_from.orig_system_source_code;
-- R12 Data Model Changes 4485150 End

  END migrate;
  PROCEDURE migrate (
    p_from IN kln_rec_type,
    p_to   IN OUT NOCOPY klnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.discount_list := p_from.discount_list;
    p_to.acct_rule_id := p_from.acct_rule_id;
    p_to.payment_type := p_from.payment_type;
    p_to.cc_no := p_from.cc_no;
    p_to.cc_expiry_date := p_from.cc_expiry_date;
    p_to.cc_bank_acct_id := p_from.cc_bank_acct_id;
    p_to.cc_auth_code := p_from.cc_auth_code;
    p_to.commitment_id := p_from.commitment_id;
    p_to.locked_price_list_id := p_from.locked_price_list_id;
    p_to.usage_est_yn := p_from.usage_est_yn;
    p_to.usage_est_method := p_from.usage_est_method;
    p_to.usage_est_start_date := p_from.usage_est_start_date;
    p_to.termn_method := p_from.termn_method;
    p_to.ubt_amount := p_from.ubt_amount;
    p_to.credit_amount := p_from.credit_amount;
    p_to.suppressed_credit := p_from.suppressed_credit;
    p_to.override_amount := p_from.override_amount;
    p_to.cust_po_number_req_yn := p_from.cust_po_number_req_yn;
    p_to.cust_po_number := p_from.cust_po_number;
    p_to.grace_duration := p_from.grace_duration;
    p_to.grace_period := p_from.grace_period;
    p_to.inv_print_flag := p_from.inv_print_flag;
    p_to.price_uom := p_from.price_uom;
    p_to.tax_amount := p_from.tax_amount;
    p_to.tax_inclusive_yn := p_from.tax_inclusive_yn;
    p_to.tax_status := p_from.tax_status;
    p_to.tax_code := p_from.tax_code;
    p_to.tax_exemption_id := p_from.tax_exemption_id;
    p_to.ib_trans_type := p_from.ib_trans_type;
    p_to.ib_trans_date := p_from.ib_trans_date;
    p_to.prod_price := p_from.prod_price;
    p_to.service_price := p_from.service_price;
    p_to.clvl_list_price := p_from.clvl_list_price;
    p_to.clvl_quantity := p_from.clvl_quantity;
    p_to.clvl_extended_amt := p_from.clvl_extended_amt;
    p_to.clvl_uom_code := p_from.clvl_uom_code;
    p_to.toplvl_operand_code := p_from.toplvl_operand_code;
    p_to.toplvl_operand_val := p_from.toplvl_operand_val;
    p_to.toplvl_quantity := p_from.toplvl_quantity;
    p_to.toplvl_uom_code := p_from.toplvl_uom_code;
    p_to.toplvl_adj_price := p_from.toplvl_adj_price;
    p_to.toplvl_price_qty := p_from.toplvl_price_qty;
    p_to.averaging_interval := p_from.averaging_interval;
    p_to.settlement_interval := p_from.settlement_interval;
    p_to.minimum_quantity := p_from.minimum_quantity;
    p_to.default_quantity := p_from.default_quantity;
    p_to.amcv_flag := p_from.amcv_flag;
    p_to.fixed_quantity := p_from.fixed_quantity;
    p_to.usage_duration := p_from.usage_duration;
    p_to.usage_period := p_from.usage_period;
    p_to.level_yn := p_from.level_yn;
    p_to.usage_type := p_from.usage_type;
    p_to.uom_quantified := p_from.uom_quantified;
    p_to.base_reading := p_from.base_reading;
    p_to.billing_schedule_type := p_from.billing_schedule_type;
    p_to.full_credit := p_from.full_credit;
    p_to.locked_price_list_line_id := p_from.locked_price_list_line_id;
    p_to.break_uom := p_from.break_uom;
    p_to.prorate := p_from.prorate;
    p_to.coverage_type := p_from.coverage_type;
    p_to.exception_cov_id := p_from.exception_cov_id;
    p_to.limit_uom_quantified := p_from.limit_uom_quantified;
    p_to.discount_amount := p_from.discount_amount;
    p_to.discount_percent := p_from.discount_percent;
    p_to.offset_duration := p_from.offset_duration;
    p_to.offset_period := p_from.offset_period;
    p_to.incident_severity_id := p_from.incident_severity_id;
    p_to.pdf_id := p_from.pdf_id;
    p_to.work_thru_yn := p_from.work_thru_yn;
    p_to.react_active_yn := p_from.react_active_yn;
    p_to.transfer_option := p_from.transfer_option;
    p_to.prod_upgrade_yn := p_from.prod_upgrade_yn;
    p_to.inheritance_type := p_from.inheritance_type;
    p_to.pm_program_id := p_from.pm_program_id;
    p_to.pm_conf_req_yn := p_from.pm_conf_req_yn;
    p_to.pm_sch_exists_yn := p_from.pm_sch_exists_yn;
    p_to.allow_bt_discount := p_from.allow_bt_discount;
    p_to.apply_default_timezone := p_from.apply_default_timezone;
    p_to.sync_date_install := p_from.sync_date_install;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
-- R12 Data Model Changes 4485150 Start
    p_to.trxn_extension_id             := p_from.trxn_extension_id   ;
    p_to.tax_classification_code       := p_from.tax_classification_code;
    p_to.exempt_certificate_number     := p_from.exempt_certificate_number;
    p_to.exempt_reason_code            := p_from.exempt_reason_code;

    p_to.coverage_id                    := p_from.coverage_id;
    p_to.standard_cov_yn                := p_from.standard_cov_yn;
    p_to.orig_system_id1                := p_from.orig_system_id1;
    p_to.orig_system_reference1         := p_from.orig_system_reference1;
    p_to.orig_system_source_code        := p_from.orig_system_source_code;
-- R12 Data Model Changes 4485150 End
  END migrate;
  PROCEDURE migrate (
    p_from IN klnv_rec_type,
    p_to   IN OUT NOCOPY klt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.invoice_text := p_from.invoice_text;
    p_to.ib_trx_details := p_from.ib_trx_details;
    p_to.status_text := p_from.status_text;
    p_to.react_time_name := p_from.react_time_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN klt_rec_type,
    p_to   IN OUT NOCOPY klnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.invoice_text := p_from.invoice_text;
    p_to.ib_trx_details := p_from.ib_trx_details;
    p_to.status_text := p_from.status_text;
    p_to.react_time_name := p_from.react_time_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- validate_row for:OKS_K_LINES_V --
  ------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klnv_rec                     klnv_rec_type := p_klnv_rec;
    l_kln_rec                      kln_rec_type;
    l_klt_rec                      klt_rec_type;
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
    l_return_status := Validate_Attributes(l_klnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_klnv_rec);
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
  -----------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_K_LINES_V --
  -----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klnv_tbl.COUNT > 0) THEN
      i := p_klnv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_klnv_rec                     => p_klnv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_klnv_tbl.LAST);
        i := p_klnv_tbl.NEXT(i);
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

  -----------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_K_LINES_V --
  -----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klnv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_klnv_tbl                     => p_klnv_tbl,
        px_error_tbl                   => l_error_tbl);
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
  ----------------------------------
  -- insert_row for:OKS_K_LINES_B --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_kln_rec                      IN kln_rec_type,
    x_kln_rec                      OUT NOCOPY kln_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_kln_rec                      kln_rec_type := p_kln_rec;
    l_def_kln_rec                  kln_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKS_K_LINES_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_kln_rec IN kln_rec_type,
      x_kln_rec OUT NOCOPY kln_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_kln_rec := p_kln_rec;
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
      p_kln_rec,                         -- IN
      l_kln_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_K_LINES_B(
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
      price_uom,
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
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
-- R12 Data Model Changes 4485150 Start
      trxn_extension_id,
      tax_classification_code,
      exempt_certificate_number,
      exempt_reason_code,
      coverage_id,
      standard_cov_yn,
      orig_system_id1,
      orig_system_reference1,
      orig_system_source_code
-- R12 Data Model Changes 4485150 End
)
    VALUES (
      l_kln_rec.id,
      l_kln_rec.cle_id,
      l_kln_rec.dnz_chr_id,
      l_kln_rec.discount_list,
      l_kln_rec.acct_rule_id,
      l_kln_rec.payment_type,
      l_kln_rec.cc_no,
      l_kln_rec.cc_expiry_date,
      l_kln_rec.cc_bank_acct_id,
      l_kln_rec.cc_auth_code,
      l_kln_rec.commitment_id,
      l_kln_rec.locked_price_list_id,
      l_kln_rec.usage_est_yn,
      l_kln_rec.usage_est_method,
      l_kln_rec.usage_est_start_date,
      l_kln_rec.termn_method,
      l_kln_rec.ubt_amount,
      l_kln_rec.credit_amount,
      l_kln_rec.suppressed_credit,
      l_kln_rec.override_amount,
      l_kln_rec.cust_po_number_req_yn,
      l_kln_rec.cust_po_number,
      l_kln_rec.grace_duration,
      l_kln_rec.grace_period,
      l_kln_rec.inv_print_flag,
      l_kln_rec.price_uom,
      l_kln_rec.tax_amount,
      l_kln_rec.tax_inclusive_yn,
      l_kln_rec.tax_status,
      l_kln_rec.tax_code,
      l_kln_rec.tax_exemption_id,
      l_kln_rec.ib_trans_type,
      l_kln_rec.ib_trans_date,
      l_kln_rec.prod_price,
      l_kln_rec.service_price,
      l_kln_rec.clvl_list_price,
      l_kln_rec.clvl_quantity,
      l_kln_rec.clvl_extended_amt,
      l_kln_rec.clvl_uom_code,
      l_kln_rec.toplvl_operand_code,
      l_kln_rec.toplvl_operand_val,
      l_kln_rec.toplvl_quantity,
      l_kln_rec.toplvl_uom_code,
      l_kln_rec.toplvl_adj_price,
      l_kln_rec.toplvl_price_qty,
      l_kln_rec.averaging_interval,
      l_kln_rec.settlement_interval,
      l_kln_rec.minimum_quantity,
      l_kln_rec.default_quantity,
      l_kln_rec.amcv_flag,
      l_kln_rec.fixed_quantity,
      l_kln_rec.usage_duration,
      l_kln_rec.usage_period,
      l_kln_rec.level_yn,
      l_kln_rec.usage_type,
      l_kln_rec.uom_quantified,
      l_kln_rec.base_reading,
      l_kln_rec.billing_schedule_type,
      l_kln_rec.full_credit,
      l_kln_rec.locked_price_list_line_id,
      l_kln_rec.break_uom,
      l_kln_rec.prorate,
      l_kln_rec.coverage_type,
      l_kln_rec.exception_cov_id,
      l_kln_rec.limit_uom_quantified,
      l_kln_rec.discount_amount,
      l_kln_rec.discount_percent,
      l_kln_rec.offset_duration,
      l_kln_rec.offset_period,
      l_kln_rec.incident_severity_id,
      l_kln_rec.pdf_id,
      l_kln_rec.work_thru_yn,
      l_kln_rec.react_active_yn,
      l_kln_rec.transfer_option,
      l_kln_rec.prod_upgrade_yn,
      l_kln_rec.inheritance_type,
      l_kln_rec.pm_program_id,
      l_kln_rec.pm_conf_req_yn,
      l_kln_rec.pm_sch_exists_yn,
      l_kln_rec.allow_bt_discount,
      l_kln_rec.apply_default_timezone,
      l_kln_rec.sync_date_install,
      l_kln_rec.object_version_number,
      l_kln_rec.request_id,
      l_kln_rec.created_by,
      l_kln_rec.creation_date,
      l_kln_rec.last_updated_by,
      l_kln_rec.last_update_date,
      l_kln_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
      l_kln_rec.trxn_extension_id,
      l_kln_rec.tax_classification_code,
      l_kln_rec.exempt_certificate_number,
      l_kln_rec.exempt_reason_code,
      l_kln_rec.coverage_id,
      l_kln_rec.standard_cov_yn,
      l_kln_rec.orig_system_id1,
      l_kln_rec.orig_system_reference1,
      l_kln_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
);
    -- Set OUT values
    x_kln_rec := l_kln_rec;
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
  -----------------------------------
  -- insert_row for:OKS_K_LINES_TL --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klt_rec                      IN klt_rec_type,
    x_klt_rec                      OUT NOCOPY klt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klt_rec                      klt_rec_type := p_klt_rec;
    l_def_klt_rec                  klt_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------
    -- Set_Attributes for:OKS_K_LINES_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_klt_rec IN klt_rec_type,
      x_klt_rec OUT NOCOPY klt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_klt_rec := p_klt_rec;
      x_klt_rec.LANGUAGE := USERENV('LANG');
      x_klt_rec.SOURCE_LANG := USERENV('LANG');
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
      p_klt_rec,                         -- IN
      l_klt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_klt_rec.language := l_lang_rec.language_code;
      INSERT INTO OKS_K_LINES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        invoice_text,
        ib_trx_details,
        status_text,
        react_time_name,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_klt_rec.id,
        l_klt_rec.language,
        l_klt_rec.source_lang,
        l_klt_rec.sfwt_flag,
        l_klt_rec.invoice_text,
        l_klt_rec.ib_trx_details,
        l_klt_rec.status_text,
        l_klt_rec.react_time_name,
        l_klt_rec.created_by,
        l_klt_rec.creation_date,
        l_klt_rec.last_updated_by,
        l_klt_rec.last_update_date,
        l_klt_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_klt_rec := l_klt_rec;
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
  -----------------------------------
  -- insert_row for :OKS_K_LINES_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type,
    x_klnv_rec                     OUT NOCOPY klnv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klnv_rec                     klnv_rec_type := p_klnv_rec;
    l_def_klnv_rec                 klnv_rec_type;
    l_kln_rec                      kln_rec_type;
    lx_kln_rec                     kln_rec_type;
    l_klt_rec                      klt_rec_type;
    lx_klt_rec                     klt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_klnv_rec IN klnv_rec_type
    ) RETURN klnv_rec_type IS
      l_klnv_rec klnv_rec_type := p_klnv_rec;
    BEGIN
      l_klnv_rec.CREATION_DATE := SYSDATE;
      l_klnv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_klnv_rec.LAST_UPDATE_DATE := l_klnv_rec.CREATION_DATE;
      l_klnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_klnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_klnv_rec);
    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKS_K_LINES_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_klnv_rec IN klnv_rec_type,
      x_klnv_rec OUT NOCOPY klnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_klnv_rec := p_klnv_rec;
      x_klnv_rec.OBJECT_VERSION_NUMBER := 1;
      x_klnv_rec.SFWT_FLAG := 'N';
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
    l_klnv_rec := null_out_defaults(p_klnv_rec);
    -- Set primary key value
    l_klnv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_klnv_rec,                        -- IN
      l_def_klnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_klnv_rec := fill_who_columns(l_def_klnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_klnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_klnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_klnv_rec, l_kln_rec);
    migrate(l_def_klnv_rec, l_klt_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_kln_rec,
      lx_kln_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_kln_rec, l_def_klnv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_klt_rec,
      lx_klt_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_klt_rec, l_def_klnv_rec);
    -- Set OUT values
    x_klnv_rec := l_def_klnv_rec;
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
  -- PL/SQL TBL insert_row for:KLNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klnv_tbl.COUNT > 0) THEN
      i := p_klnv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_klnv_rec                     => p_klnv_tbl(i),
            x_klnv_rec                     => x_klnv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_klnv_tbl.LAST);
        i := p_klnv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:KLNV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klnv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_klnv_tbl                     => p_klnv_tbl,
        x_klnv_tbl                     => x_klnv_tbl,
        px_error_tbl                   => l_error_tbl);
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
  --------------------------------
  -- lock_row for:OKS_K_LINES_B --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_kln_rec                      IN kln_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_kln_rec IN kln_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_K_LINES_B
     WHERE ID = p_kln_rec.id
       AND OBJECT_VERSION_NUMBER = p_kln_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_kln_rec IN kln_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_K_LINES_B
     WHERE ID = p_kln_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_K_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_K_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
      OPEN lock_csr(p_kln_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_kln_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_kln_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_kln_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
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
  ---------------------------------
  -- lock_row for:OKS_K_LINES_TL --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klt_rec                      IN klt_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_klt_rec IN klt_rec_type) IS
    SELECT *
      FROM OKS_K_LINES_TL
     WHERE ID = p_klt_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
      OPEN lock_csr(p_klt_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
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
  ---------------------------------
  -- lock_row for: OKS_K_LINES_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_kln_rec                      kln_rec_type;
    l_klt_rec                      klt_rec_type;
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
    migrate(p_klnv_rec, l_kln_rec);
    migrate(p_klnv_rec, l_klt_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_kln_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_klt_rec
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
  -- PL/SQL TBL lock_row for:KLNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_klnv_tbl.COUNT > 0) THEN
      i := p_klnv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_klnv_rec                     => p_klnv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_klnv_tbl.LAST);
        i := p_klnv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:KLNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    x_return_status := l_return_status;
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_klnv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_klnv_tbl                     => p_klnv_tbl,
        px_error_tbl                   => l_error_tbl);
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
  ----------------------------------
  -- update_row for:OKS_K_LINES_B --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_kln_rec                      IN kln_rec_type,
    x_kln_rec                      OUT NOCOPY kln_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_kln_rec                      kln_rec_type := p_kln_rec;
    l_def_kln_rec                  kln_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_credit_card_changed VARCHAR2(1) := 'N';
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_kln_rec IN kln_rec_type,
      x_kln_rec OUT NOCOPY kln_rec_type,
      x_credit_card_changed OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2 IS
      l_kln_rec                      kln_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_kln_rec := p_kln_rec;
      -- Get current database values
      l_kln_rec := get_rec(p_kln_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_kln_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.id := l_kln_rec.id;
        END IF;
        IF (x_kln_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.cle_id := l_kln_rec.cle_id;
        END IF;
        IF (x_kln_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.dnz_chr_id := l_kln_rec.dnz_chr_id;
        END IF;
        IF (x_kln_rec.discount_list = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.discount_list := l_kln_rec.discount_list;
        END IF;
        IF (x_kln_rec.acct_rule_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.acct_rule_id := l_kln_rec.acct_rule_id;
        END IF;
        IF (x_kln_rec.payment_type = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.payment_type := l_kln_rec.payment_type;
        END IF;
        IF (x_kln_rec.cc_no = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.cc_no := l_kln_rec.cc_no;
        END IF;
        IF (x_kln_rec.cc_expiry_date = OKC_API.G_MISS_DATE)
        THEN
          x_kln_rec.cc_expiry_date := l_kln_rec.cc_expiry_date;
        END IF;
        IF (x_kln_rec.cc_bank_acct_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.cc_bank_acct_id := l_kln_rec.cc_bank_acct_id;
        END IF;
        IF (x_kln_rec.cc_auth_code = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.cc_auth_code := l_kln_rec.cc_auth_code;
        END IF;
        IF (x_kln_rec.commitment_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.commitment_id := l_kln_rec.commitment_id;
        END IF;
        IF (x_kln_rec.locked_price_list_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.locked_price_list_id := l_kln_rec.locked_price_list_id;
        END IF;
        IF (x_kln_rec.usage_est_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.usage_est_yn := l_kln_rec.usage_est_yn;
        END IF;
        IF (x_kln_rec.usage_est_method = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.usage_est_method := l_kln_rec.usage_est_method;
        END IF;
        IF (x_kln_rec.usage_est_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_kln_rec.usage_est_start_date := l_kln_rec.usage_est_start_date;
        END IF;
        IF (x_kln_rec.termn_method = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.termn_method := l_kln_rec.termn_method;
        END IF;
        IF (x_kln_rec.ubt_amount = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.ubt_amount := l_kln_rec.ubt_amount;
        END IF;
        IF (x_kln_rec.credit_amount = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.credit_amount := l_kln_rec.credit_amount;
        END IF;
        IF (x_kln_rec.suppressed_credit = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.suppressed_credit := l_kln_rec.suppressed_credit;
        END IF;
        IF (x_kln_rec.override_amount = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.override_amount := l_kln_rec.override_amount;
        END IF;
        IF (x_kln_rec.cust_po_number_req_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.cust_po_number_req_yn := l_kln_rec.cust_po_number_req_yn;
        END IF;
        IF (x_kln_rec.cust_po_number = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.cust_po_number := l_kln_rec.cust_po_number;
        END IF;
        IF (x_kln_rec.grace_duration = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.grace_duration := l_kln_rec.grace_duration;
        END IF;
        IF (x_kln_rec.grace_period = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.grace_period := l_kln_rec.grace_period;
        END IF;
        IF (x_kln_rec.inv_print_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.inv_print_flag := l_kln_rec.inv_print_flag;
        END IF;
        IF (x_kln_rec.price_uom = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.price_uom := l_kln_rec.price_uom;
        END IF;
        IF (x_kln_rec.tax_amount = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.tax_amount := l_kln_rec.tax_amount;
        END IF;
        IF (x_kln_rec.tax_inclusive_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.tax_inclusive_yn := l_kln_rec.tax_inclusive_yn;
        END IF;
        IF (x_kln_rec.tax_status = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.tax_status := l_kln_rec.tax_status;
        END IF;
        IF (x_kln_rec.tax_code = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.tax_code := l_kln_rec.tax_code;
        END IF;
        IF (x_kln_rec.tax_exemption_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.tax_exemption_id := l_kln_rec.tax_exemption_id;
        END IF;
        IF (x_kln_rec.ib_trans_type = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.ib_trans_type := l_kln_rec.ib_trans_type;
        END IF;
        IF (x_kln_rec.ib_trans_date = OKC_API.G_MISS_DATE)
        THEN
          x_kln_rec.ib_trans_date := l_kln_rec.ib_trans_date;
        END IF;
        IF (x_kln_rec.prod_price = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.prod_price := l_kln_rec.prod_price;
        END IF;
        IF (x_kln_rec.service_price = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.service_price := l_kln_rec.service_price;
        END IF;
        IF (x_kln_rec.clvl_list_price = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.clvl_list_price := l_kln_rec.clvl_list_price;
        END IF;
        IF (x_kln_rec.clvl_quantity = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.clvl_quantity := l_kln_rec.clvl_quantity;
        END IF;
        IF (x_kln_rec.clvl_extended_amt = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.clvl_extended_amt := l_kln_rec.clvl_extended_amt;
        END IF;
        IF (x_kln_rec.clvl_uom_code = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.clvl_uom_code := l_kln_rec.clvl_uom_code;
        END IF;
        IF (x_kln_rec.toplvl_operand_code = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.toplvl_operand_code := l_kln_rec.toplvl_operand_code;
        END IF;
        IF (x_kln_rec.toplvl_operand_val = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.toplvl_operand_val := l_kln_rec.toplvl_operand_val;
        END IF;
        IF (x_kln_rec.toplvl_quantity = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.toplvl_quantity := l_kln_rec.toplvl_quantity;
        END IF;
        IF (x_kln_rec.toplvl_uom_code = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.toplvl_uom_code := l_kln_rec.toplvl_uom_code;
        END IF;
        IF (x_kln_rec.toplvl_adj_price = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.toplvl_adj_price := l_kln_rec.toplvl_adj_price;
        END IF;
        IF (x_kln_rec.toplvl_price_qty = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.toplvl_price_qty := l_kln_rec.toplvl_price_qty;
        END IF;
        IF (x_kln_rec.averaging_interval = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.averaging_interval := l_kln_rec.averaging_interval;
        END IF;
        IF (x_kln_rec.settlement_interval = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.settlement_interval := l_kln_rec.settlement_interval;
        END IF;
        IF (x_kln_rec.minimum_quantity = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.minimum_quantity := l_kln_rec.minimum_quantity;
        END IF;
        IF (x_kln_rec.default_quantity = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.default_quantity := l_kln_rec.default_quantity;
        END IF;
        IF (x_kln_rec.amcv_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.amcv_flag := l_kln_rec.amcv_flag;
        END IF;
        IF (x_kln_rec.fixed_quantity = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.fixed_quantity := l_kln_rec.fixed_quantity;
        END IF;
        IF (x_kln_rec.usage_duration = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.usage_duration := l_kln_rec.usage_duration;
        END IF;
        IF (x_kln_rec.usage_period = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.usage_period := l_kln_rec.usage_period;
        END IF;
        IF (x_kln_rec.level_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.level_yn := l_kln_rec.level_yn;
        END IF;
        IF (x_kln_rec.usage_type = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.usage_type := l_kln_rec.usage_type;
        END IF;
        IF (x_kln_rec.uom_quantified = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.uom_quantified := l_kln_rec.uom_quantified;
        END IF;
        IF (x_kln_rec.base_reading = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.base_reading := l_kln_rec.base_reading;
        END IF;
        IF (x_kln_rec.billing_schedule_type = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.billing_schedule_type := l_kln_rec.billing_schedule_type;
        END IF;
        IF (x_kln_rec.full_credit = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.full_credit := l_kln_rec.full_credit;
        END IF;
        IF (x_kln_rec.locked_price_list_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.locked_price_list_line_id := l_kln_rec.locked_price_list_line_id;
        END IF;
        IF (x_kln_rec.break_uom = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.break_uom := l_kln_rec.break_uom;
        END IF;
        IF (x_kln_rec.prorate = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.prorate := l_kln_rec.prorate;
        END IF;
        IF (x_kln_rec.coverage_type = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.coverage_type := l_kln_rec.coverage_type;
        END IF;
        IF (x_kln_rec.exception_cov_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.exception_cov_id := l_kln_rec.exception_cov_id;
        END IF;
        IF (x_kln_rec.limit_uom_quantified = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.limit_uom_quantified := l_kln_rec.limit_uom_quantified;
        END IF;
        IF (x_kln_rec.discount_amount = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.discount_amount := l_kln_rec.discount_amount;
        END IF;
        IF (x_kln_rec.discount_percent = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.discount_percent := l_kln_rec.discount_percent;
        END IF;
        IF (x_kln_rec.offset_duration = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.offset_duration := l_kln_rec.offset_duration;
        END IF;
        IF (x_kln_rec.offset_period = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.offset_period := l_kln_rec.offset_period;
        END IF;
        IF (x_kln_rec.incident_severity_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.incident_severity_id := l_kln_rec.incident_severity_id;
        END IF;
        IF (x_kln_rec.pdf_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.pdf_id := l_kln_rec.pdf_id;
        END IF;
        IF (x_kln_rec.work_thru_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.work_thru_yn := l_kln_rec.work_thru_yn;
        END IF;
        IF (x_kln_rec.react_active_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.react_active_yn := l_kln_rec.react_active_yn;
        END IF;
        IF (x_kln_rec.transfer_option = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.transfer_option := l_kln_rec.transfer_option;
        END IF;
        IF (x_kln_rec.prod_upgrade_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.prod_upgrade_yn := l_kln_rec.prod_upgrade_yn;
        END IF;
        IF (x_kln_rec.inheritance_type = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.inheritance_type := l_kln_rec.inheritance_type;
        END IF;
        IF (x_kln_rec.pm_program_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.pm_program_id := l_kln_rec.pm_program_id;
        END IF;
        IF (x_kln_rec.pm_conf_req_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.pm_conf_req_yn := l_kln_rec.pm_conf_req_yn;
        END IF;
        IF (x_kln_rec.pm_sch_exists_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.pm_sch_exists_yn := l_kln_rec.pm_sch_exists_yn;
        END IF;
        IF (x_kln_rec.allow_bt_discount = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.allow_bt_discount := l_kln_rec.allow_bt_discount;
        END IF;
        IF (x_kln_rec.apply_default_timezone = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.apply_default_timezone := l_kln_rec.apply_default_timezone;
        END IF;
        IF (x_kln_rec.sync_date_install = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.sync_date_install := l_kln_rec.sync_date_install;
        END IF;
        IF (x_kln_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.object_version_number := l_kln_rec.object_version_number;
        END IF;
        IF (x_kln_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.request_id := l_kln_rec.request_id;
        END IF;
        IF (x_kln_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.created_by := l_kln_rec.created_by;
        END IF;
        IF (x_kln_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_kln_rec.creation_date := l_kln_rec.creation_date;
        END IF;
        IF (x_kln_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.last_updated_by := l_kln_rec.last_updated_by;
        END IF;
        IF (x_kln_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_kln_rec.last_update_date := l_kln_rec.last_update_date;
        END IF;
        IF (x_kln_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.last_update_login := l_kln_rec.last_update_login;
        END IF;
-- R12 Data Model Changes 4485150 Start

        /**
        IF (x_kln_rec.trxn_extension_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.trxn_extension_id := l_kln_rec.trxn_extension_id;
        END IF;
        **/
        --bug 4656532 (QA updates cc_auth_code after authorization which we need to null out if credit card changes
        IF (x_kln_rec.trxn_extension_id = OKC_API.G_MISS_NUM)
                THEN
                x_kln_rec.trxn_extension_id := l_kln_rec.trxn_extension_id;

                x_credit_card_changed := 'N';
        ELSIF
                nvl(x_kln_rec.trxn_extension_id,  - 9999) <>
                nvl(l_kln_rec.trxn_extension_id,  - 9999) THEN
                x_credit_card_changed := 'Y';
        ELSE
                x_credit_card_changed := 'N';
        END IF;


        IF (x_kln_rec.tax_classification_code = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.tax_classification_code := l_kln_rec.tax_classification_code;
        END IF;
        IF (x_kln_rec.exempt_certificate_number = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.exempt_certificate_number := l_kln_rec.exempt_certificate_number;
        END IF;
        IF (x_kln_rec.exempt_reason_code = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.exempt_reason_code := l_kln_rec.exempt_reason_code;
        END IF;
        IF (x_kln_rec.coverage_id = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.coverage_id := l_kln_rec.coverage_id;
        END IF;
        IF (x_kln_rec.standard_cov_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.standard_cov_yn := l_kln_rec.standard_cov_yn;
        END IF;
        IF (x_kln_rec.orig_system_id1 = OKC_API.G_MISS_NUM)
        THEN
          x_kln_rec.orig_system_id1 := l_kln_rec.orig_system_id1;
        END IF;
        IF (x_kln_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.orig_system_reference1 := l_kln_rec.orig_system_reference1;
        END IF;
        IF (x_kln_rec.orig_system_source_code = OKC_API.G_MISS_CHAR)
        THEN
          x_kln_rec.orig_system_source_code := l_kln_rec.orig_system_source_code;
        END IF;
-- R12 Data Model Changes 4485150 End

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKS_K_LINES_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_kln_rec IN kln_rec_type,
      x_kln_rec OUT NOCOPY kln_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_kln_rec := p_kln_rec;
      x_kln_rec.OBJECT_VERSION_NUMBER := p_kln_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_kln_rec,                         -- IN
      l_kln_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_kln_rec, l_def_kln_rec, l_credit_card_changed);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --bug 4656532 (QA updates cc_auth_code after authorization which we need to null out if credit card changes
    IF l_credit_card_changed = 'Y' THEN
       l_def_kln_rec.cc_auth_code := NULL;
    END IF;

    UPDATE OKS_K_LINES_B
    SET CLE_ID = l_def_kln_rec.cle_id,
        DNZ_CHR_ID = l_def_kln_rec.dnz_chr_id,
        DISCOUNT_LIST = l_def_kln_rec.discount_list,
        ACCT_RULE_ID = l_def_kln_rec.acct_rule_id,
        PAYMENT_TYPE = l_def_kln_rec.payment_type,
        CC_NO = l_def_kln_rec.cc_no,
        CC_EXPIRY_DATE = l_def_kln_rec.cc_expiry_date,
        CC_BANK_ACCT_ID = l_def_kln_rec.cc_bank_acct_id,
        CC_AUTH_CODE = l_def_kln_rec.cc_auth_code,
        COMMITMENT_ID = l_def_kln_rec.commitment_id,
        LOCKED_PRICE_LIST_ID = l_def_kln_rec.locked_price_list_id,
        USAGE_EST_YN = l_def_kln_rec.usage_est_yn,
        USAGE_EST_METHOD = l_def_kln_rec.usage_est_method,
        USAGE_EST_START_DATE = l_def_kln_rec.usage_est_start_date,
        TERMN_METHOD = l_def_kln_rec.termn_method,
        UBT_AMOUNT = l_def_kln_rec.ubt_amount,
        CREDIT_AMOUNT = l_def_kln_rec.credit_amount,
        SUPPRESSED_CREDIT = l_def_kln_rec.suppressed_credit,
        OVERRIDE_AMOUNT = l_def_kln_rec.override_amount,
        CUST_PO_NUMBER_REQ_YN = l_def_kln_rec.cust_po_number_req_yn,
        CUST_PO_NUMBER = l_def_kln_rec.cust_po_number,
        GRACE_DURATION = l_def_kln_rec.grace_duration,
        GRACE_PERIOD = l_def_kln_rec.grace_period,
        INV_PRINT_FLAG = l_def_kln_rec.inv_print_flag,
        PRICE_UOM = l_def_kln_rec.price_uom,
        TAX_AMOUNT = l_def_kln_rec.tax_amount,
        TAX_INCLUSIVE_YN = l_def_kln_rec.tax_inclusive_yn,
        TAX_STATUS = l_def_kln_rec.tax_status,
        TAX_CODE = l_def_kln_rec.tax_code,
        TAX_EXEMPTION_ID = l_def_kln_rec.tax_exemption_id,
        IB_TRANS_TYPE = l_def_kln_rec.ib_trans_type,
        IB_TRANS_DATE = l_def_kln_rec.ib_trans_date,
        PROD_PRICE = l_def_kln_rec.prod_price,
        SERVICE_PRICE = l_def_kln_rec.service_price,
        CLVL_LIST_PRICE = l_def_kln_rec.clvl_list_price,
        CLVL_QUANTITY = l_def_kln_rec.clvl_quantity,
        CLVL_EXTENDED_AMT = l_def_kln_rec.clvl_extended_amt,
        CLVL_UOM_CODE = l_def_kln_rec.clvl_uom_code,
        TOPLVL_OPERAND_CODE = l_def_kln_rec.toplvl_operand_code,
        TOPLVL_OPERAND_VAL = l_def_kln_rec.toplvl_operand_val,
        TOPLVL_QUANTITY = l_def_kln_rec.toplvl_quantity,
        TOPLVL_UOM_CODE = l_def_kln_rec.toplvl_uom_code,
        TOPLVL_ADJ_PRICE = l_def_kln_rec.toplvl_adj_price,
        TOPLVL_PRICE_QTY = l_def_kln_rec.toplvl_price_qty,
        AVERAGING_INTERVAL = l_def_kln_rec.averaging_interval,
        SETTLEMENT_INTERVAL = l_def_kln_rec.settlement_interval,
        MINIMUM_QUANTITY = l_def_kln_rec.minimum_quantity,
        DEFAULT_QUANTITY = l_def_kln_rec.default_quantity,
        AMCV_FLAG = l_def_kln_rec.amcv_flag,
        FIXED_QUANTITY = l_def_kln_rec.fixed_quantity,
        USAGE_DURATION = l_def_kln_rec.usage_duration,
        USAGE_PERIOD = l_def_kln_rec.usage_period,
        LEVEL_YN = l_def_kln_rec.level_yn,
        USAGE_TYPE = l_def_kln_rec.usage_type,
        UOM_QUANTIFIED = l_def_kln_rec.uom_quantified,
        BASE_READING = l_def_kln_rec.base_reading,
        BILLING_SCHEDULE_TYPE = l_def_kln_rec.billing_schedule_type,
        FULL_CREDIT = l_def_kln_rec.full_credit,
        LOCKED_PRICE_LIST_LINE_ID = l_def_kln_rec.locked_price_list_line_id,
        BREAK_UOM = l_def_kln_rec.break_uom,
        PRORATE = l_def_kln_rec.prorate,
        COVERAGE_TYPE = l_def_kln_rec.coverage_type,
        EXCEPTION_COV_ID = l_def_kln_rec.exception_cov_id,
        LIMIT_UOM_QUANTIFIED = l_def_kln_rec.limit_uom_quantified,
        DISCOUNT_AMOUNT = l_def_kln_rec.discount_amount,
        DISCOUNT_PERCENT = l_def_kln_rec.discount_percent,
        OFFSET_DURATION = l_def_kln_rec.offset_duration,
        OFFSET_PERIOD = l_def_kln_rec.offset_period,
        INCIDENT_SEVERITY_ID = l_def_kln_rec.incident_severity_id,
        PDF_ID = l_def_kln_rec.pdf_id,
        WORK_THRU_YN = l_def_kln_rec.work_thru_yn,
        REACT_ACTIVE_YN = l_def_kln_rec.react_active_yn,
        TRANSFER_OPTION = l_def_kln_rec.transfer_option,
        PROD_UPGRADE_YN = l_def_kln_rec.prod_upgrade_yn,
        INHERITANCE_TYPE = l_def_kln_rec.inheritance_type,
        PM_PROGRAM_ID = l_def_kln_rec.pm_program_id,
        PM_CONF_REQ_YN = l_def_kln_rec.pm_conf_req_yn,
        PM_SCH_EXISTS_YN = l_def_kln_rec.pm_sch_exists_yn,
        ALLOW_BT_DISCOUNT = l_def_kln_rec.allow_bt_discount,
        APPLY_DEFAULT_TIMEZONE = l_def_kln_rec.apply_default_timezone,
        SYNC_DATE_INSTALL = l_def_kln_rec.sync_date_install,
        OBJECT_VERSION_NUMBER = l_def_kln_rec.object_version_number,
        REQUEST_ID = l_def_kln_rec.request_id,
        CREATED_BY = l_def_kln_rec.created_by,
        CREATION_DATE = l_def_kln_rec.creation_date,
        LAST_UPDATED_BY = l_def_kln_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_kln_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_kln_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
        TRXN_EXTENSION_ID = l_def_kln_rec.trxn_extension_id,
        TAX_CLASSIFICATION_CODE = l_def_kln_rec.tax_classification_code,
        EXEMPT_CERTIFICATE_NUMBER = l_def_kln_rec.exempt_certificate_number,
        EXEMPT_REASON_CODE = l_def_kln_rec.exempt_reason_code,
        COVERAGE_ID = l_def_kln_rec.coverage_id,
        STANDARD_COV_YN = l_def_kln_rec.standard_cov_yn,
        ORIG_SYSTEM_ID1 = l_def_kln_rec.orig_system_id1,
        ORIG_SYSTEM_REFERENCE1 = l_def_kln_rec.orig_system_reference1,
        ORIG_SYSTEM_SOURCE_CODE = l_def_kln_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
    WHERE ID = l_def_kln_rec.id;

    x_kln_rec := l_kln_rec;
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
  -----------------------------------
  -- update_row for:OKS_K_LINES_TL --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klt_rec                      IN klt_rec_type,
    x_klt_rec                      OUT NOCOPY klt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klt_rec                      klt_rec_type := p_klt_rec;
    l_def_klt_rec                  klt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_klt_rec IN klt_rec_type,
      x_klt_rec OUT NOCOPY klt_rec_type
    ) RETURN VARCHAR2 IS
      l_klt_rec                      klt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_klt_rec := p_klt_rec;
      -- Get current database values
      l_klt_rec := get_rec(p_klt_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_klt_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_klt_rec.id := l_klt_rec.id;
        END IF;
        IF (x_klt_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_klt_rec.language := l_klt_rec.language;
        END IF;
        IF (x_klt_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_klt_rec.source_lang := l_klt_rec.source_lang;
        END IF;
        IF (x_klt_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_klt_rec.sfwt_flag := l_klt_rec.sfwt_flag;
        END IF;
        IF (x_klt_rec.invoice_text = OKC_API.G_MISS_CHAR)
        THEN
          x_klt_rec.invoice_text := l_klt_rec.invoice_text;
        END IF;
        IF (x_klt_rec.ib_trx_details = OKC_API.G_MISS_CHAR)
        THEN
          x_klt_rec.ib_trx_details := l_klt_rec.ib_trx_details;
        END IF;
        IF (x_klt_rec.status_text = OKC_API.G_MISS_CHAR)
        THEN
          x_klt_rec.status_text := l_klt_rec.status_text;
        END IF;
        IF (x_klt_rec.react_time_name = OKC_API.G_MISS_CHAR)
        THEN
          x_klt_rec.react_time_name := l_klt_rec.react_time_name;
        END IF;
        IF (x_klt_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_klt_rec.created_by := l_klt_rec.created_by;
        END IF;
        IF (x_klt_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_klt_rec.creation_date := l_klt_rec.creation_date;
        END IF;
        IF (x_klt_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_klt_rec.last_updated_by := l_klt_rec.last_updated_by;
        END IF;
        IF (x_klt_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_klt_rec.last_update_date := l_klt_rec.last_update_date;
        END IF;
        IF (x_klt_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_klt_rec.last_update_login := l_klt_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKS_K_LINES_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_klt_rec IN klt_rec_type,
      x_klt_rec OUT NOCOPY klt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_klt_rec := p_klt_rec;
      x_klt_rec.LANGUAGE := USERENV('LANG');
      x_klt_rec.LANGUAGE := USERENV('LANG');
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
      p_klt_rec,                         -- IN
      l_klt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_klt_rec, l_def_klt_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_K_LINES_TL
    SET INVOICE_TEXT = l_def_klt_rec.invoice_text,
        IB_TRX_DETAILS = l_def_klt_rec.ib_trx_details,
        STATUS_TEXT = l_def_klt_rec.status_text,
        REACT_TIME_NAME = l_def_klt_rec.react_time_name,
        CREATED_BY = l_def_klt_rec.created_by,
        CREATION_DATE = l_def_klt_rec.creation_date,
        LAST_UPDATED_BY = l_def_klt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_klt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_klt_rec.last_update_login
    WHERE ID = l_def_klt_rec.id
      --npalepu modified on 15-FEB-2007 for bug # 5691160
      /* AND SOURCE_LANG = USERENV('LANG'); */
      AND  USERENV('LANG') IN (SOURCE_LANG,LANGUAGE);
      --end 5691160

    UPDATE OKS_K_LINES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_klt_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_klt_rec := l_klt_rec;
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
  ----------------------------------
  -- update_row for:OKS_K_LINES_V --
  ----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type,
    x_klnv_rec                     OUT NOCOPY klnv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klnv_rec                     klnv_rec_type := p_klnv_rec;
    l_def_klnv_rec                 klnv_rec_type;
    l_db_klnv_rec                  klnv_rec_type;
    l_kln_rec                      kln_rec_type;
    lx_kln_rec                     kln_rec_type;
    l_klt_rec                      klt_rec_type;
    lx_klt_rec                     klt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_klnv_rec IN klnv_rec_type
    ) RETURN klnv_rec_type IS
      l_klnv_rec klnv_rec_type := p_klnv_rec;
    BEGIN
      l_klnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_klnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_klnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_klnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_klnv_rec IN klnv_rec_type,
      x_klnv_rec OUT NOCOPY klnv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_klnv_rec := p_klnv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_klnv_rec := get_rec(p_klnv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_klnv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.id := l_db_klnv_rec.id;
        END IF;
        IF (x_klnv_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.cle_id := l_db_klnv_rec.cle_id;
        END IF;
        IF (x_klnv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.dnz_chr_id := l_db_klnv_rec.dnz_chr_id;
        END IF;
        IF (x_klnv_rec.discount_list = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.discount_list := l_db_klnv_rec.discount_list;
        END IF;
        IF (x_klnv_rec.acct_rule_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.acct_rule_id := l_db_klnv_rec.acct_rule_id;
        END IF;
        IF (x_klnv_rec.payment_type = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.payment_type := l_db_klnv_rec.payment_type;
        END IF;
        IF (x_klnv_rec.cc_no = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.cc_no := l_db_klnv_rec.cc_no;
        END IF;
        IF (x_klnv_rec.cc_expiry_date = OKC_API.G_MISS_DATE)
        THEN
          x_klnv_rec.cc_expiry_date := l_db_klnv_rec.cc_expiry_date;
        END IF;
        IF (x_klnv_rec.cc_bank_acct_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.cc_bank_acct_id := l_db_klnv_rec.cc_bank_acct_id;
        END IF;
        IF (x_klnv_rec.cc_auth_code = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.cc_auth_code := l_db_klnv_rec.cc_auth_code;
        END IF;
        IF (x_klnv_rec.commitment_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.commitment_id := l_db_klnv_rec.commitment_id;
        END IF;
        IF (x_klnv_rec.locked_price_list_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.locked_price_list_id := l_db_klnv_rec.locked_price_list_id;
        END IF;
        IF (x_klnv_rec.usage_est_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.usage_est_yn := l_db_klnv_rec.usage_est_yn;
        END IF;
        IF (x_klnv_rec.usage_est_method = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.usage_est_method := l_db_klnv_rec.usage_est_method;
        END IF;
        IF (x_klnv_rec.usage_est_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_klnv_rec.usage_est_start_date := l_db_klnv_rec.usage_est_start_date;
        END IF;
        IF (x_klnv_rec.termn_method = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.termn_method := l_db_klnv_rec.termn_method;
        END IF;
        IF (x_klnv_rec.ubt_amount = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.ubt_amount := l_db_klnv_rec.ubt_amount;
        END IF;
        IF (x_klnv_rec.credit_amount = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.credit_amount := l_db_klnv_rec.credit_amount;
        END IF;
        IF (x_klnv_rec.suppressed_credit = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.suppressed_credit := l_db_klnv_rec.suppressed_credit;
        END IF;
        IF (x_klnv_rec.override_amount = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.override_amount := l_db_klnv_rec.override_amount;
        END IF;
        IF (x_klnv_rec.cust_po_number_req_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.cust_po_number_req_yn := l_db_klnv_rec.cust_po_number_req_yn;
        END IF;
        IF (x_klnv_rec.cust_po_number = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.cust_po_number := l_db_klnv_rec.cust_po_number;
        END IF;
        IF (x_klnv_rec.grace_duration = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.grace_duration := l_db_klnv_rec.grace_duration;
        END IF;
        IF (x_klnv_rec.grace_period = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.grace_period := l_db_klnv_rec.grace_period;
        END IF;
        IF (x_klnv_rec.inv_print_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.inv_print_flag := l_db_klnv_rec.inv_print_flag;
        END IF;
        IF (x_klnv_rec.price_uom = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.price_uom := l_db_klnv_rec.price_uom;
        END IF;
        IF (x_klnv_rec.tax_amount = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.tax_amount := l_db_klnv_rec.tax_amount;
        END IF;
        IF (x_klnv_rec.tax_inclusive_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.tax_inclusive_yn := l_db_klnv_rec.tax_inclusive_yn;
        END IF;
        IF (x_klnv_rec.tax_status = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.tax_status := l_db_klnv_rec.tax_status;
        END IF;
        IF (x_klnv_rec.tax_code = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.tax_code := l_db_klnv_rec.tax_code;
        END IF;
        IF (x_klnv_rec.tax_exemption_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.tax_exemption_id := l_db_klnv_rec.tax_exemption_id;
        END IF;
        IF (x_klnv_rec.ib_trans_type = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.ib_trans_type := l_db_klnv_rec.ib_trans_type;
        END IF;
        IF (x_klnv_rec.ib_trans_date = OKC_API.G_MISS_DATE)
        THEN
          x_klnv_rec.ib_trans_date := l_db_klnv_rec.ib_trans_date;
        END IF;
        IF (x_klnv_rec.prod_price = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.prod_price := l_db_klnv_rec.prod_price;
        END IF;
        IF (x_klnv_rec.service_price = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.service_price := l_db_klnv_rec.service_price;
        END IF;
        IF (x_klnv_rec.clvl_list_price = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.clvl_list_price := l_db_klnv_rec.clvl_list_price;
        END IF;
        IF (x_klnv_rec.clvl_quantity = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.clvl_quantity := l_db_klnv_rec.clvl_quantity;
        END IF;
        IF (x_klnv_rec.clvl_extended_amt = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.clvl_extended_amt := l_db_klnv_rec.clvl_extended_amt;
        END IF;
        IF (x_klnv_rec.clvl_uom_code = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.clvl_uom_code := l_db_klnv_rec.clvl_uom_code;
        END IF;
        IF (x_klnv_rec.toplvl_operand_code = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.toplvl_operand_code := l_db_klnv_rec.toplvl_operand_code;
        END IF;
        IF (x_klnv_rec.toplvl_operand_val = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.toplvl_operand_val := l_db_klnv_rec.toplvl_operand_val;
        END IF;
        IF (x_klnv_rec.toplvl_quantity = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.toplvl_quantity := l_db_klnv_rec.toplvl_quantity;
        END IF;
        IF (x_klnv_rec.toplvl_uom_code = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.toplvl_uom_code := l_db_klnv_rec.toplvl_uom_code;
        END IF;
        IF (x_klnv_rec.toplvl_adj_price = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.toplvl_adj_price := l_db_klnv_rec.toplvl_adj_price;
        END IF;
        IF (x_klnv_rec.toplvl_price_qty = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.toplvl_price_qty := l_db_klnv_rec.toplvl_price_qty;
        END IF;
        IF (x_klnv_rec.averaging_interval = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.averaging_interval := l_db_klnv_rec.averaging_interval;
        END IF;
        IF (x_klnv_rec.settlement_interval = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.settlement_interval := l_db_klnv_rec.settlement_interval;
        END IF;
        IF (x_klnv_rec.minimum_quantity = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.minimum_quantity := l_db_klnv_rec.minimum_quantity;
        END IF;
        IF (x_klnv_rec.default_quantity = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.default_quantity := l_db_klnv_rec.default_quantity;
        END IF;
        IF (x_klnv_rec.amcv_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.amcv_flag := l_db_klnv_rec.amcv_flag;
        END IF;
        IF (x_klnv_rec.fixed_quantity = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.fixed_quantity := l_db_klnv_rec.fixed_quantity;
        END IF;
        IF (x_klnv_rec.usage_duration = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.usage_duration := l_db_klnv_rec.usage_duration;
        END IF;
        IF (x_klnv_rec.usage_period = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.usage_period := l_db_klnv_rec.usage_period;
        END IF;
        IF (x_klnv_rec.level_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.level_yn := l_db_klnv_rec.level_yn;
        END IF;
        IF (x_klnv_rec.usage_type = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.usage_type := l_db_klnv_rec.usage_type;
        END IF;
        IF (x_klnv_rec.uom_quantified = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.uom_quantified := l_db_klnv_rec.uom_quantified;
        END IF;
        IF (x_klnv_rec.base_reading = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.base_reading := l_db_klnv_rec.base_reading;
        END IF;
        IF (x_klnv_rec.billing_schedule_type = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.billing_schedule_type := l_db_klnv_rec.billing_schedule_type;
        END IF;
        IF (x_klnv_rec.full_credit = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.full_credit := l_db_klnv_rec.full_credit;
        END IF;
        IF (x_klnv_rec.locked_price_list_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.locked_price_list_line_id := l_db_klnv_rec.locked_price_list_line_id;
        END IF;
        IF (x_klnv_rec.break_uom = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.break_uom := l_db_klnv_rec.break_uom;
        END IF;
        IF (x_klnv_rec.prorate = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.prorate := l_db_klnv_rec.prorate;
        END IF;
        IF (x_klnv_rec.coverage_type = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.coverage_type := l_db_klnv_rec.coverage_type;
        END IF;
        IF (x_klnv_rec.exception_cov_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.exception_cov_id := l_db_klnv_rec.exception_cov_id;
        END IF;
        IF (x_klnv_rec.limit_uom_quantified = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.limit_uom_quantified := l_db_klnv_rec.limit_uom_quantified;
        END IF;
        IF (x_klnv_rec.discount_amount = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.discount_amount := l_db_klnv_rec.discount_amount;
        END IF;
        IF (x_klnv_rec.discount_percent = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.discount_percent := l_db_klnv_rec.discount_percent;
        END IF;
        IF (x_klnv_rec.offset_duration = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.offset_duration := l_db_klnv_rec.offset_duration;
        END IF;
        IF (x_klnv_rec.offset_period = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.offset_period := l_db_klnv_rec.offset_period;
        END IF;
        IF (x_klnv_rec.incident_severity_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.incident_severity_id := l_db_klnv_rec.incident_severity_id;
        END IF;
        IF (x_klnv_rec.pdf_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.pdf_id := l_db_klnv_rec.pdf_id;
        END IF;
        IF (x_klnv_rec.work_thru_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.work_thru_yn := l_db_klnv_rec.work_thru_yn;
        END IF;
        IF (x_klnv_rec.react_active_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.react_active_yn := l_db_klnv_rec.react_active_yn;
        END IF;
        IF (x_klnv_rec.transfer_option = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.transfer_option := l_db_klnv_rec.transfer_option;
        END IF;
        IF (x_klnv_rec.prod_upgrade_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.prod_upgrade_yn := l_db_klnv_rec.prod_upgrade_yn;
        END IF;
        IF (x_klnv_rec.inheritance_type = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.inheritance_type := l_db_klnv_rec.inheritance_type;
        END IF;
        IF (x_klnv_rec.pm_program_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.pm_program_id := l_db_klnv_rec.pm_program_id;
        END IF;
        IF (x_klnv_rec.pm_conf_req_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.pm_conf_req_yn := l_db_klnv_rec.pm_conf_req_yn;
        END IF;
        IF (x_klnv_rec.pm_sch_exists_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.pm_sch_exists_yn := l_db_klnv_rec.pm_sch_exists_yn;
        END IF;
        IF (x_klnv_rec.allow_bt_discount = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.allow_bt_discount := l_db_klnv_rec.allow_bt_discount;
        END IF;
        IF (x_klnv_rec.apply_default_timezone = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.apply_default_timezone := l_db_klnv_rec.apply_default_timezone;
        END IF;
        IF (x_klnv_rec.sync_date_install = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.sync_date_install := l_db_klnv_rec.sync_date_install;
        END IF;
        IF (x_klnv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.sfwt_flag := l_db_klnv_rec.sfwt_flag;
        END IF;
        IF (x_klnv_rec.invoice_text = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.invoice_text := l_db_klnv_rec.invoice_text;
        END IF;
        IF (x_klnv_rec.ib_trx_details = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.ib_trx_details := l_db_klnv_rec.ib_trx_details;
        END IF;
        IF (x_klnv_rec.status_text = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.status_text := l_db_klnv_rec.status_text;
        END IF;
        IF (x_klnv_rec.react_time_name = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.react_time_name := l_db_klnv_rec.react_time_name;
        END IF;
        IF (x_klnv_rec.security_group_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.security_group_id := l_db_klnv_rec.security_group_id;
        END IF;
        IF (x_klnv_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.request_id := l_db_klnv_rec.request_id;
        END IF;
        IF (x_klnv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.created_by := l_db_klnv_rec.created_by;
        END IF;
        IF (x_klnv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_klnv_rec.creation_date := l_db_klnv_rec.creation_date;
        END IF;
        IF (x_klnv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.last_updated_by := l_db_klnv_rec.last_updated_by;
        END IF;
        IF (x_klnv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_klnv_rec.last_update_date := l_db_klnv_rec.last_update_date;
        END IF;
        IF (x_klnv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.last_update_login := l_db_klnv_rec.last_update_login;
        END IF;
-- R12 Data Model Changes 4485150 Start

        IF (x_klnv_rec.trxn_extension_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.trxn_extension_id  := l_db_klnv_rec.trxn_extension_id ;
        END IF;
        IF (x_klnv_rec.tax_classification_code = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.tax_classification_code := l_db_klnv_rec.tax_classification_code;
        END IF;
        IF (x_klnv_rec.exempt_certificate_number = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.exempt_certificate_number := l_db_klnv_rec.exempt_certificate_number;
        END IF;
        IF (x_klnv_rec.exempt_reason_code = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.exempt_reason_code := l_db_klnv_rec.exempt_reason_code;
        END IF;

        IF (x_klnv_rec.coverage_id = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.coverage_id  := l_db_klnv_rec.coverage_id ;
        END IF;
        IF (x_klnv_rec.standard_cov_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.standard_cov_yn := l_db_klnv_rec.standard_cov_yn;
        END IF;
        IF (x_klnv_rec.orig_system_id1 = OKC_API.G_MISS_NUM)
        THEN
          x_klnv_rec.orig_system_id1 := l_db_klnv_rec.orig_system_id1;
        END IF;
        IF (x_klnv_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.orig_system_reference1 := l_db_klnv_rec.orig_system_reference1;
        END IF;
        IF (x_klnv_rec.orig_system_source_code = OKC_API.G_MISS_CHAR)
        THEN
          x_klnv_rec.orig_system_source_code := l_db_klnv_rec.orig_system_source_code;
        END IF;
-- R12 Data Model Changes 4485150 End

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKS_K_LINES_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_klnv_rec IN klnv_rec_type,
      x_klnv_rec OUT NOCOPY klnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_klnv_rec := p_klnv_rec;
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
      p_klnv_rec,                        -- IN
      x_klnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_klnv_rec, l_def_klnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_klnv_rec := fill_who_columns(l_def_klnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_klnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_klnv_rec, l_db_klnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_klnv_rec                     => p_klnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_klnv_rec, l_kln_rec);
    migrate(l_def_klnv_rec, l_klt_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_kln_rec,
      lx_kln_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_kln_rec, l_def_klnv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_klt_rec,
      lx_klt_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_klt_rec, l_def_klnv_rec);
    x_klnv_rec := l_def_klnv_rec;
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
  -- PL/SQL TBL update_row for:klnv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klnv_tbl.COUNT > 0) THEN
      i := p_klnv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_klnv_rec                     => p_klnv_tbl(i),
            x_klnv_rec                     => x_klnv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_klnv_tbl.LAST);
        i := p_klnv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:KLNV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klnv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_klnv_tbl                     => p_klnv_tbl,
        x_klnv_tbl                     => x_klnv_tbl,
        px_error_tbl                   => l_error_tbl);
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
  ----------------------------------
  -- delete_row for:OKS_K_LINES_B --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_kln_rec                      IN kln_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_kln_rec                      kln_rec_type := p_kln_rec;
    l_row_notfound                 BOOLEAN := TRUE;
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

    DELETE FROM OKS_K_LINES_B
     WHERE ID = p_kln_rec.id;

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
  -----------------------------------
  -- delete_row for:OKS_K_LINES_TL --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klt_rec                      IN klt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klt_rec                      klt_rec_type := p_klt_rec;
    l_row_notfound                 BOOLEAN := TRUE;
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

    DELETE FROM OKS_K_LINES_TL
     WHERE ID = p_klt_rec.id;

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
  ----------------------------------
  -- delete_row for:OKS_K_LINES_V --
  ----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klnv_rec                     klnv_rec_type := p_klnv_rec;
    l_klt_rec                      klt_rec_type;
    l_kln_rec                      kln_rec_type;
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
    migrate(l_klnv_rec, l_klt_rec);
    migrate(l_klnv_rec, l_kln_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_klt_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_kln_rec
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
  ---------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_K_LINES_V --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klnv_tbl.COUNT > 0) THEN
      i := p_klnv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_klnv_rec                     => p_klnv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_klnv_tbl.LAST);
        i := p_klnv_tbl.NEXT(i);
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

  ---------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_K_LINES_V --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klnv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_klnv_tbl                     => p_klnv_tbl,
        px_error_tbl                   => l_error_tbl);
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

END OKS_KLN_PVT;

/
