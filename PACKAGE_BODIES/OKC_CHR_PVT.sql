--------------------------------------------------------
--  DDL for Package Body OKC_CHR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CHR_PVT" AS
/* $Header: OKCSCHRB.pls 120.7 2007/09/07 10:07:15 vmutyala ship $ */

    l_application_id NUMBER;

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
  ---------------------------------------------------------------------------

  /************************ HAND-CODED *********************************/
    FUNCTION Validate_Attributes (p_chrv_rec IN chrv_rec_type)
    RETURN VARCHAR2;
    G_NO_PARENT_RECORD CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
    G_CHILD_RECORD_EXISTS CONSTANT VARCHAR2(200) := 'OKC_CANNOT_DELETE_MASTER';
    G_TABLE_TOKEN CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
    G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
    G_SQLERRM_TOKEN CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
    G_SQLCODE_TOKEN CONSTANT VARCHAR2(200) := 'ERROR_CODE';
    G_VIEW CONSTANT VARCHAR2(200) := 'OKC_K_HEADERS_V';
    G_EXCEPTION_HALT_VALIDATION EXCEPTION;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_contract_number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_contract_number(x_return_status OUT NOCOPY VARCHAR2,
                                       p_chrv_rec IN chrv_rec_type) IS

    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('100: Entered validate_contract_number', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.contract_number = OKC_API.G_MISS_CHAR OR
            p_chrv_rec.contract_number IS NULL)
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'Contract Number');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        IF (l_debug = 'Y') THEN
            okc_debug.LOG('200: Exiting validate_contract_number', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('300: Exiting validate_contract_number:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('400: Exiting validate_contract_number:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);

	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    END validate_contract_number;

  -- Start of comments
  --
  -- Procedure Name  : validate_currency_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_currency_code(x_return_status OUT NOCOPY VARCHAR2,
                                     p_chrv_rec IN chrv_rec_type) IS

    l_dummy_var VARCHAR2(1) := '?';
    CURSOR l_fndv_csr IS
        SELECT 'x'
      FROM FND_CURRENCIES_VL
      WHERE currency_code = p_chrv_rec.currency_code
      AND SYSDATE BETWEEN nvl(start_date_active, SYSDATE)
                   AND nvl(end_date_active, SYSDATE);
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('500: Entered validate_currency_code', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.currency_code = OKC_API.G_MISS_CHAR OR
            p_chrv_rec.currency_code IS NULL)
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'Currency Code');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    -- check data is in lookup table
        OPEN l_fndv_csr;
        FETCH l_fndv_csr INTO l_dummy_var;
        CLOSE l_fndv_csr;

      -- if l_dummy_var still set to default, data was not found
        IF (l_dummy_var = '?') THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_no_parent_record,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'currency_code',
                                p_token2 => g_child_table_token,
                                p_token2_value => G_VIEW,
                                p_token3 => g_parent_table_token,
                                p_token3_value => 'FND_CURRENCIES');
	    -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('600: Exiting validate_currency_code', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('700: Exiting validate_currency_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('800: Exiting validate_currency_code:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
            IF l_fndv_csr%ISOPEN THEN
                CLOSE l_fndv_csr;
            END IF;


    END validate_currency_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_sfwt_flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_sfwt_flag(x_return_status OUT NOCOPY VARCHAR2,
                                 p_chrv_rec IN chrv_rec_type) IS

    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('900: Entered validate_sfwt_flag', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.sfwt_flag = OKC_API.G_MISS_CHAR OR
            p_chrv_rec.sfwt_flag IS NULL)
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'sfwt_flag');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    -- check allowed values
        IF (upper(p_chrv_rec.sfwt_flag) NOT IN ('Y', 'N')) THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'sfwt_flag');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        IF (l_debug = 'Y') THEN
            okc_debug.LOG('1000: Exiting validate_sfwt_flag', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('1100: Exiting validate_sfwt_flag:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('1200: Exiting validate_sfwt_flag:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    END validate_sfwt_flag;

  -- Start of comments
  --
  -- Procedure Name  : validate_chr_id_response
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_chr_id_response(x_return_status OUT NOCOPY VARCHAR2,
                                       p_chrv_rec IN chrv_rec_type) IS

    l_dummy_var VARCHAR2(1) := '?';
    CURSOR l_chrv_csr IS
        SELECT 'x'
        --npalepu 08-11-2005 modified for bug # 4691662.
        --Replaced table okc_k_headers_b with headers_All_b table
      /* FROM OKC_K_HEADERS_B */
        FROM OKC_K_HEADERS_ALL_B
        --end npalepu
        WHERE id = p_chrv_rec.chr_id_response;

    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('1300: Entered validate_chr_id_response', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (chr_id_response is optional)
        IF (p_chrv_rec.chr_id_response <> OKC_API.G_MISS_NUM AND
            p_chrv_rec.chr_id_response IS NOT NULL)
            THEN
            OPEN l_chrv_csr;
            FETCH l_chrv_csr INTO l_dummy_var;
            CLOSE l_chrv_csr;
       -- if l_dummy_var still set to default, data was not found
            IF (l_dummy_var = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_no_parent_record,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'chr_id_response',
                                    p_token2 => g_child_table_token,
                                    p_token2_value => G_VIEW,
                                    p_token3 => g_parent_table_token,
                                    p_token3_value => G_VIEW);
	     -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('1400: Exiting validate_chr_id_response', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('1500: Exiting validate_chr_id_response:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
            IF l_chrv_csr%ISOPEN THEN
                CLOSE l_chrv_csr;
            END IF;


    END validate_chr_id_response;

  -- Start of comments
  --
  -- Procedure Name  : validate_chr_id_award
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_chr_id_award(x_return_status OUT NOCOPY VARCHAR2,
                                    p_chrv_rec IN chrv_rec_type) IS

    l_dummy_var VARCHAR2(1) := '?';
    CURSOR l_chrv_csr IS
        SELECT 'x'
        --npalepu 08-11-2005 modified for bug # 4691662.
        --Replaced table okc_k_headers_b with headers_All_b table
      /* FROM OKC_K_HEADERS_B */
        FROM OKC_K_HEADERS_ALL_B
        --end npalepu
        WHERE id = p_chrv_rec.chr_id_award;

    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('1600: Entered validate_chr_id_award', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (chr_id_award is optional)
        IF (p_chrv_rec.chr_id_award <> OKC_API.G_MISS_NUM AND
            p_chrv_rec.chr_id_award IS NOT NULL)
            THEN
            OPEN l_chrv_csr;
            FETCH l_chrv_csr INTO l_dummy_var;
            CLOSE l_chrv_csr;
       -- if l_dummy_var still set to default, data was not found
            IF (l_dummy_var = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_no_parent_record,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'chr_id_award',
                                    p_token2 => g_child_table_token,
                                    p_token2_value => G_VIEW,
                                    p_token3 => g_parent_table_token,
                                    p_token3_value => G_VIEW);
	     -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('1700: Exiting validate_chr_id_award', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('1800: Exiting validate_chr_id_award:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
            IF l_chrv_csr%ISOPEN THEN
                CLOSE l_chrv_csr;
            END IF;


    END validate_chr_id_award;

  -- Start of comments
  --
  -- Procedure Name  : validate_INV_ORGANIZATION_ID
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_INV_ORGANIZATION_ID(x_return_status OUT NOCOPY VARCHAR2,
                                           p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('1900: Entered validate_INV_ORGANIZATION_ID', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.INV_ORGANIZATION_ID = OKC_API.G_MISS_NUM OR
            p_chrv_rec.INV_ORGANIZATION_ID IS NULL)
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'INV_ORGANIZATION_ID');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('2000: Exiting validate_INV_ORGANIZATION_ID', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('2100: Exiting validate_INV_ORGANIZATION_ID:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('2200: Exiting validate_INV_ORGANIZATION_ID:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_INV_ORGANIZATION_ID;

  -- Start of comments
  --
  -- Procedure Name  : validate_sts_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_sts_code(x_return_status OUT NOCOPY VARCHAR2,
                                p_chrv_rec IN chrv_rec_type) IS
    l_dummy_var VARCHAR2(1) := '?';
    CURSOR l_stsv_csr (p_code IN VARCHAR2) IS
        SELECT 'x'
         FROM Okc_Statuses_B
         WHERE okc_statuses_B.code = p_code;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('2300: Entered validate_sts_code', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.sts_code = OKC_API.G_MISS_CHAR OR
            p_chrv_rec.sts_code IS NULL)
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'sts_code');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    -- Check foreign key
        OPEN l_stsv_csr(p_chrv_rec.sts_code);
        FETCH l_stsv_csr INTO l_dummy_var;
        CLOSE l_stsv_csr;

        IF (l_dummy_var = '?') THEN
	  --set error message in message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => g_app_name,
                                p_msg_name => g_no_parent_record,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'sts_code',
                                p_token2 => g_child_table_token,
                                p_token2_value => G_VIEW,
                                p_token3 => g_parent_table_token,
                                p_token3_value => 'OKC_STATUSES_V');
	    -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('2400: Exiting validate_sts_code', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('2500: Exiting validate_sts_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('2600: Exiting validate_sts_code:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_sts_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_qcl_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_qcl_id(x_return_status OUT NOCOPY VARCHAR2,
                              p_chrv_rec IN chrv_rec_type) IS

    l_dummy_var VARCHAR2(1) := '?';
    CURSOR l_qclv_csr IS
        SELECT 'x'
        FROM OKC_QA_CHECK_LISTS_B
        WHERE ID = p_chrv_rec.qcl_id;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('2700: Entered validate_qcl_id', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (qcl_id is optional)
        IF (p_chrv_rec.qcl_id <> OKC_API.G_MISS_NUM AND
            p_chrv_rec.qcl_id IS NOT NULL)
            THEN
            OPEN l_qclv_csr;
            FETCH l_qclv_csr INTO l_dummy_var;
            CLOSE l_qclv_csr;

       -- if l_dummy_var still set to default, data was not found
            IF (l_dummy_var = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_no_parent_record,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'qcl_id',
                                    p_token2 => g_child_table_token,
                                    p_token2_value => G_VIEW,
                                    p_token3 => g_parent_table_token,
                                    p_token3_value => G_VIEW);
	    -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('2800: Exiting validate_qcl_id', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('2900: Exiting validate_qcl_id:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
            IF l_qclv_csr%ISOPEN THEN
                CLOSE l_qclv_csr;
            END IF;


    END validate_qcl_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_org_ids
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_org_ids(x_return_status OUT NOCOPY VARCHAR2,
                               p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('3000: Entered validate_org_ids', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;



    -- check that data exists
        IF (p_chrv_rec.authoring_org_id = OKC_API.G_MISS_NUM OR
            p_chrv_rec.authoring_org_id IS NULL)
            THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'authoring_org_id');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
           -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

--mmadhavi start MOAC
    -- check that data exists
        IF (p_chrv_rec.org_id = OKC_API.G_MISS_NUM OR
            p_chrv_rec.org_id IS NULL)
            THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'org_id');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;


        IF (l_debug = 'Y') THEN
            okc_debug.LOG('3100: Exiting validate_org_ids', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('3200: Exiting validate_org_ids:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('3300: Exiting validate_org_ids:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_org_ids;

  -- Start of comments
  --
  -- Procedure Name  : validate_buy_or_sell
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_buy_or_sell(x_return_status OUT NOCOPY VARCHAR2,
                                   p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('3400: Entered validate_buy_or_sell', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.buy_or_sell <> OKC_API.G_MISS_CHAR AND
            p_chrv_rec.buy_or_sell IS NOT NULL)
            THEN
            IF (upper(p_chrv_rec.buy_or_sell) NOT IN ('B', 'S')) THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_invalid_value,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'buy_or_sell');
	     -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;

	     -- halt validation
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('3500: Exiting validate_buy_or_sell', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('3600: Exiting validate_buy_or_sell:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('3700: Exiting validate_buy_or_sell:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_buy_or_sell;

  -- Start of comments
  --
  -- Procedure Name  : validate_issue_or_receive
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_issue_or_receive(x_return_status OUT NOCOPY VARCHAR2,
                                        p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('3800: Entered validate_issue_or_receive', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.issue_or_receive <> OKC_API.G_MISS_CHAR AND
            p_chrv_rec.issue_or_receive IS NOT NULL)
            THEN
            IF (upper(p_chrv_rec.issue_or_receive) NOT IN ('I', 'R')) THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_invalid_value,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'issue_or_receive');
	     -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;

	     -- halt validation
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('3900: Exiting validate_issue_or_receive', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('4000: Exiting validate_issue_or_receive:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('4100: Exiting validate_issue_or_receive:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_issue_or_receive;

  -- Start of comments
  --
  -- Procedure Name  : validate_scs_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_scs_code(x_return_status OUT NOCOPY VARCHAR2,
                                p_chrv_rec IN chrv_rec_type) IS
    l_dummy_var VARCHAR2(1) := '?';
    CURSOR l_scsv_csr (p_code IN VARCHAR2) IS
        SELECT 'x'
          FROM Okc_Subclasses_B
         WHERE okc_subclasses_b.code = p_code;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('4200: Entered validate_scs_code', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.scs_code = OKC_API.G_MISS_CHAR OR
            p_chrv_rec.scs_code IS NULL)
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'scs_code');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    -- Check foreign key
        OPEN l_scsv_csr(p_chrv_rec.scs_code);
        FETCH l_scsv_csr INTO l_dummy_var;
        CLOSE l_scsv_csr;

    -- if l_dummy_var still set to default, data was not found
        IF (l_dummy_var = '?') THEN
            OKC_API.SET_MESSAGE(
                                p_app_name => g_app_name,
                                p_msg_name => g_no_parent_record,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'scs_code',
                                p_token2 => g_child_table_token,
                                p_token2_value => G_VIEW,
                                p_token3 => g_parent_table_token,
                                p_token3_value => 'OKC_SUBCLASSES_V');
	  -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('4300: Exiting validate_scs_code', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('4400: Exiting validate_scs_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('4500: Exiting validate_scs_code:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_scs_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_archived_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_archived_yn(x_return_status OUT NOCOPY VARCHAR2,
                                   p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('4600: Entered validate_archived_yn', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.archived_yn = OKC_API.G_MISS_CHAR OR
            p_chrv_rec.archived_yn IS NULL)
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'archived_yn');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    -- check allowed values
        IF (upper(p_chrv_rec.archived_yn) NOT IN ('Y', 'N')) THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'archived_yn');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('4700: Exiting validate_archived_yn', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('4800: Exiting validate_archived_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('4900: Exiting validate_archived_yn:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_archived_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_deleted_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_deleted_yn(x_return_status OUT NOCOPY VARCHAR2,
                                  p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('5000: Entered validate_deleted_yn', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.deleted_yn = OKC_API.G_MISS_CHAR OR
            p_chrv_rec.deleted_yn IS NULL)
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'deleted_yn');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    -- check allowed values
        IF (upper(p_chrv_rec.deleted_yn) NOT IN ('Y', 'N')) THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'deleted_yn');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('5100: Exiting validate_deleted_yn', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('5200: Exiting validate_deleted_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('5300: Exiting validate_deleted_yn:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_deleted_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_cust_po_number_req_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_cust_po_number_req_yn(x_return_status OUT NOCOPY VARCHAR2,
                                             p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('5400: Entered validate_cust_po_number_req_yn', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.cust_po_number_req_yn <> OKC_API.G_MISS_CHAR AND
            p_chrv_rec.cust_po_number_req_yn IS NOT NULL)
            THEN
            IF (upper(p_chrv_rec.cust_po_number_req_yn) NOT IN ('Y', 'N')) THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_invalid_value,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'cust_po_number_req_yn');
	     -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;

	     -- halt validation
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('5500: Exiting validate_cust_po_number_req_yn', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('5600: Exiting validate_cust_po_number_req_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('5700: Exiting validate_cust_po_number_req_yn:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_cust_po_number_req_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_pre_pay_req_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_pre_pay_req_yn(x_return_status OUT NOCOPY VARCHAR2,
                                      p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('5800: Entered validate_pre_pay_req_yn', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.pre_pay_req_yn <> OKC_API.G_MISS_CHAR AND
            p_chrv_rec.pre_pay_req_yn IS NOT NULL)
            THEN
       -- check allowed values
            IF (upper(p_chrv_rec.cust_po_number_req_yn) NOT IN ('Y', 'N')) THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_required_value,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'pre_pay_req_yn');
	   -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('5900: Exiting validate_pre_pay_req_yn', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('6000: Exiting validate_pre_pay_req_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('6100: Exiting validate_pre_pay_req_yn:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_pre_pay_req_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_template_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_template_yn(x_return_status OUT NOCOPY VARCHAR2,
                                   p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('6200: Entered validate_template_yn', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.template_yn = OKC_API.G_MISS_CHAR OR
            p_chrv_rec.template_yn IS NULL)
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'template_yn');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    -- check allowed values
        IF (upper(p_chrv_rec.template_yn) NOT IN ('Y', 'N')) THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'template_yn');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('6300: Exiting validate_template_yn', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('6400: Exiting validate_template_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('6500: Exiting validate_template_yn:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_template_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_chr_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_chr_type(x_return_status OUT NOCOPY VARCHAR2,
                                p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('6600: Entered validate_chr_type', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.chr_type = OKC_API.G_MISS_CHAR OR
            p_chrv_rec.chr_type IS NULL)
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_required_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'chr_type');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    -- check allowed values
        IF (upper(p_chrv_rec.chr_type) NOT IN ('CYR', 'CYP', 'CYA')) THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'chr_type');
	   -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('6700: Exiting validate_chr_type', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('6800: Exiting validate_chr_type:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('6900: Exiting validate_chr_type:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_chr_type;

/*
  -- Start of comments
  --
  -- Procedure Name  : validate_datetime_cancelled
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_datetime_cancelled(x_return_status OUT NOCOPY   VARCHAR2,
                            	   		p_chrv_rec      IN    chrv_rec_type) is
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CHR_PVT');
       okc_debug.log('7000: Entered validate_datetime_cancelled', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check that data exists
    If (p_chrv_rec.datetime_cancelled <> OKC_API.G_MISS_DATE and
  	   p_chrv_rec.datetime_cancelled IS NOT NULL)
    Then
	   If (p_chrv_rec.date_approved <> OKC_API.G_MISS_DATE and
		  p_chrv_rec.date_approved IS NOT NULL)
    	   Then
		 If (p_chrv_rec.date_approved < p_chrv_rec.datetime_cancelled) Then
        		x_return_status := OKC_API.G_RET_STS_ERROR;
		 End If;
	   Else
        	 x_return_status := OKC_API.G_RET_STS_ERROR;
	   End If;
    End If;
    If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'datetime_cancelled');
    End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Exiting validate_datetime_cancelled', 2);
       okc_debug.Reset_Indentation;
    END IF;


  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('7200: Exiting validate_datetime_cancelled:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_datetime_cancelled;
*/

  -- Start of comments
  --
  -- Procedure Name  : validate_keep_on_mail_list
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_keep_on_mail_list(x_return_status OUT NOCOPY VARCHAR2,
                                         p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('7300: Entered validate_keep_on_mail_list', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        IF (p_chrv_rec.keep_on_mail_list <> OKC_API.G_MISS_CHAR AND
            p_chrv_rec.keep_on_mail_list IS NOT NULL)
            THEN
      -- check allowed values
            IF (upper(p_chrv_rec.keep_on_mail_list) NOT IN ('Y', 'N')) THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_invalid_value,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'keep_on_mail_list');
	     -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('7400: Exiting validate_keep_on_mail_list', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('7500: Exiting validate_keep_on_mail_list:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_keep_on_mail_list;

  -- Start of comments
  --
  -- Procedure Name  : validate_set_aside_percent
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_set_aside_percent(x_return_status OUT NOCOPY VARCHAR2,
                                         p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('7600: Entered validate_set_aside_percent', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check percent range if not null
        IF ((p_chrv_rec.set_aside_percent <> OKC_API.G_MISS_NUM AND
             p_chrv_rec.set_aside_percent IS NOT NULL) AND
            (p_chrv_rec.set_aside_percent < 0 OR
             p_chrv_rec.set_aside_percent > 100))
            THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1 => g_col_name_token,
                                p_token1_value => 'set_aside_percent');
	      -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        IF (l_debug = 'Y') THEN
            okc_debug.LOG('7700: Exiting validate_set_aside_percent', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('7800: Exiting validate_set_aside_percent:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('7900: Exiting validate_set_aside_percent:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_set_aside_percent;
/*
  -- Start of comments
  --
  -- Procedure Name  : validate_date_terminated
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_date_terminated(x_return_status OUT NOCOPY   VARCHAR2,
                            	   	  p_chrv_rec      IN    chrv_rec_type) is
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CHR_PVT');
       okc_debug.log('8000: Entered validate_date_terminated', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;


    -- check that data exists
    If (p_chrv_rec.date_terminated <> OKC_API.G_MISS_DATE and
  	   p_chrv_rec.date_terminated IS NOT NULL)
    Then
	   If (p_chrv_rec.date_signed <> OKC_API.G_MISS_DATE and
		  p_chrv_rec.date_signed IS NOT NULL)
    	   Then
		 If (p_chrv_rec.date_signed > p_chrv_rec.date_terminated) Then
        		x_return_status := OKC_API.G_RET_STS_ERROR;
		 End If;
	   Else
        	 x_return_status := OKC_API.G_RET_STS_ERROR;
	   End If;
    End If;

    If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> 'OKC_NOT_SIGNED_CONTRACT',
					  p_token1          => g_col_name_token,
					  p_token1_value	=> 'date_terminated');
    End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('8100: Exiting validate_date_terminated', 2);
       okc_debug.Reset_Indentation;
    END IF;


  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('8200: Exiting validate_date_terminated:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_date_terminated;
*/
  -- Start of comments
  --
  -- Procedure Name  : validate_trn_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_trn_code(x_return_status OUT NOCOPY VARCHAR2,
                                p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('8300: Entered validate_trn_code', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key if data exists
        IF (p_chrv_rec.trn_code <> OKC_API.G_MISS_CHAR AND
            p_chrv_rec.trn_code IS NOT NULL)
            THEN
      -- Check if the value is a valid code from lookup table
            x_return_status := OKC_UTIL.check_lookup_code('OKC_TERMINATION_REASON',
                                                          p_chrv_rec.trn_code);
            IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	    --set error message in message stack
                OKC_API.SET_MESSAGE(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_INVALID_VALUE,
                                    p_token1 => G_COL_NAME_TOKEN,
                                    p_token1_value => 'TERMINATION_REASON');
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('8400: Exiting validate_trn_code', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('8500: Exiting validate_trn_code:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_trn_code;

-- Start of comments
  --
  -- Procedure Name  : validate_curr_code_rnwd
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_curr_code_rnwd(x_return_status OUT NOCOPY VARCHAR2,
                                      p_chrv_rec IN chrv_rec_type) IS

    l_dummy_var VARCHAR2(1) := '?';
    CURSOR l_fndv_csr IS
        SELECT 'x'
      FROM FND_CURRENCIES_VL
      WHERE currency_code = p_chrv_rec.currency_code_renewed
      AND SYSDATE BETWEEN nvl(start_date_active, SYSDATE)
                   AND nvl(end_date_active, SYSDATE);
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('8600: Entered validate_curr_code_rnwd', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.currency_code_renewed <> OKC_API.G_MISS_CHAR OR
            p_chrv_rec.currency_code_renewed IS NOT NULL)
            THEN
    -- check data is in lookup table
            OPEN l_fndv_csr;
            FETCH l_fndv_csr INTO l_dummy_var;
            CLOSE l_fndv_csr;

      -- if l_dummy_var still set to default, data was not found
            IF (l_dummy_var = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_no_parent_record,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'currency_code_renewed',
                                    p_token2 => g_child_table_token,
                                    p_token2_value => G_VIEW,
                                    p_token3 => g_parent_table_token,
                                    p_token3_value => 'FND_CURRENCIES');
	    -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('8700: Exiting validate_curr_code_rnwd', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('8800: Exiting validate_curr_code_rnwd:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('8900: Exiting validate_curr_code_rnwd:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
            IF l_fndv_csr%ISOPEN THEN
                CLOSE l_fndv_csr;
            END IF;


    END validate_curr_code_rnwd;

    PROCEDURE validate_orig_sys_code(x_return_status OUT NOCOPY VARCHAR2,
                                     p_chrv_rec IN chrv_rec_type) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('9000: Entered validate_orig_sys_code', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key if data exists
        IF (p_chrv_rec.orig_system_source_code <> OKC_API.G_MISS_CHAR AND
            p_chrv_rec.orig_system_source_code IS NOT NULL)
            THEN
      -- Check if the value is a valid code from lookup table
            x_return_status := OKC_UTIL.check_lookup_code('OKC_CONTRACT_SOURCES',
                                                          p_chrv_rec.orig_system_source_code);
            IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	    --set error message in message stack
                OKC_API.SET_MESSAGE(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_INVALID_VALUE,
                                    p_token1 => G_COL_NAME_TOKEN,
                                    p_token1_value => 'ORIG_SYSTEM_SOURCE_CODE');
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('9100: Exiting validate_orig_sys_code', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('9200: Exiting validate_orig_sys_code:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_orig_sys_code;

  -- Procedure Name  : validate_price_list_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_price_list_id(x_return_status OUT NOCOPY VARCHAR2,
                                     p_chrv_rec IN chrv_rec_type) IS

    l_dummy_var VARCHAR2(1) := '?';

-- Bug 2661571 ricagraw
/* Cursor l_price_list_id_csr Is
  select 'x'
  from okx_list_headers_v
  WHERE id1 = p_chrv_rec.price_list_id
  and   status = 'A'
  and   currency_code = p_chrv_rec.currency_code
  and   sysdate between nvl(start_date_active,sysdate)
                    and nvl(end_date_active,sysdate);
*/
-- Bug 2661571 ricagraw
    CURSOR l_price_list_id_csr IS
        SELECT 'x'
        FROM okx_list_headers_v
        WHERE id1 = p_chrv_rec.price_list_id
        AND ((status = 'A' AND p_chrv_rec.pricing_date IS NULL) OR
             (p_chrv_rec.pricing_date IS NOT NULL
              AND p_chrv_rec.pricing_date BETWEEN
              nvl(start_date_active, p_chrv_rec.pricing_date)
              AND nvl(end_date_active, p_chrv_rec.pricing_date)))
        AND  currency_code = p_chrv_rec.currency_code;

    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('9300: Entered validate_price_list_id', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.price_list_id <> OKC_API.G_MISS_NUM AND
            p_chrv_rec.price_list_id IS NOT NULL) THEN

      -- check data is in lookup table
            OPEN l_price_list_id_csr;
            FETCH l_price_list_id_csr INTO l_dummy_var;
            CLOSE l_price_list_id_csr;

        -- if l_dummy_var still set to default, data was not found
            IF (l_dummy_var = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_invalid_value,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'Price List Id');
	    -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('9400: Exiting validate_price_list_id', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('9500: Exiting validate_price_list_id:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('9600: Exiting validate_price_list_id:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_price_list_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_GOVERNING_CONTRACT_YN
  ---------------------------------------------------------------------------
    PROCEDURE validate_GOVERNING_CONTRACT_YN(
                                             p_chrv_rec IN chrv_rec_type,
                                             x_return_status OUT NOCOPY VARCHAR2) IS
    BEGIN
    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.GOVERNING_CONTRACT_YN <> OKC_API.G_MISS_CHAR AND
            p_chrv_rec.GOVERNING_CONTRACT_YN IS NOT NULL)
            THEN
            IF p_chrv_rec.GOVERNING_CONTRACT_YN NOT IN ('Y', 'N') THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_invalid_value,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'GOVERNING_CONTRACT_YN');
          -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;

          -- halt validation
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN
       -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
        -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_GOVERNING_CONTRACT_YN;


  -- Start of comments
  --
  -- Procedure Name  : validate_renewal_type_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_renewal_type_code (x_return_status OUT NOCOPY VARCHAR2,
                                          p_chrv_rec IN chrv_rec_type) IS

    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('9612: Entered validate_renewal_type_code', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.renewal_type_code <> OKC_API.G_MISS_CHAR AND
            p_chrv_rec.renewal_type_code IS NOT NULL)
            THEN
    -- Check if the value is a valid code from lookup table
            x_return_status := OKC_UTIL.check_lookup_code('OKC_RENEWAL_TYPE',
                                                          p_chrv_rec.renewal_type_code);

            IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	    --set error message in message stack
                OKC_API.SET_MESSAGE(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_INVALID_VALUE,
                                    p_token1 => G_COL_NAME_TOKEN,
                                    p_token1_value => 'RENEWAL_TYPE');

            ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('9613: Exiting validate_renewal_type_code', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('9614: Exiting validate_renewal_type_code:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;



    END validate_renewal_type_code;

  -- Start of comments
  -- From R12 OKS has moved to new renewal type loookup OKS_RENEWAL_TYPE
  -- Procedure Name  : validate_oks_renewal_type_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_oks_renewal_type_code (x_return_status OUT NOCOPY VARCHAR2,
                                          p_chrv_rec IN chrv_rec_type) IS

    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('9612: Entered validate_oks_renewal_type_code', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.renewal_type_code <> OKC_API.G_MISS_CHAR AND
            p_chrv_rec.renewal_type_code IS NOT NULL)
            THEN
    -- Check if the value is a valid code from lookup table
            x_return_status := OKC_UTIL.check_lookup_code('OKS_RENEWAL_TYPE',
                                                          p_chrv_rec.renewal_type_code);

            IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	    --set error message in message stack
                OKC_API.SET_MESSAGE(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_INVALID_VALUE,
                                    p_token1 => G_COL_NAME_TOKEN,
                                    p_token1_value => 'RENEWAL_TYPE');

            ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('9613: Exiting validate_oks_renewal_type_code', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('9614: Exiting validate_oks_renewal_type_code:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;



    END validate_oks_renewal_type_code;

-- Start of comments
  -- R12 Data Model Changes 4485150 Start
  -- Procedure Name  : validate_approval_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE validate_approval_type(x_return_status OUT NOCOPY VARCHAR2,
                                     p_chrv_rec IN chrv_rec_type) IS

    l_dummy_var VARCHAR2(1) := '?';
    CURSOR l_fndv_csr IS
        SELECT 'x'
      FROM FND_LOOKUPS
      WHERE lookup_code = p_chrv_rec.approval_type
              AND (lookup_type = 'OKS_REN_ONLINE_APPROVAL'
                   OR lookup_type = 'OKS_REN_MANUAL_APPROVAL')
      AND SYSDATE BETWEEN nvl(start_date_active, SYSDATE)
                   AND nvl(end_date_active, SYSDATE)
              AND enabled_flag = 'Y';
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('500: Entered validate_approval_type', 2);
        END IF;

    -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
        IF (p_chrv_rec.approval_type = OKC_API.G_MISS_CHAR OR
            p_chrv_rec.approval_type IS NULL)
            THEN
            NULL;
        ELSE
    -- check data is in lookup table
            OPEN l_fndv_csr;
            FETCH l_fndv_csr INTO l_dummy_var;
            CLOSE l_fndv_csr;

      -- if l_dummy_var still set to default, data was not found
            IF (l_dummy_var = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                    p_msg_name => g_no_parent_record,
                                    p_token1 => g_col_name_token,
                                    p_token1_value => 'approval_type',
                                    p_token2 => g_child_table_token,
                                    p_token2_value => G_VIEW,
                                    p_token3 => g_parent_table_token,
                                    p_token3_value => 'FND_LOOKUPS');
	    -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
            IF (l_debug = 'Y') THEN
                okc_debug.LOG('600: Exiting validate_approval_type', 2);
                okc_debug.Reset_Indentation;
            END IF;
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('700: Exiting validate_approval_type:G_EXCEPTION_HALT_VALIDATION Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

      -- no processing necessary; validation can continue with next column
            NULL;

        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('800: Exiting validate_approval_type:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
            IF l_fndv_csr%ISOPEN THEN
                CLOSE l_fndv_csr;
            END IF;


    END validate_approval_type;

  -- R12 Data Model Changes 4485150 End
  /*********************** END HAND-CODED ********************************/

  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
    FUNCTION get_seq_id RETURN NUMBER IS

    l_id NUMBER;

    CURSOR l_seq_csr IS
        SELECT okc_k_headers_b_s.NEXTVAL
        FROM dual;

    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('9700: Entered get_seq_id', 2);
        END IF;

        OPEN l_seq_csr;
        FETCH l_seq_csr INTO l_id;
        CLOSE l_seq_csr;

        IF (l_debug = 'Y') THEN
            okc_debug.LOG('9700: Sequence Generated is : '|| l_id, 2);
        END IF;

    -- RETURN(okc_p_util.raw_to_number(sys_guid()));
        RETURN l_id;

    END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
    PROCEDURE qc IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('9800: Entered qc', 2);
        END IF;

        NULL;

    END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
    PROCEDURE change_version IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('9900: Entered change_version', 2);
        END IF;

        NULL;

    END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
    PROCEDURE api_copy IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('10000: Entered api_copy', 2);
        END IF;

        NULL;

    END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
    PROCEDURE add_language IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('10100: Entered add_language', 2);
        END IF;

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

    DELETE FROM OKC_K_HEADERS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_K_HEADERS_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_K_HEADERS_TL T SET (
        SHORT_DESCRIPTION,
        COMMENTS,
        DESCRIPTION,
        COGNOMEN,
        NON_RESPONSE_REASON,
        NON_RESPONSE_EXPLAIN,
        SET_ASIDE_REASON) = (SELECT
                                  B.SHORT_DESCRIPTION,
                                  B.COMMENTS,
                                  B.DESCRIPTION,
                                  B.COGNOMEN,
                                  B.NON_RESPONSE_REASON,
                                  B.NON_RESPONSE_EXPLAIN,
                                  B.SET_ASIDE_REASON
                                FROM OKC_K_HEADERS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_K_HEADERS_TL SUBB, OKC_K_HEADERS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      OR SUBB.COMMENTS <> SUBT.COMMENTS
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.COGNOMEN <> SUBT.COGNOMEN
                      OR SUBB.NON_RESPONSE_REASON <> SUBT.NON_RESPONSE_REASON
                      OR SUBB.NON_RESPONSE_EXPLAIN <> SUBT.NON_RESPONSE_EXPLAIN
                      OR SUBB.SET_ASIDE_REASON <> SUBT.SET_ASIDE_REASON
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.COGNOMEN IS NULL AND SUBT.COGNOMEN IS NOT NULL)
                      OR (SUBB.COGNOMEN IS NOT NULL AND SUBT.COGNOMEN IS NULL)
                      OR (SUBB.NON_RESPONSE_REASON IS NULL AND SUBT.NON_RESPONSE_REASON IS NOT NULL)
                      OR (SUBB.NON_RESPONSE_REASON IS NOT NULL AND SUBT.NON_RESPONSE_REASON IS NULL)
                      OR (SUBB.NON_RESPONSE_EXPLAIN IS NULL AND SUBT.NON_RESPONSE_EXPLAIN IS NOT NULL)
                      OR (SUBB.NON_RESPONSE_EXPLAIN IS NOT NULL AND SUBT.NON_RESPONSE_EXPLAIN IS NULL)
                      OR (SUBB.SET_ASIDE_REASON IS NULL AND SUBT.SET_ASIDE_REASON IS NOT NULL)
                      OR (SUBB.SET_ASIDE_REASON IS NOT NULL AND SUBT.SET_ASIDE_REASON IS NULL)
              ));
 */
/* Modifying Insert as per performance guidelines given in bug 3723874 */

        INSERT /*+ append parallel(tt) */ INTO OKC_K_HEADERS_TL tt(
                                                                   ID,
                                                                   LANGUAGE,
                                                                   SOURCE_LANG,
                                                                   SFWT_FLAG,
                                                                   SHORT_DESCRIPTION,
                                                                   COMMENTS,
                                                                   DESCRIPTION,
                                                                   COGNOMEN,
                                                                   NON_RESPONSE_REASON,
                                                                   NON_RESPONSE_EXPLAIN,
                                                                   SET_ASIDE_REASON,
                                                                   CREATED_BY,
                                                                   CREATION_DATE,
                                                                   LAST_UPDATED_BY,
                                                                   LAST_UPDATE_DATE,
                                                                   LAST_UPDATE_LOGIN)
          SELECT /*+ parallel(v) parallel(t) use_nl(t) */  v. * FROM
          (SELECT /*+ no_merge ordered parallel(b) */
           B.ID,
           L.LANGUAGE_CODE,
           B.SOURCE_LANG,
           B.SFWT_FLAG,
           B.SHORT_DESCRIPTION,
           B.COMMENTS,
           B.DESCRIPTION,
           B.COGNOMEN,
           B.NON_RESPONSE_REASON,
           B.NON_RESPONSE_EXPLAIN,
           B.SET_ASIDE_REASON,
           B.CREATED_BY,
           B.CREATION_DATE,
           B.LAST_UPDATED_BY,
           B.LAST_UPDATE_DATE,
           B.LAST_UPDATE_LOGIN
           FROM OKC_K_HEADERS_TL B, FND_LANGUAGES L
           WHERE L.INSTALLED_FLAG IN ('I', 'B')
           AND B.LANGUAGE = USERENV('LANG')
           ) v, OKC_K_HEADERS_TL t
             WHERE t.ID( + ) = v.ID
         AND t.language( + ) = v.LANGUAGE_CODE
         AND t.id IS NULL;


/* Commenting delete and update for bug 3723874 */
/*
 DELETE FROM OKC_K_HEADERS_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_K_HEADERS_BH B
         WHERE B.ID = T.ID
         AND B.MAJOR_VERSION = T.MAJOR_VERSION
        );

    UPDATE OKC_K_HEADERS_TLH T SET (
        SHORT_DESCRIPTION,
        COMMENTS,
        DESCRIPTION,
        COGNOMEN,
        NON_RESPONSE_REASON,
        NON_RESPONSE_EXPLAIN,
        SET_ASIDE_REASON) = (SELECT
                                  B.SHORT_DESCRIPTION,
                                  B.COMMENTS,
                                  B.DESCRIPTION,
                                  B.COGNOMEN,
                                  B.NON_RESPONSE_REASON,
                                  B.NON_RESPONSE_EXPLAIN,
                                  B.SET_ASIDE_REASON
                                FROM OKC_K_HEADERS_TLH B
                               WHERE B.ID = T.ID
                                  AND B.MAJOR_VERSION = T.MAJOR_VERSION
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.MAJOR_VERSION,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.MAJOR_VERSION,
                  SUBT.LANGUAGE
                FROM OKC_K_HEADERS_TLH SUBB, OKC_K_HEADERS_TLH SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
                AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      OR SUBB.COMMENTS <> SUBT.COMMENTS
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.COGNOMEN <> SUBT.COGNOMEN
                      OR SUBB.NON_RESPONSE_REASON <> SUBT.NON_RESPONSE_REASON
                      OR SUBB.NON_RESPONSE_EXPLAIN <> SUBT.NON_RESPONSE_EXPLAIN
                      OR SUBB.SET_ASIDE_REASON <> SUBT.SET_ASIDE_REASON
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.COGNOMEN IS NULL AND SUBT.COGNOMEN IS NOT NULL)
                      OR (SUBB.COGNOMEN IS NOT NULL AND SUBT.COGNOMEN IS NULL)
                      OR (SUBB.NON_RESPONSE_REASON IS NULL AND SUBT.NON_RESPONSE_REASON IS NOT NULL)
                      OR (SUBB.NON_RESPONSE_REASON IS NOT NULL AND SUBT.NON_RESPONSE_REASON IS NULL)
                      OR (SUBB.NON_RESPONSE_EXPLAIN IS NULL AND SUBT.NON_RESPONSE_EXPLAIN IS NOT NULL)
                      OR (SUBB.NON_RESPONSE_EXPLAIN IS NOT NULL AND SUBT.NON_RESPONSE_EXPLAIN IS NULL)
                      OR (SUBB.SET_ASIDE_REASON IS NULL AND SUBT.SET_ASIDE_REASON IS NOT NULL)
                      OR (SUBB.SET_ASIDE_REASON IS NOT NULL AND SUBT.SET_ASIDE_REASON IS NULL)
              ));

*/
/* Modifying Insert as per performance guidelines given in bug 3723874 */
        INSERT /*+ append parallel(tt) */ INTO OKC_K_HEADERS_TLH tt(
                                                                    ID,
                                                                    LANGUAGE,
                                                                    MAJOR_VERSION,
                                                                    SOURCE_LANG,
                                                                    SFWT_FLAG,
                                                                    SHORT_DESCRIPTION,
                                                                    COMMENTS,
                                                                    DESCRIPTION,
                                                                    COGNOMEN,
                                                                    NON_RESPONSE_REASON,
                                                                    NON_RESPONSE_EXPLAIN,
                                                                    SET_ASIDE_REASON,
                                                                    CREATED_BY,
                                                                    CREATION_DATE,
                                                                    LAST_UPDATED_BY,
                                                                    LAST_UPDATE_DATE,
                                                                    LAST_UPDATE_LOGIN)
          SELECT /*+ parallel(v) parallel(t) use_nl(t)  */ v. * FROM
          (SELECT /*+ no_merge ordered parallel(b) */
           B.ID,
           L.LANGUAGE_CODE,
           B.MAJOR_VERSION,
           B.SOURCE_LANG,
           B.SFWT_FLAG,
           B.SHORT_DESCRIPTION,
           B.COMMENTS,
           B.DESCRIPTION,
           B.COGNOMEN,
           B.NON_RESPONSE_REASON,
           B.NON_RESPONSE_EXPLAIN,
           B.SET_ASIDE_REASON,
           B.CREATED_BY,
           B.CREATION_DATE,
           B.LAST_UPDATED_BY,
           B.LAST_UPDATE_DATE,
           B.LAST_UPDATE_LOGIN
           FROM OKC_K_HEADERS_TLH B, FND_LANGUAGES L
           WHERE L.INSTALLED_FLAG IN ('I', 'B')
           AND B.LANGUAGE = USERENV('LANG')
           ) v, OKC_K_HEADERS_TLH t
             WHERE T.ID( + ) = v.ID
             AND T.MAJOR_VERSION( + ) = v.MAJOR_VERSION
             AND T.LANGUAGE( + ) = v.LANGUAGE_CODE
         AND t.id IS NULL;


    END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_HEADERS_ALL_B
  ---------------------------------------------------------------------------
    FUNCTION get_rec (
                      p_chr_rec IN chr_rec_type,
                      x_no_data_found OUT NOCOPY BOOLEAN
                      ) RETURN chr_rec_type IS
    CURSOR chr_pk_csr (p_id IN NUMBER) IS
        SELECT
                ID,
                CONTRACT_NUMBER,
                AUTHORING_ORG_ID,
--	    ORG_ID, --mmadhavi added for MOAC
                CONTRACT_NUMBER_MODIFIER,
                CHR_ID_RESPONSE,
                CHR_ID_AWARD,
            INV_ORGANIZATION_ID,
                STS_CODE,
                QCL_ID,
                SCS_CODE,
                TRN_CODE,
                CURRENCY_CODE,
                ARCHIVED_YN,
                DELETED_YN,
                TEMPLATE_YN,
                CHR_TYPE,
                OBJECT_VERSION_NUMBER,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                CUST_PO_NUMBER_REQ_YN,
                PRE_PAY_REQ_YN,
                CUST_PO_NUMBER,
                DPAS_RATING,
                TEMPLATE_USED,
                DATE_APPROVED,
                DATETIME_CANCELLED,
                AUTO_RENEW_DAYS,
                DATE_ISSUED,
                DATETIME_RESPONDED,
                RFP_TYPE,
                KEEP_ON_MAIL_LIST,
                SET_ASIDE_PERCENT,
                RESPONSE_COPIES_REQ,
                DATE_CLOSE_PROJECTED,
                DATETIME_PROPOSED,
                DATE_SIGNED,
                DATE_TERMINATED,
                DATE_RENEWED,
                START_DATE,
                END_DATE,
                BUY_OR_SELL,
                ISSUE_OR_RECEIVE,
                ESTIMATED_AMOUNT,
                ESTIMATED_AMOUNT_RENEWED,
                CURRENCY_CODE_RENEWED,
                LAST_UPDATE_LOGIN,
            UPG_ORIG_SYSTEM_REF,
            UPG_ORIG_SYSTEM_REF_ID,
            APPLICATION_ID,
            ORIG_SYSTEM_SOURCE_CODE,
            ORIG_SYSTEM_ID1,
            ORIG_SYSTEM_REFERENCE1,
                PROGRAM_ID,
                REQUEST_ID,
                PROGRAM_UPDATE_DATE,
                PROGRAM_APPLICATION_ID,
                PRICE_LIST_ID,
                PRICING_DATE,
                SIGN_BY_DATE,
                TOTAL_LINE_LIST_PRICE,
              USER_ESTIMATED_AMOUNT,
              GOVERNING_CONTRACT_YN,
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
            -- new colums to replace rules
                CONVERSION_TYPE,
                CONVERSION_RATE,
                CONVERSION_RATE_DATE,
                CONVERSION_EURO_RATE,
                CUST_ACCT_ID,
                BILL_TO_SITE_USE_ID,
                INV_RULE_ID,
                RENEWAL_TYPE_CODE,
                RENEWAL_NOTIFY_TO,
                RENEWAL_END_DATE,
                SHIP_TO_SITE_USE_ID,
                PAYMENT_TERM_ID,
            DOCUMENT_ID,
-- R12 Data Model Changes 4485150 Start
                APPROVAL_TYPE,
                TERM_CANCEL_SOURCE,
                PAYMENT_INSTRUCTION_TYPE,
                ORG_ID, --mmadhavi added for MOAC
-- R12 Data Model Changes 4485150 End
 		      CANCELLED_AMOUNT -- LLC
          FROM Okc_K_Headers_All_B --mmadhavi changed to _ALL for MOAC
         WHERE okc_k_headers_all_b.id = p_id;
    l_chr_pk chr_pk_csr%ROWTYPE;
    l_chr_rec chr_rec_type;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('10200: Entered get_rec', 2);
        END IF;

        x_no_data_found := TRUE;
    -- Get current database values
        OPEN chr_pk_csr (p_chr_rec.id);
        FETCH chr_pk_csr INTO
        l_chr_rec.ID,
        l_chr_rec.CONTRACT_NUMBER,
        l_chr_rec.AUTHORING_ORG_ID,
--	      l_chr_rec.ORG_ID, --mmadhavi added for MOAC
        l_chr_rec.CONTRACT_NUMBER_MODIFIER,
        l_chr_rec.CHR_ID_RESPONSE,
        l_chr_rec.CHR_ID_AWARD,
        l_chr_rec.INV_ORGANIZATION_ID,
        l_chr_rec.STS_CODE,
        l_chr_rec.QCL_ID,
        l_chr_rec.SCS_CODE,
        l_chr_rec.TRN_CODE,
        l_chr_rec.CURRENCY_CODE,
        l_chr_rec.ARCHIVED_YN,
        l_chr_rec.DELETED_YN,
        l_chr_rec.TEMPLATE_YN,
        l_chr_rec.CHR_TYPE,
        l_chr_rec.OBJECT_VERSION_NUMBER,
        l_chr_rec.CREATED_BY,
        l_chr_rec.CREATION_DATE,
        l_chr_rec.LAST_UPDATED_BY,
        l_chr_rec.LAST_UPDATE_DATE,
        l_chr_rec.CUST_PO_NUMBER_REQ_YN,
        l_chr_rec.PRE_PAY_REQ_YN,
        l_chr_rec.CUST_PO_NUMBER,
        l_chr_rec.DPAS_RATING,
        l_chr_rec.TEMPLATE_USED,
        l_chr_rec.DATE_APPROVED,
        l_chr_rec.DATETIME_CANCELLED,
        l_chr_rec.AUTO_RENEW_DAYS,
        l_chr_rec.DATE_ISSUED,
        l_chr_rec.DATETIME_RESPONDED,
        l_chr_rec.RFP_TYPE,
        l_chr_rec.KEEP_ON_MAIL_LIST,
        l_chr_rec.SET_ASIDE_PERCENT,
        l_chr_rec.RESPONSE_COPIES_REQ,
        l_chr_rec.DATE_CLOSE_PROJECTED,
        l_chr_rec.DATETIME_PROPOSED,
        l_chr_rec.DATE_SIGNED,
        l_chr_rec.DATE_TERMINATED,
        l_chr_rec.DATE_RENEWED,
        l_chr_rec.START_DATE,
        l_chr_rec.END_DATE,
        l_chr_rec.BUY_OR_SELL,
        l_chr_rec.ISSUE_OR_RECEIVE,
        l_chr_rec.ESTIMATED_AMOUNT,
        l_chr_rec.ESTIMATED_AMOUNT_RENEWED,
        l_chr_rec.CURRENCY_CODE_RENEWED,
        l_chr_rec.LAST_UPDATE_LOGIN,
        l_chr_rec.UPG_ORIG_SYSTEM_REF,
        l_chr_rec.UPG_ORIG_SYSTEM_REF_ID,
        l_chr_rec.APPLICATION_ID,
        l_chr_rec.ORIG_SYSTEM_SOURCE_CODE,
        l_chr_rec.ORIG_SYSTEM_ID1,
        l_chr_rec.ORIG_SYSTEM_REFERENCE1,
        l_chr_rec.PROGRAM_ID,
        l_chr_rec.REQUEST_ID,
        l_chr_rec.PROGRAM_UPDATE_DATE,
        l_chr_rec.PROGRAM_APPLICATION_ID,
        l_chr_rec.PRICE_LIST_ID,
        l_chr_rec.PRICING_DATE,
        l_chr_rec.SIGN_BY_DATE,
        l_chr_rec.TOTAL_LINE_LIST_PRICE,
        l_chr_rec.USER_ESTIMATED_AMOUNT,
        l_chr_rec.GOVERNING_CONTRACT_YN,
        l_chr_rec.ATTRIBUTE_CATEGORY,
        l_chr_rec.ATTRIBUTE1,
        l_chr_rec.ATTRIBUTE2,
        l_chr_rec.ATTRIBUTE3,
        l_chr_rec.ATTRIBUTE4,
        l_chr_rec.ATTRIBUTE5,
        l_chr_rec.ATTRIBUTE6,
        l_chr_rec.ATTRIBUTE7,
        l_chr_rec.ATTRIBUTE8,
        l_chr_rec.ATTRIBUTE9,
        l_chr_rec.ATTRIBUTE10,
        l_chr_rec.ATTRIBUTE11,
        l_chr_rec.ATTRIBUTE12,
        l_chr_rec.ATTRIBUTE13,
        l_chr_rec.ATTRIBUTE14,
        l_chr_rec.ATTRIBUTE15,
--new columns to replace rules
        l_chr_rec.CONVERSION_TYPE,
        l_chr_rec.CONVERSION_RATE,
        l_chr_rec.CONVERSION_RATE_DATE,
        l_chr_rec.CONVERSION_EURO_RATE,
        l_chr_rec.CUST_ACCT_ID,
        l_chr_rec.BILL_TO_SITE_USE_ID,
        l_chr_rec.INV_RULE_ID,
        l_chr_rec.RENEWAL_TYPE_CODE,
        l_chr_rec.RENEWAL_NOTIFY_TO,
        l_chr_rec.RENEWAL_END_DATE,
        l_chr_rec.SHIP_TO_SITE_USE_ID,
        l_chr_rec.PAYMENT_TERM_ID,
        l_chr_rec.DOCUMENT_ID,
-- R12 Data Model Changes 4485150 Start
        l_chr_rec.APPROVAL_TYPE,
        l_chr_rec.TERM_CANCEL_SOURCE,
        l_chr_rec.PAYMENT_INSTRUCTION_TYPE,
        l_chr_rec.ORG_ID, --mmadhavi added for MOAC
	   l_chr_rec.CANCELLED_AMOUNT -- LLC
-- R12 Data Model Changes 4485150 End
        ;

        x_no_data_found := chr_pk_csr%NOTFOUND;
        CLOSE chr_pk_csr;
        RETURN(l_chr_rec);

    END get_rec;

    FUNCTION get_rec (
                      p_chr_rec IN chr_rec_type
                      ) RETURN chr_rec_type IS
    l_row_notfound BOOLEAN := TRUE;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('10300: Entered get_rec', 2);
        END IF;

        RETURN(get_rec(p_chr_rec, l_row_notfound));

    END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_HEADERS_TL
  ---------------------------------------------------------------------------
    FUNCTION get_rec (
                      p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type,
                      x_no_data_found OUT NOCOPY BOOLEAN
                      ) RETURN okc_k_headers_tl_rec_type IS
    CURSOR chr_pktl_csr (p_id IN NUMBER,
                         p_language IN VARCHAR2) IS
        SELECT
                ID,
                LANGUAGE,
                SOURCE_LANG,
                SFWT_FLAG,
                SHORT_DESCRIPTION,
                COMMENTS,
                DESCRIPTION,
                COGNOMEN,
                NON_RESPONSE_REASON,
                NON_RESPONSE_EXPLAIN,
                SET_ASIDE_REASON,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN
          FROM Okc_K_Headers_Tl
         WHERE okc_k_headers_tl.id = p_id
           AND okc_k_headers_tl.language = p_language;
    l_chr_pktl chr_pktl_csr%ROWTYPE;
    l_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('10400: Entered get_rec', 2);
        END IF;

        x_no_data_found := TRUE;
    -- Get current database values
        OPEN chr_pktl_csr (p_okc_k_headers_tl_rec.id,
                           p_okc_k_headers_tl_rec.language);
        FETCH chr_pktl_csr INTO
        l_okc_k_headers_tl_rec.ID,
        l_okc_k_headers_tl_rec.LANGUAGE,
        l_okc_k_headers_tl_rec.SOURCE_LANG,
        l_okc_k_headers_tl_rec.SFWT_FLAG,
        l_okc_k_headers_tl_rec.SHORT_DESCRIPTION,
        l_okc_k_headers_tl_rec.COMMENTS,
        l_okc_k_headers_tl_rec.DESCRIPTION,
        l_okc_k_headers_tl_rec.COGNOMEN,
        l_okc_k_headers_tl_rec.NON_RESPONSE_REASON,
        l_okc_k_headers_tl_rec.NON_RESPONSE_EXPLAIN,
        l_okc_k_headers_tl_rec.SET_ASIDE_REASON,
        l_okc_k_headers_tl_rec.CREATED_BY,
        l_okc_k_headers_tl_rec.CREATION_DATE,
        l_okc_k_headers_tl_rec.LAST_UPDATED_BY,
        l_okc_k_headers_tl_rec.LAST_UPDATE_DATE,
        l_okc_k_headers_tl_rec.LAST_UPDATE_LOGIN;
        x_no_data_found := chr_pktl_csr%NOTFOUND;
        CLOSE chr_pktl_csr;
        RETURN(l_okc_k_headers_tl_rec);

    END get_rec;

    FUNCTION get_rec (
                      p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type
                      ) RETURN okc_k_headers_tl_rec_type IS
    l_row_notfound BOOLEAN := TRUE;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('10500: Entered get_rec', 2);
        END IF;

        RETURN(get_rec(p_okc_k_headers_tl_rec, l_row_notfound));

    END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_HEADERS_V
  ---------------------------------------------------------------------------
    FUNCTION get_rec (
                      p_chrv_rec IN chrv_rec_type,
                      x_no_data_found OUT NOCOPY BOOLEAN
                      ) RETURN chrv_rec_type IS
    CURSOR okc_chrv_pk_csr (p_id IN NUMBER) IS
        SELECT
                ID,
                OBJECT_VERSION_NUMBER,
                SFWT_FLAG,
                CHR_ID_RESPONSE,
                CHR_ID_AWARD,
              INV_ORGANIZATION_ID,
                STS_CODE,
                QCL_ID,
                SCS_CODE,
                CONTRACT_NUMBER,
                CURRENCY_CODE,
                CONTRACT_NUMBER_MODIFIER,
                ARCHIVED_YN,
                DELETED_YN,
                CUST_PO_NUMBER_REQ_YN,
                PRE_PAY_REQ_YN,
                CUST_PO_NUMBER,
                SHORT_DESCRIPTION,
                COMMENTS,
                DESCRIPTION,
                DPAS_RATING,
                COGNOMEN,
                TEMPLATE_YN,
                TEMPLATE_USED,
                DATE_APPROVED,
                DATETIME_CANCELLED,
                AUTO_RENEW_DAYS,
                DATE_ISSUED,
                DATETIME_RESPONDED,
                NON_RESPONSE_REASON,
                NON_RESPONSE_EXPLAIN,
                RFP_TYPE,
                CHR_TYPE,
                KEEP_ON_MAIL_LIST,
                SET_ASIDE_REASON,
                SET_ASIDE_PERCENT,
                RESPONSE_COPIES_REQ,
                DATE_CLOSE_PROJECTED,
                DATETIME_PROPOSED,
                DATE_SIGNED,
                DATE_TERMINATED,
                DATE_RENEWED,
                TRN_CODE,
                START_DATE,
                END_DATE,
                AUTHORING_ORG_ID,
--	    ORG_ID, --mmadhavi added for MOAC
                BUY_OR_SELL,
                ISSUE_OR_RECEIVE,
            ESTIMATED_AMOUNT,
                ESTIMATED_AMOUNT_RENEWED,
                CURRENCY_CODE_RENEWED,
            UPG_ORIG_SYSTEM_REF,
            UPG_ORIG_SYSTEM_REF_ID,
            APPLICATION_ID,
                ORIG_SYSTEM_SOURCE_CODE,
                ORIG_SYSTEM_ID1,
                ORIG_SYSTEM_REFERENCE1,
                PROGRAM_ID,
                REQUEST_ID,
                PROGRAM_UPDATE_DATE,
                PROGRAM_APPLICATION_ID,
                PRICE_LIST_ID,
                PRICING_DATE,
                SIGN_BY_DATE,
                TOTAL_LINE_LIST_PRICE,
                USER_ESTIMATED_AMOUNT,
              GOVERNING_CONTRACT_YN,
                CONVERSION_TYPE,
                CONVERSION_RATE,
                CONVERSION_RATE_DATE,
                CONVERSION_EURO_RATE,
                CUST_ACCT_ID,
                BILL_TO_SITE_USE_ID,
                INV_RULE_ID,
                RENEWAL_TYPE_CODE,
                RENEWAL_NOTIFY_TO,
                RENEWAL_END_DATE,
                SHIP_TO_SITE_USE_ID,
                PAYMENT_TERM_ID,
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
                DOCUMENT_ID,
-- R12 Data Model Changes 4485150 Start
                APPROVAL_TYPE,
                TERM_CANCEL_SOURCE,
                PAYMENT_INSTRUCTION_TYPE,
                ORG_ID, --mmadhavi added for MOAC
			 CANCELLED_AMOUNT -- LLC
-- R12 Data Model Changes 4485150 End
          FROM Okc_K_Headers_V
         WHERE okc_k_headers_v.id = p_id;
    l_okc_chrv_pk okc_chrv_pk_csr%ROWTYPE;
    l_chrv_rec chrv_rec_type;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('10600: Entered get_rec', 2);
        END IF;

        x_no_data_found := TRUE;
    -- Get current database values
        OPEN okc_chrv_pk_csr (p_chrv_rec.id);
        FETCH okc_chrv_pk_csr INTO
        l_chrv_rec.ID,
        l_chrv_rec.OBJECT_VERSION_NUMBER,
        l_chrv_rec.SFWT_FLAG,
        l_chrv_rec.CHR_ID_RESPONSE,
        l_chrv_rec.CHR_ID_AWARD,
        l_chrv_rec.INV_ORGANIZATION_ID,
        l_chrv_rec.STS_CODE,
        l_chrv_rec.QCL_ID,
        l_chrv_rec.SCS_CODE,
        l_chrv_rec.CONTRACT_NUMBER,
        l_chrv_rec.CURRENCY_CODE,
        l_chrv_rec.CONTRACT_NUMBER_MODIFIER,
        l_chrv_rec.ARCHIVED_YN,
        l_chrv_rec.DELETED_YN,
        l_chrv_rec.CUST_PO_NUMBER_REQ_YN,
        l_chrv_rec.PRE_PAY_REQ_YN,
        l_chrv_rec.CUST_PO_NUMBER,
        l_chrv_rec.SHORT_DESCRIPTION,
        l_chrv_rec.COMMENTS,
        l_chrv_rec.DESCRIPTION,
        l_chrv_rec.DPAS_RATING,
        l_chrv_rec.COGNOMEN,
        l_chrv_rec.TEMPLATE_YN,
        l_chrv_rec.TEMPLATE_USED,
        l_chrv_rec.DATE_APPROVED,
        l_chrv_rec.DATETIME_CANCELLED,
        l_chrv_rec.AUTO_RENEW_DAYS,
        l_chrv_rec.DATE_ISSUED,
        l_chrv_rec.DATETIME_RESPONDED,
        l_chrv_rec.NON_RESPONSE_REASON,
        l_chrv_rec.NON_RESPONSE_EXPLAIN,
        l_chrv_rec.RFP_TYPE,
        l_chrv_rec.CHR_TYPE,
        l_chrv_rec.KEEP_ON_MAIL_LIST,
        l_chrv_rec.SET_ASIDE_REASON,
        l_chrv_rec.SET_ASIDE_PERCENT,
        l_chrv_rec.RESPONSE_COPIES_REQ,
        l_chrv_rec.DATE_CLOSE_PROJECTED,
        l_chrv_rec.DATETIME_PROPOSED,
        l_chrv_rec.DATE_SIGNED,
        l_chrv_rec.DATE_TERMINATED,
        l_chrv_rec.DATE_RENEWED,
        l_chrv_rec.TRN_CODE,
        l_chrv_rec.START_DATE,
        l_chrv_rec.END_DATE,
        l_chrv_rec.AUTHORING_ORG_ID,
--	      l_chrv_rec.ORG_ID, --mmadhavi added for MOAC
        l_chrv_rec.BUY_OR_SELL,
        l_chrv_rec.ISSUE_OR_RECEIVE,
        l_chrv_rec.ESTIMATED_AMOUNT,
        l_chrv_rec.ESTIMATED_AMOUNT_RENEWED,
        l_chrv_rec.CURRENCY_CODE_RENEWED,
        l_chrv_rec.UPG_ORIG_SYSTEM_REF,
        l_chrv_rec.UPG_ORIG_SYSTEM_REF_ID,
        l_chrv_rec.APPLICATION_ID,
        l_chrv_rec.ORIG_SYSTEM_SOURCE_CODE,
        l_chrv_rec.ORIG_SYSTEM_ID1,
        l_chrv_rec.ORIG_SYSTEM_REFERENCE1,
        l_chrv_rec.program_id,
        l_chrv_rec.request_id,
        l_chrv_rec.program_update_date,
        l_chrv_rec.program_application_id,
        l_chrv_rec.price_list_id,
        l_chrv_rec.pricing_date,
        l_chrv_rec.sign_by_date,
        l_chrv_rec.total_line_list_price,
        l_chrv_rec.USER_ESTIMATED_AMOUNT,
        l_chrv_rec.GOVERNING_CONTRACT_YN,
  --new columns  to replace rules
        l_chrv_rec.CONVERSION_TYPE,
        l_chrv_rec.CONVERSION_RATE,
        l_chrv_rec.CONVERSION_RATE_DATE,
        l_chrv_rec.CONVERSION_EURO_RATE,
        l_chrv_rec.CUST_ACCT_ID,
        l_chrv_rec.BILL_TO_SITE_USE_ID,
        l_chrv_rec.INV_RULE_ID,
        l_chrv_rec.RENEWAL_TYPE_CODE,
        l_chrv_rec.RENEWAL_NOTIFY_TO,
        l_chrv_rec.RENEWAL_END_DATE,
        l_chrv_rec.SHIP_TO_SITE_USE_ID,
        l_chrv_rec.PAYMENT_TERM_ID,
--
        l_chrv_rec.ATTRIBUTE_CATEGORY,
        l_chrv_rec.ATTRIBUTE1,
        l_chrv_rec.ATTRIBUTE2,
        l_chrv_rec.ATTRIBUTE3,
        l_chrv_rec.ATTRIBUTE4,
        l_chrv_rec.ATTRIBUTE5,
        l_chrv_rec.ATTRIBUTE6,
        l_chrv_rec.ATTRIBUTE7,
        l_chrv_rec.ATTRIBUTE8,
        l_chrv_rec.ATTRIBUTE9,
        l_chrv_rec.ATTRIBUTE10,
        l_chrv_rec.ATTRIBUTE11,
        l_chrv_rec.ATTRIBUTE12,
        l_chrv_rec.ATTRIBUTE13,
        l_chrv_rec.ATTRIBUTE14,
        l_chrv_rec.ATTRIBUTE15,
        l_chrv_rec.CREATED_BY,
        l_chrv_rec.CREATION_DATE,
        l_chrv_rec.LAST_UPDATED_BY,
        l_chrv_rec.LAST_UPDATE_DATE,
        l_chrv_rec.LAST_UPDATE_LOGIN,
        l_chrv_rec.DOCUMENT_ID,
-- R12 Data Model Changes 4485150 End
        l_chrv_rec.APPROVAL_TYPE,
        l_chrv_rec.TERM_CANCEL_SOURCE,
        l_chrv_rec.PAYMENT_INSTRUCTION_TYPE,
        l_chrv_rec.ORG_ID, --mmadhavi added for MOAC
	   l_chrv_rec.CANCELLED_AMOUNT -- LLC
-- R12 Data Model Changes 4485150 End
        ;
        x_no_data_found := okc_chrv_pk_csr%NOTFOUND;
        CLOSE okc_chrv_pk_csr;
        RETURN(l_chrv_rec);

    END get_rec;

    FUNCTION get_rec (
                      p_chrv_rec IN chrv_rec_type
                      ) RETURN chrv_rec_type IS
    l_row_notfound BOOLEAN := TRUE;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('10700: Entered get_rec', 2);
        END IF;

        RETURN(get_rec(p_chrv_rec, l_row_notfound));

    END get_rec;

  -----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_HEADERS_V --
  -----------------------------------------------------
    FUNCTION null_out_defaults (
                                p_chrv_rec IN chrv_rec_type
                                ) RETURN chrv_rec_type IS
    l_chrv_rec chrv_rec_type := p_chrv_rec;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('10800: Entered null_out_defaults', 2);
        END IF;

        IF (l_chrv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.object_version_number := NULL;
        END IF;
        IF (l_chrv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.sfwt_flag := NULL;
        END IF;
        IF (l_chrv_rec.chr_id_response = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.chr_id_response := NULL;
        END IF;
        IF (l_chrv_rec.chr_id_award = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.chr_id_award := NULL;
        END IF;
        IF (l_chrv_rec.INV_ORGANIZATION_ID = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.INV_ORGANIZATION_ID := NULL;
        END IF;
        IF (l_chrv_rec.sts_code = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.sts_code := NULL;
        END IF;
        IF (l_chrv_rec.qcl_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.qcl_id := NULL;
        END IF;
        IF (l_chrv_rec.scs_code = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.scs_code := NULL;
        END IF;
        IF (l_chrv_rec.contract_number = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.contract_number := NULL;
        END IF;
        IF (l_chrv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.currency_code := NULL;
        END IF;
        IF (l_chrv_rec.contract_number_modifier = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.contract_number_modifier := NULL;
        END IF;
        IF (l_chrv_rec.archived_yn = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.archived_yn := NULL;
        END IF;
        IF (l_chrv_rec.deleted_yn = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.deleted_yn := NULL;
        END IF;
        IF (l_chrv_rec.cust_po_number_req_yn = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.cust_po_number_req_yn := NULL;
        END IF;
        IF (l_chrv_rec.pre_pay_req_yn = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.pre_pay_req_yn := NULL;
        END IF;
        IF (l_chrv_rec.cust_po_number = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.cust_po_number := NULL;
        END IF;
        IF (l_chrv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.short_description := NULL;
        END IF;
        IF (l_chrv_rec.comments = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.comments := NULL;
        END IF;
        IF (l_chrv_rec.description = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.description := NULL;
        END IF;
        IF (l_chrv_rec.dpas_rating = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.dpas_rating := NULL;
        END IF;
        IF (l_chrv_rec.cognomen = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.cognomen := NULL;
        END IF;
        IF (l_chrv_rec.template_yn = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.template_yn := NULL;
        END IF;
        IF (l_chrv_rec.template_used = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.template_used := NULL;
        END IF;
        IF (l_chrv_rec.date_approved = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.date_approved := NULL;
        END IF;
        IF (l_chrv_rec.datetime_cancelled = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.datetime_cancelled := NULL;
        END IF;
        IF (l_chrv_rec.auto_renew_days = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.auto_renew_days := NULL;
        END IF;
        IF (l_chrv_rec.date_issued = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.date_issued := NULL;
        END IF;
        IF (l_chrv_rec.datetime_responded = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.datetime_responded := NULL;
        END IF;
        IF (l_chrv_rec.non_response_reason = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.non_response_reason := NULL;
        END IF;
        IF (l_chrv_rec.non_response_explain = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.non_response_explain := NULL;
        END IF;
        IF (l_chrv_rec.rfp_type = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.rfp_type := NULL;
        END IF;
        IF (l_chrv_rec.chr_type = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.chr_type := NULL;
        END IF;
        IF (l_chrv_rec.keep_on_mail_list = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.keep_on_mail_list := NULL;
        END IF;
        IF (l_chrv_rec.set_aside_reason = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.set_aside_reason := NULL;
        END IF;
        IF (l_chrv_rec.set_aside_percent = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.set_aside_percent := NULL;
        END IF;
        IF (l_chrv_rec.response_copies_req = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.response_copies_req := NULL;
        END IF;
        IF (l_chrv_rec.date_close_projected = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.date_close_projected := NULL;
        END IF;
        IF (l_chrv_rec.datetime_proposed = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.datetime_proposed := NULL;
        END IF;
        IF (l_chrv_rec.date_signed = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.date_signed := NULL;
        END IF;
        IF (l_chrv_rec.date_terminated = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.date_terminated := NULL;
        END IF;
        IF (l_chrv_rec.date_renewed = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.date_renewed := NULL;
        END IF;
        IF (l_chrv_rec.trn_code = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.trn_code := NULL;
        END IF;
        IF (l_chrv_rec.start_date = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.start_date := NULL;
        END IF;
        IF (l_chrv_rec.end_date = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.end_date := NULL;
        END IF;
        IF (l_chrv_rec.authoring_org_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.authoring_org_id := NULL;
        END IF;
    --mmadhavi added for MOAC

        IF (l_chrv_rec.org_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.org_id := NULL;
        END IF;

    --mmadhavi end MOAC
        IF (l_chrv_rec.buy_or_sell = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.buy_or_sell := NULL;
        END IF;
        IF (l_chrv_rec.issue_or_receive = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.issue_or_receive := NULL;
        END IF;
        IF (l_chrv_rec.estimated_amount = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.estimated_amount := NULL;
        END IF;
        IF (l_chrv_rec.estimated_amount_renewed = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.estimated_amount_renewed := NULL;
        END IF;
        IF (l_chrv_rec.currency_code_renewed = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.currency_code_renewed := NULL;
        END IF;
        IF (l_chrv_rec.upg_orig_system_ref = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.upg_orig_system_ref := NULL;
        END IF;
        IF (l_chrv_rec.upg_orig_system_ref_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.upg_orig_system_ref_id := NULL;
        END IF;
        IF (l_chrv_rec.program_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.program_id := NULL;
        END IF;
        IF (l_chrv_rec.request_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.request_id := NULL;
        END IF;
        IF (l_chrv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.program_update_date := NULL;
        END IF;
        IF (l_chrv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.program_application_id := NULL;
        END IF;
        IF (l_chrv_rec.price_list_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.price_list_id := NULL;
        END IF;
        IF (l_chrv_rec.pricing_date = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.pricing_date := NULL;
        END IF;
        IF (l_chrv_rec.sign_by_date = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.sign_by_date := NULL;
        END IF;
        IF (l_chrv_rec.total_line_list_price = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.total_line_list_price := NULL;
        END IF;
        IF (l_chrv_rec.application_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.application_id := NULL;
        END IF;
        IF (l_chrv_rec.orig_system_source_code = OKC_API.G_MISS_CHAR ) THEN
            l_chrv_rec.orig_system_source_code := NULL;
        END IF;
        IF (l_chrv_rec.orig_system_id1 = OKC_API.G_MISS_NUM ) THEN
            l_chrv_rec.orig_system_id1 := NULL;
        END IF;
        IF (l_chrv_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR ) THEN
            l_chrv_rec.orig_system_reference1 := NULL;
        END IF;

        IF (l_chrv_rec.USER_ESTIMATED_AMOUNT = OKC_API.G_MISS_NUM ) THEN
            l_chrv_rec.USER_ESTIMATED_AMOUNT := NULL;
        END IF;

        IF (l_chrv_rec.GOVERNING_CONTRACT_YN = OKC_API.G_MISS_CHAR ) THEN
            l_chrv_rec.GOVERNING_CONTRACT_YN := NULL;
        END IF;

        IF (l_chrv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute_category := NULL;
        END IF;
        IF (l_chrv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute1 := NULL;
        END IF;
        IF (l_chrv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute2 := NULL;
        END IF;
        IF (l_chrv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute3 := NULL;
        END IF;
        IF (l_chrv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute4 := NULL;
        END IF;
        IF (l_chrv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute5 := NULL;
        END IF;
        IF (l_chrv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute6 := NULL;
        END IF;
        IF (l_chrv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute7 := NULL;
        END IF;
        IF (l_chrv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute8 := NULL;
        END IF;
        IF (l_chrv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute9 := NULL;
        END IF;
        IF (l_chrv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute10 := NULL;
        END IF;
        IF (l_chrv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute11 := NULL;
        END IF;
        IF (l_chrv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute12 := NULL;
        END IF;
        IF (l_chrv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute13 := NULL;
        END IF;
        IF (l_chrv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute14 := NULL;
        END IF;
        IF (l_chrv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.attribute15 := NULL;
        END IF;
        IF (l_chrv_rec.created_by = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.created_by := NULL;
        END IF;
        IF (l_chrv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.creation_date := NULL;
        END IF;
        IF (l_chrv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.last_updated_by := NULL;
        END IF;
        IF (l_chrv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.last_update_date := NULL;
        END IF;
        IF (l_chrv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.last_update_login := NULL;
        END IF;
    -- new  columns to replace rules
        IF (l_chrv_rec.conversion_type = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.conversion_type := NULL;
        END IF;
        IF (l_chrv_rec.conversion_rate = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.conversion_rate := NULL;
        END IF;
        IF (l_chrv_rec.conversion_rate_date = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.conversion_rate_date := NULL;
        END IF;
        IF (l_chrv_rec.conversion_euro_rate = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.conversion_euro_rate := NULL;
        END IF;
        IF (l_chrv_rec.cust_acct_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec .cust_acct_id := NULL;
        END IF;
        IF (l_chrv_rec.bill_to_site_use_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.bill_to_site_use_id := NULL;
        END IF;
        IF (l_chrv_rec.inv_rule_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.inv_rule_id := NULL;
        END IF;
        IF (l_chrv_rec.renewal_type_code = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.renewal_type_code := NULL;
        END IF;
        IF (l_chrv_rec.renewal_notify_to = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.renewal_notify_to := NULL;
        END IF;
        IF (l_chrv_rec.renewal_end_date = OKC_API.G_MISS_DATE) THEN
            l_chrv_rec.renewal_end_date := NULL;
        END IF;
        IF (l_chrv_rec.ship_to_site_use_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.ship_to_site_use_id := NULL;
        END IF;
        IF (l_chrv_rec.payment_term_id = OKC_API.G_MISS_NUM) THEN
            l_chrv_rec.payment_term_id := NULL;
        END IF;
-- R12 Data Model Changes 4485150 Start
        IF (l_chrv_rec.approval_type = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.approval_type := NULL;
        END IF;
        IF (l_chrv_rec.term_cancel_source = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.term_cancel_source := NULL;
        END IF;
        IF (l_chrv_rec.payment_instruction_type = OKC_API.G_MISS_CHAR) THEN
            l_chrv_rec.payment_instruction_type := NULL;
        END IF;
	   -- LLC
	   IF (l_chrv_rec.cancelled_amount = OKC_API.G_MISS_NUM) THEN
	   	  l_chrv_rec.cancelled_amount := NULL;
	   END IF;
-- R12 Data Model Changes 4485150 End
        RETURN(l_chrv_rec);

    END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKC_K_HEADERS_V --
  ---------------------------------------------
    FUNCTION Validate_Attributes (
                                  p_chrv_rec IN chrv_rec_type
                                  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('10900: Entered Validate_Attributes', 2);
        END IF;

  /************************ HAND-CODED *********************************/
        validate_contract_number
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_currency_code
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_sfwt_flag
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_chr_id_response
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_chr_id_award
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_INV_ORGANIZATION_ID
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_sts_code
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_qcl_id
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_org_ids
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_buy_or_sell
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_issue_or_receive
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_scs_code
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_archived_yn
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_deleted_yn
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_cust_po_number_req_yn
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_pre_pay_req_yn
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_template_yn
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_chr_type
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

/*
    validate_datetime_cancelled
			(x_return_status => l_return_status,
			 p_chrv_rec      => p_chrv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;
*/
        validate_keep_on_mail_list
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_set_aside_percent
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;
/*
    validate_date_terminated
			(x_return_status => l_return_status,
			 p_chrv_rec      => p_chrv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;
*/
        validate_trn_code
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;
/*
    validate_chr_id_rnwd_to
			(x_return_status => l_return_status,
			 p_chrv_rec      => p_chrv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;
*/
        validate_curr_code_rnwd
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;

        validate_orig_sys_code
        (x_return_status => l_return_status,
         p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;
/* Bug 3652127 Price list not validated for OKS*/
        IF l_application_id <> 515 THEN
            validate_PRICE_LIST_ID
            (x_return_status => l_return_status,
             p_chrv_rec => p_chrv_rec);

    -- store the highest degree of error
            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                    x_return_status := l_return_status;
                END IF;
            END IF;
        END IF;

        --From R12 onwards, OKS has it's won renewal type
        IF l_application_id <> 515 THEN
                validate_renewal_type_code
                (x_return_status => l_return_status,
                 p_chrv_rec => p_chrv_rec);

            -- store the highest degree of error
                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                        x_return_status := l_return_status;
                    END IF;
                END IF;
        ELSE
                validate_oks_renewal_type_code
                (x_return_status => l_return_status,
                 p_chrv_rec => p_chrv_rec);

            -- store the highest degree of error
                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                        x_return_status := l_return_status;
                    END IF;
                END IF;
        END IF;
        --end of R12 renewal_type_code validation changes

-- R12 Data Model Changes 4485150 Start
        validate_approval_type(x_return_status => l_return_status,
                               p_chrv_rec => p_chrv_rec) ;
    -- store the highest degree of error
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
            END IF;
        END IF;
-- R12 Data Model Changes 4485150 End
        RETURN(x_return_status);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('11000: Exiting Validate_Attributes', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('11100: Exiting Validate_Attributes:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);

	   -- notify caller of an UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

	   -- return status to caller
            RETURN(x_return_status);


    END Validate_Attributes;

  -- This function returns the status type for given status code
    FUNCTION Get_Status_Type(p_code VARCHAR2) RETURN VARCHAR2 IS
    l_ste_code VARCHAR2(30) := 'X';

    CURSOR l_stsv_csr IS
        SELECT ste_code
        FROM okc_statuses_b
        WHERE code = p_code;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('11200: Entered Get_Status_Type', 2);
        END IF;

        OPEN l_stsv_csr;
        FETCH l_stsv_csr INTO l_ste_code;
        CLOSE l_stsv_csr;
        RETURN l_ste_code;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('11300: Exiting Get_Status_Type', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('11400: Exiting Get_Status_Type:NO_DATA_FOUND Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

            RETURN l_ste_code;
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('11500: Exiting Get_Status_Type:Others Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

            RETURN l_ste_code;
    END;

    FUNCTION IS_UNIQUE (p_chrv_rec chrv_rec_type) RETURN VARCHAR2
    IS
    CURSOR l_chr_csr1 IS
        SELECT 'x'
        --npalepu 08-11-2005 modified for bug # 4691662.
        --Replaced table okc_k_headers_b with headers_All_b table
        /* FROM okc_k_headers_b */
        FROM okc_k_headers_all_b
        --end npalepu
        WHERE contract_number = p_chrv_rec.contract_number
        AND   contract_number_modifier IS NULL
        AND   id <> nvl(p_chrv_rec.id, - 99999);

    CURSOR l_chr_csr2 IS
        SELECT 'x'
        --npalepu 08-11-2005 modified for bug # 4691662.
        --Replaced table okc_k_headers_b with headers_All_b table
        /* FROM okc_k_headers_b */
        FROM okc_k_headers_all_b
        --end npalepu
        WHERE contract_number = p_chrv_rec.contract_number
        AND   contract_number_modifier = p_chrv_rec.contract_number_modifier
        AND   id <> nvl(p_chrv_rec.id, - 99999);

    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1);
    l_found BOOLEAN;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('11600: Entered IS_UNIQUE', 2);
        END IF;

    -- check for unique CONTRACT_NUMBER + MODIFIER
        IF (p_chrv_rec.contract_number_modifier IS NULL) THEN
            OPEN l_chr_csr1;
            FETCH l_chr_csr1 INTO l_dummy;
            l_found := l_chr_csr1%FOUND;
            CLOSE l_chr_csr1;
        ELSE
            OPEN l_chr_csr2;
            FETCH l_chr_csr2 INTO l_dummy;
            l_found := l_chr_csr2%FOUND;
            CLOSE l_chr_csr2;
        END IF;
        IF (l_found) THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => 'OKC_CONTRACT_EXISTS',
                                p_token1 => 'VALUE1',
                                p_token1_value => p_chrv_rec.contract_number,
                                p_token2 => 'VALUE2',
                                p_token2_value => nvl(p_chrv_rec.contract_number_modifier,' '));
	  -- notify caller of an error
            l_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        RETURN (l_return_status);

        IF (l_debug = 'Y') THEN
            okc_debug.LOG('11700: Exiting IS_UNIQUE', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('11800: Exiting IS_UNIQUE:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

            RETURN (l_return_status);

    END IS_UNIQUE;

  /*********************** END HAND-CODED ********************************/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------

  -----------------------------------------
  -- Validate_Record for:OKC_K_HEADERS_V --
  -----------------------------------------
    FUNCTION Validate_Record (
                              p_chrv_rec IN chrv_rec_type
                              ) RETURN VARCHAR2 IS
    CURSOR l_chr_csr1 IS
        SELECT 'x'
        --npalepu 08-11-2005 modified for bug # 4691662.
        --Replaced table okc_k_headers_b with headers_All_b table
        /* FROM okc_k_headers_b */
        FROM okc_k_headers_all_b
        --end npalepu
        WHERE contract_number = p_chrv_rec.contract_number
        AND   contract_number_modifier IS NULL
        AND   id <> nvl(p_chrv_rec.id, - 99999);

    CURSOR l_chr_csr2 IS
        SELECT 'x'
        --npalepu 08-11-2005 modified for bug # 4691662.
        --Replaced table okc_k_headers_b with headers_All_b table
        /* FROM okc_k_headers_b */
        FROM okc_k_headers_all_b
        --end npalepu
        WHERE contract_number = p_chrv_rec.contract_number
        AND   contract_number_modifier = p_chrv_rec.contract_number_modifier
        AND   id <> nvl(p_chrv_rec.id, - 99999);

    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1);
    l_found BOOLEAN;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('11900: Entered Validate_Record', 2);
        END IF;

    -- check for unique CONTRACT_NUMBER + MODIFIER
    /*
    If (p_chrv_rec.contract_number_modifier is null) Then
        open l_chr_csr1;
        fetch l_chr_csr1 into l_dummy;
	   l_found := l_chr_csr1%FOUND;
	   close l_chr_csr1;
    Else
        open l_chr_csr2;
        fetch l_chr_csr2 into l_dummy;
	   l_found := l_chr_csr2%FOUND;
	   close l_chr_csr2;
    End If;
    If (l_found) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> 'OKC_CONTRACT_EXISTS',
					    p_token1		=> 'VALUE1',
					    p_token1_value	=> p_chrv_rec.contract_number,
					    p_token2		=> 'VALUE2',
					    p_token2_value	=> nvl(p_chrv_rec.contract_number_modifier,' '));
	  -- notify caller of an error
	  l_return_status := OKC_API.G_RET_STS_ERROR;
    End If;
    */
        l_return_status := IS_UNIQUE(p_chrv_rec);

        IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       -- start date cannot be after end date
            IF (p_chrv_rec.START_DATE IS NOT NULL AND
                p_chrv_rec.END_DATE IS NOT NULL)
                THEN
                IF (p_chrv_rec.START_DATE > p_chrv_rec.END_DATE) THEN
		    -- notify caller of an error as UNEXPETED error
                    l_return_status := OKC_API.G_RET_STS_ERROR;
                    OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                        p_msg_name => 'OKC_INVALID_START_END_DATES'
                                        );
                END IF;
            END IF;
       ---SIGN_BY_DATE  must be earlier than the END_DATE of the contract
            IF (p_chrv_rec.START_DATE IS NOT NULL AND
                p_chrv_rec.SIGN_BY_DATE IS NOT NULL)
                THEN
--Bug 3720503      If (p_chrv_rec.END_DATE > p_chrv_rec.SIGN_BY_DATE) Then
                IF (p_chrv_rec.SIGN_BY_DATE > p_chrv_rec.END_DATE ) THEN
		    -- notify caller of an error as UNEXPETED error
                    l_return_status := OKC_API.G_RET_STS_ERROR;
                    OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                        p_msg_name => 'OKC_INVALID_SIGN_END_DATES');
                END IF;
            END IF;

        END IF;
   --Pricing date should not be than contract end date for advanced pricing
        IF ((l_return_status = OKC_API.G_RET_STS_SUCCESS) AND
            NVL(fnd_profile.VALUE('OKC_ADVANCED_PRICING'), 'N') = 'Y') THEN
            IF (p_chrv_rec.END_DATE IS NOT NULL AND
                p_chrv_rec.PRICING_DATE IS NOT NULL)
                THEN
                IF (p_chrv_rec.PRICING_DATE > p_chrv_rec.END_DATE) THEN
              -- notify caller of an error as UNEXPETED error
                    l_return_status := OKC_API.G_RET_STS_ERROR;
                    OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                        p_msg_name => 'OKC_INVALID_PRICING_DATE');
                END IF;
            END IF;
        END IF;

        RETURN (l_return_status);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('12000: Exiting Validate_Record', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('12100: Exiting Validate_Record:NO_DATA_FOUND Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

            NULL;

    END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
    PROCEDURE migrate (
                       p_from IN chrv_rec_type,
                       p_to IN OUT NOCOPY chr_rec_type
                       ) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('12200: Entered migrate', 2);
        END IF;

        p_to.id := p_from.id;
        p_to.contract_number := p_from.contract_number;
        p_to.authoring_org_id := p_from.authoring_org_id;
--    p_to.org_id := p_from.org_id; --mmadhavi added for MOAC
        p_to.contract_number_modifier := p_from.contract_number_modifier;
        p_to.chr_id_response := p_from.chr_id_response;
        p_to.chr_id_award := p_from.chr_id_award;
        p_to.INV_ORGANIZATION_ID := p_from.INV_ORGANIZATION_ID;
        p_to.sts_code := p_from.sts_code;
        p_to.qcl_id := p_from.qcl_id;
        p_to.scs_code := p_from.scs_code;
        p_to.trn_code := p_from.trn_code;
        p_to.currency_code := p_from.currency_code;
        p_to.archived_yn := p_from.archived_yn;
        p_to.deleted_yn := p_from.deleted_yn;
        p_to.template_yn := p_from.template_yn;
        p_to.chr_type := p_from.chr_type;
        p_to.object_version_number := p_from.object_version_number;
        p_to.created_by := p_from.created_by;
        p_to.creation_date := p_from.creation_date;
        p_to.last_updated_by := p_from.last_updated_by;
        p_to.last_update_date := p_from.last_update_date;
        p_to.cust_po_number_req_yn := p_from.cust_po_number_req_yn;
        p_to.pre_pay_req_yn := p_from.pre_pay_req_yn;
        p_to.cust_po_number := p_from.cust_po_number;
        p_to.dpas_rating := p_from.dpas_rating;
        p_to.template_used := p_from.template_used;
        p_to.date_approved := p_from.date_approved;
        p_to.datetime_cancelled := p_from.datetime_cancelled;
        p_to.auto_renew_days := p_from.auto_renew_days;
        p_to.date_issued := p_from.date_issued;
        p_to.datetime_responded := p_from.datetime_responded;
        p_to.rfp_type := p_from.rfp_type;
        p_to.keep_on_mail_list := p_from.keep_on_mail_list;
        p_to.set_aside_percent := p_from.set_aside_percent;
        p_to.response_copies_req := p_from.response_copies_req;
        p_to.date_close_projected := p_from.date_close_projected;
        p_to.datetime_proposed := p_from.datetime_proposed;
        p_to.date_signed := p_from.date_signed;
        p_to.date_terminated := p_from.date_terminated;
        p_to.date_renewed := p_from.date_renewed;
        p_to.start_date := p_from.start_date;
        p_to.end_date := p_from.end_date;
        p_to.buy_or_sell := p_from.buy_or_sell;
        p_to.issue_or_receive := p_from.issue_or_receive;
        p_to.estimated_amount := p_from.estimated_amount;
        p_to.estimated_amount_renewed := p_from.estimated_amount_renewed;
        p_to.currency_code_renewed := p_from.currency_code_renewed;
        p_to.last_update_login := p_from.last_update_login;
        p_to.upg_orig_system_ref := p_from.upg_orig_system_ref;
        p_to.upg_orig_system_ref_id := p_from.upg_orig_system_ref_id;
        p_to.application_id := p_from.application_id;
        p_to.orig_system_source_code := p_from.orig_system_source_code;
        p_to.orig_system_id1 := p_from.orig_system_id1;
        p_to.orig_system_reference1 := p_from.orig_system_reference1 ;
        p_to.program_id := p_from.program_id;
        p_to.request_id := p_from.request_id;
        p_to.program_update_date := p_from.program_update_date;
        p_to.program_application_id := p_from.program_application_id;
        p_to.price_list_id := p_from.price_list_id;
        p_to.pricing_date := p_from.pricing_date;
        p_to.sign_by_date := p_from.sign_by_date;
        p_to.total_line_list_price := p_from.total_line_list_price;
        p_to.USER_ESTIMATED_AMOUNT := p_from.USER_ESTIMATED_AMOUNT;
        p_to.governing_contract_yn := p_from.governing_contract_yn;
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
 --new columns to replace rules
        p_to.conversion_type := p_from.conversion_type;
        p_to.conversion_rate := p_from.conversion_rate;
        p_to.conversion_rate_date := p_from.conversion_rate_date;
        p_to.conversion_euro_rate := p_from.conversion_euro_rate;
        p_to.cust_acct_id := p_from.cust_acct_id;
        p_to.bill_to_site_use_id := p_from.bill_to_site_use_id;
        p_to.inv_rule_id := p_from.inv_rule_id;
        p_to.renewal_type_code := p_from.renewal_type_code;
        p_to.renewal_notify_to := p_from.renewal_notify_to;
        p_to.renewal_end_date := p_from.renewal_end_date;
        p_to.ship_to_site_use_id := p_from.ship_to_site_use_id;
        p_to.payment_term_id := p_from.payment_term_id;
        p_to.document_id := p_from.document_id;

-- R12 Data Model Changes 4485150 Start
        p_to.approval_type := p_from.approval_type;
        p_to.term_cancel_source := p_from.term_cancel_source;
        p_to.payment_instruction_type := p_from.payment_instruction_type;
        p_to.org_id := p_from.org_id; --mmadhavi added for MOAC
-- R12 Data Model Changes 4485150 End
	  p_to.cancelled_amount := p_from.cancelled_amount; -- LLC

    END migrate;
    PROCEDURE migrate (
                       p_from IN chr_rec_type,
                       p_to IN OUT NOCOPY chrv_rec_type
                       ) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('12300: Entered migrate', 2);
        END IF;

        p_to.id := p_from.id;
        p_to.contract_number := p_from.contract_number;
        p_to.authoring_org_id := p_from.authoring_org_id;
        p_to.org_id := p_from.org_id; --mmadhavi added for MOAC
        p_to.contract_number_modifier := p_from.contract_number_modifier;
        p_to.chr_id_response := p_from.chr_id_response;
        p_to.chr_id_award := p_from.chr_id_award;
        p_to.INV_ORGANIZATION_ID := p_from.INV_ORGANIZATION_ID;
        p_to.sts_code := p_from.sts_code;
        p_to.qcl_id := p_from.qcl_id;
        p_to.scs_code := p_from.scs_code;
        p_to.trn_code := p_from.trn_code;
        p_to.currency_code := p_from.currency_code;
        p_to.archived_yn := p_from.archived_yn;
        p_to.deleted_yn := p_from.deleted_yn;
        p_to.template_yn := p_from.template_yn;
        p_to.chr_type := p_from.chr_type;
        p_to.object_version_number := p_from.object_version_number;
        p_to.created_by := p_from.created_by;
        p_to.creation_date := p_from.creation_date;
        p_to.last_updated_by := p_from.last_updated_by;
        p_to.last_update_date := p_from.last_update_date;
        p_to.cust_po_number_req_yn := p_from.cust_po_number_req_yn;
        p_to.pre_pay_req_yn := p_from.pre_pay_req_yn;
        p_to.cust_po_number := p_from.cust_po_number;
        p_to.dpas_rating := p_from.dpas_rating;
        p_to.template_used := p_from.template_used;
        p_to.date_approved := p_from.date_approved;
        p_to.datetime_cancelled := p_from.datetime_cancelled;
        p_to.auto_renew_days := p_from.auto_renew_days;
        p_to.date_issued := p_from.date_issued;
        p_to.datetime_responded := p_from.datetime_responded;
        p_to.rfp_type := p_from.rfp_type;
        p_to.keep_on_mail_list := p_from.keep_on_mail_list;
        p_to.set_aside_percent := p_from.set_aside_percent;
        p_to.response_copies_req := p_from.response_copies_req;
        p_to.date_close_projected := p_from.date_close_projected;
        p_to.datetime_proposed := p_from.datetime_proposed;
        p_to.date_signed := p_from.date_signed;
        p_to.date_terminated := p_from.date_terminated;
        p_to.date_renewed := p_from.date_renewed;
        p_to.start_date := p_from.start_date;
        p_to.end_date := p_from.end_date;
        p_to.buy_or_sell := p_from.buy_or_sell;
        p_to.issue_or_receive := p_from.issue_or_receive;
        p_to.estimated_amount := p_from.estimated_amount;
        p_to.estimated_amount_renewed := p_from.estimated_amount_renewed;
        p_to.currency_code_renewed := p_from.currency_code_renewed;
        p_to.last_update_login := p_from.last_update_login;
        p_to.upg_orig_system_ref := p_from.upg_orig_system_ref;
        p_to.upg_orig_system_ref_id := p_from.upg_orig_system_ref_id;
        p_to.application_id := p_from.application_id;
        p_to.orig_system_source_code := p_from.orig_system_source_code;
        p_to.orig_system_id1 := p_from.orig_system_id1;
        p_to.orig_system_reference1 := p_from.orig_system_reference1 ;
        p_to.program_id := p_from.program_id;
        p_to.request_id := p_from.request_id;
        p_to.program_update_date := p_from.program_update_date;
        p_to.program_application_id := p_from.program_application_id;
        p_to.price_list_id := p_from.price_list_id;
        p_to.pricing_date := p_from.pricing_date;
        p_to.sign_by_date := p_from.sign_by_date;
        p_to.total_line_list_price := p_from.total_line_list_price;
        p_to.USER_ESTIMATED_AMOUNT := p_from.USER_ESTIMATED_AMOUNT;
        p_to.GOVERNING_CONTRACT_YN := p_from.GOVERNING_CONTRACT_YN;
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
     --new columns to replace rules
        p_to.conversion_type := p_from.conversion_type;
        p_to.conversion_rate := p_from.conversion_rate;
        p_to.conversion_rate_date := p_from.conversion_rate_date;
        p_to.conversion_euro_rate := p_from.conversion_euro_rate;
        p_to.cust_acct_id := p_from.cust_acct_id;
        p_to.bill_to_site_use_id := p_from.bill_to_site_use_id;
        p_to.inv_rule_id := p_from.inv_rule_id;
        p_to.renewal_type_code := p_from.renewal_type_code;
        p_to.renewal_notify_to := p_from.renewal_notify_to;
        p_to.renewal_end_date := p_from.renewal_end_date;
        p_to.ship_to_site_use_id := p_from.ship_to_site_use_id;
        p_to.payment_term_id := p_from.payment_term_id;
        p_to.document_id := p_from.document_id;

-- R12 Data Model Changes 4485150 Start
        p_to.approval_type := p_from.approval_type;
        p_to.term_cancel_source := p_from.term_cancel_source;
        p_to.payment_instruction_type := p_from.payment_instruction_type;
        p_to.org_id := p_from.org_id; --mmadhavi added for MOAC
-- R12 Data Model Changes 4485150 End
 	   p_to.cancelled_amount := p_from.cancelled_amount; -- LLC

    END migrate;
    PROCEDURE migrate (
                       p_from IN chrv_rec_type,
                       p_to IN OUT NOCOPY okc_k_headers_tl_rec_type
                       ) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('12400: Entered migrate', 2);
        END IF;

        p_to.id := p_from.id;
        p_to.sfwt_flag := p_from.sfwt_flag;
        p_to.short_description := p_from.short_description;
        p_to.comments := p_from.comments;
        p_to.description := p_from.description;
        p_to.cognomen := p_from.cognomen;
        p_to.non_response_reason := p_from.non_response_reason;
        p_to.non_response_explain := p_from.non_response_explain;
        p_to.set_aside_reason := p_from.set_aside_reason;
        p_to.created_by := p_from.created_by;
        p_to.creation_date := p_from.creation_date;
        p_to.last_updated_by := p_from.last_updated_by;
        p_to.last_update_date := p_from.last_update_date;
        p_to.last_update_login := p_from.last_update_login;

    END migrate;
    PROCEDURE migrate (
                       p_from IN okc_k_headers_tl_rec_type,
                       p_to IN OUT NOCOPY chrv_rec_type
                       ) IS
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('12500: Entered migrate', 2);
        END IF;

        p_to.id := p_from.id;
        p_to.sfwt_flag := p_from.sfwt_flag;
        p_to.short_description := p_from.short_description;
        p_to.comments := p_from.comments;
        p_to.description := p_from.description;
        p_to.cognomen := p_from.cognomen;
        p_to.non_response_reason := p_from.non_response_reason;
        p_to.non_response_explain := p_from.non_response_explain;
        p_to.set_aside_reason := p_from.set_aside_reason;
        p_to.created_by := p_from.created_by;
        p_to.creation_date := p_from.creation_date;
        p_to.last_updated_by := p_from.last_updated_by;
        p_to.last_update_date := p_from.last_update_date;
        p_to.last_update_login := p_from.last_update_login;

    END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKC_K_HEADERS_V --
  --------------------------------------
    PROCEDURE validate_row(
                           p_api_version IN NUMBER,
                           p_init_msg_list IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2,
                           p_chrv_rec IN chrv_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chrv_rec chrv_rec_type := p_chrv_rec;
    l_chr_rec chr_rec_type;
    l_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('12600: Entered validate_row', 2);
        END IF;

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

        IF p_chrv_rec.VALIDATE_YN = 'Y' THEN ---Bug#3150149
       --- Validate all non-missing attributes (Item Level Validation)
            l_return_status := Validate_Attributes(l_chrv_rec);
        END IF;

    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := Validate_Record(l_chrv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('12700: Exiting validate_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('12800: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('12900: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('13000: Exiting validate_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  ------------------------------------------
  -- PL/SQL TBL validate_row for:CHRV_TBL --
  ------------------------------------------
    PROCEDURE validate_row(
                           p_api_version IN NUMBER,
                           p_init_msg_list IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2,
                           p_chrv_tbl IN chrv_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('13100: Entered validate_row', 2);
        END IF;

        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_chrv_tbl.COUNT > 0) THEN
            i := p_chrv_tbl.FIRST;
            LOOP
                validate_row (
                              p_api_version => p_api_version,
                              p_init_msg_list => OKC_API.G_FALSE,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_chrv_rec => p_chrv_tbl(i));

		-- store the highest degree of error
                IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := x_return_status;
                    END IF;
                END IF;

                EXIT WHEN (i = p_chrv_tbl.LAST);
                i := p_chrv_tbl.NEXT(i);
            END LOOP;
	 -- return overall status
            x_return_status := l_overall_status;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('13200: Exiting validate_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('13300: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('13400: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('13500: Exiting validate_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  ------------------------------------
  -- insert_row for:OKC_K_HEADERS_ALL_B --
  ------------------------------------
    PROCEDURE insert_row(
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_chr_rec IN chr_rec_type,
                         x_chr_rec OUT NOCOPY chr_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chr_rec chr_rec_type := p_chr_rec;
    l_def_chr_rec chr_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKC_K_HEADERS_ALL_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
                             p_chr_rec IN chr_rec_type,
                             x_chr_rec OUT NOCOPY chr_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('13600: Entered Set_Attributes', 2);
        END IF;

        x_chr_rec := p_chr_rec;
        RETURN(l_return_status);

    END Set_Attributes;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('13700: Entered insert_row', 2);
        END IF;

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
                                          p_chr_rec,  -- IN
                                          l_chr_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        INSERT INTO OKC_K_HEADERS_ALL_B( --mmadhavi changed to _ALL for MOAC
                                        id,
                                        contract_number,
                                        authoring_org_id,
                                        org_id,  --mmadhavi added for MOAC
                                        contract_number_modifier,
                                        chr_id_response,
                                        chr_id_award,
                                        INV_ORGANIZATION_ID,
                                        sts_code,
                                        qcl_id,
                                        scs_code,
                                        trn_code,
                                        currency_code,
                                        archived_yn,
                                        deleted_yn,
                                        template_yn,
                                        chr_type,
                                        object_version_number,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        cust_po_number_req_yn,
                                        pre_pay_req_yn,
                                        cust_po_number,
                                        dpas_rating,
                                        template_used,
                                        date_approved,
                                        datetime_cancelled,
                                        auto_renew_days,
                                        date_issued,
                                        datetime_responded,
                                        rfp_type,
                                        keep_on_mail_list,
                                        set_aside_percent,
                                        response_copies_req,
                                        date_close_projected,
                                        datetime_proposed,
                                        date_signed,
                                        date_terminated,
                                        date_renewed,
                                        start_date,
                                        end_date,
                                        buy_or_sell,
                                        issue_or_receive,
                                        estimated_amount,
                                        estimated_amount_renewed,
                                        currency_code_renewed,
                                        last_update_login,
                                        upg_orig_system_ref,
                                        upg_orig_system_ref_id,
                                        application_id,
                                        orig_system_source_code,
                                        orig_system_id1,
                                        orig_system_reference1,
                                        program_id,
                                        request_id,
                                        program_update_date,
                                        program_application_id,
                                        price_list_id,
                                        pricing_date,
                                        sign_by_date,
                                        total_line_list_price,
                                        USER_ESTIMATED_AMOUNT,
                                        GOVERNING_CONTRACT_YN,
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
                                        -- new columns to replace rules
                                        conversion_type,
                                        conversion_rate,
                                        conversion_rate_date,
                                        conversion_euro_rate,
                                        cust_acct_id,
                                        bill_to_site_use_id,
                                        inv_rule_id,
                                        renewal_type_code,
                                        renewal_notify_to,
                                        renewal_end_date,
                                        ship_to_site_use_id,
                                        payment_term_id,
                                        document_id,
                                        -- R12 Data Model Changes 4485150 Start
                                        approval_type,
                                        term_cancel_source,
                                        payment_instruction_type,
                                        -- R12 Data Model Changes 4485150 End
					billed_at_source
                                        )
          VALUES (
                  l_chr_rec.id,
                  l_chr_rec.contract_number,
                  --l_chr_rec.authoring_org_id,
                  l_chr_rec.authoring_org_id,
                  l_chr_rec.org_id,  --mmadhavi added for MOAC
                  l_chr_rec.contract_number_modifier,
                  l_chr_rec.chr_id_response,
                  l_chr_rec.chr_id_award,
                  l_chr_rec.INV_ORGANIZATION_ID,
                  l_chr_rec.sts_code,
                  l_chr_rec.qcl_id,
                  l_chr_rec.scs_code,
                  l_chr_rec.trn_code,
                  l_chr_rec.currency_code,
                  l_chr_rec.archived_yn,
                  l_chr_rec.deleted_yn,
                  l_chr_rec.template_yn,
                  l_chr_rec.chr_type,
                  l_chr_rec.object_version_number,
                  l_chr_rec.created_by,
                  l_chr_rec.creation_date,
                  l_chr_rec.last_updated_by,
                  l_chr_rec.last_update_date,
                  l_chr_rec.cust_po_number_req_yn,
                  l_chr_rec.pre_pay_req_yn,
                  l_chr_rec.cust_po_number,
                  l_chr_rec.dpas_rating,
                  l_chr_rec.template_used,
                  l_chr_rec.date_approved,
                  l_chr_rec.datetime_cancelled,
                  l_chr_rec.auto_renew_days,
                  l_chr_rec.date_issued,
                  l_chr_rec.datetime_responded,
                  l_chr_rec.rfp_type,
                  l_chr_rec.keep_on_mail_list,
                  l_chr_rec.set_aside_percent,
                  l_chr_rec.response_copies_req,
                  l_chr_rec.date_close_projected,
                  l_chr_rec.datetime_proposed,
                  l_chr_rec.date_signed,
                  l_chr_rec.date_terminated,
                  l_chr_rec.date_renewed,
                  l_chr_rec.start_date,
                  l_chr_rec.end_date,
                  l_chr_rec.buy_or_sell,
                  l_chr_rec.issue_or_receive,
                  l_chr_rec.estimated_amount,
                  l_chr_rec.estimated_amount_renewed,
                  l_chr_rec.currency_code_renewed,
                  l_chr_rec.last_update_login,
                  l_chr_rec.upg_orig_system_ref,
                  l_chr_rec.upg_orig_system_ref_id,
                  l_chr_rec.application_id,
                  l_chr_rec.orig_system_source_code,
                  l_chr_rec.orig_system_id1,
                  l_chr_rec.orig_system_reference1,
                  decode(FND_GLOBAL.CONC_PROGRAM_ID, - 1, NULL, FND_GLOBAL.CONC_PROGRAM_ID),
                  decode(FND_GLOBAL.CONC_REQUEST_ID, - 1, NULL, FND_GLOBAL.CONC_REQUEST_ID),
                  decode(FND_GLOBAL.CONC_REQUEST_ID, - 1, NULL, SYSDATE),
                  decode(FND_GLOBAL.PROG_APPL_ID, - 1, NULL, FND_GLOBAL.PROG_APPL_ID),
                  l_chr_rec.price_list_id,
                  l_chr_rec.pricing_date,
                  l_chr_rec.sign_by_date,
                  l_chr_rec.total_line_list_price,
                  l_chr_rec.USER_ESTIMATED_AMOUNT,
                  l_chr_rec.GOVERNING_CONTRACT_YN,
                  l_chr_rec.attribute_category,
                  l_chr_rec.attribute1,
                  l_chr_rec.attribute2,
                  l_chr_rec.attribute3,
                  l_chr_rec.attribute4,
                  l_chr_rec.attribute5,
                  l_chr_rec.attribute6,
                  l_chr_rec.attribute7,
                  l_chr_rec.attribute8,
                  l_chr_rec.attribute9,
                  l_chr_rec.attribute10,
                  l_chr_rec.attribute11,
                  l_chr_rec.attribute12,
                  l_chr_rec.attribute13,
                  l_chr_rec.attribute14,
                  l_chr_rec.attribute15,
                  -- new columns to replace rules
                  l_chr_rec.conversion_type,
                  l_chr_rec.conversion_rate,
                  l_chr_rec.conversion_rate_date,
                  l_chr_rec.conversion_euro_rate,
                  l_chr_rec.cust_acct_id,
                  l_chr_rec.bill_to_site_use_id,
                  l_chr_rec.inv_rule_id,
                  l_chr_rec.renewal_type_code,
                  l_chr_rec.renewal_notify_to,
                  l_chr_rec.renewal_end_date,
                  l_chr_rec.ship_to_site_use_id,
                  l_chr_rec.payment_term_id,
                  l_chr_rec.id,
                  -- R12 Data Model Changes 4485150 Start
                  l_chr_rec.approval_type,
                  l_chr_rec.term_cancel_source,
                  l_chr_rec.payment_instruction_type,
                  -- R12 Data Model Changes 4485150 End
                  l_chr_rec.billed_at_source
                  );
    -- Set OUT values
        x_chr_rec := l_chr_rec;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('13800: Exiting insert_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('13900: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('14000: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('14100: Exiting insert_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  -------------------------------------
  -- insert_row for:OKC_K_HEADERS_TL --
  -------------------------------------
    PROCEDURE insert_row(
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type,
                         x_okc_k_headers_tl_rec OUT NOCOPY okc_k_headers_tl_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_headers_tl_rec okc_k_headers_tl_rec_type := p_okc_k_headers_tl_rec;
    l_def_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    CURSOR get_languages IS
        SELECT *
          FROM FND_LANGUAGES
         WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------
    -- Set_Attributes for:OKC_K_HEADERS_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
                             p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type,
                             x_okc_k_headers_tl_rec OUT NOCOPY okc_k_headers_tl_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('14200: Entered Set_Attributes', 2);
        END IF;

        x_okc_k_headers_tl_rec := p_okc_k_headers_tl_rec;
        x_okc_k_headers_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
        x_okc_k_headers_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
        RETURN(l_return_status);

    END Set_Attributes;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('14300: Entered insert_row', 2);
        END IF;

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
                                          p_okc_k_headers_tl_rec,  -- IN
                                          l_okc_k_headers_tl_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        FOR l_lang_rec IN get_languages LOOP
            l_okc_k_headers_tl_rec.language := l_lang_rec.language_code;
            INSERT INTO OKC_K_HEADERS_TL(
                                         id,
                                         language,
                                         source_lang,
                                         sfwt_flag,
                                         short_description,
                                         comments,
                                         description,
                                         cognomen,
                                         non_response_reason,
                                         non_response_explain,
                                         set_aside_reason,
                                         created_by,
                                         creation_date,
                                         last_updated_by,
                                         last_update_date,
                                         last_update_login)
              VALUES (
                      l_okc_k_headers_tl_rec.id,
                      l_okc_k_headers_tl_rec.language,
                      l_okc_k_headers_tl_rec.source_lang,
                      l_okc_k_headers_tl_rec.sfwt_flag,
                      l_okc_k_headers_tl_rec.short_description,
                      l_okc_k_headers_tl_rec.comments,
                      l_okc_k_headers_tl_rec.description,
                      l_okc_k_headers_tl_rec.cognomen,
                      l_okc_k_headers_tl_rec.non_response_reason,
                      l_okc_k_headers_tl_rec.non_response_explain,
                      l_okc_k_headers_tl_rec.set_aside_reason,
                      l_okc_k_headers_tl_rec.created_by,
                      l_okc_k_headers_tl_rec.creation_date,
                      l_okc_k_headers_tl_rec.last_updated_by,
                      l_okc_k_headers_tl_rec.last_update_date,
                      l_okc_k_headers_tl_rec.last_update_login);
        END LOOP;
    -- Set OUT values
        x_okc_k_headers_tl_rec := l_okc_k_headers_tl_rec;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('14400: Exiting insert_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('14500: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('14600: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('14700: Exiting insert_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  ------------------------------------
  -- insert_row for:OKC_K_HEADERS_V --
  ------------------------------------
    PROCEDURE insert_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_chrv_rec IN chrv_rec_type,
                         x_chrv_rec OUT NOCOPY chrv_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chrv_rec chrv_rec_type;
    l_def_chrv_rec chrv_rec_type;
    l_chr_rec chr_rec_type;
    lx_chr_rec chr_rec_type;
    l_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    lx_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
                               p_chrv_rec IN chrv_rec_type
                               ) RETURN chrv_rec_type IS
    l_chrv_rec chrv_rec_type := p_chrv_rec;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('14800: Entered fill_who_columns', 2);
        END IF;

        l_chrv_rec.CREATION_DATE := SYSDATE;
        l_chrv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
        l_chrv_rec.LAST_UPDATE_DATE := l_chrv_rec.CREATION_DATE;
        l_chrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_chrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_chrv_rec);

    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKC_K_HEADERS_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
                             p_chrv_rec IN chrv_rec_type,
                             x_chrv_rec OUT NOCOPY chrv_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    CURSOR l_app_csr(p_scs_code VARCHAR2) IS
        SELECT application_id
        FROM okc_classes_b cls, okc_subclasses_b scs
        WHERE cls.code = scs.cls_code
        AND scs.code = p_scs_code;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('14900: Entered Set_Attributes', 2);
        END IF;

        x_chrv_rec := p_chrv_rec;
        x_chrv_rec.OBJECT_VERSION_NUMBER := 1;
        x_chrv_rec.SFWT_FLAG := 'N';
      /************************ HAND-CODED *********************************/
        x_chrv_rec.ARCHIVED_YN := UPPER(x_chrv_rec.ARCHIVED_YN);
        x_chrv_rec.DELETED_YN := UPPER(x_chrv_rec.DELETED_YN);
        x_chrv_rec.CUST_PO_NUMBER_REQ_YN := UPPER(x_chrv_rec.CUST_PO_NUMBER_REQ_YN);
        x_chrv_rec.PRE_PAY_REQ_YN := UPPER(x_chrv_rec.PRE_PAY_REQ_YN);
        x_chrv_rec.TEMPLATE_YN := UPPER(x_chrv_rec.TEMPLATE_YN);
        x_chrv_rec.TEMPLATE_USED := UPPER(x_chrv_rec.TEMPLATE_USED);
        x_chrv_rec.KEEP_ON_MAIL_LIST := UPPER(x_chrv_rec.KEEP_ON_MAIL_LIST);
      --Supports only CYA in this release
        x_chrv_rec.CHR_TYPE := 'CYA';
        x_chrv_rec.AUTHORING_ORG_ID := nvl(OKC_CONTEXT.GET_OKC_ORG_ID, - 99);
        x_chrv_rec.ORG_ID := nvl(OKC_CONTEXT.GET_OKC_ORG_ID, - 99); --mmadhavi added for MOAC
        x_chrv_rec.INV_ORGANIZATION_ID := nvl(OKC_CONTEXT.GET_OKC_ORGANIZATION_ID, - 99);
 /* Bug 3652127 */
      -- populate application id
        OPEN l_app_csr(p_chrv_rec.scs_code);
        FETCH l_app_csr INTO l_application_id;
        CLOSE l_app_csr;

        x_chrv_rec.application_id := l_application_id;
      /*********************** END HAND-CODED ********************************/
        RETURN(l_return_status);

    END Set_Attributes;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('15000: Entered insert_row', 2);
        END IF;

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
        l_chrv_rec := null_out_defaults(p_chrv_rec);
    -- Set primary key value
        l_chrv_rec.ID := get_seq_id;
        l_chrv_rec.DOCUMENT_ID := l_chrv_rec.ID;
    --- Setting item attributes
        l_return_status := Set_Attributes(
                                          l_chrv_rec,  -- IN
                                          l_def_chrv_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_def_chrv_rec := fill_who_columns(l_def_chrv_rec);

        IF p_chrv_rec.VALIDATE_YN = 'Y' THEN ---Bug#3150149
       --- Validate all non-missing attributes (Item Level Validation)
            l_return_status := Validate_Attributes(l_def_chrv_rec);
        END IF; ---Bug#3150149

    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := Validate_Record(l_def_chrv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
        migrate(l_def_chrv_rec, l_chr_rec);
        migrate(l_def_chrv_rec, l_okc_k_headers_tl_rec);

    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
        insert_row(
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_chr_rec,
                   lx_chr_rec
                   );
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        migrate(lx_chr_rec, l_def_chrv_rec);
        insert_row(
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_okc_k_headers_tl_rec,
                   lx_okc_k_headers_tl_rec
                   );
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        migrate(lx_okc_k_headers_tl_rec, l_def_chrv_rec);
    -- Set OUT values
        x_chrv_rec := l_def_chrv_rec;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('15100: Exiting insert_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('15200: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('15300: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('15400: Exiting insert_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  -- PL/SQL TBL insert_row for:CHRV_TBL --
  ----------------------------------------
    PROCEDURE insert_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_chrv_tbl IN chrv_tbl_type,
                         x_chrv_tbl OUT NOCOPY chrv_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
    l_chrv_rec OKC_CHR_PVT.chrv_rec_type;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('15500: Entered insert_row', 2);
        END IF;

        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_chrv_tbl.COUNT > 0) THEN
            i := p_chrv_tbl.FIRST;
            LOOP
	   /************************ HAND-CODED ***************************/
                x_return_status := OKC_API.G_RET_STS_SUCCESS;
                l_chrv_rec := p_chrv_tbl(i);
        -- if contract number is null, polpulate default contract number
                IF (l_chrv_rec.contract_number = OKC_API.G_MISS_CHAR OR
                    l_chrv_rec.contract_number IS NULL)
                    THEN

                    OKC_CONTRACT_PVT.GENERATE_CONTRACT_NUMBER(
                                                              p_scs_code => l_chrv_rec.scs_code,
                                                              p_modifier => l_chrv_rec.contract_number_modifier,
                                                              x_return_status => x_return_status,
                                                              x_contract_number => l_chrv_rec.contract_number);

                    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                        OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                            p_msg_name => g_unexpected_error,
                                            p_token1 => g_sqlcode_token,
                                            p_token1_value => SQLCODE,
                                            p_token2 => g_sqlerrm_token,
                                            p_token2_value => SQLERRM);
                    END IF;
                END IF;

                IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
                    insert_row (
                                p_api_version => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                p_chrv_rec => l_chrv_rec,
                                x_chrv_rec => x_chrv_tbl(i));
                END IF;

		-- store the highest degree of error
                IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := x_return_status;
                    END IF;
                END IF;
	   /*********************** END HAND-CODED ************************/
                EXIT WHEN (i = p_chrv_tbl.LAST);
                i := p_chrv_tbl.NEXT(i);
            END LOOP;
	 -- return overall status
            x_return_status := l_overall_status;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('15600: Exiting insert_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('15700: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('15800: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('15900: Exiting insert_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  ----------------------------------
  -- lock_row for:OKC_K_HEADERS_ALL_B --
  ----------------------------------
    PROCEDURE lock_row(
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_chr_rec IN chr_rec_type) IS

    E_Resource_Busy EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy,  - 00054);
    CURSOR lock_csr (p_chr_rec IN chr_rec_type) IS
        SELECT OBJECT_VERSION_NUMBER
          FROM OKC_K_HEADERS_ALL_B --mmadhavi changed to _ALL for MOAC
         WHERE ID = p_chr_rec.id
           AND OBJECT_VERSION_NUMBER = p_chr_rec.object_version_number
        FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_chr_rec IN chr_rec_type) IS
        SELECT OBJECT_VERSION_NUMBER
          FROM OKC_K_HEADERS_ALL_B --mmadhavi changed to _ALL for MOAC
        WHERE ID = p_chr_rec.id;
    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number OKC_K_HEADERS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number OKC_K_HEADERS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound BOOLEAN := FALSE;
    lc_row_notfound BOOLEAN := FALSE;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('16000: Entered lock_row', 2);
        END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.Set_Indentation('OKC_CHR_PVT');
                okc_debug.LOG('16100: Entered lock_row', 2);
            END IF;

            OPEN lock_csr(p_chr_rec);
            FETCH lock_csr INTO l_object_version_number;
            l_row_notfound := lock_csr%NOTFOUND;
            CLOSE lock_csr;
            IF (l_debug = 'Y') THEN
                okc_debug.LOG('16200: Exiting lock_row', 2);
                okc_debug.Reset_Indentation;
            END IF;


        EXCEPTION
            WHEN E_Resource_Busy THEN

                IF (l_debug = 'Y') THEN
                    okc_debug.LOG('16300: Exiting lock_row:E_Resource_Busy Exception', 2);
                    okc_debug.Reset_Indentation;
                END IF;

                IF (lock_csr%ISOPEN) THEN
                    CLOSE lock_csr;
                END IF;
                OKC_API.set_message(G_FND_APP, G_FORM_UNABLE_TO_RESERVE_REC);
                RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
        END;

        IF (l_row_notfound ) THEN
            OPEN lchk_csr(p_chr_rec);
            FETCH lchk_csr INTO lc_object_version_number;
            lc_row_notfound := lchk_csr%NOTFOUND;
            CLOSE lchk_csr;
        END IF;
        IF (lc_row_notfound) THEN
            OKC_API.set_message(G_APP_NAME, 'OKC_FORM_RECORD_DELETED');
            RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSIF lc_object_version_number > p_chr_rec.object_version_number THEN
            OKC_API.set_message(G_APP_NAME, 'OKC_FORM_RECORD_CHANGED');
            RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSIF lc_object_version_number <> p_chr_rec.object_version_number THEN
            OKC_API.set_message(G_APP_NAME, 'OKC_FORM_RECORD_CHANGED');
            RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSIF lc_object_version_number =  - 1 THEN
            OKC_API.set_message(G_FND_APP, G_RECORD_LOGICALLY_DELETED);
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('16400: Exiting lock_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('16500: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('16600: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('16700: Exiting lock_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  -----------------------------------
  -- lock_row for:OKC_K_HEADERS_TL --
  -----------------------------------
    PROCEDURE lock_row(
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type) IS

    E_Resource_Busy EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy,  - 00054);
    CURSOR lock_csr (p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type) IS
        SELECT *
          FROM OKC_K_HEADERS_TL
         WHERE ID = p_okc_k_headers_tl_rec.id
        FOR UPDATE NOWAIT;

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var lock_csr%ROWTYPE;
    l_row_notfound BOOLEAN := FALSE;
    lc_row_notfound BOOLEAN := FALSE;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('16800: Entered lock_row', 2);
        END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.Set_Indentation('OKC_CHR_PVT');
                okc_debug.LOG('16900: Entered lock_row', 2);
            END IF;

            OPEN lock_csr(p_okc_k_headers_tl_rec);
            FETCH lock_csr INTO l_lock_var;
            l_row_notfound := lock_csr%NOTFOUND;
            CLOSE lock_csr;
            IF (l_debug = 'Y') THEN
                okc_debug.LOG('17000: Exiting lock_row', 2);
                okc_debug.Reset_Indentation;
            END IF;


        EXCEPTION
            WHEN E_Resource_Busy THEN

                IF (l_debug = 'Y') THEN
                    okc_debug.LOG('17100: Exiting lock_row:E_Resource_Busy Exception', 2);
                    okc_debug.Reset_Indentation;
                END IF;

                IF (lock_csr%ISOPEN) THEN
                    CLOSE lock_csr;
                END IF;
                OKC_API.set_message(G_FND_APP, G_FORM_UNABLE_TO_RESERVE_REC);
                RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
        END;

        IF (l_row_notfound ) THEN
            OKC_API.set_message(G_APP_NAME, 'OKC_FORM_RECORD_DELETED');
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('17200: Exiting lock_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('17300: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('17400: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('17500: Exiting lock_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  ----------------------------------
  -- lock_row for:OKC_K_HEADERS_V --
  ----------------------------------
    PROCEDURE lock_row(
                       p_api_version IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_chrv_rec IN chrv_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chr_rec chr_rec_type;
    l_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('17600: Entered lock_row', 2);
        END IF;

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
        migrate(p_chrv_rec, l_chr_rec);
        migrate(p_chrv_rec, l_okc_k_headers_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
        lock_row(
                 p_init_msg_list,
                 x_return_status,
                 x_msg_count,
                 x_msg_data,
                 l_chr_rec
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
                 l_okc_k_headers_tl_rec
                 );
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('17700: Exiting lock_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('17800: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('17900: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('18000: Exiting lock_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  -- PL/SQL TBL lock_row for:CHRV_TBL --
  --------------------------------------
    PROCEDURE lock_row(
                       p_api_version IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_chrv_tbl IN chrv_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('18100: Entered lock_row', 2);
        END IF;

        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_chrv_tbl.COUNT > 0) THEN
            i := p_chrv_tbl.FIRST;
            LOOP
                lock_row (
                          p_api_version => p_api_version,
                          p_init_msg_list => OKC_API.G_FALSE,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_chrv_rec => p_chrv_tbl(i));

		-- store the highest degree of error
                IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := x_return_status;
                    END IF;
                END IF;

                EXIT WHEN (i = p_chrv_tbl.LAST);
                i := p_chrv_tbl.NEXT(i);
            END LOOP;
	 -- return overall status
            x_return_status := l_overall_status;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('18200: Exiting lock_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('18300: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('18400: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('18500: Exiting lock_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  ------------------------------------
  -- update_row for:OKC_K_HEADERS_ALL_B --
  ------------------------------------
    PROCEDURE update_row(
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_restricted_update IN VARCHAR2,
                         p_chr_rec IN chr_rec_type,
                         x_chr_rec OUT NOCOPY chr_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chr_rec chr_rec_type := p_chr_rec;
    l_def_chr_rec chr_rec_type;
    l_row_notfound BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
                                  p_chr_rec IN chr_rec_type,
                                  x_chr_rec OUT NOCOPY chr_rec_type
                                  ) RETURN VARCHAR2 IS
    l_chr_rec chr_rec_type;
    l_row_notfound BOOLEAN := TRUE;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('18600: Entered populate_new_record', 2);
        END IF;

        x_chr_rec := p_chr_rec;
      -- Get current database values
        l_chr_rec := get_rec(p_chr_rec, l_row_notfound);
        IF (l_row_notfound) THEN
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END IF;
        IF (x_chr_rec.id = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.id := l_chr_rec.id;
        END IF;
        IF (x_chr_rec.contract_number = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.contract_number := l_chr_rec.contract_number;
        END IF;
        IF (x_chr_rec.authoring_org_id = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.authoring_org_id := l_chr_rec.authoring_org_id;
        END IF;
      --mmadhavi added for MOAC

        IF (x_chr_rec.org_id = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.org_id := l_chr_rec.org_id;
        END IF;

      --mmadhavi end MOAC
        IF (x_chr_rec.contract_number_modifier = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.contract_number_modifier := l_chr_rec.contract_number_modifier;
        END IF;
        IF (x_chr_rec.chr_id_response = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.chr_id_response := l_chr_rec.chr_id_response;
        END IF;
        IF (x_chr_rec.chr_id_award = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.chr_id_award := l_chr_rec.chr_id_award;
        END IF;
        IF (x_chr_rec.INV_ORGANIZATION_ID = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.INV_ORGANIZATION_ID := l_chr_rec.INV_ORGANIZATION_ID;
        END IF;
        IF (x_chr_rec.sts_code = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.sts_code := l_chr_rec.sts_code;
        END IF;
        IF (x_chr_rec.qcl_id = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.qcl_id := l_chr_rec.qcl_id;
        END IF;
        IF (x_chr_rec.scs_code = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.scs_code := l_chr_rec.scs_code;
        END IF;
        IF (x_chr_rec.trn_code = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.trn_code := l_chr_rec.trn_code;
        END IF;
        IF (x_chr_rec.currency_code = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.currency_code := l_chr_rec.currency_code;
        END IF;
        IF (x_chr_rec.archived_yn = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.archived_yn := l_chr_rec.archived_yn;
        END IF;
        IF (x_chr_rec.deleted_yn = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.deleted_yn := l_chr_rec.deleted_yn;
        END IF;
        IF (x_chr_rec.template_yn = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.template_yn := l_chr_rec.template_yn;
        END IF;
        IF (x_chr_rec.chr_type = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.chr_type := l_chr_rec.chr_type;
        END IF;
        IF (x_chr_rec.object_version_number = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.object_version_number := l_chr_rec.object_version_number;
        END IF;
        IF (x_chr_rec.created_by = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.created_by := l_chr_rec.created_by;
        END IF;
        IF (x_chr_rec.creation_date = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.creation_date := l_chr_rec.creation_date;
        END IF;
        IF (x_chr_rec.last_updated_by = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.last_updated_by := l_chr_rec.last_updated_by;
        END IF;
        IF (x_chr_rec.last_update_date = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.last_update_date := l_chr_rec.last_update_date;
        END IF;
        IF (x_chr_rec.cust_po_number_req_yn = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.cust_po_number_req_yn := l_chr_rec.cust_po_number_req_yn;
        END IF;
        IF (x_chr_rec.pre_pay_req_yn = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.pre_pay_req_yn := l_chr_rec.pre_pay_req_yn;
        END IF;
        IF (x_chr_rec.cust_po_number = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.cust_po_number := l_chr_rec.cust_po_number;
        END IF;
        IF (x_chr_rec.dpas_rating = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.dpas_rating := l_chr_rec.dpas_rating;
        END IF;
        IF (x_chr_rec.template_used = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.template_used := l_chr_rec.template_used;
        END IF;
        IF (x_chr_rec.date_approved = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.date_approved := l_chr_rec.date_approved;
        END IF;
        IF (x_chr_rec.datetime_cancelled = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.datetime_cancelled := l_chr_rec.datetime_cancelled;
        END IF;
        IF (x_chr_rec.auto_renew_days = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.auto_renew_days := l_chr_rec.auto_renew_days;
        END IF;
        IF (x_chr_rec.date_issued = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.date_issued := l_chr_rec.date_issued;
        END IF;
        IF (x_chr_rec.datetime_responded = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.datetime_responded := l_chr_rec.datetime_responded;
        END IF;
        IF (x_chr_rec.rfp_type = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.rfp_type := l_chr_rec.rfp_type;
        END IF;
        IF (x_chr_rec.keep_on_mail_list = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.keep_on_mail_list := l_chr_rec.keep_on_mail_list;
        END IF;
        IF (x_chr_rec.set_aside_percent = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.set_aside_percent := l_chr_rec.set_aside_percent;
        END IF;
        IF (x_chr_rec.response_copies_req = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.response_copies_req := l_chr_rec.response_copies_req;
        END IF;
        IF (x_chr_rec.date_close_projected = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.date_close_projected := l_chr_rec.date_close_projected;
        END IF;
        IF (x_chr_rec.datetime_proposed = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.datetime_proposed := l_chr_rec.datetime_proposed;
        END IF;
        IF (x_chr_rec.date_signed = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.date_signed := l_chr_rec.date_signed;
        END IF;
        IF (x_chr_rec.date_terminated = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.date_terminated := l_chr_rec.date_terminated;
        END IF;
        IF (x_chr_rec.date_renewed = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.date_renewed := l_chr_rec.date_renewed;
        END IF;
        IF (x_chr_rec.start_date = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.start_date := l_chr_rec.start_date;
        END IF;
        IF (x_chr_rec.end_date = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.end_date := l_chr_rec.end_date;
        END IF;
        IF (x_chr_rec.buy_or_sell = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.buy_or_sell := l_chr_rec.buy_or_sell;
        END IF;
        IF (x_chr_rec.issue_or_receive = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.issue_or_receive := l_chr_rec.issue_or_receive;
        END IF;
        IF (x_chr_rec.estimated_amount = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.estimated_amount := l_chr_rec.estimated_amount;
        END IF;
        IF (x_chr_rec.estimated_amount_renewed = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.estimated_amount_renewed := l_chr_rec.estimated_amount_renewed;
        END IF;
        IF (x_chr_rec.currency_code_renewed = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.currency_code_renewed := l_chr_rec.currency_code_renewed;
        END IF;
        IF (x_chr_rec.last_update_login = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.last_update_login := l_chr_rec.last_update_login;
        END IF;
        IF (x_chr_rec.upg_orig_system_ref = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.upg_orig_system_ref := l_chr_rec.upg_orig_system_ref;
        END IF;
        IF (x_chr_rec.upg_orig_system_ref_id = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.upg_orig_system_ref_id := l_chr_rec.upg_orig_system_ref_id;
        END IF;
        IF (x_chr_rec.application_id = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.application_id := l_chr_rec.application_id;
        END IF;
        IF (x_chr_rec.orig_system_source_code = OKC_API.G_MISS_CHAR )
            THEN
            x_chr_rec.orig_system_source_code := l_chr_rec.orig_system_source_code ;
        END IF;
        IF (x_chr_rec.orig_system_id1 = OKC_API.G_MISS_NUM )
            THEN
            x_chr_rec.orig_system_id1 := l_chr_rec.orig_system_id1 ;
        END IF ;
        IF (x_chr_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR )
            THEN
            x_chr_rec.orig_system_reference1 := l_chr_rec.orig_system_reference1 ;
        END IF;
        IF (x_chr_rec.program_id = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.program_id := l_chr_rec.program_id;
        END IF;
        IF (x_chr_rec.request_id = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.request_id := l_chr_rec.request_id;
        END IF;
        IF (x_chr_rec.program_update_date = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.program_update_date := l_chr_rec.program_update_date;
        END IF;
        IF (x_chr_rec.program_application_id = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.program_application_id := l_chr_rec.program_application_id;
        END IF;
        IF (x_chr_rec.price_list_id = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.price_list_id := l_chr_rec.price_list_id;
        END IF;
        IF (x_chr_rec.pricing_date = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.pricing_date := l_chr_rec.pricing_date ;
        END IF;
        IF (x_chr_rec.sign_by_date = OKC_API.G_MISS_DATE)
            THEN
            x_chr_rec.sign_by_date := l_chr_rec.sign_by_date;
        END IF;
        IF (x_chr_rec.total_line_list_price = OKC_API.G_MISS_NUM)
            THEN
            x_chr_rec.total_line_list_price := l_chr_rec.total_line_list_price;
        END IF;
        IF (x_chr_rec.user_estimated_amount = OKC_API.G_MISS_NUM) THEN
            x_chr_rec.user_estimated_amount := l_chr_rec.user_estimated_amount;
        END IF;

        IF (x_chr_rec.governing_contract_yn = OKC_API.G_MISS_CHAR) THEN
            x_chr_rec.governing_contract_yn := l_chr_rec.governing_contract_yn;
        END IF;
        IF (x_chr_rec.attribute_category = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute_category := l_chr_rec.attribute_category;
        END IF;
        IF (x_chr_rec.attribute1 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute1 := l_chr_rec.attribute1;
        END IF;
        IF (x_chr_rec.attribute2 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute2 := l_chr_rec.attribute2;
        END IF;
        IF (x_chr_rec.attribute3 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute3 := l_chr_rec.attribute3;
        END IF;
        IF (x_chr_rec.attribute4 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute4 := l_chr_rec.attribute4;
        END IF;
        IF (x_chr_rec.attribute5 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute5 := l_chr_rec.attribute5;
        END IF;
        IF (x_chr_rec.attribute6 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute6 := l_chr_rec.attribute6;
        END IF;
        IF (x_chr_rec.attribute7 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute7 := l_chr_rec.attribute7;
        END IF;
        IF (x_chr_rec.attribute8 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute8 := l_chr_rec.attribute8;
        END IF;
        IF (x_chr_rec.attribute9 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute9 := l_chr_rec.attribute9;
        END IF;
        IF (x_chr_rec.attribute10 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute10 := l_chr_rec.attribute10;
        END IF;
        IF (x_chr_rec.attribute11 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute11 := l_chr_rec.attribute11;
        END IF;
        IF (x_chr_rec.attribute12 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute12 := l_chr_rec.attribute12;
        END IF;
        IF (x_chr_rec.attribute13 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute13 := l_chr_rec.attribute13;
        END IF;
        IF (x_chr_rec.attribute14 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute14 := l_chr_rec.attribute14;
        END IF;
        IF (x_chr_rec.attribute15 = OKC_API.G_MISS_CHAR)
            THEN
            x_chr_rec.attribute15 := l_chr_rec.attribute15;
        END IF;
      -- new  columns to replace rules
        IF (x_chr_rec.conversion_type = OKC_API.G_MISS_CHAR) THEN
            x_chr_rec.conversion_type := l_chr_rec.conversion_type;
        END IF;
        IF (x_chr_rec.conversion_rate = OKC_API.G_MISS_NUM) THEN
            x_chr_rec.conversion_rate := l_chr_rec.conversion_rate;
        END IF;
        IF (x_chr_rec.conversion_rate_date = OKC_API.G_MISS_DATE) THEN
            x_chr_rec.conversion_rate_date := l_chr_rec.conversion_rate_date;
        END IF;
        IF (x_chr_rec.conversion_euro_rate = OKC_API.G_MISS_NUM) THEN
            x_chr_rec.conversion_euro_rate := l_chr_rec.conversion_euro_rate;
        END IF;
        IF (x_chr_rec.cust_acct_id = OKC_API.G_MISS_NUM) THEN
            x_chr_rec.cust_acct_id := l_chr_rec.cust_acct_id;
        END IF;
        IF (x_chr_rec.bill_to_site_use_id = OKC_API.G_MISS_NUM) THEN
            x_chr_rec.bill_to_site_use_id := l_chr_rec.bill_to_site_use_id;
        END IF;
        IF (x_chr_rec.inv_rule_id = OKC_API.G_MISS_NUM) THEN
            x_chr_rec.inv_rule_id := l_chr_rec.inv_rule_id;
        END IF;
        IF (x_chr_rec.renewal_type_code = OKC_API.G_MISS_CHAR) THEN
            x_chr_rec.renewal_type_code := l_chr_rec.renewal_type_code;
        END IF;
        IF (x_chr_rec.renewal_notify_to = OKC_API.G_MISS_NUM) THEN
            x_chr_rec.renewal_notify_to := l_chr_rec.renewal_notify_to;
        END IF;
        IF (x_chr_rec.renewal_end_date = OKC_API.G_MISS_DATE) THEN
            x_chr_rec.renewal_end_date := l_chr_rec.renewal_end_date;
        END IF;
        IF (x_chr_rec.ship_to_site_use_id = OKC_API.G_MISS_NUM) THEN
            x_chr_rec.ship_to_site_use_id := l_chr_rec.ship_to_site_use_id;
        END IF;
        IF (x_chr_rec.payment_term_id = OKC_API.G_MISS_NUM) THEN
            x_chr_rec.payment_term_id := l_chr_rec.payment_term_id;
        END IF;

-- R12 Data Model Changes 4485150 Start
        IF (x_chr_rec.approval_type = OKC_API.G_MISS_CHAR) THEN
            x_chr_rec.approval_type := l_chr_rec.approval_type;
        END IF;
        IF (x_chr_rec.term_cancel_source = OKC_API.G_MISS_CHAR) THEN
            x_chr_rec.term_cancel_source := l_chr_rec.term_cancel_source;
        END IF;
        IF (x_chr_rec.payment_instruction_type = OKC_API.G_MISS_CHAR) THEN
            x_chr_rec.payment_instruction_type := l_chr_rec.payment_instruction_type;
        END IF;
	   -- LLC
	   IF (x_chr_rec.cancelled_amount = OKC_API.G_MISS_NUM) THEN
	   	  x_chr_rec.cancelled_amount := l_chr_rec.cancelled_amount;
	   END IF;
-- R12 Data Model Changes 4485150 End
        RETURN(l_return_status);

    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_K_HEADERS_ALL_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
                             p_chr_rec IN chr_rec_type,
                             x_chr_rec OUT NOCOPY chr_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('18700: Entered Set_Attributes', 2);
        END IF;

        x_chr_rec := p_chr_rec;
        RETURN(l_return_status);

    END Set_Attributes;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('18800: Entered update_row', 2);
        END IF;

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
                                          p_chr_rec,  -- IN
                                          l_chr_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := populate_new_record(l_chr_rec, l_def_chr_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        UPDATE  OKC_K_HEADERS_ALL_B --mmadhavi changed to _ALL for MOAC
        SET CONTRACT_NUMBER = l_def_chr_rec.contract_number,
        --AUTHORING_ORG_ID = l_def_chr_rec.authoring_org_id,
          CONTRACT_NUMBER_MODIFIER = l_def_chr_rec.contract_number_modifier,
          CHR_ID_RESPONSE = l_def_chr_rec.chr_id_response,
          CHR_ID_AWARD = l_def_chr_rec.chr_id_award,
        --INV_ORGANIZATION_ID = l_def_chr_rec.INV_ORGANIZATION_ID,
          STS_CODE = l_def_chr_rec.sts_code,
          QCL_ID = l_def_chr_rec.qcl_id,
        --SCS_CODE = l_def_chr_rec.scs_code,
          TRN_CODE = l_def_chr_rec.trn_code,
          CURRENCY_CODE = l_def_chr_rec.currency_code,
          ARCHIVED_YN = l_def_chr_rec.archived_yn,
          DELETED_YN = l_def_chr_rec.deleted_yn,
          TEMPLATE_YN = l_def_chr_rec.template_yn,
        --CHR_TYPE = l_def_chr_rec.chr_type,
          OBJECT_VERSION_NUMBER = l_def_chr_rec.object_version_number,
        --CREATED_BY = l_def_chr_rec.created_by,
        --CREATION_DATE = l_def_chr_rec.creation_date,
          LAST_UPDATED_BY = l_def_chr_rec.last_updated_by,
          LAST_UPDATE_DATE = l_def_chr_rec.last_update_date,
          CUST_PO_NUMBER_REQ_YN = l_def_chr_rec.cust_po_number_req_yn,
          PRE_PAY_REQ_YN = l_def_chr_rec.pre_pay_req_yn,
          CUST_PO_NUMBER = l_def_chr_rec.cust_po_number,
          DPAS_RATING = l_def_chr_rec.dpas_rating,
          TEMPLATE_USED = l_def_chr_rec.template_used,
          DATE_APPROVED = l_def_chr_rec.date_approved,
          DATETIME_CANCELLED = l_def_chr_rec.datetime_cancelled,
          AUTO_RENEW_DAYS = l_def_chr_rec.auto_renew_days,
          DATE_ISSUED = l_def_chr_rec.date_issued,
          DATETIME_RESPONDED = l_def_chr_rec.datetime_responded,
          RFP_TYPE = l_def_chr_rec.rfp_type,
          KEEP_ON_MAIL_LIST = l_def_chr_rec.keep_on_mail_list,
          SET_ASIDE_PERCENT = l_def_chr_rec.set_aside_percent,
          RESPONSE_COPIES_REQ = l_def_chr_rec.response_copies_req,
          DATE_CLOSE_PROJECTED = l_def_chr_rec.date_close_projected,
          DATETIME_PROPOSED = l_def_chr_rec.datetime_proposed,
          DATE_SIGNED = l_def_chr_rec.date_signed,
          DATE_TERMINATED = l_def_chr_rec.date_terminated,
          DATE_RENEWED = l_def_chr_rec.date_renewed,
          START_DATE = l_def_chr_rec.start_date,
          END_DATE = l_def_chr_rec.end_date,
          BUY_OR_SELL = l_def_chr_rec.buy_or_sell,
          ISSUE_OR_RECEIVE = l_def_chr_rec.issue_or_receive,
         ESTIMATED_AMOUNT = l_def_chr_rec.estimated_amount,
          ESTIMATED_AMOUNT_RENEWED = l_def_chr_rec.estimated_amount_renewed,
          CURRENCY_CODE_RENEWED = l_def_chr_rec.currency_code_renewed,
          LAST_UPDATE_LOGIN = l_def_chr_rec.last_update_login,
          UPG_ORIG_SYSTEM_REF = l_def_chr_rec.upg_orig_system_ref,
          UPG_ORIG_SYSTEM_REF_ID = l_def_chr_rec.upg_orig_system_ref_id,
--------APPLICATION_ID = l_def_chr_rec.application_id,
          ORIG_SYSTEM_SOURCE_CODE = l_def_chr_rec.orig_system_source_code,
          ORIG_SYSTEM_ID1 = l_def_chr_rec.orig_system_id1,
          ORIG_SYSTEM_REFERENCE1 = l_def_chr_rec.orig_system_reference1,
          PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID, - 1, NULL, FND_GLOBAL.CONC_PROGRAM_ID), l_def_chr_rec.program_id),
          REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID, - 1, NULL, FND_GLOBAL.CONC_REQUEST_ID), l_def_chr_rec.request_id),
          PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID, - 1, NULL, SYSDATE), NULL, l_def_chr_rec.program_update_date, SYSDATE),
          PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID, - 1, NULL, FND_GLOBAL.PROG_APPL_ID), l_def_chr_rec.program_application_id),
          PRICE_LIST_ID = l_def_chr_rec.price_list_id,
          PRICING_DATE = l_def_chr_rec.pricing_date,
          SIGN_BY_DATE = l_def_chr_rec.sign_by_date,
          TOTAL_LINE_LIST_PRICE = l_def_chr_rec.total_line_list_price,
         USER_ESTIMATED_AMOUNT = l_def_chr_rec.user_estimated_amount,
         GOVERNING_CONTRACT_YN = l_def_chr_rec.governing_contract_yn,
          ATTRIBUTE_CATEGORY = l_def_chr_rec.attribute_category,
          ATTRIBUTE1 = l_def_chr_rec.attribute1,
          ATTRIBUTE2 = l_def_chr_rec.attribute2,
          ATTRIBUTE3 = l_def_chr_rec.attribute3,
          ATTRIBUTE4 = l_def_chr_rec.attribute4,
          ATTRIBUTE5 = l_def_chr_rec.attribute5,
          ATTRIBUTE6 = l_def_chr_rec.attribute6,
          ATTRIBUTE7 = l_def_chr_rec.attribute7,
          ATTRIBUTE8 = l_def_chr_rec.attribute8,
          ATTRIBUTE9 = l_def_chr_rec.attribute9,
          ATTRIBUTE10 = l_def_chr_rec.attribute10,
          ATTRIBUTE11 = l_def_chr_rec.attribute11,
          ATTRIBUTE12 = l_def_chr_rec.attribute12,
          ATTRIBUTE13 = l_def_chr_rec.attribute13,
          ATTRIBUTE14 = l_def_chr_rec.attribute14,
          ATTRIBUTE15 = l_def_chr_rec.attribute15,
--new columns to replace rules
          conversion_type = l_def_chr_rec. conversion_type,
          conversion_rate = l_def_chr_rec. conversion_rate,
          conversion_rate_date = l_def_chr_rec. conversion_rate_date,
          conversion_euro_rate = l_def_chr_rec. conversion_euro_rate,
          cust_acct_id = l_def_chr_rec.cust_acct_id,
          bill_to_site_use_id = l_def_chr_rec.bill_to_site_use_id,
          inv_rule_id = l_def_chr_rec.inv_rule_id,
          renewal_type_code = l_def_chr_rec.renewal_type_code,
          renewal_notify_to = l_def_chr_rec.renewal_notify_to,
          renewal_end_date = l_def_chr_rec.renewal_end_date,
          ship_to_site_use_id = l_def_chr_rec.ship_to_site_use_id,
          payment_term_id = l_def_chr_rec.payment_term_id,
-- R12 Data Model Changes 4485150 End
          approval_type = l_def_chr_rec.approval_type,
          term_cancel_source = l_def_chr_rec.term_cancel_source,
          payment_instruction_type = l_def_chr_rec.payment_instruction_type,
		cancelled_amount = l_def_chr_rec.cancelled_amount -- LLC
-- R12 Data Model Changes 4485150 End
        WHERE ID = l_def_chr_rec.id;

        x_chr_rec := l_def_chr_rec;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('18900: Exiting update_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('19000: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('19100: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('19200: Exiting update_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  -------------------------------------
  -- update_row for:OKC_K_HEADERS_TL --
  -------------------------------------
    PROCEDURE update_row(
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type,
                         x_okc_k_headers_tl_rec OUT NOCOPY okc_k_headers_tl_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_headers_tl_rec okc_k_headers_tl_rec_type := p_okc_k_headers_tl_rec;
    l_def_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    l_row_notfound BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
                                  p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type,
                                  x_okc_k_headers_tl_rec OUT NOCOPY okc_k_headers_tl_rec_type
                                  ) RETURN VARCHAR2 IS
    l_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    l_row_notfound BOOLEAN := TRUE;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('19300: Entered populate_new_record', 2);
        END IF;

        x_okc_k_headers_tl_rec := p_okc_k_headers_tl_rec;
      -- Get current database values
        l_okc_k_headers_tl_rec := get_rec(p_okc_k_headers_tl_rec, l_row_notfound);
        IF (l_row_notfound) THEN
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END IF;
        IF (x_okc_k_headers_tl_rec.id = OKC_API.G_MISS_NUM)
            THEN
            x_okc_k_headers_tl_rec.id := l_okc_k_headers_tl_rec.id;
        END IF;
        IF (x_okc_k_headers_tl_rec.language = OKC_API.G_MISS_CHAR)
            THEN
            x_okc_k_headers_tl_rec.language := l_okc_k_headers_tl_rec.language;
        END IF;
        IF (x_okc_k_headers_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
            THEN
            x_okc_k_headers_tl_rec.source_lang := l_okc_k_headers_tl_rec.source_lang;
        END IF;
        IF (x_okc_k_headers_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
            THEN
            x_okc_k_headers_tl_rec.sfwt_flag := l_okc_k_headers_tl_rec.sfwt_flag;
        END IF;
        IF (x_okc_k_headers_tl_rec.short_description = OKC_API.G_MISS_CHAR)
            THEN
            x_okc_k_headers_tl_rec.short_description := l_okc_k_headers_tl_rec.short_description;
        END IF;
        IF (x_okc_k_headers_tl_rec.comments = OKC_API.G_MISS_CHAR)
            THEN
            x_okc_k_headers_tl_rec.comments := l_okc_k_headers_tl_rec.comments;
        END IF;
        IF (x_okc_k_headers_tl_rec.description = OKC_API.G_MISS_CHAR)
            THEN
            x_okc_k_headers_tl_rec.description := l_okc_k_headers_tl_rec.description;
        END IF;
        IF (x_okc_k_headers_tl_rec.cognomen = OKC_API.G_MISS_CHAR)
            THEN
            x_okc_k_headers_tl_rec.cognomen := l_okc_k_headers_tl_rec.cognomen;
        END IF;
        IF (x_okc_k_headers_tl_rec.non_response_reason = OKC_API.G_MISS_CHAR)
            THEN
            x_okc_k_headers_tl_rec.non_response_reason := l_okc_k_headers_tl_rec.non_response_reason;
        END IF;
        IF (x_okc_k_headers_tl_rec.non_response_explain = OKC_API.G_MISS_CHAR)
            THEN
            x_okc_k_headers_tl_rec.non_response_explain := l_okc_k_headers_tl_rec.non_response_explain;
        END IF;
        IF (x_okc_k_headers_tl_rec.set_aside_reason = OKC_API.G_MISS_CHAR)
            THEN
            x_okc_k_headers_tl_rec.set_aside_reason := l_okc_k_headers_tl_rec.set_aside_reason;
        END IF;
        IF (x_okc_k_headers_tl_rec.created_by = OKC_API.G_MISS_NUM)
            THEN
            x_okc_k_headers_tl_rec.created_by := l_okc_k_headers_tl_rec.created_by;
        END IF;
        IF (x_okc_k_headers_tl_rec.creation_date = OKC_API.G_MISS_DATE)
            THEN
            x_okc_k_headers_tl_rec.creation_date := l_okc_k_headers_tl_rec.creation_date;
        END IF;
        IF (x_okc_k_headers_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
            THEN
            x_okc_k_headers_tl_rec.last_updated_by := l_okc_k_headers_tl_rec.last_updated_by;
        END IF;
        IF (x_okc_k_headers_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
            THEN
            x_okc_k_headers_tl_rec.last_update_date := l_okc_k_headers_tl_rec.last_update_date;
        END IF;
        IF (x_okc_k_headers_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
            THEN
            x_okc_k_headers_tl_rec.last_update_login := l_okc_k_headers_tl_rec.last_update_login;
        END IF;
        RETURN(l_return_status);

    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_HEADERS_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
                             p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type,
                             x_okc_k_headers_tl_rec OUT NOCOPY okc_k_headers_tl_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('19400: Entered Set_Attributes', 2);
        END IF;

        x_okc_k_headers_tl_rec := p_okc_k_headers_tl_rec;
        x_okc_k_headers_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
        x_okc_k_headers_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
        RETURN(l_return_status);

    END Set_Attributes;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('19500: Entered update_row', 2);
        END IF;

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
                                          p_okc_k_headers_tl_rec,  -- IN
                                          l_okc_k_headers_tl_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := populate_new_record(l_okc_k_headers_tl_rec, l_def_okc_k_headers_tl_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        UPDATE  OKC_K_HEADERS_TL
        SET SHORT_DESCRIPTION = l_def_okc_k_headers_tl_rec.short_description,
            COMMENTS = l_def_okc_k_headers_tl_rec.comments,
            DESCRIPTION = l_def_okc_k_headers_tl_rec.description,
            COGNOMEN = l_def_okc_k_headers_tl_rec.cognomen,
            NON_RESPONSE_REASON = l_def_okc_k_headers_tl_rec.non_response_reason,
            NON_RESPONSE_EXPLAIN = l_def_okc_k_headers_tl_rec.non_response_explain,
            SET_ASIDE_REASON = l_def_okc_k_headers_tl_rec.set_aside_reason,
           SOURCE_LANG = l_def_okc_k_headers_tl_rec.source_lang,
        --CREATED_BY = l_def_okc_k_headers_tl_rec.created_by,
        --CREATION_DATE = l_def_okc_k_headers_tl_rec.creation_date,
            LAST_UPDATED_BY = l_def_okc_k_headers_tl_rec.last_updated_by,
            LAST_UPDATE_DATE = l_def_okc_k_headers_tl_rec.last_update_date,
            LAST_UPDATE_LOGIN = l_def_okc_k_headers_tl_rec.last_update_login
        WHERE ID = l_def_okc_k_headers_tl_rec.id
          AND USERENV('LANG')  IN (SOURCE_LANG, LANGUAGE);

        UPDATE  OKC_K_HEADERS_TL
        SET SFWT_FLAG = 'Y'
        WHERE ID = l_def_okc_k_headers_tl_rec.id
          AND SOURCE_LANG <> USERENV('LANG');

        x_okc_k_headers_tl_rec := l_def_okc_k_headers_tl_rec;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('19600: Exiting update_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('19700: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('19800: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('19900: Exiting update_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  ------------------------------------
  -- update_row for:OKC_K_HEADERS_V --
  ------------------------------------
    PROCEDURE update_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_restricted_update IN VARCHAR2,
                         p_chrv_rec IN chrv_rec_type,
                         x_chrv_rec OUT NOCOPY chrv_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chrv_rec chrv_rec_type := p_chrv_rec;
    l_def_chrv_rec chrv_rec_type;
    l_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    lx_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    l_chr_rec chr_rec_type;
    lx_chr_rec chr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
                               p_chrv_rec IN chrv_rec_type
                               ) RETURN chrv_rec_type IS
    l_chrv_rec chrv_rec_type := p_chrv_rec;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('20000: Entered fill_who_columns', 2);
        END IF;

        l_chrv_rec.LAST_UPDATE_DATE := SYSDATE;
        l_chrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_chrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_chrv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
                                  p_chrv_rec IN chrv_rec_type,
                                  x_chrv_rec OUT NOCOPY chrv_rec_type
                                  ) RETURN VARCHAR2 IS
    l_chrv_rec chrv_rec_type;
    l_row_notfound BOOLEAN := TRUE;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('20100: Entered populate_new_record', 2);
        END IF;

        x_chrv_rec := p_chrv_rec;
      -- Get current database values
        l_chrv_rec := get_rec(p_chrv_rec, l_row_notfound);
        IF (l_row_notfound) THEN
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END IF;
        IF (x_chrv_rec.id = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.id := l_chrv_rec.id;
        END IF;
        IF (x_chrv_rec.object_version_number = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.object_version_number := l_chrv_rec.object_version_number;
        END IF;
        IF (x_chrv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.sfwt_flag := l_chrv_rec.sfwt_flag;
        END IF;
        IF (x_chrv_rec.chr_id_response = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.chr_id_response := l_chrv_rec.chr_id_response;
        END IF;
        IF (x_chrv_rec.chr_id_award = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.chr_id_award := l_chrv_rec.chr_id_award;
        END IF;
        IF (x_chrv_rec.INV_ORGANIZATION_ID = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.INV_ORGANIZATION_ID := l_chrv_rec.INV_ORGANIZATION_ID;
        END IF;
        IF (x_chrv_rec.sts_code = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.sts_code := l_chrv_rec.sts_code;
        END IF;
        IF (x_chrv_rec.qcl_id = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.qcl_id := l_chrv_rec.qcl_id;
        END IF;
        IF (x_chrv_rec.scs_code = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.scs_code := l_chrv_rec.scs_code;
        END IF;
        IF (x_chrv_rec.contract_number = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.contract_number := l_chrv_rec.contract_number;
        END IF;
        IF (x_chrv_rec.currency_code = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.currency_code := l_chrv_rec.currency_code;
        END IF;
        IF (x_chrv_rec.contract_number_modifier = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.contract_number_modifier := l_chrv_rec.contract_number_modifier;
        END IF;
        IF (x_chrv_rec.archived_yn = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.archived_yn := l_chrv_rec.archived_yn;
        END IF;
        IF (x_chrv_rec.deleted_yn = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.deleted_yn := l_chrv_rec.deleted_yn;
        END IF;
        IF (x_chrv_rec.cust_po_number_req_yn = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.cust_po_number_req_yn := l_chrv_rec.cust_po_number_req_yn;
        END IF;
        IF (x_chrv_rec.pre_pay_req_yn = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.pre_pay_req_yn := l_chrv_rec.pre_pay_req_yn;
        END IF;
        IF (x_chrv_rec.cust_po_number = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.cust_po_number := l_chrv_rec.cust_po_number;
        END IF;
        IF (x_chrv_rec.short_description = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.short_description := l_chrv_rec.short_description;
        END IF;
        IF (x_chrv_rec.comments = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.comments := l_chrv_rec.comments;
        END IF;
        IF (x_chrv_rec.description = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.description := l_chrv_rec.description;
        END IF;
        IF (x_chrv_rec.dpas_rating = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.dpas_rating := l_chrv_rec.dpas_rating;
        END IF;
        IF (x_chrv_rec.cognomen = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.cognomen := l_chrv_rec.cognomen;
        END IF;
        IF (x_chrv_rec.template_yn = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.template_yn := l_chrv_rec.template_yn;
        END IF;
        IF (x_chrv_rec.template_used = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.template_used := l_chrv_rec.template_used;
        END IF;
        IF (x_chrv_rec.date_approved = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.date_approved := l_chrv_rec.date_approved;
        END IF;
        IF (x_chrv_rec.datetime_cancelled = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.datetime_cancelled := l_chrv_rec.datetime_cancelled;
        END IF;
        IF (x_chrv_rec.auto_renew_days = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.auto_renew_days := l_chrv_rec.auto_renew_days;
        END IF;
        IF (x_chrv_rec.date_issued = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.date_issued := l_chrv_rec.date_issued;
        END IF;
        IF (x_chrv_rec.datetime_responded = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.datetime_responded := l_chrv_rec.datetime_responded;
        END IF;
        IF (x_chrv_rec.non_response_reason = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.non_response_reason := l_chrv_rec.non_response_reason;
        END IF;
        IF (x_chrv_rec.non_response_explain = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.non_response_explain := l_chrv_rec.non_response_explain;
        END IF;
        IF (x_chrv_rec.rfp_type = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.rfp_type := l_chrv_rec.rfp_type;
        END IF;
        IF (x_chrv_rec.chr_type = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.chr_type := l_chrv_rec.chr_type;
        END IF;
        IF (x_chrv_rec.keep_on_mail_list = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.keep_on_mail_list := l_chrv_rec.keep_on_mail_list;
        END IF;
        IF (x_chrv_rec.set_aside_reason = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.set_aside_reason := l_chrv_rec.set_aside_reason;
        END IF;
        IF (x_chrv_rec.set_aside_percent = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.set_aside_percent := l_chrv_rec.set_aside_percent;
        END IF;
        IF (x_chrv_rec.response_copies_req = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.response_copies_req := l_chrv_rec.response_copies_req;
        END IF;
        IF (x_chrv_rec.date_close_projected = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.date_close_projected := l_chrv_rec.date_close_projected;
        END IF;
        IF (x_chrv_rec.datetime_proposed = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.datetime_proposed := l_chrv_rec.datetime_proposed;
        END IF;
        IF (x_chrv_rec.date_signed = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.date_signed := l_chrv_rec.date_signed;
        END IF;
        IF (x_chrv_rec.date_terminated = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.date_terminated := l_chrv_rec.date_terminated;
        END IF;
        IF (x_chrv_rec.date_renewed = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.date_renewed := l_chrv_rec.date_renewed;
        END IF;
        IF (x_chrv_rec.trn_code = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.trn_code := l_chrv_rec.trn_code;
        END IF;
        IF (x_chrv_rec.start_date = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.start_date := l_chrv_rec.start_date;
        END IF;
        IF (x_chrv_rec.end_date = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.end_date := l_chrv_rec.end_date;
        END IF;
        IF (x_chrv_rec.authoring_org_id = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.authoring_org_id := l_chrv_rec.authoring_org_id;
        END IF;
      --mmadhavi added for MOAC

        IF (x_chrv_rec.org_id = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.org_id := l_chrv_rec.org_id;
        END IF;

      --mmadhavi end MOAC
        IF (x_chrv_rec.buy_or_sell = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.buy_or_sell := l_chrv_rec.buy_or_sell;
        END IF;
        IF (x_chrv_rec.issue_or_receive = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.issue_or_receive := l_chrv_rec.issue_or_receive;
        END IF;
        IF (x_chrv_rec.estimated_amount = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.estimated_amount := l_chrv_rec.estimated_amount;
        END IF;
        IF (x_chrv_rec.estimated_amount_renewed = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.estimated_amount_renewed := l_chrv_rec.estimated_amount_renewed;
        END IF;
        IF (x_chrv_rec.currency_code_renewed = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.currency_code_renewed := l_chrv_rec.currency_code_renewed;
        END IF;
        IF (x_chrv_rec.upg_orig_system_ref = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.upg_orig_system_ref := l_chrv_rec.upg_orig_system_ref;
        END IF;
        IF (x_chrv_rec.upg_orig_system_ref_id = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.upg_orig_system_ref_id := l_chrv_rec.upg_orig_system_ref_id;
        END IF;
        IF (x_chrv_rec.application_id = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.application_id := l_chrv_rec.application_id;
        END IF;
        IF (x_chrv_rec.orig_system_source_code = OKC_API.G_MISS_CHAR )
            THEN
            x_chrv_rec.orig_system_source_code := l_chrv_rec.orig_system_source_code ;
        END IF;
        IF (x_chrv_rec.orig_system_id1 = OKC_API.G_MISS_NUM )
            THEN
            x_chrv_rec.orig_system_id1 := l_chrv_rec.orig_system_id1 ;
        END IF;
        IF (x_chrv_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR )
            THEN
            x_chrv_rec.orig_system_reference1 := l_chrv_rec.orig_system_reference1 ;
        END IF ;
        IF (x_chrv_rec.program_id = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.program_id := l_chrv_rec.program_id;
        END IF;
        IF (x_chrv_rec.request_id = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.request_id := l_chrv_rec.request_id;
        END IF;
        IF (x_chrv_rec.program_update_date = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.program_update_date := l_chrv_rec.program_update_date;
        END IF;
        IF (x_chrv_rec.program_application_id = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.program_application_id := l_chrv_rec.program_application_id;
        END IF;
        IF (x_chrv_rec.price_list_id = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.price_list_id := l_chrv_rec.price_list_id;
        END IF;
        IF (x_chrv_rec.pricing_date = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.pricing_date := l_chrv_rec.pricing_date;
        END IF;
        IF (x_chrv_rec.sign_by_date = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.sign_by_date := l_chrv_rec.sign_by_date;
        END IF;
        IF (x_chrv_rec.total_line_list_price = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.total_line_list_price := l_chrv_rec.total_line_list_price;
        END IF;
        IF (x_chrv_rec.user_estimated_amount = OKC_API.G_MISS_NUM) THEN
            x_chrv_rec.user_estimated_amount := l_chrv_rec.user_estimated_amount;
        END IF;
        IF (x_chrv_rec.governing_contract_yn = OKC_API.G_MISS_CHAR) THEN
            x_chrv_rec.governing_contract_yn := l_chrv_rec.governing_contract_yn;
        END IF;
        IF (x_chrv_rec.attribute_category = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute_category := l_chrv_rec.attribute_category;
        END IF;
        IF (x_chrv_rec.attribute1 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute1 := l_chrv_rec.attribute1;
        END IF;
        IF (x_chrv_rec.attribute2 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute2 := l_chrv_rec.attribute2;
        END IF;
        IF (x_chrv_rec.attribute3 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute3 := l_chrv_rec.attribute3;
        END IF;
        IF (x_chrv_rec.attribute4 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute4 := l_chrv_rec.attribute4;
        END IF;
        IF (x_chrv_rec.attribute5 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute5 := l_chrv_rec.attribute5;
        END IF;
        IF (x_chrv_rec.attribute6 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute6 := l_chrv_rec.attribute6;
        END IF;
        IF (x_chrv_rec.attribute7 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute7 := l_chrv_rec.attribute7;
        END IF;
        IF (x_chrv_rec.attribute8 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute8 := l_chrv_rec.attribute8;
        END IF;
        IF (x_chrv_rec.attribute9 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute9 := l_chrv_rec.attribute9;
        END IF;
        IF (x_chrv_rec.attribute10 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute10 := l_chrv_rec.attribute10;
        END IF;
        IF (x_chrv_rec.attribute11 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute11 := l_chrv_rec.attribute11;
        END IF;
        IF (x_chrv_rec.attribute12 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute12 := l_chrv_rec.attribute12;
        END IF;
        IF (x_chrv_rec.attribute13 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute13 := l_chrv_rec.attribute13;
        END IF;
        IF (x_chrv_rec.attribute14 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute14 := l_chrv_rec.attribute14;
        END IF;
        IF (x_chrv_rec.attribute15 = OKC_API.G_MISS_CHAR)
            THEN
            x_chrv_rec.attribute15 := l_chrv_rec.attribute15;
        END IF;
        IF (x_chrv_rec.created_by = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.created_by := l_chrv_rec.created_by;
        END IF;
        IF (x_chrv_rec.creation_date = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.creation_date := l_chrv_rec.creation_date;
        END IF;
        IF (x_chrv_rec.last_updated_by = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.last_updated_by := l_chrv_rec.last_updated_by;
        END IF;
        IF (x_chrv_rec.last_update_date = OKC_API.G_MISS_DATE)
            THEN
            x_chrv_rec.last_update_date := l_chrv_rec.last_update_date;
        END IF;
        IF (x_chrv_rec.last_update_login = OKC_API.G_MISS_NUM)
            THEN
            x_chrv_rec.last_update_login := l_chrv_rec.last_update_login;
        END IF;
            -- new  columns to replace rules
        IF (x_chrv_rec.conversion_type = OKC_API.G_MISS_CHAR) THEN
            x_chrv_rec.conversion_type := l_chrv_rec.conversion_type;
        END IF;
        IF (x_chrv_rec.conversion_rate = OKC_API.G_MISS_NUM) THEN
            x_chrv_rec.conversion_rate := l_chrv_rec.conversion_rate;
        END IF;
        IF (x_chrv_rec.conversion_rate_date = OKC_API.G_MISS_DATE) THEN
            x_chrv_rec.conversion_rate_date := l_chrv_rec.conversion_rate_date;
        END IF;
        IF (x_chrv_rec.conversion_euro_rate = OKC_API.G_MISS_NUM) THEN
            x_chrv_rec.conversion_euro_rate := l_chrv_rec.conversion_euro_rate;
        END IF;
        IF (x_chrv_rec.cust_acct_id = OKC_API.G_MISS_NUM) THEN
            x_chrv_rec.cust_acct_id := l_chrv_rec.cust_acct_id;
        END IF;
        IF (x_chrv_rec.bill_to_site_use_id = OKC_API.G_MISS_NUM) THEN
            x_chrv_rec.bill_to_site_use_id := l_chrv_rec.bill_to_site_use_id;
        END IF;
        IF (x_chrv_rec.inv_rule_id = OKC_API.G_MISS_NUM) THEN
            x_chrv_rec.inv_rule_id := l_chrv_rec.inv_rule_id;
        END IF;
        IF (x_chrv_rec.renewal_type_code = OKC_API.G_MISS_CHAR) THEN
            x_chrv_rec.renewal_type_code := l_chrv_rec.renewal_type_code;
        END IF;
        IF (x_chrv_rec.renewal_notify_to = OKC_API.G_MISS_NUM) THEN
            x_chrv_rec.renewal_notify_to := l_chrv_rec.renewal_notify_to;
        END IF;
        IF (x_chrv_rec.renewal_end_date = OKC_API.G_MISS_DATE) THEN
            x_chrv_rec.renewal_end_date := l_chrv_rec.renewal_end_date;
        END IF;
        IF (x_chrv_rec.ship_to_site_use_id = OKC_API.G_MISS_NUM) THEN
            x_chrv_rec.ship_to_site_use_id := l_chrv_rec.ship_to_site_use_id;
        END IF;
        IF (x_chrv_rec.payment_term_id = OKC_API.G_MISS_NUM) THEN
            x_chrv_rec.payment_term_id := l_chrv_rec.payment_term_id;
        END IF;
        IF (x_chrv_rec.document_id = OKC_API.G_MISS_NUM) THEN
            x_chrv_rec.document_id := l_chrv_rec.document_id;
        END IF;
-- R12 Data Model Changes 4485150 Start
        IF (x_chrv_rec.approval_type = OKC_API.G_MISS_CHAR) THEN
            x_chrv_rec.approval_type := l_chrv_rec.approval_type;
        END IF;
        IF (x_chrv_rec.term_cancel_source = OKC_API.G_MISS_CHAR) THEN
            x_chrv_rec.term_cancel_source := l_chrv_rec.term_cancel_source;
        END IF;
        IF (x_chrv_rec.payment_instruction_type = OKC_API.G_MISS_CHAR) THEN
            x_chrv_rec.payment_instruction_type := l_chrv_rec.payment_instruction_type;
        END IF;
	   -- LLC
	   IF (x_chrv_rec.cancelled_amount = OKC_API.G_MISS_NUM) THEN
	   	  x_chrv_rec.cancelled_amount := l_chrv_rec.cancelled_amount;
	   END IF;
-- R12 Data Model Changes 4485150 End

        RETURN(l_return_status);

    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_K_HEADERS_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
                             p_chrv_rec IN chrv_rec_type,
                             x_chrv_rec OUT NOCOPY chrv_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('20200: Entered Set_Attributes', 2);
        END IF;

        x_chrv_rec := p_chrv_rec;
        x_chrv_rec.OBJECT_VERSION_NUMBER := NVL(x_chrv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      /************************ HAND-CODED *********************************/
        x_chrv_rec.SFWT_FLAG := UPPER(x_chrv_rec.SFWT_FLAG);
        x_chrv_rec.ARCHIVED_YN := UPPER(x_chrv_rec.ARCHIVED_YN);
        x_chrv_rec.DELETED_YN := UPPER(x_chrv_rec.DELETED_YN);
        x_chrv_rec.CUST_PO_NUMBER_REQ_YN := UPPER(x_chrv_rec.CUST_PO_NUMBER_REQ_YN);
        x_chrv_rec.PRE_PAY_REQ_YN := UPPER(x_chrv_rec.PRE_PAY_REQ_YN);
        x_chrv_rec.TEMPLATE_YN := UPPER(x_chrv_rec.TEMPLATE_YN);
        x_chrv_rec.KEEP_ON_MAIL_LIST := UPPER(x_chrv_rec.KEEP_ON_MAIL_LIST);
        x_chrv_rec.CHR_TYPE := UPPER(x_chrv_rec.CHR_TYPE);

	 -- If contract is cancelled, update datetime_cancelled
        IF (Get_Status_Type(x_chrv_rec.STS_CODE) = 'CANCELLED' AND
            (x_chrv_rec.datetime_cancelled = OKC_API.G_MISS_DATE OR
             x_chrv_rec.datetime_cancelled IS NULL) )
            THEN
            x_chrv_rec.datetime_cancelled := SYSDATE;
        END IF;
      /*********************** END HAND-CODED ********************************/
        RETURN(l_return_status);

    END Set_Attributes;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('20300: Entered update_row', 2);
        END IF;

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
                                          p_chrv_rec,  -- IN
                                          l_chrv_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := populate_new_record(l_chrv_rec, l_def_chrv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_def_chrv_rec := fill_who_columns(l_def_chrv_rec);

        IF p_chrv_rec.VALIDATE_YN = 'Y' THEN ---Bug#3150149
       --- Validate all non-missing attributes (Item Level Validation)
       -- No validation if the status changes from ENTERED -> CANCELED
            IF (NVL(p_chrv_rec.new_ste_code, 'x') <> 'CANCELLED') THEN
                l_return_status := Validate_Attributes(l_def_chrv_rec);
            END IF;
        END IF; ---Bug#3150149.

    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := Validate_Record(l_def_chrv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
        migrate(l_def_chrv_rec, l_okc_k_headers_tl_rec);
        migrate(l_def_chrv_rec, l_chr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
        update_row(
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_okc_k_headers_tl_rec,
                   lx_okc_k_headers_tl_rec
                   );
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        migrate(lx_okc_k_headers_tl_rec, l_def_chrv_rec);
        update_row(
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   p_restricted_update,
                   l_chr_rec,
                   lx_chr_rec
                   );
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        migrate(lx_chr_rec, l_def_chrv_rec);
        x_chrv_rec := l_def_chrv_rec;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('20400: Exiting update_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('20500: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('20600: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('20700: Exiting update_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  -- PL/SQL TBL update_row for:CHRV_TBL --
  ----------------------------------------
    PROCEDURE update_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_restricted_update IN VARCHAR2,
                         p_chrv_tbl IN chrv_tbl_type,
                         x_chrv_tbl OUT NOCOPY chrv_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('20800: Entered update_row', 2);
        END IF;

        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_chrv_tbl.COUNT > 0) THEN
            i := p_chrv_tbl.FIRST;
            LOOP
                update_row (
                            p_api_version => p_api_version,
                            p_init_msg_list => OKC_API.G_FALSE,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data,
                            p_restricted_update => p_restricted_update,
                            p_chrv_rec => p_chrv_tbl(i),
                            x_chrv_rec => x_chrv_tbl(i));

		-- store the highest degree of error
                IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := x_return_status;
                    END IF;
                END IF;

                EXIT WHEN (i = p_chrv_tbl.LAST);
                i := p_chrv_tbl.NEXT(i);
            END LOOP;
	 -- return overall status
            x_return_status := l_overall_status;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('20900: Exiting update_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('21000: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('21100: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('21200: Exiting update_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  ------------------------------------
  -- delete_row for:OKC_K_HEADERS_ALL_B --
  ------------------------------------
    PROCEDURE delete_row(
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_chr_rec IN chr_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chr_rec chr_rec_type := p_chr_rec;
    l_row_notfound BOOLEAN := TRUE;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('21300: Entered delete_row', 2);
        END IF;

        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  p_init_msg_list,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        DELETE FROM OKC_K_HEADERS_ALL_B --mmadhavi changed to _ALL for MOAC
         WHERE ID = l_chr_rec.id;

        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('21400: Exiting delete_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('21500: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('21600: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('21700: Exiting delete_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  -------------------------------------
  -- delete_row for:OKC_K_HEADERS_TL --
  -------------------------------------
    PROCEDURE delete_row(
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_headers_tl_rec okc_k_headers_tl_rec_type := p_okc_k_headers_tl_rec;
    l_row_notfound BOOLEAN := TRUE;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_HEADERS_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
                             p_okc_k_headers_tl_rec IN okc_k_headers_tl_rec_type,
                             x_okc_k_headers_tl_rec OUT NOCOPY okc_k_headers_tl_rec_type
                             ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('21800: Entered Set_Attributes', 2);
        END IF;

        x_okc_k_headers_tl_rec := p_okc_k_headers_tl_rec;
        x_okc_k_headers_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
        RETURN(l_return_status);

    END Set_Attributes;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('21900: Entered delete_row', 2);
        END IF;

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
                                          p_okc_k_headers_tl_rec,  -- IN
                                          l_okc_k_headers_tl_rec); -- OUT
    --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        DELETE FROM OKC_K_HEADERS_TL
         WHERE ID = l_okc_k_headers_tl_rec.id;

        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('22000: Exiting delete_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('22100: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('22200: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('22300: Exiting delete_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  ------------------------------------
  -- delete_row for:OKC_K_HEADERS_V --
  ------------------------------------
    PROCEDURE delete_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_chrv_rec IN chrv_rec_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chrv_rec chrv_rec_type := p_chrv_rec;
    l_okc_k_headers_tl_rec okc_k_headers_tl_rec_type;
    l_chr_rec chr_rec_type;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('22400: Entered delete_row', 2);
        END IF;

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
        migrate(l_chrv_rec, l_okc_k_headers_tl_rec);
        migrate(l_chrv_rec, l_chr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
        delete_row(
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_okc_k_headers_tl_rec
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
                   l_chr_rec
                   );
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('22500: Exiting delete_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('22600: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('22700: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('22800: Exiting delete_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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
  ----------------------------------------
  -- PL/SQL TBL delete_row for:CHRV_TBL --
  ----------------------------------------
    PROCEDURE delete_row(
                         p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_chrv_tbl IN chrv_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
    l_dummy_val NUMBER;
    CURSOR l_clev_csr IS
        SELECT COUNT(1)
        FROM OKC_K_LINES_B
        WHERE chr_id = p_chrv_tbl(i).id;
    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('22900: Entered delete_row', 2);
        END IF;

        OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
        IF (p_chrv_tbl.COUNT > 0) THEN
            i := p_chrv_tbl.FIRST;
            LOOP
		/************************ HAND-CODED ***************************/
    		-- check whether detail records exists
                OPEN l_clev_csr;
                FETCH l_clev_csr INTO l_dummy_val;
                CLOSE l_clev_csr;

    		-- delete only if there are no detail records
                IF (l_dummy_val = 0) THEN
                    delete_row (
                                p_api_version => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                p_chrv_rec => p_chrv_tbl(i));

				-- store the highest degree of error
                    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                        IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                            l_overall_status := x_return_status;
                        END IF;
                    END IF;
                ELSE
                    OKC_API.SET_MESSAGE(
                                        p_app_name => g_app_name,
                                        p_msg_name => G_CHILD_RECORD_EXISTS);
	    		-- notify caller of an error
                    x_return_status := OKC_API.G_RET_STS_ERROR;

		     -- store the highest degree of error
                    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := x_return_status;
                    END IF;

                END IF;
		/*********************** END HAND-CODED ************************/

                EXIT WHEN (i = p_chrv_tbl.LAST);
                i := p_chrv_tbl.NEXT(i);
            END LOOP;
	 -- return overall status
            x_return_status := l_overall_status;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('23000: Exiting delete_row', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('23100: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('23200: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('23300: Exiting delete_row:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

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

---------------------------------------------------------------
-- Procedure for mass insert in OKC_K_HEADERS _B and TL tables
---------------------------------------------------------------
    PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_chrv_tbl chrv_tbl_type) IS
    l_tabsize NUMBER := p_chrv_tbl.COUNT;
    l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

    in_id OKC_DATATYPES.NumberTabTyp;
    in_object_version_number OKC_DATATYPES.NumberTabTyp;
    in_sfwt_flag OKC_DATATYPES.Var3TabTyp;
    in_chr_id_response OKC_DATATYPES.NumberTabTyp;
    in_chr_id_award OKC_DATATYPES.NumberTabTyp;
    in_inv_organization_id OKC_DATATYPES.NumberTabTyp;
    in_sts_code OKC_DATATYPES.Var30TabTyp;
    in_qcl_id OKC_DATATYPES.NumberTabTyp;
    in_scs_code OKC_DATATYPES.Var30TabTyp;
    in_contract_number OKC_DATATYPES.Var120TabTyp;
    in_currency_code OKC_DATATYPES.Var15TabTyp;
    in_contract_number_modifier OKC_DATATYPES.Var120TabTyp;
    in_archived_yn OKC_DATATYPES.Var3TabTyp;
    in_deleted_yn OKC_DATATYPES.Var3TabTyp;
    in_cust_po_number_req_yn OKC_DATATYPES.Var3TabTyp;
    in_pre_pay_req_yn OKC_DATATYPES.Var3TabTyp;
    in_cust_po_number OKC_DATATYPES.Var150TabTyp;
    in_short_description OKC_DATATYPES.Var600TabTyp;
    in_comments OKC_DATATYPES.Var1995TabTyp;
    in_description OKC_DATATYPES.Var1995TabTyp;
    in_dpas_rating OKC_DATATYPES.Var24TabTyp;
    in_cognomen OKC_DATATYPES.Var300TabTyp;
    in_template_yn OKC_DATATYPES.Var3TabTyp;
    in_template_used OKC_DATATYPES.Var120TabTyp;
    in_date_approved OKC_DATATYPES.DateTabTyp;
    in_datetime_cancelled OKC_DATATYPES.DateTabTyp;
    in_auto_renew_days OKC_DATATYPES.NumberTabTyp;
    in_date_issued OKC_DATATYPES.DateTabTyp;
    in_datetime_responded OKC_DATATYPES.DateTabTyp;
    in_non_response_reason OKC_DATATYPES.Var3TabTyp;
    in_non_response_explain OKC_DATATYPES.Var1995TabTyp;
    in_rfp_type OKC_DATATYPES.Var30TabTyp;
    in_chr_type OKC_DATATYPES.Var30TabTyp;
    in_keep_on_mail_list OKC_DATATYPES.Var3TabTyp;
    in_set_aside_reason OKC_DATATYPES.Var3TabTyp;
    in_set_aside_percent OKC_DATATYPES.NumberTabTyp;
    in_response_copies_req OKC_DATATYPES.NumberTabTyp;
    in_date_close_projected OKC_DATATYPES.DateTabTyp;
    in_datetime_proposed OKC_DATATYPES.DateTabTyp;
    in_date_signed OKC_DATATYPES.DateTabTyp;
    in_date_terminated OKC_DATATYPES.DateTabTyp;
    in_date_renewed OKC_DATATYPES.DateTabTyp;
    in_trn_code OKC_DATATYPES.Var30TabTyp;
    in_start_date OKC_DATATYPES.DateTabTyp;
    in_end_date OKC_DATATYPES.DateTabTyp;
    in_authoring_org_id OKC_DATATYPES.NumberTabTyp;
    in_org_id OKC_DATATYPES.NumberTabTyp; --mmadhavi added for MOAC
    in_buy_or_sell OKC_DATATYPES.Var3TabTyp;
    in_issue_or_receive OKC_DATATYPES.Var3TabTyp;
    in_estimated_amount OKC_DATATYPES.NumberTabTyp;
    in_estimated_amount_renewed OKC_DATATYPES.NumberTabTyp;
    in_currency_code_renewed OKC_DATATYPES.Var15TabTyp;
    in_upg_orig_system_ref OKC_DATATYPES.Var75TabTyp;
    in_upg_orig_system_ref_id OKC_DATATYPES.NumberTabTyp;
    in_application_id OKC_DATATYPES.NumberTabTyp;
    in_orig_system_source_code OKC_DATATYPES.Var30TabTyp;
    in_orig_system_id1 OKC_DATATYPES.NumberTabTyp;
    in_orig_system_reference1 OKC_DATATYPES.Var30TabTyp;
    in_program_id OKC_DATATYPES.NumberTabTyp;
    in_request_id OKC_DATATYPES.NumberTabTyp;
    in_program_update_date OKC_DATATYPES.DateTabTyp;
    in_program_application_id OKC_DATATYPES.NumberTabTyp;
    in_price_list_id OKC_DATATYPES.NumberTabTyp;
    in_pricing_date OKC_DATATYPES.DateTabTyp;
    in_sign_by_date OKC_DATATYPES.DateTabTyp;
    in_total_line_list_price OKC_DATATYPES.NumberTabTyp;
    in_user_estimated_amount OKC_DATATYPES.NumberTabTyp;
    in_governing_contract_yn OKC_DATATYPES.Var3TabTyp;
  --new columns to replace rules
    in_conversion_type OKC_DATATYPES.Var30TabTyp;
    in_conversion_rate OKC_DATATYPES.NumberTabTyp;
    in_conversion_rate_date OKC_DATATYPES.DateTabTyp;
    in_conversion_euro_rate OKC_DATATYPES.NumberTabTyp;
    in_cust_acct_id OKC_DATATYPES.Number15TabTyp;
    in_bill_to_site_use_id OKC_DATATYPES.Number15TabTyp;
    in_inv_rule_id OKC_DATATYPES.Number15TabTyp;
    in_renewal_type_code OKC_DATATYPES.Var30TabTyp;
    in_renewal_notify_to OKC_DATATYPES.NumberTabTyp;
    in_renewal_end_date OKC_DATATYPES.DateTabTyp;
    in_ship_to_site_use_id OKC_DATATYPES.Number15TabTyp;
    in_payment_term_id OKC_DATATYPES.Number15TabTyp;
--
    in_attribute_category OKC_DATATYPES.Var90TabTyp;
    in_attribute1 OKC_DATATYPES.Var450TabTyp;
    in_attribute2 OKC_DATATYPES.Var450TabTyp;
    in_attribute3 OKC_DATATYPES.Var450TabTyp;
    in_attribute4 OKC_DATATYPES.Var450TabTyp;
    in_attribute5 OKC_DATATYPES.Var450TabTyp;
    in_attribute6 OKC_DATATYPES.Var450TabTyp;
    in_attribute7 OKC_DATATYPES.Var450TabTyp;
    in_attribute8 OKC_DATATYPES.Var450TabTyp;
    in_attribute9 OKC_DATATYPES.Var450TabTyp;
    in_attribute10 OKC_DATATYPES.Var450TabTyp;
    in_attribute11 OKC_DATATYPES.Var450TabTyp;
    in_attribute12 OKC_DATATYPES.Var450TabTyp;
    in_attribute13 OKC_DATATYPES.Var450TabTyp;
    in_attribute14 OKC_DATATYPES.Var450TabTyp;
    in_attribute15 OKC_DATATYPES.Var450TabTyp;
    in_created_by OKC_DATATYPES.NumberTabTyp;
    in_creation_date OKC_DATATYPES.DateTabTyp;
    in_last_updated_by OKC_DATATYPES.NumberTabTyp;
    in_last_update_date OKC_DATATYPES.DateTabTyp;
    in_last_update_login OKC_DATATYPES.NumberTabTyp;
  -- GCHADHA --
  -- BUG 3941485 --
    in_document_id OKC_DATATYPES.NumberTabTyp;
  -- END GCHADHA --
-- R12 Data Model Changes 4485150 Start
    in_approval_type OKC_DATATYPES.Var450TabTyp;
    in_term_cancel_source OKC_DATATYPES.Var450TabTyp;
    in_payment_instruction_type OKC_DATATYPES.Var450TabTyp;
-- R12 Data Model Changes 4485150 End

    i NUMBER := p_chrv_tbl.FIRST;
    j NUMBER := 0;

    BEGIN
    --Initializing return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('23400: Entered INSERT_ROW_UPG', 2);
        END IF;


    -- pkoganti   08/26/2000
    -- replace for loop with while loop to handle
    -- gaps in pl/sql table indexes.
    -- Example:
    --   consider a pl/sql table(A) with the following elements
    --   A(1) = 10
    --   A(2) = 20
    --   A(6) = 30
    --   A(7) = 40
    --
    --  The for loop was erroring for indexes 3,4,5, the while loop
    -- along with the NEXT operator would handle the missing indexes
    -- with out causing the API to fail.
    --
        WHILE i IS NOT NULL
            LOOP

            j := j + 1;

            in_id (j) := p_chrv_tbl(i).id;
    -- GCHADHA --
    -- 3941485 --
            in_document_id (j) := p_chrv_tbl(i).document_id;
    -- END GCHADHA --
            in_object_version_number (j) := p_chrv_tbl(i).object_version_number;
            in_sfwt_flag (j) := p_chrv_tbl(i).sfwt_flag;
            in_chr_id_response (j) := p_chrv_tbl(i).chr_id_response;
            in_chr_id_award (j) := p_chrv_tbl(i).chr_id_award;
            in_inv_organization_id (j) := p_chrv_tbl(i).inv_organization_id;
            in_sts_code (j) := p_chrv_tbl(i).sts_code;
            in_qcl_id (j) := p_chrv_tbl(i).qcl_id;
            in_scs_code (j) := p_chrv_tbl(i).scs_code;
            in_contract_number (j) := p_chrv_tbl(i).contract_number;
            in_currency_code (j) := p_chrv_tbl(i).currency_code;
            in_contract_number_modifier (j) := p_chrv_tbl(i).contract_number_modifier;
            in_archived_yn (j) := p_chrv_tbl(i).archived_yn;
            in_deleted_yn (j) := p_chrv_tbl(i).deleted_yn;
            in_cust_po_number_req_yn (j) := p_chrv_tbl(i).cust_po_number_req_yn;
            in_pre_pay_req_yn (j) := p_chrv_tbl(i).pre_pay_req_yn;
            in_cust_po_number (j) := p_chrv_tbl(i).cust_po_number;
            in_short_description (j) := p_chrv_tbl(i).short_description;
            in_comments (j) := p_chrv_tbl(i).comments;
            in_description (j) := p_chrv_tbl(i).description;
            in_dpas_rating (j) := p_chrv_tbl(i).dpas_rating;
            in_cognomen (j) := p_chrv_tbl(i).cognomen;
            in_template_yn (j) := p_chrv_tbl(i).template_yn;
            in_template_used (j) := p_chrv_tbl(i).template_used;
            in_date_approved (j) := p_chrv_tbl(i).date_approved;
            in_datetime_cancelled (j) := p_chrv_tbl(i).datetime_cancelled;
            in_auto_renew_days (j) := p_chrv_tbl(i).auto_renew_days;
            in_date_issued (j) := p_chrv_tbl(i).date_issued;
            in_datetime_responded (j) := p_chrv_tbl(i).datetime_responded;
            in_non_response_reason (j) := p_chrv_tbl(i).non_response_reason;
            in_non_response_explain (j) := p_chrv_tbl(i).non_response_explain;
            in_rfp_type (j) := p_chrv_tbl(i).rfp_type;
            in_chr_type (j) := p_chrv_tbl(i).chr_type;
            in_keep_on_mail_list (j) := p_chrv_tbl(i).keep_on_mail_list;
            in_set_aside_reason (j) := p_chrv_tbl(i).set_aside_reason;
            in_set_aside_percent (j) := p_chrv_tbl(i).set_aside_percent;
            in_response_copies_req (j) := p_chrv_tbl(i).response_copies_req;
            in_date_close_projected (j) := p_chrv_tbl(i).date_close_projected;
            in_datetime_proposed (j) := p_chrv_tbl(i).datetime_proposed;
            in_date_signed (j) := p_chrv_tbl(i).date_signed;
            in_date_terminated (j) := p_chrv_tbl(i).date_terminated;
            in_date_renewed (j) := p_chrv_tbl(i).date_renewed;
            in_trn_code (j) := p_chrv_tbl(i).trn_code;
            in_start_date (j) := p_chrv_tbl(i).start_date;
            in_end_date (j) := p_chrv_tbl(i).end_date;
            in_authoring_org_id (j) := p_chrv_tbl(i).authoring_org_id;
            in_org_id (j) := p_chrv_tbl(i).org_id; --mmadhavi added for MOAC
            in_buy_or_sell (j) := p_chrv_tbl(i).buy_or_sell;
            in_issue_or_receive (j) := p_chrv_tbl(i).issue_or_receive;
            in_estimated_amount (j) := p_chrv_tbl(i).estimated_amount;
            in_estimated_amount_renewed (j) := p_chrv_tbl(i).estimated_amount_renewed;
            in_currency_code_renewed (j) := p_chrv_tbl(i).currency_code_renewed;
            in_upg_orig_system_ref (j) := p_chrv_tbl(i).upg_orig_system_ref;
            in_upg_orig_system_ref_id (j) := p_chrv_tbl(i).upg_orig_system_ref_id;
            in_application_id (j) := p_chrv_tbl(i).application_id;
            in_orig_system_source_code (j) := p_chrv_tbl(i).orig_system_source_code;
            in_orig_system_id1 (j) := p_chrv_tbl(i).orig_system_id1;
            in_orig_system_reference1 (j) := p_chrv_tbl(i).orig_system_reference1;
            in_program_id (j) := p_chrv_tbl(i). program_id;
            in_request_id (j) := p_chrv_tbl(i).request_id;
            in_program_update_date (j) := p_chrv_tbl(i).program_update_date;
            in_program_application_id (j) := p_chrv_tbl(i).program_application_id;
            in_price_list_id (j) := p_chrv_tbl(i).price_list_id;
            in_pricing_date (j) := p_chrv_tbl(i).pricing_date;
            in_sign_by_date (j) := p_chrv_tbl(i).sign_by_date;
            in_total_line_list_price (j) := p_chrv_tbl(i).total_line_list_price;
            in_user_estimated_amount (j) := p_chrv_tbl(i).user_estimated_amount;
            in_governing_contract_yn (j) := p_chrv_tbl(i).governing_contract_yn;
            in_attribute_category (j) := p_chrv_tbl(i).attribute_category;
            in_attribute1 (j) := p_chrv_tbl(i).attribute1;
            in_attribute2 (j) := p_chrv_tbl(i).attribute2;
            in_attribute3 (j) := p_chrv_tbl(i).attribute3;
            in_attribute4 (j) := p_chrv_tbl(i).attribute4;
            in_attribute5 (j) := p_chrv_tbl(i).attribute5;
            in_attribute6 (j) := p_chrv_tbl(i).attribute6;
            in_attribute7 (j) := p_chrv_tbl(i).attribute7;
            in_attribute8 (j) := p_chrv_tbl(i).attribute8;
            in_attribute9 (j) := p_chrv_tbl(i).attribute9;
            in_attribute10 (j) := p_chrv_tbl(i).attribute10;
            in_attribute11 (j) := p_chrv_tbl(i).attribute11;
            in_attribute12 (j) := p_chrv_tbl(i).attribute12;
            in_attribute13 (j) := p_chrv_tbl(i).attribute13;
            in_attribute14 (j) := p_chrv_tbl(i).attribute14;
            in_attribute15 (j) := p_chrv_tbl(i).attribute15;
            in_created_by (j) := p_chrv_tbl(i).created_by;
            in_creation_date (j) := p_chrv_tbl(i).creation_date;
            in_last_updated_by (j) := p_chrv_tbl(i).last_updated_by;
            in_last_update_date (j) := p_chrv_tbl(i).last_update_date;
            in_last_update_login (j) := p_chrv_tbl(i).last_update_login;
      --new columns to replace rules
            in_conversion_type (j) := p_chrv_tbl(i).conversion_type;
            in_conversion_rate (j) := p_chrv_tbl(i).conversion_rate;
            in_conversion_rate_date (j) := p_chrv_tbl(i).conversion_rate_date;
            in_conversion_euro_rate (j) := p_chrv_tbl(i).conversion_euro_rate;
            in_cust_acct_id (j) := p_chrv_tbl(i).cust_acct_id;
            in_bill_to_site_use_id (j) := p_chrv_tbl(i).bill_to_site_use_id;
            in_inv_rule_id (j) := p_chrv_tbl(i).inv_rule_id;
            in_renewal_type_code (j) := p_chrv_tbl(i).renewal_type_code;
            in_renewal_notify_to (j) := p_chrv_tbl(i).renewal_notify_to;
            in_renewal_end_date (j) := p_chrv_tbl(i).renewal_end_date;
            in_ship_to_site_use_id (j) := p_chrv_tbl(i).ship_to_site_use_id;
            in_payment_term_id (j) := p_chrv_tbl(i).payment_term_id;
-- R12 Data Model Changes 4485150 End
            in_approval_type (j) := p_chrv_tbl(i).approval_type ;
            in_term_cancel_source (j) := p_chrv_tbl(i).term_cancel_source ;
            in_payment_instruction_type (j) := p_chrv_tbl(i).payment_instruction_type;
-- R12 Data Model Changes 4485150 End
            i := p_chrv_tbl.NEXT(i);
        END LOOP;

        FORALL i IN 1..l_tabsize
        INSERT
          INTO OKC_K_HEADERS_ALL_B --mmadhavi changed to _ALL for MOAC
          (
           id,
           -- GCHADHA --
           -- BUG 3941485 --
           document_id,
           -- END GCHADHA --
           contract_number,
           authoring_org_id,
           org_id,  --mmadhavi added for MOAC
           contract_number_modifier,
           chr_id_response,
           chr_id_award,
           sts_code,
           qcl_id,
           scs_code,
           trn_code,
           currency_code,
           archived_yn,
           deleted_yn,
           template_yn,
           chr_type,
           object_version_number,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           cust_po_number_req_yn,
           pre_pay_req_yn,
           cust_po_number,
           dpas_rating,
           template_used,
           date_approved,
           datetime_cancelled,
           auto_renew_days,
           date_issued,
           datetime_responded,
           rfp_type,
           keep_on_mail_list,
           set_aside_percent,
           response_copies_req,
           date_close_projected,
           datetime_proposed,
           date_signed,
           date_terminated,
           date_renewed,
           start_date,
           end_date,
           buy_or_sell,
           issue_or_receive,
           last_update_login,
           upg_orig_system_ref,
           upg_orig_system_ref_id,
           application_id,
           orig_system_source_code,
           orig_system_id1,
           orig_system_reference1,
           program_id,
           request_id,
           program_update_date,
           program_application_id,
           price_list_id,
           pricing_date,
           sign_by_date,
           total_line_list_price,
           user_estimated_amount,
           governing_contract_yn,
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
           estimated_amount,
           inv_organization_id,
           estimated_amount_renewed,
           currency_code_renewed,
           -- new columns to replace rules
           conversion_type,
           conversion_rate,
           conversion_rate_date,
           conversion_euro_rate,
           cust_acct_id,
           bill_to_site_use_id,
           inv_rule_id,
           renewal_type_code,
           renewal_notify_to,
           renewal_end_date,
           ship_to_site_use_id,
           payment_term_id,
           -- R12 Data Model Changes 4485150 End
           approval_type,
           term_cancel_source,
           payment_instruction_type
           -- R12 Data Model Changes 4485150 End
           )
         VALUES (
                 in_id(i),
                 -- GCHADHA --
                 -- 3941485 --
                 in_document_id(i),
                 -- END GCHADHA --
                 in_contract_number(i),
                 in_authoring_org_id(i),
                 in_org_id(i),  --mmadhavi added for MOAC
                 in_contract_number_modifier(i),
                 in_chr_id_response(i),
                 in_chr_id_award(i),
                 in_sts_code(i),
                 in_qcl_id(i),
                 in_scs_code(i),
                 in_trn_code(i),
                 in_currency_code(i),
                 in_archived_yn(i),
                 in_deleted_yn(i),
                 in_template_yn(i),
                 in_chr_type(i),
                 in_object_version_number(i),
                 in_created_by(i),
                 in_creation_date(i),
                 in_last_updated_by(i),
                 in_last_update_date(i),
                 in_cust_po_number_req_yn(i),
                 in_pre_pay_req_yn(i),
                 in_cust_po_number(i),
                 in_dpas_rating(i),
                 in_template_used(i),
                 in_date_approved(i),
                 in_datetime_cancelled(i),
                 in_auto_renew_days(i),
                 in_date_issued(i),
                 in_datetime_responded(i),
                 in_rfp_type(i),
                 in_keep_on_mail_list(i),
                 in_set_aside_percent(i),
                 in_response_copies_req(i),
                 in_date_close_projected(i),
                 in_datetime_proposed(i),
                 in_date_signed(i),
                 in_date_terminated(i),
                 in_date_renewed(i),
                 in_start_date(i),
                 in_end_date(i),
                 in_buy_or_sell(i),
                 in_issue_or_receive(i),
                 in_last_update_login(i),
                 in_upg_orig_system_ref(i),
                 in_upg_orig_system_ref_id(i),
                 in_application_id(i),
                 in_orig_system_source_code(i),
                 in_orig_system_id1(i),
                 in_orig_system_reference1(i),
                 in_program_id(i),
                 in_request_id(i),
                 in_program_update_date(i),
                 in_program_application_id(i),
                 in_price_list_id(i),
                 in_pricing_date(i),
                 in_sign_by_date(i),
                 in_total_line_list_price(i),
                 in_user_estimated_amount(i),
                 in_governing_contract_yn(i),
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
                 in_estimated_amount(i),
                 in_inv_organization_id(i),
                 in_estimated_amount_renewed(i),
                 in_currency_code_renewed(i),
                 --new columns to replace rules
                 in_conversion_type(i),
                 in_conversion_rate(i),
                 in_conversion_rate_date(i),
                 in_conversion_euro_rate(i),
                 in_cust_acct_id(i),
                 in_bill_to_site_use_id(i),
                 in_inv_rule_id(i),
                 in_renewal_type_code(i),
                 in_renewal_notify_to(i),
                 in_renewal_end_date(i),
                 in_ship_to_site_use_id(i),
                 in_payment_term_id(i),
                 -- R12 Data Model Changes 4485150 End
                 in_approval_type(i),
                 in_term_cancel_source(i),
                 in_payment_instruction_type(i)
                 -- R12 Data Model Changes 4485150 End
                 );

        FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
            FORALL i IN 1..l_tabsize
            INSERT INTO OKC_K_HEADERS_TL(
                                         id,
                                         language,
                                         source_lang,
                                         sfwt_flag,
                                         short_description,
                                         comments,
                                         description,
                                         cognomen,
                                         non_response_reason,
                                         non_response_explain,
                                         set_aside_reason,
                                         created_by,
                                         creation_date,
                                         last_updated_by,
                                         last_update_date,
                                         last_update_login
                                         )
           VALUES (
                   in_id(i),
                   OKC_UTIL.g_language_code(lang_i),
                   l_source_lang,
                   in_sfwt_flag(i),
                   in_short_description(i),
                   in_comments(i),
                   in_description(i),
                   in_cognomen(i),
                   in_non_response_reason(i),
                   in_non_response_explain(i),
                   in_set_aside_reason(i),
                   in_created_by(i),
                   in_creation_date(i),
                   in_last_updated_by(i),
                   in_last_update_date(i),
                   in_last_update_login(i)
                   );
        END LOOP;

  -- Insert version numbers
        FORALL i IN 1..l_tabsize
        INSERT
          INTO OKC_K_VERS_NUMBERS
          (
           chr_id,
           major_version,
           minor_version,
           object_version_number,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
           )
         VALUES (
                 in_id(i),
                 0,
                 0,
                 in_object_version_number(i),
                 in_created_by(i),
                 in_creation_date(i),
                 in_last_updated_by(i),
                 in_last_update_date(i),
                 in_last_update_login(i)
                 );

        IF (l_debug = 'Y') THEN
            okc_debug.LOG('23500: Exiting INSERT_ROW_UPG', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('23600: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;
    -- Store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

   -- RAISE;

    END INSERT_ROW_UPG;

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

    FUNCTION create_version(
                            p_chr_id IN NUMBER,
                            p_major_version IN NUMBER
                            ) RETURN VARCHAR2 IS

    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('23700: Entered create_version', 2);
        END IF;

        INSERT INTO okc_k_headers_all_bh --mmadhavi changed to _ALL for MOAC
          (
           major_version,
           id,
           contract_number,
           authoring_org_id,
           org_id,  --mmadhavi added for MOAC
           contract_number_modifier,
           chr_id_response,
           chr_id_award,
           sts_code,
           qcl_id,
           scs_code,
           trn_code,
           currency_code,
           archived_yn,
           deleted_yn,
           template_yn,
           chr_type,
           object_version_number,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           cust_po_number_req_yn,
           pre_pay_req_yn,
           cust_po_number,
           dpas_rating,
           template_used,
           date_approved,
           datetime_cancelled,
           auto_renew_days,
           date_issued,
           datetime_responded,
           rfp_type,
           keep_on_mail_list,
           set_aside_percent,
           response_copies_req,
           date_close_projected,
           datetime_proposed,
           date_signed,
           date_terminated,
           date_renewed,
           start_date,
           end_date,
           buy_or_sell,
           issue_or_receive,
           last_update_login,
           application_id,
           orig_system_source_code,
           orig_system_id1,
           orig_system_reference1,
           upg_orig_system_ref,
           upg_orig_system_ref_id,
           program_id,
           request_id,
           program_update_date,
           program_application_id,
           price_list_id,
           pricing_date,
           sign_by_date,
           total_line_list_price,
           user_estimated_amount,
           governing_contract_yn,
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
           estimated_amount,
           inv_organization_id,
           currency_code_renewed,
           estimated_amount_renewed,
           -- new columns to replace rules
           conversion_type,
           conversion_rate,
           conversion_rate_date,
           conversion_euro_rate,
           cust_acct_id,
           bill_to_site_use_id,
           inv_rule_id,
           renewal_type_code,
           renewal_notify_to,
           renewal_end_date,
           ship_to_site_use_id,
           payment_term_id,
           document_id,
           -- R12 Data Model Changes 4485150 End
           approval_type,
           term_cancel_source,
           payment_instruction_type,
           -- R12 Data Model Changes 4485150 End
		 cancelled_amount -- LLC
           )
          SELECT
              p_major_version,
              id,
              contract_number,
              authoring_org_id,
              org_id,  --mmadhavi added for MOAC
              contract_number_modifier,
              chr_id_response,
              chr_id_award,
              sts_code,
              qcl_id,
              scs_code,
              trn_code,
              currency_code,
              archived_yn,
              deleted_yn,
              template_yn,
              chr_type,
              object_version_number,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              cust_po_number_req_yn,
              pre_pay_req_yn,
              cust_po_number,
              dpas_rating,
              template_used,
              date_approved,
              datetime_cancelled,
              auto_renew_days,
              date_issued,
              datetime_responded,
              rfp_type,
              keep_on_mail_list,
              set_aside_percent,
              response_copies_req,
              date_close_projected,
              datetime_proposed,
              date_signed,
              date_terminated,
              date_renewed,
              start_date,
              end_date,
              buy_or_sell,
              issue_or_receive,
              last_update_login,
              application_id,
              orig_system_source_code,
              orig_system_id1,
              orig_system_reference1,
              upg_orig_system_ref,
              upg_orig_system_ref_id,
              program_id,
              request_id,
              program_update_date,
              program_application_id,
              price_list_id,
              pricing_date,
              sign_by_date,
              total_line_list_price,
             user_estimated_amount,
             governing_contract_yn,
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
              estimated_amount,
              inv_organization_id,
              currency_code_renewed,
              estimated_amount_renewed,
-- new columns to replace rules
              conversion_type,
              conversion_rate,
              conversion_rate_date,
              conversion_euro_rate,
              cust_acct_id,
              bill_to_site_use_id,
              inv_rule_id,
              renewal_type_code,
              renewal_notify_to,
              renewal_end_date,
              ship_to_site_use_id,
              payment_term_id,
              document_id,
-- R12 Data Model Changes 4485150 Start
              approval_type,
              term_cancel_source,
              payment_instruction_type,
		    cancelled_amount -- LLC
-- R12 Data Model Changes 4485150 End
          FROM okc_k_headers_all_b --mamdhavi changed to _ALL for MOAC
         WHERE id = p_chr_id;

--------------------------------
-- Versioning TL Table
--------------------------------

        INSERT INTO okc_k_headers_tlh
          (
           major_version,
           id,
           language,
           source_lang,
           sfwt_flag,
           short_description,
           comments,
           description,
           cognomen,
           non_response_reason,
           non_response_explain,
           set_aside_reason,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
           )
          SELECT
              p_major_version,
              id,
              language,
              source_lang,
              sfwt_flag,
              short_description,
              comments,
              description,
              cognomen,
              non_response_reason,
              non_response_explain,
              set_aside_reason,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login
          FROM okc_k_headers_tl
         WHERE id = p_chr_id;

        RETURN l_return_status;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('23800: Exiting create_version', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
       -- other appropriate handlers
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('23900: Exiting create_version:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

       -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => okc_version_pvt.G_APP_NAME,
                                p_msg_name => okc_version_pvt.G_UNEXPECTED_ERROR,
                                p_token1 => okc_version_pvt.G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => okc_version_pvt.G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

       -- notify  UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN l_return_status;

    END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API


    FUNCTION restore_version(
                             p_chr_id IN NUMBER,
                             p_major_version IN NUMBER
                             ) RETURN VARCHAR2 IS

    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CHR_PVT');
            okc_debug.LOG('24000: Entered restore_version', 2);
        END IF;

        INSERT INTO okc_k_headers_tl
          (
           id,
           language,
           source_lang,
           sfwt_flag,
           short_description,
           comments,
           description,
           cognomen,
           non_response_reason,
           non_response_explain,
           set_aside_reason,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
           )
          SELECT
              id,
              language,
              source_lang,
              sfwt_flag,
              short_description,
              comments,
              description,
              cognomen,
              non_response_reason,
              non_response_explain,
              set_aside_reason,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login
          FROM okc_k_headers_tlh
        WHERE id = p_chr_id
          AND major_version = p_major_version;

--------------------------------------
-- Restore Base Table
--------------------------------------

        INSERT INTO okc_k_headers_all_b --mmadhavi changed to _ALL for MOAC
          (
           id,
           contract_number,
           authoring_org_id,
           org_id,  --mmadhavi added for MOAC
           contract_number_modifier,
           chr_id_response,
           chr_id_award,
           sts_code,
           qcl_id,
           scs_code,
           trn_code,
           currency_code,
           archived_yn,
           deleted_yn,
           template_yn,
           chr_type,
           object_version_number,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           cust_po_number_req_yn,
           pre_pay_req_yn,
           cust_po_number,
           dpas_rating,
           template_used,
           date_approved,
           datetime_cancelled,
           auto_renew_days,
           date_issued,
           datetime_responded,
           rfp_type,
           keep_on_mail_list,
           set_aside_percent,
           response_copies_req,
           date_close_projected,
           datetime_proposed,
           date_signed,
           date_terminated,
           date_renewed,
           start_date,
           end_date,
           buy_or_sell,
           issue_or_receive,
           last_update_login,
           application_id,
           orig_system_source_code,
           orig_system_id1,
           orig_system_reference1,
           upg_orig_system_ref,
           upg_orig_system_ref_id,
           program_id,
           request_id,
           program_update_date,
           program_application_id,
           price_list_id,
           pricing_date,
           sign_by_date,
           total_line_list_price,
           user_estimated_amount,
           governing_contract_yn,
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
           estimated_amount,
           inv_organization_id,
           currency_code_renewed,
           estimated_amount_renewed,
           -- new columns to replace rules
           conversion_type,
           conversion_rate,
           conversion_rate_date,
           conversion_euro_rate,
           cust_acct_id,
           bill_to_site_use_id,
           inv_rule_id,
           renewal_type_code,
           renewal_notify_to,
           renewal_end_date,
           ship_to_site_use_id,
           payment_term_id,
           document_id,
           -- R12 Data Model Changes 4485150 Start
           approval_type,
           term_cancel_source,
           payment_instruction_type,
		 cancelled_amount -- LLC
           -- R12 Data Model Changes 4485150 Start
           )
          SELECT
              id,
              contract_number,
              authoring_org_id,
              org_id,  --mmadhavi added for MOAC
              contract_number_modifier,
              chr_id_response,
              chr_id_award,
              sts_code,
              qcl_id,
              scs_code,
              trn_code,
              currency_code,
              archived_yn,
              deleted_yn,
              template_yn,
              chr_type,
              object_version_number,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              cust_po_number_req_yn,
              pre_pay_req_yn,
              cust_po_number,
              dpas_rating,
              template_used,
              date_approved,
              datetime_cancelled,
              auto_renew_days,
              date_issued,
              datetime_responded,
              rfp_type,
              keep_on_mail_list,
              set_aside_percent,
              response_copies_req,
              date_close_projected,
              datetime_proposed,
              date_signed,
              date_terminated,
              date_renewed,
              start_date,
              end_date,
              buy_or_sell,
              issue_or_receive,
              last_update_login,
              application_id,
              orig_system_source_code,
              orig_system_id1,
              orig_system_reference1,
              upg_orig_system_ref,
              upg_orig_system_ref_id,
              program_id,
              request_id,
              program_update_date,
              program_application_id,
              price_list_id,
              pricing_date,
              sign_by_date,
              total_line_list_price,
             user_estimated_amount,
             governing_contract_yn,
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
              estimated_amount,
              inv_organization_id,
              currency_code_renewed,
              estimated_amount_renewed,
              conversion_type,
              conversion_rate,
              conversion_rate_date,
              conversion_euro_rate,
              cust_acct_id,
              bill_to_site_use_id,
              inv_rule_id,
              renewal_type_code,
              renewal_notify_to,
              renewal_end_date,
              ship_to_site_use_id,
              payment_term_id,
              document_id,
-- R12 data Model Changes 4485150 Start
              approval_type,
              term_cancel_source,
              payment_instruction_type,
		    cancelled_amount -- LLC
-- R12 data Model Changes 4485150 End
          FROM okc_k_headers_all_bh --mmadhavi changed to _ALL for MOAC
        WHERE id = p_chr_id
          AND major_version = p_major_version;

        RETURN l_return_status;
        IF (l_debug = 'Y') THEN
            okc_debug.LOG('24100: Exiting restore_version', 2);
            okc_debug.Reset_Indentation;
        END IF;


    EXCEPTION
       -- other appropriate handlers
        WHEN OTHERS THEN

            IF (l_debug = 'Y') THEN
                okc_debug.LOG('24200: Exiting restore_version:OTHERS Exception', 2);
                okc_debug.Reset_Indentation;
            END IF;

       -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => okc_version_pvt.G_APP_NAME,
                                p_msg_name => okc_version_pvt.G_UNEXPECTED_ERROR,
                                p_token1 => okc_version_pvt.G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => okc_version_pvt.G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

       -- notify  UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN l_return_status;

    END restore_version;



END OKC_CHR_PVT;

/
