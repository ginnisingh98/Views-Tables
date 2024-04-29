--------------------------------------------------------
--  DDL for Package Body OKL_ACN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACN_PVT" AS
/* $Header: OKLSACNB.pls 120.6 2007/08/08 12:41:32 arajagop noship $ */



----------------------------------------
  -- Developer Generated Code here --
  -- Reason : Added code so that the validation functionality is accomplished --
  ----------------------------------------

G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) :='OKC_NO_PARENT_RECORD';
G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) :='OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';
G_EXCEPTION_HALT_VALIDATION exception;

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
  -- History         : RABHUPAT 13-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_record(p_acnv_rec      IN  acnv_rec_type,
                                     x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- If transaction currency <> functional currency, then conversion columns
    -- are mandatory
    IF (p_acnv_rec.currency_code <> p_acnv_rec.currency_conversion_code) THEN
      IF (p_acnv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR OR
         p_acnv_rec.currency_conversion_type IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_type');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_acnv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM OR
         p_acnv_rec.currency_conversion_rate IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_rate');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_acnv_rec.currency_conversion_date = OKC_API.G_MISS_DATE OR
         p_acnv_rec.currency_conversion_date IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_date');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    -- Else If transaction currency = functional currency, then conversion columns
    -- should all be NULL
    ELSIF (p_acnv_rec.currency_code = p_acnv_rec.currency_conversion_code) THEN
      IF (p_acnv_rec.currency_conversion_type IS NOT NULL) OR
         (p_acnv_rec.currency_conversion_rate IS NOT NULL) OR
         (p_acnv_rec.currency_conversion_date IS NOT NULL) THEN
        --SET MESSAGE
        -- Currency conversion columns should be all null
        IF p_acnv_rec.currency_conversion_rate IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_rate');
        END IF;
        IF p_acnv_rec.currency_conversion_date IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_date');
        END IF;
        IF p_acnv_rec.currency_conversion_type IS NOT NULL THEN
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
  -- History         : RABHUPAT 13-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_code(p_acnv_rec      IN  acnv_rec_type,
                                   x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_acnv_rec.currency_code IS NULL) OR
       (p_acnv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_code');

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_acnv_rec.currency_code);
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
  -- History         : RABHUPAT 13-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_code(p_acnv_rec      IN  acnv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_acnv_rec.currency_conversion_code IS NULL) OR
       (p_acnv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_conversion_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_acnv_rec.currency_conversion_code);
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
  -- History         : RABHUPAT 13-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_type(p_acnv_rec      IN  acnv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_acnv_rec.currency_conversion_type <> OKL_API.G_MISS_CHAR AND
       p_acnv_rec.currency_conversion_type IS NOT NULL) THEN
      -- check from currency values using the generic okl_util.validate_currency_code
      l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_con_type(p_acnv_rec.currency_conversion_type);
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



  -- Start of comments
  --
  -- Procedure Name  : validate_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_id(
	x_return_status out nocopy VARCHAR2,
	p_acnv_rec		in	acnv_rec_type) is

  begin

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acnv_rec.id is null) or (p_acnv_rec.id = OKC_API.G_MISS_NUM) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary;  validation can continue
      -- with the next column
      null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  end validate_id;


  -- Start of comments
  --
  -- Procedure Name  : validate_object_version_number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_object_version_number(
	x_return_status out nocopy VARCHAR2,
	p_acnv_rec		in	acnv_rec_type) is

  begin

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acnv_rec.object_version_number is null) or (p_acnv_rec.object_version_number = OKC_API.G_MISS_NUM) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'object_version_number');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary;  validation can continue
      -- with the next column
      null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  end validate_object_version_number;


------------------------------------------------------------------------
  -- PROCEDURE validate_sfwt_flag
  -- Post-Generation Change
  ------------------------------------------------------------------------
  PROCEDURE validate_sfwt_flag(
	x_return_status OUT NOCOPY VARCHAR2,
	p_acnv_rec		IN	acnv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_acnv_rec.sfwt_flag IS NULL)
  	OR (p_acnv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
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




  -- Start of comments
  --
  -- Procedure Name  : validate_dty_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_dty_code(
	x_return_status out nocopy VARCHAR2,
	p_acnv_rec		in	acnv_rec_type) is

  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  begin

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;


    -- If value passed
    IF  p_acnv_rec.dty_code IS NOT NULL
    AND p_acnv_rec.dty_code <> OKC_API.G_MISS_CHAR THEN

      l_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_DAMAGE_TYPE'
						,p_lookup_code 	=>	p_acnv_rec.dty_code);

      IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'dty_code');

         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;

      ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;
    END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary;  validation can continue
      -- with the next column
      null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  end validate_dty_code;



  -- Start of comments
  --
  -- Procedure Name  : validate_cdn_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_cdn_code(
	x_return_status out nocopy VARCHAR2,
	p_acnv_rec		in	acnv_rec_type) is

  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acnv_rec.cdn_code is null) or (p_acnv_rec.cdn_code = OKC_API.G_MISS_CHAR) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'cdn_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;


    -- Foreign Key Validation
    l_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_ASSET_CONDITION'
						,p_lookup_code 	=>	p_acnv_rec.cdn_code);

     IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                      	  p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'cdn_code');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

    end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary;  validation can continue
      -- with the next column
      null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  end validate_cdn_code;


  -- Start of comments
  --
  -- Procedure Name  : validate_acs_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_acs_code(
	x_return_status out nocopy VARCHAR2,
	p_acnv_rec		in	acnv_rec_type) is
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acnv_rec.acs_code is null) or (p_acnv_rec.acs_code = OKC_API.G_MISS_CHAR) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'acs_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;

    -- Foreign Key Validation
    l_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_ASSET_CNDN_LINE_STATUS'
						,p_lookup_code 	=>	p_acnv_rec.acs_code);

     IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                      	  p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'acs_code');


        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary;  validation can continue
      -- with the next column
      null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  end validate_acs_code;


  -- Start of comments
  --
  -- Procedure Name  : validate_acd_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_acd_id(
	x_return_status out nocopy VARCHAR2,
	p_acnv_rec		in	acnv_rec_type) is
	l_dummy_var	VARCHAR2(1) := '?';

     -- select the ID of the parent record from the parent table
    CURSOR l_acnv_csr  IS
    select 'x'  FROM OKL_ASSET_CNDTNS
    where ID = p_acnv_rec.acd_id;

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acnv_rec.acd_id is null) or (p_acnv_rec.acd_id = OKC_API.G_MISS_NUM) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'acd_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;

     -- enforce foreign key
    OPEN  l_acnv_csr;
    FETCH l_acnv_csr INTO l_dummy_var;
    CLOSE l_acnv_csr;

    -- if l_dummy_var is still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			          p_msg_name		=> G_NO_PARENT_RECORD,
      			          p_token1		    => G_COL_NAME_TOKEN,
      			          p_token1_value	=> 'acd_id',
      			          p_token2		    => G_CHILD_TABLE_TOKEN,
                          p_token2_value	=> 'OKL_ASSET_CNDTN_LNS_V',
      			          p_token3		    => G_PARENT_TABLE_TOKEN,
      			          p_token3_value	=> 'OKL_ASSET_CNDTNS');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary;  validation can continue
      -- with the next column
      null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
-- verify that cursor was closed
    IF l_acnv_csr%ISOPEN THEN
      CLOSE l_acnv_csr;
    END IF;

  end validate_acd_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_estimated_repair_cost
  -- Description     :   Checks if input >=0
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_estimated_repair_cost(
	x_return_status out nocopy VARCHAR2,
	p_acnv_rec		in	acnv_rec_type) is

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if  (p_acnv_rec.estimated_repair_cost is not null)
    and (p_acnv_rec.estimated_repair_cost <> okc_api.g_miss_num)then
       if (p_acnv_rec.estimated_repair_cost < 0) then
         OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'estimated_repair_cost');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt further validation of this column
        raise G_EXCEPTION_HALT_VALIDATION;
      end if;
    end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary;  validation can continue
      -- with the next column
      null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  end validate_estimated_repair_cost;



-- Start of comments
  --
  -- Procedure Name  : validate_actual_repair_cost
  -- Description     :   Checks if input >=0
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_actual_repair_cost(
	x_return_status out nocopy VARCHAR2,
	p_acnv_rec		in	acnv_rec_type) is

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acnv_rec.actual_repair_cost is not null)
    and (p_acnv_rec.actual_repair_cost <> okc_api.g_miss_num)then
       if (p_acnv_rec.actual_repair_cost < 0) then
         OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'actual_repair_cost');


        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt further validation of this column
        raise G_EXCEPTION_HALT_VALIDATION;
      end if;
    end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary;  validation can continue
      -- with the next column
      null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  end validate_actual_repair_cost;



  PROCEDURE validate_org_id(
    x_return_status OUT NOCOPY VARCHAR2,
    p_acnv_rec  IN acnv_rec_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check org id validity using the generic function okl_util.check_org_id()
    l_return_status := OKL_UTIL.check_org_id (p_acnv_rec.org_id);

    IF ( l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'org_id');

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

  END validate_org_id;


-- Start of comments
  --
  -- Procedure Name  : validate_isq_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

procedure validate_isq_id(
		x_return_status OUT NOCOPY VARCHAR2,
		p_acnv_rec IN acnv_rec_type
) IS
/* -- Check here --
CURSOR l_isq_csr IS
select 'x'  FROM OKX_SRVC_REQUESTS_V
where ID = p_acnv_rec.isq_id;
*/
l_dummy_var	VARCHAR2(1) := '?';

begin
null;
/*
-- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_acnv_rec.isq_id IS NOT NULL) THEN
      OPEN  l_isq_csr;
      FETCH l_isq_csr INTO l_dummy_var;
      CLOSE l_isq_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'isq_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_ASSET_CNDTNS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKX_SRVC_REQUESTS_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
	END IF;

    EXCEPTION
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

	  -- verify that cursor was closed
      IF l_isq_csr%ISOPEN THEN
        CLOSE l_isq_csr;
      END IF; */
end validate_isq_id;


-- Start of comments
  --
  -- Procedure Name  : validate_ctp_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
procedure validate_ctp_code(
		x_return_status OUT NOCOPY VARCHAR2,
		p_acnv_rec IN acnv_rec_type
)IS
l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- If value passed
    IF  p_acnv_rec.ctp_code IS NOT NULL
    AND p_acnv_rec.ctp_code <> OKC_API.G_MISS_CHAR THEN

      -- Foreign Key Validation
      l_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_CLAIM_TYPE'
						,p_lookup_code 	=>	p_acnv_rec.ctp_code);

      IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	  p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'ctp_code');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

      ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

      END IF;
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
end validate_ctp_code;



  -- Start of comments
  --
  -- Procedure Name  : validate_pzt_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

procedure validate_pzt_id(
		x_return_status OUT NOCOPY VARCHAR2,
		p_acnv_rec IN acnv_rec_type
) IS
/* -- Check here --
CURSOR l_pzt_csr IS
select 'x'  FROM OKX_PARTS_V
where ID = p_acnv_rec.pzt_id; */

l_dummy_var	VARCHAR2(1) := '?';

begin
null;
/*
-- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_acnv_rec.pzt_id IS NOT NULL) THEN
      OPEN  l_pzt_csr;
      FETCH l_pzt_csr INTO l_dummy_var;
      CLOSE l_pzt_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'pzt_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_ASSET_CNDTNS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKX_PARTS_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
	END IF;

    EXCEPTION
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

	  -- verify that cursor was closed
      IF l_pzt_csr%ISOPEN THEN
        CLOSE l_pzt_csr;
      END IF; */
end validate_pzt_id;




  -- Start of comments
  --
  -- Procedure Name  : validate_rpc_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

procedure validate_rpc_id(
		x_return_status OUT NOCOPY VARCHAR2,
		p_acnv_rec IN acnv_rec_type
) IS
/* -- Check here --
CURSOR l_rpc_csr IS
select 'x'  FROM OKL_REPAIR_COSTS_V
where ID = p_acnv_rec.rpc_id; */

l_dummy_var	VARCHAR2(1) := '?';

begin
null;
/*
-- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_acnv_rec.rpc_id IS NOT NULL) THEN
      OPEN  l_rpc_csr;
      FETCH l_rpc_csr INTO l_dummy_var;
      CLOSE l_rpc_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'rpc_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_ASSET_CNDTNS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKL_REPAIR_COSTS_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
	END IF;

    EXCEPTION
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

	  -- verify that cursor was closed
      IF l_rpc_csr%ISOPEN THEN
        CLOSE l_rpc_csr;
      END IF; */
end validate_rpc_id;



-- Start of comments
  --
  -- Procedure Name  : validate_approved_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
procedure validate_approved_yn(
		x_return_status OUT NOCOPY VARCHAR2,
		p_acnv_rec IN acnv_rec_type
)IS
l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;


    l_return_status := OKL_UTIL.check_domain_yn(
						p_col_value 	=> p_acnv_rec.approved_yn);

    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	  p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'approved_yn');

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
end validate_approved_yn;

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
    DELETE FROM OKL_ASSET_CNDTN_LNS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_AST_CNDTN_LNS_ALL_B  B
         WHERE B.ID = T.ID
        );

    UPDATE OKL_ASSET_CNDTN_LNS_TL T SET (
        DAMAGE_DESCRIPTION,
        CLAIM_DESCRIPTION,
        RECOMMENDED_REPAIR,
        PART_NAME) = (SELECT
                                  B.DAMAGE_DESCRIPTION,
                                  B.CLAIM_DESCRIPTION,
                                  B.RECOMMENDED_REPAIR,
                                  B.PART_NAME
                                FROM OKL_ASSET_CNDTN_LNS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_ASSET_CNDTN_LNS_TL SUBB, OKL_ASSET_CNDTN_LNS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DAMAGE_DESCRIPTION <> SUBT.DAMAGE_DESCRIPTION
                      OR SUBB.CLAIM_DESCRIPTION <> SUBT.CLAIM_DESCRIPTION
                      OR SUBB.RECOMMENDED_REPAIR <> SUBT.RECOMMENDED_REPAIR
                      OR SUBB.PART_NAME <> SUBT.PART_NAME
                      OR (SUBB.DAMAGE_DESCRIPTION IS NULL AND SUBT.DAMAGE_DESCRIPTION IS NOT NULL)
                      OR (SUBB.DAMAGE_DESCRIPTION IS NOT NULL AND SUBT.DAMAGE_DESCRIPTION IS NULL)
                      OR (SUBB.CLAIM_DESCRIPTION IS NULL AND SUBT.CLAIM_DESCRIPTION IS NOT NULL)
                      OR (SUBB.CLAIM_DESCRIPTION IS NOT NULL AND SUBT.CLAIM_DESCRIPTION IS NULL)
                      OR (SUBB.RECOMMENDED_REPAIR IS NULL AND SUBT.RECOMMENDED_REPAIR IS NOT NULL)
                      OR (SUBB.RECOMMENDED_REPAIR IS NOT NULL AND SUBT.RECOMMENDED_REPAIR IS NULL)
                      OR (SUBB.PART_NAME IS NULL AND SUBT.PART_NAME IS NOT NULL)
                      OR (SUBB.PART_NAME IS NOT NULL AND SUBT.PART_NAME IS NULL)
              ));

    INSERT INTO OKL_ASSET_CNDTN_LNS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DAMAGE_DESCRIPTION,
        CLAIM_DESCRIPTION,
        RECOMMENDED_REPAIR,
        PART_NAME,
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
            B.DAMAGE_DESCRIPTION,
            B.CLAIM_DESCRIPTION,
            B.RECOMMENDED_REPAIR,
            B.PART_NAME,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_ASSET_CNDTN_LNS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_ASSET_CNDTN_LNS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ASSET_CNDTN_LNS_B
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : get_rec
  -- Description     : for: OKL_ASSET_CNDTN_LNS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 13-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments

  FUNCTION get_rec (
    p_acn_rec                      IN acn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN acn_rec_type IS
    CURSOR okl_asset_cndtn_lns_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SEQUENCE_NUMBER,
            ACD_ID,
            CTP_CODE,
            CDN_CODE,
            DTY_CODE,
            ACS_CODE,
            ISQ_ID,
            PZT_ID,
            RPC_ID,
            ESTIMATED_REPAIR_COST,
            ACTUAL_REPAIR_COST,
            OBJECT_VERSION_NUMBER,
            APPROVED_BY,
            APPROVED_YN,
            DATE_APPROVED,
            DATE_REPORTED,
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
  -- RABHUPAT - 2667636 - Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
  -- RABHUPAT - 2667636 - End
      FROM Okl_Asset_Cndtn_Lns_B
     WHERE okl_asset_cndtn_lns_b.id = p_id;
    l_okl_asset_cndtn_lns_b_pk     okl_asset_cndtn_lns_b_pk_csr%ROWTYPE;
    l_acn_rec                      acn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_asset_cndtn_lns_b_pk_csr (p_acn_rec.id);
    FETCH okl_asset_cndtn_lns_b_pk_csr INTO
              l_acn_rec.ID,
              l_acn_rec.SEQUENCE_NUMBER,
              l_acn_rec.ACD_ID,
              l_acn_rec.CTP_CODE,
              l_acn_rec.CDN_CODE,
              l_acn_rec.DTY_CODE,
              l_acn_rec.ACS_CODE,
              l_acn_rec.ISQ_ID,
              l_acn_rec.PZT_ID,
              l_acn_rec.RPC_ID,
              l_acn_rec.ESTIMATED_REPAIR_COST,
              l_acn_rec.ACTUAL_REPAIR_COST,
              l_acn_rec.OBJECT_VERSION_NUMBER,
              l_acn_rec.APPROVED_BY,
              l_acn_rec.APPROVED_YN,
              l_acn_rec.DATE_APPROVED,
              l_acn_rec.DATE_REPORTED,
              l_acn_rec.ORG_ID,
              l_acn_rec.REQUEST_ID,
              l_acn_rec.PROGRAM_APPLICATION_ID,
              l_acn_rec.PROGRAM_ID,
              l_acn_rec.PROGRAM_UPDATE_DATE,
              l_acn_rec.ATTRIBUTE_CATEGORY,
              l_acn_rec.ATTRIBUTE1,
              l_acn_rec.ATTRIBUTE2,
              l_acn_rec.ATTRIBUTE3,
              l_acn_rec.ATTRIBUTE4,
              l_acn_rec.ATTRIBUTE5,
              l_acn_rec.ATTRIBUTE6,
              l_acn_rec.ATTRIBUTE7,
              l_acn_rec.ATTRIBUTE8,
              l_acn_rec.ATTRIBUTE9,
              l_acn_rec.ATTRIBUTE10,
              l_acn_rec.ATTRIBUTE11,
              l_acn_rec.ATTRIBUTE12,
              l_acn_rec.ATTRIBUTE13,
              l_acn_rec.ATTRIBUTE14,
              l_acn_rec.ATTRIBUTE15,
              l_acn_rec.CREATED_BY,
              l_acn_rec.CREATION_DATE,
              l_acn_rec.LAST_UPDATED_BY,
              l_acn_rec.LAST_UPDATE_DATE,
              l_acn_rec.LAST_UPDATE_LOGIN,
  -- RABHUPAT - 2667636 - Start
              l_acn_rec.CURRENCY_CODE,
              l_acn_rec.CURRENCY_CONVERSION_CODE,
              l_acn_rec.CURRENCY_CONVERSION_TYPE,
              l_acn_rec.CURRENCY_CONVERSION_RATE,
              l_acn_rec.CURRENCY_CONVERSION_DATE;
  -- RABHUPAT - 2667636 - End
    x_no_data_found := okl_asset_cndtn_lns_b_pk_csr%NOTFOUND;
    CLOSE okl_asset_cndtn_lns_b_pk_csr;
    RETURN(l_acn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_acn_rec                      IN acn_rec_type
  ) RETURN acn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_acn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ASSET_CNDTN_LNS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_asset_cndtn_lns_tl_rec   IN OklAssetCndtnLnsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklAssetCndtnLnsTlRecType IS
    CURSOR okl_asset_cndtn_lns_tl_pk_csr (p_id                 IN NUMBER,
                                          p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DAMAGE_DESCRIPTION,
            CLAIM_DESCRIPTION,
            RECOMMENDED_REPAIR,
            PART_NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Asset_Cndtn_Lns_Tl
     WHERE okl_asset_cndtn_lns_tl.id = p_id
       AND okl_asset_cndtn_lns_tl.language = p_language;
    l_okl_asset_cndtn_lns_tl_pk    okl_asset_cndtn_lns_tl_pk_csr%ROWTYPE;
    l_okl_asset_cndtn_lns_tl_rec   OklAssetCndtnLnsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_asset_cndtn_lns_tl_pk_csr (p_okl_asset_cndtn_lns_tl_rec.id,
                                        p_okl_asset_cndtn_lns_tl_rec.language);
    FETCH okl_asset_cndtn_lns_tl_pk_csr INTO
              l_okl_asset_cndtn_lns_tl_rec.ID,
              l_okl_asset_cndtn_lns_tl_rec.LANGUAGE,
              l_okl_asset_cndtn_lns_tl_rec.SOURCE_LANG,
              l_okl_asset_cndtn_lns_tl_rec.SFWT_FLAG,
              l_okl_asset_cndtn_lns_tl_rec.DAMAGE_DESCRIPTION,
              l_okl_asset_cndtn_lns_tl_rec.CLAIM_DESCRIPTION,
              l_okl_asset_cndtn_lns_tl_rec.RECOMMENDED_REPAIR,
              l_okl_asset_cndtn_lns_tl_rec.PART_NAME,
              l_okl_asset_cndtn_lns_tl_rec.CREATED_BY,
              l_okl_asset_cndtn_lns_tl_rec.CREATION_DATE,
              l_okl_asset_cndtn_lns_tl_rec.LAST_UPDATED_BY,
              l_okl_asset_cndtn_lns_tl_rec.LAST_UPDATE_DATE,
              l_okl_asset_cndtn_lns_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_asset_cndtn_lns_tl_pk_csr%NOTFOUND;
    CLOSE okl_asset_cndtn_lns_tl_pk_csr;
    RETURN(l_okl_asset_cndtn_lns_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_asset_cndtn_lns_tl_rec   IN OklAssetCndtnLnsTlRecType
  ) RETURN OklAssetCndtnLnsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_asset_cndtn_lns_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ASSET_CNDTN_LNS_V
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : get_rec
  -- Description     : for: OKL_ASSET_CNDTN_LNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 13-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION get_rec (
    p_acnv_rec                     IN acnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN acnv_rec_type IS
    CURSOR okl_acnv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CTP_CODE,
            DTY_CODE,
            CDN_CODE,
            ACS_CODE,
            ISQ_ID,
            PZT_ID,
            ACD_ID,
            RPC_ID,
            SEQUENCE_NUMBER,
            DAMAGE_DESCRIPTION,
            CLAIM_DESCRIPTION,
            ESTIMATED_REPAIR_COST,
            ACTUAL_REPAIR_COST,
            APPROVED_BY,
            APPROVED_YN,
            DATE_APPROVED,
            DATE_REPORTED,
            RECOMMENDED_REPAIR,
            PART_NAME,
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
            LAST_UPDATE_LOGIN,
  -- RABHUPAT - 2667636 - Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
  -- RABHUPAT - 2667636 - End
      FROM Okl_Asset_Cndtn_Lns_V
     WHERE okl_asset_cndtn_lns_v.id = p_id;
    l_okl_acnv_pk                  okl_acnv_pk_csr%ROWTYPE;
    l_acnv_rec                     acnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_acnv_pk_csr (p_acnv_rec.id);
    FETCH okl_acnv_pk_csr INTO
              l_acnv_rec.ID,
              l_acnv_rec.OBJECT_VERSION_NUMBER,
              l_acnv_rec.SFWT_FLAG,
              l_acnv_rec.CTP_CODE,
              l_acnv_rec.DTY_CODE,
              l_acnv_rec.CDN_CODE,
              l_acnv_rec.ACS_CODE,
              l_acnv_rec.ISQ_ID,
              l_acnv_rec.PZT_ID,
              l_acnv_rec.ACD_ID,
              l_acnv_rec.RPC_ID,
              l_acnv_rec.SEQUENCE_NUMBER,
              l_acnv_rec.DAMAGE_DESCRIPTION,
              l_acnv_rec.CLAIM_DESCRIPTION,
              l_acnv_rec.ESTIMATED_REPAIR_COST,
              l_acnv_rec.ACTUAL_REPAIR_COST,
              l_acnv_rec.APPROVED_BY,
              l_acnv_rec.APPROVED_YN,
              l_acnv_rec.DATE_APPROVED,
              l_acnv_rec.DATE_REPORTED,
              l_acnv_rec.RECOMMENDED_REPAIR,
              l_acnv_rec.PART_NAME,
              l_acnv_rec.ATTRIBUTE_CATEGORY,
              l_acnv_rec.ATTRIBUTE1,
              l_acnv_rec.ATTRIBUTE2,
              l_acnv_rec.ATTRIBUTE3,
              l_acnv_rec.ATTRIBUTE4,
              l_acnv_rec.ATTRIBUTE5,
              l_acnv_rec.ATTRIBUTE6,
              l_acnv_rec.ATTRIBUTE7,
              l_acnv_rec.ATTRIBUTE8,
              l_acnv_rec.ATTRIBUTE9,
              l_acnv_rec.ATTRIBUTE10,
              l_acnv_rec.ATTRIBUTE11,
              l_acnv_rec.ATTRIBUTE12,
              l_acnv_rec.ATTRIBUTE13,
              l_acnv_rec.ATTRIBUTE14,
              l_acnv_rec.ATTRIBUTE15,
              l_acnv_rec.ORG_ID,
              l_acnv_rec.REQUEST_ID,
              l_acnv_rec.PROGRAM_APPLICATION_ID,
              l_acnv_rec.PROGRAM_ID,
              l_acnv_rec.PROGRAM_UPDATE_DATE,
              l_acnv_rec.CREATED_BY,
              l_acnv_rec.CREATION_DATE,
              l_acnv_rec.LAST_UPDATED_BY,
              l_acnv_rec.LAST_UPDATE_DATE,
              l_acnv_rec.LAST_UPDATE_LOGIN,
  -- RABHUPAT - 2667636 - Start
              l_acnv_rec.CURRENCY_CODE,
              l_acnv_rec.CURRENCY_CONVERSION_CODE,
              l_acnv_rec.CURRENCY_CONVERSION_TYPE,
              l_acnv_rec.CURRENCY_CONVERSION_RATE,
              l_acnv_rec.CURRENCY_CONVERSION_DATE;
  -- RABHUPAT - 2667636 - End
    x_no_data_found := okl_acnv_pk_csr%NOTFOUND;
    CLOSE okl_acnv_pk_csr;
    RETURN(l_acnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_acnv_rec                     IN acnv_rec_type
  ) RETURN acnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_acnv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_ASSET_CNDTN_LNS_V --
  -----------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : null_out_defaults
  -- Description     : for: OKL_ASSET_CNDTN_LNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 13-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION null_out_defaults (
    p_acnv_rec	IN acnv_rec_type
  ) RETURN acnv_rec_type IS
    l_acnv_rec	acnv_rec_type := p_acnv_rec;
  BEGIN
    IF (l_acnv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.object_version_number := NULL;
    END IF;
    IF (l_acnv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_acnv_rec.ctp_code = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.ctp_code := NULL;
    END IF;
    IF (l_acnv_rec.dty_code = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.dty_code := NULL;
    END IF;
    IF (l_acnv_rec.cdn_code = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.cdn_code := NULL;
    END IF;
    IF (l_acnv_rec.acs_code = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.acs_code := NULL;
    END IF;
    IF (l_acnv_rec.isq_id = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.isq_id := NULL;
    END IF;
    IF (l_acnv_rec.pzt_id = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.pzt_id := NULL;
    END IF;
    IF (l_acnv_rec.acd_id = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.acd_id := NULL;
    END IF;
    IF (l_acnv_rec.rpc_id = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.rpc_id := NULL;
    END IF;
    IF (l_acnv_rec.sequence_number = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.sequence_number := NULL;
    END IF;
    IF (l_acnv_rec.damage_description = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.damage_description := NULL;
    END IF;
    IF (l_acnv_rec.claim_description = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.claim_description := NULL;
    END IF;
    IF (l_acnv_rec.estimated_repair_cost = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.estimated_repair_cost := NULL;
    END IF;
    IF (l_acnv_rec.actual_repair_cost = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.actual_repair_cost := NULL;
    END IF;
    IF (l_acnv_rec.approved_by = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.approved_by := NULL;
    END IF;
    IF (l_acnv_rec.approved_yn = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.approved_yn := NULL;
    END IF;
    IF (l_acnv_rec.date_approved = OKC_API.G_MISS_DATE) THEN
      l_acnv_rec.date_approved := NULL;
    END IF;
    IF (l_acnv_rec.date_reported = OKC_API.G_MISS_DATE) THEN
      l_acnv_rec.date_reported := NULL;
    END IF;
    IF (l_acnv_rec.recommended_repair = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.recommended_repair := NULL;
    END IF;
    IF (l_acnv_rec.part_name = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.part_name := NULL;
    END IF;
    IF (l_acnv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute_category := NULL;
    END IF;
    IF (l_acnv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute1 := NULL;
    END IF;
    IF (l_acnv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute2 := NULL;
    END IF;
    IF (l_acnv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute3 := NULL;
    END IF;
    IF (l_acnv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute4 := NULL;
    END IF;
    IF (l_acnv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute5 := NULL;
    END IF;
    IF (l_acnv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute6 := NULL;
    END IF;
    IF (l_acnv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute7 := NULL;
    END IF;
    IF (l_acnv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute8 := NULL;
    END IF;
    IF (l_acnv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute9 := NULL;
    END IF;
    IF (l_acnv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute10 := NULL;
    END IF;
    IF (l_acnv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute11 := NULL;
    END IF;
    IF (l_acnv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute12 := NULL;
    END IF;
    IF (l_acnv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute13 := NULL;
    END IF;
    IF (l_acnv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute14 := NULL;
    END IF;
    IF (l_acnv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute15 := NULL;
    END IF;
    IF (l_acnv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.org_id := NULL;
    END IF;
/*
    IF (l_acnv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.request_id := NULL;
    END IF;
    IF (l_acnv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.program_application_id := NULL;
    END IF;
    IF (l_acnv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.program_id := NULL;
    END IF;
    IF (l_acnv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_acnv_rec.program_update_date := NULL;
    END IF;
*/
    IF (l_acnv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.created_by := NULL;
    END IF;
    IF (l_acnv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_acnv_rec.creation_date := NULL;
    END IF;
    IF (l_acnv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_acnv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_acnv_rec.last_update_date := NULL;
    END IF;
    IF (l_acnv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.last_update_login := NULL;
    END IF;
  -- RABHUPAT - 2667636 -Start
    IF (l_acnv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.currency_code := NULL;
    END IF;
    IF (l_acnv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.currency_conversion_code := NULL;
    END IF;
    IF (l_acnv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_acnv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_acnv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
      l_acnv_rec.currency_conversion_date := NULL;
    END IF;
  -- RABHUPAT - 2667636 -End
    RETURN(l_acnv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_ASSET_CNDTN_LNS_V --
  ------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_attributes
  -- Description     : for:OKL_ASSET_CNDTN_LNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : Modified by : Ravi Munjuluri
  --                 : RABHUPAT 13-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments

  FUNCTION Validate_Attributes (
    p_acnv_rec IN  acnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  begin
    -- call each column-level validation
    validate_id(x_return_status => l_return_status,
                p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

     validate_object_version_number(x_return_status => l_return_status,
                 				   p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;


     validate_sfwt_flag(x_return_status => l_return_status,
                 				   p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;



    validate_dty_code(x_return_status => l_return_status,
                 	   p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_cdn_code(x_return_status => l_return_status,
                 	   p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;


    validate_acs_code(x_return_status => l_return_status,
                 	   p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_acd_id(x_return_status => l_return_status,
                          p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;


    validate_estimated_repair_cost(x_return_status => l_return_status,
                 		    p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_actual_repair_cost(x_return_status => l_return_status,
                 		   p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_org_id(x_return_status => l_return_status,
               	     p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_isq_id(x_return_status => l_return_status,
               	     p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_ctp_code(x_return_status => l_return_status,
               	     p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_pzt_id(x_return_status => l_return_status,
               	     p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_rpc_id(x_return_status => l_return_status,
                    p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_approved_yn(x_return_status => l_return_status,
                    p_acnv_rec      => p_acnv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

  -- RABHUPAT - 2667636 - Start
    validate_currency_code(p_acnv_rec      => p_acnv_rec,
                           x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_code(p_acnv_rec      => p_acnv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_type(p_acnv_rec      => p_acnv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- RABHUPAT - 2667636 - End

  RETURN(x_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_ASSET_CNDTN_LNS_V --
  -----------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : Validate_Record
  -- Description     : for:OKL_ASSET_CNDTN_LNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 13-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments

  FUNCTION Validate_Record (
    p_acnv_rec IN acnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
  -- RABHUPAT - 2667636 - Start
    -- Validate Currency conversion Code,type,rate and Date

    validate_currency_record(p_acnv_rec      => p_acnv_rec,
                                 x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- RABHUPAT - 2667636 - End
    RETURN (x_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate
  -- Description     : from _V to _B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 13-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments

  PROCEDURE migrate (
    p_from	IN acnv_rec_type,
    p_to	IN OUT NOCOPY acn_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.acd_id := p_from.acd_id;
    p_to.ctp_code := p_from.ctp_code;
    p_to.cdn_code := p_from.cdn_code;
    p_to.dty_code := p_from.dty_code;
    p_to.acs_code := p_from.acs_code;
    p_to.isq_id := p_from.isq_id;
    p_to.pzt_id := p_from.pzt_id;
    p_to.rpc_id := p_from.rpc_id;
    p_to.estimated_repair_cost := p_from.estimated_repair_cost;
    p_to.actual_repair_cost := p_from.actual_repair_cost;
    p_to.object_version_number := p_from.object_version_number;
    p_to.approved_by := p_from.approved_by;
    p_to.approved_yn := p_from.approved_yn;
    p_to.date_approved := p_from.date_approved;
    p_to.date_reported := p_from.date_reported;
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
  -- RABHUPAT - 2667636 - Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- RABHUPAT - 2667636 - End
  END migrate;

  -- Start of comments
  --
  -- Procedure Name  : Migrate
  -- Description     : from _B to _V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 13-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE migrate (
    p_from	IN acn_rec_type,
    p_to	IN OUT NOCOPY acnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.acd_id := p_from.acd_id;
    p_to.ctp_code := p_from.ctp_code;
    p_to.cdn_code := p_from.cdn_code;
    p_to.dty_code := p_from.dty_code;
    p_to.acs_code := p_from.acs_code;
    p_to.isq_id := p_from.isq_id;
    p_to.pzt_id := p_from.pzt_id;
    p_to.rpc_id := p_from.rpc_id;
    p_to.estimated_repair_cost := p_from.estimated_repair_cost;
    p_to.actual_repair_cost := p_from.actual_repair_cost;
    p_to.object_version_number := p_from.object_version_number;
    p_to.approved_by := p_from.approved_by;
    p_to.approved_yn := p_from.approved_yn;
    p_to.date_approved := p_from.date_approved;
    p_to.date_reported := p_from.date_reported;
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
  -- RABHUPAT - 2667636 - Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- RABHUPAT - 2667636 - End
  END migrate;
  PROCEDURE migrate (
    p_from	IN acnv_rec_type,
    p_to	IN OUT NOCOPY OklAssetCndtnLnsTlRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.damage_description := p_from.damage_description;
    p_to.claim_description := p_from.claim_description;
    p_to.recommended_repair := p_from.recommended_repair;
    p_to.part_name := p_from.part_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN OklAssetCndtnLnsTlRecType,
    p_to	IN OUT NOCOPY acnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.damage_description := p_from.damage_description;
    p_to.claim_description := p_from.claim_description;
    p_to.recommended_repair := p_from.recommended_repair;
    p_to.part_name := p_from.part_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_ASSET_CNDTN_LNS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec                     acnv_rec_type := p_acnv_rec;
    l_acn_rec                      acn_rec_type;
    l_okl_asset_cndtn_lns_tl_rec   OklAssetCndtnLnsTlRecType;
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
    l_return_status := Validate_Attributes(l_acnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_acnv_rec);
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
  -- PL/SQL TBL validate_row for:ACNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type) IS

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
    IF (p_acnv_tbl.COUNT > 0) THEN
      i := p_acnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acnv_rec                     => p_acnv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_acnv_tbl.LAST);
        i := p_acnv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKL_ASSET_CNDTN_LNS_B --
  ------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : for OKL_ASSET_CNDTN_LNS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 13-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acn_rec                      IN acn_rec_type,
    x_acn_rec                      OUT NOCOPY acn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acn_rec                      acn_rec_type := p_acn_rec;
    l_def_acn_rec                  acn_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTN_LNS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_acn_rec IN  acn_rec_type,
      x_acn_rec OUT NOCOPY acn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acn_rec := p_acn_rec;
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
      p_acn_rec,                         -- IN
      l_acn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_ASSET_CNDTN_LNS_B(
        id,
        sequence_number,
        acd_id,
        ctp_code,
        cdn_code,
        dty_code,
        acs_code,
        isq_id,
        pzt_id,
        rpc_id,
        estimated_repair_cost,
        actual_repair_cost,
        object_version_number,
        approved_by,
        approved_yn,
        date_approved,
        date_reported,
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
  -- RABHUPAT - 2667636 - Start
        currency_code,
        currency_conversion_code,
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date)
  -- RABHUPAT - 2667636 - End
      VALUES (
        l_acn_rec.id,
        l_acn_rec.sequence_number,
        l_acn_rec.acd_id,
        l_acn_rec.ctp_code,
        l_acn_rec.cdn_code,
        l_acn_rec.dty_code,
        l_acn_rec.acs_code,
        l_acn_rec.isq_id,
        l_acn_rec.pzt_id,
        l_acn_rec.rpc_id,
        l_acn_rec.estimated_repair_cost,
        l_acn_rec.actual_repair_cost,
        l_acn_rec.object_version_number,
        l_acn_rec.approved_by,
        l_acn_rec.approved_yn,
        l_acn_rec.date_approved,
        l_acn_rec.date_reported,
        l_acn_rec.org_id,
-- Begin Post Gen Changes
/*
        l_acn_rec.request_id,
        l_acn_rec.program_application_id,
        l_acn_rec.program_id,
        l_acn_rec.program_update_date,
*/
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
        decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
        decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
-- End Post Gen Changes
        l_acn_rec.attribute_category,
        l_acn_rec.attribute1,
        l_acn_rec.attribute2,
        l_acn_rec.attribute3,
        l_acn_rec.attribute4,
        l_acn_rec.attribute5,
        l_acn_rec.attribute6,
        l_acn_rec.attribute7,
        l_acn_rec.attribute8,
        l_acn_rec.attribute9,
        l_acn_rec.attribute10,
        l_acn_rec.attribute11,
        l_acn_rec.attribute12,
        l_acn_rec.attribute13,
        l_acn_rec.attribute14,
        l_acn_rec.attribute15,
        l_acn_rec.created_by,
        l_acn_rec.creation_date,
        l_acn_rec.last_updated_by,
        l_acn_rec.last_update_date,
        l_acn_rec.last_update_login,
  -- RABHUPAT - 2667636 - Start
        l_acn_rec.currency_code,
        l_acn_rec.currency_conversion_code,
        l_acn_rec.currency_conversion_type,
        l_acn_rec.currency_conversion_rate,
        l_acn_rec.currency_conversion_date);
  -- RABHUPAT - 2667636 - End
    -- Set OUT values
    x_acn_rec := l_acn_rec;
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
  -------------------------------------------
  -- insert_row for:OKL_ASSET_CNDTN_LNS_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_asset_cndtn_lns_tl_rec   IN OklAssetCndtnLnsTlRecType,
    x_okl_asset_cndtn_lns_tl_rec   OUT NOCOPY OklAssetCndtnLnsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_asset_cndtn_lns_tl_rec   OklAssetCndtnLnsTlRecType := p_okl_asset_cndtn_lns_tl_rec;
    ldefoklassetcndtnlnstlrec      OklAssetCndtnLnsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTN_LNS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_asset_cndtn_lns_tl_rec IN  OklAssetCndtnLnsTlRecType,
      x_okl_asset_cndtn_lns_tl_rec OUT NOCOPY OklAssetCndtnLnsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_asset_cndtn_lns_tl_rec := p_okl_asset_cndtn_lns_tl_rec;
      x_okl_asset_cndtn_lns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_asset_cndtn_lns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_asset_cndtn_lns_tl_rec,      -- IN
      l_okl_asset_cndtn_lns_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_asset_cndtn_lns_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_ASSET_CNDTN_LNS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          damage_description,
          claim_description,
          recommended_repair,
          part_name,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_asset_cndtn_lns_tl_rec.id,
          l_okl_asset_cndtn_lns_tl_rec.language,
          l_okl_asset_cndtn_lns_tl_rec.source_lang,
          l_okl_asset_cndtn_lns_tl_rec.sfwt_flag,
          l_okl_asset_cndtn_lns_tl_rec.damage_description,
          l_okl_asset_cndtn_lns_tl_rec.claim_description,
          l_okl_asset_cndtn_lns_tl_rec.recommended_repair,
          l_okl_asset_cndtn_lns_tl_rec.part_name,
          l_okl_asset_cndtn_lns_tl_rec.created_by,
          l_okl_asset_cndtn_lns_tl_rec.creation_date,
          l_okl_asset_cndtn_lns_tl_rec.last_updated_by,
          l_okl_asset_cndtn_lns_tl_rec.last_update_date,
          l_okl_asset_cndtn_lns_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_asset_cndtn_lns_tl_rec := l_okl_asset_cndtn_lns_tl_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_ASSET_CNDTN_LNS_V --
  ------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : for OKL_ASSET_CNDTN_LNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 13-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec                     acnv_rec_type;
    l_def_acnv_rec                 acnv_rec_type;
    l_acn_rec                      acn_rec_type;
    lx_acn_rec                     acn_rec_type;
    l_okl_asset_cndtn_lns_tl_rec   OklAssetCndtnLnsTlRecType;
    lx_okl_asset_cndtn_lns_tl_rec  OklAssetCndtnLnsTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_acnv_rec	IN acnv_rec_type
    ) RETURN acnv_rec_type IS
      l_acnv_rec	acnv_rec_type := p_acnv_rec;
    BEGIN
      l_acnv_rec.CREATION_DATE := SYSDATE;
      l_acnv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_acnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_acnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_acnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_acnv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTN_LNS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_acnv_rec IN  acnv_rec_type,
      x_acnv_rec OUT NOCOPY acnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acnv_rec := p_acnv_rec;
      x_acnv_rec.OBJECT_VERSION_NUMBER := 1;
      x_acnv_rec.SFWT_FLAG := 'N';

      -- Default the YN columns if value not passed
      IF p_acnv_rec.approved_yn IS NULL
      OR p_acnv_rec.approved_yn = OKC_API.G_MISS_CHAR THEN
        x_acnv_rec.approved_yn := 'N';
      END IF;

      -- Default the ORG ID if a value is not passed
      IF p_acnv_rec.org_id IS NULL
      OR p_acnv_rec.org_id = OKC_API.G_MISS_NUM THEN
	x_acnv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      END IF;

  -- RABHUPAT - 2667636 - Start
      x_acnv_rec.currency_conversion_code := OKL_AM_UTIL_PVT.get_functional_currency;

      IF p_acnv_rec.currency_code IS NULL
      OR p_acnv_rec.currency_code = OKC_API.G_MISS_CHAR THEN
        x_acnv_rec.currency_code := x_acnv_rec.currency_conversion_code;
      END IF;
  -- RABHUPAT- 2667636 - End

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
    l_acnv_rec := null_out_defaults(p_acnv_rec);
    -- Set primary key value
    l_acnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_acnv_rec,                        -- IN
      l_def_acnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_acnv_rec := fill_who_columns(l_def_acnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_acnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
        --gkadarka Fixes for 3559327
    l_def_acnv_rec.currency_conversion_type := NULL;
    l_def_acnv_rec.currency_conversion_rate := NULL;
    l_def_acnv_rec.currency_conversion_date := NULL;
    --gkdarka
    l_return_status := Validate_Record(l_def_acnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_acnv_rec, l_acn_rec);
    migrate(l_def_acnv_rec, l_okl_asset_cndtn_lns_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_acn_rec,
      lx_acn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_acn_rec, l_def_acnv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_asset_cndtn_lns_tl_rec,
      lx_okl_asset_cndtn_lns_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_asset_cndtn_lns_tl_rec, l_def_acnv_rec);
    -- Set OUT values
    x_acnv_rec := l_def_acnv_rec;
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
  -- PL/SQL TBL insert_row for:ACNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type) IS

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
    IF (p_acnv_tbl.COUNT > 0) THEN
      i := p_acnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acnv_rec                     => p_acnv_tbl(i),
          x_acnv_rec                     => x_acnv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_acnv_tbl.LAST);
        i := p_acnv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKL_ASSET_CNDTN_LNS_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acn_rec                      IN acn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_acn_rec IN acn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ASSET_CNDTN_LNS_B
     WHERE ID = p_acn_rec.id
       AND OBJECT_VERSION_NUMBER = p_acn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_acn_rec IN acn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ASSET_CNDTN_LNS_B
    WHERE ID = p_acn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_ASSET_CNDTN_LNS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_ASSET_CNDTN_LNS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_acn_rec);
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
      OPEN lchk_csr(p_acn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_acn_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_acn_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKL_ASSET_CNDTN_LNS_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_asset_cndtn_lns_tl_rec   IN OklAssetCndtnLnsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_asset_cndtn_lns_tl_rec IN OklAssetCndtnLnsTlRecType) IS
    SELECT *
      FROM OKL_ASSET_CNDTN_LNS_TL
     WHERE ID = p_okl_asset_cndtn_lns_tl_rec.id
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
      OPEN lock_csr(p_okl_asset_cndtn_lns_tl_rec);
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
  ----------------------------------------
  -- lock_row for:OKL_ASSET_CNDTN_LNS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acn_rec                      acn_rec_type;
    l_okl_asset_cndtn_lns_tl_rec   OklAssetCndtnLnsTlRecType;
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
    migrate(p_acnv_rec, l_acn_rec);
    migrate(p_acnv_rec, l_okl_asset_cndtn_lns_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_acn_rec
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
      l_okl_asset_cndtn_lns_tl_rec
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
  -- PL/SQL TBL lock_row for:ACNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type) IS

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
    IF (p_acnv_tbl.COUNT > 0) THEN
      i := p_acnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acnv_rec                     => p_acnv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_acnv_tbl.LAST);
        i := p_acnv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKL_ASSET_CNDTN_LNS_B --
  ------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : for OKL_ASSET_CNDTN_LNS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 13-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acn_rec                      IN acn_rec_type,
    x_acn_rec                      OUT NOCOPY acn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acn_rec                      acn_rec_type := p_acn_rec;
    l_def_acn_rec                  acn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_acn_rec	IN acn_rec_type,
      x_acn_rec	OUT NOCOPY acn_rec_type
    ) RETURN VARCHAR2 IS
      l_acn_rec                      acn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acn_rec := p_acn_rec;
      -- Get current database values
      l_acn_rec := get_rec(p_acn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_acn_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.id := l_acn_rec.id;
      END IF;
      IF (x_acn_rec.sequence_number = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.sequence_number := l_acn_rec.sequence_number;
      END IF;
      IF (x_acn_rec.acd_id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.acd_id := l_acn_rec.acd_id;
      END IF;
      IF (x_acn_rec.ctp_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.ctp_code := l_acn_rec.ctp_code;
      END IF;
      IF (x_acn_rec.cdn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.cdn_code := l_acn_rec.cdn_code;
      END IF;
      IF (x_acn_rec.dty_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.dty_code := l_acn_rec.dty_code;
      END IF;
      IF (x_acn_rec.acs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.acs_code := l_acn_rec.acs_code;
      END IF;
      IF (x_acn_rec.isq_id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.isq_id := l_acn_rec.isq_id;
      END IF;
      IF (x_acn_rec.pzt_id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.pzt_id := l_acn_rec.pzt_id;
      END IF;
      IF (x_acn_rec.rpc_id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.rpc_id := l_acn_rec.rpc_id;
      END IF;
      IF (x_acn_rec.estimated_repair_cost = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.estimated_repair_cost := l_acn_rec.estimated_repair_cost;
      END IF;
      IF (x_acn_rec.actual_repair_cost = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.actual_repair_cost := l_acn_rec.actual_repair_cost;
      END IF;
      IF (x_acn_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.object_version_number := l_acn_rec.object_version_number;
      END IF;
      IF (x_acn_rec.approved_by = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.approved_by := l_acn_rec.approved_by;
      END IF;
      IF (x_acn_rec.approved_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.approved_yn := l_acn_rec.approved_yn;
      END IF;
      IF (x_acn_rec.date_approved = OKC_API.G_MISS_DATE)
      THEN
        x_acn_rec.date_approved := l_acn_rec.date_approved;
      END IF;
      IF (x_acn_rec.date_reported = OKC_API.G_MISS_DATE)
      THEN
        x_acn_rec.date_reported := l_acn_rec.date_reported;
      END IF;
      IF (x_acn_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.org_id := l_acn_rec.org_id;
      END IF;
      IF (x_acn_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.request_id := l_acn_rec.request_id;
      END IF;
      IF (x_acn_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.program_application_id := l_acn_rec.program_application_id;
      END IF;
      IF (x_acn_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.program_id := l_acn_rec.program_id;
      END IF;
      IF (x_acn_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_acn_rec.program_update_date := l_acn_rec.program_update_date;
      END IF;
      IF (x_acn_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute_category := l_acn_rec.attribute_category;
      END IF;
      IF (x_acn_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute1 := l_acn_rec.attribute1;
      END IF;
      IF (x_acn_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute2 := l_acn_rec.attribute2;
      END IF;
      IF (x_acn_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute3 := l_acn_rec.attribute3;
      END IF;
      IF (x_acn_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute4 := l_acn_rec.attribute4;
      END IF;
      IF (x_acn_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute5 := l_acn_rec.attribute5;
      END IF;
      IF (x_acn_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute6 := l_acn_rec.attribute6;
      END IF;
      IF (x_acn_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute7 := l_acn_rec.attribute7;
      END IF;
      IF (x_acn_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute8 := l_acn_rec.attribute8;
      END IF;
      IF (x_acn_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute9 := l_acn_rec.attribute9;
      END IF;
      IF (x_acn_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute10 := l_acn_rec.attribute10;
      END IF;
      IF (x_acn_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute11 := l_acn_rec.attribute11;
      END IF;
      IF (x_acn_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute12 := l_acn_rec.attribute12;
      END IF;
      IF (x_acn_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute13 := l_acn_rec.attribute13;
      END IF;
      IF (x_acn_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute14 := l_acn_rec.attribute14;
      END IF;
      IF (x_acn_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute15 := l_acn_rec.attribute15;
      END IF;
      IF (x_acn_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.created_by := l_acn_rec.created_by;
      END IF;
      IF (x_acn_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_acn_rec.creation_date := l_acn_rec.creation_date;
      END IF;
      IF (x_acn_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.last_updated_by := l_acn_rec.last_updated_by;
      END IF;
      IF (x_acn_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_acn_rec.last_update_date := l_acn_rec.last_update_date;
      END IF;
      IF (x_acn_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.last_update_login := l_acn_rec.last_update_login;
      END IF;
  -- RABHUPAT - 2667636 - Start
     IF (x_acn_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.currency_code := l_acn_rec.currency_code;
      END IF;
      IF (x_acn_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.currency_conversion_code := l_acn_rec.currency_conversion_code;
      END IF;
      IF (x_acn_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.currency_conversion_type := l_acn_rec.currency_conversion_type;
      END IF;
      IF (x_acn_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.currency_conversion_rate := l_acn_rec.currency_conversion_rate;
      END IF;
      IF (x_acn_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_acn_rec.currency_conversion_date := l_acn_rec.currency_conversion_date;
      END IF;
  -- RABHUPAT - 2667636 - End
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTN_LNS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_acn_rec IN  acn_rec_type,
      x_acn_rec OUT NOCOPY acn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acn_rec := p_acn_rec;
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
      p_acn_rec,                         -- IN
      l_acn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_acn_rec, l_def_acn_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ASSET_CNDTN_LNS_B
    SET SEQUENCE_NUMBER = l_def_acn_rec.sequence_number,
        ACD_ID = l_def_acn_rec.acd_id,
        CTP_CODE = l_def_acn_rec.ctp_code,
        CDN_CODE = l_def_acn_rec.cdn_code,
        DTY_CODE = l_def_acn_rec.dty_code,
        ACS_CODE = l_def_acn_rec.acs_code,
        ISQ_ID = l_def_acn_rec.isq_id,
        PZT_ID = l_def_acn_rec.pzt_id,
        RPC_ID = l_def_acn_rec.rpc_id,
        ESTIMATED_REPAIR_COST = l_def_acn_rec.estimated_repair_cost,
        ACTUAL_REPAIR_COST = l_def_acn_rec.actual_repair_cost,
        OBJECT_VERSION_NUMBER = l_def_acn_rec.object_version_number,
        APPROVED_BY = l_def_acn_rec.approved_by,
        APPROVED_YN = l_def_acn_rec.approved_yn,
        DATE_APPROVED = l_def_acn_rec.date_approved,
        DATE_REPORTED = l_def_acn_rec.date_reported,
        ORG_ID = l_def_acn_rec.org_id,
        REQUEST_ID = l_def_acn_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_acn_rec.program_application_id,
        PROGRAM_ID = l_def_acn_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_acn_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_acn_rec.attribute_category,
        ATTRIBUTE1 = l_def_acn_rec.attribute1,
        ATTRIBUTE2 = l_def_acn_rec.attribute2,
        ATTRIBUTE3 = l_def_acn_rec.attribute3,
        ATTRIBUTE4 = l_def_acn_rec.attribute4,
        ATTRIBUTE5 = l_def_acn_rec.attribute5,
        ATTRIBUTE6 = l_def_acn_rec.attribute6,
        ATTRIBUTE7 = l_def_acn_rec.attribute7,
        ATTRIBUTE8 = l_def_acn_rec.attribute8,
        ATTRIBUTE9 = l_def_acn_rec.attribute9,
        ATTRIBUTE10 = l_def_acn_rec.attribute10,
        ATTRIBUTE11 = l_def_acn_rec.attribute11,
        ATTRIBUTE12 = l_def_acn_rec.attribute12,
        ATTRIBUTE13 = l_def_acn_rec.attribute13,
        ATTRIBUTE14 = l_def_acn_rec.attribute14,
        ATTRIBUTE15 = l_def_acn_rec.attribute15,
        CREATED_BY = l_def_acn_rec.created_by,
        CREATION_DATE = l_def_acn_rec.creation_date,
        LAST_UPDATED_BY = l_def_acn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_acn_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_acn_rec.last_update_login,
  -- RABHUPAT - 2667636 - Start
        CURRENCY_CODE = l_def_acn_rec.currency_code,
        CURRENCY_CONVERSION_CODE = l_def_acn_rec.currency_conversion_code,
        CURRENCY_CONVERSION_TYPE = l_def_acn_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_acn_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_acn_rec.currency_conversion_date
  -- RABHUPAT - 2667636 - End
    WHERE ID = l_def_acn_rec.id;

    x_acn_rec := l_def_acn_rec;
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
  -------------------------------------------
  -- update_row for:OKL_ASSET_CNDTN_LNS_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_asset_cndtn_lns_tl_rec   IN OklAssetCndtnLnsTlRecType,
    x_okl_asset_cndtn_lns_tl_rec   OUT NOCOPY OklAssetCndtnLnsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_asset_cndtn_lns_tl_rec   OklAssetCndtnLnsTlRecType := p_okl_asset_cndtn_lns_tl_rec;
    ldefoklassetcndtnlnstlrec      OklAssetCndtnLnsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_asset_cndtn_lns_tl_rec	IN OklAssetCndtnLnsTlRecType,
      x_okl_asset_cndtn_lns_tl_rec	OUT NOCOPY OklAssetCndtnLnsTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_asset_cndtn_lns_tl_rec   OklAssetCndtnLnsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_asset_cndtn_lns_tl_rec := p_okl_asset_cndtn_lns_tl_rec;
      -- Get current database values
      l_okl_asset_cndtn_lns_tl_rec := get_rec(p_okl_asset_cndtn_lns_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.id := l_okl_asset_cndtn_lns_tl_rec.id;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.language := l_okl_asset_cndtn_lns_tl_rec.language;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.source_lang := l_okl_asset_cndtn_lns_tl_rec.source_lang;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.sfwt_flag := l_okl_asset_cndtn_lns_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.damage_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.damage_description := l_okl_asset_cndtn_lns_tl_rec.damage_description;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.claim_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.claim_description := l_okl_asset_cndtn_lns_tl_rec.claim_description;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.recommended_repair = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.recommended_repair := l_okl_asset_cndtn_lns_tl_rec.recommended_repair;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.part_name = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.part_name := l_okl_asset_cndtn_lns_tl_rec.part_name;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.created_by := l_okl_asset_cndtn_lns_tl_rec.created_by;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.creation_date := l_okl_asset_cndtn_lns_tl_rec.creation_date;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.last_updated_by := l_okl_asset_cndtn_lns_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.last_update_date := l_okl_asset_cndtn_lns_tl_rec.last_update_date;
      END IF;
      IF (x_okl_asset_cndtn_lns_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_asset_cndtn_lns_tl_rec.last_update_login := l_okl_asset_cndtn_lns_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTN_LNS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_asset_cndtn_lns_tl_rec IN  OklAssetCndtnLnsTlRecType,
      x_okl_asset_cndtn_lns_tl_rec OUT NOCOPY OklAssetCndtnLnsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_asset_cndtn_lns_tl_rec := p_okl_asset_cndtn_lns_tl_rec;
      x_okl_asset_cndtn_lns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_asset_cndtn_lns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_asset_cndtn_lns_tl_rec,      -- IN
      l_okl_asset_cndtn_lns_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_asset_cndtn_lns_tl_rec, ldefoklassetcndtnlnstlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ASSET_CNDTN_LNS_TL
    SET DAMAGE_DESCRIPTION = ldefoklassetcndtnlnstlrec.damage_description,
        CLAIM_DESCRIPTION = ldefoklassetcndtnlnstlrec.claim_description,
        SOURCE_LANG = ldefoklassetcndtnlnstlrec.source_lang, --Added for fix 3637102
        RECOMMENDED_REPAIR = ldefoklassetcndtnlnstlrec.recommended_repair,
        PART_NAME = ldefoklassetcndtnlnstlrec.part_name,
        CREATED_BY = ldefoklassetcndtnlnstlrec.created_by,
        CREATION_DATE = ldefoklassetcndtnlnstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklassetcndtnlnstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklassetcndtnlnstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklassetcndtnlnstlrec.last_update_login
    WHERE ID = ldefoklassetcndtnlnstlrec.id
      AND  USERENV('LANG') in (SOURCE_LANG,LANGUAGE); --Fix for 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_ASSET_CNDTN_LNS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklassetcndtnlnstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_asset_cndtn_lns_tl_rec := ldefoklassetcndtnlnstlrec;
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
  ------------------------------------------
  -- update_row for:OKL_ASSET_CNDTN_LNS_V --
  ------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : for OKL_ASSET_CNDTN_LNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 13-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec                     acnv_rec_type := p_acnv_rec;
    l_def_acnv_rec                 acnv_rec_type;
    l_okl_asset_cndtn_lns_tl_rec   OklAssetCndtnLnsTlRecType;
    lx_okl_asset_cndtn_lns_tl_rec  OklAssetCndtnLnsTlRecType;
    l_acn_rec                      acn_rec_type;
    lx_acn_rec                     acn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_acnv_rec	IN acnv_rec_type
    ) RETURN acnv_rec_type IS
      l_acnv_rec	acnv_rec_type := p_acnv_rec;
    BEGIN
      l_acnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_acnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_acnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_acnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_acnv_rec	IN acnv_rec_type,
      x_acnv_rec	OUT NOCOPY acnv_rec_type
    ) RETURN VARCHAR2 IS
      l_acnv_rec                     acnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acnv_rec := p_acnv_rec;
      -- Get current database values
      l_acnv_rec := get_rec(p_acnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_acnv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.id := l_acnv_rec.id;
      END IF;
      IF (x_acnv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.object_version_number := l_acnv_rec.object_version_number;
      END IF;
      IF (x_acnv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.sfwt_flag := l_acnv_rec.sfwt_flag;
      END IF;
      IF (x_acnv_rec.ctp_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.ctp_code := l_acnv_rec.ctp_code;
      END IF;
      IF (x_acnv_rec.dty_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.dty_code := l_acnv_rec.dty_code;
      END IF;
      IF (x_acnv_rec.cdn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.cdn_code := l_acnv_rec.cdn_code;
      END IF;
      IF (x_acnv_rec.acs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.acs_code := l_acnv_rec.acs_code;
      END IF;
      IF (x_acnv_rec.isq_id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.isq_id := l_acnv_rec.isq_id;
      END IF;
      IF (x_acnv_rec.pzt_id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.pzt_id := l_acnv_rec.pzt_id;
      END IF;
      IF (x_acnv_rec.acd_id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.acd_id := l_acnv_rec.acd_id;
      END IF;
      IF (x_acnv_rec.rpc_id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.rpc_id := l_acnv_rec.rpc_id;
      END IF;
      IF (x_acnv_rec.sequence_number = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.sequence_number := l_acnv_rec.sequence_number;
      END IF;
      IF (x_acnv_rec.damage_description = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.damage_description := l_acnv_rec.damage_description;
      END IF;
      IF (x_acnv_rec.claim_description = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.claim_description := l_acnv_rec.claim_description;
      END IF;
      IF (x_acnv_rec.estimated_repair_cost = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.estimated_repair_cost := l_acnv_rec.estimated_repair_cost;
      END IF;
      IF (x_acnv_rec.actual_repair_cost = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.actual_repair_cost := l_acnv_rec.actual_repair_cost;
      END IF;
      IF (x_acnv_rec.approved_by = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.approved_by := l_acnv_rec.approved_by;
      END IF;
      IF (x_acnv_rec.approved_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.approved_yn := l_acnv_rec.approved_yn;
      END IF;
      IF (x_acnv_rec.date_approved = OKC_API.G_MISS_DATE)
      THEN
        x_acnv_rec.date_approved := l_acnv_rec.date_approved;
      END IF;
      IF (x_acnv_rec.date_reported = OKC_API.G_MISS_DATE)
      THEN
        x_acnv_rec.date_reported := l_acnv_rec.date_reported;
      END IF;
      IF (x_acnv_rec.recommended_repair = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.recommended_repair := l_acnv_rec.recommended_repair;
      END IF;
      IF (x_acnv_rec.part_name = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.part_name := l_acnv_rec.part_name;
      END IF;
      IF (x_acnv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute_category := l_acnv_rec.attribute_category;
      END IF;
      IF (x_acnv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute1 := l_acnv_rec.attribute1;
      END IF;
      IF (x_acnv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute2 := l_acnv_rec.attribute2;
      END IF;
      IF (x_acnv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute3 := l_acnv_rec.attribute3;
      END IF;
      IF (x_acnv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute4 := l_acnv_rec.attribute4;
      END IF;
      IF (x_acnv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute5 := l_acnv_rec.attribute5;
      END IF;
      IF (x_acnv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute6 := l_acnv_rec.attribute6;
      END IF;
      IF (x_acnv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute7 := l_acnv_rec.attribute7;
      END IF;
      IF (x_acnv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute8 := l_acnv_rec.attribute8;
      END IF;
      IF (x_acnv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute9 := l_acnv_rec.attribute9;
      END IF;
      IF (x_acnv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute10 := l_acnv_rec.attribute10;
      END IF;
      IF (x_acnv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute11 := l_acnv_rec.attribute11;
      END IF;
      IF (x_acnv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute12 := l_acnv_rec.attribute12;
      END IF;
      IF (x_acnv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute13 := l_acnv_rec.attribute13;
      END IF;
      IF (x_acnv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute14 := l_acnv_rec.attribute14;
      END IF;
      IF (x_acnv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute15 := l_acnv_rec.attribute15;
      END IF;
      IF (x_acnv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.org_id := l_acnv_rec.org_id;
      END IF;
      IF (x_acnv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.request_id := l_acnv_rec.request_id;
      END IF;
      IF (x_acnv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.program_application_id := l_acnv_rec.program_application_id;
      END IF;
      IF (x_acnv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.program_id := l_acnv_rec.program_id;
      END IF;
      IF (x_acnv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_acnv_rec.program_update_date := l_acnv_rec.program_update_date;
      END IF;
      IF (x_acnv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.created_by := l_acnv_rec.created_by;
      END IF;
      IF (x_acnv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_acnv_rec.creation_date := l_acnv_rec.creation_date;
      END IF;
      IF (x_acnv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.last_updated_by := l_acnv_rec.last_updated_by;
      END IF;
      IF (x_acnv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_acnv_rec.last_update_date := l_acnv_rec.last_update_date;
      END IF;
      IF (x_acnv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.last_update_login := l_acnv_rec.last_update_login;
      END IF;
  -- RABHUPAT - 2667636 - Start
     IF (x_acnv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.currency_code := l_acnv_rec.currency_code;
      END IF;
      IF (x_acnv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.currency_conversion_code := l_acnv_rec.currency_conversion_code;
      END IF;
      IF (x_acnv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.currency_conversion_type := l_acnv_rec.currency_conversion_type;
      END IF;
      IF (x_acnv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.currency_conversion_rate := l_acnv_rec.currency_conversion_rate;
      END IF;
      IF (x_acnv_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_acnv_rec.currency_conversion_date := l_acnv_rec.currency_conversion_date;
      END IF;
  -- RABHUPAT - 2667636 - End
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTN_LNS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_acnv_rec IN  acnv_rec_type,
      x_acnv_rec OUT NOCOPY acnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acnv_rec := p_acnv_rec;
      x_acnv_rec.OBJECT_VERSION_NUMBER := NVL(x_acnv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_acnv_rec,                        -- IN
      l_acnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_acnv_rec, l_def_acnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_acnv_rec := fill_who_columns(l_def_acnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_acnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
        --gkadarka Fixes for 3559327
    l_def_acnv_rec.currency_conversion_type := NULL;
    l_def_acnv_rec.currency_conversion_rate := NULL;
    l_def_acnv_rec.currency_conversion_date := NULL;
    --gkdarka
    l_return_status := Validate_Record(l_def_acnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_acnv_rec, l_okl_asset_cndtn_lns_tl_rec);
    migrate(l_def_acnv_rec, l_acn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_asset_cndtn_lns_tl_rec,
      lx_okl_asset_cndtn_lns_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_asset_cndtn_lns_tl_rec, l_def_acnv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_acn_rec,
      lx_acn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_acn_rec, l_def_acnv_rec);
    x_acnv_rec := l_def_acnv_rec;
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
  -- PL/SQL TBL update_row for:ACNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type) IS

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
    IF (p_acnv_tbl.COUNT > 0) THEN
      i := p_acnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acnv_rec                     => p_acnv_tbl(i),
          x_acnv_rec                     => x_acnv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_acnv_tbl.LAST);
        i := p_acnv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKL_ASSET_CNDTN_LNS_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acn_rec                      IN acn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acn_rec                      acn_rec_type:= p_acn_rec;
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
    DELETE FROM OKL_ASSET_CNDTN_LNS_B
     WHERE ID = l_acn_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKL_ASSET_CNDTN_LNS_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_asset_cndtn_lns_tl_rec   IN OklAssetCndtnLnsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_asset_cndtn_lns_tl_rec   OklAssetCndtnLnsTlRecType:= p_okl_asset_cndtn_lns_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTN_LNS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_asset_cndtn_lns_tl_rec IN  OklAssetCndtnLnsTlRecType,
      x_okl_asset_cndtn_lns_tl_rec OUT NOCOPY OklAssetCndtnLnsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_asset_cndtn_lns_tl_rec := p_okl_asset_cndtn_lns_tl_rec;
      x_okl_asset_cndtn_lns_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_asset_cndtn_lns_tl_rec,      -- IN
      l_okl_asset_cndtn_lns_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_ASSET_CNDTN_LNS_TL
     WHERE ID = l_okl_asset_cndtn_lns_tl_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_ASSET_CNDTN_LNS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec                     acnv_rec_type := p_acnv_rec;
    l_okl_asset_cndtn_lns_tl_rec   OklAssetCndtnLnsTlRecType;
    l_acn_rec                      acn_rec_type;
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
    migrate(l_acnv_rec, l_okl_asset_cndtn_lns_tl_rec);
    migrate(l_acnv_rec, l_acn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_asset_cndtn_lns_tl_rec
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
      l_acn_rec
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
  -- PL/SQL TBL delete_row for:ACNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type) IS

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
    IF (p_acnv_tbl.COUNT > 0) THEN
      i := p_acnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acnv_rec                     => p_acnv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_acnv_tbl.LAST);
        i := p_acnv_tbl.NEXT(i);
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
END OKL_ACN_PVT;

/
