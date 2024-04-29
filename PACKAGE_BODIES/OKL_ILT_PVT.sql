--------------------------------------------------------
--  DDL for Package Body OKL_ILT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ILT_PVT" AS
/* $Header: OKLSILTB.pls 120.3 2006/03/23 14:49:19 abindal noship $ */


-- Checking Unique Key
  FUNCTION IS_UNIQUE (p_iltv_rec iltv_rec_type) RETURN VARCHAR2
  IS
    CURSOR l_ilt_csr IS
		 SELECT 'x'
		 FROM okl_invc_line_types_v
		 WHERE ity_id = p_iltv_rec.ity_id
		 AND name = p_iltv_rec.name
		 AND   id <> NVL(p_iltv_rec.id,-99999);

    l_return_status     VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;
  BEGIN
    -- check for unique product and location
        OPEN l_ilt_csr;
        FETCH l_ilt_csr INTO l_dummy;
	   l_found := l_ilt_csr%FOUND;
	   CLOSE l_ilt_csr;

    IF (l_found) THEN
  	    okl_api.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> 'OKL_LCS_Exists',
					 --   p_token1		=> 'VALUE1',
					 --   p_token1_value	=> p_iltv_rec.ity_id,
					    p_token2		=> 'NAME',
					    p_token2_value	=> p_iltv_rec.name);
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
			 p_iltv_rec 		IN	iltv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := okl_api.G_RET_STS_SUCCESS;

-- data is required
IF(p_iltv_rec.id IS NULL) OR (p_iltv_rec.id = okl_api.G_MISS_NUM) THEN
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
			 p_iltv_rec 		IN	iltv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := okl_api.G_RET_STS_SUCCESS;

-- data is required
IF(p_iltv_rec.object_version_number IS NULL) OR (p_iltv_rec.object_version_number = okl_api.G_MISS_NUM) THEN
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
			 p_iltv_rec 		IN	iltv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := okl_api.G_RET_STS_SUCCESS;

-- data is required
IF(p_iltv_rec.name IS NULL) OR (p_iltv_rec.name = okl_api.G_MISS_CHAR) THEN
	okl_api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'name');

-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
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


END validate_name;


PROCEDURE validate_sequence_number(x_return_status OUT NOCOPY VARCHAR2,
			 p_iltv_rec 		IN	iltv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := okl_api.G_RET_STS_SUCCESS;

-- data is required
IF(p_iltv_rec.sequence_number IS NULL) OR (p_iltv_rec.sequence_number = okl_api.G_MISS_NUM) THEN
	okl_api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'sequence_number');

-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
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


END validate_sequence_number;


PROCEDURE validate_ity_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_iltv_rec 		IN	iltv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_iltv_csr IS
	SELECT 'x'
	FROM OKL_INVOICE_TYPES_V
	WHERE id = p_iltv_rec.ity_id;

BEGIN
-- initialize return status
x_return_status := okl_api.G_RET_STS_SUCCESS;

-- data is required
IF(p_iltv_rec.ity_id IS NULL) OR (p_iltv_rec.ity_id = okl_api.G_MISS_NUM) THEN
	okl_api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'ity_id');

-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

-- enforce foreign key
OPEN l_iltv_csr;
	FETCH l_iltv_csr INTO l_dummy_var;
CLOSE l_iltv_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	okl_api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'ity_id',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_INVC_LINE_TYPES_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'OKL_INVOICE_TYPES_V');

-- notify caller of an error
	x_return_status := okl_api.G_RET_STS_ERROR;
	END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
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
	IF l_iltv_csr%ISOPEN THEN
	  CLOSE l_iltv_csr;
	END IF;

END validate_ity_id;


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
    DELETE FROM OKL_INVC_LINE_TYPES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_INVC_LINE_TYPES_B B     --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_INVC_LINE_TYPES_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_INVC_LINE_TYPES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_INVC_LINE_TYPES_TL SUBB, OKL_INVC_LINE_TYPES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_INVC_LINE_TYPES_TL (
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
        FROM OKL_INVC_LINE_TYPES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_INVC_LINE_TYPES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVC_LINE_TYPES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ilt_rec                      IN ilt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ilt_rec_type IS
    CURSOR ilt_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ITY_ID,
            OBJECT_VERSION_NUMBER,
            SEQUENCE_NUMBER,
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
      FROM Okl_Invc_Line_Types_B
     WHERE okl_invc_line_types_b.id = p_id;
    l_ilt_pk                       ilt_pk_csr%ROWTYPE;
    l_ilt_rec                      ilt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ilt_pk_csr (p_ilt_rec.id);
    FETCH ilt_pk_csr INTO
              l_ilt_rec.ID,
              l_ilt_rec.ITY_ID,
              l_ilt_rec.OBJECT_VERSION_NUMBER,
              l_ilt_rec.SEQUENCE_NUMBER,
              l_ilt_rec.ATTRIBUTE_CATEGORY,
              l_ilt_rec.ATTRIBUTE1,
              l_ilt_rec.ATTRIBUTE2,
              l_ilt_rec.ATTRIBUTE3,
              l_ilt_rec.ATTRIBUTE4,
              l_ilt_rec.ATTRIBUTE5,
              l_ilt_rec.ATTRIBUTE6,
              l_ilt_rec.ATTRIBUTE7,
              l_ilt_rec.ATTRIBUTE8,
              l_ilt_rec.ATTRIBUTE9,
              l_ilt_rec.ATTRIBUTE10,
              l_ilt_rec.ATTRIBUTE11,
              l_ilt_rec.ATTRIBUTE12,
              l_ilt_rec.ATTRIBUTE13,
              l_ilt_rec.ATTRIBUTE14,
              l_ilt_rec.ATTRIBUTE15,
              l_ilt_rec.CREATED_BY,
              l_ilt_rec.CREATION_DATE,
              l_ilt_rec.LAST_UPDATED_BY,
              l_ilt_rec.LAST_UPDATE_DATE,
              l_ilt_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := ilt_pk_csr%NOTFOUND;
    CLOSE ilt_pk_csr;
    RETURN(l_ilt_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ilt_rec                      IN ilt_rec_type
  ) RETURN ilt_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ilt_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVC_LINE_TYPES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_invc_line_types_tl_rec   IN OklInvcLineTypesTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklInvcLineTypesTlRecType IS
    CURSOR okl_invc_line_types_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Invc_Line_Types_Tl
     WHERE okl_invc_line_types_tl.id = p_id
       AND okl_invc_line_types_tl.LANGUAGE = p_language;
    l_okl_invc_line_types_tl_pk    okl_invc_line_types_tl_pk_csr%ROWTYPE;
    l_okl_invc_line_types_tl_rec   OklInvcLineTypesTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_invc_line_types_tl_pk_csr (p_okl_invc_line_types_tl_rec.id,
                                        p_okl_invc_line_types_tl_rec.LANGUAGE);
    FETCH okl_invc_line_types_tl_pk_csr INTO
              l_okl_invc_line_types_tl_rec.ID,
              l_okl_invc_line_types_tl_rec.LANGUAGE,
              l_okl_invc_line_types_tl_rec.SOURCE_LANG,
              l_okl_invc_line_types_tl_rec.SFWT_FLAG,
              l_okl_invc_line_types_tl_rec.NAME,
              l_okl_invc_line_types_tl_rec.DESCRIPTION,
              l_okl_invc_line_types_tl_rec.CREATED_BY,
              l_okl_invc_line_types_tl_rec.CREATION_DATE,
              l_okl_invc_line_types_tl_rec.LAST_UPDATED_BY,
              l_okl_invc_line_types_tl_rec.LAST_UPDATE_DATE,
              l_okl_invc_line_types_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_invc_line_types_tl_pk_csr%NOTFOUND;
    CLOSE okl_invc_line_types_tl_pk_csr;
    RETURN(l_okl_invc_line_types_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_invc_line_types_tl_rec   IN OklInvcLineTypesTlRecType
  ) RETURN OklInvcLineTypesTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_invc_line_types_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVC_LINE_TYPES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_iltv_rec                     IN iltv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN iltv_rec_type IS
    CURSOR okl_iltv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            ITY_ID,
            SEQUENCE_NUMBER,
            NAME,
            DESCRIPTION,
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
      FROM Okl_Invc_Line_Types_V
     WHERE okl_invc_line_types_v.id = p_id;
    l_okl_iltv_pk                  okl_iltv_pk_csr%ROWTYPE;
    l_iltv_rec                     iltv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_iltv_pk_csr (p_iltv_rec.id);
    FETCH okl_iltv_pk_csr INTO
              l_iltv_rec.ID,
              l_iltv_rec.OBJECT_VERSION_NUMBER,
              l_iltv_rec.SFWT_FLAG,
              l_iltv_rec.ITY_ID,
              l_iltv_rec.SEQUENCE_NUMBER,
              l_iltv_rec.NAME,
              l_iltv_rec.DESCRIPTION,
              l_iltv_rec.ATTRIBUTE_CATEGORY,
              l_iltv_rec.ATTRIBUTE1,
              l_iltv_rec.ATTRIBUTE2,
              l_iltv_rec.ATTRIBUTE3,
              l_iltv_rec.ATTRIBUTE4,
              l_iltv_rec.ATTRIBUTE5,
              l_iltv_rec.ATTRIBUTE6,
              l_iltv_rec.ATTRIBUTE7,
              l_iltv_rec.ATTRIBUTE8,
              l_iltv_rec.ATTRIBUTE9,
              l_iltv_rec.ATTRIBUTE10,
              l_iltv_rec.ATTRIBUTE11,
              l_iltv_rec.ATTRIBUTE12,
              l_iltv_rec.ATTRIBUTE13,
              l_iltv_rec.ATTRIBUTE14,
              l_iltv_rec.ATTRIBUTE15,
              l_iltv_rec.CREATED_BY,
              l_iltv_rec.CREATION_DATE,
              l_iltv_rec.LAST_UPDATED_BY,
              l_iltv_rec.LAST_UPDATE_DATE,
              l_iltv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_iltv_pk_csr%NOTFOUND;
    CLOSE okl_iltv_pk_csr;
    RETURN(l_iltv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_iltv_rec                     IN iltv_rec_type
  ) RETURN iltv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_iltv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INVC_LINE_TYPES_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_iltv_rec	IN iltv_rec_type
  ) RETURN iltv_rec_type IS
    l_iltv_rec	iltv_rec_type := p_iltv_rec;
  BEGIN
    IF (l_iltv_rec.object_version_number = okl_api.G_MISS_NUM) THEN
      l_iltv_rec.object_version_number := NULL;
    END IF;
    IF (l_iltv_rec.sfwt_flag = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_iltv_rec.ity_id = okl_api.G_MISS_NUM) THEN
      l_iltv_rec.ity_id := NULL;
    END IF;
    IF (l_iltv_rec.sequence_number = okl_api.G_MISS_NUM) THEN
      l_iltv_rec.sequence_number := NULL;
    END IF;
    IF (l_iltv_rec.name = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.name := NULL;
    END IF;
    IF (l_iltv_rec.description = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.description := NULL;
    END IF;
    IF (l_iltv_rec.attribute_category = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute_category := NULL;
    END IF;
    IF (l_iltv_rec.attribute1 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute1 := NULL;
    END IF;
    IF (l_iltv_rec.attribute2 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute2 := NULL;
    END IF;
    IF (l_iltv_rec.attribute3 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute3 := NULL;
    END IF;
    IF (l_iltv_rec.attribute4 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute4 := NULL;
    END IF;
    IF (l_iltv_rec.attribute5 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute5 := NULL;
    END IF;
    IF (l_iltv_rec.attribute6 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute6 := NULL;
    END IF;
    IF (l_iltv_rec.attribute7 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute7 := NULL;
    END IF;
    IF (l_iltv_rec.attribute8 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute8 := NULL;
    END IF;
    IF (l_iltv_rec.attribute9 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute9 := NULL;
    END IF;
    IF (l_iltv_rec.attribute10 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute10 := NULL;
    END IF;
    IF (l_iltv_rec.attribute11 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute11 := NULL;
    END IF;
    IF (l_iltv_rec.attribute12 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute12 := NULL;
    END IF;
    IF (l_iltv_rec.attribute13 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute13 := NULL;
    END IF;
    IF (l_iltv_rec.attribute14 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute14 := NULL;
    END IF;
    IF (l_iltv_rec.attribute15 = okl_api.G_MISS_CHAR) THEN
      l_iltv_rec.attribute15 := NULL;
    END IF;
    IF (l_iltv_rec.created_by = okl_api.G_MISS_NUM) THEN
      l_iltv_rec.created_by := NULL;
    END IF;
    IF (l_iltv_rec.creation_date = okl_api.G_MISS_DATE) THEN
      l_iltv_rec.creation_date := NULL;
    END IF;
    IF (l_iltv_rec.last_updated_by = okl_api.G_MISS_NUM) THEN
      l_iltv_rec.last_updated_by := NULL;
    END IF;
    IF (l_iltv_rec.last_update_date = okl_api.G_MISS_DATE) THEN
      l_iltv_rec.last_update_date := NULL;
    END IF;
    IF (l_iltv_rec.last_update_login = okl_api.G_MISS_NUM) THEN
      l_iltv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_iltv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_INVC_LINE_TYPES_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_iltv_rec IN  iltv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1)	:= okl_api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
     -- Call each column level validation

  validate_id(x_return_status => l_return_status,
			 	p_iltv_rec =>	p_iltv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_object_version_number(x_return_status => l_return_status,
			 	p_iltv_rec =>	p_iltv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_ity_id(x_return_status => l_return_status,
			 	p_iltv_rec =>	p_iltv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_name(x_return_status => l_return_status,
			 	p_iltv_rec =>	p_iltv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_sequence_number(x_return_status => l_return_status,
			 	p_iltv_rec =>	p_iltv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;


    RETURN(x_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_INVC_LINE_TYPES_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_iltv_rec IN iltv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
      l_return_status := IS_UNIQUE(p_iltv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN iltv_rec_type,
    p_to	OUT NOCOPY ilt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ity_id := p_from.ity_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_number := p_from.sequence_number;
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
    p_from	IN ilt_rec_type,
    p_to	OUT NOCOPY iltv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ity_id := p_from.ity_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_number := p_from.sequence_number;
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
    p_from	IN iltv_rec_type,
    p_to	OUT NOCOPY OklInvcLineTypesTlRecType
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
    p_from	IN OklInvcLineTypesTlRecType,
    p_to	OUT NOCOPY iltv_rec_type
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
  -- validate_row for:OKL_INVC_LINE_TYPES_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iltv_rec                     IN iltv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_iltv_rec                     iltv_rec_type := p_iltv_rec;
    l_ilt_rec                      ilt_rec_type;
    l_okl_invc_line_types_tl_rec   OklInvcLineTypesTlRecType;
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
    l_return_status := Validate_Attributes(l_iltv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_iltv_rec);
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
  -- PL/SQL TBL validate_row for:ILTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iltv_tbl                     IN iltv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iltv_tbl.COUNT > 0) THEN
      i := p_iltv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_iltv_rec                     => p_iltv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_iltv_tbl.LAST);
        i := p_iltv_tbl.NEXT(i);
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
  -- insert_row for:OKL_INVC_LINE_TYPES_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilt_rec                      IN ilt_rec_type,
    x_ilt_rec                      OUT NOCOPY ilt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ilt_rec                      ilt_rec_type := p_ilt_rec;
    l_def_ilt_rec                  ilt_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INVC_LINE_TYPES_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ilt_rec IN  ilt_rec_type,
      x_ilt_rec OUT NOCOPY ilt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ilt_rec := p_ilt_rec;
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
      p_ilt_rec,                         -- IN
      l_ilt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_INVC_LINE_TYPES_B(
        id,
        ity_id,
        object_version_number,
        sequence_number,
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
        l_ilt_rec.id,
        l_ilt_rec.ity_id,
        l_ilt_rec.object_version_number,
        l_ilt_rec.sequence_number,
        l_ilt_rec.attribute_category,
        l_ilt_rec.attribute1,
        l_ilt_rec.attribute2,
        l_ilt_rec.attribute3,
        l_ilt_rec.attribute4,
        l_ilt_rec.attribute5,
        l_ilt_rec.attribute6,
        l_ilt_rec.attribute7,
        l_ilt_rec.attribute8,
        l_ilt_rec.attribute9,
        l_ilt_rec.attribute10,
        l_ilt_rec.attribute11,
        l_ilt_rec.attribute12,
        l_ilt_rec.attribute13,
        l_ilt_rec.attribute14,
        l_ilt_rec.attribute15,
        l_ilt_rec.created_by,
        l_ilt_rec.creation_date,
        l_ilt_rec.last_updated_by,
        l_ilt_rec.last_update_date,
        l_ilt_rec.last_update_login);
    -- Set OUT values
    x_ilt_rec := l_ilt_rec;
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
  END insert_row;
  -------------------------------------------
  -- insert_row for:OKL_INVC_LINE_TYPES_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invc_line_types_tl_rec   IN OklInvcLineTypesTlRecType,
    x_okl_invc_line_types_tl_rec   OUT NOCOPY OklInvcLineTypesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_invc_line_types_tl_rec   OklInvcLineTypesTlRecType := p_okl_invc_line_types_tl_rec;
    ldefoklinvclinetypestlrec      OklInvcLineTypesTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_INVC_LINE_TYPES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invc_line_types_tl_rec IN  OklInvcLineTypesTlRecType,
      x_okl_invc_line_types_tl_rec OUT NOCOPY OklInvcLineTypesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invc_line_types_tl_rec := p_okl_invc_line_types_tl_rec;
      x_okl_invc_line_types_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_invc_line_types_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_invc_line_types_tl_rec,      -- IN
      l_okl_invc_line_types_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_invc_line_types_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_INVC_LINE_TYPES_TL(
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
          l_okl_invc_line_types_tl_rec.id,
          l_okl_invc_line_types_tl_rec.LANGUAGE,
          l_okl_invc_line_types_tl_rec.source_lang,
          l_okl_invc_line_types_tl_rec.sfwt_flag,
          l_okl_invc_line_types_tl_rec.name,
          l_okl_invc_line_types_tl_rec.description,
          l_okl_invc_line_types_tl_rec.created_by,
          l_okl_invc_line_types_tl_rec.creation_date,
          l_okl_invc_line_types_tl_rec.last_updated_by,
          l_okl_invc_line_types_tl_rec.last_update_date,
          l_okl_invc_line_types_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_invc_line_types_tl_rec := l_okl_invc_line_types_tl_rec;
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
  END insert_row;
  ------------------------------------------
  -- insert_row for:OKL_INVC_LINE_TYPES_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iltv_rec                     IN iltv_rec_type,
    x_iltv_rec                     OUT NOCOPY iltv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_iltv_rec                     iltv_rec_type;
    l_def_iltv_rec                 iltv_rec_type;
    l_ilt_rec                      ilt_rec_type;
    lx_ilt_rec                     ilt_rec_type;
    l_okl_invc_line_types_tl_rec   OklInvcLineTypesTlRecType;
    lx_okl_invc_line_types_tl_rec  OklInvcLineTypesTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_iltv_rec	IN iltv_rec_type
    ) RETURN iltv_rec_type IS
      l_iltv_rec	iltv_rec_type := p_iltv_rec;
    BEGIN
      l_iltv_rec.CREATION_DATE := SYSDATE;
      l_iltv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_iltv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_iltv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_iltv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_iltv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INVC_LINE_TYPES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_iltv_rec IN  iltv_rec_type,
      x_iltv_rec OUT NOCOPY iltv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_iltv_rec := p_iltv_rec;
      x_iltv_rec.OBJECT_VERSION_NUMBER := 1;
      x_iltv_rec.SFWT_FLAG := 'N';
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
    l_iltv_rec := null_out_defaults(p_iltv_rec);
    -- Set primary key value
    l_iltv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_iltv_rec,                        -- IN
      l_def_iltv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_iltv_rec := fill_who_columns(l_def_iltv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_iltv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_iltv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_iltv_rec, l_ilt_rec);
    migrate(l_def_iltv_rec, l_okl_invc_line_types_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ilt_rec,
      lx_ilt_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ilt_rec, l_def_iltv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invc_line_types_tl_rec,
      lx_okl_invc_line_types_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_invc_line_types_tl_rec, l_def_iltv_rec);
    -- Set OUT values
    x_iltv_rec := l_def_iltv_rec;
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
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:ILTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iltv_tbl                     IN iltv_tbl_type,
    x_iltv_tbl                     OUT NOCOPY iltv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iltv_tbl.COUNT > 0) THEN
      i := p_iltv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_iltv_rec                     => p_iltv_tbl(i),
          x_iltv_rec                     => x_iltv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_iltv_tbl.LAST);
        i := p_iltv_tbl.NEXT(i);
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
  -- lock_row for:OKL_INVC_LINE_TYPES_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilt_rec                      IN ilt_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ilt_rec IN ilt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INVC_LINE_TYPES_B
     WHERE ID = p_ilt_rec.id
       AND OBJECT_VERSION_NUMBER = p_ilt_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ilt_rec IN ilt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INVC_LINE_TYPES_B
    WHERE ID = p_ilt_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INVC_LINE_TYPES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INVC_LINE_TYPES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ilt_rec);
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
      OPEN lchk_csr(p_ilt_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ilt_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ilt_rec.object_version_number THEN
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
  -- lock_row for:OKL_INVC_LINE_TYPES_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invc_line_types_tl_rec   IN OklInvcLineTypesTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_invc_line_types_tl_rec IN OklInvcLineTypesTlRecType) IS
    SELECT *
      FROM OKL_INVC_LINE_TYPES_TL
     WHERE ID = p_okl_invc_line_types_tl_rec.id
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
      OPEN lock_csr(p_okl_invc_line_types_tl_rec);
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
  -- lock_row for:OKL_INVC_LINE_TYPES_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iltv_rec                     IN iltv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ilt_rec                      ilt_rec_type;
    l_okl_invc_line_types_tl_rec   OklInvcLineTypesTlRecType;
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
    migrate(p_iltv_rec, l_ilt_rec);
    migrate(p_iltv_rec, l_okl_invc_line_types_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ilt_rec
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
      l_okl_invc_line_types_tl_rec
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
  -- PL/SQL TBL lock_row for:ILTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iltv_tbl                     IN iltv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iltv_tbl.COUNT > 0) THEN
      i := p_iltv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_iltv_rec                     => p_iltv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_iltv_tbl.LAST);
        i := p_iltv_tbl.NEXT(i);
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
  -- update_row for:OKL_INVC_LINE_TYPES_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilt_rec                      IN ilt_rec_type,
    x_ilt_rec                      OUT NOCOPY ilt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ilt_rec                      ilt_rec_type := p_ilt_rec;
    l_def_ilt_rec                  ilt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ilt_rec	IN ilt_rec_type,
      x_ilt_rec	OUT NOCOPY ilt_rec_type
    ) RETURN VARCHAR2 IS
      l_ilt_rec                      ilt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ilt_rec := p_ilt_rec;
      -- Get current database values
      l_ilt_rec := get_rec(p_ilt_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ilt_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_ilt_rec.id := l_ilt_rec.id;
      END IF;
      IF (x_ilt_rec.ity_id = okl_api.G_MISS_NUM)
      THEN
        x_ilt_rec.ity_id := l_ilt_rec.ity_id;
      END IF;
      IF (x_ilt_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_ilt_rec.object_version_number := l_ilt_rec.object_version_number;
      END IF;
      IF (x_ilt_rec.sequence_number = okl_api.G_MISS_NUM)
      THEN
        x_ilt_rec.sequence_number := l_ilt_rec.sequence_number;
      END IF;
      IF (x_ilt_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute_category := l_ilt_rec.attribute_category;
      END IF;
      IF (x_ilt_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute1 := l_ilt_rec.attribute1;
      END IF;
      IF (x_ilt_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute2 := l_ilt_rec.attribute2;
      END IF;
      IF (x_ilt_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute3 := l_ilt_rec.attribute3;
      END IF;
      IF (x_ilt_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute4 := l_ilt_rec.attribute4;
      END IF;
      IF (x_ilt_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute5 := l_ilt_rec.attribute5;
      END IF;
      IF (x_ilt_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute6 := l_ilt_rec.attribute6;
      END IF;
      IF (x_ilt_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute7 := l_ilt_rec.attribute7;
      END IF;
      IF (x_ilt_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute8 := l_ilt_rec.attribute8;
      END IF;
      IF (x_ilt_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute9 := l_ilt_rec.attribute9;
      END IF;
      IF (x_ilt_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute10 := l_ilt_rec.attribute10;
      END IF;
      IF (x_ilt_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute11 := l_ilt_rec.attribute11;
      END IF;
      IF (x_ilt_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute12 := l_ilt_rec.attribute12;
      END IF;
      IF (x_ilt_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute13 := l_ilt_rec.attribute13;
      END IF;
      IF (x_ilt_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute14 := l_ilt_rec.attribute14;
      END IF;
      IF (x_ilt_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_ilt_rec.attribute15 := l_ilt_rec.attribute15;
      END IF;
      IF (x_ilt_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_ilt_rec.created_by := l_ilt_rec.created_by;
      END IF;
      IF (x_ilt_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_ilt_rec.creation_date := l_ilt_rec.creation_date;
      END IF;
      IF (x_ilt_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_ilt_rec.last_updated_by := l_ilt_rec.last_updated_by;
      END IF;
      IF (x_ilt_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_ilt_rec.last_update_date := l_ilt_rec.last_update_date;
      END IF;
      IF (x_ilt_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_ilt_rec.last_update_login := l_ilt_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INVC_LINE_TYPES_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ilt_rec IN  ilt_rec_type,
      x_ilt_rec OUT NOCOPY ilt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ilt_rec := p_ilt_rec;
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
      p_ilt_rec,                         -- IN
      l_ilt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ilt_rec, l_def_ilt_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INVC_LINE_TYPES_B
    SET ITY_ID = l_def_ilt_rec.ity_id,
        OBJECT_VERSION_NUMBER = l_def_ilt_rec.object_version_number,
        SEQUENCE_NUMBER = l_def_ilt_rec.sequence_number,
        ATTRIBUTE_CATEGORY = l_def_ilt_rec.attribute_category,
        ATTRIBUTE1 = l_def_ilt_rec.attribute1,
        ATTRIBUTE2 = l_def_ilt_rec.attribute2,
        ATTRIBUTE3 = l_def_ilt_rec.attribute3,
        ATTRIBUTE4 = l_def_ilt_rec.attribute4,
        ATTRIBUTE5 = l_def_ilt_rec.attribute5,
        ATTRIBUTE6 = l_def_ilt_rec.attribute6,
        ATTRIBUTE7 = l_def_ilt_rec.attribute7,
        ATTRIBUTE8 = l_def_ilt_rec.attribute8,
        ATTRIBUTE9 = l_def_ilt_rec.attribute9,
        ATTRIBUTE10 = l_def_ilt_rec.attribute10,
        ATTRIBUTE11 = l_def_ilt_rec.attribute11,
        ATTRIBUTE12 = l_def_ilt_rec.attribute12,
        ATTRIBUTE13 = l_def_ilt_rec.attribute13,
        ATTRIBUTE14 = l_def_ilt_rec.attribute14,
        ATTRIBUTE15 = l_def_ilt_rec.attribute15,
        CREATED_BY = l_def_ilt_rec.created_by,
        CREATION_DATE = l_def_ilt_rec.creation_date,
        LAST_UPDATED_BY = l_def_ilt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ilt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ilt_rec.last_update_login
    WHERE ID = l_def_ilt_rec.id;

    x_ilt_rec := l_def_ilt_rec;
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
  -- update_row for:OKL_INVC_LINE_TYPES_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invc_line_types_tl_rec   IN OklInvcLineTypesTlRecType,
    x_okl_invc_line_types_tl_rec   OUT NOCOPY OklInvcLineTypesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_invc_line_types_tl_rec   OklInvcLineTypesTlRecType := p_okl_invc_line_types_tl_rec;
    ldefoklinvclinetypestlrec      OklInvcLineTypesTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_invc_line_types_tl_rec	IN OklInvcLineTypesTlRecType,
      x_okl_invc_line_types_tl_rec	OUT NOCOPY OklInvcLineTypesTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_invc_line_types_tl_rec   OklInvcLineTypesTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invc_line_types_tl_rec := p_okl_invc_line_types_tl_rec;
      -- Get current database values
      l_okl_invc_line_types_tl_rec := get_rec(p_okl_invc_line_types_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_okl_invc_line_types_tl_rec.id := l_okl_invc_line_types_tl_rec.id;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.LANGUAGE = okl_api.G_MISS_CHAR)
      THEN
        x_okl_invc_line_types_tl_rec.LANGUAGE := l_okl_invc_line_types_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.source_lang = okl_api.G_MISS_CHAR)
      THEN
        x_okl_invc_line_types_tl_rec.source_lang := l_okl_invc_line_types_tl_rec.source_lang;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.sfwt_flag = okl_api.G_MISS_CHAR)
      THEN
        x_okl_invc_line_types_tl_rec.sfwt_flag := l_okl_invc_line_types_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.name = okl_api.G_MISS_CHAR)
      THEN
        x_okl_invc_line_types_tl_rec.name := l_okl_invc_line_types_tl_rec.name;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.description = okl_api.G_MISS_CHAR)
      THEN
        x_okl_invc_line_types_tl_rec.description := l_okl_invc_line_types_tl_rec.description;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_okl_invc_line_types_tl_rec.created_by := l_okl_invc_line_types_tl_rec.created_by;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_okl_invc_line_types_tl_rec.creation_date := l_okl_invc_line_types_tl_rec.creation_date;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_okl_invc_line_types_tl_rec.last_updated_by := l_okl_invc_line_types_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_okl_invc_line_types_tl_rec.last_update_date := l_okl_invc_line_types_tl_rec.last_update_date;
      END IF;
      IF (x_okl_invc_line_types_tl_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_okl_invc_line_types_tl_rec.last_update_login := l_okl_invc_line_types_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_INVC_LINE_TYPES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invc_line_types_tl_rec IN  OklInvcLineTypesTlRecType,
      x_okl_invc_line_types_tl_rec OUT NOCOPY OklInvcLineTypesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invc_line_types_tl_rec := p_okl_invc_line_types_tl_rec;
      x_okl_invc_line_types_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_invc_line_types_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_invc_line_types_tl_rec,      -- IN
      l_okl_invc_line_types_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_invc_line_types_tl_rec, ldefoklinvclinetypestlrec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INVC_LINE_TYPES_TL
    SET NAME = ldefoklinvclinetypestlrec.name,
        DESCRIPTION = ldefoklinvclinetypestlrec.description,
        CREATED_BY = ldefoklinvclinetypestlrec.created_by,
        CREATION_DATE = ldefoklinvclinetypestlrec.creation_date,
        LAST_UPDATED_BY = ldefoklinvclinetypestlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklinvclinetypestlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklinvclinetypestlrec.last_update_login
    WHERE ID = ldefoklinvclinetypestlrec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_INVC_LINE_TYPES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklinvclinetypestlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_invc_line_types_tl_rec := ldefoklinvclinetypestlrec;
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
  -- update_row for:OKL_INVC_LINE_TYPES_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iltv_rec                     IN iltv_rec_type,
    x_iltv_rec                     OUT NOCOPY iltv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_iltv_rec                     iltv_rec_type := p_iltv_rec;
    l_def_iltv_rec                 iltv_rec_type;
    l_okl_invc_line_types_tl_rec   OklInvcLineTypesTlRecType;
    lx_okl_invc_line_types_tl_rec  OklInvcLineTypesTlRecType;
    l_ilt_rec                      ilt_rec_type;
    lx_ilt_rec                     ilt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_iltv_rec	IN iltv_rec_type
    ) RETURN iltv_rec_type IS
      l_iltv_rec	iltv_rec_type := p_iltv_rec;
    BEGIN
      l_iltv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_iltv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_iltv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_iltv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_iltv_rec	IN iltv_rec_type,
      x_iltv_rec	OUT NOCOPY iltv_rec_type
    ) RETURN VARCHAR2 IS
      l_iltv_rec                     iltv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_iltv_rec := p_iltv_rec;
      -- Get current database values
      l_iltv_rec := get_rec(p_iltv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_iltv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_iltv_rec.id := l_iltv_rec.id;
      END IF;
      IF (x_iltv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_iltv_rec.object_version_number := l_iltv_rec.object_version_number;
      END IF;
      IF (x_iltv_rec.sfwt_flag = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.sfwt_flag := l_iltv_rec.sfwt_flag;
      END IF;
      IF (x_iltv_rec.ity_id = okl_api.G_MISS_NUM)
      THEN
        x_iltv_rec.ity_id := l_iltv_rec.ity_id;
      END IF;
      IF (x_iltv_rec.sequence_number = okl_api.G_MISS_NUM)
      THEN
        x_iltv_rec.sequence_number := l_iltv_rec.sequence_number;
      END IF;
      IF (x_iltv_rec.name = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.name := l_iltv_rec.name;
      END IF;
      IF (x_iltv_rec.description = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.description := l_iltv_rec.description;
      END IF;
      IF (x_iltv_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute_category := l_iltv_rec.attribute_category;
      END IF;
      IF (x_iltv_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute1 := l_iltv_rec.attribute1;
      END IF;
      IF (x_iltv_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute2 := l_iltv_rec.attribute2;
      END IF;
      IF (x_iltv_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute3 := l_iltv_rec.attribute3;
      END IF;
      IF (x_iltv_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute4 := l_iltv_rec.attribute4;
      END IF;
      IF (x_iltv_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute5 := l_iltv_rec.attribute5;
      END IF;
      IF (x_iltv_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute6 := l_iltv_rec.attribute6;
      END IF;
      IF (x_iltv_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute7 := l_iltv_rec.attribute7;
      END IF;
      IF (x_iltv_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute8 := l_iltv_rec.attribute8;
      END IF;
      IF (x_iltv_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute9 := l_iltv_rec.attribute9;
      END IF;
      IF (x_iltv_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute10 := l_iltv_rec.attribute10;
      END IF;
      IF (x_iltv_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute11 := l_iltv_rec.attribute11;
      END IF;
      IF (x_iltv_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute12 := l_iltv_rec.attribute12;
      END IF;
      IF (x_iltv_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute13 := l_iltv_rec.attribute13;
      END IF;
      IF (x_iltv_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute14 := l_iltv_rec.attribute14;
      END IF;
      IF (x_iltv_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_iltv_rec.attribute15 := l_iltv_rec.attribute15;
      END IF;
      IF (x_iltv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_iltv_rec.created_by := l_iltv_rec.created_by;
      END IF;
      IF (x_iltv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_iltv_rec.creation_date := l_iltv_rec.creation_date;
      END IF;
      IF (x_iltv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_iltv_rec.last_updated_by := l_iltv_rec.last_updated_by;
      END IF;
      IF (x_iltv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_iltv_rec.last_update_date := l_iltv_rec.last_update_date;
      END IF;
      IF (x_iltv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_iltv_rec.last_update_login := l_iltv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INVC_LINE_TYPES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_iltv_rec IN  iltv_rec_type,
      x_iltv_rec OUT NOCOPY iltv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_iltv_rec := p_iltv_rec;
      x_iltv_rec.OBJECT_VERSION_NUMBER := NVL(x_iltv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_iltv_rec,                        -- IN
      l_iltv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_iltv_rec, l_def_iltv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_iltv_rec := fill_who_columns(l_def_iltv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_iltv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_iltv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_iltv_rec, l_okl_invc_line_types_tl_rec);
    migrate(l_def_iltv_rec, l_ilt_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invc_line_types_tl_rec,
      lx_okl_invc_line_types_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_invc_line_types_tl_rec, l_def_iltv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ilt_rec,
      lx_ilt_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ilt_rec, l_def_iltv_rec);
    x_iltv_rec := l_def_iltv_rec;
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
  -- PL/SQL TBL update_row for:ILTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iltv_tbl                     IN iltv_tbl_type,
    x_iltv_tbl                     OUT NOCOPY iltv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iltv_tbl.COUNT > 0) THEN
      i := p_iltv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_iltv_rec                     => p_iltv_tbl(i),
          x_iltv_rec                     => x_iltv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_iltv_tbl.LAST);
        i := p_iltv_tbl.NEXT(i);
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
  -- delete_row for:OKL_INVC_LINE_TYPES_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilt_rec                      IN ilt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ilt_rec                      ilt_rec_type:= p_ilt_rec;
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
    DELETE FROM OKL_INVC_LINE_TYPES_B
     WHERE ID = l_ilt_rec.id;

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
  -- delete_row for:OKL_INVC_LINE_TYPES_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invc_line_types_tl_rec   IN OklInvcLineTypesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_invc_line_types_tl_rec   OklInvcLineTypesTlRecType:= p_okl_invc_line_types_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_INVC_LINE_TYPES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invc_line_types_tl_rec IN  OklInvcLineTypesTlRecType,
      x_okl_invc_line_types_tl_rec OUT NOCOPY OklInvcLineTypesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invc_line_types_tl_rec := p_okl_invc_line_types_tl_rec;
      x_okl_invc_line_types_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_invc_line_types_tl_rec,      -- IN
      l_okl_invc_line_types_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_INVC_LINE_TYPES_TL
     WHERE ID = l_okl_invc_line_types_tl_rec.id;

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
  -- delete_row for:OKL_INVC_LINE_TYPES_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iltv_rec                     IN iltv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_iltv_rec                     iltv_rec_type := p_iltv_rec;
    l_okl_invc_line_types_tl_rec   OklInvcLineTypesTlRecType;
    l_ilt_rec                      ilt_rec_type;
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
    migrate(l_iltv_rec, l_okl_invc_line_types_tl_rec);
    migrate(l_iltv_rec, l_ilt_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invc_line_types_tl_rec
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
      l_ilt_rec
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
  -- PL/SQL TBL delete_row for:ILTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iltv_tbl                     IN iltv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iltv_tbl.COUNT > 0) THEN
      i := p_iltv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_iltv_rec                     => p_iltv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_iltv_tbl.LAST);
        i := p_iltv_tbl.NEXT(i);
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
END Okl_Ilt_Pvt;

/
