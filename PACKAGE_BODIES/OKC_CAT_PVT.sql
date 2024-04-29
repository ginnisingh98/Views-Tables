--------------------------------------------------------
--  DDL for Package Body OKC_CAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CAT_PVT" AS
/* $Header: OKCSCATB.pls 120.0 2005/05/26 09:32:19 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
/*+++++++++++++Start of hand code +++++++++++++++++*/
G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
g_return_status                         varchar2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
/*+++++++++++++End of hand code +++++++++++++++++++*/
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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('500: Entered add_language', 2);
    END IF;

    DELETE FROM OKC_K_ARTICLES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_K_ARTICLES_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_K_ARTICLES_TL T SET (
        COMMENTS,
        VARIATION_DESCRIPTION,
        NAME,
        TEXT,
        SAV_SAV_RELEASE) = (SELECT
                                  B.COMMENTS,
                                  B.VARIATION_DESCRIPTION,
                                  B.NAME,
                                  B.TEXT,
                                  B.SAV_SAV_RELEASE
                                FROM OKC_K_ARTICLES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_K_ARTICLES_TL SUBB, OKC_K_ARTICLES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR SUBB.VARIATION_DESCRIPTION <> SUBT.VARIATION_DESCRIPTION
                      OR SUBB.NAME <> SUBT.NAME
-- Commented in favor of handcode
---                     OR SUBB.TEXT <> SUBT.TEXT
--+Hand code start
                      OR ( (SUBB.TEXT IS NOT NULL AND SUBT.TEXT IS NOT NULL)
				   AND (DBMS_LOB.COMPARE(SUBB.TEXT,SUBT.TEXT) <> 0))
--+Hand code end
                      OR SUBB.SAV_SAV_RELEASE <> SUBT.SAV_SAV_RELEASE
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
                      OR (SUBB.VARIATION_DESCRIPTION IS NULL AND SUBT.VARIATION_DESCRIPTION IS NOT NULL)
                      OR (SUBB.VARIATION_DESCRIPTION IS NOT NULL AND SUBT.VARIATION_DESCRIPTION IS NULL)
                      OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                      OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
                      OR (SUBB.TEXT IS NULL AND SUBT.TEXT IS NOT NULL)
                      OR (SUBB.TEXT IS NOT NULL AND SUBT.TEXT IS NULL)
                      OR (SUBB.SAV_SAV_RELEASE IS NULL AND SUBT.SAV_SAV_RELEASE IS NOT NULL)
                      OR (SUBB.SAV_SAV_RELEASE IS NOT NULL AND SUBT.SAV_SAV_RELEASE IS NULL)
              ));

    INSERT INTO OKC_K_ARTICLES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        OBJECT_VERSION_NUMBER,
        COMMENTS,
        VARIATION_DESCRIPTION,
        NAME,
        TEXT,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SAV_SAV_RELEASE)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.OBJECT_VERSION_NUMBER,
            B.COMMENTS,
            B.VARIATION_DESCRIPTION,
            B.NAME,
            B.TEXT,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN,
            B.SAV_SAV_RELEASE
        FROM OKC_K_ARTICLES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_K_ARTICLES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
DELETE FROM OKC_K_ARTICLES_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_K_ARTICLES_BH B
         WHERE B.ID = T.ID
         AND B.MAJOR_VERSION = T.MAJOR_VERSION
        );

    UPDATE OKC_K_ARTICLES_TLH T SET (
        COMMENTS,
        VARIATION_DESCRIPTION,
        NAME,
        TEXT,
        SAV_SAV_RELEASE) = (SELECT
                                  B.COMMENTS,
                                  B.VARIATION_DESCRIPTION,
                                  B.NAME,
                                  B.TEXT,
                                  B.SAV_SAV_RELEASE
                                FROM OKC_K_ARTICLES_TLH B
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
                FROM OKC_K_ARTICLES_TLH SUBB, OKC_K_ARTICLES_TLH SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR SUBB.VARIATION_DESCRIPTION <> SUBT.VARIATION_DESCRIPTION
                      OR SUBB.NAME <> SUBT.NAME
   OR ( (SUBB.TEXT IS NOT NULL AND SUBT.TEXT IS NOT NULL)
                                   AND (DBMS_LOB.COMPARE(SUBB.TEXT,SUBT.TEXT) <> 0))
                      OR SUBB.SAV_SAV_RELEASE <> SUBT.SAV_SAV_RELEASE
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
                      OR (SUBB.VARIATION_DESCRIPTION IS NULL AND SUBT.VARIATION_DESCRIPTION IS NOT NULL)
                      OR (SUBB.VARIATION_DESCRIPTION IS NOT NULL AND SUBT.VARIATION_DESCRIPTION IS NULL)
                      OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                      OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
                      OR (SUBB.TEXT IS NULL AND SUBT.TEXT IS NOT NULL)
                      OR (SUBB.TEXT IS NOT NULL AND SUBT.TEXT IS NULL)
                      OR (SUBB.SAV_SAV_RELEASE IS NULL AND SUBT.SAV_SAV_RELEASE IS NOT NULL)
                      OR (SUBB.SAV_SAV_RELEASE IS NOT NULL AND SUBT.SAV_SAV_RELEASE IS NULL)
              ));

    INSERT INTO OKC_K_ARTICLES_TLH (
        ID,
        LANGUAGE,
        MAJOR_VERSION,
        SOURCE_LANG,
        SFWT_FLAG,
        OBJECT_VERSION_NUMBER,
        COMMENTS,
        VARIATION_DESCRIPTION,
        NAME,
        TEXT,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SAV_SAV_RELEASE)
 SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.MAJOR_VERSION,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.OBJECT_VERSION_NUMBER,
            B.COMMENTS,
            B.VARIATION_DESCRIPTION,
            B.NAME,
            B.TEXT,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN,
            B.SAV_SAV_RELEASE
        FROM OKC_K_ARTICLES_TLH B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_K_ARTICLES_TLH T
                     WHERE T.ID = B.ID
                     AND T.MAJOR_VERSION = B.MAJOR_VERSION
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );


  IF (l_debug = 'Y') THEN
     okc_debug.log('600: Leaving  add_language ', 2);
     okc_debug.Reset_Indentation;
  END IF;

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_ARTICLES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cat_rec                      IN cat_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cat_rec_type IS
    CURSOR okc_k_articles_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SAV_SAE_ID,
            SBT_CODE,
            CAT_TYPE,
            CHR_ID,
            CLE_ID,
            CAT_ID,
            DNZ_CHR_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            FULLTEXT_YN,
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
            ATTRIBUTE15
      FROM Okc_K_Articles_B
     WHERE okc_k_articles_b.id  = p_id;
    l_okc_k_articles_b_pk          okc_k_articles_b_pk_csr%ROWTYPE;
    l_cat_rec                      cat_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('700: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_k_articles_b_pk_csr (p_cat_rec.id);
    FETCH okc_k_articles_b_pk_csr INTO
              l_cat_rec.ID,
              l_cat_rec.SAV_SAE_ID,
              l_cat_rec.SBT_CODE,
              l_cat_rec.CAT_TYPE,
              l_cat_rec.CHR_ID,
              l_cat_rec.CLE_ID,
              l_cat_rec.CAT_ID,
              l_cat_rec.DNZ_CHR_ID,
              l_cat_rec.OBJECT_VERSION_NUMBER,
              l_cat_rec.CREATED_BY,
              l_cat_rec.CREATION_DATE,
              l_cat_rec.LAST_UPDATED_BY,
              l_cat_rec.LAST_UPDATE_DATE,
              l_cat_rec.FULLTEXT_YN,
              l_cat_rec.LAST_UPDATE_LOGIN,
              l_cat_rec.ATTRIBUTE_CATEGORY,
              l_cat_rec.ATTRIBUTE1,
              l_cat_rec.ATTRIBUTE2,
              l_cat_rec.ATTRIBUTE3,
              l_cat_rec.ATTRIBUTE4,
              l_cat_rec.ATTRIBUTE5,
              l_cat_rec.ATTRIBUTE6,
              l_cat_rec.ATTRIBUTE7,
              l_cat_rec.ATTRIBUTE8,
              l_cat_rec.ATTRIBUTE9,
              l_cat_rec.ATTRIBUTE10,
              l_cat_rec.ATTRIBUTE11,
              l_cat_rec.ATTRIBUTE12,
              l_cat_rec.ATTRIBUTE13,
              l_cat_rec.ATTRIBUTE14,
              l_cat_rec.ATTRIBUTE15;
    x_no_data_found := okc_k_articles_b_pk_csr%NOTFOUND;
    CLOSE okc_k_articles_b_pk_csr;

   IF (l_debug = 'Y') THEN
      okc_debug.log('800: Leaving  get_rec ', 2);
      okc_debug.Reset_Indentation;
   END IF;

    RETURN(l_cat_rec);

  END get_rec;

  FUNCTION get_rec (
    p_cat_rec                      IN cat_rec_type
  ) RETURN cat_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_cat_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_ARTICLES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_k_articles_tl_rec        IN okc_k_articles_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_k_articles_tl_rec_type IS
    CURSOR okc_k_articles_tl_pk_csr (p_id                 IN NUMBER,
                                     p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            OBJECT_VERSION_NUMBER,
            COMMENTS,
            VARIATION_DESCRIPTION,
            NAME,
            TEXT,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            SAV_SAV_RELEASE
      FROM Okc_K_Articles_Tl
     WHERE okc_k_articles_tl.id = p_id
       AND okc_k_articles_tl.language = p_language;
    l_okc_k_articles_tl_pk         okc_k_articles_tl_pk_csr%ROWTYPE;
    l_okc_k_articles_tl_rec        okc_k_articles_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('900: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_k_articles_tl_pk_csr (p_okc_k_articles_tl_rec.id,
                                   p_okc_k_articles_tl_rec.language);
    FETCH okc_k_articles_tl_pk_csr INTO
              l_okc_k_articles_tl_rec.ID,
              l_okc_k_articles_tl_rec.LANGUAGE,
              l_okc_k_articles_tl_rec.SOURCE_LANG,
              l_okc_k_articles_tl_rec.SFWT_FLAG,
              l_okc_k_articles_tl_rec.OBJECT_VERSION_NUMBER,
              l_okc_k_articles_tl_rec.COMMENTS,
              l_okc_k_articles_tl_rec.VARIATION_DESCRIPTION,
              l_okc_k_articles_tl_rec.NAME,
              l_okc_k_articles_tl_rec.TEXT,
              l_okc_k_articles_tl_rec.CREATED_BY,
              l_okc_k_articles_tl_rec.CREATION_DATE,
              l_okc_k_articles_tl_rec.LAST_UPDATED_BY,
              l_okc_k_articles_tl_rec.LAST_UPDATE_DATE,
              l_okc_k_articles_tl_rec.LAST_UPDATE_LOGIN,
              l_okc_k_articles_tl_rec.SAV_SAV_RELEASE;
    x_no_data_found := okc_k_articles_tl_pk_csr%NOTFOUND;
    CLOSE okc_k_articles_tl_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('900: Leaving  Get_Rec ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_okc_k_articles_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_k_articles_tl_rec        IN okc_k_articles_tl_rec_type
  ) RETURN okc_k_articles_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_okc_k_articles_tl_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_ARTICLES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_catv_rec                     IN catv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN catv_rec_type IS
    CURSOR okc_catv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CHR_ID,
            CLE_ID,
            CAT_ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            SAV_SAE_ID,
            SAV_SAV_RELEASE,
            SBT_CODE,
            DNZ_CHR_ID,
            COMMENTS,
            FULLTEXT_YN,
            VARIATION_DESCRIPTION,
            NAME,
            TEXT,
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
            CAT_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Articles_V
     WHERE okc_k_articles_v.id  = p_id;
    l_okc_catv_pk                  okc_catv_pk_csr%ROWTYPE;
    l_catv_rec                     catv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('1000: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_catv_pk_csr (p_catv_rec.id);
    FETCH okc_catv_pk_csr INTO
              l_catv_rec.ID,
              l_catv_rec.CHR_ID,
              l_catv_rec.CLE_ID,
              l_catv_rec.CAT_ID,
              l_catv_rec.OBJECT_VERSION_NUMBER,
              l_catv_rec.SFWT_FLAG,
              l_catv_rec.SAV_SAE_ID,
              l_catv_rec.SAV_SAV_RELEASE,
              l_catv_rec.SBT_CODE,
              l_catv_rec.DNZ_CHR_ID,
              l_catv_rec.COMMENTS,
              l_catv_rec.FULLTEXT_YN,
              l_catv_rec.VARIATION_DESCRIPTION,
              l_catv_rec.NAME,
              l_catv_rec.TEXT,
              l_catv_rec.ATTRIBUTE_CATEGORY,
              l_catv_rec.ATTRIBUTE1,
              l_catv_rec.ATTRIBUTE2,
              l_catv_rec.ATTRIBUTE3,
              l_catv_rec.ATTRIBUTE4,
              l_catv_rec.ATTRIBUTE5,
              l_catv_rec.ATTRIBUTE6,
              l_catv_rec.ATTRIBUTE7,
              l_catv_rec.ATTRIBUTE8,
              l_catv_rec.ATTRIBUTE9,
              l_catv_rec.ATTRIBUTE10,
              l_catv_rec.ATTRIBUTE11,
              l_catv_rec.ATTRIBUTE12,
              l_catv_rec.ATTRIBUTE13,
              l_catv_rec.ATTRIBUTE14,
              l_catv_rec.ATTRIBUTE15,
              l_catv_rec.CAT_TYPE,
              l_catv_rec.CREATED_BY,
              l_catv_rec.CREATION_DATE,
              l_catv_rec.LAST_UPDATED_BY,
              l_catv_rec.LAST_UPDATE_DATE,
              l_catv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_catv_pk_csr%NOTFOUND;
    CLOSE okc_catv_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('1000: Leaving  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_catv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_catv_rec                     IN catv_rec_type
  ) RETURN catv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_catv_rec, l_row_notfound));

  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_ARTICLES_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_catv_rec	IN catv_rec_type
  ) RETURN catv_rec_type IS
    l_catv_rec	catv_rec_type := p_catv_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('1100: Entered null_out_defaults', 2);
    END IF;

    IF (l_catv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_catv_rec.chr_id := NULL;
    END IF;
    IF (l_catv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_catv_rec.cle_id := NULL;
    END IF;
    IF (l_catv_rec.cat_id = OKC_API.G_MISS_NUM) THEN
      l_catv_rec.cat_id := NULL;
    END IF;
    IF (l_catv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_catv_rec.object_version_number := NULL;
    END IF;
    IF (l_catv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_catv_rec.sav_sae_id = OKC_API.G_MISS_NUM) THEN
      l_catv_rec.sav_sae_id := NULL;
    END IF;
    IF (l_catv_rec.sav_sav_release = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.sav_sav_release := NULL;
    END IF;
    IF (l_catv_rec.sbt_code = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.sbt_code := NULL;
    END IF;
    IF (l_catv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_catv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_catv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.comments := NULL;
    END IF;
    IF (l_catv_rec.fulltext_yn = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.fulltext_yn := NULL;
    END IF;
    IF (l_catv_rec.variation_description = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.variation_description := NULL;
    END IF;
    IF (l_catv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.name := NULL;
    END IF;
---text field is NULL initially
--- IF (l_catv_rec.text = OKC_API.G_MISS_CHAR) THEN
---   l_catv_rec.text := NULL;
--- END IF;
    IF (l_catv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute_category := NULL;
    END IF;
    IF (l_catv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute1 := NULL;
    END IF;
    IF (l_catv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute2 := NULL;
    END IF;
    IF (l_catv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute3 := NULL;
    END IF;
    IF (l_catv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute4 := NULL;
    END IF;
    IF (l_catv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute5 := NULL;
    END IF;
    IF (l_catv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute6 := NULL;
    END IF;
    IF (l_catv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute7 := NULL;
    END IF;
    IF (l_catv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute8 := NULL;
    END IF;
    IF (l_catv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute9 := NULL;
    END IF;
    IF (l_catv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute10 := NULL;
    END IF;
    IF (l_catv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute11 := NULL;
    END IF;
    IF (l_catv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute12 := NULL;
    END IF;
    IF (l_catv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute13 := NULL;
    END IF;
    IF (l_catv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute14 := NULL;
    END IF;
    IF (l_catv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.attribute15 := NULL;
    END IF;
    IF (l_catv_rec.cat_type = OKC_API.G_MISS_CHAR) THEN
      l_catv_rec.cat_type := NULL;
    END IF;
    IF (l_catv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_catv_rec.created_by := NULL;
    END IF;
    IF (l_catv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_catv_rec.creation_date := NULL;
    END IF;
    IF (l_catv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_catv_rec.last_updated_by := NULL;
    END IF;
    IF (l_catv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_catv_rec.last_update_date := NULL;
    END IF;
    IF (l_catv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_catv_rec.last_update_login := NULL;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Leaving  null_out_defaults ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_catv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
/*+++++++++++++Start of hand code +++++++++++++++++*/

-- Start of comments
--
-- Procedure Name  : validate_sbt_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_sbt_code(x_return_status OUT NOCOPY VARCHAR2,
                          p_catv_rec	  IN	catv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('1300: Entered validate_sbt_code', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_catv_rec.sbt_code is NULL or p_catv_rec.sbt_code = OKC_API.G_MISS_CHAR) then
    return;
  end if;
  x_return_status := OKC_UTIL.check_lookup_code('OKC_SUBJECT',p_catv_rec.sbt_code);
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
  OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SBT_CODE');
  x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('1400: Leaving validate_sbt_code', 2);
   okc_debug.Reset_Indentation;
END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Leaving validate_sbt_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 end validate_sbt_code;

-- Start of comments
--
-- Procedure Name  : validate_cat_type
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_cat_type(x_return_status OUT NOCOPY VARCHAR2,
                          p_catv_rec	  IN	catv_rec_TYPE) is
begin

IF (l_debug = 'Y') THEN
   okc_debug.Set_Indentation('OKC_CAT_PVT');
   okc_debug.log('1600: Entered validate_cat_type', 2);
END IF;

  if (P_catv_rec.cat_type in ('STA','NSD',OKC_API.G_MISS_CHAR)) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    return;
  end if;
  if (P_catv_rec.cat_type is NULL) then
    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CAT_TYPE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
  OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CAT_TYPE');
  x_return_status := OKC_API.G_RET_STS_ERROR;

IF (l_debug = 'Y') THEN
   okc_debug.log('1700: Leaving validate_cat_type', 2);
   okc_debug.Reset_Indentation;
END IF;

end validate_cat_type;

-- Start of comments
--
-- Procedure Name  : validate_fulltext_yn
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_fulltext_yn(x_return_status OUT NOCOPY VARCHAR2,
                          p_catv_rec	  IN	catv_rec_TYPE) is
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('1800: Entered validate_fulltext_yn', 2);
    END IF;

  if (P_catv_rec.fulltext_yn in ('Y','N',OKC_API.G_MISS_CHAR)
      or  P_catv_rec.fulltext_yn is NULL) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  else
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'FULLTEXT_YN');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('1900: Leaving validate_fulltext_yn', 2);
   okc_debug.Reset_Indentation;
END IF;

end validate_fulltext_yn;


-- Start of comments
--
-- Procedure Name  : validate_dnz_chr_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_dnz_chr_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_catv_rec	  IN	catv_rec_TYPE) is
l_dummy varchar2(1) := '?';
cursor Kt_Hr_Mj_Vr is
    select '!'
    from okc_k_headers_b
    where id = p_catv_rec.dnz_chr_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('2000: Entered validate_dnz_chr_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_catv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) then
    return;
  end if;
  if (p_catv_rec.dnz_chr_id is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'DNZ_CHR_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	return;
  end if;
  open Kt_Hr_Mj_Vr;
  fetch Kt_Hr_Mj_Vr into l_dummy;
  close Kt_Hr_Mj_Vr;
  if (l_dummy='?') then
  	OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DNZ_CHR_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	return;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('2100: Leaving validate_dnz_chr_id', 2);
   okc_debug.Reset_Indentation;
END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Leaving validate_dnz_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_dnz_chr_id;

-- Start of comments
--
-- Procedure Name  : validate_cat_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_cat_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_catv_rec	  IN	catv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cat_csr is
  select '!'
  from OKC_K_ARTICLES_B
  where id = p_catv_rec.cat_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('2300: Entered validate_cat_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_catv_rec.cat_id = OKC_API.G_MISS_NUM or p_catv_rec.cat_id is NULL) then
    return;
  end if;
  open l_cat_csr;
  fetch l_cat_csr into l_dummy_var;
  close l_cat_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CAT_ID');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('2400: Leaving validate_cat_id', 2);
   okc_debug.Reset_Indentation;
END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2500: Leaving validate_cat_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_cat_csr%ISOPEN then
      close l_cat_csr;
    end if;
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_cat_id;

-- Start of comments
--
-- Procedure Name  : validate_cle_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_cle_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_catv_rec	  IN	catv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cle_csr is
  select '!'
  from OKC_K_LINES_B
  where id = p_catv_rec.cle_id;
begin

IF (l_debug = 'Y') THEN
   okc_debug.Set_Indentation('OKC_CAT_PVT');
   okc_debug.log('2600: Entered validate_cle_id', 2);
END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_catv_rec.cle_id = OKC_API.G_MISS_NUM or p_catv_rec.cle_id is NULL) then
    return;
  end if;
  open l_cle_csr;
  fetch l_cle_csr into l_dummy_var;
  close l_cle_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('2700: Leaving validate_cle_id', 2);
   okc_debug.Reset_Indentation;
END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2800: Leaving validate_cle_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_cle_csr%ISOPEN then
      close l_cle_csr;
    end if;
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_cle_id;

-- Start of comments
--
-- Procedure Name  : validate_chr_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_chr_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_catv_rec	  IN	catv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_chr_csr is
  select '!'
  from OKC_K_HEADERS_B
  where id = p_catv_rec.chr_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('2900: Entered validate_chr_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_catv_rec.chr_id = OKC_API.G_MISS_NUM or p_catv_rec.chr_id is NULL) then
    return;
  end if;
  open l_chr_csr;
  fetch l_chr_csr into l_dummy_var;
  close l_chr_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('3000: Leaving validate_chr_id', 2);
   okc_debug.Reset_Indentation;
END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3100: Leaving validate_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_chr_csr%ISOPEN then
      close l_chr_csr;
    end if;
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_chr_id;

/*+++++++++++++End of hand code +++++++++++++++++++*/
  ----------------------------------------------
  -- Validate_Attributes for:OKC_K_ARTICLES_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_catv_rec IN  catv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*-------------Commented in favor of hand code------
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('3200: Entered Validate_Attributes', 2);
    END IF;

    IF p_catv_rec.id = OKC_API.G_MISS_NUM OR
       p_catv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_catv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_catv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_catv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
          p_catv_rec.dnz_chr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dnz_chr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_catv_rec.cat_type = OKC_API.G_MISS_CHAR OR
          p_catv_rec.cat_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cat_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3300: Leaving Validate_Attributes ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_return_status);

  END Validate_Attributes;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    validate_sbt_code(x_return_status => l_return_status,
                    p_catv_rec      => p_catv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    validate_cat_type(x_return_status => l_return_status,
                    p_catv_rec      => p_catv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    validate_fulltext_yn(x_return_status => l_return_status,
                    p_catv_rec      => p_catv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    validate_dnz_chr_id(x_return_status => l_return_status,
                    p_catv_rec      => p_catv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    validate_cle_id(x_return_status => l_return_status,
                    p_catv_rec      => p_catv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    validate_chr_id(x_return_status => l_return_status,
                    p_catv_rec      => p_catv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    validate_cat_id(x_return_status => l_return_status,
                    p_catv_rec      => p_catv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    return x_return_status;

IF (l_debug = 'Y') THEN
   okc_debug.log('3400: Leaving Validate_Attributes ', 2);
   okc_debug.Reset_Indentation;
END IF;

  exception
    when OTHERS then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      return x_return_status;

  END Validate_Attributes;
/*+++++++++++++End of hand code +++++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_K_ARTICLES_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_catv_rec IN catv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*+++++++++++++Start of hand code +++++++++++++++++*/
  CURSOR std_art_csr (p_sae_id IN NUMBER, p_sav_release IN VARCHAR2) IS
    select '!' from OKC_STD_ART_VERSIONS_B
    where SAE_ID=p_sae_id and SAV_RELEASE=p_sav_release;
  l_dummy_var VARCHAR2(1) := '?';
  BEGIN

IF (l_debug = 'Y') THEN
   okc_debug.Set_Indentation('OKC_CAT_PVT');
   okc_debug.log('3500: Entered Validate_Record', 2);
END IF;

  if (p_catv_rec.CAT_TYPE) = 'STA' then
-- fulltext_yn should have a value
      if (p_catv_rec.fulltext_yn IS NULL) THEN
        OKC_API.SET_MESSAGE(g_app_name,g_required_value,g_col_name_token,'FULLTEXT_YN');
           l_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
-- sav_sae_id should have a value
      if (p_catv_rec.sav_sae_id IS NULL) THEN
        OKC_API.SET_MESSAGE(g_app_name,g_required_value,g_col_name_token,'SAV_SAE_ID');
           l_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
-- arc validation
      if (p_catv_rec.sbt_code IS NOT NULL and p_catv_rec.sbt_code <> OKC_API.G_MISS_CHAR)
      then
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SBT_CODE');
           l_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
-- composite FK validation
      if not(p_catv_rec.sav_sae_id = OKC_API.G_MISS_NUM
             and p_catv_rec.sav_sav_release = OKC_API.G_MISS_CHAR) then
        OPEN std_art_csr(p_catv_rec.sav_sae_id,p_catv_rec.sav_sav_release);
        FETCH std_art_csr INTO l_dummy_var;
        CLOSE std_art_csr;
        if (l_dummy_var='?') then
           OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SAV_SAE_ID');
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SAV_SAV_RELEASE');
           l_return_status := OKC_API.G_RET_STS_ERROR;
        end if;
      end if;
  elsif (p_catv_rec.CAT_TYPE = 'NSD') then
-- name should have a value
    if (p_catv_rec.name IS NULL) THEN
        OKC_API.SET_MESSAGE(g_app_name,g_required_value,g_col_name_token,'NAME');
        l_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
-- sbt_code should have a value
      if (p_catv_rec.sbt_code IS NULL) THEN
        OKC_API.SET_MESSAGE(g_app_name,g_required_value,g_col_name_token,'SBT_CODE');
        l_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
-- arc validation
   if (p_catv_rec.sav_sae_id IS NOT NULL and p_catv_rec.sav_sae_id <> OKC_API.G_MISS_NUM) THEN
     OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SAV_SAE_ID');
     l_return_status := OKC_API.G_RET_STS_ERROR;
   end if;
   if (p_catv_rec.sav_sav_release IS NOT NULL and p_catv_rec.sav_sav_release <> OKC_API.G_MISS_CHAR) THEN
     OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SAV_SAV_RELEASE');
     l_return_status := OKC_API.G_RET_STS_ERROR;
   end if;
  end if;
  if (p_catv_rec.cle_id IS NULL and p_catv_rec.chr_id IS NULL)
  then
        OKC_API.SET_MESSAGE(g_app_name,g_required_value,g_col_name_token,'CLE_ID V CHR_ID');
           l_return_status := OKC_API.G_RET_STS_ERROR;
  end if;
  if ((p_catv_rec.cle_id IS NOT NULL and p_catv_rec.cle_id <> OKC_API.G_MISS_NUM) and
          (p_catv_rec.chr_id IS NOT NULL and p_catv_rec.chr_id <> OKC_API.G_MISS_NUM))
  then
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID V CHR_ID');
           l_return_status := OKC_API.G_RET_STS_ERROR;
  end if;
  RETURN (l_return_status);

IF (l_debug = 'Y') THEN
   okc_debug.log('3600: Leaving Validate_Record', 2);
   okc_debug.Reset_Indentation;
END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3700: Leaving Validate_Record:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      if std_art_csr%ISOPEN then
        close std_art_csr;
      end if;
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
      RETURN(OKC_API.G_RET_STS_UNEXP_ERROR);

  END Validate_Record;
/*+++++++++++++End of hand code +++++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN catv_rec_type,
    p_to	IN OUT NOCOPY cat_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sav_sae_id := p_from.sav_sae_id;
    p_to.sbt_code := p_from.sbt_code;
    p_to.cat_type := p_from.cat_type;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.cat_id := p_from.cat_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.fulltext_yn := p_from.fulltext_yn;
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

  END migrate;


  PROCEDURE migrate (
    p_from	IN cat_rec_type,
    p_to	IN OUT NOCOPY catv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sav_sae_id := p_from.sav_sae_id;
    p_to.sbt_code := p_from.sbt_code;
    p_to.cat_type := p_from.cat_type;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.cat_id := p_from.cat_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.fulltext_yn := p_from.fulltext_yn;
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

  END migrate;


  PROCEDURE migrate (
    p_from	IN catv_rec_type,
    p_to	IN OUT NOCOPY okc_k_articles_tl_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.object_version_number := p_from.object_version_number;
    p_to.comments := p_from.comments;
    p_to.variation_description := p_from.variation_description;
    p_to.name := p_from.name;
    p_to.text := p_from.text;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.sav_sav_release := p_from.sav_sav_release;

  END migrate;


  PROCEDURE migrate (
    p_from	IN okc_k_articles_tl_rec_type,
    p_to	IN OUT NOCOPY catv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.object_version_number := p_from.object_version_number;
    p_to.comments := p_from.comments;
    p_to.variation_description := p_from.variation_description;
    p_to.name := p_from.name;
    p_to.text := p_from.text;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.sav_sav_release := p_from.sav_sav_release;

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKC_K_ARTICLES_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_catv_rec                     catv_rec_type := p_catv_rec;
    l_cat_rec                      cat_rec_type;
    l_okc_k_articles_tl_rec        okc_k_articles_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('3800: Entered validate_row', 2);
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
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_catv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_catv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('3900: Leaving validate_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4000: Leaving validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('4100: Leaving validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4200: Leaving validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL validate_row for:CATV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('4300: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_catv_tbl.COUNT > 0) THEN
      i := p_catv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_catv_rec                     => p_catv_tbl(i));
        EXIT WHEN (i = p_catv_tbl.LAST);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('4400: Leaving validate_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4500: Leaving validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('4600: Leaving validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4700: Leaving validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- insert_row for:OKC_K_ARTICLES_B --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_rec                      IN cat_rec_type,
    x_cat_rec                      OUT NOCOPY cat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cat_rec                      cat_rec_type := p_cat_rec;
    l_def_cat_rec                  cat_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_ARTICLES_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_cat_rec IN  cat_rec_type,
      x_cat_rec OUT NOCOPY cat_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cat_rec := p_cat_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('4800: Entered insert_row', 2);
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
      p_cat_rec,                         -- IN
      l_cat_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_ARTICLES_B(
        id,
        sav_sae_id,
        sbt_code,
        cat_type,
        chr_id,
        cle_id,
        cat_id,
        dnz_chr_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        fulltext_yn,
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
        attribute15)
      VALUES (
        l_cat_rec.id,
        l_cat_rec.sav_sae_id,
        l_cat_rec.sbt_code,
        l_cat_rec.cat_type,
        l_cat_rec.chr_id,
        l_cat_rec.cle_id,
        l_cat_rec.cat_id,
        l_cat_rec.dnz_chr_id,
        l_cat_rec.object_version_number,
        l_cat_rec.created_by,
        l_cat_rec.creation_date,
        l_cat_rec.last_updated_by,
        l_cat_rec.last_update_date,
        l_cat_rec.fulltext_yn,
        l_cat_rec.last_update_login,
        l_cat_rec.attribute_category,
        l_cat_rec.attribute1,
        l_cat_rec.attribute2,
        l_cat_rec.attribute3,
        l_cat_rec.attribute4,
        l_cat_rec.attribute5,
        l_cat_rec.attribute6,
        l_cat_rec.attribute7,
        l_cat_rec.attribute8,
        l_cat_rec.attribute9,
        l_cat_rec.attribute10,
        l_cat_rec.attribute11,
        l_cat_rec.attribute12,
        l_cat_rec.attribute13,
        l_cat_rec.attribute14,
        l_cat_rec.attribute15);
    -- Set OUT values
    x_cat_rec := l_cat_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('4900: Leaving insert_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5000: Leaving insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('5100: Leaving insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5200: Leaving insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  --------------------------------------
  -- insert_row for:OKC_K_ARTICLES_TL --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_articles_tl_rec        IN okc_k_articles_tl_rec_type,
    x_okc_k_articles_tl_rec        OUT NOCOPY okc_k_articles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_articles_tl_rec        okc_k_articles_tl_rec_type := p_okc_k_articles_tl_rec;
    l_def_okc_k_articles_tl_rec    okc_k_articles_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ------------------------------------------
    -- Set_Attributes for:OKC_K_ARTICLES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_k_articles_tl_rec IN  okc_k_articles_tl_rec_type,
      x_okc_k_articles_tl_rec OUT NOCOPY okc_k_articles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okc_k_articles_tl_rec := p_okc_k_articles_tl_rec;
      x_okc_k_articles_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_k_articles_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('5300: Entered insert_row', 2);
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
      p_okc_k_articles_tl_rec,           -- IN
      l_okc_k_articles_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_k_articles_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_K_ARTICLES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          object_version_number,
          comments,
          variation_description,
          name,
          text,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          sav_sav_release)
        VALUES (
          l_okc_k_articles_tl_rec.id,
          l_okc_k_articles_tl_rec.language,
          l_okc_k_articles_tl_rec.source_lang,
          l_okc_k_articles_tl_rec.sfwt_flag,
          l_okc_k_articles_tl_rec.object_version_number,
          l_okc_k_articles_tl_rec.comments,
          l_okc_k_articles_tl_rec.variation_description,
          l_okc_k_articles_tl_rec.name,
          l_okc_k_articles_tl_rec.text,
          l_okc_k_articles_tl_rec.created_by,
          l_okc_k_articles_tl_rec.creation_date,
          l_okc_k_articles_tl_rec.last_updated_by,
          l_okc_k_articles_tl_rec.last_update_date,
          l_okc_k_articles_tl_rec.last_update_login,
          l_okc_k_articles_tl_rec.sav_sav_release);
    END LOOP;
    -- Set OUT values
    x_okc_k_articles_tl_rec := l_okc_k_articles_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('5400: Leaving insert_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5500: Leaving insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('5600: Leaving insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5700: Leaving insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- insert_row for:OKC_K_ARTICLES_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type,
    x_catv_rec                     OUT NOCOPY catv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_catv_rec                     catv_rec_type;
    l_def_catv_rec                 catv_rec_type;
    l_cat_rec                      cat_rec_type;
    lx_cat_rec                     cat_rec_type;
    l_okc_k_articles_tl_rec        okc_k_articles_tl_rec_type;
    lx_okc_k_articles_tl_rec       okc_k_articles_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_catv_rec	IN catv_rec_type
    ) RETURN catv_rec_type IS
      l_catv_rec	catv_rec_type := p_catv_rec;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('5800: Entered fill_who_columns', 2);
    END IF;

      l_catv_rec.CREATION_DATE := SYSDATE;
      l_catv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_catv_rec.LAST_UPDATE_DATE := l_catv_rec.CREATION_DATE;
      l_catv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_catv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: Leaving fill_who_columns ', 2);
       okc_debug.Reset_Indentation;
    END IF;

      RETURN(l_catv_rec);

    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_ARTICLES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_catv_rec IN  catv_rec_type,
      x_catv_rec OUT NOCOPY catv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_catv_rec := p_catv_rec;
      x_catv_rec.OBJECT_VERSION_NUMBER := 1;
      x_catv_rec.SFWT_FLAG := 'N';
      If  ((x_catv_rec.chr_id is null) and
	     (x_catv_rec.cle_id is null))
      Then
	     x_catv_rec.chr_id := x_catv_rec.dnz_chr_id;
      End If;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('6000: Entered insert_row', 2);
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
    l_catv_rec := null_out_defaults(p_catv_rec);
    -- Set primary key value
    l_catv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_catv_rec,                        -- IN
      l_def_catv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_catv_rec := fill_who_columns(l_def_catv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_catv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_catv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_catv_rec, l_cat_rec);
    migrate(l_def_catv_rec, l_okc_k_articles_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cat_rec,
      lx_cat_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cat_rec, l_def_catv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_articles_tl_rec,
      lx_okc_k_articles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_k_articles_tl_rec, l_def_catv_rec);
    -- Set OUT values
    x_catv_rec := l_def_catv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('6050: Leaving insert_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6100: Leaving insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6200: Leaving insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6300: Leaving insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL insert_row for:CATV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type,
    x_catv_tbl                     OUT NOCOPY catv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('6500: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_catv_tbl.COUNT > 0) THEN
      i := p_catv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_catv_rec                     => p_catv_tbl(i),
          x_catv_rec                     => x_catv_tbl(i));
        EXIT WHEN (i = p_catv_tbl.LAST);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('6550: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6600: Leaving insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6700: Leaving insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6800: Leaving insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- lock_row for:OKC_K_ARTICLES_B --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_rec                      IN cat_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cat_rec IN cat_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_ARTICLES_B
     WHERE ID = p_cat_rec.id
       AND OBJECT_VERSION_NUMBER = p_cat_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cat_rec IN cat_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_ARTICLES_B
    WHERE ID = p_cat_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_ARTICLES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_ARTICLES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('7000: Entered lock_row', 2);
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

      OPEN lock_csr(p_cat_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Leaving lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_cat_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cat_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cat_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('7150: Leaving lock_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7200: Leaving lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7300: Leaving lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7400: Leaving lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ------------------------------------
  -- lock_row for:OKC_K_ARTICLES_TL --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_articles_tl_rec        IN okc_k_articles_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_k_articles_tl_rec IN okc_k_articles_tl_rec_type) IS
    SELECT *
      FROM OKC_K_ARTICLES_TL
     WHERE ID = p_okc_k_articles_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('8000: Entered lock_row', 2);
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

      OPEN lock_csr(p_okc_k_articles_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

 IF (l_debug = 'Y') THEN
    okc_debug.log('8100: Leaving lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8200: Leaving lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

 IF (l_debug = 'Y') THEN
    okc_debug.log('8300: Leaving lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8400: Leaving lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('8500: Leaving lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Leaving lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- lock_row for:OKC_K_ARTICLES_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cat_rec                      cat_rec_type;
    l_okc_k_articles_tl_rec        okc_k_articles_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('8700: Entered lock_row', 2);
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
    migrate(p_catv_rec, l_cat_rec);
    migrate(p_catv_rec, l_okc_k_articles_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cat_rec
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
      l_okc_k_articles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('8800: Leaving lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8900: Leaving lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('9000: Leaving lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9100: Leaving lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL lock_row for:CATV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('9400: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_catv_tbl.COUNT > 0) THEN
      i := p_catv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_catv_rec                     => p_catv_tbl(i));
        EXIT WHEN (i = p_catv_tbl.LAST);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
    END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.log('9500: Leaving lock_row', 2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9600: Leaving lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('9700: Leaving lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9800: Leaving lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- update_row for:OKC_K_ARTICLES_B --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_rec                      IN cat_rec_type,
    x_cat_rec                      OUT NOCOPY cat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cat_rec                      cat_rec_type := p_cat_rec;
    l_def_cat_rec                  cat_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cat_rec	IN cat_rec_type,
      x_cat_rec	OUT NOCOPY cat_rec_type
    ) RETURN VARCHAR2 IS
      l_cat_rec                      cat_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('9900: Entered populate_new_record', 2);
    END IF;

      x_cat_rec := p_cat_rec;
      -- Get current database values
      l_cat_rec := get_rec(p_cat_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cat_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cat_rec.id := l_cat_rec.id;
      END IF;
      IF (x_cat_rec.sav_sae_id = OKC_API.G_MISS_NUM)
      THEN
        x_cat_rec.sav_sae_id := l_cat_rec.sav_sae_id;
      END IF;
      IF (x_cat_rec.sbt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.sbt_code := l_cat_rec.sbt_code;
      END IF;
      IF (x_cat_rec.cat_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.cat_type := l_cat_rec.cat_type;
      END IF;
      IF (x_cat_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cat_rec.chr_id := l_cat_rec.chr_id;
      END IF;
      IF (x_cat_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_cat_rec.cle_id := l_cat_rec.cle_id;
      END IF;
      IF (x_cat_rec.cat_id = OKC_API.G_MISS_NUM)
      THEN
        x_cat_rec.cat_id := l_cat_rec.cat_id;
      END IF;
      IF (x_cat_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cat_rec.dnz_chr_id := l_cat_rec.dnz_chr_id;
      END IF;
      IF (x_cat_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cat_rec.object_version_number := l_cat_rec.object_version_number;
      END IF;
      IF (x_cat_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cat_rec.created_by := l_cat_rec.created_by;
      END IF;
      IF (x_cat_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cat_rec.creation_date := l_cat_rec.creation_date;
      END IF;
      IF (x_cat_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cat_rec.last_updated_by := l_cat_rec.last_updated_by;
      END IF;
      IF (x_cat_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cat_rec.last_update_date := l_cat_rec.last_update_date;
      END IF;
      IF (x_cat_rec.fulltext_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.fulltext_yn := l_cat_rec.fulltext_yn;
      END IF;
      IF (x_cat_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cat_rec.last_update_login := l_cat_rec.last_update_login;
      END IF;
      IF (x_cat_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute_category := l_cat_rec.attribute_category;
      END IF;
      IF (x_cat_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute1 := l_cat_rec.attribute1;
      END IF;
      IF (x_cat_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute2 := l_cat_rec.attribute2;
      END IF;
      IF (x_cat_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute3 := l_cat_rec.attribute3;
      END IF;
      IF (x_cat_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute4 := l_cat_rec.attribute4;
      END IF;
      IF (x_cat_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute5 := l_cat_rec.attribute5;
      END IF;
      IF (x_cat_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute6 := l_cat_rec.attribute6;
      END IF;
      IF (x_cat_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute7 := l_cat_rec.attribute7;
      END IF;
      IF (x_cat_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute8 := l_cat_rec.attribute8;
      END IF;
      IF (x_cat_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute9 := l_cat_rec.attribute9;
      END IF;
      IF (x_cat_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute10 := l_cat_rec.attribute10;
      END IF;
      IF (x_cat_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute11 := l_cat_rec.attribute11;
      END IF;
      IF (x_cat_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute12 := l_cat_rec.attribute12;
      END IF;
      IF (x_cat_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute13 := l_cat_rec.attribute13;
      END IF;
      IF (x_cat_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute14 := l_cat_rec.attribute14;
      END IF;
      IF (x_cat_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute15 := l_cat_rec.attribute15;
      END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('10000: Leaving populate_new_record ', 2);
       okc_debug.Reset_Indentation;
    END IF;

      RETURN(l_return_status);

    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_ARTICLES_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_cat_rec IN  cat_rec_type,
      x_cat_rec OUT NOCOPY cat_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cat_rec := p_cat_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('10100: Entered update_row', 2);
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
      p_cat_rec,                         -- IN
      l_cat_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cat_rec, l_def_cat_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_K_ARTICLES_B
    SET SAV_SAE_ID = l_def_cat_rec.sav_sae_id,
        SBT_CODE = l_def_cat_rec.sbt_code,
        CAT_TYPE = l_def_cat_rec.cat_type,
        CHR_ID = l_def_cat_rec.chr_id,
        CLE_ID = l_def_cat_rec.cle_id,
        CAT_ID = l_def_cat_rec.cat_id,
        DNZ_CHR_ID = l_def_cat_rec.dnz_chr_id,
        OBJECT_VERSION_NUMBER = l_def_cat_rec.object_version_number,
        CREATED_BY = l_def_cat_rec.created_by,
        CREATION_DATE = l_def_cat_rec.creation_date,
        LAST_UPDATED_BY = l_def_cat_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cat_rec.last_update_date,
        FULLTEXT_YN = l_def_cat_rec.fulltext_yn,
        LAST_UPDATE_LOGIN = l_def_cat_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_cat_rec.attribute_category,
        ATTRIBUTE1 = l_def_cat_rec.attribute1,
        ATTRIBUTE2 = l_def_cat_rec.attribute2,
        ATTRIBUTE3 = l_def_cat_rec.attribute3,
        ATTRIBUTE4 = l_def_cat_rec.attribute4,
        ATTRIBUTE5 = l_def_cat_rec.attribute5,
        ATTRIBUTE6 = l_def_cat_rec.attribute6,
        ATTRIBUTE7 = l_def_cat_rec.attribute7,
        ATTRIBUTE8 = l_def_cat_rec.attribute8,
        ATTRIBUTE9 = l_def_cat_rec.attribute9,
        ATTRIBUTE10 = l_def_cat_rec.attribute10,
        ATTRIBUTE11 = l_def_cat_rec.attribute11,
        ATTRIBUTE12 = l_def_cat_rec.attribute12,
        ATTRIBUTE13 = l_def_cat_rec.attribute13,
        ATTRIBUTE14 = l_def_cat_rec.attribute14,
        ATTRIBUTE15 = l_def_cat_rec.attribute15
    WHERE ID = l_def_cat_rec.id;

    x_cat_rec := l_def_cat_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('10200: Leaving update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10300: Leaving update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10400: Leaving update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10500: Leaving update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  --------------------------------------
  -- update_row for:OKC_K_ARTICLES_TL --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_articles_tl_rec        IN okc_k_articles_tl_rec_type,
    x_okc_k_articles_tl_rec        OUT NOCOPY okc_k_articles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_articles_tl_rec        okc_k_articles_tl_rec_type := p_okc_k_articles_tl_rec;
    l_def_okc_k_articles_tl_rec    okc_k_articles_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_k_articles_tl_rec	IN okc_k_articles_tl_rec_type,
      x_okc_k_articles_tl_rec	OUT NOCOPY okc_k_articles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_k_articles_tl_rec        okc_k_articles_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('10500: Entered populate_new_record', 2);
    END IF;

      x_okc_k_articles_tl_rec := p_okc_k_articles_tl_rec;
      -- Get current database values
      l_okc_k_articles_tl_rec := get_rec(p_okc_k_articles_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_k_articles_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_k_articles_tl_rec.id := l_okc_k_articles_tl_rec.id;
      END IF;
      IF (x_okc_k_articles_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_articles_tl_rec.language := l_okc_k_articles_tl_rec.language;
      END IF;
      IF (x_okc_k_articles_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_articles_tl_rec.source_lang := l_okc_k_articles_tl_rec.source_lang;
      END IF;
      IF (x_okc_k_articles_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_articles_tl_rec.sfwt_flag := l_okc_k_articles_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_k_articles_tl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_okc_k_articles_tl_rec.object_version_number := l_okc_k_articles_tl_rec.object_version_number;
      END IF;
      IF (x_okc_k_articles_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_articles_tl_rec.comments := l_okc_k_articles_tl_rec.comments;
      END IF;
      IF (x_okc_k_articles_tl_rec.variation_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_articles_tl_rec.variation_description := l_okc_k_articles_tl_rec.variation_description;
      END IF;
      IF (x_okc_k_articles_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_articles_tl_rec.name := l_okc_k_articles_tl_rec.name;
      END IF;
-- Commented in favor of hand code
--    IF (x_okc_k_articles_tl_rec.text = OKC_API.G_MISS_CHAR)
--+Hand code start
      IF (x_okc_k_articles_tl_rec.text is NULL)
--+Hand code end
      THEN
        x_okc_k_articles_tl_rec.text := l_okc_k_articles_tl_rec.text;
      END IF;
      IF (x_okc_k_articles_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_k_articles_tl_rec.created_by := l_okc_k_articles_tl_rec.created_by;
      END IF;
      IF (x_okc_k_articles_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_k_articles_tl_rec.creation_date := l_okc_k_articles_tl_rec.creation_date;
      END IF;
      IF (x_okc_k_articles_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_k_articles_tl_rec.last_updated_by := l_okc_k_articles_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_k_articles_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_k_articles_tl_rec.last_update_date := l_okc_k_articles_tl_rec.last_update_date;
      END IF;
      IF (x_okc_k_articles_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_k_articles_tl_rec.last_update_login := l_okc_k_articles_tl_rec.last_update_login;
      END IF;
      IF (x_okc_k_articles_tl_rec.sav_sav_release = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_articles_tl_rec.sav_sav_release := l_okc_k_articles_tl_rec.sav_sav_release;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('10650: Leaving update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_K_ARTICLES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_k_articles_tl_rec IN  okc_k_articles_tl_rec_type,
      x_okc_k_articles_tl_rec OUT NOCOPY okc_k_articles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okc_k_articles_tl_rec := p_okc_k_articles_tl_rec;
      x_okc_k_articles_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_k_articles_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('10700: Entered update_row', 2);
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
      p_okc_k_articles_tl_rec,           -- IN
      l_okc_k_articles_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_k_articles_tl_rec, l_def_okc_k_articles_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_K_ARTICLES_TL
    SET OBJECT_VERSION_NUMBER = l_def_okc_k_articles_tl_rec.object_version_number,
        COMMENTS = l_def_okc_k_articles_tl_rec.comments,
        VARIATION_DESCRIPTION = l_def_okc_k_articles_tl_rec.variation_description,
        NAME = l_def_okc_k_articles_tl_rec.name,
        TEXT = l_def_okc_k_articles_tl_rec.text,
        CREATED_BY = l_def_okc_k_articles_tl_rec.created_by,
        CREATION_DATE = l_def_okc_k_articles_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_k_articles_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_k_articles_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_k_articles_tl_rec.last_update_login,
        SAV_SAV_RELEASE = l_def_okc_k_articles_tl_rec.sav_sav_release
--+
	,SOURCE_LANG = l_def_okc_k_articles_tl_rec.SOURCE_LANG
--+
    WHERE ID = l_def_okc_k_articles_tl_rec.id
---      AND SOURCE_LANG = USERENV('LANG');
--+
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);
--+

    UPDATE  OKC_K_ARTICLES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okc_k_articles_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_k_articles_tl_rec := l_def_okc_k_articles_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('10750: Leaving update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10800: Leaving update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10900: Leaving update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11000: Leaving update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- update_row for:OKC_K_ARTICLES_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type,
    x_catv_rec                     OUT NOCOPY catv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_catv_rec                     catv_rec_type := p_catv_rec;
    l_def_catv_rec                 catv_rec_type;
    l_okc_k_articles_tl_rec        okc_k_articles_tl_rec_type;
    lx_okc_k_articles_tl_rec       okc_k_articles_tl_rec_type;
    l_cat_rec                      cat_rec_type;
    lx_cat_rec                     cat_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_catv_rec	IN catv_rec_type
    ) RETURN catv_rec_type IS
      l_catv_rec	catv_rec_type := p_catv_rec;
    BEGIN

      l_catv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_catv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_catv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_catv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_catv_rec	IN catv_rec_type,
      x_catv_rec	OUT NOCOPY catv_rec_type
    ) RETURN VARCHAR2 IS
      l_catv_rec                     catv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('11300: Entered populate_new_record', 2);
    END IF;

      x_catv_rec := p_catv_rec;
      -- Get current database values
      l_catv_rec := get_rec(p_catv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_catv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_catv_rec.id := l_catv_rec.id;
      END IF;
      IF (x_catv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_catv_rec.chr_id := l_catv_rec.chr_id;
      END IF;
      IF (x_catv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_catv_rec.cle_id := l_catv_rec.cle_id;
      END IF;
      IF (x_catv_rec.cat_id = OKC_API.G_MISS_NUM)
      THEN
        x_catv_rec.cat_id := l_catv_rec.cat_id;
      END IF;
      IF (x_catv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_catv_rec.object_version_number := l_catv_rec.object_version_number;
      END IF;
      IF (x_catv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.sfwt_flag := l_catv_rec.sfwt_flag;
      END IF;
      IF (x_catv_rec.sav_sae_id = OKC_API.G_MISS_NUM)
      THEN
        x_catv_rec.sav_sae_id := l_catv_rec.sav_sae_id;
      END IF;
      IF (x_catv_rec.sav_sav_release = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.sav_sav_release := l_catv_rec.sav_sav_release;
      END IF;
      IF (x_catv_rec.sbt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.sbt_code := l_catv_rec.sbt_code;
      END IF;
      IF (x_catv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_catv_rec.dnz_chr_id := l_catv_rec.dnz_chr_id;
      END IF;
      IF (x_catv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.comments := l_catv_rec.comments;
      END IF;
      IF (x_catv_rec.fulltext_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.fulltext_yn := l_catv_rec.fulltext_yn;
      END IF;
      IF (x_catv_rec.variation_description = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.variation_description := l_catv_rec.variation_description;
      END IF;
      IF (x_catv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.name := l_catv_rec.name;
      END IF;
-- Commented in favor of hand code
--    IF (x_catv_rec.text = OKC_API.G_MISS_CHAR)
--+Hand code start
      IF (x_catv_rec.text is NULL)
--+Hand code end
      THEN
        x_catv_rec.text := l_catv_rec.text;
      END IF;
      IF (x_catv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute_category := l_catv_rec.attribute_category;
      END IF;
      IF (x_catv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute1 := l_catv_rec.attribute1;
      END IF;
      IF (x_catv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute2 := l_catv_rec.attribute2;
      END IF;
      IF (x_catv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute3 := l_catv_rec.attribute3;
      END IF;
      IF (x_catv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute4 := l_catv_rec.attribute4;
      END IF;
      IF (x_catv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute5 := l_catv_rec.attribute5;
      END IF;
      IF (x_catv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute6 := l_catv_rec.attribute6;
      END IF;
      IF (x_catv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute7 := l_catv_rec.attribute7;
      END IF;
      IF (x_catv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute8 := l_catv_rec.attribute8;
      END IF;
      IF (x_catv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute9 := l_catv_rec.attribute9;
      END IF;
      IF (x_catv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute10 := l_catv_rec.attribute10;
      END IF;
      IF (x_catv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute11 := l_catv_rec.attribute11;
      END IF;
      IF (x_catv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute12 := l_catv_rec.attribute12;
      END IF;
      IF (x_catv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute13 := l_catv_rec.attribute13;
      END IF;
      IF (x_catv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute14 := l_catv_rec.attribute14;
      END IF;
      IF (x_catv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute15 := l_catv_rec.attribute15;
      END IF;
      IF (x_catv_rec.cat_type = OKC_API.G_MISS_CHAR)
      THEN
        x_catv_rec.cat_type := l_catv_rec.cat_type;
      END IF;
      IF (x_catv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_catv_rec.created_by := l_catv_rec.created_by;
      END IF;
      IF (x_catv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_catv_rec.creation_date := l_catv_rec.creation_date;
      END IF;
      IF (x_catv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_catv_rec.last_updated_by := l_catv_rec.last_updated_by;
      END IF;
      IF (x_catv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_catv_rec.last_update_date := l_catv_rec.last_update_date;
      END IF;
      IF (x_catv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_catv_rec.last_update_login := l_catv_rec.last_update_login;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('11400: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_ARTICLES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_catv_rec IN  catv_rec_type,
      x_catv_rec OUT NOCOPY catv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_catv_rec := p_catv_rec;
      x_catv_rec.OBJECT_VERSION_NUMBER := NVL(x_catv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

IF (l_debug = 'Y') THEN
   okc_debug.Set_Indentation('OKC_CAT_PVT');
   okc_debug.log('11500: Entered update_row', 2);
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
      p_catv_rec,                        -- IN
      l_catv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_catv_rec, l_def_catv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_catv_rec := fill_who_columns(l_def_catv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_catv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_catv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_catv_rec, l_okc_k_articles_tl_rec);
    migrate(l_def_catv_rec, l_cat_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_articles_tl_rec,
      lx_okc_k_articles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_k_articles_tl_rec, l_def_catv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cat_rec,
      lx_cat_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cat_rec, l_def_catv_rec);
    x_catv_rec := l_def_catv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('11600: Leaving update_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11700: Leaving update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('11800: Leaving update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11900: Leaving update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL update_row for:CATV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type,
    x_catv_tbl                     OUT NOCOPY catv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('12000: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_catv_tbl.COUNT > 0) THEN
      i := p_catv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_catv_rec                     => p_catv_tbl(i),
          x_catv_rec                     => x_catv_tbl(i));
        EXIT WHEN (i = p_catv_tbl.LAST);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('12100: Leaving update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12200: Leaving update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('12300: Leaving update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12400: Leaving update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- delete_row for:OKC_K_ARTICLES_B --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_rec                      IN cat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cat_rec                      cat_rec_type:= p_cat_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('12500: Entered delete_row', 2);
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
    DELETE FROM OKC_K_ARTICLES_B
     WHERE ID = l_cat_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('12600: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12700: Leaving delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('12800: Leaving delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12900: Leaving delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  --------------------------------------
  -- delete_row for:OKC_K_ARTICLES_TL --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_articles_tl_rec        IN okc_k_articles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_articles_tl_rec        okc_k_articles_tl_rec_type:= p_okc_k_articles_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ------------------------------------------
    -- Set_Attributes for:OKC_K_ARTICLES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_k_articles_tl_rec IN  okc_k_articles_tl_rec_type,
      x_okc_k_articles_tl_rec OUT NOCOPY okc_k_articles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okc_k_articles_tl_rec := p_okc_k_articles_tl_rec;
      x_okc_k_articles_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('13100: Entered delete_row', 2);
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
      p_okc_k_articles_tl_rec,           -- IN
      l_okc_k_articles_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_K_ARTICLES_TL
     WHERE ID = l_okc_k_articles_tl_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('13200: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13300: Leaving delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('13400: Leaving delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13500: Leaving delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- delete_row for:OKC_K_ARTICLES_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_catv_rec                     catv_rec_type := p_catv_rec;
    l_okc_k_articles_tl_rec        okc_k_articles_tl_rec_type;
    l_cat_rec                      cat_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('13600: Entered delete_row', 2);
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
    migrate(l_catv_rec, l_okc_k_articles_tl_rec);
    migrate(l_catv_rec, l_cat_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_articles_tl_rec
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
      l_cat_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('13700: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13800: Leaving delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('13900: Leaving delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('14000: Leaving delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL delete_row for:CATV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('14100: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_catv_tbl.COUNT > 0) THEN
      i := p_catv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_catv_rec                     => p_catv_tbl(i));
        EXIT WHEN (i = p_catv_tbl.LAST);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.log('14200: Leaving delete_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('14300: Leaving delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('14400: Leaving delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('14500: Leaving delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

---------------------------------------------------------------
-- Procedure for mass insert in OKC_K_ARTICLES _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_catv_tbl catv_tbl_type) IS
  l_tabsize NUMBER := p_catv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_chr_id                        OKC_DATATYPES.NumberTabTyp;
  in_cle_id                        OKC_DATATYPES.NumberTabTyp;
  in_cat_id                        OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_sav_sae_id                    OKC_DATATYPES.NumberTabTyp;
  in_sav_sav_release               OKC_DATATYPES.Var150TabTyp;
  in_sbt_code                      OKC_DATATYPES.Var30TabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_comments                      OKC_DATATYPES.Var1995TabTyp;
  in_fulltext_yn                   OKC_DATATYPES.Var3TabTyp;
  in_variation_description         OKC_DATATYPES.Var240TabTyp;
  in_name                          OKC_DATATYPES.Var150TabTyp;
  in_text                          OKC_DATATYPES.ClobTabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_cat_type                      OKC_DATATYPES.Var30TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  i number;
  j number;
BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
     -- Initializing Return status
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('14600: Entered INSERT_ROW_UPG', 2);
    END IF;

  i := p_catv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    j:=j+1;
    in_id                       (j) := p_catv_tbl(i).id;
    in_chr_id                   (j) := p_catv_tbl(i).chr_id;
    in_cle_id                   (j) := p_catv_tbl(i).cle_id;
    in_cat_id                   (j) := p_catv_tbl(i).cat_id;
    in_object_version_number    (j) := p_catv_tbl(i).object_version_number;
    in_sfwt_flag                (j) := p_catv_tbl(i).sfwt_flag;
    in_sav_sae_id               (j) := p_catv_tbl(i).sav_sae_id;
    in_sav_sav_release          (j) := p_catv_tbl(i).sav_sav_release;
    in_sbt_code                 (j) := p_catv_tbl(i).sbt_code;
    in_dnz_chr_id               (j) := p_catv_tbl(i).dnz_chr_id;
    in_comments                 (j) := p_catv_tbl(i).comments;
    in_fulltext_yn              (j) := p_catv_tbl(i).fulltext_yn;
    in_variation_description    (j) := p_catv_tbl(i).variation_description;
    in_name                     (j) := p_catv_tbl(i).name;
    in_text                     (j) := p_catv_tbl(i).text;
    in_attribute_category       (j) := p_catv_tbl(i).attribute_category;
    in_attribute1               (j) := p_catv_tbl(i).attribute1;
    in_attribute2               (j) := p_catv_tbl(i).attribute2;
    in_attribute3               (j) := p_catv_tbl(i).attribute3;
    in_attribute4               (j) := p_catv_tbl(i).attribute4;
    in_attribute5               (j) := p_catv_tbl(i).attribute5;
    in_attribute6               (j) := p_catv_tbl(i).attribute6;
    in_attribute7               (j) := p_catv_tbl(i).attribute7;
    in_attribute8               (j) := p_catv_tbl(i).attribute8;
    in_attribute9               (j) := p_catv_tbl(i).attribute9;
    in_attribute10              (j) := p_catv_tbl(i).attribute10;
    in_attribute11              (j) := p_catv_tbl(i).attribute11;
    in_attribute12              (j) := p_catv_tbl(i).attribute12;
    in_attribute13              (j) := p_catv_tbl(i).attribute13;
    in_attribute14              (j) := p_catv_tbl(i).attribute14;
    in_attribute15              (j) := p_catv_tbl(i).attribute15;
    in_cat_type                 (j) := p_catv_tbl(i).cat_type;
    in_created_by               (j) := p_catv_tbl(i).created_by;
    in_creation_date            (j) := p_catv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_catv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_catv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_catv_tbl(i).last_update_login;
    i:=p_catv_tbl.next(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_K_ARTICLES_B
      (
        id,
        sav_sae_id,
        sbt_code,
        cat_type,
        chr_id,
        cle_id,
        cat_id,
        dnz_chr_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        fulltext_yn,
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
        attribute15
-- REMOVE comma from the previous line
     )
     VALUES (
        in_id(i),
        in_sav_sae_id(i),
        in_sbt_code(i),
        in_cat_type(i),
        in_chr_id(i),
        in_cle_id(i),
        in_cat_id(i),
        in_dnz_chr_id(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_fulltext_yn(i),
        in_last_update_login(i),
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
        in_attribute15(i)
-- REMOVE comma from the previous line
     );

  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..l_tabsize
      INSERT INTO OKC_K_ARTICLES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        object_version_number,
        comments,
        variation_description,
        name,
      --  text,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        sav_sav_release
-- REMOVE comma from the previous line
     )
     VALUES (
        in_id(i),
        OKC_UTIL.g_language_code(lang_i),
        l_source_lang,
        in_sfwt_flag(i),
        in_object_version_number(i),
        in_comments(i),
        in_variation_description(i),
        in_name(i),
      --  in_text(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i),
        in_sav_sav_release(i)
-- REMOVE comma from the previous line
      );
      END LOOP;

    IF (l_debug = 'Y') THEN
       okc_debug.log('14700: Leaving INSERT_ROW_UPG', 2);
       okc_debug.Reset_Indentation;
    END IF;

EXCEPTION
  WHEN OTHERS THEN

    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 'Y') THEN
       okc_debug.log('14800: Leaving INSERT_ROW_UPG:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

   -- RAISE;

END INSERT_ROW_UPG;

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('14900: Entered create_version', 2);
    END IF;

INSERT INTO okc_k_articles_bh
  (
      major_version,
      id,
      sav_sae_id,
      sbt_code,
      cat_type,
      chr_id,
      cle_id,
      cat_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      fulltext_yn,
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
      attribute15
)
  SELECT
      p_major_version,
      id,
      sav_sae_id,
      sbt_code,
      cat_type,
      chr_id,
      cle_id,
      cat_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      fulltext_yn,
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
      attribute15
  FROM okc_k_articles_b
WHERE dnz_chr_id = p_chr_id;

--------------------------------
-- Versioning TL Table
-------------------------------

INSERT INTO okc_k_articles_tlh
  (
      major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      object_version_number,
      comments,
      variation_description,
      name,
      text,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      sav_sav_release
)
  SELECT
      p_major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      object_version_number,
      comments,
      variation_description,
      name,
      text,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      sav_sav_release
  FROM okc_k_articles_tl
 WHERE id in (select id from okc_k_articles_b
			where dnz_chr_id = p_chr_id);

    IF (l_debug = 'Y') THEN
       okc_debug.log('15000: Leaving create_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('15100: Leaving create_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAT_PVT');
       okc_debug.log('15200: Entered restore_version', 2);
    END IF;

INSERT INTO okc_k_articles_tl
  (
      id,
      language,
      source_lang,
      sfwt_flag,
      object_version_number,
      comments,
      variation_description,
      name,
      text,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      sav_sav_release
)
  SELECT
      id,
      language,
      source_lang,
      sfwt_flag,
      object_version_number,
      comments,
      variation_description,
      name,
      text,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      sav_sav_release
  FROM okc_k_articles_tlh
WHERE id in (SELECT id
			FROM okc_k_articles_bh
		    WHERE dnz_chr_id = p_chr_id)
  AND major_version = p_major_version;

-----------------------------------------
-- Restoring Base Table
-----------------------------------------

INSERT INTO okc_k_articles_b
  (
      id,
      sav_sae_id,
      sbt_code,
      cat_type,
      chr_id,
      cle_id,
      cat_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      fulltext_yn,
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
      attribute15
)
  SELECT
      id,
      sav_sae_id,
      sbt_code,
      cat_type,
      chr_id,
      cle_id,
      cat_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      fulltext_yn,
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
      attribute15
  FROM okc_k_articles_bh
WHERE dnz_chr_id = p_chr_id
  AND major_version = p_major_version;

    IF (l_debug = 'Y') THEN
       okc_debug.log('15300: Leaving restore_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('15400: Leaving restore_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END restore_version;

END OKC_CAT_PVT;

/
