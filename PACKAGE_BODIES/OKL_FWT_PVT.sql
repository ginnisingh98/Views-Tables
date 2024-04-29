--------------------------------------------------------
--  DDL for Package Body OKL_FWT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FWT_PVT" AS
/* $Header: OKLSFWTB.pls 115.3 2004/05/20 22:36:24 avsingh noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
    IF (last_msg_idx = 1) THEN
      l_msg_idx := FND_MSG_PUB.G_FIRST;
    END IF;
    LOOP
      fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
            p_msg_index_out => px_error_rec.msg_count);
      px_error_tbl(j) := px_error_rec;
      j := j + 1;
    EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
    END LOOP;
  END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a OKL_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKL_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := p_error_tbl(i).error_type;
          END IF;
        END IF;
        EXIT WHEN (i = p_error_tbl.LAST);
        i := p_error_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN(l_return_status);
  END find_highest_exception;
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
    DELETE FROM OKL_FRENCH_TAX_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_FRENCH_TAX_B B
         WHERE B.ID =T.ID
        );

    UPDATE OKL_FRENCH_TAX_TL T SET(
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_FRENCH_TAX_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_FRENCH_TAX_TL SUBB, OKL_FRENCH_TAX_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO OKL_FRENCH_TAX_TL (
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
        FROM OKL_FRENCH_TAX_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_FRENCH_TAX_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_FRENCH_TAX_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fwtv_rec                     IN fwtv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fwtv_rec_type IS
    CURSOR okl_infv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CODE,
            NAME,
            DESCRIPTION,
            START_DATE,
            END_DATE,
            ENABLED_FLAG,
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
      FROM Okl_French_Tax_V
     WHERE okl_french_tax_v.id  = p_id;
    l_okl_infv_pk                  okl_infv_pk_csr%ROWTYPE;
    l_fwtv_rec                     fwtv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_infv_pk_csr (p_fwtv_rec.id);
    FETCH okl_infv_pk_csr INTO
              l_fwtv_rec.id,
              l_fwtv_rec.object_version_number,
              l_fwtv_rec.sfwt_flag,
              l_fwtv_rec.code,
              l_fwtv_rec.name,
              l_fwtv_rec.description,
              l_fwtv_rec.start_date,
              l_fwtv_rec.end_date,
              l_fwtv_rec.enabled_flag,
              l_fwtv_rec.attribute_category,
              l_fwtv_rec.attribute1,
              l_fwtv_rec.attribute2,
              l_fwtv_rec.attribute3,
              l_fwtv_rec.attribute4,
              l_fwtv_rec.attribute5,
              l_fwtv_rec.attribute6,
              l_fwtv_rec.attribute7,
              l_fwtv_rec.attribute8,
              l_fwtv_rec.attribute9,
              l_fwtv_rec.attribute10,
              l_fwtv_rec.attribute11,
              l_fwtv_rec.attribute12,
              l_fwtv_rec.attribute13,
              l_fwtv_rec.attribute14,
              l_fwtv_rec.attribute15,
              l_fwtv_rec.created_by,
              l_fwtv_rec.creation_date,
              l_fwtv_rec.last_updated_by,
              l_fwtv_rec.last_update_date,
              l_fwtv_rec.last_update_login;
    x_no_data_found := okl_infv_pk_csr%NOTFOUND;
    CLOSE okl_infv_pk_csr;
    RETURN(l_fwtv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_fwtv_rec                     IN fwtv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN fwtv_rec_type IS
    l_fwtv_rec                     fwtv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_fwtv_rec := get_rec(p_fwtv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_fwtv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_fwtv_rec                     IN fwtv_rec_type
  ) RETURN fwtv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fwtv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_FRENCH_TAX_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fwtt_rec                     IN fwtt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fwtt_rec_type IS
    CURSOR okl_french_tax_tl_pk_csr (p_id       IN NUMBER,
                                     p_language IN VARCHAR2) IS
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
      FROM Okl_French_Tax_Tl
     WHERE okl_french_tax_tl.id = p_id
       AND okl_french_tax_tl.language = p_language;
    l_okl_french_tax_tl_pk         okl_french_tax_tl_pk_csr%ROWTYPE;
    l_fwtt_rec                     fwtt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_french_tax_tl_pk_csr (p_fwtt_rec.id,
                                   p_fwtt_rec.language);
    FETCH okl_french_tax_tl_pk_csr INTO
              l_fwtt_rec.id,
              l_fwtt_rec.language,
              l_fwtt_rec.source_lang,
              l_fwtt_rec.sfwt_flag,
              l_fwtt_rec.name,
              l_fwtt_rec.description,
              l_fwtt_rec.created_by,
              l_fwtt_rec.creation_date,
              l_fwtt_rec.last_updated_by,
              l_fwtt_rec.last_update_date,
              l_fwtt_rec.last_update_login;
    x_no_data_found := okl_french_tax_tl_pk_csr%NOTFOUND;
    CLOSE okl_french_tax_tl_pk_csr;
    RETURN(l_fwtt_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_fwtt_rec                     IN fwtt_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN fwtt_rec_type IS
    l_fwtt_rec                     fwtt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_fwtt_rec := get_rec(p_fwtt_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_fwtt_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_fwtt_rec                     IN fwtt_rec_type
  ) RETURN fwtt_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fwtt_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_FRENCH_TAX_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fwt_rec                      IN fwt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fwt_rec_type IS
    CURSOR okl_french_tax_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CODE,
            START_DATE,
            END_DATE,
            ENABLED_FLAG,
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
      FROM Okl_French_Tax_B
     WHERE okl_french_tax_b.id  = p_id;
    l_okl_french_tax_b_pk          okl_french_tax_b_pk_csr%ROWTYPE;
    l_fwt_rec                      fwt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_french_tax_b_pk_csr (p_fwt_rec.id);
    FETCH okl_french_tax_b_pk_csr INTO
              l_fwt_rec.id,
              l_fwt_rec.object_version_number,
              l_fwt_rec.code,
              l_fwt_rec.start_date,
              l_fwt_rec.end_date,
              l_fwt_rec.enabled_flag,
              l_fwt_rec.attribute_category,
              l_fwt_rec.attribute1,
              l_fwt_rec.attribute2,
              l_fwt_rec.attribute3,
              l_fwt_rec.attribute4,
              l_fwt_rec.attribute5,
              l_fwt_rec.attribute6,
              l_fwt_rec.attribute7,
              l_fwt_rec.attribute8,
              l_fwt_rec.attribute9,
              l_fwt_rec.attribute10,
              l_fwt_rec.attribute11,
              l_fwt_rec.attribute12,
              l_fwt_rec.attribute13,
              l_fwt_rec.attribute14,
              l_fwt_rec.attribute15,
              l_fwt_rec.created_by,
              l_fwt_rec.creation_date,
              l_fwt_rec.last_updated_by,
              l_fwt_rec.last_update_date,
              l_fwt_rec.last_update_login;
    x_no_data_found := okl_french_tax_b_pk_csr%NOTFOUND;
    CLOSE okl_french_tax_b_pk_csr;
    RETURN(l_fwt_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_fwt_rec                      IN fwt_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN fwt_rec_type IS
    l_fwt_rec                      fwt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_fwt_rec := get_rec(p_fwt_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_fwt_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_fwt_rec                      IN fwt_rec_type
  ) RETURN fwt_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fwt_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_FRENCH_TAX_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_fwtv_rec   IN fwtv_rec_type
  ) RETURN fwtv_rec_type IS
    l_fwtv_rec                     fwtv_rec_type := p_fwtv_rec;
  BEGIN
    IF (l_fwtv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_fwtv_rec.id := NULL;
    END IF;
    IF (l_fwtv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_fwtv_rec.object_version_number := NULL;
    END IF;
    IF (l_fwtv_rec.sfwt_flag = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_fwtv_rec.code = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.code := NULL;
    END IF;
    IF (l_fwtv_rec.name = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.name := NULL;
    END IF;
    IF (l_fwtv_rec.description = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.description := NULL;
    END IF;
    IF (l_fwtv_rec.start_date = OKL_API.G_MISS_DATE ) THEN
      l_fwtv_rec.start_date := NULL;
    END IF;
    IF (l_fwtv_rec.end_date = OKL_API.G_MISS_DATE ) THEN
      l_fwtv_rec.end_date := NULL;
    END IF;
    IF (l_fwtv_rec.enabled_flag = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.enabled_flag := NULL;
    END IF;
    IF (l_fwtv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute_category := NULL;
    END IF;
    IF (l_fwtv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute1 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute2 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute3 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute4 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute5 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute6 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute7 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute8 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute9 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute10 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute11 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute12 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute13 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute14 := NULL;
    END IF;
    IF (l_fwtv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_fwtv_rec.attribute15 := NULL;
    END IF;
    IF (l_fwtv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_fwtv_rec.created_by := NULL;
    END IF;
    IF (l_fwtv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_fwtv_rec.creation_date := NULL;
    END IF;
    IF (l_fwtv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_fwtv_rec.last_updated_by := NULL;
    END IF;
    IF (l_fwtv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_fwtv_rec.last_update_date := NULL;
    END IF;
    IF (l_fwtv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_fwtv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_fwtv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_id = OKL_API.G_MISS_NUM OR
        p_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number = OKL_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  ----------------------------------------
  -- Validate_Attributes for: SFWT_FLAG --
  ----------------------------------------
  PROCEDURE validate_sfwt_flag(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sfwt_flag                    IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_sfwt_flag = OKL_API.G_MISS_CHAR OR
        p_sfwt_flag IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sfwt_flag');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_sfwt_flag;
  -----------------------------------
  -- Validate_Attributes for: CODE --
  -----------------------------------
  PROCEDURE validate_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_code                         IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_code = OKL_API.G_MISS_CHAR OR
        p_code IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'code');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_code;
  -----------------------------------
  -- Validate_Attributes for: NAME --
  -----------------------------------
  PROCEDURE validate_name(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_name                         IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_name = OKL_API.G_MISS_CHAR OR
        p_name IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'name');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_name;
  -----------------------------------------
  -- Validate_Attributes for: START_DATE --
  -----------------------------------------
  PROCEDURE validate_start_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_start_date                   IN DATE) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_start_date = OKL_API.G_MISS_DATE OR
        p_start_date IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'start_date');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_start_date;

    -----------------------------------------
  -- Validate_Attributes for: Enabled_flag --
  -----------------------------------------
  PROCEDURE validate_enabled_flag(
    x_return_status                  OUT NOCOPY VARCHAR2,
    p_enabled_flag                   IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_enabled_flag = OKL_API.G_MISS_CHAR OR
        p_enabled_flag IS NULL)
    THEN
        NULL; --nulls allowed for this field
    ELSIF (p_enabled_flag <> OKL_API.G_MISS_CHAR AND
           p_enabled_flag IS NOT NULL)
    THEN
        If p_enabled_flag not in ('Y','N') then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Enabled_Flag');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_enabled_flag;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_FRENCH_TAX_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_fwtv_rec                     IN fwtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_fwtv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_fwtv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(x_return_status, p_fwtv_rec.sfwt_flag);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- code
    -- ***
    validate_code(x_return_status, p_fwtv_rec.code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- name
    -- ***
    validate_name(x_return_status, p_fwtv_rec.name);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- start_date
    -- ***
    validate_start_date(x_return_status, p_fwtv_rec.start_date);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- enabled_flag
    -- ***
    validate_enabled_flag(x_return_status, p_fwtv_rec.enabled_flag);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate Record for:OKL_FRENCH_TAX_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_fwtv_rec IN fwtv_rec_type,
    p_db_fwtv_rec IN fwtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_fwtv_rec IN fwtv_rec_type,
      p_db_fwtv_rec IN fwtv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;


      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      Null;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys(p_fwtv_rec, p_db_fwtv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_fwtv_rec IN fwtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_fwtv_rec                  fwtv_rec_type := get_rec(p_fwtv_rec);
  BEGIN
    l_return_status := Validate_Record(p_fwtv_rec => p_fwtv_rec,
                                       p_db_fwtv_rec => l_db_fwtv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN fwtv_rec_type,
    p_to   IN OUT NOCOPY fwtt_rec_type
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
    p_from IN fwtt_rec_type,
    p_to   IN OUT NOCOPY fwtv_rec_type
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
    p_from IN fwtv_rec_type,
    p_to   IN OUT NOCOPY fwt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.code := p_from.code;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.enabled_flag := p_from.enabled_flag;
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
    p_from IN fwt_rec_type,
    p_to   IN OUT NOCOPY fwtv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.code := p_from.code;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.enabled_flag := p_from.enabled_flag;
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
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKL_FRENCH_TAX_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwtv_rec                     fwtv_rec_type := p_fwtv_rec;
    l_fwt_rec                      fwt_rec_type;
    l_fwtt_rec                     fwtt_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_fwtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_fwtv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  --------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_FRENCH_TAX_V --
  --------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fwtv_tbl.COUNT > 0) THEN
      i := p_fwtv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_fwtv_rec                     => p_fwtv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_fwtv_tbl.LAST);
        i := p_fwtv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  --------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_FRENCH_TAX_V --
  --------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fwtv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_fwtv_tbl                     => p_fwtv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_FRENCH_TAX_B --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwt_rec                      IN fwt_rec_type,
    x_fwt_rec                      OUT NOCOPY fwt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwt_rec                      fwt_rec_type := p_fwt_rec;
    l_def_fwt_rec                  fwt_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_FRENCH_TAX_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_fwt_rec IN fwt_rec_type,
      x_fwt_rec OUT NOCOPY fwt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fwt_rec := p_fwt_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_fwt_rec,                         -- IN
      l_fwt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_FRENCH_TAX_B(
      id,
      object_version_number,
      code,
      start_date,
      end_date,
      enabled_flag,
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
      l_fwt_rec.id,
      l_fwt_rec.object_version_number,
      l_fwt_rec.code,
      l_fwt_rec.start_date,
      l_fwt_rec.end_date,
      l_fwt_rec.enabled_flag,
      l_fwt_rec.attribute_category,
      l_fwt_rec.attribute1,
      l_fwt_rec.attribute2,
      l_fwt_rec.attribute3,
      l_fwt_rec.attribute4,
      l_fwt_rec.attribute5,
      l_fwt_rec.attribute6,
      l_fwt_rec.attribute7,
      l_fwt_rec.attribute8,
      l_fwt_rec.attribute9,
      l_fwt_rec.attribute10,
      l_fwt_rec.attribute11,
      l_fwt_rec.attribute12,
      l_fwt_rec.attribute13,
      l_fwt_rec.attribute14,
      l_fwt_rec.attribute15,
      l_fwt_rec.created_by,
      l_fwt_rec.creation_date,
      l_fwt_rec.last_updated_by,
      l_fwt_rec.last_update_date,
      l_fwt_rec.last_update_login);
    -- Set OUT values
    x_fwt_rec := l_fwt_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_FRENCH_TAX_TL --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtt_rec                     IN fwtt_rec_type,
    x_fwtt_rec                     OUT NOCOPY fwtt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwtt_rec                     fwtt_rec_type := p_fwtt_rec;
    l_def_fwtt_rec                 fwtt_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ------------------------------------------
    -- Set_Attributes for:OKL_FRENCH_TAX_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_fwtt_rec IN fwtt_rec_type,
      x_fwtt_rec OUT NOCOPY fwtt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fwtt_rec := p_fwtt_rec;
      x_fwtt_rec.LANGUAGE := USERENV('LANG');
      x_fwtt_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_fwtt_rec,                        -- IN
      l_fwtt_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_fwtt_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_FRENCH_TAX_TL(
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
        l_fwtt_rec.id,
        l_fwtt_rec.language,
        l_fwtt_rec.source_lang,
        l_fwtt_rec.sfwt_flag,
        l_fwtt_rec.name,
        l_fwtt_rec.description,
        l_fwtt_rec.created_by,
        l_fwtt_rec.creation_date,
        l_fwtt_rec.last_updated_by,
        l_fwtt_rec.last_update_date,
        l_fwtt_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_fwtt_rec := l_fwtt_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for :OKL_FRENCH_TAX_V --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type,
    x_fwtv_rec                     OUT NOCOPY fwtv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwtv_rec                     fwtv_rec_type := p_fwtv_rec;
    l_def_fwtv_rec                 fwtv_rec_type;
    l_fwt_rec                      fwt_rec_type;
    lx_fwt_rec                     fwt_rec_type;
    l_fwtt_rec                     fwtt_rec_type;
    lx_fwtt_rec                    fwtt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fwtv_rec IN fwtv_rec_type
    ) RETURN fwtv_rec_type IS
      l_fwtv_rec fwtv_rec_type := p_fwtv_rec;
    BEGIN
      l_fwtv_rec.CREATION_DATE := SYSDATE;
      l_fwtv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_fwtv_rec.LAST_UPDATE_DATE := l_fwtv_rec.CREATION_DATE;
      l_fwtv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_fwtv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_fwtv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_FRENCH_TAX_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_fwtv_rec IN fwtv_rec_type,
      x_fwtv_rec OUT NOCOPY fwtv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fwtv_rec := p_fwtv_rec;
      x_fwtv_rec.OBJECT_VERSION_NUMBER := 1;
      x_fwtv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_fwtv_rec := null_out_defaults(p_fwtv_rec);
    -- Set primary key value
    l_fwtv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_fwtv_rec,                        -- IN
      l_def_fwtv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_fwtv_rec := fill_who_columns(l_def_fwtv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_fwtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_fwtv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_fwtv_rec, l_fwt_rec);
    migrate(l_def_fwtv_rec, l_fwtt_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fwt_rec,
      lx_fwt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fwt_rec, l_def_fwtv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fwtt_rec,
      lx_fwtt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fwtt_rec, l_def_fwtv_rec);
    -- Set OUT values
    x_fwtv_rec := l_def_fwtv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:FWTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fwtv_tbl.COUNT > 0) THEN
      i := p_fwtv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_fwtv_rec                     => p_fwtv_tbl(i),
            x_fwtv_rec                     => x_fwtv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_fwtv_tbl.LAST);
        i := p_fwtv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:FWTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fwtv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_fwtv_tbl                     => p_fwtv_tbl,
        x_fwtv_tbl                     => x_fwtv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_FRENCH_TAX_B --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwt_rec                      IN fwt_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_fwt_rec IN fwt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FRENCH_TAX_B
     WHERE ID = p_fwt_rec.id
       AND OBJECT_VERSION_NUMBER = p_fwt_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_fwt_rec IN fwt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FRENCH_TAX_B
     WHERE ID = p_fwt_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_FRENCH_TAX_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_FRENCH_TAX_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_fwt_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_fwt_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_fwt_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_fwt_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_FRENCH_TAX_TL --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtt_rec                     IN fwtt_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_fwtt_rec IN fwtt_rec_type) IS
    SELECT *
      FROM OKL_FRENCH_TAX_TL
     WHERE ID = p_fwtt_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_fwtt_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for: OKL_FRENCH_TAX_V --
  ------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwtt_rec                     fwtt_rec_type;
    l_fwt_rec                      fwt_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_fwtv_rec, l_fwtt_rec);
    migrate(p_fwtv_rec, l_fwt_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fwtt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fwt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:FWTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_fwtv_tbl.COUNT > 0) THEN
      i := p_fwtv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_fwtv_rec                     => p_fwtv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_fwtv_tbl.LAST);
        i := p_fwtv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:FWTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_fwtv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_fwtv_tbl                     => p_fwtv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_FRENCH_TAX_B --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwt_rec                      IN fwt_rec_type,
    x_fwt_rec                      OUT NOCOPY fwt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwt_rec                      fwt_rec_type := p_fwt_rec;
    l_def_fwt_rec                  fwt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fwt_rec IN fwt_rec_type,
      x_fwt_rec OUT NOCOPY fwt_rec_type
    ) RETURN VARCHAR2 IS
      l_fwt_rec                      fwt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fwt_rec := p_fwt_rec;
      -- Get current database values
      l_fwt_rec := get_rec(p_fwt_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_fwt_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_fwt_rec.id := l_fwt_rec.id;
        END IF;
        IF (x_fwt_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_fwt_rec.object_version_number := l_fwt_rec.object_version_number;
        END IF;
        IF (x_fwt_rec.code = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.code := l_fwt_rec.code;
        END IF;
        IF (x_fwt_rec.start_date = OKL_API.G_MISS_DATE)
        THEN
          x_fwt_rec.start_date := l_fwt_rec.start_date;
        END IF;
        IF (x_fwt_rec.end_date = OKL_API.G_MISS_DATE)
        THEN
          x_fwt_rec.end_date := l_fwt_rec.end_date;
        END IF;
        IF (x_fwt_rec.enabled_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.enabled_flag := l_fwt_rec.enabled_flag;
        END IF;
        IF (x_fwt_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute_category := l_fwt_rec.attribute_category;
        END IF;
        IF (x_fwt_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute1 := l_fwt_rec.attribute1;
        END IF;
        IF (x_fwt_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute2 := l_fwt_rec.attribute2;
        END IF;
        IF (x_fwt_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute3 := l_fwt_rec.attribute3;
        END IF;
        IF (x_fwt_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute4 := l_fwt_rec.attribute4;
        END IF;
        IF (x_fwt_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute5 := l_fwt_rec.attribute5;
        END IF;
        IF (x_fwt_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute6 := l_fwt_rec.attribute6;
        END IF;
        IF (x_fwt_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute7 := l_fwt_rec.attribute7;
        END IF;
        IF (x_fwt_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute8 := l_fwt_rec.attribute8;
        END IF;
        IF (x_fwt_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute9 := l_fwt_rec.attribute9;
        END IF;
        IF (x_fwt_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute10 := l_fwt_rec.attribute10;
        END IF;
        IF (x_fwt_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute11 := l_fwt_rec.attribute11;
        END IF;
        IF (x_fwt_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute12 := l_fwt_rec.attribute12;
        END IF;
        IF (x_fwt_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute13 := l_fwt_rec.attribute13;
        END IF;
        IF (x_fwt_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute14 := l_fwt_rec.attribute14;
        END IF;
        IF (x_fwt_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwt_rec.attribute15 := l_fwt_rec.attribute15;
        END IF;
        IF (x_fwt_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_fwt_rec.created_by := l_fwt_rec.created_by;
        END IF;
        IF (x_fwt_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_fwt_rec.creation_date := l_fwt_rec.creation_date;
        END IF;
        IF (x_fwt_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_fwt_rec.last_updated_by := l_fwt_rec.last_updated_by;
        END IF;
        IF (x_fwt_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_fwt_rec.last_update_date := l_fwt_rec.last_update_date;
        END IF;
        IF (x_fwt_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_fwt_rec.last_update_login := l_fwt_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_FRENCH_TAX_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_fwt_rec IN fwt_rec_type,
      x_fwt_rec OUT NOCOPY fwt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fwt_rec := p_fwt_rec;
      x_fwt_rec.OBJECT_VERSION_NUMBER := p_fwt_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_fwt_rec,                         -- IN
      l_fwt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fwt_rec, l_def_fwt_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_FRENCH_TAX_B
    SET OBJECT_VERSION_NUMBER = l_def_fwt_rec.object_version_number,
        CODE = l_def_fwt_rec.code,
        START_DATE = l_def_fwt_rec.start_date,
        END_DATE = l_def_fwt_rec.end_date,
        ENABLED_FLAG = l_def_fwt_rec.enabled_flag,
        ATTRIBUTE_CATEGORY = l_def_fwt_rec.attribute_category,
        ATTRIBUTE1 = l_def_fwt_rec.attribute1,
        ATTRIBUTE2 = l_def_fwt_rec.attribute2,
        ATTRIBUTE3 = l_def_fwt_rec.attribute3,
        ATTRIBUTE4 = l_def_fwt_rec.attribute4,
        ATTRIBUTE5 = l_def_fwt_rec.attribute5,
        ATTRIBUTE6 = l_def_fwt_rec.attribute6,
        ATTRIBUTE7 = l_def_fwt_rec.attribute7,
        ATTRIBUTE8 = l_def_fwt_rec.attribute8,
        ATTRIBUTE9 = l_def_fwt_rec.attribute9,
        ATTRIBUTE10 = l_def_fwt_rec.attribute10,
        ATTRIBUTE11 = l_def_fwt_rec.attribute11,
        ATTRIBUTE12 = l_def_fwt_rec.attribute12,
        ATTRIBUTE13 = l_def_fwt_rec.attribute13,
        ATTRIBUTE14 = l_def_fwt_rec.attribute14,
        ATTRIBUTE15 = l_def_fwt_rec.attribute15,
        CREATED_BY = l_def_fwt_rec.created_by,
        CREATION_DATE = l_def_fwt_rec.creation_date,
        LAST_UPDATED_BY = l_def_fwt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_fwt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_fwt_rec.last_update_login
    WHERE ID = l_def_fwt_rec.id;

    x_fwt_rec := l_fwt_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_FRENCH_TAX_TL --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtt_rec                     IN fwtt_rec_type,
    x_fwtt_rec                     OUT NOCOPY fwtt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwtt_rec                     fwtt_rec_type := p_fwtt_rec;
    l_def_fwtt_rec                 fwtt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fwtt_rec IN fwtt_rec_type,
      x_fwtt_rec OUT NOCOPY fwtt_rec_type
    ) RETURN VARCHAR2 IS
      l_fwtt_rec                     fwtt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fwtt_rec := p_fwtt_rec;
      -- Get current database values
      l_fwtt_rec := get_rec(p_fwtt_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_fwtt_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_fwtt_rec.id := l_fwtt_rec.id;
        END IF;
        IF (x_fwtt_rec.language = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtt_rec.language := l_fwtt_rec.language;
        END IF;
        IF (x_fwtt_rec.source_lang = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtt_rec.source_lang := l_fwtt_rec.source_lang;
        END IF;
        IF (x_fwtt_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtt_rec.sfwt_flag := l_fwtt_rec.sfwt_flag;
        END IF;
        IF (x_fwtt_rec.name = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtt_rec.name := l_fwtt_rec.name;
        END IF;
        IF (x_fwtt_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtt_rec.description := l_fwtt_rec.description;
        END IF;
        IF (x_fwtt_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_fwtt_rec.created_by := l_fwtt_rec.created_by;
        END IF;
        IF (x_fwtt_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_fwtt_rec.creation_date := l_fwtt_rec.creation_date;
        END IF;
        IF (x_fwtt_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_fwtt_rec.last_updated_by := l_fwtt_rec.last_updated_by;
        END IF;
        IF (x_fwtt_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_fwtt_rec.last_update_date := l_fwtt_rec.last_update_date;
        END IF;
        IF (x_fwtt_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_fwtt_rec.last_update_login := l_fwtt_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_FRENCH_TAX_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_fwtt_rec IN fwtt_rec_type,
      x_fwtt_rec OUT NOCOPY fwtt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fwtt_rec := p_fwtt_rec;
      x_fwtt_rec.LANGUAGE := USERENV('LANG');
      x_fwtt_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_fwtt_rec,                        -- IN
      l_fwtt_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fwtt_rec, l_def_fwtt_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_FRENCH_TAX_TL
    SET NAME = l_def_fwtt_rec.name,
        DESCRIPTION = l_def_fwtt_rec.description,
        --Bug# 3641933 :
        SOURCE_LANG = l_def_fwtt_rec.source_lang,
        CREATED_BY = l_def_fwtt_rec.created_by,
        CREATION_DATE = l_def_fwtt_rec.creation_date,
        LAST_UPDATED_BY = l_def_fwtt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_fwtt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_fwtt_rec.last_update_login
    WHERE ID = l_def_fwtt_rec.id
      --Bug# 3641933 :
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKL_FRENCH_TAX_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_fwtt_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_fwtt_rec := l_fwtt_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_FRENCH_TAX_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type,
    x_fwtv_rec                     OUT NOCOPY fwtv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwtv_rec                     fwtv_rec_type := p_fwtv_rec;
    l_def_fwtv_rec                 fwtv_rec_type;
    l_db_fwtv_rec                  fwtv_rec_type;
    l_fwt_rec                      fwt_rec_type;
    lx_fwt_rec                     fwt_rec_type;
    l_fwtt_rec                     fwtt_rec_type;
    lx_fwtt_rec                    fwtt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fwtv_rec IN fwtv_rec_type
    ) RETURN fwtv_rec_type IS
      l_fwtv_rec fwtv_rec_type := p_fwtv_rec;
    BEGIN
      l_fwtv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_fwtv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_fwtv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_fwtv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fwtv_rec IN fwtv_rec_type,
      x_fwtv_rec OUT NOCOPY fwtv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fwtv_rec := p_fwtv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_fwtv_rec := get_rec(p_fwtv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_fwtv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_fwtv_rec.id := l_db_fwtv_rec.id;
        END IF;
        IF (x_fwtv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.sfwt_flag := l_db_fwtv_rec.sfwt_flag;
        END IF;
        IF (x_fwtv_rec.code = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.code := l_db_fwtv_rec.code;
        END IF;
        IF (x_fwtv_rec.name = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.name := l_db_fwtv_rec.name;
        END IF;
        IF (x_fwtv_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.description := l_db_fwtv_rec.description;
        END IF;
        IF (x_fwtv_rec.start_date = OKL_API.G_MISS_DATE)
        THEN
          x_fwtv_rec.start_date := l_db_fwtv_rec.start_date;
        END IF;
        IF (x_fwtv_rec.end_date = OKL_API.G_MISS_DATE)
        THEN
          x_fwtv_rec.end_date := l_db_fwtv_rec.end_date;
        END IF;
        IF (x_fwtv_rec.enabled_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.enabled_flag := l_db_fwtv_rec.enabled_flag;
        END IF;
        IF (x_fwtv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute_category := l_db_fwtv_rec.attribute_category;
        END IF;
        IF (x_fwtv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute1 := l_db_fwtv_rec.attribute1;
        END IF;
        IF (x_fwtv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute2 := l_db_fwtv_rec.attribute2;
        END IF;
        IF (x_fwtv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute3 := l_db_fwtv_rec.attribute3;
        END IF;
        IF (x_fwtv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute4 := l_db_fwtv_rec.attribute4;
        END IF;
        IF (x_fwtv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute5 := l_db_fwtv_rec.attribute5;
        END IF;
        IF (x_fwtv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute6 := l_db_fwtv_rec.attribute6;
        END IF;
        IF (x_fwtv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute7 := l_db_fwtv_rec.attribute7;
        END IF;
        IF (x_fwtv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute8 := l_db_fwtv_rec.attribute8;
        END IF;
        IF (x_fwtv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute9 := l_db_fwtv_rec.attribute9;
        END IF;
        IF (x_fwtv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute10 := l_db_fwtv_rec.attribute10;
        END IF;
        IF (x_fwtv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute11 := l_db_fwtv_rec.attribute11;
        END IF;
        IF (x_fwtv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute12 := l_db_fwtv_rec.attribute12;
        END IF;
        IF (x_fwtv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute13 := l_db_fwtv_rec.attribute13;
        END IF;
        IF (x_fwtv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute14 := l_db_fwtv_rec.attribute14;
        END IF;
        IF (x_fwtv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_fwtv_rec.attribute15 := l_db_fwtv_rec.attribute15;
        END IF;
        IF (x_fwtv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_fwtv_rec.created_by := l_db_fwtv_rec.created_by;
        END IF;
        IF (x_fwtv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_fwtv_rec.creation_date := l_db_fwtv_rec.creation_date;
        END IF;
        IF (x_fwtv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_fwtv_rec.last_updated_by := l_db_fwtv_rec.last_updated_by;
        END IF;
        IF (x_fwtv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_fwtv_rec.last_update_date := l_db_fwtv_rec.last_update_date;
        END IF;
        IF (x_fwtv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_fwtv_rec.last_update_login := l_db_fwtv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_FRENCH_TAX_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_fwtv_rec IN fwtv_rec_type,
      x_fwtv_rec OUT NOCOPY fwtv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fwtv_rec := p_fwtv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_fwtv_rec,                        -- IN
      x_fwtv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fwtv_rec, l_def_fwtv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_fwtv_rec := fill_who_columns(l_def_fwtv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_fwtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_fwtv_rec, l_db_fwtv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
/****Commented**********
    --avsingh
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_fwtv_rec                     => p_fwtv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
***********************/
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_fwtv_rec, l_fwt_rec);
    migrate(l_def_fwtv_rec, l_fwtt_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fwt_rec,
      lx_fwt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fwt_rec, l_def_fwtv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fwtt_rec,
      lx_fwtt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fwtt_rec, l_def_fwtv_rec);
    x_fwtv_rec := l_def_fwtv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:fwtv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fwtv_tbl.COUNT > 0) THEN
      i := p_fwtv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_fwtv_rec                     => p_fwtv_tbl(i),
            x_fwtv_rec                     => x_fwtv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_fwtv_tbl.LAST);
        i := p_fwtv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:FWTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fwtv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_fwtv_tbl                     => p_fwtv_tbl,
        x_fwtv_tbl                     => x_fwtv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_FRENCH_TAX_B --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwt_rec                      IN fwt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwt_rec                      fwt_rec_type := p_fwt_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_FRENCH_TAX_B
     WHERE ID = p_fwt_rec.id;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_FRENCH_TAX_TL --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtt_rec                     IN fwtt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwtt_rec                     fwtt_rec_type := p_fwtt_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_FRENCH_TAX_TL
     WHERE ID = p_fwtt_rec.id;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_FRENCH_TAX_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fwtv_rec                     fwtv_rec_type := p_fwtv_rec;
    l_fwtt_rec                     fwtt_rec_type;
    l_fwt_rec                      fwt_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_fwtv_rec, l_fwtt_rec);
    migrate(l_fwtv_rec, l_fwt_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fwtt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fwt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_FRENCH_TAX_V --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fwtv_tbl.COUNT > 0) THEN
      i := p_fwtv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_fwtv_rec                     => p_fwtv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_fwtv_tbl.LAST);
        i := p_fwtv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_FRENCH_TAX_V --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fwtv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_fwtv_tbl                     => p_fwtv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKL_FWT_PVT;

/
