--------------------------------------------------------
--  DDL for Package Body OKL_CUV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CUV_PVT" AS
/* $Header: OKLSCUVB.pls 115.5 2004/05/24 23:27:33 pjgomes noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_cuvv_rec IN cuvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_cuvv_rec.id = Okl_Api.G_MISS_NUM OR
       p_cuvv_rec.id IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number (p_cuvv_rec IN cuvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_cuvv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_cuvv_rec.object_version_number IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     => G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'object_version_number');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_crn_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_crn_id (p_cuvv_rec IN cuvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_crn_id_csr IS
    SELECT '1'
	FROM OKL_CRITERIA_B
	WHERE id = p_cuvv_rec.crn_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_cuvv_rec.crn_id = Okl_Api.G_MISS_NUM OR
       p_cuvv_rec.crn_id IS NULL
    THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'crn_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Validate Foreign Key
 	OPEN l_crn_id_csr;
	FETCH l_crn_id_csr INTO l_dummy_var;
	CLOSE l_crn_id_csr;

	IF (l_dummy_var <> '1') THEN
	 	x_return_status := Okl_Api.G_RET_STS_ERROR;
	    Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
		 				    p_msg_name			=> G_NO_PARENT_RECORD,
							p_token1			=> G_COL_NAME_TOKEN,
							p_token1_value		=> 'CRN_ID_FOR',
							p_token2			=> G_CHILD_TABLE_TOKEN,
							p_token2_value		=> G_VIEW,
							p_token3			=> G_PARENT_TABLE_TOKEN,
							p_token3_value		=> 'OKL_CRTRN_USER_VALS_V');

		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END validate_crn_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_sequence_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_sequence_number (p_cuvv_rec IN cuvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_cuvv_rec.sequence_number = Okl_Api.G_MISS_NUM OR
       p_cuvv_rec.sequence_number IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'sequence_number');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_sequence_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_value
  ---------------------------------------------------------------------------
  PROCEDURE validate_value (p_cuvv_rec IN cuvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_cuvv_rec.value = Okl_Api.G_MISS_NUM OR
       p_cuvv_rec.value IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'value');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_value;

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
    DELETE FROM OKL_CRTRN_USER_VALS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_CRTRN_USER_VALS_B B      --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_CRTRN_USER_VALS_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_CRTRN_USER_VALS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_CRTRN_USER_VALS_TL SUBB, OKL_CRTRN_USER_VALS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_CRTRN_USER_VALS_TL (
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
        FROM OKL_CRTRN_USER_VALS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_CRTRN_USER_VALS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CRTRN_USER_VALS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cuv_rec                      IN cuv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cuv_rec_type IS
    CURSOR cuv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CRN_ID,
            SEQUENCE_NUMBER,
            VALUE,
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
      FROM Okl_Crtrn_User_Vals_B
     WHERE okl_crtrn_user_vals_b.id = p_id;
    l_cuv_pk                       cuv_pk_csr%ROWTYPE;
    l_cuv_rec                      cuv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cuv_pk_csr (p_cuv_rec.id);
    FETCH cuv_pk_csr INTO
              l_cuv_rec.ID,
              l_cuv_rec.CRN_ID,
              l_cuv_rec.SEQUENCE_NUMBER,
              l_cuv_rec.VALUE,
              l_cuv_rec.OBJECT_VERSION_NUMBER,
              l_cuv_rec.ATTRIBUTE_CATEGORY,
              l_cuv_rec.ATTRIBUTE1,
              l_cuv_rec.ATTRIBUTE2,
              l_cuv_rec.ATTRIBUTE3,
              l_cuv_rec.ATTRIBUTE4,
              l_cuv_rec.ATTRIBUTE5,
              l_cuv_rec.ATTRIBUTE6,
              l_cuv_rec.ATTRIBUTE7,
              l_cuv_rec.ATTRIBUTE8,
              l_cuv_rec.ATTRIBUTE9,
              l_cuv_rec.ATTRIBUTE10,
              l_cuv_rec.ATTRIBUTE11,
              l_cuv_rec.ATTRIBUTE12,
              l_cuv_rec.ATTRIBUTE13,
              l_cuv_rec.ATTRIBUTE14,
              l_cuv_rec.ATTRIBUTE15,
              l_cuv_rec.CREATED_BY,
              l_cuv_rec.CREATION_DATE,
              l_cuv_rec.LAST_UPDATED_BY,
              l_cuv_rec.LAST_UPDATE_DATE,
              l_cuv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cuv_pk_csr%NOTFOUND;
    CLOSE cuv_pk_csr;
    RETURN(l_cuv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cuv_rec                      IN cuv_rec_type
  ) RETURN cuv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cuv_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CRTRN_USER_VALS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_crtrn_user_vals_tl_rec   IN OklCrtrnUserValsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklCrtrnUserValsTlRecType IS
    CURSOR okl_crtrn_user_vals_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Crtrn_User_Vals_Tl
     WHERE okl_crtrn_user_vals_tl.id = p_id
       AND okl_crtrn_user_vals_tl.LANGUAGE = p_language;
    l_okl_crtrn_user_vals_tl_pk    okl_crtrn_user_vals_tl_pk_csr%ROWTYPE;
    l_okl_crtrn_user_vals_tl_rec   OklCrtrnUserValsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_crtrn_user_vals_tl_pk_csr (p_okl_crtrn_user_vals_tl_rec.id,
                                        p_okl_crtrn_user_vals_tl_rec.LANGUAGE);
    FETCH okl_crtrn_user_vals_tl_pk_csr INTO
              l_okl_crtrn_user_vals_tl_rec.ID,
              l_okl_crtrn_user_vals_tl_rec.LANGUAGE,
              l_okl_crtrn_user_vals_tl_rec.SOURCE_LANG,
              l_okl_crtrn_user_vals_tl_rec.SFWT_FLAG,
              l_okl_crtrn_user_vals_tl_rec.DESCRIPTION,
              l_okl_crtrn_user_vals_tl_rec.CREATED_BY,
              l_okl_crtrn_user_vals_tl_rec.CREATION_DATE,
              l_okl_crtrn_user_vals_tl_rec.LAST_UPDATED_BY,
              l_okl_crtrn_user_vals_tl_rec.LAST_UPDATE_DATE,
              l_okl_crtrn_user_vals_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_crtrn_user_vals_tl_pk_csr%NOTFOUND;
    CLOSE okl_crtrn_user_vals_tl_pk_csr;
    RETURN(l_okl_crtrn_user_vals_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_crtrn_user_vals_tl_rec   IN OklCrtrnUserValsTlRecType
  ) RETURN OklCrtrnUserValsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_crtrn_user_vals_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CRTRN_USER_VALS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cuvv_rec                     IN cuvv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cuvv_rec_type IS
    CURSOR okl_cuvv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CRN_ID,
            SEQUENCE_NUMBER,
            VALUE,
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
      FROM Okl_Crtrn_User_Vals_V
     WHERE okl_crtrn_user_vals_v.id = p_id;
    l_okl_cuvv_pk                  okl_cuvv_pk_csr%ROWTYPE;
    l_cuvv_rec                     cuvv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cuvv_pk_csr (p_cuvv_rec.id);
    FETCH okl_cuvv_pk_csr INTO
              l_cuvv_rec.ID,
              l_cuvv_rec.OBJECT_VERSION_NUMBER,
              l_cuvv_rec.SFWT_FLAG,
              l_cuvv_rec.CRN_ID,
              l_cuvv_rec.SEQUENCE_NUMBER,
              l_cuvv_rec.VALUE,
              l_cuvv_rec.DESCRIPTION,
              l_cuvv_rec.ATTRIBUTE_CATEGORY,
              l_cuvv_rec.ATTRIBUTE1,
              l_cuvv_rec.ATTRIBUTE2,
              l_cuvv_rec.ATTRIBUTE3,
              l_cuvv_rec.ATTRIBUTE4,
              l_cuvv_rec.ATTRIBUTE5,
              l_cuvv_rec.ATTRIBUTE6,
              l_cuvv_rec.ATTRIBUTE7,
              l_cuvv_rec.ATTRIBUTE8,
              l_cuvv_rec.ATTRIBUTE9,
              l_cuvv_rec.ATTRIBUTE10,
              l_cuvv_rec.ATTRIBUTE11,
              l_cuvv_rec.ATTRIBUTE12,
              l_cuvv_rec.ATTRIBUTE13,
              l_cuvv_rec.ATTRIBUTE14,
              l_cuvv_rec.ATTRIBUTE15,
              l_cuvv_rec.CREATED_BY,
              l_cuvv_rec.CREATION_DATE,
              l_cuvv_rec.LAST_UPDATED_BY,
              l_cuvv_rec.LAST_UPDATE_DATE,
              l_cuvv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_cuvv_pk_csr%NOTFOUND;
    CLOSE okl_cuvv_pk_csr;
    RETURN(l_cuvv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cuvv_rec                     IN cuvv_rec_type
  ) RETURN cuvv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cuvv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CRTRN_USER_VALS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cuvv_rec	IN cuvv_rec_type
  ) RETURN cuvv_rec_type IS
    l_cuvv_rec	cuvv_rec_type := p_cuvv_rec;
  BEGIN
    IF (l_cuvv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_cuvv_rec.object_version_number := NULL;
    END IF;
    IF (l_cuvv_rec.sfwt_flag = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_cuvv_rec.crn_id = okl_api.G_MISS_NUM) THEN
      l_cuvv_rec.crn_id := NULL;
    END IF;
    IF (l_cuvv_rec.sequence_number = okl_api.G_MISS_NUM) THEN
      l_cuvv_rec.sequence_number := NULL;
    END IF;
    IF (l_cuvv_rec.value = okl_api.G_MISS_NUM) THEN
      l_cuvv_rec.value := NULL;
    END IF;
    IF (l_cuvv_rec.description = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.description := NULL;
    END IF;
    IF (l_cuvv_rec.attribute_category = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute_category := NULL;
    END IF;
    IF (l_cuvv_rec.attribute1 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute1 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute2 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute2 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute3 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute3 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute4 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute4 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute5 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute6 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute6 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute7 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute7 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute8 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute8 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute9 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute9 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute10 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute10 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute11 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute11 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute12 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute12 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute13 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute13 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute14 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute14 := NULL;
    END IF;
    IF (l_cuvv_rec.attribute15 = okl_api.G_MISS_CHAR) THEN
      l_cuvv_rec.attribute15 := NULL;
    END IF;
    IF (l_cuvv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_cuvv_rec.created_by := NULL;
    END IF;
    IF (l_cuvv_rec.creation_date = okl_api.G_MISS_DATE) THEN
      l_cuvv_rec.creation_date := NULL;
    END IF;
    IF (l_cuvv_rec.last_updated_by = okl_api.G_MISS_NUM) THEN
      l_cuvv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cuvv_rec.last_update_date = okl_api.G_MISS_DATE) THEN
      l_cuvv_rec.last_update_date := NULL;
    END IF;
    IF (l_cuvv_rec.last_update_login = okl_api.G_MISS_NUM) THEN
      l_cuvv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cuvv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_CRTRN_USER_VALS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cuvv_rec IN  cuvv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
	-- TAPI postgen 05/23/2001
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- End TAPI postgen 05/23/2001
  BEGIN
	-- TAPI postgen 05/23/2001
    validate_id(p_cuvv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_object_version_number(p_cuvv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_crn_id(p_cuvv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_sequence_number(p_cuvv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_value(p_cuvv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	-- End TAPI postgen 05/23/2001

    IF p_cuvv_rec.id = okl_api.G_MISS_NUM OR
       p_cuvv_rec.id IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := okl_api.G_RET_STS_ERROR;
    ELSIF p_cuvv_rec.object_version_number = okl_api.G_MISS_NUM OR
          p_cuvv_rec.object_version_number IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := okl_api.G_RET_STS_ERROR;
    ELSIF p_cuvv_rec.crn_id = okl_api.G_MISS_NUM OR
          p_cuvv_rec.crn_id IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'crn_id');
      l_return_status := okl_api.G_RET_STS_ERROR;
    ELSIF p_cuvv_rec.sequence_number = okl_api.G_MISS_NUM OR
          p_cuvv_rec.sequence_number IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sequence_number');
      l_return_status := okl_api.G_RET_STS_ERROR;
    ELSIF p_cuvv_rec.value = okl_api.G_MISS_NUM OR
          p_cuvv_rec.value IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'value');
      l_return_status := okl_api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_CRTRN_USER_VALS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_cuvv_rec IN cuvv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cuvv_rec_type,
    p_to	OUT NOCOPY cuv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.crn_id := p_from.crn_id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.value := p_from.value;
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
    p_from	IN cuv_rec_type,
    p_to	OUT NOCOPY cuvv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.crn_id := p_from.crn_id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.value := p_from.value;
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
    p_from	IN cuvv_rec_type,
    p_to	OUT NOCOPY OklCrtrnUserValsTlRecType
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
    p_from	IN OklCrtrnUserValsTlRecType,
    p_to	OUT NOCOPY cuvv_rec_type
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
  -- validate_row for:OKL_CRTRN_USER_VALS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuvv_rec                     IN cuvv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cuvv_rec                     cuvv_rec_type := p_cuvv_rec;
    l_cuv_rec                      cuv_rec_type;
    l_okl_crtrn_user_vals_tl_rec   OklCrtrnUserValsTlRecType;
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
    l_return_status := Validate_Attributes(l_cuvv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cuvv_rec);
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
  -- PL/SQL TBL validate_row for:CUVV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuvv_tbl                     IN cuvv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cuvv_tbl.COUNT > 0) THEN
      i := p_cuvv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cuvv_rec                     => p_cuvv_tbl(i));
        EXIT WHEN (i = p_cuvv_tbl.LAST);
        i := p_cuvv_tbl.NEXT(i);
      END LOOP;
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
  -- insert_row for:OKL_CRTRN_USER_VALS_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuv_rec                      IN cuv_rec_type,
    x_cuv_rec                      OUT NOCOPY cuv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cuv_rec                      cuv_rec_type := p_cuv_rec;
    l_def_cuv_rec                  cuv_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_USER_VALS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cuv_rec IN  cuv_rec_type,
      x_cuv_rec OUT NOCOPY cuv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_cuv_rec := p_cuv_rec;
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
      p_cuv_rec,                         -- IN
      l_cuv_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CRTRN_USER_VALS_B(
        id,
        crn_id,
        sequence_number,
        value,
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
        l_cuv_rec.id,
        l_cuv_rec.crn_id,
        l_cuv_rec.sequence_number,
        l_cuv_rec.value,
        l_cuv_rec.object_version_number,
        l_cuv_rec.attribute_category,
        l_cuv_rec.attribute1,
        l_cuv_rec.attribute2,
        l_cuv_rec.attribute3,
        l_cuv_rec.attribute4,
        l_cuv_rec.attribute5,
        l_cuv_rec.attribute6,
        l_cuv_rec.attribute7,
        l_cuv_rec.attribute8,
        l_cuv_rec.attribute9,
        l_cuv_rec.attribute10,
        l_cuv_rec.attribute11,
        l_cuv_rec.attribute12,
        l_cuv_rec.attribute13,
        l_cuv_rec.attribute14,
        l_cuv_rec.attribute15,
        l_cuv_rec.created_by,
        l_cuv_rec.creation_date,
        l_cuv_rec.last_updated_by,
        l_cuv_rec.last_update_date,
        l_cuv_rec.last_update_login);
    -- Set OUT values
    x_cuv_rec := l_cuv_rec;
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
  -- insert_row for:OKL_CRTRN_USER_VALS_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_crtrn_user_vals_tl_rec   IN OklCrtrnUserValsTlRecType,
    x_okl_crtrn_user_vals_tl_rec   OUT NOCOPY OklCrtrnUserValsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_crtrn_user_vals_tl_rec   OklCrtrnUserValsTlRecType := p_okl_crtrn_user_vals_tl_rec;
    ldefoklcrtrnuservalstlrec      OklCrtrnUserValsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_USER_VALS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_crtrn_user_vals_tl_rec IN  OklCrtrnUserValsTlRecType,
      x_okl_crtrn_user_vals_tl_rec OUT NOCOPY OklCrtrnUserValsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_crtrn_user_vals_tl_rec := p_okl_crtrn_user_vals_tl_rec;
      x_okl_crtrn_user_vals_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_crtrn_user_vals_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_crtrn_user_vals_tl_rec,      -- IN
      l_okl_crtrn_user_vals_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_crtrn_user_vals_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_CRTRN_USER_VALS_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_crtrn_user_vals_tl_rec.id,
          l_okl_crtrn_user_vals_tl_rec.LANGUAGE,
          l_okl_crtrn_user_vals_tl_rec.source_lang,
          l_okl_crtrn_user_vals_tl_rec.sfwt_flag,
          l_okl_crtrn_user_vals_tl_rec.description,
          l_okl_crtrn_user_vals_tl_rec.created_by,
          l_okl_crtrn_user_vals_tl_rec.creation_date,
          l_okl_crtrn_user_vals_tl_rec.last_updated_by,
          l_okl_crtrn_user_vals_tl_rec.last_update_date,
          l_okl_crtrn_user_vals_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_crtrn_user_vals_tl_rec := l_okl_crtrn_user_vals_tl_rec;
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
  -- insert_row for:OKL_CRTRN_USER_VALS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuvv_rec                     IN cuvv_rec_type,
    x_cuvv_rec                     OUT NOCOPY cuvv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cuvv_rec                     cuvv_rec_type;
    l_def_cuvv_rec                 cuvv_rec_type;
    l_cuv_rec                      cuv_rec_type;
    lx_cuv_rec                     cuv_rec_type;
    l_okl_crtrn_user_vals_tl_rec   OklCrtrnUserValsTlRecType;
    lx_okl_crtrn_user_vals_tl_rec  OklCrtrnUserValsTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cuvv_rec	IN cuvv_rec_type
    ) RETURN cuvv_rec_type IS
      l_cuvv_rec	cuvv_rec_type := p_cuvv_rec;
    BEGIN
      l_cuvv_rec.CREATION_DATE := SYSDATE;
      l_cuvv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_cuvv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cuvv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_cuvv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_cuvv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_USER_VALS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cuvv_rec IN  cuvv_rec_type,
      x_cuvv_rec OUT NOCOPY cuvv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_cuvv_rec := p_cuvv_rec;
      x_cuvv_rec.OBJECT_VERSION_NUMBER := 1;
      x_cuvv_rec.SFWT_FLAG := 'N';
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
    l_cuvv_rec := null_out_defaults(p_cuvv_rec);
    -- Set primary key value
    l_cuvv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cuvv_rec,                        -- IN
      l_def_cuvv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_cuvv_rec := fill_who_columns(l_def_cuvv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cuvv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cuvv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cuvv_rec, l_cuv_rec);
    migrate(l_def_cuvv_rec, l_okl_crtrn_user_vals_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cuv_rec,
      lx_cuv_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cuv_rec, l_def_cuvv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_crtrn_user_vals_tl_rec,
      lx_okl_crtrn_user_vals_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_crtrn_user_vals_tl_rec, l_def_cuvv_rec);
    -- Set OUT values
    x_cuvv_rec := l_def_cuvv_rec;
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
  -- PL/SQL TBL insert_row for:CUVV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuvv_tbl                     IN cuvv_tbl_type,
    x_cuvv_tbl                     OUT NOCOPY cuvv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cuvv_tbl.COUNT > 0) THEN
      i := p_cuvv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cuvv_rec                     => p_cuvv_tbl(i),
          x_cuvv_rec                     => x_cuvv_tbl(i));
        EXIT WHEN (i = p_cuvv_tbl.LAST);
        i := p_cuvv_tbl.NEXT(i);
      END LOOP;
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
  -- lock_row for:OKL_CRTRN_USER_VALS_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuv_rec                      IN cuv_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cuv_rec IN cuv_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CRTRN_USER_VALS_B
     WHERE ID = p_cuv_rec.id
       AND OBJECT_VERSION_NUMBER = p_cuv_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cuv_rec IN cuv_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CRTRN_USER_VALS_B
    WHERE ID = p_cuv_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_CRTRN_USER_VALS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_CRTRN_USER_VALS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cuv_rec);
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
      OPEN lchk_csr(p_cuv_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cuv_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cuv_rec.object_version_number THEN
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
  -- lock_row for:OKL_CRTRN_USER_VALS_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_crtrn_user_vals_tl_rec   IN OklCrtrnUserValsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_crtrn_user_vals_tl_rec IN OklCrtrnUserValsTlRecType) IS
    SELECT *
      FROM OKL_CRTRN_USER_VALS_TL
     WHERE ID = p_okl_crtrn_user_vals_tl_rec.id
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
      OPEN lock_csr(p_okl_crtrn_user_vals_tl_rec);
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
  -- lock_row for:OKL_CRTRN_USER_VALS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuvv_rec                     IN cuvv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cuv_rec                      cuv_rec_type;
    l_okl_crtrn_user_vals_tl_rec   OklCrtrnUserValsTlRecType;
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
    migrate(p_cuvv_rec, l_cuv_rec);
    migrate(p_cuvv_rec, l_okl_crtrn_user_vals_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cuv_rec
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
      l_okl_crtrn_user_vals_tl_rec
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
  -- PL/SQL TBL lock_row for:CUVV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuvv_tbl                     IN cuvv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cuvv_tbl.COUNT > 0) THEN
      i := p_cuvv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cuvv_rec                     => p_cuvv_tbl(i));
        EXIT WHEN (i = p_cuvv_tbl.LAST);
        i := p_cuvv_tbl.NEXT(i);
      END LOOP;
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
  -- update_row for:OKL_CRTRN_USER_VALS_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuv_rec                      IN cuv_rec_type,
    x_cuv_rec                      OUT NOCOPY cuv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cuv_rec                      cuv_rec_type := p_cuv_rec;
    l_def_cuv_rec                  cuv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cuv_rec	IN cuv_rec_type,
      x_cuv_rec	OUT NOCOPY cuv_rec_type
    ) RETURN VARCHAR2 IS
      l_cuv_rec                      cuv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_cuv_rec := p_cuv_rec;
      -- Get current database values
      l_cuv_rec := get_rec(p_cuv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cuv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_cuv_rec.id := l_cuv_rec.id;
      END IF;
      IF (x_cuv_rec.crn_id = okl_api.G_MISS_NUM)
      THEN
        x_cuv_rec.crn_id := l_cuv_rec.crn_id;
      END IF;
      IF (x_cuv_rec.sequence_number = okl_api.G_MISS_NUM)
      THEN
        x_cuv_rec.sequence_number := l_cuv_rec.sequence_number;
      END IF;
      IF (x_cuv_rec.value = okl_api.G_MISS_NUM)
      THEN
        x_cuv_rec.value := l_cuv_rec.value;
      END IF;
      IF (x_cuv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_cuv_rec.object_version_number := l_cuv_rec.object_version_number;
      END IF;
      IF (x_cuv_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute_category := l_cuv_rec.attribute_category;
      END IF;
      IF (x_cuv_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute1 := l_cuv_rec.attribute1;
      END IF;
      IF (x_cuv_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute2 := l_cuv_rec.attribute2;
      END IF;
      IF (x_cuv_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute3 := l_cuv_rec.attribute3;
      END IF;
      IF (x_cuv_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute4 := l_cuv_rec.attribute4;
      END IF;
      IF (x_cuv_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute5 := l_cuv_rec.attribute5;
      END IF;
      IF (x_cuv_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute6 := l_cuv_rec.attribute6;
      END IF;
      IF (x_cuv_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute7 := l_cuv_rec.attribute7;
      END IF;
      IF (x_cuv_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute8 := l_cuv_rec.attribute8;
      END IF;
      IF (x_cuv_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute9 := l_cuv_rec.attribute9;
      END IF;
      IF (x_cuv_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute10 := l_cuv_rec.attribute10;
      END IF;
      IF (x_cuv_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute11 := l_cuv_rec.attribute11;
      END IF;
      IF (x_cuv_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute12 := l_cuv_rec.attribute12;
      END IF;
      IF (x_cuv_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute13 := l_cuv_rec.attribute13;
      END IF;
      IF (x_cuv_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute14 := l_cuv_rec.attribute14;
      END IF;
      IF (x_cuv_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_cuv_rec.attribute15 := l_cuv_rec.attribute15;
      END IF;
      IF (x_cuv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_cuv_rec.created_by := l_cuv_rec.created_by;
      END IF;
      IF (x_cuv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_cuv_rec.creation_date := l_cuv_rec.creation_date;
      END IF;
      IF (x_cuv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_cuv_rec.last_updated_by := l_cuv_rec.last_updated_by;
      END IF;
      IF (x_cuv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_cuv_rec.last_update_date := l_cuv_rec.last_update_date;
      END IF;
      IF (x_cuv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_cuv_rec.last_update_login := l_cuv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_USER_VALS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cuv_rec IN  cuv_rec_type,
      x_cuv_rec OUT NOCOPY cuv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_cuv_rec := p_cuv_rec;
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
      p_cuv_rec,                         -- IN
      l_cuv_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cuv_rec, l_def_cuv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CRTRN_USER_VALS_B
    SET CRN_ID = l_def_cuv_rec.crn_id,
        SEQUENCE_NUMBER = l_def_cuv_rec.sequence_number,
        VALUE = l_def_cuv_rec.value,
        OBJECT_VERSION_NUMBER = l_def_cuv_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_cuv_rec.attribute_category,
        ATTRIBUTE1 = l_def_cuv_rec.attribute1,
        ATTRIBUTE2 = l_def_cuv_rec.attribute2,
        ATTRIBUTE3 = l_def_cuv_rec.attribute3,
        ATTRIBUTE4 = l_def_cuv_rec.attribute4,
        ATTRIBUTE5 = l_def_cuv_rec.attribute5,
        ATTRIBUTE6 = l_def_cuv_rec.attribute6,
        ATTRIBUTE7 = l_def_cuv_rec.attribute7,
        ATTRIBUTE8 = l_def_cuv_rec.attribute8,
        ATTRIBUTE9 = l_def_cuv_rec.attribute9,
        ATTRIBUTE10 = l_def_cuv_rec.attribute10,
        ATTRIBUTE11 = l_def_cuv_rec.attribute11,
        ATTRIBUTE12 = l_def_cuv_rec.attribute12,
        ATTRIBUTE13 = l_def_cuv_rec.attribute13,
        ATTRIBUTE14 = l_def_cuv_rec.attribute14,
        ATTRIBUTE15 = l_def_cuv_rec.attribute15,
        CREATED_BY = l_def_cuv_rec.created_by,
        CREATION_DATE = l_def_cuv_rec.creation_date,
        LAST_UPDATED_BY = l_def_cuv_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cuv_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cuv_rec.last_update_login
    WHERE ID = l_def_cuv_rec.id;

    x_cuv_rec := l_def_cuv_rec;
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
  -- update_row for:OKL_CRTRN_USER_VALS_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_crtrn_user_vals_tl_rec   IN OklCrtrnUserValsTlRecType,
    x_okl_crtrn_user_vals_tl_rec   OUT NOCOPY OklCrtrnUserValsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_crtrn_user_vals_tl_rec   OklCrtrnUserValsTlRecType := p_okl_crtrn_user_vals_tl_rec;
    ldefoklcrtrnuservalstlrec      OklCrtrnUserValsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_crtrn_user_vals_tl_rec	IN OklCrtrnUserValsTlRecType,
      x_okl_crtrn_user_vals_tl_rec	OUT NOCOPY OklCrtrnUserValsTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_crtrn_user_vals_tl_rec   OklCrtrnUserValsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_crtrn_user_vals_tl_rec := p_okl_crtrn_user_vals_tl_rec;
      -- Get current database values
      l_okl_crtrn_user_vals_tl_rec := get_rec(p_okl_crtrn_user_vals_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_crtrn_user_vals_tl_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_okl_crtrn_user_vals_tl_rec.id := l_okl_crtrn_user_vals_tl_rec.id;
      END IF;
      IF (x_okl_crtrn_user_vals_tl_rec.LANGUAGE = okl_api.G_MISS_CHAR)
      THEN
        x_okl_crtrn_user_vals_tl_rec.LANGUAGE := l_okl_crtrn_user_vals_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_crtrn_user_vals_tl_rec.source_lang = okl_api.G_MISS_CHAR)
      THEN
        x_okl_crtrn_user_vals_tl_rec.source_lang := l_okl_crtrn_user_vals_tl_rec.source_lang;
      END IF;
      IF (x_okl_crtrn_user_vals_tl_rec.sfwt_flag = okl_api.G_MISS_CHAR)
      THEN
        x_okl_crtrn_user_vals_tl_rec.sfwt_flag := l_okl_crtrn_user_vals_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_crtrn_user_vals_tl_rec.description = okl_api.G_MISS_CHAR)
      THEN
        x_okl_crtrn_user_vals_tl_rec.description := l_okl_crtrn_user_vals_tl_rec.description;
      END IF;
      IF (x_okl_crtrn_user_vals_tl_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_okl_crtrn_user_vals_tl_rec.created_by := l_okl_crtrn_user_vals_tl_rec.created_by;
      END IF;
      IF (x_okl_crtrn_user_vals_tl_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_okl_crtrn_user_vals_tl_rec.creation_date := l_okl_crtrn_user_vals_tl_rec.creation_date;
      END IF;
      IF (x_okl_crtrn_user_vals_tl_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_okl_crtrn_user_vals_tl_rec.last_updated_by := l_okl_crtrn_user_vals_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_crtrn_user_vals_tl_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_okl_crtrn_user_vals_tl_rec.last_update_date := l_okl_crtrn_user_vals_tl_rec.last_update_date;
      END IF;
      IF (x_okl_crtrn_user_vals_tl_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_okl_crtrn_user_vals_tl_rec.last_update_login := l_okl_crtrn_user_vals_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_USER_VALS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_crtrn_user_vals_tl_rec IN  OklCrtrnUserValsTlRecType,
      x_okl_crtrn_user_vals_tl_rec OUT NOCOPY OklCrtrnUserValsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_crtrn_user_vals_tl_rec := p_okl_crtrn_user_vals_tl_rec;
      x_okl_crtrn_user_vals_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_crtrn_user_vals_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_crtrn_user_vals_tl_rec,      -- IN
      l_okl_crtrn_user_vals_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_crtrn_user_vals_tl_rec, ldefoklcrtrnuservalstlrec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CRTRN_USER_VALS_TL
    SET DESCRIPTION = ldefoklcrtrnuservalstlrec.description,
        CREATED_BY = ldefoklcrtrnuservalstlrec.created_by,
        CREATION_DATE = ldefoklcrtrnuservalstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklcrtrnuservalstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklcrtrnuservalstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklcrtrnuservalstlrec.last_update_login
    WHERE ID = ldefoklcrtrnuservalstlrec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_CRTRN_USER_VALS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklcrtrnuservalstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_crtrn_user_vals_tl_rec := ldefoklcrtrnuservalstlrec;
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
  -- update_row for:OKL_CRTRN_USER_VALS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuvv_rec                     IN cuvv_rec_type,
    x_cuvv_rec                     OUT NOCOPY cuvv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cuvv_rec                     cuvv_rec_type := p_cuvv_rec;
    l_def_cuvv_rec                 cuvv_rec_type;
    l_okl_crtrn_user_vals_tl_rec   OklCrtrnUserValsTlRecType;
    lx_okl_crtrn_user_vals_tl_rec  OklCrtrnUserValsTlRecType;
    l_cuv_rec                      cuv_rec_type;
    lx_cuv_rec                     cuv_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cuvv_rec	IN cuvv_rec_type
    ) RETURN cuvv_rec_type IS
      l_cuvv_rec	cuvv_rec_type := p_cuvv_rec;
    BEGIN
      l_cuvv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cuvv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_cuvv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_cuvv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cuvv_rec	IN cuvv_rec_type,
      x_cuvv_rec	OUT NOCOPY cuvv_rec_type
    ) RETURN VARCHAR2 IS
      l_cuvv_rec                     cuvv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_cuvv_rec := p_cuvv_rec;
      -- Get current database values
      l_cuvv_rec := get_rec(p_cuvv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cuvv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_cuvv_rec.id := l_cuvv_rec.id;
      END IF;
      IF (x_cuvv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_cuvv_rec.object_version_number := l_cuvv_rec.object_version_number;
      END IF;
      IF (x_cuvv_rec.sfwt_flag = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.sfwt_flag := l_cuvv_rec.sfwt_flag;
      END IF;
      IF (x_cuvv_rec.crn_id = okl_api.G_MISS_NUM)
      THEN
        x_cuvv_rec.crn_id := l_cuvv_rec.crn_id;
      END IF;
      IF (x_cuvv_rec.sequence_number = okl_api.G_MISS_NUM)
      THEN
        x_cuvv_rec.sequence_number := l_cuvv_rec.sequence_number;
      END IF;
      IF (x_cuvv_rec.value = okl_api.G_MISS_NUM)
      THEN
        x_cuvv_rec.value := l_cuvv_rec.value;
      END IF;
      IF (x_cuvv_rec.description = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.description := l_cuvv_rec.description;
      END IF;
      IF (x_cuvv_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute_category := l_cuvv_rec.attribute_category;
      END IF;
      IF (x_cuvv_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute1 := l_cuvv_rec.attribute1;
      END IF;
      IF (x_cuvv_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute2 := l_cuvv_rec.attribute2;
      END IF;
      IF (x_cuvv_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute3 := l_cuvv_rec.attribute3;
      END IF;
      IF (x_cuvv_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute4 := l_cuvv_rec.attribute4;
      END IF;
      IF (x_cuvv_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute5 := l_cuvv_rec.attribute5;
      END IF;
      IF (x_cuvv_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute6 := l_cuvv_rec.attribute6;
      END IF;
      IF (x_cuvv_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute7 := l_cuvv_rec.attribute7;
      END IF;
      IF (x_cuvv_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute8 := l_cuvv_rec.attribute8;
      END IF;
      IF (x_cuvv_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute9 := l_cuvv_rec.attribute9;
      END IF;
      IF (x_cuvv_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute10 := l_cuvv_rec.attribute10;
      END IF;
      IF (x_cuvv_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute11 := l_cuvv_rec.attribute11;
      END IF;
      IF (x_cuvv_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute12 := l_cuvv_rec.attribute12;
      END IF;
      IF (x_cuvv_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute13 := l_cuvv_rec.attribute13;
      END IF;
      IF (x_cuvv_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute14 := l_cuvv_rec.attribute14;
      END IF;
      IF (x_cuvv_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_cuvv_rec.attribute15 := l_cuvv_rec.attribute15;
      END IF;
      IF (x_cuvv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_cuvv_rec.created_by := l_cuvv_rec.created_by;
      END IF;
      IF (x_cuvv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_cuvv_rec.creation_date := l_cuvv_rec.creation_date;
      END IF;
      IF (x_cuvv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_cuvv_rec.last_updated_by := l_cuvv_rec.last_updated_by;
      END IF;
      IF (x_cuvv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_cuvv_rec.last_update_date := l_cuvv_rec.last_update_date;
      END IF;
      IF (x_cuvv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_cuvv_rec.last_update_login := l_cuvv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_USER_VALS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cuvv_rec IN  cuvv_rec_type,
      x_cuvv_rec OUT NOCOPY cuvv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_cuvv_rec := p_cuvv_rec;
      x_cuvv_rec.OBJECT_VERSION_NUMBER := NVL(x_cuvv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_cuvv_rec,                        -- IN
      l_cuvv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cuvv_rec, l_def_cuvv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_cuvv_rec := fill_who_columns(l_def_cuvv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cuvv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cuvv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cuvv_rec, l_okl_crtrn_user_vals_tl_rec);
    migrate(l_def_cuvv_rec, l_cuv_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_crtrn_user_vals_tl_rec,
      lx_okl_crtrn_user_vals_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_crtrn_user_vals_tl_rec, l_def_cuvv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cuv_rec,
      lx_cuv_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cuv_rec, l_def_cuvv_rec);
    x_cuvv_rec := l_def_cuvv_rec;
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
  -- PL/SQL TBL update_row for:CUVV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuvv_tbl                     IN cuvv_tbl_type,
    x_cuvv_tbl                     OUT NOCOPY cuvv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cuvv_tbl.COUNT > 0) THEN
      i := p_cuvv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cuvv_rec                     => p_cuvv_tbl(i),
          x_cuvv_rec                     => x_cuvv_tbl(i));
        EXIT WHEN (i = p_cuvv_tbl.LAST);
        i := p_cuvv_tbl.NEXT(i);
      END LOOP;
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
  -- delete_row for:OKL_CRTRN_USER_VALS_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuv_rec                      IN cuv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cuv_rec                      cuv_rec_type:= p_cuv_rec;
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
    DELETE FROM OKL_CRTRN_USER_VALS_B
     WHERE ID = l_cuv_rec.id;

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
  -- delete_row for:OKL_CRTRN_USER_VALS_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_crtrn_user_vals_tl_rec   IN OklCrtrnUserValsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_crtrn_user_vals_tl_rec   OklCrtrnUserValsTlRecType:= p_okl_crtrn_user_vals_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_USER_VALS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_crtrn_user_vals_tl_rec IN  OklCrtrnUserValsTlRecType,
      x_okl_crtrn_user_vals_tl_rec OUT NOCOPY OklCrtrnUserValsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_crtrn_user_vals_tl_rec := p_okl_crtrn_user_vals_tl_rec;
      x_okl_crtrn_user_vals_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_crtrn_user_vals_tl_rec,      -- IN
      l_okl_crtrn_user_vals_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_CRTRN_USER_VALS_TL
     WHERE ID = l_okl_crtrn_user_vals_tl_rec.id;

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
  -- delete_row for:OKL_CRTRN_USER_VALS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuvv_rec                     IN cuvv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cuvv_rec                     cuvv_rec_type := p_cuvv_rec;
    l_okl_crtrn_user_vals_tl_rec   OklCrtrnUserValsTlRecType;
    l_cuv_rec                      cuv_rec_type;
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
    migrate(l_cuvv_rec, l_okl_crtrn_user_vals_tl_rec);
    migrate(l_cuvv_rec, l_cuv_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_crtrn_user_vals_tl_rec
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
      l_cuv_rec
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
  -- PL/SQL TBL delete_row for:CUVV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cuvv_tbl                     IN cuvv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cuvv_tbl.COUNT > 0) THEN
      i := p_cuvv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cuvv_rec                     => p_cuvv_tbl(i));
        EXIT WHEN (i = p_cuvv_tbl.LAST);
        i := p_cuvv_tbl.NEXT(i);
      END LOOP;
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
END Okl_Cuv_Pvt;

/
