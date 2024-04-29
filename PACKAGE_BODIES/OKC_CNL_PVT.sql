--------------------------------------------------------
--  DDL for Package Body OKC_CNL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CNL_PVT" AS
/* $Header: OKCSCNLB.pls 120.0 2005/05/25 23:14:37 appldev noship $ */

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

    DELETE FROM OKC_CONDITION_LINES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_CONDITION_LINES_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_CONDITION_LINES_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKC_CONDITION_LINES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_CONDITION_LINES_TL SUBB, OKC_CONDITION_LINES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));
*/

    INSERT INTO OKC_CONDITION_LINES_TL (
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
        FROM OKC_CONDITION_LINES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_CONDITION_LINES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
    DELETE FROM OKC_CONDITION_LINES_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_CONDITION_LINES_BH B
         WHERE B.ID = T.ID
         AND B.MAJOR_VERSION = T.MAJOR_VERSION
        );


    UPDATE OKC_CONDITION_LINES_TLH T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKC_CONDITION_LINES_TLH B
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
                FROM OKC_CONDITION_LINES_TLH SUBB, OKC_CONDITION_LINES_TLH SUBT

               WHERE SUBB.ID = SUBT.ID
                  AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION
 IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION
 IS NULL)
              ));
   INSERT INTO OKC_CONDITION_LINES_TLH (
        ID,
        LANGUAGE,
        MAJOR_VERSION,
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
            B.MAJOR_VERSION,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_CONDITION_LINES_TLH B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_CONDITION_LINES_TLH T
                     WHERE T.ID = B.ID
                        AND B.MAJOR_VERSION = T.MAJOR_VERSION
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );


  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CONDITION_LINES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cnl_rec                      IN cnl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cnl_rec_type IS
    CURSOR okc_condition_lines_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CNH_ID,
            PDF_ID,
            AAE_ID,
            LEFT_CTR_MASTER_ID,
            RIGHT_CTR_MASTER_ID,
            LEFT_COUNTER_ID,
            RIGHT_COUNTER_ID,
            DNZ_CHR_ID,
            SORTSEQ,
            LOGICAL_OPERATOR,
            CNL_TYPE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LEFT_PARENTHESIS,
            RELATIONAL_OPERATOR,
            RIGHT_PARENTHESIS,
            TOLERANCE,
            START_AT,
            RIGHT_OPERAND,
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
      FROM Okc_Condition_Lines_B
     WHERE okc_condition_lines_b.id = p_id;
    l_okc_condition_lines_b_pk     okc_condition_lines_b_pk_csr%ROWTYPE;
    l_cnl_rec                      cnl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_condition_lines_b_pk_csr (p_cnl_rec.id);
    FETCH okc_condition_lines_b_pk_csr INTO
              l_cnl_rec.ID,
              l_cnl_rec.CNH_ID,
              l_cnl_rec.PDF_ID,
              l_cnl_rec.AAE_ID,
              l_cnl_rec.LEFT_CTR_MASTER_ID,
              l_cnl_rec.RIGHT_CTR_MASTER_ID,
              l_cnl_rec.LEFT_COUNTER_ID,
              l_cnl_rec.RIGHT_COUNTER_ID,
              l_cnl_rec.DNZ_CHR_ID,
              l_cnl_rec.SORTSEQ,
              l_cnl_rec.LOGICAL_OPERATOR,
              l_cnl_rec.CNL_TYPE,
              l_cnl_rec.OBJECT_VERSION_NUMBER,
              l_cnl_rec.CREATED_BY,
              l_cnl_rec.CREATION_DATE,
              l_cnl_rec.LAST_UPDATED_BY,
              l_cnl_rec.LAST_UPDATE_DATE,
              l_cnl_rec.LEFT_PARENTHESIS,
              l_cnl_rec.RELATIONAL_OPERATOR,
              l_cnl_rec.RIGHT_PARENTHESIS,
              l_cnl_rec.TOLERANCE,
              l_cnl_rec.START_AT,
              l_cnl_rec.RIGHT_OPERAND,
              l_cnl_rec.LAST_UPDATE_LOGIN,
              l_cnl_rec.ATTRIBUTE_CATEGORY,
              l_cnl_rec.ATTRIBUTE1,
              l_cnl_rec.ATTRIBUTE2,
              l_cnl_rec.ATTRIBUTE3,
              l_cnl_rec.ATTRIBUTE4,
              l_cnl_rec.ATTRIBUTE5,
              l_cnl_rec.ATTRIBUTE6,
              l_cnl_rec.ATTRIBUTE7,
              l_cnl_rec.ATTRIBUTE8,
              l_cnl_rec.ATTRIBUTE9,
              l_cnl_rec.ATTRIBUTE10,
              l_cnl_rec.ATTRIBUTE11,
              l_cnl_rec.ATTRIBUTE12,
              l_cnl_rec.ATTRIBUTE13,
              l_cnl_rec.ATTRIBUTE14,
              l_cnl_rec.ATTRIBUTE15,
              l_cnl_rec.APPLICATION_ID,
              l_cnl_rec.SEEDED_FLAG;
    x_no_data_found := okc_condition_lines_b_pk_csr%NOTFOUND;
    CLOSE okc_condition_lines_b_pk_csr;
    RETURN(l_cnl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cnl_rec                      IN cnl_rec_type
  ) RETURN cnl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cnl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CONDITION_LINES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_condition_lines_tl_rec   IN OkcConditionLinesTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OkcConditionLinesTlRecType IS
    CURSOR okc_condition_lines_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okc_Condition_Lines_Tl
     WHERE okc_condition_lines_tl.id = p_id
       AND okc_condition_lines_tl.language = p_language;
    l_okc_condition_lines_tl_pk    okc_condition_lines_tl_pk_csr%ROWTYPE;
    l_okc_condition_lines_tl_rec   OkcConditionLinesTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_condition_lines_tl_pk_csr (p_okc_condition_lines_tl_rec.id,
                                        p_okc_condition_lines_tl_rec.language);
    FETCH okc_condition_lines_tl_pk_csr INTO
              l_okc_condition_lines_tl_rec.ID,
              l_okc_condition_lines_tl_rec.LANGUAGE,
              l_okc_condition_lines_tl_rec.SOURCE_LANG,
              l_okc_condition_lines_tl_rec.SFWT_FLAG,
              l_okc_condition_lines_tl_rec.DESCRIPTION,
              l_okc_condition_lines_tl_rec.CREATED_BY,
              l_okc_condition_lines_tl_rec.CREATION_DATE,
              l_okc_condition_lines_tl_rec.LAST_UPDATED_BY,
              l_okc_condition_lines_tl_rec.LAST_UPDATE_DATE,
              l_okc_condition_lines_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_condition_lines_tl_pk_csr%NOTFOUND;
    CLOSE okc_condition_lines_tl_pk_csr;
    RETURN(l_okc_condition_lines_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_condition_lines_tl_rec   IN OkcConditionLinesTlRecType
  ) RETURN OkcConditionLinesTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_condition_lines_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CONDITION_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cnlv_rec                     IN cnlv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cnlv_rec_type IS
    CURSOR okc_cnlv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CNH_ID,
            PDF_ID,
            AAE_ID,
            LEFT_CTR_MASTER_ID,
            RIGHT_CTR_MASTER_ID,
            LEFT_COUNTER_ID,
            RIGHT_COUNTER_ID,
            DNZ_CHR_ID,
            SORTSEQ,
            CNL_TYPE,
            DESCRIPTION,
            LEFT_PARENTHESIS,
            RELATIONAL_OPERATOR,
            RIGHT_PARENTHESIS,
            LOGICAL_OPERATOR,
            TOLERANCE,
            START_AT,
            RIGHT_OPERAND,
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
      FROM Okc_Condition_Lines_V
     WHERE okc_condition_lines_v.id = p_id;
    l_okc_cnlv_pk                  okc_cnlv_pk_csr%ROWTYPE;
    l_cnlv_rec                     cnlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cnlv_pk_csr (p_cnlv_rec.id);
    FETCH okc_cnlv_pk_csr INTO
              l_cnlv_rec.ID,
              l_cnlv_rec.OBJECT_VERSION_NUMBER,
              l_cnlv_rec.SFWT_FLAG,
              l_cnlv_rec.CNH_ID,
              l_cnlv_rec.PDF_ID,
              l_cnlv_rec.AAE_ID,
              l_cnlv_rec.LEFT_CTR_MASTER_ID,
              l_cnlv_rec.RIGHT_CTR_MASTER_ID,
              l_cnlv_rec.LEFT_COUNTER_ID,
              l_cnlv_rec.RIGHT_COUNTER_ID,
              l_cnlv_rec.DNZ_CHR_ID,
              l_cnlv_rec.SORTSEQ,
              l_cnlv_rec.CNL_TYPE,
              l_cnlv_rec.DESCRIPTION,
              l_cnlv_rec.LEFT_PARENTHESIS,
              l_cnlv_rec.RELATIONAL_OPERATOR,
              l_cnlv_rec.RIGHT_PARENTHESIS,
              l_cnlv_rec.LOGICAL_OPERATOR,
              l_cnlv_rec.TOLERANCE,
              l_cnlv_rec.START_AT,
              l_cnlv_rec.RIGHT_OPERAND,
              l_cnlv_rec.APPLICATION_ID,
              l_cnlv_rec.SEEDED_FLAG,
              l_cnlv_rec.ATTRIBUTE_CATEGORY,
              l_cnlv_rec.ATTRIBUTE1,
              l_cnlv_rec.ATTRIBUTE2,
              l_cnlv_rec.ATTRIBUTE3,
              l_cnlv_rec.ATTRIBUTE4,
              l_cnlv_rec.ATTRIBUTE5,
              l_cnlv_rec.ATTRIBUTE6,
              l_cnlv_rec.ATTRIBUTE7,
              l_cnlv_rec.ATTRIBUTE8,
              l_cnlv_rec.ATTRIBUTE9,
              l_cnlv_rec.ATTRIBUTE10,
              l_cnlv_rec.ATTRIBUTE11,
              l_cnlv_rec.ATTRIBUTE12,
              l_cnlv_rec.ATTRIBUTE13,
              l_cnlv_rec.ATTRIBUTE14,
              l_cnlv_rec.ATTRIBUTE15,
              l_cnlv_rec.CREATED_BY,
              l_cnlv_rec.CREATION_DATE,
              l_cnlv_rec.LAST_UPDATED_BY,
              l_cnlv_rec.LAST_UPDATE_DATE,
              l_cnlv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cnlv_pk_csr%NOTFOUND;
    CLOSE okc_cnlv_pk_csr;
    RETURN(l_cnlv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cnlv_rec                     IN cnlv_rec_type
  ) RETURN cnlv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cnlv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_CONDITION_LINES_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cnlv_rec	IN cnlv_rec_type
  ) RETURN cnlv_rec_type IS
    l_cnlv_rec	cnlv_rec_type := p_cnlv_rec;
  BEGIN
    IF (l_cnlv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.object_version_number := NULL;
    END IF;
    IF (l_cnlv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_cnlv_rec.cnh_id = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.cnh_id := NULL;
    END IF;
    IF (l_cnlv_rec.pdf_id = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.pdf_id := NULL;
    END IF;
    IF (l_cnlv_rec.aae_id = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.aae_id := NULL;
    END IF;
    IF (l_cnlv_rec.left_ctr_master_id = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.left_ctr_master_id := NULL;
    END IF;
    IF (l_cnlv_rec.right_ctr_master_id = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.right_ctr_master_id := NULL;
    END IF;
    IF (l_cnlv_rec.left_counter_id = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.left_counter_id := NULL;
    END IF;
    IF (l_cnlv_rec.right_counter_id = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.right_counter_id := NULL;
    END IF;
    IF (l_cnlv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_cnlv_rec.sortseq = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.sortseq := NULL;
    END IF;
    IF (l_cnlv_rec.cnl_type = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.cnl_type := NULL;
    END IF;
    IF (l_cnlv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.description := NULL;
    END IF;
    IF (l_cnlv_rec.left_parenthesis = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.left_parenthesis := NULL;
    END IF;
    IF (l_cnlv_rec.relational_operator = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.relational_operator := NULL;
    END IF;
    IF (l_cnlv_rec.right_parenthesis = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.right_parenthesis := NULL;
    END IF;
    IF (l_cnlv_rec.logical_operator = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.logical_operator := NULL;
    END IF;
    IF (l_cnlv_rec.tolerance = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.tolerance := NULL;
    END IF;
    IF (l_cnlv_rec.start_at = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.start_at := NULL;
    END IF;
    IF (l_cnlv_rec.right_operand = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.right_operand := NULL;
    END IF;
    IF (l_cnlv_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.application_id := NULL;
    END IF;
    IF (l_cnlv_rec.seeded_flag = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.seeded_flag := NULL;
    END IF;
    IF (l_cnlv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute_category := NULL;
    END IF;
    IF (l_cnlv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute1 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute2 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute3 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute4 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute5 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute6 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute7 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute8 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute9 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute10 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute11 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute12 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute13 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute14 := NULL;
    END IF;
    IF (l_cnlv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_cnlv_rec.attribute15 := NULL;
    END IF;
    IF (l_cnlv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.created_by := NULL;
    END IF;
    IF (l_cnlv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cnlv_rec.creation_date := NULL;
    END IF;
    IF (l_cnlv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cnlv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cnlv_rec.last_update_date := NULL;
    END IF;
    IF (l_cnlv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_cnlv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cnlv_rec);
  END null_out_defaults;

  /**** Commented out nocopy generated code in favor of hand written code **********

  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKC_CONDITION_LINES_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cnlv_rec IN  cnlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_cnlv_rec.id = OKC_API.G_MISS_NUM OR
       p_cnlv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnlv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_cnlv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnlv_rec.cnh_id = OKC_API.G_MISS_NUM OR
          p_cnlv_rec.cnh_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cnh_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cnlv_rec.sortseq = OKC_API.G_MISS_NUM OR
          p_cnlv_rec.sortseq IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sortseq');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKC_CONDITION_LINES_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_cnlv_rec IN cnlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_cnlv_rec IN cnlv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okx_counters_v_pk_csr (p_counter_id         IN NUMBER) IS
      SELECT
              ID1,
              ID2,
              COUNTER_ID,
              COUNTER_GROUP_ID,
              NAME,
              DESCRIPTION,
              TYPE,
              START_DATE_ACTIVE,
              END_DATE_ACTIVE,
              CREATED_FROM_COUNTER_TMPL_ID,
              SOURCE_COUNTER_ID,
              INITIAL_READING,
              UOM_CODE,
              USAGE_ITEM_ID,
              CTR_VAL_MAX_SEQ_NO,
              COUNTER_VALUE_ID,
              VALUE_TIMESTAMP,
              COUNTER_READING,
              NET_READING,
              PREV_NET_READING,
              STATUS,
              PRIMARY_UOM_CODE
        FROM Okx_Counters_V
       WHERE okx_counters_v.counter_id = p_counter_id;
      l_okx_counters_v_pk            okx_counters_v_pk_csr%ROWTYPE;
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
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_cnlv_rec.LEFT_COUNTER_ID IS NOT NULL)
      THEN
        OPEN okx_counters_v_pk_csr(p_cnlv_rec.LEFT_COUNTER_ID);
        FETCH okx_counters_v_pk_csr INTO l_okx_counters_v_pk;
        l_row_notfound := okx_counters_v_pk_csr%NOTFOUND;
        CLOSE okx_counters_v_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEFT_COUNTER_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_cnlv_rec.RIGHT_COUNTER_ID IS NOT NULL)
      THEN
        OPEN okx_counters_v_pk_csr(p_cnlv_rec.RIGHT_COUNTER_ID);
        FETCH okx_counters_v_pk_csr INTO l_okx_counters_v_pk;
        l_row_notfound := okx_counters_v_pk_csr%NOTFOUND;
        CLOSE okx_counters_v_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RIGHT_COUNTER_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_cnlv_rec.CNH_ID IS NOT NULL)
      THEN
        OPEN okc_cnhv_pk_csr(p_cnlv_rec.CNH_ID);
        FETCH okc_cnhv_pk_csr INTO l_okc_cnhv_pk;
        l_row_notfound := okc_cnhv_pk_csr%NOTFOUND;
        CLOSE okc_cnhv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CNH_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_cnlv_rec.AAE_ID IS NOT NULL)
      THEN
        OPEN okc_aaev_pk_csr(p_cnlv_rec.AAE_ID);
        FETCH okc_aaev_pk_csr INTO l_okc_aaev_pk;
        l_row_notfound := okc_aaev_pk_csr%NOTFOUND;
        CLOSE okc_aaev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AAE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_cnlv_rec.PDF_ID IS NOT NULL)
      THEN
        OPEN okc_pdfv_pk_csr(p_cnlv_rec.PDF_ID);
        FETCH okc_pdfv_pk_csr INTO l_okc_pdfv_pk;
        l_row_notfound := okc_pdfv_pk_csr%NOTFOUND;
        CLOSE okc_pdfv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PDF_ID');
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
    l_return_status := validate_foreign_keys (p_cnlv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  ******* End Commented out nocopy generated code *********************************/

  /******** Begin Hand Written Code ****************************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKC_CONDITION_LINES_V --
  ---------------------------------------------------
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_cnh_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_cnh_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_cnh_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnlv_rec      IN     cnlv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_temp                  NUMBER       ;
    CURSOR cnhv_cur IS select 'X' from okc_condition_headers_v cnh
    where cnh.id = p_cnlv_rec.cnh_id;
    v_cnhv_rec     varchar2(1);
    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_cnlv_rec.cnh_id IS NULL) OR
       (p_cnlv_rec.cnh_id = OKC_API.G_MISS_NUM)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'cnh_id');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if the cnh_id exists in header
    OPEN cnhv_cur;
    FETCH cnhv_cur INTO v_cnhv_rec;
      IF cnhv_cur%NOTFOUND  THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'cnh_id');
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    CLOSE cnhv_cur;
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
END Validate_cnh_id;
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_pdf_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_pdf_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_pdf_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnlv_rec      IN     cnlv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_temp                  NUMBER       ;
    v_pdfv_rec     varchar2(1);

    CURSOR pdfv_cur IS
    select 'X' from okc_process_defs_v pdf
    where pdf.id = p_cnlv_rec.pdf_id
    and   pdf.usage = 'FUNCTION';

    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cnlv_rec.pdf_id IS NOT NULL) OR
       (p_cnlv_rec.pdf_id <> OKC_API.G_MISS_NUM)
    THEN
      OPEN pdfv_cur;
      FETCH pdfv_cur INTO v_pdfv_rec;
        IF pdfv_cur%NOTFOUND THEN
          OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name        => g_required_value
                             ,p_token1          => g_col_name_token
                             ,p_token1_value    => 'pdf_id');
           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
           -- halt further validation of this column
             RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      CLOSE pdfv_cur;
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
END Validate_pdf_id;
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_aae_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_aae_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_aae_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnlv_rec      IN     cnlv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_temp                  NUMBER       ;
    l_aaev_rec              VARCHAR2(1);
    l_aae_cnh_rec           VARCHAR2(1);
    CURSOR aaev_cur IS
      select 'X' from okc_action_attributes_v aae
      where aae.id = p_cnlv_rec.aae_id;
    CURSOR aae_cnh_cur IS
      select 'X' from okc_action_attributes_v aae,okc_condition_headers_v cnh
      where aae.id = p_cnlv_rec.aae_id
      and   cnh.id     = p_cnlv_rec.cnh_id
      and   aae.acn_id = cnh.acn_id;
    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_cnlv_rec.aae_id is not null) AND
       (p_cnlv_rec.aae_id <> OKC_API.G_MISS_NUM) THEN
      OPEN aaev_cur;
      FETCH aaev_cur INTO l_aaev_rec;
      IF aaev_cur%NOTFOUND THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'aae_id');
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      CLOSE aaev_cur;
    END IF;

    -- check if the aae_id of lines correspond to acn_id of headers
    IF (p_cnlv_rec.aae_id is not null) AND
       (p_cnlv_rec.aae_id <> OKC_API.G_MISS_NUM) AND
       p_cnlv_rec.cnl_type = 'GEX' THEN
       OPEN aae_cnh_cur;
       FETCH aae_cnh_cur INTO l_aae_cnh_rec;
         IF aae_cnh_cur%NOTFOUND THEN
           OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name        => g_required_value
                              ,p_token1          => g_col_name_token
                              ,p_token1_value    => 'aae_id');
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
          -- halt further validation of this column
          RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
       CLOSE aae_cnh_cur;
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
END Validate_aae_id;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_left_ctr_master_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_left_ctr_master_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_left_ctr_master_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnlv_rec      IN     cnlv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_temp                  NUMBER       ;
    CURSOR ctr_cur IS
    SELECT 'X'
    FROM   okc_condition_headers_b cnh,
	   okc_condition_lines_b cnl,
	   okx_counters_v ctr
    WHERE  cnh.id = cnl.cnh_id
    AND    cnh.counter_group_id = ctr.counter_group_id
    AND    ctr.counter_id = p_cnlv_rec.left_ctr_master_id;
    ctr_rec  ctr_cur%ROWTYPE;

    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cnlv_rec.left_ctr_master_id IS NOT NULL) OR
       (p_cnlv_rec.left_ctr_master_id <> OKC_API.G_MISS_NUM) THEN
      OPEN ctr_cur;
      FETCH ctr_cur INTO ctr_rec;
        IF ctr_cur%NOTFOUND THEN
        OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                           ,p_msg_name        => g_invalid_value
                           ,p_token1          => g_col_name_token
                           ,p_token1_value    => 'left_ctr_master_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      CLOSE ctr_cur;
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
END Validate_left_ctr_master_id;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_right_ctr_master_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_right_ctr_master_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_right_ctr_master_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnlv_rec      IN     cnlv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_temp                  NUMBER       ;
    CURSOR ctr_cur IS
    SELECT 'X'
    FROM   okc_condition_headers_b cnh,
	   okc_condition_lines_b cnl,
	   okx_counters_v ctr
    WHERE  cnh.id = cnl.cnh_id
    AND    cnh.counter_group_id = ctr.counter_group_id
    AND    ctr.counter_id = p_cnlv_rec.right_ctr_master_id;
    ctr_rec  ctr_cur%ROWTYPE;

    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cnlv_rec.right_ctr_master_id IS NOT NULL) OR
       (p_cnlv_rec.right_ctr_master_id <> OKC_API.G_MISS_NUM) THEN
      OPEN ctr_cur;
      FETCH ctr_cur INTO ctr_rec;
        IF ctr_cur%NOTFOUND THEN
        OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                           ,p_msg_name        => g_invalid_value
                           ,p_token1          => g_col_name_token
                           ,p_token1_value    => 'right_ctr_master_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      CLOSE ctr_cur;
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
END Validate_right_ctr_master_id;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_right_counter_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_right_counter_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_right_counter_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnlv_rec      IN     cnlv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_temp                  NUMBER       ;
    CURSOR ctr_cur IS
    SELECT 'X'
    FROM   okc_condition_headers_b cnh,
	   okc_condition_lines_b cnl,
	   okx_counters_v ctr
    WHERE  cnh.id = cnl.cnh_id
    AND    cnh.counter_group_id = ctr.counter_group_id
    AND    ctr.counter_id = p_cnlv_rec.right_counter_id;
    ctr_rec  ctr_cur%ROWTYPE;

    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cnlv_rec.right_counter_id IS NOT NULL) OR
       (p_cnlv_rec.right_counter_id <> OKC_API.G_MISS_NUM) THEN
      OPEN ctr_cur;
      FETCH ctr_cur INTO ctr_rec;
        IF ctr_cur%NOTFOUND THEN
        OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                           ,p_msg_name        => g_invalid_value
                           ,p_token1          => g_col_name_token
                           ,p_token1_value    => 'right_counter_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      CLOSE ctr_cur;
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
END Validate_right_counter_id;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_left_counter_id
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_left_counter_id
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_left_counter_id(  x_return_status OUT NOCOPY     VARCHAR2
                               	,p_cnlv_rec      IN     cnlv_rec_type)
    IS

    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_temp                  NUMBER       ;


    CURSOR ctr_cur IS
    SELECT 'X'
    FROM   okc_condition_headers_b cnh,
	   okc_condition_lines_b cnl,
	   okx_counters_v ctr
    WHERE  cnh.id = cnl.cnh_id
    AND    cnh.counter_group_id = ctr.counter_group_id
    AND    ctr.counter_id = p_cnlv_rec.left_counter_id;
    ctr_rec  ctr_cur%ROWTYPE;

    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cnlv_rec.left_counter_id IS NOT NULL) OR
       (p_cnlv_rec.left_counter_id <> OKC_API.G_MISS_NUM) THEN
      OPEN ctr_cur;
      FETCH ctr_cur INTO ctr_rec;
        IF ctr_cur%NOTFOUND THEN
        OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                           ,p_msg_name        => g_invalid_value
                           ,p_token1          => g_col_name_token
                           ,p_token1_value    => 'left_counter_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      CLOSE ctr_cur;
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
END Validate_left_counter_id;


    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Object_version_number
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_object_version_number
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------


  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY   VARCHAR2
                                          ,p_cnlv_rec      IN    cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnlv_rec.object_version_number is null) AND
       (p_cnlv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
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
    -- PROCEDURE Validate_Sortseq
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : Validate_Sortseq
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------


  PROCEDURE Validate_Sortseq(x_return_status OUT NOCOPY   VARCHAR2
                            ,p_cnlv_rec      IN    cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnlv_rec.sortseq IS NULL) OR
       (p_cnlv_rec.sortseq = OKC_API.G_MISS_NUM)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'sortseq');

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

  END Validate_Sortseq;

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
                              ,p_cnlv_rec      IN      cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnlv_rec.sfwt_flag IS NULL) OR
       (p_cnlv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
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
   IF (p_cnlv_rec.sfwt_flag) <> UPPER(p_cnlv_rec.sfwt_flag) THEN
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                          ,p_msg_name         => g_uppercase_required
                          ,p_token1           => g_col_name_token
                          ,p_token1_value     => 'sfwt_flag');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_cnlv_rec.sfwt_flag) NOT IN ('Y','N')) THEN
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
     p_cnlv_rec              IN cnlv_rec_type) IS
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	-- Check if seeded_flag is Y or N
	IF UPPER(p_cnlv_rec.seeded_flag) NOT IN ('Y', 'N') THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	IF p_cnlv_rec.seeded_flag <> UPPER(p_cnlv_rec.seeded_flag) THEN
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
  -- Description     : Checks if application id exists in fnd_application
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE validate_application_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
    	p_cnlv_rec              IN cnlv_rec_type) IS
	Cursor application_id_cur(p_application_id IN NUMBER) IS
	select '1'
	from fnd_application
	where application_id = p_application_id;
	l_dummy		VARCHAR2(1) := '?';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_cnlv_rec.application_id IS NOT NULL THEN
	--Check if application id exists in the fnd_application or not
	OPEN application_id_cur(p_cnlv_rec.application_id);
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
  -- PROCEDURE Validate_Left_Parenthesis
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Left_Parenthesis
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Left_Parenthesis(x_return_status OUT NOCOPY     VARCHAR2
                               ,p_cnlv_rec      IN      cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_value                 OKC_CONDITION_LINES_V.left_parenthesis%TYPE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- verify that data is within allowable values '(' or ')'
    select replace(p_cnlv_rec.left_parenthesis,'(',null) into l_value
    from dual;

    IF l_value is not null THEN
      select replace(l_value,')',null) into l_value
      from dual;
      IF l_value is null THEN
	raise no_data_found;
      ELSE
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'left_parenthesis');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    ELSE
      raise no_data_found;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      null;
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

  END Validate_Left_parenthesis;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Right_Parenthesis
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Right_Parenthesis
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Right_Parenthesis(x_return_status OUT NOCOPY     VARCHAR2
                               ,p_cnlv_rec      IN      cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_value                 OKC_CONDITION_LINES_V.right_parenthesis%TYPE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- verify that data is within allowable values
    select replace(p_cnlv_rec.right_parenthesis,')',null) into l_value
    from dual;
    IF l_value is not null THEN
      select replace(l_value,')',null) into l_value
      from dual;
      IF l_value is null THEN
	raise no_data_found;
      ELSE
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'right_parenthesis');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    ELSE
      raise no_data_found;
    END IF;

  EXCEPTION
    WHEN no_data_found THEN
    null;
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

  END Validate_Right_parenthesis;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Right_Operand
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Right_Operand
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Right_Operand(x_return_status OUT NOCOPY     VARCHAR2
                               ,p_cnlv_rec      IN      cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_value                 OKC_CONDITION_LINES_V.right_parenthesis%TYPE;
  l_format                OKC_ACTION_ATTRIBUTES_V.format_mask%TYPE;
  l_csm_rec               VARCHAR2(1);
  l_cs_rec                VARCHAR2(1);
/*  CURSOR csm_cur IS
	select 'X' from cs_ctr_master csm
	where csm.ctr_master_id = p_cnlv_rec.right_ctr_master_id;
  CURSOR cs_cur IS
	select 'X' from cs_counters cs
	where cs.right_ctr_master_id = p_cnlv_rec.cs_counter_right_id;*/
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

   /* -- verify that data is within allowable values
    IF UPPER(p_cnlv_rec.cnl_type) = 'CEX' THEN
      IF p_cnlv_rec.right_ctr_master_id IS NULL AND
	 p_cnlv_rec.right_ctr_master_id IS NULL THEN
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSIF p_cnlv_rec.right_ctr_master_id is not null THEN
      OPEN csm_cur;
      FETCH csm_cur INTO csm_rec;
	IF csm_cur%NOTFOUND THEN
              OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                                  p_msg_name          => g_invalid_value,
                                  p_token1            => g_col_name_token,
                                  p_token1_value      => 'right_operand');
               -- notify caller of an error
               x_return_status := OKC_API.G_RET_STS_ERROR;
               -- halt further validation of this column
               RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      CLOSE csm_cur;
      ELSIF p_cnlv_rec.right_ctr_master_id is not null THEN
      OPEN cs_cur;
      FETCH cs_cur INTO cs_rec;
	IF cs_cur%NOTFOUND THEN
              OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                                  p_msg_name          => g_invalid_value,
                                  p_token1            => g_col_name_token,
                                  p_token1_value      => 'right_operand');
               -- notify caller of an error
               x_return_status := OKC_API.G_RET_STS_ERROR;
               -- halt further validation of this column
               RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      CLOSE cs_cur;
      END IF;
    ELSIF UPPER(p_cnlv_rec.cnl_type) = 'FEX' THEN
      IF p_cnlv_rec.right_operand is not null THEN
              OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                                  p_msg_name          => g_invalid_value,
                                  p_token1            => g_col_name_token,
                                  p_token1_value      => 'right_operand');
               -- notify caller of an error
               x_return_status := OKC_API.G_RET_STS_ERROR;
               -- halt further validation of this column
               RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSIF UPPER(p_cnlv_rec.cnl_type) = 'GEX' THEN
      IF p_cnlv_rec.right_operand is not null THEN
	select format_mask into l_format from okc_action_attributes_v aae
	where aae.id = p_cnlv_rec.aae_id;
	IF no_data_found THEN
	  null;
        ELSE
       	  select to_char(p_cnlv_rec.right_operand,l_format) from dual;
            IF inconsistent_datatypes THEN
              OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                                  p_msg_name          => g_invalid_value,
                                  p_token1            => g_col_name_token,
                                  p_token1_value      => 'right_operand');
               -- notify caller of an error
               x_return_status := OKC_API.G_RET_STS_ERROR;
               -- halt further validation of this column
               RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;
        END IF;
      END IF;
    END IF; */

    -- IF relational operator is 'IS NULL','IS NOT NULL' then
    -- make sure that right operand is null
            IF UPPER(p_cnlv_rec.relational_operator) IN ('IS NULL','IS NOT NULL') THEN
	      IF p_cnlv_rec.right_operand IS NOT NULL THEN
		   OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
				       p_msg_name          => g_invalid_value,
				       p_token1            => g_col_name_token,
				       p_token1_value      => 'right_operand');
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

  END Validate_Right_operand;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Cnl_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Cnl_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Cnl_Type(x_return_status OUT NOCOPY     VARCHAR2
                             ,p_cnlv_rec      IN      cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  CURSOR acn_cur
  IS
  SELECT acn.counter_action_yn counter_action_yn
  FROM   okc_actions_b acn,
	 okc_condition_headers_b cnh,
	 OKC_condition_lines_b cnl
  WHERE  acn.id = cnh.acn_id
  AND    cnh.id = cnl.cnh_id
  AND    cnl.cnh_id = p_cnlv_rec.cnh_id;
  acn_rec acn_cur%ROWTYPE;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_cnlv_rec.cnl_type IS NULL) OR
       (p_cnlv_rec.cnl_type = OKC_API.G_MISS_CHAR)
    THEN
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                         ,p_msg_name        => g_required_value
                         ,p_token1          => g_col_name_token
                         ,p_token1_value    => 'cnl_type');

    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if cnl_type is in uppercase
    IF (p_cnlv_rec.cnl_type) <> UPPER(p_cnlv_rec.cnl_type)
    THEN
        OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                           ,p_msg_name         => g_uppercase_required
                           ,p_token1           => g_col_name_token
                           ,p_token1_value     => 'cnl_type');
        x_return_status    := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is within allowable values
    IF (UPPER(p_cnlv_rec.cnl_type) NOT IN ('GEX','CEX','FEX')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'cnl_type');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF UPPER(p_cnlv_rec.cnl_type) = 'GEX' AND
       p_cnlv_rec.aae_id IS NULL THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_required_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'aae_id');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF UPPER(p_cnlv_rec.cnl_type) = 'CEX' THEN
       IF p_cnlv_rec.left_ctr_master_id IS NULL AND
          p_cnlv_rec.left_counter_id    IS NULL THEN
          OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                              p_msg_name          => g_required_value,
                              p_token1            => g_col_name_token,
                              p_token1_value
			      => 'left_ctr_master_id or left_counter_id');
         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
         -- halt further validation of this column
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       OPEN acn_cur;
       FETCH acn_cur INTO acn_rec;
	 IF acn_rec.counter_action_yn = 'N' THEN
           OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                               p_msg_name          => 'OKC_INVALID_RECORD',
                               p_token1            => 'REC',
                               p_token1_value      =>
			       'Counter Expression record for non-counter-action');
           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
           -- halt further validation of this column
           RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

    ELSIF UPPER(p_cnlv_rec.cnl_type) = 'FEX' AND
       p_cnlv_rec.pdf_id IS NULL THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_required_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'pdf_id');
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

  END Validate_Cnl_Type;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Relational_operator
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Relational_Operator
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_relational_operator(x_return_status OUT NOCOPY     VARCHAR2
                             ,p_cnlv_rec      IN      cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- verify that data is within allowable values
    IF (UPPER(p_cnlv_rec.relational_operator) NOT IN
    ('=','<>','<=','>=','>','<','EVERY','IS NULL','IS NOT NULL','LIKE')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'relational_operator');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- For 'EVERY' relational operator the right side of the expression
	-- should always be a value not a counter and cnl_type should be 'CEX'
	    IF UPPER(p_cnlv_rec.relational_operator) = 'EVERY' THEN
	      IF p_cnlv_rec.right_counter_id IS NOT NULL OR
	         p_cnlv_rec.right_ctr_master_id IS NOT NULL OR
		 p_cnlv_rec.right_operand IS NULL OR
		 p_cnlv_rec.start_at IS NULL OR
		 UPPER(p_cnlv_rec.cnl_type) <> 'CEX'  THEN
		   OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
				       p_msg_name          => g_invalid_value,
				       p_token1            => g_col_name_token,
				       p_token1_value      => 'relational_operator');
		   -- notify caller of an error
		   x_return_status := OKC_API.G_RET_STS_ERROR;

		   -- halt further validation of this column
		   RAISE G_EXCEPTION_HALT_VALIDATION;
	      END IF;
	    END IF;
    -- IF relational operator is 'IS NULL' or 'IS NOT NULL' or 'LIKE' then the cnl_type
    -- can only be 'GEX'. These operators can only be used for general expressions.
            IF UPPER(p_cnlv_rec.relational_operator) IN ('IS NULL','IS NOT NULL','LIKE') THEN
              IF UPPER(p_cnlv_rec.cnl_type) <> 'GEX' THEN
		   OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
				       p_msg_name          => g_invalid_value,
				       p_token1            => g_col_name_token,
				       p_token1_value      => 'relational_operator');
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

  END Validate_Relational_Operator;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_logical_operator
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_logical_Operator
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_logical_operator(x_return_status OUT NOCOPY     VARCHAR2
                             ,p_cnlv_rec      IN      cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- verify that length is within allowed limits
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    -- verify that data is within allowable values
    IF (UPPER(p_cnlv_rec.logical_operator) NOT IN
    ('AND','OR')) THEN
       OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                           p_msg_name          => g_invalid_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'logical_operator');
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

  END Validate_Logical_Operator;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tolerance
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Tolerance
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Tolerance(x_return_status OUT NOCOPY     VARCHAR2
                                       ,p_cnlv_rec      IN      cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_cnlv_rec.tolerance is not null) AND
       (p_cnlv_rec.tolerance <> OKC_API.G_MISS_NUM) THEN
       IF p_cnlv_rec.cnl_type IN ('GEX','FEX') THEN
         OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                             p_msg_name          => g_invalid_value,
                             p_token1            => g_col_name_token,
                             p_token1_value      => 'tolerance');
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

  END Validate_Tolerance;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Start_At
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Start_At
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Start_At(x_return_status OUT NOCOPY     VARCHAR2
                                       ,p_cnlv_rec      IN      cnlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_cnlv_rec.start_at is not null) AND
       (p_cnlv_rec.start_at <> OKC_API.G_MISS_NUM) THEN
       IF p_cnlv_rec.cnl_type IN ('GEX','FEX') THEN
         OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                             p_msg_name          => g_invalid_value,
                             p_token1            => g_col_name_token,
                             p_token1_value      => 'start_at');
         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
         -- halt further validation of this column
         RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSIF p_cnlv_rec.relational_operator <> 'EVERY' THEN
         OKC_API.SET_MESSAGE(p_app_name          => g_app_name,
                             p_msg_name          => g_invalid_value,
                             p_token1            => g_col_name_token,
                             p_token1_value      => 'start_at');
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

  END Validate_Start_At;

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
 /********* commented out nocopy FK validation *************************/
/*    FUNCTION Validate_Foreign_Keys (p_cnlv_rec IN cnlv_rec_type)
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
        IF (p_cnlv_rec.ACN_ID IS NOT NULL)
        THEN
          OPEN okc_acnv_pk_csr(p_cnlv_rec.ACN_ID);
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
     END Validate_Foreign_Keys;*/


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_CONDITION_LINES_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cnlv_rec IN  cnlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    -- Validate Object_version_number
    Validate_Object_Version_Number(x_return_status,p_cnlv_rec);
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
    Validate_Sfwt_Flag(x_return_status,p_cnlv_rec);
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
    Validate_Seeded_Flag(x_return_status,p_cnlv_rec);
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
    Validate_Application_Id(x_return_status,p_cnlv_rec);
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


    -- Validate Cnh_Id
    Validate_Cnh_Id(x_return_status,p_cnlv_rec);
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


    -- Validate Pdf_Id
/*    Validate_Pdf_Id(x_return_status,p_cnlv_rec);
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
      END IF;*/

    -- Validate Aae_Id
/*    Validate_Aae_Id(x_return_status,p_cnlv_rec);
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
      END IF;*/

 /*   -- Validate Left_Ctr_Master_Id
    Validate_Left_Ctr_Master_Id(x_return_status,p_cnlv_rec);
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

    -- Validate Right_Ctr_Master_Id
    Validate_Right_Ctr_Master_Id(x_return_status,p_cnlv_rec);
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

    -- Validate Left_Counter_Id
    Validate_Left_Counter_Id(x_return_status,p_cnlv_rec);
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

    -- Validate Right_Counter_Id
    Validate_Right_Counter_Id(x_return_status,p_cnlv_rec);
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
      END IF;*/

    -- Validate Sortseq
    Validate_Sortseq(x_return_status,p_cnlv_rec);
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

    -- Validate Cnl_Type
    Validate_Cnl_Type(x_return_status,p_cnlv_rec);
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

    -- Validate Left_Parenthesis
    Validate_Left_Parenthesis(x_return_status,p_cnlv_rec);
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

    -- Validate Relational_Operator
    Validate_Relational_Operator(x_return_status,p_cnlv_rec);
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

    -- Validate Right_Parenthesis
    Validate_Right_Parenthesis(x_return_status,p_cnlv_rec);
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

    -- Validate Logical_Operator
    Validate_Logical_Operator(x_return_status,p_cnlv_rec);
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

    -- Validate Tolerance
    Validate_Tolerance(x_return_status,p_cnlv_rec);
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

    -- Validate Start_At
    Validate_Start_at(x_return_status,p_cnlv_rec);
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

    -- Validate Right_Operand
  /*  Validate_Right_Operand(x_return_status,p_cnlv_rec);
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
      END IF;*/

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
  -----------------------------------------------
  -- Validate_Record for:OKC_CONDITION_LINES_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
                            p_cnlv_rec IN cnlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnl_rec                      VARCHAR2(1);
  CURSOR cnl_cur IS
      select 'X' from okc_condition_lines_v cnl
      where cnl.sortseq = p_cnlv_rec.sortseq
      and   cnl.cnh_id  = p_cnlv_rec.cnh_id
      and   cnl.id <> p_cnlv_rec.id;
  BEGIN
      -- sortseq should be unique within a condition header
      OPEN cnl_cur;
      FETCH cnl_cur INTO l_cnl_rec;
      IF cnl_cur%FOUND THEN
        OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name        => OKC_UTIL.g_unq
                           ,p_token1          => g_col_name_token
                           ,p_token1_value    => 'sortseq');
        -- notify caller of an error
          l_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
          RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
      CLOSE cnl_cur;
    RETURN (l_return_status);
  END Validate_Record;

  /******** End Hand Written Code ******************************************/
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cnlv_rec_type,
    p_to	OUT NOCOPY cnl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cnh_id := p_from.cnh_id;
    p_to.pdf_id := p_from.pdf_id;
    p_to.aae_id := p_from.aae_id;
    p_to.left_ctr_master_id := p_from.left_ctr_master_id;
    p_to.right_ctr_master_id := p_from.right_ctr_master_id;
    p_to.left_counter_id := p_from.left_counter_id;
    p_to.right_counter_id := p_from.right_counter_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.sortseq := p_from.sortseq;
    p_to.logical_operator := p_from.logical_operator;
    p_to.cnl_type := p_from.cnl_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.left_parenthesis := p_from.left_parenthesis;
    p_to.relational_operator := p_from.relational_operator;
    p_to.right_parenthesis := p_from.right_parenthesis;
    p_to.tolerance := p_from.tolerance;
    p_to.start_at := p_from.start_at;
    p_to.right_operand := p_from.right_operand;
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
    p_from	IN cnl_rec_type,
    p_to	IN OUT NOCOPY cnlv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cnh_id := p_from.cnh_id;
    p_to.pdf_id := p_from.pdf_id;
    p_to.aae_id := p_from.aae_id;
    p_to.left_ctr_master_id := p_from.left_ctr_master_id;
    p_to.right_ctr_master_id := p_from.right_ctr_master_id;
    p_to.left_counter_id := p_from.left_counter_id;
    p_to.right_counter_id := p_from.right_counter_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.sortseq := p_from.sortseq;
    p_to.logical_operator := p_from.logical_operator;
    p_to.cnl_type := p_from.cnl_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.left_parenthesis := p_from.left_parenthesis;
    p_to.relational_operator := p_from.relational_operator;
    p_to.right_parenthesis := p_from.right_parenthesis;
    p_to.tolerance := p_from.tolerance;
    p_to.start_at := p_from.start_at;
    p_to.right_operand := p_from.right_operand;
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
    p_from	IN cnlv_rec_type,
    p_to	OUT NOCOPY OkcConditionLinesTlRecType
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
    p_from	IN OkcConditionLinesTlRecType,
    p_to	IN OUT NOCOPY cnlv_rec_type
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
  -- validate_row for:OKC_CONDITION_LINES_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_rec                     IN cnlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnlv_rec                     cnlv_rec_type := p_cnlv_rec;
    l_cnl_rec                      cnl_rec_type;
    l_okc_condition_lines_tl_rec   OkcConditionLinesTlRecType;
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
    l_return_status := Validate_Attributes(l_cnlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cnlv_rec);
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
  -- PL/SQL TBL validate_row for:CNLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_tbl                     IN cnlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnlv_tbl.COUNT > 0) THEN
      i := p_cnlv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnlv_rec                     => p_cnlv_tbl(i));
        EXIT WHEN (i = p_cnlv_tbl.LAST);
        i := p_cnlv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKC_CONDITION_LINES_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnl_rec                      IN cnl_rec_type,
    x_cnl_rec                      OUT NOCOPY cnl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnl_rec                      cnl_rec_type := p_cnl_rec;
    l_def_cnl_rec                  cnl_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_LINES_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cnl_rec IN  cnl_rec_type,
      x_cnl_rec OUT NOCOPY cnl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnl_rec := p_cnl_rec;
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
      p_cnl_rec,                         -- IN
      l_cnl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_CONDITION_LINES_B(
        id,
        cnh_id,
        pdf_id,
        aae_id,
        left_ctr_master_id,
        right_ctr_master_id,
        left_counter_id,
        right_counter_id,
        dnz_chr_id,
        sortseq,
        logical_operator,
        cnl_type,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        left_parenthesis,
        relational_operator,
        right_parenthesis,
        tolerance,
        start_at,
        right_operand,
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
        l_cnl_rec.id,
        l_cnl_rec.cnh_id,
        l_cnl_rec.pdf_id,
        l_cnl_rec.aae_id,
        l_cnl_rec.left_ctr_master_id,
        l_cnl_rec.right_ctr_master_id,
        l_cnl_rec.left_counter_id,
        l_cnl_rec.right_counter_id,
        l_cnl_rec.dnz_chr_id,
        l_cnl_rec.sortseq,
        l_cnl_rec.logical_operator,
        l_cnl_rec.cnl_type,
        l_cnl_rec.object_version_number,
        l_cnl_rec.created_by,
        l_cnl_rec.creation_date,
        l_cnl_rec.last_updated_by,
        l_cnl_rec.last_update_date,
        l_cnl_rec.left_parenthesis,
        l_cnl_rec.relational_operator,
        l_cnl_rec.right_parenthesis,
        l_cnl_rec.tolerance,
        l_cnl_rec.start_at,
        l_cnl_rec.right_operand,
        l_cnl_rec.last_update_login,
        l_cnl_rec.attribute_category,
        l_cnl_rec.attribute1,
        l_cnl_rec.attribute2,
        l_cnl_rec.attribute3,
        l_cnl_rec.attribute4,
        l_cnl_rec.attribute5,
        l_cnl_rec.attribute6,
        l_cnl_rec.attribute7,
        l_cnl_rec.attribute8,
        l_cnl_rec.attribute9,
        l_cnl_rec.attribute10,
        l_cnl_rec.attribute11,
        l_cnl_rec.attribute12,
        l_cnl_rec.attribute13,
        l_cnl_rec.attribute14,
        l_cnl_rec.attribute15,
        l_cnl_rec.application_id,
        l_cnl_rec.seeded_flag);
    -- Set OUT values
    x_cnl_rec := l_cnl_rec;
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
  -------------------------------------------
  -- insert_row for:OKC_CONDITION_LINES_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_condition_lines_tl_rec   IN OkcConditionLinesTlRecType,
    x_okc_condition_lines_tl_rec   OUT NOCOPY OkcConditionLinesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_condition_lines_tl_rec   OkcConditionLinesTlRecType := p_okc_condition_lines_tl_rec;
    ldefokcconditionlinestlrec     OkcConditionLinesTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_LINES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_condition_lines_tl_rec IN  OkcConditionLinesTlRecType,
      x_okc_condition_lines_tl_rec OUT NOCOPY OkcConditionLinesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_condition_lines_tl_rec := p_okc_condition_lines_tl_rec;
      x_okc_condition_lines_tl_rec.LANGUAGE := l_lang;
      x_okc_condition_lines_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_condition_lines_tl_rec,      -- IN
      l_okc_condition_lines_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_condition_lines_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_CONDITION_LINES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_condition_lines_tl_rec.id,
          l_okc_condition_lines_tl_rec.language,
          l_okc_condition_lines_tl_rec.source_lang,
          l_okc_condition_lines_tl_rec.sfwt_flag,
          l_okc_condition_lines_tl_rec.description,
          l_okc_condition_lines_tl_rec.created_by,
          l_okc_condition_lines_tl_rec.creation_date,
          l_okc_condition_lines_tl_rec.last_updated_by,
          l_okc_condition_lines_tl_rec.last_update_date,
          l_okc_condition_lines_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_condition_lines_tl_rec := l_okc_condition_lines_tl_rec;
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
  ------------------------------------------
  -- insert_row for:OKC_CONDITION_LINES_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_rec                     IN cnlv_rec_type,
    x_cnlv_rec                     OUT NOCOPY cnlv_rec_type) IS

    l_id                           NUMBER ;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnlv_rec                     cnlv_rec_type;
    l_def_cnlv_rec                 cnlv_rec_type;
    l_cnl_rec                      cnl_rec_type;
    lx_cnl_rec                     cnl_rec_type;
    l_okc_condition_lines_tl_rec   OkcConditionLinesTlRecType;
    lx_okc_condition_lines_tl_rec  OkcConditionLinesTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cnlv_rec	IN cnlv_rec_type
    ) RETURN cnlv_rec_type IS
      l_cnlv_rec	cnlv_rec_type := p_cnlv_rec;
    BEGIN
      l_cnlv_rec.CREATION_DATE := SYSDATE;
      l_cnlv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cnlv_rec.LAST_UPDATE_DATE := l_cnlv_rec.CREATION_DATE;
      l_cnlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cnlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cnlv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_LINES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cnlv_rec IN  cnlv_rec_type,
      x_cnlv_rec OUT NOCOPY cnlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnlv_rec := p_cnlv_rec;
      x_cnlv_rec.OBJECT_VERSION_NUMBER := 1;
      x_cnlv_rec.SFWT_FLAG := 'N';
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
    l_cnlv_rec := null_out_defaults(p_cnlv_rec);
    -- Set primary key value
    -- IF condition line is created by seed then use sequence generated id
    IF l_cnlv_rec.CREATED_BY = 1 THEN
	  SELECT OKC_CONDITION_LINES_S1.nextval INTO l_id FROM dual;
	  l_cnlv_rec.ID := l_id;
	  l_cnlv_rec.seeded_flag := 'Y';
    ELSE
	  l_cnlv_rec.ID := get_seq_id;
	  l_cnlv_rec.seeded_flag := 'N';
    END IF;

    --l_cnlv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cnlv_rec,                        -- IN
      l_def_cnlv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cnlv_rec := fill_who_columns(l_def_cnlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cnlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cnlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cnlv_rec, l_cnl_rec);
    migrate(l_def_cnlv_rec, l_okc_condition_lines_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cnl_rec,
      lx_cnl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cnl_rec, l_def_cnlv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_condition_lines_tl_rec,
      lx_okc_condition_lines_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_condition_lines_tl_rec, l_def_cnlv_rec);
    -- Set OUT values
    x_cnlv_rec := l_def_cnlv_rec;
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
  -- PL/SQL TBL insert_row for:CNLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_tbl                     IN cnlv_tbl_type,
    x_cnlv_tbl                     OUT NOCOPY cnlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnlv_tbl.COUNT > 0) THEN
      i := p_cnlv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnlv_rec                     => p_cnlv_tbl(i),
          x_cnlv_rec                     => x_cnlv_tbl(i));
        EXIT WHEN (i = p_cnlv_tbl.LAST);
        i := p_cnlv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKC_CONDITION_LINES_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnl_rec                      IN cnl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cnl_rec IN cnl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CONDITION_LINES_B
     WHERE ID = p_cnl_rec.id
       AND OBJECT_VERSION_NUMBER = p_cnl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cnl_rec IN cnl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CONDITION_LINES_B
    WHERE ID = p_cnl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_CONDITION_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_CONDITION_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cnl_rec);
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
      OPEN lchk_csr(p_cnl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cnl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cnl_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKC_CONDITION_LINES_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_condition_lines_tl_rec   IN OkcConditionLinesTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_condition_lines_tl_rec IN OkcConditionLinesTlRecType) IS
    SELECT *
      FROM OKC_CONDITION_LINES_TL
     WHERE ID = p_okc_condition_lines_tl_rec.id
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
      OPEN lock_csr(p_okc_condition_lines_tl_rec);
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
  ----------------------------------------
  -- lock_row for:OKC_CONDITION_LINES_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_rec                     IN cnlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnl_rec                      cnl_rec_type;
    l_okc_condition_lines_tl_rec   OkcConditionLinesTlRecType;
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
    migrate(p_cnlv_rec, l_cnl_rec);
    migrate(p_cnlv_rec, l_okc_condition_lines_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cnl_rec
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
      l_okc_condition_lines_tl_rec
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
  -- PL/SQL TBL lock_row for:CNLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_tbl                     IN cnlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnlv_tbl.COUNT > 0) THEN
      i := p_cnlv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnlv_rec                     => p_cnlv_tbl(i));
        EXIT WHEN (i = p_cnlv_tbl.LAST);
        i := p_cnlv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKC_CONDITION_LINES_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnl_rec                      IN cnl_rec_type,
    x_cnl_rec                      OUT NOCOPY cnl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnl_rec                      cnl_rec_type := p_cnl_rec;
    l_def_cnl_rec                  cnl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cnl_rec	IN cnl_rec_type,
      x_cnl_rec	OUT NOCOPY cnl_rec_type
    ) RETURN VARCHAR2 IS
      l_cnl_rec                      cnl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnl_rec := p_cnl_rec;
      -- Get current database values
      l_cnl_rec := get_rec(p_cnl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cnl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.id := l_cnl_rec.id;
      END IF;
      IF (x_cnl_rec.cnh_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.cnh_id := l_cnl_rec.cnh_id;
      END IF;
      IF (x_cnl_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.pdf_id := l_cnl_rec.pdf_id;
      END IF;
      IF (x_cnl_rec.aae_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.aae_id := l_cnl_rec.aae_id;
      END IF;
      IF (x_cnl_rec.left_ctr_master_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.left_ctr_master_id := l_cnl_rec.left_ctr_master_id;
      END IF;
      IF (x_cnl_rec.right_ctr_master_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.right_ctr_master_id := l_cnl_rec.right_ctr_master_id;
      END IF;
      IF (x_cnl_rec.left_counter_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.left_counter_id := l_cnl_rec.left_counter_id;
      END IF;
      IF (x_cnl_rec.right_counter_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.right_counter_id := l_cnl_rec.right_counter_id;
      END IF;
      IF (x_cnl_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.dnz_chr_id := l_cnl_rec.dnz_chr_id;
      END IF;
      IF (x_cnl_rec.sortseq = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.sortseq := l_cnl_rec.sortseq;
      END IF;
      IF (x_cnl_rec.logical_operator = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.logical_operator := l_cnl_rec.logical_operator;
      END IF;
      IF (x_cnl_rec.cnl_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.cnl_type := l_cnl_rec.cnl_type;
      END IF;
      IF (x_cnl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.object_version_number := l_cnl_rec.object_version_number;
      END IF;
      IF (x_cnl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.created_by := l_cnl_rec.created_by;
      END IF;
      IF (x_cnl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cnl_rec.creation_date := l_cnl_rec.creation_date;
      END IF;
      IF (x_cnl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.last_updated_by := l_cnl_rec.last_updated_by;
      END IF;
      IF (x_cnl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cnl_rec.last_update_date := l_cnl_rec.last_update_date;
      END IF;
      IF (x_cnl_rec.left_parenthesis = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.left_parenthesis := l_cnl_rec.left_parenthesis;
      END IF;
      IF (x_cnl_rec.relational_operator = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.relational_operator := l_cnl_rec.relational_operator;
      END IF;
      IF (x_cnl_rec.right_parenthesis = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.right_parenthesis := l_cnl_rec.right_parenthesis;
      END IF;
      IF (x_cnl_rec.tolerance = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.tolerance := l_cnl_rec.tolerance;
      END IF;
      IF (x_cnl_rec.start_at = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.start_at := l_cnl_rec.start_at;
      END IF;
      IF (x_cnl_rec.right_operand = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.right_operand := l_cnl_rec.right_operand;
      END IF;
      IF (x_cnl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.last_update_login := l_cnl_rec.last_update_login;
      END IF;
      IF (x_cnl_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute_category := l_cnl_rec.attribute_category;
      END IF;
      IF (x_cnl_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute1 := l_cnl_rec.attribute1;
      END IF;
      IF (x_cnl_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute2 := l_cnl_rec.attribute2;
      END IF;
      IF (x_cnl_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute3 := l_cnl_rec.attribute3;
      END IF;
      IF (x_cnl_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute4 := l_cnl_rec.attribute4;
      END IF;
      IF (x_cnl_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute5 := l_cnl_rec.attribute5;
      END IF;
      IF (x_cnl_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute6 := l_cnl_rec.attribute6;
      END IF;
      IF (x_cnl_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute7 := l_cnl_rec.attribute7;
      END IF;
      IF (x_cnl_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute8 := l_cnl_rec.attribute8;
      END IF;
      IF (x_cnl_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute9 := l_cnl_rec.attribute9;
      END IF;
      IF (x_cnl_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute10 := l_cnl_rec.attribute10;
      END IF;
      IF (x_cnl_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute11 := l_cnl_rec.attribute11;
      END IF;
      IF (x_cnl_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute12 := l_cnl_rec.attribute12;
      END IF;
      IF (x_cnl_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute13 := l_cnl_rec.attribute13;
      END IF;
      IF (x_cnl_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute14 := l_cnl_rec.attribute14;
      END IF;
      IF (x_cnl_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.attribute15 := l_cnl_rec.attribute15;
      END IF;
      IF (x_cnl_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnl_rec.application_id := l_cnl_rec.application_id;
      END IF;
      IF (x_cnl_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cnl_rec.seeded_flag := l_cnl_rec.seeded_flag;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_LINES_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cnl_rec IN  cnl_rec_type,
      x_cnl_rec OUT NOCOPY cnl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnl_rec := p_cnl_rec;
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
      p_cnl_rec,                         -- IN
      l_cnl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cnl_rec, l_def_cnl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CONDITION_LINES_B
    SET CNH_ID = l_def_cnl_rec.cnh_id,
        PDF_ID = l_def_cnl_rec.pdf_id,
        AAE_ID = l_def_cnl_rec.aae_id,
        LEFT_CTR_MASTER_ID = l_def_cnl_rec.left_ctr_master_id,
        RIGHT_CTR_MASTER_ID = l_def_cnl_rec.right_ctr_master_id,
        LEFT_COUNTER_ID = l_def_cnl_rec.left_counter_id,
        RIGHT_COUNTER_ID = l_def_cnl_rec.right_counter_id,
        DNZ_CHR_ID = l_def_cnl_rec.dnz_chr_id,
        SORTSEQ = l_def_cnl_rec.sortseq,
        LOGICAL_OPERATOR = l_def_cnl_rec.logical_operator,
        CNL_TYPE = l_def_cnl_rec.cnl_type,
        OBJECT_VERSION_NUMBER = l_def_cnl_rec.object_version_number,
        CREATED_BY = l_def_cnl_rec.created_by,
        CREATION_DATE = l_def_cnl_rec.creation_date,
        LAST_UPDATED_BY = l_def_cnl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cnl_rec.last_update_date,
        LEFT_PARENTHESIS = l_def_cnl_rec.left_parenthesis,
        RELATIONAL_OPERATOR = l_def_cnl_rec.relational_operator,
        RIGHT_PARENTHESIS = l_def_cnl_rec.right_parenthesis,
        TOLERANCE = l_def_cnl_rec.tolerance,
        START_AT = l_def_cnl_rec.start_at,
        RIGHT_OPERAND = l_def_cnl_rec.right_operand,
        LAST_UPDATE_LOGIN = l_def_cnl_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_cnl_rec.attribute_category,
        ATTRIBUTE1 = l_def_cnl_rec.attribute1,
        ATTRIBUTE2 = l_def_cnl_rec.attribute2,
        ATTRIBUTE3 = l_def_cnl_rec.attribute3,
        ATTRIBUTE4 = l_def_cnl_rec.attribute4,
        ATTRIBUTE5 = l_def_cnl_rec.attribute5,
        ATTRIBUTE6 = l_def_cnl_rec.attribute6,
        ATTRIBUTE7 = l_def_cnl_rec.attribute7,
        ATTRIBUTE8 = l_def_cnl_rec.attribute8,
        ATTRIBUTE9 = l_def_cnl_rec.attribute9,
        ATTRIBUTE10 = l_def_cnl_rec.attribute10,
        ATTRIBUTE11 = l_def_cnl_rec.attribute11,
        ATTRIBUTE12 = l_def_cnl_rec.attribute12,
        ATTRIBUTE13 = l_def_cnl_rec.attribute13,
        ATTRIBUTE14 = l_def_cnl_rec.attribute14,
        ATTRIBUTE15 = l_def_cnl_rec.attribute15,
        APPLICATION_ID = l_def_cnl_rec.application_id,
        SEEDED_FLAG = l_def_cnl_rec.seeded_flag
    WHERE ID = l_def_cnl_rec.id;

    x_cnl_rec := l_def_cnl_rec;
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
  -------------------------------------------
  -- update_row for:OKC_CONDITION_LINES_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_condition_lines_tl_rec   IN OkcConditionLinesTlRecType,
    x_okc_condition_lines_tl_rec   OUT NOCOPY OkcConditionLinesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_condition_lines_tl_rec   OkcConditionLinesTlRecType := p_okc_condition_lines_tl_rec;
    ldefokcconditionlinestlrec     OkcConditionLinesTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_condition_lines_tl_rec	IN OkcConditionLinesTlRecType,
      x_okc_condition_lines_tl_rec	OUT NOCOPY OkcConditionLinesTlRecType
    ) RETURN VARCHAR2 IS
      l_okc_condition_lines_tl_rec   OkcConditionLinesTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_condition_lines_tl_rec := p_okc_condition_lines_tl_rec;
      -- Get current database values
      l_okc_condition_lines_tl_rec := get_rec(p_okc_condition_lines_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_condition_lines_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_condition_lines_tl_rec.id := l_okc_condition_lines_tl_rec.id;
      END IF;
      IF (x_okc_condition_lines_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_lines_tl_rec.language := l_okc_condition_lines_tl_rec.language;
      END IF;
      IF (x_okc_condition_lines_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_lines_tl_rec.source_lang := l_okc_condition_lines_tl_rec.source_lang;
      END IF;
      IF (x_okc_condition_lines_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_lines_tl_rec.sfwt_flag := l_okc_condition_lines_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_condition_lines_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_condition_lines_tl_rec.description := l_okc_condition_lines_tl_rec.description;
      END IF;
      IF (x_okc_condition_lines_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_condition_lines_tl_rec.created_by := l_okc_condition_lines_tl_rec.created_by;
      END IF;
      IF (x_okc_condition_lines_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_condition_lines_tl_rec.creation_date := l_okc_condition_lines_tl_rec.creation_date;
      END IF;
      IF (x_okc_condition_lines_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_condition_lines_tl_rec.last_updated_by := l_okc_condition_lines_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_condition_lines_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_condition_lines_tl_rec.last_update_date := l_okc_condition_lines_tl_rec.last_update_date;
      END IF;
      IF (x_okc_condition_lines_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_condition_lines_tl_rec.last_update_login := l_okc_condition_lines_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_LINES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_condition_lines_tl_rec IN  OkcConditionLinesTlRecType,
      x_okc_condition_lines_tl_rec OUT NOCOPY OkcConditionLinesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_condition_lines_tl_rec := p_okc_condition_lines_tl_rec;
      x_okc_condition_lines_tl_rec.LANGUAGE := l_lang;
      x_okc_condition_lines_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_condition_lines_tl_rec,      -- IN
      l_okc_condition_lines_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_condition_lines_tl_rec, ldefokcconditionlinestlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CONDITION_LINES_TL
    SET DESCRIPTION = ldefokcconditionlinestlrec.description,
        SOURCE_LANG = ldefokcconditionlinestlrec.source_lang,
        CREATED_BY = ldefokcconditionlinestlrec.created_by,
        CREATION_DATE = ldefokcconditionlinestlrec.creation_date,
        LAST_UPDATED_BY = ldefokcconditionlinestlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokcconditionlinestlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokcconditionlinestlrec.last_update_login
    WHERE ID = ldefokcconditionlinestlrec.id
      AND USERENV('LANG') IN (LANGUAGE,SOURCE_LANG);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_CONDITION_LINES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokcconditionlinestlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_condition_lines_tl_rec := ldefokcconditionlinestlrec;
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
  ------------------------------------------
  -- update_row for:OKC_CONDITION_LINES_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_rec                     IN cnlv_rec_type,
    x_cnlv_rec                     OUT NOCOPY cnlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnlv_rec                     cnlv_rec_type := p_cnlv_rec;
    l_def_cnlv_rec                 cnlv_rec_type;
    l_okc_condition_lines_tl_rec   OkcConditionLinesTlRecType;
    lx_okc_condition_lines_tl_rec  OkcConditionLinesTlRecType;
    l_cnl_rec                      cnl_rec_type;
    lx_cnl_rec                     cnl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cnlv_rec	IN cnlv_rec_type
    ) RETURN cnlv_rec_type IS
      l_cnlv_rec	cnlv_rec_type := p_cnlv_rec;
    BEGIN
      l_cnlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cnlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cnlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cnlv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cnlv_rec	IN cnlv_rec_type,
      x_cnlv_rec	OUT NOCOPY cnlv_rec_type
    ) RETURN VARCHAR2 IS
      l_cnlv_rec                     cnlv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnlv_rec := p_cnlv_rec;
      -- Get current database values
      l_cnlv_rec := get_rec(p_cnlv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cnlv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.id := l_cnlv_rec.id;
      END IF;
      IF (x_cnlv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.object_version_number := l_cnlv_rec.object_version_number;
      END IF;
      IF (x_cnlv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.sfwt_flag := l_cnlv_rec.sfwt_flag;
      END IF;
      IF (x_cnlv_rec.cnh_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.cnh_id := l_cnlv_rec.cnh_id;
      END IF;
      IF (x_cnlv_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.pdf_id := l_cnlv_rec.pdf_id;
      END IF;
      IF (x_cnlv_rec.aae_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.aae_id := l_cnlv_rec.aae_id;
      END IF;
      IF (x_cnlv_rec.left_ctr_master_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.left_ctr_master_id := l_cnlv_rec.left_ctr_master_id;
      END IF;
      IF (x_cnlv_rec.right_ctr_master_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.right_ctr_master_id := l_cnlv_rec.right_ctr_master_id;
      END IF;
      IF (x_cnlv_rec.left_counter_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.left_counter_id := l_cnlv_rec.left_counter_id;
      END IF;
      IF (x_cnlv_rec.right_counter_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.right_counter_id := l_cnlv_rec.right_counter_id;
      END IF;
      IF (x_cnlv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.dnz_chr_id := l_cnlv_rec.dnz_chr_id;
      END IF;
      IF (x_cnlv_rec.sortseq = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.sortseq := l_cnlv_rec.sortseq;
      END IF;
      IF (x_cnlv_rec.cnl_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.cnl_type := l_cnlv_rec.cnl_type;
      END IF;
      IF (x_cnlv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.description := l_cnlv_rec.description;
      END IF;
      IF (x_cnlv_rec.left_parenthesis = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.left_parenthesis := l_cnlv_rec.left_parenthesis;
      END IF;
      IF (x_cnlv_rec.relational_operator = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.relational_operator := l_cnlv_rec.relational_operator;
      END IF;
      IF (x_cnlv_rec.right_parenthesis = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.right_parenthesis := l_cnlv_rec.right_parenthesis;
      END IF;
      IF (x_cnlv_rec.logical_operator = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.logical_operator := l_cnlv_rec.logical_operator;
      END IF;
      IF (x_cnlv_rec.tolerance = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.tolerance := l_cnlv_rec.tolerance;
      END IF;
      IF (x_cnlv_rec.start_at = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.start_at := l_cnlv_rec.start_at;
      END IF;
      IF (x_cnlv_rec.right_operand = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.right_operand := l_cnlv_rec.right_operand;
      END IF;
      IF (x_cnlv_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.application_id := l_cnlv_rec.application_id;
      END IF;
      IF (x_cnlv_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.seeded_flag := l_cnlv_rec.seeded_flag;
      END IF;
      IF (x_cnlv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute_category := l_cnlv_rec.attribute_category;
      END IF;
      IF (x_cnlv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute1 := l_cnlv_rec.attribute1;
      END IF;
      IF (x_cnlv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute2 := l_cnlv_rec.attribute2;
      END IF;
      IF (x_cnlv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute3 := l_cnlv_rec.attribute3;
      END IF;
      IF (x_cnlv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute4 := l_cnlv_rec.attribute4;
      END IF;
      IF (x_cnlv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute5 := l_cnlv_rec.attribute5;
      END IF;
      IF (x_cnlv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute6 := l_cnlv_rec.attribute6;
      END IF;
      IF (x_cnlv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute7 := l_cnlv_rec.attribute7;
      END IF;
      IF (x_cnlv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute8 := l_cnlv_rec.attribute8;
      END IF;
      IF (x_cnlv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute9 := l_cnlv_rec.attribute9;
      END IF;
      IF (x_cnlv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute10 := l_cnlv_rec.attribute10;
      END IF;
      IF (x_cnlv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute11 := l_cnlv_rec.attribute11;
      END IF;
      IF (x_cnlv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute12 := l_cnlv_rec.attribute12;
      END IF;
      IF (x_cnlv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute13 := l_cnlv_rec.attribute13;
      END IF;
      IF (x_cnlv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute14 := l_cnlv_rec.attribute14;
      END IF;
      IF (x_cnlv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_cnlv_rec.attribute15 := l_cnlv_rec.attribute15;
      END IF;
      IF (x_cnlv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.created_by := l_cnlv_rec.created_by;
      END IF;
      IF (x_cnlv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cnlv_rec.creation_date := l_cnlv_rec.creation_date;
      END IF;
      IF (x_cnlv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.last_updated_by := l_cnlv_rec.last_updated_by;
      END IF;
      IF (x_cnlv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cnlv_rec.last_update_date := l_cnlv_rec.last_update_date;
      END IF;
      IF (x_cnlv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cnlv_rec.last_update_login := l_cnlv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_LINES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cnlv_rec IN  cnlv_rec_type,
      x_cnlv_rec OUT NOCOPY cnlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cnlv_rec := p_cnlv_rec;
      x_cnlv_rec.OBJECT_VERSION_NUMBER := NVL(x_cnlv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    IF  l_cnlv_rec.last_updated_by <> 1 THEN
    IF  l_cnlv_rec.seeded_flag = 'Y' THEN
	   OKC_API.set_message(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cnlv_rec,                        -- IN
      l_cnlv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cnlv_rec, l_def_cnlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cnlv_rec := fill_who_columns(l_def_cnlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cnlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cnlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cnlv_rec, l_okc_condition_lines_tl_rec);
    migrate(l_def_cnlv_rec, l_cnl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_condition_lines_tl_rec,
      lx_okc_condition_lines_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_condition_lines_tl_rec, l_def_cnlv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cnl_rec,
      lx_cnl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cnl_rec, l_def_cnlv_rec);
    x_cnlv_rec := l_def_cnlv_rec;
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
  -- PL/SQL TBL update_row for:CNLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_tbl                     IN cnlv_tbl_type,
    x_cnlv_tbl                     OUT NOCOPY cnlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnlv_tbl.COUNT > 0) THEN
      i := p_cnlv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnlv_rec                     => p_cnlv_tbl(i),
          x_cnlv_rec                     => x_cnlv_tbl(i));
        EXIT WHEN (i = p_cnlv_tbl.LAST);
        i := p_cnlv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKC_CONDITION_LINES_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnl_rec                      IN cnl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnl_rec                      cnl_rec_type:= p_cnl_rec;
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
    DELETE FROM OKC_CONDITION_LINES_B
     WHERE ID = l_cnl_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKC_CONDITION_LINES_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_condition_lines_tl_rec   IN OkcConditionLinesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_condition_lines_tl_rec   OkcConditionLinesTlRecType:= p_okc_condition_lines_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKC_CONDITION_LINES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_condition_lines_tl_rec IN  OkcConditionLinesTlRecType,
      x_okc_condition_lines_tl_rec OUT NOCOPY OkcConditionLinesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_condition_lines_tl_rec := p_okc_condition_lines_tl_rec;
      x_okc_condition_lines_tl_rec.LANGUAGE := l_lang;
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
      p_okc_condition_lines_tl_rec,      -- IN
      l_okc_condition_lines_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_CONDITION_LINES_TL
     WHERE ID = l_okc_condition_lines_tl_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKC_CONDITION_LINES_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_rec                     IN cnlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnlv_rec                     cnlv_rec_type := p_cnlv_rec;
    l_okc_condition_lines_tl_rec   OkcConditionLinesTlRecType;
    l_cnl_rec                      cnl_rec_type;
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
    IF  l_cnlv_rec.last_updated_by <> 1 THEN
    IF  l_cnlv_rec.seeded_flag = 'Y' THEN
	   OKC_API.set_message(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_cnlv_rec, l_okc_condition_lines_tl_rec);
    migrate(l_cnlv_rec, l_cnl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_condition_lines_tl_rec
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
      l_cnl_rec
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
  -- PL/SQL TBL delete_row for:CNLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_tbl                     IN cnlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnlv_tbl.COUNT > 0) THEN
      i := p_cnlv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnlv_rec                     => p_cnlv_tbl(i));
        EXIT WHEN (i = p_cnlv_tbl.LAST);
        i := p_cnlv_tbl.NEXT(i);
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
-- Procedure for mass insert in OKC_CONDITION_LINES _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_cnlv_tbl cnlv_tbl_type) IS
  l_tabsize NUMBER := p_cnlv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_cnh_id                        OKC_DATATYPES.NumberTabTyp;
  in_pdf_id                        OKC_DATATYPES.NumberTabTyp;
  in_aae_id                        OKC_DATATYPES.NumberTabTyp;
  in_left_ctr_master_id            OKC_DATATYPES.NumberTabTyp;
  in_right_ctr_master_id           OKC_DATATYPES.NumberTabTyp;
  in_left_counter_id               OKC_DATATYPES.NumberTabTyp;
  in_right_counter_id              OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_sortseq                       OKC_DATATYPES.NumberTabTyp;
  in_cnl_type                      OKC_DATATYPES.Var10TabTyp;
  in_description                   OKC_DATATYPES.Var1995TabTyp;
  in_left_parenthesis              OKC_DATATYPES.Var90TabTyp;
  in_relational_operator           OKC_DATATYPES.Var90TabTyp;
  in_right_parenthesis             OKC_DATATYPES.Var90TabTyp;
  in_logical_operator              OKC_DATATYPES.Var10TabTyp;
  in_tolerance                     OKC_DATATYPES.NumberTabTyp;
  in_start_at                      OKC_DATATYPES.NumberTabTyp;
  in_right_operand                 OKC_DATATYPES.Var1995TabTyp;
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
  i                                NUMBER := p_cnlv_tbl.FIRST;
BEGIN

  -- Initializing return status
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  while i is not null
  LOOP
    j := j + 1;
    in_id                       (j) := p_cnlv_tbl(i).id;
    in_object_version_number    (j) := p_cnlv_tbl(i).object_version_number;
    in_sfwt_flag                (j) := p_cnlv_tbl(i).sfwt_flag;
    in_cnh_id                   (j) := p_cnlv_tbl(i).cnh_id;
    in_pdf_id                   (j) := p_cnlv_tbl(i).pdf_id;
    in_aae_id                   (j) := p_cnlv_tbl(i).aae_id;
    in_left_ctr_master_id       (j) := p_cnlv_tbl(i).left_ctr_master_id;
    in_right_ctr_master_id      (j) := p_cnlv_tbl(i).right_ctr_master_id;
    in_left_counter_id          (j) := p_cnlv_tbl(i).left_counter_id;
    in_right_counter_id         (j) := p_cnlv_tbl(i).right_counter_id;
    in_dnz_chr_id               (j) := p_cnlv_tbl(i).dnz_chr_id;
    in_sortseq                  (j) := p_cnlv_tbl(i).sortseq;
    in_cnl_type                 (j) := p_cnlv_tbl(i).cnl_type;
    in_description              (j) := p_cnlv_tbl(i).description;
    in_left_parenthesis         (j) := p_cnlv_tbl(i).left_parenthesis;
    in_relational_operator      (j) := p_cnlv_tbl(i).relational_operator;
    in_right_parenthesis        (j) := p_cnlv_tbl(i).right_parenthesis;
    in_logical_operator         (j) := p_cnlv_tbl(i).logical_operator;
    in_tolerance                (j) := p_cnlv_tbl(i).tolerance;
    in_start_at                 (j) := p_cnlv_tbl(i).start_at;
    in_right_operand            (j) := p_cnlv_tbl(i).right_operand;
    in_application_id           (j) := p_cnlv_tbl(i).application_id;
    in_seeded_flag              (j) := p_cnlv_tbl(i).seeded_flag;
    in_attribute_category       (j) := p_cnlv_tbl(i).attribute_category;
    in_attribute1               (j) := p_cnlv_tbl(i).attribute1;
    in_attribute2               (j) := p_cnlv_tbl(i).attribute2;
    in_attribute3               (j) := p_cnlv_tbl(i).attribute3;
    in_attribute4               (j) := p_cnlv_tbl(i).attribute4;
    in_attribute5               (j) := p_cnlv_tbl(i).attribute5;
    in_attribute6               (j) := p_cnlv_tbl(i).attribute6;
    in_attribute7               (j) := p_cnlv_tbl(i).attribute7;
    in_attribute8               (j) := p_cnlv_tbl(i).attribute8;
    in_attribute9               (j) := p_cnlv_tbl(i).attribute9;
    in_attribute10              (j) := p_cnlv_tbl(i).attribute10;
    in_attribute11              (j) := p_cnlv_tbl(i).attribute11;
    in_attribute12              (j) := p_cnlv_tbl(i).attribute12;
    in_attribute13              (j) := p_cnlv_tbl(i).attribute13;
    in_attribute14              (j) := p_cnlv_tbl(i).attribute14;
    in_attribute15              (j) := p_cnlv_tbl(i).attribute15;
    in_created_by               (j) := p_cnlv_tbl(i).created_by;
    in_creation_date            (j) := p_cnlv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_cnlv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_cnlv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_cnlv_tbl(i).last_update_login;
    i := p_cnlv_tbl.NEXT(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_CONDITION_LINES_B
      (
        id,
        cnh_id,
        pdf_id,
        aae_id,
        left_ctr_master_id,
        right_ctr_master_id,
        left_counter_id,
        right_counter_id,
        dnz_chr_id,
        sortseq,
        logical_operator,
        cnl_type,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        left_parenthesis,
        relational_operator,
        right_parenthesis,
        tolerance,
        start_at,
        right_operand,
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
        in_cnh_id(i),
        in_pdf_id(i),
        in_aae_id(i),
        in_left_ctr_master_id(i),
        in_right_ctr_master_id(i),
        in_left_counter_id(i),
        in_right_counter_id(i),
        in_dnz_chr_id(i),
        in_sortseq(i),
        in_logical_operator(i),
        in_cnl_type(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_left_parenthesis(i),
        in_relational_operator(i),
        in_right_parenthesis(i),
        in_tolerance(i),
        in_start_at(i),
        in_right_operand(i),
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
      INSERT INTO OKC_CONDITION_LINES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        description,
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
        in_description(i),
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
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
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
INSERT INTO okc_condition_lines_bh
  (
      major_version,
      id,
      cnh_id,
      pdf_id,
      aae_id,
      left_ctr_master_id,
      right_ctr_master_id,
      left_counter_id,
      right_counter_id,
      dnz_chr_id,
      sortseq,
      logical_operator,
      cnl_type,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      left_parenthesis,
      relational_operator,
      right_parenthesis,
      tolerance,
      start_at,
      right_operand,
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
      cnh_id,
      pdf_id,
      aae_id,
      left_ctr_master_id,
      right_ctr_master_id,
      left_counter_id,
      right_counter_id,
      dnz_chr_id,
      sortseq,
      logical_operator,
      cnl_type,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      left_parenthesis,
      relational_operator,
      right_parenthesis,
      tolerance,
      start_at,
      right_operand,
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
  FROM okc_condition_lines_b
WHERE dnz_chr_id = p_chr_id;

---------------------------------------
-- Versioning TL Table
---------------------------------------

INSERT INTO okc_condition_lines_tlh
  (
      major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      description,
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
      description,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_condition_lines_tl
 WHERE id in (select id from okc_condition_lines_b
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
INSERT INTO okc_condition_lines_tl
  (
      id,
      language,
      source_lang,
      sfwt_flag,
      description,
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
      description,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_condition_lines_tlh
WHERE id in (SELECT id
			FROM okc_condition_lines_bh
		    WHERE dnz_chr_id = p_chr_id)
  AND major_version = p_major_version;

-------------------------------------
-- Restoring Base Table
-------------------------------------

INSERT INTO okc_condition_lines_b
  (
      id,
      cnh_id,
      pdf_id,
      aae_id,
      left_ctr_master_id,
      right_ctr_master_id,
      left_counter_id,
      right_counter_id,
      dnz_chr_id,
      sortseq,
      logical_operator,
      cnl_type,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      left_parenthesis,
      relational_operator,
      right_parenthesis,
      tolerance,
      start_at,
      right_operand,
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
      id,
      cnh_id,
      pdf_id,
      aae_id,
      left_ctr_master_id,
      right_ctr_master_id,
      left_counter_id,
      right_counter_id,
      dnz_chr_id,
      sortseq,
      logical_operator,
      cnl_type,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      left_parenthesis,
      relational_operator,
      right_parenthesis,
      tolerance,
      start_at,
      right_operand,
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
  FROM okc_condition_lines_bh
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
END OKC_CNL_PVT;

/
