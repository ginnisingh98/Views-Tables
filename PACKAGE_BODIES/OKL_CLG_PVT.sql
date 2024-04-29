--------------------------------------------------------
--  DDL for Package Body OKL_CLG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CLG_PVT" AS
/* $Header: OKLSCLGB.pls 120.5 2007/08/08 12:43:48 arajagop noship $ */

PROCEDURE validate_currency_code(x_return_status OUT NOCOPY VARCHAR2,
			 p_clgv_rec 		IN	clgv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_clgv_csr IS
	SELECT 'x'
	FROM FND_CURRENCIES_VL
	WHERE currency_code = p_clgv_rec.currency_code;

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_clgv_rec.currency_code IS NULL) OR (p_clgv_rec.currency_code = Okl_Api.G_MISS_CHAR) THEN
           -- Message Text: Please enter all mandatory fields
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_MISSING_FIELDS');

            RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

-- enforce foreign key
OPEN l_clgv_csr;
	FETCH l_clgv_csr INTO l_dummy_var;
CLOSE l_clgv_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'Currency',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_CNTR_LVLNG_GRPS_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'FND_CURRENCIES_V');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
x_return_status := OKC_API.G_RET_STS_ERROR;

	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);


-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

-- verfiy that cursor was closed
	IF l_clgv_csr%ISOPEN THEN
	  CLOSE l_clgv_csr;
	END IF;

END validate_currency_code;

 -- for LE Uptake project 08-11-2006
 ---------------------------------------------------------------------------
  -- PROCEDURE validate_legal_entity_id
 ---------------------------------------------------------------------------
  PROCEDURE validate_legal_entity_id (p_clgv_rec IN clgv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_exists                NUMBER(1);
   item_not_found_error    EXCEPTION;
  BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	IF (p_clgv_rec.legal_entity_id IS NOT NULL) THEN
		l_exists := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_clgv_rec.legal_entity_id);
	   IF(l_exists <> 1) THEN
             Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEGAL_ENTITY_ID');
	     RAISE item_not_found_error;
           END IF;
	END IF;
EXCEPTION
WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

WHEN OTHERS THEN
-- store SQL error message on message stack for caller
Okc_Api.SET_MESSAGE(p_app_name      => g_app_name
                   ,p_msg_name      => g_unexpected_error
                   ,p_token1        => g_sqlcode_token
                   ,p_token1_value  =>SQLCODE
                   ,p_token2        => g_sqlerrm_token
                   ,p_token2_value  =>SQLERRM);

-- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
END validate_legal_entity_id;
/*
PROCEDURE validate_ibt_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_clgv_rec 		IN	clgv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_ibt_csr IS
	SELECT 'x'
	FROM OKX_BILL_TOS_V
	WHERE id = p_clgv_rec.ibt_id;

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_clgv_rec.ibt_id IS NULL) OR (p_clgv_rec.ibt_id = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'ibt_id');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

-- enforce foreign key
OPEN l_ibt_csr;
	FETCH l_ibt_csr INTO l_dummy_var;
CLOSE l_ibt_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'ibt_id',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_CNTR_LVLNG_GRPS_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'OKX_BILL_TOS_V');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

EXCEPTION

	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
x_return_status := OKC_API.G_RET_STS_ERROR;

	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);


-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

-- verfiy that cursor was closed
	IF l_ibt_csr%ISOPEN THEN
	  CLOSE l_ibt_csr;
	END IF;

END validate_ibt_id;
*/

/*
PROCEDURE validate_ica_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_clgv_rec 		IN	clgv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_ica_csr IS
	SELECT 'x'
	FROM OKX_CUSTOMER_ACCOUNTS_V
	WHERE id = p_clgv_rec.ica_id;

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_clgv_rec.ica_id IS NULL) OR (p_clgv_rec.ica_id = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'ica_id');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

-- enforce foreign key
OPEN l_ica_csr;
	FETCH l_ica_csr INTO l_dummy_var;
CLOSE l_ica_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'ica_id',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_CNTR_LVLNG_GRPS_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'OKX_CUSTOMER_ACCOUNTS_V');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
	NULL;

	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);


-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

-- verfiy that cursor was closed
	IF l_ica_csr%ISOPEN THEN
	  CLOSE l_ica_csr;
	END IF;

END validate_ica_id;
*/

PROCEDURE validate_inf_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_clgv_rec 		IN	clgv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_inf_csr IS
	SELECT 'x'
	FROM OKL_INVOICE_FORMATS_V
	WHERE id = p_clgv_rec.inf_id;

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_clgv_rec.inf_id IS NULL) OR (p_clgv_rec.inf_id = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'inf_id');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

-- enforce foreign key
OPEN l_inf_csr;
	FETCH l_inf_csr INTO l_dummy_var;
CLOSE l_inf_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'inf_id',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_CNTR_LVLNG_GRPS_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'OKL_INVOICE_FORMATS_V');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

EXCEPTION

	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
x_return_status := OKC_API.G_RET_STS_ERROR;


	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);


-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

-- verfiy that cursor was closed
	IF l_inf_csr%ISOPEN THEN
	  CLOSE l_inf_csr;
	END IF;

END validate_inf_id;
/*
PROCEDURE validate_irm_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_clgv_rec 		IN	clgv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_irm_csr IS
	SELECT 'x'
	FROM OKX_RECEIPT_METHODS_V
	WHERE id = p_clgv_rec.irm_id;

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_clgv_rec.irm_id IS NULL) OR (p_clgv_rec.irm_id = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'irm_id');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

-- enforce foreign key
OPEN l_irm_csr;
	FETCH l_irm_csr INTO l_dummy_var;
CLOSE l_irm_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'irm_id',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_CNTR_LVLNG_GRPS_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'OKX_RECEIPT_METHODS_V');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
	NULL;

	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);


-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

-- verfiy that cursor was closed
	IF l_irm_csr%ISOPEN THEN
	  CLOSE l_irm_csr;
	END IF;

END validate_irm_id;

PROCEDURE validate_iuv_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_clgv_rec 		IN	clgv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_iuv_csr IS
	SELECT 'x'
	FROM OKX_USAGES_V
	WHERE id = p_clgv_rec.iuv_id;

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_clgv_rec.iuv_id IS NULL) OR (p_clgv_rec.iuv_id = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'iuv_id');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

-- enforce foreign key
OPEN l_iuv_csr;
	FETCH l_iuv_csr INTO l_dummy_var;
CLOSE l_iuv_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'iuv_id',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_CNTR_LVLNG_GRPS_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'OKX_USAGES_V');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
	NULL;

	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);


-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

-- verfiy that cursor was closed
	IF l_iuv_csr%ISOPEN THEN
	  CLOSE l_iuv_csr;
	END IF;

END validate_iuv_id;
*/

PROCEDURE validate_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_clgv_rec 		IN	clgv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_clgv_rec.id IS NULL) OR (p_clgv_rec.id = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'id');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

END validate_id;


PROCEDURE validate_object_version_number(x_return_status OUT NOCOPY VARCHAR2,
			 p_clgv_rec 		IN	clgv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_clgv_rec.object_version_number IS NULL) OR (p_clgv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'object_version_number');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

END validate_object_version_number;


PROCEDURE validate_name(x_return_status OUT NOCOPY VARCHAR2,
			 p_clgv_rec 		IN	clgv_rec_type) IS

  l_dummy                 VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;
  l_clg_id                NUMBER;
  CURSOR c1( p_name OKL_CNTR_LVLNG_GRPS_TL.name%TYPE) IS
  SELECT 1
  FROM OKL_CNTR_LVLNG_GRPS_V
  WHERE name = p_name;
  CURSOR c2( p_name OKL_CNTR_LVLNG_GRPS_TL.name%TYPE) IS
  SELECT id
  FROM OKL_CNTR_LVLNG_GRPS_V
  WHERE name = p_name;
BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_clgv_rec.name IS NULL) OR (p_clgv_rec.name = Okl_Api.G_MISS_CHAR) THEN
           -- Message Text: Please enter all mandatory fields
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_MISSING_FIELDS');

            RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;
-- spillaip 04-Nov-2004
-- First check if the call is for insert
-- For update do not validate the uniqueness of the name
IF ((p_clgv_rec.CREATION_DATE is null) OR (p_clgv_rec.CREATION_DATE = Okc_Api.G_MISS_DATE)) then
  -- New record for insert
  -- check if name is unique

    OPEN c1(p_clgv_rec.name);
    FETCH c1 INTO l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found THEN
           -- Message Text: Please enter all mandatory fields
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_DUP_COUNTER');

            RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
END IF;
IF (p_clgv_rec.id is not null) then
    -- existing record for update
    OPEN c2(p_clgv_rec.name);
    FETCH c2 INTO l_clg_id;
    l_row_found := c2%FOUND;
    CLOSE c2;
    IF l_row_found THEN
           -- Message Text: Please enter all mandatory fields
            IF (l_clg_id <> p_clgv_rec.id) THEN
                        x_return_status := OKC_API.G_RET_STS_ERROR;
                        OKC_API.set_message( p_app_name      => G_APP_NAME,
                                    p_msg_name      => 'OKL_BPD_DUP_COUNTER');

                 RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
    END IF;
END IF; --To check the call is for insert
EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
--	no processing necessary validation can continue with the next column
--x_return_status := OKC_API.G_RET_STS_ERROR;

	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);

END validate_name;


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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_CNTR_LVLNG_GRPS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_CNTR_LVL_GRPS_ALL_B B    --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_CNTR_LVLNG_GRPS_TL T SET (
        NAME,
        DESCRIPTION,
        PRIVATE_LABEL_LOGO_URL) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION,
                                  B.PRIVATE_LABEL_LOGO_URL
                                FROM OKL_CNTR_LVLNG_GRPS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_CNTR_LVLNG_GRPS_TL SUBB, OKL_CNTR_LVLNG_GRPS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.PRIVATE_LABEL_LOGO_URL <> SUBT.PRIVATE_LABEL_LOGO_URL
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.PRIVATE_LABEL_LOGO_URL IS NULL AND SUBT.PRIVATE_LABEL_LOGO_URL IS NOT NULL)
                      OR (SUBB.PRIVATE_LABEL_LOGO_URL IS NOT NULL AND SUBT.PRIVATE_LABEL_LOGO_URL IS NULL)
              ));

    INSERT INTO OKL_CNTR_LVLNG_GRPS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
        DESCRIPTION,
        PRIVATE_LABEL_LOGO_URL,
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
            B.NAME,
            B.DESCRIPTION,
            B.PRIVATE_LABEL_LOGO_URL,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_CNTR_LVLNG_GRPS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_CNTR_LVLNG_GRPS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CNTR_LVLNG_GRPS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_clg_rec                      IN clg_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN clg_rec_type IS
    CURSOR clg_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ORG_ID,
            CURRENCY_CODE,
            INF_ID,
            ICA_ID,
            IBT_ID,
            IRM_ID,
            IUV_ID,
            OBJECT_VERSION_NUMBER,
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
            EFFECTIVE_DATE_FROM,
            EFFECTIVE_DATE_TO,
            IPL_ID,
	    LEGAL_ENTITY_ID -- for LE Uptake project 08-11-2006
      FROM Okl_Cntr_Lvlng_Grps_B
     WHERE okl_cntr_lvlng_grps_b.id = p_id;
    l_clg_pk                       clg_pk_csr%ROWTYPE;
    l_clg_rec                      clg_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN clg_pk_csr (p_clg_rec.id);
    FETCH clg_pk_csr INTO
              l_clg_rec.ID,
              l_clg_rec.ORG_ID,
              l_clg_rec.CURRENCY_CODE,
              l_clg_rec.INF_ID,
              l_clg_rec.ICA_ID,
              l_clg_rec.IBT_ID,
              l_clg_rec.IRM_ID,
              l_clg_rec.IUV_ID,
              l_clg_rec.OBJECT_VERSION_NUMBER,
              l_clg_rec.ATTRIBUTE_CATEGORY,
              l_clg_rec.ATTRIBUTE1,
              l_clg_rec.ATTRIBUTE2,
              l_clg_rec.ATTRIBUTE3,
              l_clg_rec.ATTRIBUTE4,
              l_clg_rec.ATTRIBUTE5,
              l_clg_rec.ATTRIBUTE6,
              l_clg_rec.ATTRIBUTE7,
              l_clg_rec.ATTRIBUTE8,
              l_clg_rec.ATTRIBUTE9,
              l_clg_rec.ATTRIBUTE10,
              l_clg_rec.ATTRIBUTE11,
              l_clg_rec.ATTRIBUTE12,
              l_clg_rec.ATTRIBUTE13,
              l_clg_rec.ATTRIBUTE14,
              l_clg_rec.ATTRIBUTE15,
              l_clg_rec.CREATED_BY,
              l_clg_rec.CREATION_DATE,
              l_clg_rec.LAST_UPDATED_BY,
              l_clg_rec.LAST_UPDATE_DATE,
              l_clg_rec.LAST_UPDATE_LOGIN,
              l_clg_rec.EFFECTIVE_DATE_FROM,
              l_clg_rec.EFFECTIVE_DATE_TO,
              l_clg_rec.IPL_ID,
	      l_clg_rec.LEGAL_ENTITY_ID;  -- for LE Uptake project 08-11-2006
    x_no_data_found := clg_pk_csr%NOTFOUND;
    CLOSE clg_pk_csr;
    RETURN(l_clg_rec);
  END get_rec;

  FUNCTION get_rec (
    p_clg_rec                      IN clg_rec_type
  ) RETURN clg_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_clg_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CNTR_LVLNG_GRPS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_cntr_lvlng_grps_tl_rec   IN OklCntrLvlngGrpsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklCntrLvlngGrpsTlRecType IS
    CURSOR okl_cntr_lvlng_grps_tl_pk_csr (p_id                 IN NUMBER,
                                          p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
            PRIVATE_LABEL_LOGO_URL,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Cntr_Lvlng_Grps_Tl
     WHERE okl_cntr_lvlng_grps_tl.id = p_id
       AND okl_cntr_lvlng_grps_tl.LANGUAGE = p_language;
    l_okl_cntr_lvlng_grps_tl_pk    okl_cntr_lvlng_grps_tl_pk_csr%ROWTYPE;
    l_okl_cntr_lvlng_grps_tl_rec   OklCntrLvlngGrpsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cntr_lvlng_grps_tl_pk_csr (p_okl_cntr_lvlng_grps_tl_rec.id,
                                        p_okl_cntr_lvlng_grps_tl_rec.LANGUAGE);
    FETCH okl_cntr_lvlng_grps_tl_pk_csr INTO
              l_okl_cntr_lvlng_grps_tl_rec.ID,
              l_okl_cntr_lvlng_grps_tl_rec.LANGUAGE,
              l_okl_cntr_lvlng_grps_tl_rec.SOURCE_LANG,
              l_okl_cntr_lvlng_grps_tl_rec.SFWT_FLAG,
              l_okl_cntr_lvlng_grps_tl_rec.NAME,
              l_okl_cntr_lvlng_grps_tl_rec.DESCRIPTION,
              l_okl_cntr_lvlng_grps_tl_rec.PRIVATE_LABEL_LOGO_URL,
              l_okl_cntr_lvlng_grps_tl_rec.CREATED_BY,
              l_okl_cntr_lvlng_grps_tl_rec.CREATION_DATE,
              l_okl_cntr_lvlng_grps_tl_rec.LAST_UPDATED_BY,
              l_okl_cntr_lvlng_grps_tl_rec.LAST_UPDATE_DATE,
              l_okl_cntr_lvlng_grps_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_cntr_lvlng_grps_tl_pk_csr%NOTFOUND;
    CLOSE okl_cntr_lvlng_grps_tl_pk_csr;
    RETURN(l_okl_cntr_lvlng_grps_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_cntr_lvlng_grps_tl_rec   IN OklCntrLvlngGrpsTlRecType
  ) RETURN OklCntrLvlngGrpsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_cntr_lvlng_grps_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CNTR_LVLNG_GRPS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_clgv_rec                     IN clgv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN clgv_rec_type IS
    CURSOR okl_clgv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ORG_ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            INF_ID,
            ICA_ID,
            IBT_ID,
            CURRENCY_CODE,
            IRM_ID,
            IUV_ID,
            NAME,
            DESCRIPTION,
            PRIVATE_LABEL_LOGO_URL,
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
            EFFECTIVE_DATE_FROM,
            EFFECTIVE_DATE_TO,
            IPL_ID,
	    LEGAL_ENTITY_ID -- for LE Uptake project 08-11-2006
      FROM Okl_Cntr_Lvlng_Grps_V
     WHERE okl_cntr_lvlng_grps_v.id = p_id;
    l_okl_clgv_pk                  okl_clgv_pk_csr%ROWTYPE;
    l_clgv_rec                     clgv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_clgv_pk_csr (p_clgv_rec.id);
    FETCH okl_clgv_pk_csr INTO
              l_clgv_rec.ID,
              l_clgv_rec.ORG_ID,
              l_clgv_rec.OBJECT_VERSION_NUMBER,
              l_clgv_rec.SFWT_FLAG,
              l_clgv_rec.INF_ID,
              l_clgv_rec.ICA_ID,
              l_clgv_rec.IBT_ID,
              l_clgv_rec.CURRENCY_CODE,
              l_clgv_rec.IRM_ID,
              l_clgv_rec.IUV_ID,
              l_clgv_rec.NAME,
              l_clgv_rec.DESCRIPTION,
              l_clgv_rec.PRIVATE_LABEL_LOGO_URL,
              l_clgv_rec.ATTRIBUTE_CATEGORY,
              l_clgv_rec.ATTRIBUTE1,
              l_clgv_rec.ATTRIBUTE2,
              l_clgv_rec.ATTRIBUTE3,
              l_clgv_rec.ATTRIBUTE4,
              l_clgv_rec.ATTRIBUTE5,
              l_clgv_rec.ATTRIBUTE6,
              l_clgv_rec.ATTRIBUTE7,
              l_clgv_rec.ATTRIBUTE8,
              l_clgv_rec.ATTRIBUTE9,
              l_clgv_rec.ATTRIBUTE10,
              l_clgv_rec.ATTRIBUTE11,
              l_clgv_rec.ATTRIBUTE12,
              l_clgv_rec.ATTRIBUTE13,
              l_clgv_rec.ATTRIBUTE14,
              l_clgv_rec.ATTRIBUTE15,
              l_clgv_rec.CREATED_BY,
              l_clgv_rec.CREATION_DATE,
              l_clgv_rec.LAST_UPDATED_BY,
              l_clgv_rec.LAST_UPDATE_DATE,
              l_clgv_rec.LAST_UPDATE_LOGIN,
              l_clgv_rec.EFFECTIVE_DATE_FROM,
              l_clgv_rec.EFFECTIVE_DATE_TO,
              l_clgv_rec.IPL_ID,
	      l_clgv_rec.LEGAL_ENTITY_ID; -- for LE Uptake project 08-11-2006
    x_no_data_found := okl_clgv_pk_csr%NOTFOUND;
    CLOSE okl_clgv_pk_csr;
    RETURN(l_clgv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_clgv_rec                     IN clgv_rec_type
  ) RETURN clgv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_clgv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CNTR_LVLNG_GRPS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_clgv_rec	IN clgv_rec_type
  ) RETURN clgv_rec_type IS
    l_clgv_rec	clgv_rec_type := p_clgv_rec;
  BEGIN
    IF (l_clgv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.org_id := NULL;
    END IF;
    IF (l_clgv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.object_version_number := NULL;
    END IF;
    IF (l_clgv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_clgv_rec.inf_id = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.inf_id := NULL;
    END IF;
    IF (l_clgv_rec.ica_id = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.ica_id := NULL;
    END IF;
    IF (l_clgv_rec.ibt_id = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.ibt_id := NULL;
    END IF;
    IF (l_clgv_rec.currency_code = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.currency_code := NULL;
    END IF;
    IF (l_clgv_rec.irm_id = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.irm_id := NULL;
    END IF;
    IF (l_clgv_rec.iuv_id = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.iuv_id := NULL;
    END IF;
    IF (l_clgv_rec.name = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.name := NULL;
    END IF;
    IF (l_clgv_rec.description = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.description := NULL;
    END IF;
    IF (l_clgv_rec.private_label_logo_url = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.private_label_logo_url := NULL;
    END IF;
    IF (l_clgv_rec.attribute_category = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute_category := NULL;
    END IF;
    IF (l_clgv_rec.attribute1 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute1 := NULL;
    END IF;
    IF (l_clgv_rec.attribute2 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute2 := NULL;
    END IF;
    IF (l_clgv_rec.attribute3 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute3 := NULL;
    END IF;
    IF (l_clgv_rec.attribute4 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute4 := NULL;
    END IF;
    IF (l_clgv_rec.attribute5 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute5 := NULL;
    END IF;
    IF (l_clgv_rec.attribute6 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute6 := NULL;
    END IF;
    IF (l_clgv_rec.attribute7 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute7 := NULL;
    END IF;
    IF (l_clgv_rec.attribute8 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute8 := NULL;
    END IF;
    IF (l_clgv_rec.attribute9 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute9 := NULL;
    END IF;
    IF (l_clgv_rec.attribute10 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute10 := NULL;
    END IF;
    IF (l_clgv_rec.attribute11 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute11 := NULL;
    END IF;
    IF (l_clgv_rec.attribute12 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute12 := NULL;
    END IF;
    IF (l_clgv_rec.attribute13 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute13 := NULL;
    END IF;
    IF (l_clgv_rec.attribute14 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute14 := NULL;
    END IF;
    IF (l_clgv_rec.attribute15 = Okc_Api.G_MISS_CHAR) THEN
      l_clgv_rec.attribute15 := NULL;
    END IF;
    IF (l_clgv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.created_by := NULL;
    END IF;
    IF (l_clgv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_clgv_rec.creation_date := NULL;
    END IF;
    IF (l_clgv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.last_updated_by := NULL;
    END IF;
    IF (l_clgv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_clgv_rec.last_update_date := NULL;
    END IF;
    IF (l_clgv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.last_update_login := NULL;
    END IF;
   IF (l_clgv_rec.effective_date_from = Okc_Api.G_MISS_DATE) THEN
      l_clgv_rec.effective_date_from := NULL;
    END IF;
   IF (l_clgv_rec.effective_date_to = Okc_Api.G_MISS_DATE) THEN
      l_clgv_rec.effective_date_to := NULL;
    END IF;
   IF (l_clgv_rec.ipl_id = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.ipl_id := NULL;
    END IF;
    -- for LE Uptake project 08-11-2006
   IF (l_clgv_rec.legal_entity_id = Okc_Api.G_MISS_NUM) THEN
      l_clgv_rec.legal_entity_id := NULL;
    END IF;
    -- for LE Uptake project 08-11-2006
    RETURN(l_clgv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_CNTR_LVLNG_GRPS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_clgv_rec IN  clgv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1)	:= Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
     -- Call each column level validation

  validate_id(x_return_status => l_return_status,
			 	p_clgv_rec =>	p_clgv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
		x_return_status := l_return_status;
        RAISE   Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
--  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
--		x_return_status := l_return_status;
--	END IF;
  END IF;

  validate_object_version_number(x_return_status => l_return_status,
			 	p_clgv_rec =>	p_clgv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
		x_return_status := l_return_status;
        RAISE   Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
--  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
--		x_return_status := l_return_status;
--	END IF;
  END IF;

  validate_name(x_return_status => l_return_status,
			 	p_clgv_rec =>	p_clgv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
		x_return_status := l_return_status;
        RAISE   Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
--  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
--		x_return_status := l_return_status;
--	END IF;
  END IF;
/*
  validate_ibt_id(x_return_status => l_return_status,
			 	p_clgv_rec =>	p_clgv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_ica_id(x_return_status => l_return_status,
			 	p_clgv_rec =>	p_clgv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_irm_id(x_return_status => l_return_status,
			 	p_clgv_rec =>	p_clgv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_iuv_id(x_return_status => l_return_status,
			 	p_clgv_rec =>	p_clgv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;
*/
--  validate_inf_id(x_return_status => l_return_status,
--			 	p_clgv_rec =>	p_clgv_rec);

  -- Store the highest degree of error
  validate_currency_code(x_return_status => l_return_status,
			 	p_clgv_rec =>	p_clgv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        RAISE   Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;
-- for LE Uptake project 08-11-2006
IF ((p_clgv_rec.legal_entity_id = Okl_Api.G_MISS_NUM) OR p_clgv_rec.legal_entity_id IS NULL)
THEN
   RAISE G_EXCEPTION_HALT_VALIDATION;
ELSE
  validate_legal_entity_id(p_clgv_rec =>	p_clgv_rec,
                           x_return_status => l_return_status);

 IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        RAISE   Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
 END IF;
END IF;
-- for LE Uptake project 08-11-2006

    RETURN(l_return_status);
  EXCEPTION
    WHEN OTHERS THEN
        RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_CNTR_LVLNG_GRPS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_clgv_rec IN clgv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN clgv_rec_type,
    p_to	OUT NOCOPY clg_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.inf_id := p_from.inf_id;
    p_to.ica_id := p_from.ica_id;
    p_to.ibt_id := p_from.ibt_id;
    p_to.irm_id := p_from.irm_id;
    p_to.iuv_id := p_from.iuv_id;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.effective_date_from := p_from.effective_date_from;
    p_to.effective_date_to := p_from.effective_date_to;
    p_to.ipl_id := p_from.ipl_id;
    p_to.legal_entity_id := p_from.legal_entity_id; -- for LE Uptake project 08-11-2006
  END migrate;
  PROCEDURE migrate (
    p_from	IN clg_rec_type,
    p_to	OUT NOCOPY clgv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.inf_id := p_from.inf_id;
    p_to.ica_id := p_from.ica_id;
    p_to.ibt_id := p_from.ibt_id;
    p_to.irm_id := p_from.irm_id;
    p_to.iuv_id := p_from.iuv_id;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.effective_date_from := p_from.effective_date_from;
    p_to.effective_date_to := p_from.effective_date_to;
    --p_to.ipl_id := p_to.ipl_id;
    p_to.ipl_id := p_from.ipl_id;
    p_to.legal_entity_id := p_from.legal_entity_id; -- for LE Uptake project 08-11-2006
  END migrate;
  PROCEDURE migrate (
    p_from	IN clgv_rec_type,
    p_to	OUT NOCOPY OklCntrLvlngGrpsTlRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.private_label_logo_url := p_from.private_label_logo_url;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN OklCntrLvlngGrpsTlRecType,
    p_to	OUT NOCOPY clgv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.private_label_logo_url := p_from.private_label_logo_url;
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
  -- validate_row for:OKL_CNTR_LVLNG_GRPS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_rec                     IN clgv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_clgv_rec                     clgv_rec_type := p_clgv_rec;
    l_clg_rec                      clg_rec_type;
    l_okl_cntr_lvlng_grps_tl_rec   OklCntrLvlngGrpsTlRecType;
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
    l_return_status := Validate_Attributes(l_clgv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_clgv_rec);
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
  -- PL/SQL TBL validate_row for:CLGV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_tbl                     IN clgv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clgv_tbl.COUNT > 0) THEN
      i := p_clgv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clgv_rec                     => p_clgv_tbl(i));
        EXIT WHEN (i = p_clgv_tbl.LAST);
        i := p_clgv_tbl.NEXT(i);
      END LOOP;
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
  ------------------------------------------
  -- insert_row for:OKL_CNTR_LVLNG_GRPS_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clg_rec                      IN clg_rec_type,
    x_clg_rec                      OUT NOCOPY clg_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_clg_rec                      clg_rec_type := p_clg_rec;
    l_def_clg_rec                  clg_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_GRPS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_clg_rec IN  clg_rec_type,
      x_clg_rec OUT NOCOPY clg_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_clg_rec := p_clg_rec;
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
      p_clg_rec,                         -- IN
      l_clg_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CNTR_LVLNG_GRPS_B(
        id,
        org_id,
        currency_code,
        inf_id,
        ica_id,
        ibt_id,
        irm_id,
        iuv_id,
        object_version_number,
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
        effective_date_from,
        effective_date_to,
        ipl_id,
	legal_entity_id) -- for LE Uptake project 08-11-2006
      VALUES (
        l_clg_rec.id,
        l_clg_rec.org_id,
        l_clg_rec.currency_code,
        l_clg_rec.inf_id,
        l_clg_rec.ica_id,
        l_clg_rec.ibt_id,
        l_clg_rec.irm_id,
        l_clg_rec.iuv_id,
        l_clg_rec.object_version_number,
        l_clg_rec.attribute_category,
        l_clg_rec.attribute1,
        l_clg_rec.attribute2,
        l_clg_rec.attribute3,
        l_clg_rec.attribute4,
        l_clg_rec.attribute5,
        l_clg_rec.attribute6,
        l_clg_rec.attribute7,
        l_clg_rec.attribute8,
        l_clg_rec.attribute9,
        l_clg_rec.attribute10,
        l_clg_rec.attribute11,
        l_clg_rec.attribute12,
        l_clg_rec.attribute13,
        l_clg_rec.attribute14,
        l_clg_rec.attribute15,
        l_clg_rec.created_by,
        l_clg_rec.creation_date,
        l_clg_rec.last_updated_by,
        l_clg_rec.last_update_date,
        l_clg_rec.last_update_login,
        l_clg_rec.effective_date_from,
        l_clg_rec.effective_date_to,
        l_clg_rec.ipl_id,
	l_clg_rec.legal_entity_id); -- for LE Uptake project 08-11-2006
    -- Set OUT values
    x_clg_rec := l_clg_rec;
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
  -------------------------------------------
  -- insert_row for:OKL_CNTR_LVLNG_GRPS_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cntr_lvlng_grps_tl_rec   IN OklCntrLvlngGrpsTlRecType,
    x_okl_cntr_lvlng_grps_tl_rec   OUT NOCOPY OklCntrLvlngGrpsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_cntr_lvlng_grps_tl_rec   OklCntrLvlngGrpsTlRecType := p_okl_cntr_lvlng_grps_tl_rec;
    ldefoklcntrlvlnggrpstlrec      OklCntrLvlngGrpsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_GRPS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cntr_lvlng_grps_tl_rec IN  OklCntrLvlngGrpsTlRecType,
      x_okl_cntr_lvlng_grps_tl_rec OUT NOCOPY OklCntrLvlngGrpsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cntr_lvlng_grps_tl_rec := p_okl_cntr_lvlng_grps_tl_rec;
      x_okl_cntr_lvlng_grps_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_cntr_lvlng_grps_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_cntr_lvlng_grps_tl_rec,      -- IN
      l_okl_cntr_lvlng_grps_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_cntr_lvlng_grps_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_CNTR_LVLNG_GRPS_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          name,
          description,
          private_label_logo_url,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_cntr_lvlng_grps_tl_rec.id,
          l_okl_cntr_lvlng_grps_tl_rec.LANGUAGE,
          l_okl_cntr_lvlng_grps_tl_rec.source_lang,
          l_okl_cntr_lvlng_grps_tl_rec.sfwt_flag,
          l_okl_cntr_lvlng_grps_tl_rec.name,
          l_okl_cntr_lvlng_grps_tl_rec.description,
          l_okl_cntr_lvlng_grps_tl_rec.private_label_logo_url,
          l_okl_cntr_lvlng_grps_tl_rec.created_by,
          l_okl_cntr_lvlng_grps_tl_rec.creation_date,
          l_okl_cntr_lvlng_grps_tl_rec.last_updated_by,
          l_okl_cntr_lvlng_grps_tl_rec.last_update_date,
          l_okl_cntr_lvlng_grps_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_cntr_lvlng_grps_tl_rec := l_okl_cntr_lvlng_grps_tl_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_CNTR_LVLNG_GRPS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_rec                     IN clgv_rec_type,
    x_clgv_rec                     OUT NOCOPY clgv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_clgv_rec                     clgv_rec_type;
    l_def_clgv_rec                 clgv_rec_type;
    l_clg_rec                      clg_rec_type;
    lx_clg_rec                     clg_rec_type;
    l_okl_cntr_lvlng_grps_tl_rec   OklCntrLvlngGrpsTlRecType;
    lx_okl_cntr_lvlng_grps_tl_rec  OklCntrLvlngGrpsTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_clgv_rec	IN clgv_rec_type
    ) RETURN clgv_rec_type IS
      l_clgv_rec	clgv_rec_type := p_clgv_rec;
    BEGIN
      l_clgv_rec.CREATION_DATE := SYSDATE;
      l_clgv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_clgv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_clgv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_clgv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_clgv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_GRPS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_clgv_rec IN  clgv_rec_type,
      x_clgv_rec OUT NOCOPY clgv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_clgv_rec := p_clgv_rec;
      x_clgv_rec.OBJECT_VERSION_NUMBER := 1;
      x_clgv_rec.SFWT_FLAG := 'N';
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
    l_clgv_rec := null_out_defaults(p_clgv_rec);
    -- Set primary key value
    l_clgv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_clgv_rec,                        -- IN
      l_def_clgv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_clgv_rec);

    --- If any errors happen abort API
    IF (l_return_status <> 'S') THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_clgv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --Do not change the position of the fill_who_columns
    l_def_clgv_rec := fill_who_columns(l_def_clgv_rec);
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_clgv_rec, l_clg_rec);
    migrate(l_def_clgv_rec, l_okl_cntr_lvlng_grps_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_clg_rec,
      lx_clg_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_clg_rec, l_def_clgv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cntr_lvlng_grps_tl_rec,
      lx_okl_cntr_lvlng_grps_tl_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_cntr_lvlng_grps_tl_rec, l_def_clgv_rec);
    -- Set OUT values
    x_clgv_rec := l_def_clgv_rec;
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
  -- PL/SQL TBL insert_row for:CLGV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_tbl                     IN clgv_tbl_type,
    x_clgv_tbl                     OUT NOCOPY clgv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clgv_tbl.COUNT > 0) THEN
      i := p_clgv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clgv_rec                     => p_clgv_tbl(i),
          x_clgv_rec                     => x_clgv_tbl(i));
        EXIT WHEN (i = p_clgv_tbl.LAST);
        i := p_clgv_tbl.NEXT(i);
      END LOOP;
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
  ----------------------------------------
  -- lock_row for:OKL_CNTR_LVLNG_GRPS_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clg_rec                      IN clg_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_clg_rec IN clg_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CNTR_LVLNG_GRPS_B
     WHERE ID = p_clg_rec.id
       AND OBJECT_VERSION_NUMBER = p_clg_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_clg_rec IN clg_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CNTR_LVLNG_GRPS_B
    WHERE ID = p_clg_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_CNTR_LVLNG_GRPS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_CNTR_LVLNG_GRPS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_clg_rec);
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
      OPEN lchk_csr(p_clg_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_clg_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_clg_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKL_CNTR_LVLNG_GRPS_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cntr_lvlng_grps_tl_rec   IN OklCntrLvlngGrpsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_cntr_lvlng_grps_tl_rec IN OklCntrLvlngGrpsTlRecType) IS
    SELECT *
      FROM OKL_CNTR_LVLNG_GRPS_TL
     WHERE ID = p_okl_cntr_lvlng_grps_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
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
      OPEN lock_csr(p_okl_cntr_lvlng_grps_tl_rec);
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
  ----------------------------------------
  -- lock_row for:OKL_CNTR_LVLNG_GRPS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_rec                     IN clgv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_clg_rec                      clg_rec_type;
    l_okl_cntr_lvlng_grps_tl_rec   OklCntrLvlngGrpsTlRecType;
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
    migrate(p_clgv_rec, l_clg_rec);
    migrate(p_clgv_rec, l_okl_cntr_lvlng_grps_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_clg_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cntr_lvlng_grps_tl_rec
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
  -- PL/SQL TBL lock_row for:CLGV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_tbl                     IN clgv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clgv_tbl.COUNT > 0) THEN
      i := p_clgv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clgv_rec                     => p_clgv_tbl(i));
        EXIT WHEN (i = p_clgv_tbl.LAST);
        i := p_clgv_tbl.NEXT(i);
      END LOOP;
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
  ------------------------------------------
  -- update_row for:OKL_CNTR_LVLNG_GRPS_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clg_rec                      IN clg_rec_type,
    x_clg_rec                      OUT NOCOPY clg_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_clg_rec                      clg_rec_type := p_clg_rec;
    l_def_clg_rec                  clg_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_clg_rec	IN clg_rec_type,
      x_clg_rec	OUT NOCOPY clg_rec_type
    ) RETURN VARCHAR2 IS
      l_clg_rec                      clg_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_clg_rec := p_clg_rec;
      -- Get current database values
      l_clg_rec := get_rec(p_clg_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_clg_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.id := l_clg_rec.id;
      END IF;
      IF (x_clg_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.org_id := l_clg_rec.org_id;
      END IF;
      IF (x_clg_rec.currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.currency_code := l_clg_rec.currency_code;
      END IF;
      IF (x_clg_rec.inf_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.inf_id := l_clg_rec.inf_id;
      END IF;
      IF (x_clg_rec.ica_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.ica_id := l_clg_rec.ica_id;
      END IF;
      IF (x_clg_rec.ibt_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.ibt_id := l_clg_rec.ibt_id;
      END IF;
      IF (x_clg_rec.irm_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.irm_id := l_clg_rec.irm_id;
      END IF;
      IF (x_clg_rec.iuv_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.iuv_id := l_clg_rec.iuv_id;
      END IF;
      IF (x_clg_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.object_version_number := l_clg_rec.object_version_number;
      END IF;
      IF (x_clg_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute_category := l_clg_rec.attribute_category;
      END IF;
      IF (x_clg_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute1 := l_clg_rec.attribute1;
      END IF;
      IF (x_clg_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute2 := l_clg_rec.attribute2;
      END IF;
      IF (x_clg_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute3 := l_clg_rec.attribute3;
      END IF;
      IF (x_clg_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute4 := l_clg_rec.attribute4;
      END IF;
      IF (x_clg_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute5 := l_clg_rec.attribute5;
      END IF;
      IF (x_clg_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute6 := l_clg_rec.attribute6;
      END IF;
      IF (x_clg_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute7 := l_clg_rec.attribute7;
      END IF;
      IF (x_clg_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute8 := l_clg_rec.attribute8;
      END IF;
      IF (x_clg_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute9 := l_clg_rec.attribute9;
      END IF;
      IF (x_clg_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute10 := l_clg_rec.attribute10;
      END IF;
      IF (x_clg_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute11 := l_clg_rec.attribute11;
      END IF;
      IF (x_clg_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute12 := l_clg_rec.attribute12;
      END IF;
      IF (x_clg_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute13 := l_clg_rec.attribute13;
      END IF;
      IF (x_clg_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute14 := l_clg_rec.attribute14;
      END IF;
      IF (x_clg_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clg_rec.attribute15 := l_clg_rec.attribute15;
      END IF;
      IF (x_clg_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.created_by := l_clg_rec.created_by;
      END IF;
      IF (x_clg_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_clg_rec.creation_date := l_clg_rec.creation_date;
      END IF;
      IF (x_clg_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.last_updated_by := l_clg_rec.last_updated_by;
      END IF;
      IF (x_clg_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_clg_rec.last_update_date := l_clg_rec.last_update_date;
      END IF;
      IF (x_clg_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.last_update_login := l_clg_rec.last_update_login;
      END IF;
      IF (x_clg_rec.effective_date_from = Okc_Api.G_MISS_DATE)
      THEN
        x_clg_rec.effective_date_from := l_clg_rec.effective_date_from;
      END IF;
      IF (x_clg_rec.effective_date_to = Okc_Api.G_MISS_DATE)
      THEN
        x_clg_rec.effective_date_to := l_clg_rec.effective_date_to;
      END IF;
      IF (x_clg_rec.ipl_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.ipl_id := l_clg_rec.ipl_id;
      END IF;
      -- for LE Uptake project 08-11-2006
      IF (x_clg_rec.legal_entity_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clg_rec.legal_entity_id := l_clg_rec.legal_entity_id;
      END IF;
      -- for LE Uptake project 08-11-2006
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_GRPS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_clg_rec IN  clg_rec_type,
      x_clg_rec OUT NOCOPY clg_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_clg_rec := p_clg_rec;
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
      p_clg_rec,                         -- IN
      l_clg_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_clg_rec, l_def_clg_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CNTR_LVLNG_GRPS_B
    SET ORG_ID = l_def_clg_rec.org_id,
        CURRENCY_CODE = l_def_clg_rec.currency_code,
        INF_ID = l_def_clg_rec.inf_id,
        ICA_ID = l_def_clg_rec.ica_id,
        IBT_ID = l_def_clg_rec.ibt_id,
        IRM_ID = l_def_clg_rec.irm_id,
        IUV_ID = l_def_clg_rec.iuv_id,
        OBJECT_VERSION_NUMBER = l_def_clg_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_clg_rec.attribute_category,
        ATTRIBUTE1 = l_def_clg_rec.attribute1,
        ATTRIBUTE2 = l_def_clg_rec.attribute2,
        ATTRIBUTE3 = l_def_clg_rec.attribute3,
        ATTRIBUTE4 = l_def_clg_rec.attribute4,
        ATTRIBUTE5 = l_def_clg_rec.attribute5,
        ATTRIBUTE6 = l_def_clg_rec.attribute6,
        ATTRIBUTE7 = l_def_clg_rec.attribute7,
        ATTRIBUTE8 = l_def_clg_rec.attribute8,
        ATTRIBUTE9 = l_def_clg_rec.attribute9,
        ATTRIBUTE10 = l_def_clg_rec.attribute10,
        ATTRIBUTE11 = l_def_clg_rec.attribute11,
        ATTRIBUTE12 = l_def_clg_rec.attribute12,
        ATTRIBUTE13 = l_def_clg_rec.attribute13,
        ATTRIBUTE14 = l_def_clg_rec.attribute14,
        ATTRIBUTE15 = l_def_clg_rec.attribute15,
        CREATED_BY = l_def_clg_rec.created_by,
        CREATION_DATE = l_def_clg_rec.creation_date,
        LAST_UPDATED_BY = l_def_clg_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_clg_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_clg_rec.last_update_login,
        EFFECTIVE_DATE_FROM = l_def_clg_rec.effective_date_from,
        EFFECTIVE_DATE_TO = l_def_clg_rec.effective_date_to,
        IPL_ID = l_def_clg_rec.ipl_id,
	LEGAL_ENTITY_ID = l_def_clg_rec.legal_entity_id -- for LE Uptake project 08-11-2006
    WHERE ID = l_def_clg_rec.id;

    x_clg_rec := l_def_clg_rec;
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
  -------------------------------------------
  -- update_row for:OKL_CNTR_LVLNG_GRPS_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cntr_lvlng_grps_tl_rec   IN OklCntrLvlngGrpsTlRecType,
    x_okl_cntr_lvlng_grps_tl_rec   OUT NOCOPY OklCntrLvlngGrpsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_cntr_lvlng_grps_tl_rec   OklCntrLvlngGrpsTlRecType := p_okl_cntr_lvlng_grps_tl_rec;
    ldefoklcntrlvlnggrpstlrec      OklCntrLvlngGrpsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_cntr_lvlng_grps_tl_rec	IN OklCntrLvlngGrpsTlRecType,
      x_okl_cntr_lvlng_grps_tl_rec	OUT NOCOPY OklCntrLvlngGrpsTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_cntr_lvlng_grps_tl_rec   OklCntrLvlngGrpsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cntr_lvlng_grps_tl_rec := p_okl_cntr_lvlng_grps_tl_rec;
      -- Get current database values
      l_okl_cntr_lvlng_grps_tl_rec := get_rec(p_okl_cntr_lvlng_grps_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.id := l_okl_cntr_lvlng_grps_tl_rec.id;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.LANGUAGE = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.LANGUAGE := l_okl_cntr_lvlng_grps_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.source_lang = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.source_lang := l_okl_cntr_lvlng_grps_tl_rec.source_lang;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.sfwt_flag := l_okl_cntr_lvlng_grps_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.name = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.name := l_okl_cntr_lvlng_grps_tl_rec.name;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.description := l_okl_cntr_lvlng_grps_tl_rec.description;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.private_label_logo_url = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.private_label_logo_url := l_okl_cntr_lvlng_grps_tl_rec.private_label_logo_url;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.created_by := l_okl_cntr_lvlng_grps_tl_rec.created_by;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.creation_date := l_okl_cntr_lvlng_grps_tl_rec.creation_date;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.last_updated_by := l_okl_cntr_lvlng_grps_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.last_update_date := l_okl_cntr_lvlng_grps_tl_rec.last_update_date;
      END IF;
      IF (x_okl_cntr_lvlng_grps_tl_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_cntr_lvlng_grps_tl_rec.last_update_login := l_okl_cntr_lvlng_grps_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_GRPS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cntr_lvlng_grps_tl_rec IN  OklCntrLvlngGrpsTlRecType,
      x_okl_cntr_lvlng_grps_tl_rec OUT NOCOPY OklCntrLvlngGrpsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cntr_lvlng_grps_tl_rec := p_okl_cntr_lvlng_grps_tl_rec;
      x_okl_cntr_lvlng_grps_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_cntr_lvlng_grps_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_cntr_lvlng_grps_tl_rec,      -- IN
      l_okl_cntr_lvlng_grps_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_cntr_lvlng_grps_tl_rec, ldefoklcntrlvlnggrpstlrec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CNTR_LVLNG_GRPS_TL
    SET NAME = ldefoklcntrlvlnggrpstlrec.name,
        DESCRIPTION = ldefoklcntrlvlnggrpstlrec.description,
        PRIVATE_LABEL_LOGO_URL = ldefoklcntrlvlnggrpstlrec.private_label_logo_url,
        CREATED_BY = ldefoklcntrlvlnggrpstlrec.created_by,
        CREATION_DATE = ldefoklcntrlvlnggrpstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklcntrlvlnggrpstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklcntrlvlnggrpstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklcntrlvlnggrpstlrec.last_update_login
    WHERE ID = ldefoklcntrlvlnggrpstlrec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_CNTR_LVLNG_GRPS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklcntrlvlnggrpstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_cntr_lvlng_grps_tl_rec := ldefoklcntrlvlnggrpstlrec;
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
  ------------------------------------------
  -- update_row for:OKL_CNTR_LVLNG_GRPS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_rec                     IN clgv_rec_type,
    x_clgv_rec                     OUT NOCOPY clgv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_clgv_rec                     clgv_rec_type := p_clgv_rec;
    l_def_clgv_rec                 clgv_rec_type;
    l_okl_cntr_lvlng_grps_tl_rec   OklCntrLvlngGrpsTlRecType;
    lx_okl_cntr_lvlng_grps_tl_rec  OklCntrLvlngGrpsTlRecType;
    l_clg_rec                      clg_rec_type;
    lx_clg_rec                     clg_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_clgv_rec	IN clgv_rec_type
    ) RETURN clgv_rec_type IS
      l_clgv_rec	clgv_rec_type := p_clgv_rec;
    BEGIN
      l_clgv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_clgv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_clgv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_clgv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_clgv_rec	IN clgv_rec_type,
      x_clgv_rec	OUT NOCOPY clgv_rec_type
    ) RETURN VARCHAR2 IS
      l_clgv_rec                     clgv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_clgv_rec := p_clgv_rec;
      -- Get current database values
      l_clgv_rec := get_rec(p_clgv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_clgv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.id := l_clgv_rec.id;
      END IF;
      IF (x_clgv_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.org_id := l_clgv_rec.org_id;
      END IF;
      IF (x_clgv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.object_version_number := l_clgv_rec.object_version_number;
      END IF;
      IF (x_clgv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.sfwt_flag := l_clgv_rec.sfwt_flag;
      END IF;
      IF (x_clgv_rec.inf_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.inf_id := l_clgv_rec.inf_id;
      END IF;
      IF (x_clgv_rec.ica_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.ica_id := l_clgv_rec.ica_id;
      END IF;
      IF (x_clgv_rec.ibt_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.ibt_id := l_clgv_rec.ibt_id;
      END IF;
      IF (x_clgv_rec.currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.currency_code := l_clgv_rec.currency_code;
      END IF;
      IF (x_clgv_rec.irm_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.irm_id := l_clgv_rec.irm_id;
      END IF;
      IF (x_clgv_rec.iuv_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.iuv_id := l_clgv_rec.iuv_id;
      END IF;
      IF (x_clgv_rec.name = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.name := l_clgv_rec.name;
      END IF;
      IF (x_clgv_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.description := l_clgv_rec.description;
      END IF;
      IF (x_clgv_rec.private_label_logo_url = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.private_label_logo_url := l_clgv_rec.private_label_logo_url;
      END IF;
      IF (x_clgv_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute_category := l_clgv_rec.attribute_category;
      END IF;
      IF (x_clgv_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute1 := l_clgv_rec.attribute1;
      END IF;
      IF (x_clgv_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute2 := l_clgv_rec.attribute2;
      END IF;
      IF (x_clgv_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute3 := l_clgv_rec.attribute3;
      END IF;
      IF (x_clgv_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute4 := l_clgv_rec.attribute4;
      END IF;
      IF (x_clgv_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute5 := l_clgv_rec.attribute5;
      END IF;
      IF (x_clgv_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute6 := l_clgv_rec.attribute6;
      END IF;
      IF (x_clgv_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute7 := l_clgv_rec.attribute7;
      END IF;
      IF (x_clgv_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute8 := l_clgv_rec.attribute8;
      END IF;
      IF (x_clgv_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute9 := l_clgv_rec.attribute9;
      END IF;
      IF (x_clgv_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute10 := l_clgv_rec.attribute10;
      END IF;
      IF (x_clgv_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute11 := l_clgv_rec.attribute11;
      END IF;
      IF (x_clgv_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute12 := l_clgv_rec.attribute12;
      END IF;
      IF (x_clgv_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute13 := l_clgv_rec.attribute13;
      END IF;
      IF (x_clgv_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute14 := l_clgv_rec.attribute14;
      END IF;
      IF (x_clgv_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_clgv_rec.attribute15 := l_clgv_rec.attribute15;
      END IF;
      IF (x_clgv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.created_by := l_clgv_rec.created_by;
      END IF;
      IF (x_clgv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_clgv_rec.creation_date := l_clgv_rec.creation_date;
      END IF;
      IF (x_clgv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.last_updated_by := l_clgv_rec.last_updated_by;
      END IF;
      IF (x_clgv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_clgv_rec.last_update_date := l_clgv_rec.last_update_date;
      END IF;
      IF (x_clgv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.last_update_login := l_clgv_rec.last_update_login;
      END IF;
      IF (x_clgv_rec.effective_date_from = Okc_Api.G_MISS_DATE)
      THEN
        x_clgv_rec.effective_date_from := l_clgv_rec.effective_date_from;
      END IF;
      IF (x_clgv_rec.effective_date_to = Okc_Api.G_MISS_DATE)
      THEN
        x_clgv_rec.effective_date_to := l_clgv_rec.effective_date_to;
      END IF;
      IF (x_clgv_rec.ipl_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.ipl_id := l_clgv_rec.ipl_id;
      END IF;
      -- for LE Uptake project 08-11-2006
      IF (x_clgv_rec.legal_entity_id = Okc_Api.G_MISS_NUM)
      THEN
        x_clgv_rec.legal_entity_id := l_clgv_rec.legal_entity_id;
      END IF;
      -- for LE Uptake project 08-11-2006
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_GRPS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_clgv_rec IN  clgv_rec_type,
      x_clgv_rec OUT NOCOPY clgv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_clgv_rec := p_clgv_rec;
      x_clgv_rec.OBJECT_VERSION_NUMBER := NVL(x_clgv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_clgv_rec,                        -- IN
      l_clgv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_clgv_rec, l_def_clgv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_clgv_rec := fill_who_columns(l_def_clgv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_clgv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_clgv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_clgv_rec, l_okl_cntr_lvlng_grps_tl_rec);
    migrate(l_def_clgv_rec, l_clg_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cntr_lvlng_grps_tl_rec,
      lx_okl_cntr_lvlng_grps_tl_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_cntr_lvlng_grps_tl_rec, l_def_clgv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_clg_rec,
      lx_clg_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_clg_rec, l_def_clgv_rec);
    x_clgv_rec := l_def_clgv_rec;
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
  -- PL/SQL TBL update_row for:CLGV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_tbl                     IN clgv_tbl_type,
    x_clgv_tbl                     OUT NOCOPY clgv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clgv_tbl.COUNT > 0) THEN
      i := p_clgv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clgv_rec                     => p_clgv_tbl(i),
          x_clgv_rec                     => x_clgv_tbl(i));
        EXIT WHEN (i = p_clgv_tbl.LAST);
        i := p_clgv_tbl.NEXT(i);
      END LOOP;
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
  ------------------------------------------
  -- delete_row for:OKL_CNTR_LVLNG_GRPS_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clg_rec                      IN clg_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_clg_rec                      clg_rec_type:= p_clg_rec;
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
    DELETE FROM OKL_CNTR_LVLNG_GRPS_B
     WHERE ID = l_clg_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKL_CNTR_LVLNG_GRPS_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cntr_lvlng_grps_tl_rec   IN OklCntrLvlngGrpsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_cntr_lvlng_grps_tl_rec   OklCntrLvlngGrpsTlRecType:= p_okl_cntr_lvlng_grps_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_GRPS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cntr_lvlng_grps_tl_rec IN  OklCntrLvlngGrpsTlRecType,
      x_okl_cntr_lvlng_grps_tl_rec OUT NOCOPY OklCntrLvlngGrpsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cntr_lvlng_grps_tl_rec := p_okl_cntr_lvlng_grps_tl_rec;
      x_okl_cntr_lvlng_grps_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_cntr_lvlng_grps_tl_rec,      -- IN
      l_okl_cntr_lvlng_grps_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_CNTR_LVLNG_GRPS_TL
     WHERE ID = l_okl_cntr_lvlng_grps_tl_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_CNTR_LVLNG_GRPS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_rec                     IN clgv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_clgv_rec                     clgv_rec_type := p_clgv_rec;
    l_okl_cntr_lvlng_grps_tl_rec   OklCntrLvlngGrpsTlRecType;
    l_clg_rec                      clg_rec_type;
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
    migrate(l_clgv_rec, l_okl_cntr_lvlng_grps_tl_rec);
    migrate(l_clgv_rec, l_clg_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cntr_lvlng_grps_tl_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_clg_rec
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
  -- PL/SQL TBL delete_row for:CLGV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_tbl                     IN clgv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clgv_tbl.COUNT > 0) THEN
      i := p_clgv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clgv_rec                     => p_clgv_tbl(i));
        EXIT WHEN (i = p_clgv_tbl.LAST);
        i := p_clgv_tbl.NEXT(i);
      END LOOP;
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
END Okl_Clg_Pvt;

/
