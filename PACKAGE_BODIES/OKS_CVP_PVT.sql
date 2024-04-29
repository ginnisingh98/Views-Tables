--------------------------------------------------------
--  DDL for Package Body OKS_CVP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CVP_PVT" AS
/* $Header: OKSSCVPB.pls 120.0 2005/05/25 18:10:08 appldev noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKC_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

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
  -- in a OKC_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKC_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
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
    DELETE FROM OKS_COV_TYPES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKS_COV_TYPES_B B
         WHERE B.CODE =T.CODE
        );

    UPDATE OKS_COV_TYPES_TL T SET(
        MEANING,
        DESCRIPTION) = (SELECT
                                  B.MEANING,
                                  B.DESCRIPTION
                                FROM OKS_COV_TYPES_TL B
                               WHERE B.CODE = T.CODE
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.CODE,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.CODE,
                  SUBT.LANGUAGE
                FROM OKS_COV_TYPES_TL SUBB, OKS_COV_TYPES_TL SUBT
               WHERE SUBB.CODE = SUBT.CODE
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.MEANING <> SUBT.MEANING
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.MEANING IS NOT NULL AND SUBT.MEANING IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO OKS_COV_TYPES_TL (
        CODE,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        MEANING,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
      SELECT
            B.CODE,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.MEANING,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_LOGIN,
            B.LAST_UPDATE_DATE
        FROM OKS_COV_TYPES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKS_COV_TYPES_TL T
                     WHERE T.CODE = B.CODE
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_COV_TYPES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cvpv_rec                     IN cvpv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cvpv_rec_type IS
    CURSOR oks_cvt_pk_csr (p_code IN VARCHAR2) IS
    SELECT
            CODE,
            MEANING,
            DESCRIPTION,
            IMPORTANCE_LEVEL,
            SFWT_FLAG,
            ENABLED_FLAG,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
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
      FROM Oks_Cov_Types_V
     WHERE oks_cov_types_v.code = p_code;
    l_oks_cvt_pk                   oks_cvt_pk_csr%ROWTYPE;
    l_cvpv_rec                     cvpv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_cvt_pk_csr (p_cvpv_rec.code);
    FETCH oks_cvt_pk_csr INTO
              l_cvpv_rec.code,
              l_cvpv_rec.meaning,
              l_cvpv_rec.description,
              l_cvpv_rec.importance_level,
              l_cvpv_rec.sfwt_flag,
              l_cvpv_rec.enabled_flag,
              l_cvpv_rec.start_date_active,
              l_cvpv_rec.end_date_active,
              l_cvpv_rec.created_by,
              l_cvpv_rec.creation_date,
              l_cvpv_rec.last_updated_by,
              l_cvpv_rec.last_update_login,
              l_cvpv_rec.last_update_date,
              l_cvpv_rec.attribute_category,
              l_cvpv_rec.attribute1,
              l_cvpv_rec.attribute2,
              l_cvpv_rec.attribute3,
              l_cvpv_rec.attribute4,
              l_cvpv_rec.attribute5,
              l_cvpv_rec.attribute6,
              l_cvpv_rec.attribute7,
              l_cvpv_rec.attribute8,
              l_cvpv_rec.attribute9,
              l_cvpv_rec.attribute10,
              l_cvpv_rec.attribute11,
              l_cvpv_rec.attribute12,
              l_cvpv_rec.attribute13,
              l_cvpv_rec.attribute14,
              l_cvpv_rec.attribute15;
    x_no_data_found := oks_cvt_pk_csr%NOTFOUND;
    CLOSE oks_cvt_pk_csr;
    RETURN(l_cvpv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_cvpv_rec                     IN cvpv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN cvpv_rec_type IS
    l_cvpv_rec                     cvpv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_cvpv_rec := get_rec(p_cvpv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CODE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_cvpv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_cvpv_rec                     IN cvpv_rec_type
  ) RETURN cvpv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cvpv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_COV_TYPES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_cov_types_tl_rec         IN oks_cov_types_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oks_cov_types_tl_rec_type IS
    CURSOR oks_cov_types_tl_pk_csr (p_code     IN VARCHAR2,
                                    p_language IN VARCHAR2) IS
    SELECT
            CODE,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            MEANING,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE
      FROM Oks_Cov_Types_Tl
     WHERE oks_cov_types_tl.code = p_code
       AND oks_cov_types_tl.language = p_language;
    l_oks_cov_types_tl_pk          oks_cov_types_tl_pk_csr%ROWTYPE;
    l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_cov_types_tl_pk_csr (p_oks_cov_types_tl_rec.code,
                                  p_oks_cov_types_tl_rec.language);
    FETCH oks_cov_types_tl_pk_csr INTO
              l_oks_cov_types_tl_rec.code,
              l_oks_cov_types_tl_rec.language,
              l_oks_cov_types_tl_rec.source_lang,
              l_oks_cov_types_tl_rec.sfwt_flag,
              l_oks_cov_types_tl_rec.meaning,
              l_oks_cov_types_tl_rec.description,
              l_oks_cov_types_tl_rec.created_by,
              l_oks_cov_types_tl_rec.creation_date,
              l_oks_cov_types_tl_rec.last_updated_by,
              l_oks_cov_types_tl_rec.last_update_login,
              l_oks_cov_types_tl_rec.last_update_date;
    x_no_data_found := oks_cov_types_tl_pk_csr%NOTFOUND;
    CLOSE oks_cov_types_tl_pk_csr;
    RETURN(l_oks_cov_types_tl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_cov_types_tl_rec         IN oks_cov_types_tl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN oks_cov_types_tl_rec_type IS
    l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oks_cov_types_tl_rec := get_rec(p_oks_cov_types_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CODE');
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oks_cov_types_tl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oks_cov_types_tl_rec         IN oks_cov_types_tl_rec_type
  ) RETURN oks_cov_types_tl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oks_cov_types_tl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_COV_TYPES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cvp_rec                      IN cvp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cvp_rec_type IS
    CURSOR oks_cov_types_b_pk_csr (p_code IN VARCHAR2) IS
    SELECT
            CODE,
            IMPORTANCE_LEVEL,
            ENABLED_FLAG,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
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
      FROM Oks_Cov_Types_B
     WHERE oks_cov_types_b.code = p_code;
    l_oks_cov_types_b_pk           oks_cov_types_b_pk_csr%ROWTYPE;
    l_cvp_rec                      cvp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_cov_types_b_pk_csr (p_cvp_rec.code);
    FETCH oks_cov_types_b_pk_csr INTO
              l_cvp_rec.code,
              l_cvp_rec.importance_level,
              l_cvp_rec.enabled_flag,
              l_cvp_rec.start_date_active,
              l_cvp_rec.end_date_active,
              l_cvp_rec.created_by,
              l_cvp_rec.creation_date,
              l_cvp_rec.last_updated_by,
              l_cvp_rec.last_update_login,
              l_cvp_rec.last_update_date,
              l_cvp_rec.attribute_category,
              l_cvp_rec.attribute1,
              l_cvp_rec.attribute2,
              l_cvp_rec.attribute3,
              l_cvp_rec.attribute4,
              l_cvp_rec.attribute5,
              l_cvp_rec.attribute6,
              l_cvp_rec.attribute7,
              l_cvp_rec.attribute8,
              l_cvp_rec.attribute9,
              l_cvp_rec.attribute10,
              l_cvp_rec.attribute11,
              l_cvp_rec.attribute12,
              l_cvp_rec.attribute13,
              l_cvp_rec.attribute14,
              l_cvp_rec.attribute15;
    x_no_data_found := oks_cov_types_b_pk_csr%NOTFOUND;
    CLOSE oks_cov_types_b_pk_csr;
    RETURN(l_cvp_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_cvp_rec                      IN cvp_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN cvp_rec_type IS
    l_cvp_rec                      cvp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_cvp_rec := get_rec(p_cvp_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CODE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_cvp_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_cvp_rec                      IN cvp_rec_type
  ) RETURN cvp_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cvp_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_COV_TYPES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cvpv_rec   IN cvpv_rec_type
  ) RETURN cvpv_rec_type IS
    l_cvpv_rec                     cvpv_rec_type := p_cvpv_rec;
  BEGIN
    IF (l_cvpv_rec.code = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.code := NULL;
    END IF;
    IF (l_cvpv_rec.meaning = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.meaning := NULL;
    END IF;
    IF (l_cvpv_rec.description = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.description := NULL;
    END IF;
    IF (l_cvpv_rec.importance_level = OKC_API.G_MISS_NUM ) THEN
      l_cvpv_rec.importance_level := NULL;
    END IF;
    IF (l_cvpv_rec.sfwt_flag = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_cvpv_rec.enabled_flag = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.enabled_flag := NULL;
    END IF;
    IF (l_cvpv_rec.start_date_active = OKC_API.G_MISS_DATE ) THEN
      l_cvpv_rec.start_date_active := NULL;
    END IF;
    IF (l_cvpv_rec.end_date_active = OKC_API.G_MISS_DATE ) THEN
      l_cvpv_rec.end_date_active := NULL;
    END IF;
    IF (l_cvpv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_cvpv_rec.created_by := NULL;
    END IF;
    IF (l_cvpv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_cvpv_rec.creation_date := NULL;
    END IF;
    IF (l_cvpv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_cvpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cvpv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_cvpv_rec.last_update_login := NULL;
    END IF;
    IF (l_cvpv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_cvpv_rec.last_update_date := NULL;
    END IF;
    IF (l_cvpv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute_category := NULL;
    END IF;
    IF (l_cvpv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute1 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute2 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute3 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute4 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute5 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute6 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute7 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute8 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute9 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute10 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute11 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute12 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute13 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute14 := NULL;
    END IF;
    IF (l_cvpv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_cvpv_rec.attribute15 := NULL;
    END IF;
    RETURN(l_cvpv_rec);
  END null_out_defaults;
  -----------------------------------
  -- Validate_Attributes for: CODE --
  -----------------------------------
  PROCEDURE validate_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_code                         IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_code = OKC_API.G_MISS_CHAR OR
        p_code IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_code;
  --------------------------------------
  -- Validate_Attributes for: MEANING --
  --------------------------------------
  PROCEDURE validate_meaning(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_meaning                      IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_meaning = OKC_API.G_MISS_CHAR OR
        p_meaning IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'meaning');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_meaning;
  -------------------------------------------
  -- Validate_Attributes for: ENABLED_FLAG --
  -------------------------------------------
  PROCEDURE validate_enabled_flag(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_enabled_flag                 IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_enabled_flag = OKC_API.G_MISS_CHAR OR
        p_enabled_flag IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'enabled_flag');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_enabled_flag;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKS_COV_TYPES_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_cvpv_rec                     IN cvpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- code
    -- ***
    validate_code(x_return_status, p_cvpv_rec.code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- meaning
    -- ***
    validate_meaning(x_return_status, p_cvpv_rec.meaning);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- enabled_flag
    -- ***
    validate_enabled_flag(x_return_status, p_cvpv_rec.enabled_flag);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate Record for:OKS_COV_TYPES_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_cvpv_rec IN cvpv_rec_type,
    p_db_cvpv_rec IN cvpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_cvpv_rec IN cvpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_cvpv_rec                  cvpv_rec_type := get_rec(p_cvpv_rec);
  BEGIN
    l_return_status := Validate_Record(p_cvpv_rec => p_cvpv_rec,
                                       p_db_cvpv_rec => l_db_cvpv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN cvpv_rec_type,
    p_to   IN OUT NOCOPY oks_cov_types_tl_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.meaning := p_from.meaning;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.last_update_date := p_from.last_update_date;
  END migrate;
  PROCEDURE migrate (
    p_from IN oks_cov_types_tl_rec_type,
    p_to   IN OUT NOCOPY cvpv_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.meaning := p_from.meaning;
    p_to.description := p_from.description;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.last_update_date := p_from.last_update_date;
  END migrate;
  PROCEDURE migrate (
    p_from IN cvpv_rec_type,
    p_to   IN OUT NOCOPY cvp_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.importance_level := p_from.importance_level;
    p_to.enabled_flag := p_from.enabled_flag;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.last_update_date := p_from.last_update_date;
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
    p_from IN cvp_rec_type,
    p_to   IN OUT NOCOPY cvpv_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.importance_level := p_from.importance_level;
    p_to.enabled_flag := p_from.enabled_flag;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.last_update_date := p_from.last_update_date;
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
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKS_COV_TYPES_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_rec                     IN cvpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvpv_rec                     cvpv_rec_type := p_cvpv_rec;
    l_cvp_rec                      cvp_rec_type;
    l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_cvpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cvpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_COV_TYPES_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cvpv_tbl.COUNT > 0) THEN
      i := p_cvpv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_cvpv_rec                     => p_cvpv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_cvpv_tbl.LAST);
        i := p_cvpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_COV_TYPES_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cvpv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cvpv_tbl                     => p_cvpv_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- insert_row for:OKS_COV_TYPES_B --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvp_rec                      IN cvp_rec_type,
    x_cvp_rec                      OUT NOCOPY cvp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvp_rec                      cvp_rec_type := p_cvp_rec;
    l_def_cvp_rec                  cvp_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKS_COV_TYPES_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_cvp_rec IN cvp_rec_type,
      x_cvp_rec OUT NOCOPY cvp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvp_rec := p_cvp_rec;
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
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_cvp_rec,                         -- IN
      l_cvp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_COV_TYPES_B(
      code,
      importance_level,
      enabled_flag,
      start_date_active,
      end_date_active,
      created_by,
      creation_date,
      last_updated_by,
      last_update_login,
      last_update_date,
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
      l_cvp_rec.code,
      l_cvp_rec.importance_level,
      l_cvp_rec.enabled_flag,
      l_cvp_rec.start_date_active,
      l_cvp_rec.end_date_active,
      l_cvp_rec.created_by,
      l_cvp_rec.creation_date,
      l_cvp_rec.last_updated_by,
      l_cvp_rec.last_update_login,
      l_cvp_rec.last_update_date,
      l_cvp_rec.attribute_category,
      l_cvp_rec.attribute1,
      l_cvp_rec.attribute2,
      l_cvp_rec.attribute3,
      l_cvp_rec.attribute4,
      l_cvp_rec.attribute5,
      l_cvp_rec.attribute6,
      l_cvp_rec.attribute7,
      l_cvp_rec.attribute8,
      l_cvp_rec.attribute9,
      l_cvp_rec.attribute10,
      l_cvp_rec.attribute11,
      l_cvp_rec.attribute12,
      l_cvp_rec.attribute13,
      l_cvp_rec.attribute14,
      l_cvp_rec.attribute15);
    -- Set OUT values
    x_cvp_rec := l_cvp_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKS_COV_TYPES_TL --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_cov_types_tl_rec         IN oks_cov_types_tl_rec_type,
    x_oks_cov_types_tl_rec         OUT NOCOPY oks_cov_types_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type := p_oks_cov_types_tl_rec;
    l_def_oks_cov_types_tl_rec     oks_cov_types_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------
    -- Set_Attributes for:OKS_COV_TYPES_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_oks_cov_types_tl_rec IN oks_cov_types_tl_rec_type,
      x_oks_cov_types_tl_rec OUT NOCOPY oks_cov_types_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_cov_types_tl_rec := p_oks_cov_types_tl_rec;
      x_oks_cov_types_tl_rec.LANGUAGE := USERENV('LANG');
      x_oks_cov_types_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_oks_cov_types_tl_rec,            -- IN
      l_oks_cov_types_tl_rec);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_oks_cov_types_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKS_COV_TYPES_TL(
        code,
        language,
        source_lang,
        sfwt_flag,
        meaning,
        description,
        created_by,
        creation_date,
        last_updated_by,
        last_update_login,
        last_update_date)
      VALUES (
        l_oks_cov_types_tl_rec.code,
        l_oks_cov_types_tl_rec.language,
        l_oks_cov_types_tl_rec.source_lang,
        l_oks_cov_types_tl_rec.sfwt_flag,
        l_oks_cov_types_tl_rec.meaning,
        l_oks_cov_types_tl_rec.description,
        l_oks_cov_types_tl_rec.created_by,
        l_oks_cov_types_tl_rec.creation_date,
        l_oks_cov_types_tl_rec.last_updated_by,
        l_oks_cov_types_tl_rec.last_update_login,
        l_oks_cov_types_tl_rec.last_update_date);
    END LOOP;
    -- Set OUT values
    x_oks_cov_types_tl_rec := l_oks_cov_types_tl_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for :OKS_COV_TYPES_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_rec                     IN cvpv_rec_type,
    x_cvpv_rec                     OUT NOCOPY cvpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvpv_rec                     cvpv_rec_type := p_cvpv_rec;
    l_def_cvpv_rec                 cvpv_rec_type;
    l_cvp_rec                      cvp_rec_type;
    lx_cvp_rec                     cvp_rec_type;
    l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type;
    lx_oks_cov_types_tl_rec        oks_cov_types_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cvpv_rec IN cvpv_rec_type
    ) RETURN cvpv_rec_type IS
      l_cvpv_rec cvpv_rec_type := p_cvpv_rec;
    BEGIN
      l_cvpv_rec.CREATION_DATE := SYSDATE;
      l_cvpv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cvpv_rec.LAST_UPDATE_DATE := l_cvpv_rec.CREATION_DATE;
      l_cvpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cvpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cvpv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKS_COV_TYPES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_cvpv_rec IN cvpv_rec_type,
      x_cvpv_rec OUT NOCOPY cvpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvpv_rec := p_cvpv_rec;
      x_cvpv_rec.SFWT_FLAG := 'N';
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
    l_cvpv_rec := null_out_defaults(p_cvpv_rec);
    -- Set primary key value
    -- Error: Primary Key Column "CODE"
    --        Does not have a NUMBER datatype, cannot assign get_seq_id
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_cvpv_rec,                        -- IN
      l_def_cvpv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cvpv_rec := fill_who_columns(l_def_cvpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cvpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cvpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_cvpv_rec, l_cvp_rec);
    migrate(l_def_cvpv_rec, l_oks_cov_types_tl_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cvp_rec,
      lx_cvp_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cvp_rec, l_def_cvpv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_cov_types_tl_rec,
      lx_oks_cov_types_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oks_cov_types_tl_rec, l_def_cvpv_rec);
    -- Set OUT values
    x_cvpv_rec := l_def_cvpv_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:CVPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    x_cvpv_tbl                     OUT NOCOPY cvpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cvpv_tbl.COUNT > 0) THEN
      i := p_cvpv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_cvpv_rec                     => p_cvpv_tbl(i),
            x_cvpv_rec                     => x_cvpv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_cvpv_tbl.LAST);
        i := p_cvpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:CVPV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    x_cvpv_tbl                     OUT NOCOPY cvpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cvpv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cvpv_tbl                     => p_cvpv_tbl,
        x_cvpv_tbl                     => x_cvpv_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------
  -- lock_row for:OKS_COV_TYPES_B --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvp_rec                      IN cvp_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cvp_rec IN cvp_rec_type) IS
    SELECT *
      FROM OKS_COV_TYPES_B
     WHERE CODE = p_cvp_rec.code
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
      OPEN lock_csr(p_cvp_rec);
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
    ELSE
      IF (l_lock_var.code <> p_cvp_rec.code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.importance_level <> p_cvp_rec.importance_level) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.enabled_flag <> p_cvp_rec.enabled_flag) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.start_date_active <> p_cvp_rec.start_date_active) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.end_date_active <> p_cvp_rec.end_date_active) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.created_by <> p_cvp_rec.created_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.creation_date <> p_cvp_rec.creation_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_updated_by <> p_cvp_rec.last_updated_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_login <> p_cvp_rec.last_update_login) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_date <> p_cvp_rec.last_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute_category <> p_cvp_rec.attribute_category) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute1 <> p_cvp_rec.attribute1) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute2 <> p_cvp_rec.attribute2) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute3 <> p_cvp_rec.attribute3) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute4 <> p_cvp_rec.attribute4) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute5 <> p_cvp_rec.attribute5) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute6 <> p_cvp_rec.attribute6) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute7 <> p_cvp_rec.attribute7) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute8 <> p_cvp_rec.attribute8) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute9 <> p_cvp_rec.attribute9) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute10 <> p_cvp_rec.attribute10) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute11 <> p_cvp_rec.attribute11) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute12 <> p_cvp_rec.attribute12) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute13 <> p_cvp_rec.attribute13) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute14 <> p_cvp_rec.attribute14) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute15 <> p_cvp_rec.attribute15) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKS_COV_TYPES_TL --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_cov_types_tl_rec         IN oks_cov_types_tl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_oks_cov_types_tl_rec IN oks_cov_types_tl_rec_type) IS
    SELECT *
      FROM OKS_COV_TYPES_TL
     WHERE CODE = p_oks_cov_types_tl_rec.code
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
      OPEN lock_csr(p_oks_cov_types_tl_rec);
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
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for: OKS_COV_TYPES_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_rec                     IN cvpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type;
    l_cvp_rec                      cvp_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_cvpv_rec, l_oks_cov_types_tl_rec);
    migrate(p_cvpv_rec, l_cvp_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_cov_types_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cvp_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:CVPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_cvpv_tbl.COUNT > 0) THEN
      i := p_cvpv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_cvpv_rec                     => p_cvpv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_cvpv_tbl.LAST);
        i := p_cvpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:CVPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_cvpv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cvpv_tbl                     => p_cvpv_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- update_row for:OKS_COV_TYPES_B --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvp_rec                      IN cvp_rec_type,
    x_cvp_rec                      OUT NOCOPY cvp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvp_rec                      cvp_rec_type := p_cvp_rec;
    l_def_cvp_rec                  cvp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cvp_rec IN cvp_rec_type,
      x_cvp_rec OUT NOCOPY cvp_rec_type
    ) RETURN VARCHAR2 IS
      l_cvp_rec                      cvp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvp_rec := p_cvp_rec;
      -- Get current database values
      l_cvp_rec := get_rec(p_cvp_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_cvp_rec.code = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.code := l_cvp_rec.code;
        END IF;
        IF (x_cvp_rec.importance_level = OKC_API.G_MISS_NUM)
        THEN
          x_cvp_rec.importance_level := l_cvp_rec.importance_level;
        END IF;
        IF (x_cvp_rec.enabled_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.enabled_flag := l_cvp_rec.enabled_flag;
        END IF;
        IF (x_cvp_rec.start_date_active = OKC_API.G_MISS_DATE)
        THEN
          x_cvp_rec.start_date_active := l_cvp_rec.start_date_active;
        END IF;
        IF (x_cvp_rec.end_date_active = OKC_API.G_MISS_DATE)
        THEN
          x_cvp_rec.end_date_active := l_cvp_rec.end_date_active;
        END IF;
        IF (x_cvp_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_cvp_rec.created_by := l_cvp_rec.created_by;
        END IF;
        IF (x_cvp_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_cvp_rec.creation_date := l_cvp_rec.creation_date;
        END IF;
        IF (x_cvp_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_cvp_rec.last_updated_by := l_cvp_rec.last_updated_by;
        END IF;
        IF (x_cvp_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_cvp_rec.last_update_login := l_cvp_rec.last_update_login;
        END IF;
        IF (x_cvp_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_cvp_rec.last_update_date := l_cvp_rec.last_update_date;
        END IF;
        IF (x_cvp_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute_category := l_cvp_rec.attribute_category;
        END IF;
        IF (x_cvp_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute1 := l_cvp_rec.attribute1;
        END IF;
        IF (x_cvp_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute2 := l_cvp_rec.attribute2;
        END IF;
        IF (x_cvp_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute3 := l_cvp_rec.attribute3;
        END IF;
        IF (x_cvp_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute4 := l_cvp_rec.attribute4;
        END IF;
        IF (x_cvp_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute5 := l_cvp_rec.attribute5;
        END IF;
        IF (x_cvp_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute6 := l_cvp_rec.attribute6;
        END IF;
        IF (x_cvp_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute7 := l_cvp_rec.attribute7;
        END IF;
        IF (x_cvp_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute8 := l_cvp_rec.attribute8;
        END IF;
        IF (x_cvp_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute9 := l_cvp_rec.attribute9;
        END IF;
        IF (x_cvp_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute10 := l_cvp_rec.attribute10;
        END IF;
        IF (x_cvp_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute11 := l_cvp_rec.attribute11;
        END IF;
        IF (x_cvp_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute12 := l_cvp_rec.attribute12;
        END IF;
        IF (x_cvp_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute13 := l_cvp_rec.attribute13;
        END IF;
        IF (x_cvp_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute14 := l_cvp_rec.attribute14;
        END IF;
        IF (x_cvp_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvp_rec.attribute15 := l_cvp_rec.attribute15;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKS_COV_TYPES_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_cvp_rec IN cvp_rec_type,
      x_cvp_rec OUT NOCOPY cvp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvp_rec := p_cvp_rec;
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
      p_cvp_rec,                         -- IN
      l_cvp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cvp_rec, l_def_cvp_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_COV_TYPES_B
    SET IMPORTANCE_LEVEL = l_def_cvp_rec.importance_level,
        ENABLED_FLAG = l_def_cvp_rec.enabled_flag,
        START_DATE_ACTIVE = l_def_cvp_rec.start_date_active,
        END_DATE_ACTIVE = l_def_cvp_rec.end_date_active,
        CREATED_BY = l_def_cvp_rec.created_by,
        CREATION_DATE = l_def_cvp_rec.creation_date,
        LAST_UPDATED_BY = l_def_cvp_rec.last_updated_by,
        LAST_UPDATE_LOGIN = l_def_cvp_rec.last_update_login,
        LAST_UPDATE_DATE = l_def_cvp_rec.last_update_date,
        ATTRIBUTE_CATEGORY = l_def_cvp_rec.attribute_category,
        ATTRIBUTE1 = l_def_cvp_rec.attribute1,
        ATTRIBUTE2 = l_def_cvp_rec.attribute2,
        ATTRIBUTE3 = l_def_cvp_rec.attribute3,
        ATTRIBUTE4 = l_def_cvp_rec.attribute4,
        ATTRIBUTE5 = l_def_cvp_rec.attribute5,
        ATTRIBUTE6 = l_def_cvp_rec.attribute6,
        ATTRIBUTE7 = l_def_cvp_rec.attribute7,
        ATTRIBUTE8 = l_def_cvp_rec.attribute8,
        ATTRIBUTE9 = l_def_cvp_rec.attribute9,
        ATTRIBUTE10 = l_def_cvp_rec.attribute10,
        ATTRIBUTE11 = l_def_cvp_rec.attribute11,
        ATTRIBUTE12 = l_def_cvp_rec.attribute12,
        ATTRIBUTE13 = l_def_cvp_rec.attribute13,
        ATTRIBUTE14 = l_def_cvp_rec.attribute14,
        ATTRIBUTE15 = l_def_cvp_rec.attribute15
    WHERE CODE = l_def_cvp_rec.code;

    x_cvp_rec := l_cvp_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKS_COV_TYPES_TL --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_cov_types_tl_rec         IN oks_cov_types_tl_rec_type,
    x_oks_cov_types_tl_rec         OUT NOCOPY oks_cov_types_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type := p_oks_cov_types_tl_rec;
    l_def_oks_cov_types_tl_rec     oks_cov_types_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oks_cov_types_tl_rec IN oks_cov_types_tl_rec_type,
      x_oks_cov_types_tl_rec OUT NOCOPY oks_cov_types_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_cov_types_tl_rec := p_oks_cov_types_tl_rec;
      -- Get current database values
      l_oks_cov_types_tl_rec := get_rec(p_oks_cov_types_tl_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oks_cov_types_tl_rec.code = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_cov_types_tl_rec.code := l_oks_cov_types_tl_rec.code;
        END IF;
        IF (x_oks_cov_types_tl_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_cov_types_tl_rec.language := l_oks_cov_types_tl_rec.language;
        END IF;
        IF (x_oks_cov_types_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_cov_types_tl_rec.source_lang := l_oks_cov_types_tl_rec.source_lang;
        END IF;
        IF (x_oks_cov_types_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_cov_types_tl_rec.sfwt_flag := l_oks_cov_types_tl_rec.sfwt_flag;
        END IF;
        IF (x_oks_cov_types_tl_rec.meaning = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_cov_types_tl_rec.meaning := l_oks_cov_types_tl_rec.meaning;
        END IF;
        IF (x_oks_cov_types_tl_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_cov_types_tl_rec.description := l_oks_cov_types_tl_rec.description;
        END IF;
        IF (x_oks_cov_types_tl_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oks_cov_types_tl_rec.created_by := l_oks_cov_types_tl_rec.created_by;
        END IF;
        IF (x_oks_cov_types_tl_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_cov_types_tl_rec.creation_date := l_oks_cov_types_tl_rec.creation_date;
        END IF;
        IF (x_oks_cov_types_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oks_cov_types_tl_rec.last_updated_by := l_oks_cov_types_tl_rec.last_updated_by;
        END IF;
        IF (x_oks_cov_types_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oks_cov_types_tl_rec.last_update_login := l_oks_cov_types_tl_rec.last_update_login;
        END IF;
        IF (x_oks_cov_types_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_cov_types_tl_rec.last_update_date := l_oks_cov_types_tl_rec.last_update_date;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKS_COV_TYPES_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_oks_cov_types_tl_rec IN oks_cov_types_tl_rec_type,
      x_oks_cov_types_tl_rec OUT NOCOPY oks_cov_types_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_cov_types_tl_rec := p_oks_cov_types_tl_rec;
      x_oks_cov_types_tl_rec.LANGUAGE := USERENV('LANG');
      x_oks_cov_types_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_oks_cov_types_tl_rec,            -- IN
      l_oks_cov_types_tl_rec);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oks_cov_types_tl_rec, l_def_oks_cov_types_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_COV_TYPES_TL
    SET MEANING = l_def_oks_cov_types_tl_rec.meaning,
        DESCRIPTION = l_def_oks_cov_types_tl_rec.description,
        CREATED_BY = l_def_oks_cov_types_tl_rec.created_by,
        CREATION_DATE = l_def_oks_cov_types_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_oks_cov_types_tl_rec.last_updated_by,
        LAST_UPDATE_LOGIN = l_def_oks_cov_types_tl_rec.last_update_login,
        LAST_UPDATE_DATE = l_def_oks_cov_types_tl_rec.last_update_date
    WHERE CODE = l_def_oks_cov_types_tl_rec.code
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKS_COV_TYPES_TL
    SET SFWT_FLAG = 'Y'
    WHERE CODE = l_def_oks_cov_types_tl_rec.code
      AND SOURCE_LANG <> USERENV('LANG');

    x_oks_cov_types_tl_rec := l_oks_cov_types_tl_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKS_COV_TYPES_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_rec                     IN cvpv_rec_type,
    x_cvpv_rec                     OUT NOCOPY cvpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvpv_rec                     cvpv_rec_type := p_cvpv_rec;
    l_def_cvpv_rec                 cvpv_rec_type;
    l_db_cvpv_rec                  cvpv_rec_type;
    l_cvp_rec                      cvp_rec_type;
    lx_cvp_rec                     cvp_rec_type;
    l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type;
    lx_oks_cov_types_tl_rec        oks_cov_types_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cvpv_rec IN cvpv_rec_type
    ) RETURN cvpv_rec_type IS
      l_cvpv_rec cvpv_rec_type := p_cvpv_rec;
    BEGIN
      l_cvpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cvpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cvpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cvpv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cvpv_rec IN cvpv_rec_type,
      x_cvpv_rec OUT NOCOPY cvpv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvpv_rec := p_cvpv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_cvpv_rec := get_rec(p_cvpv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_cvpv_rec.code = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.code := l_db_cvpv_rec.code;
        END IF;
        IF (x_cvpv_rec.meaning = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.meaning := l_db_cvpv_rec.meaning;
        END IF;
        IF (x_cvpv_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.description := l_db_cvpv_rec.description;
        END IF;
        IF (x_cvpv_rec.importance_level = OKC_API.G_MISS_NUM)
        THEN
          x_cvpv_rec.importance_level := l_db_cvpv_rec.importance_level;
        END IF;
        IF (x_cvpv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.sfwt_flag := l_db_cvpv_rec.sfwt_flag;
        END IF;
        IF (x_cvpv_rec.enabled_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.enabled_flag := l_db_cvpv_rec.enabled_flag;
        END IF;
        IF (x_cvpv_rec.start_date_active = OKC_API.G_MISS_DATE)
        THEN
          x_cvpv_rec.start_date_active := l_db_cvpv_rec.start_date_active;
        END IF;
        IF (x_cvpv_rec.end_date_active = OKC_API.G_MISS_DATE)
        THEN
          x_cvpv_rec.end_date_active := l_db_cvpv_rec.end_date_active;
        END IF;
        IF (x_cvpv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_cvpv_rec.created_by := l_db_cvpv_rec.created_by;
        END IF;
        IF (x_cvpv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_cvpv_rec.creation_date := l_db_cvpv_rec.creation_date;
        END IF;
        IF (x_cvpv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_cvpv_rec.last_updated_by := l_db_cvpv_rec.last_updated_by;
        END IF;
        IF (x_cvpv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_cvpv_rec.last_update_login := l_db_cvpv_rec.last_update_login;
        END IF;
        IF (x_cvpv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_cvpv_rec.last_update_date := l_db_cvpv_rec.last_update_date;
        END IF;
        IF (x_cvpv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute_category := l_db_cvpv_rec.attribute_category;
        END IF;
        IF (x_cvpv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute1 := l_db_cvpv_rec.attribute1;
        END IF;
        IF (x_cvpv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute2 := l_db_cvpv_rec.attribute2;
        END IF;
        IF (x_cvpv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute3 := l_db_cvpv_rec.attribute3;
        END IF;
        IF (x_cvpv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute4 := l_db_cvpv_rec.attribute4;
        END IF;
        IF (x_cvpv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute5 := l_db_cvpv_rec.attribute5;
        END IF;
        IF (x_cvpv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute6 := l_db_cvpv_rec.attribute6;
        END IF;
        IF (x_cvpv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute7 := l_db_cvpv_rec.attribute7;
        END IF;
        IF (x_cvpv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute8 := l_db_cvpv_rec.attribute8;
        END IF;
        IF (x_cvpv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute9 := l_db_cvpv_rec.attribute9;
        END IF;
        IF (x_cvpv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute10 := l_db_cvpv_rec.attribute10;
        END IF;
        IF (x_cvpv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute11 := l_db_cvpv_rec.attribute11;
        END IF;
        IF (x_cvpv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute12 := l_db_cvpv_rec.attribute12;
        END IF;
        IF (x_cvpv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute13 := l_db_cvpv_rec.attribute13;
        END IF;
        IF (x_cvpv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute14 := l_db_cvpv_rec.attribute14;
        END IF;
        IF (x_cvpv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_cvpv_rec.attribute15 := l_db_cvpv_rec.attribute15;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKS_COV_TYPES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_cvpv_rec IN cvpv_rec_type,
      x_cvpv_rec OUT NOCOPY cvpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvpv_rec := p_cvpv_rec;
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
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cvpv_rec,                        -- IN
      x_cvpv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cvpv_rec, l_def_cvpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cvpv_rec := fill_who_columns(l_def_cvpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cvpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cvpv_rec, l_db_cvpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
/*    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_cvpv_rec                     => p_cvpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;*/

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_cvpv_rec, l_cvp_rec);
    migrate(l_def_cvpv_rec, l_oks_cov_types_tl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cvp_rec,
      lx_cvp_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cvp_rec, l_def_cvpv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_cov_types_tl_rec,
      lx_oks_cov_types_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oks_cov_types_tl_rec, l_def_cvpv_rec);
    x_cvpv_rec := l_def_cvpv_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:cvpv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    x_cvpv_tbl                     OUT NOCOPY cvpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cvpv_tbl.COUNT > 0) THEN
      i := p_cvpv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_cvpv_rec                     => p_cvpv_tbl(i),
            x_cvpv_rec                     => x_cvpv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_cvpv_tbl.LAST);
        i := p_cvpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:CVPV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    x_cvpv_tbl                     OUT NOCOPY cvpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cvpv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cvpv_tbl                     => p_cvpv_tbl,
        x_cvpv_tbl                     => x_cvpv_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- delete_row for:OKS_COV_TYPES_B --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvp_rec                      IN cvp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvp_rec                      cvp_rec_type := p_cvp_rec;
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

    DELETE FROM OKS_COV_TYPES_B
     WHERE CODE = p_cvp_rec.code;

    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKS_COV_TYPES_TL --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_cov_types_tl_rec         IN oks_cov_types_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type := p_oks_cov_types_tl_rec;
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

    DELETE FROM OKS_COV_TYPES_TL
     WHERE CODE = p_oks_cov_types_tl_rec.code;

    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKS_COV_TYPES_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_rec                     IN cvpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvpv_rec                     cvpv_rec_type := p_cvpv_rec;
    l_oks_cov_types_tl_rec         oks_cov_types_tl_rec_type;
    l_cvp_rec                      cvp_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_cvpv_rec, l_oks_cov_types_tl_rec);
    migrate(l_cvpv_rec, l_cvp_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_cov_types_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cvp_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_COV_TYPES_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cvpv_tbl.COUNT > 0) THEN
      i := p_cvpv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_cvpv_rec                     => p_cvpv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_cvpv_tbl.LAST);
        i := p_cvpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_COV_TYPES_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cvpv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cvpv_tbl                     => p_cvpv_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate Coverage Types
  ---------------------------------------------------------------------------
PROCEDURE MIGRATE_COVERAGE_TYPES(p_api_version                   IN NUMBER,
                                   p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status                 OUT NOCOPY VARCHAR2,
                                   x_msg_count                     OUT NOCOPY NUMBER,
                                   x_msg_data                      OUT NOCOPY VARCHAR2)

  IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_MIGRATE_COVTYPES';
    l_api_name2                    CONSTANT VARCHAR2(30) := 'V_MIGRATE_COVTYPES_LANG';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    v_code                         FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE ;
    v_exist                        BOOLEAN;
    v_sourcelang_null              BOOLEAN :=FALSE;
    v_source_lang                  VARCHAR2(4);
    v_lang                         VARCHAR2(30);
    l_init_msg_list                VARCHAR2(1):= 'F';
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);
      CURSOR CUR_GET_COV_TYPES IS
         SELECT  F.LANGUAGE , F.SOURCE_LANG,F.LOOKUP_CODE , F.MEANING , F.DESCRIPTION , F.ENABLED_FLAG,
         F.CREATED_BY, F.CREATION_DATE,F.START_DATE_ACTIVE , F.END_DATE_ACTIVE,
         ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,ATTRIBUTE5, ATTRIBUTE6,
         ATTRIBUTE7, ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,
         ATTRIBUTE13, ATTRIBUTE14,ATTRIBUTE15
         FROM FND_LOOKUP_VALUES F
         WHERE F.LOOKUP_TYPE = 'OKSCVETYPE';


    CURSOR CUR_CHECK_EXISTS_B(v_code VARCHAR2) IS
    SELECT 'X' FROM OKS_COV_TYPES_B
    WHERE CODE = v_code ;

     CURSOR CUR_CHECK_EXISTS_TL(v_code VARCHAR2, v_lang VARCHAR2) IS
     SELECT 'X' FROM OKS_COV_TYPES_TL
     WHERE CODE = v_code
     AND LANGUAGE = v_lang ;

     CURSOR CUR_CHECK_SOURCELANG_NULL IS
     SELECT 'X' FROM OKS_COV_TYPES_TL
     WHERE SOURCE_LANG IS NULL;


   BEGIN
--Modified to pass source_lang and SFWT_FLAG for bug 3807465
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

       FOR C1 IN CUR_GET_COV_TYPES
       LOOP
       v_code:= C1.LOOKUP_CODE;
       v_lang:= C1.LANGUAGE;
       v_source_lang:= C1.SOURCE_LANG;
       v_exist:= FALSE ;

       FOR C2 IN CUR_CHECK_EXISTS_B(v_code)
       LOOP
       v_exist:= TRUE;
       END LOOP ;

      IF (v_exist = FALSE) THEN
      INSERT INTO OKS_COV_TYPES_B(CODE,
                                  IMPORTANCE_LEVEL,
                                  ENABLED_FLAG,
                                  START_DATE_ACTIVE,
                                  END_DATE_ACTIVE,
                                  CREATED_BY,
                                  CREATION_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_LOGIN,
                                  LAST_UPDATE_DATE,
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
                                  )
                                  VALUES

                                  (C1.LOOKUP_CODE,
                                   NULL, -- IMPORTANCE_LEVEL
                                   C1.ENABLED_FLAG,
                                   C1.START_DATE_ACTIVE,
                                   C1.END_DATE_ACTIVE,
                                   C1.CREATED_BY,
                                   C1.CREATION_DATE,
                                   1,
                                   0,
                                   SYSDATE,
                                  C1.ATTRIBUTE1,
                                  C1.ATTRIBUTE2,
                                  C1.ATTRIBUTE3,
                                  C1.ATTRIBUTE4,
                                  C1.ATTRIBUTE5,
                                  C1.ATTRIBUTE6,
                                  C1.ATTRIBUTE7,
                                  C1.ATTRIBUTE8,
                                  C1.ATTRIBUTE9,
                                  C1.ATTRIBUTE10,
                                  C1.ATTRIBUTE11,
                                  C1.ATTRIBUTE12,
                                  C1.ATTRIBUTE13,
                                  C1.ATTRIBUTE14,
                                  C1.ATTRIBUTE15
                                   );
       END IF ;
          v_exist:= FALSE;
         FOR C3 IN CUR_CHECK_EXISTS_TL(v_code, v_lang)
         LOOP
         v_exist:= TRUE;
         END LOOP ;

         IF (v_exist = FALSE) THEN
         INSERT INTO OKS_COV_TYPES_TL(CODE,
                                      LANGUAGE,
                                      SOURCE_LANG,
                                      SFWT_FLAG,
                                      MEANING,
                                      DESCRIPTION,
                                      CREATED_BY,
                                      CREATION_DATE,
                                      LAST_UPDATED_BY,
                                      LAST_UPDATE_LOGIN,
                                      LAST_UPDATE_DATE)
                                  VALUES
                                     (C1.LOOKUP_CODE,
                                      C1.LANGUAGE,
                                      C1.SOURCE_LANG,
                                      'N',
                                      C1.MEANING,
                                      C1.DESCRIPTION,
                                      C1.CREATED_BY,
                                      C1.CREATION_DATE,
                                      1,
                                      0,
                                      SYSDATE);
       END IF ;
       END LOOP ;
       --To populate source_lang and sfwt_flag for bug 3807465

       BEGIN
       	  FOR C4 IN CUR_CHECK_SOURCELANG_NULL
      	  LOOP
           	v_sourcelang_null:= TRUE;
      	  END LOOP ;

          IF v_sourcelang_null= TRUE THEN
                UPDATE OKS_COV_TYPES_TL
                SET SOURCE_LANG=userenv('LANG'),SFWT_FLAG='N'
                WHERE SOURCE_LANG  IS NULL;
          END IF;
        EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            ROLLBACK ;
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
            l_api_name2,
            G_PKG_NAME,
            'OKC_API.G_RET_STS_ERROR',
            x_msg_count,
            x_msg_data,
            '_PVT'
             );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK ;
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
            l_api_name2,
            G_PKG_NAME,
            'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count,
            x_msg_data,
            '_PVT'
          );
        WHEN OTHERS THEN
            ROLLBACK ;
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
            l_api_name2,
            G_PKG_NAME,
            'OTHERS',
            x_msg_count,
            x_msg_data,
            '_PVT'
          );
	END;
             x_return_status:= OKC_API.G_RET_STS_SUCCESS;

   EXCEPTION
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
    ROLLBACK ;
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
    ROLLBACK ;
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
      ROLLBACK ;
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


   END MIGRATE_COVERAGE_TYPES;

/* chkrishn old procedure
  ---------------------------------------------------------------------------
  -- PROCEDURE Delete Coverage Types
  ---------------------------------------------------------------------------


    PROCEDURE DELETE_COVERAGE_TYPES( p_api_version                  IN NUMBER,
                                   p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status                 OUT NOCOPY VARCHAR2,
                                   x_msg_count                     OUT NOCOPY NUMBER,
                                   x_msg_data                      OUT NOCOPY VARCHAR2)
  IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(40) := 'V_DELETE_COVEREAGE_TYPES';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    BEGIN
        delete FND_LOOKUP_VALUES
        where  lookup_code in
              (SELECT code FROM oks_cov_types_v)
        and    lookup_type = 'OKSCVETYPE';
              x_return_status:= OKC_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN OTHERS THEN
         NULL;

      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END;
     BEGIN
        delete from FND_LOOKUP_TYPES_TL
        where LOOKUP_TYPE = 'OKSCVETYPE'
        and not exists (SELECT 'x' from FND_LOOKUP_VALUES
                        WHERE lookup_type = 'OKSCVETYPE');
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;

   EXCEPTION
  WHEN OTHERS THEN
         NULL;

      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END;
       BEGIN
        delete from FND_LOOKUP_TYPES
        where LOOKUP_TYPE = 'OKSCVETYPE'
        and not exists (SELECT 'x' from FND_LOOKUP_VALUES
                        WHERE lookup_type = 'OKSCVETYPE');

      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN OTHERS THEN
      NULL;

      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

END ;
END ;
*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Delete Coverage Types
  ---------------------------------------------------------------------------


    PROCEDURE DELETE_COVERAGE_TYPES( p_api_version                  IN NUMBER,
                                   p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status                 OUT NOCOPY VARCHAR2,
                                   x_msg_count                     OUT NOCOPY NUMBER,
                                   x_msg_data                      OUT NOCOPY VARCHAR2)
  IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(40) := 'V_DELETE_COVEREAGE_TYPES';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
--BEGIN
  BEGIN

        update FND_LOOKUP_VALUES
         set END_DATE_ACTIVE = sysdate-1
                 where  lookup_code in
              (SELECT code FROM oks_cov_types_v)
        and    lookup_type = 'OKSCVETYPE';


              x_return_status:= OKC_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN OTHERS THEN
         NULL;

      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END delete_coverage_types;


END;

/
