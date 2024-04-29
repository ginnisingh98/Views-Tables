--------------------------------------------------------
--  DDL for Package Body OKL_ITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ITY_PVT" AS
/* $Header: OKLSITYB.pls 120.3 2006/03/23 14:50:08 abindal noship $ */


-- Checking Unique Key
  FUNCTION IS_UNIQUE (p_ityv_rec ityv_rec_type) RETURN VARCHAR2
  IS
    CURSOR l_ity_csr IS
		 SELECT 'x'
		 FROM okl_invoice_types_v
		 WHERE inf_id = p_ityv_rec.inf_id
		 AND name = p_ityv_rec.name
		 AND   id <> NVL(p_ityv_rec.id,-99999);

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;
  BEGIN
    -- check for unique product and location
        OPEN l_ity_csr;
        FETCH l_ity_csr INTO l_dummy;
	   l_found := l_ity_csr%FOUND;
	   CLOSE l_ity_csr;

    IF (l_found) THEN
  	    Okl_Api.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> 'OKL_ITY_Exists',
					    p_token1		=> 'NAME',
					    p_token1_value	=> p_ityv_rec.name);
	  -- notify caller of an error
	  l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN (l_return_status);

  EXCEPTION
    WHEN OTHERS THEN
	 RETURN (l_return_status);
  END IS_UNIQUE;


-- Validate not null value for ID

PROCEDURE validate_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_ityv_rec 		IN	ityv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ityv_rec.id IS NULL) OR (p_ityv_rec.id = Okl_Api.G_MISS_NUM) THEN
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


-- Validate not null value for Version Number

PROCEDURE validate_object_version_number(x_return_status OUT NOCOPY VARCHAR2,
			 p_ityv_rec 		IN	ityv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ityv_rec.object_version_number IS NULL) OR (p_ityv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
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
			 p_ityv_rec 		IN	ityv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ityv_rec.name IS NULL) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> 'OKC', --g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'Name');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

END validate_name;



PROCEDURE validate_group_asset_yn(x_return_status OUT NOCOPY VARCHAR2,
			 p_ityv_rec 		IN	ityv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ityv_rec.group_asset_yn IS NULL) OR (p_ityv_rec.group_asset_yn = Okl_Api.G_MISS_CHAR) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'group_asset_yn');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
ELSE
	x_return_status := Okl_Util.CHECK_DOMAIN_YN(p_ityv_rec.group_asset_yn);

END IF;

END validate_group_asset_yn;



PROCEDURE validate_group_by_contract_yn(x_return_status OUT NOCOPY VARCHAR2,
			 p_ityv_rec 		IN	ityv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ityv_rec.group_by_contract_yn IS NULL) OR (p_ityv_rec.group_by_contract_yn = Okl_Api.G_MISS_CHAR) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'group_by_contract_yn');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
ELSE
	x_return_status := Okl_Util.CHECK_DOMAIN_YN(p_ityv_rec.group_by_contract_yn);

END IF;

END validate_group_by_contract_yn;

PROCEDURE validate_inf_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_ityv_rec 		IN	ityv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_ityv_csr IS
	SELECT 'x'
	FROM OKL_INVOICE_FORMATS_V
	WHERE id = p_ityv_rec.inf_id;

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ityv_rec.inf_id IS NULL) OR (p_ityv_rec.inf_id = Okl_Api.G_MISS_NUM) THEN
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
OPEN l_ityv_csr;
	FETCH l_ityv_csr INTO l_dummy_var;
CLOSE l_ityv_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'inf_id',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_INVOICE_TYPES_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'OKL_INVOICE_FORMATS_V');

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
	IF l_ityv_csr%ISOPEN THEN
	  CLOSE l_ityv_csr;
	END IF;

END validate_inf_id;


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
    DELETE FROM OKL_INVOICE_TYPES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_INVOICE_TYPES_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_INVOICE_TYPES_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_INVOICE_TYPES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_INVOICE_TYPES_TL SUBB, OKL_INVOICE_TYPES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_INVOICE_TYPES_TL (
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
        FROM OKL_INVOICE_TYPES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_INVOICE_TYPES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVOICE_TYPES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ity_rec                      IN ity_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ity_rec_type IS
    CURSOR ity_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            INF_ID,
            GROUP_ASSET_YN,
            GROUP_BY_CONTRACT_YN,
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
            LAST_UPDATE_LOGIN
      FROM Okl_Invoice_Types_B
     WHERE okl_invoice_types_b.id = p_id;
    l_ity_pk                       ity_pk_csr%ROWTYPE;
    l_ity_rec                      ity_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ity_pk_csr (p_ity_rec.id);
    FETCH ity_pk_csr INTO
              l_ity_rec.ID,
              l_ity_rec.INF_ID,
              l_ity_rec.GROUP_ASSET_YN,
              l_ity_rec.GROUP_BY_CONTRACT_YN,
              l_ity_rec.OBJECT_VERSION_NUMBER,
              l_ity_rec.ATTRIBUTE_CATEGORY,
              l_ity_rec.ATTRIBUTE1,
              l_ity_rec.ATTRIBUTE2,
              l_ity_rec.ATTRIBUTE3,
              l_ity_rec.ATTRIBUTE4,
              l_ity_rec.ATTRIBUTE5,
              l_ity_rec.ATTRIBUTE6,
              l_ity_rec.ATTRIBUTE7,
              l_ity_rec.ATTRIBUTE8,
              l_ity_rec.ATTRIBUTE9,
              l_ity_rec.ATTRIBUTE10,
              l_ity_rec.ATTRIBUTE11,
              l_ity_rec.ATTRIBUTE12,
              l_ity_rec.ATTRIBUTE13,
              l_ity_rec.ATTRIBUTE14,
              l_ity_rec.ATTRIBUTE15,
              l_ity_rec.CREATED_BY,
              l_ity_rec.CREATION_DATE,
              l_ity_rec.LAST_UPDATED_BY,
              l_ity_rec.LAST_UPDATE_DATE,
              l_ity_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := ity_pk_csr%NOTFOUND;
    CLOSE ity_pk_csr;
    RETURN(l_ity_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ity_rec                      IN ity_rec_type
  ) RETURN ity_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ity_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVOICE_TYPES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_invoice_types_tl_rec     IN okl_invoice_types_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_invoice_types_tl_rec_type IS
    CURSOR okl_invoice_types_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Invoice_Types_Tl
     WHERE okl_invoice_types_tl.id = p_id
       AND okl_invoice_types_tl.LANGUAGE = p_language;
    l_okl_invoice_types_tl_pk      okl_invoice_types_tl_pk_csr%ROWTYPE;
    l_okl_invoice_types_tl_rec     okl_invoice_types_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_invoice_types_tl_pk_csr (p_okl_invoice_types_tl_rec.id,
                                      p_okl_invoice_types_tl_rec.LANGUAGE);
    FETCH okl_invoice_types_tl_pk_csr INTO
              l_okl_invoice_types_tl_rec.ID,
              l_okl_invoice_types_tl_rec.LANGUAGE,
              l_okl_invoice_types_tl_rec.SOURCE_LANG,
              l_okl_invoice_types_tl_rec.SFWT_FLAG,
              l_okl_invoice_types_tl_rec.NAME,
              l_okl_invoice_types_tl_rec.DESCRIPTION,
              l_okl_invoice_types_tl_rec.CREATED_BY,
              l_okl_invoice_types_tl_rec.CREATION_DATE,
              l_okl_invoice_types_tl_rec.LAST_UPDATED_BY,
              l_okl_invoice_types_tl_rec.LAST_UPDATE_DATE,
              l_okl_invoice_types_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_invoice_types_tl_pk_csr%NOTFOUND;
    CLOSE okl_invoice_types_tl_pk_csr;
    RETURN(l_okl_invoice_types_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_invoice_types_tl_rec     IN okl_invoice_types_tl_rec_type
  ) RETURN okl_invoice_types_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_invoice_types_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVOICE_TYPES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ityv_rec                     IN ityv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ityv_rec_type IS
    CURSOR okl_ityv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            INF_ID,
            NAME,
            DESCRIPTION,
            GROUP_ASSET_YN,
            GROUP_BY_CONTRACT_YN,
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
      FROM Okl_Invoice_Types_V
     WHERE okl_invoice_types_v.id = p_id;
    l_okl_ityv_pk                  okl_ityv_pk_csr%ROWTYPE;
    l_ityv_rec                     ityv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ityv_pk_csr (p_ityv_rec.id);
    FETCH okl_ityv_pk_csr INTO
              l_ityv_rec.ID,
              l_ityv_rec.OBJECT_VERSION_NUMBER,
              l_ityv_rec.SFWT_FLAG,
              l_ityv_rec.INF_ID,
              l_ityv_rec.NAME,
              l_ityv_rec.DESCRIPTION,
              l_ityv_rec.GROUP_ASSET_YN,
              l_ityv_rec.GROUP_BY_CONTRACT_YN,
              l_ityv_rec.ATTRIBUTE_CATEGORY,
              l_ityv_rec.ATTRIBUTE1,
              l_ityv_rec.ATTRIBUTE2,
              l_ityv_rec.ATTRIBUTE3,
              l_ityv_rec.ATTRIBUTE4,
              l_ityv_rec.ATTRIBUTE5,
              l_ityv_rec.ATTRIBUTE6,
              l_ityv_rec.ATTRIBUTE7,
              l_ityv_rec.ATTRIBUTE8,
              l_ityv_rec.ATTRIBUTE9,
              l_ityv_rec.ATTRIBUTE10,
              l_ityv_rec.ATTRIBUTE11,
              l_ityv_rec.ATTRIBUTE12,
              l_ityv_rec.ATTRIBUTE13,
              l_ityv_rec.ATTRIBUTE14,
              l_ityv_rec.ATTRIBUTE15,
              l_ityv_rec.CREATED_BY,
              l_ityv_rec.CREATION_DATE,
              l_ityv_rec.LAST_UPDATED_BY,
              l_ityv_rec.LAST_UPDATE_DATE,
              l_ityv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ityv_pk_csr%NOTFOUND;
    CLOSE okl_ityv_pk_csr;
    RETURN(l_ityv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ityv_rec                     IN ityv_rec_type
  ) RETURN ityv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ityv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INVOICE_TYPES_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ityv_rec	IN ityv_rec_type
  ) RETURN ityv_rec_type IS
    l_ityv_rec	ityv_rec_type := p_ityv_rec;
  BEGIN
    IF (l_ityv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_ityv_rec.object_version_number := NULL;
    END IF;
    IF (l_ityv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_ityv_rec.inf_id = Okl_Api.G_MISS_NUM) THEN
      l_ityv_rec.inf_id := NULL;
    END IF;
    IF (l_ityv_rec.name = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.name := NULL;
    END IF;
    IF (l_ityv_rec.description = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.description := NULL;
    END IF;
    IF (l_ityv_rec.group_asset_yn = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.group_asset_yn := NULL;
    END IF;
    IF (l_ityv_rec.group_by_contract_yn = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.group_by_contract_yn := NULL;
    END IF;
    IF (l_ityv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute_category := NULL;
    END IF;
    IF (l_ityv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute1 := NULL;
    END IF;
    IF (l_ityv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute2 := NULL;
    END IF;
    IF (l_ityv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute3 := NULL;
    END IF;
    IF (l_ityv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute4 := NULL;
    END IF;
    IF (l_ityv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute5 := NULL;
    END IF;
    IF (l_ityv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute6 := NULL;
    END IF;
    IF (l_ityv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute7 := NULL;
    END IF;
    IF (l_ityv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute8 := NULL;
    END IF;
    IF (l_ityv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute9 := NULL;
    END IF;
    IF (l_ityv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute10 := NULL;
    END IF;
    IF (l_ityv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute11 := NULL;
    END IF;
    IF (l_ityv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute12 := NULL;
    END IF;
    IF (l_ityv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute13 := NULL;
    END IF;
    IF (l_ityv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute14 := NULL;
    END IF;
    IF (l_ityv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_ityv_rec.attribute15 := NULL;
    END IF;
    IF (l_ityv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_ityv_rec.created_by := NULL;
    END IF;
    IF (l_ityv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_ityv_rec.creation_date := NULL;
    END IF;
    IF (l_ityv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_ityv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ityv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_ityv_rec.last_update_date := NULL;
    END IF;
    IF (l_ityv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_ityv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ityv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_INVOICE_TYPES_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ityv_rec IN  ityv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1)	:= Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
     -- Call each column level validation

  validate_id(x_return_status => l_return_status,
			 	p_ityv_rec =>	p_ityv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_object_version_number(x_return_status => l_return_status,
			 	p_ityv_rec =>	p_ityv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_inf_id(x_return_status => l_return_status,
			 	p_ityv_rec =>	p_ityv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_name(x_return_status => l_return_status,
			 	p_ityv_rec =>	p_ityv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_group_asset_yn(x_return_status => l_return_status,
			 	p_ityv_rec =>	p_ityv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_group_by_contract_yn(x_return_status => l_return_status,
			 	p_ityv_rec =>	p_ityv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_INVOICE_TYPES_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_ityv_rec IN ityv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
      l_return_status := IS_UNIQUE(p_ityv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ityv_rec_type,
    p_to	OUT NOCOPY ity_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.inf_id := p_from.inf_id;
    p_to.group_asset_yn := p_from.group_asset_yn;
    p_to.group_by_contract_yn := p_from.group_by_contract_yn;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN ity_rec_type,
    p_to	OUT NOCOPY ityv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.inf_id := p_from.inf_id;
    p_to.group_asset_yn := p_from.group_asset_yn;
    p_to.group_by_contract_yn := p_from.group_by_contract_yn;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN ityv_rec_type,
    p_to	OUT NOCOPY okl_invoice_types_tl_rec_type
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
    p_from	IN okl_invoice_types_tl_rec_type,
    p_to	OUT NOCOPY ityv_rec_type
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
  ------------------------------------------
  -- validate_row for:OKL_INVOICE_TYPES_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_rec                     IN ityv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ityv_rec                     ityv_rec_type := p_ityv_rec;
    l_ity_rec                      ity_rec_type;
    l_okl_invoice_types_tl_rec     okl_invoice_types_tl_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_ityv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ityv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:ITYV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_tbl                     IN ityv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ityv_tbl.COUNT > 0) THEN
      i := p_ityv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ityv_rec                     => p_ityv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_ityv_tbl.LAST);
        i := p_ityv_tbl.NEXT(i);
      END LOOP;
   -- return overall status
   	  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_INVOICE_TYPES_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ity_rec                      IN ity_rec_type,
    x_ity_rec                      OUT NOCOPY ity_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ity_rec                      ity_rec_type := p_ity_rec;
    l_def_ity_rec                  ity_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_TYPES_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ity_rec IN  ity_rec_type,
      x_ity_rec OUT NOCOPY ity_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ity_rec := p_ity_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ity_rec,                         -- IN
      l_ity_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_INVOICE_TYPES_B(
        id,
        inf_id,
        group_asset_yn,
        group_by_contract_yn,
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
        last_update_login)
      VALUES (
        l_ity_rec.id,
        l_ity_rec.inf_id,
        l_ity_rec.group_asset_yn,
        l_ity_rec.group_by_contract_yn,
        l_ity_rec.object_version_number,
        l_ity_rec.attribute_category,
        l_ity_rec.attribute1,
        l_ity_rec.attribute2,
        l_ity_rec.attribute3,
        l_ity_rec.attribute4,
        l_ity_rec.attribute5,
        l_ity_rec.attribute6,
        l_ity_rec.attribute7,
        l_ity_rec.attribute8,
        l_ity_rec.attribute9,
        l_ity_rec.attribute10,
        l_ity_rec.attribute11,
        l_ity_rec.attribute12,
        l_ity_rec.attribute13,
        l_ity_rec.attribute14,
        l_ity_rec.attribute15,
        l_ity_rec.created_by,
        l_ity_rec.creation_date,
        l_ity_rec.last_updated_by,
        l_ity_rec.last_update_date,
        l_ity_rec.last_update_login);
    -- Set OUT values
    x_ity_rec := l_ity_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_INVOICE_TYPES_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_types_tl_rec     IN okl_invoice_types_tl_rec_type,
    x_okl_invoice_types_tl_rec     OUT NOCOPY okl_invoice_types_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_invoice_types_tl_rec     okl_invoice_types_tl_rec_type := p_okl_invoice_types_tl_rec;
    ldefoklinvoicetypestlrec       okl_invoice_types_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_TYPES_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invoice_types_tl_rec IN  okl_invoice_types_tl_rec_type,
      x_okl_invoice_types_tl_rec OUT NOCOPY okl_invoice_types_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_types_tl_rec := p_okl_invoice_types_tl_rec;
      x_okl_invoice_types_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_invoice_types_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_invoice_types_tl_rec,        -- IN
      l_okl_invoice_types_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_invoice_types_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_INVOICE_TYPES_TL(
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
          l_okl_invoice_types_tl_rec.id,
          l_okl_invoice_types_tl_rec.LANGUAGE,
          l_okl_invoice_types_tl_rec.source_lang,
          l_okl_invoice_types_tl_rec.sfwt_flag,
          l_okl_invoice_types_tl_rec.name,
          l_okl_invoice_types_tl_rec.description,
          l_okl_invoice_types_tl_rec.created_by,
          l_okl_invoice_types_tl_rec.creation_date,
          l_okl_invoice_types_tl_rec.last_updated_by,
          l_okl_invoice_types_tl_rec.last_update_date,
          l_okl_invoice_types_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_invoice_types_tl_rec := l_okl_invoice_types_tl_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_INVOICE_TYPES_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_rec                     IN ityv_rec_type,
    x_ityv_rec                     OUT NOCOPY ityv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ityv_rec                     ityv_rec_type;
    l_def_ityv_rec                 ityv_rec_type;
    l_ity_rec                      ity_rec_type;
    lx_ity_rec                     ity_rec_type;
    l_okl_invoice_types_tl_rec     okl_invoice_types_tl_rec_type;
    lx_okl_invoice_types_tl_rec    okl_invoice_types_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ityv_rec	IN ityv_rec_type
    ) RETURN ityv_rec_type IS
      l_ityv_rec	ityv_rec_type := p_ityv_rec;
    BEGIN
      l_ityv_rec.CREATION_DATE := SYSDATE;
      l_ityv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_ityv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ityv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_ityv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_ityv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_TYPES_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ityv_rec IN  ityv_rec_type,
      x_ityv_rec OUT NOCOPY ityv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ityv_rec := p_ityv_rec;
      x_ityv_rec.OBJECT_VERSION_NUMBER := 1;
      x_ityv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_ityv_rec := null_out_defaults(p_ityv_rec);
    -- Set primary key value
    l_ityv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ityv_rec,                        -- IN
      l_def_ityv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_ityv_rec := fill_who_columns(l_def_ityv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ityv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ityv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ityv_rec, l_ity_rec);
    migrate(l_def_ityv_rec, l_okl_invoice_types_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ity_rec,
      lx_ity_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ity_rec, l_def_ityv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_types_tl_rec,
      lx_okl_invoice_types_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_invoice_types_tl_rec, l_def_ityv_rec);
    -- Set OUT values
    x_ityv_rec := l_def_ityv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E';
	  /*
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
	  */
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
	  /*
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:ITYV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_tbl                     IN ityv_tbl_type,
    x_ityv_tbl                     OUT NOCOPY ityv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ityv_tbl.COUNT > 0) THEN
      i := p_ityv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ityv_rec                     => p_ityv_tbl(i),
          x_ityv_rec                     => x_ityv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_ityv_tbl.LAST);
        i := p_ityv_tbl.NEXT(i);
      END LOOP;
   -- return overall status
   	  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_INVOICE_TYPES_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ity_rec                      IN ity_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ity_rec IN ity_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INVOICE_TYPES_B
     WHERE ID = p_ity_rec.id
       AND OBJECT_VERSION_NUMBER = p_ity_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ity_rec IN ity_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INVOICE_TYPES_B
    WHERE ID = p_ity_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INVOICE_TYPES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INVOICE_TYPES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_ity_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_ity_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ity_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ity_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okl_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_INVOICE_TYPES_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_types_tl_rec     IN okl_invoice_types_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_invoice_types_tl_rec IN okl_invoice_types_tl_rec_type) IS
    SELECT *
      FROM OKL_INVOICE_TYPES_TL
     WHERE ID = p_okl_invoice_types_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_invoice_types_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_INVOICE_TYPES_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_rec                     IN ityv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ity_rec                      ity_rec_type;
    l_okl_invoice_types_tl_rec     okl_invoice_types_tl_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_ityv_rec, l_ity_rec);
    migrate(p_ityv_rec, l_okl_invoice_types_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ity_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_types_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:ITYV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_tbl                     IN ityv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ityv_tbl.COUNT > 0) THEN
      i := p_ityv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ityv_rec                     => p_ityv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_ityv_tbl.LAST);
        i := p_ityv_tbl.NEXT(i);
      END LOOP;
   -- return overall status
   	  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_INVOICE_TYPES_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ity_rec                      IN ity_rec_type,
    x_ity_rec                      OUT NOCOPY ity_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ity_rec                      ity_rec_type := p_ity_rec;
    l_def_ity_rec                  ity_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ity_rec	IN ity_rec_type,
      x_ity_rec	OUT NOCOPY ity_rec_type
    ) RETURN VARCHAR2 IS
      l_ity_rec                      ity_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ity_rec := p_ity_rec;
      -- Get current database values
      l_ity_rec := get_rec(p_ity_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ity_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_ity_rec.id := l_ity_rec.id;
      END IF;
      IF (x_ity_rec.inf_id = Okl_Api.G_MISS_NUM)
      THEN
        x_ity_rec.inf_id := l_ity_rec.inf_id;
      END IF;
      IF (x_ity_rec.group_asset_yn = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.group_asset_yn := l_ity_rec.group_asset_yn;
      END IF;
      IF (x_ity_rec.group_by_contract_yn = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.group_by_contract_yn := l_ity_rec.group_by_contract_yn;
      END IF;
      IF (x_ity_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_ity_rec.object_version_number := l_ity_rec.object_version_number;
      END IF;
      IF (x_ity_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute_category := l_ity_rec.attribute_category;
      END IF;
      IF (x_ity_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute1 := l_ity_rec.attribute1;
      END IF;
      IF (x_ity_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute2 := l_ity_rec.attribute2;
      END IF;
      IF (x_ity_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute3 := l_ity_rec.attribute3;
      END IF;
      IF (x_ity_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute4 := l_ity_rec.attribute4;
      END IF;
      IF (x_ity_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute5 := l_ity_rec.attribute5;
      END IF;
      IF (x_ity_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute6 := l_ity_rec.attribute6;
      END IF;
      IF (x_ity_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute7 := l_ity_rec.attribute7;
      END IF;
      IF (x_ity_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute8 := l_ity_rec.attribute8;
      END IF;
      IF (x_ity_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute9 := l_ity_rec.attribute9;
      END IF;
      IF (x_ity_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute10 := l_ity_rec.attribute10;
      END IF;
      IF (x_ity_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute11 := l_ity_rec.attribute11;
      END IF;
      IF (x_ity_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute12 := l_ity_rec.attribute12;
      END IF;
      IF (x_ity_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute13 := l_ity_rec.attribute13;
      END IF;
      IF (x_ity_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute14 := l_ity_rec.attribute14;
      END IF;
      IF (x_ity_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ity_rec.attribute15 := l_ity_rec.attribute15;
      END IF;
      IF (x_ity_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_ity_rec.created_by := l_ity_rec.created_by;
      END IF;
      IF (x_ity_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_ity_rec.creation_date := l_ity_rec.creation_date;
      END IF;
      IF (x_ity_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_ity_rec.last_updated_by := l_ity_rec.last_updated_by;
      END IF;
      IF (x_ity_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_ity_rec.last_update_date := l_ity_rec.last_update_date;
      END IF;
      IF (x_ity_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_ity_rec.last_update_login := l_ity_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_TYPES_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ity_rec IN  ity_rec_type,
      x_ity_rec OUT NOCOPY ity_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ity_rec := p_ity_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ity_rec,                         -- IN
      l_ity_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ity_rec, l_def_ity_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INVOICE_TYPES_B
    SET INF_ID = l_def_ity_rec.inf_id,
        GROUP_ASSET_YN = l_def_ity_rec.group_asset_yn,
        GROUP_BY_CONTRACT_YN = l_def_ity_rec.group_by_contract_yn,
        OBJECT_VERSION_NUMBER = l_def_ity_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_ity_rec.attribute_category,
        ATTRIBUTE1 = l_def_ity_rec.attribute1,
        ATTRIBUTE2 = l_def_ity_rec.attribute2,
        ATTRIBUTE3 = l_def_ity_rec.attribute3,
        ATTRIBUTE4 = l_def_ity_rec.attribute4,
        ATTRIBUTE5 = l_def_ity_rec.attribute5,
        ATTRIBUTE6 = l_def_ity_rec.attribute6,
        ATTRIBUTE7 = l_def_ity_rec.attribute7,
        ATTRIBUTE8 = l_def_ity_rec.attribute8,
        ATTRIBUTE9 = l_def_ity_rec.attribute9,
        ATTRIBUTE10 = l_def_ity_rec.attribute10,
        ATTRIBUTE11 = l_def_ity_rec.attribute11,
        ATTRIBUTE12 = l_def_ity_rec.attribute12,
        ATTRIBUTE13 = l_def_ity_rec.attribute13,
        ATTRIBUTE14 = l_def_ity_rec.attribute14,
        ATTRIBUTE15 = l_def_ity_rec.attribute15,
        CREATED_BY = l_def_ity_rec.created_by,
        CREATION_DATE = l_def_ity_rec.creation_date,
        LAST_UPDATED_BY = l_def_ity_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ity_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ity_rec.last_update_login
    WHERE ID = l_def_ity_rec.id;

    x_ity_rec := l_def_ity_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_INVOICE_TYPES_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_types_tl_rec     IN okl_invoice_types_tl_rec_type,
    x_okl_invoice_types_tl_rec     OUT NOCOPY okl_invoice_types_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_invoice_types_tl_rec     okl_invoice_types_tl_rec_type := p_okl_invoice_types_tl_rec;
    ldefoklinvoicetypestlrec       okl_invoice_types_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_invoice_types_tl_rec	IN okl_invoice_types_tl_rec_type,
      x_okl_invoice_types_tl_rec	OUT NOCOPY okl_invoice_types_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_invoice_types_tl_rec     okl_invoice_types_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_types_tl_rec := p_okl_invoice_types_tl_rec;
      -- Get current database values
      l_okl_invoice_types_tl_rec := get_rec(p_okl_invoice_types_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_invoice_types_tl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_invoice_types_tl_rec.id := l_okl_invoice_types_tl_rec.id;
      END IF;
      IF (x_okl_invoice_types_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_invoice_types_tl_rec.LANGUAGE := l_okl_invoice_types_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_invoice_types_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_invoice_types_tl_rec.source_lang := l_okl_invoice_types_tl_rec.source_lang;
      END IF;
      IF (x_okl_invoice_types_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_invoice_types_tl_rec.sfwt_flag := l_okl_invoice_types_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_invoice_types_tl_rec.name = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_invoice_types_tl_rec.name := l_okl_invoice_types_tl_rec.name;
      END IF;
      IF (x_okl_invoice_types_tl_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_invoice_types_tl_rec.description := l_okl_invoice_types_tl_rec.description;
      END IF;
      IF (x_okl_invoice_types_tl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_invoice_types_tl_rec.created_by := l_okl_invoice_types_tl_rec.created_by;
      END IF;
      IF (x_okl_invoice_types_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_invoice_types_tl_rec.creation_date := l_okl_invoice_types_tl_rec.creation_date;
      END IF;
      IF (x_okl_invoice_types_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_invoice_types_tl_rec.last_updated_by := l_okl_invoice_types_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_invoice_types_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_invoice_types_tl_rec.last_update_date := l_okl_invoice_types_tl_rec.last_update_date;
      END IF;
      IF (x_okl_invoice_types_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_invoice_types_tl_rec.last_update_login := l_okl_invoice_types_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_TYPES_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invoice_types_tl_rec IN  okl_invoice_types_tl_rec_type,
      x_okl_invoice_types_tl_rec OUT NOCOPY okl_invoice_types_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_types_tl_rec := p_okl_invoice_types_tl_rec;
      x_okl_invoice_types_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_invoice_types_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_invoice_types_tl_rec,        -- IN
      l_okl_invoice_types_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_invoice_types_tl_rec, ldefoklinvoicetypestlrec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INVOICE_TYPES_TL
    SET NAME = ldefoklinvoicetypestlrec.name,
        DESCRIPTION = ldefoklinvoicetypestlrec.description,
        CREATED_BY = ldefoklinvoicetypestlrec.created_by,
        CREATION_DATE = ldefoklinvoicetypestlrec.creation_date,
        LAST_UPDATED_BY = ldefoklinvoicetypestlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklinvoicetypestlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklinvoicetypestlrec.last_update_login
    WHERE ID = ldefoklinvoicetypestlrec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_INVOICE_TYPES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklinvoicetypestlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_invoice_types_tl_rec := ldefoklinvoicetypestlrec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_INVOICE_TYPES_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_rec                     IN ityv_rec_type,
    x_ityv_rec                     OUT NOCOPY ityv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ityv_rec                     ityv_rec_type := p_ityv_rec;
    l_def_ityv_rec                 ityv_rec_type;
    l_okl_invoice_types_tl_rec     okl_invoice_types_tl_rec_type;
    lx_okl_invoice_types_tl_rec    okl_invoice_types_tl_rec_type;
    l_ity_rec                      ity_rec_type;
    lx_ity_rec                     ity_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ityv_rec	IN ityv_rec_type
    ) RETURN ityv_rec_type IS
      l_ityv_rec	ityv_rec_type := p_ityv_rec;
    BEGIN
      l_ityv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ityv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_ityv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_ityv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ityv_rec	IN ityv_rec_type,
      x_ityv_rec	OUT NOCOPY ityv_rec_type
    ) RETURN VARCHAR2 IS
      l_ityv_rec                     ityv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ityv_rec := p_ityv_rec;
      -- Get current database values
      l_ityv_rec := get_rec(p_ityv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ityv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_ityv_rec.id := l_ityv_rec.id;
      END IF;
      IF (x_ityv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_ityv_rec.object_version_number := l_ityv_rec.object_version_number;
      END IF;
      IF (x_ityv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.sfwt_flag := l_ityv_rec.sfwt_flag;
      END IF;
      IF (x_ityv_rec.inf_id = Okl_Api.G_MISS_NUM)
      THEN
        x_ityv_rec.inf_id := l_ityv_rec.inf_id;
      END IF;
      IF (x_ityv_rec.name = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.name := l_ityv_rec.name;
      END IF;
      IF (x_ityv_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.description := l_ityv_rec.description;
      END IF;
      IF (x_ityv_rec.group_asset_yn = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.group_asset_yn := l_ityv_rec.group_asset_yn;
      END IF;
      IF (x_ityv_rec.group_by_contract_yn = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.group_by_contract_yn := l_ityv_rec.group_by_contract_yn;
      END IF;
      IF (x_ityv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute_category := l_ityv_rec.attribute_category;
      END IF;
      IF (x_ityv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute1 := l_ityv_rec.attribute1;
      END IF;
      IF (x_ityv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute2 := l_ityv_rec.attribute2;
      END IF;
      IF (x_ityv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute3 := l_ityv_rec.attribute3;
      END IF;
      IF (x_ityv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute4 := l_ityv_rec.attribute4;
      END IF;
      IF (x_ityv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute5 := l_ityv_rec.attribute5;
      END IF;
      IF (x_ityv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute6 := l_ityv_rec.attribute6;
      END IF;
      IF (x_ityv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute7 := l_ityv_rec.attribute7;
      END IF;
      IF (x_ityv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute8 := l_ityv_rec.attribute8;
      END IF;
      IF (x_ityv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute9 := l_ityv_rec.attribute9;
      END IF;
      IF (x_ityv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute10 := l_ityv_rec.attribute10;
      END IF;
      IF (x_ityv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute11 := l_ityv_rec.attribute11;
      END IF;
      IF (x_ityv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute12 := l_ityv_rec.attribute12;
      END IF;
      IF (x_ityv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute13 := l_ityv_rec.attribute13;
      END IF;
      IF (x_ityv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute14 := l_ityv_rec.attribute14;
      END IF;
      IF (x_ityv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ityv_rec.attribute15 := l_ityv_rec.attribute15;
      END IF;
      IF (x_ityv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_ityv_rec.created_by := l_ityv_rec.created_by;
      END IF;
      IF (x_ityv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_ityv_rec.creation_date := l_ityv_rec.creation_date;
      END IF;
      IF (x_ityv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_ityv_rec.last_updated_by := l_ityv_rec.last_updated_by;
      END IF;
      IF (x_ityv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_ityv_rec.last_update_date := l_ityv_rec.last_update_date;
      END IF;
      IF (x_ityv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_ityv_rec.last_update_login := l_ityv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_TYPES_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ityv_rec IN  ityv_rec_type,
      x_ityv_rec OUT NOCOPY ityv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ityv_rec := p_ityv_rec;
      x_ityv_rec.OBJECT_VERSION_NUMBER := NVL(x_ityv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ityv_rec,                        -- IN
      l_ityv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ityv_rec, l_def_ityv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_ityv_rec := fill_who_columns(l_def_ityv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ityv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ityv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ityv_rec, l_okl_invoice_types_tl_rec);
    migrate(l_def_ityv_rec, l_ity_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_types_tl_rec,
      lx_okl_invoice_types_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_invoice_types_tl_rec, l_def_ityv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ity_rec,
      lx_ity_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ity_rec, l_def_ityv_rec);
    x_ityv_rec := l_def_ityv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:ITYV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_tbl                     IN ityv_tbl_type,
    x_ityv_tbl                     OUT NOCOPY ityv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ityv_tbl.COUNT > 0) THEN
      i := p_ityv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ityv_rec                     => p_ityv_tbl(i),
          x_ityv_rec                     => x_ityv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_ityv_tbl.LAST);
        i := p_ityv_tbl.NEXT(i);
      END LOOP;
   -- return overall status
   	  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_INVOICE_TYPES_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ity_rec                      IN ity_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ity_rec                      ity_rec_type:= p_ity_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_INVOICE_TYPES_B
     WHERE ID = l_ity_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_INVOICE_TYPES_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_types_tl_rec     IN okl_invoice_types_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_invoice_types_tl_rec     okl_invoice_types_tl_rec_type:= p_okl_invoice_types_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_TYPES_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invoice_types_tl_rec IN  okl_invoice_types_tl_rec_type,
      x_okl_invoice_types_tl_rec OUT NOCOPY okl_invoice_types_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_types_tl_rec := p_okl_invoice_types_tl_rec;
      x_okl_invoice_types_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_invoice_types_tl_rec,        -- IN
      l_okl_invoice_types_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_INVOICE_TYPES_TL
     WHERE ID = l_okl_invoice_types_tl_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_INVOICE_TYPES_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_rec                     IN ityv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ityv_rec                     ityv_rec_type := p_ityv_rec;
    l_okl_invoice_types_tl_rec     okl_invoice_types_tl_rec_type;
    l_ity_rec                      ity_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_ityv_rec, l_okl_invoice_types_tl_rec);
    migrate(l_ityv_rec, l_ity_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_types_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ity_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:ITYV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_tbl                     IN ityv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ityv_tbl.COUNT > 0) THEN
      i := p_ityv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ityv_rec                     => p_ityv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_ityv_tbl.LAST);
        i := p_ityv_tbl.NEXT(i);
      END LOOP;
   -- return overall status
   	  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Ity_Pvt;

/
