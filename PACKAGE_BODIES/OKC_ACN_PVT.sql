--------------------------------------------------------
--  DDL for Package Body OKC_ACN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ACN_PVT" AS
/* $Header: OKCSACNB.pls 120.0 2005/05/25 19:35:32 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  l_lang       VARCHAR2(12) := okc_util.get_userenv_lang;
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
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

    DELETE FROM OKC_ACTIONS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_ACTIONS_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_ACTIONS_TL T SET (
        NAME,
        DESCRIPTION,
        SHORT_DESCRIPTION,
        COMMENTS) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION,
                                  B.SHORT_DESCRIPTION,
                                  B.COMMENTS
                                FROM OKC_ACTIONS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_ACTIONS_TL SUBB, OKC_ACTIONS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      OR SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));
*/

    INSERT INTO OKC_ACTIONS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
        DESCRIPTION,
        SHORT_DESCRIPTION,
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
            B.NAME,
            B.DESCRIPTION,
            B.SHORT_DESCRIPTION,
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_ACTIONS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_ACTIONS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ACTIONS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_acn_rec                      IN acn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN acn_rec_type IS
    CURSOR okc_actions_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CORRELATION,
            ENABLED_YN,
            FACTORY_ENABLED_YN,
            ACN_TYPE,
            COUNTER_ACTION_YN,
            SYNC_ALLOWED_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
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
            APPLICATION_ID,
            SEEDED_FLAG
      FROM Okc_Actions_B
     WHERE okc_actions_b.id     = p_id;
    l_okc_actions_b_pk             okc_actions_b_pk_csr%ROWTYPE;
    l_acn_rec                      acn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_actions_b_pk_csr (p_acn_rec.id);
    FETCH okc_actions_b_pk_csr INTO
              l_acn_rec.ID,
              l_acn_rec.CORRELATION,
              l_acn_rec.ENABLED_YN,
              l_acn_rec.FACTORY_ENABLED_YN,
              l_acn_rec.ACN_TYPE,
              l_acn_rec.COUNTER_ACTION_YN,
              l_acn_rec.SYNC_ALLOWED_YN,
              l_acn_rec.OBJECT_VERSION_NUMBER,
              l_acn_rec.CREATED_BY,
              l_acn_rec.CREATION_DATE,
              l_acn_rec.LAST_UPDATED_BY,
              l_acn_rec.LAST_UPDATE_DATE,
              l_acn_rec.LAST_UPDATE_LOGIN,
              l_acn_rec.ATTRIBUTE_CATEGORY,
              l_acn_rec.ATTRIBUTE1,
              l_acn_rec.ATTRIBUTE2,
              l_acn_rec.ATTRIBUTE3,
              l_acn_rec.ATTRIBUTE4,
              l_acn_rec.ATTRIBUTE5,
              l_acn_rec.ATTRIBUTE6,
              l_acn_rec.ATTRIBUTE7,
              l_acn_rec.ATTRIBUTE8,
              l_acn_rec.ATTRIBUTE9,
              l_acn_rec.ATTRIBUTE10,
              l_acn_rec.ATTRIBUTE11,
              l_acn_rec.ATTRIBUTE12,
              l_acn_rec.ATTRIBUTE13,
              l_acn_rec.ATTRIBUTE14,
              l_acn_rec.ATTRIBUTE15,
              l_acn_rec.APPLICATION_ID,
              l_acn_rec.SEEDED_FLAG;
    x_no_data_found := okc_actions_b_pk_csr%NOTFOUND;
    CLOSE okc_actions_b_pk_csr;
    RETURN(l_acn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_acn_rec                      IN acn_rec_type
  ) RETURN acn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_acn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ACTIONS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_actions_tl_rec           IN okc_actions_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_actions_tl_rec_type IS
    CURSOR okc_actions_tl_pk_csr (p_id                 IN NUMBER,
                                  p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Actions_Tl
     WHERE okc_actions_tl.id    = p_id
       AND okc_actions_tl.language = p_language;
    l_okc_actions_tl_pk            okc_actions_tl_pk_csr%ROWTYPE;
    l_okc_actions_tl_rec           okc_actions_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_actions_tl_pk_csr (p_okc_actions_tl_rec.id,
                                p_okc_actions_tl_rec.language);
    FETCH okc_actions_tl_pk_csr INTO
              l_okc_actions_tl_rec.ID,
              l_okc_actions_tl_rec.LANGUAGE,
              l_okc_actions_tl_rec.SOURCE_LANG,
              l_okc_actions_tl_rec.SFWT_FLAG,
              l_okc_actions_tl_rec.NAME,
              l_okc_actions_tl_rec.DESCRIPTION,
              l_okc_actions_tl_rec.SHORT_DESCRIPTION,
              l_okc_actions_tl_rec.COMMENTS,
              l_okc_actions_tl_rec.CREATED_BY,
              l_okc_actions_tl_rec.CREATION_DATE,
              l_okc_actions_tl_rec.LAST_UPDATED_BY,
              l_okc_actions_tl_rec.LAST_UPDATE_DATE,
              l_okc_actions_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_actions_tl_pk_csr%NOTFOUND;
    CLOSE okc_actions_tl_pk_csr;
    RETURN(l_okc_actions_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_actions_tl_rec           IN okc_actions_tl_rec_type
  ) RETURN okc_actions_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_actions_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ACTIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_acnv_rec                     IN acnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN acnv_rec_type IS
    CURSOR okc_acnv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CORRELATION,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            COMMENTS,
            ENABLED_YN,
            FACTORY_ENABLED_YN,
            COUNTER_ACTION_YN,
            ACN_TYPE,
            SYNC_ALLOWED_YN,
            APPLICATION_ID,
            SEEDED_FLAG,
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
      FROM Okc_Actions_V
     WHERE okc_actions_v.id     = p_id;
    l_okc_acnv_pk                  okc_acnv_pk_csr%ROWTYPE;
    l_acnv_rec                     acnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_acnv_pk_csr (p_acnv_rec.id);
    FETCH okc_acnv_pk_csr INTO
              l_acnv_rec.ID,
              l_acnv_rec.CORRELATION,
              l_acnv_rec.OBJECT_VERSION_NUMBER,
              l_acnv_rec.SFWT_FLAG,
              l_acnv_rec.NAME,
              l_acnv_rec.DESCRIPTION,
              l_acnv_rec.SHORT_DESCRIPTION,
              l_acnv_rec.COMMENTS,
              l_acnv_rec.ENABLED_YN,
              l_acnv_rec.FACTORY_ENABLED_YN,
              l_acnv_rec.COUNTER_ACTION_YN,
              l_acnv_rec.ACN_TYPE,
              l_acnv_rec.SYNC_ALLOWED_YN,
              l_acnv_rec.APPLICATION_ID,
              l_acnv_rec.SEEDED_FLAG,
              l_acnv_rec.ATTRIBUTE_CATEGORY,
              l_acnv_rec.ATTRIBUTE1,
              l_acnv_rec.ATTRIBUTE2,
              l_acnv_rec.ATTRIBUTE3,
              l_acnv_rec.ATTRIBUTE4,
              l_acnv_rec.ATTRIBUTE5,
              l_acnv_rec.ATTRIBUTE6,
              l_acnv_rec.ATTRIBUTE7,
              l_acnv_rec.ATTRIBUTE8,
              l_acnv_rec.ATTRIBUTE9,
              l_acnv_rec.ATTRIBUTE10,
              l_acnv_rec.ATTRIBUTE11,
              l_acnv_rec.ATTRIBUTE12,
              l_acnv_rec.ATTRIBUTE13,
              l_acnv_rec.ATTRIBUTE14,
              l_acnv_rec.ATTRIBUTE15,
              l_acnv_rec.CREATED_BY,
              l_acnv_rec.CREATION_DATE,
              l_acnv_rec.LAST_UPDATED_BY,
              l_acnv_rec.LAST_UPDATE_DATE,
              l_acnv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_acnv_pk_csr%NOTFOUND;
    CLOSE okc_acnv_pk_csr;
    RETURN(l_acnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_acnv_rec                     IN acnv_rec_type
  ) RETURN acnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_acnv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_ACTIONS_V --
  ---------------------------------------------------
  FUNCTION null_out_defaults (
    p_acnv_rec	IN acnv_rec_type
  ) RETURN acnv_rec_type IS
    l_acnv_rec	acnv_rec_type := p_acnv_rec;
  BEGIN
    IF (l_acnv_rec.correlation = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.correlation := NULL;
    END IF;
    IF (l_acnv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.object_version_number := NULL;
    END IF;
    IF (l_acnv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_acnv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.name := NULL;
    END IF;
    IF (l_acnv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.description := NULL;
    END IF;
    IF (l_acnv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.short_description := NULL;
    END IF;
    IF (l_acnv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.comments := NULL;
    END IF;
    IF (l_acnv_rec.enabled_yn = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.enabled_yn := NULL;
    END IF;
    IF (l_acnv_rec.factory_enabled_yn = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.factory_enabled_yn := NULL;
    END IF;
    IF (l_acnv_rec.counter_action_yn = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.counter_action_yn := NULL;
    END IF;
    IF (l_acnv_rec.acn_type = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.acn_type := NULL;
    END IF;
    IF (l_acnv_rec.sync_allowed_yn = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.sync_allowed_yn := NULL;
    END IF;
    IF (l_acnv_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.application_id := NULL;
    END IF;
    IF (l_acnv_rec.seeded_flag = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.seeded_flag := NULL;
    END IF;
    IF (l_acnv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute_category := NULL;
    END IF;
    IF (l_acnv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute1 := NULL;
    END IF;
    IF (l_acnv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute2 := NULL;
    END IF;
    IF (l_acnv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute3 := NULL;
    END IF;
    IF (l_acnv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute4 := NULL;
    END IF;
    IF (l_acnv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute5 := NULL;
    END IF;
    IF (l_acnv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute6 := NULL;
    END IF;
    IF (l_acnv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute7 := NULL;
    END IF;
    IF (l_acnv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute8 := NULL;
    END IF;
    IF (l_acnv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute9 := NULL;
    END IF;
    IF (l_acnv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute10 := NULL;
    END IF;
    IF (l_acnv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute11 := NULL;
    END IF;
    IF (l_acnv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute12 := NULL;
    END IF;
    IF (l_acnv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute13 := NULL;
    END IF;
    IF (l_acnv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute14 := NULL;
    END IF;
    IF (l_acnv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_acnv_rec.attribute15 := NULL;
    END IF;
    IF (l_acnv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.created_by := NULL;
    END IF;
    IF (l_acnv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_acnv_rec.creation_date := NULL;
    END IF;
    IF (l_acnv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_acnv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_acnv_rec.last_update_date := NULL;
    END IF;
    IF (l_acnv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_acnv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_acnv_rec);
  END null_out_defaults;

  /********** Commented out nocopy generated code in favor of hand written code ***
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Attributes for:OKC_ACTIONS_V --
  -------------------------------------------
  FUNCTION Validate_Attributes (
    p_acnv_rec IN  acnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_acnv_rec.id = OKC_API.G_MISS_NUM OR
       p_acnv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_acnv_rec.correlation = OKC_API.G_MISS_CHAR OR
          p_acnv_rec.correlation IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'correlation');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_acnv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_acnv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_acnv_rec.name = OKC_API.G_MISS_CHAR OR
          p_acnv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_acnv_rec.enabled_yn = OKC_API.G_MISS_CHAR OR
          p_acnv_rec.enabled_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'enabled_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_acnv_rec.factory_enabled_yn = OKC_API.G_MISS_CHAR OR
          p_acnv_rec.factory_enabled_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'factory_enabled_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_acnv_rec.counter_action_yn = OKC_API.G_MISS_CHAR OR
          p_acnv_rec.counter_action_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'counter_action_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_acnv_rec.acn_type = OKC_API.G_MISS_CHAR OR
          p_acnv_rec.acn_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'acn_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_acnv_rec.sync_allowed_yn = OKC_API.G_MISS_CHAR OR
          p_acnv_rec.sync_allowed_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sync_allowed_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  ******************* End Commented out nocopy Generated Code *********************/

  /************************ BEGIN HAND-CODED *******************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Correlation
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Correlation
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Correlation(x_return_status OUT NOCOPY     VARCHAR2
                                ,p_acnv_rec      IN      acnv_rec_type)
  IS

  CURSOR l_unq_cur(p_correlation VARCHAR2) IS
	    SELECT id FROM OKC_ACTIONS_V
	    WHERE correlation = p_correlation;

  l_id                    NUMBER       := OKC_API.G_MISS_NUM;
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_temp                  NUMBER       ;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_acnv_rec.correlation IS NULL) OR
       (p_acnv_rec.correlation = OKC_API.G_MISS_CHAR)
    THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    --check uniqueness
    --bug 1699203 - removed check_unique

    OPEN l_unq_cur(p_acnv_rec.correlation);
    FETCH l_unq_cur INTO l_id;
    CLOSE l_unq_cur;
    IF (l_id <> OKC_API.G_MISS_NUM AND l_id <> nvl(p_acnv_rec.id,0)) THEN
	  x_return_status := OKC_API.G_RET_STS_ERROR;
	  OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
					  p_msg_name => 'OKC_DUP_CORRELATION_NAME');
    END IF;

/*
    OKC_UTIL.CHECK_UNIQUE(p_view_name    => 'OKC_ACTIONS_V'
                         ,p_col_name      => 'correlation'
                         ,p_col_value     => p_acnv_rec.correlation
                         ,p_id            => p_acnv_rec.id
                         ,x_return_status => l_return_status);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
    -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
    -- verify that data is in uppercase
    IF (p_acnv_rec.correlation) <> UPPER(p_acnv_rec.correlation) THEN
       OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                          ,p_msg_name        => g_uppercase_required
                          ,p_token1          => g_col_name_token
                          ,p_token1_value    => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check that correlation should not contain the special characters
    l_temp := INSTR(p_acnv_rec.correlation,'<');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,'>');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,'?');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,'[');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,']');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,'/');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,'#');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,'.');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,'=');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,'!');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,'(');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,')');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_acnv_rec.correlation,',');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'correlation');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
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

  END Validate_Correlation;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY   VARCHAR2
                                          ,p_acnv_rec      IN    acnv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_acnv_rec.object_version_number IS NULL) OR
       (p_acnv_rec.object_version_number = OKC_API.G_MISS_NUM)
    THEN
      OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'object_version_number');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
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

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sfwt_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sfwt_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sfwt_Flag(x_return_status OUT NOCOPY     VARCHAR2
                              ,p_acnv_rec      IN      acnv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_acnv_rec.sfwt_flag IS NULL) OR
       (p_acnv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'sfwt_flag');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if sfwt_flag is in uppercase
   IF (p_acnv_rec.sfwt_flag) <> UPPER(p_acnv_rec.sfwt_flag) THEN
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                          ,p_msg_name         => g_uppercase_required
                          ,p_token1           => g_col_name_token
                          ,p_token1_value     => 'sfwt_flag');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_acnv_rec.sfwt_flag) NOT IN ('Y','N')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'sfwt_flag');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
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

  END Validate_Sfwt_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Seeded_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Seeded_Flag
  -- Description     : Checks if column SEEDED_FLAG is 'Y' or 'N' only
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE validate_seeded_flag(
    	x_return_status 	OUT NOCOPY VARCHAR2,
    	p_acnv_rec              IN acnv_rec_type) IS
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	-- Check if seeded_flag is Y or N
	IF UPPER(p_acnv_rec.seeded_flag) NOT IN ('Y', 'N') THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	IF p_acnv_rec.seeded_flag <> UPPER(p_acnv_rec.seeded_flag) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_uppercase_required,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_seeded_flag;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Application_id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Application_id
  -- Description     : Checks id application id exists in fnd_application
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE validate_application_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
    	p_acnv_rec          IN acnv_rec_type) IS
	Cursor application_id_cur(p_application_id IN NUMBER) IS
	select '1'
	from fnd_application
	where application_id = p_application_id;
	l_dummy		VARCHAR2(1) := '?';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_acnv_rec.application_id IS NOT NULL THEN
	--Check if application id exists in the fnd_application or not
	OPEN application_id_cur(p_acnv_rec.application_id);
	FETCH application_id_cur INTO l_dummy;
	CLOSE application_id_cur ;
	IF l_dummy = '?' THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'application_id');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
     END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_application_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Name(x_return_status OUT NOCOPY     VARCHAR2
                         ,p_acnv_rec      IN      acnv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_acnv_rec.name is not null) AND
       (p_acnv_rec.name <> OKC_API.G_MISS_CHAR) THEN

    -- check uniqueness

    OKC_UTIL.CHECK_UNIQUE(p_view_name     => 'OKC_ACTIONS_V'
                         ,p_col_name      => 'name'
                         ,p_col_value     => p_acnv_rec.name
                         ,p_id            => p_acnv_rec.id
                         ,x_return_status => l_return_status);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
    -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
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

  END Validate_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sync_Allowed_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sync_Allowed_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sync_Allowed_YN(x_return_status OUT NOCOPY     VARCHAR2
                                    ,p_acnv_rec      IN      acnv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_acnv_rec.sync_allowed_yn IS NULL) OR
       (p_acnv_rec.sync_allowed_yn = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       =>  g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'sync_allowed_yn');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- check if Sync_Allowed_YN is in uppercase
    IF (p_acnv_rec.sync_allowed_yn) <> UPPER(p_acnv_rec.sync_allowed_yn) THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'sync_allowed_yn');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_acnv_rec.sync_allowed_yn) NOT IN ('Y','N')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'sync_allowed_yn');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with next column
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

  END Validate_Sync_Allowed_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Counter_Action_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Counter_Action_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Counter_Action_YN(x_return_status OUT NOCOPY     VARCHAR2
                                      ,p_acnv_rec      IN      acnv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_acnv_rec.counter_action_yn IS NULL) OR
       (p_acnv_rec.counter_action_yn = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       =>  g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'counter_action_yn');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    -- check if counter_action_yn is 'Y' then acn_type cannot be date based action
    ELSIF (p_acnv_rec.counter_action_yn = 'Y' ) AND
		(p_acnv_rec.acn_type = 'DBA' )
    THEN
      OKC_API.SET_MESSAGE(p_app_name        =>  g_app_name
                         ,p_msg_name        =>  g_invalid_value
                         ,p_token1          =>  g_col_name_token
                         ,p_token1_value    =>  'counter_action_yn');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- check if Counter_Action_YN is in uppercase
    IF (p_acnv_rec.counter_action_yn) <> UPPER(p_acnv_rec.counter_action_yn) THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'counter_action_yn');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_acnv_rec.counter_action_yn) NOT IN ('Y','N')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'counter_action_yn');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with next column
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

  END Validate_Counter_Action_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Enabled_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Enabled_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Enabled_YN(x_return_status OUT NOCOPY     VARCHAR2
                               ,p_acnv_rec      IN      acnv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_acnv_rec.enabled_yn IS NULL) OR
       (p_acnv_rec.enabled_yn = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'enabled_yn');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if enabled_yn is in uppercase
    IF (p_acnv_rec.enabled_yn) <> UPPER(p_acnv_rec.enabled_yn) THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'enabled_yn');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_acnv_rec.enabled_yn) NOT IN ('Y','N')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'enabled_yn');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with next column
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

  END Validate_Enabled_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Factory_Enabled_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Factory_Enabled_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Factory_Enabled_YN(x_return_status OUT NOCOPY     VARCHAR2
                                       ,p_acnv_rec      IN      acnv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_acnv_rec.factory_enabled_yn IS NULL) OR
       (p_acnv_rec.factory_enabled_yn = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'factory_enabled_yn');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if factory_enabled_yn is in uppercase
    IF (p_acnv_rec.factory_enabled_yn) <> UPPER(p_acnv_rec.factory_enabled_yn)
    THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'factory_enabled_yn');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_acnv_rec.factory_enabled_yn) NOT IN ('Y','N')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'factory_enabled_yn');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with next column
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

  END Validate_Factory_Enabled_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Acn_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Acn_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Acn_Type(x_return_status OUT NOCOPY     VARCHAR2
                             ,p_acnv_rec      IN      acnv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_acnv_rec.acn_type IS NULL) OR
       (p_acnv_rec.acn_type = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'acn_type');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if acn_type is in uppercase
    IF (p_acnv_rec.acn_type) <> UPPER(p_acnv_rec.acn_type)
    THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'acn_type');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_acnv_rec.acn_type) NOT IN ('DBA','ABA')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'acn_type');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with next column
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

  END Validate_Acn_Type;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_acnv_rec IN  acnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    -- call each column-level validation

    -- Validate_Id
    IF p_acnv_rec.id = OKC_API.G_MISS_NUM OR
       p_acnv_rec.id IS NULL
    THEN
	  OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
       l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    -- Validate Correlation
    Validate_Correlation(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Object_Version_Number
    Validate_Object_Version_Number(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Sfwt_Flag
    Validate_Sfwt_Flag(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Seeded_Flag
    Validate_Seeded_Flag(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Application_Id
    Validate_Application_Id(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Name
    Validate_Name(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Enabled_YN
    Validate_Enabled_YN(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Sync_Allowed_YN
    Validate_Sync_Allowed_YN(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Counter_Action_YN
    Validate_Counter_Action_YN(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Factory_Enabled_YN
    Validate_Factory_Enabled_YN(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Acn_Type
    Validate_Acn_Type(x_return_status,p_acnv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;
       RETURN(l_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- just come out with return status
       NULL;
       RETURN (l_return_status);
    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

  /****************** END HAND-CODED ***************************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- Validate_Record for:OKC_ACTIONS_V --
  ---------------------------------------
  FUNCTION Validate_Record (
    p_acnv_rec IN acnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN acnv_rec_type,
    p_to	OUT NOCOPY acn_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.correlation := p_from.correlation;
    p_to.enabled_yn := p_from.enabled_yn;
    p_to.factory_enabled_yn := p_from.factory_enabled_yn;
    p_to.acn_type := p_from.acn_type;
    p_to.counter_action_yn := p_from.counter_action_yn;
    p_to.sync_allowed_yn := p_from.sync_allowed_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
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
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
  END migrate;
  PROCEDURE migrate (
    p_from	IN acn_rec_type,
    p_to	IN OUT NOCOPY acnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.correlation := p_from.correlation;
    p_to.enabled_yn := p_from.enabled_yn;
    p_to.factory_enabled_yn := p_from.factory_enabled_yn;
    p_to.acn_type := p_from.acn_type;
    p_to.counter_action_yn := p_from.counter_action_yn;
    p_to.sync_allowed_yn := p_from.sync_allowed_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
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
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
  END migrate;
  PROCEDURE migrate (
    p_from	IN acnv_rec_type,
    p_to	OUT NOCOPY okc_actions_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okc_actions_tl_rec_type,
    p_to	IN OUT NOCOPY acnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
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
  ------------------------------------
  -- validate_row for:OKC_ACTIONS_V --
  ------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec                     acnv_rec_type := p_acnv_rec;
    l_acn_rec                      acn_rec_type;
    l_okc_actions_tl_rec           okc_actions_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_acnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_acnv_rec);
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
  -- PL/SQL TBL validate_row for:ACNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_acnv_tbl.COUNT > 0) THEN
      i := p_acnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acnv_rec                     => p_acnv_tbl(i));
        EXIT WHEN (i = p_acnv_tbl.LAST);
        i := p_acnv_tbl.NEXT(i);
      END LOOP;
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
  ----------------------------------
  -- insert_row for:OKC_ACTIONS_B --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acn_rec                      IN acn_rec_type,
    x_acn_rec                      OUT NOCOPY acn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acn_rec                      acn_rec_type := p_acn_rec;
    l_def_acn_rec                  acn_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKC_ACTIONS_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_acn_rec IN  acn_rec_type,
      x_acn_rec OUT NOCOPY acn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acn_rec := p_acn_rec;
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
      p_acn_rec,                         -- IN
      l_acn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_ACTIONS_B(
        id,
        correlation,
        enabled_yn,
        factory_enabled_yn,
        acn_type,
        counter_action_yn,
        sync_allowed_yn,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
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
        application_id,
        seeded_flag)
      VALUES (
        l_acn_rec.id,
        l_acn_rec.correlation,
        l_acn_rec.enabled_yn,
        l_acn_rec.factory_enabled_yn,
        l_acn_rec.acn_type,
        l_acn_rec.counter_action_yn,
        l_acn_rec.sync_allowed_yn,
        l_acn_rec.object_version_number,
        l_acn_rec.created_by,
        l_acn_rec.creation_date,
        l_acn_rec.last_updated_by,
        l_acn_rec.last_update_date,
        l_acn_rec.last_update_login,
        l_acn_rec.attribute_category,
        l_acn_rec.attribute1,
        l_acn_rec.attribute2,
        l_acn_rec.attribute3,
        l_acn_rec.attribute4,
        l_acn_rec.attribute5,
        l_acn_rec.attribute6,
        l_acn_rec.attribute7,
        l_acn_rec.attribute8,
        l_acn_rec.attribute9,
        l_acn_rec.attribute10,
        l_acn_rec.attribute11,
        l_acn_rec.attribute12,
        l_acn_rec.attribute13,
        l_acn_rec.attribute14,
        l_acn_rec.attribute15,
        l_acn_rec.application_id,
        l_acn_rec.seeded_flag);
    -- Set OUT values
    x_acn_rec := l_acn_rec;
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
  -----------------------------------
  -- insert_row for:OKC_ACTIONS_TL --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_actions_tl_rec           IN okc_actions_tl_rec_type,
    x_okc_actions_tl_rec           OUT NOCOPY okc_actions_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_actions_tl_rec           okc_actions_tl_rec_type := p_okc_actions_tl_rec;
    l_def_okc_actions_tl_rec       okc_actions_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------
    -- Set_Attributes for:OKC_ACTIONS_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okc_actions_tl_rec IN  okc_actions_tl_rec_type,
      x_okc_actions_tl_rec OUT NOCOPY okc_actions_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_actions_tl_rec := p_okc_actions_tl_rec;
      x_okc_actions_tl_rec.LANGUAGE := l_lang;
      x_okc_actions_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_actions_tl_rec,              -- IN
      l_okc_actions_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_actions_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_ACTIONS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          name,
          description,
          short_description,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_actions_tl_rec.id,
          l_okc_actions_tl_rec.language,
          l_okc_actions_tl_rec.source_lang,
          l_okc_actions_tl_rec.sfwt_flag,
          l_okc_actions_tl_rec.name,
          l_okc_actions_tl_rec.description,
          l_okc_actions_tl_rec.short_description,
          l_okc_actions_tl_rec.comments,
          l_okc_actions_tl_rec.created_by,
          l_okc_actions_tl_rec.creation_date,
          l_okc_actions_tl_rec.last_updated_by,
          l_okc_actions_tl_rec.last_update_date,
          l_okc_actions_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_actions_tl_rec := l_okc_actions_tl_rec;
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
  ----------------------------------
  -- insert_row for:OKC_ACTIONS_V --
  ----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type) IS

    l_id                          NUMBER ;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec                     acnv_rec_type;
    l_def_acnv_rec                 acnv_rec_type;
    l_acn_rec                      acn_rec_type;
    lx_acn_rec                     acn_rec_type;
    l_okc_actions_tl_rec           okc_actions_tl_rec_type;
    lx_okc_actions_tl_rec          okc_actions_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_acnv_rec	IN acnv_rec_type
    ) RETURN acnv_rec_type IS
      l_acnv_rec	acnv_rec_type := p_acnv_rec;
    BEGIN
      l_acnv_rec.CREATION_DATE := SYSDATE;
      l_acnv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_acnv_rec.LAST_UPDATE_DATE := l_acnv_rec.CREATION_DATE;
      l_acnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_acnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_acnv_rec);
    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKC_ACTIONS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_acnv_rec IN  acnv_rec_type,
      x_acnv_rec OUT NOCOPY acnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acnv_rec := p_acnv_rec;
      x_acnv_rec.OBJECT_VERSION_NUMBER := 1;
      x_acnv_rec.SFWT_FLAG := 'N';
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
    l_acnv_rec := null_out_defaults(p_acnv_rec);
    -- Set primary key value
    -- If action is created by seed then use sequence generated id
    IF l_acnv_rec.CREATED_BY = 1 THEN
	  SELECT OKC_ACTIONS_S1.nextval INTO l_id FROM dual;
	  l_acnv_rec.ID := l_id;
	  l_acnv_rec.seeded_flag := 'Y';
    ELSE
	  l_acnv_rec.ID := get_seq_id;
	  l_acnv_rec.seeded_flag := 'N';
    END IF;

    --l_acnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_acnv_rec,                        -- IN
      l_def_acnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_acnv_rec := fill_who_columns(l_def_acnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_acnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_acnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_acnv_rec, l_acn_rec);
    migrate(l_def_acnv_rec, l_okc_actions_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_acn_rec,
      lx_acn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_acn_rec, l_def_acnv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_actions_tl_rec,
      lx_okc_actions_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_actions_tl_rec, l_def_acnv_rec);
    -- Set OUT values
    x_acnv_rec := l_def_acnv_rec;
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
  -- PL/SQL TBL insert_row for:ACNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_acnv_tbl.COUNT > 0) THEN
      i := p_acnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acnv_rec                     => p_acnv_tbl(i),
          x_acnv_rec                     => x_acnv_tbl(i));
        EXIT WHEN (i = p_acnv_tbl.LAST);
        i := p_acnv_tbl.NEXT(i);
      END LOOP;
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
  --------------------------------
  -- lock_row for:OKC_ACTIONS_B --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acn_rec                      IN acn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_acn_rec IN acn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ACTIONS_B
     WHERE ID = p_acn_rec.id
       AND OBJECT_VERSION_NUMBER = p_acn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_acn_rec IN acn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ACTIONS_B
    WHERE ID = p_acn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_ACTIONS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_ACTIONS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_acn_rec);
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
      OPEN lchk_csr(p_acn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_acn_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_acn_rec.object_version_number THEN
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
  ---------------------------------
  -- lock_row for:OKC_ACTIONS_TL --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_actions_tl_rec           IN okc_actions_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_actions_tl_rec IN okc_actions_tl_rec_type) IS
    SELECT *
      FROM OKC_ACTIONS_TL
     WHERE ID = p_okc_actions_tl_rec.id
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
      OPEN lock_csr(p_okc_actions_tl_rec);
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
  --------------------------------
  -- lock_row for:OKC_ACTIONS_V --
  --------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acn_rec                      acn_rec_type;
    l_okc_actions_tl_rec           okc_actions_tl_rec_type;
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
    migrate(p_acnv_rec, l_acn_rec);
    migrate(p_acnv_rec, l_okc_actions_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_acn_rec
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
      l_okc_actions_tl_rec
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
  -- PL/SQL TBL lock_row for:ACNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_acnv_tbl.COUNT > 0) THEN
      i := p_acnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acnv_rec                     => p_acnv_tbl(i));
        EXIT WHEN (i = p_acnv_tbl.LAST);
        i := p_acnv_tbl.NEXT(i);
      END LOOP;
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
  ----------------------------------
  -- update_row for:OKC_ACTIONS_B --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acn_rec                      IN acn_rec_type,
    x_acn_rec                      OUT NOCOPY acn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acn_rec                      acn_rec_type := p_acn_rec;
    l_def_acn_rec                  acn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_acn_rec	IN acn_rec_type,
      x_acn_rec	OUT NOCOPY acn_rec_type
    ) RETURN VARCHAR2 IS
      l_acn_rec                      acn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acn_rec := p_acn_rec;
      -- Get current database values
      l_acn_rec := get_rec(p_acn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_acn_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.id := l_acn_rec.id;
      END IF;
      IF (x_acn_rec.correlation = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.correlation := l_acn_rec.correlation;
      END IF;
      IF (x_acn_rec.enabled_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.enabled_yn := l_acn_rec.enabled_yn;
      END IF;
      IF (x_acn_rec.factory_enabled_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.factory_enabled_yn := l_acn_rec.factory_enabled_yn;
      END IF;
      IF (x_acn_rec.acn_type = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.acn_type := l_acn_rec.acn_type;
      END IF;
      IF (x_acn_rec.counter_action_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.counter_action_yn := l_acn_rec.counter_action_yn;
      END IF;
      IF (x_acn_rec.sync_allowed_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.sync_allowed_yn := l_acn_rec.sync_allowed_yn;
      END IF;
      IF (x_acn_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.object_version_number := l_acn_rec.object_version_number;
      END IF;
      IF (x_acn_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.created_by := l_acn_rec.created_by;
      END IF;
      IF (x_acn_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_acn_rec.creation_date := l_acn_rec.creation_date;
      END IF;
      IF (x_acn_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.last_updated_by := l_acn_rec.last_updated_by;
      END IF;
      IF (x_acn_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_acn_rec.last_update_date := l_acn_rec.last_update_date;
      END IF;
      IF (x_acn_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.last_update_login := l_acn_rec.last_update_login;
      END IF;
      IF (x_acn_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute_category := l_acn_rec.attribute_category;
      END IF;
      IF (x_acn_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute1 := l_acn_rec.attribute1;
      END IF;
      IF (x_acn_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute2 := l_acn_rec.attribute2;
      END IF;
      IF (x_acn_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute3 := l_acn_rec.attribute3;
      END IF;
      IF (x_acn_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute4 := l_acn_rec.attribute4;
      END IF;
      IF (x_acn_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute5 := l_acn_rec.attribute5;
      END IF;
      IF (x_acn_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute6 := l_acn_rec.attribute6;
      END IF;
      IF (x_acn_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute7 := l_acn_rec.attribute7;
      END IF;
      IF (x_acn_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute8 := l_acn_rec.attribute8;
      END IF;
      IF (x_acn_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute9 := l_acn_rec.attribute9;
      END IF;
      IF (x_acn_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute10 := l_acn_rec.attribute10;
      END IF;
      IF (x_acn_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute11 := l_acn_rec.attribute11;
      END IF;
      IF (x_acn_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute12 := l_acn_rec.attribute12;
      END IF;
      IF (x_acn_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute13 := l_acn_rec.attribute13;
      END IF;
      IF (x_acn_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute14 := l_acn_rec.attribute14;
      END IF;
      IF (x_acn_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.attribute15 := l_acn_rec.attribute15;
      END IF;
      IF (x_acn_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_acn_rec.application_id := l_acn_rec.application_id;
      END IF;
      IF (x_acn_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_acn_rec.seeded_flag := l_acn_rec.seeded_flag;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKC_ACTIONS_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_acn_rec IN  acn_rec_type,
      x_acn_rec OUT NOCOPY acn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acn_rec := p_acn_rec;
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
      p_acn_rec,                         -- IN
      l_acn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_acn_rec, l_def_acn_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_ACTIONS_B
    SET CORRELATION = l_def_acn_rec.correlation,
        ENABLED_YN = l_def_acn_rec.enabled_yn,
        FACTORY_ENABLED_YN = l_def_acn_rec.factory_enabled_yn,
        ACN_TYPE = l_def_acn_rec.acn_type,
        COUNTER_ACTION_YN = l_def_acn_rec.counter_action_yn,
        SYNC_ALLOWED_YN = l_def_acn_rec.sync_allowed_yn,
        OBJECT_VERSION_NUMBER = l_def_acn_rec.object_version_number,
        CREATED_BY = l_def_acn_rec.created_by,
        CREATION_DATE = l_def_acn_rec.creation_date,
        LAST_UPDATED_BY = l_def_acn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_acn_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_acn_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_acn_rec.attribute_category,
        ATTRIBUTE1 = l_def_acn_rec.attribute1,
        ATTRIBUTE2 = l_def_acn_rec.attribute2,
        ATTRIBUTE3 = l_def_acn_rec.attribute3,
        ATTRIBUTE4 = l_def_acn_rec.attribute4,
        ATTRIBUTE5 = l_def_acn_rec.attribute5,
        ATTRIBUTE6 = l_def_acn_rec.attribute6,
        ATTRIBUTE7 = l_def_acn_rec.attribute7,
        ATTRIBUTE8 = l_def_acn_rec.attribute8,
        ATTRIBUTE9 = l_def_acn_rec.attribute9,
        ATTRIBUTE10 = l_def_acn_rec.attribute10,
        ATTRIBUTE11 = l_def_acn_rec.attribute11,
        ATTRIBUTE12 = l_def_acn_rec.attribute12,
        ATTRIBUTE13 = l_def_acn_rec.attribute13,
        ATTRIBUTE14 = l_def_acn_rec.attribute14,
        ATTRIBUTE15 = l_def_acn_rec.attribute15,
        APPLICATION_ID = l_def_acn_rec.application_id,
        SEEDED_FLAG = l_def_acn_rec.seeded_flag
    WHERE ID = l_def_acn_rec.id;

    x_acn_rec := l_def_acn_rec;
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
  -----------------------------------
  -- update_row for:OKC_ACTIONS_TL --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_actions_tl_rec           IN okc_actions_tl_rec_type,
    x_okc_actions_tl_rec           OUT NOCOPY okc_actions_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_actions_tl_rec           okc_actions_tl_rec_type := p_okc_actions_tl_rec;
    l_def_okc_actions_tl_rec       okc_actions_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_actions_tl_rec	IN okc_actions_tl_rec_type,
      x_okc_actions_tl_rec	OUT NOCOPY okc_actions_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_actions_tl_rec           okc_actions_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_actions_tl_rec := p_okc_actions_tl_rec;
      -- Get current database values
      l_okc_actions_tl_rec := get_rec(p_okc_actions_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_actions_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_actions_tl_rec.id := l_okc_actions_tl_rec.id;
      END IF;
      IF (x_okc_actions_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_actions_tl_rec.language := l_okc_actions_tl_rec.language;
      END IF;
      IF (x_okc_actions_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_actions_tl_rec.source_lang := l_okc_actions_tl_rec.source_lang;
      END IF;
      IF (x_okc_actions_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_actions_tl_rec.sfwt_flag := l_okc_actions_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_actions_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_actions_tl_rec.name := l_okc_actions_tl_rec.name;
      END IF;
      IF (x_okc_actions_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_actions_tl_rec.description := l_okc_actions_tl_rec.description;
      END IF;
      IF (x_okc_actions_tl_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_actions_tl_rec.short_description := l_okc_actions_tl_rec.short_description;
      END IF;
      IF (x_okc_actions_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_actions_tl_rec.comments := l_okc_actions_tl_rec.comments;
      END IF;
      IF (x_okc_actions_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_actions_tl_rec.created_by := l_okc_actions_tl_rec.created_by;
      END IF;
      IF (x_okc_actions_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_actions_tl_rec.creation_date := l_okc_actions_tl_rec.creation_date;
      END IF;
      IF (x_okc_actions_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_actions_tl_rec.last_updated_by := l_okc_actions_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_actions_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_actions_tl_rec.last_update_date := l_okc_actions_tl_rec.last_update_date;
      END IF;
      IF (x_okc_actions_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_actions_tl_rec.last_update_login := l_okc_actions_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_ACTIONS_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okc_actions_tl_rec IN  okc_actions_tl_rec_type,
      x_okc_actions_tl_rec OUT NOCOPY okc_actions_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_actions_tl_rec := p_okc_actions_tl_rec;
      x_okc_actions_tl_rec.LANGUAGE := l_lang;
      x_okc_actions_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_actions_tl_rec,              -- IN
      l_okc_actions_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_actions_tl_rec, l_def_okc_actions_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_ACTIONS_TL
    SET NAME = l_def_okc_actions_tl_rec.name,
        DESCRIPTION = l_def_okc_actions_tl_rec.description,
        SOURCE_LANG = l_def_okc_actions_tl_rec.source_lang,
        SHORT_DESCRIPTION = l_def_okc_actions_tl_rec.short_description,
        COMMENTS = l_def_okc_actions_tl_rec.comments,
        CREATED_BY = l_def_okc_actions_tl_rec.created_by,
        CREATION_DATE = l_def_okc_actions_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_actions_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_actions_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_actions_tl_rec.last_update_login
    WHERE ID = l_def_okc_actions_tl_rec.id
      AND USERENV('LANG') IN (SOURCE_LANG,LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_ACTIONS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okc_actions_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_actions_tl_rec := l_def_okc_actions_tl_rec;
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
  ----------------------------------
  -- update_row for:OKC_ACTIONS_V --
  ----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec                     acnv_rec_type := p_acnv_rec;
    l_def_acnv_rec                 acnv_rec_type;
    l_okc_actions_tl_rec           okc_actions_tl_rec_type;
    lx_okc_actions_tl_rec          okc_actions_tl_rec_type;
    l_acn_rec                      acn_rec_type;
    lx_acn_rec                     acn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_acnv_rec	IN acnv_rec_type
    ) RETURN acnv_rec_type IS
      l_acnv_rec	acnv_rec_type := p_acnv_rec;
    BEGIN
      l_acnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_acnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_acnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_acnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_acnv_rec	IN acnv_rec_type,
      x_acnv_rec	OUT NOCOPY acnv_rec_type
    ) RETURN VARCHAR2 IS
      l_acnv_rec                     acnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acnv_rec := p_acnv_rec;
      -- Get current database values
      l_acnv_rec := get_rec(p_acnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_acnv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.id := l_acnv_rec.id;
      END IF;
      IF (x_acnv_rec.correlation = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.correlation := l_acnv_rec.correlation;
      END IF;
      IF (x_acnv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.object_version_number := l_acnv_rec.object_version_number;
      END IF;
      IF (x_acnv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.sfwt_flag := l_acnv_rec.sfwt_flag;
      END IF;
      IF (x_acnv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.name := l_acnv_rec.name;
      END IF;
      IF (x_acnv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.description := l_acnv_rec.description;
      END IF;
      IF (x_acnv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.short_description := l_acnv_rec.short_description;
      END IF;
      IF (x_acnv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.comments := l_acnv_rec.comments;
      END IF;
      IF (x_acnv_rec.enabled_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.enabled_yn := l_acnv_rec.enabled_yn;
      END IF;
      IF (x_acnv_rec.factory_enabled_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.factory_enabled_yn := l_acnv_rec.factory_enabled_yn;
      END IF;
      IF (x_acnv_rec.counter_action_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.counter_action_yn := l_acnv_rec.counter_action_yn;
      END IF;
      IF (x_acnv_rec.acn_type = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.acn_type := l_acnv_rec.acn_type;
      END IF;
      IF (x_acnv_rec.sync_allowed_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.sync_allowed_yn := l_acnv_rec.sync_allowed_yn;
      END IF;
      IF (x_acnv_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.application_id := l_acnv_rec.application_id;
      END IF;
      IF (x_acnv_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.seeded_flag := l_acnv_rec.seeded_flag;
      END IF;
      IF (x_acnv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute_category := l_acnv_rec.attribute_category;
      END IF;
      IF (x_acnv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute1 := l_acnv_rec.attribute1;
      END IF;
      IF (x_acnv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute2 := l_acnv_rec.attribute2;
      END IF;
      IF (x_acnv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute3 := l_acnv_rec.attribute3;
      END IF;
      IF (x_acnv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute4 := l_acnv_rec.attribute4;
      END IF;
      IF (x_acnv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute5 := l_acnv_rec.attribute5;
      END IF;
      IF (x_acnv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute6 := l_acnv_rec.attribute6;
      END IF;
      IF (x_acnv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute7 := l_acnv_rec.attribute7;
      END IF;
      IF (x_acnv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute8 := l_acnv_rec.attribute8;
      END IF;
      IF (x_acnv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute9 := l_acnv_rec.attribute9;
      END IF;
      IF (x_acnv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute10 := l_acnv_rec.attribute10;
      END IF;
      IF (x_acnv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute11 := l_acnv_rec.attribute11;
      END IF;
      IF (x_acnv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute12 := l_acnv_rec.attribute12;
      END IF;
      IF (x_acnv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute13 := l_acnv_rec.attribute13;
      END IF;
      IF (x_acnv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute14 := l_acnv_rec.attribute14;
      END IF;
      IF (x_acnv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_acnv_rec.attribute15 := l_acnv_rec.attribute15;
      END IF;
      IF (x_acnv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.created_by := l_acnv_rec.created_by;
      END IF;
      IF (x_acnv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_acnv_rec.creation_date := l_acnv_rec.creation_date;
      END IF;
      IF (x_acnv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.last_updated_by := l_acnv_rec.last_updated_by;
      END IF;
      IF (x_acnv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_acnv_rec.last_update_date := l_acnv_rec.last_update_date;
      END IF;
      IF (x_acnv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_acnv_rec.last_update_login := l_acnv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKC_ACTIONS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_acnv_rec IN  acnv_rec_type,
      x_acnv_rec OUT NOCOPY acnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acnv_rec := p_acnv_rec;
      x_acnv_rec.OBJECT_VERSION_NUMBER := NVL(x_acnv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    --  Seed data should not be updated
	   IF l_acnv_rec.last_updated_by <> 1 THEN
	   IF l_acnv_rec.seeded_flag = 'Y' THEN
	   IF x_acnv_rec.enabled_yn = l_acnv_rec.enabled_yn THEN
	   OKC_API.set_message(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
        RAISE OKC_API.G_EXCEPTION_ERROR;
	   END IF;
	   END IF;
	   END IF;
	   /*IF l_acnv_rec.created_by = 1 THEN
	   OKC_API.set_message(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
        RAISE OKC_API.G_EXCEPTION_ERROR;
	   END IF;*/
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_acnv_rec,                        -- IN
      l_acnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_acnv_rec, l_def_acnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_acnv_rec := fill_who_columns(l_def_acnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_acnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_acnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_acnv_rec, l_okc_actions_tl_rec);
    migrate(l_def_acnv_rec, l_acn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_actions_tl_rec,
      lx_okc_actions_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_actions_tl_rec, l_def_acnv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_acn_rec,
      lx_acn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_acn_rec, l_def_acnv_rec);
    x_acnv_rec := l_def_acnv_rec;
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
  -- PL/SQL TBL update_row for:ACNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_acnv_tbl.COUNT > 0) THEN
      i := p_acnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acnv_rec                     => p_acnv_tbl(i),
          x_acnv_rec                     => x_acnv_tbl(i));
        EXIT WHEN (i = p_acnv_tbl.LAST);
        i := p_acnv_tbl.NEXT(i);
      END LOOP;
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
  ----------------------------------
  -- delete_row for:OKC_ACTIONS_B --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acn_rec                      IN acn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acn_rec                      acn_rec_type:= p_acn_rec;
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
    DELETE FROM OKC_ACTIONS_B
     WHERE ID = l_acn_rec.id;

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
  -----------------------------------
  -- delete_row for:OKC_ACTIONS_TL --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_actions_tl_rec           IN okc_actions_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_actions_tl_rec           okc_actions_tl_rec_type:= p_okc_actions_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------
    -- Set_Attributes for:OKC_ACTIONS_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okc_actions_tl_rec IN  okc_actions_tl_rec_type,
      x_okc_actions_tl_rec OUT NOCOPY okc_actions_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_actions_tl_rec := p_okc_actions_tl_rec;
      x_okc_actions_tl_rec.LANGUAGE := l_lang;
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
      p_okc_actions_tl_rec,              -- IN
      l_okc_actions_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_ACTIONS_TL
     WHERE ID = l_okc_actions_tl_rec.id;

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
  ----------------------------------
  -- delete_row for:OKC_ACTIONS_V --
  ----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec                     acnv_rec_type := p_acnv_rec;
    l_okc_actions_tl_rec           okc_actions_tl_rec_type;
    l_acn_rec                      acn_rec_type;
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
    -- ** Seed data should not be deleted
    IF l_acnv_rec.last_updated_by <> 1 THEN
    IF l_acnv_rec.seeded_flag = 'Y' THEN
	  OKC_API.set_message(p_app_name => G_APP_NAME,
					  p_msg_name => 'OKC_NOT_DELETE_SEEDED');
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    /*IF l_acnv_rec.created_by = 1 THEN
	  OKC_API.set_message(p_app_name => G_APP_NAME,
					  p_msg_name => 'OKC_NOT_DELETE_SEEDED');
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;*/
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_acnv_rec, l_okc_actions_tl_rec);
    migrate(l_acnv_rec, l_acn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_actions_tl_rec
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
      l_acn_rec
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
  -- PL/SQL TBL delete_row for:ACNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_acnv_tbl.COUNT > 0) THEN
      i := p_acnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acnv_rec                     => p_acnv_tbl(i));
        EXIT WHEN (i = p_acnv_tbl.LAST);
        i := p_acnv_tbl.NEXT(i);
      END LOOP;
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
END OKC_ACN_PVT;

/
