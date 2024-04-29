--------------------------------------------------------
--  DDL for Package Body OKC_AAE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AAE_PVT" AS
/* $Header: OKCSAAEB.pls 120.1 2005/12/19 11:39:22 rvohra noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  l_lang      VARCHAR2(12)  := okc_util.get_userenv_lang;
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

    DELETE FROM OKC_ACTION_ATTRIBUTES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_ACTION_ATTRIBUTES_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_ACTION_ATTRIBUTES_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKC_ACTION_ATTRIBUTES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_ACTION_ATTRIBUTES_TL SUBB, OKC_ACTION_ATTRIBUTES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));
*/

    INSERT INTO OKC_ACTION_ATTRIBUTES_TL (
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
        FROM OKC_ACTION_ATTRIBUTES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_ACTION_ATTRIBUTES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ACTION_ATTRIBUTES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aae_rec                      IN aae_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aae_rec_type IS
    CURSOR okc_action_attributes_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            AAL_ID,
            ACN_ID,
            ELEMENT_NAME,
            DATA_TYPE,
            LIST_YN,
            VISIBLE_YN,
            DATE_OF_INTEREST_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            FORMAT_MASK,
            MINIMUM_VALUE,
            MAXIMUM_VALUE,
            JTOT_OBJECT_CODE,
            NAME_COLUMN,
            DESCRIPTION_COLUMN,
            source_doc_number_yn,
            LAST_UPDATE_LOGIN,
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
            ATTRIBUTE15
      FROM Okc_Action_Attributes_B
     WHERE okc_action_attributes_b.id = p_id;
    l_okc_action_attributes_b_pk   okc_action_attributes_b_pk_csr%ROWTYPE;
    l_aae_rec                      aae_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_action_attributes_b_pk_csr (p_aae_rec.id);
    FETCH okc_action_attributes_b_pk_csr INTO
              l_aae_rec.ID,
              l_aae_rec.AAL_ID,
              l_aae_rec.ACN_ID,
              l_aae_rec.ELEMENT_NAME,
              l_aae_rec.DATA_TYPE,
              l_aae_rec.LIST_YN,
              l_aae_rec.VISIBLE_YN,
              l_aae_rec.DATE_OF_INTEREST_YN,
              l_aae_rec.OBJECT_VERSION_NUMBER,
              l_aae_rec.CREATED_BY,
              l_aae_rec.CREATION_DATE,
              l_aae_rec.LAST_UPDATED_BY,
              l_aae_rec.LAST_UPDATE_DATE,
              l_aae_rec.FORMAT_MASK,
              l_aae_rec.MINIMUM_VALUE,
              l_aae_rec.MAXIMUM_VALUE,
              l_aae_rec.JTOT_OBJECT_CODE,
              l_aae_rec.NAME_COLUMN,
              l_aae_rec.DESCRIPTION_COLUMN,
              l_aae_rec.source_doc_number_yn,
              l_aae_rec.LAST_UPDATE_LOGIN,
              l_aae_rec.APPLICATION_ID,
              l_aae_rec.SEEDED_FLAG,
              l_aae_rec.ATTRIBUTE_CATEGORY,
              l_aae_rec.ATTRIBUTE1,
              l_aae_rec.ATTRIBUTE2,
              l_aae_rec.ATTRIBUTE3,
              l_aae_rec.ATTRIBUTE4,
              l_aae_rec.ATTRIBUTE5,
              l_aae_rec.ATTRIBUTE6,
              l_aae_rec.ATTRIBUTE7,
              l_aae_rec.ATTRIBUTE8,
              l_aae_rec.ATTRIBUTE9,
              l_aae_rec.ATTRIBUTE10,
              l_aae_rec.ATTRIBUTE11,
              l_aae_rec.ATTRIBUTE12,
              l_aae_rec.ATTRIBUTE13,
              l_aae_rec.ATTRIBUTE14,
              l_aae_rec.ATTRIBUTE15;
    x_no_data_found := okc_action_attributes_b_pk_csr%NOTFOUND;
    CLOSE okc_action_attributes_b_pk_csr;
    RETURN(l_aae_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aae_rec                      IN aae_rec_type
  ) RETURN aae_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aae_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ACTION_ATTRIBUTES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_action_attributes_tl_rec IN OkcActionAttributesTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OkcActionAttributesTlRecType IS
    CURSOR okc_action_attribute1_csr (p_id                 IN NUMBER,
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
      FROM Okc_Action_Attributes_Tl
     WHERE okc_action_attributes_tl.id = p_id
       AND okc_action_attributes_tl.language = p_language;
    l_okc_action_attributes_tl_pk  okc_action_attribute1_csr%ROWTYPE;
    l_okc_action_attributes_tl_rec OkcActionAttributesTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_action_attribute1_csr (p_okc_action_attributes_tl_rec.id,
                                    p_okc_action_attributes_tl_rec.language);
    FETCH okc_action_attribute1_csr INTO
              l_okc_action_attributes_tl_rec.ID,
              l_okc_action_attributes_tl_rec.LANGUAGE,
              l_okc_action_attributes_tl_rec.SOURCE_LANG,
              l_okc_action_attributes_tl_rec.SFWT_FLAG,
              l_okc_action_attributes_tl_rec.NAME,
              l_okc_action_attributes_tl_rec.DESCRIPTION,
              l_okc_action_attributes_tl_rec.CREATED_BY,
              l_okc_action_attributes_tl_rec.CREATION_DATE,
              l_okc_action_attributes_tl_rec.LAST_UPDATED_BY,
              l_okc_action_attributes_tl_rec.LAST_UPDATE_DATE,
              l_okc_action_attributes_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_action_attribute1_csr%NOTFOUND;
    CLOSE okc_action_attribute1_csr;
    RETURN(l_okc_action_attributes_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_action_attributes_tl_rec IN OkcActionAttributesTlRecType
  ) RETURN OkcActionAttributesTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_action_attributes_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ACTION_ATTRIBUTES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aaev_rec                     IN aaev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aaev_rec_type IS
    CURSOR okc_aaev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            AAL_ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            ACN_ID,
            ELEMENT_NAME,
            NAME,
            DESCRIPTION,
            DATA_TYPE,
            LIST_YN,
            VISIBLE_YN,
            DATE_OF_INTEREST_YN,
            FORMAT_MASK,
            MINIMUM_VALUE,
            MAXIMUM_VALUE,
            JTOT_OBJECT_CODE,
            NAME_COLUMN,
            DESCRIPTION_COLUMN,
            source_doc_number_yn,
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
      FROM Okc_Action_Attributes_V
     WHERE okc_action_attributes_v.id = p_id;
    l_okc_aaev_pk                  okc_aaev_pk_csr%ROWTYPE;
    l_aaev_rec                     aaev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_aaev_pk_csr (p_aaev_rec.id);
    FETCH okc_aaev_pk_csr INTO
              l_aaev_rec.ID,
              l_aaev_rec.AAL_ID,
              l_aaev_rec.OBJECT_VERSION_NUMBER,
              l_aaev_rec.SFWT_FLAG,
              l_aaev_rec.ACN_ID,
              l_aaev_rec.ELEMENT_NAME,
              l_aaev_rec.NAME,
              l_aaev_rec.DESCRIPTION,
              l_aaev_rec.DATA_TYPE,
              l_aaev_rec.LIST_YN,
              l_aaev_rec.VISIBLE_YN,
              l_aaev_rec.DATE_OF_INTEREST_YN,
              l_aaev_rec.FORMAT_MASK,
              l_aaev_rec.MINIMUM_VALUE,
              l_aaev_rec.MAXIMUM_VALUE,
              l_aaev_rec.JTOT_OBJECT_CODE,
              l_aaev_rec.NAME_COLUMN,
              l_aaev_rec.DESCRIPTION_COLUMN,
              l_aaev_rec.source_doc_number_yn,
              l_aaev_rec.APPLICATION_ID,
              l_aaev_rec.SEEDED_FLAG,
              l_aaev_rec.ATTRIBUTE_CATEGORY,
              l_aaev_rec.ATTRIBUTE1,
              l_aaev_rec.ATTRIBUTE2,
              l_aaev_rec.ATTRIBUTE3,
              l_aaev_rec.ATTRIBUTE4,
              l_aaev_rec.ATTRIBUTE5,
              l_aaev_rec.ATTRIBUTE6,
              l_aaev_rec.ATTRIBUTE7,
              l_aaev_rec.ATTRIBUTE8,
              l_aaev_rec.ATTRIBUTE9,
              l_aaev_rec.ATTRIBUTE10,
              l_aaev_rec.ATTRIBUTE11,
              l_aaev_rec.ATTRIBUTE12,
              l_aaev_rec.ATTRIBUTE13,
              l_aaev_rec.ATTRIBUTE14,
              l_aaev_rec.ATTRIBUTE15,
              l_aaev_rec.CREATED_BY,
              l_aaev_rec.CREATION_DATE,
              l_aaev_rec.LAST_UPDATED_BY,
              l_aaev_rec.LAST_UPDATE_DATE,
              l_aaev_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_aaev_pk_csr%NOTFOUND;
    CLOSE okc_aaev_pk_csr;
    RETURN(l_aaev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aaev_rec                     IN aaev_rec_type
  ) RETURN aaev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aaev_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_ACTION_ATTRIBUTES_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_aaev_rec	IN aaev_rec_type
  ) RETURN aaev_rec_type IS
    l_aaev_rec	aaev_rec_type := p_aaev_rec;
  BEGIN
    IF (l_aaev_rec.aal_id = OKC_API.G_MISS_NUM) THEN
      l_aaev_rec.aal_id := NULL;
    END IF;
    IF (l_aaev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_aaev_rec.object_version_number := NULL;
    END IF;
    IF (l_aaev_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.sfwt_flag := NULL;
    END IF;
    IF (l_aaev_rec.acn_id = OKC_API.G_MISS_NUM) THEN
      l_aaev_rec.acn_id := NULL;
    END IF;
    IF (l_aaev_rec.element_name = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.element_name := NULL;
    END IF;
    IF (l_aaev_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.name := NULL;
    END IF;
    IF (l_aaev_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.description := NULL;
    END IF;
    IF (l_aaev_rec.data_type = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.data_type := NULL;
    END IF;
    IF (l_aaev_rec.list_yn = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.list_yn := NULL;
    END IF;
    IF (l_aaev_rec.visible_yn = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.visible_yn := NULL;
    END IF;
    IF (l_aaev_rec.date_of_interest_yn = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.date_of_interest_yn := NULL;
    END IF;
    IF (l_aaev_rec.format_mask = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.format_mask := NULL;
    END IF;
    IF (l_aaev_rec.minimum_value = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.minimum_value := NULL;
    END IF;
    IF (l_aaev_rec.maximum_value = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.maximum_value := NULL;
    END IF;
    IF (l_aaev_rec.JTOT_object_code = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.JTOT_object_code := NULL;
    END IF;
    IF (l_aaev_rec.NAME_COLUMN = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.NAME_COLUMN := NULL;
    END IF;
    IF (l_aaev_rec.description_column = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.description_column := NULL;
    END IF;
    IF (l_aaev_rec.source_doc_number_yn = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.source_doc_number_yn := NULL;
    END IF;
    IF (l_aaev_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_aaev_rec.application_id := NULL;
    END IF;
    IF (l_aaev_rec.seeded_flag = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.seeded_flag := NULL;
    END IF;
    IF (l_aaev_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute_category := NULL;
    END IF;
    IF (l_aaev_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute1 := NULL;
    END IF;
    IF (l_aaev_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute2 := NULL;
    END IF;
    IF (l_aaev_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute3 := NULL;
    END IF;
    IF (l_aaev_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute4 := NULL;
    END IF;
    IF (l_aaev_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute5 := NULL;
    END IF;
    IF (l_aaev_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute6 := NULL;
    END IF;
    IF (l_aaev_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute7 := NULL;
    END IF;
    IF (l_aaev_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute8 := NULL;
    END IF;
    IF (l_aaev_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute9 := NULL;
    END IF;
    IF (l_aaev_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute10 := NULL;
    END IF;
    IF (l_aaev_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute11 := NULL;
    END IF;
    IF (l_aaev_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute12 := NULL;
    END IF;
    IF (l_aaev_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute13 := NULL;
    END IF;
    IF (l_aaev_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute14 := NULL;
    END IF;
    IF (l_aaev_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_aaev_rec.attribute15 := NULL;
    END IF;
    IF (l_aaev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_aaev_rec.created_by := NULL;
    END IF;
    IF (l_aaev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_aaev_rec.creation_date := NULL;
    END IF;
    IF (l_aaev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_aaev_rec.last_updated_by := NULL;
    END IF;
    IF (l_aaev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_aaev_rec.last_update_date := NULL;
    END IF;
    IF (l_aaev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_aaev_rec.last_update_login := NULL;
    END IF;
    RETURN(l_aaev_rec);
  END null_out_defaults;

  /*** Commeted out nocopy generated code in favor of hand written code ************
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_ACTION_ATTRIBUTES_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_aaev_rec IN  aaev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_aaev_rec.id = OKC_API.G_MISS_NUM OR
       p_aaev_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aaev_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_aaev_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aaev_rec.acn_id = OKC_API.G_MISS_NUM OR
          p_aaev_rec.acn_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'acn_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aaev_rec.element_name = OKC_API.G_MISS_CHAR OR
          p_aaev_rec.element_name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'element_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aaev_rec.name = OKC_API.G_MISS_CHAR OR
          p_aaev_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aaev_rec.data_type = OKC_API.G_MISS_CHAR OR
          p_aaev_rec.data_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'data_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aaev_rec.list_yn = OKC_API.G_MISS_CHAR OR
          p_aaev_rec.list_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'list_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aaev_rec.visible_yn = OKC_API.G_MISS_CHAR OR
          p_aaev_rec.visible_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'visible_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aaev_rec.date_of_interest_yn = OKC_API.G_MISS_CHAR OR
          p_aaev_rec.date_of_interest_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_of_interest_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKC_ACTION_ATTRIBUTES_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_aaev_rec IN aaev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_aaev_rec IN aaev_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_aalv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              OBJECT_NAME,
              NAME_COLUMN,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okc_Action_Att_Lookups_V
       WHERE okc_action_att_lookups_v.id = p_id;
      l_okc_aalv_pk                  okc_aalv_pk_csr%ROWTYPE;
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
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_aaev_rec.AAL_ID IS NOT NULL)
      THEN
        OPEN okc_aalv_pk_csr(p_aaev_rec.AAL_ID);
        FETCH okc_aalv_pk_csr INTO l_okc_aalv_pk;
        l_row_notfound := okc_aalv_pk_csr%NOTFOUND;
        CLOSE okc_aalv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AAL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_aaev_rec.ACN_ID IS NOT NULL)
      THEN
        OPEN okc_acnv_pk_csr(p_aaev_rec.ACN_ID);
        FETCH okc_acnv_pk_csr INTO l_okc_acnv_pk;
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
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_aaev_rec);
    RETURN (l_return_status);
  END Validate_Record;
  */

  /************************** BEGIN HAND-CODED *****************************/

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
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
                                          ,p_aaev_rec      IN   aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aaev_rec.object_version_number IS NULL) OR
       (p_aaev_rec.object_version_Number = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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
  PROCEDURE Validate_Sfwt_Flag(x_return_status OUT NOCOPY  VARCHAR2
                              ,p_aaev_rec      IN   aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aaev_rec.sfwt_flag IS NULL) OR
       (p_aaev_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'sfwt_flag');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

      -- check if sfwt_flag is in uppercase
      IF (p_aaev_rec.sfwt_flag) <> UPPER(p_aaev_rec.sfwt_flag) THEN
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_uppercase_required
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'sfwt_flag');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- check if sfwt_flag is Y or N
      IF UPPER(p_aaev_rec.sfwt_flag) NOT IN ('Y','N') THEN
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_invalid_value
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'sfwt_flag');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
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
    	p_aaev_rec              IN aaev_rec_type) IS
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	-- Check if seeded_flag is Y or N
	IF UPPER(p_aaev_rec.seeded_flag) NOT IN ('Y', 'N') THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	IF p_aaev_rec.seeded_flag <> UPPER(p_aaev_rec.seeded_flag) THEN
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
    	p_aaev_rec          IN aaev_rec_type) IS
	Cursor application_id_cur(p_application_id IN NUMBER) IS
	select '1'
	from fnd_application
	where application_id = p_application_id;
	l_dummy		VARCHAR2(1) := '?';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_aaev_rec.application_id IS NOT NULL THEN
	--Check if application id exists in the fnd_application or not
	OPEN application_id_cur(p_aaev_rec.application_id);
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
  -- PROCEDURE Validate_Acn_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Acn_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Acn_Id(x_return_status OUT NOCOPY     VARCHAR2
                           ,p_aaev_rec      IN      aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aaev_rec.acn_id IS NULL) OR
       (p_aaev_rec.acn_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'acn_id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
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

  END Validate_Acn_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Element_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Element_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Element_Name(x_return_status OUT NOCOPY     VARCHAR2
                                 ,p_aaev_rec      IN      aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_temp                  NUMBER;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aaev_rec.element_name IS NULL) OR
       (p_aaev_rec.element_name = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'element_name');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check that element_name should not contain the special characters
    l_temp := INSTR(p_aaev_rec.element_name,'<');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,'>');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,'?');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,'[');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,']');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,'/');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,'#');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,'.');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,'=');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,'!');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,'(');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,')');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_temp := INSTR(p_aaev_rec.element_name,',');
    IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'element_name');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
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

  END Validate_Element_Name;

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
                         ,p_aaev_rec      IN      aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aaev_rec.name IS NULL) OR
       (p_aaev_rec.name = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'name');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
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
  -- PROCEDURE Validate_Data_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Data_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Data_Type(x_return_status OUT NOCOPY     VARCHAR2
                              ,p_aaev_rec      IN      aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aaev_rec.data_type IS NULL) OR
       (p_aaev_rec.data_type = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'data_type');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

      -- verify that data is uppercase
      IF (p_aaev_rec.data_type) <> UPPER(p_aaev_rec.data_type) THEN
         OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                            ,p_msg_name        => g_uppercase_required
                            ,p_token1          => g_col_name_token
                            ,p_token1_value    => 'data_type');

         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- check for valid data_type
    IF (UPPER(p_aaev_rec.data_type) NOT IN ('CHAR','NUMBER','DATE')) THEN
      --IF (UPPER(p_aaev_rec.data_type) NOT IN ('C','N','D')) THEN
         OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                            ,p_msg_name       => g_invalid_value
                            ,p_token1         => g_col_name_token
                            ,p_token1_value   => 'data_type');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
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

  END Validate_Data_Type;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_List_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_List_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_List_YN(x_return_status OUT NOCOPY     VARCHAR2
                            ,p_aaev_rec      IN      aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aaev_rec.list_yn IS NULL) OR
       (p_aaev_rec.list_yn = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'list_yn');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

      -- check if list_yn is in uppercase
      IF (p_aaev_rec.list_yn) <> UPPER(p_aaev_rec.list_yn) THEN
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_uppercase_required
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'list_yn');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- check if list_yn is Y or N
      IF UPPER(p_aaev_rec.list_yn) NOT IN ('Y','N') THEN
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_invalid_value
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'list_yn');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

	 -- check if list_yn is Y then aal_id should not be null
      /*IF UPPER(p_aaev_rec.list_yn) = 'Y' THEN
	    IF (p_aaev_rec.aal_id IS NULL) OR
		  (p_aaev_rec.aal_id = OKC_API.G_MISS_NUM) THEN
             OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                                ,p_msg_name         => g_invalid_value
                                ,p_token1           => g_col_name_token
                                ,p_token1_value     => 'list_yn');
             x_return_status    := OKC_API.G_RET_STS_ERROR;
             RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;
      END IF;*/
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
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

  END Validate_List_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Visible_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Visible_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Visible_YN(x_return_status OUT NOCOPY     VARCHAR2
                               ,p_aaev_rec      IN      aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aaev_rec.visible_yn IS NULL) OR
       (p_aaev_rec.visible_yn = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'visible_yn');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

      -- check if visible_yn is in uppercase
      IF (p_aaev_rec.visible_yn) <> UPPER(p_aaev_rec.visible_yn) THEN
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_uppercase_required
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'visible_yn');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- check if visible_yn is Y or N
      IF UPPER(p_aaev_rec.visible_yn) NOT IN ('Y','N') THEN
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_invalid_value
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'visible_yn');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
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

  END Validate_Visible_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_of_Interest_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_of_Interest_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_of_Interest_YN(x_return_status OUT NOCOPY     VARCHAR2
                                        ,p_aaev_rec      IN      aaev_rec_type)
  IS

      CURSOR okc_doi_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Action_Attributes_V
       WHERE okc_action_attributes_v.acn_id = p_id
	  AND   okc_action_attributes_v.date_of_interest_yn = 'Y';

      l_dummy_var                    VARCHAR2(1);

      l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_found                 BOOLEAN := FALSE;
    BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check if date_of_interest_yn has been already checked or not

   IF (p_aaev_rec.ACN_ID IS NOT NULL)
      THEN

   IF (p_aaev_rec.DATE_OF_INTEREST_YN = 'Y') THEN
        OPEN okc_doi_csr(p_aaev_rec.ACN_ID);
        FETCH okc_doi_csr INTO l_dummy_var;
        l_row_found := okc_doi_csr%FOUND;
        CLOSE okc_doi_csr;
        IF (l_row_found) THEN
         -- OKC_API.set_message(G_APP_NAME, G_ONE_DOI,G_COL_NAME_TOKEN,'DATE_OF_INTEREST_YN');
          OKC_API.set_message(G_APP_NAME, G_ONE_DOI);
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       END IF;
   END IF;

    -- check for data before processing
    IF (p_aaev_rec.date_of_interest_yn IS NULL) OR
       (p_aaev_rec.date_of_interest_yn = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'date_of_interest_yn');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

      -- check if date_of_interest_yn is in uppercase
      IF (p_aaev_rec.date_of_interest_yn) <> UPPER(p_aaev_rec.date_of_interest_yn) THEN
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_uppercase_required
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'date_of_interest_yn');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- check if date_of_interest_yn is Y or N
      IF UPPER(p_aaev_rec.date_of_interest_yn) NOT IN ('Y','N') THEN
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_invalid_value
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'date_of_interest_yn');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
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

  END Validate_Date_of_Interest_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Format_Mask
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Format_Mask
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Format_Mask(x_return_status OUT NOCOPY     VARCHAR2
                                ,p_aaev_rec      IN      aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_char_check            VARCHAR2(255) ;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aaev_rec.format_mask is not null) AND
       (p_aaev_rec.format_mask <> OKC_API.G_MISS_CHAR) THEN

     --
     -- Check if format_mask is in date format whenever the value in the field
     -- data_type is 'DATE'
     --
      IF UPPER(p_aaev_rec.data_type) = 'DATE' THEN
     -- IF UPPER(p_aaev_rec.data_type) = 'D' THEN
          SELECT to_char(SYSDATE,NVL(p_aaev_rec.format_mask, 'DD-MON-YYYY'))
          INTO l_char_check
          FROM DUAL;
      ELSIF
          UPPER(p_aaev_rec.data_type) = 'NUMBER' AND p_aaev_rec.format_mask IS NOT NULL
          --UPPER(p_aaev_rec.data_type) = 'N' AND p_aaev_rec.format_mask IS NOT NULL
      THEN
            SELECT to_char(1,p_aaev_rec.format_mask)
            INTO l_char_check
            FROM DUAL;
       IF p_aaev_rec.data_type = 'CHAR' AND
       --IF p_aaev_rec.data_type = 'C' AND
          p_aaev_rec.format_mask IS NOT NULL THEN
          OKC_API.SET_MESSAGE(G_APP_NAME
                             ,G_INVALID_VALUE
                             ,G_COL_NAME_TOKEN
                             ,'format_mask');

         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;

         -- halt furhter validation of this column
         RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
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

  END Validate_Format_Mask;


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
    FUNCTION Validate_Foreign_Keys (
      p_aaev_rec IN aaev_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;

      CURSOR okc_acnv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Actions_V
       WHERE okc_actions_v.id = p_id;

      l_dummy_var                    VARCHAR2(1);

      CURSOR okc_aalv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Action_Att_Lookups_V
       WHERE okc_action_att_lookups_v.id = p_id;

      l_dummy                        VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_aaev_rec.ACN_ID IS NOT NULL)
      THEN
        OPEN okc_acnv_pk_csr(p_aaev_rec.ACN_ID);
        FETCH okc_acnv_pk_csr INTO l_dummy_var;
        l_row_notfound := okc_acnv_pk_csr%NOTFOUND;
        CLOSE okc_acnv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ACN_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_aaev_rec.AAL_ID IS NOT NULL)
      THEN
        OPEN okc_aalv_pk_csr(p_aaev_rec.AAL_ID);
        FETCH okc_aalv_pk_csr INTO l_dummy;
        l_row_notfound := okc_aalv_pk_csr%NOTFOUND;
        CLOSE okc_aalv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AAL_ID');
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
    p_aaev_rec IN  aaev_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- Validate_Foreign_Keys;

    l_return_status := Validate_Foreign_Keys(p_aaev_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       -- need to leave
       x_return_status := l_return_status;
       RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
       -- record that there was an error
       x_return_status := l_return_status;
       END IF;
    END IF;

    -- call each column-level validation

    -- Validate_Id
    IF p_aaev_rec.id = OKC_API.G_MISS_NUM OR
       p_aaev_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    -- Validate_Object_Version_Number
    IF (p_aaev_rec.object_version_number IS NOT NULL) AND
       (p_aaev_rec.object_version_number <> OKC_API.G_MISS_NUM) THEN
       Validate_Object_Version_Number(x_return_status,p_aaev_rec);
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
    END IF;

    -- Validate_Sfwt_Flag
    IF (p_aaev_rec.sfwt_flag IS NOT NULL) AND
       (p_aaev_rec.sfwt_flag <> OKC_API.G_MISS_CHAR) THEN
       Validate_Sfwt_Flag(x_return_status,p_aaev_rec);
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
    END IF;

    -- Validate_Seeded_Flag
    IF (p_aaev_rec.seeded_flag IS NOT NULL) AND
       (p_aaev_rec.sfwt_flag <> OKC_API.G_MISS_CHAR) THEN
       Validate_Sfwt_Flag(x_return_status,p_aaev_rec);
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
    END IF;


    -- Validate_Application_id
    IF (p_aaev_rec.application_id IS NOT NULL) AND
       (p_aaev_rec.sfwt_flag <> OKC_API.G_MISS_CHAR) THEN
       Validate_Sfwt_Flag(x_return_status,p_aaev_rec);
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
    END IF;

    -- Validate_Acn_Id
    IF (p_aaev_rec.acn_id IS NOT NULL) AND
       (p_aaev_rec.acn_id <> OKC_API.G_MISS_NUM) THEN
       Validate_Acn_Id(x_return_status,p_aaev_rec);
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
    END IF;

    -- Validate_Element_Name
    IF (p_aaev_rec.element_name IS NOT NULL) AND
       (p_aaev_rec.element_name <> OKC_API.G_MISS_CHAR) THEN
       Validate_Element_Name(x_return_status,p_aaev_rec);
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
    END IF;

    -- Validate_Name
    IF (p_aaev_rec.name IS NOT NULL) AND
       (p_aaev_rec.name <> OKC_API.G_MISS_CHAR) THEN
       Validate_Name(x_return_status,p_aaev_rec);
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
    END IF;

    -- Validate_Data_Type
    IF (p_aaev_rec.data_type IS NOT NULL) AND
       (p_aaev_rec.data_type <> OKC_API.G_MISS_CHAR) THEN
       Validate_Data_Type(x_return_status,p_aaev_rec);
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
    END IF;

    -- Validate_List_YN
    IF (p_aaev_rec.list_yn IS NOT NULL) AND
       (p_aaev_rec.list_yn <> OKC_API.G_MISS_CHAR) THEN
       Validate_List_YN(x_return_status,p_aaev_rec);
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
    END IF;

    -- Validate_Visible_YN
    IF (p_aaev_rec.visible_yn IS NOT NULL) AND
       (p_aaev_rec.visible_yn <> OKC_API.G_MISS_CHAR) THEN
       Validate_Visible_YN(x_return_status,p_aaev_rec);
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
    END IF;

    -- Validate_Date_of_Interest_YN
    IF (p_aaev_rec.date_of_interest_yn IS NOT NULL) AND
       (p_aaev_rec.date_of_interest_yn <> OKC_API.G_MISS_CHAR) THEN
       Validate_Date_of_Interest_YN(x_return_status,p_aaev_rec);
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
    END IF;

    -- Validate_Format_Mask
    IF (p_aaev_rec.format_mask IS NOT NULL) AND
       (p_aaev_rec.format_mask <> OKC_API.G_MISS_CHAR) THEN
       Validate_Format_Mask(x_return_status,p_aaev_rec);
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
  -- PROCEDURE Validate_Unique_Aae_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Aae_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Aae_Record(
                                  x_return_status OUT NOCOPY     VARCHAR2,
                                  p_aaev_rec      IN      aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_dummy                 VARCHAR2(1);
  l_row_found             Boolean := False;
  CURSOR c1(p_acn_id okc_action_attributes_v.acn_id%TYPE,
		  p_element_name okc_Action_attributes_v.element_name%TYPE) is
  SELECT 1
  FROM okc_action_attributes_b
  WHERE  acn_id = p_acn_id
  AND    element_name = p_element_name
  AND    id <> nvl(p_aaev_rec.id,-9999);

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
/*    Bug 1636056:The following code commented out nocopy since it was not using bind
	    variables and parsing was taking place.Replaced with explicit cursor
	    as above

    -- initialize columns of unique concatenated key

    l_unq_tbl(1).p_col_name   := 'acn_id';
    l_unq_tbl(1).p_col_val    := p_aaev_rec.acn_id;
    l_unq_tbl(2).p_col_name   := 'element_name';
    l_unq_tbl(2).p_col_val    := p_aaev_rec.element_name;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- call check_comp_unique utility
    OKC_UTIL.check_comp_unique(p_view_name => 'OKC_ACTION_ATTRIBUTES_V'
                              ,p_col_tbl   => l_unq_tbl
                              ,p_id        => p_aaev_rec.id
                              ,x_return_status => l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    */
    OPEN c1(p_aaev_rec.acn_id,
		  p_aaev_rec.element_name);
    FETCH c1 into l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found then
		--OKC_API.set_message(G_APP_NAME,G_UNQS,G_COL_NAME_TOKEN1,'acn_id',G_COL_NAME_TOKEN2,'element_name');
		OKC_API.set_message(G_APP_NAME,G_UNQS);
		x_return_status := OKC_API.G_RET_STS_ERROR;
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

  END Validate_Unique_Aae_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Dt_Doi_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Dt_Doi_YN
  -- Description     : To Validate that if Date_of_Interest_YN can be 'Y'
  --				 : only for Data_type 'Date'
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Dt_Doi_YN(x_return_status OUT NOCOPY     VARCHAR2,
                               p_aaev_rec      IN      aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    --
    -- Check if Date_of_Interest_YN is 'Y' then Data_Type should be 'Date'
    --

    IF UPPER(p_aaev_rec.data_type) <> 'DATE'
       AND UPPER(p_aaev_rec.date_of_interest_yn) = 'Y' THEN
       OKC_API.SET_MESSAGE(G_APP_NAME
                          ,G_INVALID_VALUE
                          ,G_COL_NAME_TOKEN
                          ,'Dt_Doi_YN');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt furhter validation of this column
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

  END Validate_Dt_Doi_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Minmaxvalue
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Minmaxvalue
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Minmaxvalue(x_return_status OUT NOCOPY     VARCHAR2,
                                 p_aaev_rec      IN      aaev_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_date_check_max        DATE;
  l_date_check_min        DATE;
  -- Bug 4893035 - Changing the declaration to NUMBER
  -- l_number_check_max      NUMBER(38);
  -- l_number_check_min      NUMBER(38);
  l_number_check_max      NUMBER;
  l_number_check_min      NUMBER;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    --
    -- Check if minimum_value and maximum_value are of the correct data type
    --

    --IF UPPER(p_aaev_rec.data_type) = 'VARCHAR2' THEN
    IF UPPER(p_aaev_rec.data_type) = 'CHAR' THEN
	  -- no need to check minimum and maximum value
       x_return_status := OKC_API.G_RET_STS_SUCCESS;
    ELSIF
	  UPPER(p_aaev_rec.data_type) = 'DATE' THEN
	  --UPPER(p_aaev_rec.data_type) = 'D' THEN
       SELECT to_date(p_aaev_rec.minimum_value,NVL(p_aaev_rec.format_mask,'XXXXX')),
              to_date(p_aaev_rec.maximum_value,NVL(p_aaev_rec.format_mask,'XXXXX'))
       INTO l_date_check_min,l_date_check_max
       FROM DUAL;
       x_return_status := OKC_API.G_RET_STS_SUCCESS;
    ELSIF
       UPPER(p_aaev_rec.data_type) = 'NUMBER'
       --UPPER(p_aaev_rec.data_type) = 'N'
       THEN
       SELECT to_number(p_aaev_rec.minimum_value,NVL(p_aaev_rec.format_mask,'XXXXX')),
              to_number(p_aaev_rec.maximum_value,NVL(p_aaev_rec.format_mask,'XXXXX'))
       INTO l_number_check_max,l_number_check_min
       FROM DUAL;
       x_return_status := OKC_API.G_RET_STS_SUCCESS;
    ELSE
       OKC_API.SET_MESSAGE(G_APP_NAME
                          ,G_INVALID_VALUE
                          ,G_COL_NAME_TOKEN
                          ,'MINMAX_VALUE');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt furhter validation of this column
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

  END Validate_Minmaxvalue;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Record (
    p_aaev_rec IN aaev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- Validate_Unique_Aae_Record
      Validate_Unique_Aae_Record(x_return_status,p_aaev_rec);
      -- store the highest degree of error
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            -- need to leave
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
            -- record that there was an error
            l_return_status := x_return_status;
        END IF;
      END IF;

    -- Validate_Dt_Doi_YN
      Validate_Dt_Doi_YN(x_return_status,p_aaev_rec);
      -- store the highest degree of error
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            -- need to leave
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
            -- record that there was an error
            l_return_status := x_return_status;
        END IF;
      END IF;

    -- Validate_Minmaxvalue
      Validate_Minmaxvalue(x_return_status,p_aaev_rec);
      -- store the highest degree of error
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
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
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;
    RETURN (l_return_status);

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

  END Validate_Record;

  /*********************** END HAND-CODED **********************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN aaev_rec_type,
    p_to	OUT NOCOPY aae_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.aal_id := p_from.aal_id;
    p_to.acn_id := p_from.acn_id;
    p_to.element_name := p_from.element_name;
    p_to.data_type := p_from.data_type;
    p_to.list_yn := p_from.list_yn;
    p_to.visible_yn := p_from.visible_yn;
    p_to.date_of_interest_yn := p_from.date_of_interest_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.format_mask := p_from.format_mask;
    p_to.minimum_value := p_from.minimum_value;
    p_to.maximum_value := p_from.maximum_value;
    p_to.JTOT_object_code := p_from.JTOT_object_code;
    p_to.NAME_COLUMN := p_from.NAME_COLUMN;
    p_to.description_column := p_from.description_column;
    p_to.source_doc_number_yn := p_from.source_doc_number_yn;
    p_to.last_update_login := p_from.last_update_login;
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
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
    p_from	IN aae_rec_type,
    p_to	IN OUT NOCOPY aaev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.aal_id := p_from.aal_id;
    p_to.acn_id := p_from.acn_id;
    p_to.element_name := p_from.element_name;
    p_to.data_type := p_from.data_type;
    p_to.list_yn := p_from.list_yn;
    p_to.visible_yn := p_from.visible_yn;
    p_to.date_of_interest_yn := p_from.date_of_interest_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.format_mask := p_from.format_mask;
    p_to.minimum_value := p_from.minimum_value;
    p_to.maximum_value := p_from.maximum_value;
    p_to.JTOT_object_code := p_from.JTOT_object_code;
    p_to.NAME_COLUMN := p_from.NAME_COLUMN;
    p_to.description_column := p_from.description_column;
    p_to.source_doc_number_yn := p_from.source_doc_number_yn;
    p_to.last_update_login := p_from.last_update_login;
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
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
    p_from	IN aaev_rec_type,
    p_to	OUT NOCOPY OkcActionAttributesTlRecType
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
    p_from	IN OkcActionAttributesTlRecType,
    p_to	IN OUT NOCOPY aaev_rec_type
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
  ----------------------------------------------
  -- validate_row for:OKC_ACTION_ATTRIBUTES_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aaev_rec                     aaev_rec_type := p_aaev_rec;
    l_aae_rec                      aae_rec_type;
    l_okc_action_attributes_tl_rec OkcActionAttributesTlRecType;
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
    l_return_status := Validate_Attributes(l_aaev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_aaev_rec);
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
  -- PL/SQL TBL validate_row for:AAEV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aaev_tbl.COUNT > 0) THEN
      i := p_aaev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aaev_rec                     => p_aaev_tbl(i));
        EXIT WHEN (i = p_aaev_tbl.LAST);
        i := p_aaev_tbl.NEXT(i);
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
  -- insert_row for:OKC_ACTION_ATTRIBUTES_B --
  --------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aae_rec                      IN aae_rec_type,
    x_aae_rec                      OUT NOCOPY aae_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aae_rec                      aae_rec_type := p_aae_rec;
    l_def_aae_rec                  aae_rec_type;
    ------------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATTRIBUTES_B --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_aae_rec IN  aae_rec_type,
      x_aae_rec OUT NOCOPY aae_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aae_rec := p_aae_rec;
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
      p_aae_rec,                         -- IN
      l_aae_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_ACTION_ATTRIBUTES_B(
        id,
        aal_id,
        acn_id,
        element_name,
        data_type,
        list_yn,
        visible_yn,
        date_of_interest_yn,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        format_mask,
        minimum_value,
        maximum_value,
        JTOT_object_code,
        NAME_COLUMN,
        description_column,
        source_doc_number_yn,
        last_update_login,
        application_id,
        seeded_flag,
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
        l_aae_rec.id,
        l_aae_rec.aal_id,
        l_aae_rec.acn_id,
        l_aae_rec.element_name,
        l_aae_rec.data_type,
        l_aae_rec.list_yn,
        l_aae_rec.visible_yn,
        l_aae_rec.date_of_interest_yn,
        l_aae_rec.object_version_number,
        l_aae_rec.created_by,
        l_aae_rec.creation_date,
        l_aae_rec.last_updated_by,
        l_aae_rec.last_update_date,
        l_aae_rec.format_mask,
        l_aae_rec.minimum_value,
        l_aae_rec.maximum_value,
        l_aae_rec.JTOT_object_code,
        l_aae_rec.NAME_COLUMN,
        l_aae_rec.description_column,
        l_aae_rec.source_doc_number_yn,
        l_aae_rec.last_update_login,
        l_aae_rec.application_id,
        l_aae_rec.seeded_flag,
        l_aae_rec.attribute_category,
        l_aae_rec.attribute1,
        l_aae_rec.attribute2,
        l_aae_rec.attribute3,
        l_aae_rec.attribute4,
        l_aae_rec.attribute5,
        l_aae_rec.attribute6,
        l_aae_rec.attribute7,
        l_aae_rec.attribute8,
        l_aae_rec.attribute9,
        l_aae_rec.attribute10,
        l_aae_rec.attribute11,
        l_aae_rec.attribute12,
        l_aae_rec.attribute13,
        l_aae_rec.attribute14,
        l_aae_rec.attribute15);
    -- Set OUT values
    x_aae_rec := l_aae_rec;
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
  -- insert_row for:OKC_ACTION_ATTRIBUTES_TL --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_action_attributes_tl_rec  IN OkcActionAttributesTlRecType,
    x_okc_action_attributes_tl_rec  OUT NOCOPY OkcActionAttributesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_action_attributes_tl_rec OkcActionAttributesTlRecType := p_okc_action_attributes_tl_rec;
    ldefokcactionattributestlrec   OkcActionAttributesTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -------------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATTRIBUTES_TL --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_action_attributes_tl_rec IN  OkcActionAttributesTlRecType,
      x_okc_action_attributes_tl_rec OUT NOCOPY OkcActionAttributesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_action_attributes_tl_rec := p_okc_action_attributes_tl_rec;
      x_okc_action_attributes_tl_rec.LANGUAGE := l_lang;
      x_okc_action_attributes_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_action_attributes_tl_rec,    -- IN
      l_okc_action_attributes_tl_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_action_attributes_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_ACTION_ATTRIBUTES_TL(
          id,
          language,
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
          l_okc_action_attributes_tl_rec.id,
          l_okc_action_attributes_tl_rec.language,
          l_okc_action_attributes_tl_rec.source_lang,
          l_okc_action_attributes_tl_rec.sfwt_flag,
          l_okc_action_attributes_tl_rec.name,
          l_okc_action_attributes_tl_rec.description,
          l_okc_action_attributes_tl_rec.created_by,
          l_okc_action_attributes_tl_rec.creation_date,
          l_okc_action_attributes_tl_rec.last_updated_by,
          l_okc_action_attributes_tl_rec.last_update_date,
          l_okc_action_attributes_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_action_attributes_tl_rec := l_okc_action_attributes_tl_rec;
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
  -- insert_row for:OKC_ACTION_ATTRIBUTES_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type,
    x_aaev_rec                     OUT NOCOPY aaev_rec_type) IS

    l_id                           NUMBER ;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aaev_rec                     aaev_rec_type;
    l_def_aaev_rec                 aaev_rec_type;
    l_aae_rec                      aae_rec_type;
    lx_aae_rec                     aae_rec_type;
    l_okc_action_attributes_tl_rec OkcActionAttributesTlRecType;
    LxOkcActionAttributesTlRec     OkcActionAttributesTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aaev_rec	IN aaev_rec_type
    ) RETURN aaev_rec_type IS
      l_aaev_rec	aaev_rec_type := p_aaev_rec;
    BEGIN
      l_aaev_rec.CREATION_DATE := SYSDATE;
      l_aaev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_aaev_rec.LAST_UPDATE_DATE := l_aaev_rec.CREATION_DATE;
      l_aaev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_aaev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_aaev_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATTRIBUTES_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_aaev_rec IN  aaev_rec_type,
      x_aaev_rec OUT NOCOPY aaev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aaev_rec := p_aaev_rec;
      x_aaev_rec.OBJECT_VERSION_NUMBER := 1;
      x_aaev_rec.SFWT_FLAG := 'N';
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
    l_aaev_rec := null_out_defaults(p_aaev_rec);
    -- Set primary key value
    -- If action attribute is created by seed then use sequence generated id
    IF l_aaev_rec.CREATED_BY = 1 THEN
	  SELECT OKC_ACTION_ATTRIBUTES_S1.nextval INTO l_id FROM dual;
	  l_aaev_rec.ID := l_id;
	  l_aaev_rec.seeded_flag := 'Y';
    ELSE
       l_aaev_rec.ID := get_seq_id;
	  l_aaev_rec.seeded_flag := 'N';
    END IF;
    --l_aaev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_aaev_rec,                        -- IN
      l_def_aaev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_aaev_rec := fill_who_columns(l_def_aaev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aaev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aaev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aaev_rec, l_aae_rec);
    migrate(l_def_aaev_rec, l_okc_action_attributes_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aae_rec,
      lx_aae_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aae_rec, l_def_aaev_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_action_attributes_tl_rec,
      LxOkcActionAttributesTlRec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxOkcActionAttributesTlRec, l_def_aaev_rec);
    -- Set OUT values
    x_aaev_rec := l_def_aaev_rec;
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
  -- PL/SQL TBL insert_row for:AAEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aaev_tbl.COUNT > 0) THEN
      i := p_aaev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aaev_rec                     => p_aaev_tbl(i),
          x_aaev_rec                     => x_aaev_tbl(i));
        EXIT WHEN (i = p_aaev_tbl.LAST);
        i := p_aaev_tbl.NEXT(i);
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
  -- lock_row for:OKC_ACTION_ATTRIBUTES_B --
  ------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aae_rec                      IN aae_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_aae_rec IN aae_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ACTION_ATTRIBUTES_B
     WHERE ID = p_aae_rec.id
       AND OBJECT_VERSION_NUMBER = p_aae_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_aae_rec IN aae_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ACTION_ATTRIBUTES_B
    WHERE ID = p_aae_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_ACTION_ATTRIBUTES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_ACTION_ATTRIBUTES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_aae_rec);
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
      OPEN lchk_csr(p_aae_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_aae_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_aae_rec.object_version_number THEN
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
  -- lock_row for:OKC_ACTION_ATTRIBUTES_TL --
  -------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_action_attributes_tl_rec  IN OkcActionAttributesTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_action_attributes_tl_rec IN OkcActionAttributesTlRecType) IS
    SELECT *
      FROM OKC_ACTION_ATTRIBUTES_TL
     WHERE ID = p_okc_action_attributes_tl_rec.id
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
      OPEN lock_csr(p_okc_action_attributes_tl_rec);
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
  -- lock_row for:OKC_ACTION_ATTRIBUTES_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aae_rec                      aae_rec_type;
    l_okc_action_attributes_tl_rec OkcActionAttributesTlRecType;
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
    migrate(p_aaev_rec, l_aae_rec);
    migrate(p_aaev_rec, l_okc_action_attributes_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aae_rec
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
      l_okc_action_attributes_tl_rec
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
  -- PL/SQL TBL lock_row for:AAEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aaev_tbl.COUNT > 0) THEN
      i := p_aaev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aaev_rec                     => p_aaev_tbl(i));
        EXIT WHEN (i = p_aaev_tbl.LAST);
        i := p_aaev_tbl.NEXT(i);
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
  -- update_row for:OKC_ACTION_ATTRIBUTES_B --
  --------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aae_rec                      IN aae_rec_type,
    x_aae_rec                      OUT NOCOPY aae_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aae_rec                      aae_rec_type := p_aae_rec;
    l_def_aae_rec                  aae_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aae_rec	IN aae_rec_type,
      x_aae_rec	OUT NOCOPY aae_rec_type
    ) RETURN VARCHAR2 IS
      l_aae_rec                      aae_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aae_rec := p_aae_rec;
      -- Get current database values
      l_aae_rec := get_rec(p_aae_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aae_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_aae_rec.id := l_aae_rec.id;
      END IF;
      IF (x_aae_rec.aal_id = OKC_API.G_MISS_NUM)
      THEN
        x_aae_rec.aal_id := l_aae_rec.aal_id;
      END IF;
      IF (x_aae_rec.acn_id = OKC_API.G_MISS_NUM)
      THEN
        x_aae_rec.acn_id := l_aae_rec.acn_id;
      END IF;
      IF (x_aae_rec.element_name = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.element_name := l_aae_rec.element_name;
      END IF;
      IF (x_aae_rec.data_type = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.data_type := l_aae_rec.data_type;
      END IF;
      IF (x_aae_rec.list_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.list_yn := l_aae_rec.list_yn;
      END IF;
      IF (x_aae_rec.visible_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.visible_yn := l_aae_rec.visible_yn;
      END IF;
      IF (x_aae_rec.date_of_interest_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.date_of_interest_yn := l_aae_rec.date_of_interest_yn;
      END IF;
      IF (x_aae_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_aae_rec.object_version_number := l_aae_rec.object_version_number;
      END IF;
      IF (x_aae_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_aae_rec.created_by := l_aae_rec.created_by;
      END IF;
      IF (x_aae_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_aae_rec.creation_date := l_aae_rec.creation_date;
      END IF;
      IF (x_aae_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_aae_rec.last_updated_by := l_aae_rec.last_updated_by;
      END IF;
      IF (x_aae_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_aae_rec.last_update_date := l_aae_rec.last_update_date;
      END IF;
      IF (x_aae_rec.format_mask = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.format_mask := l_aae_rec.format_mask;
      END IF;
      IF (x_aae_rec.minimum_value = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.minimum_value := l_aae_rec.minimum_value;
      END IF;
      IF (x_aae_rec.maximum_value = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.maximum_value := l_aae_rec.maximum_value;
      END IF;
      IF (x_aae_rec.JTOT_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.JTOT_object_code := l_aae_rec.JTOT_object_code;
      END IF;
      IF (x_aae_rec.NAME_COLUMN = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.NAME_COLUMN := l_aae_rec.NAME_COLUMN;
      END IF;
      IF (x_aae_rec.description_column = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.description_column := l_aae_rec.description_column;
      END IF;
      IF (x_aae_rec.source_doc_number_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.source_doc_number_yn := l_aae_rec.source_doc_number_yn;
      END IF;
      IF (x_aae_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_aae_rec.last_update_login := l_aae_rec.last_update_login;
      END IF;
      IF (x_aae_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_aae_rec.application_id := l_aae_rec.application_id;
      END IF;
      IF (x_aae_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.seeded_flag := l_aae_rec.seeded_flag;
      END IF;
      IF (x_aae_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute_category := l_aae_rec.attribute_category;
      END IF;
      IF (x_aae_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute1 := l_aae_rec.attribute1;
      END IF;
      IF (x_aae_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute2 := l_aae_rec.attribute2;
      END IF;
      IF (x_aae_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute3 := l_aae_rec.attribute3;
      END IF;
      IF (x_aae_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute4 := l_aae_rec.attribute4;
      END IF;
      IF (x_aae_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute5 := l_aae_rec.attribute5;
      END IF;
      IF (x_aae_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute6 := l_aae_rec.attribute6;
      END IF;
      IF (x_aae_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute7 := l_aae_rec.attribute7;
      END IF;
      IF (x_aae_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute8 := l_aae_rec.attribute8;
      END IF;
      IF (x_aae_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute9 := l_aae_rec.attribute9;
      END IF;
      IF (x_aae_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute10 := l_aae_rec.attribute10;
      END IF;
      IF (x_aae_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute11 := l_aae_rec.attribute11;
      END IF;
      IF (x_aae_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute12 := l_aae_rec.attribute12;
      END IF;
      IF (x_aae_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute13 := l_aae_rec.attribute13;
      END IF;
      IF (x_aae_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute14 := l_aae_rec.attribute14;
      END IF;
      IF (x_aae_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_aae_rec.attribute15 := l_aae_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATTRIBUTES_B --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_aae_rec IN  aae_rec_type,
      x_aae_rec OUT NOCOPY aae_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aae_rec := p_aae_rec;
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
      p_aae_rec,                         -- IN
      l_aae_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aae_rec, l_def_aae_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_ACTION_ATTRIBUTES_B
    SET AAL_ID = l_def_aae_rec.aal_id,
        ACN_ID = l_def_aae_rec.acn_id,
        ELEMENT_NAME = l_def_aae_rec.element_name,
        DATA_TYPE = l_def_aae_rec.data_type,
        LIST_YN = l_def_aae_rec.list_yn,
        VISIBLE_YN = l_def_aae_rec.visible_yn,
        DATE_OF_INTEREST_YN = l_def_aae_rec.date_of_interest_yn,
        OBJECT_VERSION_NUMBER = l_def_aae_rec.object_version_number,
        CREATED_BY = l_def_aae_rec.created_by,
        CREATION_DATE = l_def_aae_rec.creation_date,
        LAST_UPDATED_BY = l_def_aae_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_aae_rec.last_update_date,
        FORMAT_MASK = l_def_aae_rec.format_mask,
        MINIMUM_VALUE = l_def_aae_rec.minimum_value,
        MAXIMUM_VALUE = l_def_aae_rec.maximum_value,
        JTOT_OBJECT_CODE = l_def_aae_rec.JTOT_object_code,
        NAME_COLUMN= l_def_aae_rec.NAME_COLUMN,
        DESCRIPTION_COLUMN = l_def_aae_rec.description_column,
        source_doc_number_yn = l_def_aae_rec.source_doc_number_yn,
        LAST_UPDATE_LOGIN = l_def_aae_rec.last_update_login,
        APPLICATION_ID = l_def_aae_rec.application_id,
        SEEDED_FLAG = l_def_aae_rec.seeded_flag,
        ATTRIBUTE_CATEGORY = l_def_aae_rec.attribute_category,
        ATTRIBUTE1 = l_def_aae_rec.attribute1,
        ATTRIBUTE2 = l_def_aae_rec.attribute2,
        ATTRIBUTE3 = l_def_aae_rec.attribute3,
        ATTRIBUTE4 = l_def_aae_rec.attribute4,
        ATTRIBUTE5 = l_def_aae_rec.attribute5,
        ATTRIBUTE6 = l_def_aae_rec.attribute6,
        ATTRIBUTE7 = l_def_aae_rec.attribute7,
        ATTRIBUTE8 = l_def_aae_rec.attribute8,
        ATTRIBUTE9 = l_def_aae_rec.attribute9,
        ATTRIBUTE10 = l_def_aae_rec.attribute10,
        ATTRIBUTE11 = l_def_aae_rec.attribute11,
        ATTRIBUTE12 = l_def_aae_rec.attribute12,
        ATTRIBUTE13 = l_def_aae_rec.attribute13,
        ATTRIBUTE14 = l_def_aae_rec.attribute14,
        ATTRIBUTE15 = l_def_aae_rec.attribute15
    WHERE ID = l_def_aae_rec.id;

    x_aae_rec := l_def_aae_rec;
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
  -- update_row for:OKC_ACTION_ATTRIBUTES_TL --
  ---------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_action_attributes_tl_rec  IN OkcActionAttributesTlRecType,
    x_okc_action_attributes_tl_rec  OUT NOCOPY OkcActionAttributesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_action_attributes_tl_rec OkcActionAttributesTlRecType := p_okc_action_attributes_tl_rec;
    ldefokcactionattributestlrec   OkcActionAttributesTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_action_attributes_tl_rec	IN OkcActionAttributesTlRecType,
      x_okc_action_attributes_tl_rec	OUT NOCOPY OkcActionAttributesTlRecType
    ) RETURN VARCHAR2 IS
      l_okc_action_attributes_tl_rec OkcActionAttributesTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_action_attributes_tl_rec := p_okc_action_attributes_tl_rec;
      -- Get current database values
      l_okc_action_attributes_tl_rec := get_rec(p_okc_action_attributes_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_action_attributes_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_action_attributes_tl_rec.id := l_okc_action_attributes_tl_rec.id;
      END IF;
      IF (x_okc_action_attributes_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_action_attributes_tl_rec.language := l_okc_action_attributes_tl_rec.language;
      END IF;
      IF (x_okc_action_attributes_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_action_attributes_tl_rec.source_lang := l_okc_action_attributes_tl_rec.source_lang;
      END IF;
      IF (x_okc_action_attributes_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_action_attributes_tl_rec.sfwt_flag := l_okc_action_attributes_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_action_attributes_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_action_attributes_tl_rec.name := l_okc_action_attributes_tl_rec.name;
      END IF;
      IF (x_okc_action_attributes_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_action_attributes_tl_rec.description := l_okc_action_attributes_tl_rec.description;
      END IF;
      IF (x_okc_action_attributes_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_action_attributes_tl_rec.created_by := l_okc_action_attributes_tl_rec.created_by;
      END IF;
      IF (x_okc_action_attributes_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_action_attributes_tl_rec.creation_date := l_okc_action_attributes_tl_rec.creation_date;
      END IF;
      IF (x_okc_action_attributes_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_action_attributes_tl_rec.last_updated_by := l_okc_action_attributes_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_action_attributes_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_action_attributes_tl_rec.last_update_date := l_okc_action_attributes_tl_rec.last_update_date;
      END IF;
      IF (x_okc_action_attributes_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_action_attributes_tl_rec.last_update_login := l_okc_action_attributes_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATTRIBUTES_TL --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_action_attributes_tl_rec IN  OkcActionAttributesTlRecType,
      x_okc_action_attributes_tl_rec OUT NOCOPY OkcActionAttributesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_action_attributes_tl_rec := p_okc_action_attributes_tl_rec;
      x_okc_action_attributes_tl_rec.LANGUAGE := l_lang;
      x_okc_action_attributes_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_action_attributes_tl_rec,    -- IN
      l_okc_action_attributes_tl_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_action_attributes_tl_rec, ldefokcactionattributestlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_ACTION_ATTRIBUTES_TL
    SET NAME = ldefokcactionattributestlrec.name,
        DESCRIPTION = ldefokcactionattributestlrec.description,
        SOURCE_LANG = ldefokcactionattributestlrec.source_lang,
        CREATED_BY = ldefokcactionattributestlrec.created_by,
        CREATION_DATE = ldefokcactionattributestlrec.creation_date,
        LAST_UPDATED_BY = ldefokcactionattributestlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokcactionattributestlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokcactionattributestlrec.last_update_login
    WHERE ID = ldefokcactionattributestlrec.id
      AND USERENV('LANG') IN (SOURCE_LANG,LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_ACTION_ATTRIBUTES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokcactionattributestlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_action_attributes_tl_rec := ldefokcactionattributestlrec;
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
  -- update_row for:OKC_ACTION_ATTRIBUTES_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type,
    x_aaev_rec                     OUT NOCOPY aaev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aaev_rec                     aaev_rec_type := p_aaev_rec;
    l_def_aaev_rec                 aaev_rec_type;
    l_okc_action_attributes_tl_rec OkcActionAttributesTlRecType;
    LxOkcActionAttributesTlRec     OkcActionAttributesTlRecType;
    l_aae_rec                      aae_rec_type;
    lx_aae_rec                     aae_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aaev_rec	IN aaev_rec_type
    ) RETURN aaev_rec_type IS
      l_aaev_rec	aaev_rec_type := p_aaev_rec;
    BEGIN
      l_aaev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aaev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_aaev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_aaev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aaev_rec	IN aaev_rec_type,
      x_aaev_rec	OUT NOCOPY aaev_rec_type
    ) RETURN VARCHAR2 IS
      l_aaev_rec                     aaev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aaev_rec := p_aaev_rec;
      -- Get current database values
      l_aaev_rec := get_rec(p_aaev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aaev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_aaev_rec.id := l_aaev_rec.id;
      END IF;
      IF (x_aaev_rec.aal_id = OKC_API.G_MISS_NUM)
      THEN
        x_aaev_rec.aal_id := l_aaev_rec.aal_id;
      END IF;
      IF (x_aaev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_aaev_rec.object_version_number := l_aaev_rec.object_version_number;
      END IF;
      IF (x_aaev_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.sfwt_flag := l_aaev_rec.sfwt_flag;
      END IF;
      IF (x_aaev_rec.acn_id = OKC_API.G_MISS_NUM)
      THEN
        x_aaev_rec.acn_id := l_aaev_rec.acn_id;
      END IF;
      IF (x_aaev_rec.element_name = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.element_name := l_aaev_rec.element_name;
      END IF;
      IF (x_aaev_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.name := l_aaev_rec.name;
      END IF;
      IF (x_aaev_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.description := l_aaev_rec.description;
      END IF;
      IF (x_aaev_rec.data_type = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.data_type := l_aaev_rec.data_type;
      END IF;
      IF (x_aaev_rec.list_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.list_yn := l_aaev_rec.list_yn;
      END IF;
      IF (x_aaev_rec.visible_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.visible_yn := l_aaev_rec.visible_yn;
      END IF;
      IF (x_aaev_rec.date_of_interest_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.date_of_interest_yn := l_aaev_rec.date_of_interest_yn;
      END IF;
      IF (x_aaev_rec.format_mask = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.format_mask := l_aaev_rec.format_mask;
      END IF;
      IF (x_aaev_rec.minimum_value = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.minimum_value := l_aaev_rec.minimum_value;
      END IF;
      IF (x_aaev_rec.maximum_value = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.maximum_value := l_aaev_rec.maximum_value;
      END IF;
      IF (x_aaev_rec.JTOT_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.JTOT_object_code := l_aaev_rec.JTOT_object_code;
      END IF;
      IF (x_aaev_rec.NAME_COLUMN = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.NAME_COLUMN := l_aaev_rec.NAME_COLUMN;
      END IF;
      IF (x_aaev_rec.description_column = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.description_column := l_aaev_rec.description_column;
      END IF;
      IF (x_aaev_rec.source_doc_number_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.source_doc_number_yn := l_aaev_rec.source_doc_number_yn;
      END IF;
      IF (x_aaev_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_aaev_rec.application_id := l_aaev_rec.application_id;
      END IF;
      IF (x_aaev_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.seeded_flag := l_aaev_rec.seeded_flag;
      END IF;
      IF (x_aaev_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute_category := l_aaev_rec.attribute_category;
      END IF;
      IF (x_aaev_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute1 := l_aaev_rec.attribute1;
      END IF;
      IF (x_aaev_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute2 := l_aaev_rec.attribute2;
      END IF;
      IF (x_aaev_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute3 := l_aaev_rec.attribute3;
      END IF;
      IF (x_aaev_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute4 := l_aaev_rec.attribute4;
      END IF;
      IF (x_aaev_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute5 := l_aaev_rec.attribute5;
      END IF;
      IF (x_aaev_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute6 := l_aaev_rec.attribute6;
      END IF;
      IF (x_aaev_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute7 := l_aaev_rec.attribute7;
      END IF;
      IF (x_aaev_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute8 := l_aaev_rec.attribute8;
      END IF;
      IF (x_aaev_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute9 := l_aaev_rec.attribute9;
      END IF;
      IF (x_aaev_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute10 := l_aaev_rec.attribute10;
      END IF;
      IF (x_aaev_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute11 := l_aaev_rec.attribute11;
      END IF;
      IF (x_aaev_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute12 := l_aaev_rec.attribute12;
      END IF;
      IF (x_aaev_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute13 := l_aaev_rec.attribute13;
      END IF;
      IF (x_aaev_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute14 := l_aaev_rec.attribute14;
      END IF;
      IF (x_aaev_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_aaev_rec.attribute15 := l_aaev_rec.attribute15;
      END IF;
      IF (x_aaev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_aaev_rec.created_by := l_aaev_rec.created_by;
      END IF;
      IF (x_aaev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_aaev_rec.creation_date := l_aaev_rec.creation_date;
      END IF;
      IF (x_aaev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_aaev_rec.last_updated_by := l_aaev_rec.last_updated_by;
      END IF;
      IF (x_aaev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_aaev_rec.last_update_date := l_aaev_rec.last_update_date;
      END IF;
      IF (x_aaev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_aaev_rec.last_update_login := l_aaev_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATTRIBUTES_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_aaev_rec IN  aaev_rec_type,
      x_aaev_rec OUT NOCOPY aaev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aaev_rec := p_aaev_rec;
      x_aaev_rec.OBJECT_VERSION_NUMBER := NVL(x_aaev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    -- Seeded data should not be updated
    IF l_aaev_rec.last_updated_by <> 1 THEN
    IF l_aaev_rec.seeded_flag = 'Y' THEN
	  OKC_API.set_message (p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    /*IF l_aaev_rec.created_by = 1 THEN
	  OKC_API.set_message (p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;*/
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_aaev_rec,                        -- IN
      l_aaev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aaev_rec, l_def_aaev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_aaev_rec := fill_who_columns(l_def_aaev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aaev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aaev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aaev_rec, l_okc_action_attributes_tl_rec);
    migrate(l_def_aaev_rec, l_aae_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_action_attributes_tl_rec,
      LxOkcActionAttributesTlRec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxOkcActionAttributesTlRec, l_def_aaev_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aae_rec,
      lx_aae_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aae_rec, l_def_aaev_rec);
    x_aaev_rec := l_def_aaev_rec;
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
  -- PL/SQL TBL update_row for:AAEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aaev_tbl.COUNT > 0) THEN
      i := p_aaev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aaev_rec                     => p_aaev_tbl(i),
          x_aaev_rec                     => x_aaev_tbl(i));
        EXIT WHEN (i = p_aaev_tbl.LAST);
        i := p_aaev_tbl.NEXT(i);
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
  -- delete_row for:OKC_ACTION_ATTRIBUTES_B --
  --------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aae_rec                      IN aae_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aae_rec                      aae_rec_type:= p_aae_rec;
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
    DELETE FROM OKC_ACTION_ATTRIBUTES_B
     WHERE ID = l_aae_rec.id;

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
  -- delete_row for:OKC_ACTION_ATTRIBUTES_TL --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_action_attributes_tl_rec  IN OkcActionAttributesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_action_attributes_tl_rec OkcActionAttributesTlRecType:= p_okc_action_attributes_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -------------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATTRIBUTES_TL --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_action_attributes_tl_rec IN  OkcActionAttributesTlRecType,
      x_okc_action_attributes_tl_rec OUT NOCOPY OkcActionAttributesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_action_attributes_tl_rec := p_okc_action_attributes_tl_rec;
      x_okc_action_attributes_tl_rec.LANGUAGE := l_lang;
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
      p_okc_action_attributes_tl_rec,    -- IN
      l_okc_action_attributes_tl_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_ACTION_ATTRIBUTES_TL
     WHERE ID = l_okc_action_attributes_tl_rec.id;

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
  -- delete_row for:OKC_ACTION_ATTRIBUTES_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aaev_rec                     aaev_rec_type := p_aaev_rec;
    l_okc_action_attributes_tl_rec OkcActionAttributesTlRecType;
    l_aae_rec                      aae_rec_type;
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
    -- Seeded data should not be deleted
    IF l_aaev_rec.last_updated_by <> 1 THEN
    IF l_aaev_rec.seeded_flag = 'Y' THEN
	  OKC_API.set_message (p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    /*IF l_aaev_rec.created_by = 1 THEN
	  OKC_API.set_message (p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;*/
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_aaev_rec, l_okc_action_attributes_tl_rec);
    migrate(l_aaev_rec, l_aae_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_action_attributes_tl_rec
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
      l_aae_rec
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
  -- PL/SQL TBL delete_row for:AAEV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aaev_tbl.COUNT > 0) THEN
      i := p_aaev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aaev_rec                     => p_aaev_tbl(i));
        EXIT WHEN (i = p_aaev_tbl.LAST);
        i := p_aaev_tbl.NEXT(i);
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
END OKC_AAE_PVT;

/
