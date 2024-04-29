--------------------------------------------------------
--  DDL for Package Body OKL_GTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GTS_PVT" AS
/* $Header: OKLSGTSB.pls 120.6 2007/10/15 16:44:33 dpsingh noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ST_GEN_TMPT_SETS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_gts_rec                      IN  gts_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN gts_rec_type IS
    CURSOR okl_st_gen_tmpt_sets_pk_csr (p_id IN NUMBER) IS
    SELECT  ID
            ,OBJECT_VERSION_NUMBER
            ,NAME
            ,DESCRIPTION
            ,PRODUCT_TYPE
            ,TAX_OWNER
            ,DEAL_TYPE
            ,PRICING_ENGINE
            ,ORG_ID
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATE_LOGIN
            ,INTEREST_CALC_METH_CODE
            ,REVENUE_RECOG_METH_CODE
            ,DAYS_IN_MONTH_CODE
            ,DAYS_IN_YR_CODE
           ,ISG_ARREARS_PAY_DATES_OPTION
    FROM OKL_ST_GEN_TMPT_SETS
    WHERE OKL_ST_GEN_TMPT_SETS.id = p_id;

    l_okl_st_gen_tmpt_sets_pk   okl_st_gen_tmpt_sets_pk_csr%ROWTYPE;
    l_gts_rec                   gts_rec_type;
  BEGIN
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_st_gen_tmpt_sets_pk_csr (p_gts_rec.id);

    FETCH okl_st_gen_tmpt_sets_pk_csr INTO
        l_gts_rec.id
        ,l_gts_rec.object_version_number
        ,l_gts_rec.name
        ,l_gts_rec.description
        ,l_gts_rec.product_type
        ,l_gts_rec.tax_owner
        ,l_gts_rec.deal_type
        ,l_gts_rec.pricing_engine
        ,l_gts_rec.org_id
        ,l_gts_rec.created_by
        ,l_gts_rec.creation_date
        ,l_gts_rec.last_updated_by
        ,l_gts_rec.last_update_date
        ,l_gts_rec.last_update_login
        ,l_gts_rec.interest_calc_meth_code
        ,l_gts_rec.revenue_recog_meth_code
        ,l_gts_rec.days_in_month_code
        ,l_gts_rec.days_in_yr_code
        ,l_gts_rec.isg_arrears_pay_dates_option;


    x_no_data_found := okl_st_gen_tmpt_sets_pk_csr%NOTFOUND;
    CLOSE okl_st_gen_tmpt_sets_pk_csr;

    RETURN(l_gts_rec);

  END get_rec;

  FUNCTION get_rec (
    p_gts_rec                      IN gts_rec_type
  ) RETURN gts_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_gts_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SYS_ACCT_OPTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_gtsv_rec                     IN  gtsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN gtsv_rec_type IS
    CURSOR okl_gtsv_pk_csr (p_id                 IN NUMBER) IS
    SELECT ID
        ,OBJECT_VERSION_NUMBER
        ,NAME
        ,DESCRIPTION
        ,PRODUCT_TYPE
        ,TAX_OWNER
        ,DEAL_TYPE
        ,PRICING_ENGINE
        ,ORG_ID
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,INTEREST_CALC_METH_CODE
        ,REVENUE_RECOG_METH_CODE
        ,DAYS_IN_MONTH_CODE
        ,DAYS_IN_YR_CODE
        ,ISG_ARREARS_PAY_DATES_OPTION
FROM OKL_ST_GEN_TMPT_SETS
    WHERE OKL_ST_GEN_TMPT_SETS.ID = p_id;

    l_okl_gtsv_pk                  okl_gtsv_pk_csr%ROWTYPE;
    l_gtsv_rec                     gtsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_gtsv_pk_csr (p_gtsv_rec.id);
    FETCH okl_gtsv_pk_csr INTO
        l_gtsv_rec.id
        ,l_gtsv_rec.object_version_number
        ,l_gtsv_rec.name
        ,l_gtsv_rec.description
        ,l_gtsv_rec.product_type
        ,l_gtsv_rec.tax_owner
        ,l_gtsv_rec.deal_type
        ,l_gtsv_rec.pricing_engine
        ,l_gtsv_rec.org_id
        ,l_gtsv_rec.created_by
        ,l_gtsv_rec.creation_date
        ,l_gtsv_rec.last_updated_by
        ,l_gtsv_rec.last_update_date
        ,l_gtsv_rec.last_update_login
        ,l_gtsv_rec.interest_calc_meth_code
        ,l_gtsv_rec.revenue_recog_meth_code
        ,l_gtsv_rec.days_in_month_code
        ,l_gtsv_rec.days_in_yr_code
        ,l_gtsv_rec.isg_arrears_pay_dates_option;

    x_no_data_found := okl_gtsv_pk_csr%NOTFOUND;
    CLOSE okl_gtsv_pk_csr;
    RETURN(l_gtsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_gtsv_rec                     IN gtsv_rec_type
  ) RETURN gtsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_gtsv_rec, l_row_notfound));
  END get_rec;

---------------------------------------------------------------------------
     -- PROCEDURE validate_arrears_pay_dt_opt
     ---------------------------------------------------------------------------

     PROCEDURE validate_arrears_pay_dt_opt(
         p_gtsv_rec      IN   gtsv_rec_type,
       x_return_status OUT NOCOPY  VARCHAR2
     ) IS
     l_dummy varchar2(1);

     BEGIN
       -- initialize return status
       x_return_status := Okl_Api.G_RET_STS_SUCCESS;

       IF (p_gtsv_rec.ISG_ARREARS_PAY_DATES_OPTION <>  Okl_Api.G_MISS_CHAR ) AND
          (p_gtsv_rec.ISG_ARREARS_PAY_DATES_OPTION IS NOT NULL) THEN

          l_dummy
             := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_ISG_ARREAR_PAY_DATE_OPTION',
                                          p_lookup_code => p_gtsv_rec.isg_arrears_pay_dates_option);

          IF (l_dummy = Okl_Api.G_FALSE) THEN
             Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'ISG_ARREARS_PAY_DATES_OPTION');
             x_return_status    := Okl_Api.G_RET_STS_ERROR;
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
         Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

         -- notify caller of an UNEXPECTED error
         x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

     END validate_arrears_pay_dt_opt;

---------------------------------------------------------------------------
  -- PROCEDURE validate_id
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
    p_gtsv_rec      IN   gtsv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := okl_api.G_RET_STS_SUCCESS;

    IF p_gtsv_rec.id = okl_api.G_MISS_NUM OR
       p_gtsv_rec.id IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := okl_api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_object_version_number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(
    p_gtsv_rec      IN   gtsv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := okl_api.G_RET_STS_SUCCESS;

    IF p_gtsv_rec.object_version_number = okl_api.G_MISS_NUM OR
       p_gtsv_rec.object_version_number IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := okl_api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_name
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
---------------------------------------------------------------------------
  PROCEDURE Validate_name(
    p_gtsv_rec      IN   gtsv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  CURSOR okl_st_gen_tempt_sets_csr(p_name OKL_ST_GEN_TMPT_SETS.name%type) IS
    SELECT  ID
           ,name tmpt_set_name
    FROM OKL_ST_GEN_TMPT_SETS gts
    WHERE UPPER(gts.name) = upper( p_name );
    l_name_in_use VARCHAR2(1) := okl_api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := okl_api.G_RET_STS_SUCCESS;

    IF p_gtsv_rec.name = okl_api.G_MISS_CHAR OR
       p_gtsv_rec.name IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TEMPLATE_SET_NAME');
      x_return_status := okl_api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
        FOR gtsv_temp_rec In okl_st_gen_tempt_sets_csr(p_gtsv_rec.name)
        LOOP
            IF( gtsv_temp_rec.id <> p_gtsv_rec.id )
            THEN
                l_name_in_use := Okl_Api.G_TRUE;
            END IF;
        END LOOP;
        IF ( l_name_in_use = Okl_Api.G_TRUE )
        THEN
            okl_api.set_message(G_APP_NAME,
                                'OKL_NAME_VERSION_NOT_UNIQUE'
                                );
            x_return_status := okl_api.G_RET_STS_ERROR;
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
      okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

  END Validate_name;


---------------------------------------------------------------------------
    -- PROCEDURE validate_product_type
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : validate_tax_owner
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE validate_product_type(
      p_gtsv_rec      IN   gtsv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    BEGIN
      -- initialize return status
      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- check for data before processing
      IF (p_gtsv_rec.product_type IS NOT NULL) AND
         (p_gtsv_rec.product_type  <> okl_api.G_MISS_CHAR) THEN

      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_STREAM_PRODUCT_TYPE',
                                     p_lookup_code => p_gtsv_rec.product_type);


      IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'PRODUCT_TYPE');
         x_return_status := okl_api.G_RET_STS_ERROR;
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
        okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

    END validate_product_type;
    ---------------------------------------------------------------------------
    -- PROCEDURE validate_tax_owner
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : validate_tax_owner
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE validate_tax_owner(
      p_gtsv_rec      IN   gtsv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    BEGIN
      -- initialize return status
      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- check for data before processing
      IF (p_gtsv_rec.tax_owner IS NOT NULL) AND
         (p_gtsv_rec.tax_owner  <> okl_api.G_MISS_CHAR) THEN

      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_TAX_OWNER',
                                     p_lookup_code => p_gtsv_rec.tax_owner);


      IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'TAX_OWNER');
         x_return_status := okl_api.G_RET_STS_ERROR;
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
        okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

    END validate_tax_owner;

    ---------------------------------------------------------------------------
    -- PROCEDURE validate_deal_type
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : validate_deal_type
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE validate_deal_type(
      p_gtsv_rec      IN   gtsv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    BEGIN
      -- initialize return status
      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- check for data before processing
      IF (p_gtsv_rec.deal_type IS NOT NULL) AND
         (p_gtsv_rec.deal_type  <> okl_api.G_MISS_CHAR) THEN


      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_STREAM_ALL_BOOK_CLASS',
                                     p_lookup_code => p_gtsv_rec.deal_type);

      IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'DEAL_TYPE');
         x_return_status := okl_api.G_RET_STS_ERROR;
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
        okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

    END validate_deal_type;

    ---------------------------------------------------------------------------
    -- PROCEDURE validate_pricing_engine
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : validate_pricing_engine
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE validate_pricing_engine(
      p_gtsv_rec      IN   gtsv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    BEGIN
      -- initialize return status
      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- check for data before processing
      IF (p_gtsv_rec.pricing_engine IS NOT NULL) AND
         (p_gtsv_rec.pricing_engine  <> okl_api.G_MISS_CHAR) THEN

      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_STREAM_PRICING',
                                     p_lookup_code => p_gtsv_rec.pricing_engine);


      IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'PRICING_ENGINE');
         x_return_status := okl_api.G_RET_STS_ERROR;
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
        okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

    END validate_pricing_engine;

    ---------------------------------------------------------------------------
    -- PROCEDURE val_interest_calc_meth_code
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : val_interest_calc_meth_code
    -- Description     : Validates that INTEREST_CALC_METH_CODE is entered / valid
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE val_interest_calc_meth_code(
      p_gtsv_rec      IN   gtsv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    BEGIN
      -- initialize return status
      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- check for data before processing
    IF p_gtsv_rec.INTEREST_CALC_METH_CODE = okl_api.G_MISS_CHAR OR
       p_gtsv_rec.INTEREST_CALC_METH_CODE IS NULL
    THEN
      IF p_gtsv_rec.product_type = OKL_GTS_PVT.G_FINANCIAL_TYPE THEN
        okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'INTEREST_CALC_METH_CODE');
        x_return_status := okl_api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_INTEREST_CALCULATION_BASIS',
                                     p_lookup_code => p_gtsv_rec.INTEREST_CALC_METH_CODE);
      IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'INTEREST_CALC_METH_CODE');
         x_return_status := okl_api.G_RET_STS_ERROR;
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
        okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

    END val_interest_calc_meth_code;

    ---------------------------------------------------------------------------
    -- PROCEDURE val_revenue_recog_meth_code
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : val_revenue_recog_meth_code
    -- Description     : Validates that REVENUE_RECOG_METH_CODE is entered / valid
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE val_revenue_recog_meth_code(
      p_gtsv_rec      IN   gtsv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    BEGIN
      -- initialize return status
      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- check for data before processing
    IF p_gtsv_rec.REVENUE_RECOG_METH_CODE = okl_api.G_MISS_CHAR OR
       p_gtsv_rec.REVENUE_RECOG_METH_CODE IS NULL
    THEN
      IF p_gtsv_rec.product_type = OKL_GTS_PVT.G_FINANCIAL_TYPE THEN
        okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'REVENUE_RECOG_METH_CODE');
        x_return_status := okl_api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_REVENUE_RECOGNITION_METHOD',
                                     p_lookup_code => p_gtsv_rec.REVENUE_RECOG_METH_CODE);
      IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'REVENUE_RECOG_METH_CODE');
         x_return_status := okl_api.G_RET_STS_ERROR;
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
        okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

    END val_revenue_recog_meth_code;

    ---------------------------------------------------------------------------
    -- PROCEDURE validate_days_in_month_code
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : validate_days_in_month_code
    -- Description     : Validates that validate_days_in_month_code is entered / valid
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE validate_days_in_month_code(
      p_gtsv_rec      IN   gtsv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    BEGIN
      -- initialize return status
      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- check for data before processing
    IF p_gtsv_rec.DAYS_IN_MONTH_CODE = okl_api.G_MISS_CHAR OR
       p_gtsv_rec.DAYS_IN_MONTH_CODE IS NULL
    THEN
      IF p_gtsv_rec.product_type = OKL_GTS_PVT.G_FINANCIAL_TYPE THEN
        okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'DAYS_IN_MONTH_CODE');
        x_return_status := okl_api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_MONTH_TYPE',
                                     p_lookup_code => p_gtsv_rec.DAYS_IN_MONTH_CODE);

      IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'DAYS_IN_MONTH_CODE');
         x_return_status := okl_api.G_RET_STS_ERROR;
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
        okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

    END validate_days_in_month_code;

    ---------------------------------------------------------------------------
    -- PROCEDURE validate_days_in_yr_code
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : validate_days_in_yr_code
    -- Description     : Validates that from validate_days_in_yr_code is entered / valid
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE validate_days_in_yr_code(
      p_gtsv_rec      IN   gtsv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    BEGIN
      -- initialize return status
      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- check for data before processing
    IF p_gtsv_rec.DAYS_IN_YR_CODE = okl_api.G_MISS_CHAR OR
       p_gtsv_rec.DAYS_IN_YR_CODE IS NULL
    THEN
      IF p_gtsv_rec.product_type = OKL_GTS_PVT.G_FINANCIAL_TYPE THEN
        okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'OKL_YEAR_TYPE');
        x_return_status := okl_api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_YEAR_TYPE',
                                     p_lookup_code => p_gtsv_rec.DAYS_IN_YR_CODE);

      IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'DAYS_IN_YR_CODE');
         x_return_status := okl_api.G_RET_STS_ERROR;
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
        okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

    END validate_days_in_yr_code;

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
    p_gtsv_rec IN  gtsv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation


     -- Validate_Id
    Validate_Id(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    validate_object_version_number(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;
    -- validate_name
    -- Need to find a solution so as to check for the uniqueness
    -- during the duplicate scenario.
    validate_name(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;
    Validate_product_type(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    validate_tax_owner(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    validate_deal_type(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    validate_pricing_engine(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    val_interest_calc_meth_code(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    val_revenue_recog_meth_code(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    validate_days_in_month_code(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    validate_days_in_yr_code(p_gtsv_rec, x_return_status);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

     --  Added for new field by dpsingh for bug 6274342
       validate_arrears_pay_dt_opt (p_gtsv_rec, x_return_status);
       IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
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
       -- just come out with return status
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
  END;



  ----------------------------------------------
  -- validate_record for:OKL_ST_GEN_TMPT_SETS --
  ----------------------------------------------
 FUNCTION validate_record (
    p_gtsv_rec IN gtsv_rec_type
  ) RETURN VARCHAR2 IS
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END validate_record;

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
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN gts_rec_type,
    p_to	IN OUT NOCOPY gtsv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.product_type := p_from.product_type;
    p_to.tax_owner := p_from.tax_owner;
    p_to.deal_type := p_from.deal_type;
    p_to.pricing_engine := p_from.pricing_engine;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.interest_calc_meth_code  := p_from.interest_calc_meth_code;
    p_to.revenue_recog_meth_code   := p_from.revenue_recog_meth_code;
    p_to.days_in_month_code  := p_from.days_in_month_code;
    p_to.days_in_yr_code   := p_from.days_in_yr_code;
    p_to.isg_arrears_pay_dates_option   := p_from.isg_arrears_pay_dates_option;

  END;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN gtsv_rec_type,
    p_to	IN OUT NOCOPY gts_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.product_type := p_from.product_type;
    p_to.tax_owner := p_from.tax_owner;
    p_to.deal_type := p_from.deal_type;
    p_to.pricing_engine := p_from.pricing_engine;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.interest_calc_meth_code  := p_from.interest_calc_meth_code;
    p_to.revenue_recog_meth_code   := p_from.revenue_recog_meth_code;
    p_to.days_in_month_code  := p_from.days_in_month_code;
    p_to.days_in_yr_code   := p_from.days_in_yr_code;
    p_to.isg_arrears_pay_dates_option   := p_from.isg_arrears_pay_dates_option;
  END;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : null_out_defaults
  -- Description     : nulling out the defaults
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_gtsv_rec	IN gtsv_rec_type
  ) RETURN gtsv_rec_type IS
    l_gtsv_rec	gtsv_rec_type := p_gtsv_rec;
  BEGIN

    IF (l_gtsv_rec.id = okl_api.G_MISS_NUM) THEN
        l_gtsv_rec.id := NULL;
    END IF;
    IF (l_gtsv_rec.object_version_number = okl_api.G_MISS_NUM) THEN
        l_gtsv_rec.object_version_number := NULL;
    END IF;
    IF (l_gtsv_rec.name = okl_api.G_MISS_CHAR) THEN
        l_gtsv_rec.name := NULL;
    END IF;
    IF (l_gtsv_rec.description = okl_api.G_MISS_CHAR) THEN
        l_gtsv_rec.description := NULL;
    END IF;
    IF (l_gtsv_rec.product_type = okl_api.G_MISS_CHAR) THEN
        l_gtsv_rec.product_type := NULL;
    END IF;
    IF (l_gtsv_rec.tax_owner = okl_api.G_MISS_CHAR) THEN
        l_gtsv_rec.tax_owner := NULL;
    END IF;
    IF (l_gtsv_rec.deal_type = okl_api.G_MISS_CHAR) THEN
        l_gtsv_rec.deal_type := NULL;
    END IF;
    IF (l_gtsv_rec.pricing_engine = okl_api.G_MISS_CHAR) THEN
        l_gtsv_rec.pricing_engine := NULL;
    END IF;
     IF (l_gtsv_rec.org_id = okl_api.G_MISS_NUM) THEN
      l_gtsv_rec.org_id := NULL;
    END IF;
    IF (l_gtsv_rec.created_by = okl_api.G_MISS_NUM) THEN
      l_gtsv_rec.created_by := NULL;
    END IF;
    IF (l_gtsv_rec.creation_date = okl_api.G_MISS_DATE) THEN
      l_gtsv_rec.creation_date := NULL;
    END IF;
    IF (l_gtsv_rec.last_updated_by = okl_api.G_MISS_NUM) THEN
      l_gtsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_gtsv_rec.last_update_date = okl_api.G_MISS_DATE) THEN
      l_gtsv_rec.last_update_date := NULL;
    END IF;
    IF (l_gtsv_rec.last_update_login = okl_api.G_MISS_NUM) THEN
      l_gtsv_rec.last_update_login := NULL;
    END IF;
    IF (l_gtsv_rec.INTEREST_CALC_METH_CODE  = okl_api.G_MISS_CHAR) THEN
      l_gtsv_rec.INTEREST_CALC_METH_CODE  := NULL;
    END IF;
    IF (l_gtsv_rec.REVENUE_RECOG_METH_CODE = okl_api.G_MISS_CHAR) THEN
      l_gtsv_rec.REVENUE_RECOG_METH_CODE := NULL;
    END IF;
    IF (l_gtsv_rec.DAYS_IN_MONTH_CODE  = okl_api.G_MISS_CHAR) THEN
      l_gtsv_rec.DAYS_IN_MONTH_CODE  := NULL;
    END IF;
    IF (l_gtsv_rec.DAYS_IN_YR_CODE = okl_api.G_MISS_CHAR) THEN
      l_gtsv_rec.DAYS_IN_YR_CODE := NULL;
    END IF;
    IF (l_gtsv_rec.ISG_ARREARS_PAY_DATES_OPTION = okl_api.G_MISS_CHAR) THEN
      l_gtsv_rec.ISG_ARREARS_PAY_DATES_OPTION := NULL;
    END IF;
    RETURN(l_gtsv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : procedure for inserting the records in
  --                   table OKL_ST_GEN_TMPT_SETS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gts_rec                      IN gts_rec_type,
    x_gts_rec                      OUT NOCOPY gts_rec_type ) IS

    -- Local Variables within the function
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status               VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_gts_rec                     gts_rec_type := p_gts_rec;
    l_def_gts_rec                 gts_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_TMPT_SETS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_gts_rec IN  gts_rec_type,
      x_gts_rec OUT NOCOPY gts_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_gts_rec := p_gts_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_gts_rec,    -- IN
      l_gts_rec     -- OUT
    );
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_ST_GEN_TMPT_SETS(
       Id
      ,object_version_number
      ,name
      ,description
      ,product_type
      ,tax_owner
      ,deal_type
      ,pricing_engine
      ,org_id
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,interest_calc_meth_code
      ,revenue_recog_meth_code
      ,days_in_month_code
      ,days_in_yr_code
      ,isg_arrears_pay_dates_option
    )
    VALUES (
       l_gts_rec.Id
      ,l_gts_rec.object_version_number
      ,l_gts_rec.name
      ,l_gts_rec.description
      ,l_gts_rec.product_type
      ,l_gts_rec.tax_owner
      ,l_gts_rec.deal_type
      ,l_gts_rec.pricing_engine
      ,l_gts_rec.org_id
      ,l_gts_rec.created_by
      ,l_gts_rec.creation_date
      ,l_gts_rec.last_updated_by
      ,l_gts_rec.last_update_date
      ,l_gts_rec.last_update_login
      ,l_gts_rec.interest_calc_meth_code
      ,l_gts_rec.revenue_recog_meth_code
      ,l_gts_rec.days_in_month_code
      ,l_gts_rec.days_in_yr_code
      ,l_gts_rec.isg_arrears_pay_dates_option
    );

    -- Set OUT values
    x_gts_rec := l_gts_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_rec                     IN gtsv_rec_type,
    x_gtsv_rec                     OUT NOCOPY gtsv_rec_type ) IS

    -- Local Variables within the function
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_gtsv_rec                     gtsv_rec_type;
    l_def_gtsv_rec                 gtsv_rec_type;
    l_gts_rec                      gts_rec_type;
    lx_gts_rec                     gts_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_gtsv_rec	IN gtsv_rec_type
    ) RETURN gtsv_rec_type IS
      l_gtsv_rec	gtsv_rec_type := p_gtsv_rec;
    BEGIN
      l_gtsv_rec.CREATION_DATE := SYSDATE;
      l_gtsv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_gtsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_gtsv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_gtsv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_gtsv_rec);
    END fill_who_columns;

    -----------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_TMPT_SETS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_gtsv_rec IN  gtsv_rec_type,
      x_gtsv_rec OUT NOCOPY gtsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtsv_rec := p_gtsv_rec;
      x_gtsv_rec.OBJECT_VERSION_NUMBER := 1;
      x_gtsv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

      RETURN(l_return_status);
    END Set_Attributes;

   BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    l_gtsv_rec := null_out_defaults(p_gtsv_rec);
    -- Set primary key value
    l_gtsv_rec.ID := get_seq_id;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_gtsv_rec,                        -- IN
      l_def_gtsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- fill who columns for the l_def_gtsv_rec
    l_def_gtsv_rec := fill_who_columns(l_def_gtsv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_gtsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    -- Perfrom all row level validations
    l_return_status := validate_record(l_def_gtsv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_gtsv_rec, l_gts_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_api_version => l_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_gts_rec => l_gts_rec,
      x_gts_rec => lx_gts_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_gts_rec, l_def_gtsv_rec);

    -- Set OUT values
    x_gtsv_rec := l_def_gtsv_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END; -- insert_row

  ----------------------------------------
  -- PL/SQL TBL insert_row for:GTSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_tbl                     IN  gtsv_tbl_type,
    x_gtsv_tbl                     OUT NOCOPY gtsv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status 		       VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Making sure PL/SQL table has records in it before passing
    IF (p_gtsv_tbl.COUNT > 0) THEN
      i := p_gtsv_tbl.FIRST;
      LOOP

        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gtsv_rec                     => p_gtsv_tbl(i),
          x_gtsv_rec                     => x_gtsv_tbl(i));

    	-- store the highest degree of error
    	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
        EXIT WHEN (i = p_gtsv_tbl.LAST);
        i := p_gtsv_tbl.NEXT(i);
      END LOOP;

      -- return overall status
      x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : procedure for updating the records in
  --                   table OKL_ST_GEN_TMPT_SETS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  --------------------------------------------------------------------------

  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gts_rec                      IN  gts_rec_type,
    x_gts_rec                      OUT NOCOPY gts_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_gts_rec                      gts_rec_type := p_gts_rec;
    l_def_gts_rec                  gts_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_gts_rec	IN  gts_rec_type,
      x_gts_rec	OUT NOCOPY gts_rec_type
    ) RETURN VARCHAR2 IS
      l_gts_rec                      gts_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_gts_rec := p_gts_rec;

      -- Get current database values
      l_gts_rec := get_rec(p_gts_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_gts_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_gts_rec.id := l_gts_rec.id;
      END IF;
      IF (x_gts_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_gts_rec.object_version_number := l_gts_rec.object_version_number;
      END IF;
      IF ( x_gts_rec.name = okl_api.G_MISS_CHAR )
      THEN
        x_gts_rec.name  := l_gts_rec.name;
      END IF;
      IF ( x_gts_rec.description = okl_api.G_MISS_CHAR )
      THEN
        x_gts_rec.description := l_gts_rec.description;
      END IF;
      IF ( x_gts_rec.product_type = okl_api.G_MISS_CHAR )
      THEN
        x_gts_rec.product_type := l_gts_rec.product_type;
      END IF;
      IF ( x_gts_rec.tax_owner = okl_api.G_MISS_CHAR )
      THEN
        x_gts_rec.tax_owner := l_gts_rec.tax_owner;
      END IF;
      IF ( x_gts_rec.deal_type = okl_api.G_MISS_CHAR )
      THEN
        x_gts_rec.deal_type := l_gts_rec.deal_type;
      END IF;
      IF ( x_gts_rec.pricing_engine = okl_api.G_MISS_CHAR )
      THEN
        x_gts_rec.pricing_engine := l_gts_rec.pricing_engine;
      END IF;
      IF (x_gts_rec.org_id = okl_api.G_MISS_NUM)
      THEN
        x_gts_rec.org_id := l_gts_rec.org_id;
      END IF;
      IF (x_gts_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_gts_rec.created_by := l_gts_rec.created_by;
      END IF;
      IF (x_gts_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_gts_rec.creation_date := l_gts_rec.creation_date;
      END IF;
      IF (x_gts_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_gts_rec.last_updated_by := l_gts_rec.last_updated_by;
      END IF;
      IF (x_gts_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_gts_rec.last_update_date := l_gts_rec.last_update_date;
      END IF;
      IF (x_gts_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_gts_rec.last_update_login := l_gts_rec.last_update_login;
      END IF;

      if (x_gts_rec.interest_calc_meth_code = okl_api.g_miss_char)
      then
        x_gts_rec.interest_calc_meth_code := l_gts_rec.interest_calc_meth_code;
      end if;

      if (x_gts_rec.revenue_recog_meth_code  = okl_api.g_miss_char)
      then
        x_gts_rec.revenue_recog_meth_code  := l_gts_rec.revenue_recog_meth_code;
      end if;

      if (x_gts_rec.days_in_month_code  = okl_api.g_miss_char)
      then
        x_gts_rec.days_in_month_code  := l_gts_rec.days_in_month_code;
      end if;

      if (x_gts_rec.days_in_yr_code  = okl_api.g_miss_char)
      then
        x_gts_rec.days_in_yr_code  := l_gts_rec.days_in_yr_code;
      end if;

       if (x_gts_rec.isg_arrears_pay_dates_option  = okl_api.g_miss_char)
      then
        x_gts_rec.isg_arrears_pay_dates_option  := l_gts_rec.isg_arrears_pay_dates_option;
      end if;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_TMPT_SETS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_gts_rec IN  gts_rec_type,
      x_gts_rec OUT NOCOPY gts_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_gts_rec := p_gts_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_gts_rec,                         -- IN
      l_gts_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_gts_rec, l_def_gts_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_ST_GEN_TMPT_SETS
    SET ID                     = l_def_gts_rec.id
        ,OBJECT_VERSION_NUMBER = l_def_gts_rec.object_version_number
        ,NAME                  = l_def_gts_rec.name
        ,DESCRIPTION           = l_def_gts_rec.description
        ,PRODUCT_TYPE          = l_def_gts_rec.product_type
        ,TAX_OWNER             = l_def_gts_rec.tax_owner
        ,DEAL_TYPE             = l_def_gts_rec.deal_type
        ,PRICING_ENGINE        = l_def_gts_rec.pricing_engine
        ,ORG_ID                = l_def_gts_rec.org_id
        ,CREATED_BY            = l_def_gts_rec.created_by
        ,CREATION_DATE         = l_def_gts_rec.creation_date
        ,LAST_UPDATED_BY       = l_def_gts_rec.last_updated_by
        ,LAST_UPDATE_DATE      = l_def_gts_rec.last_update_date
        ,LAST_UPDATE_LOGIN     = l_def_gts_rec.last_update_login
        ,INTEREST_CALC_METH_CODE = l_def_gts_rec.INTEREST_CALC_METH_CODE
        ,REVENUE_RECOG_METH_CODE = l_def_gts_rec.REVENUE_RECOG_METH_CODE
        ,DAYS_IN_MONTH_CODE  	= l_def_gts_rec.DAYS_IN_MONTH_CODE
        ,DAYS_IN_YR_CODE        = l_def_gts_rec.DAYS_IN_YR_CODE
       ,ISG_ARREARS_PAY_DATES_OPTION        = l_def_gts_rec.ISG_ARREARS_PAY_DATES_OPTION
    WHERE ID = l_def_gts_rec.id;

    x_gts_rec := l_def_gts_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_rec                      IN  gtsv_rec_type,
    x_gtsv_rec                      OUT NOCOPY gtsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_gtsv_rec                     gtsv_rec_type := p_gtsv_rec;
    l_def_gtsv_rec                 gtsv_rec_type;
    l_gts_rec                      gts_rec_type;
    lx_gts_rec                     gts_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_gtsv_rec	IN gtsv_rec_type
    ) RETURN gtsv_rec_type IS
      l_gtsv_rec	gtsv_rec_type := p_gtsv_rec;
    BEGIN
      l_gtsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_gtsv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_gtsv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_gtsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_gtsv_rec	IN  gtsv_rec_type,
      x_gtsv_rec	OUT NOCOPY gtsv_rec_type
    ) RETURN VARCHAR2 IS
      l_gtsv_rec                      gtsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtsv_rec := p_gtsv_rec;

      -- Get current database values
      l_gtsv_rec := get_rec(p_gtsv_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_gtsv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_gtsv_rec.id := l_gts_rec.id;
      END IF;
      IF (x_gtsv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_gtsv_rec.object_version_number := l_gtsv_rec.object_version_number;
      END IF;
      IF ( x_gtsv_rec.name = okl_api.G_MISS_CHAR )
      THEN
        x_gtsv_rec.name  := l_gtsv_rec.name;
      END IF;
      IF ( x_gtsv_rec.description = okl_api.G_MISS_CHAR )
      THEN
        x_gtsv_rec.description := l_gtsv_rec.description;
      END IF;
      IF ( x_gtsv_rec.product_type = okl_api.G_MISS_CHAR )
      THEN
        x_gtsv_rec.product_type := l_gtsv_rec.product_type;
      END IF;
      IF ( x_gtsv_rec.tax_owner = okl_api.G_MISS_CHAR )
      THEN
        x_gtsv_rec.tax_owner := l_gtsv_rec.tax_owner;
      END IF;
      IF ( x_gtsv_rec.deal_type = okl_api.G_MISS_CHAR )
      THEN
        x_gtsv_rec.deal_type := l_gtsv_rec.deal_type;
      END IF;
      IF ( x_gtsv_rec.pricing_engine = okl_api.G_MISS_CHAR )
      THEN
        x_gtsv_rec.pricing_engine := l_gtsv_rec.pricing_engine;
      END IF;
      IF (x_gtsv_rec.org_id = okl_api.G_MISS_NUM)
      THEN
        x_gtsv_rec.org_id := l_gtsv_rec.org_id;
      END IF;
      IF (x_gtsv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_gtsv_rec.created_by := l_gtsv_rec.created_by;
      END IF;
      IF (x_gtsv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_gtsv_rec.creation_date := l_gtsv_rec.creation_date;
      END IF;
      IF (x_gtsv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_gtsv_rec.last_updated_by := l_gtsv_rec.last_updated_by;
      END IF;
      IF (x_gtsv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_gtsv_rec.last_update_date := l_gtsv_rec.last_update_date;
      END IF;
      IF (x_gtsv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_gtsv_rec.last_update_login := l_gtsv_rec.last_update_login;
      END IF;
      IF ( x_gtsv_rec.INTEREST_CALC_METH_CODE = okl_api.G_MISS_CHAR )
      THEN
        x_gtsv_rec.INTEREST_CALC_METH_CODE := l_gtsv_rec.INTEREST_CALC_METH_CODE;
      END IF;
      IF ( x_gtsv_rec.REVENUE_RECOG_METH_CODE = okl_api.G_MISS_CHAR )
      THEN
        x_gtsv_rec.REVENUE_RECOG_METH_CODE := l_gtsv_rec.REVENUE_RECOG_METH_CODE;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for: OKL_ST_GEN_TMPT_SETS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_gtsv_rec IN  gtsv_rec_type,
      x_gtsv_rec OUT NOCOPY gtsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtsv_rec := p_gtsv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_gtsv_rec,                        -- IN
      l_gtsv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_gtsv_rec, l_def_gtsv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_gtsv_rec := fill_who_columns(l_def_gtsv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_gtsv_rec);

    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_gtsv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_gtsv_rec, l_gts_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_gts_rec => l_gts_rec,
      x_gts_rec => lx_gts_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_gts_rec, l_def_gtsv_rec);

    x_gtsv_rec := l_def_gtsv_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END;

  ----------------------------------------------------
  -- PL/SQL TBL update_row for:OKL_ST_GEN_TMPT_SETS --
  ----------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_tbl                     IN  gtsv_tbl_type,
    x_gtsv_tbl                     OUT NOCOPY gtsv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    l_overall_status 		  VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_gtsv_tbl.COUNT > 0) THEN
      i := p_gtsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gtsv_rec                     => p_gtsv_tbl(i),
          x_gtsv_rec                     => x_gtsv_tbl(i));

    	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;

        EXIT WHEN (i = p_gtsv_tbl.LAST);
        i := p_gtsv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -----------------------------------------
  -- delete_row for:OKL_ST_GEN_TMPT_SETS --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gts_rec                      IN  gts_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_gts_rec                      gts_rec_type:= p_gts_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- Actual deletion of the row
    DELETE FROM OKL_ST_GEN_TMPT_SETS
     WHERE ID = l_gts_rec.id;

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_ST_GEN_TMPT_SETS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_rec                     IN  gtsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_gtsv_rec                     gtsv_rec_type := p_gtsv_rec;
    l_gts_rec                      gts_rec_type;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_gtsv_rec, l_gts_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_gts_rec => l_gts_rec
    );

    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;


  ----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_ST_GEN_TMPT_SETS --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_tbl                     IN  gtsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    l_overall_status 		  VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_gtsv_tbl.COUNT > 0) THEN
      i := p_gtsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gtsv_rec                     => p_gtsv_tbl(i));

    	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;

        EXIT WHEN (i = p_gtsv_tbl.LAST);
        i := p_gtsv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END okl_gts_pvt;

/
