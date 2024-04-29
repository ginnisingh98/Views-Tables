--------------------------------------------------------
--  DDL for Package Body OKL_ANT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ANT_PVT" AS
/* $Header: OKLSANTB.pls 115.5 2004/05/21 21:25:53 pjgomes noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_antv_rec IN antv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_antv_rec.id = Okl_Api.G_MISS_NUM OR
       p_antv_rec.id IS NULL
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
  PROCEDURE validate_object_version_number (p_antv_rec IN antv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_antv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_antv_rec.object_version_number IS NULL
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
  -- PROCEDURE validate_qty_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_qty_id (p_antv_rec IN antv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_qty_id_csr IS
    SELECT '1'
	FROM OKL_QUESTION_TYPES_B
	WHERE id = p_antv_rec.qty_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_antv_rec.qty_id = Okl_Api.G_MISS_NUM OR
       p_antv_rec.qty_id IS NULL
    THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'qty_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Validate Foreign Key
 	OPEN l_qty_id_csr;
	FETCH l_qty_id_csr INTO l_dummy_var;
	CLOSE l_qty_id_csr;

	IF (l_dummy_var <> '1') THEN
	 	x_return_status := Okl_Api.G_RET_STS_ERROR;
	    Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
		 				    p_msg_name			=> G_NO_PARENT_RECORD,
							p_token1			=> G_COL_NAME_TOKEN,
							p_token1_value		=> 'QTY_ID_FOR',
							p_token2			=> G_CHILD_TABLE_TOKEN,
							p_token2_value		=> G_VIEW,
							p_token3			=> G_PARENT_TABLE_TOKEN,
							p_token3_value		=> 'OKL_ANSWER_SETS_V');

		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END validate_qty_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_name
  ---------------------------------------------------------------------------
  PROCEDURE validate_name (p_antv_rec IN antv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_antv_rec.name = Okl_Api.G_MISS_CHAR OR
       p_antv_rec.name IS NULL
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
  -- PROCEDURE Is_Unique
  -- Post-Generation Change
  -- By STMATHEW on 24-APR-2001
  ---------------------------------------------------------------------------
  FUNCTION Is_Unique (
    p_antv_rec IN antv_rec_type
  ) RETURN VARCHAR2 IS

    CURSOR l_antv_csr IS
                  SELECT 'x'
                  FROM   okl_answer_sets_v
                  WHERE  name = p_antv_rec.name
                  AND    id   <> nvl (p_antv_rec.id, -99999);

    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;

  BEGIN

    -- check for unique NAME
    OPEN     l_antv_csr;
    FETCH    l_antv_csr INTO l_dummy;
          l_found  := l_antv_csr%FOUND;
          CLOSE    l_antv_csr;

    IF (l_found) THEN

      -- display error message
      OKL_API.set_message(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_NOT_SAME,
        p_token1          => 'NAME',
        p_token1_value    => p_antv_rec.name);

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
      IF l_antv_csr%ISOPEN THEN
         CLOSE l_antv_csr;
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
    DELETE FROM OKL_ANSWER_SETS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_ANSWER_SETS_B B      --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_ANSWER_SETS_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_ANSWER_SETS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_ANSWER_SETS_TL SUBB, OKL_ANSWER_SETS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_ANSWER_SETS_TL (
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
        FROM OKL_ANSWER_SETS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_ANSWER_SETS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ANSWER_SETS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ant_rec                      IN ant_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ant_rec_type IS
    CURSOR ant_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            QTY_ID,
            OBJECT_VERSION_NUMBER,
            CONTEXT_ORG,
            CONTEXT_INV_ORG,
            CONTEXT_ASSET_BOOK,
            CONTEXT_INTENT,
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
      FROM Okl_Answer_Sets_B
     WHERE okl_answer_sets_b.id = p_id;
    l_ant_pk                       ant_pk_csr%ROWTYPE;
    l_ant_rec                      ant_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ant_pk_csr (p_ant_rec.id);
    FETCH ant_pk_csr INTO
              l_ant_rec.ID,
              l_ant_rec.QTY_ID,
              l_ant_rec.OBJECT_VERSION_NUMBER,
              l_ant_rec.CONTEXT_ORG,
              l_ant_rec.CONTEXT_INV_ORG,
              l_ant_rec.CONTEXT_ASSET_BOOK,
              l_ant_rec.CONTEXT_INTENT,
              l_ant_rec.START_DATE,
              l_ant_rec.END_DATE,
              l_ant_rec.ATTRIBUTE_CATEGORY,
              l_ant_rec.ATTRIBUTE1,
              l_ant_rec.ATTRIBUTE2,
              l_ant_rec.ATTRIBUTE3,
              l_ant_rec.ATTRIBUTE4,
              l_ant_rec.ATTRIBUTE5,
              l_ant_rec.ATTRIBUTE6,
              l_ant_rec.ATTRIBUTE7,
              l_ant_rec.ATTRIBUTE8,
              l_ant_rec.ATTRIBUTE9,
              l_ant_rec.ATTRIBUTE10,
              l_ant_rec.ATTRIBUTE11,
              l_ant_rec.ATTRIBUTE12,
              l_ant_rec.ATTRIBUTE13,
              l_ant_rec.ATTRIBUTE14,
              l_ant_rec.ATTRIBUTE15,
              l_ant_rec.CREATED_BY,
              l_ant_rec.CREATION_DATE,
              l_ant_rec.LAST_UPDATED_BY,
              l_ant_rec.LAST_UPDATE_DATE,
              l_ant_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := ant_pk_csr%NOTFOUND;
    CLOSE ant_pk_csr;
    RETURN(l_ant_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ant_rec                      IN ant_rec_type
  ) RETURN ant_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ant_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ANSWER_SETS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_answer_sets_tl_rec       IN okl_answer_sets_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_answer_sets_tl_rec_type IS
    CURSOR okl_answer_sets_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Answer_Sets_Tl
     WHERE okl_answer_sets_tl.id = p_id
       AND okl_answer_sets_tl.LANGUAGE = p_language;
    l_okl_answer_sets_tl_pk        okl_answer_sets_tl_pk_csr%ROWTYPE;
    l_okl_answer_sets_tl_rec       okl_answer_sets_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_answer_sets_tl_pk_csr (p_okl_answer_sets_tl_rec.id,
                                    p_okl_answer_sets_tl_rec.LANGUAGE);
    FETCH okl_answer_sets_tl_pk_csr INTO
              l_okl_answer_sets_tl_rec.ID,
              l_okl_answer_sets_tl_rec.LANGUAGE,
              l_okl_answer_sets_tl_rec.SOURCE_LANG,
              l_okl_answer_sets_tl_rec.SFWT_FLAG,
              l_okl_answer_sets_tl_rec.NAME,
              l_okl_answer_sets_tl_rec.DESCRIPTION,
              l_okl_answer_sets_tl_rec.CREATED_BY,
              l_okl_answer_sets_tl_rec.CREATION_DATE,
              l_okl_answer_sets_tl_rec.LAST_UPDATED_BY,
              l_okl_answer_sets_tl_rec.LAST_UPDATE_DATE,
              l_okl_answer_sets_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_answer_sets_tl_pk_csr%NOTFOUND;
    CLOSE okl_answer_sets_tl_pk_csr;
    RETURN(l_okl_answer_sets_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_answer_sets_tl_rec       IN okl_answer_sets_tl_rec_type
  ) RETURN okl_answer_sets_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_answer_sets_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ANSWER_SETS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_antv_rec                     IN antv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN antv_rec_type IS
    CURSOR okl_antv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            QTY_ID,
            NAME,
            DESCRIPTION,
            CONTEXT_ORG,
            CONTEXT_INV_ORG,
            CONTEXT_ASSET_BOOK,
            CONTEXT_INTENT,
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
      FROM Okl_Answer_Sets_V
     WHERE okl_answer_sets_v.id = p_id;
    l_okl_antv_pk                  okl_antv_pk_csr%ROWTYPE;
    l_antv_rec                     antv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_antv_pk_csr (p_antv_rec.id);
    FETCH okl_antv_pk_csr INTO
              l_antv_rec.ID,
              l_antv_rec.OBJECT_VERSION_NUMBER,
              l_antv_rec.SFWT_FLAG,
              l_antv_rec.QTY_ID,
              l_antv_rec.NAME,
              l_antv_rec.DESCRIPTION,
              l_antv_rec.CONTEXT_ORG,
              l_antv_rec.CONTEXT_INV_ORG,
              l_antv_rec.CONTEXT_ASSET_BOOK,
              l_antv_rec.CONTEXT_INTENT,
              l_antv_rec.START_DATE,
              l_antv_rec.END_DATE,
              l_antv_rec.ATTRIBUTE_CATEGORY,
              l_antv_rec.ATTRIBUTE1,
              l_antv_rec.ATTRIBUTE2,
              l_antv_rec.ATTRIBUTE3,
              l_antv_rec.ATTRIBUTE4,
              l_antv_rec.ATTRIBUTE5,
              l_antv_rec.ATTRIBUTE6,
              l_antv_rec.ATTRIBUTE7,
              l_antv_rec.ATTRIBUTE8,
              l_antv_rec.ATTRIBUTE9,
              l_antv_rec.ATTRIBUTE10,
              l_antv_rec.ATTRIBUTE11,
              l_antv_rec.ATTRIBUTE12,
              l_antv_rec.ATTRIBUTE13,
              l_antv_rec.ATTRIBUTE14,
              l_antv_rec.ATTRIBUTE15,
              l_antv_rec.CREATED_BY,
              l_antv_rec.CREATION_DATE,
              l_antv_rec.LAST_UPDATED_BY,
              l_antv_rec.LAST_UPDATE_DATE,
              l_antv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_antv_pk_csr%NOTFOUND;
    CLOSE okl_antv_pk_csr;
    RETURN(l_antv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_antv_rec                     IN antv_rec_type
  ) RETURN antv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_antv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_ANSWER_SETS_V --
  -------------------------------------------------------
  FUNCTION null_out_defaults (
    p_antv_rec	IN antv_rec_type
  ) RETURN antv_rec_type IS
    l_antv_rec	antv_rec_type := p_antv_rec;
  BEGIN
    IF (l_antv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_antv_rec.object_version_number := NULL;
    END IF;
    IF (l_antv_rec.sfwt_flag = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_antv_rec.qty_id = okl_api.G_MISS_NUM) THEN
      l_antv_rec.qty_id := NULL;
    END IF;
    IF (l_antv_rec.name = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.name := NULL;
    END IF;
    IF (l_antv_rec.description = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.description := NULL;
    END IF;
    IF (l_antv_rec.context_org = okl_api.G_MISS_NUM) THEN
      l_antv_rec.context_org := NULL;
    END IF;
    IF (l_antv_rec.context_inv_org = okl_api.G_MISS_NUM) THEN
      l_antv_rec.context_inv_org := NULL;
    END IF;
    IF (l_antv_rec.context_asset_book = Okl_Api.G_MISS_CHAR) THEN
      l_antv_rec.context_asset_book := NULL;
    END IF;
    IF (l_antv_rec.context_intent = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.context_intent := NULL;
    END IF;
    IF (l_antv_rec.start_date = okl_api.G_MISS_DATE) THEN
      l_antv_rec.start_date := NULL;
    END IF;
    IF (l_antv_rec.end_date = okl_api.G_MISS_DATE) THEN
      l_antv_rec.end_date := NULL;
    END IF;
    IF (l_antv_rec.attribute_category = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute_category := NULL;
    END IF;
    IF (l_antv_rec.attribute1 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute1 := NULL;
    END IF;
    IF (l_antv_rec.attribute2 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute2 := NULL;
    END IF;
    IF (l_antv_rec.attribute3 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute3 := NULL;
    END IF;
    IF (l_antv_rec.attribute4 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute4 := NULL;
    END IF;
    IF (l_antv_rec.attribute5 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute5 := NULL;
    END IF;
    IF (l_antv_rec.attribute6 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute6 := NULL;
    END IF;
    IF (l_antv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_antv_rec.attribute7 := NULL;
    END IF;
    IF (l_antv_rec.attribute8 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute8 := NULL;
    END IF;
    IF (l_antv_rec.attribute9 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute9 := NULL;
    END IF;
    IF (l_antv_rec.attribute10 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute10 := NULL;
    END IF;
    IF (l_antv_rec.attribute11 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute11 := NULL;
    END IF;
    IF (l_antv_rec.attribute12 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute12 := NULL;
    END IF;
    IF (l_antv_rec.attribute13 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute13 := NULL;
    END IF;
    IF (l_antv_rec.attribute14 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute14 := NULL;
    END IF;
    IF (l_antv_rec.attribute15 = okl_api.G_MISS_CHAR) THEN
      l_antv_rec.attribute15 := NULL;
    END IF;
    IF (l_antv_rec.created_by = okl_api.G_MISS_NUM) THEN
      l_antv_rec.created_by := NULL;
    END IF;
    IF (l_antv_rec.creation_date = okl_api.G_MISS_DATE) THEN
      l_antv_rec.creation_date := NULL;
    END IF;
    IF (l_antv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_antv_rec.last_updated_by := NULL;
    END IF;
    IF (l_antv_rec.last_update_date = okl_api.G_MISS_DATE) THEN
      l_antv_rec.last_update_date := NULL;
    END IF;
    IF (l_antv_rec.last_update_login = okl_api.G_MISS_NUM) THEN
      l_antv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_antv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKL_ANSWER_SETS_V --
  -----------------------------------------------
  FUNCTION Validate_Attributes (
    p_antv_rec IN  antv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
	-- TAPI postgen 05/23/2001
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- End TAPI postgen 05/23/2001
  BEGIN
  	-- TAPI postgen 05/23/2001
    validate_id(p_antv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_object_version_number(p_antv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_qty_id(p_antv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_name(p_antv_rec, x_return_status);
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
  -------------------------------------------
  -- Validate_Record for:OKL_ANSWER_SETS_V --
  -------------------------------------------
  FUNCTION Validate_Record (
    p_antv_rec IN antv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each record-level validation
    l_return_status := is_unique (p_antv_rec);

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
    p_from	IN antv_rec_type,
    p_to	OUT NOCOPY ant_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.qty_id := p_from.qty_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.context_org := p_from.context_org;
    p_to.context_inv_org := p_from.context_inv_org;
    p_to.context_asset_book := p_from.context_asset_book;
    p_to.context_intent := p_from.context_intent;
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
    p_from	IN ant_rec_type,
    p_to	OUT NOCOPY antv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.qty_id := p_from.qty_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.context_org := p_from.context_org;
    p_to.context_inv_org := p_from.context_inv_org;
    p_to.context_asset_book := p_from.context_asset_book;
    p_to.context_intent := p_from.context_intent;
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
    p_from	IN antv_rec_type,
    p_to	OUT NOCOPY okl_answer_sets_tl_rec_type
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
    p_from	IN okl_answer_sets_tl_rec_type,
    p_to	OUT NOCOPY antv_rec_type
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
  ----------------------------------------
  -- validate_row for:OKL_ANSWER_SETS_V --
  ----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_antv_rec                     IN antv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_antv_rec                     antv_rec_type := p_antv_rec;
    l_ant_rec                      ant_rec_type;
    l_okl_answer_sets_tl_rec       okl_answer_sets_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_antv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_antv_rec);
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
  -- PL/SQL TBL validate_row for:ANTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_antv_tbl                     IN antv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_antv_tbl.COUNT > 0) THEN
      i := p_antv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_antv_rec                     => p_antv_tbl(i));
        EXIT WHEN (i = p_antv_tbl.LAST);
        i := p_antv_tbl.NEXT(i);
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
  --------------------------------------
  -- insert_row for:OKL_ANSWER_SETS_B --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ant_rec                      IN ant_rec_type,
    x_ant_rec                      OUT NOCOPY ant_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ant_rec                      ant_rec_type := p_ant_rec;
    l_def_ant_rec                  ant_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_ANSWER_SETS_B --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_ant_rec IN  ant_rec_type,
      x_ant_rec OUT NOCOPY ant_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ant_rec := p_ant_rec;
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
      p_ant_rec,                         -- IN
      l_ant_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_ANSWER_SETS_B(
        id,
        qty_id,
        object_version_number,
        context_org,
        context_inv_org,
        context_asset_book,
        context_intent,
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
        l_ant_rec.id,
        l_ant_rec.qty_id,
        l_ant_rec.object_version_number,
        l_ant_rec.context_org,
        l_ant_rec.context_inv_org,
        l_ant_rec.context_asset_book,
        l_ant_rec.context_intent,
        l_ant_rec.start_date,
        l_ant_rec.end_date,
        l_ant_rec.attribute_category,
        l_ant_rec.attribute1,
        l_ant_rec.attribute2,
        l_ant_rec.attribute3,
        l_ant_rec.attribute4,
        l_ant_rec.attribute5,
        l_ant_rec.attribute6,
        l_ant_rec.attribute7,
        l_ant_rec.attribute8,
        l_ant_rec.attribute9,
        l_ant_rec.attribute10,
        l_ant_rec.attribute11,
        l_ant_rec.attribute12,
        l_ant_rec.attribute13,
        l_ant_rec.attribute14,
        l_ant_rec.attribute15,
        l_ant_rec.created_by,
        l_ant_rec.creation_date,
        l_ant_rec.last_updated_by,
        l_ant_rec.last_update_date,
        l_ant_rec.last_update_login);
    -- Set OUT values
    x_ant_rec := l_ant_rec;
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
  ---------------------------------------
  -- insert_row for:OKL_ANSWER_SETS_TL --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_answer_sets_tl_rec       IN okl_answer_sets_tl_rec_type,
    x_okl_answer_sets_tl_rec       OUT NOCOPY okl_answer_sets_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_answer_sets_tl_rec       okl_answer_sets_tl_rec_type := p_okl_answer_sets_tl_rec;
    l_def_okl_answer_sets_tl_rec   okl_answer_sets_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -------------------------------------------
    -- Set_Attributes for:OKL_ANSWER_SETS_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_answer_sets_tl_rec IN  okl_answer_sets_tl_rec_type,
      x_okl_answer_sets_tl_rec OUT NOCOPY okl_answer_sets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_answer_sets_tl_rec := p_okl_answer_sets_tl_rec;
      x_okl_answer_sets_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_answer_sets_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_answer_sets_tl_rec,          -- IN
      l_okl_answer_sets_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_answer_sets_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_ANSWER_SETS_TL(
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
          l_okl_answer_sets_tl_rec.id,
          l_okl_answer_sets_tl_rec.LANGUAGE,
          l_okl_answer_sets_tl_rec.source_lang,
          l_okl_answer_sets_tl_rec.sfwt_flag,
          l_okl_answer_sets_tl_rec.name,
          l_okl_answer_sets_tl_rec.description,
          l_okl_answer_sets_tl_rec.created_by,
          l_okl_answer_sets_tl_rec.creation_date,
          l_okl_answer_sets_tl_rec.last_updated_by,
          l_okl_answer_sets_tl_rec.last_update_date,
          l_okl_answer_sets_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_answer_sets_tl_rec := l_okl_answer_sets_tl_rec;
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
  --------------------------------------
  -- insert_row for:OKL_ANSWER_SETS_V --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_antv_rec                     IN antv_rec_type,
    x_antv_rec                     OUT NOCOPY antv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_antv_rec                     antv_rec_type;
    l_def_antv_rec                 antv_rec_type;
    l_ant_rec                      ant_rec_type;
    lx_ant_rec                     ant_rec_type;
    l_okl_answer_sets_tl_rec       okl_answer_sets_tl_rec_type;
    lx_okl_answer_sets_tl_rec      okl_answer_sets_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_antv_rec	IN antv_rec_type
    ) RETURN antv_rec_type IS
      l_antv_rec	antv_rec_type := p_antv_rec;
    BEGIN
      l_antv_rec.CREATION_DATE := SYSDATE;
      l_antv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_antv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_antv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_antv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_antv_rec);
    END fill_who_columns;
    ------------------------------------------
    -- Set_Attributes for:OKL_ANSWER_SETS_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_antv_rec IN  antv_rec_type,
      x_antv_rec OUT NOCOPY antv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_antv_rec := p_antv_rec;
      x_antv_rec.OBJECT_VERSION_NUMBER := 1;
      x_antv_rec.SFWT_FLAG := 'N';
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
    l_antv_rec := null_out_defaults(p_antv_rec);
    -- Set primary key value
    l_antv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_antv_rec,                        -- IN
      l_def_antv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_antv_rec := fill_who_columns(l_def_antv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_antv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_antv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_antv_rec, l_ant_rec);
    migrate(l_def_antv_rec, l_okl_answer_sets_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ant_rec,
      lx_ant_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ant_rec, l_def_antv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_answer_sets_tl_rec,
      lx_okl_answer_sets_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_answer_sets_tl_rec, l_def_antv_rec);
    -- Set OUT values
    x_antv_rec := l_def_antv_rec;
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
  -- PL/SQL TBL insert_row for:ANTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_antv_tbl                     IN antv_tbl_type,
    x_antv_tbl                     OUT NOCOPY antv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_antv_tbl.COUNT > 0) THEN
      i := p_antv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_antv_rec                     => p_antv_tbl(i),
          x_antv_rec                     => x_antv_tbl(i));
        EXIT WHEN (i = p_antv_tbl.LAST);
        i := p_antv_tbl.NEXT(i);
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
  ------------------------------------
  -- lock_row for:OKL_ANSWER_SETS_B --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ant_rec                      IN ant_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ant_rec IN ant_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ANSWER_SETS_B
     WHERE ID = p_ant_rec.id
       AND OBJECT_VERSION_NUMBER = p_ant_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ant_rec IN ant_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ANSWER_SETS_B
    WHERE ID = p_ant_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_ANSWER_SETS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_ANSWER_SETS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ant_rec);
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
      OPEN lchk_csr(p_ant_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ant_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ant_rec.object_version_number THEN
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
  -------------------------------------
  -- lock_row for:OKL_ANSWER_SETS_TL --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_answer_sets_tl_rec       IN okl_answer_sets_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_answer_sets_tl_rec IN okl_answer_sets_tl_rec_type) IS
    SELECT *
      FROM OKL_ANSWER_SETS_TL
     WHERE ID = p_okl_answer_sets_tl_rec.id
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
      OPEN lock_csr(p_okl_answer_sets_tl_rec);
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
  ------------------------------------
  -- lock_row for:OKL_ANSWER_SETS_V --
  ------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_antv_rec                     IN antv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ant_rec                      ant_rec_type;
    l_okl_answer_sets_tl_rec       okl_answer_sets_tl_rec_type;
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
    migrate(p_antv_rec, l_ant_rec);
    migrate(p_antv_rec, l_okl_answer_sets_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ant_rec
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
      l_okl_answer_sets_tl_rec
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
  -- PL/SQL TBL lock_row for:ANTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_antv_tbl                     IN antv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_antv_tbl.COUNT > 0) THEN
      i := p_antv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_antv_rec                     => p_antv_tbl(i));
        EXIT WHEN (i = p_antv_tbl.LAST);
        i := p_antv_tbl.NEXT(i);
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
  --------------------------------------
  -- update_row for:OKL_ANSWER_SETS_B --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ant_rec                      IN ant_rec_type,
    x_ant_rec                      OUT NOCOPY ant_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ant_rec                      ant_rec_type := p_ant_rec;
    l_def_ant_rec                  ant_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ant_rec	IN ant_rec_type,
      x_ant_rec	OUT NOCOPY ant_rec_type
    ) RETURN VARCHAR2 IS
      l_ant_rec                      ant_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ant_rec := p_ant_rec;
      -- Get current database values
      l_ant_rec := get_rec(p_ant_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ant_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_ant_rec.id := l_ant_rec.id;
      END IF;
      IF (x_ant_rec.qty_id = okl_api.G_MISS_NUM)
      THEN
        x_ant_rec.qty_id := l_ant_rec.qty_id;
      END IF;
      IF (x_ant_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_ant_rec.object_version_number := l_ant_rec.object_version_number;
      END IF;
      IF (x_ant_rec.context_org = okl_api.G_MISS_NUM)
      THEN
        x_ant_rec.context_org := l_ant_rec.context_org;
      END IF;
      IF (x_ant_rec.context_inv_org = okl_api.G_MISS_NUM)
      THEN
        x_ant_rec.context_inv_org := l_ant_rec.context_inv_org;
      END IF;
      IF (x_ant_rec.context_asset_book = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.context_asset_book := l_ant_rec.context_asset_book;
      END IF;
      IF (x_ant_rec.context_intent = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.context_intent := l_ant_rec.context_intent;
      END IF;
      IF (x_ant_rec.start_date = okl_api.G_MISS_DATE)
      THEN
        x_ant_rec.start_date := l_ant_rec.start_date;
      END IF;
      IF (x_ant_rec.end_date = okl_api.G_MISS_DATE)
      THEN
        x_ant_rec.end_date := l_ant_rec.end_date;
      END IF;
      IF (x_ant_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute_category := l_ant_rec.attribute_category;
      END IF;
      IF (x_ant_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute1 := l_ant_rec.attribute1;
      END IF;
      IF (x_ant_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute2 := l_ant_rec.attribute2;
      END IF;
      IF (x_ant_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute3 := l_ant_rec.attribute3;
      END IF;
      IF (x_ant_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute4 := l_ant_rec.attribute4;
      END IF;
      IF (x_ant_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute5 := l_ant_rec.attribute5;
      END IF;
      IF (x_ant_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute6 := l_ant_rec.attribute6;
      END IF;
      IF (x_ant_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute7 := l_ant_rec.attribute7;
      END IF;
      IF (x_ant_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute8 := l_ant_rec.attribute8;
      END IF;
      IF (x_ant_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute9 := l_ant_rec.attribute9;
      END IF;
      IF (x_ant_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute10 := l_ant_rec.attribute10;
      END IF;
      IF (x_ant_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute11 := l_ant_rec.attribute11;
      END IF;
      IF (x_ant_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute12 := l_ant_rec.attribute12;
      END IF;
      IF (x_ant_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute13 := l_ant_rec.attribute13;
      END IF;
      IF (x_ant_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute14 := l_ant_rec.attribute14;
      END IF;
      IF (x_ant_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_ant_rec.attribute15 := l_ant_rec.attribute15;
      END IF;
      IF (x_ant_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_ant_rec.created_by := l_ant_rec.created_by;
      END IF;
      IF (x_ant_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_ant_rec.creation_date := l_ant_rec.creation_date;
      END IF;
      IF (x_ant_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_ant_rec.last_updated_by := l_ant_rec.last_updated_by;
      END IF;
      IF (x_ant_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_ant_rec.last_update_date := l_ant_rec.last_update_date;
      END IF;
      IF (x_ant_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_ant_rec.last_update_login := l_ant_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_ANSWER_SETS_B --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_ant_rec IN  ant_rec_type,
      x_ant_rec OUT NOCOPY ant_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ant_rec := p_ant_rec;
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
      p_ant_rec,                         -- IN
      l_ant_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ant_rec, l_def_ant_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ANSWER_SETS_B
    SET QTY_ID = l_def_ant_rec.qty_id,
        OBJECT_VERSION_NUMBER = l_def_ant_rec.object_version_number,
        CONTEXT_ORG = l_def_ant_rec.context_org,
        CONTEXT_INV_ORG = l_def_ant_rec.context_inv_org,
        CONTEXT_ASSET_BOOK = l_def_ant_rec.context_asset_book,
        CONTEXT_INTENT = l_def_ant_rec.context_intent,
        START_DATE = l_def_ant_rec.start_date,
        END_DATE = l_def_ant_rec.end_date,
        ATTRIBUTE_CATEGORY = l_def_ant_rec.attribute_category,
        ATTRIBUTE1 = l_def_ant_rec.attribute1,
        ATTRIBUTE2 = l_def_ant_rec.attribute2,
        ATTRIBUTE3 = l_def_ant_rec.attribute3,
        ATTRIBUTE4 = l_def_ant_rec.attribute4,
        ATTRIBUTE5 = l_def_ant_rec.attribute5,
        ATTRIBUTE6 = l_def_ant_rec.attribute6,
        ATTRIBUTE7 = l_def_ant_rec.attribute7,
        ATTRIBUTE8 = l_def_ant_rec.attribute8,
        ATTRIBUTE9 = l_def_ant_rec.attribute9,
        ATTRIBUTE10 = l_def_ant_rec.attribute10,
        ATTRIBUTE11 = l_def_ant_rec.attribute11,
        ATTRIBUTE12 = l_def_ant_rec.attribute12,
        ATTRIBUTE13 = l_def_ant_rec.attribute13,
        ATTRIBUTE14 = l_def_ant_rec.attribute14,
        ATTRIBUTE15 = l_def_ant_rec.attribute15,
        CREATED_BY = l_def_ant_rec.created_by,
        CREATION_DATE = l_def_ant_rec.creation_date,
        LAST_UPDATED_BY = l_def_ant_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ant_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ant_rec.last_update_login
    WHERE ID = l_def_ant_rec.id;

    x_ant_rec := l_def_ant_rec;
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
  ---------------------------------------
  -- update_row for:OKL_ANSWER_SETS_TL --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_answer_sets_tl_rec       IN okl_answer_sets_tl_rec_type,
    x_okl_answer_sets_tl_rec       OUT NOCOPY okl_answer_sets_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_answer_sets_tl_rec       okl_answer_sets_tl_rec_type := p_okl_answer_sets_tl_rec;
    l_def_okl_answer_sets_tl_rec   okl_answer_sets_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_answer_sets_tl_rec	IN okl_answer_sets_tl_rec_type,
      x_okl_answer_sets_tl_rec	OUT NOCOPY okl_answer_sets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_answer_sets_tl_rec       okl_answer_sets_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_answer_sets_tl_rec := p_okl_answer_sets_tl_rec;
      -- Get current database values
      l_okl_answer_sets_tl_rec := get_rec(p_okl_answer_sets_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_answer_sets_tl_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_okl_answer_sets_tl_rec.id := l_okl_answer_sets_tl_rec.id;
      END IF;
      IF (x_okl_answer_sets_tl_rec.LANGUAGE = okl_api.G_MISS_CHAR)
      THEN
        x_okl_answer_sets_tl_rec.LANGUAGE := l_okl_answer_sets_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_answer_sets_tl_rec.source_lang = okl_api.G_MISS_CHAR)
      THEN
        x_okl_answer_sets_tl_rec.source_lang := l_okl_answer_sets_tl_rec.source_lang;
      END IF;
      IF (x_okl_answer_sets_tl_rec.sfwt_flag = okl_api.G_MISS_CHAR)
      THEN
        x_okl_answer_sets_tl_rec.sfwt_flag := l_okl_answer_sets_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_answer_sets_tl_rec.name = okl_api.G_MISS_CHAR)
      THEN
        x_okl_answer_sets_tl_rec.name := l_okl_answer_sets_tl_rec.name;
      END IF;
      IF (x_okl_answer_sets_tl_rec.description = okl_api.G_MISS_CHAR)
      THEN
        x_okl_answer_sets_tl_rec.description := l_okl_answer_sets_tl_rec.description;
      END IF;
      IF (x_okl_answer_sets_tl_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_okl_answer_sets_tl_rec.created_by := l_okl_answer_sets_tl_rec.created_by;
      END IF;
      IF (x_okl_answer_sets_tl_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_okl_answer_sets_tl_rec.creation_date := l_okl_answer_sets_tl_rec.creation_date;
      END IF;
      IF (x_okl_answer_sets_tl_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_okl_answer_sets_tl_rec.last_updated_by := l_okl_answer_sets_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_answer_sets_tl_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_okl_answer_sets_tl_rec.last_update_date := l_okl_answer_sets_tl_rec.last_update_date;
      END IF;
      IF (x_okl_answer_sets_tl_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_okl_answer_sets_tl_rec.last_update_login := l_okl_answer_sets_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_ANSWER_SETS_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_answer_sets_tl_rec IN  okl_answer_sets_tl_rec_type,
      x_okl_answer_sets_tl_rec OUT NOCOPY okl_answer_sets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_answer_sets_tl_rec := p_okl_answer_sets_tl_rec;
      x_okl_answer_sets_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_answer_sets_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_answer_sets_tl_rec,          -- IN
      l_okl_answer_sets_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_answer_sets_tl_rec, l_def_okl_answer_sets_tl_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ANSWER_SETS_TL
    SET NAME = l_def_okl_answer_sets_tl_rec.name,
        DESCRIPTION = l_def_okl_answer_sets_tl_rec.description,
        CREATED_BY = l_def_okl_answer_sets_tl_rec.created_by,
        CREATION_DATE = l_def_okl_answer_sets_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_answer_sets_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_answer_sets_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_answer_sets_tl_rec.last_update_login
    WHERE ID = l_def_okl_answer_sets_tl_rec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_ANSWER_SETS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_answer_sets_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_answer_sets_tl_rec := l_def_okl_answer_sets_tl_rec;
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
  --------------------------------------
  -- update_row for:OKL_ANSWER_SETS_V --
  --------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_antv_rec                     IN antv_rec_type,
    x_antv_rec                     OUT NOCOPY antv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_antv_rec                     antv_rec_type := p_antv_rec;
    l_def_antv_rec                 antv_rec_type;
    l_okl_answer_sets_tl_rec       okl_answer_sets_tl_rec_type;
    lx_okl_answer_sets_tl_rec      okl_answer_sets_tl_rec_type;
    l_ant_rec                      ant_rec_type;
    lx_ant_rec                     ant_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_antv_rec	IN antv_rec_type
    ) RETURN antv_rec_type IS
      l_antv_rec	antv_rec_type := p_antv_rec;
    BEGIN
      l_antv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_antv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_antv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_antv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_antv_rec	IN antv_rec_type,
      x_antv_rec	OUT NOCOPY antv_rec_type
    ) RETURN VARCHAR2 IS
      l_antv_rec                     antv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_antv_rec := p_antv_rec;
      -- Get current database values
      l_antv_rec := get_rec(p_antv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_antv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_antv_rec.id := l_antv_rec.id;
      END IF;
      IF (x_antv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_antv_rec.object_version_number := l_antv_rec.object_version_number;
      END IF;
      IF (x_antv_rec.sfwt_flag = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.sfwt_flag := l_antv_rec.sfwt_flag;
      END IF;
      IF (x_antv_rec.qty_id = okl_api.G_MISS_NUM)
      THEN
        x_antv_rec.qty_id := l_antv_rec.qty_id;
      END IF;
      IF (x_antv_rec.name = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.name := l_antv_rec.name;
      END IF;
      IF (x_antv_rec.description = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.description := l_antv_rec.description;
      END IF;
      IF (x_antv_rec.context_org = okl_api.G_MISS_NUM)
      THEN
        x_antv_rec.context_org := l_antv_rec.context_org;
      END IF;
      IF (x_antv_rec.context_inv_org = okl_api.G_MISS_NUM)
      THEN
        x_antv_rec.context_inv_org := l_antv_rec.context_inv_org;
      END IF;
      IF (x_antv_rec.context_asset_book = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.context_asset_book := l_antv_rec.context_asset_book;
      END IF;
      IF (x_antv_rec.context_intent = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.context_intent := l_antv_rec.context_intent;
      END IF;
      IF (x_antv_rec.start_date = okl_api.G_MISS_DATE)
      THEN
        x_antv_rec.start_date := l_antv_rec.start_date;
      END IF;
      IF (x_antv_rec.end_date = okl_api.G_MISS_DATE)
      THEN
        x_antv_rec.end_date := l_antv_rec.end_date;
      END IF;
      IF (x_antv_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute_category := l_antv_rec.attribute_category;
      END IF;
      IF (x_antv_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute1 := l_antv_rec.attribute1;
      END IF;
      IF (x_antv_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute2 := l_antv_rec.attribute2;
      END IF;
      IF (x_antv_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute3 := l_antv_rec.attribute3;
      END IF;
      IF (x_antv_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute4 := l_antv_rec.attribute4;
      END IF;
      IF (x_antv_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute5 := l_antv_rec.attribute5;
      END IF;
      IF (x_antv_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute6 := l_antv_rec.attribute6;
      END IF;
      IF (x_antv_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute7 := l_antv_rec.attribute7;
      END IF;
      IF (x_antv_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute8 := l_antv_rec.attribute8;
      END IF;
      IF (x_antv_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute9 := l_antv_rec.attribute9;
      END IF;
      IF (x_antv_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute10 := l_antv_rec.attribute10;
      END IF;
      IF (x_antv_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute11 := l_antv_rec.attribute11;
      END IF;
      IF (x_antv_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute12 := l_antv_rec.attribute12;
      END IF;
      IF (x_antv_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute13 := l_antv_rec.attribute13;
      END IF;
      IF (x_antv_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute14 := l_antv_rec.attribute14;
      END IF;
      IF (x_antv_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_antv_rec.attribute15 := l_antv_rec.attribute15;
      END IF;
      IF (x_antv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_antv_rec.created_by := l_antv_rec.created_by;
      END IF;
      IF (x_antv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_antv_rec.creation_date := l_antv_rec.creation_date;
      END IF;
      IF (x_antv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_antv_rec.last_updated_by := l_antv_rec.last_updated_by;
      END IF;
      IF (x_antv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_antv_rec.last_update_date := l_antv_rec.last_update_date;
      END IF;
      IF (x_antv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_antv_rec.last_update_login := l_antv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_ANSWER_SETS_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_antv_rec IN  antv_rec_type,
      x_antv_rec OUT NOCOPY antv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_antv_rec := p_antv_rec;
      x_antv_rec.OBJECT_VERSION_NUMBER := NVL(x_antv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_antv_rec,                        -- IN
      l_antv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_antv_rec, l_def_antv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_antv_rec := fill_who_columns(l_def_antv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_antv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_antv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_antv_rec, l_okl_answer_sets_tl_rec);
    migrate(l_def_antv_rec, l_ant_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_answer_sets_tl_rec,
      lx_okl_answer_sets_tl_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_answer_sets_tl_rec, l_def_antv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ant_rec,
      lx_ant_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ant_rec, l_def_antv_rec);
    x_antv_rec := l_def_antv_rec;
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
  -- PL/SQL TBL update_row for:ANTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_antv_tbl                     IN antv_tbl_type,
    x_antv_tbl                     OUT NOCOPY antv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_antv_tbl.COUNT > 0) THEN
      i := p_antv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_antv_rec                     => p_antv_tbl(i),
          x_antv_rec                     => x_antv_tbl(i));
        EXIT WHEN (i = p_antv_tbl.LAST);
        i := p_antv_tbl.NEXT(i);
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
  --------------------------------------
  -- delete_row for:OKL_ANSWER_SETS_B --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ant_rec                      IN ant_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ant_rec                      ant_rec_type:= p_ant_rec;
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
    DELETE FROM OKL_ANSWER_SETS_B
     WHERE ID = l_ant_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKL_ANSWER_SETS_TL --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_answer_sets_tl_rec       IN okl_answer_sets_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_okl_answer_sets_tl_rec       okl_answer_sets_tl_rec_type:= p_okl_answer_sets_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -------------------------------------------
    -- Set_Attributes for:OKL_ANSWER_SETS_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_answer_sets_tl_rec IN  okl_answer_sets_tl_rec_type,
      x_okl_answer_sets_tl_rec OUT NOCOPY okl_answer_sets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_answer_sets_tl_rec := p_okl_answer_sets_tl_rec;
      x_okl_answer_sets_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_answer_sets_tl_rec,          -- IN
      l_okl_answer_sets_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_ANSWER_SETS_TL
     WHERE ID = l_okl_answer_sets_tl_rec.id;

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
  --------------------------------------
  -- delete_row for:OKL_ANSWER_SETS_V --
  --------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_antv_rec                     IN antv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_antv_rec                     antv_rec_type := p_antv_rec;
    l_okl_answer_sets_tl_rec       okl_answer_sets_tl_rec_type;
    l_ant_rec                      ant_rec_type;
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
    migrate(l_antv_rec, l_okl_answer_sets_tl_rec);
    migrate(l_antv_rec, l_ant_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_answer_sets_tl_rec
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
      l_ant_rec
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
  -- PL/SQL TBL delete_row for:ANTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_antv_tbl                     IN antv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_antv_tbl.COUNT > 0) THEN
      i := p_antv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_antv_rec                     => p_antv_tbl(i));
        EXIT WHEN (i = p_antv_tbl.LAST);
        i := p_antv_tbl.NEXT(i);
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
END Okl_Ant_Pvt;

/
