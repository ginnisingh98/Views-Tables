--------------------------------------------------------
--  DDL for Package Body OKL_RAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RAS_PVT" AS
/* $Header: OKLSRASB.pls 120.5 2007/08/08 12:50:12 arajagop noship $ */


  ----------------------------------------
  -- GLOBAL CONSTANTS
  -- Post-Generation Change
  -- By RMUNJULU on 16-APR-2001
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
  -- History         : RABHUPAT 17-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_record(p_rasv_rec      IN  rasv_rec_type,
                                     x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- If transaction currency <> functional currency, then conversion columns
    -- are mandatory
    IF (p_rasv_rec.currency_code <> p_rasv_rec.currency_conversion_code) THEN
      IF (p_rasv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR OR
         p_rasv_rec.currency_conversion_type IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_type');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_rasv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM OR
         p_rasv_rec.currency_conversion_rate IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_rate');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_rasv_rec.currency_conversion_date = OKC_API.G_MISS_DATE OR
         p_rasv_rec.currency_conversion_date IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_date');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    -- Else If transaction currency = functional currency, then conversion columns
    -- should all be NULL
    ELSIF (p_rasv_rec.currency_code = p_rasv_rec.currency_conversion_code) THEN
      IF (p_rasv_rec.currency_conversion_type IS NOT NULL) OR
         (p_rasv_rec.currency_conversion_rate IS NOT NULL) OR
         (p_rasv_rec.currency_conversion_date IS NOT NULL) THEN
        --SET MESSAGE
        -- Currency conversion columns should be all null
        IF p_rasv_rec.currency_conversion_rate IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_rate');
        END IF;
        IF p_rasv_rec.currency_conversion_date IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_date');
        END IF;
        IF p_rasv_rec.currency_conversion_type IS NOT NULL THEN
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
  -- History         : RABHUPAT 17-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_code(p_rasv_rec      IN  rasv_rec_type,
                                   x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_rasv_rec.currency_code IS NULL) OR
       (p_rasv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_code');

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_rasv_rec.currency_code);
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
  -- History         : RABHUPAT 17-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_code(p_rasv_rec      IN  rasv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_rasv_rec.currency_conversion_code IS NULL) OR
       (p_rasv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_conversion_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_rasv_rec.currency_conversion_code);
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
  -- History         : RABHUPAT 17-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_type(p_rasv_rec      IN  rasv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_rasv_rec.currency_conversion_type <> OKL_API.G_MISS_CHAR AND
       p_rasv_rec.currency_conversion_type IS NOT NULL) THEN
      -- check from currency values using the generic okl_util.validate_currency_code
      l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_con_type(p_rasv_rec.currency_conversion_type);
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
  -- By RMUNJULU on 16-APR-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_id(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rasv_rec		IN	rasv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
	IF (p_rasv_rec.id = OKC_API.G_MISS_NUM OR p_rasv_rec.id IS NULL) THEN
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
  -- By RMUNJULU on 16-APR-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_object_version_number(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rasv_rec		IN	rasv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rasv_rec.object_version_number IS NULL)
	OR (p_rasv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
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
  -- By RMUNJULU on 16-APR-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_sfwt_flag(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rasv_rec		IN	rasv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rasv_rec.sfwt_flag IS NULL)
	OR (p_rasv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
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
  -- PROCEDURE validate_org_id : Use the standard check_org_id() function
  -- Post-Generation Change
  -- By RMUNJULU on 16-APR-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_org_id(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rasv_rec		IN	rasv_rec_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check org id validity using the generic function okl_util.check_org_id()
    l_return_status := OKL_UTIL.check_org_id (p_rasv_rec.org_id);

    IF ( l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'org_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

     ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
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

  END validate_org_id;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_date_ship_instr_sen
  -- Post-Generation Change
  -- By RMUNJULU on 16-APR-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_date_ship_instr_sen(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rasv_rec		IN	rasv_rec_type) IS
    l_sysdate   DATE := OKC_API.G_MISS_DATE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- get sysdate
    SELECT  SYSDATE
    INTO	l_sysdate
    FROM	DUAL;

    -- date_shipping_instructions_sen cannot be greater then sys date
    IF (p_rasv_rec.date_shipping_instructions_sen IS NOT NULL) AND
       (l_sysdate <> OKC_API.G_MISS_DATE) AND
       (p_rasv_rec.date_shipping_instructions_sen > l_sysdate) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'date_shipping_instructions_sen');

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

  END validate_date_ship_instr_sen;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_ist_fkey	: Enforce foreign key
  -- Post-Generation Change
  -- By RMUNJULU on 16-APR-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_ist_fkey(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rasv_rec		IN	rasv_rec_type) IS
    /*-- Check here --
    CURSOR  l_ist_csr  IS
      SELECT 'x'
      FROM   OKX_SHIP_TOS_V
      WHERE  id = p_rasv_rec.ist_id;

     l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy_var                 VARCHAR2(1) := '?';
	*/
  BEGIN
    NULL;
 	/*
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_rasv_rec.ist_id IS NOT NULL) THEN
      OPEN  l_ist_csr;
      FETCH l_ist_csr INTO l_dummy_var;
      CLOSE l_ist_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'ist_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_RELOCATE_ASSETS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKX_SHIP_TOS_V');

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
      IF l_ist_csr%ISOPEN THEN
        CLOSE l_ist_csr;
      END IF;
	*/
  END validate_ist_fkey;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_pac_fkey	: Enforce foreign key
  -- Post-Generation Change
  -- By RMUNJULU on 16-APR-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_pac_fkey(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rasv_rec		IN	rasv_rec_type) IS
    /*-- Check here --
     CURSOR  l_pac_csr  IS
      SELECT 'x'
      FROM   OKX_PTY_CUS_ACT_CTS_V
      WHERE  ID = p_rasv_rec.pac_id;

     l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy_var                 VARCHAR2(1) := '?';
	*/
  BEGIN
    NULL;
 	/*
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_rasv_rec.pac_id IS NOT NULL) THEN
      OPEN  l_pac_csr;
      FETCH l_pac_csr INTO l_dummy_var;
      CLOSE l_pac_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'pac_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_RELOCATE_ASSETS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKX_PTY_CUS_ACT_CTS_V');

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
      IF l_pac_csr%ISOPEN THEN
        CLOSE l_pac_csr;
      END IF;
	*/
  END validate_pac_fkey;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_art_fkey	: Enforce foreign key
  -- Post-Generation Change
  -- By RMUNJULU on 16-APR-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_art_fkey(
	x_return_status OUT NOCOPY VARCHAR2,
	p_rasv_rec		IN	rasv_rec_type) IS

	CURSOR  l_art_csr IS
      SELECT  'x'
      FROM   OKL_ASSET_RETURNS_V
      WHERE  ID = p_rasv_rec.art_id;

     l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy_var                 VARCHAR2(1) := '?';

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF (p_rasv_rec.art_id IS NOT NULL) THEN
      OPEN  l_art_csr;
      FETCH l_art_csr INTO l_dummy_var;
      CLOSE l_art_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'art_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_RELOCATE_ASSETS_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKL_ASSET_RETURNS_V');

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
      IF l_art_csr%ISOPEN THEN
        CLOSE l_art_csr;
      END IF;

  END validate_art_fkey;


  ------------------------------------------------------------------------
  -- PROCEDURE validate_trans_opt_acc_yn
  -- Post-Generation Change
  -- By RMUNJULU on 27-SEP-2001
  ------------------------------------------------------------------------

  PROCEDURE validate_trans_opt_acc_yn (
    x_return_status    OUT NOCOPY VARCHAR2,
    p_rasv_rec         IN rasv_rec_type ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- intialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic okl_util.check_domain_yn
    l_return_status := OKL_UTIL.check_domain_yn(p_rasv_rec.trans_option_accepted_yn);


    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_invalid_value,
                           p_token1       => g_col_name_token,
                           p_token1_value => 'trans_option_accepted_yn');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
       raise G_EXCEPTION_HALT_VALIDATION;

    ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;

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

  END validate_trans_opt_acc_yn;
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
    DELETE FROM OKL_RELOCATE_ASSETS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_RELOCATE_ASTS_ALL_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKL_RELOCATE_ASSETS_TL T SET (
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKL_RELOCATE_ASSETS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_RELOCATE_ASSETS_TL SUBB, OKL_RELOCATE_ASSETS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

    INSERT INTO OKL_RELOCATE_ASSETS_TL (
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
        FROM OKL_RELOCATE_ASSETS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_RELOCATE_ASSETS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_RELOCATE_ASSETS_B
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : get_rec
  -- Description     : for: OKL_RELOCATE_ASSETS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION get_rec (
    p_ras_rec                      IN ras_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ras_rec_type IS
    CURSOR okl_relocate_assets_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            IST_ID,
            PAC_ID,
            ART_ID,
            OBJECT_VERSION_NUMBER,
            DATE_SHIPPING_INSTRUCTIONS_SEN,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            TRANS_OPTION_ACCEPTED_YN,
            INSURANCE_AMOUNT,
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
      FROM Okl_Relocate_Assets_B
     WHERE okl_relocate_assets_b.id = p_id;
    l_okl_relocate_assets_b_pk     okl_relocate_assets_b_pk_csr%ROWTYPE;
    l_ras_rec                      ras_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_relocate_assets_b_pk_csr (p_ras_rec.id);
    FETCH okl_relocate_assets_b_pk_csr INTO
              l_ras_rec.ID,
              l_ras_rec.IST_ID,
              l_ras_rec.PAC_ID,
              l_ras_rec.ART_ID,
              l_ras_rec.OBJECT_VERSION_NUMBER,
              l_ras_rec.DATE_SHIPPING_INSTRUCTIONS_SEN,
              l_ras_rec.ORG_ID,
              l_ras_rec.REQUEST_ID,
              l_ras_rec.PROGRAM_APPLICATION_ID,
              l_ras_rec.PROGRAM_ID,
              l_ras_rec.PROGRAM_UPDATE_DATE,
              l_ras_rec.TRANS_OPTION_ACCEPTED_YN,
              l_ras_rec.INSURANCE_AMOUNT,
              l_ras_rec.ATTRIBUTE_CATEGORY,
              l_ras_rec.ATTRIBUTE1,
              l_ras_rec.ATTRIBUTE2,
              l_ras_rec.ATTRIBUTE3,
              l_ras_rec.ATTRIBUTE4,
              l_ras_rec.ATTRIBUTE5,
              l_ras_rec.ATTRIBUTE6,
              l_ras_rec.ATTRIBUTE7,
              l_ras_rec.ATTRIBUTE8,
              l_ras_rec.ATTRIBUTE9,
              l_ras_rec.ATTRIBUTE10,
              l_ras_rec.ATTRIBUTE11,
              l_ras_rec.ATTRIBUTE12,
              l_ras_rec.ATTRIBUTE13,
              l_ras_rec.ATTRIBUTE14,
              l_ras_rec.ATTRIBUTE15,
              l_ras_rec.CREATED_BY,
              l_ras_rec.CREATION_DATE,
              l_ras_rec.LAST_UPDATED_BY,
              l_ras_rec.LAST_UPDATE_DATE,
              l_ras_rec.LAST_UPDATE_LOGIN,
  -- RABHUPAT - 2667636 - Start
              l_ras_rec.CURRENCY_CODE,
              l_ras_rec.CURRENCY_CONVERSION_CODE,
              l_ras_rec.CURRENCY_CONVERSION_TYPE,
              l_ras_rec.CURRENCY_CONVERSION_RATE,
              l_ras_rec.CURRENCY_CONVERSION_DATE;
  -- RABHUPAT - 2667636 - End
    x_no_data_found := okl_relocate_assets_b_pk_csr%NOTFOUND;
    CLOSE okl_relocate_assets_b_pk_csr;
    RETURN(l_ras_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ras_rec                      IN ras_rec_type
  ) RETURN ras_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ras_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_RELOCATE_ASSETS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_relocate_assets_tl_rec   IN OklRelocateAssetsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklRelocateAssetsTlRecType IS
    CURSOR okl_relocate_assets_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Relocate_Assets_Tl
     WHERE okl_relocate_assets_tl.id = p_id
       AND okl_relocate_assets_tl.language = p_language;
    l_okl_relocate_assets_tl_pk    okl_relocate_assets_tl_pk_csr%ROWTYPE;
    l_okl_relocate_assets_tl_rec   OklRelocateAssetsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_relocate_assets_tl_pk_csr (p_okl_relocate_assets_tl_rec.id,
                                        p_okl_relocate_assets_tl_rec.language);
    FETCH okl_relocate_assets_tl_pk_csr INTO
              l_okl_relocate_assets_tl_rec.ID,
              l_okl_relocate_assets_tl_rec.LANGUAGE,
              l_okl_relocate_assets_tl_rec.SOURCE_LANG,
              l_okl_relocate_assets_tl_rec.SFWT_FLAG,
              l_okl_relocate_assets_tl_rec.COMMENTS,
              l_okl_relocate_assets_tl_rec.CREATED_BY,
              l_okl_relocate_assets_tl_rec.CREATION_DATE,
              l_okl_relocate_assets_tl_rec.LAST_UPDATED_BY,
              l_okl_relocate_assets_tl_rec.LAST_UPDATE_DATE,
              l_okl_relocate_assets_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_relocate_assets_tl_pk_csr%NOTFOUND;
    CLOSE okl_relocate_assets_tl_pk_csr;
    RETURN(l_okl_relocate_assets_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_relocate_assets_tl_rec   IN OklRelocateAssetsTlRecType
  ) RETURN OklRelocateAssetsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_relocate_assets_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_RELOCATE_ASSETS_V
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : get_rec
  -- Description     : for: OKL_RELOCATE_ASSETS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION get_rec (
    p_rasv_rec                     IN rasv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rasv_rec_type IS
    CURSOR okl_rasv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            ART_ID,
            PAC_ID,
            IST_ID,
            DATE_SHIPPING_INSTRUCTIONS_SEN,
            COMMENTS,
            TRANS_OPTION_ACCEPTED_YN,
            INSURANCE_AMOUNT,
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
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
  -- RABHUPAT - 2667636 - Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
  -- RABHUPAT - 2667636 - End
      FROM Okl_Relocate_Assets_V
     WHERE okl_relocate_assets_v.id = p_id;
    l_okl_rasv_pk                  okl_rasv_pk_csr%ROWTYPE;
    l_rasv_rec                     rasv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_rasv_pk_csr (p_rasv_rec.id);
    FETCH okl_rasv_pk_csr INTO
              l_rasv_rec.ID,
              l_rasv_rec.OBJECT_VERSION_NUMBER,
              l_rasv_rec.SFWT_FLAG,
              l_rasv_rec.ART_ID,
              l_rasv_rec.PAC_ID,
              l_rasv_rec.IST_ID,
              l_rasv_rec.DATE_SHIPPING_INSTRUCTIONS_SEN,
              l_rasv_rec.COMMENTS,
              l_rasv_rec.TRANS_OPTION_ACCEPTED_YN,
              l_rasv_rec.INSURANCE_AMOUNT,
              l_rasv_rec.ATTRIBUTE_CATEGORY,
              l_rasv_rec.ATTRIBUTE1,
              l_rasv_rec.ATTRIBUTE2,
              l_rasv_rec.ATTRIBUTE3,
              l_rasv_rec.ATTRIBUTE4,
              l_rasv_rec.ATTRIBUTE5,
              l_rasv_rec.ATTRIBUTE6,
              l_rasv_rec.ATTRIBUTE7,
              l_rasv_rec.ATTRIBUTE8,
              l_rasv_rec.ATTRIBUTE9,
              l_rasv_rec.ATTRIBUTE10,
              l_rasv_rec.ATTRIBUTE11,
              l_rasv_rec.ATTRIBUTE12,
              l_rasv_rec.ATTRIBUTE13,
              l_rasv_rec.ATTRIBUTE14,
              l_rasv_rec.ATTRIBUTE15,
              l_rasv_rec.ORG_ID,
              l_rasv_rec.REQUEST_ID,
              l_rasv_rec.PROGRAM_APPLICATION_ID,
              l_rasv_rec.PROGRAM_ID,
              l_rasv_rec.PROGRAM_UPDATE_DATE,
              l_rasv_rec.CREATED_BY,
              l_rasv_rec.CREATION_DATE,
              l_rasv_rec.LAST_UPDATED_BY,
              l_rasv_rec.LAST_UPDATE_LOGIN,
              l_rasv_rec.LAST_UPDATE_DATE,
  -- RABHUPAT - 2667636 - Start
              l_rasv_rec.CURRENCY_CODE,
              l_rasv_rec.CURRENCY_CONVERSION_CODE,
              l_rasv_rec.CURRENCY_CONVERSION_TYPE,
              l_rasv_rec.CURRENCY_CONVERSION_RATE,
              l_rasv_rec.CURRENCY_CONVERSION_DATE;
  -- RABHUPAT - 2667636 - End
    x_no_data_found := okl_rasv_pk_csr%NOTFOUND;
    CLOSE okl_rasv_pk_csr;
    RETURN(l_rasv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rasv_rec                     IN rasv_rec_type
  ) RETURN rasv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rasv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_RELOCATE_ASSETS_V --
  -----------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : null_out_defaults
  -- Description     : for: OKL_RELOCATE_ASSETS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION null_out_defaults (
    p_rasv_rec	IN rasv_rec_type
  ) RETURN rasv_rec_type IS
    l_rasv_rec	rasv_rec_type := p_rasv_rec;
  BEGIN
    IF (l_rasv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.object_version_number := NULL;
    END IF;
    IF (l_rasv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_rasv_rec.art_id = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.art_id := NULL;
    END IF;
    IF (l_rasv_rec.pac_id = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.pac_id := NULL;
    END IF;
    IF (l_rasv_rec.ist_id = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.ist_id := NULL;
    END IF;
    IF (l_rasv_rec.date_shipping_instructions_sen = OKC_API.G_MISS_DATE) THEN
      l_rasv_rec.date_shipping_instructions_sen := NULL;
    END IF;
    IF (l_rasv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.comments := NULL;
    END IF;
    IF (l_rasv_rec.trans_option_accepted_yn = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.trans_option_accepted_yn := NULL;
    END IF;
    IF (l_rasv_rec.insurance_amount = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.insurance_amount := NULL;
    END IF;
    IF (l_rasv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute_category := NULL;
    END IF;
    IF (l_rasv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute1 := NULL;
    END IF;
    IF (l_rasv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute2 := NULL;
    END IF;
    IF (l_rasv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute3 := NULL;
    END IF;
    IF (l_rasv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute4 := NULL;
    END IF;
    IF (l_rasv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute5 := NULL;
    END IF;
    IF (l_rasv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute6 := NULL;
    END IF;
    IF (l_rasv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute7 := NULL;
    END IF;
    IF (l_rasv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute8 := NULL;
    END IF;
    IF (l_rasv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute9 := NULL;
    END IF;
    IF (l_rasv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute10 := NULL;
    END IF;
    IF (l_rasv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute11 := NULL;
    END IF;
    IF (l_rasv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute12 := NULL;
    END IF;
    IF (l_rasv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute13 := NULL;
    END IF;
    IF (l_rasv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute14 := NULL;
    END IF;
    IF (l_rasv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.attribute15 := NULL;
    END IF;
    IF (l_rasv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.org_id := NULL;
    END IF;
/* -- post gen change
    IF (l_rasv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.request_id := NULL;
    END IF;
    IF (l_rasv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.program_application_id := NULL;
    END IF;
    IF (l_rasv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.program_id := NULL;
    END IF;
    IF (l_rasv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_rasv_rec.program_update_date := NULL;
    END IF;
*/
    IF (l_rasv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.created_by := NULL;
    END IF;
    IF (l_rasv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_rasv_rec.creation_date := NULL;
    END IF;
    IF (l_rasv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rasv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.last_update_login := NULL;
    END IF;
    IF (l_rasv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_rasv_rec.last_update_date := NULL;
    END IF;
  -- RABHUPAT - 2667636 -Start
    IF (l_rasv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.currency_code := NULL;
    END IF;
    IF (l_rasv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.currency_conversion_code := NULL;
    END IF;
    IF (l_rasv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
      l_rasv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_rasv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
      l_rasv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_rasv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
      l_rasv_rec.currency_conversion_date := NULL;
    END IF;
  -- RABHUPAT - 2667636 -End
    RETURN(l_rasv_rec);
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
  -- Description     : for:OKL_RELOCATE_ASSETS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments

  FUNCTION validate_attributes(p_rasv_rec IN  rasv_rec_type)
    RETURN VARCHAR2 IS

    x_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call column-level validation for 'id'
    validate_id(x_return_status => l_return_status,
                p_rasv_rec      => p_rasv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'object_version_number'
    validate_object_version_number(x_return_status => l_return_status,
                 				   p_rasv_rec      => p_rasv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'sfwt_flag'
    validate_sfwt_flag(x_return_status => l_return_status,
                 	   p_rasv_rec      => p_rasv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'org_id'
    validate_org_id(x_return_status => l_return_status,
                 	   p_rasv_rec      => p_rasv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'date_shipping_instructions_sen'
    validate_date_ship_instr_sen(x_return_status => l_return_status,
                 	   						p_rasv_rec      => p_rasv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

	-- call foreign key validation for 'ist_id'
    validate_ist_fkey(x_return_status => l_return_status,
                 	  p_rasv_rec      => p_rasv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

	-- call foreign key validation for 'pac_id'
    validate_pac_fkey(x_return_status => l_return_status,
                 	  p_rasv_rec      => p_rasv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

	-- call foreign key validation for 'art_id'
    validate_art_fkey(x_return_status => l_return_status,
                 	  p_rasv_rec      => p_rasv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

	-- call validation for 'trans_option_accepted_yn'
    validate_trans_opt_acc_yn(x_return_status => l_return_status,
                        	  p_rasv_rec      => p_rasv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

  -- RABHUPAT - 2667636 - Start
    validate_currency_code(p_rasv_rec      => p_rasv_rec,
                           x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_code(p_rasv_rec      => p_rasv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_type(p_rasv_rec      => p_rasv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- RABHUPAT - 2667636 - End

    -- return status to caller
    RETURN x_return_status;

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

      -- return status to caller
      RETURN x_return_status;

  END validate_attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_RELOCATE_ASSETS_V --
  -----------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : Validate_Record
  -- Description     : for:OKL_RELOCATE_ASSETS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION Validate_Record (
    p_rasv_rec IN rasv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     x_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
  -- RABHUPAT - 2667636 - Start
    -- Validate Currency conversion Code,type,rate and Date

    validate_currency_record(p_rasv_rec      => p_rasv_rec,
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
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE migrate (
    p_from	IN rasv_rec_type,
    p_to	IN OUT NOCOPY ras_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ist_id := p_from.ist_id;
    p_to.pac_id := p_from.pac_id;
    p_to.art_id := p_from.art_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_shipping_instructions_sen := p_from.date_shipping_instructions_sen;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.trans_option_accepted_yn := p_from.trans_option_accepted_yn;
    p_to.insurance_amount := p_from.insurance_amount;
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
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE migrate (
    p_from	IN ras_rec_type,
    p_to	IN OUT NOCOPY rasv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ist_id := p_from.ist_id;
    p_to.pac_id := p_from.pac_id;
    p_to.art_id := p_from.art_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_shipping_instructions_sen := p_from.date_shipping_instructions_sen;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.trans_option_accepted_yn := p_from.trans_option_accepted_yn;
    p_to.insurance_amount := p_from.insurance_amount;
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
    p_from	IN rasv_rec_type,
    p_to	IN OUT NOCOPY OklRelocateAssetsTlRecType
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
    p_from	IN OklRelocateAssetsTlRecType,
    p_to	IN OUT NOCOPY rasv_rec_type
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
  --------------------------------------------
  -- validate_row for:OKL_RELOCATE_ASSETS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_rec                     IN rasv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rasv_rec                     rasv_rec_type := p_rasv_rec;
    l_ras_rec                      ras_rec_type;
    l_okl_relocate_assets_tl_rec   OklRelocateAssetsTlRecType;
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
    l_return_status := Validate_Attributes(l_rasv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rasv_rec);
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
  -- PL/SQL TBL validate_row for:RASV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_tbl                     IN rasv_tbl_type) IS

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
    IF (p_rasv_tbl.COUNT > 0) THEN
      i := p_rasv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rasv_rec                     => p_rasv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rasv_tbl.LAST);
        i := p_rasv_tbl.NEXT(i);
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
  -- insert_row for:OKL_RELOCATE_ASSETS_B --
  ------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : for OKL_RELOCATE_ASSETS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ras_rec                      IN ras_rec_type,
    x_ras_rec                      OUT NOCOPY ras_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ras_rec                      ras_rec_type := p_ras_rec;
    l_def_ras_rec                  ras_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_RELOCATE_ASSETS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ras_rec IN  ras_rec_type,
      x_ras_rec OUT NOCOPY ras_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ras_rec := p_ras_rec;
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
      p_ras_rec,                         -- IN
      l_ras_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_RELOCATE_ASSETS_B(
        id,
        ist_id,
        pac_id,
        art_id,
        object_version_number,
        date_shipping_instructions_sen,
        org_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        trans_option_accepted_yn,
        insurance_amount,
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
        l_ras_rec.id,
        l_ras_rec.ist_id,
        l_ras_rec.pac_id,
        l_ras_rec.art_id,
        l_ras_rec.object_version_number,
        l_ras_rec.date_shipping_instructions_sen,
        l_ras_rec.org_id,
    	-- Begin Post-Generation Change
        /*
        l_ras_rec.request_id,
        l_ras_rec.program_application_id,
        l_ras_rec.program_id,
        l_ras_rec.program_update_date,
        */
        DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
        DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
        DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
        DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
	    -- End Post-Generation Change
        l_ras_rec.trans_option_accepted_yn,
        l_ras_rec.insurance_amount,
        l_ras_rec.attribute_category,
        l_ras_rec.attribute1,
        l_ras_rec.attribute2,
        l_ras_rec.attribute3,
        l_ras_rec.attribute4,
        l_ras_rec.attribute5,
        l_ras_rec.attribute6,
        l_ras_rec.attribute7,
        l_ras_rec.attribute8,
        l_ras_rec.attribute9,
        l_ras_rec.attribute10,
        l_ras_rec.attribute11,
        l_ras_rec.attribute12,
        l_ras_rec.attribute13,
        l_ras_rec.attribute14,
        l_ras_rec.attribute15,
        l_ras_rec.created_by,
        l_ras_rec.creation_date,
        l_ras_rec.last_updated_by,
        l_ras_rec.last_update_date,
        l_ras_rec.last_update_login,
  -- RABHUPAT - 2667636 - Start
        l_ras_rec.currency_code,
        l_ras_rec.currency_conversion_code,
        l_ras_rec.currency_conversion_type,
        l_ras_rec.currency_conversion_rate,
        l_ras_rec.currency_conversion_date);
  -- RABHUPAT - 2667636 - End
    -- Set OUT values
    x_ras_rec := l_ras_rec;
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
  -- insert_row for:OKL_RELOCATE_ASSETS_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_relocate_assets_tl_rec   IN OklRelocateAssetsTlRecType,
    x_okl_relocate_assets_tl_rec   OUT NOCOPY OklRelocateAssetsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_relocate_assets_tl_rec   OklRelocateAssetsTlRecType := p_okl_relocate_assets_tl_rec;
    ldefoklrelocateassetstlrec     OklRelocateAssetsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_RELOCATE_ASSETS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_relocate_assets_tl_rec IN  OklRelocateAssetsTlRecType,
      x_okl_relocate_assets_tl_rec OUT NOCOPY OklRelocateAssetsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_relocate_assets_tl_rec := p_okl_relocate_assets_tl_rec;
      x_okl_relocate_assets_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_relocate_assets_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_relocate_assets_tl_rec,      -- IN
      l_okl_relocate_assets_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_relocate_assets_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_RELOCATE_ASSETS_TL(
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
          l_okl_relocate_assets_tl_rec.id,
          l_okl_relocate_assets_tl_rec.language,
          l_okl_relocate_assets_tl_rec.source_lang,
          l_okl_relocate_assets_tl_rec.sfwt_flag,
          l_okl_relocate_assets_tl_rec.comments,
          l_okl_relocate_assets_tl_rec.created_by,
          l_okl_relocate_assets_tl_rec.creation_date,
          l_okl_relocate_assets_tl_rec.last_updated_by,
          l_okl_relocate_assets_tl_rec.last_update_date,
          l_okl_relocate_assets_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_relocate_assets_tl_rec := l_okl_relocate_assets_tl_rec;
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
  -- insert_row for:OKL_RELOCATE_ASSETS_V --
  ------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : for OKL_RELOCATE_ASSETS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_rec                     IN rasv_rec_type,
    x_rasv_rec                     OUT NOCOPY rasv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rasv_rec                     rasv_rec_type;
    l_def_rasv_rec                 rasv_rec_type;
    l_ras_rec                      ras_rec_type;
    lx_ras_rec                     ras_rec_type;
    l_okl_relocate_assets_tl_rec   OklRelocateAssetsTlRecType;
    lx_okl_relocate_assets_tl_rec  OklRelocateAssetsTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rasv_rec	IN rasv_rec_type
    ) RETURN rasv_rec_type IS
      l_rasv_rec	rasv_rec_type := p_rasv_rec;
    BEGIN
      l_rasv_rec.CREATION_DATE := SYSDATE;
      l_rasv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rasv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rasv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rasv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rasv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_RELOCATE_ASSETS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_rasv_rec IN  rasv_rec_type,
      x_rasv_rec OUT NOCOPY rasv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rasv_rec := p_rasv_rec;
      x_rasv_rec.OBJECT_VERSION_NUMBER := 1;
      x_rasv_rec.SFWT_FLAG := 'N';
      -- Default the ORG ID if a value is not passed
      IF p_rasv_rec.org_id IS NULL
      OR p_rasv_rec.org_id = OKC_API.G_MISS_NUM THEN
        x_rasv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      END IF;
  -- RABHUPAT - 2667636 - Start
      x_rasv_rec.currency_conversion_code := OKL_AM_UTIL_PVT.get_functional_currency;

      IF p_rasv_rec.currency_code IS NULL
      OR p_rasv_rec.currency_code = OKC_API.G_MISS_CHAR THEN
        x_rasv_rec.currency_code := x_rasv_rec.currency_conversion_code;
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
    l_rasv_rec := null_out_defaults(p_rasv_rec);
    -- Set primary key value
    l_rasv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rasv_rec,                        -- IN
      l_def_rasv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rasv_rec := fill_who_columns(l_def_rasv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rasv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rasv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rasv_rec, l_ras_rec);
    migrate(l_def_rasv_rec, l_okl_relocate_assets_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ras_rec,
      lx_ras_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ras_rec, l_def_rasv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_relocate_assets_tl_rec,
      lx_okl_relocate_assets_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_relocate_assets_tl_rec, l_def_rasv_rec);
    -- Set OUT values
    x_rasv_rec := l_def_rasv_rec;
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
  -- PL/SQL TBL insert_row for:RASV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_tbl                     IN rasv_tbl_type,
    x_rasv_tbl                     OUT NOCOPY rasv_tbl_type) IS

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
    IF (p_rasv_tbl.COUNT > 0) THEN
      i := p_rasv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rasv_rec                     => p_rasv_tbl(i),
          x_rasv_rec                     => x_rasv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rasv_tbl.LAST);
        i := p_rasv_tbl.NEXT(i);
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
  -- lock_row for:OKL_RELOCATE_ASSETS_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ras_rec                      IN ras_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ras_rec IN ras_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_RELOCATE_ASSETS_B
     WHERE ID = p_ras_rec.id
       AND OBJECT_VERSION_NUMBER = p_ras_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ras_rec IN ras_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_RELOCATE_ASSETS_B
    WHERE ID = p_ras_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_RELOCATE_ASSETS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_RELOCATE_ASSETS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ras_rec);
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
      OPEN lchk_csr(p_ras_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ras_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ras_rec.object_version_number THEN
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
  -- lock_row for:OKL_RELOCATE_ASSETS_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_relocate_assets_tl_rec   IN OklRelocateAssetsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_relocate_assets_tl_rec IN OklRelocateAssetsTlRecType) IS
    SELECT *
      FROM OKL_RELOCATE_ASSETS_TL
     WHERE ID = p_okl_relocate_assets_tl_rec.id
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
      OPEN lock_csr(p_okl_relocate_assets_tl_rec);
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
  -- lock_row for:OKL_RELOCATE_ASSETS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_rec                     IN rasv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ras_rec                      ras_rec_type;
    l_okl_relocate_assets_tl_rec   OklRelocateAssetsTlRecType;
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
    migrate(p_rasv_rec, l_ras_rec);
    migrate(p_rasv_rec, l_okl_relocate_assets_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ras_rec
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
      l_okl_relocate_assets_tl_rec
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
  -- PL/SQL TBL lock_row for:RASV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_tbl                     IN rasv_tbl_type) IS

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
    IF (p_rasv_tbl.COUNT > 0) THEN
      i := p_rasv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rasv_rec                     => p_rasv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rasv_tbl.LAST);
        i := p_rasv_tbl.NEXT(i);
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
  -- update_row for:OKL_RELOCATE_ASSETS_B --
  ------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : for OKL_RELOCATE_ASSETS_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ras_rec                      IN ras_rec_type,
    x_ras_rec                      OUT NOCOPY ras_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ras_rec                      ras_rec_type := p_ras_rec;
    l_def_ras_rec                  ras_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ras_rec	IN ras_rec_type,
      x_ras_rec	OUT NOCOPY ras_rec_type
    ) RETURN VARCHAR2 IS
      l_ras_rec                      ras_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ras_rec := p_ras_rec;
      -- Get current database values
      l_ras_rec := get_rec(p_ras_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ras_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.id := l_ras_rec.id;
      END IF;
      IF (x_ras_rec.ist_id = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.ist_id := l_ras_rec.ist_id;
      END IF;
      IF (x_ras_rec.pac_id = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.pac_id := l_ras_rec.pac_id;
      END IF;
      IF (x_ras_rec.art_id = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.art_id := l_ras_rec.art_id;
      END IF;
      IF (x_ras_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.object_version_number := l_ras_rec.object_version_number;
      END IF;
      IF (x_ras_rec.date_shipping_instructions_sen = OKC_API.G_MISS_DATE)
      THEN
        x_ras_rec.date_shipping_instructions_sen := l_ras_rec.date_shipping_instructions_sen;
      END IF;
      IF (x_ras_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.org_id := l_ras_rec.org_id;
      END IF;
      IF (x_ras_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.request_id := l_ras_rec.request_id;
      END IF;
      IF (x_ras_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.program_application_id := l_ras_rec.program_application_id;
      END IF;
      IF (x_ras_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.program_id := l_ras_rec.program_id;
      END IF;
      IF (x_ras_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ras_rec.program_update_date := l_ras_rec.program_update_date;
      END IF;
      IF (x_ras_rec.trans_option_accepted_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.trans_option_accepted_yn := l_ras_rec.trans_option_accepted_yn;
      END IF;
      IF (x_ras_rec.insurance_amount = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.insurance_amount := l_ras_rec.insurance_amount;
      END IF;
      IF (x_ras_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute_category := l_ras_rec.attribute_category;
      END IF;
      IF (x_ras_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute1 := l_ras_rec.attribute1;
      END IF;
      IF (x_ras_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute2 := l_ras_rec.attribute2;
      END IF;
      IF (x_ras_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute3 := l_ras_rec.attribute3;
      END IF;
      IF (x_ras_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute4 := l_ras_rec.attribute4;
      END IF;
      IF (x_ras_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute5 := l_ras_rec.attribute5;
      END IF;
      IF (x_ras_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute6 := l_ras_rec.attribute6;
      END IF;
      IF (x_ras_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute7 := l_ras_rec.attribute7;
      END IF;
      IF (x_ras_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute8 := l_ras_rec.attribute8;
      END IF;
      IF (x_ras_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute9 := l_ras_rec.attribute9;
      END IF;
      IF (x_ras_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute10 := l_ras_rec.attribute10;
      END IF;
      IF (x_ras_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute11 := l_ras_rec.attribute11;
      END IF;
      IF (x_ras_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute12 := l_ras_rec.attribute12;
      END IF;
      IF (x_ras_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute13 := l_ras_rec.attribute13;
      END IF;
      IF (x_ras_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute14 := l_ras_rec.attribute14;
      END IF;
      IF (x_ras_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.attribute15 := l_ras_rec.attribute15;
      END IF;
      IF (x_ras_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.created_by := l_ras_rec.created_by;
      END IF;
      IF (x_ras_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ras_rec.creation_date := l_ras_rec.creation_date;
      END IF;
      IF (x_ras_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.last_updated_by := l_ras_rec.last_updated_by;
      END IF;
      IF (x_ras_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ras_rec.last_update_date := l_ras_rec.last_update_date;
      END IF;
      IF (x_ras_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.last_update_login := l_ras_rec.last_update_login;
      END IF;
  -- RABHUPAT - 2667636 - Start
     IF (x_ras_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.currency_code := l_ras_rec.currency_code;
      END IF;
      IF (x_ras_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.currency_conversion_code := l_ras_rec.currency_conversion_code;
      END IF;
      IF (x_ras_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_ras_rec.currency_conversion_type := l_ras_rec.currency_conversion_type;
      END IF;
      IF (x_ras_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_ras_rec.currency_conversion_rate := l_ras_rec.currency_conversion_rate;
      END IF;
      IF (x_ras_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_ras_rec.currency_conversion_date := l_ras_rec.currency_conversion_date;
      END IF;
  -- RABHUPAT - 2667636 - End
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_RELOCATE_ASSETS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ras_rec IN  ras_rec_type,
      x_ras_rec OUT NOCOPY ras_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ras_rec := p_ras_rec;
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
      p_ras_rec,                         -- IN
      l_ras_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ras_rec, l_def_ras_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_RELOCATE_ASSETS_B
    SET IST_ID = l_def_ras_rec.ist_id,
        PAC_ID = l_def_ras_rec.pac_id,
        ART_ID = l_def_ras_rec.art_id,
        OBJECT_VERSION_NUMBER = l_def_ras_rec.object_version_number,
        DATE_SHIPPING_INSTRUCTIONS_SEN = l_def_ras_rec.date_shipping_instructions_sen,
        ORG_ID = l_def_ras_rec.org_id,
        REQUEST_ID = l_def_ras_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_ras_rec.program_application_id,
        PROGRAM_ID = l_def_ras_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_ras_rec.program_update_date,
        TRANS_OPTION_ACCEPTED_YN = l_def_ras_rec.trans_option_accepted_yn,
        INSURANCE_AMOUNT = l_def_ras_rec.insurance_amount,
        ATTRIBUTE_CATEGORY = l_def_ras_rec.attribute_category,
        ATTRIBUTE1 = l_def_ras_rec.attribute1,
        ATTRIBUTE2 = l_def_ras_rec.attribute2,
        ATTRIBUTE3 = l_def_ras_rec.attribute3,
        ATTRIBUTE4 = l_def_ras_rec.attribute4,
        ATTRIBUTE5 = l_def_ras_rec.attribute5,
        ATTRIBUTE6 = l_def_ras_rec.attribute6,
        ATTRIBUTE7 = l_def_ras_rec.attribute7,
        ATTRIBUTE8 = l_def_ras_rec.attribute8,
        ATTRIBUTE9 = l_def_ras_rec.attribute9,
        ATTRIBUTE10 = l_def_ras_rec.attribute10,
        ATTRIBUTE11 = l_def_ras_rec.attribute11,
        ATTRIBUTE12 = l_def_ras_rec.attribute12,
        ATTRIBUTE13 = l_def_ras_rec.attribute13,
        ATTRIBUTE14 = l_def_ras_rec.attribute14,
        ATTRIBUTE15 = l_def_ras_rec.attribute15,
        CREATED_BY = l_def_ras_rec.created_by,
        CREATION_DATE = l_def_ras_rec.creation_date,
        LAST_UPDATED_BY = l_def_ras_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ras_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ras_rec.last_update_login,
  -- RABHUPAT - 2667636 - Start
        CURRENCY_CODE = l_def_ras_rec.currency_code,
        CURRENCY_CONVERSION_CODE = l_def_ras_rec.currency_conversion_code,
        CURRENCY_CONVERSION_TYPE = l_def_ras_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_ras_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_ras_rec.currency_conversion_date
  -- RABHUPAT - 2667636 - End
    WHERE ID = l_def_ras_rec.id;

    x_ras_rec := l_def_ras_rec;
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
  -- update_row for:OKL_RELOCATE_ASSETS_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_relocate_assets_tl_rec   IN OklRelocateAssetsTlRecType,
    x_okl_relocate_assets_tl_rec   OUT NOCOPY OklRelocateAssetsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_relocate_assets_tl_rec   OklRelocateAssetsTlRecType := p_okl_relocate_assets_tl_rec;
    ldefoklrelocateassetstlrec     OklRelocateAssetsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_relocate_assets_tl_rec	IN OklRelocateAssetsTlRecType,
      x_okl_relocate_assets_tl_rec	OUT NOCOPY OklRelocateAssetsTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_relocate_assets_tl_rec   OklRelocateAssetsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_relocate_assets_tl_rec := p_okl_relocate_assets_tl_rec;
      -- Get current database values
      l_okl_relocate_assets_tl_rec := get_rec(p_okl_relocate_assets_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_relocate_assets_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_relocate_assets_tl_rec.id := l_okl_relocate_assets_tl_rec.id;
      END IF;
      IF (x_okl_relocate_assets_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_relocate_assets_tl_rec.language := l_okl_relocate_assets_tl_rec.language;
      END IF;
      IF (x_okl_relocate_assets_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_relocate_assets_tl_rec.source_lang := l_okl_relocate_assets_tl_rec.source_lang;
      END IF;
      IF (x_okl_relocate_assets_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_relocate_assets_tl_rec.sfwt_flag := l_okl_relocate_assets_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_relocate_assets_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_relocate_assets_tl_rec.comments := l_okl_relocate_assets_tl_rec.comments;
      END IF;
      IF (x_okl_relocate_assets_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_relocate_assets_tl_rec.created_by := l_okl_relocate_assets_tl_rec.created_by;
      END IF;
      IF (x_okl_relocate_assets_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_relocate_assets_tl_rec.creation_date := l_okl_relocate_assets_tl_rec.creation_date;
      END IF;
      IF (x_okl_relocate_assets_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_relocate_assets_tl_rec.last_updated_by := l_okl_relocate_assets_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_relocate_assets_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_relocate_assets_tl_rec.last_update_date := l_okl_relocate_assets_tl_rec.last_update_date;
      END IF;
      IF (x_okl_relocate_assets_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_relocate_assets_tl_rec.last_update_login := l_okl_relocate_assets_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_RELOCATE_ASSETS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_relocate_assets_tl_rec IN  OklRelocateAssetsTlRecType,
      x_okl_relocate_assets_tl_rec OUT NOCOPY OklRelocateAssetsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_relocate_assets_tl_rec := p_okl_relocate_assets_tl_rec;
      x_okl_relocate_assets_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_relocate_assets_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_relocate_assets_tl_rec,      -- IN
      l_okl_relocate_assets_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_relocate_assets_tl_rec, ldefoklrelocateassetstlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_RELOCATE_ASSETS_TL
    SET COMMENTS = ldefoklrelocateassetstlrec.comments,
        SOURCE_LANG = ldefoklrelocateassetstlrec.source_lang,--Fix for bug 3637102
        CREATED_BY = ldefoklrelocateassetstlrec.created_by,
        CREATION_DATE = ldefoklrelocateassetstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklrelocateassetstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklrelocateassetstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklrelocateassetstlrec.last_update_login
    WHERE ID = ldefoklrelocateassetstlrec.id
        AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);--Fix for bug 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_RELOCATE_ASSETS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklrelocateassetstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_relocate_assets_tl_rec := ldefoklrelocateassetstlrec;
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
  -- update_row for:OKL_RELOCATE_ASSETS_V --
  ------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : for OKL_RELOCATE_ASSETS_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_rec                     IN rasv_rec_type,
    x_rasv_rec                     OUT NOCOPY rasv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rasv_rec                     rasv_rec_type := p_rasv_rec;
    l_def_rasv_rec                 rasv_rec_type;
    l_okl_relocate_assets_tl_rec   OklRelocateAssetsTlRecType;
    lx_okl_relocate_assets_tl_rec  OklRelocateAssetsTlRecType;
    l_ras_rec                      ras_rec_type;
    lx_ras_rec                     ras_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rasv_rec	IN rasv_rec_type
    ) RETURN rasv_rec_type IS
      l_rasv_rec	rasv_rec_type := p_rasv_rec;
    BEGIN
      l_rasv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rasv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rasv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rasv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rasv_rec	IN rasv_rec_type,
      x_rasv_rec	OUT NOCOPY rasv_rec_type
    ) RETURN VARCHAR2 IS
      l_rasv_rec                     rasv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rasv_rec := p_rasv_rec;
      -- Get current database values
      l_rasv_rec := get_rec(p_rasv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rasv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.id := l_rasv_rec.id;
      END IF;
      IF (x_rasv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.object_version_number := l_rasv_rec.object_version_number;
      END IF;
      IF (x_rasv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.sfwt_flag := l_rasv_rec.sfwt_flag;
      END IF;
      IF (x_rasv_rec.art_id = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.art_id := l_rasv_rec.art_id;
      END IF;
      IF (x_rasv_rec.pac_id = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.pac_id := l_rasv_rec.pac_id;
      END IF;
      IF (x_rasv_rec.ist_id = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.ist_id := l_rasv_rec.ist_id;
      END IF;
      IF (x_rasv_rec.date_shipping_instructions_sen = OKC_API.G_MISS_DATE)
      THEN
        x_rasv_rec.date_shipping_instructions_sen := l_rasv_rec.date_shipping_instructions_sen;
      END IF;
      IF (x_rasv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.comments := l_rasv_rec.comments;
      END IF;
      IF (x_rasv_rec.trans_option_accepted_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.trans_option_accepted_yn := l_rasv_rec.trans_option_accepted_yn;
      END IF;
      IF (x_rasv_rec.insurance_amount = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.insurance_amount := l_rasv_rec.insurance_amount;
      END IF;
      IF (x_rasv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute_category := l_rasv_rec.attribute_category;
      END IF;
      IF (x_rasv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute1 := l_rasv_rec.attribute1;
      END IF;
      IF (x_rasv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute2 := l_rasv_rec.attribute2;
      END IF;
      IF (x_rasv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute3 := l_rasv_rec.attribute3;
      END IF;
      IF (x_rasv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute4 := l_rasv_rec.attribute4;
      END IF;
      IF (x_rasv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute5 := l_rasv_rec.attribute5;
      END IF;
      IF (x_rasv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute6 := l_rasv_rec.attribute6;
      END IF;
      IF (x_rasv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute7 := l_rasv_rec.attribute7;
      END IF;
      IF (x_rasv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute8 := l_rasv_rec.attribute8;
      END IF;
      IF (x_rasv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute9 := l_rasv_rec.attribute9;
      END IF;
      IF (x_rasv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute10 := l_rasv_rec.attribute10;
      END IF;
      IF (x_rasv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute11 := l_rasv_rec.attribute11;
      END IF;
      IF (x_rasv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute12 := l_rasv_rec.attribute12;
      END IF;
      IF (x_rasv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute13 := l_rasv_rec.attribute13;
      END IF;
      IF (x_rasv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute14 := l_rasv_rec.attribute14;
      END IF;
      IF (x_rasv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.attribute15 := l_rasv_rec.attribute15;
      END IF;
      IF (x_rasv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.org_id := l_rasv_rec.org_id;
      END IF;
      IF (x_rasv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.request_id := l_rasv_rec.request_id;
      END IF;
      IF (x_rasv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.program_application_id := l_rasv_rec.program_application_id;
      END IF;
      IF (x_rasv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.program_id := l_rasv_rec.program_id;
      END IF;
      IF (x_rasv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rasv_rec.program_update_date := l_rasv_rec.program_update_date;
      END IF;
      IF (x_rasv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.created_by := l_rasv_rec.created_by;
      END IF;
      IF (x_rasv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rasv_rec.creation_date := l_rasv_rec.creation_date;
      END IF;
      IF (x_rasv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.last_updated_by := l_rasv_rec.last_updated_by;
      END IF;
      IF (x_rasv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.last_update_login := l_rasv_rec.last_update_login;
      END IF;
      IF (x_rasv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rasv_rec.last_update_date := l_rasv_rec.last_update_date;
      END IF;
  -- RABHUPAT - 2667636 - Start
     IF (x_rasv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.currency_code := l_rasv_rec.currency_code;
      END IF;
      IF (x_rasv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.currency_conversion_code := l_rasv_rec.currency_conversion_code;
      END IF;
      IF (x_rasv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_rasv_rec.currency_conversion_type := l_rasv_rec.currency_conversion_type;
      END IF;
      IF (x_rasv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_rasv_rec.currency_conversion_rate := l_rasv_rec.currency_conversion_rate;
      END IF;
      IF (x_rasv_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_rasv_rec.currency_conversion_date := l_rasv_rec.currency_conversion_date;
      END IF;
  -- RABHUPAT - 2667636 - End
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_RELOCATE_ASSETS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_rasv_rec IN  rasv_rec_type,
      x_rasv_rec OUT NOCOPY rasv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rasv_rec := p_rasv_rec;
      x_rasv_rec.OBJECT_VERSION_NUMBER := NVL(x_rasv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_rasv_rec,                        -- IN
      l_rasv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rasv_rec, l_def_rasv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rasv_rec := fill_who_columns(l_def_rasv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rasv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rasv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rasv_rec, l_okl_relocate_assets_tl_rec);
    migrate(l_def_rasv_rec, l_ras_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_relocate_assets_tl_rec,
      lx_okl_relocate_assets_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_relocate_assets_tl_rec, l_def_rasv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ras_rec,
      lx_ras_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ras_rec, l_def_rasv_rec);
    x_rasv_rec := l_def_rasv_rec;
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
  -- PL/SQL TBL update_row for:RASV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_tbl                     IN rasv_tbl_type,
    x_rasv_tbl                     OUT NOCOPY rasv_tbl_type) IS

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
    IF (p_rasv_tbl.COUNT > 0) THEN
      i := p_rasv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rasv_rec                     => p_rasv_tbl(i),
          x_rasv_rec                     => x_rasv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rasv_tbl.LAST);
        i := p_rasv_tbl.NEXT(i);
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
  -- delete_row for:OKL_RELOCATE_ASSETS_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ras_rec                      IN ras_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ras_rec                      ras_rec_type:= p_ras_rec;
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
    DELETE FROM OKL_RELOCATE_ASSETS_B
     WHERE ID = l_ras_rec.id;

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
  -- delete_row for:OKL_RELOCATE_ASSETS_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_relocate_assets_tl_rec   IN OklRelocateAssetsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_relocate_assets_tl_rec   OklRelocateAssetsTlRecType:= p_okl_relocate_assets_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_RELOCATE_ASSETS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_relocate_assets_tl_rec IN  OklRelocateAssetsTlRecType,
      x_okl_relocate_assets_tl_rec OUT NOCOPY OklRelocateAssetsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_relocate_assets_tl_rec := p_okl_relocate_assets_tl_rec;
      x_okl_relocate_assets_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_relocate_assets_tl_rec,      -- IN
      l_okl_relocate_assets_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_RELOCATE_ASSETS_TL
     WHERE ID = l_okl_relocate_assets_tl_rec.id;

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
  -- delete_row for:OKL_RELOCATE_ASSETS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_rec                     IN rasv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rasv_rec                     rasv_rec_type := p_rasv_rec;
    l_okl_relocate_assets_tl_rec   OklRelocateAssetsTlRecType;
    l_ras_rec                      ras_rec_type;
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
    migrate(l_rasv_rec, l_okl_relocate_assets_tl_rec);
    migrate(l_rasv_rec, l_ras_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_relocate_assets_tl_rec
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
      l_ras_rec
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
  -- PL/SQL TBL delete_row for:RASV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_tbl                     IN rasv_tbl_type) IS

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
    IF (p_rasv_tbl.COUNT > 0) THEN
      i := p_rasv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rasv_rec                     => p_rasv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rasv_tbl.LAST);
        i := p_rasv_tbl.NEXT(i);
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
END OKL_RAS_PVT;

/
