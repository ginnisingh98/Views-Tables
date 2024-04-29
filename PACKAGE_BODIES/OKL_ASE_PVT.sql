--------------------------------------------------------
--  DDL for Package Body OKL_ASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ASE_PVT" AS
/* $Header: OKLSASEB.pls 120.7 2006/07/13 12:53:17 adagur noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
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
  -- FUNCTION get_rec for: OKL_ACCT_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_asev_rec                     IN asev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN asev_rec_type IS
    CURSOR okl_asev_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            SOURCE_TABLE,
            SOURCE_ID,
            PDT_ID,
            TRY_ID,
            STY_ID,
            MEMO_YN,
            FACTOR_INVESTOR_FLAG,
            FACTOR_INVESTOR_CODE,
            AMOUNT,
            FORMULA_USED,
            ENTERED_DATE,
            ACCOUNTING_DATE,
            GL_REVERSAL_FLAG,
            POST_TO_GL,
            CURRENCY_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_DATE,
            CURRENCY_CONVERSION_RATE,
            KHR_ID,
            KLE_ID,
            PAY_VENDOR_SITES_PK,
            REC_SITE_USES_PK,
            ASSET_CATEGORY_ID_PK1,
            ASSET_BOOK_PK2,
            PAY_FINANCIAL_OPTIONS_PK,
            JTF_SALES_REPS_PK,
            INVENTORY_ITEM_ID_PK1,
            INVENTORY_ORG_ID_PK2,
            REC_TRX_TYPES_PK,
            AVL_ID,
            LOCAL_PRODUCT_YN,
            INTERNAL_STATUS,
            CUSTOM_STATUS,
            SOURCE_INDICATOR_FLAG,
            ORG_ID,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_ACCT_SOURCES
     WHERE OKL_ACCT_SOURCES.id = p_id;
    l_okl_asev_pk                  okl_asev_pk_csr%ROWTYPE;
    l_asev_rec                     asev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_asev_pk_csr (p_asev_rec.id);
    FETCH okl_asev_pk_csr INTO
              l_asev_rec.id,
              l_asev_rec.source_table,
              l_asev_rec.source_id,
              l_asev_rec.pdt_id,
              l_asev_rec.try_id,
              l_asev_rec.sty_id,
              l_asev_rec.memo_yn,
              l_asev_rec.factor_investor_flag,
              l_asev_rec.factor_investor_code,
              l_asev_rec.amount,
              l_asev_rec.formula_used,
              l_asev_rec.entered_date,
              l_asev_rec.accounting_date,
              l_asev_rec.gl_reversal_flag,
              l_asev_rec.post_to_gl,
              l_asev_rec.currency_code,
              l_asev_rec.currency_conversion_type,
              l_asev_rec.currency_conversion_date,
              l_asev_rec.currency_conversion_rate,
              l_asev_rec.khr_id,
              l_asev_rec.kle_id,
              l_asev_rec.pay_vendor_sites_pk,
              l_asev_rec.rec_site_uses_pk,
              l_asev_rec.asset_category_id_pk1,
              l_asev_rec.asset_book_pk2,
              l_asev_rec.pay_financial_options_pk,
              l_asev_rec.jtf_sales_reps_pk,
              l_asev_rec.inventory_item_id_pk1,
              l_asev_rec.inventory_org_id_pk2,
              l_asev_rec.rec_trx_types_pk,
              l_asev_rec.avl_id,
              l_asev_rec.local_product_yn,
              l_asev_rec.internal_status,
              l_asev_rec.custom_status,
              l_asev_rec.source_indicator_flag,
              l_asev_rec.org_id,
              l_asev_rec.program_id,
              l_asev_rec.program_application_id,
              l_asev_rec.request_id,
              l_asev_rec.program_update_date,
              l_asev_rec.created_by,
              l_asev_rec.creation_date,
              l_asev_rec.last_updated_by,
              l_asev_rec.last_update_date,
              l_asev_rec.last_update_login;
    x_no_data_found := okl_asev_pk_csr%NOTFOUND;
    CLOSE okl_asev_pk_csr;
    RETURN(l_asev_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_asev_rec                     IN asev_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN asev_rec_type IS
    l_asev_rec                     asev_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_asev_rec := get_rec(p_asev_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_asev_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_asev_rec                     IN asev_rec_type
  ) RETURN asev_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_asev_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ACCT_SOURCES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ase_rec                      IN ase_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ase_rec_type IS
    CURSOR okl_acct_sources_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            SOURCE_TABLE,
            SOURCE_ID,
            PDT_ID,
            TRY_ID,
            STY_ID,
            MEMO_YN,
            FACTOR_INVESTOR_FLAG,
            FACTOR_INVESTOR_CODE,
            AMOUNT,
            FORMULA_USED,
            ENTERED_DATE,
            ACCOUNTING_DATE,
            GL_REVERSAL_FLAG,
            POST_TO_GL,
            CURRENCY_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_DATE,
            CURRENCY_CONVERSION_RATE,
            KHR_ID,
            KLE_ID,
            PAY_VENDOR_SITES_PK,
            REC_SITE_USES_PK,
            ASSET_CATEGORY_ID_PK1,
            ASSET_BOOK_PK2,
            PAY_FINANCIAL_OPTIONS_PK,
            JTF_SALES_REPS_PK,
            INVENTORY_ITEM_ID_PK1,
            INVENTORY_ORG_ID_PK2,
            REC_TRX_TYPES_PK,
            AVL_ID,
            LOCAL_PRODUCT_YN,
            INTERNAL_STATUS,
            CUSTOM_STATUS,
            SOURCE_INDICATOR_FLAG,
            ORG_ID,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_ACCT_SOURCES
     WHERE OKL_ACCT_SOURCES.id  = p_id;
    l_okl_acct_sources_pk          okl_acct_sources_pk_csr%ROWTYPE;
    l_ase_rec                      ase_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_acct_sources_pk_csr (p_ase_rec.id);
    FETCH okl_acct_sources_pk_csr INTO
              l_ase_rec.id,
              l_ase_rec.source_table,
              l_ase_rec.source_id,
              l_ase_rec.pdt_id,
              l_ase_rec.try_id,
              l_ase_rec.sty_id,
              l_ase_rec.memo_yn,
              l_ase_rec.factor_investor_flag,
              l_ase_rec.factor_investor_code,
              l_ase_rec.amount,
              l_ase_rec.formula_used,
              l_ase_rec.entered_date,
              l_ase_rec.accounting_date,
              l_ase_rec.gl_reversal_flag,
              l_ase_rec.post_to_gl,
              l_ase_rec.currency_code,
              l_ase_rec.currency_conversion_type,
              l_ase_rec.currency_conversion_date,
              l_ase_rec.currency_conversion_rate,
              l_ase_rec.khr_id,
              l_ase_rec.kle_id,
              l_ase_rec.pay_vendor_sites_pk,
              l_ase_rec.rec_site_uses_pk,
              l_ase_rec.asset_category_id_pk1,
              l_ase_rec.asset_book_pk2,
              l_ase_rec.pay_financial_options_pk,
              l_ase_rec.jtf_sales_reps_pk,
              l_ase_rec.inventory_item_id_pk1,
              l_ase_rec.inventory_org_id_pk2,
              l_ase_rec.rec_trx_types_pk,
              l_ase_rec.avl_id,
              l_ase_rec.local_product_yn,
              l_ase_rec.internal_status,
              l_ase_rec.custom_status,
              l_ase_rec.source_indicator_flag,
              l_ase_rec.org_id,
              l_ase_rec.program_id,
              l_ase_rec.program_application_id,
              l_ase_rec.request_id,
              l_ase_rec.program_update_date,
              l_ase_rec.created_by,
              l_ase_rec.creation_date,
              l_ase_rec.last_updated_by,
              l_ase_rec.last_update_date,
              l_ase_rec.last_update_login;
    x_no_data_found := okl_acct_sources_pk_csr%NOTFOUND;
    CLOSE okl_acct_sources_pk_csr;
    RETURN(l_ase_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ase_rec                      IN ase_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ase_rec_type IS
    l_ase_rec                      ase_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_ase_rec := get_rec(p_ase_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ase_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ase_rec                      IN ase_rec_type
  ) RETURN ase_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ase_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_ACCT_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_asev_rec   IN asev_rec_type
  ) RETURN asev_rec_type IS
    l_asev_rec                     asev_rec_type := p_asev_rec;
  BEGIN
    -- udhenuko Bug#5042061 Modified G_MISS_NUM to G_MISS_CHAR
    IF (l_asev_rec.id = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.id := NULL;
    END IF;
    IF (l_asev_rec.source_table = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.source_table := NULL;
    END IF;
    IF (l_asev_rec.source_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.source_id := NULL;
    END IF;
    IF (l_asev_rec.pdt_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.pdt_id := NULL;
    END IF;
    IF (l_asev_rec.try_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.try_id := NULL;
    END IF;
    IF (l_asev_rec.sty_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.sty_id := NULL;
    END IF;
    IF (l_asev_rec.memo_yn = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.memo_yn := NULL;
    END IF;
    IF (l_asev_rec.factor_investor_flag = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.factor_investor_flag := NULL;
    END IF;
    IF (l_asev_rec.factor_investor_code = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.factor_investor_code := NULL;
    END IF;
    IF (l_asev_rec.amount = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.amount := NULL;
    END IF;
    IF (l_asev_rec.formula_used = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.formula_used := NULL;
    END IF;
    IF (l_asev_rec.entered_date = Okc_Api.G_MISS_DATE ) THEN
      l_asev_rec.entered_date := NULL;
    END IF;
    IF (l_asev_rec.accounting_date = Okc_Api.G_MISS_DATE ) THEN
      l_asev_rec.accounting_date := NULL;
    END IF;
    IF (l_asev_rec.gl_reversal_flag = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.gl_reversal_flag := NULL;
    END IF;
    IF (l_asev_rec.post_to_gl = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.post_to_gl := NULL;
    END IF;
    IF (l_asev_rec.currency_code = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.currency_code := NULL;
    END IF;
    IF (l_asev_rec.currency_conversion_type = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_asev_rec.currency_conversion_date = Okc_Api.G_MISS_DATE ) THEN
      l_asev_rec.currency_conversion_date := NULL;
    END IF;
    IF (l_asev_rec.currency_conversion_rate = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_asev_rec.khr_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.khr_id := NULL;
    END IF;
    IF (l_asev_rec.kle_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.kle_id := NULL;
    END IF;
    IF (l_asev_rec.pay_vendor_sites_pk = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.pay_vendor_sites_pk := NULL;
    END IF;
    IF (l_asev_rec.rec_site_uses_pk = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.rec_site_uses_pk := NULL;
    END IF;
    IF (l_asev_rec.asset_category_id_pk1 = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.asset_category_id_pk1 := NULL;
    END IF;
    IF (l_asev_rec.asset_book_pk2 = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.asset_book_pk2 := NULL;
    END IF;
    IF (l_asev_rec.pay_financial_options_pk = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.pay_financial_options_pk := NULL;
    END IF;
    IF (l_asev_rec.jtf_sales_reps_pk = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.jtf_sales_reps_pk := NULL;
    END IF;
    IF (l_asev_rec.inventory_item_id_pk1 = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.inventory_item_id_pk1 := NULL;
    END IF;
    IF (l_asev_rec.inventory_org_id_pk2 = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.inventory_org_id_pk2 := NULL;
    END IF;
    IF (l_asev_rec.rec_trx_types_pk = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.rec_trx_types_pk := NULL;
    END IF;
    IF (l_asev_rec.avl_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.avl_id := NULL;
    END IF;
    IF (l_asev_rec.local_product_yn = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.local_product_yn := NULL;
    END IF;
    IF (l_asev_rec.internal_status = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.internal_status := NULL;
    END IF;
    IF (l_asev_rec.custom_status = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.custom_status := NULL;
    END IF;
    IF (l_asev_rec.source_indicator_flag = Okc_Api.G_MISS_CHAR ) THEN
      l_asev_rec.source_indicator_flag := NULL;
    END IF;
    IF (l_asev_rec.org_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.org_id := NULL;
    END IF;
    IF (l_asev_rec.program_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.program_id := NULL;
    END IF;
    IF (l_asev_rec.program_application_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.program_application_id := NULL;
    END IF;
    IF (l_asev_rec.request_id = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.request_id := NULL;
    END IF;
    IF (l_asev_rec.program_update_date = Okc_Api.G_MISS_DATE ) THEN
      l_asev_rec.program_update_date := NULL;
    END IF;
    IF (l_asev_rec.created_by = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.created_by := NULL;
    END IF;
    IF (l_asev_rec.creation_date = Okc_Api.G_MISS_DATE ) THEN
      l_asev_rec.creation_date := NULL;
    END IF;
    IF (l_asev_rec.last_updated_by = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.last_updated_by := NULL;
    END IF;
    IF (l_asev_rec.last_update_date = Okc_Api.G_MISS_DATE ) THEN
      l_asev_rec.last_update_date := NULL;
    END IF;
    IF (l_asev_rec.last_update_login = Okc_Api.G_MISS_NUM ) THEN
      l_asev_rec.last_update_login := NULL;
    END IF;
    RETURN(l_asev_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    p_asev_rec                      IN  asev_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- udhenuko Bug#5042061 Modified G_MISS_NUM to G_MISS_CHAR
    IF (p_asev_rec.id = Okc_Api.G_MISS_CHAR OR
        p_asev_rec.id IS NULL)
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  -------------------------------------------
  -- Validate_Attributes for: SOURCE_TABLE --
  -------------------------------------------
  PROCEDURE validate_source_table(
    p_asev_rec                      IN  asev_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS

    l_dummy			      VARCHAR2(1) := Okc_Api.G_FALSE;
  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF (p_asev_rec.source_table = Okc_Api.G_MISS_CHAR OR
        p_asev_rec.source_table IS NULL)
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_table');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

       l_dummy := Okl_Accounting_Util.VALIDATE_SOURCE_ID_TABLE
                                 (p_source_id => p_asev_rec.source_id,
                                  p_source_table => p_asev_rec.source_table);

       IF (l_dummy = Okc_Api.G_FALSE) THEN
	   Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => g_invalid_value,
                               p_token1       => g_col_name_token,
                               p_token1_value => 'source_table');
           x_return_status := Okc_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_source_table;
  ----------------------------------------
  -- Validate_Attributes for: SOURCE_ID --
  ----------------------------------------
  PROCEDURE validate_source_id(
    p_asev_rec                      IN  asev_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF (p_asev_rec.source_id = Okc_Api.G_MISS_NUM OR
        p_asev_rec.source_id IS NULL)
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_source_id;
  -------------------------------------
  -- Validate_Attributes for: PDT_ID --
  -------------------------------------
  PROCEDURE validate_pdt_id(
    p_asev_rec                      IN  asev_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS

  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;

  CURSOR pdt_csr (v_pdt_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_PRODUCTS_V
  WHERE ID = v_pdt_id;


  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF (p_asev_rec.pdt_id = Okc_Api.G_MISS_NUM OR
        p_asev_rec.pdt_id IS NULL)
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'pdt_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_asev_rec.pdt_id IS NOT NULL) AND
       (p_asev_rec.pdt_id <> Okc_Api.G_MISS_NUM) THEN

        OPEN pdt_csr(p_asev_rec.PDT_ID);
        FETCH pdt_csr INTO l_dummy;
        l_row_notfound := pdt_csr%NOTFOUND;
        CLOSE pdt_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PDT_ID');
          x_return_status := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_pdt_id;
  -------------------------------------
  -- Validate_Attributes for: TRY_ID --
  -------------------------------------
  PROCEDURE validate_try_id(
    p_asev_rec                      IN  asev_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS

    l_dummy                   VARCHAR2(1)    ;

    CURSOR try_csr(v_try_id NUMBER) IS
    SELECT '1'
    FROM OKL_TRX_TYPES_V
    WHERE ID = v_try_id;


  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF (p_asev_rec.try_id = Okc_Api.G_MISS_NUM OR
        p_asev_rec.try_id IS NULL)
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'try_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

      OPEN try_csr(p_asev_rec.TRY_ID);
      FETCH try_csr INTO l_dummy;
      IF (try_csr%NOTFOUND) THEN
         Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name      => g_invalid_value
                             ,p_token1        => g_col_name_token
                             ,p_token1_value  => 'TRY_ID');
         x_return_status     := Okc_Api.G_RET_STS_ERROR;
         CLOSE try_csr;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      CLOSE try_csr;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_try_id;



  PROCEDURE Validate_Sty_Id (p_asev_rec IN  asev_rec_type
                           ,x_return_status OUT NOCOPY VARCHAR2)
    IS
    l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
    l_dummy                       VARCHAR2(1);
    l_row_notfound                    BOOLEAN := TRUE;

    CURSOR sty_csr (p_id IN NUMBER) IS
    SELECT  '1'
    FROM Okl_Strm_Type_V
    WHERE okl_strm_type_v.id = p_id;


    BEGIN
      -- initialize return status
      x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF (p_asev_rec.sty_id = Okc_Api.G_MISS_NUM OR
        p_asev_rec.sty_id IS NULL)
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sty_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN sty_csr(p_asev_rec.sty_id);
    FETCH sty_csr INTO l_dummy;
      IF (sty_csr%NOTFOUND) THEN
         Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name      => g_invalid_value
                             ,p_token1        => g_col_name_token
                             ,p_token1_value  => 'sty_id');
         x_return_status     := Okc_Api.G_RET_STS_ERROR;
         CLOSE sty_csr;
         x_return_status := Okc_Api.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      CLOSE sty_csr;



    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;

      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                            ,p_msg_name      => g_unexpected_error
                            ,p_token1        => g_sqlcode_token
                            ,p_token1_value  => SQLCODE
                            ,p_token2        => g_sqlerrm_token
                            ,p_token2_value  => SQLERRM);

         -- notify caller of an UNEXPECTED error
         x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Sty_Id;


  PROCEDURE Validate_Gl_Reversal_Flag (p_asev_rec      IN   asev_rec_type,
  					x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;
  l_app_id        NUMBER := 0;
  l_view_app_id   NUMBER := 0;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_asev_rec.GL_REVERSAL_FLAG IS NOT NULL) AND
       (p_asev_rec.GL_REVERSAL_FLAG <> Okc_Api.G_MISS_CHAR) THEN
        l_dummy := Okl_Accounting_Util.VALIDATE_LOOKUP_CODE
                           (p_lookup_type => 'YES_NO',
                            p_lookup_code => p_asev_rec.gl_reversal_flag,
                            p_app_id      => l_app_id,
                            p_view_app_id => l_view_app_id);

        IF (l_dummy = Okc_Api.G_FALSE) THEN
           Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'GL_REVERSAL_FLAG');
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
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_GL_REVERSAL_FLAG;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_post_to_gl
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_post_to_gl
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_POST_TO_GL (p_asev_rec      IN   asev_rec_type,
  				 x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;
  l_app_id        NUMBER := 0;
  l_view_app_id   NUMBER := 0;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_asev_rec.POST_TO_GL IS NOT NULL) AND
       (p_asev_rec.POST_TO_GL <> Okc_Api.G_MISS_CHAR) THEN
        l_dummy := Okl_Accounting_Util.VALIDATE_LOOKUP_CODE
                           (p_lookup_type => 'YES_NO',
                            p_lookup_code => p_asev_rec.POST_TO_GL,
                            p_app_id      => l_app_id,
                            p_view_app_id => l_view_app_id);

        IF (l_dummy = Okc_Api.G_FALSE) THEN
           Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'POST_TO_GL');
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
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_POST_TO_GL;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Khr_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Khr_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Khr_Id (p_asev_rec IN  asev_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;

  CURSOR okl_asev_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM Okl_K_Headers_V
  WHERE okl_k_headers_v.id = p_id;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_asev_rec.khr_id IS NOT NULL) AND
       (p_asev_rec.khr_id <> Okc_Api.G_MISS_NUM) THEN

        OPEN okl_asev_fk_csr(p_asev_rec.KHR_ID);
        FETCH okl_asev_fk_csr INTO l_dummy;
        l_row_notfound := okl_asev_fk_csr%NOTFOUND;
        CLOSE okl_asev_fk_csr;

        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID');
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
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Khr_Id;


---------------------------------------------------------------------------
  -- PROCEDURE Validate_Internal_Status
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_TSU_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Internal_Status(p_asev_rec      IN      asev_rec_type
			     ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_asev_rec.internal_status IS NULL) OR
       (p_asev_rec.internal_status = Okc_Api.G_MISS_CHAR) THEN
         Okc_Api.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'internal_status');

          x_return_status := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_dummy := Okl_Accounting_Util.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_ACCT_SOURCES_STATUS',
                               p_lookup_code => p_asev_rec.internal_status);

    IF (l_dummy = Okl_Api.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'internal_status');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Internal_Status;


---------------------------------------------------------------------------
  -- PROCEDURE Validate_Custom_Status
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_TSU_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Custom_Status(p_asev_rec      IN      asev_rec_type
			     ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_asev_rec.custom_status IS NULL) OR
       (p_asev_rec.custom_status = Okc_Api.G_MISS_CHAR) THEN
         Okc_Api.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'custom_status');

          x_return_status := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_dummy := Okl_Accounting_Util.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_ACCT_SOURCES_CUSTOM_STATUS',
                               p_lookup_code => p_asev_rec.custom_status);

    IF (l_dummy = Okl_Api.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'custom_status');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Custom_Status;


---------------------------------------------------------------------------
  -- PROCEDURE Validate_Source_Indicator_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Source_Indicator_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Source_Indicator_Flag(p_asev_rec      IN      asev_rec_type
			     ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_asev_rec.source_indicator_flag IS NULL) OR
       (p_asev_rec.source_indicator_flag = Okc_Api.G_MISS_CHAR) THEN
         Okc_Api.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'source_indicator_flag');

          x_return_status := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_dummy := Okl_Accounting_Util.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_ACCT_SOURCES_INDICATOR',
                               p_lookup_code => p_asev_rec.source_indicator_flag);

    IF (l_dummy = Okl_Api.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'source_indicator_flag');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Source_Indicator_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_template_id
  ---------------------------------------------------------------------------
    PROCEDURE validate_template_id(
      p_asev_rec IN  asev_rec_type,
      x_return_status OUT NOCOPY VARCHAR2
    ) IS
    l_dummy			      VARCHAR2(1) ;

      CURSOR tmpl_csr(v_template_id IN NUMBER)
	  IS
	  SELECT '1'
	  FROM OKL_AE_TEMPLATES
	  WHERE id = v_template_id;

	   l_fetch_flag VARCHAR2(1);

    BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_asev_rec.avl_id IS NOT NULL) AND
       (p_asev_rec.avl_id <> Okc_Api.G_MISS_NUM) THEN
	  OPEN tmpl_csr(p_asev_rec.avl_id);
	  FETCH tmpl_csr INTO l_dummy;

          IF (tmpl_csr%NOTFOUND) THEN

		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'avl_id');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
                CLOSE tmpl_csr;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;

         CLOSE tmpl_csr;

    END IF;


      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         Okc_Api.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_template_id;



  ---------------------------------------------------------------------------
  -- PROCEDURE validate_curr_code
  ---------------------------------------------------------------------------
    PROCEDURE validate_curr_code(
      p_asev_rec IN  asev_rec_type,
      x_return_status OUT NOCOPY VARCHAR2
    ) IS
    l_dummy	      VARCHAR2(1)	:= Okc_Api.G_FALSE;

    BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_asev_rec.currency_code IS NOT NULL) AND
       (p_asev_rec.currency_code <> Okc_Api.G_MISS_CHAR) THEN
       l_dummy := Okl_Accounting_Util.VALIDATE_CURRENCY_CODE (p_asev_rec.currency_code);

      IF (l_dummy = Okl_Api.g_false) THEN
	    Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'CURRENCY_CODE');

	    x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         Okc_Api.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_curr_code;


  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_ACCT_SOURCES_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_asev_rec                     IN asev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(p_asev_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;


    -- ***
    -- source_table
    -- ***
    validate_source_table(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

    -- ***
    -- source_id
    -- ***
    validate_source_id(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

    -- ***
    -- pdt_id
    -- ***
    validate_pdt_id(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

    -- ***
    -- try_id
    -- ***
    validate_try_id(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

    -- ***
    -- Validate_Sty_Id
    -- ***
    Validate_Sty_Id(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
    -- ***
    -- Validate_Gl_Reversal_Flag
    -- ***
    Validate_Gl_Reversal_Flag(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
    -- ***
    -- Validate_post_to_gl
    -- ***
    Validate_post_to_gl(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
    -- ***
    -- Validate_Khr_Id
    -- ***
    Validate_Khr_Id(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
    -- ***
    -- Validate_Internal_Status
    -- ***
    Validate_Internal_Status(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
    -- ***
    -- Validate_Custom_Status
    -- ***
    Validate_Custom_Status(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
    -- ***
    -- Validate_Source_Indicator_Flag
    -- ***
    Validate_Source_Indicator_Flag(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
    -- ***
    -- validate_template_id
    -- ***
    validate_template_id(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
    -- ***
    -- validate_curr_code
    -- ***
    validate_curr_code(p_asev_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;



    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate Record for:OKL_ACCT_SOURCES_V --
  --------------------------------------------

  -- bug 4049781
  /*
  FUNCTION Validate_Record (
    p_asev_rec IN asev_rec_type,
    p_db_asev_rec IN asev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  */

  -- bug 4049781

  FUNCTION Validate_Record (
    p_asev_rec IN asev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN asev_rec_type,
    p_to   IN OUT NOCOPY ase_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.source_table := p_from.source_table;
    p_to.source_id := p_from.source_id;
    p_to.pdt_id := p_from.pdt_id;
    p_to.try_id := p_from.try_id;
    p_to.sty_id := p_from.sty_id;
    p_to.memo_yn := p_from.memo_yn;
    p_to.factor_investor_flag := p_from.factor_investor_flag;
    p_to.factor_investor_code := p_from.factor_investor_code;
    p_to.amount := p_from.amount;
    p_to.formula_used := p_from.formula_used;
    p_to.entered_date := p_from.entered_date;
    p_to.accounting_date := p_from.accounting_date;
    p_to.gl_reversal_flag := p_from.gl_reversal_flag;
    p_to.post_to_gl := p_from.post_to_gl;
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.pay_vendor_sites_pk := p_from.pay_vendor_sites_pk;
    p_to.rec_site_uses_pk := p_from.rec_site_uses_pk;
    p_to.asset_category_id_pk1 := p_from.asset_category_id_pk1;
    p_to.asset_book_pk2 := p_from.asset_book_pk2;
    p_to.pay_financial_options_pk := p_from.pay_financial_options_pk;
    p_to.jtf_sales_reps_pk := p_from.jtf_sales_reps_pk;
    p_to.inventory_item_id_pk1 := p_from.inventory_item_id_pk1;
    p_to.inventory_org_id_pk2 := p_from.inventory_org_id_pk2;
    p_to.rec_trx_types_pk := p_from.rec_trx_types_pk;
    p_to.avl_id := p_from.avl_id;
    p_to.local_product_yn := p_from.local_product_yn;
    p_to.internal_status := p_from.internal_status;
    p_to.custom_status := p_from.custom_status;
    p_to.source_indicator_flag := p_from.source_indicator_flag;
    p_to.org_id := p_from.org_id;
    p_to.program_id := p_from.program_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.request_id := p_from.request_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN ase_rec_type,
    p_to   IN OUT NOCOPY asev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.source_table := p_from.source_table;
    p_to.source_id := p_from.source_id;
    p_to.pdt_id := p_from.pdt_id;
    p_to.try_id := p_from.try_id;
    p_to.sty_id := p_from.sty_id;
    p_to.memo_yn := p_from.memo_yn;
    p_to.factor_investor_flag := p_from.factor_investor_flag;
    p_to.factor_investor_code := p_from.factor_investor_code;
    p_to.amount := p_from.amount;
    p_to.formula_used := p_from.formula_used;
    p_to.entered_date := p_from.entered_date;
    p_to.accounting_date := p_from.accounting_date;
    p_to.gl_reversal_flag := p_from.gl_reversal_flag;
    p_to.post_to_gl := p_from.post_to_gl;
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.pay_vendor_sites_pk := p_from.pay_vendor_sites_pk;
    p_to.rec_site_uses_pk := p_from.rec_site_uses_pk;
    p_to.asset_category_id_pk1 := p_from.asset_category_id_pk1;
    p_to.asset_book_pk2 := p_from.asset_book_pk2;
    p_to.pay_financial_options_pk := p_from.pay_financial_options_pk;
    p_to.jtf_sales_reps_pk := p_from.jtf_sales_reps_pk;
    p_to.inventory_item_id_pk1 := p_from.inventory_item_id_pk1;
    p_to.inventory_org_id_pk2 := p_from.inventory_org_id_pk2;
    p_to.rec_trx_types_pk := p_from.rec_trx_types_pk;
    p_to.avl_id := p_from.avl_id;
    p_to.local_product_yn := p_from.local_product_yn;
    p_to.internal_status := p_from.internal_status;
    p_to.custom_status := p_from.custom_status;
    p_to.source_indicator_flag := p_from.source_indicator_flag;
    p_to.org_id := p_from.org_id;
    p_to.program_id := p_from.program_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.request_id := p_from.request_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_ACCT_SOURCES_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN asev_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_asev_rec                     asev_rec_type := p_asev_rec;
    l_ase_rec                      ase_rec_type;
    l_ase_rec                      ase_rec_type;
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
    l_return_status := Validate_Attributes(l_asev_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_asev_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_ACCT_SOURCES_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_tbl                     IN asev_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asev_tbl.COUNT > 0) THEN
      i := p_asev_tbl.FIRST;
      LOOP
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_asev_rec                     => p_asev_tbl(i));

        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_asev_tbl.LAST);
        i := p_asev_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- insert_row for:OKL_ACCT_SOURCES --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ase_rec                      IN ase_rec_type,
    x_ase_rec                      OUT NOCOPY ase_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_ase_rec                      ase_rec_type := p_ase_rec;
    l_def_ase_rec                  ase_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_ACCT_SOURCES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ase_rec IN ase_rec_type,
      x_ase_rec OUT NOCOPY ase_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ase_rec := p_ase_rec;
      RETURN(l_return_status);
    END Set_Attributes;
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
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_ase_rec,                         -- IN
      l_ase_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_ACCT_SOURCES(
      id,
      source_table,
      source_id,
      pdt_id,
      try_id,
      sty_id,
      memo_yn,
      factor_investor_flag,
      factor_investor_code,
      amount,
      formula_used,
      entered_date,
      accounting_date,
      gl_reversal_flag,
      post_to_gl,
      currency_code,
      currency_conversion_type,
      currency_conversion_date,
      currency_conversion_rate,
      khr_id,
      kle_id,
      pay_vendor_sites_pk,
      rec_site_uses_pk,
      asset_category_id_pk1,
      asset_book_pk2,
      pay_financial_options_pk,
      jtf_sales_reps_pk,
      inventory_item_id_pk1,
      inventory_org_id_pk2,
      rec_trx_types_pk,
      avl_id,
      local_product_yn,
      internal_status,
      custom_status,
      source_indicator_flag,
      org_id,
      program_id,
      program_application_id,
      request_id,
      program_update_date,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_ase_rec.id,
      l_ase_rec.source_table,
      l_ase_rec.source_id,
      l_ase_rec.pdt_id,
      l_ase_rec.try_id,
      l_ase_rec.sty_id,
      l_ase_rec.memo_yn,
      l_ase_rec.factor_investor_flag,
      l_ase_rec.factor_investor_code,
      l_ase_rec.amount,
      l_ase_rec.formula_used,
      l_ase_rec.entered_date,
      l_ase_rec.accounting_date,
      l_ase_rec.gl_reversal_flag,
      l_ase_rec.post_to_gl,
      l_ase_rec.currency_code,
      l_ase_rec.currency_conversion_type,
      l_ase_rec.currency_conversion_date,
      l_ase_rec.currency_conversion_rate,
      l_ase_rec.khr_id,
      l_ase_rec.kle_id,
      l_ase_rec.pay_vendor_sites_pk,
      l_ase_rec.rec_site_uses_pk,
      l_ase_rec.asset_category_id_pk1,
      l_ase_rec.asset_book_pk2,
      l_ase_rec.pay_financial_options_pk,
      l_ase_rec.jtf_sales_reps_pk,
      l_ase_rec.inventory_item_id_pk1,
      l_ase_rec.inventory_org_id_pk2,
      l_ase_rec.rec_trx_types_pk,
      l_ase_rec.avl_id,
      l_ase_rec.local_product_yn,
      l_ase_rec.internal_status,
      l_ase_rec.custom_status,
      l_ase_rec.source_indicator_flag,
      l_ase_rec.org_id,
      l_ase_rec.program_id,
      l_ase_rec.program_application_id,
      l_ase_rec.request_id,
      l_ase_rec.program_update_date,
      l_ase_rec.created_by,
      l_ase_rec.creation_date,
      l_ase_rec.last_updated_by,
      l_ase_rec.last_update_date,
      l_ase_rec.last_update_login);
    -- Set OUT values
    x_ase_rec := l_ase_rec;
    x_return_status := l_return_status;
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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for :OKL_ACCT_SOURCES_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN asev_rec_type,
    x_asev_rec                     OUT NOCOPY asev_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_asev_rec                     asev_rec_type := p_asev_rec;
    l_def_asev_rec                 asev_rec_type;
    l_ase_rec                      ase_rec_type;
    lx_ase_rec                     ase_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_asev_rec IN asev_rec_type
    ) RETURN asev_rec_type IS
      l_asev_rec asev_rec_type := p_asev_rec;
    BEGIN
      l_asev_rec.CREATION_DATE := SYSDATE;
      l_asev_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_asev_rec.LAST_UPDATE_DATE := l_asev_rec.CREATION_DATE;
      l_asev_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_asev_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_asev_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_ACCT_SOURCES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_asev_rec IN asev_rec_type,
      x_asev_rec OUT NOCOPY asev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

	  l_request_id NUMBER := Fnd_Global.CONC_REQUEST_ID;
	  l_prog_app_id NUMBER := Fnd_Global.PROG_APPL_ID;
	  l_program_id NUMBER := Fnd_Global.CONC_PROGRAM_ID;


    BEGIN
      x_asev_rec := p_asev_rec;

      SELECT DECODE(l_request_id, -1, NULL, l_request_id),
      DECODE(l_prog_app_id, -1, NULL, l_prog_app_id),
      DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
      DECODE(l_request_id, -1, NULL, SYSDATE)
     INTO  x_asev_rec.REQUEST_ID
          ,x_asev_rec.PROGRAM_APPLICATION_ID
          ,x_asev_rec.PROGRAM_ID
          ,x_asev_rec.PROGRAM_UPDATE_DATE
     FROM DUAL;

       x_asev_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

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
    l_asev_rec := null_out_defaults(p_asev_rec);
    -- Set primary key value
    l_asev_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_asev_rec,                        -- IN
      l_def_asev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_asev_rec := fill_who_columns(l_def_asev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_asev_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_asev_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_asev_rec, l_ase_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ase_rec,
      lx_ase_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
	    migrate(lx_ase_rec, l_def_asev_rec);
    -- Set OUT values
    x_asev_rec := l_def_asev_rec;
    x_return_status := l_return_status;
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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

 --Added by gboomina on 14-Oct-2005
     --Bug 4662173 - Start of Changes
     PROCEDURE insert_row_bulk(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_asev_tbl                     IN asev_tbl_type,
       x_asev_tbl                     OUT NOCOPY asev_tbl_type) IS

       l_api_version                  CONSTANT NUMBER := 1;
       l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row_bulk';
       l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

       l_tabsize                      NUMBER := p_asev_tbl.COUNT;
       --Modified by kthiruva on 07-Oct-2005
       --The id column in the Okl_Acct_Sources table is VARCHAR2(240)
       in_id                          Okl_Streams_Util.Var240TabTyp;
       in_source_table                Okl_Streams_Util.Var30TabTyp;
       in_source_id                   Okl_Streams_Util.NumberTabTyp;
       in_pdt_id                      Okl_Streams_Util.NumberTabTyp;
       in_try_id                      Okl_Streams_Util.NumberTabTyp;
       in_sty_id                      Okl_Streams_Util.NumberTabTyp;
       in_memo_yn                     Okl_Streams_Util.Var3TabTyp;
       in_factor_investor_flag        Okl_Streams_Util.Var45TabTyp;
       in_factor_investor_code        Okl_Streams_Util.Var30TabTyp;
       in_amount                      Okl_Streams_Util.NumberTabTyp;
       in_formula_used                Okl_Streams_Util.Var3TabTyp;
       in_entered_date                Okl_Streams_Util.DateTabTyp;
       in_accounting_date             Okl_Streams_Util.DateTabTyp;
       in_gl_reversal_flag            Okl_Streams_Util.Var3TabTyp;
       in_post_to_gl                  Okl_Streams_Util.Var3TabTyp;
       in_currency_code               Okl_Streams_Util.Var30TabTyp;
       --The currency_conversion_type columnn is a VARCHAR2(30)
       in_currency_conversion_type    Okl_Streams_Util.Var30TabTyp;
       in_currency_conversion_date    Okl_Streams_Util.DateTabTyp;
       in_currency_conversion_rate    Okl_Streams_Util.NumberTabTyp;
       in_khr_id                      Okl_Streams_Util.NumberTabTyp;
       in_kle_id                      Okl_Streams_Util.NumberTabTyp;
       in_pay_vendor_sites_pk         Okl_Streams_Util.Var50TabTyp;
       in_rec_site_uses_pk            Okl_Streams_Util.Var50TabTyp;
       in_asset_category_id_pk1       Okl_Streams_Util.Var50TabTyp;
       in_asset_book_pk2              Okl_Streams_Util.Var50TabTyp;
       in_pay_financial_options_pk    Okl_Streams_Util.Var50TabTyp;
       in_jtf_sales_reps_pk           Okl_Streams_Util.Var50TabTyp;
       in_inventory_item_id_pk1       Okl_Streams_Util.Var50TabTyp;
       in_inventory_org_id_pk2        Okl_Streams_Util.Var50TabTyp;
       in_rec_trx_types_pk            Okl_Streams_Util.Var50TabTyp;
       in_avl_id                      Okl_Streams_Util.NumberTabTyp;
       in_local_product_yn            Okl_Streams_Util.Var3TabTyp;
       in_internal_status             Okl_Streams_Util.Var30TabTyp;
       in_custom_status               Okl_Streams_Util.Var30TabTyp;
       in_source_indicator_flag       Okl_Streams_Util.Var30TabTyp;
       in_org_id                      Okl_Streams_Util.Number15NoPrecisionTabTyp;
       in_program_id                  Okl_Streams_Util.NumberTabTyp;
       in_program_application_id      Okl_Streams_Util.NumberTabTyp;
       in_request_id                  Okl_Streams_Util.NumberTabTyp;
       in_program_update_date         Okl_Streams_Util.DateTabTyp;
       in_created_by                  Okl_Streams_Util.NumberTabTyp;
       in_creation_date               Okl_Streams_Util.DateTabTyp;
       in_last_updated_by             Okl_Streams_Util.NumberTabTyp;
       in_last_update_date            Okl_Streams_Util.DateTabTyp;
       in_last_update_login           Okl_Streams_Util.NumberTabTyp;
       --Declaring the local variables used
       l_created_by                     NUMBER;
       l_last_updated_by                NUMBER;
       l_creation_date                  DATE;
       l_last_update_date               DATE;
       l_last_update_login              NUMBER;
       i                                INTEGER;
       j                                INTEGER;
       l_org_id                         NUMBER;
       l_request_id NUMBER := Fnd_Global.CONC_REQUEST_ID;
       l_prog_app_id NUMBER := Fnd_Global.PROG_APPL_ID;
       l_program_id NUMBER := Fnd_Global.CONC_PROGRAM_ID;
       l_prog_update_date   DATE;

     BEGIN
         x_return_Status := OKC_API.G_RET_STS_SUCCESS;
         i := p_asev_tbl.FIRST;
         j:=0;
        --Assigning the values for the who columns
         l_created_by := FND_GLOBAL.USER_ID;
         l_last_updated_by := FND_GLOBAL.USER_ID;
         l_creation_date := SYSDATE;
         l_last_update_date := SYSDATE;
         l_last_update_login := FND_GLOBAL.LOGIN_ID;
         --Deriving the org_id to be used
         l_org_id  := MO_GLOBAL.GET_CURRENT_ORG_ID();

         SELECT DECODE(l_request_id, -1, NULL, l_request_id),
         DECODE(l_prog_app_id, -1, NULL, l_prog_app_id),
         DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
         DECODE(l_request_id, -1, NULL, SYSDATE)
         INTO  l_request_id
             ,l_prog_app_id
             ,l_program_id
             ,l_prog_update_date
         FROM DUAL;

       WHILE i is not null LOOP
         j:=j+1;
         in_id(j) := get_seq_id;
         --Assigning the id to the return table
         x_asev_tbl(j).id := in_id(j);

         in_source_table(j)             := p_asev_tbl(i).source_table;
         in_source_id(j)                := p_asev_tbl(i).source_id;
         in_pdt_id(j)                   := p_asev_tbl(i).pdt_id;
         in_try_id(j)                   := p_asev_tbl(i).try_id;
         in_sty_id(j)                   := p_asev_tbl(i).sty_id;
         in_memo_yn(j)                  := p_asev_tbl(i).memo_yn;
         in_factor_investor_flag(j)     := p_asev_tbl(i).factor_investor_flag;
         in_factor_investor_code(j)     := p_asev_tbl(i).factor_investor_code;
         in_amount(j)                   := p_asev_tbl(i).amount;
         in_formula_used(j)             := p_asev_tbl(i).formula_used;
         in_entered_date(j)             := p_asev_tbl(i).entered_date;
         in_accounting_date(j)          := p_asev_tbl(i).accounting_date;
         in_gl_reversal_flag(j)         := p_asev_tbl(i).gl_reversal_flag;
         in_post_to_gl(j)               := p_asev_tbl(i).post_to_gl;
         in_currency_code(j)            := p_asev_tbl(i).currency_code;
         in_currency_conversion_type(j) := p_asev_tbl(i).currency_conversion_type;
         in_currency_conversion_date(j) := p_asev_tbl(i).currency_conversion_date;
         in_currency_conversion_rate(j) := p_asev_tbl(i).currency_conversion_rate;
         in_khr_id(j)                   := p_asev_tbl(i).khr_id;
         in_kle_id(j)                   := p_asev_tbl(i).kle_id;
         in_pay_vendor_sites_pk(j)      := p_asev_tbl(i).pay_vendor_sites_pk;
         in_rec_site_uses_pk(j)         := p_asev_tbl(i).rec_site_uses_pk;
         in_asset_category_id_pk1(j)    := p_asev_tbl(i).asset_category_id_pk1;
         in_asset_book_pk2(j)           := p_asev_tbl(i).asset_book_pk2;
         in_pay_financial_options_pk(j) := p_asev_tbl(i).pay_financial_options_pk;
         in_jtf_sales_reps_pk(j)        := p_asev_tbl(i).jtf_sales_reps_pk;
         in_inventory_item_id_pk1(j)    := p_asev_tbl(i).inventory_item_id_pk1;
         in_inventory_org_id_pk2(j)     := p_asev_tbl(i).inventory_org_id_pk2;
         in_rec_trx_types_pk(j)         := p_asev_tbl(i).rec_trx_types_pk;
         in_avl_id(j)                   := p_asev_tbl(i).avl_id;
         in_local_product_yn(j)         := p_asev_tbl(i).local_product_yn;
         in_internal_status(j)          := p_asev_tbl(i).internal_status;
         in_custom_status(j)            := p_asev_tbl(i).custom_status;
         in_source_indicator_flag(j)    := p_asev_tbl(i).source_indicator_flag;
         in_org_id(j)                   := l_org_id;
         in_program_id(j)               := l_program_id;
         in_program_application_id(j)   := l_prog_app_id;
         in_request_id(j)               := l_request_id;
         in_program_update_date(j)      := l_prog_update_date;
         in_created_by(j)               := l_created_by;
         in_creation_date(j)            := l_creation_date;
         in_last_updated_by(j)          := l_last_updated_by;
         in_last_update_date(j)         := l_last_update_date;
         in_last_update_login(j)        := l_last_update_login;
         i:= p_asev_tbl.next(i);
       END LOOP;

        FORALL i in 1..l_tabsize
           INSERT INTO okl_acct_sources(id
                                        ,source_table
                                        ,source_id
                                        ,pdt_id
                                        ,try_id
                                        ,sty_id
                                        ,memo_yn
                                        ,factor_investor_flag
                                        ,factor_investor_code
                                        ,amount
                                        ,formula_used
                                        ,entered_date
                                        ,accounting_date
                                        ,gl_reversal_flag
                                        ,post_to_gl
                                        ,currency_code
                                        ,currency_conversion_type
                                        ,currency_conversion_date
                                        ,currency_conversion_rate
                                        ,khr_id
                                        ,kle_id
                                        ,pay_vendor_sites_pk
                                        ,rec_site_uses_pk
                                        ,asset_category_id_pk1
                                        ,asset_book_pk2
                                        ,pay_financial_options_pk
                                        ,jtf_sales_reps_pk
                                        ,inventory_item_id_pk1
                                        ,inventory_org_id_pk2
                                        ,rec_trx_types_pk
                                        ,avl_id
                                        ,local_product_yn
                                        ,internal_status
                                        ,custom_status
                                        ,source_indicator_flag
                                        ,org_id
                                        ,program_id
                                        ,program_application_id
                                        ,request_id
                                        ,program_update_date
                                        ,created_by
                                        ,creation_date
                                        ,last_updated_by
                                        ,last_update_date
                                        ,last_update_login)
                                  VALUES(in_id(i)
                                        ,in_source_table(i)
                                        ,in_source_id(i)
                                        ,in_pdt_id(i)
                                        ,in_try_id(i)
                                        ,in_sty_id(i)
                                        ,in_memo_yn(i)
                                        ,in_factor_investor_flag(i)
                                        ,in_factor_investor_code(i)
                                        ,in_amount(i)
                                        ,in_formula_used(i)
                                        ,in_entered_date(i)
                                        ,in_accounting_date(i)
                                        ,in_gl_reversal_flag(i)
                                        ,in_post_to_gl(i)
                                        ,in_currency_code(i)
                                        ,in_currency_conversion_type(i)
                                        ,in_currency_conversion_date(i)
                                        ,in_currency_conversion_rate(i)
                                        ,in_khr_id(i)
                                        ,in_kle_id(i)
                                        ,in_pay_vendor_sites_pk(i)
                                        ,in_rec_site_uses_pk(i)
                                        ,in_asset_category_id_pk1(i)
                                        ,in_asset_book_pk2(i)
                                        ,in_pay_financial_options_pk(i)
                                        ,in_jtf_sales_reps_pk(i)
                                        ,in_inventory_item_id_pk1(i)
                                        ,in_inventory_org_id_pk2(i)
                                        ,in_rec_trx_types_pk(i)
                                        ,in_avl_id(i)
                                        ,in_local_product_yn(i)
                                        ,in_internal_status(i)
                                        ,in_custom_status(i)
                                        ,in_source_indicator_flag(i)
                                        ,in_org_id(i)
                                        ,in_program_id(i)
                                        ,in_program_application_id(i)
                                        ,in_request_id(i)
                                        ,in_program_update_date(i)
                                        ,in_created_by(i)
                                        ,in_creation_date(i)
                                        ,in_last_updated_by(i)
                                        ,in_last_update_date(i)
                                        ,in_last_update_login(i));

       x_return_status := l_return_status;
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
         x_return_status := Okc_Api.HANDLE_EXCEPTIONS
         (
           l_api_name,
           G_PKG_NAME,
           'OKC_API.G_RET_STS_UNEXP_ERROR',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );
       WHEN OTHERS THEN
         x_return_status := Okc_Api.HANDLE_EXCEPTIONS
         (
           l_api_name,
           G_PKG_NAME,
           'OTHERS',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );
     END insert_row_bulk;
     --Bug 4662173 - End of Changes

  ----------------------------------------
  -- PL/SQL TBL insert_row for:ASEV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_tbl                     IN asev_tbl_type,
    x_asev_tbl                     OUT NOCOPY asev_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_Status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asev_tbl.COUNT > 0) THEN
      i := p_asev_tbl.FIRST;
      LOOP
        insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_asev_rec                     => p_asev_tbl(i),
        x_asev_rec                     => x_asev_tbl(i));

         IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
            IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                l_overall_status := x_return_status;
            END IF;
          END IF;

        EXIT WHEN (i = p_asev_tbl.LAST);
        i := p_asev_tbl.NEXT(i);
      END LOOP;
    END IF;
        x_return_status := l_overall_Status;

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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -----------------------------------
  -- lock_row for:OKL_ACCT_SOURCES --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ase_rec                      IN ase_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ase_rec IN ase_rec_type) IS
    SELECT *
      FROM OKL_ACCT_SOURCES
     WHERE ID = p_ase_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
      OPEN lock_csr(p_ase_rec);
      FETCH lock_csr INTO l_lock_var;
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
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSE
      IF (l_lock_var.id <> p_ase_rec.id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.source_table <> p_ase_rec.source_table) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.source_id <> p_ase_rec.source_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.pdt_id <> p_ase_rec.pdt_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.try_id <> p_ase_rec.try_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.sty_id <> p_ase_rec.sty_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.memo_yn <> p_ase_rec.memo_yn) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.factor_investor_flag <> p_ase_rec.factor_investor_flag) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.factor_investor_code <> p_ase_rec.factor_investor_code) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.amount <> p_ase_rec.amount) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.formula_used <> p_ase_rec.formula_used) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.entered_date <> p_ase_rec.entered_date) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.accounting_date <> p_ase_rec.accounting_date) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.gl_reversal_flag <> p_ase_rec.gl_reversal_flag) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.post_to_gl <> p_ase_rec.post_to_gl) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.currency_code <> p_ase_rec.currency_code) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.currency_conversion_type <> p_ase_rec.currency_conversion_type) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.currency_conversion_date <> p_ase_rec.currency_conversion_date) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.currency_conversion_rate <> p_ase_rec.currency_conversion_rate) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.khr_id <> p_ase_rec.khr_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.kle_id <> p_ase_rec.kle_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.pay_vendor_sites_pk <> p_ase_rec.pay_vendor_sites_pk) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rec_site_uses_pk <> p_ase_rec.rec_site_uses_pk) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_category_id_pk1 <> p_ase_rec.asset_category_id_pk1) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_book_pk2 <> p_ase_rec.asset_book_pk2) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.pay_financial_options_pk <> p_ase_rec.pay_financial_options_pk) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.jtf_sales_reps_pk <> p_ase_rec.jtf_sales_reps_pk) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.inventory_item_id_pk1 <> p_ase_rec.inventory_item_id_pk1) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.inventory_org_id_pk2 <> p_ase_rec.inventory_org_id_pk2) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rec_trx_types_pk <> p_ase_rec.rec_trx_types_pk) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.avl_id <> p_ase_rec.avl_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.local_product_yn <> p_ase_rec.local_product_yn) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.internal_status <> p_ase_rec.internal_status) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.custom_status <> p_ase_rec.custom_status) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.source_indicator_flag <> p_ase_rec.source_indicator_flag) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.org_id <> p_ase_rec.org_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.program_id <> p_ase_rec.program_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.program_application_id <> p_ase_rec.program_application_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.request_id <> p_ase_rec.request_id) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.program_update_date <> p_ase_rec.program_update_date) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.created_by <> p_ase_rec.created_by) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.creation_date <> p_ase_rec.creation_date) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_updated_by <> p_ase_rec.last_updated_by) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_date <> p_ase_rec.last_update_date) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_login <> p_ase_rec.last_update_login) THEN
        Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for: OKL_ACCT_SOURCES_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN asev_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_ase_rec                      ase_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_asev_rec, l_ase_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ase_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:ASEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_tbl                     IN asev_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_asev_tbl.COUNT > 0) THEN
      i := p_asev_tbl.FIRST;
      LOOP
	  lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_asev_rec                     => p_asev_tbl(i));

   IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_asev_tbl.LAST);
        i := p_asev_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- update_row for:OKL_ACCT_SOURCES --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ase_rec                      IN ase_rec_type,
    x_ase_rec                      OUT NOCOPY ase_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_ase_rec                      ase_rec_type := p_ase_rec;
    l_def_ase_rec                  ase_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ase_rec IN ase_rec_type,
      x_ase_rec OUT NOCOPY ase_rec_type
    ) RETURN VARCHAR2 IS
      l_ase_rec                      ase_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ase_rec := p_ase_rec;
      -- Get current database values
      l_ase_rec := get_rec(p_ase_rec, l_return_status);
      IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
        -- smadhava Bug#5032013 Modified G_MISS_NUM to G_MISS_CHAR
        IF (x_ase_rec.id = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.id := l_ase_rec.id;
        END IF;
        IF (x_ase_rec.source_table = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.source_table := l_ase_rec.source_table;
        END IF;
        IF (x_ase_rec.source_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.source_id := l_ase_rec.source_id;
        END IF;
        IF (x_ase_rec.pdt_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.pdt_id := l_ase_rec.pdt_id;
        END IF;
        IF (x_ase_rec.try_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.try_id := l_ase_rec.try_id;
        END IF;
        IF (x_ase_rec.sty_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.sty_id := l_ase_rec.sty_id;
        END IF;
        IF (x_ase_rec.memo_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.memo_yn := l_ase_rec.memo_yn;
        END IF;
        IF (x_ase_rec.factor_investor_flag = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.factor_investor_flag := l_ase_rec.factor_investor_flag;
        END IF;
        IF (x_ase_rec.factor_investor_code = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.factor_investor_code := l_ase_rec.factor_investor_code;
        END IF;
        IF (x_ase_rec.amount = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.amount := l_ase_rec.amount;
        END IF;
        IF (x_ase_rec.formula_used = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.formula_used := l_ase_rec.formula_used;
        END IF;
        IF (x_ase_rec.entered_date = Okc_Api.G_MISS_DATE)
        THEN
          x_ase_rec.entered_date := l_ase_rec.entered_date;
        END IF;
        IF (x_ase_rec.accounting_date = Okc_Api.G_MISS_DATE)
        THEN
          x_ase_rec.accounting_date := l_ase_rec.accounting_date;
        END IF;
        IF (x_ase_rec.gl_reversal_flag = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.gl_reversal_flag := l_ase_rec.gl_reversal_flag;
        END IF;
        IF (x_ase_rec.post_to_gl = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.post_to_gl := l_ase_rec.post_to_gl;
        END IF;
        IF (x_ase_rec.currency_code = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.currency_code := l_ase_rec.currency_code;
        END IF;
        IF (x_ase_rec.currency_conversion_type = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.currency_conversion_type := l_ase_rec.currency_conversion_type;
        END IF;
        IF (x_ase_rec.currency_conversion_date = Okc_Api.G_MISS_DATE)
        THEN
          x_ase_rec.currency_conversion_date := l_ase_rec.currency_conversion_date;
        END IF;
        IF (x_ase_rec.currency_conversion_rate = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.currency_conversion_rate := l_ase_rec.currency_conversion_rate;
        END IF;
        IF (x_ase_rec.khr_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.khr_id := l_ase_rec.khr_id;
        END IF;
        IF (x_ase_rec.kle_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.kle_id := l_ase_rec.kle_id;
        END IF;
        IF (x_ase_rec.pay_vendor_sites_pk = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.pay_vendor_sites_pk := l_ase_rec.pay_vendor_sites_pk;
        END IF;
        IF (x_ase_rec.rec_site_uses_pk = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.rec_site_uses_pk := l_ase_rec.rec_site_uses_pk;
        END IF;
        IF (x_ase_rec.asset_category_id_pk1 = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.asset_category_id_pk1 := l_ase_rec.asset_category_id_pk1;
        END IF;
        IF (x_ase_rec.asset_book_pk2 = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.asset_book_pk2 := l_ase_rec.asset_book_pk2;
        END IF;
        IF (x_ase_rec.pay_financial_options_pk = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.pay_financial_options_pk := l_ase_rec.pay_financial_options_pk;
        END IF;
        IF (x_ase_rec.jtf_sales_reps_pk = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.jtf_sales_reps_pk := l_ase_rec.jtf_sales_reps_pk;
        END IF;
        IF (x_ase_rec.inventory_item_id_pk1 = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.inventory_item_id_pk1 := l_ase_rec.inventory_item_id_pk1;
        END IF;
        IF (x_ase_rec.inventory_org_id_pk2 = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.inventory_org_id_pk2 := l_ase_rec.inventory_org_id_pk2;
        END IF;
        IF (x_ase_rec.rec_trx_types_pk = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.rec_trx_types_pk := l_ase_rec.rec_trx_types_pk;
        END IF;
        IF (x_ase_rec.avl_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.avl_id := l_ase_rec.avl_id;
        END IF;
        IF (x_ase_rec.local_product_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.local_product_yn := l_ase_rec.local_product_yn;
        END IF;
        IF (x_ase_rec.internal_status = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.internal_status := l_ase_rec.internal_status;
        END IF;
        IF (x_ase_rec.custom_status = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.custom_status := l_ase_rec.custom_status;
        END IF;
        IF (x_ase_rec.source_indicator_flag = Okc_Api.G_MISS_CHAR)
        THEN
          x_ase_rec.source_indicator_flag := l_ase_rec.source_indicator_flag;
        END IF;
        IF (x_ase_rec.org_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.org_id := l_ase_rec.org_id;
        END IF;
        IF (x_ase_rec.program_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.program_id := l_ase_rec.program_id;
        END IF;
        IF (x_ase_rec.program_application_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.program_application_id := l_ase_rec.program_application_id;
        END IF;
        IF (x_ase_rec.request_id = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.request_id := l_ase_rec.request_id;
        END IF;
        IF (x_ase_rec.program_update_date = Okc_Api.G_MISS_DATE)
        THEN
          x_ase_rec.program_update_date := l_ase_rec.program_update_date;
        END IF;
        IF (x_ase_rec.created_by = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.created_by := l_ase_rec.created_by;
        END IF;
        IF (x_ase_rec.creation_date = Okc_Api.G_MISS_DATE)
        THEN
          x_ase_rec.creation_date := l_ase_rec.creation_date;
        END IF;
        IF (x_ase_rec.last_updated_by = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.last_updated_by := l_ase_rec.last_updated_by;
        END IF;
        IF (x_ase_rec.last_update_date = Okc_Api.G_MISS_DATE)
        THEN
          x_ase_rec.last_update_date := l_ase_rec.last_update_date;
        END IF;
        IF (x_ase_rec.last_update_login = Okc_Api.G_MISS_NUM)
        THEN
          x_ase_rec.last_update_login := l_ase_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_ACCT_SOURCES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ase_rec IN ase_rec_type,
      x_ase_rec OUT NOCOPY ase_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ase_rec := p_ase_rec;
      RETURN(l_return_status);
    END Set_Attributes;
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
      p_ase_rec,                         -- IN
      l_ase_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ase_rec, l_def_ase_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_ACCT_SOURCES
    SET SOURCE_TABLE = l_def_ase_rec.source_table,
        SOURCE_ID = l_def_ase_rec.source_id,
        PDT_ID = l_def_ase_rec.pdt_id,
        TRY_ID = l_def_ase_rec.try_id,
        STY_ID = l_def_ase_rec.sty_id,
        MEMO_YN = l_def_ase_rec.memo_yn,
        FACTOR_INVESTOR_FLAG = l_def_ase_rec.factor_investor_flag,
        FACTOR_INVESTOR_CODE = l_def_ase_rec.factor_investor_code,
        AMOUNT = l_def_ase_rec.amount,
        FORMULA_USED = l_def_ase_rec.formula_used,
        ENTERED_DATE = l_def_ase_rec.entered_date,
        ACCOUNTING_DATE = l_def_ase_rec.accounting_date,
        GL_REVERSAL_FLAG = l_def_ase_rec.gl_reversal_flag,
        POST_TO_GL = l_def_ase_rec.post_to_gl,
        CURRENCY_CODE = l_def_ase_rec.currency_code,
        CURRENCY_CONVERSION_TYPE = l_def_ase_rec.currency_conversion_type,
        CURRENCY_CONVERSION_DATE = l_def_ase_rec.currency_conversion_date,
        CURRENCY_CONVERSION_RATE = l_def_ase_rec.currency_conversion_rate,
        KHR_ID = l_def_ase_rec.khr_id,
        KLE_ID = l_def_ase_rec.kle_id,
        PAY_VENDOR_SITES_PK = l_def_ase_rec.pay_vendor_sites_pk,
        REC_SITE_USES_PK = l_def_ase_rec.rec_site_uses_pk,
        ASSET_CATEGORY_ID_PK1 = l_def_ase_rec.asset_category_id_pk1,
        ASSET_BOOK_PK2 = l_def_ase_rec.asset_book_pk2,
        PAY_FINANCIAL_OPTIONS_PK = l_def_ase_rec.pay_financial_options_pk,
        JTF_SALES_REPS_PK = l_def_ase_rec.jtf_sales_reps_pk,
        INVENTORY_ITEM_ID_PK1 = l_def_ase_rec.inventory_item_id_pk1,
        INVENTORY_ORG_ID_PK2 = l_def_ase_rec.inventory_org_id_pk2,
        REC_TRX_TYPES_PK = l_def_ase_rec.rec_trx_types_pk,
        AVL_ID = l_def_ase_rec.avl_id,
        LOCAL_PRODUCT_YN = l_def_ase_rec.local_product_yn,
        INTERNAL_STATUS = l_def_ase_rec.internal_status,
        CUSTOM_STATUS = l_def_ase_rec.custom_status,
        SOURCE_INDICATOR_FLAG = l_def_ase_rec.source_indicator_flag,
        ORG_ID = l_def_ase_rec.org_id,
        PROGRAM_ID = l_def_ase_rec.program_id,
        PROGRAM_APPLICATION_ID = l_def_ase_rec.program_application_id,
        REQUEST_ID = l_def_ase_rec.request_id,
        PROGRAM_UPDATE_DATE = l_def_ase_rec.program_update_date,
        CREATED_BY = l_def_ase_rec.created_by,
        CREATION_DATE = l_def_ase_rec.creation_date,
        LAST_UPDATED_BY = l_def_ase_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ase_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ase_rec.last_update_login
    WHERE ID = l_def_ase_rec.id;

    x_ase_rec := l_ase_rec;
    x_return_status := l_return_status;
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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ---------------------------------------
  -- update_row for:OKL_ACCT_SOURCES_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN asev_rec_type,
    x_asev_rec                     OUT NOCOPY asev_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_asev_rec                     asev_rec_type := p_asev_rec;
    l_def_asev_rec                 asev_rec_type;
    l_db_asev_rec                  asev_rec_type;
    l_ase_rec                      ase_rec_type;
    lx_ase_rec                     ase_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_asev_rec IN asev_rec_type
    ) RETURN asev_rec_type IS
      l_asev_rec asev_rec_type := p_asev_rec;
    BEGIN
      l_asev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_asev_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_asev_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_asev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_asev_rec IN asev_rec_type,
      x_asev_rec OUT NOCOPY asev_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_asev_rec := p_asev_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_asev_rec := get_rec(p_asev_rec, l_return_status);
      IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
        -- udhenuko Bug#5042061 Modified G_MISS_NUM to G_MISS_CHAR
        IF (x_asev_rec.id = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.id := l_db_asev_rec.id;
        END IF;
        IF (x_asev_rec.source_table = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.source_table := l_db_asev_rec.source_table;
        END IF;
        IF (x_asev_rec.source_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.source_id := l_db_asev_rec.source_id;
        END IF;
        IF (x_asev_rec.pdt_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.pdt_id := l_db_asev_rec.pdt_id;
        END IF;
        IF (x_asev_rec.try_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.try_id := l_db_asev_rec.try_id;
        END IF;
        IF (x_asev_rec.sty_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.sty_id := l_db_asev_rec.sty_id;
        END IF;
        IF (x_asev_rec.memo_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.memo_yn := l_db_asev_rec.memo_yn;
        END IF;
        IF (x_asev_rec.factor_investor_flag = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.factor_investor_flag := l_db_asev_rec.factor_investor_flag;
        END IF;
        IF (x_asev_rec.factor_investor_code = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.factor_investor_code := l_db_asev_rec.factor_investor_code;
        END IF;
        IF (x_asev_rec.amount = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.amount := l_db_asev_rec.amount;
        END IF;
        IF (x_asev_rec.formula_used = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.formula_used := l_db_asev_rec.formula_used;
        END IF;
        IF (x_asev_rec.entered_date = Okc_Api.G_MISS_DATE)
        THEN
          x_asev_rec.entered_date := l_db_asev_rec.entered_date;
        END IF;
        IF (x_asev_rec.accounting_date = Okc_Api.G_MISS_DATE)
        THEN
          x_asev_rec.accounting_date := l_db_asev_rec.accounting_date;
        END IF;
        IF (x_asev_rec.gl_reversal_flag = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.gl_reversal_flag := l_db_asev_rec.gl_reversal_flag;
        END IF;
        IF (x_asev_rec.post_to_gl = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.post_to_gl := l_db_asev_rec.post_to_gl;
        END IF;
        IF (x_asev_rec.currency_code = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.currency_code := l_db_asev_rec.currency_code;
        END IF;
        IF (x_asev_rec.currency_conversion_type = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.currency_conversion_type := l_db_asev_rec.currency_conversion_type;
        END IF;
        IF (x_asev_rec.currency_conversion_date = Okc_Api.G_MISS_DATE)
        THEN
          x_asev_rec.currency_conversion_date := l_db_asev_rec.currency_conversion_date;
        END IF;
        IF (x_asev_rec.currency_conversion_rate = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.currency_conversion_rate := l_db_asev_rec.currency_conversion_rate;
        END IF;
        IF (x_asev_rec.khr_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.khr_id := l_db_asev_rec.khr_id;
        END IF;
        IF (x_asev_rec.kle_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.kle_id := l_db_asev_rec.kle_id;
        END IF;
        IF (x_asev_rec.pay_vendor_sites_pk = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.pay_vendor_sites_pk := l_db_asev_rec.pay_vendor_sites_pk;
        END IF;
        IF (x_asev_rec.rec_site_uses_pk = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.rec_site_uses_pk := l_db_asev_rec.rec_site_uses_pk;
        END IF;
        IF (x_asev_rec.asset_category_id_pk1 = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.asset_category_id_pk1 := l_db_asev_rec.asset_category_id_pk1;
        END IF;
        IF (x_asev_rec.asset_book_pk2 = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.asset_book_pk2 := l_db_asev_rec.asset_book_pk2;
        END IF;
        IF (x_asev_rec.pay_financial_options_pk = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.pay_financial_options_pk := l_db_asev_rec.pay_financial_options_pk;
        END IF;
        IF (x_asev_rec.jtf_sales_reps_pk = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.jtf_sales_reps_pk := l_db_asev_rec.jtf_sales_reps_pk;
        END IF;
        IF (x_asev_rec.inventory_item_id_pk1 = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.inventory_item_id_pk1 := l_db_asev_rec.inventory_item_id_pk1;
        END IF;
        IF (x_asev_rec.inventory_org_id_pk2 = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.inventory_org_id_pk2 := l_db_asev_rec.inventory_org_id_pk2;
        END IF;
        IF (x_asev_rec.rec_trx_types_pk = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.rec_trx_types_pk := l_db_asev_rec.rec_trx_types_pk;
        END IF;
        IF (x_asev_rec.avl_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.avl_id := l_db_asev_rec.avl_id;
        END IF;
        IF (x_asev_rec.local_product_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.local_product_yn := l_db_asev_rec.local_product_yn;
        END IF;
        IF (x_asev_rec.internal_status = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.internal_status := l_db_asev_rec.internal_status;
        END IF;
        IF (x_asev_rec.custom_status = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.custom_status := l_db_asev_rec.custom_status;
        END IF;
        IF (x_asev_rec.source_indicator_flag = Okc_Api.G_MISS_CHAR)
        THEN
          x_asev_rec.source_indicator_flag := l_db_asev_rec.source_indicator_flag;
        END IF;
        IF (x_asev_rec.org_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.org_id := l_db_asev_rec.org_id;
        END IF;
        IF (x_asev_rec.program_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.program_id := l_db_asev_rec.program_id;
        END IF;
        IF (x_asev_rec.program_application_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.program_application_id := l_db_asev_rec.program_application_id;
        END IF;
        IF (x_asev_rec.request_id = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.request_id := l_db_asev_rec.request_id;
        END IF;
        IF (x_asev_rec.program_update_date = Okc_Api.G_MISS_DATE)
        THEN
          x_asev_rec.program_update_date := l_db_asev_rec.program_update_date;
        END IF;
        IF (x_asev_rec.created_by = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.created_by := l_db_asev_rec.created_by;
        END IF;
        IF (x_asev_rec.creation_date = Okc_Api.G_MISS_DATE)
        THEN
          x_asev_rec.creation_date := l_db_asev_rec.creation_date;
        END IF;
        IF (x_asev_rec.last_updated_by = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.last_updated_by := l_db_asev_rec.last_updated_by;
        END IF;
        IF (x_asev_rec.last_update_date = Okc_Api.G_MISS_DATE)
        THEN
          x_asev_rec.last_update_date := l_db_asev_rec.last_update_date;
        END IF;
        IF (x_asev_rec.last_update_login = Okc_Api.G_MISS_NUM)
        THEN
          x_asev_rec.last_update_login := l_db_asev_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_ACCT_SOURCES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_asev_rec IN asev_rec_type,
      x_asev_rec OUT NOCOPY asev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	  l_request_id NUMBER := Fnd_Global.CONC_REQUEST_ID;
	  l_prog_app_id NUMBER := Fnd_Global.PROG_APPL_ID;
	  l_program_id NUMBER := Fnd_Global.CONC_PROGRAM_ID;

    BEGIN
      x_asev_rec := p_asev_rec;

	 SELECT  NVL(DECODE(l_request_id, -1, NULL, l_request_id) ,p_asev_rec.REQUEST_ID)
    ,NVL(DECODE(l_prog_app_id, -1, NULL, l_prog_app_id) ,p_asev_rec.PROGRAM_APPLICATION_ID)
    ,NVL(DECODE(l_program_id, -1, NULL, l_program_id)  ,p_asev_rec.PROGRAM_ID)
    ,DECODE(DECODE(l_request_id, -1, NULL, SYSDATE) ,NULL, p_asev_rec.PROGRAM_UPDATE_DATE,SYSDATE)
  	INTO x_asev_rec.REQUEST_ID
    ,x_asev_rec.PROGRAM_APPLICATION_ID
    ,x_asev_rec.PROGRAM_ID
    ,x_asev_rec.PROGRAM_UPDATE_DATE
    FROM DUAL;

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
      p_asev_rec,                        -- IN
      x_asev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_asev_rec, l_def_asev_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_asev_rec := fill_who_columns(l_def_asev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_asev_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
-- bug 4049781
    l_return_status := Validate_Record(l_def_asev_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

/*
-- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_asev_rec                     => p_asev_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
*/

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_asev_rec, l_ase_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ase_rec,
      lx_ase_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ase_rec, l_def_asev_rec);
    x_asev_rec := l_def_asev_rec;
    x_return_status := l_return_status;
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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:ASEV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_tbl                     IN asev_tbl_type,
    x_asev_tbl                     OUT NOCOPY asev_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing

    IF (p_asev_tbl.COUNT > 0) THEN
      i := p_asev_tbl.FIRST;
      LOOP
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_asev_rec                     => p_asev_tbl(i),
        x_asev_rec                     => x_asev_tbl(i));

    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
            IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                l_overall_status := x_return_status;
            END IF;
          END IF;

        EXIT WHEN (i = p_asev_tbl.LAST);
        i := p_asev_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_Status := l_overall_Status;

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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- delete_row for:OKL_ACCT_SOURCES --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ase_rec                      IN ase_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_ase_rec                      ase_rec_type := p_ase_rec;
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

    DELETE FROM OKL_ACCT_SOURCES
     WHERE ID = p_ase_rec.id;

    x_return_status := l_return_status;
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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ---------------------------------------
  -- delete_row for:OKL_ACCT_SOURCES_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN asev_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_asev_rec                     asev_rec_type := p_asev_rec;
    l_ase_rec                      ase_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_asev_rec, l_ase_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ase_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  --------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_ACCT_SOURCES_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_tbl                     IN asev_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing

    IF (p_asev_tbl.COUNT > 0) THEN
      i := p_asev_tbl.FIRST;
      LOOP
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_asev_rec                     => p_asev_tbl(i));

   IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_asev_tbl.LAST);
        i := p_asev_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

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
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END Okl_Ase_Pvt;

/
