--------------------------------------------------------
--  DDL for Package Body OKL_ART_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ART_PVT" AS
/* $Header: OKLSARTB.pls 120.9 2007/11/09 22:10:42 djanaswa noship $ */

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
  -- History         : RABHUPAT 16-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_record(p_artv_rec      IN  artv_rec_type,
                                     x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- If transaction currency <> functional currency, then conversion columns
    -- are mandatory
    IF (p_artv_rec.currency_code <> p_artv_rec.currency_conversion_code) THEN
      IF (p_artv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR OR
         p_artv_rec.currency_conversion_type IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_type');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_artv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM OR
         p_artv_rec.currency_conversion_rate IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_rate');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_artv_rec.currency_conversion_date = OKC_API.G_MISS_DATE OR
         p_artv_rec.currency_conversion_date IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_date');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    -- Else If transaction currency = functional currency, then conversion columns
    -- should all be NULL
    ELSIF (p_artv_rec.currency_code = p_artv_rec.currency_conversion_code) THEN
      IF (p_artv_rec.currency_conversion_type IS NOT NULL) OR
         (p_artv_rec.currency_conversion_rate IS NOT NULL) OR
         (p_artv_rec.currency_conversion_date IS NOT NULL) THEN
        --SET MESSAGE
        -- Currency conversion columns should be all null
        IF p_artv_rec.currency_conversion_rate IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_rate');
        END IF;
        IF p_artv_rec.currency_conversion_date IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_date');
        END IF;
        IF p_artv_rec.currency_conversion_type IS NOT NULL THEN
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
  -- History         : RABHUPAT 16-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_code(p_artv_rec      IN  artv_rec_type,
                                   x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_artv_rec.currency_code IS NULL) OR
       (p_artv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_code');

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_artv_rec.currency_code);
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
  -- History         : RABHUPAT 16-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_code(p_artv_rec      IN  artv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_artv_rec.currency_conversion_code IS NULL) OR
       (p_artv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_conversion_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_artv_rec.currency_conversion_code);
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
  -- History         : RABHUPAT 16-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_type(p_artv_rec      IN  artv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_artv_rec.currency_conversion_type <> OKL_API.G_MISS_CHAR AND
       p_artv_rec.currency_conversion_type IS NOT NULL) THEN
      -- check from currency values using the generic okl_util.validate_currency_code
      l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_con_type(p_artv_rec.currency_conversion_type);
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
	p_artv_rec		in	artv_rec_type) is

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_artv_rec.id is null) or (p_artv_rec.id = OKC_API.G_MISS_NUM) then
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
	p_artv_rec		in	artv_rec_type) is

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_artv_rec.object_version_number is null) or (p_artv_rec.object_version_number = OKC_API.G_MISS_NUM) then
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
	p_artv_rec		IN	artv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_artv_rec.sfwt_flag IS NULL)
	OR (p_artv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
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
  -- Procedure Name  : validate_kle_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_kle_id(
	x_return_status out nocopy VARCHAR2,
	p_artv_rec		in	artv_rec_type) is
	l_dummy_var	VARCHAR2(1) := '?';
 	--- Check here  ---
	CURSOR l_kle_csr IS
	select 'x' from OKL_K_LINES_V
	where ID = p_artv_rec.kle_id;

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_artv_rec.kle_id is null) or (p_artv_rec.kle_id = OKC_API.G_MISS_NUM) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'kle_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;
-- enforce foreign key
    OPEN  l_kle_csr;
      FETCH l_kle_csr INTO l_dummy_var;
    CLOSE l_kle_csr;

    -- if l_dummy_var is still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			          p_msg_name		=> G_NO_PARENT_RECORD);


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
    IF l_kle_csr%ISOPEN THEN
      CLOSE l_kle_csr;
    END IF;

  end validate_kle_id;

-- Start of comments
  --
  -- Procedure Name  : validate_legal_entity_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_legal_entity_id(
	x_return_status out nocopy VARCHAR2,
	p_artv_rec		in	artv_rec_type) is
	l_dummy_var	VARCHAR2(1) := '?';

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_artv_rec.legal_entity_id is null) or (p_artv_rec.legal_entity_id = OKC_API.G_MISS_NUM) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'legal_entity_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      l_dummy_var := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_artv_rec.legal_entity_id);
        IF  (l_dummy_var <> 1) THEN
          OKL_API.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'LEGAL_ENTITY_ID');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary;  validation can continue
      -- with the next column
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_legal_entity_id;


  -- Start of comments
  --
  -- Procedure Name  : validate_ars_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_ars_code(
	x_return_status out nocopy VARCHAR2,
	p_artv_rec		in	artv_rec_type) is
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_artv_rec.ars_code is null) or (p_artv_rec.ars_code = OKC_API.G_MISS_CHAR) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'ars_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;
    l_return_status := OKL_UTIL.check_lookup_code(
					 p_lookup_type 	=>	'OKL_ASSET_RETURN_STATUS'
					,p_lookup_code 	=>	p_artv_rec.ars_code);

     IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                      	    p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'ars_code');


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

  end validate_ars_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_art1_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  procedure validate_art1_code(
	x_return_status out nocopy VARCHAR2,
	p_artv_rec		in	artv_rec_type) is
  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_artv_rec.art1_code is null) or (p_artv_rec.art1_code = OKC_API.G_MISS_CHAR) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'art1_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;

     l_return_status := OKL_UTIL.check_lookup_code(
					 p_lookup_type 	=>	'OKL_ASSET_RETURN_TYPE'
					,p_lookup_code 	=>	p_artv_rec.art1_code);

     IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                      	    p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'art1_code');

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

  end validate_art1_code;


  -- Start of comments
  --
  -- Procedure Name  : validate_relocate_asset_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments


 PROCEDURE validate_relocate_asset_yn (
 x_return_status OUT NOCOPY VARCHAR2,
 p_artv_rec  IN artv_rec_type ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
 -- intialize return status
 x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic okl_util.check_domain_yn
    l_return_status := OKL_UTIL.check_domain_yn(p_artv_rec.relocate_asset_yn);

    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_invalid_value,
                           p_token1       => g_col_name_token,
                           p_token1_value => 'relocate_asset_yn');

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

  END validate_relocate_asset_yn;





PROCEDURE validate_org_id(
 x_return_status OUT NOCOPY VARCHAR2,
 p_artv_rec  IN artv_rec_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check org id validity using the generic function okl_util.check_org_id()
    l_return_status := OKL_UTIL.check_org_id (p_artv_rec.org_id);

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


  --  Foreign Key Validation

-- Start of comments
  --
  -- Procedure Name  : validate_sec_dep_trx_ap_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

procedure validate_sec_dep_trx_ap_id(
        x_return_status OUT NOCOPY VARCHAR2,
		p_artv_rec		in	artv_rec_type
)IS
CURSOR l_sdt_csr IS
select 'x' from OKL_TRX_AP_INVOICES_V
where ID = p_artv_rec.security_dep_trx_ap_id;

l_dummy_var	VARCHAR2(1) := '?';

begin
-- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_artv_rec.security_dep_trx_ap_id IS NOT NULL) THEN
      OPEN  l_sdt_csr;
      FETCH l_sdt_csr INTO l_dummy_var;
      CLOSE l_sdt_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'security_dep_trx_ap_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_ASSET_RETURNS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKL_TRX_AP_INVOICES_V');

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
      IF l_sdt_csr%ISOPEN THEN
        CLOSE l_sdt_csr;
      END IF;
end validate_sec_dep_trx_ap_id;

-- Start of comments
  --
  -- Procedure Name  : validate_iso_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

procedure validate_iso_id(
        x_return_status OUT NOCOPY VARCHAR2,
		p_artv_rec		in	artv_rec_type
)
IS
/*CURSOR l_iso_csr IS
select 'x' from OKX_SELL_ORDERS_V
where ID = p_artv_rec.iso_id; */
l_dummy_var	VARCHAR2(1) := '?';

begin
NULL;
/*
-- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_artv_rec.iso_id IS NOT NULL) THEN
      OPEN  l_iso_csr;
      FETCH l_iso_csr INTO l_dummy_var;
      CLOSE l_iso_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'iso_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_ASSET_RETURNS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKX_SELL_ORDERS_V');

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
      IF l_iso_csr%ISOPEN THEN
        CLOSE l_iso_csr;
      END IF;
*/
end validate_iso_id;

-- Start of comments
  --
  -- Procedure Name  : validate_rna_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

procedure validate_rna_id(
        x_return_status OUT NOCOPY VARCHAR2,
		p_artv_rec		in	artv_rec_type
)
IS

CURSOR l_rna_csr IS
select 'x' from OKX_VENDORS_V
where ID1 = p_artv_rec.rna_id;

l_dummy_var	VARCHAR2(1) := '?';
begin

-- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_artv_rec.rna_id IS NOT NULL) THEN
      OPEN  l_rna_csr;
      FETCH l_rna_csr INTO l_dummy_var;
      CLOSE l_rna_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'rna_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_ASSET_RETURNS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKX_VENDORS_V');

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
      IF l_rna_csr%ISOPEN THEN
        CLOSE l_rna_csr;
      END IF;

end validate_rna_id;

-- Start of comments
  --
  -- Procedure Name  : validate_rmr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

procedure validate_rmr_id(
        x_return_status OUT NOCOPY VARCHAR2,
		p_artv_rec		in	artv_rec_type
)
IS

CURSOR l_rmr_csr IS
select 'x' from OKL_AM_REMARKET_TEAMS_UV
where ORIG_SYSTEM_ID = p_artv_rec.rmr_id;



l_dummy_var	VARCHAR2(1) := '?';
begin

-- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_artv_rec.rmr_id IS NOT NULL) THEN
      OPEN  l_rmr_csr;
      FETCH l_rmr_csr INTO l_dummy_var;
      CLOSE l_rmr_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'rmr_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_ASSET_RETURNS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKL_AM_REMARKET_TEAMS_UV');

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
      IF l_rmr_csr%ISOPEN THEN
        CLOSE l_rmr_csr;
      END IF;

end validate_rmr_id;

-- Start of comments
  --
  -- Procedure Name  : validate_imr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

procedure validate_imr_id(
        x_return_status OUT NOCOPY VARCHAR2,
		p_artv_rec		in	artv_rec_type
)

IS

CURSOR l_imr_csr IS
select 'x' from OKX_SYSTEM_ITEMS_V
where ID1 = p_artv_rec.imr_id;

l_dummy_var	VARCHAR2(1) := '?';
begin


-- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_artv_rec.imr_id IS NOT NULL) THEN
      OPEN  l_imr_csr;
      FETCH l_imr_csr INTO l_dummy_var;
      CLOSE l_imr_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'imr_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_ASSET_RETURNS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKX_SYSTEM_ITEMS_V');

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
      IF l_imr_csr%ISOPEN THEN
        CLOSE l_imr_csr;
      END IF;

end validate_imr_id;


  -- Start of comments
  --
  -- Procedure Name  : validate_asset_relocated_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_asset_relocated_yn(
	x_return_status OUT NOCOPY VARCHAR2,
	p_artv_rec		in	artv_rec_type) is


    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic okl_util.check_domain_yn
    l_return_status := OKL_UTIL.check_domain_yn(p_artv_rec.asset_relocated_yn);

    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_invalid_value,
                           p_token1       => g_col_name_token,
                           p_token1_value => 'asset_relocated_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary;  validation can continue
      -- with the next column
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_asset_relocated_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_commmercially_reas_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments


 PROCEDURE validate_commmercially_reas_yn (
 x_return_status OUT NOCOPY VARCHAR2,
 p_artv_rec  IN artv_rec_type ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
 -- intialize return status
 x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic okl_util.check_domain_yn
    l_return_status := OKL_UTIL.check_domain_yn(p_artv_rec.commmercially_reas_sale_yn);

    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_invalid_value,
                           p_token1       => g_col_name_token,
                           p_token1_value => 'commmercially_reas_sale_yn');

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

  END validate_commmercially_reas_yn;


  -- Start of comments
  --
  -- Procedure Name  : validate_voluntary_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments


 PROCEDURE validate_voluntary_yn (
 x_return_status OUT NOCOPY VARCHAR2,
 p_artv_rec  IN artv_rec_type ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
 -- intialize return status
 x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic okl_util.check_domain_yn
    l_return_status := OKL_UTIL.check_domain_yn(p_artv_rec.voluntary_yn);

    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_invalid_value,
                           p_token1       => g_col_name_token,
                           p_token1_value => 'voluntary_yn');

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

  END validate_voluntary_yn;



  -- Start of comments
  --
  -- Procedure Name  : validate_repurchase_agmt_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments


 PROCEDURE validate_repurchase_agmt_yn (
 x_return_status OUT NOCOPY VARCHAR2,
 p_artv_rec  IN artv_rec_type ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
 -- intialize return status
 x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic okl_util.check_domain_yn
    l_return_status := OKL_UTIL.check_domain_yn(p_artv_rec.repurchase_agmt_yn);

    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_invalid_value,
                           p_token1       => g_col_name_token,
                           p_token1_value => 'repurchase_agmt_yn');

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

  END validate_repurchase_agmt_yn;


  -- Start of comments
  --
  -- Procedure Name  : validate_like_kind_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments


 PROCEDURE validate_like_kind_yn (
 x_return_status OUT NOCOPY VARCHAR2,
 p_artv_rec  IN artv_rec_type ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
 -- intialize return status
 x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic okl_util.check_domain_yn
    l_return_status := OKL_UTIL.check_domain_yn(p_artv_rec.like_kind_yn);

    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_invalid_value,
                           p_token1       => g_col_name_token,
                           p_token1_value => 'like_kind_yn');

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

  END validate_like_kind_yn;

  -- Start of comments
  --
  -- Procedure Name  : is_unique
  -- Description     : Do not create a new return if any return exists with status other than cancelled
  --                   Do not update a return with status cancelled
  --                   Do not update a return to status other than cancelled,
  --                   if other return with status other than cancelled exists
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure is_unique(
	p_artv_rec		in	artv_rec_type,
	x_return_status out nocopy VARCHAR2) is
    -- Cursor to check whether create or update mode
    CURSOR okl_cre_upd_csr ( p_id IN NUMBER) IS
    SELECT id, ars_code
    FROM   OKL_ASSET_RETURNS_V
    WHERE  id = p_id;

    -- Cursor to get ars code if a asset return exists (create mode)
    CURSOR okl_ars_cre_csr ( p_kle_id IN NUMBER) IS
    SELECT ars_code
    FROM   OKL_ASSET_RETURNS_V
    WHERE  kle_id = p_kle_id;

    -- Cursor to get ars code if a asset return exists (update mode)
    CURSOR okl_ars_upd_csr ( p_id IN NUMBER, p_kle_id IN NUMBER) IS
    SELECT ars_code
    FROM   OKL_ASSET_RETURNS_V
    WHERE  kle_id = p_kle_id
    AND    id <> p_id;

    -- Cursor to get the meaning of the fnd_lookup value
    CURSOR okl_get_meaning_csr  (p_code IN VARCHAR2) IS
    SELECT meaning
    FROM   FND_LOOKUPS
    WHERE  lookup_code = p_code
      AND  lookup_type = 'OKL_ASSET_RETURN_STATUS';

    -- Cursor to get the name of the asset
    CURSOR okl_get_asset_name_csr ( p_kle_id IN NUMBER) IS
    SELECT  name
    FROM    OKC_K_LINES_V
    WHERE   id = p_kle_id;

    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_id            NUMBER;
    l_ars_code      VARCHAR2(200);
    l_ars_code_db   VARCHAR2(200);
    l_meaning       VARCHAR2(2000);
    l_asset_name    VARCHAR2(2000);
  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- Check if value passed for id
    IF (p_artv_rec.id IS NOT NULL AND p_artv_rec.id <> OKC_API.G_MISS_NUM) THEN
      OPEN okl_cre_upd_csr(p_artv_rec.id);
      FETCH okl_cre_upd_csr INTO l_id, l_ars_code_db;
      -- If id already exists then update mode
      IF okl_cre_upd_csr%FOUND THEN
        -- If changing the return status which was cancelled.
        IF (l_ars_code_db = 'CANCELLED' AND p_artv_rec.ars_code <> 'CANCELLED')THEN

           OPEN okl_get_meaning_csr(l_ars_code);
           FETCH okl_get_meaning_csr INTO l_meaning;
           CLOSE okl_get_meaning_csr;

          -- Cannot update a cancelled Asset Return.
  	        OKL_API.SET_MESSAGE( p_app_name		=> 'OKL'
				    	  	    ,p_msg_name		=> 'OKL_AM_ASS_RET_UPD_ERR'
					    	    ,p_token1		=> 'STATUS'
					   	  	    ,p_token1_value	=> l_meaning);
    	    -- notify caller of an error
	        l_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        -- enforce uniqueness
        OPEN okl_ars_upd_csr(p_artv_rec.id,p_artv_rec.kle_id);
        FETCH okl_ars_upd_csr INTO l_ars_code;
        IF okl_ars_upd_csr%FOUND THEN
          IF (l_ars_code <> 'CANCELLED' AND p_artv_rec.ars_code <> 'CANCELLED') THEN

           OPEN okl_get_meaning_csr(l_ars_code);
           FETCH okl_get_meaning_csr INTO l_meaning;
           CLOSE okl_get_meaning_csr;

           OPEN okl_get_asset_name_csr(p_artv_rec.kle_id);
           FETCH okl_get_asset_name_csr INTO l_asset_name;
           CLOSE okl_get_asset_name_csr;

          -- Asset Return already exists for this asset NAME with the status STATUS so cannot create a new asset return now.
  	        OKL_API.SET_MESSAGE( p_app_name	  	=> 'OKL'
				    	  	              ,p_msg_name	  	=> 'OKL_AM_ASS_RET_ARS_ERR'
					    	                ,p_token1	    	=> 'NAME'
					   	  	              ,p_token1_value	=> l_asset_name
					    	                ,p_token2	    	=> 'STATUS'
					   	  	              ,p_token2_value	=> l_meaning);
    	    -- notify caller of an error
	        l_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
        END IF;
        CLOSE okl_ars_upd_csr;
      ELSE -- id does not exists, so create mode
        -- enforce uniqueness
        OPEN okl_ars_cre_csr(p_artv_rec.kle_id);
        FETCH okl_ars_cre_csr INTO l_ars_code;
        IF okl_ars_cre_csr%FOUND THEN
          IF (l_ars_code <> 'CANCELLED') THEN

           OPEN okl_get_meaning_csr(l_ars_code);
           FETCH okl_get_meaning_csr INTO l_meaning;
           CLOSE okl_get_meaning_csr;

           OPEN okl_get_asset_name_csr(p_artv_rec.kle_id);
           FETCH okl_get_asset_name_csr INTO l_asset_name;
           CLOSE okl_get_asset_name_csr;

           -- Asset Return already exists for this asset NAME with the status STATUS so cannot create a new asset return now.
  	        OKL_API.SET_MESSAGE( p_app_name	  	=> 'OKL'
				    	  	              ,p_msg_name	  	=> 'OKL_AM_ASS_RET_ARS_ERR'
					    	                ,p_token1	    	=> 'NAME'
					   	  	              ,p_token1_value	=> l_asset_name
					    	                ,p_token2	    	=> 'STATUS'
					   	  	              ,p_token2_value	=> l_meaning);
    	    -- notify caller of an error
	        l_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
        END IF;
        CLOSE okl_ars_cre_csr;
      END IF;
      CLOSE okl_cre_upd_csr;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      IF okl_cre_upd_csr%ISOPEN THEN
         CLOSE okl_cre_upd_csr;
      END IF;
      IF okl_ars_cre_csr%ISOPEN THEN
         CLOSE okl_ars_cre_csr;
      END IF;
      IF okl_ars_upd_csr%ISOPEN THEN
         CLOSE okl_ars_upd_csr;
      END IF;
      IF okl_get_meaning_csr%ISOPEN THEN
         CLOSE okl_get_meaning_csr;
      END IF;
      IF okl_get_asset_name_csr%ISOPEN THEN
         CLOSE okl_get_asset_name_csr;
      END IF;

      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  end is_unique;

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
    DELETE FROM OKL_ASSET_RETURNS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_ASSET_RETURNS_ALL_B  B
         WHERE B.ID = T.ID
        );

    UPDATE OKL_ASSET_RETURNS_TL T SET (
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKL_ASSET_RETURNS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_ASSET_RETURNS_TL SUBB, OKL_ASSET_RETURNS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

    INSERT INTO OKL_ASSET_RETURNS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        COMMENTS,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        NEW_ITEM_DESCRIPTION)
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
            B.LAST_UPDATE_LOGIN,
            B.NEW_ITEM_DESCRIPTION
        FROM OKL_ASSET_RETURNS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_ASSET_RETURNS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ASSET_RETURNS_B
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : get_rec
  -- Description     : for: OKL_ASSET_RETURNS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION get_rec (
    p_art_rec                      IN art_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN art_rec_type IS
    CURSOR okl_asset_returns_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            KLE_ID,
            SECURITY_DEP_TRX_AP_ID,
            ISO_ID,
            RNA_ID,
            RMR_ID,
            ARS_CODE,
            IMR_ID,
            ART1_CODE,
            DATE_RETURN_DUE,
            DATE_RETURN_NOTIFIED,
            RELOCATE_ASSET_YN,
            OBJECT_VERSION_NUMBER,
            VOLUNTARY_YN,
            COMMMERCIALLY_REAS_SALE_YN,
            DATE_REPOSSESSION_REQUIRED,
            DATE_REPOSSESSION_ACTUAL,
            DATE_HOLD_UNTIL,
            DATE_RETURNED,
            DATE_TITLE_RETURNED,
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
            FLOOR_PRICE,
            NEW_ITEM_PRICE,
			-- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
			NEW_ITEM_NUMBER,
            ASSET_RELOCATED_YN,
            REPURCHASE_AGMT_YN,
            LIKE_KIND_YN,
  -- RABHUPAT - 2667636 - Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
            LEGAL_ENTITY_ID,
  -- Legal Entity Changes End
  -- DJANASWA Loan Repossession proj start
            ASSET_FMV_AMOUNT
  --   Loan Repossession proj end
      FROM Okl_Asset_Returns_B
     WHERE okl_asset_returns_b.id = p_id;
    l_okl_asset_returns_b_pk       okl_asset_returns_b_pk_csr%ROWTYPE;
    l_art_rec                      art_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_asset_returns_b_pk_csr (p_art_rec.id);
    FETCH okl_asset_returns_b_pk_csr INTO
              l_art_rec.ID,
              l_art_rec.KLE_ID,
              l_art_rec.SECURITY_DEP_TRX_AP_ID,
              l_art_rec.ISO_ID,
              l_art_rec.RNA_ID,
              l_art_rec.RMR_ID,
              l_art_rec.ARS_CODE,
              l_art_rec.IMR_ID,
              l_art_rec.ART1_CODE,
              l_art_rec.DATE_RETURN_DUE,
              l_art_rec.DATE_RETURN_NOTIFIED,
              l_art_rec.RELOCATE_ASSET_YN,
              l_art_rec.OBJECT_VERSION_NUMBER,
              l_art_rec.VOLUNTARY_YN,
              l_art_rec.COMMMERCIALLY_REAS_SALE_YN,
              l_art_rec.DATE_REPOSSESSION_REQUIRED,
              l_art_rec.DATE_REPOSSESSION_ACTUAL,
              l_art_rec.DATE_HOLD_UNTIL,
              l_art_rec.DATE_RETURNED,
              l_art_rec.DATE_TITLE_RETURNED,
              l_art_rec.ORG_ID,
              l_art_rec.REQUEST_ID,
              l_art_rec.PROGRAM_APPLICATION_ID,
              l_art_rec.PROGRAM_ID,
              l_art_rec.PROGRAM_UPDATE_DATE,
              l_art_rec.ATTRIBUTE_CATEGORY,
              l_art_rec.ATTRIBUTE1,
              l_art_rec.ATTRIBUTE2,
              l_art_rec.ATTRIBUTE3,
              l_art_rec.ATTRIBUTE4,
              l_art_rec.ATTRIBUTE5,
              l_art_rec.ATTRIBUTE6,
              l_art_rec.ATTRIBUTE7,
              l_art_rec.ATTRIBUTE8,
              l_art_rec.ATTRIBUTE9,
              l_art_rec.ATTRIBUTE10,
              l_art_rec.ATTRIBUTE11,
              l_art_rec.ATTRIBUTE12,
              l_art_rec.ATTRIBUTE13,
              l_art_rec.ATTRIBUTE14,
              l_art_rec.ATTRIBUTE15,
              l_art_rec.CREATED_BY,
              l_art_rec.CREATION_DATE,
              l_art_rec.LAST_UPDATED_BY,
              l_art_rec.LAST_UPDATE_DATE,
              l_art_rec.LAST_UPDATE_LOGIN,
              l_art_rec.FLOOR_PRICE,
              l_art_rec.NEW_ITEM_PRICE,
			  -- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
			  l_art_rec.NEW_ITEM_NUMBER,
              l_art_rec.ASSET_RELOCATED_YN,
              l_art_rec.REPURCHASE_AGMT_YN,
              l_art_rec.LIKE_KIND_YN,
  -- RABHUPAT - 2667636 - Start
              l_art_rec.CURRENCY_CODE,
              l_art_rec.CURRENCY_CONVERSION_CODE,
              l_art_rec.CURRENCY_CONVERSION_TYPE,
              l_art_rec.CURRENCY_CONVERSION_RATE,
              l_art_rec.CURRENCY_CONVERSION_DATE,
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
              l_art_rec.LEGAL_ENTITY_ID,
  -- Legal Entity Changes End
 -- DJANASWA Loan Repossession proj start
              l_art_rec.ASSET_FMV_AMOUNT;
  --   Loan Repossession proj end
    x_no_data_found := okl_asset_returns_b_pk_csr%NOTFOUND;
    CLOSE okl_asset_returns_b_pk_csr;
    RETURN(l_art_rec);
  END get_rec;

  FUNCTION get_rec (
    p_art_rec                      IN art_rec_type
  ) RETURN art_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_art_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ASSET_RETURNS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_asset_returns_tl_rec     IN okl_asset_returns_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_asset_returns_tl_rec_type IS
    CURSOR okl_asset_returns_tl_pk_csr (p_id                 IN NUMBER,
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
            LAST_UPDATE_LOGIN,
            NEW_ITEM_DESCRIPTION
      FROM Okl_Asset_Returns_Tl
     WHERE okl_asset_returns_tl.id = p_id
       AND okl_asset_returns_tl.language = p_language;
    l_okl_asset_returns_tl_pk      okl_asset_returns_tl_pk_csr%ROWTYPE;
    l_okl_asset_returns_tl_rec     okl_asset_returns_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_asset_returns_tl_pk_csr (p_okl_asset_returns_tl_rec.id,
                                      p_okl_asset_returns_tl_rec.language);
    FETCH okl_asset_returns_tl_pk_csr INTO
              l_okl_asset_returns_tl_rec.ID,
              l_okl_asset_returns_tl_rec.LANGUAGE,
              l_okl_asset_returns_tl_rec.SOURCE_LANG,
              l_okl_asset_returns_tl_rec.SFWT_FLAG,
              l_okl_asset_returns_tl_rec.COMMENTS,
              l_okl_asset_returns_tl_rec.CREATED_BY,
              l_okl_asset_returns_tl_rec.CREATION_DATE,
              l_okl_asset_returns_tl_rec.LAST_UPDATED_BY,
              l_okl_asset_returns_tl_rec.LAST_UPDATE_DATE,
              l_okl_asset_returns_tl_rec.LAST_UPDATE_LOGIN,
              l_okl_asset_returns_tl_rec.NEW_ITEM_DESCRIPTION;
    x_no_data_found := okl_asset_returns_tl_pk_csr%NOTFOUND;
    CLOSE okl_asset_returns_tl_pk_csr;
    RETURN(l_okl_asset_returns_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_asset_returns_tl_rec     IN okl_asset_returns_tl_rec_type
  ) RETURN okl_asset_returns_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_asset_returns_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ASSET_RETURNS_V
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : get_rec
  -- Description     : for: OKL_ASSET_RETURNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION get_rec (
    p_artv_rec                     IN artv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN artv_rec_type IS
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
            DATE_RETURNED,
            DATE_TITLE_RETURNED,
            DATE_RETURN_DUE,
            DATE_RETURN_NOTIFIED,
            RELOCATE_ASSET_YN,
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
            LAST_UPDATE_LOGIN,
            FLOOR_PRICE,
            NEW_ITEM_PRICE,
			-- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
			NEW_ITEM_NUMBER,
            ASSET_RELOCATED_YN,
            NEW_ITEM_DESCRIPTION,
            REPURCHASE_AGMT_YN,
            LIKE_KIND_YN,
  -- RABHUPAT - 2667636 - Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
            LEGAL_ENTITY_ID,
  -- Legal Entity Changes End
 -- DJANASWA Loan Repossession proj start
            ASSET_FMV_AMOUNT
  --   Loan Repossession proj end
      FROM Okl_Asset_Returns_V
     WHERE okl_asset_returns_v.id = p_id;
    l_okl_artv_pk                  okl_artv_pk_csr%ROWTYPE;
    l_artv_rec                     artv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_artv_pk_csr (p_artv_rec.id);
    FETCH okl_artv_pk_csr INTO
              l_artv_rec.ID,
              l_artv_rec.OBJECT_VERSION_NUMBER,
              l_artv_rec.SFWT_FLAG,
              l_artv_rec.RMR_ID,
              l_artv_rec.IMR_ID,
              l_artv_rec.RNA_ID,
              l_artv_rec.KLE_ID,
              l_artv_rec.ISO_ID,
              l_artv_rec.SECURITY_DEP_TRX_AP_ID,
              l_artv_rec.ARS_CODE,
              l_artv_rec.ART1_CODE,
              l_artv_rec.DATE_RETURNED,
              l_artv_rec.DATE_TITLE_RETURNED,
              l_artv_rec.DATE_RETURN_DUE,
              l_artv_rec.DATE_RETURN_NOTIFIED,
              l_artv_rec.RELOCATE_ASSET_YN,
              l_artv_rec.VOLUNTARY_YN,
              l_artv_rec.DATE_REPOSSESSION_REQUIRED,
              l_artv_rec.DATE_REPOSSESSION_ACTUAL,
              l_artv_rec.DATE_HOLD_UNTIL,
              l_artv_rec.COMMMERCIALLY_REAS_SALE_YN,
              l_artv_rec.COMMENTS,
              l_artv_rec.ATTRIBUTE_CATEGORY,
              l_artv_rec.ATTRIBUTE1,
              l_artv_rec.ATTRIBUTE2,
              l_artv_rec.ATTRIBUTE3,
              l_artv_rec.ATTRIBUTE4,
              l_artv_rec.ATTRIBUTE5,
              l_artv_rec.ATTRIBUTE6,
              l_artv_rec.ATTRIBUTE7,
              l_artv_rec.ATTRIBUTE8,
              l_artv_rec.ATTRIBUTE9,
              l_artv_rec.ATTRIBUTE10,
              l_artv_rec.ATTRIBUTE11,
              l_artv_rec.ATTRIBUTE12,
              l_artv_rec.ATTRIBUTE13,
              l_artv_rec.ATTRIBUTE14,
              l_artv_rec.ATTRIBUTE15,
              l_artv_rec.ORG_ID,
              l_artv_rec.REQUEST_ID,
              l_artv_rec.PROGRAM_APPLICATION_ID,
              l_artv_rec.PROGRAM_ID,
              l_artv_rec.PROGRAM_UPDATE_DATE,
              l_artv_rec.CREATED_BY,
              l_artv_rec.CREATION_DATE,
              l_artv_rec.LAST_UPDATED_BY,
              l_artv_rec.LAST_UPDATE_DATE,
              l_artv_rec.LAST_UPDATE_LOGIN,
              l_artv_rec.FLOOR_PRICE,
              l_artv_rec.NEW_ITEM_PRICE,
			  -- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
			  l_artv_rec.NEW_ITEM_NUMBER,
              l_artv_rec.ASSET_RELOCATED_YN,
              l_artv_rec.NEW_ITEM_DESCRIPTION,
              l_artv_rec.REPURCHASE_AGMT_YN,
              l_artv_rec.LIKE_KIND_YN,
  -- RABHUPAT - 2667636 - Start
              l_artv_rec.CURRENCY_CODE,
              l_artv_rec.CURRENCY_CONVERSION_CODE,
              l_artv_rec.CURRENCY_CONVERSION_TYPE,
              l_artv_rec.CURRENCY_CONVERSION_RATE,
              l_artv_rec.CURRENCY_CONVERSION_DATE,
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
              l_artv_rec.LEGAL_ENTITY_ID,
  -- Legal Entity Changes End
 -- DJANASWA Loan Repossession proj start
             l_artv_rec.ASSET_FMV_AMOUNT;
  --   Loan Repossession proj end
x_no_data_found := okl_artv_pk_csr%NOTFOUND;
    CLOSE okl_artv_pk_csr;
    RETURN(l_artv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_artv_rec                     IN artv_rec_type
  ) RETURN artv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_artv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_ASSET_RETURNS_V --
  ---------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : null_out_defaults
  -- Description     : for: OKL_ASSET_RETURNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION null_out_defaults (
    p_artv_rec	IN artv_rec_type
  ) RETURN artv_rec_type IS
    l_artv_rec	artv_rec_type := p_artv_rec;
  BEGIN
    IF (l_artv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.object_version_number := NULL;
    END IF;
    IF (l_artv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_artv_rec.rmr_id = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.rmr_id := NULL;
    END IF;
    IF (l_artv_rec.imr_id = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.imr_id := NULL;
    END IF;
    IF (l_artv_rec.rna_id = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.rna_id := NULL;
    END IF;
    IF (l_artv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.kle_id := NULL;
    END IF;
    IF (l_artv_rec.iso_id = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.iso_id := NULL;
    END IF;
    IF (l_artv_rec.security_dep_trx_ap_id = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.security_dep_trx_ap_id := NULL;
    END IF;
    IF (l_artv_rec.ars_code = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.ars_code := NULL;
    END IF;
    IF (l_artv_rec.art1_code = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.art1_code := NULL;
    END IF;
    IF (l_artv_rec.date_returned = OKC_API.G_MISS_DATE) THEN
      l_artv_rec.date_returned := NULL;
    END IF;
    IF (l_artv_rec.date_title_returned = OKC_API.G_MISS_DATE) THEN
      l_artv_rec.date_title_returned := NULL;
    END IF;
    IF (l_artv_rec.date_return_due = OKC_API.G_MISS_DATE) THEN
      l_artv_rec.date_return_due := NULL;
    END IF;
    IF (l_artv_rec.date_return_notified = OKC_API.G_MISS_DATE) THEN
      l_artv_rec.date_return_notified := NULL;
    END IF;
    IF (l_artv_rec.relocate_asset_yn = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.relocate_asset_yn := NULL;
    END IF;
    IF (l_artv_rec.voluntary_yn = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.voluntary_yn := NULL;
    END IF;
    IF (l_artv_rec.date_repossession_required = OKC_API.G_MISS_DATE) THEN
      l_artv_rec.date_repossession_required := NULL;
    END IF;
    IF (l_artv_rec.date_repossession_actual = OKC_API.G_MISS_DATE) THEN
      l_artv_rec.date_repossession_actual := NULL;
    END IF;
    IF (l_artv_rec.date_hold_until = OKC_API.G_MISS_DATE) THEN
      l_artv_rec.date_hold_until := NULL;
    END IF;
    IF (l_artv_rec.commmercially_reas_sale_yn = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.commmercially_reas_sale_yn := NULL;
    END IF;
    IF (l_artv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.comments := NULL;
    END IF;
    IF (l_artv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute_category := NULL;
    END IF;
    IF (l_artv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute1 := NULL;
    END IF;
    IF (l_artv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute2 := NULL;
    END IF;
    IF (l_artv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute3 := NULL;
    END IF;
    IF (l_artv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute4 := NULL;
    END IF;
    IF (l_artv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute5 := NULL;
    END IF;
    IF (l_artv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute6 := NULL;
    END IF;
    IF (l_artv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute7 := NULL;
    END IF;
    IF (l_artv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute8 := NULL;
    END IF;
    IF (l_artv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute9 := NULL;
    END IF;
    IF (l_artv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute10 := NULL;
    END IF;
    IF (l_artv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute11 := NULL;
    END IF;
    IF (l_artv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute12 := NULL;
    END IF;
    IF (l_artv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute13 := NULL;
    END IF;
    IF (l_artv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute14 := NULL;
    END IF;
    IF (l_artv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.attribute15 := NULL;
    END IF;
    IF (l_artv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.org_id := NULL;
    END IF;
    IF (l_artv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.created_by := NULL;
    END IF;
    IF (l_artv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_artv_rec.creation_date := NULL;
    END IF;
    IF (l_artv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.last_updated_by := NULL;
    END IF;
    IF (l_artv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_artv_rec.last_update_date := NULL;
    END IF;
    IF (l_artv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.last_update_login := NULL;
    END IF;

    IF (l_artv_rec.floor_price = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.floor_price := NULL;
    END IF;
    IF (l_artv_rec.new_item_price = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.new_item_price := NULL;
    END IF;
    -- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
	IF (l_artv_rec.new_item_number = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.new_item_number := NULL;
    END IF;


    IF (l_artv_rec.asset_relocated_yn = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.asset_relocated_yn := NULL;
    END IF;
    IF (l_artv_rec.new_item_description = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.new_item_description := NULL;
    END IF;
    IF (l_artv_rec.repurchase_agmt_yn = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.repurchase_agmt_yn := NULL;
    END IF;
    IF (l_artv_rec.like_kind_yn = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.like_kind_yn := NULL;
    END IF;
  -- RABHUPAT - 2667636 -Start
    IF (l_artv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.currency_code := NULL;
    END IF;
    IF (l_artv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.currency_conversion_code := NULL;
    END IF;
    IF (l_artv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
      l_artv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_artv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_artv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
      l_artv_rec.currency_conversion_date := NULL;
    END IF;
  -- RABHUPAT - 2667636 -End
  -- RRAVIKIR Legal Entity Changes
    IF (l_artv_rec.legal_entity_id = OKC_API.G_MISS_NUM) THEN
      l_artv_rec.legal_entity_id := NULL;
    END IF;
  -- Legal Entity Changes End
 -- DJANASWA Loan Repossession proj start
    IF (l_artv_rec.ASSET_FMV_AMOUNT= OKC_API.G_MISS_NUM) THEN
      l_artv_rec.ASSET_FMV_AMOUNT:= NULL;
    END IF;
  --   Loan Repossession proj end
    RETURN(l_artv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_ASSET_RETURNS_V --
  -------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_attributes
  -- Description     : for:OKL_ASSET_RETURNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  FUNCTION Validate_Attributes (
    p_artv_rec IN  artv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
   -- call each column-level validation
   validate_id(x_return_status => l_return_status,
                p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

   validate_object_version_number(x_return_status => l_return_status,
               				   p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_sfwt_flag(x_return_status => l_return_status,
               				   p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;



    validate_kle_id(x_return_status => l_return_status,
               	   p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

   validate_ars_code(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

   validate_art1_code(x_return_status => l_return_status,
               	      p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
   if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

   validate_relocate_asset_yn(x_return_status => l_return_status,
               	              p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_org_id(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

   validate_sec_dep_trx_ap_id(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

 validate_iso_id(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

 validate_rna_id(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

 validate_rmr_id(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

 validate_imr_id(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

 validate_asset_relocated_yn(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;


 validate_commmercially_reas_yn(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

 validate_voluntary_yn(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

 validate_repurchase_agmt_yn(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

 validate_like_kind_yn(x_return_status => l_return_status,
               	     p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

  -- RABHUPAT - 2667636 - Start
    validate_currency_code(p_artv_rec      => p_artv_rec,
                           x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_code(p_artv_rec      => p_artv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_type(p_artv_rec      => p_artv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- RABHUPAT - 2667636 - End

    -- RRAVIKIR Legal Entity validation
    validate_legal_entity_id(x_return_status => l_return_status,
                             p_artv_rec      => p_artv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;
    -- Legal Entity validation End

    RETURN(x_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_ASSET_RETURNS_V --
  ---------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : Validate_Record
  -- Description     : for:OKL_ASSET_RETURNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION Validate_Record (
    p_artv_rec IN artv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- check uniqueness
    is_unique(p_artv_rec,l_return_status);

    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

  -- RABHUPAT - 2667636 - Start
    -- Validate Currency conversion Code,type,rate and Date

    validate_currency_record(p_artv_rec      => p_artv_rec,
                                 x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- RABHUPAT - 2667636 - End
    RETURN (x_return_status);
   EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => sqlcode
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => sqlerrm);

        --notify caller of an UNEXPECTED error
        x_return_status  := OKL_API.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        RETURN x_return_status;
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
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE migrate (
    p_from	IN artv_rec_type,
    p_to	IN OUT NOCOPY art_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.kle_id := p_from.kle_id;
    p_to.security_dep_trx_ap_id := p_from.security_dep_trx_ap_id;
    p_to.iso_id := p_from.iso_id;
    p_to.rna_id := p_from.rna_id;
    p_to.rmr_id := p_from.rmr_id;
    p_to.ars_code := p_from.ars_code;
    p_to.imr_id := p_from.imr_id;
    p_to.art1_code := p_from.art1_code;
    p_to.date_return_due := p_from.date_return_due;
    p_to.date_return_notified := p_from.date_return_notified;
    p_to.relocate_asset_yn := p_from.relocate_asset_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.voluntary_yn := p_from.voluntary_yn;
    p_to.commmercially_reas_sale_yn := p_from.commmercially_reas_sale_yn;
    p_to.date_repossession_required := p_from.date_repossession_required;
    p_to.date_repossession_actual := p_from.date_repossession_actual;
    p_to.date_hold_until := p_from.date_hold_until;
    p_to.date_returned := p_from.date_returned;
    p_to.date_title_returned := p_from.date_title_returned;
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

    p_to.floor_price := p_from.floor_price;
    p_to.new_item_price := p_from.new_item_price;

    -- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
    p_to.new_item_number := p_from.new_item_number;

    p_to.asset_relocated_yn := p_from.asset_relocated_yn;
    p_to.repurchase_agmt_yn := p_from.repurchase_agmt_yn;
    p_to.like_kind_yn := p_from.like_kind_yn;

  -- RABHUPAT - 2667636 - Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
    p_to.legal_entity_id  := p_from.legal_entity_id;
  -- Legal Entity Changes End
 -- DJANASWA Loan Repossession proj start
    p_to.ASSET_FMV_AMOUNT:= p_from.ASSET_FMV_AMOUNT;
  --   Loan Repossession proj end
  END migrate;

  -- Start of comments
  --
  -- Procedure Name  : Migrate
  -- Description     : from _B to _V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE migrate (
    p_from	IN art_rec_type,
    p_to	IN OUT NOCOPY artv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.kle_id := p_from.kle_id;
    p_to.security_dep_trx_ap_id := p_from.security_dep_trx_ap_id;
    p_to.iso_id := p_from.iso_id;
    p_to.rna_id := p_from.rna_id;
    p_to.rmr_id := p_from.rmr_id;
    p_to.ars_code := p_from.ars_code;
    p_to.imr_id := p_from.imr_id;
    p_to.art1_code := p_from.art1_code;
    p_to.date_return_due := p_from.date_return_due;
    p_to.date_return_notified := p_from.date_return_notified;
    p_to.relocate_asset_yn := p_from.relocate_asset_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.voluntary_yn := p_from.voluntary_yn;
    p_to.commmercially_reas_sale_yn := p_from.commmercially_reas_sale_yn;
    p_to.date_repossession_required := p_from.date_repossession_required;
    p_to.date_repossession_actual := p_from.date_repossession_actual;
    p_to.date_hold_until := p_from.date_hold_until;
    p_to.date_returned := p_from.date_returned;
    p_to.date_title_returned := p_from.date_title_returned;
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

    p_to.floor_price := p_from.floor_price;
    p_to.new_item_price := p_from.new_item_price;

    -- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
    p_to.new_item_number := p_from.new_item_number;

    p_to.asset_relocated_yn := p_from.asset_relocated_yn;
    p_to.repurchase_agmt_yn := p_from.repurchase_agmt_yn;
    p_to.like_kind_yn := p_from.like_kind_yn;

  -- RABHUPAT - 2667636 - Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
    p_to.legal_entity_id  := p_from.legal_entity_id;
  -- Legal Entity Changes End
 -- DJANASWA Loan Repossession proj start
    p_to.ASSET_FMV_AMOUNT:= p_from.ASSET_FMV_AMOUNT;
  --   Loan Repossession proj end
  END migrate;
  PROCEDURE migrate (
    p_from	IN artv_rec_type,
    p_to	IN OUT NOCOPY okl_asset_returns_tl_rec_type
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

    p_to.new_item_description := p_from.new_item_description;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_asset_returns_tl_rec_type,
    p_to	IN OUT NOCOPY artv_rec_type
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

    p_to.new_item_description := p_from.new_item_description;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_ASSET_RETURNS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_rec                     IN artv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_artv_rec                     artv_rec_type := p_artv_rec;
    l_art_rec                      art_rec_type;
    l_okl_asset_returns_tl_rec     okl_asset_returns_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_artv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_artv_rec);
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
  -- PL/SQL TBL validate_row for:ARTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_tbl                     IN artv_tbl_type) IS

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
    IF (p_artv_tbl.COUNT > 0) THEN
      i := p_artv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_artv_rec                     => p_artv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_artv_tbl.LAST);
        i := p_artv_tbl.NEXT(i);
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
  -- insert_row for:OKL_ASSET_RETURNS_B --
  ----------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : for OKL_ASSET_RETURNS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_art_rec                      IN art_rec_type,
    x_art_rec                      OUT NOCOPY art_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_art_rec                      art_rec_type := p_art_rec;
    l_def_art_rec                  art_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_ASSET_RETURNS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_art_rec IN  art_rec_type,
      x_art_rec OUT NOCOPY art_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_art_rec := p_art_rec;
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
      p_art_rec,                         -- IN
      l_art_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_ASSET_RETURNS_B(
        id,
        kle_id,
        security_dep_trx_ap_id,
        iso_id,
        rna_id,
        rmr_id,
        ars_code,
        imr_id,
        art1_code,
        date_return_due,
        date_return_notified,
        relocate_asset_yn,
        object_version_number,
        voluntary_yn,
        commmercially_reas_sale_yn,
        date_repossession_required,
        date_repossession_actual,
        date_hold_until,
        date_returned,
        date_title_returned,
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
        floor_price,
        new_item_price,

		-- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
    	new_item_number,

        asset_relocated_yn,
        repurchase_agmt_yn,
        like_kind_yn,
  -- RABHUPAT - 2667636 - Start
        currency_code,
        currency_conversion_code,
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date,
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
        legal_entity_id,
  -- Legal Entity Changes End
  -- DJANASWA Loan Repossession proj start
         ASSET_FMV_AMOUNT)
  --   Loan Repossession proj end
      VALUES (
        l_art_rec.id,
        l_art_rec.kle_id,
        l_art_rec.security_dep_trx_ap_id,
        l_art_rec.iso_id,
        l_art_rec.rna_id,
        l_art_rec.rmr_id,
        l_art_rec.ars_code,
        l_art_rec.imr_id,
        l_art_rec.art1_code,
        l_art_rec.date_return_due,
        l_art_rec.date_return_notified,
        l_art_rec.relocate_asset_yn,
        l_art_rec.object_version_number,
        l_art_rec.voluntary_yn,
        l_art_rec.commmercially_reas_sale_yn,
        l_art_rec.date_repossession_required,
        l_art_rec.date_repossession_actual,
        l_art_rec.date_hold_until,
        l_art_rec.date_returned,
        l_art_rec.date_title_returned,
        l_art_rec.org_id,
        DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
        DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
        DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
        DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
        l_art_rec.attribute_category,
        l_art_rec.attribute1,
        l_art_rec.attribute2,
        l_art_rec.attribute3,
        l_art_rec.attribute4,
        l_art_rec.attribute5,
        l_art_rec.attribute6,
        l_art_rec.attribute7,
        l_art_rec.attribute8,
        l_art_rec.attribute9,
        l_art_rec.attribute10,
        l_art_rec.attribute11,
        l_art_rec.attribute12,
        l_art_rec.attribute13,
        l_art_rec.attribute14,
        l_art_rec.attribute15,
        l_art_rec.created_by,
        l_art_rec.creation_date,
        l_art_rec.last_updated_by,
        l_art_rec.last_update_date,
        l_art_rec.last_update_login,
        l_art_rec.floor_price,
        l_art_rec.new_item_price,

		-- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
		l_art_rec.new_item_number,

        l_art_rec.asset_relocated_yn,
        l_art_rec.repurchase_agmt_yn,
        l_art_rec.like_kind_yn,
  -- RABHUPAT - 2667636 - Start
        l_art_rec.currency_code,
        l_art_rec.currency_conversion_code,
        l_art_rec.currency_conversion_type,
        l_art_rec.currency_conversion_rate,
        l_art_rec.currency_conversion_date,
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
        l_art_rec.legal_entity_id,
  -- Legal Entity Changes End
 -- DJANASWA Loan Repossession proj start
        l_art_rec.ASSET_FMV_AMOUNT);
  --   Loan Repossession proj end
    -- Set OUT values
    x_art_rec := l_art_rec;
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
  -----------------------------------------
  -- insert_row for:OKL_ASSET_RETURNS_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_asset_returns_tl_rec     IN okl_asset_returns_tl_rec_type,
    x_okl_asset_returns_tl_rec     OUT NOCOPY okl_asset_returns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_asset_returns_tl_rec     okl_asset_returns_tl_rec_type := p_okl_asset_returns_tl_rec;
    ldefoklassetreturnstlrec       okl_asset_returns_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_ASSET_RETURNS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_asset_returns_tl_rec IN  okl_asset_returns_tl_rec_type,
      x_okl_asset_returns_tl_rec OUT NOCOPY okl_asset_returns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_asset_returns_tl_rec := p_okl_asset_returns_tl_rec;
      x_okl_asset_returns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_asset_returns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_asset_returns_tl_rec,        -- IN
      l_okl_asset_returns_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_asset_returns_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_ASSET_RETURNS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          new_item_description)
        VALUES (
          l_okl_asset_returns_tl_rec.id,
          l_okl_asset_returns_tl_rec.language,
          l_okl_asset_returns_tl_rec.source_lang,
          l_okl_asset_returns_tl_rec.sfwt_flag,
          l_okl_asset_returns_tl_rec.comments,
          l_okl_asset_returns_tl_rec.created_by,
          l_okl_asset_returns_tl_rec.creation_date,
          l_okl_asset_returns_tl_rec.last_updated_by,
          l_okl_asset_returns_tl_rec.last_update_date,
          l_okl_asset_returns_tl_rec.last_update_login,
          l_okl_asset_returns_tl_rec.new_item_description);
    END LOOP;
    -- Set OUT values
    x_okl_asset_returns_tl_rec := l_okl_asset_returns_tl_rec;
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
  -- insert_row for:OKL_ASSET_RETURNS_V --
  ----------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : for OKL_ASSET_RETURNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_rec                     IN artv_rec_type,
    x_artv_rec                     OUT NOCOPY artv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_artv_rec                     artv_rec_type;
    l_def_artv_rec                 artv_rec_type;
    l_art_rec                      art_rec_type;
    lx_art_rec                     art_rec_type;
    l_okl_asset_returns_tl_rec     okl_asset_returns_tl_rec_type;
    lx_okl_asset_returns_tl_rec    okl_asset_returns_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_artv_rec	IN artv_rec_type
    ) RETURN artv_rec_type IS
      l_artv_rec	artv_rec_type := p_artv_rec;
    BEGIN
      l_artv_rec.CREATION_DATE := SYSDATE;
      l_artv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_artv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_artv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_artv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_artv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_ASSET_RETURNS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_artv_rec IN  artv_rec_type,
      x_artv_rec OUT NOCOPY artv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_artv_rec := p_artv_rec;
      x_artv_rec.OBJECT_VERSION_NUMBER := 1;
      x_artv_rec.SFWT_FLAG := 'N';

      -- Default the YN columns if not passed.
      IF p_artv_rec.like_kind_yn IS NULL
      OR p_artv_rec.like_kind_yn = OKC_API.G_MISS_CHAR THEN
        x_artv_rec.like_kind_yn := 'N';
      END IF;

      IF p_artv_rec.repurchase_agmt_yn IS NULL
      OR p_artv_rec.repurchase_agmt_yn = OKC_API.G_MISS_CHAR THEN
        x_artv_rec.repurchase_agmt_yn := 'N';
      END IF;
      IF p_artv_rec.asset_relocated_yn IS NULL
      OR p_artv_rec.asset_relocated_yn = OKC_API.G_MISS_CHAR THEN
        x_artv_rec.asset_relocated_yn := 'N';
      END IF;
      IF p_artv_rec.commmercially_reas_sale_yn IS NULL
      OR p_artv_rec.commmercially_reas_sale_yn = OKC_API.G_MISS_CHAR THEN
        x_artv_rec.commmercially_reas_sale_yn := 'N';
      END IF;
      IF p_artv_rec.voluntary_yn IS NULL
      OR p_artv_rec.voluntary_yn = OKC_API.G_MISS_CHAR THEN
        x_artv_rec.voluntary_yn := 'N';
      END IF;
      IF p_artv_rec.relocate_asset_yn IS NULL
      OR p_artv_rec.relocate_asset_yn = OKC_API.G_MISS_CHAR THEN
        x_artv_rec.relocate_asset_yn := 'N';
      END IF;

      -- Default the ORG ID if a value is not passed
      IF p_artv_rec.org_id IS NULL
      OR p_artv_rec.org_id = OKC_API.G_MISS_NUM THEN
        x_artv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      END IF;

  -- RABHUPAT - 2667636 - Start
      x_artv_rec.currency_conversion_code := OKL_AM_UTIL_PVT.get_functional_currency;

      IF p_artv_rec.currency_code IS NULL
      OR p_artv_rec.currency_code = OKC_API.G_MISS_CHAR THEN
        x_artv_rec.currency_code := x_artv_rec.currency_conversion_code;
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
    l_artv_rec := null_out_defaults(p_artv_rec);
    -- Set primary key value
    l_artv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_artv_rec,                        -- IN
      l_def_artv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_artv_rec := fill_who_columns(l_def_artv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_artv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_artv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_artv_rec, l_art_rec);
    migrate(l_def_artv_rec, l_okl_asset_returns_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_art_rec,
      lx_art_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_art_rec, l_def_artv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_asset_returns_tl_rec,
      lx_okl_asset_returns_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_asset_returns_tl_rec, l_def_artv_rec);
    -- Set OUT values
    x_artv_rec := l_def_artv_rec;
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
  -- PL/SQL TBL insert_row for:ARTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_tbl                     IN artv_tbl_type,
    x_artv_tbl                     OUT NOCOPY artv_tbl_type) IS

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
    IF (p_artv_tbl.COUNT > 0) THEN
      i := p_artv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_artv_rec                     => p_artv_tbl(i),
          x_artv_rec                     => x_artv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_artv_tbl.LAST);
        i := p_artv_tbl.NEXT(i);
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
  -- lock_row for:OKL_ASSET_RETURNS_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_art_rec                      IN art_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_art_rec IN art_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ASSET_RETURNS_B
     WHERE ID = p_art_rec.id
       AND OBJECT_VERSION_NUMBER = p_art_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_art_rec IN art_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ASSET_RETURNS_B
    WHERE ID = p_art_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_ASSET_RETURNS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_ASSET_RETURNS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_art_rec);
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
      OPEN lchk_csr(p_art_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_art_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_art_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKL_ASSET_RETURNS_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_asset_returns_tl_rec     IN okl_asset_returns_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_asset_returns_tl_rec IN okl_asset_returns_tl_rec_type) IS
    SELECT *
      FROM OKL_ASSET_RETURNS_TL
     WHERE ID = p_okl_asset_returns_tl_rec.id
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
      OPEN lock_csr(p_okl_asset_returns_tl_rec);
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
  --------------------------------------
  -- lock_row for:OKL_ASSET_RETURNS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_rec                     IN artv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_art_rec                      art_rec_type;
    l_okl_asset_returns_tl_rec     okl_asset_returns_tl_rec_type;
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
    migrate(p_artv_rec, l_art_rec);
    migrate(p_artv_rec, l_okl_asset_returns_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_art_rec
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
      l_okl_asset_returns_tl_rec
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
  -- PL/SQL TBL lock_row for:ARTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_tbl                     IN artv_tbl_type) IS

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
    IF (p_artv_tbl.COUNT > 0) THEN
      i := p_artv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_artv_rec                     => p_artv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_artv_tbl.LAST);
        i := p_artv_tbl.NEXT(i);
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
  -- update_row for:OKL_ASSET_RETURNS_B --
  ----------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : for OKL_ASSET_RETURNS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_art_rec                      IN art_rec_type,
    x_art_rec                      OUT NOCOPY art_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_art_rec                      art_rec_type := p_art_rec;
    l_def_art_rec                  art_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_art_rec	IN art_rec_type,
      x_art_rec	OUT NOCOPY art_rec_type
    ) RETURN VARCHAR2 IS
      l_art_rec                      art_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_art_rec := p_art_rec;
      -- Get current database values
      l_art_rec := get_rec(p_art_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_art_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.id := l_art_rec.id;
      END IF;
      IF (x_art_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.kle_id := l_art_rec.kle_id;
      END IF;
      IF (x_art_rec.security_dep_trx_ap_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.security_dep_trx_ap_id := l_art_rec.security_dep_trx_ap_id;
      END IF;
      IF (x_art_rec.iso_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.iso_id := l_art_rec.iso_id;
      END IF;
      IF (x_art_rec.rna_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.rna_id := l_art_rec.rna_id;
      END IF;
      IF (x_art_rec.rmr_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.rmr_id := l_art_rec.rmr_id;
      END IF;
      IF (x_art_rec.ars_code = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.ars_code := l_art_rec.ars_code;
      END IF;
      IF (x_art_rec.imr_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.imr_id := l_art_rec.imr_id;
      END IF;
      IF (x_art_rec.art1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.art1_code := l_art_rec.art1_code;
      END IF;
      IF (x_art_rec.date_return_due = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.date_return_due := l_art_rec.date_return_due;
      END IF;
      IF (x_art_rec.date_return_notified = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.date_return_notified := l_art_rec.date_return_notified;
      END IF;
      IF (x_art_rec.relocate_asset_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.relocate_asset_yn := l_art_rec.relocate_asset_yn;
      END IF;
      IF (x_art_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.object_version_number := l_art_rec.object_version_number;
      END IF;
      IF (x_art_rec.voluntary_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.voluntary_yn := l_art_rec.voluntary_yn;
      END IF;
      IF (x_art_rec.commmercially_reas_sale_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.commmercially_reas_sale_yn := l_art_rec.commmercially_reas_sale_yn;
      END IF;
      IF (x_art_rec.date_repossession_required = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.date_repossession_required := l_art_rec.date_repossession_required;
      END IF;
      IF (x_art_rec.date_repossession_actual = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.date_repossession_actual := l_art_rec.date_repossession_actual;
      END IF;
      IF (x_art_rec.date_hold_until = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.date_hold_until := l_art_rec.date_hold_until;
      END IF;
      IF (x_art_rec.date_returned = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.date_returned := l_art_rec.date_returned;
      END IF;
      IF (x_art_rec.date_title_returned = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.date_title_returned := l_art_rec.date_title_returned;
      END IF;
      IF (x_art_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.org_id := l_art_rec.org_id;
      END IF;
      IF (x_art_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.request_id := l_art_rec.request_id;
      END IF;
      IF (x_art_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.program_application_id := l_art_rec.program_application_id;
      END IF;
      IF (x_art_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.program_id := l_art_rec.program_id;
      END IF;
      IF (x_art_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.program_update_date := l_art_rec.program_update_date;
      END IF;
      IF (x_art_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute_category := l_art_rec.attribute_category;
      END IF;
      IF (x_art_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute1 := l_art_rec.attribute1;
      END IF;
      IF (x_art_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute2 := l_art_rec.attribute2;
      END IF;
      IF (x_art_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute3 := l_art_rec.attribute3;
      END IF;
      IF (x_art_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute4 := l_art_rec.attribute4;
      END IF;
      IF (x_art_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute5 := l_art_rec.attribute5;
      END IF;
      IF (x_art_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute6 := l_art_rec.attribute6;
      END IF;
      IF (x_art_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute7 := l_art_rec.attribute7;
      END IF;
      IF (x_art_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute8 := l_art_rec.attribute8;
      END IF;
      IF (x_art_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute9 := l_art_rec.attribute9;
      END IF;
      IF (x_art_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute10 := l_art_rec.attribute10;
      END IF;
      IF (x_art_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute11 := l_art_rec.attribute11;
      END IF;
      IF (x_art_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute12 := l_art_rec.attribute12;
      END IF;
      IF (x_art_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute13 := l_art_rec.attribute13;
      END IF;
      IF (x_art_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute14 := l_art_rec.attribute14;
      END IF;
      IF (x_art_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.attribute15 := l_art_rec.attribute15;
      END IF;
      IF (x_art_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.created_by := l_art_rec.created_by;
      END IF;
      IF (x_art_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.creation_date := l_art_rec.creation_date;
      END IF;
      IF (x_art_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.last_updated_by := l_art_rec.last_updated_by;
      END IF;
      IF (x_art_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.last_update_date := l_art_rec.last_update_date;
      END IF;
      IF (x_art_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.last_update_login := l_art_rec.last_update_login;
      END IF;

      IF (x_art_rec.floor_price = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.floor_price := l_art_rec.floor_price;
      END IF;
      IF (x_art_rec.new_item_price = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.new_item_price := l_art_rec.new_item_price;
      END IF;

      -- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
      IF (x_art_rec.new_item_number = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.new_item_number := l_art_rec.new_item_number;
      END IF;


      IF (x_art_rec.asset_relocated_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.asset_relocated_yn := l_art_rec.asset_relocated_yn;
      END IF;
      IF (x_art_rec.repurchase_agmt_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.repurchase_agmt_yn := l_art_rec.repurchase_agmt_yn;
      END IF;
      IF (x_art_rec.like_kind_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.like_kind_yn := l_art_rec.like_kind_yn;
      END IF;

  -- RABHUPAT - 2667636 - Start
     IF (x_art_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.currency_code := l_art_rec.currency_code;
      END IF;
      IF (x_art_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.currency_conversion_code := l_art_rec.currency_conversion_code;
      END IF;
      IF (x_art_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_art_rec.currency_conversion_type := l_art_rec.currency_conversion_type;
      END IF;
      IF (x_art_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.currency_conversion_rate := l_art_rec.currency_conversion_rate;
      END IF;
      IF (x_art_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_art_rec.currency_conversion_date := l_art_rec.currency_conversion_date;
      END IF;
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
      IF (x_art_rec.legal_entity_id = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.legal_entity_id := l_art_rec.legal_entity_id;
      END IF;
  -- Legal Entity Changes End
 -- DJANASWA Loan Repossession proj start
      IF (x_art_rec.ASSET_FMV_AMOUNT = OKC_API.G_MISS_NUM)
      THEN
        x_art_rec.ASSET_FMV_AMOUNT := l_art_rec.ASSET_FMV_AMOUNT;
      END IF;
  --   Loan Repossession proj end

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_ASSET_RETURNS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_art_rec IN  art_rec_type,
      x_art_rec OUT NOCOPY art_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_art_rec := p_art_rec;
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
      p_art_rec,                         -- IN
      l_art_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_art_rec, l_def_art_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ASSET_RETURNS_B
    SET KLE_ID = l_def_art_rec.kle_id,
        SECURITY_DEP_TRX_AP_ID = l_def_art_rec.security_dep_trx_ap_id,
        ISO_ID = l_def_art_rec.iso_id,
        RNA_ID = l_def_art_rec.rna_id,
        RMR_ID = l_def_art_rec.rmr_id,
        ARS_CODE = l_def_art_rec.ars_code,
        IMR_ID = l_def_art_rec.imr_id,
        ART1_CODE = l_def_art_rec.art1_code,
        DATE_RETURN_DUE = l_def_art_rec.date_return_due,
        DATE_RETURN_NOTIFIED = l_def_art_rec.date_return_notified,
        RELOCATE_ASSET_YN = l_def_art_rec.relocate_asset_yn,
        OBJECT_VERSION_NUMBER = l_def_art_rec.object_version_number,
        VOLUNTARY_YN = l_def_art_rec.voluntary_yn,
        COMMMERCIALLY_REAS_SALE_YN = l_def_art_rec.commmercially_reas_sale_yn,
        DATE_REPOSSESSION_REQUIRED = l_def_art_rec.date_repossession_required,
        DATE_REPOSSESSION_ACTUAL = l_def_art_rec.date_repossession_actual,
        DATE_HOLD_UNTIL = l_def_art_rec.date_hold_until,
        DATE_RETURNED = l_def_art_rec.date_returned,
        DATE_TITLE_RETURNED = l_def_art_rec.date_title_returned,
        ORG_ID = l_def_art_rec.org_id,
        REQUEST_ID = l_def_art_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_art_rec.program_application_id,
        PROGRAM_ID = l_def_art_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_art_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_art_rec.attribute_category,
        ATTRIBUTE1 = l_def_art_rec.attribute1,
        ATTRIBUTE2 = l_def_art_rec.attribute2,
        ATTRIBUTE3 = l_def_art_rec.attribute3,
        ATTRIBUTE4 = l_def_art_rec.attribute4,
        ATTRIBUTE5 = l_def_art_rec.attribute5,
        ATTRIBUTE6 = l_def_art_rec.attribute6,
        ATTRIBUTE7 = l_def_art_rec.attribute7,
        ATTRIBUTE8 = l_def_art_rec.attribute8,
        ATTRIBUTE9 = l_def_art_rec.attribute9,
        ATTRIBUTE10 = l_def_art_rec.attribute10,
        ATTRIBUTE11 = l_def_art_rec.attribute11,
        ATTRIBUTE12 = l_def_art_rec.attribute12,
        ATTRIBUTE13 = l_def_art_rec.attribute13,
        ATTRIBUTE14 = l_def_art_rec.attribute14,
        ATTRIBUTE15 = l_def_art_rec.attribute15,
        CREATED_BY = l_def_art_rec.created_by,
        CREATION_DATE = l_def_art_rec.creation_date,
        LAST_UPDATED_BY = l_def_art_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_art_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_art_rec.last_update_login,
        FLOOR_PRICE = l_def_art_rec.floor_price,
        NEW_ITEM_PRICE = l_def_art_rec.new_item_price,

        -- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
        NEW_ITEM_NUMBER = l_def_art_rec.new_item_number,

        ASSET_RELOCATED_YN = l_def_art_rec.asset_relocated_yn,
        REPURCHASE_AGMT_YN = l_def_art_rec.repurchase_agmt_yn,
        LIKE_KIND_YN = l_def_art_rec.like_kind_yn,
  -- RABHUPAT - 2667636 - Start
        CURRENCY_CODE = l_def_art_rec.currency_code,
        CURRENCY_CONVERSION_CODE = l_def_art_rec.currency_conversion_code,
        CURRENCY_CONVERSION_TYPE = l_def_art_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_art_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_art_rec.currency_conversion_date,
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
        LEGAL_ENTITY_ID = l_def_art_rec.legal_entity_id,
  -- Legal Entity Changes End
 -- DJANASWA Loan Repossession proj start
        ASSET_FMV_AMOUNT = l_def_art_rec.ASSET_FMV_AMOUNT
  --   Loan Repossession proj end
    WHERE ID = l_def_art_rec.id;

    x_art_rec := l_def_art_rec;
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
  -----------------------------------------
  -- update_row for:OKL_ASSET_RETURNS_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_asset_returns_tl_rec     IN okl_asset_returns_tl_rec_type,
    x_okl_asset_returns_tl_rec     OUT NOCOPY okl_asset_returns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_asset_returns_tl_rec     okl_asset_returns_tl_rec_type := p_okl_asset_returns_tl_rec;
    ldefoklassetreturnstlrec       okl_asset_returns_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_asset_returns_tl_rec	IN okl_asset_returns_tl_rec_type,
      x_okl_asset_returns_tl_rec	OUT NOCOPY okl_asset_returns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_asset_returns_tl_rec     okl_asset_returns_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_asset_returns_tl_rec := p_okl_asset_returns_tl_rec;
      -- Get current database values
      l_okl_asset_returns_tl_rec := get_rec(p_okl_asset_returns_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_asset_returns_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_asset_returns_tl_rec.id := l_okl_asset_returns_tl_rec.id;
      END IF;
      IF (x_okl_asset_returns_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_returns_tl_rec.language := l_okl_asset_returns_tl_rec.language;
      END IF;
      IF (x_okl_asset_returns_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_returns_tl_rec.source_lang := l_okl_asset_returns_tl_rec.source_lang;
      END IF;
      IF (x_okl_asset_returns_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_returns_tl_rec.sfwt_flag := l_okl_asset_returns_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_asset_returns_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_returns_tl_rec.comments := l_okl_asset_returns_tl_rec.comments;
      END IF;
      IF (x_okl_asset_returns_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_asset_returns_tl_rec.created_by := l_okl_asset_returns_tl_rec.created_by;
      END IF;
      IF (x_okl_asset_returns_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_asset_returns_tl_rec.creation_date := l_okl_asset_returns_tl_rec.creation_date;
      END IF;
      IF (x_okl_asset_returns_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_asset_returns_tl_rec.last_updated_by := l_okl_asset_returns_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_asset_returns_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_asset_returns_tl_rec.last_update_date := l_okl_asset_returns_tl_rec.last_update_date;
      END IF;
      IF (x_okl_asset_returns_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_asset_returns_tl_rec.last_update_login := l_okl_asset_returns_tl_rec.last_update_login;
      END IF;

      IF (x_okl_asset_returns_tl_rec.new_item_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_asset_returns_tl_rec.new_item_description := l_okl_asset_returns_tl_rec.new_item_description;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ASSET_RETURNS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_asset_returns_tl_rec IN  okl_asset_returns_tl_rec_type,
      x_okl_asset_returns_tl_rec OUT NOCOPY okl_asset_returns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_asset_returns_tl_rec := p_okl_asset_returns_tl_rec;
      x_okl_asset_returns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_asset_returns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_asset_returns_tl_rec,        -- IN
      l_okl_asset_returns_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_asset_returns_tl_rec, ldefoklassetreturnstlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ASSET_RETURNS_TL
    SET COMMENTS = ldefoklassetreturnstlrec.comments,
        SOURCE_LANG = ldefoklassetreturnstlrec.source_lang, --Fix for bug 3637102
        CREATED_BY = ldefoklassetreturnstlrec.created_by,
        CREATION_DATE = ldefoklassetreturnstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklassetreturnstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklassetreturnstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklassetreturnstlrec.last_update_login,
        NEW_ITEM_DESCRIPTION = ldefoklassetreturnstlrec.new_item_description
    WHERE ID = ldefoklassetreturnstlrec.id
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);-- Fix for bug 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_ASSET_RETURNS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklassetreturnstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_asset_returns_tl_rec := ldefoklassetreturnstlrec;
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
  -- update_row for:OKL_ASSET_RETURNS_V --
  ----------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : for OKL_ASSET_RETURNS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_rec                     IN artv_rec_type,
    x_artv_rec                     OUT NOCOPY artv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_artv_rec                     artv_rec_type := p_artv_rec;
    l_def_artv_rec                 artv_rec_type;
    l_okl_asset_returns_tl_rec     okl_asset_returns_tl_rec_type;
    lx_okl_asset_returns_tl_rec    okl_asset_returns_tl_rec_type;
    l_art_rec                      art_rec_type;
    lx_art_rec                     art_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_artv_rec	IN artv_rec_type
    ) RETURN artv_rec_type IS
      l_artv_rec	artv_rec_type := p_artv_rec;
    BEGIN
      l_artv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_artv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_artv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_artv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_artv_rec	IN artv_rec_type,
      x_artv_rec	OUT NOCOPY artv_rec_type
    ) RETURN VARCHAR2 IS
      l_artv_rec                     artv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_artv_rec := p_artv_rec;
      -- Get current database values
      l_artv_rec := get_rec(p_artv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_artv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.id := l_artv_rec.id;
      END IF;
      IF (x_artv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.object_version_number := l_artv_rec.object_version_number;
      END IF;
      IF (x_artv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.sfwt_flag := l_artv_rec.sfwt_flag;
      END IF;
      IF (x_artv_rec.rmr_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.rmr_id := l_artv_rec.rmr_id;
      END IF;
      IF (x_artv_rec.imr_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.imr_id := l_artv_rec.imr_id;
      END IF;
      IF (x_artv_rec.rna_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.rna_id := l_artv_rec.rna_id;
      END IF;
      IF (x_artv_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.kle_id := l_artv_rec.kle_id;
      END IF;
      IF (x_artv_rec.iso_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.iso_id := l_artv_rec.iso_id;
      END IF;
      IF (x_artv_rec.security_dep_trx_ap_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.security_dep_trx_ap_id := l_artv_rec.security_dep_trx_ap_id;
      END IF;
      IF (x_artv_rec.ars_code = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.ars_code := l_artv_rec.ars_code;
      END IF;
      IF (x_artv_rec.art1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.art1_code := l_artv_rec.art1_code;
      END IF;
      IF (x_artv_rec.date_returned = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.date_returned := l_artv_rec.date_returned;
      END IF;
      IF (x_artv_rec.date_title_returned = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.date_title_returned := l_artv_rec.date_title_returned;
      END IF;
      IF (x_artv_rec.date_return_due = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.date_return_due := l_artv_rec.date_return_due;
      END IF;
      IF (x_artv_rec.date_return_notified = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.date_return_notified := l_artv_rec.date_return_notified;
      END IF;
      IF (x_artv_rec.relocate_asset_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.relocate_asset_yn := l_artv_rec.relocate_asset_yn;
      END IF;
      IF (x_artv_rec.voluntary_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.voluntary_yn := l_artv_rec.voluntary_yn;
      END IF;
      IF (x_artv_rec.date_repossession_required = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.date_repossession_required := l_artv_rec.date_repossession_required;
      END IF;
      IF (x_artv_rec.date_repossession_actual = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.date_repossession_actual := l_artv_rec.date_repossession_actual;
      END IF;
      IF (x_artv_rec.date_hold_until = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.date_hold_until := l_artv_rec.date_hold_until;
      END IF;
      IF (x_artv_rec.commmercially_reas_sale_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.commmercially_reas_sale_yn := l_artv_rec.commmercially_reas_sale_yn;
      END IF;
      IF (x_artv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.comments := l_artv_rec.comments;
      END IF;
      IF (x_artv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute_category := l_artv_rec.attribute_category;
      END IF;
      IF (x_artv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute1 := l_artv_rec.attribute1;
      END IF;
      IF (x_artv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute2 := l_artv_rec.attribute2;
      END IF;
      IF (x_artv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute3 := l_artv_rec.attribute3;
      END IF;
      IF (x_artv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute4 := l_artv_rec.attribute4;
      END IF;
      IF (x_artv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute5 := l_artv_rec.attribute5;
      END IF;
      IF (x_artv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute6 := l_artv_rec.attribute6;
      END IF;
      IF (x_artv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute7 := l_artv_rec.attribute7;
      END IF;
      IF (x_artv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute8 := l_artv_rec.attribute8;
      END IF;
      IF (x_artv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute9 := l_artv_rec.attribute9;
      END IF;
      IF (x_artv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute10 := l_artv_rec.attribute10;
      END IF;
      IF (x_artv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute11 := l_artv_rec.attribute11;
      END IF;
      IF (x_artv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute12 := l_artv_rec.attribute12;
      END IF;
      IF (x_artv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute13 := l_artv_rec.attribute13;
      END IF;
      IF (x_artv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute14 := l_artv_rec.attribute14;
      END IF;
      IF (x_artv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.attribute15 := l_artv_rec.attribute15;
      END IF;
      IF (x_artv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.org_id := l_artv_rec.org_id;
      END IF;
      IF (x_artv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.request_id := l_artv_rec.request_id;
      END IF;
      IF (x_artv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.program_application_id := l_artv_rec.program_application_id;
      END IF;
      IF (x_artv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.program_id := l_artv_rec.program_id;
      END IF;
      IF (x_artv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.program_update_date := l_artv_rec.program_update_date;
      END IF;
      IF (x_artv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.created_by := l_artv_rec.created_by;
      END IF;
      IF (x_artv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.creation_date := l_artv_rec.creation_date;
      END IF;
      IF (x_artv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.last_updated_by := l_artv_rec.last_updated_by;
      END IF;
      IF (x_artv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.last_update_date := l_artv_rec.last_update_date;
      END IF;
      IF (x_artv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.last_update_login := l_artv_rec.last_update_login;
      END IF;

      IF (x_artv_rec.floor_price = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.floor_price := l_artv_rec.floor_price;
      END IF;
      IF (x_artv_rec.new_item_price = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.new_item_price := l_artv_rec.new_item_price;
      END IF;

      -- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number
      IF (x_artv_rec.new_item_number = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.new_item_number := l_artv_rec.new_item_number;
      END IF;

      IF (x_artv_rec.asset_relocated_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.asset_relocated_yn := l_artv_rec.asset_relocated_yn;
      END IF;
      IF (x_artv_rec.new_item_description = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.new_item_description := l_artv_rec.new_item_description;
      END IF;
      IF (x_artv_rec.repurchase_agmt_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.repurchase_agmt_yn := l_artv_rec.repurchase_agmt_yn;
      END IF;
      IF (x_artv_rec.like_kind_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.like_kind_yn := l_artv_rec.like_kind_yn;
      END IF;

  -- RABHUPAT - 2667636 - Start
     IF (x_artv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.currency_code := l_artv_rec.currency_code;
      END IF;
      IF (x_artv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.currency_conversion_code := l_artv_rec.currency_conversion_code;
      END IF;
      IF (x_artv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_artv_rec.currency_conversion_type := l_artv_rec.currency_conversion_type;
      END IF;
      IF (x_artv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.currency_conversion_rate := l_artv_rec.currency_conversion_rate;
      END IF;
      IF (x_artv_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_artv_rec.currency_conversion_date := l_artv_rec.currency_conversion_date;
      END IF;
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR Legal Entity Changes
      IF (x_artv_rec.legal_entity_id = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.legal_entity_id := l_artv_rec.legal_entity_id;
      END IF;
  -- Legal Entity Changes End
 -- DJANASWA Loan Repossession proj start
      IF (x_artv_rec.ASSET_FMV_AMOUNT = OKC_API.G_MISS_NUM)
      THEN
        x_artv_rec.ASSET_FMV_AMOUNT := l_artv_rec.ASSET_FMV_AMOUNT;
      END IF;
  --   Loan Repossession proj end
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_ASSET_RETURNS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_artv_rec IN  artv_rec_type,
      x_artv_rec OUT NOCOPY artv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_artv_rec := p_artv_rec;
      x_artv_rec.OBJECT_VERSION_NUMBER := NVL(x_artv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_artv_rec,                        -- IN
      l_artv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_artv_rec, l_def_artv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_artv_rec := fill_who_columns(l_def_artv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_artv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_artv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_artv_rec, l_okl_asset_returns_tl_rec);
    migrate(l_def_artv_rec, l_art_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_asset_returns_tl_rec,
      lx_okl_asset_returns_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_asset_returns_tl_rec, l_def_artv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_art_rec,
      lx_art_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_art_rec, l_def_artv_rec);
    x_artv_rec := l_def_artv_rec;
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
  -- PL/SQL TBL update_row for:ARTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_tbl                     IN artv_tbl_type,
    x_artv_tbl                     OUT NOCOPY artv_tbl_type) IS

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
    IF (p_artv_tbl.COUNT > 0) THEN
      i := p_artv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_artv_rec                     => p_artv_tbl(i),
          x_artv_rec                     => x_artv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_artv_tbl.LAST);
        i := p_artv_tbl.NEXT(i);
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
  -- delete_row for:OKL_ASSET_RETURNS_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_art_rec                      IN art_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_art_rec                      art_rec_type:= p_art_rec;
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
    DELETE FROM OKL_ASSET_RETURNS_B
     WHERE ID = l_art_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKL_ASSET_RETURNS_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_asset_returns_tl_rec     IN okl_asset_returns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_asset_returns_tl_rec     okl_asset_returns_tl_rec_type:= p_okl_asset_returns_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ASSET_RETURNS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_asset_returns_tl_rec IN  okl_asset_returns_tl_rec_type,
      x_okl_asset_returns_tl_rec OUT NOCOPY okl_asset_returns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_asset_returns_tl_rec := p_okl_asset_returns_tl_rec;
      x_okl_asset_returns_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_asset_returns_tl_rec,        -- IN
      l_okl_asset_returns_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_ASSET_RETURNS_TL
     WHERE ID = l_okl_asset_returns_tl_rec.id;

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
  -- delete_row for:OKL_ASSET_RETURNS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_rec                     IN artv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_artv_rec                     artv_rec_type := p_artv_rec;
    l_okl_asset_returns_tl_rec     okl_asset_returns_tl_rec_type;
    l_art_rec                      art_rec_type;
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
    migrate(l_artv_rec, l_okl_asset_returns_tl_rec);
    migrate(l_artv_rec, l_art_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_asset_returns_tl_rec
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
      l_art_rec
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
  -- PL/SQL TBL delete_row for:ARTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_tbl                     IN artv_tbl_type) IS

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
    IF (p_artv_tbl.COUNT > 0) THEN
      i := p_artv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_artv_rec                     => p_artv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_artv_tbl.LAST);
        i := p_artv_tbl.NEXT(i);
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
END OKL_ART_PVT;

/
