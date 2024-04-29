--------------------------------------------------------
--  DDL for Package Body OKL_CRN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CRN_PVT" AS
/* $Header: OKLSCRNB.pls 115.6 2004/05/21 21:26:43 pjgomes noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_crnv_rec IN crnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_crnv_rec.id = Okl_Api.G_MISS_NUM OR
       p_crnv_rec.id IS NULL
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
  PROCEDURE validate_object_version_number (p_crnv_rec IN crnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_crnv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_crnv_rec.object_version_number IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'object_version_number');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_name
  ---------------------------------------------------------------------------
  PROCEDURE validate_name (p_crnv_rec IN crnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_crnv_rec.name = Okl_Api.G_MISS_CHAR OR
       p_crnv_rec.name IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'name');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_name;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_crn_type
  ---------------------------------------------------------------------------
  PROCEDURE validate_crn_type (p_crnv_rec IN crnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_crnv_rec.crn_type = Okl_Api.G_MISS_NUM OR
       p_crnv_rec.crn_type IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'crn_type');
      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check for Valid CRN Type
    IF p_crnv_rec.crn_type NOT IN ('CNU','CUA','CUU','CVF')
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_INVALID_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'crn_type');
      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;


  END validate_crn_type;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_data_type_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_data_type_code (p_crnv_rec IN crnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

--	x_return_status := Okl_Util.CHECK_FND_LOOKUP_CODE('OKL_CR_DATATYPE', p_crnv_rec.data_type_code);

  END validate_data_type_code;

--  validate_jtf_object_code(p_crnv_rec, x_return_status)

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_jtf_object_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_jtf_object_code (p_crnv_rec IN crnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

--	x_return_status := Okl_Util.CHECK_FND_LOOKUP_CODE('JTF OBJECT', p_crnv_rec.jtf_object_code);

  END validate_jtf_object_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Is_Unique
  -- Post-Generation Change
  -- By STMATHEW on 24-APR-2001
  ---------------------------------------------------------------------------
  FUNCTION Is_Unique (
    p_crnv_rec IN crnv_rec_type
  ) RETURN VARCHAR2 IS

    CURSOR l_crnv_csr IS
                  SELECT 'x'
                  FROM   OKL_CRITERIA_V
                  WHERE  name = p_crnv_rec.name
                  AND    id   <> nvl (p_crnv_rec.id, -99999);

    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;

  BEGIN

    -- check for unique NAME
    OPEN     l_crnv_csr;
    FETCH    l_crnv_csr INTO l_dummy;
          l_found  := l_crnv_csr%FOUND;
          CLOSE    l_crnv_csr;

    IF (l_found) THEN

      -- display error message
      OKL_API.set_message(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_NOT_SAME,
        p_token1          => 'NAME',
        p_token1_value    => p_crnv_rec.name);

      -- notify caller of an error
      l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

    -- return status to the caller
    RETURN l_return_status;

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1          => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
        p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- verify the cursor is closed
      IF l_crnv_csr%ISOPEN THEN
         CLOSE l_crnv_csr;
      END IF;
      -- return status to the caller
      RETURN l_return_status;

  END Is_Unique;


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
    DELETE FROM OKL_CRITERIA_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_CRITERIA_B B     --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_CRITERIA_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_CRITERIA_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_CRITERIA_TL SUBB, OKL_CRITERIA_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_CRITERIA_TL (
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
        FROM OKL_CRITERIA_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_CRITERIA_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CRITERIA_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_crn_rec                      IN crn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN crn_rec_type IS
    CURSOR crn_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            DATA_TYPE_CODE,
            JTF_OBJECT_CODE,
            CRN_TYPE,
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
      FROM Okl_Criteria_B
     WHERE okl_criteria_b.id    = p_id;
    l_crn_pk                       crn_pk_csr%ROWTYPE;
    l_crn_rec                      crn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN crn_pk_csr (p_crn_rec.id);
    FETCH crn_pk_csr INTO
              l_crn_rec.ID,
              l_crn_rec.DATA_TYPE_CODE,
              l_crn_rec.JTF_OBJECT_CODE,
              l_crn_rec.CRN_TYPE,
              l_crn_rec.OBJECT_VERSION_NUMBER,
              l_crn_rec.ATTRIBUTE_CATEGORY,
              l_crn_rec.ATTRIBUTE1,
              l_crn_rec.ATTRIBUTE2,
              l_crn_rec.ATTRIBUTE3,
              l_crn_rec.ATTRIBUTE4,
              l_crn_rec.ATTRIBUTE5,
              l_crn_rec.ATTRIBUTE6,
              l_crn_rec.ATTRIBUTE7,
              l_crn_rec.ATTRIBUTE8,
              l_crn_rec.ATTRIBUTE9,
              l_crn_rec.ATTRIBUTE10,
              l_crn_rec.ATTRIBUTE11,
              l_crn_rec.ATTRIBUTE12,
              l_crn_rec.ATTRIBUTE13,
              l_crn_rec.ATTRIBUTE14,
              l_crn_rec.ATTRIBUTE15,
              l_crn_rec.CREATED_BY,
              l_crn_rec.CREATION_DATE,
              l_crn_rec.LAST_UPDATED_BY,
              l_crn_rec.LAST_UPDATE_DATE,
              l_crn_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := crn_pk_csr%NOTFOUND;
    CLOSE crn_pk_csr;
    RETURN(l_crn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_crn_rec                      IN crn_rec_type
  ) RETURN crn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_crn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CRITERIA_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_criteria_tl_rec          IN okl_criteria_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_criteria_tl_rec_type IS
    CURSOR okl_criteria_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Criteria_Tl
     WHERE okl_criteria_tl.id   = p_id
       AND okl_criteria_tl.LANGUAGE = p_language;
    l_okl_criteria_tl_pk           okl_criteria_tl_pk_csr%ROWTYPE;
    l_okl_criteria_tl_rec          okl_criteria_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_criteria_tl_pk_csr (p_okl_criteria_tl_rec.id,
                                 p_okl_criteria_tl_rec.LANGUAGE);
    FETCH okl_criteria_tl_pk_csr INTO
              l_okl_criteria_tl_rec.ID,
              l_okl_criteria_tl_rec.LANGUAGE,
              l_okl_criteria_tl_rec.SOURCE_LANG,
              l_okl_criteria_tl_rec.SFWT_FLAG,
              l_okl_criteria_tl_rec.NAME,
              l_okl_criteria_tl_rec.DESCRIPTION,
              l_okl_criteria_tl_rec.CREATED_BY,
              l_okl_criteria_tl_rec.CREATION_DATE,
              l_okl_criteria_tl_rec.LAST_UPDATED_BY,
              l_okl_criteria_tl_rec.LAST_UPDATE_DATE,
              l_okl_criteria_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_criteria_tl_pk_csr%NOTFOUND;
    CLOSE okl_criteria_tl_pk_csr;
    RETURN(l_okl_criteria_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_criteria_tl_rec          IN okl_criteria_tl_rec_type
  ) RETURN okl_criteria_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_criteria_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CRITERIA_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_crnv_rec                     IN crnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN crnv_rec_type IS
    CURSOR okl_crnv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            DATA_TYPE_CODE,
            JTF_OBJECT_CODE,
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
            CRN_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Criteria_V
     WHERE okl_criteria_v.id    = p_id;
    l_okl_crnv_pk                  okl_crnv_pk_csr%ROWTYPE;
    l_crnv_rec                     crnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_crnv_pk_csr (p_crnv_rec.id);
    FETCH okl_crnv_pk_csr INTO
              l_crnv_rec.ID,
              l_crnv_rec.OBJECT_VERSION_NUMBER,
              l_crnv_rec.SFWT_FLAG,
              l_crnv_rec.DATA_TYPE_CODE,
              l_crnv_rec.JTF_OBJECT_CODE,
              l_crnv_rec.NAME,
              l_crnv_rec.DESCRIPTION,
              l_crnv_rec.ATTRIBUTE_CATEGORY,
              l_crnv_rec.ATTRIBUTE1,
              l_crnv_rec.ATTRIBUTE2,
              l_crnv_rec.ATTRIBUTE3,
              l_crnv_rec.ATTRIBUTE4,
              l_crnv_rec.ATTRIBUTE5,
              l_crnv_rec.ATTRIBUTE6,
              l_crnv_rec.ATTRIBUTE7,
              l_crnv_rec.ATTRIBUTE8,
              l_crnv_rec.ATTRIBUTE9,
              l_crnv_rec.ATTRIBUTE10,
              l_crnv_rec.ATTRIBUTE11,
              l_crnv_rec.ATTRIBUTE12,
              l_crnv_rec.ATTRIBUTE13,
              l_crnv_rec.ATTRIBUTE14,
              l_crnv_rec.ATTRIBUTE15,
              l_crnv_rec.CRN_TYPE,
              l_crnv_rec.CREATED_BY,
              l_crnv_rec.CREATION_DATE,
              l_crnv_rec.LAST_UPDATED_BY,
              l_crnv_rec.LAST_UPDATE_DATE,
              l_crnv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_crnv_pk_csr%NOTFOUND;
    CLOSE okl_crnv_pk_csr;
    RETURN(l_crnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_crnv_rec                     IN crnv_rec_type
  ) RETURN crnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_crnv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CRITERIA_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_crnv_rec	IN crnv_rec_type
  ) RETURN crnv_rec_type IS
    l_crnv_rec	crnv_rec_type := p_crnv_rec;
  BEGIN
    IF (l_crnv_rec.object_version_number = okl_api.G_MISS_NUM) THEN
      l_crnv_rec.object_version_number := NULL;
    END IF;
    IF (l_crnv_rec.sfwt_flag = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_crnv_rec.data_type_code = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.data_type_code := NULL;
    END IF;
    IF (l_crnv_rec.jtf_object_code = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.jtf_object_code := NULL;
    END IF;
    IF (l_crnv_rec.name = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.name := NULL;
    END IF;
    IF (l_crnv_rec.description = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.description := NULL;
    END IF;
    IF (l_crnv_rec.attribute_category = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute_category := NULL;
    END IF;
    IF (l_crnv_rec.attribute1 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute1 := NULL;
    END IF;
    IF (l_crnv_rec.attribute2 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute2 := NULL;
    END IF;
    IF (l_crnv_rec.attribute3 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute3 := NULL;
    END IF;
    IF (l_crnv_rec.attribute4 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute4 := NULL;
    END IF;
    IF (l_crnv_rec.attribute5 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute5 := NULL;
    END IF;
    IF (l_crnv_rec.attribute6 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute6 := NULL;
    END IF;
    IF (l_crnv_rec.attribute7 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute7 := NULL;
    END IF;
    IF (l_crnv_rec.attribute8 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute8 := NULL;
    END IF;
    IF (l_crnv_rec.attribute9 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute9 := NULL;
    END IF;
    IF (l_crnv_rec.attribute10 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute10 := NULL;
    END IF;
    IF (l_crnv_rec.attribute11 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute11 := NULL;
    END IF;
    IF (l_crnv_rec.attribute12 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute12 := NULL;
    END IF;
    IF (l_crnv_rec.attribute13 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute13 := NULL;
    END IF;
    IF (l_crnv_rec.attribute14 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute14 := NULL;
    END IF;
    IF (l_crnv_rec.attribute15 = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.attribute15 := NULL;
    END IF;
    IF (l_crnv_rec.crn_type = okl_api.G_MISS_CHAR) THEN
      l_crnv_rec.crn_type := NULL;
    END IF;
    IF (l_crnv_rec.created_by = okl_api.G_MISS_NUM) THEN
      l_crnv_rec.created_by := NULL;
    END IF;
    IF (l_crnv_rec.creation_date = okl_api.G_MISS_DATE) THEN
      l_crnv_rec.creation_date := NULL;
    END IF;
    IF (l_crnv_rec.last_updated_by = okl_api.G_MISS_NUM) THEN
      l_crnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_crnv_rec.last_update_date = okl_api.G_MISS_DATE) THEN
      l_crnv_rec.last_update_date := NULL;
    END IF;
    IF (l_crnv_rec.last_update_login = okl_api.G_MISS_NUM) THEN
      l_crnv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_crnv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKL_CRITERIA_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_crnv_rec IN  crnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
	-- TAPI postgen 05/23/2001
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- End TAPI postgen 05/23/2001
  BEGIN
	-- TAPI postgen 05/23/2001
    validate_id(p_crnv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_object_version_number(p_crnv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_name(p_crnv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_crn_type(p_crnv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_data_type_code(p_crnv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_jtf_object_code(p_crnv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
	-- End TAPI postgen 05/23/2001

    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKL_CRITERIA_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_crnv_rec IN crnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    x_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call each record-level validation
    l_return_status := is_unique (p_crnv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN x_return_status;
  EXCEPTION
    when OTHERS then
      -- display error message
      OKL_API.set_message(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1          => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
        p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- return status to the caller
      RETURN x_return_status;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN crnv_rec_type,
    p_to	OUT NOCOPY crn_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.data_type_code := p_from.data_type_code;
    p_to.jtf_object_code := p_from.jtf_object_code;
    p_to.crn_type := p_from.crn_type;
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
    p_from	IN crn_rec_type,
    p_to	OUT NOCOPY crnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.data_type_code := p_from.data_type_code;
    p_to.jtf_object_code := p_from.jtf_object_code;
    p_to.crn_type := p_from.crn_type;
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
    p_from	IN crnv_rec_type,
    p_to	OUT NOCOPY okl_criteria_tl_rec_type
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
    p_from	IN okl_criteria_tl_rec_type,
    p_to	OUT NOCOPY crnv_rec_type
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
  -------------------------------------
  -- validate_row for:OKL_CRITERIA_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crnv_rec                     IN crnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_crnv_rec                     crnv_rec_type := p_crnv_rec;
    l_crn_rec                      crn_rec_type;
    l_okl_criteria_tl_rec          okl_criteria_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_crnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_crnv_rec);
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
  -- PL/SQL TBL validate_row for:CRNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crnv_tbl                     IN crnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crnv_tbl.COUNT > 0) THEN
      i := p_crnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crnv_rec                     => p_crnv_tbl(i));
        EXIT WHEN (i = p_crnv_tbl.LAST);
        i := p_crnv_tbl.NEXT(i);
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
  -----------------------------------
  -- insert_row for:OKL_CRITERIA_B --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crn_rec                      IN crn_rec_type,
    x_crn_rec                      OUT NOCOPY crn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_crn_rec                      crn_rec_type := p_crn_rec;
    l_def_crn_rec                  crn_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_CRITERIA_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_crn_rec IN  crn_rec_type,
      x_crn_rec OUT NOCOPY crn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_crn_rec := p_crn_rec;
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
      p_crn_rec,                         -- IN
      l_crn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CRITERIA_B(
        id,
        data_type_code,
        jtf_object_code,
        crn_type,
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
        l_crn_rec.id,
        l_crn_rec.data_type_code,
        l_crn_rec.jtf_object_code,
        l_crn_rec.crn_type,
        l_crn_rec.object_version_number,
        l_crn_rec.attribute_category,
        l_crn_rec.attribute1,
        l_crn_rec.attribute2,
        l_crn_rec.attribute3,
        l_crn_rec.attribute4,
        l_crn_rec.attribute5,
        l_crn_rec.attribute6,
        l_crn_rec.attribute7,
        l_crn_rec.attribute8,
        l_crn_rec.attribute9,
        l_crn_rec.attribute10,
        l_crn_rec.attribute11,
        l_crn_rec.attribute12,
        l_crn_rec.attribute13,
        l_crn_rec.attribute14,
        l_crn_rec.attribute15,
        l_crn_rec.created_by,
        l_crn_rec.creation_date,
        l_crn_rec.last_updated_by,
        l_crn_rec.last_update_date,
        l_crn_rec.last_update_login);
    -- Set OUT values
    x_crn_rec := l_crn_rec;
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
  ------------------------------------
  -- insert_row for:OKL_CRITERIA_TL --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_criteria_tl_rec          IN okl_criteria_tl_rec_type,
    x_okl_criteria_tl_rec          OUT NOCOPY okl_criteria_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_criteria_tl_rec          okl_criteria_tl_rec_type := p_okl_criteria_tl_rec;
    l_def_okl_criteria_tl_rec      okl_criteria_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------
    -- Set_Attributes for:OKL_CRITERIA_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_criteria_tl_rec IN  okl_criteria_tl_rec_type,
      x_okl_criteria_tl_rec OUT NOCOPY okl_criteria_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_criteria_tl_rec := p_okl_criteria_tl_rec;
      x_okl_criteria_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_criteria_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_criteria_tl_rec,             -- IN
      l_okl_criteria_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_criteria_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_CRITERIA_TL(
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
          l_okl_criteria_tl_rec.id,
          l_okl_criteria_tl_rec.LANGUAGE,
          l_okl_criteria_tl_rec.source_lang,
          l_okl_criteria_tl_rec.sfwt_flag,
          l_okl_criteria_tl_rec.name,
          l_okl_criteria_tl_rec.description,
          l_okl_criteria_tl_rec.created_by,
          l_okl_criteria_tl_rec.creation_date,
          l_okl_criteria_tl_rec.last_updated_by,
          l_okl_criteria_tl_rec.last_update_date,
          l_okl_criteria_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_criteria_tl_rec := l_okl_criteria_tl_rec;
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
  -----------------------------------
  -- insert_row for:OKL_CRITERIA_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crnv_rec                     IN crnv_rec_type,
    x_crnv_rec                     OUT NOCOPY crnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_crnv_rec                     crnv_rec_type;
    l_def_crnv_rec                 crnv_rec_type;
    l_crn_rec                      crn_rec_type;
    lx_crn_rec                     crn_rec_type;
    l_okl_criteria_tl_rec          okl_criteria_tl_rec_type;
    lx_okl_criteria_tl_rec         okl_criteria_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_crnv_rec	IN crnv_rec_type
    ) RETURN crnv_rec_type IS
      l_crnv_rec	crnv_rec_type := p_crnv_rec;
    BEGIN
      l_crnv_rec.CREATION_DATE := SYSDATE;
      l_crnv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_crnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_crnv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_crnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_crnv_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKL_CRITERIA_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_crnv_rec IN  crnv_rec_type,
      x_crnv_rec OUT NOCOPY crnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_crnv_rec := p_crnv_rec;
      x_crnv_rec.OBJECT_VERSION_NUMBER := 1;
      x_crnv_rec.SFWT_FLAG := 'N';
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
    l_crnv_rec := null_out_defaults(p_crnv_rec);
    -- Set primary key value
    l_crnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_crnv_rec,                        -- IN
      l_def_crnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_crnv_rec := fill_who_columns(l_def_crnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_crnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_crnv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_crnv_rec, l_crn_rec);
    migrate(l_def_crnv_rec, l_okl_criteria_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_crn_rec,
      lx_crn_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_crn_rec, l_def_crnv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_criteria_tl_rec,
      lx_okl_criteria_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_criteria_tl_rec, l_def_crnv_rec);
    -- Set OUT values
    x_crnv_rec := l_def_crnv_rec;
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
  -- PL/SQL TBL insert_row for:CRNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crnv_tbl                     IN crnv_tbl_type,
    x_crnv_tbl                     OUT NOCOPY crnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crnv_tbl.COUNT > 0) THEN
      i := p_crnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crnv_rec                     => p_crnv_tbl(i),
          x_crnv_rec                     => x_crnv_tbl(i));
        EXIT WHEN (i = p_crnv_tbl.LAST);
        i := p_crnv_tbl.NEXT(i);
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
  ---------------------------------
  -- lock_row for:OKL_CRITERIA_B --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crn_rec                      IN crn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_crn_rec IN crn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CRITERIA_B
     WHERE ID = p_crn_rec.id
       AND OBJECT_VERSION_NUMBER = p_crn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_crn_rec IN crn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CRITERIA_B
    WHERE ID = p_crn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_CRITERIA_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_CRITERIA_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_crn_rec);
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
      OPEN lchk_csr(p_crn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_crn_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_crn_rec.object_version_number THEN
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
  ----------------------------------
  -- lock_row for:OKL_CRITERIA_TL --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_criteria_tl_rec          IN okl_criteria_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_criteria_tl_rec IN okl_criteria_tl_rec_type) IS
    SELECT *
      FROM OKL_CRITERIA_TL
     WHERE ID = p_okl_criteria_tl_rec.id
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
      OPEN lock_csr(p_okl_criteria_tl_rec);
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
  ---------------------------------
  -- lock_row for:OKL_CRITERIA_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crnv_rec                     IN crnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_crn_rec                      crn_rec_type;
    l_okl_criteria_tl_rec          okl_criteria_tl_rec_type;
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
    migrate(p_crnv_rec, l_crn_rec);
    migrate(p_crnv_rec, l_okl_criteria_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_crn_rec
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
      l_okl_criteria_tl_rec
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
  -- PL/SQL TBL lock_row for:CRNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crnv_tbl                     IN crnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crnv_tbl.COUNT > 0) THEN
      i := p_crnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crnv_rec                     => p_crnv_tbl(i));
        EXIT WHEN (i = p_crnv_tbl.LAST);
        i := p_crnv_tbl.NEXT(i);
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
  -----------------------------------
  -- update_row for:OKL_CRITERIA_B --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crn_rec                      IN crn_rec_type,
    x_crn_rec                      OUT NOCOPY crn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_crn_rec                      crn_rec_type := p_crn_rec;
    l_def_crn_rec                  crn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_crn_rec	IN crn_rec_type,
      x_crn_rec	OUT NOCOPY crn_rec_type
    ) RETURN VARCHAR2 IS
      l_crn_rec                      crn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_crn_rec := p_crn_rec;
      -- Get current database values
      l_crn_rec := get_rec(p_crn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_crn_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_crn_rec.id := l_crn_rec.id;
      END IF;
      IF (x_crn_rec.data_type_code = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.data_type_code := l_crn_rec.data_type_code;
      END IF;
      IF (x_crn_rec.jtf_object_code = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.jtf_object_code := l_crn_rec.jtf_object_code;
      END IF;
      IF (x_crn_rec.crn_type = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.crn_type := l_crn_rec.crn_type;
      END IF;
      IF (x_crn_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_crn_rec.object_version_number := l_crn_rec.object_version_number;
      END IF;
      IF (x_crn_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute_category := l_crn_rec.attribute_category;
      END IF;
      IF (x_crn_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute1 := l_crn_rec.attribute1;
      END IF;
      IF (x_crn_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute2 := l_crn_rec.attribute2;
      END IF;
      IF (x_crn_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute3 := l_crn_rec.attribute3;
      END IF;
      IF (x_crn_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute4 := l_crn_rec.attribute4;
      END IF;
      IF (x_crn_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute5 := l_crn_rec.attribute5;
      END IF;
      IF (x_crn_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute6 := l_crn_rec.attribute6;
      END IF;
      IF (x_crn_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute7 := l_crn_rec.attribute7;
      END IF;
      IF (x_crn_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute8 := l_crn_rec.attribute8;
      END IF;
      IF (x_crn_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute9 := l_crn_rec.attribute9;
      END IF;
      IF (x_crn_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute10 := l_crn_rec.attribute10;
      END IF;
      IF (x_crn_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute11 := l_crn_rec.attribute11;
      END IF;
      IF (x_crn_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute12 := l_crn_rec.attribute12;
      END IF;
      IF (x_crn_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute13 := l_crn_rec.attribute13;
      END IF;
      IF (x_crn_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute14 := l_crn_rec.attribute14;
      END IF;
      IF (x_crn_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_crn_rec.attribute15 := l_crn_rec.attribute15;
      END IF;
      IF (x_crn_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_crn_rec.created_by := l_crn_rec.created_by;
      END IF;
      IF (x_crn_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_crn_rec.creation_date := l_crn_rec.creation_date;
      END IF;
      IF (x_crn_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_crn_rec.last_updated_by := l_crn_rec.last_updated_by;
      END IF;
      IF (x_crn_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_crn_rec.last_update_date := l_crn_rec.last_update_date;
      END IF;
      IF (x_crn_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_crn_rec.last_update_login := l_crn_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_CRITERIA_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_crn_rec IN  crn_rec_type,
      x_crn_rec OUT NOCOPY crn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_crn_rec := p_crn_rec;
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
      p_crn_rec,                         -- IN
      l_crn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_crn_rec, l_def_crn_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CRITERIA_B
    SET DATA_TYPE_CODE = l_def_crn_rec.data_type_code,
        JTF_OBJECT_CODE = l_def_crn_rec.jtf_object_code,
        CRN_TYPE = l_def_crn_rec.crn_type,
        OBJECT_VERSION_NUMBER = l_def_crn_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_crn_rec.attribute_category,
        ATTRIBUTE1 = l_def_crn_rec.attribute1,
        ATTRIBUTE2 = l_def_crn_rec.attribute2,
        ATTRIBUTE3 = l_def_crn_rec.attribute3,
        ATTRIBUTE4 = l_def_crn_rec.attribute4,
        ATTRIBUTE5 = l_def_crn_rec.attribute5,
        ATTRIBUTE6 = l_def_crn_rec.attribute6,
        ATTRIBUTE7 = l_def_crn_rec.attribute7,
        ATTRIBUTE8 = l_def_crn_rec.attribute8,
        ATTRIBUTE9 = l_def_crn_rec.attribute9,
        ATTRIBUTE10 = l_def_crn_rec.attribute10,
        ATTRIBUTE11 = l_def_crn_rec.attribute11,
        ATTRIBUTE12 = l_def_crn_rec.attribute12,
        ATTRIBUTE13 = l_def_crn_rec.attribute13,
        ATTRIBUTE14 = l_def_crn_rec.attribute14,
        ATTRIBUTE15 = l_def_crn_rec.attribute15,
        CREATED_BY = l_def_crn_rec.created_by,
        CREATION_DATE = l_def_crn_rec.creation_date,
        LAST_UPDATED_BY = l_def_crn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_crn_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_crn_rec.last_update_login
    WHERE ID = l_def_crn_rec.id;

    x_crn_rec := l_def_crn_rec;
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
  ------------------------------------
  -- update_row for:OKL_CRITERIA_TL --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_criteria_tl_rec          IN okl_criteria_tl_rec_type,
    x_okl_criteria_tl_rec          OUT NOCOPY okl_criteria_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_criteria_tl_rec          okl_criteria_tl_rec_type := p_okl_criteria_tl_rec;
    l_def_okl_criteria_tl_rec      okl_criteria_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_criteria_tl_rec	IN okl_criteria_tl_rec_type,
      x_okl_criteria_tl_rec	OUT NOCOPY okl_criteria_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_criteria_tl_rec          okl_criteria_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_criteria_tl_rec := p_okl_criteria_tl_rec;
      -- Get current database values
      l_okl_criteria_tl_rec := get_rec(p_okl_criteria_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_criteria_tl_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_okl_criteria_tl_rec.id := l_okl_criteria_tl_rec.id;
      END IF;
      IF (x_okl_criteria_tl_rec.LANGUAGE = okl_api.G_MISS_CHAR)
      THEN
        x_okl_criteria_tl_rec.LANGUAGE := l_okl_criteria_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_criteria_tl_rec.source_lang = okl_api.G_MISS_CHAR)
      THEN
        x_okl_criteria_tl_rec.source_lang := l_okl_criteria_tl_rec.source_lang;
      END IF;
      IF (x_okl_criteria_tl_rec.sfwt_flag = okl_api.G_MISS_CHAR)
      THEN
        x_okl_criteria_tl_rec.sfwt_flag := l_okl_criteria_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_criteria_tl_rec.name = okl_api.G_MISS_CHAR)
      THEN
        x_okl_criteria_tl_rec.name := l_okl_criteria_tl_rec.name;
      END IF;
      IF (x_okl_criteria_tl_rec.description = okl_api.G_MISS_CHAR)
      THEN
        x_okl_criteria_tl_rec.description := l_okl_criteria_tl_rec.description;
      END IF;
      IF (x_okl_criteria_tl_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_okl_criteria_tl_rec.created_by := l_okl_criteria_tl_rec.created_by;
      END IF;
      IF (x_okl_criteria_tl_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_okl_criteria_tl_rec.creation_date := l_okl_criteria_tl_rec.creation_date;
      END IF;
      IF (x_okl_criteria_tl_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_okl_criteria_tl_rec.last_updated_by := l_okl_criteria_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_criteria_tl_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_okl_criteria_tl_rec.last_update_date := l_okl_criteria_tl_rec.last_update_date;
      END IF;
      IF (x_okl_criteria_tl_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_okl_criteria_tl_rec.last_update_login := l_okl_criteria_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_CRITERIA_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_criteria_tl_rec IN  okl_criteria_tl_rec_type,
      x_okl_criteria_tl_rec OUT NOCOPY okl_criteria_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_criteria_tl_rec := p_okl_criteria_tl_rec;
      x_okl_criteria_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_criteria_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_criteria_tl_rec,             -- IN
      l_okl_criteria_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_criteria_tl_rec, l_def_okl_criteria_tl_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CRITERIA_TL
    SET NAME = l_def_okl_criteria_tl_rec.name,
        DESCRIPTION = l_def_okl_criteria_tl_rec.description,
        CREATED_BY = l_def_okl_criteria_tl_rec.created_by,
        CREATION_DATE = l_def_okl_criteria_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_criteria_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_criteria_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_criteria_tl_rec.last_update_login
    WHERE ID = l_def_okl_criteria_tl_rec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_CRITERIA_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_criteria_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_criteria_tl_rec := l_def_okl_criteria_tl_rec;
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
  -----------------------------------
  -- update_row for:OKL_CRITERIA_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crnv_rec                     IN crnv_rec_type,
    x_crnv_rec                     OUT NOCOPY crnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_crnv_rec                     crnv_rec_type := p_crnv_rec;
    l_def_crnv_rec                 crnv_rec_type;
    l_okl_criteria_tl_rec          okl_criteria_tl_rec_type;
    lx_okl_criteria_tl_rec         okl_criteria_tl_rec_type;
    l_crn_rec                      crn_rec_type;
    lx_crn_rec                     crn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_crnv_rec	IN crnv_rec_type
    ) RETURN crnv_rec_type IS
      l_crnv_rec	crnv_rec_type := p_crnv_rec;
    BEGIN
      l_crnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_crnv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_crnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_crnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_crnv_rec	IN crnv_rec_type,
      x_crnv_rec	OUT NOCOPY crnv_rec_type
    ) RETURN VARCHAR2 IS
      l_crnv_rec                     crnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_crnv_rec := p_crnv_rec;
      -- Get current database values
      l_crnv_rec := get_rec(p_crnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_crnv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_crnv_rec.id := l_crnv_rec.id;
      END IF;
      IF (x_crnv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_crnv_rec.object_version_number := l_crnv_rec.object_version_number;
      END IF;
      IF (x_crnv_rec.sfwt_flag = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.sfwt_flag := l_crnv_rec.sfwt_flag;
      END IF;
      IF (x_crnv_rec.data_type_code = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.data_type_code := l_crnv_rec.data_type_code;
      END IF;
      IF (x_crnv_rec.jtf_object_code = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.jtf_object_code := l_crnv_rec.jtf_object_code;
      END IF;
      IF (x_crnv_rec.name = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.name := l_crnv_rec.name;
      END IF;
      IF (x_crnv_rec.description = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.description := l_crnv_rec.description;
      END IF;
      IF (x_crnv_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute_category := l_crnv_rec.attribute_category;
      END IF;
      IF (x_crnv_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute1 := l_crnv_rec.attribute1;
      END IF;
      IF (x_crnv_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute2 := l_crnv_rec.attribute2;
      END IF;
      IF (x_crnv_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute3 := l_crnv_rec.attribute3;
      END IF;
      IF (x_crnv_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute4 := l_crnv_rec.attribute4;
      END IF;
      IF (x_crnv_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute5 := l_crnv_rec.attribute5;
      END IF;
      IF (x_crnv_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute6 := l_crnv_rec.attribute6;
      END IF;
      IF (x_crnv_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute7 := l_crnv_rec.attribute7;
      END IF;
      IF (x_crnv_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute8 := l_crnv_rec.attribute8;
      END IF;
      IF (x_crnv_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute9 := l_crnv_rec.attribute9;
      END IF;
      IF (x_crnv_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute10 := l_crnv_rec.attribute10;
      END IF;
      IF (x_crnv_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute11 := l_crnv_rec.attribute11;
      END IF;
      IF (x_crnv_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute12 := l_crnv_rec.attribute12;
      END IF;
      IF (x_crnv_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute13 := l_crnv_rec.attribute13;
      END IF;
      IF (x_crnv_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute14 := l_crnv_rec.attribute14;
      END IF;
      IF (x_crnv_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.attribute15 := l_crnv_rec.attribute15;
      END IF;
      IF (x_crnv_rec.crn_type = okl_api.G_MISS_CHAR)
      THEN
        x_crnv_rec.crn_type := l_crnv_rec.crn_type;
      END IF;
      IF (x_crnv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_crnv_rec.created_by := l_crnv_rec.created_by;
      END IF;
      IF (x_crnv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_crnv_rec.creation_date := l_crnv_rec.creation_date;
      END IF;
      IF (x_crnv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_crnv_rec.last_updated_by := l_crnv_rec.last_updated_by;
      END IF;
      IF (x_crnv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_crnv_rec.last_update_date := l_crnv_rec.last_update_date;
      END IF;
      IF (x_crnv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_crnv_rec.last_update_login := l_crnv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_CRITERIA_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_crnv_rec IN  crnv_rec_type,
      x_crnv_rec OUT NOCOPY crnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_crnv_rec := p_crnv_rec;
      x_crnv_rec.OBJECT_VERSION_NUMBER := NVL(x_crnv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_crnv_rec,                        -- IN
      l_crnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_crnv_rec, l_def_crnv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_crnv_rec := fill_who_columns(l_def_crnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_crnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_crnv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_crnv_rec, l_okl_criteria_tl_rec);
    migrate(l_def_crnv_rec, l_crn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_criteria_tl_rec,
      lx_okl_criteria_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_criteria_tl_rec, l_def_crnv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_crn_rec,
      lx_crn_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_crn_rec, l_def_crnv_rec);
    x_crnv_rec := l_def_crnv_rec;
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
  -- PL/SQL TBL update_row for:CRNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crnv_tbl                     IN crnv_tbl_type,
    x_crnv_tbl                     OUT NOCOPY crnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crnv_tbl.COUNT > 0) THEN
      i := p_crnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crnv_rec                     => p_crnv_tbl(i),
          x_crnv_rec                     => x_crnv_tbl(i));
        EXIT WHEN (i = p_crnv_tbl.LAST);
        i := p_crnv_tbl.NEXT(i);
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
  -----------------------------------
  -- delete_row for:OKL_CRITERIA_B --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crn_rec                      IN crn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_crn_rec                      crn_rec_type:= p_crn_rec;
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
    DELETE FROM OKL_CRITERIA_B
     WHERE ID = l_crn_rec.id;

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
  ------------------------------------
  -- delete_row for:OKL_CRITERIA_TL --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_criteria_tl_rec          IN okl_criteria_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_criteria_tl_rec          okl_criteria_tl_rec_type:= p_okl_criteria_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------
    -- Set_Attributes for:OKL_CRITERIA_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_criteria_tl_rec IN  okl_criteria_tl_rec_type,
      x_okl_criteria_tl_rec OUT NOCOPY okl_criteria_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_criteria_tl_rec := p_okl_criteria_tl_rec;
      x_okl_criteria_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_criteria_tl_rec,             -- IN
      l_okl_criteria_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_CRITERIA_TL
     WHERE ID = l_okl_criteria_tl_rec.id;

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
  -----------------------------------
  -- delete_row for:OKL_CRITERIA_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crnv_rec                     IN crnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_crnv_rec                     crnv_rec_type := p_crnv_rec;
    l_okl_criteria_tl_rec          okl_criteria_tl_rec_type;
    l_crn_rec                      crn_rec_type;
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
    migrate(l_crnv_rec, l_okl_criteria_tl_rec);
    migrate(l_crnv_rec, l_crn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_criteria_tl_rec
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
      l_crn_rec
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
  -- PL/SQL TBL delete_row for:CRNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crnv_tbl                     IN crnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crnv_tbl.COUNT > 0) THEN
      i := p_crnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crnv_rec                     => p_crnv_tbl(i));
        EXIT WHEN (i = p_crnv_tbl.LAST);
        i := p_crnv_tbl.NEXT(i);
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
END Okl_Crn_Pvt;

/
