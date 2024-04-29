--------------------------------------------------------
--  DDL for Package Body OKC_OCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OCE_PVT" AS
/* $Header: OKCSOCEB.pls 120.0 2005/05/30 04:11:08 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- Define a local variable to get the value of USERENV('LANG')
  ---------------------------------------------------------------------------
  l_lang     VARCHAR2(12) := OKC_UTIL.get_userenv_lang;

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
    DELETE FROM OKC_OUTCOMES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_OUTCOMES_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_OUTCOMES_TL T SET (
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKC_OUTCOMES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_OUTCOMES_TL SUBB, OKC_OUTCOMES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

    INSERT INTO OKC_OUTCOMES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
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
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_OUTCOMES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_OUTCOMES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
 DELETE FROM OKC_OUTCOMES_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_OUTCOMES_BH B
         WHERE B.ID = T.ID
          AND B.MAJOR_VERSION = T.MAJOR_VERSION
        );

    UPDATE OKC_OUTCOMES_TLH T SET (
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKC_OUTCOMES_TLH B
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
                FROM OKC_OUTCOMES_TLH SUBB, OKC_OUTCOMES_TLH SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

 INSERT INTO OKC_OUTCOMES_TLH (
        ID,
        LANGUAGE,
        MAJOR_VERSION,
        SOURCE_LANG,
        SFWT_FLAG,
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
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_OUTCOMES_TLH B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_OUTCOMES_TLH T
                     WHERE T.ID = B.ID
                       AND T.MAJOR_VERSION = B.MAJOR_VERSION
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );


  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_OUTCOMES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oce_rec                      IN oce_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oce_rec_type IS
    CURSOR okc_outcomes_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PDF_ID,
            CNH_ID,
            DNZ_CHR_ID,
		  SUCCESS_resource_ID,
		  FAILURE_resource_ID,
            ENABLED_YN,
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
      FROM Okc_Outcomes_B
     WHERE okc_outcomes_b.id    = p_id;
    l_okc_outcomes_b_pk            okc_outcomes_b_pk_csr%ROWTYPE;
    l_oce_rec                      oce_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_outcomes_b_pk_csr (p_oce_rec.id);
    FETCH okc_outcomes_b_pk_csr INTO
              l_oce_rec.ID,
              l_oce_rec.PDF_ID,
              l_oce_rec.CNH_ID,
              l_oce_rec.DNZ_CHR_ID,
		    l_oce_rec.SUCCESS_resource_ID,
		    l_oce_rec.FAILURE_resource_ID,
              l_oce_rec.ENABLED_YN,
              l_oce_rec.OBJECT_VERSION_NUMBER,
              l_oce_rec.CREATED_BY,
              l_oce_rec.CREATION_DATE,
              l_oce_rec.LAST_UPDATED_BY,
              l_oce_rec.LAST_UPDATE_DATE,
              l_oce_rec.LAST_UPDATE_LOGIN,
              l_oce_rec.ATTRIBUTE_CATEGORY,
              l_oce_rec.ATTRIBUTE1,
              l_oce_rec.ATTRIBUTE2,
              l_oce_rec.ATTRIBUTE3,
              l_oce_rec.ATTRIBUTE4,
              l_oce_rec.ATTRIBUTE5,
              l_oce_rec.ATTRIBUTE6,
              l_oce_rec.ATTRIBUTE7,
              l_oce_rec.ATTRIBUTE8,
              l_oce_rec.ATTRIBUTE9,
              l_oce_rec.ATTRIBUTE10,
              l_oce_rec.ATTRIBUTE11,
              l_oce_rec.ATTRIBUTE12,
              l_oce_rec.ATTRIBUTE13,
              l_oce_rec.ATTRIBUTE14,
              l_oce_rec.ATTRIBUTE15,
              l_oce_rec.APPLICATION_ID,
              l_oce_rec.SEEDED_FLAG;
    x_no_data_found := okc_outcomes_b_pk_csr%NOTFOUND;
    CLOSE okc_outcomes_b_pk_csr;
    RETURN(l_oce_rec);
  END get_rec;

  FUNCTION get_rec (
    p_oce_rec                      IN oce_rec_type
  ) RETURN oce_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oce_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_OUTCOMES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_outcomes_tl_rec          IN okc_outcomes_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_outcomes_tl_rec_type IS
    CURSOR okc_outcomes_tl_pk_csr (p_id                 IN NUMBER,
                                   p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Outcomes_Tl
     WHERE okc_outcomes_tl.id   = p_id
       AND okc_outcomes_tl.language = p_language;
    l_okc_outcomes_tl_pk           okc_outcomes_tl_pk_csr%ROWTYPE;
    l_okc_outcomes_tl_rec          okc_outcomes_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_outcomes_tl_pk_csr (p_okc_outcomes_tl_rec.id,
                                 p_okc_outcomes_tl_rec.language);
    FETCH okc_outcomes_tl_pk_csr INTO
              l_okc_outcomes_tl_rec.ID,
              l_okc_outcomes_tl_rec.LANGUAGE,
              l_okc_outcomes_tl_rec.SOURCE_LANG,
              l_okc_outcomes_tl_rec.SFWT_FLAG,
              l_okc_outcomes_tl_rec.COMMENTS,
              l_okc_outcomes_tl_rec.CREATED_BY,
              l_okc_outcomes_tl_rec.CREATION_DATE,
              l_okc_outcomes_tl_rec.LAST_UPDATED_BY,
              l_okc_outcomes_tl_rec.LAST_UPDATE_DATE,
              l_okc_outcomes_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_outcomes_tl_pk_csr%NOTFOUND;
    CLOSE okc_outcomes_tl_pk_csr;
    RETURN(l_okc_outcomes_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_outcomes_tl_rec          IN okc_outcomes_tl_rec_type
  ) RETURN okc_outcomes_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_outcomes_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_OUTCOMES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ocev_rec                     IN ocev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ocev_rec_type IS
    CURSOR okc_ocev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            PDF_ID,
            CNH_ID,
            DNZ_CHR_ID,
		  SUCCESS_resource_ID,
		  FAILURE_resource_ID,
            ENABLED_YN,
            COMMENTS,
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
      FROM Okc_Outcomes_V
     WHERE okc_outcomes_v.id    = p_id;
    l_okc_ocev_pk                  okc_ocev_pk_csr%ROWTYPE;
    l_ocev_rec                     ocev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_ocev_pk_csr (p_ocev_rec.id);
    FETCH okc_ocev_pk_csr INTO
              l_ocev_rec.ID,
              l_ocev_rec.OBJECT_VERSION_NUMBER,
              l_ocev_rec.SFWT_FLAG,
              l_ocev_rec.PDF_ID,
              l_ocev_rec.CNH_ID,
              l_ocev_rec.DNZ_CHR_ID,
		    l_ocev_rec.SUCCESS_resource_ID,
		    l_ocev_rec.FAILURE_resource_ID,
              l_ocev_rec.ENABLED_YN,
              l_ocev_rec.COMMENTS,
              l_ocev_rec.APPLICATION_ID,
              l_ocev_rec.SEEDED_FLAG,
              l_ocev_rec.ATTRIBUTE_CATEGORY,
              l_ocev_rec.ATTRIBUTE1,
              l_ocev_rec.ATTRIBUTE2,
              l_ocev_rec.ATTRIBUTE3,
              l_ocev_rec.ATTRIBUTE4,
              l_ocev_rec.ATTRIBUTE5,
              l_ocev_rec.ATTRIBUTE6,
              l_ocev_rec.ATTRIBUTE7,
              l_ocev_rec.ATTRIBUTE8,
              l_ocev_rec.ATTRIBUTE9,
              l_ocev_rec.ATTRIBUTE10,
              l_ocev_rec.ATTRIBUTE11,
              l_ocev_rec.ATTRIBUTE12,
              l_ocev_rec.ATTRIBUTE13,
              l_ocev_rec.ATTRIBUTE14,
              l_ocev_rec.ATTRIBUTE15,
              l_ocev_rec.CREATED_BY,
              l_ocev_rec.CREATION_DATE,
              l_ocev_rec.LAST_UPDATED_BY,
              l_ocev_rec.LAST_UPDATE_DATE,
              l_ocev_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_ocev_pk_csr%NOTFOUND;
    CLOSE okc_ocev_pk_csr;
    RETURN(l_ocev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ocev_rec                     IN ocev_rec_type
  ) RETURN ocev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ocev_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_OUTCOMES_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_ocev_rec	IN ocev_rec_type
  ) RETURN ocev_rec_type IS
    l_ocev_rec	ocev_rec_type := p_ocev_rec;
  BEGIN
    IF (l_ocev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_ocev_rec.object_version_number := NULL;
    END IF;
    IF (l_ocev_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.sfwt_flag := NULL;
    END IF;
    IF (l_ocev_rec.pdf_id = OKC_API.G_MISS_NUM) THEN
      l_ocev_rec.pdf_id := NULL;
    END IF;
    IF (l_ocev_rec.cnh_id = OKC_API.G_MISS_NUM) THEN
      l_ocev_rec.cnh_id := NULL;
    END IF;
    IF (l_ocev_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_ocev_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_ocev_rec.success_resource_id = OKC_API.G_MISS_NUM) THEN
      l_ocev_rec.success_resource_id := NULL;
    END IF;
    IF (l_ocev_rec.failure_resource_id = OKC_API.G_MISS_NUM) THEN
      l_ocev_rec.failure_resource_id := NULL;
    END IF;
    IF (l_ocev_rec.enabled_yn = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.enabled_yn := NULL;
    END IF;
    IF (l_ocev_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.comments := NULL;
    END IF;
    IF (l_ocev_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_ocev_rec.application_id := NULL;
    END IF;
    IF (l_ocev_rec.seeded_flag = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.seeded_flag := NULL;
    END IF;
    IF (l_ocev_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute_category := NULL;
    END IF;
    IF (l_ocev_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute1 := NULL;
    END IF;
    IF (l_ocev_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute2 := NULL;
    END IF;
    IF (l_ocev_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute3 := NULL;
    END IF;
    IF (l_ocev_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute4 := NULL;
    END IF;
    IF (l_ocev_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute5 := NULL;
    END IF;
    IF (l_ocev_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute6 := NULL;
    END IF;
    IF (l_ocev_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute7 := NULL;
    END IF;
    IF (l_ocev_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute8 := NULL;
    END IF;
    IF (l_ocev_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute9 := NULL;
    END IF;
    IF (l_ocev_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute10 := NULL;
    END IF;
    IF (l_ocev_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute11 := NULL;
    END IF;
    IF (l_ocev_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute12 := NULL;
    END IF;
    IF (l_ocev_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute13 := NULL;
    END IF;
    IF (l_ocev_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute14 := NULL;
    END IF;
    IF (l_ocev_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_ocev_rec.attribute15 := NULL;
    END IF;
    IF (l_ocev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_ocev_rec.created_by := NULL;
    END IF;
    IF (l_ocev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_ocev_rec.creation_date := NULL;
    END IF;
    IF (l_ocev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_ocev_rec.last_updated_by := NULL;
    END IF;
    IF (l_ocev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_ocev_rec.last_update_date := NULL;
    END IF;
    IF (l_ocev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_ocev_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ocev_rec);
  END null_out_defaults;

  /********* Commented out nocopy generated code in favor of hand written code  ****
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKC_OUTCOMES_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_ocev_rec IN  ocev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ocev_rec.id = OKC_API.G_MISS_NUM OR
       p_ocev_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ocev_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_ocev_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ocev_rec.pdf_id = OKC_API.G_MISS_NUM OR
          p_ocev_rec.pdf_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pdf_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ocev_rec.cnh_id = OKC_API.G_MISS_NUM OR
          p_ocev_rec.cnh_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cnh_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ocev_rec.enabled_yn = OKC_API.G_MISS_CHAR OR
          p_ocev_rec.enabled_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'enabled_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKC_OUTCOMES_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_ocev_rec IN ocev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_ocev_rec IN ocev_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_rulv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              OBJECT1_ID1,
              OBJECT2_ID1,
              OBJECT3_ID1,
              OBJECT1_ID2,
              OBJECT2_ID2,
              OBJECT3_ID2,
              JTOT_OBJECT1_CODE,
              JTOT_OBJECT2_CODE,
              JTOT_OBJECT3_CODE,
              DNZ_CHR_ID,
              RGP_ID,
              PRIORITY,
              STD_TEMPLATE_YN,
              COMMENTS,
              WARN_YN,
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
              TEXT,
              RULE_INFORMATION_CATEGORY,
              RULE_INFORMATION1,
              RULE_INFORMATION2,
              RULE_INFORMATION3,
              RULE_INFORMATION4,
              RULE_INFORMATION5,
              RULE_INFORMATION6,
              RULE_INFORMATION7,
              RULE_INFORMATION8,
              RULE_INFORMATION9,
              RULE_INFORMATION10,
              RULE_INFORMATION11,
              RULE_INFORMATION12,
              RULE_INFORMATION13,
              RULE_INFORMATION14,
              RULE_INFORMATION15
        FROM Okc_Rules_V
       WHERE okc_rules_v.id       = p_id;
      l_okc_rulv_pk                  okc_rulv_pk_csr%ROWTYPE;
      CURSOR okc_pdfv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              DESCRIPTION,
              SHORT_DESCRIPTION,
              COMMENTS,
              USAGE,
              NAME,
              WF_NAME,
              WF_PROCESS_NAME,
              PROCEDURE_NAME,
              PACKAGE_NAME,
              PDF_TYPE,
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
              BEGIN_DATE,
              END_DATE,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okc_Process_Defs_V
       WHERE okc_process_defs_v.id = p_id;
      l_okc_pdfv_pk                  okc_pdfv_pk_csr%ROWTYPE;
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
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_ocev_rec.PDF_ID IS NOT NULL)
      THEN
        OPEN okc_pdfv_pk_csr(p_ocev_rec.PDF_ID);
        FETCH okc_pdfv_pk_csr INTO l_okc_pdfv_pk;
        l_row_notfound := okc_pdfv_pk_csr%NOTFOUND;
        CLOSE okc_pdfv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PDF_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_ocev_rec.CNH_ID IS NOT NULL)
      THEN
        OPEN okc_cnhv_pk_csr(p_ocev_rec.CNH_ID);
        FETCH okc_cnhv_pk_csr INTO l_okc_cnhv_pk;
        l_row_notfound := okc_cnhv_pk_csr%NOTFOUND;
        CLOSE okc_cnhv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CNH_ID');
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
    l_return_status := validate_foreign_keys (p_ocev_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ***************** End Commented out nocopy generated code ***********************/
  /**************** Begin Hand Written Code ********************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKC_OUTCOMES_V --
  --------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_object_version_number
  -- Description     : Check if object_version_number is not null
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_object_version_number(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_ocev_rec              IN ocev_rec_type) IS
   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_ocev_rec.object_version_number = OKC_API.G_MISS_NUM OR
		p_ocev_rec.object_version_number IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'object_version_number');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	ELSE
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
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
  END validate_object_version_number;

  -- Start of comments
  -- Procedure Name  : validate_sfwt_flag
  -- Description     : Checks if column SFWT_FLAG is 'Y' or 'N' only
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE Validate_sfwt_flag(x_return_status OUT NOCOPY VARCHAR2
			       ,p_ocev_rec IN ocev_rec_type) IS
  BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	--Check if sfwt_flag is null
	IF p_ocev_rec.sfwt_flag = OKC_API.G_MISS_CHAR OR
		p_ocev_rec.sfwt_flag IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'sfwt_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the sfwt_flag is 'Y' or 'N'
	IF p_ocev_rec.sfwt_flag NOT IN ('Y', 'N') THEN
	        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    p_msg_name     => g_invalid_value,
                           	    p_token1       => g_col_name_token,
                           	    p_token1_value => 'sfwt_flag');
		x_return_status := OKC_API.G_RET_STS_ERROR;
	END IF;

	--Check if the data is in upper case
	IF p_ocev_rec.sfwt_flag <> UPPER(p_ocev_rec.sfwt_flag) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    p_msg_name     => g_uppercase_required,
                           	    p_token1       => g_col_name_token,
                           	    p_token1_value => 'sfwt_flag');
		x_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_sfwt_flag;

   -- Start of comments
   -- Procedure Name  : validate_seeded_flag
   -- Description     : Checks if column SEEDED_FLAG is 'Y' or 'N' only
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_seeded_flag(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_ocev_rec              IN ocev_rec_type) IS
		l_y VARCHAR2(1) := 'Y';
		l_n VARCHAR2(1) := 'N';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	-- Check if seeded_flag is Y or N
	IF UPPER(p_ocev_rec.seeded_flag) NOT IN ('Y', 'N') THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	IF p_ocev_rec.seeded_flag <> UPPER(p_ocev_rec.seeded_flag) THEN
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
   -- Start of comments
   -- Procedure Name  : validate_application_id
   -- Description     : Checks if application_id exists in fnd_application
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_application_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_ocev_rec              IN ocev_rec_type) IS
	Cursor application_id_cur(p_application_id IN NUMBER) IS
	select '1'
	from fnd_application
	where application_id = p_application_id;
	l_dummy		VARCHAR2(1) := '?';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_ocev_rec.application_id IS NOT NULL THEN
	--Check if application id exists in the fnd_application or not
	OPEN application_id_cur(p_ocev_rec.application_id);
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

--************************************************************************
   -- Start of comments
   -- Procedure Name  : validate_success_resource_id
   -- Description     : Checks if success_resource_id exists in okx_resources
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_success_resource_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_ocev_rec              IN ocev_rec_type) IS
	Cursor success_resource_id_cur(p_success_resource_id IN NUMBER) IS
	select '1'
	from okx_resources_v
	where id1   = p_success_resource_id
	and   resource_type = 'EMPLOYEE'
	and   status        = 'A';
	l_dummy		VARCHAR2(1) := '?';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_ocev_rec.success_resource_id IS NOT NULL THEN
	--Check if id exists in the okx_resources_v or not
	OPEN success_resource_id_cur(p_ocev_rec.success_resource_id);
	FETCH success_resource_id_cur INTO l_dummy;
	CLOSE success_resource_id_cur ;
	IF l_dummy = '?' THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'success_resource_id');
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
    END validate_success_resource_id;


   -- Start of comments
   -- Procedure Name  : validate_failure_resource_id
   -- Description     : Checks if failure_resource_id exists in okx_resources
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_failure_resource_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_ocev_rec              IN ocev_rec_type) IS
	Cursor failure_resource_id_cur(p_failure_resource_id IN NUMBER) IS
	select '1'
	from okx_resources_v
	where id1   = p_failure_resource_id
	and   resource_type = 'EMPLOYEE'
	and   status        = 'A';
	l_dummy		VARCHAR2(1) := '?';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_ocev_rec.failure_resource_id IS NOT NULL THEN
	--Check if id exists in the okx_resources_v or not
	OPEN failure_resource_id_cur(p_ocev_rec.failure_resource_id);
	FETCH failure_resource_id_cur INTO l_dummy;
	CLOSE failure_resource_id_cur ;
	IF l_dummy = '?' THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'failure_resource_id');
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
    END validate_failure_resource_id;

--***********************************************************************
  -- Start of comments
  -- Procedure Name  : validate_cnh_id
  -- Description     : Check if cnh_id is valid
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_cnh_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_ocev_rec              IN ocev_rec_type) IS

      CURSOR okc_cnhv_pk_csr IS
      SELECT '1'
      FROM Okc_condition_headers_v
      WHERE okc_condition_headers_v.id = p_ocev_rec.cnh_id;

      l_dummy     VARCHAR2(1) := '?';

  Begin
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if cnh_id is null
	IF p_ocev_rec.cnh_id = OKC_API.G_MISS_NUM OR p_ocev_rec.pdf_id IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'cnh_id');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Enforce foreign key
        OPEN okc_cnhv_pk_csr;
        FETCH okc_cnhv_pk_csr INTO l_dummy;
	CLOSE okc_cnhv_pk_csr;

	-- If l_dummy is still set to default, data was not found
        IF (l_dummy = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_no_parent_record,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'cnh_id',
                        	    p_token2       => g_child_table_token,
                        	    p_token2_value => 'OKC_OUTCOMES_V',
                        	    p_token3       => g_parent_table_token,
                        	    p_token3_value => 'OKC_CONDITION_HEADERS_V');
         	x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
  EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		-- verify that cursor was closed
		if okc_cnhv_pk_csr %ISOPEN then
      			close okc_cnhv_pk_csr ;
    		end if;

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
  END validate_cnh_id;

  -- Start of comments
  -- Procedure Name  : validate_pdf_id
  -- Description     : Check if pdf_id is null and enforce foreign key
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_pdf_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_ocev_rec              IN ocev_rec_type) IS

      CURSOR okc_pdfv_pk_csr IS
      SELECT '1'
      FROM Okc_Process_Defs_V
      WHERE okc_process_defs_v.id = p_ocev_rec.pdf_id;

      CURSOR sync_flag_yn_csr(p_cnh_id IN NUMBER) IS
      Select acn.sync_allowed_yn
      from okc_condition_headers_v cnh, okc_actions_v acn
      where cnh.id = p_cnh_id
      and cnh.acn_id = acn.id;

      CURSOR pdf_type_csr(p_pdf_id IN NUMBER) IS
      Select pdf.usage, pdf.pdf_type
      From okc_process_defs_v pdf, okc_outcomes_v oce
      where pdf.id = p_pdf_id
      and pdf.id = oce.pdf_id;

      l_dummy     	VARCHAR2(1) := '?';
      l_sync_flag  	okc_process_defs_v.pdf_type%TYPE;
      l_usage		okc_process_defs_v.usage%TYPE;
      l_pdf_type	okc_process_defs_v.pdf_type%TYPE;
   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if pdf_id is null
	IF p_ocev_rec.pdf_id = OKC_API.G_MISS_NUM OR p_ocev_rec.pdf_id IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'pdf_id');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Enforce foreign key
        OPEN okc_pdfv_pk_csr;
        FETCH okc_pdfv_pk_csr INTO l_dummy;
	CLOSE okc_pdfv_pk_csr;

	-- If l_dummy is still set to default, data was not found
        IF (l_dummy = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_no_parent_record,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'pdf_id',
                        	    p_token2       => g_child_table_token,
                        	    p_token2_value => 'OKC_OUTCOMES_V',
                        	    p_token3       => g_parent_table_token,
                        	    p_token3_value => 'OKC_PROCESS_DEFS_V');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

	--If sync_allowed_flag is 'N' then outcome cannot be 'Alert' or 'Script'
        OPEN sync_flag_yn_csr(p_ocev_rec.cnh_id);
	FETCH sync_flag_yn_csr INTO l_sync_flag;
        CLOSE sync_flag_yn_csr;

	OPEN pdf_type_csr(p_ocev_rec.pdf_id);
	FETCH pdf_type_csr INTO l_usage, l_pdf_type;
        CLOSE pdf_type_csr;

	IF l_sync_flag = 'N' then
		IF l_usage IN ('OUTCOME') THEN
			IF l_pdf_type IN ('ALERT', 'SCRIPT') THEN
				OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'pdf_id');
				RAISE G_EXCEPTION_HALT_VALIDATION;
			END IF;
		END IF;
	END IF;
  EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		-- verify that cursor was closed
		if okc_pdfv_pk_csr%ISOPEN then
      			close okc_pdfv_pk_csr;
    		end if;

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
  END validate_pdf_id;

  -- Start of comments
  -- Procedure Name  : validate_enabled_yn
  -- Description     : Checks if column ENABLED_YN is 'Y' or 'N' only
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE Validate_enabled_yn(x_return_status OUT NOCOPY VARCHAR2
			       ,p_ocev_rec IN ocev_rec_type) IS

  BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if enabled_yn is null
	IF p_ocev_rec.enabled_yn = OKC_API.G_MISS_CHAR OR p_ocev_rec.enabled_yn IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'enabled_yn');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	IF UPPER(p_ocev_rec.enabled_yn) IN ('Y', 'N') THEN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
	ELSE
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    p_msg_name     => g_invalid_value,
                           	    p_token1       => g_col_name_token,
                           	    p_token1_value => 'enabled_yn');
		x_return_status := OKC_API.G_RET_STS_ERROR;
	END IF;

	--Check if the data is in upper case
	IF p_ocev_rec.enabled_yn <> UPPER(p_ocev_rec.enabled_yn) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    p_msg_name     => g_uppercase_required,
                           	    p_token1       => g_col_name_token,
                           	    p_token1_value => 'enabled_yn');
		x_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_enabled_yn;

  FUNCTION Validate_Attributes (
    p_ocev_rec IN  ocev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    	validate_object_version_number(x_return_status => l_return_status
		   		      ,p_ocev_rec      => p_ocev_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_sfwt_flag(x_return_status => l_return_status
		          ,p_ocev_rec      => p_ocev_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;


	validate_seeded_flag(x_return_status => l_return_status
		          ,p_ocev_rec      => p_ocev_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_application_id(x_return_status => l_return_status
		          ,p_ocev_rec      => p_ocev_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_success_resource_id(x_return_status => l_return_status
		          ,p_ocev_rec      => p_ocev_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_failure_resource_id(x_return_status => l_return_status
		          ,p_ocev_rec      => p_ocev_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_cnh_id(x_return_status => l_return_status
		       ,p_ocev_rec      => p_ocev_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	/*validate_rul_id(x_return_status => l_return_status
		       ,p_ocev_rec      => p_ocev_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;*/

	validate_pdf_id(x_return_status => l_return_status
		       ,p_ocev_rec      => p_ocev_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_enabled_yn(x_return_status => l_return_status
		           ,p_ocev_rec      => p_ocev_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	RETURN(l_return_status);

  EXCEPTION
		When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;
		RETURN(l_return_status);

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
		RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKC_OUTCOMES_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_ocev_rec IN ocev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ocev_rec_type,
    p_to	OUT NOCOPY oce_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pdf_id := p_from.pdf_id;
    p_to.cnh_id := p_from.cnh_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.success_resource_id := p_from.success_resource_id;
    p_to.failure_resource_id := p_from.failure_resource_id;
    p_to.enabled_yn := p_from.enabled_yn;
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
    p_from	IN oce_rec_type,
    p_to	IN OUT NOCOPY ocev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pdf_id := p_from.pdf_id;
    p_to.cnh_id := p_from.cnh_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.success_resource_id := p_from.success_resource_id;
    p_to.failure_resource_id := p_from.failure_resource_id;
    p_to.enabled_yn := p_from.enabled_yn;
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
    p_from	IN ocev_rec_type,
    p_to	OUT NOCOPY okc_outcomes_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okc_outcomes_tl_rec_type,
    p_to	IN OUT NOCOPY ocev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
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
  -------------------------------------
  -- validate_row for:OKC_OUTCOMES_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ocev_rec                     ocev_rec_type := p_ocev_rec;
    l_oce_rec                      oce_rec_type;
    l_okc_outcomes_tl_rec          okc_outcomes_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_ocev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ocev_rec);
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
  -- PL/SQL TBL validate_row for:OCEV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_tbl                     IN ocev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ocev_tbl.COUNT > 0) THEN
      i := p_ocev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ocev_rec                     => p_ocev_tbl(i));
        EXIT WHEN (i = p_ocev_tbl.LAST);
        i := p_ocev_tbl.NEXT(i);
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
  -----------------------------------
  -- insert_row for:OKC_OUTCOMES_B --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oce_rec                      IN oce_rec_type,
    x_oce_rec                      OUT NOCOPY oce_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oce_rec                      oce_rec_type := p_oce_rec;
    l_def_oce_rec                  oce_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKC_OUTCOMES_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_oce_rec IN  oce_rec_type,
      x_oce_rec OUT NOCOPY oce_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oce_rec := p_oce_rec;
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
      p_oce_rec,                         -- IN
      l_oce_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_OUTCOMES_B(
        id,
        pdf_id,
        cnh_id,
        dnz_chr_id,
	   success_resource_id,
	   failure_resource_id,
        enabled_yn,
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
        l_oce_rec.id,
        l_oce_rec.pdf_id,
        l_oce_rec.cnh_id,
        l_oce_rec.dnz_chr_id,
	   l_oce_rec.success_resource_id,
	   l_oce_rec.failure_resource_id,
        l_oce_rec.enabled_yn,
        l_oce_rec.object_version_number,
        l_oce_rec.created_by,
        l_oce_rec.creation_date,
        l_oce_rec.last_updated_by,
        l_oce_rec.last_update_date,
        l_oce_rec.last_update_login,
        l_oce_rec.attribute_category,
        l_oce_rec.attribute1,
        l_oce_rec.attribute2,
        l_oce_rec.attribute3,
        l_oce_rec.attribute4,
        l_oce_rec.attribute5,
        l_oce_rec.attribute6,
        l_oce_rec.attribute7,
        l_oce_rec.attribute8,
        l_oce_rec.attribute9,
        l_oce_rec.attribute10,
        l_oce_rec.attribute11,
        l_oce_rec.attribute12,
        l_oce_rec.attribute13,
        l_oce_rec.attribute14,
        l_oce_rec.attribute15,
        l_oce_rec.application_id,
        l_oce_rec.seeded_flag);
    -- Set OUT values
    x_oce_rec := l_oce_rec;
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
  ------------------------------------
  -- insert_row for:OKC_OUTCOMES_TL --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_outcomes_tl_rec          IN okc_outcomes_tl_rec_type,
    x_okc_outcomes_tl_rec          OUT NOCOPY okc_outcomes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_outcomes_tl_rec          okc_outcomes_tl_rec_type := p_okc_outcomes_tl_rec;
    l_def_okc_outcomes_tl_rec      okc_outcomes_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------
    -- Set_Attributes for:OKC_OUTCOMES_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_outcomes_tl_rec IN  okc_outcomes_tl_rec_type,
      x_okc_outcomes_tl_rec OUT NOCOPY okc_outcomes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_outcomes_tl_rec := p_okc_outcomes_tl_rec;
      x_okc_outcomes_tl_rec.LANGUAGE :=l_lang;
      x_okc_outcomes_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_outcomes_tl_rec,             -- IN
      l_okc_outcomes_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_outcomes_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_OUTCOMES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_outcomes_tl_rec.id,
          l_okc_outcomes_tl_rec.language,
          l_okc_outcomes_tl_rec.source_lang,
          l_okc_outcomes_tl_rec.sfwt_flag,
          l_okc_outcomes_tl_rec.comments,
          l_okc_outcomes_tl_rec.created_by,
          l_okc_outcomes_tl_rec.creation_date,
          l_okc_outcomes_tl_rec.last_updated_by,
          l_okc_outcomes_tl_rec.last_update_date,
          l_okc_outcomes_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_outcomes_tl_rec := l_okc_outcomes_tl_rec;
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
  -- insert_row for:OKC_OUTCOMES_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type,
    x_ocev_rec                     OUT NOCOPY ocev_rec_type) IS

    l_id                           NUMBER ;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ocev_rec                     ocev_rec_type;
    l_def_ocev_rec                 ocev_rec_type;
    l_oce_rec                      oce_rec_type;
    lx_oce_rec                     oce_rec_type;
    l_okc_outcomes_tl_rec          okc_outcomes_tl_rec_type;
    lx_okc_outcomes_tl_rec         okc_outcomes_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ocev_rec	IN ocev_rec_type
    ) RETURN ocev_rec_type IS
      l_ocev_rec	ocev_rec_type := p_ocev_rec;
    BEGIN
      l_ocev_rec.CREATION_DATE := SYSDATE;
      l_ocev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ocev_rec.LAST_UPDATE_DATE := l_ocev_rec.CREATION_DATE;
      l_ocev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ocev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ocev_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKC_OUTCOMES_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_ocev_rec IN  ocev_rec_type,
      x_ocev_rec OUT NOCOPY ocev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ocev_rec := p_ocev_rec;
      x_ocev_rec.OBJECT_VERSION_NUMBER := 1;
      x_ocev_rec.SFWT_FLAG := 'N';
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
    l_ocev_rec := null_out_defaults(p_ocev_rec);
    -- Set primary key value
    -- If outcome record is created by seed then use sequence generated id
    IF l_ocev_rec.CREATED_BY = 1 THEN
	  SELECT OKC_OUTCOMES_S1.nextval INTO l_id FROM dual;
	  l_ocev_rec.ID := l_id;
	  l_ocev_rec.seeded_flag := 'Y';
    ELSE
       l_ocev_rec.ID := get_seq_id;
	  l_ocev_rec.seeded_flag := 'N';
    END IF;

    --l_ocev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ocev_rec,                        -- IN
      l_def_ocev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ocev_rec := fill_who_columns(l_def_ocev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ocev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ocev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ocev_rec, l_oce_rec);
    migrate(l_def_ocev_rec, l_okc_outcomes_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oce_rec,
      lx_oce_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oce_rec, l_def_ocev_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_outcomes_tl_rec,
      lx_okc_outcomes_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_outcomes_tl_rec, l_def_ocev_rec);
    -- Set OUT values
    x_ocev_rec := l_def_ocev_rec;
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
  -- PL/SQL TBL insert_row for:OCEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_tbl                     IN ocev_tbl_type,
    x_ocev_tbl                     OUT NOCOPY ocev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ocev_tbl.COUNT > 0) THEN
      i := p_ocev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ocev_rec                     => p_ocev_tbl(i),
          x_ocev_rec                     => x_ocev_tbl(i));
        EXIT WHEN (i = p_ocev_tbl.LAST);
        i := p_ocev_tbl.NEXT(i);
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
  ---------------------------------
  -- lock_row for:OKC_OUTCOMES_B --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oce_rec                      IN oce_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_oce_rec IN oce_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_OUTCOMES_B
     WHERE ID = p_oce_rec.id
       AND OBJECT_VERSION_NUMBER = p_oce_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_oce_rec IN oce_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_OUTCOMES_B
    WHERE ID = p_oce_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_OUTCOMES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_OUTCOMES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_oce_rec);
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
      OPEN lchk_csr(p_oce_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_oce_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_oce_rec.object_version_number THEN
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
  ----------------------------------
  -- lock_row for:OKC_OUTCOMES_TL --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_outcomes_tl_rec          IN okc_outcomes_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_outcomes_tl_rec IN okc_outcomes_tl_rec_type) IS
    SELECT *
      FROM OKC_OUTCOMES_TL
     WHERE ID = p_okc_outcomes_tl_rec.id
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
      OPEN lock_csr(p_okc_outcomes_tl_rec);
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
  ---------------------------------
  -- lock_row for:OKC_OUTCOMES_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oce_rec                      oce_rec_type;
    l_okc_outcomes_tl_rec          okc_outcomes_tl_rec_type;
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
    migrate(p_ocev_rec, l_oce_rec);
    migrate(p_ocev_rec, l_okc_outcomes_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oce_rec
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
      l_okc_outcomes_tl_rec
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
  -- PL/SQL TBL lock_row for:OCEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_tbl                     IN ocev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ocev_tbl.COUNT > 0) THEN
      i := p_ocev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ocev_rec                     => p_ocev_tbl(i));
        EXIT WHEN (i = p_ocev_tbl.LAST);
        i := p_ocev_tbl.NEXT(i);
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
  -----------------------------------
  -- update_row for:OKC_OUTCOMES_B --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oce_rec                      IN oce_rec_type,
    x_oce_rec                      OUT NOCOPY oce_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oce_rec                      oce_rec_type := p_oce_rec;
    l_def_oce_rec                  oce_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oce_rec	IN oce_rec_type,
      x_oce_rec	OUT NOCOPY oce_rec_type
    ) RETURN VARCHAR2 IS
      l_oce_rec                      oce_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oce_rec := p_oce_rec;
      -- Get current database values
      l_oce_rec := get_rec(p_oce_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_oce_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.id := l_oce_rec.id;
      END IF;
      IF (x_oce_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.pdf_id := l_oce_rec.pdf_id;
      END IF;
      IF (x_oce_rec.cnh_id = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.cnh_id := l_oce_rec.cnh_id;
      END IF;
      IF (x_oce_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.dnz_chr_id := l_oce_rec.dnz_chr_id;
      END IF;
      IF (x_oce_rec.success_resource_id = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.success_resource_id := l_oce_rec.success_resource_id;
      END IF;
      IF (x_oce_rec.failure_resource_id = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.failure_resource_id := l_oce_rec.failure_resource_id;
      END IF;
      IF (x_oce_rec.enabled_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.enabled_yn := l_oce_rec.enabled_yn;
      END IF;
      IF (x_oce_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.object_version_number := l_oce_rec.object_version_number;
      END IF;
      IF (x_oce_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.created_by := l_oce_rec.created_by;
      END IF;
      IF (x_oce_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_oce_rec.creation_date := l_oce_rec.creation_date;
      END IF;
      IF (x_oce_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.last_updated_by := l_oce_rec.last_updated_by;
      END IF;
      IF (x_oce_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_oce_rec.last_update_date := l_oce_rec.last_update_date;
      END IF;
      IF (x_oce_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.last_update_login := l_oce_rec.last_update_login;
      END IF;
      IF (x_oce_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute_category := l_oce_rec.attribute_category;
      END IF;
      IF (x_oce_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute1 := l_oce_rec.attribute1;
      END IF;
      IF (x_oce_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute2 := l_oce_rec.attribute2;
      END IF;
      IF (x_oce_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute3 := l_oce_rec.attribute3;
      END IF;
      IF (x_oce_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute4 := l_oce_rec.attribute4;
      END IF;
      IF (x_oce_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute5 := l_oce_rec.attribute5;
      END IF;
      IF (x_oce_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute6 := l_oce_rec.attribute6;
      END IF;
      IF (x_oce_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute7 := l_oce_rec.attribute7;
      END IF;
      IF (x_oce_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute8 := l_oce_rec.attribute8;
      END IF;
      IF (x_oce_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute9 := l_oce_rec.attribute9;
      END IF;
      IF (x_oce_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute10 := l_oce_rec.attribute10;
      END IF;
      IF (x_oce_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute11 := l_oce_rec.attribute11;
      END IF;
      IF (x_oce_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute12 := l_oce_rec.attribute12;
      END IF;
      IF (x_oce_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute13 := l_oce_rec.attribute13;
      END IF;
      IF (x_oce_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute14 := l_oce_rec.attribute14;
      END IF;
      IF (x_oce_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.attribute15 := l_oce_rec.attribute15;
      END IF;
      IF (x_oce_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_oce_rec.application_id := l_oce_rec.application_id;
      END IF;
      IF (x_oce_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_oce_rec.seeded_flag := l_oce_rec.seeded_flag;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_OUTCOMES_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_oce_rec IN  oce_rec_type,
      x_oce_rec OUT NOCOPY oce_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oce_rec := p_oce_rec;
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
      p_oce_rec,                         -- IN
      l_oce_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oce_rec, l_def_oce_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_OUTCOMES_B
    SET PDF_ID = l_def_oce_rec.pdf_id,
        CNH_ID = l_def_oce_rec.cnh_id,
        DNZ_CHR_ID = l_def_oce_rec.dnz_chr_id,
	   SUCCESS_resource_ID = l_def_oce_rec.success_resource_id,
	   FAILURE_resource_ID = l_def_oce_rec.failure_resource_id,
        ENABLED_YN = l_def_oce_rec.enabled_yn,
        OBJECT_VERSION_NUMBER = l_def_oce_rec.object_version_number,
        CREATED_BY = l_def_oce_rec.created_by,
        CREATION_DATE = l_def_oce_rec.creation_date,
        LAST_UPDATED_BY = l_def_oce_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_oce_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_oce_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_oce_rec.attribute_category,
        ATTRIBUTE1 = l_def_oce_rec.attribute1,
        ATTRIBUTE2 = l_def_oce_rec.attribute2,
        ATTRIBUTE3 = l_def_oce_rec.attribute3,
        ATTRIBUTE4 = l_def_oce_rec.attribute4,
        ATTRIBUTE5 = l_def_oce_rec.attribute5,
        ATTRIBUTE6 = l_def_oce_rec.attribute6,
        ATTRIBUTE7 = l_def_oce_rec.attribute7,
        ATTRIBUTE8 = l_def_oce_rec.attribute8,
        ATTRIBUTE9 = l_def_oce_rec.attribute9,
        ATTRIBUTE10 = l_def_oce_rec.attribute10,
        ATTRIBUTE11 = l_def_oce_rec.attribute11,
        ATTRIBUTE12 = l_def_oce_rec.attribute12,
        ATTRIBUTE13 = l_def_oce_rec.attribute13,
        ATTRIBUTE14 = l_def_oce_rec.attribute14,
        ATTRIBUTE15 = l_def_oce_rec.attribute15,
        APPLICATION_ID = l_def_oce_rec.application_id,
        SEEDED_FLAG = l_def_oce_rec.seeded_flag
    WHERE ID = l_def_oce_rec.id;

    x_oce_rec := l_def_oce_rec;
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
  ------------------------------------
  -- update_row for:OKC_OUTCOMES_TL --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_outcomes_tl_rec          IN okc_outcomes_tl_rec_type,
    x_okc_outcomes_tl_rec          OUT NOCOPY okc_outcomes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_outcomes_tl_rec          okc_outcomes_tl_rec_type := p_okc_outcomes_tl_rec;
    l_def_okc_outcomes_tl_rec      okc_outcomes_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_outcomes_tl_rec	IN okc_outcomes_tl_rec_type,
      x_okc_outcomes_tl_rec	OUT NOCOPY okc_outcomes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_outcomes_tl_rec          okc_outcomes_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_outcomes_tl_rec := p_okc_outcomes_tl_rec;
      -- Get current database values
      l_okc_outcomes_tl_rec := get_rec(p_okc_outcomes_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_outcomes_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_outcomes_tl_rec.id := l_okc_outcomes_tl_rec.id;
      END IF;
      IF (x_okc_outcomes_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_outcomes_tl_rec.language := l_okc_outcomes_tl_rec.language;
      END IF;
      IF (x_okc_outcomes_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_outcomes_tl_rec.source_lang := l_okc_outcomes_tl_rec.source_lang;
      END IF;
      IF (x_okc_outcomes_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_outcomes_tl_rec.sfwt_flag := l_okc_outcomes_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_outcomes_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_outcomes_tl_rec.comments := l_okc_outcomes_tl_rec.comments;
      END IF;
      IF (x_okc_outcomes_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_outcomes_tl_rec.created_by := l_okc_outcomes_tl_rec.created_by;
      END IF;
      IF (x_okc_outcomes_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_outcomes_tl_rec.creation_date := l_okc_outcomes_tl_rec.creation_date;
      END IF;
      IF (x_okc_outcomes_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_outcomes_tl_rec.last_updated_by := l_okc_outcomes_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_outcomes_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_outcomes_tl_rec.last_update_date := l_okc_outcomes_tl_rec.last_update_date;
      END IF;
      IF (x_okc_outcomes_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_outcomes_tl_rec.last_update_login := l_okc_outcomes_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_OUTCOMES_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_outcomes_tl_rec IN  okc_outcomes_tl_rec_type,
      x_okc_outcomes_tl_rec OUT NOCOPY okc_outcomes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_outcomes_tl_rec := p_okc_outcomes_tl_rec;
      x_okc_outcomes_tl_rec.LANGUAGE := l_lang;
      x_okc_outcomes_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_outcomes_tl_rec,             -- IN
      l_okc_outcomes_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_outcomes_tl_rec, l_def_okc_outcomes_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_OUTCOMES_TL
    SET COMMENTS = l_def_okc_outcomes_tl_rec.comments,
        SOURCE_LANG = l_def_okc_outcomes_tl_rec.source_lang,
        CREATED_BY = l_def_okc_outcomes_tl_rec.created_by,
        CREATION_DATE = l_def_okc_outcomes_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_outcomes_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_outcomes_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_outcomes_tl_rec.last_update_login
    WHERE ID = l_def_okc_outcomes_tl_rec.id
      AND USERENV('LANG') IN (SOURCE_LANG,LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_OUTCOMES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okc_outcomes_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_outcomes_tl_rec := l_def_okc_outcomes_tl_rec;
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
  -- update_row for:OKC_OUTCOMES_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type,
    x_ocev_rec                     OUT NOCOPY ocev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ocev_rec                     ocev_rec_type := p_ocev_rec;
    l_def_ocev_rec                 ocev_rec_type;
    l_okc_outcomes_tl_rec          okc_outcomes_tl_rec_type;
    lx_okc_outcomes_tl_rec         okc_outcomes_tl_rec_type;
    l_oce_rec                      oce_rec_type;
    lx_oce_rec                     oce_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ocev_rec	IN ocev_rec_type
    ) RETURN ocev_rec_type IS
      l_ocev_rec	ocev_rec_type := p_ocev_rec;
    BEGIN
      l_ocev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ocev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ocev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ocev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ocev_rec	IN ocev_rec_type,
      x_ocev_rec	OUT NOCOPY ocev_rec_type
    ) RETURN VARCHAR2 IS
      l_ocev_rec                     ocev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ocev_rec := p_ocev_rec;
      -- Get current database values
      l_ocev_rec := get_rec(p_ocev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ocev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.id := l_ocev_rec.id;
      END IF;
      IF (x_ocev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.object_version_number := l_ocev_rec.object_version_number;
      END IF;
      IF (x_ocev_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.sfwt_flag := l_ocev_rec.sfwt_flag;
      END IF;
      IF (x_ocev_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.pdf_id := l_ocev_rec.pdf_id;
      END IF;
      IF (x_ocev_rec.cnh_id = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.cnh_id := l_ocev_rec.cnh_id;
      END IF;
      IF (x_ocev_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.dnz_chr_id := l_ocev_rec.dnz_chr_id;
      END IF;
      IF (x_ocev_rec.success_resource_id = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.success_resource_id := l_ocev_rec.success_resource_id;
      END IF;
      IF (x_ocev_rec.failure_resource_id = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.failure_resource_id := l_ocev_rec.failure_resource_id;
      END IF;
      IF (x_ocev_rec.enabled_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.enabled_yn := l_ocev_rec.enabled_yn;
      END IF;
      IF (x_ocev_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.comments := l_ocev_rec.comments;
      END IF;
      IF (x_ocev_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.application_id := l_ocev_rec.application_id;
      END IF;
      IF (x_ocev_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.seeded_flag := l_ocev_rec.seeded_flag;
      END IF;
      IF (x_ocev_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute_category := l_ocev_rec.attribute_category;
      END IF;
      IF (x_ocev_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute1 := l_ocev_rec.attribute1;
      END IF;
      IF (x_ocev_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute2 := l_ocev_rec.attribute2;
      END IF;
      IF (x_ocev_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute3 := l_ocev_rec.attribute3;
      END IF;
      IF (x_ocev_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute4 := l_ocev_rec.attribute4;
      END IF;
      IF (x_ocev_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute5 := l_ocev_rec.attribute5;
      END IF;
      IF (x_ocev_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute6 := l_ocev_rec.attribute6;
      END IF;
      IF (x_ocev_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute7 := l_ocev_rec.attribute7;
      END IF;
      IF (x_ocev_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute8 := l_ocev_rec.attribute8;
      END IF;
      IF (x_ocev_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute9 := l_ocev_rec.attribute9;
      END IF;
      IF (x_ocev_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute10 := l_ocev_rec.attribute10;
      END IF;
      IF (x_ocev_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute11 := l_ocev_rec.attribute11;
      END IF;
      IF (x_ocev_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute12 := l_ocev_rec.attribute12;
      END IF;
      IF (x_ocev_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute13 := l_ocev_rec.attribute13;
      END IF;
      IF (x_ocev_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute14 := l_ocev_rec.attribute14;
      END IF;
      IF (x_ocev_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_ocev_rec.attribute15 := l_ocev_rec.attribute15;
      END IF;
      IF (x_ocev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.created_by := l_ocev_rec.created_by;
      END IF;
      IF (x_ocev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ocev_rec.creation_date := l_ocev_rec.creation_date;
      END IF;
      IF (x_ocev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.last_updated_by := l_ocev_rec.last_updated_by;
      END IF;
      IF (x_ocev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ocev_rec.last_update_date := l_ocev_rec.last_update_date;
      END IF;
      IF (x_ocev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ocev_rec.last_update_login := l_ocev_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_OUTCOMES_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_ocev_rec IN  ocev_rec_type,
      x_ocev_rec OUT NOCOPY ocev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ocev_rec := p_ocev_rec;
      x_ocev_rec.OBJECT_VERSION_NUMBER := NVL(x_ocev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    --  Seed data should not be updated unless user is DATAMERGE
    IF l_ocev_rec.last_updated_by = 1 THEN
    IF l_ocev_rec.seeded_flag = 'Y' THEN
	  OKC_API.set_message(p_app_name => G_APP_NAME,
					  p_msg_name => 'OKC_NOT_DELETE_SEEDED');
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ocev_rec,                        -- IN
      l_ocev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ocev_rec, l_def_ocev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ocev_rec := fill_who_columns(l_def_ocev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ocev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ocev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ocev_rec, l_okc_outcomes_tl_rec);
    migrate(l_def_ocev_rec, l_oce_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_outcomes_tl_rec,
      lx_okc_outcomes_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_outcomes_tl_rec, l_def_ocev_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oce_rec,
      lx_oce_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oce_rec, l_def_ocev_rec);
    x_ocev_rec := l_def_ocev_rec;
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
  -- PL/SQL TBL update_row for:OCEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_tbl                     IN ocev_tbl_type,
    x_ocev_tbl                     OUT NOCOPY ocev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ocev_tbl.COUNT > 0) THEN
      i := p_ocev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ocev_rec                     => p_ocev_tbl(i),
          x_ocev_rec                     => x_ocev_tbl(i));
        EXIT WHEN (i = p_ocev_tbl.LAST);
        i := p_ocev_tbl.NEXT(i);
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
  -----------------------------------
  -- delete_row for:OKC_OUTCOMES_B --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oce_rec                      IN oce_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oce_rec                      oce_rec_type:= p_oce_rec;
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
    DELETE FROM OKC_OUTCOMES_B
     WHERE ID = l_oce_rec.id;

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
  ------------------------------------
  -- delete_row for:OKC_OUTCOMES_TL --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_outcomes_tl_rec          IN okc_outcomes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_outcomes_tl_rec          okc_outcomes_tl_rec_type:= p_okc_outcomes_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------
    -- Set_Attributes for:OKC_OUTCOMES_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_outcomes_tl_rec IN  okc_outcomes_tl_rec_type,
      x_okc_outcomes_tl_rec OUT NOCOPY okc_outcomes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_outcomes_tl_rec := p_okc_outcomes_tl_rec;
      x_okc_outcomes_tl_rec.LANGUAGE := l_lang;
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
      p_okc_outcomes_tl_rec,             -- IN
      l_okc_outcomes_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_OUTCOMES_TL
     WHERE ID = l_okc_outcomes_tl_rec.id;

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
  -- delete_row for:OKC_OUTCOMES_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ocev_rec                     ocev_rec_type := p_ocev_rec;
    l_okc_outcomes_tl_rec          okc_outcomes_tl_rec_type;
    l_oce_rec                      oce_rec_type;
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
    --  Seed data should not be deleted unless user is DATAMERGE
    IF l_ocev_rec.last_updated_by <> 1 THEN
    IF l_ocev_rec.seeded_flag = 'Y' THEN
	  OKC_API.set_message(p_app_name => G_APP_NAME,
					  p_msg_name => 'OKC_NOT_DELETE_SEEDED');
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_ocev_rec, l_okc_outcomes_tl_rec);
    migrate(l_ocev_rec, l_oce_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_outcomes_tl_rec
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
      l_oce_rec
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
  -- PL/SQL TBL delete_row for:OCEV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_tbl                     IN ocev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ocev_tbl.COUNT > 0) THEN
      i := p_ocev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ocev_rec                     => p_ocev_tbl(i));
        EXIT WHEN (i = p_ocev_tbl.LAST);
        i := p_ocev_tbl.NEXT(i);
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
-- Procedure for mass insert in OKC_OUTCOMES _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_ocev_tbl ocev_tbl_type) IS
  l_tabsize NUMBER := p_ocev_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_pdf_id                        OKC_DATATYPES.NumberTabTyp;
  in_cnh_id                        OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_success_resource_id                    OKC_DATATYPES.NumberTabTyp;
  in_failure_resource_id                    OKC_DATATYPES.NumberTabTyp;
  in_enabled_yn                    OKC_DATATYPES.Var3TabTyp;
  in_comments                      OKC_DATATYPES.Var1995TabTyp;
  in_application_id                OKC_DATATYPES.NumberTabTyp;
  in_seeded_flag                   OKC_DATATYPES.Var3TabTyp;
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
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  j                                NUMBER := 0;
  i                                NUMBER := p_ocev_tbl.FIRST;
BEGIN

   --Initialize return status
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

  while i is not null
  LOOP
    j := j + 1;
    in_id                       (j) := p_ocev_tbl(i).id;
    in_object_version_number    (j) := p_ocev_tbl(i).object_version_number;
    in_sfwt_flag                (j) := p_ocev_tbl(i).sfwt_flag;
    in_pdf_id                   (j) := p_ocev_tbl(i).pdf_id;
    in_cnh_id                   (j) := p_ocev_tbl(i).cnh_id;
    in_dnz_chr_id               (j) := p_ocev_tbl(i).dnz_chr_id;
    in_success_resource_id          (j) := p_ocev_tbl(i).success_resource_id;
    in_failure_resource_id          (j) := p_ocev_tbl(i).failure_resource_id;
    in_enabled_yn               (j) := p_ocev_tbl(i).enabled_yn;
    in_comments                 (j) := p_ocev_tbl(i).comments;
    in_application_id           (j) := p_ocev_tbl(i).application_id;
    in_seeded_flag              (j) := p_ocev_tbl(i).seeded_flag;
    in_attribute_category       (j) := p_ocev_tbl(i).attribute_category;
    in_attribute1               (j) := p_ocev_tbl(i).attribute1;
    in_attribute2               (j) := p_ocev_tbl(i).attribute2;
    in_attribute3               (j) := p_ocev_tbl(i).attribute3;
    in_attribute4               (j) := p_ocev_tbl(i).attribute4;
    in_attribute5               (j) := p_ocev_tbl(i).attribute5;
    in_attribute6               (j) := p_ocev_tbl(i).attribute6;
    in_attribute7               (j) := p_ocev_tbl(i).attribute7;
    in_attribute8               (j) := p_ocev_tbl(i).attribute8;
    in_attribute9               (j) := p_ocev_tbl(i).attribute9;
    in_attribute10              (j) := p_ocev_tbl(i).attribute10;
    in_attribute11              (j) := p_ocev_tbl(i).attribute11;
    in_attribute12              (j) := p_ocev_tbl(i).attribute12;
    in_attribute13              (j) := p_ocev_tbl(i).attribute13;
    in_attribute14              (j) := p_ocev_tbl(i).attribute14;
    in_attribute15              (j) := p_ocev_tbl(i).attribute15;
    in_created_by               (j) := p_ocev_tbl(i).created_by;
    in_creation_date            (j) := p_ocev_tbl(i).creation_date;
    in_last_updated_by          (j) := p_ocev_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_ocev_tbl(i).last_update_date;
    in_last_update_login        (j) := p_ocev_tbl(i).last_update_login;
    i := p_ocev_tbl.NEXT(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_OUTCOMES_B
      (
        id,
        pdf_id,
        cnh_id,
        dnz_chr_id,
	   success_resource_id,
	   failure_resource_id,
        enabled_yn,
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
        seeded_flag
     )
     VALUES (
        in_id(i),
        in_pdf_id(i),
        in_cnh_id(i),
        in_dnz_chr_id(i),
	   in_success_resource_id(i),
	   in_failure_resource_id(i),
        in_enabled_yn(i),
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
        in_application_id(i),
        in_seeded_flag(i)
     );

  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..l_tabsize
      INSERT INTO OKC_OUTCOMES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        comments,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
     )
     VALUES (
        in_id(i),
        OKC_UTIL.g_language_code(lang_i),
        l_source_lang,
        in_sfwt_flag(i),
        in_comments(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i)
      );
      END LOOP;
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

--    RAISE;
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
INSERT INTO okc_outcomes_bh
  (
      major_version,
      id,
      pdf_id,
      cnh_id,
      dnz_chr_id,
	 success_resource_id,
	 failure_resource_id,
      enabled_yn,
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
      seeded_flag
)
  SELECT
      p_major_version,
      id,
      pdf_id,
      cnh_id,
      dnz_chr_id,
	 success_resource_id,
	 failure_resource_id,
      enabled_yn,
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
    seeded_flag
  FROM okc_outcomes_b
 WHERE dnz_chr_id = p_chr_id;

------------------------------
-- Versioning TL Table
------------------------------

INSERT INTO okc_outcomes_tlh
  (
      major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      p_major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_outcomes_tl
 WHERE id in (select id from okc_outcomes_b
		    where dnz_chr_id = p_chr_id);

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

--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_outcomes_tl
(
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_outcomes_tlh
WHERE id in (select id from okc_outcomes_b where dnz_chr_id = p_chr_id)
  AND major_version = p_major_version;

--------------------------------------
-- Restoring Base Table
--------------------------------------

INSERT INTO okc_outcomes_b
  (
      id,
      pdf_id,
      cnh_id,
      dnz_chr_id,
      enabled_yn,
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
	 success_resource_id,
	 failure_resource_id,
    application_id,
    seeded_flag
)
  SELECT
      id,
      pdf_id,
      cnh_id,
      dnz_chr_id,
      enabled_yn,
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
	   success_resource_id,
	   failure_resource_id,
      application_id,
      seeded_flag
  FROM okc_outcomes_bh
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

END OKC_OCE_PVT;

/
