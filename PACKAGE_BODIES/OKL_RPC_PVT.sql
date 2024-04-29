--------------------------------------------------------
--  DDL for Package Body OKL_RPC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RPC_PVT" AS
/* $Header: OKLSRPCB.pls 120.6 2007/08/08 12:52:01 arajagop noship $ */



  ----------------------------------------
  -- GLOBAL CONSTANTS
  -- Post-Generation Change
  -- By RMUNJULU on 27-SEP-2001
  ----------------------------------------
  G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	    CONSTANT VARCHAR2(200) := 'SQLcode';
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- Start of comments
  --
  -- Procedure Name  : validate_currency_record
  -- Description     : Used for validation of Currency Code Conversion Coulms
  -- Business Rules  : If transaction currency <> functional currency, then conversion columns
  --                   are mandatory
  --                   Else If transaction currency = functional currency, then conversion columns
  --                   should all be NULL
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_record(p_rpcv_rec      IN  rpcv_rec_type,
                                     x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- If transaction currency <> functional currency, then conversion columns
    -- are mandatory
    IF (p_rpcv_rec.currency_code <> p_rpcv_rec.currency_conversion_code) THEN
      IF (p_rpcv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR OR
         p_rpcv_rec.currency_conversion_type IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_type');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_rpcv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM OR
         p_rpcv_rec.currency_conversion_rate IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_rate');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_rpcv_rec.currency_conversion_date = OKC_API.G_MISS_DATE OR
         p_rpcv_rec.currency_conversion_date IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_date');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    -- Else If transaction currency = functional currency, then conversion columns
    -- should all be NULL
    ELSIF (p_rpcv_rec.currency_code = p_rpcv_rec.currency_conversion_code) THEN
      IF (p_rpcv_rec.currency_conversion_type IS NOT NULL) OR
         (p_rpcv_rec.currency_conversion_rate IS NOT NULL) OR
         (p_rpcv_rec.currency_conversion_date IS NOT NULL) THEN
        --SET MESSAGE
        -- Currency conversion columns should be all null
        IF p_rpcv_rec.currency_conversion_rate IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_rate');
        END IF;
        IF p_rpcv_rec.currency_conversion_date IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_date');
        END IF;
        IF p_rpcv_rec.currency_conversion_type IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_type');
        END IF;
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    ELSE
        x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_currency_record;
---------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_currency_code
  -- Description     : Validation of Currency Code
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_code(p_rpcv_rec      IN  rpcv_rec_type,
                                   x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_rpcv_rec.currency_code IS NULL) OR
       (p_rpcv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_code');

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_rpcv_rec.currency_code);
    IF (l_return_status <>  OKC_API.G_TRUE) THEN
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_invalid_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'currency_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_currency_code;
---------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_currency_con_code
  -- Description     : Validation of Currency Conversion Code
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_code(p_rpcv_rec      IN  rpcv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_rpcv_rec.currency_conversion_code IS NULL) OR
       (p_rpcv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_conversion_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_rpcv_rec.currency_conversion_code);
    IF (l_return_status <>  OKC_API.G_TRUE) THEN
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'currency_conversion_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_currency_con_code;
---------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_currency_con_type
  -- Description     : Validation of Currency Conversion type
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_type(p_rpcv_rec      IN  rpcv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_rpcv_rec.currency_conversion_type <> OKL_API.G_MISS_CHAR AND
       p_rpcv_rec.currency_conversion_type IS NOT NULL) THEN
      -- check from currency values using the generic okl_util.validate_currency_code
      l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_con_type(p_rpcv_rec.currency_conversion_type);
      IF (l_return_status <>  OKC_API.G_TRUE) THEN
            OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'currency_conversion_type');
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_currency_con_type;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_id
  -- Post-Generation Change
  -- By RMUNJULU on 27-SEP-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_id(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rpcv_rec		IN	rpcv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
	IF (p_rpcv_rec.id = OKC_API.G_MISS_NUM OR p_rpcv_rec.id IS NULL) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_id;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  -- Post-Generation Change
  -- By RMUNJULU on 27-SEP-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_object_version_number(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rpcv_rec		IN	rpcv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rpcv_rec.object_version_number IS NULL)
	OR (p_rpcv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'object_version_number');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_object_version_number;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_sfwt_flag
  -- Post-Generation Change
  -- By RMUNJULU on 27-SEP-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_sfwt_flag(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rpcv_rec		IN	rpcv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rpcv_rec.sfwt_flag IS NULL)
	OR (p_rpcv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'sfwt_flag');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_sfwt_flag;



  ------------------------------------------------------------------------
  -- PROCEDURE validate_cost
  -- Post-Generation Change
  -- By RMUNJULU on 27-SEP-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_cost(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rpcv_rec		IN	rpcv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rpcv_rec.cost IS NULL)
	OR (p_rpcv_rec.cost = OKC_API.G_MISS_NUM) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'cost');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_cost;




  ------------------------------------------------------------------------
  -- PROCEDURE validate_repair_type
  -- Post-Generation Change
  -- By RMUNJULU on 27-SEP-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_repair_type(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rpcv_rec		IN	rpcv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rpcv_rec.repair_type IS NULL)
	OR (p_rpcv_rec.repair_type = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'repair_type');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_repair_type;



  ------------------------------------------------------------------------
  -- PROCEDURE validate_description
  -- Post-Generation Change
  -- By RMUNJULU on 27-SEP-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_description(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rpcv_rec		IN	rpcv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rpcv_rec.description IS NULL)
	OR (p_rpcv_rec.description = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'description');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_description;



  ------------------------------------------------------------------------
  -- PROCEDURE validate_enabled_yn
  -- Post-Generation Change
  -- By RMUNJULU on 27-SEP-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_enabled_yn (
    x_return_status              OUT NOCOPY VARCHAR2,
    p_rpcv_rec                   IN rpcv_rec_type ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- intialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic okl_util.check_domain_yn
    l_return_status := OKL_UTIL.check_domain_yn(p_rpcv_rec.enabled_yn);

    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_invalid_value,
                           p_token1       => g_col_name_token,
                           p_token1_value => 'enabled_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;

    ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_enabled_yn;


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
    DELETE FROM OKL_REPAIR_COSTS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_REPAIR_COSTS_ALL_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKL_REPAIR_COSTS_TL T SET (
        REPAIR_TYPE,
        DESCRIPTION) = (SELECT
                                  B.REPAIR_TYPE,
                                  B.DESCRIPTION
                                FROM OKL_REPAIR_COSTS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_REPAIR_COSTS_TL SUBB, OKL_REPAIR_COSTS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.REPAIR_TYPE <> SUBT.REPAIR_TYPE
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
              ));

    INSERT INTO OKL_REPAIR_COSTS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        REPAIR_TYPE,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.REPAIR_TYPE,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_REPAIR_COSTS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_REPAIR_COSTS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_REPAIR_COSTS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_repair_costs_tl_rec      IN okl_repair_costs_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_repair_costs_tl_rec_type IS
    CURSOR okl_repair_costs_tl_pk_csr (p_id                 IN NUMBER,
                                       p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            REPAIR_TYPE,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Repair_Costs_Tl
     WHERE okl_repair_costs_tl.id = p_id
       AND okl_repair_costs_tl.language = p_language;
    l_okl_repair_costs_tl_pk       okl_repair_costs_tl_pk_csr%ROWTYPE;
    l_okl_repair_costs_tl_rec      okl_repair_costs_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_repair_costs_tl_pk_csr (p_okl_repair_costs_tl_rec.id,
                                     p_okl_repair_costs_tl_rec.language);
    FETCH okl_repair_costs_tl_pk_csr INTO
              l_okl_repair_costs_tl_rec.ID,
              l_okl_repair_costs_tl_rec.LANGUAGE,
              l_okl_repair_costs_tl_rec.SOURCE_LANG,
              l_okl_repair_costs_tl_rec.SFWT_FLAG,
              l_okl_repair_costs_tl_rec.REPAIR_TYPE,
              l_okl_repair_costs_tl_rec.DESCRIPTION,
              l_okl_repair_costs_tl_rec.CREATED_BY,
              l_okl_repair_costs_tl_rec.CREATION_DATE,
              l_okl_repair_costs_tl_rec.LAST_UPDATED_BY,
              l_okl_repair_costs_tl_rec.LAST_UPDATE_DATE,
              l_okl_repair_costs_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_repair_costs_tl_pk_csr%NOTFOUND;
    CLOSE okl_repair_costs_tl_pk_csr;
    RETURN(l_okl_repair_costs_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_repair_costs_tl_rec      IN okl_repair_costs_tl_rec_type
  ) RETURN okl_repair_costs_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_repair_costs_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_REPAIR_COSTS_B
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : get_rec
  -- Description     : for: OKL_REPAIR_COSTS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION get_rec (
    p_rpc_rec                      IN rpc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rpc_rec_type IS
    CURSOR okl_repair_costs_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            ENABLED_YN,
            ORG_ID,
            COST,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
  -- SPILLAIP - 2667636 - Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
  -- SPILLAIP - 2667636 - End
      FROM Okl_Repair_Costs_B
     WHERE okl_repair_costs_b.id = p_id;
    l_okl_repair_costs_b_pk        okl_repair_costs_b_pk_csr%ROWTYPE;
    l_rpc_rec                      rpc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_repair_costs_b_pk_csr (p_rpc_rec.id);
    FETCH okl_repair_costs_b_pk_csr INTO
              l_rpc_rec.ID,
              l_rpc_rec.OBJECT_VERSION_NUMBER,
              l_rpc_rec.ENABLED_YN,
              l_rpc_rec.ORG_ID,
              l_rpc_rec.COST,
              l_rpc_rec.CREATED_BY,
              l_rpc_rec.CREATION_DATE,
              l_rpc_rec.LAST_UPDATED_BY,
              l_rpc_rec.LAST_UPDATE_DATE,
              l_rpc_rec.LAST_UPDATE_LOGIN,
  -- SPILLAIP - 2667636 - Start
              l_rpc_rec.CURRENCY_CODE,
              l_rpc_rec.CURRENCY_CONVERSION_CODE,
              l_rpc_rec.CURRENCY_CONVERSION_TYPE,
              l_rpc_rec.CURRENCY_CONVERSION_RATE,
              l_rpc_rec.CURRENCY_CONVERSION_DATE;
  -- SPILLAIP - 2667636 - End
    x_no_data_found := okl_repair_costs_b_pk_csr%NOTFOUND;
    CLOSE okl_repair_costs_b_pk_csr;
    RETURN(l_rpc_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rpc_rec                      IN rpc_rec_type
  ) RETURN rpc_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rpc_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_REPAIR_COSTS_V
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : get_rec
  -- Description     : for: OKL_REPAIR_COSTS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION get_rec (
    p_rpcv_rec                     IN rpcv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rpcv_rec_type IS
    CURSOR okl_rpcv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            ENABLED_YN,
            ORG_ID,
            COST,
            REPAIR_TYPE,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
 -- SPILLAIP - 2667636 - Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
 -- SPILLAIP - 2667636 - End
      FROM Okl_Repair_Costs_V
     WHERE okl_repair_costs_v.id = p_id;
    l_okl_rpcv_pk                  okl_rpcv_pk_csr%ROWTYPE;
    l_rpcv_rec                     rpcv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_rpcv_pk_csr (p_rpcv_rec.id);
    FETCH okl_rpcv_pk_csr INTO
              l_rpcv_rec.ID,
              l_rpcv_rec.OBJECT_VERSION_NUMBER,
              l_rpcv_rec.SFWT_FLAG,
              l_rpcv_rec.ENABLED_YN,
              l_rpcv_rec.ORG_ID,
              l_rpcv_rec.COST,
              l_rpcv_rec.REPAIR_TYPE,
              l_rpcv_rec.DESCRIPTION,
              l_rpcv_rec.CREATED_BY,
              l_rpcv_rec.CREATION_DATE,
              l_rpcv_rec.LAST_UPDATED_BY,
              l_rpcv_rec.LAST_UPDATE_DATE,
              l_rpcv_rec.LAST_UPDATE_LOGIN,
  -- SPILLAIP - 2667636 -Start
              l_rpcv_rec.CURRENCY_CODE,
              l_rpcv_rec.CURRENCY_CONVERSION_CODE,
              l_rpcv_rec.CURRENCY_CONVERSION_TYPE,
              l_rpcv_rec.CURRENCY_CONVERSION_RATE,
              l_rpcv_rec.CURRENCY_CONVERSION_DATE;
  -- SPILLAIP - 2667636 -End
    x_no_data_found := okl_rpcv_pk_csr%NOTFOUND;
    CLOSE okl_rpcv_pk_csr;
    RETURN(l_rpcv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rpcv_rec                     IN rpcv_rec_type
  ) RETURN rpcv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rpcv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_REPAIR_COSTS_V --
  --------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : null_out_defaults
  -- Description     : for: OKL_REPAIR_COSTS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION null_out_defaults (
    p_rpcv_rec	IN rpcv_rec_type
  ) RETURN rpcv_rec_type IS
    l_rpcv_rec	rpcv_rec_type := p_rpcv_rec;
  BEGIN
    IF (l_rpcv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_rpcv_rec.object_version_number := NULL;
    END IF;
    IF (l_rpcv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_rpcv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_rpcv_rec.enabled_yn = OKC_API.G_MISS_CHAR) THEN
      l_rpcv_rec.enabled_yn := NULL;
    END IF;
    IF (l_rpcv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_rpcv_rec.org_id := NULL;
    END IF;
    IF (l_rpcv_rec.cost = OKC_API.G_MISS_NUM) THEN
      l_rpcv_rec.cost := NULL;
    END IF;
    IF (l_rpcv_rec.repair_type = OKC_API.G_MISS_CHAR) THEN
      l_rpcv_rec.repair_type := NULL;
    END IF;
    IF (l_rpcv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_rpcv_rec.description := NULL;
    END IF;
    IF (l_rpcv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_rpcv_rec.created_by := NULL;
    END IF;
    IF (l_rpcv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_rpcv_rec.creation_date := NULL;
    END IF;
    IF (l_rpcv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_rpcv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rpcv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_rpcv_rec.last_update_date := NULL;
    END IF;
    IF (l_rpcv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_rpcv_rec.last_update_login := NULL;
    END IF;
  -- SPILLAIP - 2667636 -Start
    IF (l_rpcv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_rpcv_rec.currency_code := NULL;
    END IF;
    IF (l_rpcv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      l_rpcv_rec.currency_conversion_code := NULL;
    END IF;
    IF (l_rpcv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
      l_rpcv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_rpcv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
      l_rpcv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_rpcv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
      l_rpcv_rec.currency_conversion_date := NULL;
    END IF;
  -- SPILLAIP - 2667636 -End
    RETURN(l_rpcv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  -- Post-Generation Change
  -- By RMUNJULU on 16-APR-2001
  ---------------------------------------------------------------------------

  ---------------------------------------------------
  -- Validate_Attributes for:OKL_RELOCATE_ASSETS_V --
  ---------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_attributes
  -- Description     : for:OKL_REMARKTNG_COSTS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         :  Modified by : RMUNJULU on 16-APR-2001
  --                 : SPILLAIP 12-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments


  FUNCTION validate_attributes(p_rpcv_rec IN  rpcv_rec_type)
    RETURN VARCHAR2 IS

    x_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call column-level validation for 'id'
    validate_id(x_return_status => l_return_status,
                p_rpcv_rec      => p_rpcv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'object_version_number'
    validate_object_version_number(x_return_status => l_return_status,
                 				   p_rpcv_rec      => p_rpcv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'sfwt_flag'
    validate_sfwt_flag(x_return_status => l_return_status,
                 	   p_rpcv_rec      => p_rpcv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;


    -- call column-level validation for 'cost'
    validate_cost(x_return_status => l_return_status,
            	   p_rpcv_rec      => p_rpcv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;


    -- call column-level validation for 'repair_type'
    validate_repair_type(x_return_status => l_return_status,
                 	     p_rpcv_rec      => p_rpcv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'description'
    validate_description(x_return_status => l_return_status,
                 	     p_rpcv_rec      => p_rpcv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;


    -- call column-level validation for 'enabled_yn'
    validate_enabled_yn(x_return_status => l_return_status,
                 	    p_rpcv_rec      => p_rpcv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

  -- SPILLAIP - 2667636 - Start
    validate_currency_code(p_rpcv_rec      => p_rpcv_rec,
                           x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_code(p_rpcv_rec      => p_rpcv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_type(p_rpcv_rec      => p_rpcv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- SPILLAIP - 2667636 - End

    -- return status to caller
    RETURN x_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name   => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- return status to caller
      RETURN x_return_status;

  END validate_attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_REPAIR_COSTS_V --
  --------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : Validate_Record
  -- Description     : for:OKL_REPAIR_COSTS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION Validate_Record (
    p_rpcv_rec IN rpcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
  -- SPILLAIP - 2667636 - Start
    -- Validate Currency conversion Code,type,rate and Date

    validate_currency_record(p_rpcv_rec      => p_rpcv_rec,
                                 x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- SPILLAIP - 2667636 - End
    RETURN (x_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN rpcv_rec_type,
    p_to	IN OUT NOCOPY okl_repair_costs_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.repair_type := p_from.repair_type;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_repair_costs_tl_rec_type,
    p_to	IN OUT NOCOPY rpcv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.repair_type := p_from.repair_type;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  -- Start of comments
  --
  -- Procedure Name  : Migrate
  -- Description     : from _V to _B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments

  PROCEDURE migrate (
    p_from	IN rpcv_rec_type,
    p_to	IN OUT NOCOPY rpc_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.enabled_yn := p_from.enabled_yn;
    p_to.org_id := p_from.org_id;
    p_to.cost := p_from.cost;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  -- SPILLAIP - 2667636 - Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- SPILLAIP - 2667636 - End
  END migrate;

  -- Start of comments
  --
  -- Procedure Name  : Migrate
  -- Description     : from _B to _V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE migrate (
    p_from	IN rpc_rec_type,
    p_to	IN OUT NOCOPY rpcv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.enabled_yn := p_from.enabled_yn;
    p_to.org_id := p_from.org_id;
    p_to.cost := p_from.cost;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  -- SPILLAIP - 2667636 - Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- SPILLAIP - 2667636 - End
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_REPAIR_COSTS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpcv_rec                     IN rpcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpcv_rec                     rpcv_rec_type := p_rpcv_rec;
    l_okl_repair_costs_tl_rec      okl_repair_costs_tl_rec_type;
    l_rpc_rec                      rpc_rec_type;
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
    l_return_status := Validate_Attributes(l_rpcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rpcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:RPCV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpcv_tbl                     IN rpcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rpcv_tbl.COUNT > 0) THEN
      i := p_rpcv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rpcv_rec                     => p_rpcv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rpcv_tbl.LAST);
        i := p_rpcv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------
  -- insert_row for:OKL_REPAIR_COSTS_TL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_repair_costs_tl_rec      IN okl_repair_costs_tl_rec_type,
    x_okl_repair_costs_tl_rec      OUT NOCOPY okl_repair_costs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_repair_costs_tl_rec      okl_repair_costs_tl_rec_type := p_okl_repair_costs_tl_rec;
    ldefoklrepaircoststlrec        okl_repair_costs_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    --------------------------------------------
    -- Set_Attributes for:OKL_REPAIR_COSTS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_repair_costs_tl_rec IN  okl_repair_costs_tl_rec_type,
      x_okl_repair_costs_tl_rec OUT NOCOPY okl_repair_costs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_repair_costs_tl_rec := p_okl_repair_costs_tl_rec;
      x_okl_repair_costs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_repair_costs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_repair_costs_tl_rec,         -- IN
      l_okl_repair_costs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_repair_costs_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_REPAIR_COSTS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          repair_type,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_repair_costs_tl_rec.id,
          l_okl_repair_costs_tl_rec.language,
          l_okl_repair_costs_tl_rec.source_lang,
          l_okl_repair_costs_tl_rec.sfwt_flag,
          l_okl_repair_costs_tl_rec.repair_type,
          l_okl_repair_costs_tl_rec.description,
          l_okl_repair_costs_tl_rec.created_by,
          l_okl_repair_costs_tl_rec.creation_date,
          l_okl_repair_costs_tl_rec.last_updated_by,
          l_okl_repair_costs_tl_rec.last_update_date,
          l_okl_repair_costs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_repair_costs_tl_rec := l_okl_repair_costs_tl_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ---------------------------------------
  -- insert_row for:OKL_REPAIR_COSTS_B --
  ---------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : for OKL_REPAIR_COSTS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpc_rec                      IN rpc_rec_type,
    x_rpc_rec                      OUT NOCOPY rpc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpc_rec                      rpc_rec_type := p_rpc_rec;
    l_def_rpc_rec                  rpc_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_REPAIR_COSTS_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rpc_rec IN  rpc_rec_type,
      x_rpc_rec OUT NOCOPY rpc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rpc_rec := p_rpc_rec;
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
      p_rpc_rec,                         -- IN
      l_rpc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_REPAIR_COSTS_B(
        id,
        object_version_number,
        enabled_yn,
        org_id,
        cost,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
  -- SPILLAIP - 2667636 - Start
        currency_code,
        currency_conversion_code,
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date)
  -- SPILLAIP - 2667636 - End
      VALUES (
        l_rpc_rec.id,
        l_rpc_rec.object_version_number,
        l_rpc_rec.enabled_yn,
        l_rpc_rec.org_id,
        l_rpc_rec.cost,
        l_rpc_rec.created_by,
        l_rpc_rec.creation_date,
        l_rpc_rec.last_updated_by,
        l_rpc_rec.last_update_date,
        l_rpc_rec.last_update_login,
  -- SPILLAIP - 2667636 - Start
        l_rpc_rec.currency_code,
        l_rpc_rec.currency_conversion_code,
        l_rpc_rec.currency_conversion_type,
        l_rpc_rec.currency_conversion_rate,
        l_rpc_rec.currency_conversion_date);
  -- SPILLAIP - 2667636 - End
    -- Set OUT values
    x_rpc_rec := l_rpc_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ---------------------------------------
  -- insert_row for:OKL_REPAIR_COSTS_V --
  ---------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : for OKL_REPAIR_COSTS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpcv_rec                     IN rpcv_rec_type,
    x_rpcv_rec                     OUT NOCOPY rpcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpcv_rec                     rpcv_rec_type;
    l_def_rpcv_rec                 rpcv_rec_type;
    l_okl_repair_costs_tl_rec      okl_repair_costs_tl_rec_type;
    lx_okl_repair_costs_tl_rec     okl_repair_costs_tl_rec_type;
    l_rpc_rec                      rpc_rec_type;
    lx_rpc_rec                     rpc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rpcv_rec	IN rpcv_rec_type
    ) RETURN rpcv_rec_type IS
      l_rpcv_rec	rpcv_rec_type := p_rpcv_rec;
    BEGIN
      l_rpcv_rec.CREATION_DATE := SYSDATE;
      l_rpcv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rpcv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rpcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rpcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rpcv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_REPAIR_COSTS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rpcv_rec IN  rpcv_rec_type,
      x_rpcv_rec OUT NOCOPY rpcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rpcv_rec := p_rpcv_rec;
      x_rpcv_rec.OBJECT_VERSION_NUMBER := 1;
      x_rpcv_rec.SFWT_FLAG := 'N';

      IF (x_rpcv_rec.enabled_yn = OKL_API.G_MISS_CHAR OR x_rpcv_rec.enabled_yn IS NULL) THEN
         x_rpcv_rec.enabled_yn := 'N';
      END IF;

      -- Default the ORG ID if a value is not passed
      IF p_rpcv_rec.org_id IS NULL
      OR p_rpcv_rec.org_id = OKC_API.G_MISS_NUM THEN
        x_rpcv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      END IF;

  -- SPILLAIP - 2667636 - Start
      x_rpcv_rec.currency_conversion_code := OKL_AM_UTIL_PVT.get_functional_currency;

      IF p_rpcv_rec.currency_code IS NULL
      OR p_rpcv_rec.currency_code = OKC_API.G_MISS_CHAR THEN
        x_rpcv_rec.currency_code := x_rpcv_rec.currency_conversion_code;
      END IF;
  -- SPILLAIP - 2667636 - End

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
    l_rpcv_rec := null_out_defaults(p_rpcv_rec);
    -- Set primary key value
    l_rpcv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rpcv_rec,                        -- IN
      l_def_rpcv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rpcv_rec := fill_who_columns(l_def_rpcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rpcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
          --gkadarka Fixes for 3559327
    l_def_rpcv_rec.currency_conversion_type := NULL;
    l_def_rpcv_rec.currency_conversion_rate := NULL;
    l_def_rpcv_rec.currency_conversion_date := NULL;
    --gkdarka
    l_return_status := Validate_Record(l_def_rpcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rpcv_rec, l_okl_repair_costs_tl_rec);
    migrate(l_def_rpcv_rec, l_rpc_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_repair_costs_tl_rec,
      lx_okl_repair_costs_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_repair_costs_tl_rec, l_def_rpcv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rpc_rec,
      lx_rpc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rpc_rec, l_def_rpcv_rec);
    -- Set OUT values
    x_rpcv_rec := l_def_rpcv_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:RPCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpcv_tbl                     IN rpcv_tbl_type,
    x_rpcv_tbl                     OUT NOCOPY rpcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rpcv_tbl.COUNT > 0) THEN
      i := p_rpcv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rpcv_rec                     => p_rpcv_tbl(i),
          x_rpcv_rec                     => x_rpcv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rpcv_tbl.LAST);
        i := p_rpcv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- lock_row for:OKL_REPAIR_COSTS_TL --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_repair_costs_tl_rec      IN okl_repair_costs_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_repair_costs_tl_rec IN okl_repair_costs_tl_rec_type) IS
    SELECT *
      FROM OKL_REPAIR_COSTS_TL
     WHERE ID = p_okl_repair_costs_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_okl_repair_costs_tl_rec);
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -------------------------------------
  -- lock_row for:OKL_REPAIR_COSTS_B --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpc_rec                      IN rpc_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rpc_rec IN rpc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_REPAIR_COSTS_B
     WHERE ID = p_rpc_rec.id
       AND OBJECT_VERSION_NUMBER = p_rpc_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rpc_rec IN rpc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_REPAIR_COSTS_B
    WHERE ID = p_rpc_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_REPAIR_COSTS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_REPAIR_COSTS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_rpc_rec);
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
      OPEN lchk_csr(p_rpc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rpc_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rpc_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -------------------------------------
  -- lock_row for:OKL_REPAIR_COSTS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpcv_rec                     IN rpcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_repair_costs_tl_rec      okl_repair_costs_tl_rec_type;
    l_rpc_rec                      rpc_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_rpcv_rec, l_okl_repair_costs_tl_rec);
    migrate(p_rpcv_rec, l_rpc_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_repair_costs_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rpc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:RPCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpcv_tbl                     IN rpcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rpcv_tbl.COUNT > 0) THEN
      i := p_rpcv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rpcv_rec                     => p_rpcv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rpcv_tbl.LAST);
        i := p_rpcv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------
  -- update_row for:OKL_REPAIR_COSTS_TL --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_repair_costs_tl_rec      IN okl_repair_costs_tl_rec_type,
    x_okl_repair_costs_tl_rec      OUT NOCOPY okl_repair_costs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_repair_costs_tl_rec      okl_repair_costs_tl_rec_type := p_okl_repair_costs_tl_rec;
    ldefoklrepaircoststlrec        okl_repair_costs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_repair_costs_tl_rec	IN okl_repair_costs_tl_rec_type,
      x_okl_repair_costs_tl_rec	OUT NOCOPY okl_repair_costs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_repair_costs_tl_rec      okl_repair_costs_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_repair_costs_tl_rec := p_okl_repair_costs_tl_rec;
      -- Get current database values
      l_okl_repair_costs_tl_rec := get_rec(p_okl_repair_costs_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_repair_costs_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_repair_costs_tl_rec.id := l_okl_repair_costs_tl_rec.id;
      END IF;
      IF (x_okl_repair_costs_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_repair_costs_tl_rec.language := l_okl_repair_costs_tl_rec.language;
      END IF;
      IF (x_okl_repair_costs_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_repair_costs_tl_rec.source_lang := l_okl_repair_costs_tl_rec.source_lang;
      END IF;
      IF (x_okl_repair_costs_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_repair_costs_tl_rec.sfwt_flag := l_okl_repair_costs_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_repair_costs_tl_rec.repair_type = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_repair_costs_tl_rec.repair_type := l_okl_repair_costs_tl_rec.repair_type;
      END IF;
      IF (x_okl_repair_costs_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_repair_costs_tl_rec.description := l_okl_repair_costs_tl_rec.description;
      END IF;
      IF (x_okl_repair_costs_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_repair_costs_tl_rec.created_by := l_okl_repair_costs_tl_rec.created_by;
      END IF;
      IF (x_okl_repair_costs_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_repair_costs_tl_rec.creation_date := l_okl_repair_costs_tl_rec.creation_date;
      END IF;
      IF (x_okl_repair_costs_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_repair_costs_tl_rec.last_updated_by := l_okl_repair_costs_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_repair_costs_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_repair_costs_tl_rec.last_update_date := l_okl_repair_costs_tl_rec.last_update_date;
      END IF;
      IF (x_okl_repair_costs_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_repair_costs_tl_rec.last_update_login := l_okl_repair_costs_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_REPAIR_COSTS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_repair_costs_tl_rec IN  okl_repair_costs_tl_rec_type,
      x_okl_repair_costs_tl_rec OUT NOCOPY okl_repair_costs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_repair_costs_tl_rec := p_okl_repair_costs_tl_rec;
      x_okl_repair_costs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_repair_costs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_repair_costs_tl_rec,         -- IN
      l_okl_repair_costs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_repair_costs_tl_rec, ldefoklrepaircoststlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_REPAIR_COSTS_TL
    SET REPAIR_TYPE = ldefoklrepaircoststlrec.repair_type,
        DESCRIPTION = ldefoklrepaircoststlrec.description,
        SOURCE_LANG = ldefoklrepaircoststlrec.source_lang, --Fix fro bug 3637102
        CREATED_BY = ldefoklrepaircoststlrec.created_by,
        CREATION_DATE = ldefoklrepaircoststlrec.creation_date,
        LAST_UPDATED_BY = ldefoklrepaircoststlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklrepaircoststlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklrepaircoststlrec.last_update_login
    WHERE ID = ldefoklrepaircoststlrec.id
        AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);--Fix for bug 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_REPAIR_COSTS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklrepaircoststlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_repair_costs_tl_rec := ldefoklrepaircoststlrec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_REPAIR_COSTS_B --
  ---------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : for OKL_REPAIR_COSTS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpc_rec                      IN rpc_rec_type,
    x_rpc_rec                      OUT NOCOPY rpc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpc_rec                      rpc_rec_type := p_rpc_rec;
    l_def_rpc_rec                  rpc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rpc_rec	IN rpc_rec_type,
      x_rpc_rec	OUT NOCOPY rpc_rec_type
    ) RETURN VARCHAR2 IS
      l_rpc_rec                      rpc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rpc_rec := p_rpc_rec;
      -- Get current database values
      l_rpc_rec := get_rec(p_rpc_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rpc_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rpc_rec.id := l_rpc_rec.id;
      END IF;
      IF (x_rpc_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rpc_rec.object_version_number := l_rpc_rec.object_version_number;
      END IF;
      IF (x_rpc_rec.enabled_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rpc_rec.enabled_yn := l_rpc_rec.enabled_yn;
      END IF;
      IF (x_rpc_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_rpc_rec.org_id := l_rpc_rec.org_id;
      END IF;
      IF (x_rpc_rec.cost = OKC_API.G_MISS_NUM)
      THEN
        x_rpc_rec.cost := l_rpc_rec.cost;
      END IF;
      IF (x_rpc_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rpc_rec.created_by := l_rpc_rec.created_by;
      END IF;
      IF (x_rpc_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rpc_rec.creation_date := l_rpc_rec.creation_date;
      END IF;
      IF (x_rpc_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rpc_rec.last_updated_by := l_rpc_rec.last_updated_by;
      END IF;
      IF (x_rpc_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rpc_rec.last_update_date := l_rpc_rec.last_update_date;
      END IF;
      IF (x_rpc_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rpc_rec.last_update_login := l_rpc_rec.last_update_login;
      END IF;
  -- SPILLAIP - 2667636 - Start
     IF (x_rpc_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rpc_rec.currency_code := l_rpc_rec.currency_code;
      END IF;
      IF (x_rpc_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rpc_rec.currency_conversion_code := l_rpc_rec.currency_conversion_code;
      END IF;
      IF (x_rpc_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_rpc_rec.currency_conversion_type := l_rpc_rec.currency_conversion_type;
      END IF;
      IF (x_rpc_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_rpc_rec.currency_conversion_rate := l_rpc_rec.currency_conversion_rate;
      END IF;
      IF (x_rpc_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_rpc_rec.currency_conversion_date := l_rpc_rec.currency_conversion_date;
      END IF;
  -- SPILLAIP - 2667636 - End
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_REPAIR_COSTS_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rpc_rec IN  rpc_rec_type,
      x_rpc_rec OUT NOCOPY rpc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rpc_rec := p_rpc_rec;
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
      p_rpc_rec,                         -- IN
      l_rpc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rpc_rec, l_def_rpc_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_REPAIR_COSTS_B
    SET OBJECT_VERSION_NUMBER = l_def_rpc_rec.object_version_number,
        ENABLED_YN = l_def_rpc_rec.enabled_yn,
        ORG_ID = l_def_rpc_rec.org_id,
        COST = l_def_rpc_rec.cost,
        CREATED_BY = l_def_rpc_rec.created_by,
        CREATION_DATE = l_def_rpc_rec.creation_date,
        LAST_UPDATED_BY = l_def_rpc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rpc_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rpc_rec.last_update_login,
  -- SPILLAIP - 2667636 - Start
        CURRENCY_CODE = l_def_rpc_rec.currency_code,
        CURRENCY_CONVERSION_CODE = l_def_rpc_rec.currency_conversion_code,
        CURRENCY_CONVERSION_TYPE = l_def_rpc_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_rpc_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_rpc_rec.currency_conversion_date
  -- SPILLAIP - 2667636 - End

    WHERE ID = l_def_rpc_rec.id;

    x_rpc_rec := l_def_rpc_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_REPAIR_COSTS_V --
  ---------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : for OKL_REPAIR_COSTS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : SPILLAIP 12-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpcv_rec                     IN rpcv_rec_type,
    x_rpcv_rec                     OUT NOCOPY rpcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpcv_rec                     rpcv_rec_type := p_rpcv_rec;
    l_def_rpcv_rec                 rpcv_rec_type;
    l_rpc_rec                      rpc_rec_type;
    lx_rpc_rec                     rpc_rec_type;
    l_okl_repair_costs_tl_rec      okl_repair_costs_tl_rec_type;
    lx_okl_repair_costs_tl_rec     okl_repair_costs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rpcv_rec	IN rpcv_rec_type
    ) RETURN rpcv_rec_type IS
      l_rpcv_rec	rpcv_rec_type := p_rpcv_rec;
    BEGIN
      l_rpcv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rpcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rpcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rpcv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rpcv_rec	IN rpcv_rec_type,
      x_rpcv_rec	OUT NOCOPY rpcv_rec_type
    ) RETURN VARCHAR2 IS
      l_rpcv_rec                     rpcv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rpcv_rec := p_rpcv_rec;
      -- Get current database values
      l_rpcv_rec := get_rec(p_rpcv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rpcv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rpcv_rec.id := l_rpcv_rec.id;
      END IF;
      IF (x_rpcv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rpcv_rec.object_version_number := l_rpcv_rec.object_version_number;
      END IF;
      IF (x_rpcv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_rpcv_rec.sfwt_flag := l_rpcv_rec.sfwt_flag;
      END IF;
      IF (x_rpcv_rec.enabled_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rpcv_rec.enabled_yn := l_rpcv_rec.enabled_yn;
      END IF;
      IF (x_rpcv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_rpcv_rec.org_id := l_rpcv_rec.org_id;
      END IF;
      IF (x_rpcv_rec.cost = OKC_API.G_MISS_NUM)
      THEN
        x_rpcv_rec.cost := l_rpcv_rec.cost;
      END IF;
      IF (x_rpcv_rec.repair_type = OKC_API.G_MISS_CHAR)
      THEN
        x_rpcv_rec.repair_type := l_rpcv_rec.repair_type;
      END IF;
      IF (x_rpcv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_rpcv_rec.description := l_rpcv_rec.description;
      END IF;
      IF (x_rpcv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rpcv_rec.created_by := l_rpcv_rec.created_by;
      END IF;
      IF (x_rpcv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rpcv_rec.creation_date := l_rpcv_rec.creation_date;
      END IF;
      IF (x_rpcv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rpcv_rec.last_updated_by := l_rpcv_rec.last_updated_by;
      END IF;
      IF (x_rpcv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rpcv_rec.last_update_date := l_rpcv_rec.last_update_date;
      END IF;
      IF (x_rpcv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rpcv_rec.last_update_login := l_rpcv_rec.last_update_login;
      END IF;
  -- SPILLAIP - 2667636 - Start
     IF (x_rpcv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rpcv_rec.currency_code := l_rpcv_rec.currency_code;
      END IF;
      IF (x_rpcv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rpcv_rec.currency_conversion_code := l_rpcv_rec.currency_conversion_code;
      END IF;
      IF (x_rpcv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_rpcv_rec.currency_conversion_type := l_rpcv_rec.currency_conversion_type;
      END IF;
      IF (x_rpcv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_rpcv_rec.currency_conversion_rate := l_rpcv_rec.currency_conversion_rate;
      END IF;
      IF (x_rpcv_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_rpcv_rec.currency_conversion_date := l_rpcv_rec.currency_conversion_date;
      END IF;
  -- SPILLAIP - 2667636 - End
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_REPAIR_COSTS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rpcv_rec IN  rpcv_rec_type,
      x_rpcv_rec OUT NOCOPY rpcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rpcv_rec := p_rpcv_rec;
      x_rpcv_rec.OBJECT_VERSION_NUMBER := NVL(x_rpcv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_rpcv_rec,                        -- IN
      l_rpcv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rpcv_rec, l_def_rpcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rpcv_rec := fill_who_columns(l_def_rpcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rpcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --gkadarka Fixes for 3559327
    l_def_rpcv_rec.currency_conversion_type := NULL;
    l_def_rpcv_rec.currency_conversion_rate := NULL;
    l_def_rpcv_rec.currency_conversion_date := NULL;
    --gkdarka
    l_return_status := Validate_Record(l_def_rpcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rpcv_rec, l_rpc_rec);
    migrate(l_def_rpcv_rec, l_okl_repair_costs_tl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rpc_rec,
      lx_rpc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rpc_rec, l_def_rpcv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_repair_costs_tl_rec,
      lx_okl_repair_costs_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_repair_costs_tl_rec, l_def_rpcv_rec);
    x_rpcv_rec := l_def_rpcv_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:RPCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpcv_tbl                     IN rpcv_tbl_type,
    x_rpcv_tbl                     OUT NOCOPY rpcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rpcv_tbl.COUNT > 0) THEN
      i := p_rpcv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rpcv_rec                     => p_rpcv_tbl(i),
          x_rpcv_rec                     => x_rpcv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rpcv_tbl.LAST);
        i := p_rpcv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------
  -- delete_row for:OKL_REPAIR_COSTS_TL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_repair_costs_tl_rec      IN okl_repair_costs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_repair_costs_tl_rec      okl_repair_costs_tl_rec_type:= p_okl_repair_costs_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    --------------------------------------------
    -- Set_Attributes for:OKL_REPAIR_COSTS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_repair_costs_tl_rec IN  okl_repair_costs_tl_rec_type,
      x_okl_repair_costs_tl_rec OUT NOCOPY okl_repair_costs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_repair_costs_tl_rec := p_okl_repair_costs_tl_rec;
      x_okl_repair_costs_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_repair_costs_tl_rec,         -- IN
      l_okl_repair_costs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_REPAIR_COSTS_TL
     WHERE ID = l_okl_repair_costs_tl_rec.id;

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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_REPAIR_COSTS_B --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpc_rec                      IN rpc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpc_rec                      rpc_rec_type:= p_rpc_rec;
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
    DELETE FROM OKL_REPAIR_COSTS_B
     WHERE ID = l_rpc_rec.id;

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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_REPAIR_COSTS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpcv_rec                     IN rpcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpcv_rec                     rpcv_rec_type := p_rpcv_rec;
    l_rpc_rec                      rpc_rec_type;
    l_okl_repair_costs_tl_rec      okl_repair_costs_tl_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_rpcv_rec, l_rpc_rec);
    migrate(l_rpcv_rec, l_okl_repair_costs_tl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rpc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_repair_costs_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:RPCV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpcv_tbl                     IN rpcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rpcv_tbl.COUNT > 0) THEN
      i := p_rpcv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rpcv_rec                     => p_rpcv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rpcv_tbl.LAST);
        i := p_rpcv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;  EXCEPTION
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_RPC_PVT;

/
