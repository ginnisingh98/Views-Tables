--------------------------------------------------------
--  DDL for Package Body OKL_QTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QTE_PVT" AS
/* $Header: OKLSQTEB.pls 120.10 2007/12/27 23:04:51 rmunjulu noship $ */
G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
G_UPPER_CASE_REQUIRED CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
--G_INVALID_END_DATE    CONSTANT VARCHAR2(200) := 'INVALID_END_DATE';
G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';
G_VIEW                CONSTANT VARCHAR2(200) := 'OKL_TRX_QUOTES_V';

G_EXCEPTION_HALT_VALIDATION EXCEPTION;
--------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_currency_record
  -- Description     : Used for validation of Currency Code Conversion Coulms
  -- Business Rules  : If transaction currency <> functional currency, then
  --                   conversion columns are mandatory
  --                   Else If transaction currency = functional currency,
  --                   then conversion columns should all be NULL
  -- Parameters      : Record structure of OKL_TRX_QUOTE_B table
  -- Version         : 1.0
  -- History         : 15-DEC-2002 BAKUCHIB :Added new procedure
  -- End of comments

  PROCEDURE validate_currency_record(p_qtev_rec      IN  qtev_rec_type,
                                     x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- If transaction currency <> functional currency, then conversion columns
    -- are mandatory
    IF (p_qtev_rec.currency_code <> p_qtev_rec.currency_conversion_code) THEN
      IF (p_qtev_rec.currency_conversion_type = OKC_API.G_MISS_CHAR OR
         p_qtev_rec.currency_conversion_type IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_type');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_qtev_rec.currency_conversion_rate = OKC_API.G_MISS_NUM OR
         p_qtev_rec.currency_conversion_rate IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_rate');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_qtev_rec.currency_conversion_date = OKC_API.G_MISS_DATE OR
         p_qtev_rec.currency_conversion_date IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_date');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    -- Else If transaction currency = functional currency, then conversion
    -- columns should all be NULL
    ELSIF (p_qtev_rec.currency_code = p_qtev_rec.currency_conversion_code) THEN
      IF (p_qtev_rec.currency_conversion_type IS NOT NULL) OR
         (p_qtev_rec.currency_conversion_rate IS NOT NULL) OR
         (p_qtev_rec.currency_conversion_date IS NOT NULL) THEN
        --SET MESSAGE
        -- Currency conversion columns should be all null
        IF p_qtev_rec.currency_conversion_rate IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_rate');
        END IF;
        IF p_qtev_rec.currency_conversion_date IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_date');
        END IF;
        IF p_qtev_rec.currency_conversion_type IS NOT NULL THEN
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
--------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_currency_code
  -- Description     : Validation of Currency Code
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_B table
  -- Version         : 1.0
  -- History         : 15-DEC-2002 BAKUCHIB :Added new procedure
  -- End of comments

  PROCEDURE validate_currency_code(p_qtev_rec      IN  qtev_rec_type,
                                   x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_qtev_rec.currency_code IS NULL) OR
       (p_qtev_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_code');

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_qtev_rec.currency_code);
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
--------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_currency_con_code
  -- Description     : Validation of Currency Conversion Code
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_B table
  -- Version         : 1.0
  -- History         : 15-DEC-2002 BAKUCHIB :Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_code(p_qtev_rec      IN  qtev_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_qtev_rec.currency_conversion_code IS NULL) OR
       (p_qtev_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_conversion_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_qtev_rec.currency_conversion_code);
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
-------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_currency_con_type
  -- Description     : Validation of Currency Conversion type
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_B table
  -- Version         : 1.0
  -- History         : 15-DEC-2002 BAKUCHIB :Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_type(p_qtev_rec      IN  qtev_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_qtev_rec.currency_conversion_type <> OKL_API.G_MISS_CHAR AND
       p_qtev_rec.currency_conversion_type IS NOT NULL) THEN
      -- check from currency values using the generic okl_util.validate_currency_code
      l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_con_type(p_qtev_rec.currency_conversion_type);
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
--------------------------------------------------------------------------------

--g_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_id(p_qtev_rec  IN qtev_rec_type
 					   ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.id IS NULL) OR
       (p_qtev_rec.id = OKC_API.G_MISS_NUM) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_object_version_number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_object_version_number(p_qtev_rec  IN qtev_rec_type
 					   			          ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.object_version_number IS NULL) OR
       (p_qtev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'object_version_number');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_object_version_number;

  --dkagrawa added following validation for LE uptake
  -- Start of comments
  --
  -- Procedure Name  : validate_legal_entity_id(
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_legal_entity_id( p_qtev_rec      IN qtev_rec_type
                                   ,x_return_status OUT NOCOPY VARCHAR2) IS
    l_exists  NUMBER(1);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_qtev_rec.legal_entity_id = OKL_API.G_MISS_NUM OR
        p_qtev_rec.legal_entity_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'LEGAL_ENTITY_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      l_exists := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_qtev_rec.legal_entity_id);
      IF (l_exists <> 1) THEN
        OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEGAL_ENTITY_ID');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       null;
     WHEN OTHERS THEN
       OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                           ,p_msg_name     => G_UNEXPECTED_ERROR
                           ,p_token1       => G_SQLCODE_TOKEN
                           ,p_token1_value => SQLCODE
                           ,p_token2       => G_SQLERRM_TOKEN
                           ,p_token2_value => SQLERRM);
       -- notify caller of an UNEXPECTED error
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   END validate_legal_entity_id;

  --AKP:REPO-QUOTE-START 6599890
  -- Start of comments
  --
  -- Procedure Name  : validate_repo_qte_indicator_yn(
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_repo_qte_indicator_yn( p_qtev_rec      IN qtev_rec_type
                                   ,x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_qtev_rec.repo_quote_indicator_yn IS NOT NULL AND
        p_qtev_rec.repo_quote_indicator_yn <> OKL_API.G_MISS_CHAR )
    THEN
      IF p_qtev_rec.repo_quote_indicator_yn NOT IN ('Y', 'N') THEN
         OKL_API.SET_MESSAGE(
                     p_app_name      => 'OKL',
      		     p_msg_name      => 'OKL_LA_VAR_INVALID_PARAM',
      		     p_token1	     => 'VALUE',
      		     p_token1_value  => p_qtev_rec.repo_quote_indicator_yn,
      		     p_token2	     => 'PARAM',
      		     p_token2_value  => 'REPO_QUOTE_INDICATOR_YN');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       null;
     WHEN OTHERS THEN
       OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                           ,p_msg_name     => G_UNEXPECTED_ERROR
                           ,p_token1       => G_SQLCODE_TOKEN
                           ,p_token1_value => SQLCODE
                           ,p_token2       => G_SQLERRM_TOKEN
                           ,p_token2_value => SQLERRM);
       -- notify caller of an UNEXPECTED error
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   END validate_repo_qte_indicator_yn;
  --AKP:REPO-QUOTE-START


  -- Start of comments
  --
  -- Procedure Name  : validate_sfwt_flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_sfwt_flag(p_qtev_rec  IN qtev_rec_type
 					          ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.sfwt_flag IS NULL) OR
       (p_qtev_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'sfwt_flag');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_sfwt_flag;

  -- Start of comments
  --
  -- Procedure Name  : validate_qrs_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_qrs_code(p_qtev_rec IN qtev_rec_type
 					         ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.qrs_code IS NULL) OR
       (p_qtev_rec.qrs_code = OKC_API.G_MISS_CHAR) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'qrs_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_QUOTE_REASON'
						,p_lookup_code 	=>	p_qtev_rec.qrs_code);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'qrs_code');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_qrs_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_qst_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_qst_code(p_qtev_rec IN qtev_rec_type
 					         ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.qst_code IS NULL) OR
       (p_qtev_rec.qst_code = OKC_API.G_MISS_CHAR) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'qst_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_QUOTE_STATUS'
						,p_lookup_code 	=>	p_qtev_rec.qst_code);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'qst_code');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_qst_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_qtp_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_qtp_code(p_qtev_rec IN qtev_rec_type
 					         ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.qtp_code IS NULL) OR
       (p_qtev_rec.qtp_code = OKC_API.G_MISS_CHAR) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'qtp_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_QUOTE_TYPE'
						,p_lookup_code 	=>	p_qtev_rec.qtp_code);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'qtp_code');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_qtp_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_trn_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_trn_code(p_qtev_rec IN qtev_rec_type
 					         ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is not required
    IF (p_qtev_rec.trn_code IS NOT NULL) AND
       (p_qtev_rec.trn_code <> OKC_API.G_MISS_CHAR) THEN

      x_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKC_TERMINATION_REASON'
						,p_lookup_code 	=>	p_qtev_rec.trn_code);

      IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'trn_code');

        RAISE G_EXCEPTION_HALT_VALIDATION;

      ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_trn_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_pop_code_end
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_pop_code_end(p_qtev_rec IN qtev_rec_type
 					             ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_qtev_rec.pop_code_end IS NOT NULL) AND
       (p_qtev_rec.pop_code_end <> OKC_API.G_MISS_CHAR) THEN

      x_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_EOT_OPTION'
						,p_lookup_code 	=>	p_qtev_rec.pop_code_end);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'pop_code_end');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_pop_code_end;

  -- Start of comments
  --
  -- Procedure Name  : validate_pop_code_early
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_pop_code_early(p_qtev_rec IN qtev_rec_type
 					               ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_qtev_rec.pop_code_early IS NOT NULL) AND
       (p_qtev_rec.pop_code_early <> OKC_API.G_MISS_CHAR) THEN

      x_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_PURCHASE_OPTION'
						,p_lookup_code 	=>	p_qtev_rec.pop_code_early);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN

        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'pop_code_early');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_pop_code_early;

  -- Start of comments
  --
  -- Procedure Name  : validate_consolidated_qte_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_consolidated_qte_id(p_qtev_rec IN qtev_rec_type
 					                    ,x_return_status OUT NOCOPY VARCHAR2) IS
  -- select the ID of the parent record from the parent
  CURSOR okl_qtev_csr (p_consolidated_qte_id  IN NUMBER) IS
      SELECT 'x'
      FROM   OKL_TRX_QUOTES_V
      WHERE  ID = p_consolidated_qte_id;

  l_dummy_var	VARCHAR2(1) := '?';

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_qtev_rec.consolidated_qte_id IS NOT NULL) AND
       (p_qtev_rec.consolidated_qte_id <> OKC_API.G_MISS_NUM) THEN

      -- enforce foreign key
      OPEN okl_qtev_csr(p_qtev_rec.consolidated_qte_id);
      FETCH okl_qtev_csr INTO l_dummy_var;
      CLOSE okl_qtev_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name 	 	=> G_APP_NAME
                           ,p_msg_name 	 	=> G_NO_PARENT_RECORD
                           ,p_token1		=> G_COL_NAME_TOKEN
                           ,p_token1_value 	=> 'consolidated_qte_id'
                           ,p_token2		=> G_CHILD_TABLE_TOKEN
                           ,p_token2_value 	=> 'OKL_TRX_QUOTES_V'
                           ,p_token3		=> G_PARENT_TABLE_TOKEN
                           ,p_token3_value 	=> 'OKL_TRX_QUOTES_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- verify that cursor was closed
      IF okl_qtev_csr%ISOPEN THEN
        CLOSE okl_qtev_csr;
      END IF;

  END validate_consolidated_qte_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_khr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_khr_id(p_qtev_rec IN qtev_rec_type
 					       ,x_return_status OUT NOCOPY VARCHAR2) IS

  -- select the ID of the parent record from the parent
  CURSOR okl_khrv_csr (p_khr_id  IN NUMBER) IS
      SELECT 'x'
      FROM   OKL_K_HEADERS_V
      WHERE  ID = p_khr_id;

  l_dummy_var	VARCHAR2(1) := '?';

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_qtev_rec.khr_id IS NOT NULL
    AND p_qtev_rec.khr_id <> OKC_API.G_MISS_NUM THEN

     -- enforce foreign key
      OPEN okl_khrv_csr(p_qtev_rec.khr_id);
      FETCH okl_khrv_csr INTO l_dummy_var;
      CLOSE okl_khrv_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name 	 => OKL_API.G_APP_NAME
                           ,p_msg_name 	 => 'OKL_NO_PARENT_RECORD'
                           ,p_token1		 => 'COL_NAME'
                           ,p_token1_value => 'khr_id'
                           ,p_token2		 => 'CHILD_TABLE'
                           ,p_token2_value => 'OKL_K_HEADERS_V'
                           ,p_token3		 => 'PARENT_TABLE'
                           ,p_token3_value => 'OKL_TRX_QUOTES_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- verify that cursor was closed
      IF okl_khrv_csr%ISOPEN THEN
        CLOSE okl_khrv_csr;
      END IF;

  END validate_khr_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_pdt_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_pdt_id(p_qtev_rec IN qtev_rec_type
 					       ,x_return_status OUT NOCOPY VARCHAR2) IS

  -- select the ID of the parent record from the parent
  CURSOR okl_pdtv_csr (p_pdt_id  IN NUMBER) IS
      SELECT 'x'
      FROM   OKL_PRODUCTS_V
      WHERE  ID = p_pdt_id;

  l_dummy_var	VARCHAR2(1) := '?';

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_qtev_rec.pdt_id IS NOT NULL) AND
       (p_qtev_rec.pdt_id <> OKC_API.G_MISS_NUM) THEN

      -- enforce foreign key
      OPEN okl_pdtv_csr(p_qtev_rec.pdt_id);
      FETCH okl_pdtv_csr INTO l_dummy_var;
      CLOSE okl_pdtv_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name 	 	=> G_APP_NAME
                           ,p_msg_name 	 	=> G_NO_PARENT_RECORD
                           ,p_token1		=> G_COL_NAME_TOKEN
                           ,p_token1_value 	=> 'pdt_id'
                           ,p_token2		=> G_CHILD_TABLE_TOKEN
                           ,p_token2_value 	=> 'OKL_TRX_QUOTES_V'
                           ,p_token3		=> G_PARENT_TABLE_TOKEN
                           ,p_token3_value  => 'OKL_PRODUCTS_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- verify that cursor was closed
      IF okl_pdtv_csr%ISOPEN THEN
        CLOSE okl_pdtv_csr;
      END IF;

  END validate_pdt_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_early_termination_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_early_termination_yn(p_qtev_rec IN qtev_rec_type
 					                     ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.early_termination_yn IS NULL) OR
       (p_qtev_rec.early_termination_yn = OKC_API.G_MISS_CHAR) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'early_termination_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_domain_yn(
						p_col_value 	=> p_qtev_rec.early_termination_yn);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'early_termination_yn');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_early_termination_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_partial_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_partial_yn(p_qtev_rec IN qtev_rec_type
 					           ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.partial_yn IS NULL) OR
       (p_qtev_rec.partial_yn = OKC_API.G_MISS_CHAR) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'partial_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_domain_yn(
						p_col_value 	=> p_qtev_rec.partial_yn);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'partial_yn');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_partial_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_preproceeds_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_preproceeds_yn(p_qtev_rec IN qtev_rec_type
 					               ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.preproceeds_yn IS NULL) OR
       (p_qtev_rec.preproceeds_yn = OKC_API.G_MISS_CHAR) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'preproceeds_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_domain_yn(
						p_col_value 	=> p_qtev_rec.preproceeds_yn);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'preproceeds_yn');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_preproceeds_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_date_requested
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_requested(p_qtev_rec IN qtev_rec_type
 					               ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is not required
    IF (p_qtev_rec.date_requested IS NULL) OR
       (p_qtev_rec.date_requested = OKC_API.G_MISS_DATE) THEN

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_date_requested;

  -- Start of comments
  --
  -- Procedure Name  : validate_date_proposal
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_proposal(p_qtev_rec IN qtev_rec_type
 					              ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.date_proposal IS NULL) OR
       (p_qtev_rec.date_proposal = OKC_API.G_MISS_DATE) THEN

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_date_proposal;

  -- Start of comments
  --
  -- Procedure Name  : validate_date_effective_to
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_effective_to(p_qtev_rec IN qtev_rec_type
 					                  ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.date_effective_to IS NULL) OR
       (p_qtev_rec.date_effective_to = OKC_API.G_MISS_DATE) THEN
      -- rmunjulu bug 6674730 -- if Loan Repo Quote then Effective To Can be Null
      IF  (nvl(p_qtev_rec.repo_quote_indicator_yn,'N') = 'N') THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'date_effective_to');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_date_effective_to;

  -- Start of comments
  --
  -- Procedure Name  : validate_date_accepted
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_accepted(p_qtev_rec IN qtev_rec_type
 					              ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_date_accepted;

  -- Start of comments
  --
  -- Procedure Name  : validate_summary_format_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_summary_format_yn(p_qtev_rec IN qtev_rec_type
 					                  ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is not required
    IF (p_qtev_rec.summary_format_yn IS NULL) OR
       (p_qtev_rec.summary_format_yn = OKC_API.G_MISS_CHAR) THEN

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_domain_yn(
						p_col_value 	=> p_qtev_rec.summary_format_yn);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'summary_format_yn');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_summary_format_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_consolidated_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_consolidated_yn(p_qtev_rec IN qtev_rec_type
 					                ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is not required
    IF (p_qtev_rec.consolidated_yn IS NULL) OR
       (p_qtev_rec.consolidated_yn = OKC_API.G_MISS_CHAR) THEN

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_domain_yn(
						p_col_value 	=> p_qtev_rec.consolidated_yn);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'consolidated_yn');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_consolidated_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_principal_paydown_amt
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_principal_paydown_amt(p_qtev_rec  IN qtev_rec_type
 					                      ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_principal_paydown_amt;

  -- Start of comments
  --
  -- Procedure Name  : validate_residual_amount
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_residual_amount(p_qtev_rec  IN qtev_rec_type
 					                ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_residual_amount;

  -- Start of comments
  --
  -- Procedure Name  : validate_yield
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_yield(p_qtev_rec  IN qtev_rec_type
 					      ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_yield;

  -- Start of comments
  --
  -- Procedure Name  : validate_rent_amount
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_rent_amount(p_qtev_rec  IN qtev_rec_type
 					            ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_rent_amount;

  -- Start of comments
  --
  -- Procedure Name  : validate_date_restructure_end
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_restructure_end(p_qtev_rec IN qtev_rec_type
 					         ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_date_restructure_end;

  -- Start of comments
  --
  -- Procedure Name  : validate_date_restructure_start
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_res_start(p_qtev_rec IN qtev_rec_type
 					           ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_date_res_start;

  -- Start of comments
  --
  -- Procedure Name  : validate_term
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_term(p_qtev_rec  IN qtev_rec_type
 					     ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_term;

  -- Start of comments
  --
  -- Procedure Name  : validate_purchase_percent
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_purchase_percent(p_qtev_rec  IN qtev_rec_type
 					                 ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_purchase_percent;

  -- Start of comments
  --
  -- Procedure Name  : validate_comments
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_comments(p_qtev_rec IN qtev_rec_type
 					         ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_comments;

  -- Start of comments
  --
  -- Procedure Name  : validate_date_due
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_due(p_qtev_rec IN qtev_rec_type
 					         ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_date_due;

  -- Start of comments
  --
  -- Procedure Name  : validate_payment_frequency
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_payment_frequency(p_qtev_rec IN qtev_rec_type
 					                  ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_payment_frequency;

  -- Start of comments
  --
  -- Procedure Name  : validate_remaining_payments
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_remaining_payments(p_qtev_rec IN qtev_rec_type
 					                   ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_remaining_payments;

  -- Start of comments
  --
  -- Procedure Name  : validate_date_effective_from
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_effective_from(p_qtev_rec IN qtev_rec_type
 					                    ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.date_effective_from IS NULL) OR
       (p_qtev_rec.date_effective_from = OKC_API.G_MISS_DATE) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'date_effective_from');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_date_effective_from;

  -- Start of comments
  --
  -- Procedure Name  : validate_quote_number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_quote_number(p_qtev_rec IN qtev_rec_type
 					             ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qtev_rec.quote_number IS NULL) OR
       (p_qtev_rec.quote_number = OKC_API.G_MISS_NUM) THEN

      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'quote_number');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_quote_number;

  -- Start of comments
  --
  -- Procedure Name  : validate_requested_by
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_requested_by(p_qtev_rec IN qtev_rec_type
 					             ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is not required
    IF (p_qtev_rec.requested_by IS NULL) OR
       (p_qtev_rec.requested_by = OKC_API.G_MISS_NUM) THEN

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_requested_by;

  -- Start of comments
  --
  -- Procedure Name  : validate_approved_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_approved_yn(p_qtev_rec IN qtev_rec_type
 					            ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is not required
    IF (p_qtev_rec.approved_yn IS NULL) OR
       (p_qtev_rec.approved_yn = OKC_API.G_MISS_CHAR) THEN

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_domain_yn(
						p_col_value 	=> p_qtev_rec.approved_yn);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'approved_yn');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_approved_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_accepted_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_accepted_yn(p_qtev_rec IN qtev_rec_type
 					            ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is not required
    IF (p_qtev_rec.accepted_yn IS NULL) OR
       (p_qtev_rec.accepted_yn = OKC_API.G_MISS_CHAR) THEN

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_domain_yn(
						p_col_value 	=> p_qtev_rec.accepted_yn);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'accepted_yn');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_accepted_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_payment_received_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_payment_received_yn(p_qtev_rec IN qtev_rec_type
 					                    ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is not required
    IF (p_qtev_rec.payment_received_yn IS NULL) OR
       (p_qtev_rec.payment_received_yn = OKC_API.G_MISS_CHAR) THEN

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.check_domain_yn(
						p_col_value 	=> p_qtev_rec.payment_received_yn);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'payment_received_yn');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_payment_received_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_date_payment_received
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_payment_received(p_qtev_rec IN qtev_rec_type
 					                      ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_date_payment_received;

  -- Start of comments
  --
  -- Procedure Name  : validate_date_approved
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_approved(p_qtev_rec IN qtev_rec_type
 					              ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_date_approved;

  -- Start of comments
  --
  -- Procedure Name  : validate_approved_by
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_approved_by(p_qtev_rec IN qtev_rec_type
 					             ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_approved_by;

  -- Start of comments
  --
  -- Procedure Name  : validate_org_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_org_id(p_qtev_rec IN qtev_rec_type
 					       ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_qtev_rec.org_id IS NOT NULL) AND
       (p_qtev_rec.org_id <> OKC_API.G_MISS_NUM) THEN

      x_return_status := OKL_UTIL.check_org_id(p_org_id => p_qtev_rec.org_id);

      IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'org_id');

         raise G_EXCEPTION_HALT_VALIDATION;

      ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

         raise G_EXCEPTION_HALT_VALIDATION;

     end if;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_org_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_art_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_art_id(p_qtev_rec IN qtev_rec_type
 					       ,x_return_status OUT NOCOPY VARCHAR2) IS

  -- select the ID of the parent record from the parent
  CURSOR okl_artv_csr (p_art_id  IN NUMBER) IS
      SELECT 'x'
      FROM   OKL_ASSET_RETURNS_V
      WHERE  ID = p_art_id;

  l_dummy_var	VARCHAR2(1) := '?';

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_qtev_rec.art_id IS NOT NULL) AND
       (p_qtev_rec.art_id <> OKC_API.G_MISS_NUM) THEN

      -- enforce foreign key
      OPEN okl_artv_csr(p_qtev_rec.art_id);
      FETCH okl_artv_csr INTO l_dummy_var;
      CLOSE okl_artv_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name 	 	=> G_APP_NAME
                           ,p_msg_name 	 	=> G_NO_PARENT_RECORD
                           ,p_token1		=> G_COL_NAME_TOKEN
                           ,p_token1_value 	=> 'art_id'
                           ,p_token2		=> G_CHILD_TABLE_TOKEN
                           ,p_token2_value 	=> 'OKL_TRX_QUOTES_V'
                           ,p_token3		=> G_PARENT_TABLE_TOKEN
                           ,p_token3_value  => 'OKL_ASSET_RETURNS_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- verify that cursor was closed
      IF okl_artv_csr%ISOPEN THEN
        CLOSE okl_artv_csr;
      END IF;

  END validate_art_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_termination
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_termination(p_qtev_rec IN qtev_rec_type
 					            ,x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

	validate_trn_code( p_qtev_rec      => p_qtev_rec
 				      ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_early_termination_yn( p_qtev_rec      => p_qtev_rec
 				                  ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_partial_yn( p_qtev_rec      => p_qtev_rec
 				        ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_preproceeds_yn( p_qtev_rec      => p_qtev_rec
 				            ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_summary_format_yn( p_qtev_rec      => p_qtev_rec
 				                ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_termination;

  -- Start of comments
  --
  -- Procedure Name  : validate_restructure
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_restructure(p_qtev_rec IN qtev_rec_type
 					            ,x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

	validate_pop_code_end( p_qtev_rec      => p_qtev_rec
 				          ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_pop_code_early( p_qtev_rec      => p_qtev_rec
 				            ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_pdt_id( p_qtev_rec      => p_qtev_rec
 				    ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_principal_paydown_amt( p_qtev_rec      => p_qtev_rec
 				                   ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_residual_amount( p_qtev_rec      => p_qtev_rec
 				             ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_yield( p_qtev_rec      => p_qtev_rec
 				   ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_rent_amount( p_qtev_rec      => p_qtev_rec
 				         ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_date_restructure_end( p_qtev_rec      => p_qtev_rec
 				      ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_date_res_start( p_qtev_rec      => p_qtev_rec
 				        ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    l_return_status := 	 OKL_UTIL.check_from_to_date_range(
						 p_from_date 	=> p_qtev_rec.date_restructure_start
						,p_to_date 		=> p_qtev_rec.date_restructure_end);

    -- Log error message on the error-message-stack
    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'date_restructure_end');

    END IF;


    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_term( p_qtev_rec      => p_qtev_rec
 				  ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_purchase_percent( p_qtev_rec      => p_qtev_rec
 				              ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_date_due( p_qtev_rec      => p_qtev_rec
 				      ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_payment_frequency( p_qtev_rec      => p_qtev_rec
 				               ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_remaining_payments( p_qtev_rec      => p_qtev_rec
 				                ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_restructure;

  -- Start of comments
  --
  -- Procedure Name  : validate_repurchase
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_repurchase(p_qtev_rec IN qtev_rec_type
 					           ,x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

	validate_art_id( p_qtev_rec      => p_qtev_rec
 				    ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_repurchase;

  -- Start of comments
  --
  -- Procedure Name  : validate_effective_dates
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_effective_dates(p_qtev_rec IN qtev_rec_type
 					                ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_UTIL.check_from_to_date_range(
							 p_from_date 	=> p_qtev_rec.date_effective_from
							,p_to_date 		=> p_qtev_rec.date_effective_to);

    IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'date_effective_to');

      raise G_EXCEPTION_HALT_VALIDATION;

    ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           raise G_EXCEPTION_HALT_VALIDATION;
    end if;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_effective_dates;

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
    DELETE FROM OKL_TRX_QUOTES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TRX_QUOTES_ALL_B  B
         WHERE B.ID = T.ID
        );

    UPDATE OKL_TRX_QUOTES_TL T SET (
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKL_TRX_QUOTES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TRX_QUOTES_TL SUBB, OKL_TRX_QUOTES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

    INSERT INTO OKL_TRX_QUOTES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        COMMENTS,
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
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_TRX_QUOTES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TRX_QUOTES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_QUOTES_B
  ---------------------------------------------------------------------------
  -- Start of comments
  -- Function Name   : get_rec
  -- Description     : get record structure of OKL_TRX_QUOTE_B table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_B table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  -- End of comments
  FUNCTION get_rec (
    p_qte_rec                      IN qte_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qte_rec_type IS
    CURSOR okl_trx_quotes_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            QRS_CODE,
            QST_CODE,
            CONSOLIDATED_QTE_ID,
            KHR_ID,
            ART_ID,
            QTP_CODE,
            TRN_CODE,
            POP_CODE_END,
            POP_CODE_EARLY,
            PDT_ID,
            DATE_EFFECTIVE_FROM,
            QUOTE_NUMBER,
            OBJECT_VERSION_NUMBER,
            PURCHASE_PERCENT,
            TERM,
            DATE_RESTRUCTURE_START,
            DATE_DUE,
            DATE_APPROVED,
            DATE_RESTRUCTURE_END,
            REMAINING_PAYMENTS,
            RENT_AMOUNT,
            YIELD,
            RESIDUAL_AMOUNT,
            PRINCIPAL_PAYDOWN_AMOUNT,
            PAYMENT_FREQUENCY,
            EARLY_TERMINATION_YN,
            PARTIAL_YN,
            PREPROCEEDS_YN,
            SUMMARY_FORMAT_YN,
            CONSOLIDATED_YN,
            DATE_REQUESTED,
            DATE_PROPOSAL,
            DATE_EFFECTIVE_TO,
            DATE_ACCEPTED,
            PAYMENT_RECEIVED_YN,
            REQUESTED_BY,
            APPROVED_YN,
            ACCEPTED_YN,
            DATE_PAYMENT_RECEIVED,
            APPROVED_BY,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
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
            PURCHASE_AMOUNT,
            PURCHASE_FORMULA,
            ASSET_VALUE,
            RESIDUAL_VALUE,
            UNBILLED_RECEIVABLES,
            GAIN_LOSS,
  -- BAKUCHIB 2667636 Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
            PERDIEM_AMOUNT, --SANAHUJA  LOANS_ENHACEMENTS
  -- BAKUCHIB 2667636 End
            LEGAL_ENTITY_ID   --DKAGRAWA added for LE update
            ,REPO_QUOTE_INDICATOR_YN   --AKP:REPO-QUOTE-START-END 6599890
      FROM Okl_Trx_Quotes_B
     WHERE okl_trx_quotes_b.id  = p_id;
    l_okl_trx_quotes_b_pk          okl_trx_quotes_b_pk_csr%ROWTYPE;
    l_qte_rec                      qte_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_quotes_b_pk_csr (p_qte_rec.id);
    FETCH okl_trx_quotes_b_pk_csr INTO
              l_qte_rec.ID,
              l_qte_rec.QRS_CODE,
              l_qte_rec.QST_CODE,
              l_qte_rec.CONSOLIDATED_QTE_ID,
              l_qte_rec.KHR_ID,
              l_qte_rec.ART_ID,
              l_qte_rec.QTP_CODE,
              l_qte_rec.TRN_CODE,
              l_qte_rec.POP_CODE_END,
              l_qte_rec.POP_CODE_EARLY,
              l_qte_rec.PDT_ID,
              l_qte_rec.DATE_EFFECTIVE_FROM,
              l_qte_rec.QUOTE_NUMBER,
              l_qte_rec.OBJECT_VERSION_NUMBER,
              l_qte_rec.PURCHASE_PERCENT,
              l_qte_rec.TERM,
              l_qte_rec.DATE_RESTRUCTURE_START,
              l_qte_rec.DATE_DUE,
              l_qte_rec.DATE_APPROVED,
              l_qte_rec.DATE_RESTRUCTURE_END,
              l_qte_rec.REMAINING_PAYMENTS,
              l_qte_rec.RENT_AMOUNT,
              l_qte_rec.YIELD,
              l_qte_rec.RESIDUAL_AMOUNT,
              l_qte_rec.PRINCIPAL_PAYDOWN_AMOUNT,
              l_qte_rec.PAYMENT_FREQUENCY,
              l_qte_rec.EARLY_TERMINATION_YN,
              l_qte_rec.PARTIAL_YN,
              l_qte_rec.PREPROCEEDS_YN,
              l_qte_rec.SUMMARY_FORMAT_YN,
              l_qte_rec.CONSOLIDATED_YN,
              l_qte_rec.DATE_REQUESTED,
              l_qte_rec.DATE_PROPOSAL,
              l_qte_rec.DATE_EFFECTIVE_TO,
              l_qte_rec.DATE_ACCEPTED,
              l_qte_rec.PAYMENT_RECEIVED_YN,
              l_qte_rec.REQUESTED_BY,
              l_qte_rec.APPROVED_YN,
              l_qte_rec.ACCEPTED_YN,
              l_qte_rec.DATE_PAYMENT_RECEIVED,
              l_qte_rec.APPROVED_BY,
              l_qte_rec.ORG_ID,
              l_qte_rec.REQUEST_ID,
              l_qte_rec.PROGRAM_APPLICATION_ID,
              l_qte_rec.PROGRAM_ID,
              l_qte_rec.PROGRAM_UPDATE_DATE,
              l_qte_rec.ATTRIBUTE_CATEGORY,
              l_qte_rec.ATTRIBUTE1,
              l_qte_rec.ATTRIBUTE2,
              l_qte_rec.ATTRIBUTE3,
              l_qte_rec.ATTRIBUTE4,
              l_qte_rec.ATTRIBUTE5,
              l_qte_rec.ATTRIBUTE6,
              l_qte_rec.ATTRIBUTE7,
              l_qte_rec.ATTRIBUTE8,
              l_qte_rec.ATTRIBUTE9,
              l_qte_rec.ATTRIBUTE10,
              l_qte_rec.ATTRIBUTE11,
              l_qte_rec.ATTRIBUTE12,
              l_qte_rec.ATTRIBUTE13,
              l_qte_rec.ATTRIBUTE14,
              l_qte_rec.ATTRIBUTE15,
              l_qte_rec.CREATED_BY,
              l_qte_rec.CREATION_DATE,
              l_qte_rec.LAST_UPDATED_BY,
              l_qte_rec.LAST_UPDATE_DATE,
              l_qte_rec.LAST_UPDATE_LOGIN,
              l_qte_rec.PURCHASE_AMOUNT,
              l_qte_rec.PURCHASE_FORMULA,
              l_qte_rec.ASSET_VALUE,
              l_qte_rec.RESIDUAL_VALUE,
              l_qte_rec.UNBILLED_RECEIVABLES,
              l_qte_rec.GAIN_LOSS,
  -- BAKUCHIB 2667636 Start
              l_qte_rec.CURRENCY_CODE,
              l_qte_rec.CURRENCY_CONVERSION_CODE,
              l_qte_rec.CURRENCY_CONVERSION_TYPE,
              l_qte_rec.CURRENCY_CONVERSION_RATE,
              l_qte_rec.CURRENCY_CONVERSION_DATE,
              l_qte_rec.PERDIEM_AMOUNT,--SANAHUJA -- LOANS_ENHACEMENTS
	      l_qte_rec.LEGAL_ENTITY_ID, --DKAGRAWA added for LE uptake
	      l_qte_rec.REPO_QUOTE_INDICATOR_YN; --AKP:REPO-QUOTE-START-END 6599890
  -- BAKUCHIB 2667636 End
    x_no_data_found := okl_trx_quotes_b_pk_csr%NOTFOUND;
    CLOSE okl_trx_quotes_b_pk_csr;
    RETURN(l_qte_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qte_rec                      IN qte_rec_type
  ) RETURN qte_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qte_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_QUOTES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_trx_quotes_tl_rec        IN okl_trx_quotes_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_trx_quotes_tl_rec_type IS
    CURSOR okl_trx_quotes_tl_pk_csr (p_id                 IN NUMBER,
                                     p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Trx_Quotes_Tl
     WHERE okl_trx_quotes_tl.id = p_id
       AND okl_trx_quotes_tl.language = p_language;
    l_okl_trx_quotes_tl_pk         okl_trx_quotes_tl_pk_csr%ROWTYPE;
    l_okl_trx_quotes_tl_rec        okl_trx_quotes_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_quotes_tl_pk_csr (p_okl_trx_quotes_tl_rec.id,
                                   p_okl_trx_quotes_tl_rec.language);
    FETCH okl_trx_quotes_tl_pk_csr INTO
              l_okl_trx_quotes_tl_rec.ID,
              l_okl_trx_quotes_tl_rec.LANGUAGE,
              l_okl_trx_quotes_tl_rec.SOURCE_LANG,
              l_okl_trx_quotes_tl_rec.SFWT_FLAG,
              l_okl_trx_quotes_tl_rec.COMMENTS,
              l_okl_trx_quotes_tl_rec.CREATED_BY,
              l_okl_trx_quotes_tl_rec.CREATION_DATE,
              l_okl_trx_quotes_tl_rec.LAST_UPDATED_BY,
              l_okl_trx_quotes_tl_rec.LAST_UPDATE_DATE,
              l_okl_trx_quotes_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_trx_quotes_tl_pk_csr%NOTFOUND;
    CLOSE okl_trx_quotes_tl_pk_csr;
    RETURN(l_okl_trx_quotes_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_trx_quotes_tl_rec        IN okl_trx_quotes_tl_rec_type
  ) RETURN okl_trx_quotes_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_trx_quotes_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_QUOTES_V
  ---------------------------------------------------------------------------
  -- Start of comments
  -- Function Name   : get_rec
  -- Description     : get record structure of OKL_TRX_QUOTE_V table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  -- End of comments
  FUNCTION get_rec (
    p_qtev_rec                     IN qtev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qtev_rec_type IS
    CURSOR okl_qtev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            QRS_CODE,
            QST_CODE,
            QTP_CODE,
            TRN_CODE,
            POP_CODE_END,
            POP_CODE_EARLY,
            CONSOLIDATED_QTE_ID,
            KHR_ID,
            ART_ID,
            PDT_ID,
            EARLY_TERMINATION_YN,
            PARTIAL_YN,
            PREPROCEEDS_YN,
            DATE_REQUESTED,
            DATE_PROPOSAL,
            DATE_EFFECTIVE_TO,
            DATE_ACCEPTED,
            SUMMARY_FORMAT_YN,
            CONSOLIDATED_YN,
            PRINCIPAL_PAYDOWN_AMOUNT,
            RESIDUAL_AMOUNT,
            YIELD,
            RENT_AMOUNT,
            DATE_RESTRUCTURE_END,
            DATE_RESTRUCTURE_START,
            TERM,
            PURCHASE_PERCENT,
            COMMENTS,
            DATE_DUE,
            PAYMENT_FREQUENCY,
            REMAINING_PAYMENTS,
            DATE_EFFECTIVE_FROM,
            QUOTE_NUMBER,
            REQUESTED_BY,
            APPROVED_YN,
            ACCEPTED_YN,
            PAYMENT_RECEIVED_YN,
            DATE_PAYMENT_RECEIVED,
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
            DATE_APPROVED,
            APPROVED_BY,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PURCHASE_AMOUNT,
            PURCHASE_FORMULA,
            ASSET_VALUE,
            RESIDUAL_VALUE,
            UNBILLED_RECEIVABLES,
            GAIN_LOSS,
  -- BAKUCHIB 2667636 Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
            PERDIEM_AMOUNT, --SANAHUJA -- LOANS_ENHACEMENTS
  -- BAKUCHIB 2667636 End
            LEGAL_ENTITY_ID,   --DKAGRAWA added for LE update
            REPO_QUOTE_INDICATOR_YN   --AKP:REPO-QUOTE-START-END 6599890
      FROM Okl_Trx_Quotes_V
     WHERE okl_trx_quotes_v.id  = p_id;
    l_okl_qtev_pk                  okl_qtev_pk_csr%ROWTYPE;
    l_qtev_rec                     qtev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_qtev_pk_csr (p_qtev_rec.id);
    FETCH okl_qtev_pk_csr INTO
              l_qtev_rec.ID,
              l_qtev_rec.OBJECT_VERSION_NUMBER,
              l_qtev_rec.SFWT_FLAG,
              l_qtev_rec.QRS_CODE,
              l_qtev_rec.QST_CODE,
              l_qtev_rec.QTP_CODE,
              l_qtev_rec.TRN_CODE,
              l_qtev_rec.POP_CODE_END,
              l_qtev_rec.POP_CODE_EARLY,
              l_qtev_rec.CONSOLIDATED_QTE_ID,
              l_qtev_rec.KHR_ID,
              l_qtev_rec.ART_ID,
              l_qtev_rec.PDT_ID,
              l_qtev_rec.EARLY_TERMINATION_YN,
              l_qtev_rec.PARTIAL_YN,
              l_qtev_rec.PREPROCEEDS_YN,
              l_qtev_rec.DATE_REQUESTED,
              l_qtev_rec.DATE_PROPOSAL,
              l_qtev_rec.DATE_EFFECTIVE_TO,
              l_qtev_rec.DATE_ACCEPTED,
              l_qtev_rec.SUMMARY_FORMAT_YN,
              l_qtev_rec.CONSOLIDATED_YN,
              l_qtev_rec.PRINCIPAL_PAYDOWN_AMOUNT,
              l_qtev_rec.RESIDUAL_AMOUNT,
              l_qtev_rec.YIELD,
              l_qtev_rec.RENT_AMOUNT,
              l_qtev_rec.DATE_RESTRUCTURE_END,
              l_qtev_rec.DATE_RESTRUCTURE_START,
              l_qtev_rec.TERM,
              l_qtev_rec.PURCHASE_PERCENT,
              l_qtev_rec.COMMENTS,
              l_qtev_rec.DATE_DUE,
              l_qtev_rec.PAYMENT_FREQUENCY,
              l_qtev_rec.REMAINING_PAYMENTS,
              l_qtev_rec.DATE_EFFECTIVE_FROM,
              l_qtev_rec.QUOTE_NUMBER,
              l_qtev_rec.REQUESTED_BY,
              l_qtev_rec.APPROVED_YN,
              l_qtev_rec.ACCEPTED_YN,
              l_qtev_rec.PAYMENT_RECEIVED_YN,
              l_qtev_rec.DATE_PAYMENT_RECEIVED,
              l_qtev_rec.ATTRIBUTE_CATEGORY,
              l_qtev_rec.ATTRIBUTE1,
              l_qtev_rec.ATTRIBUTE2,
              l_qtev_rec.ATTRIBUTE3,
              l_qtev_rec.ATTRIBUTE4,
              l_qtev_rec.ATTRIBUTE5,
              l_qtev_rec.ATTRIBUTE6,
              l_qtev_rec.ATTRIBUTE7,
              l_qtev_rec.ATTRIBUTE8,
              l_qtev_rec.ATTRIBUTE9,
              l_qtev_rec.ATTRIBUTE10,
              l_qtev_rec.ATTRIBUTE11,
              l_qtev_rec.ATTRIBUTE12,
              l_qtev_rec.ATTRIBUTE13,
              l_qtev_rec.ATTRIBUTE14,
              l_qtev_rec.ATTRIBUTE15,
              l_qtev_rec.DATE_APPROVED,
              l_qtev_rec.APPROVED_BY,
              l_qtev_rec.ORG_ID,
              l_qtev_rec.REQUEST_ID,
              l_qtev_rec.PROGRAM_APPLICATION_ID,
              l_qtev_rec.PROGRAM_ID,
              l_qtev_rec.PROGRAM_UPDATE_DATE,
              l_qtev_rec.CREATED_BY,
              l_qtev_rec.CREATION_DATE,
              l_qtev_rec.LAST_UPDATED_BY,
              l_qtev_rec.LAST_UPDATE_DATE,
              l_qtev_rec.LAST_UPDATE_LOGIN,
              l_qtev_rec.PURCHASE_AMOUNT,
              l_qtev_rec.PURCHASE_FORMULA,
              l_qtev_rec.ASSET_VALUE,
              l_qtev_rec.RESIDUAL_VALUE,
              l_qtev_rec.UNBILLED_RECEIVABLES,
              l_qtev_rec.GAIN_LOSS,
  -- BAKUCHIB 2667636 Start
              l_qtev_rec.CURRENCY_CODE,
              l_qtev_rec.CURRENCY_CONVERSION_CODE,
              l_qtev_rec.CURRENCY_CONVERSION_TYPE,
              l_qtev_rec.CURRENCY_CONVERSION_RATE,
              l_qtev_rec.CURRENCY_CONVERSION_DATE,
              l_qtev_rec.PERDIEM_AMOUNT, --SANAHUJA -- LOANS_ENHACEMENTS ;
  -- BAKUCHIB 2667636 End
              l_qtev_rec.LEGAL_ENTITY_ID,   --DKAGRAWA added for LE update
              l_qtev_rec.REPO_QUOTE_INDICATOR_YN;   --AKP:REPO-QUOTE-START-END 6599890
    x_no_data_found := okl_qtev_pk_csr%NOTFOUND;
    CLOSE okl_qtev_pk_csr;
    RETURN(l_qtev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qtev_rec                     IN qtev_rec_type
  ) RETURN qtev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qtev_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_QUOTES_V --
  ------------------------------------------------------
  -- Start of comments
  -- Function Name   : null_out_defaults
  -- Description     : Null out record structure of OKL_TRX_QUOTE_V table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  -- End of comments
  FUNCTION null_out_defaults (
    p_qtev_rec	IN qtev_rec_type
  ) RETURN qtev_rec_type IS
    l_qtev_rec	qtev_rec_type := p_qtev_rec;
  BEGIN
    IF (l_qtev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.object_version_number := NULL;
    END IF;
    IF (l_qtev_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.sfwt_flag := NULL;
    END IF;
    IF (l_qtev_rec.qrs_code = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.qrs_code := NULL;
    END IF;
    IF (l_qtev_rec.qst_code = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.qst_code := NULL;
    END IF;
    IF (l_qtev_rec.qtp_code = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.qtp_code := NULL;
    END IF;
    IF (l_qtev_rec.trn_code = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.trn_code := NULL;
    END IF;
    IF (l_qtev_rec.pop_code_end = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.pop_code_end := NULL;
    END IF;
    IF (l_qtev_rec.pop_code_early = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.pop_code_early := NULL;
    END IF;
    IF (l_qtev_rec.consolidated_qte_id = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.consolidated_qte_id := NULL;
    END IF;
    IF (l_qtev_rec.khr_id = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.khr_id := NULL;
    END IF;
    IF (l_qtev_rec.art_id = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.art_id := NULL;
    END IF;
    IF (l_qtev_rec.pdt_id = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.pdt_id := NULL;
    END IF;
    IF (l_qtev_rec.early_termination_yn = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.early_termination_yn := NULL;
    END IF;
    IF (l_qtev_rec.partial_yn = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.partial_yn := NULL;
    END IF;
    IF (l_qtev_rec.preproceeds_yn = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.preproceeds_yn := NULL;
    END IF;
    IF (l_qtev_rec.date_requested = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.date_requested := NULL;
    END IF;
    IF (l_qtev_rec.date_proposal = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.date_proposal := NULL;
    END IF;
    IF (l_qtev_rec.date_effective_to = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.date_effective_to := NULL;
    END IF;
    IF (l_qtev_rec.date_accepted = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.date_accepted := NULL;
    END IF;
    IF (l_qtev_rec.summary_format_yn = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.summary_format_yn := NULL;
    END IF;
    IF (l_qtev_rec.consolidated_yn = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.consolidated_yn := NULL;
    END IF;
    IF (l_qtev_rec.principal_paydown_amount = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.principal_paydown_amount := NULL;
    END IF;
    IF (l_qtev_rec.residual_amount = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.residual_amount := NULL;
    END IF;
    IF (l_qtev_rec.yield = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.yield := NULL;
    END IF;
    IF (l_qtev_rec.rent_amount = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.rent_amount := NULL;
    END IF;
    IF (l_qtev_rec.date_restructure_end = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.date_restructure_end := NULL;
    END IF;
    IF (l_qtev_rec.date_restructure_start = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.date_restructure_start := NULL;
    END IF;
    IF (l_qtev_rec.term = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.term := NULL;
    END IF;
    IF (l_qtev_rec.purchase_percent = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.purchase_percent := NULL;
    END IF;
    IF (l_qtev_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.comments := NULL;
    END IF;
    IF (l_qtev_rec.date_due = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.date_due := NULL;
    END IF;
    IF (l_qtev_rec.payment_frequency = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.payment_frequency := NULL;
    END IF;
    IF (l_qtev_rec.remaining_payments = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.remaining_payments := NULL;
    END IF;
    IF (l_qtev_rec.date_effective_from = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.date_effective_from := NULL;
    END IF;
    IF (l_qtev_rec.quote_number = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.quote_number := NULL;
    END IF;
    IF (l_qtev_rec.requested_by = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.requested_by := NULL;
    END IF;
    IF (l_qtev_rec.approved_yn = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.approved_yn := NULL;
    END IF;
    IF (l_qtev_rec.accepted_yn = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.accepted_yn := NULL;
    END IF;
    IF (l_qtev_rec.payment_received_yn = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.payment_received_yn := NULL;
    END IF;
    IF (l_qtev_rec.date_payment_received = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.date_payment_received := NULL;
    END IF;
    IF (l_qtev_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute_category := NULL;
    END IF;
    IF (l_qtev_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute1 := NULL;
    END IF;
    IF (l_qtev_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute2 := NULL;
    END IF;
    IF (l_qtev_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute3 := NULL;
    END IF;
    IF (l_qtev_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute4 := NULL;
    END IF;
    IF (l_qtev_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute5 := NULL;
    END IF;
    IF (l_qtev_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute6 := NULL;
    END IF;
    IF (l_qtev_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute7 := NULL;
    END IF;
    IF (l_qtev_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute8 := NULL;
    END IF;
    IF (l_qtev_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute9 := NULL;
    END IF;
    IF (l_qtev_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute10 := NULL;
    END IF;
    IF (l_qtev_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute11 := NULL;
    END IF;
    IF (l_qtev_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute12 := NULL;
    END IF;
    IF (l_qtev_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute13 := NULL;
    END IF;
    IF (l_qtev_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute14 := NULL;
    END IF;
    IF (l_qtev_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.attribute15 := NULL;
    END IF;
    IF (l_qtev_rec.date_approved = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.date_approved := NULL;
    END IF;
    IF (l_qtev_rec.approved_by = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.approved_by := NULL;
    END IF;
    IF (l_qtev_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.org_id := NULL;
    END IF;
/*
    IF (l_qtev_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.request_id := NULL;
    END IF;
    IF (l_qtev_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.program_application_id := NULL;
    END IF;
    IF (l_qtev_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.program_id := NULL;
    END IF;
    IF (l_qtev_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.program_update_date := NULL;
    END IF;
*/
    IF (l_qtev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.created_by := NULL;
    END IF;
    IF (l_qtev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.creation_date := NULL;
    END IF;
    IF (l_qtev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.last_updated_by := NULL;
    END IF;
    IF (l_qtev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.last_update_date := NULL;
    END IF;
    IF (l_qtev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.last_update_login := NULL;
    END IF;
    IF (l_qtev_rec.purchase_amount = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.purchase_amount := NULL;
    END IF;
    IF (l_qtev_rec.purchase_formula = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.purchase_formula := NULL;
    END IF;
    IF (l_qtev_rec.asset_value = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.asset_value := NULL;
    END IF;
    IF (l_qtev_rec.residual_value = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.residual_value := NULL;
    END IF;
    IF (l_qtev_rec.unbilled_receivables = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.unbilled_receivables := NULL;
    END IF;
    IF (l_qtev_rec.gain_loss = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.gain_loss := NULL;
    END IF;
  -- BAKUCHIB 2667636 Start
    IF (l_qtev_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.currency_code := NULL;
    END IF;
    IF (l_qtev_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.currency_conversion_code := NULL;
    END IF;
    IF (l_qtev_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
      l_qtev_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_qtev_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_qtev_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
      l_qtev_rec.currency_conversion_date := NULL;
    END IF;
  -- BAKUCHIB 2667636 End
    IF (l_qtev_rec.PERDIEM_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.PERDIEM_AMOUNT := NULL;
    END IF;  --SANAHUJA -- LOANS_ENHACEMENTS
    --dkagrawa LE update start
    IF (l_qtev_rec.legal_entity_id = OKC_API.G_MISS_NUM) THEN
      l_qtev_rec.legal_entity_id := NULL;
    END IF;
    --dkagrawa LE update end

    RETURN(l_qtev_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_TRX_QUOTES_V --
  ----------------------------------------------
  -- Start of comments
  -- Function Name   : Validate_Attributes
  -- Description     : Validate Attributes of record structure of
  --                   OKL_TRX_QUOTE_V table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added Procedure for validation of Currency code,
  --                   currency Conversion_code and Currency conversion type
  -- End of comments
  FUNCTION Validate_Attributes (p_qtev_rec IN  qtev_rec_type)
    RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN

	validate_id( p_qtev_rec      => p_qtev_rec
				,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_object_version_number( p_qtev_rec      => p_qtev_rec
				                   ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    --dkagrawa LE uptake start
	validate_legal_entity_id( p_qtev_rec      => p_qtev_rec
				                   ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    --dkagrawa LE uptake end

    --AKP:REPO-QUOTE-START 6599890
	validate_repo_qte_indicator_yn( p_qtev_rec      => p_qtev_rec
				       ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    --AKP:REPO-QUOTE-START

	validate_sfwt_flag( p_qtev_rec      => p_qtev_rec
				       ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_qrs_code( p_qtev_rec      => p_qtev_rec
 				      ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_qst_code( p_qtev_rec      => p_qtev_rec
 				      ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_qtp_code( p_qtev_rec      => p_qtev_rec
 				      ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_khr_id( p_qtev_rec      => p_qtev_rec
 				    ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_date_requested( p_qtev_rec      => p_qtev_rec
 				            ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_date_proposal( p_qtev_rec      => p_qtev_rec
 				           ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_date_accepted( p_qtev_rec      => p_qtev_rec
 				           ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_date_effective_from( p_qtev_rec      => p_qtev_rec
 				                 ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_date_effective_to( p_qtev_rec      => p_qtev_rec
 				               ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_date_payment_received( p_qtev_rec      => p_qtev_rec
 				                   ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_quote_number( p_qtev_rec      => p_qtev_rec
 				          ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_accepted_yn( p_qtev_rec      => p_qtev_rec
 				         ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_approved_yn( p_qtev_rec      => p_qtev_rec
 				                 ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_consolidated_yn( p_qtev_rec      => p_qtev_rec
 				             ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_comments( p_qtev_rec      => p_qtev_rec
 				      ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_payment_received_yn( p_qtev_rec      => p_qtev_rec
 				                 ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;


	validate_org_id( p_qtev_rec      => p_qtev_rec
 				    ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_consolidated_qte_id( p_qtev_rec      => p_qtev_rec
 				                 ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_date_approved( p_qtev_rec      => p_qtev_rec
 				           ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

	validate_approved_by( p_qtev_rec      => p_qtev_rec
 				         ,x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

  -- BAKUCHIB 2667636 Start
    validate_currency_code(p_qtev_rec      => p_qtev_rec,
                           x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_code(p_qtev_rec      => p_qtev_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_type(p_qtev_rec      => p_qtev_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- BAKUCHIB 2667636 End

    RETURN x_return_status;

    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => sqlcode
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => sqlerrm);

        --notify caller of an UNEXPECTED error
        x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        RETURN x_return_status;

  END Validate_Attributes;

  -- Start of comments
  --
  -- Function Name  : is_unique
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  FUNCTION IS_UNIQUE (p_qtev_rec  IN qtev_rec_type) RETURN VARCHAR2
  IS

  -- select the quote record matching the unique key value
  CURSOR okl_qtev_csr (p_quote_number  IN NUMBER, p_id  IN NUMBER) IS
      SELECT 'x'
      FROM   OKL_TRX_QUOTES_V
      WHERE  QUOTE_NUMBER = p_quote_number
      AND    ID <> nvl(p_id, -99999);

  l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_dummy             VARCHAR2(1);
  l_found             BOOLEAN;

  BEGIN
    -- initialize return status
    l_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_qtev_rec.quote_number IS NOT NULL) THEN

      -- enforce foreign key
      OPEN okl_qtev_csr(p_qtev_rec.quote_number,p_qtev_rec.id);
      FETCH okl_qtev_csr INTO l_dummy;
      l_found := okl_qtev_csr%FOUND;
	  CLOSE okl_qtev_csr;

    END IF;

    IF (l_found) Then
  	  OKC_API.SET_MESSAGE(	 p_app_name		=> 'OKL'
				    	  	,p_msg_name		=> 'OKL_UNIQUE_KEY_EXISTS'
					    	,p_token1		=> 'UK_KEY_VALUE'
					   	 	,p_token1_value	=> p_qtev_rec.quote_number
					    	,p_token2		=> 'UK_KEY_VALUE'
					    	,p_token2_value	=> nvl(p_qtev_rec.id,' '));
	  -- notify caller of an error
	  l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN (l_return_status);

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- verify that cursor was closed
      IF okl_qtev_csr%ISOPEN THEN
        CLOSE okl_qtev_csr;
      END IF;

  	  RETURN (l_return_status);

  END IS_UNIQUE;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKL_TRX_QUOTES_V --
  ------------------------------------------
  -- Start of comments
  -- Function Name   : Validate_Record
  -- Description     : Validate Record of record structure of
  --                   OKL_TRX_QUOTE_V table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                   Added Procedure to validate Currency conversion Code,type
  --                  ,rate and Date aganist currency code
  -- End of comments
  FUNCTION Validate_Record (p_qtev_rec IN qtev_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    --
    -- Unique Key validation
    --
      x_return_status := IS_UNIQUE(p_qtev_rec);
    --
    -- Subtype column validation
    --
    IF (p_qtev_rec.qtp_code like 'TER%') THEN
  	  validate_termination(p_qtev_rec      => p_qtev_rec
 				          ,x_return_status => l_return_status);

	ELSIF (p_qtev_rec.qtp_code like 'RES%') THEN
  	  validate_restructure(p_qtev_rec      => p_qtev_rec
 				          ,x_return_status => l_return_status);

	ELSIF (p_qtev_rec.qtp_code = 'REP%') THEN
  	  validate_repurchase(p_qtev_rec      => p_qtev_rec
 				         ,x_return_status => l_return_status);

    END IF;

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    --
    -- Date checks
    --
	validate_effective_dates(p_qtev_rec      => p_qtev_rec
 				            ,x_return_status => l_return_status);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- BAKUCHIB 2667636 Start
    -- Validate Currency conversion Code,type,rate and Date

    validate_currency_record(p_qtev_rec      => p_qtev_rec,
                                 x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- BAKUCHIB 2667636 End

    RETURN (x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => sqlcode
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => sqlerrm);

        --notify caller of an UNEXPECTED error
        x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        RETURN x_return_status;

  END Validate_Record;

/*  generated code
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_TRX_QUOTES_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_qtev_rec IN  qtev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_qtev_rec.id = OKC_API.G_MISS_NUM OR
       p_qtev_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qtev_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_qtev_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qtev_rec.qrs_code = OKC_API.G_MISS_CHAR OR
          p_qtev_rec.qrs_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'qrs_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qtev_rec.qst_code = OKC_API.G_MISS_CHAR OR
          p_qtev_rec.qst_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'qst_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qtev_rec.qtp_code = OKC_API.G_MISS_CHAR OR
          p_qtev_rec.qtp_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'qtp_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qtev_rec.date_effective_from = OKC_API.G_MISS_DATE OR
          p_qtev_rec.date_effective_from IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_effective_from');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qtev_rec.quote_number = OKC_API.G_MISS_NUM OR
          p_qtev_rec.quote_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'quote_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKL_TRX_QUOTES_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_qtev_rec IN qtev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_qtev_rec IN qtev_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okl_artv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              RMR_ID,
              IMR_ID,
              RNA_ID,
              KLE_ID,
              ISO_ID,
              SECURITY_DEP_TRX_AP_ID,
              ARS_CODE,
              ART1_CODE,
              RRN_CODE,
              INSURANCE_AMOUNT,
              DATE_RETURNED,
              DATE_RETURN_DUE,
              DATE_RETURN_NOTIFIED,
              RELOCATE_ASSET_YN,
              TRANS_OPTION_ACCEPTED_YN,
              VOLUNTARY_YN,
              DATE_REPOSSESSION_REQUIRED,
              DATE_REPOSSESSION_ACTUAL,
              DATE_HOLD_UNTIL,
              COMMMERCIALLY_REAS_SALE_YN,
              COMMENTS,
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
              REQUEST_ID,
              PROGRAM_APPLICATION_ID,
              PROGRAM_ID,
              PROGRAM_UPDATE_DATE,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okl_Asset_Returns_V
       WHERE okl_asset_returns_v.id = p_id;
      l_okl_artv_pk                  okl_artv_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_qtev_rec.ART_ID IS NOT NULL)
      THEN
        OPEN okl_artv_pk_csr(p_qtev_rec.ART_ID);
        FETCH okl_artv_pk_csr INTO l_okl_artv_pk;
        l_row_notfound := okl_artv_pk_csr%NOTFOUND;
        CLOSE okl_artv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ART_ID');
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
    l_return_status := validate_foreign_keys (p_qtev_rec);
    RETURN (l_return_status);
  END Validate_Record;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : Migrate
  -- Description     : Migrate record structure of OKL_TRX_QUOTE_V table
  --                   to record structure of OKL_TRX_QUOTE_B table
  -- Business Rules  :
  -- Parameters      : IN Record structure of OKL_TRX_QUOTE_V table
  --                   IN OUT Record structure of OKL_TRX_QUOTE_B table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  -- End of comments
  PROCEDURE migrate (
    p_from	IN qtev_rec_type,
    p_to	IN OUT NOCOPY qte_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.qrs_code := p_from.qrs_code;
    p_to.qst_code := p_from.qst_code;
    p_to.consolidated_qte_id := p_from.consolidated_qte_id;
    p_to.khr_id := p_from.khr_id;
    p_to.art_id := p_from.art_id;
    p_to.qtp_code := p_from.qtp_code;
    p_to.trn_code := p_from.trn_code;
    p_to.pop_code_end := p_from.pop_code_end;
    p_to.pop_code_early := p_from.pop_code_early;
    p_to.pdt_id := p_from.pdt_id;
    p_to.date_effective_from := p_from.date_effective_from;
    p_to.quote_number := p_from.quote_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.purchase_percent := p_from.purchase_percent;
    p_to.term := p_from.term;
    p_to.date_restructure_start := p_from.date_restructure_start;
    p_to.date_due := p_from.date_due;
    p_to.date_approved := p_from.date_approved;
    p_to.date_restructure_end := p_from.date_restructure_end;
    p_to.remaining_payments := p_from.remaining_payments;
    p_to.rent_amount := p_from.rent_amount;
    p_to.yield := p_from.yield;
    p_to.residual_amount := p_from.residual_amount;
    p_to.principal_paydown_amount := p_from.principal_paydown_amount;
    p_to.payment_frequency := p_from.payment_frequency;
    p_to.early_termination_yn := p_from.early_termination_yn;
    p_to.partial_yn := p_from.partial_yn;
    p_to.preproceeds_yn := p_from.preproceeds_yn;
    p_to.summary_format_yn := p_from.summary_format_yn;
    p_to.consolidated_yn := p_from.consolidated_yn;
    p_to.date_requested := p_from.date_requested;
    p_to.date_proposal := p_from.date_proposal;
    p_to.date_effective_to := p_from.date_effective_to;
    p_to.date_accepted := p_from.date_accepted;
    p_to.payment_received_yn := p_from.payment_received_yn;
    p_to.requested_by := p_from.requested_by;
    p_to.approved_yn := p_from.approved_yn;
    p_to.accepted_yn := p_from.accepted_yn;
    p_to.date_payment_received := p_from.date_payment_received;
    p_to.approved_by := p_from.approved_by;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
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
    p_to.purchase_amount := p_from.purchase_amount;
    p_to.purchase_formula := p_from.purchase_formula;
    p_to.asset_value := p_from.asset_value;
    p_to.residual_value  := p_from.residual_value;
    p_to.unbilled_receivables  := p_from.unbilled_receivables;
    p_to.gain_loss  := p_from.gain_loss;
  -- BAKUCHIB 2667636 Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- BAKUCHIB 2667636 End
    p_to.PERDIEM_AMOUNT  := p_from.PERDIEM_AMOUNT; --SANAHUJA -- LOANS_ENHACEMENTS
    p_to.legal_entity_id := p_from.legal_entity_id; --DKAGRAWA for LE uptake project
    p_to.repo_quote_indicator_yn := p_from.repo_quote_indicator_yn; --AKP:REPO-QUOTE-START-END 6599890

  END migrate;
  ---------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : Migrate
  -- Description     : Migrate record structure of OKL_TRX_QUOTE_B table
  --                   to record structure of OKL_TRX_QUOTE_V table
  -- Business Rules  :
  -- Parameters      : IN Record structure of OKL_TRX_QUOTE_B table
  --                   IN OUT Record structure of OKL_TRX_QUOTE_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  -- End of comments
  PROCEDURE migrate (
    p_from	IN qte_rec_type,
    p_to	IN OUT NOCOPY qtev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.qrs_code := p_from.qrs_code;
    p_to.qst_code := p_from.qst_code;
    p_to.consolidated_qte_id := p_from.consolidated_qte_id;
    p_to.khr_id := p_from.khr_id;
    p_to.art_id := p_from.art_id;
    p_to.qtp_code := p_from.qtp_code;
    p_to.trn_code := p_from.trn_code;
    p_to.pop_code_end := p_from.pop_code_end;
    p_to.pop_code_early := p_from.pop_code_early;
    p_to.pdt_id := p_from.pdt_id;
    p_to.date_effective_from := p_from.date_effective_from;
    p_to.quote_number := p_from.quote_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.purchase_percent := p_from.purchase_percent;
    p_to.term := p_from.term;
    p_to.date_restructure_start := p_from.date_restructure_start;
    p_to.date_due := p_from.date_due;
    p_to.date_approved := p_from.date_approved;
    p_to.date_restructure_end := p_from.date_restructure_end;
    p_to.remaining_payments := p_from.remaining_payments;
    p_to.rent_amount := p_from.rent_amount;
    p_to.yield := p_from.yield;
    p_to.residual_amount := p_from.residual_amount;
    p_to.principal_paydown_amount := p_from.principal_paydown_amount;
    p_to.payment_frequency := p_from.payment_frequency;
    p_to.early_termination_yn := p_from.early_termination_yn;
    p_to.partial_yn := p_from.partial_yn;
    p_to.preproceeds_yn := p_from.preproceeds_yn;
    p_to.summary_format_yn := p_from.summary_format_yn;
    p_to.consolidated_yn := p_from.consolidated_yn;
    p_to.date_requested := p_from.date_requested;
    p_to.date_proposal := p_from.date_proposal;
    p_to.date_effective_to := p_from.date_effective_to;
    p_to.date_accepted := p_from.date_accepted;
    p_to.payment_received_yn := p_from.payment_received_yn;
    p_to.requested_by := p_from.requested_by;
    p_to.approved_yn := p_from.approved_yn;
    p_to.accepted_yn := p_from.accepted_yn;
    p_to.date_payment_received := p_from.date_payment_received;
    p_to.approved_by := p_from.approved_by;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
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
    p_to.purchase_amount := p_from.purchase_amount;
    p_to.purchase_formula := p_from.purchase_formula;
    p_to.asset_value := p_from.asset_value;
    p_to.residual_value  := p_from.residual_value;
    p_to.unbilled_receivables  := p_from.unbilled_receivables;
    p_to.gain_loss  := p_from.gain_loss;
  --BAKUCHIB 2667636 Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  --BAKUCHIB 2667636 End
    p_to.PERDIEM_AMOUNT  := p_from.PERDIEM_AMOUNT; --SANAHUJA -- LOANS_ENHACEMENTS
    p_to.legal_entity_id := p_from.legal_entity_id; --DKAGRAWA for LE uptake project
    p_to.repo_quote_indicator_yn := p_from.repo_quote_indicator_yn; --AKP:REPO-QUOTE-START-END 6599890
  END migrate;
  PROCEDURE migrate (
    p_from	IN qtev_rec_type,
    p_to	IN OUT NOCOPY okl_trx_quotes_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_trx_quotes_tl_rec_type,
    p_to	IN OUT NOCOPY qtev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKL_TRX_QUOTES_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qtev_rec                     qtev_rec_type := p_qtev_rec;
    l_qte_rec                      qte_rec_type;
    l_okl_trx_quotes_tl_rec        okl_trx_quotes_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_qtev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_qtev_rec);
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
  -- PL/SQL TBL validate_row for:QTEV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_tbl                     IN qtev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qtev_tbl.COUNT > 0) THEN
      i := p_qtev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qtev_rec                     => p_qtev_tbl(i));
        EXIT WHEN (i = p_qtev_tbl.LAST);
        i := p_qtev_tbl.NEXT(i);
      END LOOP;
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
  -------------------------------------
  -- insert_row for:OKL_TRX_QUOTES_B --
  -------------------------------------
  -- Start of comments
  -- Procedure Name  : insert_row
  -- Description     : Insert Row into OKL_TRX_QUOTE_B table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_B table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  -- End of comments
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qte_rec                      IN qte_rec_type,
    x_qte_rec                      OUT NOCOPY qte_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qte_rec                      qte_rec_type := p_qte_rec;
    l_def_qte_rec                  qte_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_QUOTES_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_qte_rec IN  qte_rec_type,
      x_qte_rec OUT NOCOPY qte_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qte_rec := p_qte_rec;
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
      p_qte_rec,                         -- IN
      l_qte_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

        -- rmunjulu loan repo
    IF l_qte_rec.repo_quote_indicator_yn IS NULL
    OR l_qte_rec.repo_quote_indicator_yn = OKL_API.G_MISS_CHAR THEN
      l_qte_rec.repo_quote_indicator_yn := 'N';
    END IF;

    INSERT INTO OKL_TRX_QUOTES_B(
        id,
        qrs_code,
        qst_code,
        consolidated_qte_id,
        khr_id,
        art_id,
        qtp_code,
        trn_code,
        pop_code_end,
        pop_code_early,
        pdt_id,
        date_effective_from,
        quote_number,
        object_version_number,
        purchase_percent,
        term,
        date_restructure_start,
        date_due,
        date_approved,
        date_restructure_end,
        remaining_payments,
        rent_amount,
        yield,
        residual_amount,
        principal_paydown_amount,
        payment_frequency,
        early_termination_yn,
        partial_yn,
        preproceeds_yn,
        summary_format_yn,
        consolidated_yn,
        date_requested,
        date_proposal,
        date_effective_to,
        date_accepted,
        payment_received_yn,
        requested_by,
        approved_yn,
        accepted_yn,
        date_payment_received,
        approved_by,
        org_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
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
        purchase_amount,
        purchase_formula,
        asset_value,
        residual_value,
        unbilled_receivables,
        gain_loss,
  -- BAKUCHIB 2667636 Start
        currency_code,
        currency_conversion_code,
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date,
  -- BAKUCHIB 2667636 End
        PERDIEM_AMOUNT, --SANAHUJA -- LOANS_ENHACEMENTS
	LEGAL_ENTITY_ID, --DKAGRAWA for LE Uptake project
	REPO_QUOTE_INDICATOR_YN) --AKP:REPO-QUOTE-START-END 6599890

      VALUES (
        l_qte_rec.id,
        l_qte_rec.qrs_code,
        l_qte_rec.qst_code,
        l_qte_rec.consolidated_qte_id,
        l_qte_rec.khr_id,
        l_qte_rec.art_id,
        l_qte_rec.qtp_code,
        l_qte_rec.trn_code,
        l_qte_rec.pop_code_end,
        l_qte_rec.pop_code_early,
        l_qte_rec.pdt_id,
        l_qte_rec.date_effective_from,
        l_qte_rec.quote_number,
        l_qte_rec.object_version_number,
        l_qte_rec.purchase_percent,
        l_qte_rec.term,
        l_qte_rec.date_restructure_start,
        l_qte_rec.date_due,
        l_qte_rec.date_approved,
        l_qte_rec.date_restructure_end,
        l_qte_rec.remaining_payments,
        l_qte_rec.rent_amount,
        l_qte_rec.yield,
        l_qte_rec.residual_amount,
        l_qte_rec.principal_paydown_amount,
        l_qte_rec.payment_frequency,
        l_qte_rec.early_termination_yn,
        l_qte_rec.partial_yn,
        l_qte_rec.preproceeds_yn,
        l_qte_rec.summary_format_yn,
        l_qte_rec.consolidated_yn,
        l_qte_rec.date_requested,
        l_qte_rec.date_proposal,
        l_qte_rec.date_effective_to,
        l_qte_rec.date_accepted,
        l_qte_rec.payment_received_yn,
        l_qte_rec.requested_by,
        l_qte_rec.approved_yn,
        l_qte_rec.accepted_yn,
        l_qte_rec.date_payment_received,
        l_qte_rec.approved_by,
        l_qte_rec.org_id,
/*
        l_qte_rec.request_id,
        l_qte_rec.program_application_id,
        l_qte_rec.program_id,
        l_qte_rec.program_update_date,
*/
        decode(FND_GLOBAL.CONC_REQUEST_ID, -1, NULL, FND_GLOBAL.CONC_REQUEST_ID),
        decode(FND_GLOBAL.PROG_APPL_ID, -1, NULL, FND_GLOBAL.PROG_APPL_ID),
        decode(FND_GLOBAL.CONC_PROGRAM_ID, -1, NULL, FND_GLOBAL.CONC_PROGRAM_ID),
        decode(FND_GLOBAL.CONC_REQUEST_ID, -1, NULL, SYSDATE),
        l_qte_rec.attribute_category,
        l_qte_rec.attribute1,
        l_qte_rec.attribute2,
        l_qte_rec.attribute3,
        l_qte_rec.attribute4,
        l_qte_rec.attribute5,
        l_qte_rec.attribute6,
        l_qte_rec.attribute7,
        l_qte_rec.attribute8,
        l_qte_rec.attribute9,
        l_qte_rec.attribute10,
        l_qte_rec.attribute11,
        l_qte_rec.attribute12,
        l_qte_rec.attribute13,
        l_qte_rec.attribute14,
        l_qte_rec.attribute15,
        l_qte_rec.created_by,
        l_qte_rec.creation_date,
        l_qte_rec.last_updated_by,
        l_qte_rec.last_update_date,
        l_qte_rec.last_update_login,
        l_qte_rec.purchase_amount,
        l_qte_rec.purchase_formula,
        l_qte_rec.asset_value,
        l_qte_rec.residual_value,
        l_qte_rec.unbilled_receivables,
        l_qte_rec.gain_loss,
  -- BAKUCHIB 2667636 Start
        l_qte_rec.currency_code,
        l_qte_rec.currency_conversion_code,
        l_qte_rec.currency_conversion_type,
        l_qte_rec.currency_conversion_rate,
        l_qte_rec.currency_conversion_date,
  -- BAKUCHIB 2667636 End
        l_qte_rec.PERDIEM_AMOUNT, --SANAHUJA -- LOANS_ENHACEMENTS
	l_qte_rec.legal_entity_id, --DKAGRAWA for LE Uptake project
	l_qte_rec.repo_quote_indicator_yn); --AKP:REPO-QUOTE-START-END 6599890
    -- Set OUT values
    x_qte_rec := l_qte_rec;
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
  --------------------------------------
  -- insert_row for:OKL_TRX_QUOTES_TL --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_quotes_tl_rec        IN okl_trx_quotes_tl_rec_type,
    x_okl_trx_quotes_tl_rec        OUT NOCOPY okl_trx_quotes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_trx_quotes_tl_rec        okl_trx_quotes_tl_rec_type := p_okl_trx_quotes_tl_rec;
    l_def_okl_trx_quotes_tl_rec    okl_trx_quotes_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ------------------------------------------
    -- Set_Attributes for:OKL_TRX_QUOTES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_quotes_tl_rec IN  okl_trx_quotes_tl_rec_type,
      x_okl_trx_quotes_tl_rec OUT NOCOPY okl_trx_quotes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_quotes_tl_rec := p_okl_trx_quotes_tl_rec;
      x_okl_trx_quotes_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_quotes_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_trx_quotes_tl_rec,           -- IN
      l_okl_trx_quotes_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_trx_quotes_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_TRX_QUOTES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_trx_quotes_tl_rec.id,
          l_okl_trx_quotes_tl_rec.language,
          l_okl_trx_quotes_tl_rec.source_lang,
          l_okl_trx_quotes_tl_rec.sfwt_flag,
          l_okl_trx_quotes_tl_rec.comments,
          l_okl_trx_quotes_tl_rec.created_by,
          l_okl_trx_quotes_tl_rec.creation_date,
          l_okl_trx_quotes_tl_rec.last_updated_by,
          l_okl_trx_quotes_tl_rec.last_update_date,
          l_okl_trx_quotes_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_trx_quotes_tl_rec := l_okl_trx_quotes_tl_rec;
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
  -------------------------------------
  -- insert_row for:OKL_TRX_QUOTES_V --
  -------------------------------------
  -- Start of comments
  -- Procedure Name  : insert_row
  -- Description     : Insert Row into OKL_TRX_QUOTE_V View
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : In set Attributes function defaulted the
  --                   currency Conversion_code to Functional Currency Code.
  --                   Also defaulted to currency code to currency Conversion
  --                   code if currency code is null.
  -- End of comments
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type,
    x_qtev_rec                     OUT NOCOPY qtev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qtev_rec                     qtev_rec_type;
    l_def_qtev_rec                 qtev_rec_type;
    l_qte_rec                      qte_rec_type;
    lx_qte_rec                     qte_rec_type;
    l_okl_trx_quotes_tl_rec        okl_trx_quotes_tl_rec_type;
    lx_okl_trx_quotes_tl_rec       okl_trx_quotes_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qtev_rec	IN qtev_rec_type
    ) RETURN qtev_rec_type IS
      l_qtev_rec	qtev_rec_type := p_qtev_rec;
    BEGIN
      l_qtev_rec.CREATION_DATE := SYSDATE;
      l_qtev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_qtev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qtev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qtev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qtev_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_QUOTES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_qtev_rec IN  qtev_rec_type,
      x_qtev_rec OUT NOCOPY qtev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qtev_rec := p_qtev_rec;
      x_qtev_rec.OBJECT_VERSION_NUMBER := 1;
      x_qtev_rec.SFWT_FLAG := 'N';

      -- Default the YN columns if value not passed
      IF p_qtev_rec.early_termination_yn IS NULL
      OR p_qtev_rec.early_termination_yn = OKC_API.G_MISS_CHAR THEN
        x_qtev_rec.early_termination_yn := 'N';
      END IF;
      IF p_qtev_rec.partial_yn IS NULL
      OR p_qtev_rec.partial_yn = OKC_API.G_MISS_CHAR THEN
        x_qtev_rec.partial_yn := 'N';
      END IF;
      IF p_qtev_rec.preproceeds_yn IS NULL
      OR p_qtev_rec.preproceeds_yn = OKC_API.G_MISS_CHAR THEN
        x_qtev_rec.preproceeds_yn := 'N';
      END IF;
      IF p_qtev_rec.summary_format_yn IS NULL
      OR p_qtev_rec.summary_format_yn = OKC_API.G_MISS_CHAR THEN
        x_qtev_rec.summary_format_yn := 'N';
      END IF;
      IF p_qtev_rec.consolidated_yn IS NULL
      OR p_qtev_rec.consolidated_yn = OKC_API.G_MISS_CHAR THEN
        x_qtev_rec.consolidated_yn := 'N';
      END IF;
      IF p_qtev_rec.approved_yn IS NULL
      OR p_qtev_rec.approved_yn = OKC_API.G_MISS_CHAR THEN
        x_qtev_rec.approved_yn := 'N';
      END IF;
      IF p_qtev_rec.accepted_yn IS NULL
      OR p_qtev_rec.accepted_yn = OKC_API.G_MISS_CHAR THEN
        x_qtev_rec.accepted_yn := 'N';
      END IF;
      IF p_qtev_rec.payment_received_yn IS NULL
      OR p_qtev_rec.payment_received_yn = OKC_API.G_MISS_CHAR THEN
        x_qtev_rec.payment_received_yn := 'N';
      END IF;

      -- Default the ORG ID if a value is not passed
      IF p_qtev_rec.org_id IS NULL
      OR p_qtev_rec.org_id = OKC_API.G_MISS_NUM THEN
        x_qtev_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      END IF;
  -- BAKUCHIB 2667636 Start
      x_qtev_rec.currency_conversion_code := OKL_AM_UTIL_PVT.get_functional_currency;

      IF p_qtev_rec.currency_code IS NULL
      OR p_qtev_rec.currency_code = OKC_API.G_MISS_CHAR THEN
        x_qtev_rec.currency_code := x_qtev_rec.currency_conversion_code;
      END IF;
  -- BAKUCHIB 2667636 End
      --DKAGRAWA for LE uptake, default the LE_id, if not passed, to contract LE_id
      IF p_qtev_rec.legal_entity_id IS NULL THEN
        x_qtev_rec.legal_entity_id := okl_legal_entity_util.get_khr_le_id(p_qtev_rec.khr_id);
      END IF;

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
    l_qtev_rec := null_out_defaults(p_qtev_rec);
    -- Set primary key value
    l_qtev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_qtev_rec,                        -- IN
      l_def_qtev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qtev_rec := fill_who_columns(l_def_qtev_rec);

    -- Added the sequence to pick the quote_number
    SELECT OKL_QTE_SEQ.NEXTVAL INTO l_def_qtev_rec.quote_number FROM DUAL;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qtev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qtev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qtev_rec, l_qte_rec);
    migrate(l_def_qtev_rec, l_okl_trx_quotes_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qte_rec,
      lx_qte_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qte_rec, l_def_qtev_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_quotes_tl_rec,
      lx_okl_trx_quotes_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_quotes_tl_rec, l_def_qtev_rec);
    -- Set OUT values
    x_qtev_rec := l_def_qtev_rec;
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
  -- PL/SQL TBL insert_row for:QTEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_tbl                     IN qtev_tbl_type,
    x_qtev_tbl                     OUT NOCOPY qtev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qtev_tbl.COUNT > 0) THEN
      i := p_qtev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qtev_rec                     => p_qtev_tbl(i),
          x_qtev_rec                     => x_qtev_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_qtev_tbl.LAST);
        i := p_qtev_tbl.NEXT(i);
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
  -----------------------------------
  -- lock_row for:OKL_TRX_QUOTES_B --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qte_rec                      IN qte_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_qte_rec IN qte_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_QUOTES_B
     WHERE ID = p_qte_rec.id
       AND OBJECT_VERSION_NUMBER = p_qte_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_qte_rec IN qte_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_QUOTES_B
    WHERE ID = p_qte_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRX_QUOTES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TRX_QUOTES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_qte_rec);
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
      OPEN lchk_csr(p_qte_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_qte_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_qte_rec.object_version_number THEN
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
  ------------------------------------
  -- lock_row for:OKL_TRX_QUOTES_TL --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_quotes_tl_rec        IN okl_trx_quotes_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_trx_quotes_tl_rec IN okl_trx_quotes_tl_rec_type) IS
    SELECT *
      FROM OKL_TRX_QUOTES_TL
     WHERE ID = p_okl_trx_quotes_tl_rec.id
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
      OPEN lock_csr(p_okl_trx_quotes_tl_rec);
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
  -----------------------------------
  -- lock_row for:OKL_TRX_QUOTES_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qte_rec                      qte_rec_type;
    l_okl_trx_quotes_tl_rec        okl_trx_quotes_tl_rec_type;
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
    migrate(p_qtev_rec, l_qte_rec);
    migrate(p_qtev_rec, l_okl_trx_quotes_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qte_rec
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
      l_okl_trx_quotes_tl_rec
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
  -- PL/SQL TBL lock_row for:QTEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_tbl                     IN qtev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qtev_tbl.COUNT > 0) THEN
      i := p_qtev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qtev_rec                     => p_qtev_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_qtev_tbl.LAST);
        i := p_qtev_tbl.NEXT(i);
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
  -------------------------------------
  -- update_row for:OKL_TRX_QUOTES_B --
  -------------------------------------
  -- Start of comments
  -- Procedure Name  : update_row
  -- Description     : Update Row into OKL_TRX_QUOTE_B table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_B table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  -- End of comments
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qte_rec                      IN qte_rec_type,
    x_qte_rec                      OUT NOCOPY qte_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qte_rec                      qte_rec_type := p_qte_rec;
    l_def_qte_rec                  qte_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    -- Start of comments
    -- Function Name   : populate_new_record
    -- Description     : Populate new record into OKL_TRX_QUOTE_B table
    -- Business Rules  :
    -- Parameters      : Record structure of OKL_TRX_QUOTE_B table
    -- Version         : 1.0
    -- History         : 18-DEC-2002 BAKUCHIB 2667636
    --                 : Added columns Currency code, currency Conversion_code
    --                   Currency conversion type, currency conversion date
    --                   currency conversion rate.
    FUNCTION populate_new_record (
      p_qte_rec	IN qte_rec_type,
      x_qte_rec	OUT NOCOPY qte_rec_type
    ) RETURN VARCHAR2 IS
      l_qte_rec                      qte_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qte_rec := p_qte_rec;
      -- Get current database values
      l_qte_rec := get_rec(p_qte_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qte_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.id := l_qte_rec.id;
      END IF;
      IF (x_qte_rec.qrs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.qrs_code := l_qte_rec.qrs_code;
      END IF;
      IF (x_qte_rec.qst_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.qst_code := l_qte_rec.qst_code;
      END IF;
      IF (x_qte_rec.consolidated_qte_id = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.consolidated_qte_id := l_qte_rec.consolidated_qte_id;
      END IF;
      IF (x_qte_rec.khr_id = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.khr_id := l_qte_rec.khr_id;
      END IF;
      IF (x_qte_rec.art_id = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.art_id := l_qte_rec.art_id;
      END IF;
      IF (x_qte_rec.qtp_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.qtp_code := l_qte_rec.qtp_code;
      END IF;
      IF (x_qte_rec.trn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.trn_code := l_qte_rec.trn_code;
      END IF;
      IF (x_qte_rec.pop_code_end = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.pop_code_end := l_qte_rec.pop_code_end;
      END IF;
      IF (x_qte_rec.pop_code_early = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.pop_code_early := l_qte_rec.pop_code_early;
      END IF;
      IF (x_qte_rec.pdt_id = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.pdt_id := l_qte_rec.pdt_id;
      END IF;
      IF (x_qte_rec.date_effective_from = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.date_effective_from := l_qte_rec.date_effective_from;
      END IF;
      IF (x_qte_rec.quote_number = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.quote_number := l_qte_rec.quote_number;
      END IF;
      IF (x_qte_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.object_version_number := l_qte_rec.object_version_number;
      END IF;
      IF (x_qte_rec.purchase_percent = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.purchase_percent := l_qte_rec.purchase_percent;
      END IF;
      IF (x_qte_rec.term = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.term := l_qte_rec.term;
      END IF;
      IF (x_qte_rec.date_restructure_start = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.date_restructure_start := l_qte_rec.date_restructure_start;
      END IF;
      IF (x_qte_rec.date_due = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.date_due := l_qte_rec.date_due;
      END IF;
      IF (x_qte_rec.date_approved = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.date_approved := l_qte_rec.date_approved;
      END IF;
      IF (x_qte_rec.date_restructure_end = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.date_restructure_end := l_qte_rec.date_restructure_end;
      END IF;
      IF (x_qte_rec.remaining_payments = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.remaining_payments := l_qte_rec.remaining_payments;
      END IF;
      IF (x_qte_rec.rent_amount = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.rent_amount := l_qte_rec.rent_amount;
      END IF;
      IF (x_qte_rec.yield = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.yield := l_qte_rec.yield;
      END IF;
      IF (x_qte_rec.residual_amount = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.residual_amount := l_qte_rec.residual_amount;
      END IF;
      IF (x_qte_rec.principal_paydown_amount = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.principal_paydown_amount := l_qte_rec.principal_paydown_amount;
      END IF;
      IF (x_qte_rec.payment_frequency = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.payment_frequency := l_qte_rec.payment_frequency;
      END IF;
      IF (x_qte_rec.early_termination_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.early_termination_yn := l_qte_rec.early_termination_yn;
      END IF;
      IF (x_qte_rec.partial_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.partial_yn := l_qte_rec.partial_yn;
      END IF;
      IF (x_qte_rec.preproceeds_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.preproceeds_yn := l_qte_rec.preproceeds_yn;
      END IF;
      IF (x_qte_rec.summary_format_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.summary_format_yn := l_qte_rec.summary_format_yn;
      END IF;
      IF (x_qte_rec.consolidated_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.consolidated_yn := l_qte_rec.consolidated_yn;
      END IF;
      IF (x_qte_rec.date_requested = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.date_requested := l_qte_rec.date_requested;
      END IF;
      IF (x_qte_rec.date_proposal = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.date_proposal := l_qte_rec.date_proposal;
      END IF;
      IF (x_qte_rec.date_effective_to = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.date_effective_to := l_qte_rec.date_effective_to;
      END IF;
      IF (x_qte_rec.date_accepted = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.date_accepted := l_qte_rec.date_accepted;
      END IF;
      IF (x_qte_rec.payment_received_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.payment_received_yn := l_qte_rec.payment_received_yn;
      END IF;
      IF (x_qte_rec.requested_by = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.requested_by := l_qte_rec.requested_by;
      END IF;
      IF (x_qte_rec.approved_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.approved_yn := l_qte_rec.approved_yn;
      END IF;
      IF (x_qte_rec.accepted_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.accepted_yn := l_qte_rec.accepted_yn;
      END IF;
      IF (x_qte_rec.date_payment_received = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.date_payment_received := l_qte_rec.date_payment_received;
      END IF;
      IF (x_qte_rec.approved_by = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.approved_by := l_qte_rec.approved_by;
      END IF;
      IF (x_qte_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.org_id := l_qte_rec.org_id;
      END IF;
      IF (x_qte_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.request_id := l_qte_rec.request_id;
      END IF;
      IF (x_qte_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.program_application_id := l_qte_rec.program_application_id;
      END IF;
      IF (x_qte_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.program_id := l_qte_rec.program_id;
      END IF;
      IF (x_qte_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.program_update_date := l_qte_rec.program_update_date;
      END IF;
      IF (x_qte_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute_category := l_qte_rec.attribute_category;
      END IF;
      IF (x_qte_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute1 := l_qte_rec.attribute1;
      END IF;
      IF (x_qte_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute2 := l_qte_rec.attribute2;
      END IF;
      IF (x_qte_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute3 := l_qte_rec.attribute3;
      END IF;
      IF (x_qte_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute4 := l_qte_rec.attribute4;
      END IF;
      IF (x_qte_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute5 := l_qte_rec.attribute5;
      END IF;
      IF (x_qte_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute6 := l_qte_rec.attribute6;
      END IF;
      IF (x_qte_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute7 := l_qte_rec.attribute7;
      END IF;
      IF (x_qte_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute8 := l_qte_rec.attribute8;
      END IF;
      IF (x_qte_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute9 := l_qte_rec.attribute9;
      END IF;
      IF (x_qte_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute10 := l_qte_rec.attribute10;
      END IF;
      IF (x_qte_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute11 := l_qte_rec.attribute11;
      END IF;
      IF (x_qte_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute12 := l_qte_rec.attribute12;
      END IF;
      IF (x_qte_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute13 := l_qte_rec.attribute13;
      END IF;
      IF (x_qte_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute14 := l_qte_rec.attribute14;
      END IF;
      IF (x_qte_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.attribute15 := l_qte_rec.attribute15;
      END IF;
      IF (x_qte_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.created_by := l_qte_rec.created_by;
      END IF;
      IF (x_qte_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.creation_date := l_qte_rec.creation_date;
      END IF;
      IF (x_qte_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.last_updated_by := l_qte_rec.last_updated_by;
      END IF;
      IF (x_qte_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.last_update_date := l_qte_rec.last_update_date;
      END IF;
      IF (x_qte_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.last_update_login := l_qte_rec.last_update_login;
      END IF;
      IF (x_qte_rec.purchase_amount = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.purchase_amount := l_qte_rec.purchase_amount;
      END IF;
      IF (x_qte_rec.purchase_formula = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.purchase_formula := l_qte_rec.purchase_formula;
      END IF;
      IF (x_qte_rec.asset_value = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.asset_value := l_qte_rec.asset_value;
      END IF;
      IF (x_qte_rec.residual_value = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.residual_value := l_qte_rec.residual_value;
      END IF;
      IF (x_qte_rec.unbilled_receivables = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.unbilled_receivables := l_qte_rec.unbilled_receivables;
      END IF;
     IF (x_qte_rec.gain_loss = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.gain_loss := l_qte_rec.gain_loss;
      END IF;
  -- BAKUCHIB 2667636 Start
     IF (x_qte_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.currency_code := l_qte_rec.currency_code;
      END IF;
      IF (x_qte_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.currency_conversion_code := l_qte_rec.currency_conversion_code;
      END IF;
      IF (x_qte_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_qte_rec.currency_conversion_type := l_qte_rec.currency_conversion_type;
      END IF;
      IF (x_qte_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.currency_conversion_rate := l_qte_rec.currency_conversion_rate;
      END IF;
      IF (x_qte_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_qte_rec.currency_conversion_date := l_qte_rec.currency_conversion_date;
      END IF;
  -- BAKUCHIB 2667636 End
      IF (x_qte_rec.PERDIEM_AMOUNT = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.PERDIEM_AMOUNT := l_qte_rec.PERDIEM_AMOUNT;
      END IF; --SANAHUJA -- LOANS_ENHACEMENTS
      --DKAGRAWA for LE uptake start
      IF (x_qte_rec.legal_entity_id = OKC_API.G_MISS_NUM)
      THEN
        x_qte_rec.legal_entity_id := l_qte_rec.legal_entity_id;
      END IF;
      --DKAGRAWA for LE uptake end
      --AKP:REPO-QUOTE-START 6599890
      IF (x_qte_rec.repo_quote_indicator_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_qte_rec.repo_quote_indicator_yn := l_qte_rec.repo_quote_indicator_yn;
      END IF;
      --AKP:REPO-QUOTE-END
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_QUOTES_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_qte_rec IN  qte_rec_type,
      x_qte_rec OUT NOCOPY qte_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qte_rec := p_qte_rec;
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
      p_qte_rec,                         -- IN
      l_qte_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qte_rec, l_def_qte_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_QUOTES_B
    SET QRS_CODE = l_def_qte_rec.qrs_code,
        QST_CODE = l_def_qte_rec.qst_code,
        CONSOLIDATED_QTE_ID = l_def_qte_rec.consolidated_qte_id,
        KHR_ID = l_def_qte_rec.khr_id,
        ART_ID = l_def_qte_rec.art_id,
        QTP_CODE = l_def_qte_rec.qtp_code,
        TRN_CODE = l_def_qte_rec.trn_code,
        POP_CODE_END = l_def_qte_rec.pop_code_end,
        POP_CODE_EARLY = l_def_qte_rec.pop_code_early,
        PDT_ID = l_def_qte_rec.pdt_id,
        DATE_EFFECTIVE_FROM = l_def_qte_rec.date_effective_from,
        QUOTE_NUMBER = l_def_qte_rec.quote_number,
        OBJECT_VERSION_NUMBER = l_def_qte_rec.object_version_number,
        PURCHASE_PERCENT = l_def_qte_rec.purchase_percent,
        TERM = l_def_qte_rec.term,
        DATE_RESTRUCTURE_START = l_def_qte_rec.date_restructure_start,
        DATE_DUE = l_def_qte_rec.date_due,
        DATE_APPROVED = l_def_qte_rec.date_approved,
        DATE_RESTRUCTURE_END = l_def_qte_rec.date_restructure_end,
        REMAINING_PAYMENTS = l_def_qte_rec.remaining_payments,
        RENT_AMOUNT = l_def_qte_rec.rent_amount,
        YIELD = l_def_qte_rec.yield,
        RESIDUAL_AMOUNT = l_def_qte_rec.residual_amount,
        PRINCIPAL_PAYDOWN_AMOUNT = l_def_qte_rec.principal_paydown_amount,
        PAYMENT_FREQUENCY = l_def_qte_rec.payment_frequency,
        EARLY_TERMINATION_YN = l_def_qte_rec.early_termination_yn,
        PARTIAL_YN = l_def_qte_rec.partial_yn,
        PREPROCEEDS_YN = l_def_qte_rec.preproceeds_yn,
        SUMMARY_FORMAT_YN = l_def_qte_rec.summary_format_yn,
        CONSOLIDATED_YN = l_def_qte_rec.consolidated_yn,
        DATE_REQUESTED = l_def_qte_rec.date_requested,
        DATE_PROPOSAL = l_def_qte_rec.date_proposal,
        DATE_EFFECTIVE_TO = l_def_qte_rec.date_effective_to,
        DATE_ACCEPTED = l_def_qte_rec.date_accepted,
        PAYMENT_RECEIVED_YN = l_def_qte_rec.payment_received_yn,
        REQUESTED_BY = l_def_qte_rec.requested_by,
        APPROVED_YN = l_def_qte_rec.approved_yn,
        ACCEPTED_YN = l_def_qte_rec.accepted_yn,
        DATE_PAYMENT_RECEIVED = l_def_qte_rec.date_payment_received,
        APPROVED_BY = l_def_qte_rec.approved_by,
        ORG_ID = l_def_qte_rec.org_id,
/*
        REQUEST_ID = l_def_qte_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_qte_rec.program_application_id,
        PROGRAM_ID = l_def_qte_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_qte_rec.program_update_date,
*/
        REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1, NULL,
                 FND_GLOBAL.CONC_REQUEST_ID),l_def_qte_rec.request_id),
        PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,
                 FND_GLOBAL.PROG_APPL_ID),l_def_qte_rec.program_application_id),
        PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,
                 FND_GLOBAL.CONC_PROGRAM_ID),l_def_qte_rec.program_id),
        PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,
                 SYSDATE),NULL,l_def_qte_rec.program_update_date,SYSDATE),
        ATTRIBUTE_CATEGORY = l_def_qte_rec.attribute_category,
        ATTRIBUTE1 = l_def_qte_rec.attribute1,
        ATTRIBUTE2 = l_def_qte_rec.attribute2,
        ATTRIBUTE3 = l_def_qte_rec.attribute3,
        ATTRIBUTE4 = l_def_qte_rec.attribute4,
        ATTRIBUTE5 = l_def_qte_rec.attribute5,
        ATTRIBUTE6 = l_def_qte_rec.attribute6,
        ATTRIBUTE7 = l_def_qte_rec.attribute7,
        ATTRIBUTE8 = l_def_qte_rec.attribute8,
        ATTRIBUTE9 = l_def_qte_rec.attribute9,
        ATTRIBUTE10 = l_def_qte_rec.attribute10,
        ATTRIBUTE11 = l_def_qte_rec.attribute11,
        ATTRIBUTE12 = l_def_qte_rec.attribute12,
        ATTRIBUTE13 = l_def_qte_rec.attribute13,
        ATTRIBUTE14 = l_def_qte_rec.attribute14,
        ATTRIBUTE15 = l_def_qte_rec.attribute15,
        CREATED_BY = l_def_qte_rec.created_by,
        CREATION_DATE = l_def_qte_rec.creation_date,
        LAST_UPDATED_BY = l_def_qte_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_qte_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_qte_rec.last_update_login,
        PURCHASE_AMOUNT = l_def_qte_rec.purchase_amount,
        PURCHASE_FORMULA = l_def_qte_rec.purchase_formula,
        ASSET_VALUE  = l_def_qte_rec.asset_value,
        RESIDUAL_VALUE  = l_def_qte_rec.residual_value,
        UNBILLED_RECEIVABLES = l_def_qte_rec.unbilled_receivables,
        GAIN_LOSS = l_def_qte_rec.gain_loss,
  -- BAKCUHIUB 2667636 Start
        CURRENCY_CODE = l_def_qte_rec.currency_code,
        CURRENCY_CONVERSION_CODE = l_def_qte_rec.currency_conversion_code,
        CURRENCY_CONVERSION_TYPE = l_def_qte_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_qte_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_qte_rec.currency_conversion_date,
  -- BAKUCHIB 2667636 End
        PERDIEM_AMOUNT = l_def_qte_rec.PERDIEM_AMOUNT, --SANAHUJA -- LOANS_ENHACEMENTS
        LEGAL_ENTITY_ID = l_def_qte_rec.legal_entity_id,--DKAGRAWA for LE uptake
        REPO_QUOTE_INDICATOR_YN = l_def_qte_rec.repo_quote_indicator_yn --AKP:REPO-QUOTE-START-END 6599890
    WHERE ID = l_def_qte_rec.id;

    x_qte_rec := l_def_qte_rec;
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
  --------------------------------------
  -- update_row for:OKL_TRX_QUOTES_TL --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_quotes_tl_rec        IN okl_trx_quotes_tl_rec_type,
    x_okl_trx_quotes_tl_rec        OUT NOCOPY okl_trx_quotes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_trx_quotes_tl_rec        okl_trx_quotes_tl_rec_type := p_okl_trx_quotes_tl_rec;
    l_def_okl_trx_quotes_tl_rec    okl_trx_quotes_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_trx_quotes_tl_rec	IN okl_trx_quotes_tl_rec_type,
      x_okl_trx_quotes_tl_rec	OUT NOCOPY okl_trx_quotes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_trx_quotes_tl_rec        okl_trx_quotes_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_quotes_tl_rec := p_okl_trx_quotes_tl_rec;
      -- Get current database values
      l_okl_trx_quotes_tl_rec := get_rec(p_okl_trx_quotes_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_trx_quotes_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_trx_quotes_tl_rec.id := l_okl_trx_quotes_tl_rec.id;
      END IF;
      IF (x_okl_trx_quotes_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_trx_quotes_tl_rec.language := l_okl_trx_quotes_tl_rec.language;
      END IF;
      IF (x_okl_trx_quotes_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_trx_quotes_tl_rec.source_lang := l_okl_trx_quotes_tl_rec.source_lang;
      END IF;
      IF (x_okl_trx_quotes_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_trx_quotes_tl_rec.sfwt_flag := l_okl_trx_quotes_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_trx_quotes_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_trx_quotes_tl_rec.comments := l_okl_trx_quotes_tl_rec.comments;
      END IF;
      IF (x_okl_trx_quotes_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_trx_quotes_tl_rec.created_by := l_okl_trx_quotes_tl_rec.created_by;
      END IF;
      IF (x_okl_trx_quotes_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_trx_quotes_tl_rec.creation_date := l_okl_trx_quotes_tl_rec.creation_date;
      END IF;
      IF (x_okl_trx_quotes_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_trx_quotes_tl_rec.last_updated_by := l_okl_trx_quotes_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_trx_quotes_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_trx_quotes_tl_rec.last_update_date := l_okl_trx_quotes_tl_rec.last_update_date;
      END IF;
      IF (x_okl_trx_quotes_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_trx_quotes_tl_rec.last_update_login := l_okl_trx_quotes_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_TRX_QUOTES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_quotes_tl_rec IN  okl_trx_quotes_tl_rec_type,
      x_okl_trx_quotes_tl_rec OUT NOCOPY okl_trx_quotes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_quotes_tl_rec := p_okl_trx_quotes_tl_rec;
      x_okl_trx_quotes_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_quotes_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_trx_quotes_tl_rec,           -- IN
      l_okl_trx_quotes_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_trx_quotes_tl_rec, l_def_okl_trx_quotes_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_QUOTES_TL
    SET COMMENTS = l_def_okl_trx_quotes_tl_rec.comments,
        SOURCE_LANG = l_def_okl_trx_quotes_tl_rec.source_lang,--Fix fro bug 3637102
        CREATED_BY = l_def_okl_trx_quotes_tl_rec.created_by,
        CREATION_DATE = l_def_okl_trx_quotes_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_trx_quotes_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_trx_quotes_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_trx_quotes_tl_rec.last_update_login
    WHERE ID = l_def_okl_trx_quotes_tl_rec.id
        AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);--Fix for bug 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_TRX_QUOTES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_trx_quotes_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_trx_quotes_tl_rec := l_def_okl_trx_quotes_tl_rec;
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
  -------------------------------------
  -- update_row for:OKL_TRX_QUOTES_V --
  -------------------------------------
  -- Start of comments
  -- Procedure Name  : update_row
  -- Description     : Update Row into OKL_TRX_QUOTE_V table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TRX_QUOTE_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636  Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  -- End of comments
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type,
    x_qtev_rec                     OUT NOCOPY qtev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qtev_rec                     qtev_rec_type := p_qtev_rec;
    l_def_qtev_rec                 qtev_rec_type;
    l_okl_trx_quotes_tl_rec        okl_trx_quotes_tl_rec_type;
    lx_okl_trx_quotes_tl_rec       okl_trx_quotes_tl_rec_type;
    l_qte_rec                      qte_rec_type;
    lx_qte_rec                     qte_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qtev_rec	IN qtev_rec_type
    ) RETURN qtev_rec_type IS
      l_qtev_rec	qtev_rec_type := p_qtev_rec;
    BEGIN
      l_qtev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qtev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qtev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qtev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    -- Start of comments
    -- Function Name   : populate_new_record
    -- Description     : Populate new record into OKL_TRX_QUOTE_V table
    -- Business Rules  :
    -- Parameters      : Record structure of OKL_TRX_QUOTE_V table
    -- Version         : 1.0
    -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
    --                 : Added columns Currency code, currency Conversion_code
    --                   Currency conversion type, currency conversion date
    --                   currency conversion rate.
    FUNCTION populate_new_record (
      p_qtev_rec	IN qtev_rec_type,
      x_qtev_rec	OUT NOCOPY qtev_rec_type
    ) RETURN VARCHAR2 IS
      l_qtev_rec                     qtev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qtev_rec := p_qtev_rec;
      -- Get current database values
      l_qtev_rec := get_rec(p_qtev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qtev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.id := l_qtev_rec.id;
      END IF;
      IF (x_qtev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.object_version_number := l_qtev_rec.object_version_number;
      END IF;
      IF (x_qtev_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.sfwt_flag := l_qtev_rec.sfwt_flag;
      END IF;
      IF (x_qtev_rec.qrs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.qrs_code := l_qtev_rec.qrs_code;
      END IF;
      IF (x_qtev_rec.qst_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.qst_code := l_qtev_rec.qst_code;
      END IF;
      IF (x_qtev_rec.qtp_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.qtp_code := l_qtev_rec.qtp_code;
      END IF;
      IF (x_qtev_rec.trn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.trn_code := l_qtev_rec.trn_code;
      END IF;
      IF (x_qtev_rec.pop_code_end = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.pop_code_end := l_qtev_rec.pop_code_end;
      END IF;
      IF (x_qtev_rec.pop_code_early = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.pop_code_early := l_qtev_rec.pop_code_early;
      END IF;
      IF (x_qtev_rec.consolidated_qte_id = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.consolidated_qte_id := l_qtev_rec.consolidated_qte_id;
      END IF;
      IF (x_qtev_rec.khr_id = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.khr_id := l_qtev_rec.khr_id;
      END IF;
      IF (x_qtev_rec.art_id = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.art_id := l_qtev_rec.art_id;
      END IF;
      IF (x_qtev_rec.pdt_id = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.pdt_id := l_qtev_rec.pdt_id;
      END IF;
      IF (x_qtev_rec.early_termination_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.early_termination_yn := l_qtev_rec.early_termination_yn;
      END IF;
      IF (x_qtev_rec.partial_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.partial_yn := l_qtev_rec.partial_yn;
      END IF;
      IF (x_qtev_rec.preproceeds_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.preproceeds_yn := l_qtev_rec.preproceeds_yn;
      END IF;
      IF (x_qtev_rec.date_requested = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.date_requested := l_qtev_rec.date_requested;
      END IF;
      IF (x_qtev_rec.date_proposal = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.date_proposal := l_qtev_rec.date_proposal;
      END IF;
      IF (x_qtev_rec.date_effective_to = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.date_effective_to := l_qtev_rec.date_effective_to;
      END IF;
      IF (x_qtev_rec.date_accepted = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.date_accepted := l_qtev_rec.date_accepted;
      END IF;
      IF (x_qtev_rec.summary_format_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.summary_format_yn := l_qtev_rec.summary_format_yn;
      END IF;
      IF (x_qtev_rec.consolidated_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.consolidated_yn := l_qtev_rec.consolidated_yn;
      END IF;
      IF (x_qtev_rec.principal_paydown_amount = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.principal_paydown_amount := l_qtev_rec.principal_paydown_amount;
      END IF;
      IF (x_qtev_rec.residual_amount = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.residual_amount := l_qtev_rec.residual_amount;
      END IF;
      IF (x_qtev_rec.yield = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.yield := l_qtev_rec.yield;
      END IF;
      IF (x_qtev_rec.rent_amount = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.rent_amount := l_qtev_rec.rent_amount;
      END IF;
      IF (x_qtev_rec.date_restructure_end = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.date_restructure_end := l_qtev_rec.date_restructure_end;
      END IF;
      IF (x_qtev_rec.date_restructure_start = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.date_restructure_start := l_qtev_rec.date_restructure_start;
      END IF;
      IF (x_qtev_rec.term = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.term := l_qtev_rec.term;
      END IF;
      IF (x_qtev_rec.purchase_percent = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.purchase_percent := l_qtev_rec.purchase_percent;
      END IF;
      IF (x_qtev_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.comments := l_qtev_rec.comments;
      END IF;
      IF (x_qtev_rec.date_due = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.date_due := l_qtev_rec.date_due;
      END IF;
      IF (x_qtev_rec.payment_frequency = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.payment_frequency := l_qtev_rec.payment_frequency;
      END IF;
      IF (x_qtev_rec.remaining_payments = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.remaining_payments := l_qtev_rec.remaining_payments;
      END IF;
      IF (x_qtev_rec.date_effective_from = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.date_effective_from := l_qtev_rec.date_effective_from;
      END IF;
      IF (x_qtev_rec.quote_number = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.quote_number := l_qtev_rec.quote_number;
      END IF;
      IF (x_qtev_rec.requested_by = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.requested_by := l_qtev_rec.requested_by;
      END IF;
      IF (x_qtev_rec.approved_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.approved_yn := l_qtev_rec.approved_yn;
      END IF;
      IF (x_qtev_rec.accepted_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.accepted_yn := l_qtev_rec.accepted_yn;
      END IF;
      IF (x_qtev_rec.payment_received_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.payment_received_yn := l_qtev_rec.payment_received_yn;
      END IF;
      IF (x_qtev_rec.date_payment_received = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.date_payment_received := l_qtev_rec.date_payment_received;
      END IF;
      IF (x_qtev_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute_category := l_qtev_rec.attribute_category;
      END IF;
      IF (x_qtev_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute1 := l_qtev_rec.attribute1;
      END IF;
      IF (x_qtev_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute2 := l_qtev_rec.attribute2;
      END IF;
      IF (x_qtev_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute3 := l_qtev_rec.attribute3;
      END IF;
      IF (x_qtev_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute4 := l_qtev_rec.attribute4;
      END IF;
      IF (x_qtev_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute5 := l_qtev_rec.attribute5;
      END IF;
      IF (x_qtev_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute6 := l_qtev_rec.attribute6;
      END IF;
      IF (x_qtev_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute7 := l_qtev_rec.attribute7;
      END IF;
      IF (x_qtev_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute8 := l_qtev_rec.attribute8;
      END IF;
      IF (x_qtev_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute9 := l_qtev_rec.attribute9;
      END IF;
      IF (x_qtev_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute10 := l_qtev_rec.attribute10;
      END IF;
      IF (x_qtev_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute11 := l_qtev_rec.attribute11;
      END IF;
      IF (x_qtev_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute12 := l_qtev_rec.attribute12;
      END IF;
      IF (x_qtev_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute13 := l_qtev_rec.attribute13;
      END IF;
      IF (x_qtev_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute14 := l_qtev_rec.attribute14;
      END IF;
      IF (x_qtev_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.attribute15 := l_qtev_rec.attribute15;
      END IF;
      IF (x_qtev_rec.date_approved = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.date_approved := l_qtev_rec.date_approved;
      END IF;
      IF (x_qtev_rec.approved_by = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.approved_by := l_qtev_rec.approved_by;
      END IF;
      IF (x_qtev_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.org_id := l_qtev_rec.org_id;
      END IF;
      IF (x_qtev_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.request_id := l_qtev_rec.request_id;
      END IF;
      IF (x_qtev_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.program_application_id := l_qtev_rec.program_application_id;
      END IF;
      IF (x_qtev_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.program_id := l_qtev_rec.program_id;
      END IF;
      IF (x_qtev_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.program_update_date := l_qtev_rec.program_update_date;
      END IF;
      IF (x_qtev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.created_by := l_qtev_rec.created_by;
      END IF;
      IF (x_qtev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.creation_date := l_qtev_rec.creation_date;
      END IF;
      IF (x_qtev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.last_updated_by := l_qtev_rec.last_updated_by;
      END IF;
      IF (x_qtev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.last_update_date := l_qtev_rec.last_update_date;
      END IF;
      IF (x_qtev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.last_update_login := l_qtev_rec.last_update_login;
      END IF;
      IF (x_qtev_rec.purchase_amount = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.purchase_amount := l_qtev_rec.purchase_amount;
      END IF;
      IF (x_qtev_rec.purchase_formula = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.purchase_formula := l_qtev_rec.purchase_formula;
      END IF;
      IF (x_qtev_rec.asset_value  = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.asset_value  := l_qtev_rec.asset_value ;
      END IF;
      IF (x_qtev_rec.residual_value = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.residual_value := l_qtev_rec.residual_value;
      END IF;
      IF (x_qtev_rec.unbilled_receivables = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.unbilled_receivables := l_qtev_rec.unbilled_receivables;
      END IF;
      IF (x_qtev_rec.gain_loss = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.gain_loss:= l_qtev_rec.gain_loss;
      END IF;
  -- BAKUCHIB 2667636 Start
     IF (x_qtev_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.currency_code := l_qtev_rec.currency_code;
      END IF;
      IF (x_qtev_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.currency_conversion_code := l_qtev_rec.currency_conversion_code;
      END IF;
      IF (x_qtev_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.currency_conversion_type := l_qtev_rec.currency_conversion_type;
      END IF;
      IF (x_qtev_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.currency_conversion_rate := l_qtev_rec.currency_conversion_rate;
      END IF;
      IF (x_qtev_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_qtev_rec.currency_conversion_date := l_qtev_rec.currency_conversion_date;
      END IF;
  -- BAKUCHIB 2667636 End
      IF (x_qtev_rec.PERDIEM_AMOUNT = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.PERDIEM_AMOUNT := l_qtev_rec.PERDIEM_AMOUNT;
      END IF;  --SANAHUJA -- LOANS_ENHACEMENTS
      --DKAGRAWA for LE uptake start
      IF (x_qtev_rec.legal_entity_id = OKC_API.G_MISS_NUM)
      THEN
        x_qtev_rec.legal_entity_id := l_qtev_rec.legal_entity_id;
      END IF;
      --DKAGRAWA for LE uptake end
      --AKP:REPO-QUOTE-START 6599890
      IF (x_qtev_rec.repo_quote_indicator_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qtev_rec.repo_quote_indicator_yn := l_qtev_rec.repo_quote_indicator_yn;
      END IF;
      --AKP:REPO-QUOTE-END

      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_QUOTES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_qtev_rec IN  qtev_rec_type,
      x_qtev_rec OUT NOCOPY qtev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qtev_rec := p_qtev_rec;
      x_qtev_rec.OBJECT_VERSION_NUMBER := NVL(x_qtev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_qtev_rec,                        -- IN
      l_qtev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qtev_rec, l_def_qtev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qtev_rec := fill_who_columns(l_def_qtev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qtev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qtev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qtev_rec, l_okl_trx_quotes_tl_rec);
    migrate(l_def_qtev_rec, l_qte_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_quotes_tl_rec,
      lx_okl_trx_quotes_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_quotes_tl_rec, l_def_qtev_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qte_rec,
      lx_qte_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qte_rec, l_def_qtev_rec);
    x_qtev_rec := l_def_qtev_rec;
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
  -- PL/SQL TBL update_row for:QTEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_tbl                     IN qtev_tbl_type,
    x_qtev_tbl                     OUT NOCOPY qtev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qtev_tbl.COUNT > 0) THEN
      i := p_qtev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qtev_rec                     => p_qtev_tbl(i),
          x_qtev_rec                     => x_qtev_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_qtev_tbl.LAST);
        i := p_qtev_tbl.NEXT(i);
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
  -------------------------------------
  -- delete_row for:OKL_TRX_QUOTES_B --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qte_rec                      IN qte_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qte_rec                      qte_rec_type:= p_qte_rec;
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
    DELETE FROM OKL_TRX_QUOTES_B
     WHERE ID = l_qte_rec.id;

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
  --------------------------------------
  -- delete_row for:OKL_TRX_QUOTES_TL --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_quotes_tl_rec        IN okl_trx_quotes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_trx_quotes_tl_rec        okl_trx_quotes_tl_rec_type:= p_okl_trx_quotes_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ------------------------------------------
    -- Set_Attributes for:OKL_TRX_QUOTES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_quotes_tl_rec IN  okl_trx_quotes_tl_rec_type,
      x_okl_trx_quotes_tl_rec OUT NOCOPY okl_trx_quotes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_quotes_tl_rec := p_okl_trx_quotes_tl_rec;
      x_okl_trx_quotes_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_trx_quotes_tl_rec,           -- IN
      l_okl_trx_quotes_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRX_QUOTES_TL
     WHERE ID = l_okl_trx_quotes_tl_rec.id;

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
  -------------------------------------
  -- delete_row for:OKL_TRX_QUOTES_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qtev_rec                     qtev_rec_type := p_qtev_rec;
    l_okl_trx_quotes_tl_rec        okl_trx_quotes_tl_rec_type;
    l_qte_rec                      qte_rec_type;
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
    migrate(l_qtev_rec, l_okl_trx_quotes_tl_rec);
    migrate(l_qtev_rec, l_qte_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_quotes_tl_rec
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
      l_qte_rec
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
  -- PL/SQL TBL delete_row for:QTEV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_tbl                     IN qtev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qtev_tbl.COUNT > 0) THEN
      i := p_qtev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qtev_rec                     => p_qtev_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_qtev_tbl.LAST);
        i := p_qtev_tbl.NEXT(i);
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
  END delete_row;
END OKL_QTE_PVT;

/
