--------------------------------------------------------
--  DDL for Package Body OKL_SAO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SAO_PVT" AS
/* $Header: OKLSSAOB.pls 120.10.12010000.3 2009/06/02 10:53:42 racheruv ship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
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
  -- FUNCTION get_rec for: OKL_SYS_ACCT_OPTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sao_rec                      IN sao_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sao_rec_type IS
    CURSOR okl_sys_acct_opts_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CC_REP_CURRENCY_CODE,
            CODE_COMBINATION_ID,
            AEL_REP_CURRENCY_CODE,
            SET_OF_BOOKS_ID,
            OBJECT_VERSION_NUMBER,
            REC_CCID,
            REALIZED_GAIN_CCID,
            REALIZED_LOSS_CCID,
            TAX_CCID,
            CROSS_CURRENCY_CCID,
            ROUNDING_CCID,
            AR_CLEARING_CCID,
            PAYABLES_CCID,
            LIABLITY_CCID,
            PRE_PAYMENT_CCID,
            FUT_DATE_PAY_CCID,
            CC_ROUNDING_RULE,
            CC_PRECISION,
            CC_MIN_ACCT_UNIT,
            DIS_TAKEN_CCID,
            AP_CLEARING_CCID,
            AEL_ROUNDING_RULE,
            AEL_PRECISION,
            AEL_MIN_ACCT_UNIT,
            ORG_ID,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            /* Changed Made by Kanti on 06/21/2001. The following two fields are available in Table
               but were missing here. Changes Start here */
            CC_APPLY_ROUNDING_DIFFERENCE,
            AEL_APPLY_ROUNDING_DIFFERENCE,
            ACCRUAL_REVERSAL_DAYS,
            /*Changes End Here  */
            -- Added a new field for the bug 2331564 Santonyr
            LKE_HOLD_DAYS,
            /*Changes made by Keerthi 10-Sep-2003 for Rounding Amounts in Streams */
            STM_APPLY_ROUNDING_DIFFERENCE,
            STM_ROUNDING_RULE
            /*Added new field for bug 4884618(H) */
            ,VALIDATE_KHR_START_DATE
            ,ACCOUNT_DERIVATION
            ,ISG_ARREARS_PAY_DATES_OPTION
            ,PAY_DIST_SET_ID
            ,SECONDARY_REP_METHOD --Bug#7225249
            --Bug# 8370699
            ,amort_inc_adj_rev_dt_yn
      FROM Okl_Sys_Acct_Opts
     WHERE okl_sys_acct_opts.id = p_id;
    l_okl_sys_acct_opts_pk         okl_sys_acct_opts_pk_csr%ROWTYPE;
    l_sao_rec                      sao_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_sys_acct_opts_pk_csr (p_sao_rec.id);
    FETCH okl_sys_acct_opts_pk_csr INTO
              l_sao_rec.ID,
              l_sao_rec.CC_REP_currency_code,
              l_sao_rec.CODE_COMBINATION_ID,
              l_sao_rec.AEL_REP_currency_code,
              l_sao_rec.SET_OF_BOOKS_ID,
              l_sao_rec.OBJECT_VERSION_NUMBER,
              l_sao_rec.REC_CCID,
              l_sao_rec.REALIZED_GAIN_CCID,
              l_sao_rec.REALIZED_LOSS_CCID,
              l_sao_rec.TAX_CCID,
              l_sao_rec.CROSS_currency_CCID,
              l_sao_rec.ROUNDING_CCID,
              l_sao_rec.AR_CLEARING_CCID,
              l_sao_rec.PAYABLES_CCID,
              l_sao_rec.LIABLITY_CCID,
              l_sao_rec.PRE_PAYMENT_CCID,
              l_sao_rec.FUT_DATE_PAY_CCID,
              l_sao_rec.CC_ROUNDING_RULE,
              l_sao_rec.CC_PRECISION,
              l_sao_rec.CC_MIN_ACCT_UNIT,
              l_sao_rec.DIS_TAKEN_CCID,
              l_sao_rec.AP_CLEARING_CCID,
              l_sao_rec.AEL_ROUNDING_RULE,
              l_sao_rec.AEL_PRECISION,
              l_sao_rec.AEL_MIN_ACCT_UNIT,
              l_sao_rec.ORG_ID,
              l_sao_rec.ATTRIBUTE_CATEGORY,
              l_sao_rec.ATTRIBUTE1,
              l_sao_rec.ATTRIBUTE2,
              l_sao_rec.ATTRIBUTE3,
              l_sao_rec.ATTRIBUTE4,
              l_sao_rec.ATTRIBUTE5,
              l_sao_rec.ATTRIBUTE6,
              l_sao_rec.ATTRIBUTE7,
              l_sao_rec.ATTRIBUTE8,
              l_sao_rec.ATTRIBUTE9,
              l_sao_rec.ATTRIBUTE10,
              l_sao_rec.ATTRIBUTE11,
              l_sao_rec.ATTRIBUTE12,
              l_sao_rec.ATTRIBUTE13,
              l_sao_rec.ATTRIBUTE14,
              l_sao_rec.ATTRIBUTE15,
              l_sao_rec.CREATED_BY,
              l_sao_rec.CREATION_DATE,
              l_sao_rec.LAST_UPDATED_BY,
              l_sao_rec.LAST_UPDATE_DATE,
              l_sao_rec.LAST_UPDATE_LOGIN,
              /* Changed made by Kanti on 06/21/2001. The following two fields are available in table
                 but were missing from here. Changes starts here */
              l_sao_rec.CC_APPLY_ROUNDING_DIFFERENCE,
              l_sao_rec.AEL_APPLY_ROUNDING_DIFFERENCE,
              l_sao_rec.ACCRUAL_REVERSAL_DAYS,
              /* Changes End Here      */
              -- Added a new field for the bug 2331564 Santonyr
              l_sao_rec.LKE_HOLD_DAYS,
              /*Changes made by Keerthi 10-Sep-2003 for Rounding Amounts in Streams */
              l_sao_rec.STM_APPLY_ROUNDING_DIFFERENCE,
              l_sao_rec.STM_ROUNDING_RULE
              /*Added new field for bug 4746246 */
              ,l_sao_rec.VALIDATE_KHR_START_DATE
              ,l_sao_rec.ACCOUNT_DERIVATION -- R12 SLA Uptake
              ,l_sao_rec.ISG_ARREARS_PAY_DATES_OPTION
              ,l_sao_rec.PAY_DIST_SET_ID
              ,l_sao_rec.SECONDARY_REP_METHOD --Bug#7225249
              --Bug# 8370699
              ,l_sao_rec.AMORT_INC_ADJ_REV_DT_YN;

    x_no_data_found := okl_sys_acct_opts_pk_csr%NOTFOUND;
    CLOSE okl_sys_acct_opts_pk_csr;
    RETURN(l_sao_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sao_rec                      IN sao_rec_type
  ) RETURN sao_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sao_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SYS_ACCT_OPTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_saov_rec                     IN saov_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN saov_rec_type IS
    CURSOR okl_saov_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SET_OF_BOOKS_ID,
            CODE_COMBINATION_ID,
            CC_REP_CURRENCY_CODE,
            AEL_REP_CURRENCY_CODE,
            REC_CCID,
            REALIZED_GAIN_CCID,
            REALIZED_LOSS_CCID,
            TAX_CCID,
            CROSS_CURRENCY_CCID,
            ROUNDING_CCID,
            AR_CLEARING_CCID,
            PAYABLES_CCID,
            LIABLITY_CCID,
            PRE_PAYMENT_CCID,
            FUT_DATE_PAY_CCID,
            DIS_TAKEN_CCID,
            AP_CLEARING_CCID,
            AEL_ROUNDING_RULE,
            AEL_PRECISION,
            AEL_MIN_ACCT_UNIT,
            CC_ROUNDING_RULE,
            CC_PRECISION,
            CC_MIN_ACCT_UNIT,
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
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            /* Changed Made by Kanti on 06/21/2001. The following two fields are available in Table
               but were missing here. Changes Start here */
       	    CC_APPLY_ROUNDING_DIFFERENCE,
       	    AEL_APPLY_ROUNDING_DIFFERENCE,
            ACCRUAL_REVERSAL_DAYS,
            -- Added new field lke_hold_days for the bug 2331564 by Santonyr
            LKE_HOLD_DAYS,
            /*Changes made by Keerthi 10-Sep-2003 for Rounding Amounts in Streams */
            STM_APPLY_ROUNDING_DIFFERENCE,
            STM_ROUNDING_RULE
            /*Changes End Here  */
           /*Added new field for bug 4746246 */
           ,VALIDATE_KHR_START_DATE
           ,ACCOUNT_DERIVATION -- R12 SLA Uptake
           ,ISG_ARREARS_PAY_DATES_OPTION
           ,PAY_DIST_SET_ID
           ,SECONDARY_REP_METHOD --Bug#7225249
           --Bug# 8370699
           ,AMORT_INC_ADJ_REV_DT_YN
      FROM OKL_SYS_ACCT_OPTS
     WHERE OKL_SYS_ACCT_OPTS.id = p_id;
    l_okl_saov_pk                  okl_saov_pk_csr%ROWTYPE;
    l_saov_rec                     saov_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_saov_pk_csr (p_saov_rec.id);
    FETCH okl_saov_pk_csr INTO
              l_saov_rec.ID,
              l_saov_rec.OBJECT_VERSION_NUMBER,
              l_saov_rec.SET_OF_BOOKS_ID,
              l_saov_rec.CODE_COMBINATION_ID,
              l_saov_rec.CC_REP_currency_code,
              l_saov_rec.AEL_REP_currency_code,
              l_saov_rec.REC_CCID,
              l_saov_rec.REALIZED_GAIN_CCID,
              l_saov_rec.REALIZED_LOSS_CCID,
              l_saov_rec.TAX_CCID,
              l_saov_rec.CROSS_currency_CCID,
              l_saov_rec.ROUNDING_CCID,
              l_saov_rec.AR_CLEARING_CCID,
              l_saov_rec.PAYABLES_CCID,
              l_saov_rec.LIABLITY_CCID,
              l_saov_rec.PRE_PAYMENT_CCID,
              l_saov_rec.FUT_DATE_PAY_CCID,
              l_saov_rec.DIS_TAKEN_CCID,
              l_saov_rec.AP_CLEARING_CCID,
              l_saov_rec.AEL_ROUNDING_RULE,
              l_saov_rec.AEL_PRECISION,
              l_saov_rec.AEL_MIN_ACCT_UNIT,
              l_saov_rec.CC_ROUNDING_RULE,
              l_saov_rec.CC_PRECISION,
              l_saov_rec.CC_MIN_ACCT_UNIT,
              l_saov_rec.ATTRIBUTE_CATEGORY,
              l_saov_rec.ATTRIBUTE1,
              l_saov_rec.ATTRIBUTE2,
              l_saov_rec.ATTRIBUTE3,
              l_saov_rec.ATTRIBUTE4,
              l_saov_rec.ATTRIBUTE5,
              l_saov_rec.ATTRIBUTE6,
              l_saov_rec.ATTRIBUTE7,
              l_saov_rec.ATTRIBUTE8,
              l_saov_rec.ATTRIBUTE9,
              l_saov_rec.ATTRIBUTE10,
              l_saov_rec.ATTRIBUTE11,
              l_saov_rec.ATTRIBUTE12,
              l_saov_rec.ATTRIBUTE13,
              l_saov_rec.ATTRIBUTE14,
              l_saov_rec.ATTRIBUTE15,
              l_saov_rec.ORG_ID,
              l_saov_rec.CREATED_BY,
              l_saov_rec.CREATION_DATE,
              l_saov_rec.LAST_UPDATED_BY,
              l_saov_rec.LAST_UPDATE_DATE,
              l_saov_rec.LAST_UPDATE_LOGIN,
              /* Changed made by Kanti on 06/21/2001. The following two fields are available in table
                 but were missing from here. Changes starts here */
              l_saov_rec.CC_APPLY_ROUNDING_DIFFERENCE,
              l_saov_rec.AEL_APPLY_ROUNDING_DIFFERENCE,
              l_saov_rec.ACCRUAL_REVERSAL_DAYS,
               -- Added new field lke_hold_days for the bug 2331564 by Santonyr
              l_saov_rec.LKE_HOLD_DAYS,
              /*Changes made by Keerthi 10-Sep-2003 for Rounding Amounts in Streams */
              l_saov_rec.STM_APPLY_ROUNDING_DIFFERENCE,
              l_saov_rec.STM_ROUNDING_RULE
              /* Changes End Here      */
              /*Added new field for bug 4746246 */
              ,l_saov_rec.VALIDATE_KHR_START_DATE
              ,l_saov_rec.ACCOUNT_DERIVATION  -- R12 SLA Uptake;
              ,l_saov_rec.ISG_ARREARS_PAY_DATES_OPTION
              ,l_saov_rec.PAY_DIST_SET_ID
              ,l_saov_rec.SECONDARY_REP_METHOD --Bug#7225249
              --Bug# 8370699
              ,l_saov_rec.AMORT_INC_ADJ_REV_DT_YN;

    x_no_data_found := okl_saov_pk_csr%NOTFOUND;
    CLOSE okl_saov_pk_csr;
    RETURN(l_saov_rec);
  END get_rec;

  FUNCTION get_rec (
    p_saov_rec                     IN saov_rec_type
  ) RETURN saov_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_saov_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SYS_ACCT_OPTS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_saov_rec	IN saov_rec_type
  ) RETURN saov_rec_type IS
    l_saov_rec	saov_rec_type := p_saov_rec;
  BEGIN
    IF (l_saov_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.object_version_number := NULL;
    END IF;
    IF (l_saov_rec.set_of_books_id = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.set_of_books_id := NULL;
    END IF;
    IF (l_saov_rec.code_combination_id = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.code_combination_id := NULL;
    END IF;
    IF (l_saov_rec.cc_rep_currency_code = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.cc_rep_currency_code := NULL;
    END IF;
    IF (l_saov_rec.ael_rep_currency_code = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.ael_rep_currency_code := NULL;
    END IF;
    IF (l_saov_rec.rec_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.rec_ccid := NULL;
    END IF;
    IF (l_saov_rec.realized_gain_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.realized_gain_ccid := NULL;
    END IF;
    IF (l_saov_rec.realized_loss_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.realized_loss_ccid := NULL;
    END IF;
    IF (l_saov_rec.tax_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.tax_ccid := NULL;
    END IF;
    IF (l_saov_rec.cross_currency_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.cross_currency_ccid := NULL;
    END IF;
    IF (l_saov_rec.rounding_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.rounding_ccid := NULL;
    END IF;
    IF (l_saov_rec.ar_clearing_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.ar_clearing_ccid := NULL;
    END IF;
    IF (l_saov_rec.payables_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.payables_ccid := NULL;
    END IF;
    IF (l_saov_rec.liablity_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.liablity_ccid := NULL;
    END IF;
    IF (l_saov_rec.pre_payment_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.pre_payment_ccid := NULL;
    END IF;
    IF (l_saov_rec.fut_date_pay_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.fut_date_pay_ccid := NULL;
    END IF;
    IF (l_saov_rec.dis_taken_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.dis_taken_ccid := NULL;
    END IF;
    IF (l_saov_rec.ap_clearing_ccid = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.ap_clearing_ccid := NULL;
    END IF;
    IF (l_saov_rec.ael_rounding_rule = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.ael_rounding_rule := NULL;
    END IF;
    IF (l_saov_rec.ael_precision = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.ael_precision := NULL;
    END IF;
    IF (l_saov_rec.ael_min_acct_unit = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.ael_min_acct_unit := NULL;
    END IF;
    IF (l_saov_rec.cc_rounding_rule = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.cc_rounding_rule := NULL;
    END IF;
    IF (l_saov_rec.cc_precision = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.cc_precision := NULL;
    END IF;
    IF (l_saov_rec.cc_min_acct_unit = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.cc_min_acct_unit := NULL;
    END IF;
    IF (l_saov_rec.attribute_category = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute_category := NULL;
    END IF;
    IF (l_saov_rec.attribute1 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute1 := NULL;
    END IF;
    IF (l_saov_rec.attribute2 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute2 := NULL;
    END IF;
    IF (l_saov_rec.attribute3 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute3 := NULL;
    END IF;
    IF (l_saov_rec.attribute4 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute4 := NULL;
    END IF;
    IF (l_saov_rec.attribute5 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute5 := NULL;
    END IF;
    IF (l_saov_rec.attribute6 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute6 := NULL;
    END IF;
    IF (l_saov_rec.attribute7 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute7 := NULL;
    END IF;
    IF (l_saov_rec.attribute8 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute8 := NULL;
    END IF;
    IF (l_saov_rec.attribute9 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute9 := NULL;
    END IF;
    IF (l_saov_rec.attribute10 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute10 := NULL;
    END IF;
    IF (l_saov_rec.attribute11 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute11 := NULL;
    END IF;
    IF (l_saov_rec.attribute12 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute12 := NULL;
    END IF;
    IF (l_saov_rec.attribute13 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute13 := NULL;
    END IF;
    IF (l_saov_rec.attribute14 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute14 := NULL;
    END IF;
    IF (l_saov_rec.attribute15 = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.attribute15 := NULL;
    END IF;
    IF (l_saov_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.org_id := NULL;
    END IF;
    IF (l_saov_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.created_by := NULL;
    END IF;
    IF (l_saov_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_saov_rec.creation_date := NULL;
    END IF;
    IF (l_saov_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.last_updated_by := NULL;
    END IF;
    IF (l_saov_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_saov_rec.last_update_date := NULL;
    END IF;
    IF (l_saov_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.last_update_login := NULL;
    END IF;
    /* Changed made by Kanti on 06/22/2001. These two fields were added in the table
       and to make the TAPI consistent, these fields are being added here */
    IF (l_saov_rec.cc_apply_rounding_difference = Okc_Api.G_MISS_CHAR) THEN
          l_saov_rec.cc_apply_rounding_difference := NULL;
    END IF;
    IF (l_saov_rec.ael_apply_rounding_difference = Okc_Api.G_MISS_CHAR) THEN
              l_saov_rec.ael_apply_rounding_difference := NULL;
    END IF;
    /* Changes end here   */
    IF (l_saov_rec.accrual_reversal_days = Okc_Api.G_MISS_NUM) THEN
              l_saov_rec.accrual_reversal_days := NULL;
    END IF;

-- Added new field lke_hold_days for the bug 2331564 by Santonyr
    IF (l_saov_rec.lke_hold_days = Okc_Api.G_MISS_NUM) THEN
              l_saov_rec.lke_hold_days := NULL;
    END IF;

-- Added by Keerthi 10-Sep-2003 for Rounding of Amounts in Streams
   IF (l_saov_rec.stm_apply_rounding_difference = Okc_Api.G_MISS_CHAR) THEN
              l_saov_rec.stm_apply_rounding_difference := NULL;
   END IF;

    IF (l_saov_rec.stm_rounding_rule = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.stm_rounding_rule := NULL;
    END IF;

    /*Added new field for bug 4884618(H) */
    IF (l_saov_rec.validate_khr_start_date = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.validate_khr_start_date := NULL;
    END IF;
    -- R12 SLA Uptake;
    IF (l_saov_rec.account_derivation = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.account_derivation := NULL;
    END IF;
     IF (l_saov_rec.isg_arrears_pay_dates_option = Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.isg_arrears_pay_dates_option := NULL;
    END IF;
     IF (l_saov_rec.PAY_DIST_SET_ID = Okc_Api.G_MISS_NUM) THEN
      l_saov_rec.PAY_DIST_SET_ID := NULL;
    END IF;
    IF (l_saov_rec.SECONDARY_REP_METHOD = Okc_Api.G_MISS_CHAR) THEN     --Bug#7225249
      l_saov_rec.SECONDARY_REP_METHOD := NULL;
    END IF;

    --Bug# 8370699
    IF (l_saov_rec.amort_inc_adj_rev_dt_yn= Okc_Api.G_MISS_CHAR) THEN
      l_saov_rec.amort_inc_adj_rev_dt_yn:= NULL;
    END IF;

    RETURN(l_saov_rec);
  END null_out_defaults;

  -- START change : mvasudev , 05/02/2001
  /*
  -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Attributes
    ---------------------------------------------------------------------------
    -------------------------------------------------
    -- Validate_Attributes for:OKL_SYS_ACCT_OPTS_V --
    -------------------------------------------------
    FUNCTION Validate_Attributes (
      p_saov_rec IN  saov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      IF p_saov_rec.id = OKC_API.G_MISS_NUM OR
         p_saov_rec.id IS NULL
      THEN
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
        l_return_status := OKC_API.G_RET_STS_ERROR;
      ELSIF p_saov_rec.object_version_number = OKC_API.G_MISS_NUM OR
            p_saov_rec.object_version_number IS NULL
      THEN
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
        l_return_status := OKC_API.G_RET_STS_ERROR;
      ELSIF p_saov_rec.set_of_books_id = OKC_API.G_MISS_NUM OR
            p_saov_rec.set_of_books_id IS NULL
      THEN
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'set_of_books_id');
        l_return_status := OKC_API.G_RET_STS_ERROR;
      ELSIF p_saov_rec.CC_REP_CURRENCY_CODE = OKC_API.G_MISS_CHAR OR
            p_saov_rec.CC_REP_CURRENCY_CODE IS NULL
      THEN
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CC_REP_CURRENCY_CODE');
        l_return_status := OKC_API.G_RET_STS_ERROR;
      ELSIF p_saov_rec.AEL_REP_CURRENCY_CODE = OKC_API.G_MISS_CHAR OR
            p_saov_rec.AEL_REP_CURRENCY_CODE IS NULL
      THEN
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'AEL_REP_CURRENCY_CODE');
        l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

      RETURN(l_return_status);
    END Validate_Attributes;
  */

  /**
  * Adding Individual Procedures for each Attribute that
  * needs to be validated
  */
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Id(
    p_saov_rec      IN   saov_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_saov_rec.id = Okc_Api.G_MISS_NUM OR
       p_saov_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_sec_rep_mthd
  ---------------------------------------------------------------------------

  PROCEDURE validate_sec_rep_mthd(
    p_saov_rec      IN   saov_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy varchar2(1);

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_saov_rec.SECONDARY_REP_METHOD <>  Okc_Api.G_MISS_CHAR) AND
       (p_saov_rec.SECONDARY_REP_METHOD IS NOT NULL)
    THEN
    l_dummy
          := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_SEC_REP_METHOD',
                                       p_lookup_code => p_saov_rec.SECONDARY_REP_METHOD);

    IF (l_dummy = Okc_Api.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'SECONDARY_REP_METHOD');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END validate_sec_rep_mthd;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_AEL_APPLY_ROUND_DIFF
  ---------------------------------------------------------------------------

  PROCEDURE validate_ael_apply_round_diff(
    p_saov_rec      IN   saov_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  l_dummy varchar2(1);

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_saov_rec.AEL_APPLY_ROUNDING_DIFFERENCE <>  Okc_Api.G_MISS_CHAR ) AND
       (p_saov_rec.AEL_APPLY_ROUNDING_DIFFERENCE IS NOT NULL) THEN

       l_dummy
          := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_APPLY_ROUNDING_DIFF',
                                       p_lookup_code => p_saov_rec.ael_apply_rounding_difference);

       IF (l_dummy = Okc_Api.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'AEL_APPLY_ROUNDING_DIFFERENCE');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END validate_ael_apply_round_diff;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_CC_APPLY_ROUND_DIFF
  ---------------------------------------------------------------------------


  PROCEDURE validate_cc_apply_round_diff(

    p_saov_rec      IN   saov_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy varchar2(1);

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_saov_rec.CC_APPLY_ROUNDING_DIFFERENCE <>  Okc_Api.G_MISS_CHAR) AND
       (p_saov_rec.CC_APPLY_ROUNDING_DIFFERENCE IS NOT NULL)
    THEN
    l_dummy
          := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_APPLY_ROUNDING_DIFF',
                                       p_lookup_code => p_saov_rec.cc_apply_rounding_difference);

    IF (l_dummy = Okc_Api.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'CC_APPLY_ROUNDING_DIFFERENCE');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END validate_cc_apply_round_diff;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(
    p_saov_rec      IN   saov_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_saov_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_saov_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;
  -- R12 SLA Uptake: Begin
  -- Commenting the validate_set_of_books_id API as this column is obsoleted
  /*
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Set_Of_Books_Id
  ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_Set_Of_Books_Id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Set_Of_Books_Id(
      p_saov_rec      IN   saov_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS

    l_dummy_var        VARCHAR2(1)  := '?';

    BEGIN
      -- initialize return status
      x_return_status := Okc_Api.G_RET_STS_SUCCESS;

      -- check for data before processing
      IF (p_saov_rec.set_of_books_id IS NULL) OR
         (p_saov_rec.set_of_books_id = Okc_Api.G_MISS_NUM) THEN
         Okc_Api.SET_MESSAGE(p_app_name       => G_APP_NAME
                            ,p_msg_name       => G_REQUIRED_VALUE
                            ,p_token1         => G_COL_NAME_TOKEN
                            ,p_token1_value   => 'SET_OF_BOOKS_ID');
         x_return_status    := Okc_Api.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Set_Of_Books_Id;
    */
    -- R12 SLA Uptake: End

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_CC_REP_CURRENCY_CODE
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_CC_REP_CURRENCY_CODE
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_CC_REP_CURRENCY_CODE(
      p_saov_rec      IN   saov_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS

    l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

    BEGIN

      x_return_status := Okc_Api.G_RET_STS_SUCCESS;

      -- check for data before processing
      IF (p_saov_rec.cc_rep_currency_code IS NOT NULL) AND
         (p_saov_rec.cc_rep_currency_code <> Okc_Api.G_MISS_CHAR) THEN
     l_dummy := OKL_ACCOUNTING_UTIL.validate_currency_code(p_saov_rec.cc_rep_currency_code);

     IF (l_dummy = okc_api.g_false) THEN
         Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'CC_REP_CURRENCY_CODE');
         x_return_status := Okc_Api.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    END IF;


    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;

      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END validate_cc_rep_currency_code;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_AEL_REP_CURRENCY_CODE
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_AEL_REP_CURRENCY_CODE
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_AEL_REP_CURRENCY_CODE(
      p_saov_rec      IN   saov_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

    BEGIN
      -- initialize return status
      x_return_status := Okc_Api.G_RET_STS_SUCCESS;

      -- check for data before processing
      IF (p_saov_rec.ael_rep_currency_code IS NOT NULL) AND
         (p_saov_rec.ael_rep_currency_code  <> Okc_Api.G_MISS_CHAR) THEN

      l_dummy := OKL_ACCOUNTING_UTIL.validate_currency_code(p_saov_rec.ael_rep_currency_code);


      IF (l_dummy = okc_api.g_false) THEN
         Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'AEL_REP_CURRENCY_CODE');
         x_return_status := Okc_Api.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    END IF;

    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;

      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END validate_ael_rep_currency_code;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Accrual_Rev_days
  ---------------------------------------------------------------------------

  PROCEDURE validate_Accrual_rev_Days(
    p_saov_rec      IN   saov_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  l_dummy varchar2(1);

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_saov_rec.accrual_reversal_days = Okc_Api.G_MISS_NUM ) OR
       (p_saov_rec.accrual_reversal_days IS NULL) THEN

         Okc_Api.SET_MESSAGE(p_app_name       => G_APP_NAME
                            ,p_msg_name       => G_REQUIRED_VALUE
                            ,p_token1         => G_COL_NAME_TOKEN
                            ,p_token1_value   => 'Accrual Reversal Days');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

--Bug 6413291 dpsingh
    IF p_saov_rec.accrual_reversal_days <>ABS(TRUNC (p_saov_rec.accrual_reversal_days)) THEN
      OKL_API.SET_MESSAGE (p_app_name => Okl_Api.G_APP_NAME, p_msg_name => 'OKL_FIN_OP_INVALID');
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END validate_accrual_rev_days;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_CC_APPLY_ROUND_DIFF



    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_All_Ccid
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_All_Ccid
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_All_Ccid(
      p_saov_rec      IN   saov_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS

    l_dummy    VARCHAR2(1) := OKC_API.G_FALSE;

    BEGIN

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- Validate CODE_COMBINATION_ID

      IF (p_saov_rec.code_combination_id IS NOT NULL) AND
         (p_saov_rec.code_combination_id <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.code_combination_id);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'REC_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate REC_CCID

      IF (p_saov_rec.rec_ccid IS NOT NULL) AND (p_saov_rec.Rec_ccid <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.REC_CCID);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'REC_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate Realized_Gain_CCID

      IF (p_saov_rec.realized_gain_CCID IS NOT NULL) AND
         (p_saov_rec.realized_gain_CCID <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.Realized_gain_CCID);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'REALIZED_GAIN_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate Realized_loss_CCID

      IF (p_saov_rec.realized_loss_CCID IS NOT NULL) AND
         (p_saov_rec.realized_loss_CCID <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.realized_loss_CCID);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'realized_loss_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate Tax_CCID
      IF (p_saov_rec.tax_ccid IS NOT NULL) AND (p_saov_rec.tax_ccid <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.tax_ccid);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'tax_ccid');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate Cross_Currency_CCID

      IF (p_saov_rec.cross_currency_CCID IS NOT NULL) AND
         (p_saov_rec.cross_currency_CCID <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.cross_currency_CCID);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'cross_currency_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate Rounding_CCID

      IF (p_saov_rec.rounding_CCID IS NOT NULL) AND
         (p_saov_rec.rounding_CCID <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.rounding_CCID);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'rounding_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate AR_CLEARING_CCID

      IF (p_saov_rec.AR_CLEARING_CCID IS NOT NULL) AND
         (p_saov_rec.AR_CLEARING_CCID <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.AR_CLEARING_CCID);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'AR_CLEARING_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate PAYABLES_CCID

      IF (p_saov_rec.PAYABLES_CCID IS NOT NULL) AND
         (p_saov_rec.PAYABLES_CCID <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.PAYABLES_CCID);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'PAYABLES_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate LIABLITY_CCID

      IF (p_saov_rec.liablity_ccid IS NOT NULL) AND
         (p_saov_rec.liablity_ccid <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.liablity_ccid);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'liablity_ccid');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate PRE_PAYMENT_CCID

      IF (p_saov_rec.pre_payment_ccid IS NOT NULL) AND
         (p_saov_rec.pre_payment_ccid <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.pre_payment_ccid);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'pre_payment_ccid');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;



-- Validate FUT_DATE_PAY_CCID

      IF (p_saov_rec.fut_date_pay_CCID IS NOT NULL) AND
         (p_saov_rec.fut_date_pay_CCID <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.fut_date_pay_CCID);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'fut_date_pay_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;


-- Validate DIS_TAKEN_CCID

      IF (p_saov_rec.DIS_TAKEN_CCID IS NOT NULL) AND
         (p_saov_rec.DIS_TAKEN_CCID <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.DIS_TAKEN_CCID);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'DIS_TAKEN_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

-- Validate AP_CLEARING_CCID

      IF (p_saov_rec.AR_CLEARING_CCID IS NOT NULL) AND
         (p_saov_rec.AR_CLEARING_CCID <> OKC_API.G_MISS_NUM) THEN
      	  l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_saov_rec.AR_CLEARING_CCID);
          IF (l_dummy = okc_api.g_false) THEN
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'AR_CLEARING_CCID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      IF (x_return_Status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;


    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;

      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    END validate_all_ccid;


    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Cc_Rounding_Rule
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_Cc_Rounding_Rule
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Cc_Rounding_Rule(
      p_saov_rec      IN   saov_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS

    l_dummy        VARCHAR2(1)  := OKC_API.G_FALSE;

    BEGIN

      -- initialize return status
      x_return_status := Okc_Api.G_RET_STS_SUCCESS;

      IF (p_saov_rec.cc_rounding_rule IS NOT NULL) THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_ROUNDING_RULE',
                                                    p_lookup_code => p_saov_rec.cc_rounding_rule);

      	 IF (l_dummy = OKC_API.G_FALSE) THEN
           Okc_Api.SET_MESSAGE(p_app_name       => G_APP_NAME
                              ,p_msg_name       => G_INVALID_VALUE
                              ,p_token1         => G_COL_NAME_TOKEN
                              ,p_token1_value   => 'CC_ROUNDING_RULE');
           x_return_status    := Okc_Api.G_RET_STS_ERROR;
      	END IF;
      END IF;

    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;

      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END validate_cc_rounding_rule;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Ael_Rounding_Rule
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_Ael_Rounding_Rule
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Ael_Rounding_Rule(
      p_saov_rec      IN   saov_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS

    l_dummy        VARCHAR2(1)  := OKC_API.G_FALSE;


    BEGIN
      -- initialize return status
      x_return_status := Okc_Api.G_RET_STS_SUCCESS;

      IF (p_saov_rec.ael_rounding_rule IS NOT NULL) AND
         (p_saov_rec.ael_rounding_rule <> OKC_API.G_MISS_CHAR)
      THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_ROUNDING_RULE',
                                     p_lookup_code => p_saov_rec.ael_rounding_rule);

      	 IF (l_dummy = OKC_API.G_FALSE) THEN

         Okc_Api.SET_MESSAGE(p_app_name       => G_APP_NAME
                            ,p_msg_name       => G_INVALID_VALUE
                            ,p_token1         => G_COL_NAME_TOKEN
                            ,p_token1_value   => 'ael_rounding_rule');
         x_return_status    := Okc_Api.G_RET_STS_ERROR;
      	END IF;
      END IF;

    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;

      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

        -- verify that the cursor was closed
    END validate_ael_rounding_rule;


-- Added new field lke_hold_days for the bug 2331564 by Santonyr

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Lke_Hold_Days
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Lke_Hold_Days
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Lke_Hold_Days(
    p_saov_rec      IN   saov_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_saov_rec.lke_hold_days = Okc_Api.G_MISS_NUM OR
       p_saov_rec.lke_hold_days IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'lke_hold_days');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--Bug 6413291 dpsingh
   IF p_saov_rec.lke_hold_days <>ABS(TRUNC (p_saov_rec.lke_hold_days)) THEN
      OKL_API.SET_MESSAGE (p_app_name => Okl_Api.G_APP_NAME, p_msg_name => 'OKL_LKE_HOLD_DAYS_INVALID');
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END validate_lke_hold_days;


   ---------------------------------------------------------------------------
  -- PROCEDURE Validate_sTM_APPLY_ROUND_DIFF
  ---------------------------------------------------------------------------

  PROCEDURE validate_stm_apply_round_diff(
    p_saov_rec      IN   saov_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  l_dummy varchar2(1);

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_saov_rec.STM_APPLY_ROUNDING_DIFFERENCE <>  Okc_Api.G_MISS_CHAR ) AND
       (p_saov_rec.STM_APPLY_ROUNDING_DIFFERENCE IS NOT NULL) THEN

       l_dummy
          := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_STRM_APPLY_ROUNDING_DIFF',
                                       p_lookup_code => p_saov_rec.stm_apply_rounding_difference);

       IF (l_dummy = Okc_Api.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'STM_APPLY_ROUNDING_DIFFERENCE');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END validate_stm_apply_round_diff;


    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Stm_Rounding_Rule
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_Stm_Rounding_Rule
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Stm_Rounding_Rule(
      p_saov_rec      IN   saov_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS

    l_dummy        VARCHAR2(1)  := OKC_API.G_FALSE;


    BEGIN
      -- initialize return status
      x_return_status := Okc_Api.G_RET_STS_SUCCESS;

      IF (p_saov_rec.stm_rounding_rule IS NOT NULL) AND
         (p_saov_rec.stm_rounding_rule <> OKC_API.G_MISS_CHAR)
      THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_ROUNDING_RULE',
                                     p_lookup_code => p_saov_rec.stm_rounding_rule);

      	 IF (l_dummy = OKC_API.G_FALSE) THEN

         Okc_Api.SET_MESSAGE(p_app_name       => G_APP_NAME
                            ,p_msg_name       => G_INVALID_VALUE
                            ,p_token1         => G_COL_NAME_TOKEN
                            ,p_token1_value   => 'stm_rounding_rule');
         x_return_status    := Okc_Api.G_RET_STS_ERROR;
      	END IF;
      END IF;

    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;

      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

        -- verify that the cursor was closed
    END validate_stm_rounding_rule;

---------------------------------------------------------------------------
     -- PROCEDURE validate_arrears_pay_dt_opt
     ---------------------------------------------------------------------------

     PROCEDURE validate_arrears_pay_dt_opt(
       p_saov_rec      IN   saov_rec_type,
       x_return_status OUT NOCOPY  VARCHAR2
     ) IS
     l_dummy varchar2(1);

     BEGIN
       -- initialize return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;

       IF (p_saov_rec.ISG_ARREARS_PAY_DATES_OPTION <>  Okc_Api.G_MISS_CHAR ) AND
          (p_saov_rec.ISG_ARREARS_PAY_DATES_OPTION IS NOT NULL) THEN

          l_dummy
             := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_ISG_ARREAR_PAY_DATE_OPTION',
                                          p_lookup_code => p_saov_rec.isg_arrears_pay_dates_option);

          IF (l_dummy = Okc_Api.G_FALSE) THEN
             Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'ISG_ARREARS_PAY_DATES_OPTION');
             x_return_status    := Okc_Api.G_RET_STS_ERROR;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

       END IF;

     EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- no processing necessary; validation can continue
       -- with the next column
       NULL;

       WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

         -- notify caller of an UNEXPECTED error
         x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

     END validate_arrears_pay_dt_opt;

     --Bug# 8370699
     ---------------------------------------------------------------------------
     -- PROCEDURE validate_amort_inc_adj_rev_dt
     ---------------------------------------------------------------------------
     -- Start of comments
     --
     -- Procedure Name  : validate_amort_inc_adj_rev_dt
     -- Description     :
     -- Business Rules  :
     -- Parameters      :
     -- Version         : 1.0
     -- End of comments
     ---------------------------------------------------------------------------
     ---------------------------------------------------------------------------
     -- PROCEDURE validate_amort_inc_adj_rev_dt
     ---------------------------------------------------------------------------

     PROCEDURE validate_amort_inc_adj_rev_dt(
       p_saov_rec      IN   saov_rec_type,
       x_return_status OUT NOCOPY  VARCHAR2
     ) IS
     l_dummy varchar2(1);

     BEGIN
       -- initialize return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;

       IF (p_saov_rec.AMORT_INC_ADJ_REV_DT_YN <>  Okc_Api.G_MISS_CHAR ) AND
          (p_saov_rec.AMORT_INC_ADJ_REV_DT_YN IS NOT NULL) THEN

          l_dummy
             := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_YES_NO',
                                          p_lookup_code => p_saov_rec.amort_inc_adj_rev_dt_yn);

          IF (l_dummy = Okc_Api.G_FALSE) THEN
             Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'AMORT_INC_ADJ_REV_DT_YN');
             x_return_status    := Okc_Api.G_RET_STS_ERROR;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

       END IF;

     EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- no processing necessary; validation can continue
       -- with the next column
       NULL;

       WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

         -- notify caller of an UNEXPECTED error
         x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

     END validate_amort_inc_adj_rev_dt;
     --Bug# 8370699

     --Bug 4884618(H)
     ---------------------------------------------------------------------------
     -- PROCEDURE validate_KHR_START_DATE
     ---------------------------------------------------------------------------

     PROCEDURE validate_khr_start_date(

       p_saov_rec      IN   saov_rec_type,
       x_return_status OUT NOCOPY  VARCHAR2
     ) IS

     l_dummy varchar2(1);

     BEGIN
       -- initialize return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;

       IF (p_saov_rec.VALIDATE_KHR_START_DATE <>  Okc_Api.G_MISS_CHAR) AND
          (p_saov_rec.VALIDATE_KHR_START_DATE IS NOT NULL)
       THEN
       l_dummy
             := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_ACCRUAL_STREAMS_BASIS',
                                          p_lookup_code => p_saov_rec.validate_khr_start_date);

       IF (l_dummy = Okc_Api.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'VALIDATE_KHR_START_DATE');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
     END IF;

     EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- no processing necessary; validation can continue
       -- with the next column
       NULL;

       WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

         -- notify caller of an UNEXPECTED error
         x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

     END validate_khr_start_date;
--Bug 4884618(H) end

---------------------------------------------------------------------------
    -- PROCEDURE validate_account_derivation
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : validate_account_derivation
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE validate_account_derivation(
      p_saov_rec      IN   saov_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy        VARCHAR2(1)  := OKC_API.G_FALSE;
    BEGIN
      -- Initialise the return Status
      x_return_status := Okc_Api.G_RET_STS_SUCCESS;
      IF (p_saov_rec.account_derivation IS NOT NULL) AND
         (p_saov_rec.account_derivation <> OKC_API.G_MISS_CHAR)
      THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(
                       p_lookup_type => 'OKL_ACCOUNT_DERIVATION_OPTION',
                       p_lookup_code => p_saov_rec.account_derivation);
      	 IF (l_dummy = OKC_API.G_FALSE)
         THEN
           Okc_Api.SET_MESSAGE(p_app_name       => G_APP_NAME
                              ,p_msg_name       => G_INVALID_VALUE
                              ,p_token1         => G_COL_NAME_TOKEN
                              ,p_token1_value   => 'ACCOUNT_DERIVATION');
           x_return_status    := Okc_Api.G_RET_STS_ERROR;
      	END IF;
      END IF;
    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION
      THEN
            NULL;
      WHEN OTHERS
      THEN
        Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_account_derivation;
    ---------------------------------------------------------------------------
    -- PROCEDURE validate_pay_dist_set
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : validate_pay_dist_set
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
           PROCEDURE validate_pay_dist_set(
       p_saov_rec      IN   saov_rec_type,
       x_return_status OUT NOCOPY  VARCHAR2
     ) IS
     l_dummy NUMBER;
     Cursor ValidDistsetId_csr ( distsetid p_saov_rec.PAY_DIST_SET_ID%TYPE )is
     select 1 from  AP_DISTRIBUTION_SETS where DISTRIBUTION_SET_ID = distsetid ;

     BEGIN
       -- initialize return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;

       IF (p_saov_rec.PAY_DIST_SET_ID  <>  Okc_Api.G_MISS_NUM ) AND
          (p_saov_rec.PAY_DIST_SET_ID  IS NOT NULL) THEN
          open ValidDistsetId_csr (p_saov_rec.PAY_DIST_SET_ID );
           FETCH ValidDistsetId_csr INTO l_dummy;
           CLOSE ValidDistsetId_csr;
                 IF (l_dummy <> 1) THEN
             Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                            ,p_msg_name       => 'OKL_SETUP_ACCT_PAY_DST_INVALID'
                             );
             x_return_status    := Okc_Api.G_RET_STS_ERROR;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;


          END IF ;
          IF(p_saov_rec.account_derivation='AMB' AND (p_saov_rec.PAY_DIST_SET_ID IS NULL OR p_saov_rec.PAY_DIST_SET_ID  = Okc_Api.G_MISS_NUM )) THEN
            Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                            ,p_msg_name       => 'OKL_SETUP_ACCT_PAY_DST_RQD'
                            );
             x_return_status    := Okc_Api.G_RET_STS_ERROR;
             RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;


     EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- no processing necessary; validation can continue
       -- with the next column
       NULL;

       WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

         -- notify caller of an UNEXPECTED error
         x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

     END validate_pay_dist_set;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_saov_rec IN  saov_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    -- Validate_Id
    Validate_Id(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    validate_sec_rep_mthd(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    validate_ael_apply_round_diff(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    validate_cc_apply_round_diff(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_CC_REP_CURRENCY_CODE
    Validate_CC_REP_CURRENCY_CODE(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_AEL_REP_CURRENCY_CODE
    Validate_AEL_REP_CURRENCY_CODE(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- validate_Accrual_rev_days
    validate_Accrual_rev_days(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;
   -- R12 SLA Uptake: Begin
   -- Commenting the validate_set_of_book_id API as this column is obsoleted now.
   /*
    Validate_Set_Of_Books_Id(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;
   */
   -- R12 SLA Uptake: End

    -- Validate_All_Ccid

    Validate_All_Ccid(p_saov_rec, x_return_status);

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;

       END IF;

    END IF;


    -- Validate_Cc_Rounding_Rule

    Validate_Cc_Rounding_Rule(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Ael_Rounding_Rule
    Validate_Ael_Rounding_Rule(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

-- Added new field lke_hold_days for the bug 2331564 by Santonyr
    Validate_Lke_Hold_Days (p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

-- Validate Stm_apply_round_diff
    validate_stm_apply_round_diff(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

-- Validate Stm_Rounding_Rule
    Validate_Stm_Rounding_Rule(p_saov_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    /*Added new field validation for bug 4884618(H) */
   --validate validate_khr_start_date
       validate_khr_start_date(p_saov_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             -- need to exit
             l_return_status := x_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             -- there was an error
             l_return_status := x_return_status;
          END IF;
       END IF;
       -- R12 SLA Uptake: Begin
       validate_account_derivation(p_saov_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS)
       THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR)
          THEN
             -- Raise the exception
             l_return_status := x_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             l_return_status := x_return_status;
          END IF;
       END IF;
       -- R12 SLA Uptake: End

       validate_arrears_pay_dt_opt(p_saov_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             -- need to exit
             l_return_status := x_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             -- there was an error
             l_return_status := x_return_status;
          END IF;
       END IF;
           validate_pay_dist_set(p_saov_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             -- need to exit
             l_return_status := x_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             -- there was an error
             l_return_status := x_return_status;
          END IF;
       END IF;

       --Bug# 8370699
       --validate amort_inc_adj_rev_dt_yn
       validate_amort_inc_adj_rev_dt(p_saov_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             -- need to exit
             l_return_status := x_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             -- there was an error
             l_return_status := x_return_status;
          END IF;
       END IF;

    RETURN(l_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN(l_return_status);
  END validate_attributes;
  -- END change : mvasudev

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_SYS_ACCT_OPTS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_saov_rec IN saov_rec_type
  ) RETURN VARCHAR2 IS
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN saov_rec_type,
-- START change : mvasudev, 05/15/2001
-- Changed OUT parameter to IN OUT
--  p_to	OUT NOCOPY sao_rec_type
    p_to	IN OUT NOCOPY sao_rec_type
-- END change : mvasudev
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cc_rep_currency_code := p_from.cc_rep_currency_code;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.ael_rep_currency_code := p_from.ael_rep_currency_code;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.rec_ccid := p_from.rec_ccid;
    p_to.realized_gain_ccid := p_from.realized_gain_ccid;
    p_to.realized_loss_ccid := p_from.realized_loss_ccid;
    p_to.tax_ccid := p_from.tax_ccid;
    p_to.cross_currency_ccid := p_from.cross_currency_ccid;
    p_to.rounding_ccid := p_from.rounding_ccid;
    p_to.ar_clearing_ccid := p_from.ar_clearing_ccid;
    p_to.payables_ccid := p_from.payables_ccid;
    p_to.liablity_ccid := p_from.liablity_ccid;
    p_to.pre_payment_ccid := p_from.pre_payment_ccid;
    p_to.fut_date_pay_ccid := p_from.fut_date_pay_ccid;
    p_to.cc_rounding_rule := p_from.cc_rounding_rule;
    p_to.cc_precision := p_from.cc_precision;
    p_to.cc_min_acct_unit := p_from.cc_min_acct_unit;
    p_to.dis_taken_ccid := p_from.dis_taken_ccid;
    p_to.ap_clearing_ccid := p_from.ap_clearing_ccid;
    p_to.ael_rounding_rule := p_from.ael_rounding_rule;
    p_to.ael_precision := p_from.ael_precision;
    p_to.ael_min_acct_unit := p_from.ael_min_acct_unit;
    p_to.org_id := p_from.org_id;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    /*  Changes done by Kanti on 06/21/2001. The following two fields added to make it
        consistent with the database */
    p_to.cc_apply_rounding_difference := p_from.cc_apply_rounding_difference;
    p_to.ael_apply_rounding_difference := p_from.ael_apply_rounding_difference;
    p_to.accrual_reversal_days := p_from.accrual_reversal_days;
    /*  Changes end here */
-- Added new field lke_hold_days for the bug 2331564 by Santonyr
    p_to.lke_hold_days := p_from.lke_hold_days;
--Added by Keerthi 10-Sep-2003 for Rounding of Amounts in Streams
    p_to.stm_apply_rounding_difference := p_from.stm_apply_rounding_difference;
    p_to.stm_rounding_rule := p_from.stm_rounding_rule;
    --Added new field for bug 4884618(H)
    p_to.validate_khr_start_date := p_from.validate_khr_start_date;
    -- R12 SLA Uptake
    p_to.account_derivation := p_from.account_derivation;
    p_to.isg_arrears_pay_dates_option := p_from.isg_arrears_pay_dates_option;
    p_to.PAY_DIST_SET_ID              :=p_from.PAY_DIST_SET_ID;
    p_to.SECONDARY_REP_METHOD := p_from.SECONDARY_REP_METHOD;    --Bug#7225249
    --Bug# 8370699
    p_to.amort_inc_adj_rev_dt_yn := p_from.amort_inc_adj_rev_dt_yn;

  END migrate;
  PROCEDURE migrate (
    p_from	IN sao_rec_type,
    -- START change : mvasudev, 05/15/2001
    -- Changed OUT parameter to IN OUT
    --  p_to	OUT NOCOPY saov_rec_type
    p_to	IN OUT NOCOPY saov_rec_type
    -- END change : mvasudev
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cc_rep_currency_code := p_from.cc_rep_currency_code;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.ael_rep_currency_code := p_from.ael_rep_currency_code;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.rec_ccid := p_from.rec_ccid;
    p_to.realized_gain_ccid := p_from.realized_gain_ccid;
    p_to.realized_loss_ccid := p_from.realized_loss_ccid;
    p_to.tax_ccid := p_from.tax_ccid;
    p_to.cross_currency_ccid := p_from.cross_currency_ccid;
    p_to.rounding_ccid := p_from.rounding_ccid;
    p_to.ar_clearing_ccid := p_from.ar_clearing_ccid;
    p_to.payables_ccid := p_from.payables_ccid;
    p_to.liablity_ccid := p_from.liablity_ccid;
    p_to.pre_payment_ccid := p_from.pre_payment_ccid;
    p_to.fut_date_pay_ccid := p_from.fut_date_pay_ccid;
    p_to.cc_rounding_rule := p_from.cc_rounding_rule;
    p_to.cc_precision := p_from.cc_precision;
    p_to.cc_min_acct_unit := p_from.cc_min_acct_unit;
    p_to.dis_taken_ccid := p_from.dis_taken_ccid;
    p_to.ap_clearing_ccid := p_from.ap_clearing_ccid;
    p_to.ael_rounding_rule := p_from.ael_rounding_rule;
    p_to.ael_precision := p_from.ael_precision;
    p_to.ael_min_acct_unit := p_from.ael_min_acct_unit;
    p_to.org_id := p_from.org_id;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    /*  Changes done by Kanti on 06/21/2001. The following two fields added to make it
            consistent with the database */
    p_to.cc_apply_rounding_difference := p_from.cc_apply_rounding_difference;
    p_to.ael_apply_rounding_difference := p_from.ael_apply_rounding_difference;
    /*  Changes end here */
    p_to.accrual_reversal_days := p_from.accrual_reversal_days;
-- Added new field lke_hold_days for the bug 2331564 by Santonyr
    p_to.lke_hold_days := p_from.lke_hold_days;
--Added by Keerthi 10-Sep-2003 for Rounding of Amounts in Streams
    p_to.stm_apply_rounding_difference := p_from.stm_apply_rounding_difference;
    p_to.stm_rounding_rule := p_from.stm_rounding_rule;
    -- Added new field for bug 4884618(H)
    p_to.validate_khr_start_date := p_from.validate_khr_start_date;
    -- R12 SLA Uptake
    p_to.account_derivation := p_from.account_derivation;
    p_to.isg_arrears_pay_dates_option := p_from.isg_arrears_pay_dates_option;
    p_to.PAY_DIST_SET_ID:=p_from.PAY_DIST_SET_ID;
    p_to.SECONDARY_REP_METHOD := p_from.SECONDARY_REP_METHOD;
    --Bug# 8370699
    p_to.amort_inc_adj_rev_dt_yn := p_from.amort_inc_adj_rev_dt_yn;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_SYS_ACCT_OPTS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_rec                     IN saov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_saov_rec                     saov_rec_type := p_saov_rec;
    l_sao_rec                      sao_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_saov_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_saov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:SAOV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_tbl                     IN saov_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saov_tbl.COUNT > 0) THEN
      i := p_saov_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saov_rec                     => p_saov_tbl(i));
	-- START change : mvasudev, 05/15/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	    	l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_saov_tbl.LAST);
        i := p_saov_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 05/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- insert_row for:OKL_SYS_ACCT_OPTS --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sao_rec                      IN sao_rec_type,
    x_sao_rec                      OUT NOCOPY sao_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_sao_rec                      sao_rec_type := p_sao_rec;
    l_def_sao_rec                  sao_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_SYS_ACCT_OPTS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_sao_rec IN  sao_rec_type,
      x_sao_rec OUT NOCOPY sao_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sao_rec := p_sao_rec;
      RETURN(l_return_status);
    END set_attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sao_rec,                         -- IN
      l_sao_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SYS_ACCT_OPTS(
        id,
        cc_rep_currency_code,
        code_combination_id,
        ael_rep_currency_code,
        set_of_books_id,
        object_version_number,
        rec_ccid,
        realized_gain_ccid,
        realized_loss_ccid,
        tax_ccid,
        cross_currency_ccid,
        rounding_ccid,
        ar_clearing_ccid,
        payables_ccid,
        liablity_ccid,
        pre_payment_ccid,
        fut_date_pay_ccid,
        cc_rounding_rule,
        cc_precision,
        cc_min_acct_unit,
        dis_taken_ccid,
        ap_clearing_ccid,
        ael_rounding_rule,
        ael_precision,
        ael_min_acct_unit,
        org_id,
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
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        /*changes made by Kanti on 06/21/2001 to make it consistent with database*/
        cc_apply_rounding_difference,
        ael_apply_rounding_difference,
        /*changes end here*/
        accrual_reversal_days ,
-- Added new field lke_hold_days for the bug 2331564 by Santonyr
        lke_hold_days,
--Added by Keerthi 10-Sep-2003 for Rounding of Amounts in Streams
        stm_apply_rounding_difference,
        stm_rounding_rule
	/*Added new field for bug 4884618(H) */
        ,validate_khr_start_date
        ,account_derivation -- R12 SLA Uptake
        ,isg_arrears_pay_dates_option
        ,PAY_DIST_SET_ID
        ,SECONDARY_REP_METHOD               --Bug#7225249
        --Bug# 8370699
        ,amort_inc_adj_rev_dt_yn
        )
      VALUES (
        l_sao_rec.id,
        l_sao_rec.cc_rep_currency_code,
        l_sao_rec.code_combination_id,
        l_sao_rec.ael_rep_currency_code,
        l_sao_rec.set_of_books_id,
        l_sao_rec.object_version_number,
        l_sao_rec.rec_ccid,
        l_sao_rec.realized_gain_ccid,
        l_sao_rec.realized_loss_ccid,
        l_sao_rec.tax_ccid,
        l_sao_rec.cross_currency_ccid,
        l_sao_rec.rounding_ccid,
        l_sao_rec.ar_clearing_ccid,
        l_sao_rec.payables_ccid,
        l_sao_rec.liablity_ccid,
        l_sao_rec.pre_payment_ccid,
        l_sao_rec.fut_date_pay_ccid,
        l_sao_rec.cc_rounding_rule,
        l_sao_rec.cc_precision,
        l_sao_rec.cc_min_acct_unit,
        l_sao_rec.dis_taken_ccid,
        l_sao_rec.ap_clearing_ccid,
        l_sao_rec.ael_rounding_rule,
        l_sao_rec.ael_precision,
        l_sao_rec.ael_min_acct_unit,
        l_sao_rec.org_id,
        l_sao_rec.attribute_category,
        l_sao_rec.attribute1,
        l_sao_rec.attribute2,
        l_sao_rec.attribute3,
        l_sao_rec.attribute4,
        l_sao_rec.attribute5,
        l_sao_rec.attribute6,
        l_sao_rec.attribute7,
        l_sao_rec.attribute8,
        l_sao_rec.attribute9,
        l_sao_rec.attribute10,
        l_sao_rec.attribute11,
        l_sao_rec.attribute12,
        l_sao_rec.attribute13,
        l_sao_rec.attribute14,
        l_sao_rec.attribute15,
        l_sao_rec.created_by,
        l_sao_rec.creation_date,
        l_sao_rec.last_updated_by,
        l_sao_rec.last_update_date,
        l_sao_rec.last_update_login,
        /* CHange done by Kanti on 06.21.2001 to make it consistent with table  */
        l_sao_rec.cc_apply_rounding_difference,
        l_sao_rec.ael_apply_rounding_difference,
        /*changes end here  */
        l_sao_rec.accrual_reversal_days,
-- Added new field lke_hold_days for the bug 2331564 by Santonyr
        l_sao_rec.lke_hold_days,
--Added by Keerthi 10-Sep-2003 for Rounding of Amounts in Streams
        l_sao_rec.stm_apply_rounding_difference,
        l_sao_rec.stm_rounding_rule
	--Added new field for bug 4884618(H)
        ,l_sao_rec.validate_khr_start_date
        -- R12 SLA Uptake
        ,l_sao_rec.account_derivation
        ,l_sao_rec.isg_arrears_pay_dates_option
        ,l_sao_rec.PAY_DIST_SET_ID
        ,l_sao_rec.SECONDARY_REP_METHOD    --Bug#7225249
        -- Bug# 8370699
        ,l_sao_rec.amort_inc_adj_rev_dt_yn
        );
    -- Set OUT values
    x_sao_rec := l_sao_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_SYS_ACCT_OPTS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_rec                     IN saov_rec_type,
    x_saov_rec                     OUT NOCOPY saov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_saov_rec                     saov_rec_type;
    l_def_saov_rec                 saov_rec_type;
    l_sao_rec                      sao_rec_type;
    lx_sao_rec                     sao_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_saov_rec	IN saov_rec_type
    ) RETURN saov_rec_type IS
      l_saov_rec	saov_rec_type := p_saov_rec;
    BEGIN
      l_saov_rec.CREATION_DATE := SYSDATE;
      l_saov_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_saov_rec.LAST_UPDATE_DATE := SYSDATE;
      l_saov_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_saov_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_saov_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_SYS_ACCT_OPTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_saov_rec IN  saov_rec_type,
      x_saov_rec OUT NOCOPY saov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_saov_rec := p_saov_rec;
      x_saov_rec.OBJECT_VERSION_NUMBER := 1;
      x_saov_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();
      x_saov_rec.cc_rep_currency_code := 'USD';
      x_saov_rec.ael_rep_currency_code := 'USD';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_saov_rec := null_out_defaults(p_saov_rec);
    -- Set primary key value
    l_saov_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_saov_rec,                        -- IN
      l_def_saov_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_saov_rec := fill_who_columns(l_def_saov_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_saov_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_saov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_saov_rec, l_sao_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    -- Add : Bug 6441762 : dpsingh
      l_sao_rec.ael_apply_rounding_difference := 'ADD_NEW_LINE';

    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sao_rec,
      lx_sao_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sao_rec, l_def_saov_rec);
    -- Set OUT values
    x_saov_rec := l_def_saov_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:SAOV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_tbl                     IN saov_tbl_type,
    x_saov_tbl                     OUT NOCOPY saov_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saov_tbl.COUNT > 0) THEN
      i := p_saov_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saov_rec                     => p_saov_tbl(i),
          x_saov_rec                     => x_saov_tbl(i));
    	-- START change : mvasudev, 05/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_saov_tbl.LAST);
        i := p_saov_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 05/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- lock_row for:OKL_SYS_ACCT_OPTS --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sao_rec                      IN sao_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sao_rec IN sao_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SYS_ACCT_OPTS
     WHERE ID = p_sao_rec.id
       AND OBJECT_VERSION_NUMBER = p_sao_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sao_rec IN sao_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SYS_ACCT_OPTS
    WHERE ID = p_sao_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SYS_ACCT_OPTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SYS_ACCT_OPTS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_sao_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_sao_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sao_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sao_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_SYS_ACCT_OPTS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_rec                     IN saov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_sao_rec                      sao_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_saov_rec, l_sao_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sao_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:SAOV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_tbl                     IN saov_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saov_tbl.COUNT > 0) THEN
      i := p_saov_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saov_rec                     => p_saov_tbl(i));
    	-- START change : mvasudev, 05/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_saov_tbl.LAST);
        i := p_saov_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 05/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- update_row for:OKL_SYS_ACCT_OPTS --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sao_rec                      IN sao_rec_type,
    x_sao_rec                      OUT NOCOPY sao_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_sao_rec                      sao_rec_type := p_sao_rec;
    l_def_sao_rec                  sao_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sao_rec	IN sao_rec_type,
      x_sao_rec	OUT NOCOPY sao_rec_type
    ) RETURN VARCHAR2 IS
      l_sao_rec                      sao_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sao_rec := p_sao_rec;
      -- Get current database values
      l_sao_rec := get_rec(p_sao_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sao_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.id := l_sao_rec.id;
      END IF;
      IF (x_sao_rec.cc_rep_currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.cc_rep_currency_code := l_sao_rec.cc_rep_currency_code;
      END IF;
      IF (x_sao_rec.code_combination_id = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.code_combination_id := l_sao_rec.code_combination_id;
      END IF;
      IF (x_sao_rec.ael_rep_currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.ael_rep_currency_code := l_sao_rec.ael_rep_currency_code;
      END IF;
      IF (x_sao_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.set_of_books_id := l_sao_rec.set_of_books_id;
      END IF;
      IF (x_sao_rec.SECONDARY_REP_METHOD = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.SECONDARY_REP_METHOD := l_sao_rec.SECONDARY_REP_METHOD;
      END IF;
      IF (x_sao_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.object_version_number := l_sao_rec.object_version_number;
      END IF;
      IF (x_sao_rec.rec_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.rec_ccid := l_sao_rec.rec_ccid;
      END IF;
      IF (x_sao_rec.realized_gain_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.realized_gain_ccid := l_sao_rec.realized_gain_ccid;
      END IF;
      IF (x_sao_rec.realized_loss_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.realized_loss_ccid := l_sao_rec.realized_loss_ccid;
      END IF;
      IF (x_sao_rec.tax_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.tax_ccid := l_sao_rec.tax_ccid;
      END IF;
      IF (x_sao_rec.cross_currency_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.cross_currency_ccid := l_sao_rec.cross_currency_ccid;
      END IF;
      IF (x_sao_rec.rounding_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.rounding_ccid := l_sao_rec.rounding_ccid;
      END IF;
      IF (x_sao_rec.ar_clearing_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.ar_clearing_ccid := l_sao_rec.ar_clearing_ccid;
      END IF;
      IF (x_sao_rec.payables_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.payables_ccid := l_sao_rec.payables_ccid;
      END IF;
      IF (x_sao_rec.liablity_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.liablity_ccid := l_sao_rec.liablity_ccid;
      END IF;
      IF (x_sao_rec.pre_payment_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.pre_payment_ccid := l_sao_rec.pre_payment_ccid;
      END IF;
      IF (x_sao_rec.fut_date_pay_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.fut_date_pay_ccid := l_sao_rec.fut_date_pay_ccid;
      END IF;
      IF (x_sao_rec.cc_rounding_rule = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.cc_rounding_rule := l_sao_rec.cc_rounding_rule;
      END IF;
      IF (x_sao_rec.cc_precision = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.cc_precision := l_sao_rec.cc_precision;
      END IF;
      IF (x_sao_rec.cc_min_acct_unit = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.cc_min_acct_unit := l_sao_rec.cc_min_acct_unit;
      END IF;
      IF (x_sao_rec.dis_taken_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.dis_taken_ccid := l_sao_rec.dis_taken_ccid;
      END IF;
      IF (x_sao_rec.ap_clearing_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.ap_clearing_ccid := l_sao_rec.ap_clearing_ccid;
      END IF;
      IF (x_sao_rec.ael_rounding_rule = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.ael_rounding_rule := l_sao_rec.ael_rounding_rule;
      END IF;
      IF (x_sao_rec.ael_precision = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.ael_precision := l_sao_rec.ael_precision;
      END IF;
      IF (x_sao_rec.ael_min_acct_unit = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.ael_min_acct_unit := l_sao_rec.ael_min_acct_unit;
      END IF;
      IF (x_sao_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.org_id := l_sao_rec.org_id;
      END IF;
      IF (x_sao_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute_category := l_sao_rec.attribute_category;
      END IF;
      IF (x_sao_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute1 := l_sao_rec.attribute1;
      END IF;
      IF (x_sao_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute2 := l_sao_rec.attribute2;
      END IF;
      IF (x_sao_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute3 := l_sao_rec.attribute3;
      END IF;
      IF (x_sao_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute4 := l_sao_rec.attribute4;
      END IF;
      IF (x_sao_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute5 := l_sao_rec.attribute5;
      END IF;
      IF (x_sao_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute6 := l_sao_rec.attribute6;
      END IF;
      IF (x_sao_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute7 := l_sao_rec.attribute7;
      END IF;
      IF (x_sao_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute8 := l_sao_rec.attribute8;
      END IF;
      IF (x_sao_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute9 := l_sao_rec.attribute9;
      END IF;
      IF (x_sao_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute10 := l_sao_rec.attribute10;
      END IF;
      IF (x_sao_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute11 := l_sao_rec.attribute11;
      END IF;
      IF (x_sao_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute12 := l_sao_rec.attribute12;
      END IF;
      IF (x_sao_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute13 := l_sao_rec.attribute13;
      END IF;
      IF (x_sao_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute14 := l_sao_rec.attribute14;
      END IF;
      IF (x_sao_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.attribute15 := l_sao_rec.attribute15;
      END IF;
      IF (x_sao_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.created_by := l_sao_rec.created_by;
      END IF;
      IF (x_sao_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_sao_rec.creation_date := l_sao_rec.creation_date;
      END IF;
      IF (x_sao_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.last_updated_by := l_sao_rec.last_updated_by;
      END IF;
      IF (x_sao_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_sao_rec.last_update_date := l_sao_rec.last_update_date;
      END IF;
      IF (x_sao_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.last_update_login := l_sao_rec.last_update_login;
      END IF;

      /* Changed made by Kanti on 06/21/2001. To make it consistent with database table
         Changes start here  */
      IF (x_sao_rec.cc_apply_rounding_difference = Okc_Api.G_MISS_CHAR)
            THEN
              x_sao_rec.cc_apply_rounding_difference := l_sao_rec.cc_apply_rounding_difference;
      END IF;
      IF (x_sao_rec.ael_apply_rounding_difference = Okc_Api.G_MISS_CHAR)
                  THEN
                    x_sao_rec.ael_apply_rounding_difference := l_sao_rec.ael_apply_rounding_difference;
      END IF;

      /* Changes End here  */
      IF (x_sao_rec.accrual_reversal_days = Okc_Api.G_MISS_NUM)
                  THEN
                    x_sao_rec.accrual_reversal_days := l_sao_rec.accrual_reversal_days;
      END IF;

-- Added new field lke_hold_days for the bug 2331564 by Santonyr
      IF (x_sao_rec.lke_hold_days = Okc_Api.G_MISS_NUM) THEN
         x_sao_rec.lke_hold_days := l_sao_rec.lke_hold_days;
      END IF;

--Added by Keerthi 10-Sep-2003 for Rounding of Amounts in Streams

     IF (x_sao_rec.stm_apply_rounding_difference = Okc_Api.G_MISS_CHAR)
                  THEN
                    x_sao_rec.stm_apply_rounding_difference := l_sao_rec.stm_apply_rounding_difference;
      END IF;

     IF (x_sao_rec.stm_rounding_rule = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.stm_rounding_rule := l_sao_rec.stm_rounding_rule;
      END IF;
      --Added new field for bug 4884618(H)
      IF (x_sao_rec.validate_khr_start_date = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.validate_khr_start_date := l_sao_rec.validate_khr_start_date;
      END IF;
      -- R12 SLA Uptake: Begin
      IF (x_sao_rec.account_derivation = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.account_derivation := l_sao_rec.account_derivation;
      END IF;
      -- R12 SLA Uptake: End

       IF (x_sao_rec.isg_arrears_pay_dates_option = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.isg_arrears_pay_dates_option := l_sao_rec.isg_arrears_pay_dates_option;
      END IF;
       IF (x_sao_rec.PAY_DIST_SET_ID = Okc_Api.G_MISS_NUM)
      THEN
        x_sao_rec.PAY_DIST_SET_ID := l_sao_rec.PAY_DIST_SET_ID;
      END IF;

      -- Bug# 8370699
      IF (x_sao_rec.amort_inc_adj_rev_dt_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_sao_rec.amort_inc_adj_rev_dt_yn := l_sao_rec.amort_inc_adj_rev_dt_yn;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_SYS_ACCT_OPTS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_sao_rec IN  sao_rec_type,
      x_sao_rec OUT NOCOPY sao_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sao_rec := p_sao_rec;
      RETURN(l_return_status);
    END set_attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sao_rec,                         -- IN
      l_sao_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sao_rec, l_def_sao_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SYS_ACCT_OPTS
    SET CC_REP_CURRENCY_CODE = l_def_sao_rec.cc_rep_currency_code,
        CODE_COMBINATION_ID = l_def_sao_rec.code_combination_id,
        AEL_REP_CURRENCY_CODE = l_def_sao_rec.ael_rep_currency_code,
        SET_OF_BOOKS_ID = l_def_sao_rec.set_of_books_id,
        OBJECT_VERSION_NUMBER = l_def_sao_rec.object_version_number,
        REC_CCID = l_def_sao_rec.rec_ccid,
        REALIZED_GAIN_CCID = l_def_sao_rec.realized_gain_ccid,
        REALIZED_LOSS_CCID = l_def_sao_rec.realized_loss_ccid,
        TAX_CCID = l_def_sao_rec.tax_ccid,
        CROSS_CURRENCY_CCID = l_def_sao_rec.cross_currency_ccid,
        ROUNDING_CCID = l_def_sao_rec.rounding_ccid,
        AR_CLEARING_CCID = l_def_sao_rec.ar_clearing_ccid,
        PAYABLES_CCID = l_def_sao_rec.payables_ccid,
        LIABLITY_CCID = l_def_sao_rec.liablity_ccid,
        PRE_PAYMENT_CCID = l_def_sao_rec.pre_payment_ccid,
        FUT_DATE_PAY_CCID = l_def_sao_rec.fut_date_pay_ccid,
        CC_ROUNDING_RULE = l_def_sao_rec.cc_rounding_rule,
        CC_PRECISION = l_def_sao_rec.cc_precision,
        CC_MIN_ACCT_UNIT = l_def_sao_rec.cc_min_acct_unit,
        DIS_TAKEN_CCID = l_def_sao_rec.dis_taken_ccid,
        AP_CLEARING_CCID = l_def_sao_rec.ap_clearing_ccid,
        AEL_ROUNDING_RULE = l_def_sao_rec.ael_rounding_rule,
        AEL_PRECISION = l_def_sao_rec.ael_precision,
        AEL_MIN_ACCT_UNIT = l_def_sao_rec.ael_min_acct_unit,
        ORG_ID = l_def_sao_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_sao_rec.attribute_category,
        ATTRIBUTE1 = l_def_sao_rec.attribute1,
        ATTRIBUTE2 = l_def_sao_rec.attribute2,
        ATTRIBUTE3 = l_def_sao_rec.attribute3,
        ATTRIBUTE4 = l_def_sao_rec.attribute4,
        ATTRIBUTE5 = l_def_sao_rec.attribute5,
        ATTRIBUTE6 = l_def_sao_rec.attribute6,
        ATTRIBUTE7 = l_def_sao_rec.attribute7,
        ATTRIBUTE8 = l_def_sao_rec.attribute8,
        ATTRIBUTE9 = l_def_sao_rec.attribute9,
        ATTRIBUTE10 = l_def_sao_rec.attribute10,
        ATTRIBUTE11 = l_def_sao_rec.attribute11,
        ATTRIBUTE12 = l_def_sao_rec.attribute12,
        ATTRIBUTE13 = l_def_sao_rec.attribute13,
        ATTRIBUTE14 = l_def_sao_rec.attribute14,
        ATTRIBUTE15 = l_def_sao_rec.attribute15,
        CREATED_BY = l_def_sao_rec.created_by,
        CREATION_DATE = l_def_sao_rec.creation_date,
        LAST_UPDATED_BY = l_def_sao_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sao_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sao_rec.last_update_login,
        /* Changes made by Kanti on 06/21/2001. Two new fields are present in the table but were
           not present here
           Changes Start here  */
        CC_APPLY_ROUNDING_DIFFERENCE = l_def_sao_rec.cc_apply_rounding_difference,
        AEL_APPLY_ROUNDING_DIFFERENCE = l_def_sao_rec.ael_apply_rounding_difference,
        ACCRUAL_REVERSAL_DAYS = l_def_sao_rec.ACCRUAL_REVERSAL_DAYS,
-- Added new field lke_hold_days for the bug 2331564 by Santonyr
        LKE_HOLD_DAYS = l_def_sao_rec.LKE_HOLD_DAYS,
	/* Changes end here */
--Added by Keerthi 10-Sep-2003 for Rounding of Amounts in Streams
        STM_APPLY_ROUNDING_DIFFERENCE = l_def_sao_rec.stm_apply_rounding_difference,
        STM_ROUNDING_RULE = l_def_sao_rec.stm_rounding_rule
        --Added new field for bug 4746246
        , VALIDATE_KHR_START_DATE=l_def_sao_rec.validate_khr_start_date
        -- R12 SLA Uptake
        ,ACCOUNT_DERIVATION = l_def_sao_rec.account_derivation
        ,ISG_ARREARS_PAY_DATES_OPTION  = l_def_sao_rec.isg_arrears_pay_dates_option
        ,PAY_DIST_SET_ID       = l_def_sao_rec.PAY_DIST_SET_ID
        ,SECONDARY_REP_METHOD  =  l_def_sao_rec.SECONDARY_REP_METHOD
        --Bug# 8370699
        ,AMORT_INC_ADJ_REV_DT_YN = l_def_sao_rec.amort_inc_adj_rev_dt_yn
      WHERE ID = l_def_sao_rec.id;

    x_sao_rec := l_def_sao_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_SYS_ACCT_OPTS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_rec                     IN saov_rec_type,
    x_saov_rec                     OUT NOCOPY saov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_saov_rec                     saov_rec_type := p_saov_rec;
    l_def_saov_rec                 saov_rec_type;
    l_sao_rec                      sao_rec_type;
    lx_sao_rec                     sao_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_saov_rec	IN saov_rec_type
    ) RETURN saov_rec_type IS
      l_saov_rec	saov_rec_type := p_saov_rec;
    BEGIN
      l_saov_rec.LAST_UPDATE_DATE := SYSDATE;
      l_saov_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_saov_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_saov_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_saov_rec	IN saov_rec_type,
      x_saov_rec	OUT NOCOPY saov_rec_type
    ) RETURN VARCHAR2 IS
      l_saov_rec                     saov_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_saov_rec := p_saov_rec;
      -- Get current database values
      l_saov_rec := get_rec(p_saov_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_saov_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.id := l_saov_rec.id;
      END IF;
      IF (x_saov_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.object_version_number := l_saov_rec.object_version_number;
      END IF;
      IF (x_saov_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.set_of_books_id := l_saov_rec.set_of_books_id;
      END IF;
      IF (x_saov_rec.SECONDARY_REP_METHOD = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.SECONDARY_REP_METHOD := l_saov_rec.SECONDARY_REP_METHOD;
      END IF;
      IF (x_saov_rec.code_combination_id = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.code_combination_id := l_saov_rec.code_combination_id;
      END IF;
      IF (x_saov_rec.cc_rep_currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.cc_rep_currency_code := l_saov_rec.cc_rep_currency_code;
      END IF;
      IF (x_saov_rec.ael_rep_currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.ael_rep_currency_code := l_saov_rec.ael_rep_currency_code;
      END IF;
      IF (x_saov_rec.rec_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.rec_ccid := l_saov_rec.rec_ccid;
      END IF;
      IF (x_saov_rec.realized_gain_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.realized_gain_ccid := l_saov_rec.realized_gain_ccid;
      END IF;
      IF (x_saov_rec.realized_loss_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.realized_loss_ccid := l_saov_rec.realized_loss_ccid;
      END IF;
      IF (x_saov_rec.tax_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.tax_ccid := l_saov_rec.tax_ccid;
      END IF;
      IF (x_saov_rec.cross_currency_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.cross_currency_ccid := l_saov_rec.cross_currency_ccid;
      END IF;
      IF (x_saov_rec.rounding_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.rounding_ccid := l_saov_rec.rounding_ccid;
      END IF;
      IF (x_saov_rec.ar_clearing_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.ar_clearing_ccid := l_saov_rec.ar_clearing_ccid;
      END IF;
      IF (x_saov_rec.payables_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.payables_ccid := l_saov_rec.payables_ccid;
      END IF;
      IF (x_saov_rec.liablity_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.liablity_ccid := l_saov_rec.liablity_ccid;
      END IF;
      IF (x_saov_rec.pre_payment_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.pre_payment_ccid := l_saov_rec.pre_payment_ccid;
      END IF;
      IF (x_saov_rec.fut_date_pay_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.fut_date_pay_ccid := l_saov_rec.fut_date_pay_ccid;
      END IF;
      IF (x_saov_rec.dis_taken_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.dis_taken_ccid := l_saov_rec.dis_taken_ccid;
      END IF;
      IF (x_saov_rec.ap_clearing_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.ap_clearing_ccid := l_saov_rec.ap_clearing_ccid;
      END IF;
      IF (x_saov_rec.ael_rounding_rule = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.ael_rounding_rule := l_saov_rec.ael_rounding_rule;
      END IF;
      IF (x_saov_rec.ael_precision = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.ael_precision := l_saov_rec.ael_precision;
      END IF;
      IF (x_saov_rec.ael_min_acct_unit = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.ael_min_acct_unit := l_saov_rec.ael_min_acct_unit;
      END IF;
      IF (x_saov_rec.cc_rounding_rule = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.cc_rounding_rule := l_saov_rec.cc_rounding_rule;
      END IF;
      IF (x_saov_rec.cc_precision = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.cc_precision := l_saov_rec.cc_precision;
      END IF;
      IF (x_saov_rec.cc_min_acct_unit = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.cc_min_acct_unit := l_saov_rec.cc_min_acct_unit;
      END IF;
      IF (x_saov_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute_category := l_saov_rec.attribute_category;
      END IF;
      IF (x_saov_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute1 := l_saov_rec.attribute1;
      END IF;
      IF (x_saov_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute2 := l_saov_rec.attribute2;
      END IF;
      IF (x_saov_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute3 := l_saov_rec.attribute3;
      END IF;
      IF (x_saov_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute4 := l_saov_rec.attribute4;
      END IF;
      IF (x_saov_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute5 := l_saov_rec.attribute5;
      END IF;
      IF (x_saov_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute6 := l_saov_rec.attribute6;
      END IF;
      IF (x_saov_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute7 := l_saov_rec.attribute7;
      END IF;
      IF (x_saov_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute8 := l_saov_rec.attribute8;
      END IF;
      IF (x_saov_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute9 := l_saov_rec.attribute9;
      END IF;
      IF (x_saov_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute10 := l_saov_rec.attribute10;
      END IF;
      IF (x_saov_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute11 := l_saov_rec.attribute11;
      END IF;
      IF (x_saov_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute12 := l_saov_rec.attribute12;
      END IF;
      IF (x_saov_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute13 := l_saov_rec.attribute13;
      END IF;
      IF (x_saov_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute14 := l_saov_rec.attribute14;
      END IF;
      IF (x_saov_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.attribute15 := l_saov_rec.attribute15;
      END IF;
      IF (x_saov_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.org_id := l_saov_rec.org_id;
      END IF;
      IF (x_saov_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.created_by := l_saov_rec.created_by;
      END IF;
      IF (x_saov_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_saov_rec.creation_date := l_saov_rec.creation_date;
      END IF;
      IF (x_saov_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.last_updated_by := l_saov_rec.last_updated_by;
      END IF;
      IF (x_saov_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_saov_rec.last_update_date := l_saov_rec.last_update_date;
      END IF;
      IF (x_saov_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.last_update_login := l_saov_rec.last_update_login;
      END IF;

      /* Changes made by Kanti on 06/21/2001 to make TAPI consistent with table definition */

      IF (x_saov_rec.cc_apply_rounding_difference = Okc_Api.G_MISS_CHAR)
      THEN
          x_saov_rec.cc_apply_rounding_difference := l_saov_rec.cc_apply_rounding_difference;
      END IF;

      IF (x_saov_rec.ael_apply_rounding_difference = Okc_Api.G_MISS_CHAR)
      THEN
          x_saov_rec.ael_apply_rounding_difference := l_saov_rec.ael_apply_rounding_difference;
      END IF;

      /* Changes End here  */

      IF (x_saov_rec.accrual_reversal_days = Okc_Api.G_MISS_NUM)
      THEN
          x_saov_rec.accrual_reversal_days := l_saov_rec.accrual_reversal_days;
      END IF;
-- Added new field lke_hold_days for the bug 2331564 by Santonyr
      IF (x_saov_rec.lke_hold_days = Okc_Api.G_MISS_NUM) THEN
          x_saov_rec.lke_hold_days := l_saov_rec.lke_hold_days;
      END IF;

-- Added by Keerthi 10-Sep-2003 for Rounding of Amounts in Streams
      IF (x_saov_rec.stm_apply_rounding_difference = Okc_Api.G_MISS_CHAR)
      THEN
          x_saov_rec.stm_apply_rounding_difference := l_saov_rec.stm_apply_rounding_difference;
      END IF;

      IF (x_saov_rec.stm_rounding_rule = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.stm_rounding_rule := l_saov_rec.stm_rounding_rule;
      END IF;
      --Added new field for bug 4884618(H)
      IF (x_saov_rec.validate_khr_start_date = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.validate_khr_start_date := l_saov_rec.validate_khr_start_date;
      END IF;
      -- R12 SLA Uptake: Begin
      IF (x_saov_rec.account_derivation = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.account_derivation := l_saov_rec.account_derivation;
      END IF;
      -- R12 SLA Uptake: End
      IF (x_saov_rec.isg_arrears_pay_dates_option  = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.isg_arrears_pay_dates_option  := l_saov_rec.isg_arrears_pay_dates_option;
      END IF;
       IF (x_saov_rec.PAY_DIST_SET_ID  = Okc_Api.G_MISS_NUM)
      THEN
        x_saov_rec.PAY_DIST_SET_ID   := l_saov_rec.PAY_DIST_SET_ID ;
      END IF;

      --Bug# 8370699
      IF (x_saov_rec.amort_inc_adj_rev_dt_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_saov_rec.amort_inc_adj_rev_dt_yn := l_saov_rec.amort_inc_adj_rev_dt_yn;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_SYS_ACCT_OPTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_saov_rec IN  saov_rec_type,
      x_saov_rec OUT NOCOPY saov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_saov_rec := p_saov_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_saov_rec,                        -- IN
      l_saov_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_saov_rec, l_def_saov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_saov_rec := fill_who_columns(l_def_saov_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_saov_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_saov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_saov_rec, l_sao_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sao_rec,
      lx_sao_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sao_rec, l_def_saov_rec);
    x_saov_rec := l_def_saov_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:SAOV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_tbl                     IN saov_tbl_type,
    x_saov_tbl                     OUT NOCOPY saov_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saov_tbl.COUNT > 0) THEN
      i := p_saov_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saov_rec                     => p_saov_tbl(i),
          x_saov_rec                     => x_saov_tbl(i));
    	-- START change : mvasudev, 05/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_saov_tbl.LAST);
        i := p_saov_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 05/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- delete_row for:OKL_SYS_ACCT_OPTS --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sao_rec                      IN sao_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_sao_rec                      sao_rec_type:= p_sao_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_SYS_ACCT_OPTS
     WHERE ID = l_sao_rec.id;

    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- delete_row for:OKL_SYS_ACCT_OPTS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_rec                     IN saov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_saov_rec                     saov_rec_type := p_saov_rec;
    l_sao_rec                      sao_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_saov_rec, l_sao_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sao_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:SAOV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_tbl                     IN saov_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saov_tbl.COUNT > 0) THEN
      i := p_saov_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saov_rec                     => p_saov_tbl(i));
    	-- START change : mvasudev, 05/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_saov_tbl.LAST);
        i := p_saov_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 05/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END okl_sao_pvt;

/
