--------------------------------------------------------
--  DDL for Package Body OKL_INF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INF_PVT" AS
/* $Header: OKLSINFB.pls 120.7 2008/01/04 05:56:24 zrehman noship $ */


-- Checking Unique Key
  FUNCTION IS_UNIQUE (p_infv_rec infv_rec_type) RETURN VARCHAR2
  IS
    CURSOR l_inf_csr IS
		 SELECT 'x'
		 FROM okl_invoice_formats_v
		 WHERE name = p_infv_rec.name
		 AND   id <> NVL(p_infv_rec.id,-99999);

    l_return_status     VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;
  BEGIN
    -- check for unique product and location
        OPEN l_inf_csr;
        FETCH l_inf_csr INTO l_dummy;
	   l_found := l_inf_csr%FOUND;
	   CLOSE l_inf_csr;

    IF (l_found) THEN
  	    okl_api.SET_MESSAGE(p_app_name		=> 'OKC', --g_app_name,
					    p_msg_name		=> 'OKC_VALUE_NOT_UNIQUE',
					    p_token2		=> 'COL_NAME',
					    p_token2_value	=> p_infv_rec.name);
	  -- notify caller of an error
	  l_return_status := okl_api.G_RET_STS_ERROR;
    END IF;
    RETURN (l_return_status);

  EXCEPTION
    WHEN OTHERS THEN
	 RETURN (l_return_status);
  END IS_UNIQUE;
-- Validate not null value for ID

PROCEDURE validate_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_infv_rec 		IN	infv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := okl_api.G_RET_STS_SUCCESS;

-- data is required
IF(p_infv_rec.id IS NULL) OR (p_infv_rec.id = okl_api.G_MISS_NUM) THEN
	okl_api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'id');

-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

END validate_id;


-- Validate not null value for Version Number

PROCEDURE validate_object_version_number(x_return_status OUT NOCOPY VARCHAR2,
			 p_infv_rec 		IN	infv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := okl_api.G_RET_STS_SUCCESS;

-- data is required
IF(p_infv_rec.object_version_number IS NULL) OR (p_infv_rec.object_version_number = okl_api.G_MISS_NUM) THEN
	okl_api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'object_version_number');

-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;
END validate_object_version_number;

PROCEDURE validate_name(x_return_status OUT NOCOPY VARCHAR2,
			 p_infv_rec 		IN	infv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := okl_api.G_RET_STS_SUCCESS;

-- data is required
IF(p_infv_rec.name IS NULL) OR (p_infv_rec.name = okl_api.G_MISS_CHAR) THEN
	okl_api.SET_MESSAGE(p_app_name	=> 'OKC',
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'name');

-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_ERROR;

-- halt further validation of this column
--	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

END validate_name;



PROCEDURE validate_contract_level_yn(x_return_status OUT NOCOPY VARCHAR2,
			 p_infv_rec 		IN	infv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := okl_api.G_RET_STS_SUCCESS;

-- data is required
IF(p_infv_rec.contract_level_yn IS NULL) OR (p_infv_rec.contract_level_yn = okl_api.G_MISS_CHAR) THEN
	okl_api.SET_MESSAGE(p_app_name	=> 'OKC',
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'contract_level_yn');

-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_ERROR;

-- halt further validation of this column
--	RAISE G_EXCEPTION_HALT_VALIDATION;
ELSE
	x_return_status := Okl_Util.CHECK_DOMAIN_YN(p_infv_rec.contract_level_yn);

END IF;

END validate_contract_level_yn;


PROCEDURE validate_ilt_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_infv_rec 		IN	infv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_infv_csr IS
	SELECT 'x'
	FROM OKL_INVC_LINE_TYPES_V
	WHERE id = p_infv_rec.ilt_id;

BEGIN
-- initialize return status
x_return_status := okl_api.G_RET_STS_SUCCESS;

/*
-- data is required
IF(p_infv_rec.ilt_id IS NULL) OR (p_infv_rec.ilt_id = okl_api.G_MISS_NUM) THEN
	okl_api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'ilt_id');

-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;


-- enforce foreign key
OPEN l_infv_csr;
	FETCH l_infv_csr INTO l_dummy_var;
CLOSE l_infv_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	okl_api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'ilt_id',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_INVOICE_FORMATS_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'OKL_INVC_LINE_TYPES_V');

-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_ERROR;
	END IF;
*/

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
	x_return_status := 'U';
	NULL;

	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	okl_api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);


-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

-- verfiy that cursor was closed
	IF l_infv_csr%ISOPEN THEN
	  CLOSE l_infv_csr;
	END IF;

END validate_ilt_id;

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
    DELETE FROM OKL_INVOICE_FORMATS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_INV_FORMATS_ALL_B B  --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_INVOICE_FORMATS_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_INVOICE_FORMATS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_INVOICE_FORMATS_TL SUBB, OKL_INVOICE_FORMATS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_INVOICE_FORMATS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
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
            B.NAME,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_INVOICE_FORMATS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_INVOICE_FORMATS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVOICE_FORMATS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_inf_rec                      IN inf_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN inf_rec_type IS
    CURSOR inf_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CONTRACT_LEVEL_YN,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            START_DATE,
            END_DATE,
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
            LAST_UPDATE_LOGIN
      FROM Okl_Invoice_Formats_B
     WHERE okl_invoice_formats_b.id = p_id;
    l_inf_pk                       inf_pk_csr%ROWTYPE;
    l_inf_rec                      inf_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN inf_pk_csr (p_inf_rec.id);
    FETCH inf_pk_csr INTO
              l_inf_rec.ID,
              l_inf_rec.CONTRACT_LEVEL_YN,
              l_inf_rec.OBJECT_VERSION_NUMBER,
              l_inf_rec.ORG_ID,
              l_inf_rec.START_DATE,
              l_inf_rec.END_DATE,
              l_inf_rec.ATTRIBUTE_CATEGORY,
              l_inf_rec.ATTRIBUTE1,
              l_inf_rec.ATTRIBUTE2,
              l_inf_rec.ATTRIBUTE3,
              l_inf_rec.ATTRIBUTE4,
              l_inf_rec.ATTRIBUTE5,
              l_inf_rec.ATTRIBUTE6,
              l_inf_rec.ATTRIBUTE7,
              l_inf_rec.ATTRIBUTE8,
              l_inf_rec.ATTRIBUTE9,
              l_inf_rec.ATTRIBUTE10,
              l_inf_rec.ATTRIBUTE11,
              l_inf_rec.ATTRIBUTE12,
              l_inf_rec.ATTRIBUTE13,
              l_inf_rec.ATTRIBUTE14,
              l_inf_rec.ATTRIBUTE15,
              l_inf_rec.CREATED_BY,
              l_inf_rec.CREATION_DATE,
              l_inf_rec.LAST_UPDATED_BY,
              l_inf_rec.LAST_UPDATE_DATE,
              l_inf_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := inf_pk_csr%NOTFOUND;
    CLOSE inf_pk_csr;
    RETURN(l_inf_rec);
  END get_rec;

  FUNCTION get_rec (
    p_inf_rec                      IN inf_rec_type
  ) RETURN inf_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_inf_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVOICE_FORMATS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_invoice_formats_tl_rec   IN OklInvoiceFormatsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklInvoiceFormatsTlRecType IS
    CURSOR okl_invoice_formats_tl_pk_csr (p_id                 IN NUMBER,
                                          p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Invoice_Formats_Tl
     WHERE okl_invoice_formats_tl.id = p_id
       AND okl_invoice_formats_tl.LANGUAGE = p_language;
    l_okl_invoice_formats_tl_pk    okl_invoice_formats_tl_pk_csr%ROWTYPE;
    l_okl_invoice_formats_tl_rec   OklInvoiceFormatsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_invoice_formats_tl_pk_csr (p_okl_invoice_formats_tl_rec.id,
                                        p_okl_invoice_formats_tl_rec.LANGUAGE);
    FETCH okl_invoice_formats_tl_pk_csr INTO
              l_okl_invoice_formats_tl_rec.ID,
              l_okl_invoice_formats_tl_rec.LANGUAGE,
              l_okl_invoice_formats_tl_rec.SOURCE_LANG,
              l_okl_invoice_formats_tl_rec.SFWT_FLAG,
              l_okl_invoice_formats_tl_rec.NAME,
              l_okl_invoice_formats_tl_rec.DESCRIPTION,
              l_okl_invoice_formats_tl_rec.CREATED_BY,
              l_okl_invoice_formats_tl_rec.CREATION_DATE,
              l_okl_invoice_formats_tl_rec.LAST_UPDATED_BY,
              l_okl_invoice_formats_tl_rec.LAST_UPDATE_DATE,
              l_okl_invoice_formats_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_invoice_formats_tl_pk_csr%NOTFOUND;
    CLOSE okl_invoice_formats_tl_pk_csr;
    RETURN(l_okl_invoice_formats_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_invoice_formats_tl_rec   IN OklInvoiceFormatsTlRecType
  ) RETURN OklInvoiceFormatsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_invoice_formats_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVOICE_FORMATS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_infv_rec                     IN infv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN infv_rec_type IS
    CURSOR okl_infv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
            CONTRACT_LEVEL_YN,
            ORG_ID,
            START_DATE,
            END_DATE,
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
            LAST_UPDATE_LOGIN
      FROM Okl_Invoice_Formats_V
     WHERE okl_invoice_formats_v.id = p_id;
    l_okl_infv_pk                  okl_infv_pk_csr%ROWTYPE;
    l_infv_rec                     infv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_infv_pk_csr (p_infv_rec.id);
    FETCH okl_infv_pk_csr INTO
              l_infv_rec.ID,
              l_infv_rec.OBJECT_VERSION_NUMBER,
              l_infv_rec.SFWT_FLAG,
              l_infv_rec.NAME,
              l_infv_rec.DESCRIPTION,
              l_infv_rec.CONTRACT_LEVEL_YN,
              l_infv_rec.ORG_ID,
              l_infv_rec.START_DATE,
              l_infv_rec.END_DATE,
              l_infv_rec.ATTRIBUTE_CATEGORY,
              l_infv_rec.ATTRIBUTE1,
              l_infv_rec.ATTRIBUTE2,
              l_infv_rec.ATTRIBUTE3,
              l_infv_rec.ATTRIBUTE4,
              l_infv_rec.ATTRIBUTE5,
              l_infv_rec.ATTRIBUTE6,
              l_infv_rec.ATTRIBUTE7,
              l_infv_rec.ATTRIBUTE8,
              l_infv_rec.ATTRIBUTE9,
              l_infv_rec.ATTRIBUTE10,
              l_infv_rec.ATTRIBUTE11,
              l_infv_rec.ATTRIBUTE12,
              l_infv_rec.ATTRIBUTE13,
              l_infv_rec.ATTRIBUTE14,
              l_infv_rec.ATTRIBUTE15,
              l_infv_rec.CREATED_BY,
              l_infv_rec.CREATION_DATE,
              l_infv_rec.LAST_UPDATED_BY,
              l_infv_rec.LAST_UPDATE_DATE,
              l_infv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_infv_pk_csr%NOTFOUND;
    CLOSE okl_infv_pk_csr;
    RETURN(l_infv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_infv_rec                     IN infv_rec_type
  ) RETURN infv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_infv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INVOICE_FORMATS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_infv_rec	IN infv_rec_type
  ) RETURN infv_rec_type IS
    l_infv_rec	infv_rec_type := p_infv_rec;
  BEGIN
    IF (l_infv_rec.object_version_number = okl_api.G_MISS_NUM) THEN
      l_infv_rec.object_version_number := NULL;
    END IF;
    IF (l_infv_rec.ilt_id = okl_api.G_MISS_NUM) THEN
      l_infv_rec.ilt_id := NULL;
    END IF;
    IF (l_infv_rec.org_id = okl_api.G_MISS_NUM) THEN
      l_infv_rec.org_id := NULL;
    END IF;
    IF (l_infv_rec.sfwt_flag = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_infv_rec.name = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.name := NULL;
    END IF;
    IF (l_infv_rec.description = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.description := NULL;
    END IF;
    IF (l_infv_rec.contract_level_yn = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.contract_level_yn := NULL;
    END IF;
    IF (l_infv_rec.start_date = okl_api.G_MISS_DATE) THEN
      l_infv_rec.start_date := NULL;
    END IF;
    IF (l_infv_rec.end_date = okl_api.G_MISS_DATE) THEN
      l_infv_rec.end_date := NULL;
    END IF;
    IF (l_infv_rec.attribute_category = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute_category := NULL;
    END IF;
    IF (l_infv_rec.attribute1 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute1 := NULL;
    END IF;
    IF (l_infv_rec.attribute2 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute2 := NULL;
    END IF;
    IF (l_infv_rec.attribute3 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute3 := NULL;
    END IF;
    IF (l_infv_rec.attribute4 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute4 := NULL;
    END IF;
    IF (l_infv_rec.attribute5 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute5 := NULL;
    END IF;
    IF (l_infv_rec.attribute6 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute6 := NULL;
    END IF;
    IF (l_infv_rec.attribute7 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute7 := NULL;
    END IF;
    IF (l_infv_rec.attribute8 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute8 := NULL;
    END IF;
    IF (l_infv_rec.attribute9 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute9 := NULL;
    END IF;
    IF (l_infv_rec.attribute10 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute10 := NULL;
    END IF;
    IF (l_infv_rec.attribute11 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute11 := NULL;
    END IF;
    IF (l_infv_rec.attribute12 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute12 := NULL;
    END IF;
    IF (l_infv_rec.attribute13 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute13 := NULL;
    END IF;
    IF (l_infv_rec.attribute14 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute14 := NULL;
    END IF;
    IF (l_infv_rec.attribute15 = okl_api.G_MISS_CHAR) THEN
      l_infv_rec.attribute15 := NULL;
    END IF;
    IF (l_infv_rec.created_by = okl_api.G_MISS_NUM) THEN
      l_infv_rec.created_by := NULL;
    END IF;
    IF (l_infv_rec.creation_date = okl_api.G_MISS_DATE) THEN
      l_infv_rec.creation_date := NULL;
    END IF;
    IF (l_infv_rec.last_updated_by = okl_api.G_MISS_NUM) THEN
      l_infv_rec.last_updated_by := NULL;
    END IF;
    IF (l_infv_rec.last_update_date = okl_api.G_MISS_DATE) THEN
      l_infv_rec.last_update_date := NULL;
    END IF;
    IF (l_infv_rec.last_update_login = okl_api.G_MISS_NUM) THEN
      l_infv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_infv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_INVOICE_FORMATS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_infv_rec IN  infv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1)	:= okl_api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
     -- Call each column level validation

  validate_id(x_return_status => l_return_status,
			 	p_infv_rec =>	p_infv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_object_version_number(x_return_status => l_return_status,
			 	p_infv_rec =>	p_infv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_name(x_return_status => l_return_status,
			 	p_infv_rec =>	p_infv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_contract_level_yn(x_return_status => l_return_status,
			 	p_infv_rec =>	p_infv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  	 validate_ilt_id(x_return_status => l_return_status,
			 	p_infv_rec =>	p_infv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_INVOICE_FORMATS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_infv_rec IN infv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
      l_return_status := IS_UNIQUE(p_infv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN infv_rec_type,
    p_to	OUT NOCOPY inf_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.contract_level_yn := p_from.contract_level_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.ilt_id := p_from.ilt_id;
    p_to.org_id := p_from.org_id;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN inf_rec_type,
    p_to	OUT NOCOPY infv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.contract_level_yn := p_from.contract_level_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.ilt_id := p_from.ilt_id;
    p_to.org_id := p_from.org_id;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN infv_rec_type,
    p_to	OUT NOCOPY OklInvoiceFormatsTlRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN OklInvoiceFormatsTlRecType,
    p_to	OUT NOCOPY infv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
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
  -- validate_row for:OKL_INVOICE_FORMATS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_rec                     IN infv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_infv_rec                     infv_rec_type := p_infv_rec;
    l_inf_rec                      inf_rec_type;
    l_okl_invoice_formats_tl_rec   OklInvoiceFormatsTlRecType;
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
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_infv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_infv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
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
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:INFV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_tbl                     IN infv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_infv_tbl.COUNT > 0) THEN
      i := p_infv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_infv_rec                     => p_infv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_infv_tbl.LAST);
        i := p_infv_tbl.NEXT(i);
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
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- insert_row for:OKL_INVOICE_FORMATS_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inf_rec                      IN inf_rec_type,
    x_inf_rec                      OUT NOCOPY inf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_inf_rec                      inf_rec_type := p_inf_rec;
    l_def_inf_rec                  inf_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_FORMATS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_inf_rec IN  inf_rec_type,
      x_inf_rec OUT NOCOPY inf_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_inf_rec := p_inf_rec;
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
      p_inf_rec,                         -- IN
      l_inf_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_INVOICE_FORMATS_B(
        id,
        contract_level_yn,
        object_version_number,
        ilt_id,
        org_id,
        start_date,
        end_date,
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
        last_update_login)
      VALUES (
        l_inf_rec.id,
        l_inf_rec.contract_level_yn,
        l_inf_rec.object_version_number,
        l_inf_rec.ilt_id,
        NVL(l_inf_rec.org_id,MO_GLOBAL.GET_CURRENT_ORG_ID()),
        l_inf_rec.start_date,
        l_inf_rec.end_date,
        l_inf_rec.attribute_category,
        l_inf_rec.attribute1,
        l_inf_rec.attribute2,
        l_inf_rec.attribute3,
        l_inf_rec.attribute4,
        l_inf_rec.attribute5,
        l_inf_rec.attribute6,
        l_inf_rec.attribute7,
        l_inf_rec.attribute8,
        l_inf_rec.attribute9,
        l_inf_rec.attribute10,
        l_inf_rec.attribute11,
        l_inf_rec.attribute12,
        l_inf_rec.attribute13,
        l_inf_rec.attribute14,
        l_inf_rec.attribute15,
        l_inf_rec.created_by,
        l_inf_rec.creation_date,
        l_inf_rec.last_updated_by,
        l_inf_rec.last_update_date,
        l_inf_rec.last_update_login);
    -- Set OUT values
    x_inf_rec := l_inf_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E';
    NULL;
    /*
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
  END insert_row;
  -------------------------------------------
  -- insert_row for:OKL_INVOICE_FORMATS_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_formats_tl_rec   IN OklInvoiceFormatsTlRecType,
    x_okl_invoice_formats_tl_rec   OUT NOCOPY OklInvoiceFormatsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_invoice_formats_tl_rec   OklInvoiceFormatsTlRecType := p_okl_invoice_formats_tl_rec;
    ldefoklinvoiceformatstlrec     OklInvoiceFormatsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_FORMATS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invoice_formats_tl_rec IN  OklInvoiceFormatsTlRecType,
      x_okl_invoice_formats_tl_rec OUT NOCOPY OklInvoiceFormatsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_formats_tl_rec := p_okl_invoice_formats_tl_rec;
      x_okl_invoice_formats_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_invoice_formats_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_invoice_formats_tl_rec,      -- IN
      l_okl_invoice_formats_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_invoice_formats_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_INVOICE_FORMATS_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          name,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_invoice_formats_tl_rec.id,
          l_okl_invoice_formats_tl_rec.LANGUAGE,
          l_okl_invoice_formats_tl_rec.source_lang,
          l_okl_invoice_formats_tl_rec.sfwt_flag,
          l_okl_invoice_formats_tl_rec.name,
          l_okl_invoice_formats_tl_rec.description,
          l_okl_invoice_formats_tl_rec.created_by,
          l_okl_invoice_formats_tl_rec.creation_date,
          l_okl_invoice_formats_tl_rec.last_updated_by,
          l_okl_invoice_formats_tl_rec.last_update_date,
          l_okl_invoice_formats_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_invoice_formats_tl_rec := l_okl_invoice_formats_tl_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E';
      NULL;
      /*
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
  END insert_row;
  ------------------------------------------
  -- insert_row for:OKL_INVOICE_FORMATS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_rec                     IN infv_rec_type,
    x_infv_rec                     OUT NOCOPY infv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_infv_rec                     infv_rec_type;
    l_def_infv_rec                 infv_rec_type;
    l_inf_rec                      inf_rec_type;
    lx_inf_rec                     inf_rec_type;
    l_okl_invoice_formats_tl_rec   OklInvoiceFormatsTlRecType;
    lx_okl_invoice_formats_tl_rec  OklInvoiceFormatsTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_infv_rec	IN infv_rec_type
    ) RETURN infv_rec_type IS
      l_infv_rec	infv_rec_type := p_infv_rec;
    BEGIN
      l_infv_rec.CREATION_DATE := SYSDATE;
      l_infv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_infv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_infv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_infv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_infv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_FORMATS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_infv_rec IN  infv_rec_type,
      x_infv_rec OUT NOCOPY infv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_infv_rec := p_infv_rec;
      x_infv_rec.OBJECT_VERSION_NUMBER := 1;
      x_infv_rec.SFWT_FLAG := 'N';
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
    l_infv_rec := null_out_defaults(p_infv_rec);
    -- Set primary key value
    l_infv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_infv_rec,                        -- IN
      l_def_infv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_infv_rec := fill_who_columns(l_def_infv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_infv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_infv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_infv_rec, l_inf_rec);
    migrate(l_def_infv_rec, l_okl_invoice_formats_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_inf_rec,
      lx_inf_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_inf_rec, l_def_infv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_formats_tl_rec,
      lx_okl_invoice_formats_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_invoice_formats_tl_rec, l_def_infv_rec);
    -- Set OUT values
    x_infv_rec := l_def_infv_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E';
      /*
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
     */
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status := 'U';
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
     */
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:INFV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_tbl                     IN infv_tbl_type,
    x_infv_tbl                     OUT NOCOPY infv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_infv_tbl.COUNT > 0) THEN
      i := p_infv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_infv_rec                     => p_infv_tbl(i),
          x_infv_rec                     => x_infv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_infv_tbl.LAST);
        i := p_infv_tbl.NEXT(i);
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
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- lock_row for:OKL_INVOICE_FORMATS_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inf_rec                      IN inf_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_inf_rec IN inf_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INVOICE_FORMATS_B
     WHERE ID = p_inf_rec.id
       AND OBJECT_VERSION_NUMBER = p_inf_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_inf_rec IN inf_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INVOICE_FORMATS_B
    WHERE ID = p_inf_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INVOICE_FORMATS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INVOICE_FORMATS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
    BEGIN
      OPEN lock_csr(p_inf_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        okl_api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_inf_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_inf_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_inf_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      okl_api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
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
  END lock_row;
  -----------------------------------------
  -- lock_row for:OKL_INVOICE_FORMATS_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_formats_tl_rec   IN OklInvoiceFormatsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_invoice_formats_tl_rec IN OklInvoiceFormatsTlRecType) IS
    SELECT *
      FROM OKL_INVOICE_FORMATS_TL
     WHERE ID = p_okl_invoice_formats_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
    BEGIN
      OPEN lock_csr(p_okl_invoice_formats_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        okl_api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
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
  END lock_row;
  ----------------------------------------
  -- lock_row for:OKL_INVOICE_FORMATS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_rec                     IN infv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_inf_rec                      inf_rec_type;
    l_okl_invoice_formats_tl_rec   OklInvoiceFormatsTlRecType;
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
    migrate(p_infv_rec, l_inf_rec);
    migrate(p_infv_rec, l_okl_invoice_formats_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_inf_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_formats_tl_rec
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
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:INFV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_tbl                     IN infv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_infv_tbl.COUNT > 0) THEN
      i := p_infv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_infv_rec                     => p_infv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_infv_tbl.LAST);
        i := p_infv_tbl.NEXT(i);
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
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- update_row for:OKL_INVOICE_FORMATS_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inf_rec                      IN inf_rec_type,
    x_inf_rec                      OUT NOCOPY inf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_inf_rec                      inf_rec_type := p_inf_rec;
    l_def_inf_rec                  inf_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_inf_rec	IN inf_rec_type,
      x_inf_rec	OUT NOCOPY inf_rec_type
    ) RETURN VARCHAR2 IS
      l_inf_rec                      inf_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_inf_rec := p_inf_rec;
      -- Get current database values
      l_inf_rec := get_rec(p_inf_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_inf_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_inf_rec.id := l_inf_rec.id;
      END IF;
      IF (x_inf_rec.contract_level_yn = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.contract_level_yn := l_inf_rec.contract_level_yn;
      END IF;
      IF (x_inf_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_inf_rec.object_version_number := l_inf_rec.object_version_number;
      END IF;
      IF (x_inf_rec.ilt_id = okl_api.G_MISS_NUM)
      THEN
        x_inf_rec.ilt_id := l_inf_rec.ilt_id;
      END IF;
      IF (x_inf_rec.org_id = okl_api.G_MISS_NUM)
      THEN
        x_inf_rec.org_id := l_inf_rec.org_id;
      END IF;
      IF (x_inf_rec.start_date = okl_api.G_MISS_DATE)
      THEN
        x_inf_rec.start_date := l_inf_rec.start_date;
      END IF;
      IF (x_inf_rec.end_date = okl_api.G_MISS_DATE)
      THEN
        x_inf_rec.end_date := l_inf_rec.end_date;
      END IF;
      IF (x_inf_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute_category := l_inf_rec.attribute_category;
      END IF;
      IF (x_inf_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute1 := l_inf_rec.attribute1;
      END IF;
      IF (x_inf_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute2 := l_inf_rec.attribute2;
      END IF;
      IF (x_inf_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute3 := l_inf_rec.attribute3;
      END IF;
      IF (x_inf_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute4 := l_inf_rec.attribute4;
      END IF;
      IF (x_inf_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute5 := l_inf_rec.attribute5;
      END IF;
      IF (x_inf_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute6 := l_inf_rec.attribute6;
      END IF;
      IF (x_inf_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute7 := l_inf_rec.attribute7;
      END IF;
      IF (x_inf_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute8 := l_inf_rec.attribute8;
      END IF;
      IF (x_inf_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute9 := l_inf_rec.attribute9;
      END IF;
      IF (x_inf_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute10 := l_inf_rec.attribute10;
      END IF;
      IF (x_inf_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute11 := l_inf_rec.attribute11;
      END IF;
      IF (x_inf_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute12 := l_inf_rec.attribute12;
      END IF;
      IF (x_inf_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute13 := l_inf_rec.attribute13;
      END IF;
      IF (x_inf_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute14 := l_inf_rec.attribute14;
      END IF;
      IF (x_inf_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_inf_rec.attribute15 := l_inf_rec.attribute15;
      END IF;
      IF (x_inf_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_inf_rec.created_by := l_inf_rec.created_by;
      END IF;
      IF (x_inf_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_inf_rec.creation_date := l_inf_rec.creation_date;
      END IF;
      IF (x_inf_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_inf_rec.last_updated_by := l_inf_rec.last_updated_by;
      END IF;
      IF (x_inf_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_inf_rec.last_update_date := l_inf_rec.last_update_date;
      END IF;
      IF (x_inf_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_inf_rec.last_update_login := l_inf_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_FORMATS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_inf_rec IN  inf_rec_type,
      x_inf_rec OUT NOCOPY inf_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_inf_rec := p_inf_rec;
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
      p_inf_rec,                         -- IN
      l_inf_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_inf_rec, l_def_inf_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INVOICE_FORMATS_B
    SET CONTRACT_LEVEL_YN = l_def_inf_rec.contract_level_yn,
        OBJECT_VERSION_NUMBER = l_def_inf_rec.object_version_number,
        ILT_ID = l_def_inf_rec.ilt_id,
	ORG_ID = NVL(l_def_inf_rec.org_id,MO_GLOBAL.GET_CURRENT_ORG_ID()),
        START_DATE = l_def_inf_rec.start_date,
        END_DATE = l_def_inf_rec.end_date,
        ATTRIBUTE_CATEGORY = l_def_inf_rec.attribute_category,
        ATTRIBUTE1 = l_def_inf_rec.attribute1,
        ATTRIBUTE2 = l_def_inf_rec.attribute2,
        ATTRIBUTE3 = l_def_inf_rec.attribute3,
        ATTRIBUTE4 = l_def_inf_rec.attribute4,
        ATTRIBUTE5 = l_def_inf_rec.attribute5,
        ATTRIBUTE6 = l_def_inf_rec.attribute6,
        ATTRIBUTE7 = l_def_inf_rec.attribute7,
        ATTRIBUTE8 = l_def_inf_rec.attribute8,
        ATTRIBUTE9 = l_def_inf_rec.attribute9,
        ATTRIBUTE10 = l_def_inf_rec.attribute10,
        ATTRIBUTE11 = l_def_inf_rec.attribute11,
        ATTRIBUTE12 = l_def_inf_rec.attribute12,
        ATTRIBUTE13 = l_def_inf_rec.attribute13,
        ATTRIBUTE14 = l_def_inf_rec.attribute14,
        ATTRIBUTE15 = l_def_inf_rec.attribute15,
        CREATED_BY = l_def_inf_rec.created_by,
        CREATION_DATE = l_def_inf_rec.creation_date,
        LAST_UPDATED_BY = l_def_inf_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_inf_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_inf_rec.last_update_login
    WHERE ID = l_def_inf_rec.id;

    x_inf_rec := l_def_inf_rec;
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
  -------------------------------------------
  -- update_row for:OKL_INVOICE_FORMATS_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_formats_tl_rec   IN OklInvoiceFormatsTlRecType,
    x_okl_invoice_formats_tl_rec   OUT NOCOPY OklInvoiceFormatsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_invoice_formats_tl_rec   OklInvoiceFormatsTlRecType := p_okl_invoice_formats_tl_rec;
    ldefoklinvoiceformatstlrec     OklInvoiceFormatsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_invoice_formats_tl_rec	IN OklInvoiceFormatsTlRecType,
      x_okl_invoice_formats_tl_rec	OUT NOCOPY OklInvoiceFormatsTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_invoice_formats_tl_rec   OklInvoiceFormatsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_formats_tl_rec := p_okl_invoice_formats_tl_rec;
      -- Get current database values
      l_okl_invoice_formats_tl_rec := get_rec(p_okl_invoice_formats_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_okl_invoice_formats_tl_rec.id := l_okl_invoice_formats_tl_rec.id;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.LANGUAGE = okl_api.G_MISS_CHAR)
      THEN
        x_okl_invoice_formats_tl_rec.LANGUAGE := l_okl_invoice_formats_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.source_lang = okl_api.G_MISS_CHAR)
      THEN
        x_okl_invoice_formats_tl_rec.source_lang := l_okl_invoice_formats_tl_rec.source_lang;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.sfwt_flag = okl_api.G_MISS_CHAR)
      THEN
        x_okl_invoice_formats_tl_rec.sfwt_flag := l_okl_invoice_formats_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.name = okl_api.G_MISS_CHAR)
      THEN
        x_okl_invoice_formats_tl_rec.name := l_okl_invoice_formats_tl_rec.name;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.description = okl_api.G_MISS_CHAR)
      THEN
        x_okl_invoice_formats_tl_rec.description := l_okl_invoice_formats_tl_rec.description;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_okl_invoice_formats_tl_rec.created_by := l_okl_invoice_formats_tl_rec.created_by;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_okl_invoice_formats_tl_rec.creation_date := l_okl_invoice_formats_tl_rec.creation_date;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_okl_invoice_formats_tl_rec.last_updated_by := l_okl_invoice_formats_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_okl_invoice_formats_tl_rec.last_update_date := l_okl_invoice_formats_tl_rec.last_update_date;
      END IF;
      IF (x_okl_invoice_formats_tl_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_okl_invoice_formats_tl_rec.last_update_login := l_okl_invoice_formats_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_FORMATS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invoice_formats_tl_rec IN  OklInvoiceFormatsTlRecType,
      x_okl_invoice_formats_tl_rec OUT NOCOPY OklInvoiceFormatsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_formats_tl_rec := p_okl_invoice_formats_tl_rec;
      x_okl_invoice_formats_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_invoice_formats_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_invoice_formats_tl_rec,      -- IN
      l_okl_invoice_formats_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_invoice_formats_tl_rec, ldefoklinvoiceformatstlrec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    -- changed by zrehman for fixing FP Bug#6697145 start
    UPDATE  OKL_INVOICE_FORMATS_TL
    SET NAME = ldefoklinvoiceformatstlrec.name,
        SOURCE_LANG = ldefoklinvoiceformatstlrec.source_lang,
        DESCRIPTION = ldefoklinvoiceformatstlrec.description,
        CREATED_BY = ldefoklinvoiceformatstlrec.created_by,
        CREATION_DATE = ldefoklinvoiceformatstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklinvoiceformatstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklinvoiceformatstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklinvoiceformatstlrec.last_update_login
    WHERE ID = ldefoklinvoiceformatstlrec.id
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);
    -- changed by zrehman for fixing FP Bug#6697145 end

    UPDATE  OKL_INVOICE_FORMATS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklinvoiceformatstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_invoice_formats_tl_rec := ldefoklinvoiceformatstlrec;
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
  ------------------------------------------
  -- update_row for:OKL_INVOICE_FORMATS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_rec                     IN infv_rec_type,
    x_infv_rec                     OUT NOCOPY infv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_infv_rec                     infv_rec_type := p_infv_rec;
    l_def_infv_rec                 infv_rec_type;
    l_okl_invoice_formats_tl_rec   OklInvoiceFormatsTlRecType;
    lx_okl_invoice_formats_tl_rec  OklInvoiceFormatsTlRecType;
    l_inf_rec                      inf_rec_type;
    lx_inf_rec                     inf_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_infv_rec	IN infv_rec_type
    ) RETURN infv_rec_type IS
      l_infv_rec	infv_rec_type := p_infv_rec;
    BEGIN
      l_infv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_infv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_infv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_infv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_infv_rec	IN infv_rec_type,
      x_infv_rec	OUT NOCOPY infv_rec_type
    ) RETURN VARCHAR2 IS
      l_infv_rec                     infv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_infv_rec := p_infv_rec;
      -- Get current database values
      l_infv_rec := get_rec(p_infv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_infv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_infv_rec.id := l_infv_rec.id;
      END IF;
      IF (x_infv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_infv_rec.object_version_number := l_infv_rec.object_version_number;
      END IF;
      IF (x_infv_rec.ilt_id = okl_api.G_MISS_NUM)
      THEN
        x_infv_rec.ilt_id := l_infv_rec.ilt_id;
      END IF;
      IF (x_infv_rec.org_id = okl_api.G_MISS_NUM)
      THEN
        x_infv_rec.org_id := l_infv_rec.org_id;
      END IF;
      IF (x_infv_rec.sfwt_flag = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.sfwt_flag := l_infv_rec.sfwt_flag;
      END IF;
      IF (x_infv_rec.name = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.name := l_infv_rec.name;
      END IF;
      IF (x_infv_rec.description = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.description := l_infv_rec.description;
      END IF;
      IF (x_infv_rec.contract_level_yn = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.contract_level_yn := l_infv_rec.contract_level_yn;
      END IF;
      IF (x_infv_rec.start_date = okl_api.G_MISS_DATE)
      THEN
        x_infv_rec.start_date := l_infv_rec.start_date;
      END IF;
      IF (x_infv_rec.end_date = okl_api.G_MISS_DATE)
      THEN
        x_infv_rec.end_date := l_infv_rec.end_date;
      END IF;
      IF (x_infv_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute_category := l_infv_rec.attribute_category;
      END IF;
      IF (x_infv_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute1 := l_infv_rec.attribute1;
      END IF;
      IF (x_infv_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute2 := l_infv_rec.attribute2;
      END IF;
      IF (x_infv_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute3 := l_infv_rec.attribute3;
      END IF;
      IF (x_infv_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute4 := l_infv_rec.attribute4;
      END IF;
      IF (x_infv_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute5 := l_infv_rec.attribute5;
      END IF;
      IF (x_infv_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute6 := l_infv_rec.attribute6;
      END IF;
      IF (x_infv_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute7 := l_infv_rec.attribute7;
      END IF;
      IF (x_infv_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute8 := l_infv_rec.attribute8;
      END IF;
      IF (x_infv_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute9 := l_infv_rec.attribute9;
      END IF;
      IF (x_infv_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute10 := l_infv_rec.attribute10;
      END IF;
      IF (x_infv_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute11 := l_infv_rec.attribute11;
      END IF;
      IF (x_infv_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute12 := l_infv_rec.attribute12;
      END IF;
      IF (x_infv_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute13 := l_infv_rec.attribute13;
      END IF;
      IF (x_infv_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute14 := l_infv_rec.attribute14;
      END IF;
      IF (x_infv_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_infv_rec.attribute15 := l_infv_rec.attribute15;
      END IF;
      IF (x_infv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_infv_rec.created_by := l_infv_rec.created_by;
      END IF;
      IF (x_infv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_infv_rec.creation_date := l_infv_rec.creation_date;
      END IF;
      IF (x_infv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_infv_rec.last_updated_by := l_infv_rec.last_updated_by;
      END IF;
      IF (x_infv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_infv_rec.last_update_date := l_infv_rec.last_update_date;
      END IF;
      IF (x_infv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_infv_rec.last_update_login := l_infv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_FORMATS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_infv_rec IN  infv_rec_type,
      x_infv_rec OUT NOCOPY infv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_infv_rec := p_infv_rec;
      x_infv_rec.OBJECT_VERSION_NUMBER := NVL(x_infv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_infv_rec,                        -- IN
      l_infv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_infv_rec, l_def_infv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_infv_rec := fill_who_columns(l_def_infv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_infv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_infv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_infv_rec, l_okl_invoice_formats_tl_rec);
    migrate(l_def_infv_rec, l_inf_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_formats_tl_rec,
      lx_okl_invoice_formats_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_invoice_formats_tl_rec, l_def_infv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_inf_rec,
      lx_inf_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_inf_rec, l_def_infv_rec);
    x_infv_rec := l_def_infv_rec;
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
  ----------------------------------------
  -- PL/SQL TBL update_row for:INFV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_tbl                     IN infv_tbl_type,
    x_infv_tbl                     OUT NOCOPY infv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_infv_tbl.COUNT > 0) THEN
      i := p_infv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_infv_rec                     => p_infv_tbl(i),
          x_infv_rec                     => x_infv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_infv_tbl.LAST);
        i := p_infv_tbl.NEXT(i);
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
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- delete_row for:OKL_INVOICE_FORMATS_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inf_rec                      IN inf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_inf_rec                      inf_rec_type:= p_inf_rec;
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
    DELETE FROM OKL_INVOICE_FORMATS_B
     WHERE ID = l_inf_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKL_INVOICE_FORMATS_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_formats_tl_rec   IN OklInvoiceFormatsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_invoice_formats_tl_rec   OklInvoiceFormatsTlRecType:= p_okl_invoice_formats_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_FORMATS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invoice_formats_tl_rec IN  OklInvoiceFormatsTlRecType,
      x_okl_invoice_formats_tl_rec OUT NOCOPY OklInvoiceFormatsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_formats_tl_rec := p_okl_invoice_formats_tl_rec;
      x_okl_invoice_formats_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_invoice_formats_tl_rec,      -- IN
      l_okl_invoice_formats_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_INVOICE_FORMATS_TL
     WHERE ID = l_okl_invoice_formats_tl_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_INVOICE_FORMATS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_rec                     IN infv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_infv_rec                     infv_rec_type := p_infv_rec;
    l_okl_invoice_formats_tl_rec   OklInvoiceFormatsTlRecType;
    l_inf_rec                      inf_rec_type;
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
    migrate(l_infv_rec, l_okl_invoice_formats_tl_rec);
    migrate(l_infv_rec, l_inf_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_formats_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_inf_rec
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
  ----------------------------------------
  -- PL/SQL TBL delete_row for:INFV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_tbl                     IN infv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_infv_tbl.COUNT > 0) THEN
      i := p_infv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_infv_rec                     => p_infv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_infv_tbl.LAST);
        i := p_infv_tbl.NEXT(i);
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
  END delete_row;
END Okl_Inf_Pvt;

/
