--------------------------------------------------------
--  DDL for Package Body OKL_TQL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TQL_PVT" AS
/* $Header: OKLSTQLB.pls 120.11.12010000.2 2009/06/02 10:56:33 racheruv ship $ */

G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
G_UPPER_CASE_REQUIRED CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
--G_INVALID_END_DATE    CONSTANT VARCHAR2(200) := 'INVALID_END_DATE';

-- RMUNJULU 05-FEB-03 2788257 Changed values of constants
G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'ERROR_CODE';
G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';


G_VIEW                CONSTANT VARCHAR2(200) := 'OKL_TXL_QUOTE_LINES_V';
G_EXCEPTION_HALT_VALIDATION            EXCEPTION;
G_EXCEPTION_STOP_VALIDATION            EXCEPTION;
G_RETURN_STATUS VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

--------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_currency_record
  -- Description     : Used for validation of Currency Code Conversion Coulms
  -- Business Rules  : If transaction currency <> functional currency, then
  --                   conversion columns are mandatory
  --                   Else If transaction currency = functional currency,
  --                   then conversion columns should all be NULL
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 15-DEC-2002 BAKUCHIB :Added new procedure
  -- End of comments

  PROCEDURE validate_currency_record(p_tqlv_rec      IN  tqlv_rec_type,
                                     x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- If transaction currency <> functional currency, then conversion columns
    -- are mandatory
    IF (p_tqlv_rec.currency_code <> p_tqlv_rec.currency_conversion_code) THEN
      IF (p_tqlv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR OR
         p_tqlv_rec.currency_conversion_type IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_type');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_tqlv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM OR
         p_tqlv_rec.currency_conversion_rate IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_rate');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_tqlv_rec.currency_conversion_date = OKC_API.G_MISS_DATE OR
         p_tqlv_rec.currency_conversion_date IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_date');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    -- Else If transaction currency = functional currency, then conversion columns
    -- should all be NULL
    ELSIF (p_tqlv_rec.currency_code = p_tqlv_rec.currency_conversion_code) THEN
      IF (p_tqlv_rec.currency_conversion_type IS NOT NULL) OR
         (p_tqlv_rec.currency_conversion_rate IS NOT NULL) OR
         (p_tqlv_rec.currency_conversion_date IS NOT NULL) THEN
        --SET MESSAGE
        -- Currency conversion columns should be all null
        IF p_tqlv_rec.currency_conversion_rate IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_rate');
        END IF;
        IF p_tqlv_rec.currency_conversion_date IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_date');
        END IF;
        IF p_tqlv_rec.currency_conversion_type IS NOT NULL THEN
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
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 15-DEC-2002 BAKUCHIB :Added new procedure
  -- End of comments

  PROCEDURE validate_currency_code(p_tqlv_rec      IN  tqlv_rec_type,
                                   x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_tqlv_rec.currency_code IS NULL) OR
       (p_tqlv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_code');

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_tqlv_rec.currency_code);
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
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 15-DEC-2002 BAKUCHIB :Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_code(p_tqlv_rec      IN  tqlv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_tqlv_rec.currency_conversion_code IS NULL) OR
       (p_tqlv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_conversion_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_tqlv_rec.currency_conversion_code);
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
--------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_currency_con_type
  -- Description     : Validation of Currency Conversion type
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 15-DEC-2002 BAKUCHIB :Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_type(p_tqlv_rec      IN  tqlv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tqlv_rec.currency_conversion_type <> OKL_API.G_MISS_CHAR AND
       p_tqlv_rec.currency_conversion_type IS NOT NULL) THEN
      -- check from currency values using the generic okl_util.validate_currency_code
      l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_con_type(p_tqlv_rec.currency_conversion_type);
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
---------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_split_kle_id
-- Description          : FK validation with OKL_K_LINES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE Validate_split_kle_id(x_return_status OUT NOCOPY VARCHAR2,
                                  p_tqlv_rec IN tqlv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_split_kle_id(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT id
                 FROM OKL_K_LINES_V
                 WHERE id = p_id);

  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- This is an optional Column.
    IF (p_tqlv_rec.split_kle_id = OKL_API.G_MISS_NUM) OR
       (p_tqlv_rec.split_kle_id IS NULL) THEN
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_split_kle_id(p_tqlv_rec.split_kle_id);
    IF c_split_kle_id%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_split_kle_id into ln_dummy;
    CLOSE c_split_kle_id;
    IF (ln_dummy = 0) THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
      null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- We are here b'cause we have no parent record
      -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_PARENT_RECORD,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'Split_kle_id');
    -- If the cursor is open then it has to be closed
    IF c_split_kle_id%ISOPEN THEN
       CLOSE c_split_kle_id;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    IF c_split_kle_id%ISOPEN THEN
       CLOSE c_split_kle_id;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_split_kle_id;
------------------------------------
-- PROCEDURE validate_org_id
------------------------------------
-- Function Name   : validate_org_id
-- Description     : To validate org_id
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

PROCEDURE validate_org_id(
 x_return_status OUT NOCOPY VARCHAR2,
 p_tqlv_rec  IN tqlv_rec_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check org id validity using the generic function okl_util.check_org_id()
    l_return_status := OKL_UTIL.check_org_id (p_tqlv_rec.org_id);

    IF ( l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'org_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary;  validation can continue with the next column
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

------------------------------------
-- PROCEDURE validate_try_id_fk
------------------------------------
-- Function Name   : validate_try_id_fk
-- Description     : To validate try_id
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

PROCEDURE validate_try_id_fk(
 x_return_status OUT NOCOPY VARCHAR2,
 p_tqlv_rec  IN tqlv_rec_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR check_try_id_csr (p_try_id IN NUMBER) IS
    SELECT try.id
    FROM   okl_trx_types_v try
    WHERE  try.id = p_try_id;

    l_try_id NUMBER;

  BEGIN
     IF (p_tqlv_rec.TRY_ID IS NOT NULL) THEN

        OPEN  check_try_id_csr (p_tqlv_rec.try_id);
        FETCH check_try_id_csr INTO l_try_id;
        CLOSE check_try_id_csr;

        IF l_try_id IS NULL THEN

           OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => g_invalid_value,
                               p_token1       => g_col_name_token,
                               p_token1_value => 'try_id');

           x_return_status := OKC_API.G_RET_STS_ERROR;
           raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary;  validation can continue with the next column
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

  END validate_try_id_fk;

------------------------------------
-- PROCEDURE validate_fk_qlt_code
------------------------------------
-- Function Name  : validate_fk_qlt_code
-- Description     : To validate the foreign key QLT_CODE
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_fk_qlt_code (
      x_return_status OUT NOCOPY VARCHAR2,
      p_tqlv_rec IN tqlv_rec_type) IS

     l_return_status varchar2(1);

    BEGIN
     IF (p_tqlv_rec.QTE_ID IS NOT NULL) THEN

        l_return_status := okl_util.check_lookup_code
                                  ( p_lookup_type=>'OKL_QUOTE_LINE_TYPE'
                                  , p_lookup_code=>p_tqlv_rec.qlt_code
                                  );

        IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
           OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => g_invalid_value,
                               p_token1       => g_col_name_token,
                               p_token1_value => 'qlt_code');

           x_return_status := OKC_API.G_RET_STS_ERROR;
           raise G_EXCEPTION_HALT_VALIDATION;

        ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           raise G_EXCEPTION_HALT_VALIDATION;
        END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary;  validation can continue with the next column
      NULL;

    when OTHERS then
         -- store SQL error on message stack for caller
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_unexpected_error,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);

         -- notify caller of an UNEXPECTED error
         x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_fk_qlt_code;



-- PROCEDURE Name  : validate_fk_sty_id
-- Description     : To validate the foreign key STY_ID
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0
-- History         : RMUNJULU 05-FEB-03 2788257 Changed to throw proper error msg

    PROCEDURE validate_fk_sty_id (
      x_return_status OUT NOCOPY VARCHAR2,
      p_tqlv_rec IN tqlv_rec_type) IS

     l_dummy_var           varchar2(1) := '?';
     -- select the ID of the parent record from the parent table
      CURSOR okl_sty_fk_csr IS
      SELECT  'x'
      FROM    OKL_STRM_TYPE_V
      WHERE    ID = p_tqlv_rec.sty_id;

    BEGIN
     IF  p_tqlv_rec.sty_id IS NOT NULL
     AND p_tqlv_rec.sty_id <> OKL_API.G_MISS_NUM THEN

        OPEN okl_sty_fk_csr;
        FETCH okl_sty_fk_csr INTO l_dummy_var;
        CLOSE okl_sty_fk_csr;

        -- if l_dummy_var is still set to default, data was not found
        IF (l_dummy_var = '?') THEN
          OKC_API.set_message(p_app_name       => 'OKL',
                              p_msg_name       => g_no_parent_record,
                              p_token1         => g_col_name_token,
                              p_token1_value   => 'sty_id',
                              p_token2         => g_child_table_token,
                              p_token2_value   => 'OKL_TXL_QUOTE_LINES_V',
                              p_token3         => g_parent_table_token,
                              p_token3_value   => 'OKL_STRM_TYPE_V');

         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
      END IF;
     EXCEPTION
       WHEN OTHERS THEN
         -- store SQL error on message stack for caller
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_unexpected_error,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);

         -- notify caller of an UNEXPECTED error
         x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

         -- verify that cursor was closed
         IF okl_sty_fk_csr%ISOPEN THEN
            CLOSE okl_sty_fk_csr;
         END IF;

    END validate_fk_sty_id;

------------------------------------
-- PROCEDURE validate_modified_yn_domain--
------------------------------------
-- Function Name  : validate_modified_yn_domain
-- Description     : To validate the domain values
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_modified_yn_domain (
      x_return_status OUT NOCOPY VARCHAR2,
      p_tqlv_rec IN tqlv_rec_type
    ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      -- check from domain values using the generic okl_util.check_domain_yn
      l_return_status := OKL_UTIL.check_domain_yn(p_tqlv_rec.modified_yn);

      IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'modified_yn');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
     END IF;

     EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary;  validation can continue with the next column
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
     END validate_modified_yn_domain;

------------------------------------
-- PROCEDURE validate_taxed_yn_domain--
------------------------------------
-- Function Name  : validate_taxed_yn_domain
-- Description     : To validate the Taxed_yn domain values
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_taxed_yn_domain (
      x_return_status OUT NOCOPY VARCHAR2,
      p_tqlv_rec IN tqlv_rec_type
    ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      -- check from domain values using the generic okl_util.check_domain_yn
      l_return_status := OKL_UTIL.check_domain_yn(p_tqlv_rec.taxed_yn);

      IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'taxed_yn');

        x_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
     END IF;

   EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
        -- no processing necessary;  validation can continue with the next column
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
    END validate_taxed_yn_domain;

------------------------------------
-- PROCEDURE validate_taxed_yn_domain--
------------------------------------
-- Function Name  : validate_taxed_yn_domain
-- Description     : To validate the Taxed_yn domain values
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_defaulted_yn_domain (
      x_return_status OUT NOCOPY VARCHAR2,
      p_tqlv_rec IN tqlv_rec_type
    ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      -- check from domain values using the generic okl_util.check_domain_yn
      l_return_status := OKL_UTIL.check_domain_yn(p_tqlv_rec.defaulted_yn);

      IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'defaulted_yn');

        x_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
     END IF;

   EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
        -- no processing necessary;  validation can continue with the next column
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
    END validate_defaulted_yn_domain;

------------------------------------
-- PROCEDURE validate_id--
------------------------------------
-- Function Name  : validate_id
-- Description     : To validate the id
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tqlv_rec IN tqlv_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_tqlv_rec.id = OKC_API.G_MISS_NUM OR
       p_tqlv_rec.id IS NULL
    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'id');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
        else
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
       end if;
      exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => G_UNEXPECTED_ERROR,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_id;

-- Start of comments
  --
  -- Procedure Name  : validate_sfwt_flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_sfwt_flag(
 x_return_status OUT NOCOPY VARCHAR2,
 p_tqlv_rec  IN tqlv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_tqlv_rec.sfwt_flag IS NULL) OR (p_tqlv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'sfwt_flag');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

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

  END validate_sfwt_flag;
------------------------------------
-- PROCEDURE validate_object_version_number--
------------------------------------
-- Function Name  : validate_object_version_number
-- Description     : To validate the object Version Number
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_object_version_number (
      x_return_status OUT NOCOPY VARCHAR2,
      p_tqlv_rec IN tqlv_rec_type
    ) IS
    BEGIN
     IF p_tqlv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_tqlv_rec.object_version_number IS NULL
     THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ObjectVersionNumber');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
     ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
     END IF;
      exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => G_UNEXPECTED_ERROR,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_object_version_number;

    -- Procedure Name  : validate_qte_id
    -- Description     : To validate the Quote Id
    -- Business Rules  :
    -- Parameters      : Record
    -- Version         : 1.0
    -- History         : RMUNJULU 05-FEB-03 2788257 Changed to add fkey checks

    PROCEDURE validate_qte_id (
                     x_return_status OUT NOCOPY VARCHAR2,
                     p_tqlv_rec      IN tqlv_rec_type    ) IS

      -- Get the Fkey for qte_id from quotes table
      CURSOR  okl_qtev_fk_csr (p_qte_id IN NUMBER) IS
      SELECT  'x'
      FROM    OKL_TRX_QUOTES_V QTE
      WHERE   QTE.ID = p_qte_id;

      l_dummy_var VARCHAR2(1) := '?';

    BEGIN

      -- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF ((p_tqlv_rec.qte_id = OKC_API.G_MISS_NUM)
      OR (p_tqlv_rec.qte_id IS NULL)) THEN

         OKC_API.SET_MESSAGE(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => G_REQUIRED_VALUE,
                      p_token1       => G_COL_NAME_TOKEN,
                      p_token1_value => 'qte_id');

          x_return_status := OKC_API.G_RET_STS_ERROR;

          RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      -- RMUNJULU 05-FEB-03 2788257 added fkey checks
      OPEN  okl_qtev_fk_csr(p_tqlv_rec.qte_id);
      FETCH okl_qtev_fk_csr INTO l_dummy_var;
      CLOSE okl_qtev_fk_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN

          OKC_API.set_message(
                          p_app_name       => 'OKL',
                          p_msg_name       => G_NO_PARENT_RECORD,
                          p_token1         => G_COL_NAME_TOKEN,
                          p_token1_value   => 'qte_id',
                          p_token2         => G_CHILD_TABLE_TOKEN,
                          p_token2_value   => 'OKL_TXL_QUOTE_LINES_V',
                          p_token3         => G_PARENT_TABLE_TOKEN,
                          p_token3_value   => 'OKL_TRX_QUOTES_V');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

      END IF;

    EXCEPTION

       WHEN G_EXCEPTION_HALT_VALIDATION THEN

         NULL;

       WHEN OTHERS THEN

         -- close cursor if open
         IF okl_qtev_fk_csr%ISOPEN THEN
            CLOSE okl_qtev_fk_csr;
         END IF;

         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UNEXPECTED_ERROR,
                             p_token1       => G_SQLCODE_TOKEN,
                             p_token1_value => SQLCODE,
                             p_token2       => G_SQLERRM_TOKEN,
                             p_token2_value => SQLERRM);

         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    END validate_qte_id;


------------------------------------
-- PROCEDURE validate_line_number--
------------------------------------
-- Function Name  : validate_line_number
-- Description     : To validate the Line Number
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_line_number (
      x_return_status OUT NOCOPY VARCHAR2,
      p_tqlv_rec IN tqlv_rec_type
    ) IS
    BEGIN
    IF p_tqlv_rec.line_number = OKC_API.G_MISS_NUM OR
          p_tqlv_rec.line_number IS NULL
    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'line_number');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
     END IF;
      exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => G_UNEXPECTED_ERROR,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_line_number;




    -- Start Comments
    --
    -- Procedure Name  : validate_amount
    -- Description     : Validate the amount column
    -- Business Rules  :
    -- Parameters      : Record
    -- Version         : 1.0
    -- History         : RMUNJULU 05-FEB-03 2788257 Added
    --
    -- End Comments
    PROCEDURE validate_amount(
                     x_return_status OUT NOCOPY VARCHAR2,
                     p_tqlv_rec      IN  tqlv_rec_type) IS

    BEGIN

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      -- If amount not passed then raise error
      IF p_tqlv_rec.amount = OKL_API.G_MISS_NUM
      OR p_tqlv_rec.amount IS NULL THEN

         OKC_API.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => G_REQUIRED_VALUE,
                     p_token1       => G_COL_NAME_TOKEN,
                     p_token1_value => 'amount');

          x_return_status := OKL_API.G_RET_STS_ERROR;

          RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

    EXCEPTION

      WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;

       WHEN OTHERS THEN

         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UNEXPECTED_ERROR,
                             p_token1       => G_SQLCODE_TOKEN,
                             p_token1_value => SQLCODE,
                             p_token2       => G_SQLERRM_TOKEN,
                             p_token2_value => SQLERRM);

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    END validate_amount;


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
    DELETE FROM OKL_TXL_QUOTE_LINES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TXL_QTE_LINES_ALL_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_TXL_QUOTE_LINES_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_TXL_QUOTE_LINES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TXL_QUOTE_LINES_TL SUBB, OKL_TXL_QUOTE_LINES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_TXL_QUOTE_LINES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
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
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_TXL_QUOTE_LINES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TXL_QUOTE_LINES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_QUOTE_LINES_B
  ---------------------------------------------------------------------------
  -- Start of comments
  -- Function Name   : get_rec
  -- Description     : get record structure of OKL_TXL_QUOTE_LINES_B table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_B table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  --                 : 15-Feb-2005 PAGARG 4161133 Added column DUE_DATE
  -- End of comments

  FUNCTION get_rec (
    p_tql_rec                      IN tql_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tql_rec_type IS
    CURSOR tql_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STY_ID,
            KLE_ID,
            QLT_CODE,
            QTE_ID,
            LINE_NUMBER,
            AMOUNT,
            OBJECT_VERSION_NUMBER,
            MODIFIED_YN,
            DEFAULTED_YN,
            TAXED_YN,
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
            START_DATE,
            PERIOD,
            NUMBER_OF_PERIODS,
            LOCK_LEVEL_STEP,
            ADVANCE_OR_ARREARS,
            YIELD_NAME,
            YIELD_VALUE,
            IMPLICIT_INTEREST_RATE,
            ASSET_VALUE,
            RESIDUAL_VALUE,
            UNBILLED_RECEIVABLES,
            ASSET_QUANTITY,
            QUOTE_QUANTITY,
            SPLIT_KLE_ID,
            SPLIT_KLE_NAME, -- RMUNJULU 2757312
  -- BAKUCHIB 2667636 Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
  -- BAKUCHIB 2667636 End
            DUE_DATE, -- PAGARG 4161133
            try_id -- rmunjulu Sales_Tax_Enhancement
      FROM Okl_Txl_Quote_Lines_B
     WHERE okl_txl_quote_lines_b.id = p_id;
    l_tql_pk                       tql_pk_csr%ROWTYPE;
    l_tql_rec                      tql_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN tql_pk_csr (p_tql_rec.id);
    FETCH tql_pk_csr INTO
              l_tql_rec.ID,
              l_tql_rec.STY_ID,
              l_tql_rec.KLE_ID,
              l_tql_rec.QLT_CODE,
              l_tql_rec.QTE_ID,
              l_tql_rec.LINE_NUMBER,
              l_tql_rec.AMOUNT,
              l_tql_rec.OBJECT_VERSION_NUMBER,
              l_tql_rec.MODIFIED_YN,
              l_tql_rec.DEFAULTED_YN,
              l_tql_rec.TAXED_YN,
              l_tql_rec.ORG_ID,
              l_tql_rec.REQUEST_ID,
              l_tql_rec.PROGRAM_APPLICATION_ID,
              l_tql_rec.PROGRAM_ID,
              l_tql_rec.PROGRAM_UPDATE_DATE,
              l_tql_rec.ATTRIBUTE_CATEGORY,
              l_tql_rec.ATTRIBUTE1,
              l_tql_rec.ATTRIBUTE2,
              l_tql_rec.ATTRIBUTE3,
              l_tql_rec.ATTRIBUTE4,
              l_tql_rec.ATTRIBUTE5,
              l_tql_rec.ATTRIBUTE6,
              l_tql_rec.ATTRIBUTE7,
              l_tql_rec.ATTRIBUTE8,
              l_tql_rec.ATTRIBUTE9,
              l_tql_rec.ATTRIBUTE10,
              l_tql_rec.ATTRIBUTE11,
              l_tql_rec.ATTRIBUTE12,
              l_tql_rec.ATTRIBUTE13,
              l_tql_rec.ATTRIBUTE14,
              l_tql_rec.ATTRIBUTE15,
              l_tql_rec.CREATED_BY,
              l_tql_rec.CREATION_DATE,
              l_tql_rec.LAST_UPDATED_BY,
              l_tql_rec.LAST_UPDATE_DATE,
              l_tql_rec.LAST_UPDATE_LOGIN,
              l_tql_rec.START_DATE,
              l_tql_rec.PERIOD,
              l_tql_rec.NUMBER_OF_PERIODS,
              l_tql_rec.LOCK_LEVEL_STEP,
              l_tql_rec.ADVANCE_OR_ARREARS,
              l_tql_rec.YIELD_NAME,
              l_tql_rec.YIELD_VALUE,
              l_tql_rec.IMPLICIT_INTEREST_RATE,
              l_tql_rec.ASSET_VALUE,
              l_tql_rec.RESIDUAL_VALUE,
              l_tql_rec.UNBILLED_RECEIVABLES,
              l_tql_rec.ASSET_QUANTITY,
              l_tql_rec.QUOTE_QUANTITY,
              l_tql_rec.SPLIT_KLE_ID,
              l_tql_rec.SPLIT_KLE_NAME, -- RMUNJULU 2757312
  -- BAKUCHIB 2667636 Start
              l_tql_rec.CURRENCY_CODE,
              l_tql_rec.CURRENCY_CONVERSION_CODE,
              l_tql_rec.CURRENCY_CONVERSION_TYPE,
              l_tql_rec.CURRENCY_CONVERSION_RATE,
              l_tql_rec.CURRENCY_CONVERSION_DATE,
  -- BAKUCHIB 2667636 End
              l_tql_rec.DUE_DATE, -- PAGARG 4161133
              l_tql_rec.try_id; -- rmunjulu Sales_Tax_Enhancement
    x_no_data_found := tql_pk_csr%NOTFOUND;
    CLOSE tql_pk_csr;
    RETURN(l_tql_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tql_rec                      IN tql_rec_type
  ) RETURN tql_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tql_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_QUOTE_LINES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_txl_quote_lines_tl_rec   IN OklTxlQuoteLinesTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklTxlQuoteLinesTlRecType IS
    CURSOR okl_txl_quote_lines_tl_pk_csr (p_id                 IN NUMBER,
                                          p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Txl_Quote_Lines_Tl
     WHERE okl_txl_quote_lines_tl.id = p_id
       AND okl_txl_quote_lines_tl.language = p_language;
    l_okl_txl_quote_lines_tl_pk    okl_txl_quote_lines_tl_pk_csr%ROWTYPE;
    l_okl_txl_quote_lines_tl_rec   OklTxlQuoteLinesTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_quote_lines_tl_pk_csr (p_okl_txl_quote_lines_tl_rec.id,
                                        p_okl_txl_quote_lines_tl_rec.language);
    FETCH okl_txl_quote_lines_tl_pk_csr INTO
              l_okl_txl_quote_lines_tl_rec.ID,
              l_okl_txl_quote_lines_tl_rec.LANGUAGE,
              l_okl_txl_quote_lines_tl_rec.SOURCE_LANG,
              l_okl_txl_quote_lines_tl_rec.SFWT_FLAG,
              l_okl_txl_quote_lines_tl_rec.DESCRIPTION,
              l_okl_txl_quote_lines_tl_rec.CREATED_BY,
              l_okl_txl_quote_lines_tl_rec.CREATION_DATE,
              l_okl_txl_quote_lines_tl_rec.LAST_UPDATED_BY,
              l_okl_txl_quote_lines_tl_rec.LAST_UPDATE_DATE,
              l_okl_txl_quote_lines_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_txl_quote_lines_tl_pk_csr%NOTFOUND;
    CLOSE okl_txl_quote_lines_tl_pk_csr;
    RETURN(l_okl_txl_quote_lines_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_txl_quote_lines_tl_rec   IN OklTxlQuoteLinesTlRecType
  ) RETURN OklTxlQuoteLinesTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_txl_quote_lines_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_QUOTE_LINES_V
  ---------------------------------------------------------------------------
  -- Start of comments
  -- Function Name   : get_rec
  -- Description     : get record structure of OKL_TXL_QUOTE_LINES_V table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  --                 : 15-Feb-2005 PAGARG 4161133 Added column DUE_DATE
  -- End of comments
  FUNCTION get_rec (
    p_tqlv_rec                     IN tqlv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tqlv_rec_type IS
    CURSOR okl_tqlv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            QLT_CODE,
            KLE_ID,
            STY_ID,
            QTE_ID,
            LINE_NUMBER,
            DESCRIPTION,
            AMOUNT,
            MODIFIED_YN,
            DEFAULTED_YN,
            TAXED_YN,
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
            START_DATE,
            PERIOD,
            NUMBER_OF_PERIODS,
            LOCK_LEVEL_STEP,
            ADVANCE_OR_ARREARS,
            YIELD_NAME,
            YIELD_VALUE,
            IMPLICIT_INTEREST_RATE,
            ASSET_VALUE,
            RESIDUAL_VALUE,
            UNBILLED_RECEIVABLES,
            ASSET_QUANTITY,
            QUOTE_QUANTITY,
            SPLIT_KLE_ID,
            SPLIT_KLE_NAME, -- RMUNJULU 2757312
  -- BAKUCHIB 2667636 Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
  -- BAKUCHIB 2667636 End
            DUE_DATE, -- PAGARG 4161133
            try_id -- rmunjulu Sales_Tax_Enhancement
      FROM Okl_Txl_Quote_Lines_V
     WHERE okl_txl_quote_lines_v.id = p_id;
    l_okl_tqlv_pk                  okl_tqlv_pk_csr%ROWTYPE;
    l_tqlv_rec                     tqlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tqlv_pk_csr (p_tqlv_rec.id);
    FETCH okl_tqlv_pk_csr INTO
              l_tqlv_rec.ID,
              l_tqlv_rec.OBJECT_VERSION_NUMBER,
              l_tqlv_rec.SFWT_FLAG,
              l_tqlv_rec.QLT_CODE,
              l_tqlv_rec.KLE_ID,
              l_tqlv_rec.STY_ID,
              l_tqlv_rec.QTE_ID,
              l_tqlv_rec.LINE_NUMBER,
              l_tqlv_rec.DESCRIPTION,
              l_tqlv_rec.AMOUNT,
              l_tqlv_rec.MODIFIED_YN,
              l_tqlv_rec.DEFAULTED_YN,
              l_tqlv_rec.TAXED_YN,
              l_tqlv_rec.ATTRIBUTE_CATEGORY,
              l_tqlv_rec.ATTRIBUTE1,
              l_tqlv_rec.ATTRIBUTE2,
              l_tqlv_rec.ATTRIBUTE3,
              l_tqlv_rec.ATTRIBUTE4,
              l_tqlv_rec.ATTRIBUTE5,
              l_tqlv_rec.ATTRIBUTE6,
              l_tqlv_rec.ATTRIBUTE7,
              l_tqlv_rec.ATTRIBUTE8,
              l_tqlv_rec.ATTRIBUTE9,
              l_tqlv_rec.ATTRIBUTE10,
              l_tqlv_rec.ATTRIBUTE11,
              l_tqlv_rec.ATTRIBUTE12,
              l_tqlv_rec.ATTRIBUTE13,
              l_tqlv_rec.ATTRIBUTE14,
              l_tqlv_rec.ATTRIBUTE15,
              l_tqlv_rec.ORG_ID,
              l_tqlv_rec.REQUEST_ID,
              l_tqlv_rec.PROGRAM_APPLICATION_ID,
              l_tqlv_rec.PROGRAM_ID,
              l_tqlv_rec.PROGRAM_UPDATE_DATE,
              l_tqlv_rec.CREATED_BY,
              l_tqlv_rec.CREATION_DATE,
              l_tqlv_rec.LAST_UPDATED_BY,
              l_tqlv_rec.LAST_UPDATE_DATE,
              l_tqlv_rec.LAST_UPDATE_LOGIN,
              l_tqlv_rec.START_DATE,
              l_tqlv_rec.PERIOD,
              l_tqlv_rec.NUMBER_OF_PERIODS,
              l_tqlv_rec.LOCK_LEVEL_STEP,
              l_tqlv_rec.ADVANCE_OR_ARREARS,
              l_tqlv_rec.YIELD_NAME,
              l_tqlv_rec.YIELD_VALUE,
              l_tqlv_rec.IMPLICIT_INTEREST_RATE,
              l_tqlv_rec.ASSET_VALUE,
              l_tqlv_rec.RESIDUAL_VALUE,
              l_tqlv_rec.UNBILLED_RECEIVABLES,
              l_tqlv_rec.ASSET_QUANTITY,
              l_tqlv_rec.QUOTE_QUANTITY,
              l_tqlv_rec.SPLIT_KLE_ID,
              l_tqlv_rec.SPLIT_KLE_NAME, -- RMUNJULU 2757312
  -- BAKUCHIB 2667636 Start
              l_tqlv_rec.CURRENCY_CODE,
              l_tqlv_rec.CURRENCY_CONVERSION_CODE,
              l_tqlv_rec.CURRENCY_CONVERSION_TYPE,
              l_tqlv_rec.CURRENCY_CONVERSION_RATE,
              l_tqlv_rec.CURRENCY_CONVERSION_DATE,
  -- BAKUCHIB 2667636 End
              l_tqlv_rec.DUE_DATE, -- PAGARG 4161133
              l_tqlv_rec.try_id; -- rmunjulu Sales_Tax_Enhancement
    x_no_data_found := okl_tqlv_pk_csr%NOTFOUND;
    CLOSE okl_tqlv_pk_csr;
    RETURN(l_tqlv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tqlv_rec                     IN tqlv_rec_type
  ) RETURN tqlv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tqlv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXL_QUOTE_LINES_V --
  -----------------------------------------------------------
  -- Start of comments
  -- Function Name   : null_out_defaults
  -- Description     : Null out record structure of OKL_TXL_QUOTE_LINES_V table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  --                 : 15-Feb-2005 PAGARG Bug 4161133 Added code for DUE_DATE
  -- End of comments

  FUNCTION null_out_defaults (
    p_tqlv_rec	IN tqlv_rec_type
  ) RETURN tqlv_rec_type IS
    l_tqlv_rec	tqlv_rec_type := p_tqlv_rec;
  BEGIN
    IF (l_tqlv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.object_version_number := NULL;
    END IF;
    IF (l_tqlv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_tqlv_rec.qlt_code = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.qlt_code := NULL;
    END IF;
    IF (l_tqlv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.kle_id := NULL;
    END IF;
    IF (l_tqlv_rec.sty_id = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.sty_id := NULL;
    END IF;
    IF (l_tqlv_rec.qte_id = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.qte_id := NULL;
    END IF;
    IF (l_tqlv_rec.line_number = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.line_number := NULL;
    END IF;
    IF (l_tqlv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.description := NULL;
    END IF;
    IF (l_tqlv_rec.amount = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.amount := NULL;
    END IF;
    IF (l_tqlv_rec.modified_yn = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.modified_yn := NULL;
    END IF;
    IF (l_tqlv_rec.defaulted_yn = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.defaulted_yn := NULL;
    END IF;
    IF (l_tqlv_rec.taxed_yn = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.taxed_yn := NULL;
    END IF;
    IF (l_tqlv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute_category := NULL;
    END IF;
    IF (l_tqlv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute1 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute2 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute3 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute4 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute5 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute6 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute7 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute8 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute9 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute10 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute11 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute12 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute13 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute14 := NULL;
    END IF;
    IF (l_tqlv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.attribute15 := NULL;
    END IF;
    IF (l_tqlv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.org_id := NULL;
    END IF;
/*
    IF (l_tqlv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.request_id := NULL;
    END IF;
    IF (l_tqlv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.program_application_id := NULL;
    END IF;
    IF (l_tqlv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.program_id := NULL;
    END IF;
    IF (l_tqlv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_tqlv_rec.program_update_date := NULL;
    END IF;
*/
  IF (l_tqlv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.created_by := NULL;
    END IF;
    IF (l_tqlv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_tqlv_rec.creation_date := NULL;
    END IF;
    IF (l_tqlv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tqlv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_tqlv_rec.last_update_date := NULL;
    END IF;
    IF (l_tqlv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.last_update_login := NULL;
    END IF;
    IF (l_tqlv_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_tqlv_rec.start_date := NULL;
    END IF;
    IF (l_tqlv_rec.period = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.period := NULL;
    END IF;
    IF (l_tqlv_rec.number_of_periods = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.number_of_periods := NULL;
    END IF;
    IF (l_tqlv_rec.lock_level_step = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.lock_level_step := NULL;
    END IF;
    IF (l_tqlv_rec.advance_or_arrears = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.advance_or_arrears := NULL;
    END IF;
    IF (l_tqlv_rec.yield_name = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.yield_name := NULL;
    END IF;
    IF (l_tqlv_rec.yield_value = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.yield_value := NULL;
    END IF;
    IF (l_tqlv_rec.implicit_interest_rate = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.implicit_interest_rate := NULL;
    END IF;
    IF (l_tqlv_rec.asset_value = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.asset_value := NULL;
    END IF;
    IF (l_tqlv_rec.residual_value = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.residual_value := NULL;
    END IF;
    IF (l_tqlv_rec.unbilled_receivables = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.unbilled_receivables := NULL;
    END IF;
    IF (l_tqlv_rec.asset_quantity = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.asset_quantity := NULL;
    END IF;
    IF (l_tqlv_rec.quote_quantity = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.quote_quantity := NULL;
    END IF;
    IF (l_tqlv_rec.split_kle_id = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.split_kle_id := NULL;
    END IF;
    -- RMUNJULU 2757312
    IF (l_tqlv_rec.split_kle_name = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.split_kle_name := NULL;
    END IF;
  -- BAKUCHIB 2667636 Start
    IF (l_tqlv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.currency_code := NULL;
    END IF;
    IF (l_tqlv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.currency_conversion_code := NULL;
    END IF;
    IF (l_tqlv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
      l_tqlv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_tqlv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
      l_tqlv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_tqlv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
      l_tqlv_rec.currency_conversion_date := NULL;
    END IF;
  -- BAKUCHIB 2667636 End
    -- PAGARG Bug 4161133 Start
    -- null out defaults for new column DUE_DATE
    IF (l_tqlv_rec.due_date = OKL_API.G_MISS_DATE) THEN
      l_tqlv_rec.due_date := NULL;
    END IF;
    -- PAGARG Bug 4161133 End
    -- rmunjulu Sales_Tax_Enhancement
    IF (l_tqlv_rec.try_id = OKL_API.G_MISS_NUM) THEN
      l_tqlv_rec.try_id := NULL;
    END IF;
    RETURN(l_tqlv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_TXL_QUOTE_LINES_V --
  ---------------------------------------------------
  -- Start of comments
  -- Function Name   : Validate_Attributes
  -- Description     : Validate Attributes of record structure of
  --                   OKL_TXL_QUOTE_LINES_V table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added Procedure for validation of Currency code,
  --                   currency Conversion_code and Currency conversion type
  --                   RMUNJULU 05-FEB-03 2788257 Added validate_amount call
  -- End of comments
  FUNCTION Validate_Attributes (
    p_tqlv_rec IN  tqlv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    validate_id(x_return_status => l_return_status,
                p_tqlv_rec      => p_tqlv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    validate_sfwt_flag(x_return_status => l_return_status,
                p_tqlv_rec      => p_tqlv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

     validate_object_version_number(x_return_status => l_return_status,
                p_tqlv_rec      => p_tqlv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    validate_qte_id(x_return_status => l_return_status,
                p_tqlv_rec      => p_tqlv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    validate_line_number(x_return_status => l_return_status,
                p_tqlv_rec      => p_tqlv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    validate_fk_qlt_code(x_return_status => l_return_status,
                p_tqlv_rec      => p_tqlv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    validate_fk_sty_id(x_return_status => l_return_status,
                p_tqlv_rec      => p_tqlv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

     validate_modified_yn_domain (x_return_status => l_return_status,
                                  p_tqlv_rec      => p_tqlv_rec);
     if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
     end if;

     validate_defaulted_yn_domain (x_return_status => l_return_status,
                                  p_tqlv_rec      => p_tqlv_rec);
     if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
     end if;

     validate_taxed_yn_domain (x_return_status => l_return_status,
                                  p_tqlv_rec      => p_tqlv_rec);
     if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
     end if;

    validate_org_id(x_return_status => l_return_status,
                p_tqlv_rec      => p_tqlv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;
    Validate_split_kle_id(x_return_status => l_return_status,
                                  p_tqlv_rec => p_tqlv_rec);
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

  -- BAKUCHIB 2667636 Start
    validate_currency_code(p_tqlv_rec      => p_tqlv_rec,
                           x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_code(p_tqlv_rec      => p_tqlv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_type(p_tqlv_rec      => p_tqlv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- BAKUCHIB 2667636 End

    -- RMUNJULU 05-FEB-03 2788257 Added call to validate_amount
    validate_amount(p_tqlv_rec      => p_tqlv_rec,
                    x_return_status => l_return_status);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- rmunjulu Sales_Tax_Enhancement
    validate_try_id_fk(p_tqlv_rec      => p_tqlv_rec,
                       x_return_status => l_return_status);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN(x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE(p_app_name	   => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_sqlerrm_token,
                            p_token2_value => sqlerrm);

        --notify caller of an UNEXPECTED error
        x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        RETURN x_return_status;
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_TXL_QUOTE_LINES_V --
  -----------------------------------------------
  -- Start of comments
  -- Function Name   : Validate_Record
  -- Description     : Validate Record of record structure of
  --                   OKL_TXL_QUOTE_LINES_V table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                   Added Procedure to validate Currency conversion Code,type
  --                  ,rate and Date aganist currency code
  -- End of comments
  FUNCTION Validate_Record (
    p_tqlv_rec IN tqlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  -- BAKUCHIB 2667636 Start
    -- Validate Currency conversion Code,type,rate and Date

    validate_currency_record(p_tqlv_rec      => p_tqlv_rec,
                                 x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- BAKUCHIB 2667636 End

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : Migrate
  -- Description     : Migrate record structure of OKL_TXL_QUOTE_LINES_V table
  --                   to record structure of OKL_TXL_QUOTE_LINES_B table
  -- Business Rules  :
  -- Parameters      : IN Record structure of OKL_TXL_QUOTE_LINES_V table
  --                   IN OUT Record structure of OKL_TXL_QUOTE_LINES_B table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  --                 : 15-Feb-2005 PAGARG 4161133 Added code for due_date
  -- End of comments
  PROCEDURE migrate (
    p_from	IN tqlv_rec_type,
    p_to	IN OUT NOCOPY tql_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sty_id := p_from.sty_id;
    p_to.kle_id := p_from.kle_id;
    p_to.qlt_code := p_from.qlt_code;
    p_to.qte_id := p_from.qte_id;
    p_to.line_number := p_from.line_number;
    p_to.amount := p_from.amount;
    p_to.object_version_number := p_from.object_version_number;
    p_to.modified_yn := p_from.modified_yn;
    p_to.defaulted_yn := p_from.defaulted_yn;
    p_to.taxed_yn := p_from.taxed_yn;
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
    p_to.start_date := p_from.start_date;
    p_to.period := p_from.period;
    p_to.number_of_periods := p_from.number_of_periods;
    p_to.lock_level_step := p_from.lock_level_step;
    p_to.advance_or_arrears := p_from.advance_or_arrears;
    p_to.yield_name := p_from.yield_name;
    p_to.yield_value := p_from.yield_value;
    p_to.implicit_interest_rate := p_from.implicit_interest_rate;
    p_to.asset_value := p_from.asset_value;
    p_to.residual_value := p_from.residual_value;
    p_to.unbilled_receivables := p_from.unbilled_receivables;
    p_to.asset_quantity := p_from.asset_quantity;
    p_to.quote_quantity := p_from.quote_quantity;
    p_to.split_kle_id := p_from.split_kle_id;
    -- RMUNJULU 2757312
    p_to.split_kle_name := p_from.split_kle_name;
  -- BAKUCHIB 2667636 Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- BAKUCHIB 2667636 End
    p_to.due_date  := p_from.due_date; -- PAGARG 4161133
    -- rmunjulu Sales_Tax_Enhancement
	p_to.try_id  := p_from.try_id;
  END migrate;

  -- Start of comments
  -- Procedure Name  : Migrate
  -- Description     : Migrate record structure of OKL_TXL_QUOTE_LINES_B table
  --                   to record structure of OKL_TXL_QUOTE_LINES_V table
  -- Business Rules  :
  -- Parameters      : IN Record structure of OKL_TXL_QUOTE_LINES_B table
  --                   IN OUT Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  --                 : 15-Feb-2005 PAGARG 4161133 Added code for due_date
  -- End of comments
  PROCEDURE migrate (
    p_from	IN tql_rec_type,
    p_to	IN OUT NOCOPY tqlv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sty_id := p_from.sty_id;
    p_to.kle_id := p_from.kle_id;
    p_to.qlt_code := p_from.qlt_code;
    p_to.qte_id := p_from.qte_id;
    p_to.line_number := p_from.line_number;
    p_to.amount := p_from.amount;
    p_to.object_version_number := p_from.object_version_number;
    p_to.modified_yn := p_from.modified_yn;
    p_to.defaulted_yn := p_from.defaulted_yn;
    p_to.taxed_yn := p_from.taxed_yn;
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
    p_to.start_date := p_from.start_date;
    p_to.period := p_from.period;
    p_to.number_of_periods := p_from.number_of_periods;
    p_to.lock_level_step := p_from.lock_level_step;
    p_to.advance_or_arrears := p_from.advance_or_arrears;
    p_to.yield_name := p_from.yield_name;
    p_to.yield_value := p_from.yield_value;
    p_to.implicit_interest_rate := p_from.implicit_interest_rate;
    p_to.asset_value := p_from.asset_value;
    p_to.residual_value := p_from.residual_value;
    p_to.unbilled_receivables := p_from.unbilled_receivables;
    p_to.asset_quantity := p_from.asset_quantity;
    p_to.quote_quantity := p_from.quote_quantity;
    p_to.split_kle_id := p_from.split_kle_id;
    -- RMUNJULU 2757312
    p_to.split_kle_name := p_from.split_kle_name;
  -- BAKUCHIB 2667636 Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- BAKUCHIB 2667636 End
    p_to.due_date  := p_from.due_date; -- PAGARG 4161133
    -- rmunjulu Sales_Tax_Enhancement
	p_to.try_id  := p_from.try_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN tqlv_rec_type,
    p_to	IN OUT NOCOPY OklTxlQuoteLinesTlRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN OklTxlQuoteLinesTlRecType,
    p_to	IN OUT NOCOPY tqlv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
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
  -- validate_row for:OKL_TXL_QUOTE_LINES_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_rec                     IN tqlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tqlv_rec                     tqlv_rec_type := p_tqlv_rec;
    l_tql_rec                      tql_rec_type;
    l_okl_txl_quote_lines_tl_rec   OklTxlQuoteLinesTlRecType;
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
    l_return_status := Validate_Attributes(l_tqlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_tqlv_rec);
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
  -- PL/SQL TBL validate_row for:TQLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tqlv_tbl.COUNT > 0) THEN
      i := p_tqlv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tqlv_rec                     => p_tqlv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tqlv_tbl.LAST);
        i := p_tqlv_tbl.NEXT(i);
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
  -- insert_row for:OKL_TXL_QUOTE_LINES_B --
  ------------------------------------------
  -- Start of comments
  -- Procedure Name  : insert_row
  -- Description     : Insert Row into OKL_TXL_QUOTE_LINES_B table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_B table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  --                 : 15-Feb-2005 PAGARG 4161133 Code for new column DUE_DATE
  -- End of comments
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tql_rec                      IN tql_rec_type,
    x_tql_rec                      OUT NOCOPY tql_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tql_rec                      tql_rec_type := p_tql_rec;
    l_def_tql_rec                  tql_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_QUOTE_LINES_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tql_rec IN  tql_rec_type,
      x_tql_rec OUT NOCOPY tql_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
    x_tql_rec := p_tql_rec;
    x_tql_rec.defaulted_yn := upper(x_tql_rec.defaulted_yn);
    x_tql_rec.taxed_yn := upper(x_tql_rec.taxed_yn);
    x_tql_rec.modified_yn := upper(x_tql_rec.modified_yn);
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
      p_tql_rec,                         -- IN
      l_tql_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXL_QUOTE_LINES_B(
        id,
        sty_id,
        kle_id,
        qlt_code,
        qte_id,
        line_number,
        amount,
        object_version_number,
        modified_yn,
        defaulted_yn,
        taxed_yn,
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
        start_date,
        period,
        number_of_periods,
        lock_level_step,
        advance_or_arrears,
        yield_name,
        yield_value,
        implicit_interest_rate,
        asset_value,
        residual_value,
        unbilled_receivables,
        asset_quantity,
        quote_quantity,
        split_kle_id,
        split_kle_name, -- RMUNJULU 2757312
  -- BAKUCHIB 2667636 Start
        currency_code,
        currency_conversion_code,
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date,
  -- BAKUCHIB 2667636 End
        due_date, -- PAGARG 4161133
        try_id) -- rmunjulu Sales_Tax_Enhancement
      VALUES (
        l_tql_rec.id,
        l_tql_rec.sty_id,
        l_tql_rec.kle_id,
        l_tql_rec.qlt_code,
        l_tql_rec.qte_id,
        l_tql_rec.line_number,
        l_tql_rec.amount,
        l_tql_rec.object_version_number,
        l_tql_rec.modified_yn,
        l_tql_rec.defaulted_yn,
        l_tql_rec.taxed_yn,
        l_tql_rec.org_id,
        decode(FND_GLOBAL.CONC_REQUEST_ID, -1, NULL, FND_GLOBAL.CONC_REQUEST_ID),
        decode(FND_GLOBAL.PROG_APPL_ID, -1, NULL, FND_GLOBAL.PROG_APPL_ID),
        decode(FND_GLOBAL.CONC_PROGRAM_ID, -1, NULL, FND_GLOBAL.CONC_PROGRAM_ID),
        decode(FND_GLOBAL.CONC_REQUEST_ID, -1, NULL, SYSDATE),
        l_tql_rec.attribute_category,
        l_tql_rec.attribute1,
        l_tql_rec.attribute2,
        l_tql_rec.attribute3,
        l_tql_rec.attribute4,
        l_tql_rec.attribute5,
        l_tql_rec.attribute6,
        l_tql_rec.attribute7,
        l_tql_rec.attribute8,
        l_tql_rec.attribute9,
        l_tql_rec.attribute10,
        l_tql_rec.attribute11,
        l_tql_rec.attribute12,
        l_tql_rec.attribute13,
        l_tql_rec.attribute14,
        l_tql_rec.attribute15,
        l_tql_rec.created_by,
        l_tql_rec.creation_date,
        l_tql_rec.last_updated_by,
        l_tql_rec.last_update_date,
        l_tql_rec.last_update_login,
        l_tql_rec.start_date,
        l_tql_rec.period,
        l_tql_rec.number_of_periods,
        l_tql_rec.lock_level_step,
        l_tql_rec.advance_or_arrears,
        l_tql_rec.yield_name,
        l_tql_rec.yield_value,
        l_tql_rec.implicit_interest_rate,
        l_tql_rec.asset_value,
        l_tql_rec.residual_value,
        l_tql_rec.unbilled_receivables,
        l_tql_rec.asset_quantity,
        l_tql_rec.quote_quantity,
        l_tql_rec.split_kle_id,
        l_tql_rec.split_kle_name, -- RMUNJULU 2757312
  -- BAKUCHIB 2667636 Start
        l_tql_rec.currency_code,
        l_tql_rec.currency_conversion_code,
        l_tql_rec.currency_conversion_type,
        l_tql_rec.currency_conversion_rate,
        l_tql_rec.currency_conversion_date,
  -- BAKUCHIB 2667636 End
        l_tql_rec.due_date, -- PAGARG 4161133
        -- rmunjulu Sales_Tax_Enhancement
        l_tql_rec.try_id);
    -- Set OUT values
    x_tql_rec := l_tql_rec;
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
  -- insert_row for:OKL_TXL_QUOTE_LINES_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_quote_lines_tl_rec   IN OklTxlQuoteLinesTlRecType,
    x_okl_txl_quote_lines_tl_rec   OUT NOCOPY OklTxlQuoteLinesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_txl_quote_lines_tl_rec   OklTxlQuoteLinesTlRecType := p_okl_txl_quote_lines_tl_rec;
    ldefokltxlquotelinestlrec      OklTxlQuoteLinesTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_TXL_QUOTE_LINES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_quote_lines_tl_rec IN  OklTxlQuoteLinesTlRecType,
      x_okl_txl_quote_lines_tl_rec OUT NOCOPY OklTxlQuoteLinesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_quote_lines_tl_rec := p_okl_txl_quote_lines_tl_rec;
      x_okl_txl_quote_lines_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_quote_lines_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txl_quote_lines_tl_rec,      -- IN
      l_okl_txl_quote_lines_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_txl_quote_lines_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_TXL_QUOTE_LINES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_txl_quote_lines_tl_rec.id,
          l_okl_txl_quote_lines_tl_rec.language,
          l_okl_txl_quote_lines_tl_rec.source_lang,
          l_okl_txl_quote_lines_tl_rec.sfwt_flag,
          l_okl_txl_quote_lines_tl_rec.description,
          l_okl_txl_quote_lines_tl_rec.created_by,
          l_okl_txl_quote_lines_tl_rec.creation_date,
          l_okl_txl_quote_lines_tl_rec.last_updated_by,
          l_okl_txl_quote_lines_tl_rec.last_update_date,
          l_okl_txl_quote_lines_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_txl_quote_lines_tl_rec := l_okl_txl_quote_lines_tl_rec;
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
  -- insert_row for:OKL_TXL_QUOTE_LINES_V --
  ------------------------------------------
  -- Start of comments
  -- Procedure Name  : insert_row
  -- Description     : Insert Row into OKL_TXL_QUOTE_LINES_V View
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : In set Attributes function defaulted the
  --                   currency Conversion_code to Functional Currency Code.
  --                   Also defaulted to currency code to currency Conversion
  --                   code if currency code is null.
  --                 : RMUNJULU 09-MAY-03 2949544 Added code to round
  --                   the amount field before saving to table
  -- End of comments
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_rec                     IN tqlv_rec_type,
    x_tqlv_rec                     OUT NOCOPY tqlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tqlv_rec                     tqlv_rec_type;
    l_def_tqlv_rec                 tqlv_rec_type;
    l_tql_rec                      tql_rec_type;
    lx_tql_rec                     tql_rec_type;
    l_okl_txl_quote_lines_tl_rec   OklTxlQuoteLinesTlRecType;
    lx_okl_txl_quote_lines_tl_rec  OklTxlQuoteLinesTlRecType;


    -- RMUNJULU 09-MAY-03 2949544 Added variable
    l_rounded_amount NUMBER;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tqlv_rec	IN tqlv_rec_type
    ) RETURN tqlv_rec_type IS
      l_tqlv_rec	tqlv_rec_type := p_tqlv_rec;
    BEGIN
      l_tqlv_rec.CREATION_DATE := SYSDATE;
      l_tqlv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_tqlv_rec.LAST_UPDATE_DATE :=l_tqlv_rec.CREATION_DATE;
      l_tqlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tqlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tqlv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_QUOTE_LINES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tqlv_rec IN  tqlv_rec_type,
      x_tqlv_rec OUT NOCOPY tqlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tqlv_rec := p_tqlv_rec;
      x_tqlv_rec.OBJECT_VERSION_NUMBER := 1;
      x_tqlv_rec.SFWT_FLAG := 'N';

      -- Default the YN columns if value not passed
      IF p_tqlv_rec.defaulted_yn IS NULL
      OR p_tqlv_rec.defaulted_yn = OKC_API.G_MISS_CHAR THEN
        x_tqlv_rec.defaulted_yn := 'N';
      END IF;

      -- Default the ORG ID if a value is not passed
      IF p_tqlv_rec.org_id IS NULL
      OR p_tqlv_rec.org_id = OKC_API.G_MISS_NUM THEN
        x_tqlv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      END IF;
  -- BAKUCHIB 2667636 Start
      x_tqlv_rec.currency_conversion_code := OKL_AM_UTIL_PVT.get_functional_currency;

      IF p_tqlv_rec.currency_code IS NULL
      OR p_tqlv_rec.currency_code = OKC_API.G_MISS_CHAR THEN
        x_tqlv_rec.currency_code := x_tqlv_rec.currency_conversion_code;
      END IF;
  -- BAKUCHIB 2667636 End


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
    l_tqlv_rec := null_out_defaults(p_tqlv_rec);
    -- Set primary key value
    l_tqlv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tqlv_rec,                        -- IN
      l_def_tqlv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tqlv_rec := fill_who_columns(l_def_tqlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tqlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tqlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    -- RMUNJULU 09-MAY-03 2949544 Added code to round
    -- the amount field before saving to table
    OKL_ACCOUNTING_UTIL.cross_currency_round_amount
              (p_api_version      => p_api_version,
               p_init_msg_list    => p_init_msg_list,
               x_return_status    => l_return_status,
               x_msg_count        => x_msg_count,
               x_msg_data         => x_msg_data,
               p_amount           => l_def_tqlv_rec.amount,
               p_currency_code    => l_def_tqlv_rec.currency_code,
               x_rounded_amount   => l_rounded_amount);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    l_def_tqlv_rec.amount := l_rounded_amount;


    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tqlv_rec, l_tql_rec);
    migrate(l_def_tqlv_rec, l_okl_txl_quote_lines_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tql_rec,
      lx_tql_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tql_rec, l_def_tqlv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_quote_lines_tl_rec,
      lx_okl_txl_quote_lines_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_quote_lines_tl_rec, l_def_tqlv_rec);
    -- Set OUT values
    x_tqlv_rec := l_def_tqlv_rec;
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
  -- PL/SQL TBL insert_row for:TQLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type,
    x_tqlv_tbl                     OUT NOCOPY tqlv_tbl_type) IS

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
    IF (p_tqlv_tbl.COUNT > 0) THEN
      i := p_tqlv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tqlv_rec                     => p_tqlv_tbl(i),
          x_tqlv_rec                     => x_tqlv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tqlv_tbl.LAST);
        i := p_tqlv_tbl.NEXT(i);
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

-- PAGARG Bug 4299668 Declare table of records to define arrays used in bulk insert
-- **Start**
  ------------------------------------------
  -- insert_row for:OKL_TXL_QUOTE_LINES_V --
  ------------------------------------------
  -- Start of comments
  -- Procedure Name  : insert_row_bulk
  -- Description     : Insert Row into OKL_TXL_QUOTE_LINES_V View
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 12-Apr-2005 PAGARG 4299668 created for bulk insert
  -- End of comments
  PROCEDURE insert_row_bulk(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type,
    x_tqlv_tbl                     OUT NOCOPY tqlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row_bulk';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- sechawla 8-may-09 Bug# 8429670  -- Added
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');

    -- Arrays to store pl-sql table and pass it to bulk insert
    in_id NumberTabTyp;
    in_sty_id NumberTabTyp;
    in_kle_id NumberTabTyp;
    in_qlt_code Var30TabTyp;
    in_qte_id NumberTabTyp;
    in_line_number NumberTabTyp;
    in_amount Number14p3TabTyp;
    in_object_version_number Number9TabTyp;
    in_modified_yn Var3TabTyp;
    in_defaulted_yn Var3TabTyp;
    in_taxed_yn Var3TabTyp;
    in_org_id Number15TabTyp;
    in_request_id Number15TabTyp;
    in_program_application_id Number15TabTyp;
    in_program_id Number15TabTyp;
    in_program_update_date DateTabTyp;
    in_attribute_category Var90TabTyp;
    in_attribute1 Var450TabTyp;
    in_attribute2 Var450TabTyp;
    in_attribute3 Var450TabTyp;
    in_attribute4 Var450TabTyp;
    in_attribute5 Var450TabTyp;
    in_attribute6 Var450TabTyp;
    in_attribute7 Var450TabTyp;
    in_attribute8 Var450TabTyp;
    in_attribute9 Var450TabTyp;
    in_attribute10 Var450TabTyp;
    in_attribute11 Var450TabTyp;
    in_attribute12 Var450TabTyp;
    in_attribute13 Var450TabTyp;
    in_attribute14 Var450TabTyp;
    in_attribute15 Var450TabTyp;
    in_created_by Number15TabTyp;
    in_creation_date DateTabTyp;
    in_last_updated_by Number15TabTyp;
    in_last_update_date DateTabTyp;
    in_last_update_login Number15TabTyp;
    in_start_date DateTabTyp;
    in_period Var30TabTyp;
    in_number_of_periods Number4TabTyp;
    in_lock_level_step Var10TabTyp;
    in_advance_or_arrears Var10TabTyp;
    in_yield_name Var150TabTyp;
    in_yield_value Number18p15TabTyp;
    in_implicit_interest_rate Number18p15TabTyp;
    in_asset_value Number14p3TabTyp;
    in_residual_value Number14p3TabTyp;
    in_unbilled_receivables Number14p3TabTyp;
    in_asset_quantity Number14p3TabTyp;
    in_quote_quantity Number14p3TabTyp;
    in_split_kle_id NumberTabTyp;
    in_split_kle_name Var150TabTyp;
    in_currency_code Var15TabTyp;
    in_currency_conversion_code Var15TabTyp;
    in_currency_conversion_type Var30TabTyp;
    in_currency_conversion_rate NumberTabTyp;
    in_currency_conversion_date DateTabTyp;
    in_language Var12TabTyp;
    in_source_lang Var15TabTyp;
    in_sfwt_flag Var3TabTyp;
    in_description Var1995TabTyp;

    -- rmunjulu Sales_Tax_Enhancement
    in_try_id NumberTabTyp; -- *** Check

    --dkagrawa Bug 4187250
    in_due_date DateTabTyp;

    l_tabsize        NUMBER := p_tqlv_tbl.COUNT;
    i                NUMBER := 0;
    j                NUMBER;
    l_org_id         NUMBER;
    l_curr_code      VARCHAR2(15);
    l_rounded_amount NUMBER;
    l_tqlv_rec       tqlv_rec_type;

    l_user_id        NUMBER(15);
    l_conc_req_id    NUMBER(15);
    l_login_id       NUMBER(15);
    l_prog_appl_id   NUMBER(15);
    l_conc_prog_id   NUMBER(15);
    l_conc_reg_id    NUMBER(15);
    l_lang           VARCHAR2(12);

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    i := p_tqlv_tbl.FIRST;
    j :=0;

    l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
    l_curr_code := OKL_AM_UTIL_PVT.get_functional_currency;
    l_user_id := FND_GLOBAL.USER_ID;
    l_login_id := FND_GLOBAL.LOGIN_ID;
    l_conc_req_id := FND_GLOBAL.CONC_REQUEST_ID;
    l_prog_appl_id := FND_GLOBAL.PROG_APPL_ID;
    l_conc_prog_id := FND_GLOBAL.CONC_PROGRAM_ID;
    l_lang := USERENV('LANG');
    WHILE i is not null LOOP
      l_tqlv_rec := null_out_defaults(p_tqlv_tbl(i));

      l_tqlv_rec.id := get_seq_id;
      l_tqlv_rec.object_version_number := 1.0;
      l_tqlv_rec.created_by := l_user_id;
      l_tqlv_rec.creation_date := SYSDATE;
      l_tqlv_rec.last_updated_by := l_user_id;
      l_tqlv_rec.last_update_date := SYSDATE;
      l_tqlv_rec.last_update_login := l_login_id;

      l_tqlv_rec.currency_conversion_code := l_curr_code;
      IF l_tqlv_rec.currency_code IS NULL
      OR l_tqlv_rec.currency_code = OKL_API.G_MISS_CHAR THEN
        l_tqlv_rec.currency_code := l_tqlv_rec.currency_conversion_code;
      END IF;

      IF l_tqlv_rec.defaulted_yn IS NULL
      OR l_tqlv_rec.defaulted_yn = OKL_API.G_MISS_CHAR THEN
        l_tqlv_rec.defaulted_yn := 'N';
      END IF;

      -- Default the ORG ID if a value is not passed
      IF l_tqlv_rec.org_id IS NULL
      OR l_tqlv_rec.org_id = OKL_API.G_MISS_NUM THEN
        l_tqlv_rec.org_id := l_org_id;
      END IF;

      IF l_conc_req_id = -1
      THEN
        l_tqlv_rec.request_id := NULL;
      ELSE
        l_tqlv_rec.request_id :=  l_conc_req_id;
      END IF;

      IF l_prog_appl_id = -1
      THEN
        l_tqlv_rec.program_application_id :=  NULL;
      ELSE
        l_tqlv_rec.program_application_id := l_prog_appl_id;
      END IF;
      IF l_conc_prog_id = -1
      THEN
        l_tqlv_rec.program_id := NULL;
      ELSE
        l_tqlv_rec.program_id := l_conc_prog_id;
      END IF;
      IF l_conc_req_id = -1
      THEN
        l_tqlv_rec.program_update_date := NULL;
      ELSE
        l_tqlv_rec.program_update_date := SYSDATE;
      END IF;
      l_tqlv_rec.sfwt_flag := 'N';

      l_return_status := Validate_Attributes(l_tqlv_rec);
      -- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_return_status := Validate_Record(l_tqlv_rec);
      -- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      j:=j+1;
      in_id(j) := l_tqlv_rec.id;
      in_object_version_number(j) := l_tqlv_rec.object_version_number;
      in_created_by(j) := l_tqlv_rec.created_by;
      in_creation_date(j) := l_tqlv_rec.creation_date;
      in_last_updated_by(j) := l_tqlv_rec.last_updated_by;
      in_last_update_date(j) := l_tqlv_rec.last_update_date;
      in_last_update_login(j) := l_tqlv_rec.last_update_login;
      in_sty_id(j) := l_tqlv_rec.sty_id;
      in_kle_id(j) := l_tqlv_rec.kle_id;
      in_qlt_code(j) := l_tqlv_rec.qlt_code;
      in_qte_id(j) := l_tqlv_rec.qte_id;
      in_line_number(j) := l_tqlv_rec.line_number;
      in_modified_yn(j) := l_tqlv_rec.modified_yn;
      in_taxed_yn(j) := l_tqlv_rec.taxed_yn;
      in_attribute_category(j) := l_tqlv_rec.attribute_category;
      in_attribute1(j) := l_tqlv_rec.attribute1;
      in_attribute2(j) := l_tqlv_rec.attribute2;
      in_attribute3(j) := l_tqlv_rec.attribute3;
      in_attribute4(j) := l_tqlv_rec.attribute4;
      in_attribute5(j) := l_tqlv_rec.attribute5;
      in_attribute6(j) := l_tqlv_rec.attribute6;
      in_attribute7(j) := l_tqlv_rec.attribute7;
      in_attribute8(j) := l_tqlv_rec.attribute8;
      in_attribute9(j) := l_tqlv_rec.attribute9;
      in_attribute10(j) := l_tqlv_rec.attribute10;
      in_attribute11(j) := l_tqlv_rec.attribute11;
      in_attribute12(j) := l_tqlv_rec.attribute12;
      in_attribute13(j) := l_tqlv_rec.attribute13;
      in_attribute14(j) := l_tqlv_rec.attribute14;
      in_attribute15(j) := l_tqlv_rec.attribute15;
      in_start_date(j) := l_tqlv_rec.start_date;
      in_period(j) := l_tqlv_rec.period;
      in_number_of_periods(j) := l_tqlv_rec.number_of_periods;
      in_lock_level_step(j) := l_tqlv_rec.lock_level_step;
      in_advance_or_arrears(j) := l_tqlv_rec.advance_or_arrears;
      in_yield_name(j) := l_tqlv_rec.yield_name;
      in_yield_value(j) := l_tqlv_rec.yield_value;
      in_implicit_interest_rate(j) := l_tqlv_rec.implicit_interest_rate;
      in_asset_value(j) := l_tqlv_rec.asset_value;
      in_residual_value(j) := l_tqlv_rec.residual_value;
      in_unbilled_receivables(j) := l_tqlv_rec.unbilled_receivables;
      in_asset_quantity(j) := l_tqlv_rec.asset_quantity;
      in_quote_quantity(j) := l_tqlv_rec.quote_quantity;
      in_split_kle_id(j) := l_tqlv_rec.split_kle_id;
      in_split_kle_name(j) := l_tqlv_rec.split_kle_name;
      in_description(j) := l_tqlv_rec.description;
      in_language(j) := l_lang;
      in_source_lang(j) := l_lang;
      in_currency_code(j) := l_tqlv_rec.currency_code;
      in_currency_conversion_code(j) := l_tqlv_rec.currency_conversion_code;
      in_currency_conversion_type(j) := l_tqlv_rec.currency_conversion_type;
      in_currency_conversion_rate(j) := l_tqlv_rec.currency_conversion_rate;
      in_currency_conversion_date(j) := l_tqlv_rec.currency_conversion_date;
      in_defaulted_yn(j) := l_tqlv_rec.defaulted_yn;
      in_org_id(j) := l_tqlv_rec.org_id;
      in_request_id(j) := l_tqlv_rec.request_id;
      in_program_application_id(j) := l_tqlv_rec.program_application_id;
      in_program_id(j) := l_tqlv_rec.program_id;
      in_program_update_date(j) := l_tqlv_rec.program_update_date;
      in_sfwt_flag(j) := l_tqlv_rec.sfwt_flag;
      -- rmunjulu Sales_Tax_Enhancement
      in_try_id(j) := l_tqlv_rec.try_id;

      in_amount(j) := l_tqlv_rec.amount;
      --dkagrawa bug 4187250
      in_due_date(j) := l_tqlv_rec.due_date;

      OKL_ACCOUNTING_UTIL.cross_currency_round_amount
              (p_api_version      => p_api_version,
               p_init_msg_list    => p_init_msg_list,
               x_return_status    => l_return_status,
               x_msg_count        => x_msg_count,
               x_msg_data         => x_msg_data,
               p_amount           => in_amount(j),
               p_currency_code    => in_currency_code(j),
               x_rounded_amount   => l_rounded_amount);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      in_amount(j) := l_rounded_amount;

      i := p_tqlv_tbl.next(i);
    END LOOP;

    -- Bulk insert into base table
    FORALL i in 1..l_tabsize
    INSERT INTO OKL_TXL_QUOTE_LINES_B(
        id,
        sty_id,
        kle_id,
        qlt_code,
        qte_id,
        line_number,
        amount,
        object_version_number,
        modified_yn,
        defaulted_yn,
        taxed_yn,
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
        start_date,
        period,
        number_of_periods,
        lock_level_step,
        advance_or_arrears,
        yield_name,
        yield_value,
        implicit_interest_rate,
        asset_value,
        residual_value,
        unbilled_receivables,
        asset_quantity,
        quote_quantity,
        split_kle_id,
        split_kle_name,
        currency_code,
        currency_conversion_code,
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date,
        try_id, -- rmunjulu Sales_Tax_Enhancement
        due_date ) --dkagrawa bug 4187250

      VALUES (
        in_id(i),
        in_sty_id(i),
        in_kle_id(i),
        in_qlt_code(i),
        in_qte_id(i),
        in_line_number(i),
        in_amount(i),
        in_object_version_number(i),
        in_modified_yn(i),
        in_defaulted_yn(i),
        in_taxed_yn(i),
        in_org_id(i),
        in_request_id(i),
        in_program_application_id(i),
        in_program_id(i),
        in_program_update_date(i),
        in_attribute_category(i),
        in_attribute1(i),
        in_attribute2(i),
        in_attribute3(i),
        in_attribute4(i),
        in_attribute5(i),
        in_attribute6(i),
        in_attribute7(i),
        in_attribute8(i),
        in_attribute9(i),
        in_attribute10(i),
        in_attribute11(i),
        in_attribute12(i),
        in_attribute13(i),
        in_attribute14(i),
        in_attribute15(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i),
        in_start_date(i),
        in_period(i),
        in_number_of_periods(i),
        in_lock_level_step(i),
        in_advance_or_arrears(i),
        in_yield_name(i),
        in_yield_value(i),
        in_implicit_interest_rate(i),
        in_asset_value(i),
        in_residual_value(i),
        in_unbilled_receivables(i),
        in_asset_quantity(i),
        in_quote_quantity(i),
        in_split_kle_id(i),
        in_split_kle_name(i),
        in_currency_code(i),
        in_currency_conversion_code(i),
        in_currency_conversion_type(i),
        in_currency_conversion_rate(i),
        in_currency_conversion_date(i),
        in_try_id(i), -- rmunjulu Sales_Tax_Enhancement
	in_due_date(i)); --dkagrawa bug 4187250

 -- sechawla Bug# 8429670  - Added
 FOR l_lang_rec IN get_languages LOOP

    -- Bulk insert into tl table
    FORALL i in 1..l_tabsize
    INSERT INTO OKL_TXL_QUOTE_LINES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          in_id(i),
          -- in_language(i), -- Bug# 8429670  Commented
          l_lang_rec.language_code, -- Bug# 8429670  Added
          in_source_lang(i),
          in_sfwt_flag(i),
          in_description(i),
          in_created_by(i),
          in_creation_date(i),
          in_last_updated_by(i),
          in_last_update_date(i),
          in_last_update_login(i));
END LOOP; -- Bug# 8429670 added
x_tqlv_tbl := p_tqlv_tbl;
x_return_status := OKL_API.G_RET_STS_SUCCESS;
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row_bulk;
-- PAGARG Bug 4299668 **End**

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- lock_row for:OKL_TXL_QUOTE_LINES_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tql_rec                      IN tql_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tql_rec IN tql_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_QUOTE_LINES_B
     WHERE ID = p_tql_rec.id
       AND OBJECT_VERSION_NUMBER = p_tql_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tql_rec IN tql_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_QUOTE_LINES_B
    WHERE ID = p_tql_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TXL_QUOTE_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TXL_QUOTE_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_tql_rec);
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
      OPEN lchk_csr(p_tql_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tql_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tql_rec.object_version_number THEN
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
  -- lock_row for:OKL_TXL_QUOTE_LINES_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_quote_lines_tl_rec   IN OklTxlQuoteLinesTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_txl_quote_lines_tl_rec IN OklTxlQuoteLinesTlRecType) IS
    SELECT *
      FROM OKL_TXL_QUOTE_LINES_TL
     WHERE ID = p_okl_txl_quote_lines_tl_rec.id
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
      OPEN lock_csr(p_okl_txl_quote_lines_tl_rec);
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
  -- lock_row for:OKL_TXL_QUOTE_LINES_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_rec                     IN tqlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tql_rec                      tql_rec_type;
    l_okl_txl_quote_lines_tl_rec   OklTxlQuoteLinesTlRecType;
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
    migrate(p_tqlv_rec, l_tql_rec);
    migrate(p_tqlv_rec, l_okl_txl_quote_lines_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tql_rec
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
      l_okl_txl_quote_lines_tl_rec
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
  -- PL/SQL TBL lock_row for:TQLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type) IS

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
    IF (p_tqlv_tbl.COUNT > 0) THEN
      i := p_tqlv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tqlv_rec                     => p_tqlv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tqlv_tbl.LAST);
        i := p_tqlv_tbl.NEXT(i);
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
  -- update_row for:OKL_TXL_QUOTE_LINES_B --
  ------------------------------------------
  -- Start of comments
  -- Procedure Name  : update_row
  -- Description     : Update Row into OKL_TXL_QUOTE_LINES_B table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_B table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  --                 : 15-Feb-2005 PAGARG 4161133 code for new column DUE_DATE
  -- End of comments
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tql_rec                      IN tql_rec_type,
    x_tql_rec                      OUT NOCOPY tql_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tql_rec                      tql_rec_type := p_tql_rec;
    l_def_tql_rec                  tql_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    -- Start of comments
    -- Function Name   : populate_new_record
    -- Description     : Populate new record into OKL_TXL_QUOTE_LINES_B table
    -- Business Rules  :
    -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_B table
    -- Version         : 1.0
    -- History         : 18-DEC-2002 BAKUCHIB 2667636
    --                 : Added columns Currency code, currency Conversion_code
    --                   Currency conversion type, currency conversion date
    --                   currency conversion rate.
    --                 : 15-Feb-2005 PAGARG 4161133 code for new column DUE_DATE
    FUNCTION populate_new_record (
      p_tql_rec	IN tql_rec_type,
      x_tql_rec	OUT NOCOPY tql_rec_type
    ) RETURN VARCHAR2 IS
      l_tql_rec                      tql_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      -- Added by Suresh P Bagukkudumbi
      -- Added for handling concurrent manager fields

      x_tql_rec := p_tql_rec;
      -- Get current database values
      l_tql_rec := get_rec(p_tql_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tql_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.id := l_tql_rec.id;
      END IF;
      IF (x_tql_rec.sty_id = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.sty_id := l_tql_rec.sty_id;
      END IF;
      IF (x_tql_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.kle_id := l_tql_rec.kle_id;
      END IF;
      IF (x_tql_rec.qlt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.qlt_code := l_tql_rec.qlt_code;
      END IF;
      IF (x_tql_rec.qte_id = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.qte_id := l_tql_rec.qte_id;
      END IF;
      IF (x_tql_rec.line_number = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.line_number := l_tql_rec.line_number;
      END IF;
      IF (x_tql_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.amount := l_tql_rec.amount;
      END IF;
      IF (x_tql_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.object_version_number := l_tql_rec.object_version_number;
      END IF;
      IF (x_tql_rec.modified_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.modified_yn := l_tql_rec.modified_yn;
      END IF;
      IF (x_tql_rec.defaulted_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.defaulted_yn := l_tql_rec.defaulted_yn;
      END IF;
      IF (x_tql_rec.taxed_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.taxed_yn := l_tql_rec.taxed_yn;
      END IF;
      IF (x_tql_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.org_id := l_tql_rec.org_id;
      END IF;
      IF (x_tql_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.request_id := l_tql_rec.request_id;
      END IF;
      IF (x_tql_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.program_application_id := l_tql_rec.program_application_id;
      END IF;
      IF (x_tql_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.program_id := l_tql_rec.program_id;
      END IF;
      IF (x_tql_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tql_rec.program_update_date := l_tql_rec.program_update_date;
      END IF;
      IF (x_tql_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute_category := l_tql_rec.attribute_category;
      END IF;
      IF (x_tql_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute1 := l_tql_rec.attribute1;
      END IF;
      IF (x_tql_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute2 := l_tql_rec.attribute2;
      END IF;
      IF (x_tql_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute3 := l_tql_rec.attribute3;
      END IF;
      IF (x_tql_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute4 := l_tql_rec.attribute4;
      END IF;
      IF (x_tql_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute5 := l_tql_rec.attribute5;
      END IF;
      IF (x_tql_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute6 := l_tql_rec.attribute6;
      END IF;
      IF (x_tql_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute7 := l_tql_rec.attribute7;
      END IF;
      IF (x_tql_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute8 := l_tql_rec.attribute8;
      END IF;
      IF (x_tql_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute9 := l_tql_rec.attribute9;
      END IF;
      IF (x_tql_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute10 := l_tql_rec.attribute10;
      END IF;
      IF (x_tql_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute11 := l_tql_rec.attribute11;
      END IF;
      IF (x_tql_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute12 := l_tql_rec.attribute12;
      END IF;
      IF (x_tql_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute13 := l_tql_rec.attribute13;
      END IF;
      IF (x_tql_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute14 := l_tql_rec.attribute14;
      END IF;
      IF (x_tql_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.attribute15 := l_tql_rec.attribute15;
      END IF;
      IF (x_tql_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.created_by := l_tql_rec.created_by;
      END IF;
      IF (x_tql_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tql_rec.creation_date := l_tql_rec.creation_date;
      END IF;
      IF (x_tql_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.last_updated_by := l_tql_rec.last_updated_by;
      END IF;
      IF (x_tql_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tql_rec.last_update_date := l_tql_rec.last_update_date;
      END IF;
      IF (x_tql_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.last_update_login := l_tql_rec.last_update_login;
      END IF;
      IF (x_tql_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_tql_rec.start_date := l_tql_rec.start_date;
      END IF;
      IF (x_tql_rec.period = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.period := l_tql_rec.period;
      END IF;
      IF (x_tql_rec.number_of_periods = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.number_of_periods := l_tql_rec.number_of_periods;
      END IF;
      IF (x_tql_rec.lock_level_step = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.lock_level_step := l_tql_rec.lock_level_step;
      END IF;
      IF (x_tql_rec.advance_or_arrears = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.advance_or_arrears := l_tql_rec.advance_or_arrears;
      END IF;
      IF (x_tql_rec.yield_name = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.yield_name := l_tql_rec.yield_name;
      END IF;
      IF (x_tql_rec.yield_value = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.yield_value := l_tql_rec.yield_value;
      END IF;
      IF (x_tql_rec.implicit_interest_rate = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.implicit_interest_rate := l_tql_rec.implicit_interest_rate;
      END IF;
      IF (x_tql_rec.asset_value = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.asset_value := l_tql_rec.asset_value;
      END IF;
      IF (x_tql_rec.residual_value = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.residual_value := l_tql_rec.residual_value;
      END IF;
      IF (x_tql_rec.unbilled_receivables = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.unbilled_receivables := l_tql_rec.unbilled_receivables;
      END IF;
      IF (x_tql_rec.asset_quantity = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.asset_quantity := l_tql_rec.asset_quantity;
      END IF;
      IF (x_tql_rec.quote_quantity = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.quote_quantity := l_tql_rec.quote_quantity;
      END IF;
      IF (x_tql_rec.split_kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.split_kle_id := l_tql_rec.split_kle_id;
      END IF;
      -- RMUNJULU 2757312
      IF (x_tql_rec.split_kle_name = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.split_kle_name := l_tql_rec.split_kle_name;
      END IF;
  -- BAKUCHIB 2667636 Start
     IF (x_tql_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.currency_code := l_tql_rec.currency_code;
      END IF;
      IF (x_tql_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.currency_conversion_code := l_tql_rec.currency_conversion_code;
      END IF;
      IF (x_tql_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tql_rec.currency_conversion_type := l_tql_rec.currency_conversion_type;
      END IF;
      IF (x_tql_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.currency_conversion_rate := l_tql_rec.currency_conversion_rate;
      END IF;
      IF (x_tql_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_tql_rec.currency_conversion_date := l_tql_rec.currency_conversion_date;
      END IF;
  -- BAKUCHIB 2667636 End
      --PAGARG 4161133 start
      -- populate attribute due date, added new to column
      IF (x_tql_rec.due_date = OKC_API.G_MISS_DATE)
      THEN
        x_tql_rec.due_date := l_tql_rec.due_date;
      END IF;
      --PAGARG 4161133 end
      -- rmunjulu Sales_Tax_Enhancement
      IF (x_tql_rec.try_id = OKC_API.G_MISS_NUM)
      THEN
        x_tql_rec.try_id := l_tql_rec.try_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_QUOTE_LINES_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tql_rec IN  tql_rec_type,
      x_tql_rec OUT NOCOPY tql_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tql_rec := p_tql_rec;
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
      p_tql_rec,                         -- IN
      l_tql_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tql_rec, l_def_tql_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_QUOTE_LINES_B
    SET STY_ID = l_def_tql_rec.sty_id,
        KLE_ID = l_def_tql_rec.kle_id,
        QLT_CODE = l_def_tql_rec.qlt_code,
        QTE_ID = l_def_tql_rec.qte_id,
        LINE_NUMBER = l_def_tql_rec.line_number,
        AMOUNT = l_def_tql_rec.amount,
        OBJECT_VERSION_NUMBER = l_def_tql_rec.object_version_number,
        MODIFIED_YN = l_def_tql_rec.modified_yn,
        DEFAULTED_YN = l_def_tql_rec.defaulted_yn,
        TAXED_YN = l_def_tql_rec.taxed_yn,
        ORG_ID = l_def_tql_rec.org_id,
        REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1, NULL,
                   FND_GLOBAL.CONC_REQUEST_ID),l_def_tql_rec.request_id),
        PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,
                   FND_GLOBAL.PROG_APPL_ID),l_def_tql_rec.program_application_id),
        PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,
                 FND_GLOBAL.CONC_PROGRAM_ID),l_def_tql_rec.program_id),
        PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,
                 SYSDATE),NULL,l_def_tql_rec.program_update_date,SYSDATE),

        ATTRIBUTE_CATEGORY = l_def_tql_rec.attribute_category,
        ATTRIBUTE1 = l_def_tql_rec.attribute1,
        ATTRIBUTE2 = l_def_tql_rec.attribute2,
        ATTRIBUTE3 = l_def_tql_rec.attribute3,
        ATTRIBUTE4 = l_def_tql_rec.attribute4,
        ATTRIBUTE5 = l_def_tql_rec.attribute5,
        ATTRIBUTE6 = l_def_tql_rec.attribute6,
        ATTRIBUTE7 = l_def_tql_rec.attribute7,
        ATTRIBUTE8 = l_def_tql_rec.attribute8,
        ATTRIBUTE9 = l_def_tql_rec.attribute9,
        ATTRIBUTE10 = l_def_tql_rec.attribute10,
        ATTRIBUTE11 = l_def_tql_rec.attribute11,
        ATTRIBUTE12 = l_def_tql_rec.attribute12,
        ATTRIBUTE13 = l_def_tql_rec.attribute13,
        ATTRIBUTE14 = l_def_tql_rec.attribute14,
        ATTRIBUTE15 = l_def_tql_rec.attribute15,
        CREATED_BY = l_def_tql_rec.created_by,
        CREATION_DATE = l_def_tql_rec.creation_date,
        LAST_UPDATED_BY = l_def_tql_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tql_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tql_rec.last_update_login,
        START_DATE = l_def_tql_rec.start_date,
        PERIOD = l_def_tql_rec.period,
        NUMBER_OF_PERIODS = l_def_tql_rec.number_of_periods,
        LOCK_LEVEL_STEP = l_def_tql_rec.lock_level_step,
        ADVANCE_OR_ARREARS = l_def_tql_rec.advance_or_arrears,
        YIELD_NAME = l_def_tql_rec.yield_name,
        YIELD_VALUE = l_def_tql_rec.yield_value,
        IMPLICIT_INTEREST_RATE = l_def_tql_rec.implicit_interest_rate,
        ASSET_VALUE = l_def_tql_rec.asset_value,
        RESIDUAL_VALUE = l_def_tql_rec.residual_value,
        UNBILLED_RECEIVABLES = l_def_tql_rec.unbilled_receivables,
        ASSET_QUANTITY = l_def_tql_rec.asset_quantity,
        QUOTE_QUANTITY = l_def_tql_rec.quote_quantity,
        SPLIT_KLE_ID = l_def_tql_rec.split_kle_id,
        -- RMUNJULU 2757312
        SPLIT_KLE_NAME = l_def_tql_rec.split_kle_name,
  -- BAKCUHIUB 2667636 Start
        CURRENCY_CODE = l_def_tql_rec.currency_code,
        CURRENCY_CONVERSION_CODE = l_def_tql_rec.currency_conversion_code,
        CURRENCY_CONVERSION_TYPE = l_def_tql_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_tql_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_tql_rec.currency_conversion_date,
  -- BAKUCHIB 2667636 End
        DUE_DATE = l_def_tql_rec.due_date, -- PAGARG Bug 4161133 new column
        TRY_ID = l_def_tql_rec.try_id-- rmunjulu Sales_Tax_Enhancement
    WHERE ID = l_def_tql_rec.id;

    x_tql_rec := l_def_tql_rec;
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
  -- update_row for:OKL_TXL_QUOTE_LINES_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_quote_lines_tl_rec   IN OklTxlQuoteLinesTlRecType,
    x_okl_txl_quote_lines_tl_rec   OUT NOCOPY OklTxlQuoteLinesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_txl_quote_lines_tl_rec   OklTxlQuoteLinesTlRecType := p_okl_txl_quote_lines_tl_rec;
    ldefokltxlquotelinestlrec      OklTxlQuoteLinesTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_txl_quote_lines_tl_rec	IN OklTxlQuoteLinesTlRecType,
      x_okl_txl_quote_lines_tl_rec	OUT NOCOPY OklTxlQuoteLinesTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_txl_quote_lines_tl_rec   OklTxlQuoteLinesTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_quote_lines_tl_rec := p_okl_txl_quote_lines_tl_rec;
      -- Get current database values
      l_okl_txl_quote_lines_tl_rec := get_rec(p_okl_txl_quote_lines_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_txl_quote_lines_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txl_quote_lines_tl_rec.id := l_okl_txl_quote_lines_tl_rec.id;
      END IF;
      IF (x_okl_txl_quote_lines_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txl_quote_lines_tl_rec.language := l_okl_txl_quote_lines_tl_rec.language;
      END IF;
      IF (x_okl_txl_quote_lines_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txl_quote_lines_tl_rec.source_lang := l_okl_txl_quote_lines_tl_rec.source_lang;
      END IF;
      IF (x_okl_txl_quote_lines_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txl_quote_lines_tl_rec.sfwt_flag := l_okl_txl_quote_lines_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_txl_quote_lines_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txl_quote_lines_tl_rec.description := l_okl_txl_quote_lines_tl_rec.description;
      END IF;
      IF (x_okl_txl_quote_lines_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txl_quote_lines_tl_rec.created_by := l_okl_txl_quote_lines_tl_rec.created_by;
      END IF;
      IF (x_okl_txl_quote_lines_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_txl_quote_lines_tl_rec.creation_date := l_okl_txl_quote_lines_tl_rec.creation_date;
      END IF;
      IF (x_okl_txl_quote_lines_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txl_quote_lines_tl_rec.last_updated_by := l_okl_txl_quote_lines_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_txl_quote_lines_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_txl_quote_lines_tl_rec.last_update_date := l_okl_txl_quote_lines_tl_rec.last_update_date;
      END IF;
      IF (x_okl_txl_quote_lines_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txl_quote_lines_tl_rec.last_update_login := l_okl_txl_quote_lines_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_TXL_QUOTE_LINES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_quote_lines_tl_rec IN  OklTxlQuoteLinesTlRecType,
      x_okl_txl_quote_lines_tl_rec OUT NOCOPY OklTxlQuoteLinesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_quote_lines_tl_rec := p_okl_txl_quote_lines_tl_rec;
      x_okl_txl_quote_lines_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_quote_lines_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txl_quote_lines_tl_rec,      -- IN
      l_okl_txl_quote_lines_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_txl_quote_lines_tl_rec, ldefokltxlquotelinestlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_QUOTE_LINES_TL
    SET DESCRIPTION = ldefokltxlquotelinestlrec.description,
        CREATED_BY = ldefokltxlquotelinestlrec.created_by,
        SOURCE_LANG = ldefokltxlquotelinestlrec.source_lang, --Fix for bug 3637102
        CREATION_DATE = ldefokltxlquotelinestlrec.creation_date,
        LAST_UPDATED_BY = ldefokltxlquotelinestlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltxlquotelinestlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltxlquotelinestlrec.last_update_login
    WHERE ID = ldefokltxlquotelinestlrec.id
        AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);--Fix for bug 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_TXL_QUOTE_LINES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltxlquotelinestlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_txl_quote_lines_tl_rec := ldefokltxlquotelinestlrec;
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
  -- update_row for:OKL_TXL_QUOTE_LINES_V --
  ------------------------------------------
  -- Start of comments
  -- Procedure Name  : update_row
  -- Description     : Update Row into OKL_TXL_QUOTE_LINES_V table
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
  -- Version         : 1.0
  -- History         : 18-DEC-2002 BAKUCHIB 2667636  Modified
  --                 : Added columns Currency code, currency Conversion_code
  --                   Currency conversion type, currency conversion date
  --                   currency conversion rate.
  --                 : RMUNJULU 09-MAY-03 2949544 Added code to round
  --                   the amount field before saving to table
  --                 : PAGARG 15-Feb-2005 Bug 4161133 Code for new column due_date
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_rec                     IN tqlv_rec_type,
    x_tqlv_rec                     OUT NOCOPY tqlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tqlv_rec                     tqlv_rec_type := p_tqlv_rec;
    l_def_tqlv_rec                 tqlv_rec_type;
    l_okl_txl_quote_lines_tl_rec   OklTxlQuoteLinesTlRecType;
    lx_okl_txl_quote_lines_tl_rec  OklTxlQuoteLinesTlRecType;
    l_tql_rec                      tql_rec_type;
    lx_tql_rec                     tql_rec_type;


    -- RMUNJULU 09-MAY-03 2949544 Added variable
    l_rounded_amount NUMBER;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tqlv_rec	IN tqlv_rec_type
    ) RETURN tqlv_rec_type IS
      l_tqlv_rec	tqlv_rec_type := p_tqlv_rec;
    BEGIN
      l_tqlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tqlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tqlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tqlv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    -- Start of comments
    -- Function Name   : populate_new_record
    -- Description     : Populate new record into OKL_TXL_QUOTE_LINES_V table
    -- Business Rules  :
    -- Parameters      : Record structure of OKL_TXL_QUOTE_LINES_V table
    -- Version         : 1.0
    -- History         : 18-DEC-2002 BAKUCHIB 2667636 Modified
    --                 : Added columns Currency code, currency Conversion_code
    --                   Currency conversion type, currency conversion date
    --                   currency conversion rate.
    --                 : PAGARG 15-Feb-2005 Bug 4161133 Code for new column due_date
    FUNCTION populate_new_record (
      p_tqlv_rec	IN tqlv_rec_type,
      x_tqlv_rec	OUT NOCOPY tqlv_rec_type
    ) RETURN VARCHAR2 IS
      l_tqlv_rec                     tqlv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tqlv_rec := p_tqlv_rec;
      -- Get current database values
      l_tqlv_rec := get_rec(p_tqlv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tqlv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.id := l_tqlv_rec.id;
      END IF;
      IF (x_tqlv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.object_version_number := l_tqlv_rec.object_version_number;
      END IF;
      IF (x_tqlv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.sfwt_flag := l_tqlv_rec.sfwt_flag;
      END IF;
      IF (x_tqlv_rec.qlt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.qlt_code := l_tqlv_rec.qlt_code;
      END IF;
      IF (x_tqlv_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.kle_id := l_tqlv_rec.kle_id;
      END IF;
      IF (x_tqlv_rec.sty_id = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.sty_id := l_tqlv_rec.sty_id;
      END IF;
      IF (x_tqlv_rec.qte_id = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.qte_id := l_tqlv_rec.qte_id;
      END IF;
      IF (x_tqlv_rec.line_number = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.line_number := l_tqlv_rec.line_number;
      END IF;
      IF (x_tqlv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.description := l_tqlv_rec.description;
      END IF;
      IF (x_tqlv_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.amount := l_tqlv_rec.amount;
      -- DAPATEL - 01/08/02 - Added to reflect a manual amount updated.
      ELSE
        IF (x_tqlv_rec.amount <> l_tqlv_rec.amount) THEN
          x_tqlv_rec.MODIFIED_YN := G_YES;
        END IF;
      -- End
      END IF;
      IF (x_tqlv_rec.modified_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.modified_yn := l_tqlv_rec.modified_yn;
      END IF;
      IF (x_tqlv_rec.defaulted_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.defaulted_yn := l_tqlv_rec.defaulted_yn;
      END IF;
      IF (x_tqlv_rec.taxed_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.taxed_yn := l_tqlv_rec.taxed_yn;
      END IF;
      IF (x_tqlv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute_category := l_tqlv_rec.attribute_category;
      END IF;
      IF (x_tqlv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute1 := l_tqlv_rec.attribute1;
      END IF;
      IF (x_tqlv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute2 := l_tqlv_rec.attribute2;
      END IF;
      IF (x_tqlv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute3 := l_tqlv_rec.attribute3;
      END IF;
      IF (x_tqlv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute4 := l_tqlv_rec.attribute4;
      END IF;
      IF (x_tqlv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute5 := l_tqlv_rec.attribute5;
      END IF;
      IF (x_tqlv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute6 := l_tqlv_rec.attribute6;
      END IF;
      IF (x_tqlv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute7 := l_tqlv_rec.attribute7;
      END IF;
      IF (x_tqlv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute8 := l_tqlv_rec.attribute8;
      END IF;
      IF (x_tqlv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute9 := l_tqlv_rec.attribute9;
      END IF;
      IF (x_tqlv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute10 := l_tqlv_rec.attribute10;
      END IF;
      IF (x_tqlv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute11 := l_tqlv_rec.attribute11;
      END IF;
      IF (x_tqlv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute12 := l_tqlv_rec.attribute12;
      END IF;
      IF (x_tqlv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute13 := l_tqlv_rec.attribute13;
      END IF;
      IF (x_tqlv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute14 := l_tqlv_rec.attribute14;
      END IF;
      IF (x_tqlv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.attribute15 := l_tqlv_rec.attribute15;
      END IF;
      IF (x_tqlv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.org_id := l_tqlv_rec.org_id;
      END IF;
      IF (x_tqlv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.request_id := l_tqlv_rec.request_id;
      END IF;
      IF (x_tqlv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.program_application_id := l_tqlv_rec.program_application_id;
      END IF;
      IF (x_tqlv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.program_id := l_tqlv_rec.program_id;
      END IF;
      IF (x_tqlv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tqlv_rec.program_update_date := l_tqlv_rec.program_update_date;
      END IF;
      IF (x_tqlv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.created_by := l_tqlv_rec.created_by;
      END IF;
      IF (x_tqlv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tqlv_rec.creation_date := l_tqlv_rec.creation_date;
      END IF;
      IF (x_tqlv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.last_updated_by := l_tqlv_rec.last_updated_by;
      END IF;
      IF (x_tqlv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tqlv_rec.last_update_date := l_tqlv_rec.last_update_date;
      END IF;
      IF (x_tqlv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.last_update_login := l_tqlv_rec.last_update_login;
      END IF;
      IF (x_tqlv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_tqlv_rec.start_date := l_tqlv_rec.start_date;
      END IF;
      IF (x_tqlv_rec.period = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.period := l_tqlv_rec.period;
      END IF;
      IF (x_tqlv_rec.number_of_periods = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.number_of_periods := l_tqlv_rec.number_of_periods;
      END IF;
      IF (x_tqlv_rec.lock_level_step = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.lock_level_step := l_tqlv_rec.lock_level_step;
      END IF;
      IF (x_tqlv_rec.advance_or_arrears = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.advance_or_arrears := l_tqlv_rec.advance_or_arrears;
      END IF;
      IF (x_tqlv_rec.yield_name = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.yield_name := l_tqlv_rec.yield_name;
      END IF;
      IF (x_tqlv_rec.yield_value = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.yield_value := l_tqlv_rec.yield_value;
      END IF;
      IF (x_tqlv_rec.implicit_interest_rate = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.implicit_interest_rate := l_tqlv_rec.implicit_interest_rate;
      END IF;
      IF (x_tqlv_rec.asset_value = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.asset_value := l_tqlv_rec.asset_value;
      END IF;
      IF (x_tqlv_rec.residual_value = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.residual_value := l_tqlv_rec.residual_value;
      END IF;
      IF (x_tqlv_rec.unbilled_receivables = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.unbilled_receivables := l_tqlv_rec.unbilled_receivables;
      END IF;
      IF (x_tqlv_rec.asset_quantity = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.asset_quantity := l_tqlv_rec.asset_quantity;
      END IF;
      IF (x_tqlv_rec.quote_quantity = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.quote_quantity := l_tqlv_rec.quote_quantity;
      END IF;
      IF (x_tqlv_rec.split_kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.split_kle_id := l_tqlv_rec.split_kle_id;
      END IF;
      -- RMUNJULU 2757312
      IF (x_tqlv_rec.split_kle_name = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.split_kle_name := l_tqlv_rec.split_kle_name;
      END IF;
  -- BAKUCHIB 2667636 Start
     IF (x_tqlv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.currency_code := l_tqlv_rec.currency_code;
      END IF;
      IF (x_tqlv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.currency_conversion_code := l_tqlv_rec.currency_conversion_code;
      END IF;
      IF (x_tqlv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tqlv_rec.currency_conversion_type := l_tqlv_rec.currency_conversion_type;
      END IF;
      IF (x_tqlv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.currency_conversion_rate := l_tqlv_rec.currency_conversion_rate;
      END IF;
      IF (x_tqlv_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_tqlv_rec.currency_conversion_date := l_tqlv_rec.currency_conversion_date;
      END IF;
  -- BAKUCHIB 2667636 End
      -- PAGARG Bug 4161133 start
      -- Populate new column due_date
      IF (x_tqlv_rec.due_date = OKL_API.G_MISS_DATE)
      THEN
        x_tqlv_rec.due_date := l_tqlv_rec.due_date;
      END IF;
      -- PAGARG Bug 4161133 end
      -- rmunjulu Sales_Tax_Enhancement
      IF (x_tqlv_rec.try_id = OKL_API.G_MISS_NUM)
      THEN
        x_tqlv_rec.try_id := l_tqlv_rec.try_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_QUOTE_LINES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tqlv_rec IN  tqlv_rec_type,
      x_tqlv_rec OUT NOCOPY tqlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tqlv_rec := p_tqlv_rec;
      x_tqlv_rec.OBJECT_VERSION_NUMBER := NVL(x_tqlv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      -- Default the YN columns if value not passed
      IF p_tqlv_rec.defaulted_yn IS NULL
      OR p_tqlv_rec.defaulted_yn = OKC_API.G_MISS_CHAR THEN
        x_tqlv_rec.defaulted_yn := 'N';
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
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tqlv_rec,                        -- IN
      l_tqlv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tqlv_rec, l_def_tqlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tqlv_rec := fill_who_columns(l_def_tqlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tqlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tqlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    -- RMUNJULU 09-MAY-03 2949544 Added code to round
    -- the amount field before saving to table
    OKL_ACCOUNTING_UTIL.cross_currency_round_amount
              (p_api_version      => p_api_version,
               p_init_msg_list    => p_init_msg_list,
               x_return_status    => l_return_status,
               x_msg_count        => x_msg_count,
               x_msg_data         => x_msg_data,
               p_amount           => l_def_tqlv_rec.amount,
               p_currency_code    => l_def_tqlv_rec.currency_code,
               x_rounded_amount   => l_rounded_amount);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    l_def_tqlv_rec.amount := l_rounded_amount;


    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tqlv_rec, l_okl_txl_quote_lines_tl_rec);
    migrate(l_def_tqlv_rec, l_tql_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_quote_lines_tl_rec,
      lx_okl_txl_quote_lines_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_quote_lines_tl_rec, l_def_tqlv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tql_rec,
      lx_tql_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tql_rec, l_def_tqlv_rec);
    x_tqlv_rec := l_def_tqlv_rec;
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
  -- PL/SQL TBL update_row for:TQLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type,
    x_tqlv_tbl                     OUT NOCOPY tqlv_tbl_type) IS

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
    IF (p_tqlv_tbl.COUNT > 0) THEN
      i := p_tqlv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tqlv_rec                     => p_tqlv_tbl(i),
          x_tqlv_rec                     => x_tqlv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tqlv_tbl.LAST);
        i := p_tqlv_tbl.NEXT(i);
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
  -- delete_row for:OKL_TXL_QUOTE_LINES_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tql_rec                      IN tql_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tql_rec                      tql_rec_type:= p_tql_rec;
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
    DELETE FROM OKL_TXL_QUOTE_LINES_B
     WHERE ID = l_tql_rec.id;

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
  -- delete_row for:OKL_TXL_QUOTE_LINES_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_quote_lines_tl_rec   IN OklTxlQuoteLinesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_txl_quote_lines_tl_rec   OklTxlQuoteLinesTlRecType:= p_okl_txl_quote_lines_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_TXL_QUOTE_LINES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_quote_lines_tl_rec IN  OklTxlQuoteLinesTlRecType,
      x_okl_txl_quote_lines_tl_rec OUT NOCOPY OklTxlQuoteLinesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_quote_lines_tl_rec := p_okl_txl_quote_lines_tl_rec;
      x_okl_txl_quote_lines_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_txl_quote_lines_tl_rec,      -- IN
      l_okl_txl_quote_lines_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TXL_QUOTE_LINES_TL
     WHERE ID = l_okl_txl_quote_lines_tl_rec.id;

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
  -- delete_row for:OKL_TXL_QUOTE_LINES_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_rec                     IN tqlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tqlv_rec                     tqlv_rec_type := p_tqlv_rec;
    l_okl_txl_quote_lines_tl_rec   OklTxlQuoteLinesTlRecType;
    l_tql_rec                      tql_rec_type;
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
    migrate(l_tqlv_rec, l_okl_txl_quote_lines_tl_rec);
    migrate(l_tqlv_rec, l_tql_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_quote_lines_tl_rec
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
      l_tql_rec
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
  -- PL/SQL TBL delete_row for:TQLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type) IS

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
    IF (p_tqlv_tbl.COUNT > 0) THEN
      i := p_tqlv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tqlv_rec                     => p_tqlv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tqlv_tbl.LAST);
        i := p_tqlv_tbl.NEXT(i);
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

END OKL_TQL_PVT;

/
