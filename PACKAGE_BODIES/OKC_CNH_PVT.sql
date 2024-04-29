--------------------------------------------------------
--  DDL for Package Body OKC_CNH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CNH_PVT" AS
/* $Header: OKCSCNHB.pls 120.0 2005/05/25 19:34:59 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  l_lang     VARCHAR2(12) := okc_util.get_userenv_lang;
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

    DELETE FROM OKC_CONDITION_HEADERS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_CONDITION_HEADERS_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_CONDITION_HEADERS_TL T SET (
        NAME,
        DESCRIPTION,
        SHORT_DESCRIPTION,
        COMMENTS) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION,
                                  B.SHORT_DESCRIPTION,
                                  B.COMMENTS
                                FROM OKC_CONDITION_HEADERS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_CONDITION_HEADERS_TL SUBB, OKC_CONDITION_HEADERS_TL SUBT
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

    INSERT INTO OKC_CONDITION_HEADERS_TL (
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
        FROM OKC_CONDITION_HEADERS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_CONDITION_HEADERS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
    DELETE FROM OKC_CONDITION_HEADERS_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_CONDITION_HEADERS_BH B
         WHERE B.ID = T.ID
         AND B.MAJOR_VERSION = T.MAJOR_VERSION
        );
    UPDATE OKC_CONDITION_HEADERS_TLH T SET (
        NAME,
        DESCRIPTION,
        SHORT_DESCRIPTION,
        COMMENTS) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION,
                                  B.SHORT_DESCRIPTION,
                                  B.COMMENTS
                                FROM OKC_CONDITION_HEADERS_TLH B
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
                FROM OKC_CONDITION_HEADERS_TLH SUBB, OKC_CONDITION_HEADERS_TLH SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
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
    INSERT INTO OKC_CONDITION_HEADERS_TLH (
        ID,
        LANGUAGE,
        MAJOR_VERSION,
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
            B.MAJOR_VERSION,
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
        FROM OKC_CONDITION_HEADERS_TLH B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_CONDITION_HEADERS_TLH T
                     WHERE T.ID = B.ID
                       AND T.MAJOR_VERSION = B.MAJOR_VERSION
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );



  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CONDITION_HEADERS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cnh_rec                      IN cnh_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cnh_rec_type IS
    CURSOR okc_condition_headers_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ACN_ID,
            COUNTER_GROUP_ID,
            ONE_TIME_YN,
            BEFORE_AFTER,
            CNH_VARIANCE,
            CONDITION_VALID_YN,
            TRACKED_YN,
            DATE_ACTIVE,
            DATE_INACTIVE,
            CNH_TYPE,
            TEMPLATE_YN,
            DNZ_CHR_ID,
            OBJECT_ID,
            JTOT_OBJECT_CODE,
            OBJECT_VERSION_NUMBER,
            TASK_OWNER_ID,
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
            SEEDED_FLAG,
		  LAST_RUNDATE
      FROM Okc_Condition_Headers_B
     WHERE okc_condition_headers_b.id = p_id;
    l_okc_condition_headers_b_pk   okc_condition_headers_b_pk_csr%ROWTYPE;
    l_cnh_rec                      cnh_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_condition_headers_b_pk_csr (p_cnh_rec.id);
    FETCH okc_condition_headers_b_pk_csr INTO
              l_cnh_rec.ID,
              l_cnh_rec.ACN_ID,
              l_cnh_rec.COUNTER_GROUP_ID,
              l_cnh_rec.ONE_TIME_YN,
              l_cnh_rec.BEFORE_AFTER,
              l_cnh_rec.CNH_VARIANCE,
              l_cnh_rec.CONDITION_VALID_YN,
              l_cnh_rec.TRACKED_YN,
              l_cnh_rec.DATE_ACTIVE,
              l_cnh_rec.DATE_INACTIVE,
              l_cnh_rec.CNH_TYPE,
              l_cnh_rec.TEMPLATE_YN,
              l_cnh_rec.DNZ_CHR_ID,
              l_cnh_rec.OBJECT_ID,
              l_cnh_rec.JTOT_OBJECT_CODE,
              l_cnh_rec.OBJECT_VERSION_NUMBER,
              l_cnh_rec.TASK_OWNER_ID,
              l_cnh_rec.CREATED_BY,
              l_cnh_rec.CREATION_DATE,
              l_cnh_rec.LAST_UPDATED_BY,
              l_cnh_rec.LAST_UPDATE_DATE,
              l_cnh_rec.LAST_UPDATE_LOGIN,
              l_cnh_rec.ATTRIBUTE_CATEGORY,
              l_cnh_rec.ATTRIBUTE1,
              l_cnh_rec.ATTRIBUTE2,
              l_cnh_rec.ATTRIBUTE3,
              l_cnh_rec.ATTRIBUTE4,
              l_cnh_rec.ATTRIBUTE5,
              l_cnh_rec.ATTRIBUTE6,
              l_cnh_rec.ATTRIBUTE7,
              l_cnh_rec.ATTRIBUTE8,
              l_cnh_rec.ATTRIBUTE9,
              l_cnh_rec.ATTRIBUTE10,
              l_cnh_rec.ATTRIBUTE11,
              l_cnh_rec.ATTRIBUTE12,
              l_cnh_rec.ATTRIBUTE13,
              l_cnh_rec.ATTRIBUTE14,
              l_cnh_rec.ATTRIBUTE15,
              l_cnh_rec.APPLICATION_ID,
              l_cnh_rec.SEEDED_FLAG,
		    l_cnh_rec.LAST_RUNDATE;
    x_no_data_found := okc_condition_headers_b_pk_csr%NOTFOUND;
    CLOSE okc_condition_headers_b_pk_csr;
    RETURN(l_cnh_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cnh_rec                      IN cnh_rec_type
  ) RETURN cnh_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cnh_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CONDITION_HEADERS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_condition_headers_tl_rec IN OkcConditionHeadersTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OkcConditionHeadersTlRecType IS
    CURSOR okc_condition_header1_csr (p_id                 IN NUMBER,
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
      FROM Okc_Condition_Headers_Tl
     WHERE okc_condition_headers_tl.id = p_id
       AND okc_condition_headers_tl.language = p_language;
    l_okc_condition_headers_tl_pk  okc_condition_header1_csr%ROWTYPE;
    l_okc_condition_headers_tl_rec OkcConditionHeadersTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_condition_header1_csr (p_okc_condition_headers_tl_rec.id,
                                    p_okc_condition_headers_tl_rec.language);
    FETCH okc_condition_header1_csr INTO
              l_okc_condition_headers_tl_rec.ID,
              l_okc_condition_headers_tl_rec.LANGUAGE,
              l_okc_condition_headers_tl_rec.SOURCE_LANG,
              l_okc_condition_headers_tl_rec.SFWT_FLAG,
              l_okc_condition_headers_tl_rec.NAME,
              l_okc_condition_headers_tl_rec.DESCRIPTION,
              l_okc_condition_headers_tl_rec.SHORT_DESCRIPTION,
              l_okc_condition_headers_tl_rec.COMMENTS,
              l_okc_condition_headers_tl_rec.CREATED_BY,
              l_okc_condition_headers_tl_rec.CREATION_DATE,
              l_okc_condition_headers_tl_rec.LAST_UPDATED_BY,
              l_okc_condition_headers_tl_rec.LAST_UPDATE_DATE,
              l_okc_condition_headers_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_condition_header1_csr%NOTFOUND;
    CLOSE okc_condition_header1_csr;
    RETURN(l_okc_condition_headers_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_condition_headers_tl_rec IN OkcConditionHeadersTlRecType
  ) RETURN OkcConditionHeadersTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_condition_headers_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CONDITION_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cnhv_rec                     IN cnhv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cnhv_rec_type IS
    CURSOR okc_cnhv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            ACN_ID,
            COUNTER_GROUP_ID,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            COMMENTS,
            ONE_TIME_YN,
            NAME,
            CONDITION_VALID_YN,
            BEFORE_AFTER,
            TRACKED_YN,
            CNH_VARIANCE,
            DNZ_CHR_ID,
            TEMPLATE_YN,
            DATE_ACTIVE,
            OBJECT_ID,
            DATE_INACTIVE,
            JTOT_OBJECT_CODE,
            TASK_OWNER_ID,
            CNH_TYPE,
            APPLICATION_ID,
            SEEDED_FLAG,
		  LAST_RUNDATE,
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
      FROM Okc_Condition_Headers_V
     WHERE okc_condition_headers_v.id = p_id;
    l_okc_cnhv_pk                  okc_cnhv_pk_csr%ROWTYPE;
    l_cnhv_rec                     cnhv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cnhv_pk_csr (p_cnhv_rec.id);
    FETCH okc_cnhv_pk_csr INTO
              l_cnhv_rec.ID,
              l_cnhv_rec.OBJECT_VERSION_NUMBER,
              l_cnhv_rec.SFWT_FLAG,
              l_cnhv_rec.ACN_ID,
              l_cnhv_rec.COUNTER_GROUP_ID,
              l_cnhv_rec.DESCRIPTION,
              l_cnhv_rec.SHORT_DESCRIPTION,
              l_cnhv_rec.COMMENTS,
              l_cnhv_rec.ONE_TIME_YN,
              l_cnhv_rec.NAME,
              l_cnhv_rec.CONDITION_VALID_YN,
              l_cnhv_rec.BEFORE_AFTER,
              l_cnhv_rec.TRACKED_YN,
              l_cnhv_rec.CNH_VARIANCE,
              l_cnhv_rec.DNZ_CHR_ID,
              l_cnhv_rec.TEMPLATE_YN,
              l_cnhv_rec.DATE_ACTIVE,
              l_cnhv_rec.OBJECT_ID,
              l_cnhv_rec.DATE_INACTIVE,
              l_cnhv_rec.JTOT_OBJECT_CODE,
              l_cnhv_rec.TASK_OWNER_ID,
              l_cnhv_rec.CNH_TYPE,
              l_cnhv_rec.APPLICATION_ID,
              l_cnhv_rec.SEEDED_FLAG,
		    l_cnhv_rec.LAST_RUNDATE,
              l_cnhv_rec.ATTRIBUTE_CATEGORY,
              l_cnhv_rec.ATTRIBUTE1,
              l_cnhv_rec.ATTRIBUTE2,
              l_cnhv_rec.ATTRIBUTE3,
              l_cnhv_rec.ATTRIBUTE4,
              l_cnhv_rec.ATTRIBUTE5,
              l_cnhv_rec.ATTRIBUTE6,
              l_cnhv_rec.ATTRIBUTE7,
              l_cnhv_rec.ATTRIBUTE8,
              l_cnhv_rec.ATTRIBUTE9,
              l_cnhv_rec.ATTRIBUTE10,
              l_cnhv_rec.ATTRIBUTE11,
              l_cnhv_rec.ATTRIBUTE12,
              l_cnhv_rec.ATTRIBUTE13,
              l_cnhv_rec.ATTRIBUTE14,
              l_cnhv_rec.ATTRIBUTE15,
              l_cnhv_rec.CREATED_BY,
              l_cnhv_rec.CREATION_DATE,
              l_cnhv_rec.LAST_UPDATED_BY,
              l_cnhv_rec.LAST_UPDATE_DATE,
              l_cnhv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cnhv_pk_csr%NOTFOUND;
    CLOSE okc_cnhv_pk_csr;
    RETURN(l_cnhv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cnhv_rec                     IN cnhv_rec_type
  ) RETURN cnhv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cnhv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_CONDITION_HEADERS_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cnhv_rec	IN cnhv_rec_type
  ) RETURN cnhv_rec_type IS
    l_cnhv_rec	cnhv_rec_type := p_cnhv_rec;
  BEGIN
    IF (l_cnhv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.object_version_number := NULL;
    END IF;
    IF (l_cnhv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_cnhv_rec.acn_id = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.acn_id := NULL;
    END IF;
    IF (l_cnhv_rec.counter_group_id = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.counter_group_id := NULL;
    END IF;
    IF (l_cnhv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.description := NULL;
    END IF;
    IF (l_cnhv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.short_description := NULL;
    END IF;
    IF (l_cnhv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.comments := NULL;
    END IF;
    IF (l_cnhv_rec.one_time_yn = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.one_time_yn := NULL;
    END IF;
    IF (l_cnhv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.name := NULL;
    END IF;
    IF (l_cnhv_rec.condition_valid_yn = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.condition_valid_yn := NULL;
    END IF;
    IF (l_cnhv_rec.before_after = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.before_after := NULL;
    END IF;
    IF (l_cnhv_rec.tracked_yn = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.tracked_yn := NULL;
    END IF;
    IF (l_cnhv_rec.cnh_variance = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.cnh_variance := NULL;
    END IF;
    IF (l_cnhv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_cnhv_rec.template_yn = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.template_yn := NULL;
    END IF;
    IF (l_cnhv_rec.date_active = OKC_API.G_MISS_DATE) THEN
      l_cnhv_rec.date_active := NULL;
    END IF;
    IF (l_cnhv_rec.object_id = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.object_id := NULL;
    END IF;
    IF (l_cnhv_rec.date_inactive = OKC_API.G_MISS_DATE) THEN
      l_cnhv_rec.date_inactive := NULL;
    END IF;
    IF (l_cnhv_rec.jtot_object_code = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.jtot_object_code := NULL;
    END IF;
    IF (l_cnhv_rec.task_owner_id = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.task_owner_id := NULL;
    END IF;
    IF (l_cnhv_rec.cnh_type = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.cnh_type := NULL;
    END IF;
    IF (l_cnhv_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.application_id := NULL;
    END IF;
    IF (l_cnhv_rec.seeded_flag = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.seeded_flag := NULL;
    END IF;
    IF (l_cnhv_rec.last_rundate = OKC_API.G_MISS_DATE) THEN
      l_cnhv_rec.last_rundate := NULL;
    END IF;
    IF (l_cnhv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute_category := NULL;
    END IF;
    IF (l_cnhv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute1 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute2 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute3 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute4 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute5 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute6 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute7 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute8 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute9 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute10 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute11 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute12 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute13 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute14 := NULL;
    END IF;
    IF (l_cnhv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_cnhv_rec.attribute15 := NULL;
    END IF;
    IF (l_cnhv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.created_by := NULL;
    END IF;
    IF (l_cnhv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cnhv_rec.creation_date := NULL;
    END IF;
    IF (l_cnhv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cnhv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cnhv_rec.last_update_date := NULL;
    END IF;
    IF (l_cnhv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_cnhv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cnhv_rec);
  END null_out_defaults;

  /******** Commented out nocopy generated code in favor of hand written code *****
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_CONDITION_HEADERS_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cnhv_rec IN  cnhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_cnhv_rec.id = OKC_API.G_MISS_NUM OR
       p_cnhv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnhv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_cnhv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnhv_rec.acn_id = OKC_API.G_MISS_NUM OR
          p_cnhv_rec.acn_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'acn_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnhv_rec.one_time_yn = OKC_API.G_MISS_CHAR OR
          p_cnhv_rec.one_time_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'one_time_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnhv_rec.name = OKC_API.G_MISS_CHAR OR
          p_cnhv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnhv_rec.condition_valid_yn = OKC_API.G_MISS_CHAR OR
          p_cnhv_rec.condition_valid_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'condition_valid_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnhv_rec.tracked_yn = OKC_API.G_MISS_CHAR OR
          p_cnhv_rec.tracked_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'tracked_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnhv_rec.template_yn = OKC_API.G_MISS_CHAR OR
          p_cnhv_rec.template_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'template_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnhv_rec.date_active = OKC_API.G_MISS_DATE OR
          p_cnhv_rec.date_active IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_active');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnhv_rec.cnh_type = OKC_API.G_MISS_CHAR OR
          p_cnhv_rec.cnh_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cnh_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKC_CONDITION_HEADERS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_cnhv_rec IN cnhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_cnhv_rec IN cnhv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
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
      CURSOR okx_counter_groups_v_pk_csr (p_counter_group_id   IN NUMBER) IS
      SELECT
              COUNTER_GROUP_ID,
              NAME,
              DESCRIPTION,
              TEMPLATE_FLAG,
              START_DATE_ACTIVE,
              END_DATE_ACTIVE,
              ASSOCIATION_TYPE,
              SOURCE_OBJECT_CODE,
              SOURCE_OBJECT_ID,
              CREATED_FROM_CTR_GRP_TMPL_ID,
              SOURCE_COUNTER_GROUP_ID
        FROM Okx_Counter_Groups_V
       WHERE okx_counter_groups_v.counter_group_id = p_counter_group_id;
      l_okx_counter_groups_v_pk      okx_counter_groups_v_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_cnhv_rec.ACN_ID IS NOT NULL)
      THEN
        OPEN okc_acnv_pk_csr(p_cnhv_rec.ACN_ID);
        FETCH okc_acnv_pk_csr INTO l_okc_acnv_pk;
        l_row_notfound := okc_acnv_pk_csr%NOTFOUND;
        CLOSE okc_acnv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ACN_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_cnhv_rec.COUNTER_GROUP_ID IS NOT NULL)
      THEN
        OPEN okx_counter_groups_v_pk_csr(p_cnhv_rec.COUNTER_GROUP_ID);
        FETCH okx_counter_groups_v_pk_csr INTO l_okx_counter_groups_v_pk;
        l_row_notfound := okx_counter_groups_v_pk_csr%NOTFOUND;
        CLOSE okx_counter_groups_v_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'COUNTER_GROUP_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_cnhv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ******* End Commented out nocopy generated code in favor of hand written code ***/

  /****************Begin Hand Written Code ********************************/

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Acn_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_acn_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_acn_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnhv_rec      IN     cnhv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_temp                  NUMBER       ;
    acn_rec                 VARCHAR2(1);
    CURSOR acn_cur IS
    SELECT 'X' FROM okc_actions_v acn
    WHERE acn.id = p_cnhv_rec.acn_id;
    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
   IF (p_cnhv_rec.acn_id IS NULL) OR
       (p_cnhv_rec.acn_id = OKC_API.G_MISS_NUM)
   THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_required_value
		          ,p_token1        => g_col_name_token
	       	          ,p_token1_value  => 'acn_id');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSE
     OPEN acn_cur;
     FETCH acn_cur INTO acn_rec;
       IF acn_cur%NOTFOUND THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_required_value
          	          ,p_token1        => g_col_name_token
	       	          ,p_token1_value  => 'acn_id');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
     CLOSE acn_cur;
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
END Validate_Acn_id;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_counter_group_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_counter_group_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_counter_group_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnhv_rec      IN     cnhv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_temp                  NUMBER       ;
    CURSOR cgp_cur IS
    SELECT 'X' FROM okx_counter_groups_v cgp
    WHERE cgp.counter_group_id = p_cnhv_rec.counter_group_id;
    cgp_rec  cgp_cur%ROWTYPE;
    CURSOR acn_cur IS
    SELECT acn.counter_action_yn counter_action_yn
    FROM   okc_actions_b acn,
	   okc_condition_headers_b cnh
    WHERE  acn.id = cnh.acn_id
    AND    cnh.id = p_cnhv_rec.id;
    acn_rec  acn_cur%ROWTYPE;
    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_cnhv_rec.counter_group_id IS NOT NULL OR
       p_cnhv_rec.counter_group_id <> OKC_API.G_MISS_NUM THEN
      OPEN cgp_cur;
      FETCH cgp_cur INTO cgp_rec;
        IF cgp_cur%NOTFOUND THEN
          OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
		          ,p_token1        => g_col_name_token
	       	          ,p_token1_value  => 'counter_group_id');
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

          -- halt further validation of this column
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
     CLOSE cgp_cur;

     OPEN acn_cur;
     FETCH acn_cur INTO acn_rec;
       IF acn_rec.counter_action_yn = 'N' THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
		          ,p_token1        => g_col_name_token
	       	          ,p_token1_value  => 'counter_group_id');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
     CLOSE acn_cur;
   ELSIF p_cnhv_rec.counter_group_id IS  NULL OR
          p_cnhv_rec.counter_group_id = OKC_API.G_MISS_NUM THEN
          OPEN acn_cur;
          FETCH acn_cur INTO acn_rec;
          IF acn_rec.counter_action_yn = 'Y' THEN
            OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                               ,p_msg_name      => g_required_value
		               ,p_token1        => g_col_name_token
	       	               ,p_token1_value  => 'counter_group_id');
            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

            -- halt further validation of this column
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
          CLOSE acn_cur;
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
END Validate_counter_group_id;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Task_Owner_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_Task_Owner_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments : Validation is required for foreign key check
    ---------------------------------------------------------------------------

  PROCEDURE Validate_Task_Owner_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnhv_rec      IN     cnhv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
       -- initialize return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       -- data is required when tracked_yn is 'Y'
    IF p_cnhv_rec.tracked_yn  = 'Y'
    THEN
      IF (p_cnhv_rec.task_owner_id IS NULL) OR
         (p_cnhv_rec.task_owner_id = OKC_API.G_MISS_NUM)
      THEN
        OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'task_owner_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

/**** Validation is required for foreign key check ************/

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
  END Validate_Task_Owner_id;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Object_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_Object_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

  PROCEDURE Validate_Object_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnhv_rec      IN     cnhv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_temp                  NUMBER       ;

    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    NULL;

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
  END Validate_Object_id;

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
                              ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnhv_rec.sfwt_flag IS NULL) OR
       (p_cnhv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
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
   IF (p_cnhv_rec.sfwt_flag) <> UPPER(p_cnhv_rec.sfwt_flag) THEN
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                          ,p_msg_name         => g_uppercase_required
                          ,p_token1           => g_col_name_token
                          ,p_token1_value     => 'sfwt_flag');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_cnhv_rec.sfwt_flag) NOT IN ('Y','N')) THEN
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
    	p_cnhv_rec              IN cnhv_rec_type) IS
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	-- Check if seeded_flag is Y or N
	IF UPPER(p_cnhv_rec.seeded_flag) NOT IN ('Y', 'N') THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	IF p_cnhv_rec.seeded_flag <> UPPER(p_cnhv_rec.seeded_flag) THEN
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
    	p_cnhv_rec          IN cnhv_rec_type) IS
	Cursor application_id_cur(p_application_id IN NUMBER) IS
	select '1'
	from fnd_application
	where application_id = p_application_id;
	l_dummy		VARCHAR2(1) := '?';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_cnhv_rec.application_id IS NOT NULL THEN
	--Check if application id exists in the fnd_application or not
	OPEN application_id_cur(p_cnhv_rec.application_id);
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
                         ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnhv_rec.name IS NULL) OR
       (p_cnhv_rec.name = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'name');

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

  END Validate_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_condition_valid_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_condition_valid_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_condition_valid_YN(x_return_status OUT NOCOPY     VARCHAR2
                               ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnhv_rec.condition_valid_yn IS NULL) OR
       (p_cnhv_rec.condition_valid_yn = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'condition_valid_yn');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if condition_valid_yn is in uppercase
    IF (p_cnhv_rec.condition_valid_yn) <> UPPER(p_cnhv_rec.condition_valid_yn) THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'condition_valid_yn');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_cnhv_rec.condition_valid_yn) NOT IN ('Y','N')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'condition_valid_yn');
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

  END Validate_condition_valid_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tracked_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Tracked_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Tracked_YN(x_return_status OUT NOCOPY     VARCHAR2
                               ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnhv_rec.tracked_yn IS NULL) OR
       (p_cnhv_rec.tracked_yn = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'tracked_yn');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if tracked_yn is in uppercase
    IF (p_cnhv_rec.tracked_yn) <> UPPER(p_cnhv_rec.tracked_yn) THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'tracked_yn');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_cnhv_rec.tracked_yn) NOT IN ('Y','N')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'tracked_yn');
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

  END Validate_tracked_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Template_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Template_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Template_YN(x_return_status OUT NOCOPY     VARCHAR2
                               ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnhv_rec.template_yn IS NULL) OR
       (p_cnhv_rec.template_yn = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'template_yn');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if template_yn is in uppercase
    IF (p_cnhv_rec.template_yn) <> UPPER(p_cnhv_rec.template_yn) THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'template_yn');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_cnhv_rec.template_yn) NOT IN ('Y','N')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'template_yn');
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

  END Validate_Template_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_One_Time_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_one_time_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_One_Time_YN(x_return_status OUT NOCOPY     VARCHAR2
                                       ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required when cnh_type is 'ABC'
    IF (p_cnhv_rec.one_time_yn IS  NULL) OR
       (p_cnhv_rec.one_time_yn = OKC_API.G_MISS_CHAR) THEN
       IF (p_cnhv_rec.cnh_type = 'ABC') THEN
         OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                            ,p_msg_name        => g_required_value
                            ,p_token1          => g_col_name_token
                            ,p_token1_value    => 'one_time_yn');

         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;

         -- halt further validation of this column
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;

    IF (p_cnhv_rec.one_time_yn IS NOT  NULL) OR
       (p_cnhv_rec.one_time_yn <> OKC_API.G_MISS_CHAR)
    THEN
      -- check if one_time_yn is in uppercase
      IF (p_cnhv_rec.one_time_yn) <> UPPER(p_cnhv_rec.one_time_yn)
      THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'one_time_yn');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;

      -- verify that data is within allowable values
      ELSIF (UPPER(p_cnhv_rec.one_time_yn) NOT IN ('Y','N')) THEN
        OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'one_time_yn');
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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

  END Validate_One_Time_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Cnh_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Cnh_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Cnh_Type(x_return_status OUT NOCOPY     VARCHAR2
                             ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_acn_type              okc_actions_v.acn_type%TYPE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnhv_rec.cnh_type IS NULL) OR
       (p_cnhv_rec.cnh_type = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'cnh_type');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if cnh_type is in uppercase
    IF (p_cnhv_rec.cnh_type) <> UPPER(p_cnhv_rec.cnh_type)
    THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'cnh_type');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_cnhv_rec.cnh_type) NOT IN ('ABC','DBC')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'cnh_type');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify if cnh_type corresponds to acn_type
    IF p_cnhv_rec.cnh_type = 'ABC' THEN
      select acn.acn_type into l_acn_type from okc_actions_v acn
      where acn.id = p_cnhv_rec.acn_id;
      IF l_acn_type <> 'ABA' THEN
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSIF p_cnhv_rec.cnh_type = 'DBC' THEN
      select acn.acn_type into l_acn_type from okc_actions_v acn
      where acn.id = p_cnhv_rec.acn_id;
      IF l_acn_type <> 'DBA' THEN
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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

  END Validate_Cnh_Type;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Before_After
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Before_After
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Before_After(x_return_status OUT NOCOPY     VARCHAR2
                             ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required when cnh_type is 'DBC'
    IF p_cnhv_rec.cnh_type = 'DBC'
    THEN
      IF (p_cnhv_rec.before_after IS NULL) OR
         (p_cnhv_rec.before_after = OKC_API.G_MISS_CHAR)
      THEN
        OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'before_after');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSIF
      p_cnhv_rec.cnh_type = 'ABC'
      THEN
      IF (p_cnhv_rec.before_after IS NOT NULL) OR
         (p_cnhv_rec.before_after <> OKC_API.G_MISS_CHAR)
      THEN
        OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'before_after');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    -- check if before_after is in uppercase
    IF (p_cnhv_rec.before_after) <> UPPER(p_cnhv_rec.before_after)
    THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'before_after');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_cnhv_rec.before_after) NOT IN ('B','A')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'before_after');
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

  END Validate_Before_After;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Cnh_Variance
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Cnh_Variance
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Cnh_Variance(x_return_status OUT NOCOPY     VARCHAR2
                             ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required when cnh_type is 'DBC'
    IF p_cnhv_rec.cnh_type = 'DBC'
    THEN
      IF (p_cnhv_rec.cnh_variance IS NULL) OR
         (p_cnhv_rec.cnh_variance = OKC_API.G_MISS_NUM)
      THEN
      -- pnayani  11-AUG-2004 Bug#3824277 changed the message for cnh_variance
        OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        =>'OKC_NUM_DAYS_REQUIRED'
                         );

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSIF
      p_cnhv_rec.cnh_type = 'ABC'
      THEN
      IF (p_cnhv_rec.cnh_variance IS NOT NULL) OR
         (p_cnhv_rec.cnh_variance <> OKC_API.G_MISS_NUM)
      THEN
        OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'cnh_variance');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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

  END Validate_Cnh_Variance;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_date_active
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure date_active  : Validate_Date_Active
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_date_active(x_return_status OUT NOCOPY     VARCHAR2
                         ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  CURSOR cnh_cur IS
  SELECT 'X'
  FROM okc_condition_headers_v cnh
  WHERE cnh.id = p_cnhv_rec.id;
  cnh_rec    cnh_cur%ROWTYPE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnhv_rec.date_active IS NULL) OR
       (p_cnhv_rec.date_active = OKC_API.G_MISS_DATE)
    THEN
      OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'date_active');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSIF TRUNC(p_cnhv_rec.date_active) < TRUNC(SYSDATE)
     THEN OPEN cnh_cur;
       IF cnh_cur%NOTFOUND THEN
         OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                         ,p_msg_name        => g_invalid_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'date_active');

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

  END Validate_date_active;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_date_inactive
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure date_inactive  : Validate_Date_Inactive
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_date_inactive(x_return_status OUT NOCOPY     VARCHAR2
                         ,p_cnhv_rec      IN      cnhv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;


    -- check for data before processing
    IF p_cnhv_rec.date_inactive IS NOT NULL OR
       p_cnhv_rec.date_inactive <> OKC_API.G_MISS_DATE THEN
       IF TRUNC(p_cnhv_rec.date_inactive) < TRUNC(p_cnhv_rec.date_active) THEN

         OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                            ,p_msg_name       => g_invalid_value
                            ,p_token1         => g_col_name_token
                            ,p_token1_value   => 'date_inactive');

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

  END Validate_date_inactive;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Cnh_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Cnh_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Cnh_Record(x_return_status OUT NOCOPY     VARCHAR2
                                      ,p_cnhv_rec      IN      cnhv_rec_type) IS


  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  --l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_dummy                 VARCHAR2(1);
  l_row_found             Boolean := False;
  CURSOR c1 IS
  SELECT 'x'
  FROM okc_condition_headers_v
  WHERE  name = p_cnhv_rec.name
  AND    object_id = p_cnhv_rec.object_id
  AND   jtot_object_code = p_cnhv_rec.jtot_object_code
  AND   id <> nvl(p_cnhv_rec.id,-99999);

  CURSOR c2 is
  SELECT 'x'
  FROM okc_condition_headers_v
  WHERE  name = p_cnhv_rec.name
  AND    object_id is null
  AND   jtot_object_code is null
  AND   id <> nvl(p_cnhv_rec.id,-99999);

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  /*Bug 1636056:The following code commented out nocopy since it was not using bind
	    variables and parsing was taking place.Replaced with explicit cursor
	    as above

    l_unq_tbl(1).p_col_name   := 'name';
    l_unq_tbl(1).p_col_val    := p_cnhv_rec.name;
    l_unq_tbl(2).p_col_name   := 'object_id';
    l_unq_tbl(2).p_col_val    := p_cnhv_rec.object_id;
    l_unq_tbl(3).p_col_name   := 'jtot_object_code';
    l_unq_tbl(3).p_col_val    := p_cnhv_rec.jtot_object_code;
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

      -- call check_comp_unique utility
      OKC_UTIL.CHECK_COMP_UNIQUE(p_view_name   => 'OKC_CONDITION_HEADERS_V'
                           ,p_col_tbl          => l_unq_tbl
                           ,p_id               => p_cnhv_rec.id
                           ,x_return_status    => l_return_status);


      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
	 */
	 IF p_cnhv_rec.OBJECT_ID IS NOT NULL AND
		p_cnhv_rec.JTOT_OBJECT_CODE IS NOT NULL
	 THEN
    OPEN c1;
    FETCH c1 into l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    ELSE
	 OPEN c2;
	 FETCH c2 into l_dummy;
    l_row_found := c2%FOUND;
    CLOSE c2;
    END IF;
    IF l_row_found then
	--OKC_API.set_message(G_APP_NAME,G_UNQS,G_COL_NAME_TOKEN1,'name',G_COL_NAME_TOKEN2,'object_id',G_COL_NAME_TOKEN3,'jtot_object_code');
	OKC_API.set_message(G_APP_NAME,G_UNQS);
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

  END Validate_Unique_Cnh_Record;

 ---------------------------------------------------------------------------
 -- FUNCTION Validate_Foreign_Keys
 ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Function Name   : Validate_Foreign_Keys
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
 ---------------------------------------------------------------------------
    FUNCTION Validate_Foreign_Keys (p_cnhv_rec IN cnhv_rec_type)
    RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;

      CURSOR okc_acnv_pk_csr (p_id  IN NUMBER) IS
      SELECT  '1'
	 FROM Okc_Actions_V
      WHERE okc_actions_v.id = p_id;
      l_dummy_var                    VARCHAR2(1);
      l_dummy                        VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

      BEGIN
        IF (p_cnhv_rec.ACN_ID IS NOT NULL)
        THEN
          OPEN okc_acnv_pk_csr(p_cnhv_rec.ACN_ID);
          FETCH okc_acnv_pk_csr INTO l_dummy_var;
          l_row_notfound := okc_acnv_pk_csr%NOTFOUND;
          CLOSE okc_acnv_pk_csr;
          IF (l_row_notfound) THEN
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ACN_ID');
            RAISE item_not_found_error;
          END IF;
        END IF;
        RETURN (l_return_status);
     EXCEPTION
	WHEN item_not_found_error THEN
	  l_return_status := OKC_API.G_RET_STS_ERROR;
	  RETURN (l_return_status);
     END Validate_Foreign_Keys;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_CONDITION_HEADERS_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cnhv_rec IN  cnhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call each column-level validation

    -- Validate Sfwt_Flag
    Validate_Sfwt_Flag(x_return_status,p_cnhv_rec);
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
    Validate_Seeded_Flag(x_return_status,p_cnhv_rec);
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

    -- Validate application_id
    Validate_application_id(x_return_status,p_cnhv_rec);
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


    -- Validate Acn_Id
    Validate_Acn_Id(x_return_status,p_cnhv_rec);
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

    -- Validate Counter_Group_Id
    Validate_Counter_Group_Id(x_return_status,p_cnhv_rec);
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

    -- Validate One_Time_YN
    Validate_One_Time_YN(x_return_status,p_cnhv_rec);
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
    Validate_Name(x_return_status,p_cnhv_rec);
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

    -- Validate Condition_Valid_YN
    Validate_Condition_Valid_YN(x_return_status,p_cnhv_rec);
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

    -- Validate Before_After
    Validate_Before_After(x_return_status,p_cnhv_rec);
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

    -- Validate Template_YN
    Validate_Template_YN(x_return_status,p_cnhv_rec);
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

    -- Validate Tracked_YN
    Validate_Tracked_YN(x_return_status,p_cnhv_rec);
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

    -- Validate Cnh_Variance
    Validate_Cnh_Variance(x_return_status,p_cnhv_rec);
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

    -- Validate Date_Active
    Validate_Date_Active(x_return_status,p_cnhv_rec);
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

    -- Validate Date_Inactive
    Validate_Date_Inactive(x_return_status,p_cnhv_rec);
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

    -- Validate Task_Owner_id
    Validate_Task_Owner_id(x_return_status,p_cnhv_rec);
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

    -- Validate Object_Id
    Validate_Object_id(x_return_status,p_cnhv_rec);
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

    -- Validate Cnh_Type
    Validate_Cnh_Type(x_return_status,p_cnhv_rec);
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

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKC_CONDITION_HEADERS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_cnhv_rec IN cnhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := validate_foreign_keys (p_cnhv_rec);
    IF p_cnhv_rec.date_inactive IS NOT NULL OR
       p_cnhv_rec.date_inactive <> OKC_API.G_MISS_DATE THEN
	 IF TRUNC(p_cnhv_rec.date_inactive) < TRUNC(p_cnhv_rec.date_active) THEN
           OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                               ,p_msg_name        => g_invalid_value
                               ,p_token1          => g_col_name_token
                               ,p_token1_value    => 'date_inactive');

           -- notify caller of an error
           l_return_status := OKC_API.G_RET_STS_ERROR;
           -- halt further validation of this column
           RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
    END IF;
/*
    -- Validate_Unique_Cnh_Record
    Validate_Unique_Cnh_Record(x_return_status,p_cnhv_rec);
    l_return_status := x_return_status;
    -- store the highest degree of error
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF
	 (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*/
      RETURN (l_return_status);

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
  END Validate_Record;

  /****************End Hand Written Code **********************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cnhv_rec_type,
    p_to	OUT NOCOPY cnh_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.acn_id := p_from.acn_id;
    p_to.counter_group_id := p_from.counter_group_id;
    p_to.one_time_yn := p_from.one_time_yn;
    p_to.before_after := p_from.before_after;
    p_to.cnh_variance := p_from.cnh_variance;
    p_to.condition_valid_yn := p_from.condition_valid_yn;
    p_to.tracked_yn := p_from.tracked_yn;
    p_to.date_active := p_from.date_active;
    p_to.date_inactive := p_from.date_inactive;
    p_to.cnh_type := p_from.cnh_type;
    p_to.template_yn := p_from.template_yn;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_id := p_from.object_id;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.task_owner_id := p_from.task_owner_id;
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
    p_to.last_rundate := p_from.last_rundate;
  END migrate;
  PROCEDURE migrate (
    p_from	IN cnh_rec_type,
    p_to	IN OUT NOCOPY cnhv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.acn_id := p_from.acn_id;
    p_to.counter_group_id := p_from.counter_group_id;
    p_to.one_time_yn := p_from.one_time_yn;
    p_to.before_after := p_from.before_after;
    p_to.cnh_variance := p_from.cnh_variance;
    p_to.condition_valid_yn := p_from.condition_valid_yn;
    p_to.tracked_yn := p_from.tracked_yn;
    p_to.date_active := p_from.date_active;
    p_to.date_inactive := p_from.date_inactive;
    p_to.cnh_type := p_from.cnh_type;
    p_to.template_yn := p_from.template_yn;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_id := p_from.object_id;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.task_owner_id := p_from.task_owner_id;
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
    p_to.last_rundate := p_from.last_rundate;
  END migrate;
  PROCEDURE migrate (
    p_from	IN cnhv_rec_type,
    p_to	OUT NOCOPY OkcConditionHeadersTlRecType
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
    p_from	IN OkcConditionHeadersTlRecType,
    p_to	IN OUT NOCOPY cnhv_rec_type
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
  ----------------------------------------------
  -- validate_row for:OKC_CONDITION_HEADERS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnhv_rec                     cnhv_rec_type := p_cnhv_rec;
    l_cnh_rec                      cnh_rec_type;
    l_okc_condition_headers_tl_rec OkcConditionHeadersTlRecType;
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
    l_return_status := Validate_Attributes(l_cnhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cnhv_rec);
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
  -- PL/SQL TBL validate_row for:CNHV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnhv_tbl.COUNT > 0) THEN
      i := p_cnhv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnhv_rec                     => p_cnhv_tbl(i));
        EXIT WHEN (i = p_cnhv_tbl.LAST);
        i := p_cnhv_tbl.NEXT(i);
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
  --------------------------------------------
  -- insert_row for:OKC_CONDITION_HEADERS_B --
  --------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnh_rec                      IN cnh_rec_type,
    x_cnh_rec                      OUT NOCOPY cnh_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnh_rec                      cnh_rec_type := p_cnh_rec;
    l_def_cnh_rec                  cnh_rec_type;
    ------------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_HEADERS_B --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_cnh_rec IN  cnh_rec_type,
      x_cnh_rec OUT NOCOPY cnh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnh_rec := p_cnh_rec;
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
      p_cnh_rec,                         -- IN
      l_cnh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_CONDITION_HEADERS_B(
        id,
        acn_id,
        counter_group_id,
        one_time_yn,
        before_after,
        cnh_variance,
        condition_valid_yn,
        tracked_yn,
        date_active,
        date_inactive,
        cnh_type,
        template_yn,
        dnz_chr_id,
        object_id,
        jtot_object_code,
        object_version_number,
        task_owner_id,
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
        seeded_flag,
	   last_rundate)
      VALUES (
        l_cnh_rec.id,
        l_cnh_rec.acn_id,
        l_cnh_rec.counter_group_id,
        l_cnh_rec.one_time_yn,
        l_cnh_rec.before_after,
        l_cnh_rec.cnh_variance,
        l_cnh_rec.condition_valid_yn,
        l_cnh_rec.tracked_yn,
        l_cnh_rec.date_active,
        l_cnh_rec.date_inactive,
        l_cnh_rec.cnh_type,
        l_cnh_rec.template_yn,
        l_cnh_rec.dnz_chr_id,
        l_cnh_rec.object_id,
        l_cnh_rec.jtot_object_code,
        l_cnh_rec.object_version_number,
        l_cnh_rec.task_owner_id,
        l_cnh_rec.created_by,
        l_cnh_rec.creation_date,
        l_cnh_rec.last_updated_by,
        l_cnh_rec.last_update_date,
        l_cnh_rec.last_update_login,
        l_cnh_rec.attribute_category,
        l_cnh_rec.attribute1,
        l_cnh_rec.attribute2,
        l_cnh_rec.attribute3,
        l_cnh_rec.attribute4,
        l_cnh_rec.attribute5,
        l_cnh_rec.attribute6,
        l_cnh_rec.attribute7,
        l_cnh_rec.attribute8,
        l_cnh_rec.attribute9,
        l_cnh_rec.attribute10,
        l_cnh_rec.attribute11,
        l_cnh_rec.attribute12,
        l_cnh_rec.attribute13,
        l_cnh_rec.attribute14,
        l_cnh_rec.attribute15,
        l_cnh_rec.application_id,
        l_cnh_rec.seeded_flag,
	   l_cnh_rec.last_rundate);
    -- Set OUT values
    x_cnh_rec := l_cnh_rec;
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
  ---------------------------------------------
  -- insert_row for:OKC_CONDITION_HEADERS_TL --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_condition_headers_tl_rec  IN OkcConditionHeadersTlRecType,
    x_okc_condition_headers_tl_rec  OUT NOCOPY OkcConditionHeadersTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_condition_headers_tl_rec OkcConditionHeadersTlRecType := p_okc_condition_headers_tl_rec;
    ldefokcconditionheaderstlrec   OkcConditionHeadersTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -------------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_HEADERS_TL --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_condition_headers_tl_rec IN  OkcConditionHeadersTlRecType,
      x_okc_condition_headers_tl_rec OUT NOCOPY OkcConditionHeadersTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_condition_headers_tl_rec := p_okc_condition_headers_tl_rec;
      x_okc_condition_headers_tl_rec.LANGUAGE := l_lang;
      x_okc_condition_headers_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_condition_headers_tl_rec,    -- IN
      l_okc_condition_headers_tl_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_condition_headers_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_CONDITION_HEADERS_TL(
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
          l_okc_condition_headers_tl_rec.id,
          l_okc_condition_headers_tl_rec.language,
          l_okc_condition_headers_tl_rec.source_lang,
          l_okc_condition_headers_tl_rec.sfwt_flag,
          l_okc_condition_headers_tl_rec.name,
          l_okc_condition_headers_tl_rec.description,
          l_okc_condition_headers_tl_rec.short_description,
          l_okc_condition_headers_tl_rec.comments,
          l_okc_condition_headers_tl_rec.created_by,
          l_okc_condition_headers_tl_rec.creation_date,
          l_okc_condition_headers_tl_rec.last_updated_by,
          l_okc_condition_headers_tl_rec.last_update_date,
          l_okc_condition_headers_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_condition_headers_tl_rec := l_okc_condition_headers_tl_rec;
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
  --------------------------------------------
  -- insert_row for:OKC_CONDITION_HEADERS_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type,
    x_cnhv_rec                     OUT NOCOPY cnhv_rec_type) IS

    l_id                  NUMBER ;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnhv_rec                     cnhv_rec_type;
    l_def_cnhv_rec                 cnhv_rec_type;
    l_cnh_rec                      cnh_rec_type;
    lx_cnh_rec                     cnh_rec_type;
    l_okc_condition_headers_tl_rec OkcConditionHeadersTlRecType;
    LxOkcConditionHeadersTlRec     OkcConditionHeadersTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cnhv_rec	IN cnhv_rec_type
    ) RETURN cnhv_rec_type IS
      l_cnhv_rec	cnhv_rec_type := p_cnhv_rec;
    BEGIN
      l_cnhv_rec.CREATION_DATE := SYSDATE;
      l_cnhv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cnhv_rec.LAST_UPDATE_DATE := l_cnhv_rec.CREATION_DATE;
      l_cnhv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cnhv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cnhv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_HEADERS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_cnhv_rec IN  cnhv_rec_type,
      x_cnhv_rec OUT NOCOPY cnhv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnhv_rec := p_cnhv_rec;
      x_cnhv_rec.OBJECT_VERSION_NUMBER := 1;
      x_cnhv_rec.SFWT_FLAG := 'N';
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
    l_cnhv_rec := null_out_defaults(p_cnhv_rec);
    -- Set primary key value
    -- If condition header is created by seed then use sequence generated id
    IF l_cnhv_rec.CREATED_BY = 1 THEN
       SELECT OKC_CONDITION_HEADERS_S1.nextval INTO l_id FROM dual;
       l_cnhv_rec.ID := l_id;
       l_cnhv_rec.seeded_flag := 'Y';
    ELSE
	  l_cnhv_rec.ID := get_seq_id;
	  l_cnhv_rec.seeded_flag := 'N';
    END IF;

    --l_cnhv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cnhv_rec,                        -- IN
      l_def_cnhv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cnhv_rec := fill_who_columns(l_def_cnhv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cnhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cnhv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    /************ ADDED TO CHECK THE UNIQUENESS ***********************/

    -- Validate_Unique_Cnh_Record
    Validate_Unique_Cnh_Record(x_return_status,p_cnhv_rec);
    l_return_status := x_return_status;
    -- store the highest degree of error
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF
	 (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    /*********** ADDED TO CHECK THE UNIQUENESS *************************/

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cnhv_rec, l_cnh_rec);
    migrate(l_def_cnhv_rec, l_okc_condition_headers_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cnh_rec,
      lx_cnh_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cnh_rec, l_def_cnhv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_condition_headers_tl_rec,
      LxOkcConditionHeadersTlRec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxOkcConditionHeadersTlRec, l_def_cnhv_rec);
    -- Set OUT values
    x_cnhv_rec := l_def_cnhv_rec;
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
  -- PL/SQL TBL insert_row for:CNHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type,
    x_cnhv_tbl                     OUT NOCOPY cnhv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnhv_tbl.COUNT > 0) THEN
      i := p_cnhv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnhv_rec                     => p_cnhv_tbl(i),
          x_cnhv_rec                     => x_cnhv_tbl(i));
        EXIT WHEN (i = p_cnhv_tbl.LAST);
        i := p_cnhv_tbl.NEXT(i);
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
  ------------------------------------------
  -- lock_row for:OKC_CONDITION_HEADERS_B --
  ------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnh_rec                      IN cnh_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cnh_rec IN cnh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CONDITION_HEADERS_B
     WHERE ID = p_cnh_rec.id
       AND OBJECT_VERSION_NUMBER = p_cnh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cnh_rec IN cnh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CONDITION_HEADERS_B
    WHERE ID = p_cnh_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_CONDITION_HEADERS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_CONDITION_HEADERS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cnh_rec);
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
      OPEN lchk_csr(p_cnh_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cnh_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cnh_rec.object_version_number THEN
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
  -------------------------------------------
  -- lock_row for:OKC_CONDITION_HEADERS_TL --
  -------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_condition_headers_tl_rec  IN OkcConditionHeadersTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_condition_headers_tl_rec IN OkcConditionHeadersTlRecType) IS
    SELECT *
      FROM OKC_CONDITION_HEADERS_TL
     WHERE ID = p_okc_condition_headers_tl_rec.id
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
      OPEN lock_csr(p_okc_condition_headers_tl_rec);
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
  ------------------------------------------
  -- lock_row for:OKC_CONDITION_HEADERS_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnh_rec                      cnh_rec_type;
    l_okc_condition_headers_tl_rec OkcConditionHeadersTlRecType;
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
    migrate(p_cnhv_rec, l_cnh_rec);
    migrate(p_cnhv_rec, l_okc_condition_headers_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cnh_rec
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
      l_okc_condition_headers_tl_rec
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
  -- PL/SQL TBL lock_row for:CNHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnhv_tbl.COUNT > 0) THEN
      i := p_cnhv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnhv_rec                     => p_cnhv_tbl(i));
        EXIT WHEN (i = p_cnhv_tbl.LAST);
        i := p_cnhv_tbl.NEXT(i);
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
  --------------------------------------------
  -- update_row for:OKC_CONDITION_HEADERS_B --
  --------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnh_rec                      IN cnh_rec_type,
    x_cnh_rec                      OUT NOCOPY cnh_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnh_rec                      cnh_rec_type := p_cnh_rec;
    l_def_cnh_rec                  cnh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cnh_rec	IN cnh_rec_type,
      x_cnh_rec	OUT NOCOPY cnh_rec_type
    ) RETURN VARCHAR2 IS
      l_cnh_rec                      cnh_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnh_rec := p_cnh_rec;
      -- Get current database values
      l_cnh_rec := get_rec(p_cnh_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cnh_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.id := l_cnh_rec.id;
      END IF;
      IF (x_cnh_rec.acn_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.acn_id := l_cnh_rec.acn_id;
      END IF;
      IF (x_cnh_rec.counter_group_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.counter_group_id := l_cnh_rec.counter_group_id;
      END IF;
      IF (x_cnh_rec.one_time_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.one_time_yn := l_cnh_rec.one_time_yn;
      END IF;
      IF (x_cnh_rec.before_after = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.before_after := l_cnh_rec.before_after;
      END IF;
      IF (x_cnh_rec.cnh_variance = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.cnh_variance := l_cnh_rec.cnh_variance;
      END IF;
      IF (x_cnh_rec.condition_valid_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.condition_valid_yn := l_cnh_rec.condition_valid_yn;
      END IF;
      IF (x_cnh_rec.tracked_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.tracked_yn := l_cnh_rec.tracked_yn;
      END IF;
      IF (x_cnh_rec.date_active = OKC_API.G_MISS_DATE)
      THEN
        x_cnh_rec.date_active := l_cnh_rec.date_active;
      END IF;
      IF (x_cnh_rec.date_inactive = OKC_API.G_MISS_DATE)
      THEN
        x_cnh_rec.date_inactive := l_cnh_rec.date_inactive;
      END IF;
      IF (x_cnh_rec.cnh_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.cnh_type := l_cnh_rec.cnh_type;
      END IF;
      IF (x_cnh_rec.template_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.template_yn := l_cnh_rec.template_yn;
      END IF;
      IF (x_cnh_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.dnz_chr_id := l_cnh_rec.dnz_chr_id;
      END IF;
      IF (x_cnh_rec.object_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.object_id := l_cnh_rec.object_id;
      END IF;
      IF (x_cnh_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.jtot_object_code := l_cnh_rec.jtot_object_code;
      END IF;
      IF (x_cnh_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.object_version_number := l_cnh_rec.object_version_number;
      END IF;
      IF (x_cnh_rec.task_owner_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.task_owner_id := l_cnh_rec.task_owner_id;
      END IF;
      IF (x_cnh_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.created_by := l_cnh_rec.created_by;
      END IF;
      IF (x_cnh_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cnh_rec.creation_date := l_cnh_rec.creation_date;
      END IF;
      IF (x_cnh_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.last_updated_by := l_cnh_rec.last_updated_by;
      END IF;
      IF (x_cnh_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cnh_rec.last_update_date := l_cnh_rec.last_update_date;
      END IF;
      IF (x_cnh_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.last_update_login := l_cnh_rec.last_update_login;
      END IF;
      IF (x_cnh_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute_category := l_cnh_rec.attribute_category;
      END IF;
      IF (x_cnh_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute1 := l_cnh_rec.attribute1;
      END IF;
      IF (x_cnh_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute2 := l_cnh_rec.attribute2;
      END IF;
      IF (x_cnh_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute3 := l_cnh_rec.attribute3;
      END IF;
      IF (x_cnh_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute4 := l_cnh_rec.attribute4;
      END IF;
      IF (x_cnh_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute5 := l_cnh_rec.attribute5;
      END IF;
      IF (x_cnh_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute6 := l_cnh_rec.attribute6;
      END IF;
      IF (x_cnh_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute7 := l_cnh_rec.attribute7;
      END IF;
      IF (x_cnh_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute8 := l_cnh_rec.attribute8;
      END IF;
      IF (x_cnh_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute9 := l_cnh_rec.attribute9;
      END IF;
      IF (x_cnh_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute10 := l_cnh_rec.attribute10;
      END IF;
      IF (x_cnh_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute11 := l_cnh_rec.attribute11;
      END IF;
      IF (x_cnh_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute12 := l_cnh_rec.attribute12;
      END IF;
      IF (x_cnh_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute13 := l_cnh_rec.attribute13;
      END IF;
      IF (x_cnh_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute14 := l_cnh_rec.attribute14;
      END IF;
      IF (x_cnh_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.attribute15 := l_cnh_rec.attribute15;
      END IF;
      IF (x_cnh_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnh_rec.application_id := l_cnh_rec.application_id;
      END IF;
      IF (x_cnh_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cnh_rec.seeded_flag := l_cnh_rec.seeded_flag;
      END IF;
      IF (x_cnh_rec.last_rundate = OKC_API.G_MISS_DATE)
      THEN
        x_cnh_rec.last_rundate := l_cnh_rec.last_rundate;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_HEADERS_B --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_cnh_rec IN  cnh_rec_type,
      x_cnh_rec OUT NOCOPY cnh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnh_rec := p_cnh_rec;
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
      p_cnh_rec,                         -- IN
      l_cnh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cnh_rec, l_def_cnh_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CONDITION_HEADERS_B
    SET ACN_ID = l_def_cnh_rec.acn_id,
        COUNTER_GROUP_ID = l_def_cnh_rec.counter_group_id,
        ONE_TIME_YN = l_def_cnh_rec.one_time_yn,
        BEFORE_AFTER = l_def_cnh_rec.before_after,
        CNH_VARIANCE = l_def_cnh_rec.cnh_variance,
        CONDITION_VALID_YN = l_def_cnh_rec.condition_valid_yn,
        TRACKED_YN = l_def_cnh_rec.tracked_yn,
        DATE_ACTIVE = l_def_cnh_rec.date_active,
        DATE_INACTIVE = l_def_cnh_rec.date_inactive,
        CNH_TYPE = l_def_cnh_rec.cnh_type,
        TEMPLATE_YN = l_def_cnh_rec.template_yn,
        DNZ_CHR_ID = l_def_cnh_rec.dnz_chr_id,
        OBJECT_ID = l_def_cnh_rec.object_id,
        JTOT_OBJECT_CODE = l_def_cnh_rec.jtot_object_code,
        OBJECT_VERSION_NUMBER = l_def_cnh_rec.object_version_number,
        TASK_OWNER_ID = l_def_cnh_rec.task_owner_id,
        CREATED_BY = l_def_cnh_rec.created_by,
        CREATION_DATE = l_def_cnh_rec.creation_date,
        LAST_UPDATED_BY = l_def_cnh_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cnh_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cnh_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_cnh_rec.attribute_category,
        ATTRIBUTE1 = l_def_cnh_rec.attribute1,
        ATTRIBUTE2 = l_def_cnh_rec.attribute2,
        ATTRIBUTE3 = l_def_cnh_rec.attribute3,
        ATTRIBUTE4 = l_def_cnh_rec.attribute4,
        ATTRIBUTE5 = l_def_cnh_rec.attribute5,
        ATTRIBUTE6 = l_def_cnh_rec.attribute6,
        ATTRIBUTE7 = l_def_cnh_rec.attribute7,
        ATTRIBUTE8 = l_def_cnh_rec.attribute8,
        ATTRIBUTE9 = l_def_cnh_rec.attribute9,
        ATTRIBUTE10 = l_def_cnh_rec.attribute10,
        ATTRIBUTE11 = l_def_cnh_rec.attribute11,
        ATTRIBUTE12 = l_def_cnh_rec.attribute12,
        ATTRIBUTE13 = l_def_cnh_rec.attribute13,
        ATTRIBUTE14 = l_def_cnh_rec.attribute14,
        ATTRIBUTE15 = l_def_cnh_rec.attribute15,
        APPLICATION_ID = l_def_cnh_rec.application_id,
        SEEDED_FLAG = l_def_cnh_rec.seeded_flag,
        LAST_RUNDATE = l_def_cnh_rec.last_rundate
    WHERE ID = l_def_cnh_rec.id;

    x_cnh_rec := l_def_cnh_rec;
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
  ---------------------------------------------
  -- update_row for:OKC_CONDITION_HEADERS_TL --
  ---------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_condition_headers_tl_rec  IN OkcConditionHeadersTlRecType,
    x_okc_condition_headers_tl_rec  OUT NOCOPY OkcConditionHeadersTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_condition_headers_tl_rec OkcConditionHeadersTlRecType := p_okc_condition_headers_tl_rec;
    ldefokcconditionheaderstlrec   OkcConditionHeadersTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_condition_headers_tl_rec	IN OkcConditionHeadersTlRecType,
      x_okc_condition_headers_tl_rec	OUT NOCOPY OkcConditionHeadersTlRecType
    ) RETURN VARCHAR2 IS
      l_okc_condition_headers_tl_rec OkcConditionHeadersTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_condition_headers_tl_rec := p_okc_condition_headers_tl_rec;
      -- Get current database values
      l_okc_condition_headers_tl_rec := get_rec(p_okc_condition_headers_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_condition_headers_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_condition_headers_tl_rec.id := l_okc_condition_headers_tl_rec.id;
      END IF;
      IF (x_okc_condition_headers_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_headers_tl_rec.language := l_okc_condition_headers_tl_rec.language;
      END IF;
      IF (x_okc_condition_headers_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_headers_tl_rec.source_lang := l_okc_condition_headers_tl_rec.source_lang;
      END IF;
      IF (x_okc_condition_headers_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_headers_tl_rec.sfwt_flag := l_okc_condition_headers_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_condition_headers_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_headers_tl_rec.name := l_okc_condition_headers_tl_rec.name;
      END IF;
      IF (x_okc_condition_headers_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_headers_tl_rec.description := l_okc_condition_headers_tl_rec.description;
      END IF;
      IF (x_okc_condition_headers_tl_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_headers_tl_rec.short_description := l_okc_condition_headers_tl_rec.short_description;
      END IF;
      IF (x_okc_condition_headers_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_headers_tl_rec.comments := l_okc_condition_headers_tl_rec.comments;
      END IF;
      IF (x_okc_condition_headers_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_condition_headers_tl_rec.created_by := l_okc_condition_headers_tl_rec.created_by;
      END IF;
      IF (x_okc_condition_headers_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_condition_headers_tl_rec.creation_date := l_okc_condition_headers_tl_rec.creation_date;
      END IF;
      IF (x_okc_condition_headers_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_condition_headers_tl_rec.last_updated_by := l_okc_condition_headers_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_condition_headers_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_condition_headers_tl_rec.last_update_date := l_okc_condition_headers_tl_rec.last_update_date;
      END IF;
      IF (x_okc_condition_headers_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_condition_headers_tl_rec.last_update_login := l_okc_condition_headers_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_HEADERS_TL --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_condition_headers_tl_rec IN  OkcConditionHeadersTlRecType,
      x_okc_condition_headers_tl_rec OUT NOCOPY OkcConditionHeadersTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_condition_headers_tl_rec := p_okc_condition_headers_tl_rec;
      x_okc_condition_headers_tl_rec.LANGUAGE := l_lang;
      x_okc_condition_headers_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_condition_headers_tl_rec,    -- IN
      l_okc_condition_headers_tl_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_condition_headers_tl_rec, ldefokcconditionheaderstlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CONDITION_HEADERS_TL
    SET NAME = ldefokcconditionheaderstlrec.name,
        SOURCE_LANG = ldefokcconditionheaderstlrec.source_lang,
        DESCRIPTION = ldefokcconditionheaderstlrec.description,
        SHORT_DESCRIPTION = ldefokcconditionheaderstlrec.short_description,
        COMMENTS = ldefokcconditionheaderstlrec.comments,
        CREATED_BY = ldefokcconditionheaderstlrec.created_by,
        CREATION_DATE = ldefokcconditionheaderstlrec.creation_date,
        LAST_UPDATED_BY = ldefokcconditionheaderstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokcconditionheaderstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokcconditionheaderstlrec.last_update_login
    WHERE ID = ldefokcconditionheaderstlrec.id
      AND USERENV('LANG') IN (SOURCE_LANG,LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_CONDITION_HEADERS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokcconditionheaderstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_condition_headers_tl_rec := ldefokcconditionheaderstlrec;
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
  --------------------------------------------
  -- update_row for:OKC_CONDITION_HEADERS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type,
    x_cnhv_rec                     OUT NOCOPY cnhv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnhv_rec                     cnhv_rec_type := p_cnhv_rec;
    l_def_cnhv_rec                 cnhv_rec_type;
    l_okc_condition_headers_tl_rec OkcConditionHeadersTlRecType;
    LxOkcConditionHeadersTlRec     OkcConditionHeadersTlRecType;
    l_cnh_rec                      cnh_rec_type;
    lx_cnh_rec                     cnh_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cnhv_rec	IN cnhv_rec_type
    ) RETURN cnhv_rec_type IS
      l_cnhv_rec	cnhv_rec_type := p_cnhv_rec;
    BEGIN
      l_cnhv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cnhv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cnhv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cnhv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cnhv_rec	IN cnhv_rec_type,
      x_cnhv_rec	OUT NOCOPY cnhv_rec_type
    ) RETURN VARCHAR2 IS
      l_cnhv_rec                     cnhv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnhv_rec := p_cnhv_rec;
      -- Get current database values
      l_cnhv_rec := get_rec(p_cnhv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cnhv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.id := l_cnhv_rec.id;
      END IF;
      IF (x_cnhv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.object_version_number := l_cnhv_rec.object_version_number;
      END IF;
      IF (x_cnhv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.sfwt_flag := l_cnhv_rec.sfwt_flag;
      END IF;
      IF (x_cnhv_rec.acn_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.acn_id := l_cnhv_rec.acn_id;
      END IF;
      IF (x_cnhv_rec.counter_group_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.counter_group_id := l_cnhv_rec.counter_group_id;
      END IF;
      IF (x_cnhv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.description := l_cnhv_rec.description;
      END IF;
      IF (x_cnhv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.short_description := l_cnhv_rec.short_description;
      END IF;
      IF (x_cnhv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.comments := l_cnhv_rec.comments;
      END IF;
      IF (x_cnhv_rec.one_time_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.one_time_yn := l_cnhv_rec.one_time_yn;
      END IF;
      IF (x_cnhv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.name := l_cnhv_rec.name;
      END IF;
      IF (x_cnhv_rec.condition_valid_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.condition_valid_yn := l_cnhv_rec.condition_valid_yn;
      END IF;
      IF (x_cnhv_rec.before_after = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.before_after := l_cnhv_rec.before_after;
      END IF;
      IF (x_cnhv_rec.tracked_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.tracked_yn := l_cnhv_rec.tracked_yn;
      END IF;
      IF (x_cnhv_rec.cnh_variance = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.cnh_variance := l_cnhv_rec.cnh_variance;
      END IF;
      IF (x_cnhv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.dnz_chr_id := l_cnhv_rec.dnz_chr_id;
      END IF;
      IF (x_cnhv_rec.template_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.template_yn := l_cnhv_rec.template_yn;
      END IF;
      IF (x_cnhv_rec.date_active = OKC_API.G_MISS_DATE)
      THEN
        x_cnhv_rec.date_active := l_cnhv_rec.date_active;
      END IF;
      IF (x_cnhv_rec.object_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.object_id := l_cnhv_rec.object_id;
      END IF;
      IF (x_cnhv_rec.date_inactive = OKC_API.G_MISS_DATE)
      THEN
        x_cnhv_rec.date_inactive := l_cnhv_rec.date_inactive;
      END IF;
      IF (x_cnhv_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.jtot_object_code := l_cnhv_rec.jtot_object_code;
      END IF;
      IF (x_cnhv_rec.task_owner_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.task_owner_id := l_cnhv_rec.task_owner_id;
      END IF;
      IF (x_cnhv_rec.cnh_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.cnh_type := l_cnhv_rec.cnh_type;
      END IF;
      IF (x_cnhv_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.application_id := l_cnhv_rec.application_id;
      END IF;
      IF (x_cnhv_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.seeded_flag := l_cnhv_rec.seeded_flag;
      END IF;
      IF (x_cnhv_rec.last_rundate = OKC_API.G_MISS_DATE)
      THEN
        x_cnhv_rec.last_rundate := l_cnhv_rec.last_rundate;
      END IF;
      IF (x_cnhv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute_category := l_cnhv_rec.attribute_category;
      END IF;
      IF (x_cnhv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute1 := l_cnhv_rec.attribute1;
      END IF;
      IF (x_cnhv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute2 := l_cnhv_rec.attribute2;
      END IF;
      IF (x_cnhv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute3 := l_cnhv_rec.attribute3;
      END IF;
      IF (x_cnhv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute4 := l_cnhv_rec.attribute4;
      END IF;
      IF (x_cnhv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute5 := l_cnhv_rec.attribute5;
      END IF;
      IF (x_cnhv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute6 := l_cnhv_rec.attribute6;
      END IF;
      IF (x_cnhv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute7 := l_cnhv_rec.attribute7;
      END IF;
      IF (x_cnhv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute8 := l_cnhv_rec.attribute8;
      END IF;
      IF (x_cnhv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute9 := l_cnhv_rec.attribute9;
      END IF;
      IF (x_cnhv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute10 := l_cnhv_rec.attribute10;
      END IF;
      IF (x_cnhv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute11 := l_cnhv_rec.attribute11;
      END IF;
      IF (x_cnhv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute12 := l_cnhv_rec.attribute12;
      END IF;
      IF (x_cnhv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute13 := l_cnhv_rec.attribute13;
      END IF;
      IF (x_cnhv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute14 := l_cnhv_rec.attribute14;
      END IF;
      IF (x_cnhv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnhv_rec.attribute15 := l_cnhv_rec.attribute15;
      END IF;
      IF (x_cnhv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.created_by := l_cnhv_rec.created_by;
      END IF;
      IF (x_cnhv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cnhv_rec.creation_date := l_cnhv_rec.creation_date;
      END IF;
      IF (x_cnhv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.last_updated_by := l_cnhv_rec.last_updated_by;
      END IF;
      IF (x_cnhv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cnhv_rec.last_update_date := l_cnhv_rec.last_update_date;
      END IF;
      IF (x_cnhv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cnhv_rec.last_update_login := l_cnhv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_HEADERS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_cnhv_rec IN  cnhv_rec_type,
      x_cnhv_rec OUT NOCOPY cnhv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnhv_rec := p_cnhv_rec;
      x_cnhv_rec.OBJECT_VERSION_NUMBER := NVL(x_cnhv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    /*
    --  Seed data should not be updated
	   IF l_cnhv_rec.last_updated_by <> 1 THEN
	   IF l_cnhv_rec.seeded_flag = 'Y' THEN
	   OKC_API.set_message(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
        RAISE OKC_API.G_EXCEPTION_ERROR;
	   END IF;
	   END IF;*/
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cnhv_rec,                        -- IN
      l_cnhv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cnhv_rec, l_def_cnhv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cnhv_rec := fill_who_columns(l_def_cnhv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cnhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cnhv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    /************ ADDED TO CHECK THE UNIQUENESS **********************/

    -- Validate_Unique_Cnh_Record
    Validate_Unique_Cnh_Record(x_return_status,p_cnhv_rec);
    l_return_status := x_return_status;
    -- store the highest degree of error
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF
	 (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    /********** ADDED TO CHECK THE UNIQUENESS *************************/

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cnhv_rec, l_okc_condition_headers_tl_rec);
    migrate(l_def_cnhv_rec, l_cnh_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_condition_headers_tl_rec,
      LxOkcConditionHeadersTlRec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxOkcConditionHeadersTlRec, l_def_cnhv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cnh_rec,
      lx_cnh_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cnh_rec, l_def_cnhv_rec);
    x_cnhv_rec := l_def_cnhv_rec;
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
  -- PL/SQL TBL update_row for:CNHV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type,
    x_cnhv_tbl                     OUT NOCOPY cnhv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnhv_tbl.COUNT > 0) THEN
      i := p_cnhv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnhv_rec                     => p_cnhv_tbl(i),
          x_cnhv_rec                     => x_cnhv_tbl(i));
        EXIT WHEN (i = p_cnhv_tbl.LAST);
        i := p_cnhv_tbl.NEXT(i);
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
  --------------------------------------------
  -- delete_row for:OKC_CONDITION_HEADERS_B --
  --------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnh_rec                      IN cnh_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnh_rec                      cnh_rec_type:= p_cnh_rec;
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
    DELETE FROM OKC_CONDITION_HEADERS_B
     WHERE ID = l_cnh_rec.id;

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
  ---------------------------------------------
  -- delete_row for:OKC_CONDITION_HEADERS_TL --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_condition_headers_tl_rec  IN OkcConditionHeadersTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_condition_headers_tl_rec OkcConditionHeadersTlRecType:= p_okc_condition_headers_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -------------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_HEADERS_TL --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_condition_headers_tl_rec IN  OkcConditionHeadersTlRecType,
      x_okc_condition_headers_tl_rec OUT NOCOPY OkcConditionHeadersTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_condition_headers_tl_rec := p_okc_condition_headers_tl_rec;
      x_okc_condition_headers_tl_rec.LANGUAGE := l_lang;
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
      p_okc_condition_headers_tl_rec,    -- IN
      l_okc_condition_headers_tl_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_CONDITION_HEADERS_TL
     WHERE ID = l_okc_condition_headers_tl_rec.id;

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
  --------------------------------------------
  -- delete_row for:OKC_CONDITION_HEADERS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnhv_rec                     cnhv_rec_type := p_cnhv_rec;
    l_okc_condition_headers_tl_rec OkcConditionHeadersTlRecType;
    l_cnh_rec                      cnh_rec_type;
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
    /*
    --  Seed data should not be deleted
	   IF l_cnhv_rec.last_updated_by <> 1 THEN
	   IF l_cnhv_rec.seeded_flag = 'Y' THEN
	   OKC_API.set_message(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
        RAISE OKC_API.G_EXCEPTION_ERROR;
	   END IF;
	   END IF;*/
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_cnhv_rec, l_okc_condition_headers_tl_rec);
    migrate(l_cnhv_rec, l_cnh_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_condition_headers_tl_rec
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
      l_cnh_rec
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
  -- PL/SQL TBL delete_row for:CNHV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnhv_tbl.COUNT > 0) THEN
      i := p_cnhv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnhv_rec                     => p_cnhv_tbl(i));
        EXIT WHEN (i = p_cnhv_tbl.LAST);
        i := p_cnhv_tbl.NEXT(i);
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

---------------------------------------------------------------
-- Procedure for mass insert in OKC_CONDITION_HEADERS _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_cnhv_tbl cnhv_tbl_type) IS
  l_tabsize NUMBER := p_cnhv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_acn_id                        OKC_DATATYPES.NumberTabTyp;
  in_counter_group_id              OKC_DATATYPES.NumberTabTyp;
  in_description                   OKC_DATATYPES.Var1995TabTyp;
  in_short_description             OKC_DATATYPES.Var600TabTyp;
  in_comments                      OKC_DATATYPES.Var1995TabTyp;
  in_one_time_yn                   OKC_DATATYPES.Var3TabTyp;
  in_name                          OKC_DATATYPES.Var150TabTyp;
  in_condition_valid_yn            OKC_DATATYPES.Var3TabTyp;
  in_before_after                  OKC_DATATYPES.Var3TabTyp;
  in_tracked_yn                    OKC_DATATYPES.Var3TabTyp;
  in_cnh_variance                  OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_template_yn                   OKC_DATATYPES.Var3TabTyp;
  in_date_active                   OKC_DATATYPES.DateTabTyp;
  in_object_id                     OKC_DATATYPES.NumberTabTyp;
  in_date_inactive                 OKC_DATATYPES.DateTabTyp;
  in_jtot_object_code              OKC_DATATYPES.Var30TabTyp;
  in_task_owner_id                 OKC_DATATYPES.NumberTabTyp;
  in_cnh_type                      OKC_DATATYPES.Var30TabTyp;
  in_attribute_category            OKC_DATATYPES.NumberTabTyp;
  in_application_id                OKC_DATATYPES.Var3TabTyp;
  in_seeded_flag                   OKC_DATATYPES.Var90TabTyp;
  in_last_rundate                  OKC_DATATYPES.DateTabTyp;
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
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  j                                NUMBER := 0;
  i                                NUMBER := p_cnhv_tbl.FIRST;
BEGIN
 -- Initializing return status
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  while i is not null
  LOOP
    j := j + 1;
    in_id                       (j) := p_cnhv_tbl(i).id;
    in_object_version_number    (j) := p_cnhv_tbl(i).object_version_number;
    in_sfwt_flag                (j) := p_cnhv_tbl(i).sfwt_flag;
    in_acn_id                   (j) := p_cnhv_tbl(i).acn_id;
    in_counter_group_id         (j) := p_cnhv_tbl(i).counter_group_id;
    in_description              (j) := p_cnhv_tbl(i).description;
    in_short_description        (j) := p_cnhv_tbl(i).short_description;
    in_comments                 (j) := p_cnhv_tbl(i).comments;
    in_one_time_yn              (j) := p_cnhv_tbl(i).one_time_yn;
    in_name                     (j) := p_cnhv_tbl(i).name;
    in_condition_valid_yn       (j) := p_cnhv_tbl(i).condition_valid_yn;
    in_before_after             (j) := p_cnhv_tbl(i).before_after;
    in_tracked_yn               (j) := p_cnhv_tbl(i).tracked_yn;
    in_cnh_variance             (j) := p_cnhv_tbl(i).cnh_variance;
    in_dnz_chr_id               (j) := p_cnhv_tbl(i).dnz_chr_id;
    in_template_yn              (j) := p_cnhv_tbl(i).template_yn;
    in_date_active              (j) := p_cnhv_tbl(i).date_active;
    in_object_id                (j) := p_cnhv_tbl(i).object_id;
    in_date_inactive            (j) := p_cnhv_tbl(i).date_inactive;
    in_jtot_object_code         (j) := p_cnhv_tbl(i).jtot_object_code;
    in_task_owner_id            (j) := p_cnhv_tbl(i).task_owner_id;
    in_cnh_type                 (j) := p_cnhv_tbl(i).cnh_type;
    in_attribute_category       (j) := p_cnhv_tbl(i).attribute_category;
    in_application_id           (j) := p_cnhv_tbl(i).application_id;
    in_seeded_flag              (j) := p_cnhv_tbl(i).seeded_flag;
    in_last_rundate             (j) := p_cnhv_tbl(i).last_rundate;
    in_attribute1               (j) := p_cnhv_tbl(i).attribute1;
    in_attribute2               (j) := p_cnhv_tbl(i).attribute2;
    in_attribute3               (j) := p_cnhv_tbl(i).attribute3;
    in_attribute4               (j) := p_cnhv_tbl(i).attribute4;
    in_attribute5               (j) := p_cnhv_tbl(i).attribute5;
    in_attribute6               (j) := p_cnhv_tbl(i).attribute6;
    in_attribute7               (j) := p_cnhv_tbl(i).attribute7;
    in_attribute8               (j) := p_cnhv_tbl(i).attribute8;
    in_attribute9               (j) := p_cnhv_tbl(i).attribute9;
    in_attribute10              (j) := p_cnhv_tbl(i).attribute10;
    in_attribute11              (j) := p_cnhv_tbl(i).attribute11;
    in_attribute12              (j) := p_cnhv_tbl(i).attribute12;
    in_attribute13              (j) := p_cnhv_tbl(i).attribute13;
    in_attribute14              (j) := p_cnhv_tbl(i).attribute14;
    in_attribute15              (j) := p_cnhv_tbl(i).attribute15;
    in_created_by               (j) := p_cnhv_tbl(i).created_by;
    in_creation_date            (j) := p_cnhv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_cnhv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_cnhv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_cnhv_tbl(i).last_update_login;
    i := p_cnhv_tbl.NEXT(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_CONDITION_HEADERS_B
      (
        id,
        acn_id,
        counter_group_id,
        one_time_yn,
        before_after,
        cnh_variance,
        condition_valid_yn,
        tracked_yn,
        date_active,
        date_inactive,
        cnh_type,
        template_yn,
        dnz_chr_id,
        object_id,
        jtot_object_code,
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
        task_owner_id,
        application_id,
        seeded_flag,
	   last_rundate
     )
     VALUES (
        in_id(i),
        in_acn_id(i),
        in_counter_group_id(i),
        in_one_time_yn(i),
        in_before_after(i),
        in_cnh_variance(i),
        in_condition_valid_yn(i),
        in_tracked_yn(i),
        in_date_active(i),
        in_date_inactive(i),
        in_cnh_type(i),
        in_template_yn(i),
        in_dnz_chr_id(i),
        in_object_id(i),
        in_jtot_object_code(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
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
        in_attribute15(i),
        in_task_owner_id(i),
        in_application_id(i),
        in_seeded_flag(i),
	   in_last_rundate(i)
     );

  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..l_tabsize
      INSERT INTO OKC_CONDITION_HEADERS_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        description,
        short_description,
        comments,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        name
     )
     VALUES (
        in_id(i),
        OKC_UTIL.g_language_code(lang_i),
        l_source_lang,
        in_sfwt_flag(i),
        in_description(i),
        in_short_description(i),
        in_comments(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i),
        in_name(i)
      );
      END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    --RAISE;
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

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
INSERT INTO okc_condition_headers_bh
  (
      major_version,
      id,
      acn_id,
      counter_group_id,
      one_time_yn,
      before_after,
      cnh_variance,
      condition_valid_yn,
      tracked_yn,
      date_active,
      date_inactive,
      cnh_type,
      template_yn,
      dnz_chr_id,
      object_id,
      jtot_object_code,
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
      task_owner_id,
      application_id, -- These 3 columns are now included in the HISTORY table
      seeded_flag,    --
      last_rundate    --
)
  SELECT
      p_major_version,
      id,
      acn_id,
      counter_group_id,
      one_time_yn,
      before_after,
      cnh_variance,
      condition_valid_yn,
      tracked_yn,
      date_active,
      date_inactive,
      cnh_type,
      template_yn,
      dnz_chr_id,
      object_id,
      jtot_object_code,
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
      task_owner_id,
      application_id,
      seeded_flag,
      last_rundate
  FROM okc_condition_headers_b
WHERE dnz_chr_id = p_chr_id;

------------------------------
-- Versioning TL Table
------------------------------

INSERT INTO okc_condition_headers_tlh
  (
      major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      description,
      short_description,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      name
)
  SELECT
      p_major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      description,
      short_description,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      name
  FROM okc_condition_headers_tl
 WHERE id in ( select id from okc_condition_headers_b
			where dnz_chr_id = p_chr_id );

RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
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
--
--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_condition_headers_tl
  (
      id,
      language,
      source_lang,
      sfwt_flag,
      description,
      short_description,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      name
)
  SELECT
      id,
      language,
      source_lang,
      sfwt_flag,
      description,
      short_description,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      name
  FROM okc_condition_headers_tlh
WHERE id in (SELECT id
			FROM okc_condition_headers_bh
		    WHERE dnz_chr_id = p_chr_id)
  AND major_version = p_major_version;

------------------------------------------
-- Restoring Base Table
------------------------------------------

INSERT INTO okc_condition_headers_b
  (
      id,
      acn_id,
      counter_group_id,
      one_time_yn,
      before_after,
      cnh_variance,
      condition_valid_yn,
      tracked_yn,
      date_active,
      date_inactive,
      cnh_type,
      template_yn,
      dnz_chr_id,
      object_id,
      jtot_object_code,
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
      task_owner_id,
      application_id,
      seeded_flag,
      last_rundate
)
  SELECT
      id,
      acn_id,
      counter_group_id,
      one_time_yn,
      before_after,
      cnh_variance,
      condition_valid_yn,
      tracked_yn,
      date_active,
      date_inactive,
      cnh_type,
      template_yn,
      dnz_chr_id,
      object_id,
      jtot_object_code,
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
      task_owner_id,
      application_id,
      seeded_flag,
      last_rundate
  FROM okc_condition_headers_bh
WHERE dnz_chr_id = p_chr_id
  AND major_version = p_major_version;

RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
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
--
END OKC_CNH_PVT;

/
