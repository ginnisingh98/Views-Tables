--------------------------------------------------------
--  DDL for Package Body OKL_PFC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PFC_PVT" AS
/* $Header: OKLSPFCB.pls 115.8 2004/05/25 06:59:52 smoduga noship $ */
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
    DELETE FROM OKL_PRTFL_CNTRCTS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_PRTFL_CNTRCTS_B B
         WHERE B.ID =T.ID
        );

    UPDATE OKL_PRTFL_CNTRCTS_TL T SET(
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_PRTFL_CNTRCTS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_PRTFL_CNTRCTS_TL SUBB, OKL_PRTFL_CNTRCTS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO OKL_PRTFL_CNTRCTS_TL (
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
        FROM OKL_PRTFL_CNTRCTS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_PRTFL_CNTRCTS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PRTFL_CNTRCTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pfcv_rec                     IN pfcv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pfcv_rec_type IS
    CURSOR okl_pfcv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            LINE_LEVEL_YN,
            KHR_ID,
            NAME,
            DESCRIPTION,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
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
      FROM Okl_Prtfl_Cntrcts_V
     WHERE okl_prtfl_cntrcts_v.id = p_id;
    l_okl_pfcv_pk                  okl_pfcv_pk_csr%ROWTYPE;
    l_pfcv_rec                     pfcv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pfcv_pk_csr (p_pfcv_rec.id);
    FETCH okl_pfcv_pk_csr INTO
              l_pfcv_rec.id,
              l_pfcv_rec.object_version_number,
              l_pfcv_rec.sfwt_flag,
              l_pfcv_rec.line_level_yn,
              l_pfcv_rec.khr_id,
              l_pfcv_rec.name,
              l_pfcv_rec.description,
              l_pfcv_rec.request_id,
              l_pfcv_rec.program_application_id,
              l_pfcv_rec.program_id,
              l_pfcv_rec.program_update_date,
              l_pfcv_rec.attribute_category,
              l_pfcv_rec.attribute1,
              l_pfcv_rec.attribute2,
              l_pfcv_rec.attribute3,
              l_pfcv_rec.attribute4,
              l_pfcv_rec.attribute5,
              l_pfcv_rec.attribute6,
              l_pfcv_rec.attribute7,
              l_pfcv_rec.attribute8,
              l_pfcv_rec.attribute9,
              l_pfcv_rec.attribute10,
              l_pfcv_rec.attribute11,
              l_pfcv_rec.attribute12,
              l_pfcv_rec.attribute13,
              l_pfcv_rec.attribute14,
              l_pfcv_rec.attribute15,
              l_pfcv_rec.created_by,
              l_pfcv_rec.creation_date,
              l_pfcv_rec.last_updated_by,
              l_pfcv_rec.last_update_date,
              l_pfcv_rec.last_update_login;
    x_no_data_found := okl_pfcv_pk_csr%NOTFOUND;
    CLOSE okl_pfcv_pk_csr;
    RETURN(l_pfcv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pfcv_rec                     IN pfcv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pfcv_rec_type IS
    l_pfcv_rec                     pfcv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_pfcv_rec := get_rec(p_pfcv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pfcv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pfcv_rec                     IN pfcv_rec_type
  ) RETURN pfcv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pfcv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PRTFL_CNTRCTS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pfc_rec                      IN pfc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pfc_rec_type IS
    CURSOR okl_prtfl_cntrcts_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            LINE_LEVEL_YN,
            KHR_ID,
            OBJECT_VERSION_NUMBER,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
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
      FROM Okl_Prtfl_Cntrcts_B
     WHERE okl_prtfl_cntrcts_b.id = p_id;
    l_okl_prtfl_cntrcts_b_pk       okl_prtfl_cntrcts_b_pk_csr%ROWTYPE;
    l_pfc_rec                      pfc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_prtfl_cntrcts_b_pk_csr (p_pfc_rec.id);
    FETCH okl_prtfl_cntrcts_b_pk_csr INTO
              l_pfc_rec.id,
              l_pfc_rec.line_level_yn,
              l_pfc_rec.khr_id,
              l_pfc_rec.object_version_number,
              l_pfc_rec.request_id,
              l_pfc_rec.program_application_id,
              l_pfc_rec.program_id,
              l_pfc_rec.program_update_date,
              l_pfc_rec.attribute_category,
              l_pfc_rec.attribute1,
              l_pfc_rec.attribute2,
              l_pfc_rec.attribute3,
              l_pfc_rec.attribute4,
              l_pfc_rec.attribute5,
              l_pfc_rec.attribute6,
              l_pfc_rec.attribute7,
              l_pfc_rec.attribute8,
              l_pfc_rec.attribute9,
              l_pfc_rec.attribute10,
              l_pfc_rec.attribute11,
              l_pfc_rec.attribute12,
              l_pfc_rec.attribute13,
              l_pfc_rec.attribute14,
              l_pfc_rec.attribute15,
              l_pfc_rec.created_by,
              l_pfc_rec.creation_date,
              l_pfc_rec.last_updated_by,
              l_pfc_rec.last_update_date,
              l_pfc_rec.last_update_login;
    x_no_data_found := okl_prtfl_cntrcts_b_pk_csr%NOTFOUND;
    CLOSE okl_prtfl_cntrcts_b_pk_csr;
    RETURN(l_pfc_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pfc_rec                      IN pfc_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pfc_rec_type IS
    l_pfc_rec                      pfc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_pfc_rec := get_rec(p_pfc_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pfc_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pfc_rec                      IN pfc_rec_type
  ) RETURN pfc_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pfc_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PRTFL_CNTRCTS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_prtfl_cntrcts_tl_rec     IN okl_prtfl_cntrcts_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_prtfl_cntrcts_tl_rec_type IS
    CURSOR okl_prtfl_cntrcts_tl_pk_csr (p_id       IN NUMBER,
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
      FROM Okl_Prtfl_Cntrcts_Tl
     WHERE okl_prtfl_cntrcts_tl.id = p_id
       AND okl_prtfl_cntrcts_tl.language = p_language;
    l_okl_prtfl_cntrcts_tl_pk      okl_prtfl_cntrcts_tl_pk_csr%ROWTYPE;
    l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_prtfl_cntrcts_tl_pk_csr (p_okl_prtfl_cntrcts_tl_rec.id,
                                      p_okl_prtfl_cntrcts_tl_rec.language);
    FETCH okl_prtfl_cntrcts_tl_pk_csr INTO
              l_okl_prtfl_cntrcts_tl_rec.id,
              l_okl_prtfl_cntrcts_tl_rec.language,
              l_okl_prtfl_cntrcts_tl_rec.source_lang,
              l_okl_prtfl_cntrcts_tl_rec.sfwt_flag,
              l_okl_prtfl_cntrcts_tl_rec.name,
              l_okl_prtfl_cntrcts_tl_rec.description,
              l_okl_prtfl_cntrcts_tl_rec.created_by,
              l_okl_prtfl_cntrcts_tl_rec.creation_date,
              l_okl_prtfl_cntrcts_tl_rec.last_updated_by,
              l_okl_prtfl_cntrcts_tl_rec.last_update_date,
              l_okl_prtfl_cntrcts_tl_rec.last_update_login;
    x_no_data_found := okl_prtfl_cntrcts_tl_pk_csr%NOTFOUND;
    CLOSE okl_prtfl_cntrcts_tl_pk_csr;
    RETURN(l_okl_prtfl_cntrcts_tl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_prtfl_cntrcts_tl_rec     IN okl_prtfl_cntrcts_tl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okl_prtfl_cntrcts_tl_rec_type IS
    l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_okl_prtfl_cntrcts_tl_rec := get_rec(p_okl_prtfl_cntrcts_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okl_prtfl_cntrcts_tl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okl_prtfl_cntrcts_tl_rec     IN okl_prtfl_cntrcts_tl_rec_type
  ) RETURN okl_prtfl_cntrcts_tl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_prtfl_cntrcts_tl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PRTFL_CNTRCTS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pfcv_rec   IN pfcv_rec_type
  ) RETURN pfcv_rec_type IS
    l_pfcv_rec                     pfcv_rec_type := p_pfcv_rec;
  BEGIN
    IF (l_pfcv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_pfcv_rec.id := NULL;
    END IF;
    IF (l_pfcv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_pfcv_rec.object_version_number := NULL;
    END IF;
    IF (l_pfcv_rec.sfwt_flag = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_pfcv_rec.line_level_yn = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.line_level_yn := NULL;
    END IF;
    IF (l_pfcv_rec.khr_id = OKL_API.G_MISS_NUM ) THEN
      l_pfcv_rec.khr_id := NULL;
    END IF;
    IF (l_pfcv_rec.name = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.name := NULL;
    END IF;
    IF (l_pfcv_rec.description = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.description := NULL;
    END IF;
    IF (l_pfcv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_pfcv_rec.request_id := NULL;
    END IF;
    IF (l_pfcv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_pfcv_rec.program_application_id := NULL;
    END IF;
    IF (l_pfcv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_pfcv_rec.program_id := NULL;
    END IF;
    IF (l_pfcv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_pfcv_rec.program_update_date := NULL;
    END IF;
    IF (l_pfcv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute_category := NULL;
    END IF;
    IF (l_pfcv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute1 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute2 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute3 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute4 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute5 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute6 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute7 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute8 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute9 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute10 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute11 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute12 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute13 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute14 := NULL;
    END IF;
    IF (l_pfcv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_pfcv_rec.attribute15 := NULL;
    END IF;
    IF (l_pfcv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_pfcv_rec.created_by := NULL;
    END IF;
    IF (l_pfcv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_pfcv_rec.creation_date := NULL;
    END IF;
    IF (l_pfcv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_pfcv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pfcv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_pfcv_rec.last_update_date := NULL;
    END IF;
    IF (l_pfcv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_pfcv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_pfcv_rec);
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
  -------------------------------------
  -- Validate_Attributes for: KHR_ID --
  -------------------------------------
  PROCEDURE validate_khr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_khr_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_khr_id = OKL_API.G_MISS_NUM OR
        p_khr_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'khr_id');
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
  END validate_khr_id;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_PRTFL_CNTRCTS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_pfcv_rec                     IN pfcv_rec_type
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
    validate_id(x_return_status, p_pfcv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_pfcv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(x_return_status, p_pfcv_rec.sfwt_flag);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- khr_id
    -- ***
    validate_khr_id(x_return_status, p_pfcv_rec.khr_id);
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

  ----------------------------------------
  -- is_unique to check uniqueness of KHR_ID
  ----------------------------------------
  PROCEDURE is_unique (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_pfcv_rec                      IN pfcv_rec_type) IS

    -- Cursor to check whether create or update mode
    CURSOR okl_cre_upd_csr ( p_id IN NUMBER) IS
    SELECT id, khr_id
    FROM   OKL_PRTFL_CNTRCTS_V
    WHERE  id = p_id;

    -- Cursor to get khr_id if a contract exists (create mode)
    CURSOR okl_pfc_cre_csr ( p_khr_id IN NUMBER) IS
    SELECT khr_id
    FROM   OKL_PRTFL_CNTRCTS_V
    WHERE  khr_id = p_khr_id
    AND    id <> NVL(NULL,-999);

    -- Cursor to get khr_id if a contract exists (update mode)
    CURSOR okl_pfc_upd_csr ( p_id IN NUMBER, p_khr_id IN NUMBER) IS
    SELECT khr_id
    FROM   OKL_PRTFL_CNTRCTS_V
    WHERE  khr_id = p_khr_id
    AND    id <> p_id;

    -- Cursor to get the contract number for khr_id
    CURSOR okl_get_k_num_csr  (p_khr_id IN NUMBER) IS
    SELECT contract_number
    FROM   OKL_K_HEADERS_FULL_V
    WHERE  id = p_khr_id;

    l_id NUMBER;
    l_khr_id NUMBER;
    l_contract_number VARCHAR2(200);
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- Check if value passed for id
    IF (p_pfcv_rec.id IS NOT NULL AND p_pfcv_rec.id <> OKC_API.G_MISS_NUM) THEN

      OPEN okl_cre_upd_csr(p_pfcv_rec.id);
      FETCH okl_cre_upd_csr INTO l_id, l_khr_id;

      -- id already exists, so update mode
      IF okl_cre_upd_csr%FOUND THEN

        -- If changing the khr_id and khr_id already exists
        -- for another profile then error
        IF (l_khr_id <> p_pfcv_rec.khr_id)THEN

           OPEN okl_pfc_upd_csr(p_pfcv_rec.id, p_pfcv_rec.khr_id);
           FETCH okl_pfc_upd_csr INTO l_khr_id;

           IF okl_pfc_upd_csr%FOUND THEN

             OPEN okl_get_k_num_csr(l_khr_id);
             FETCH okl_get_k_num_csr INTO l_contract_number;
             CLOSE okl_get_k_num_csr;

             -- A Portfolio Management Strategy profile already exists for
             -- contract CONTRACT_NUMBER, cannot have another profile for the
             -- same contract.
    	       OKL_API.SET_MESSAGE(  p_app_name  		=> 'OKL'
				      	  	              ,p_msg_name		  => 'OKL_AM_PFC_K_EXISTS_ERR'
					    	                  ,p_token1		    => 'CONTRACT_NUMBER'
					   	  	                ,p_token1_value	=> l_contract_number);

      	     -- notify caller of an error
	           l_return_status := OKC_API.G_RET_STS_ERROR;
           END IF;

           CLOSE okl_pfc_upd_csr;
        END IF;

      -- id does not exists, so create mode
      ELSE

        -- if khr_id already exists for some other profile then error
        OPEN okl_pfc_cre_csr(p_pfcv_rec.khr_id);
        FETCH okl_pfc_cre_csr INTO l_khr_id;

        IF okl_pfc_cre_csr%FOUND THEN

          OPEN okl_get_k_num_csr(l_khr_id);
          FETCH okl_get_k_num_csr INTO l_contract_number;
          CLOSE okl_get_k_num_csr;

          -- A Portfolio Management Strategy profile already exists for
          -- contract CONTRACT_NUMBER, cannot have another profile for the
          -- same contract.
 	        OKL_API.SET_MESSAGE( p_app_name  		=> 'OKL'
          			    	  	    ,p_msg_name		  => 'OKL_AM_PFC_K_EXISTS_ERR'
					    	              ,p_token1	    	=> 'CONTRACT_NUMBER'
        					   	  	    ,p_token1_value	=> l_contract_number);
    	    -- notify caller of an error
	        l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;

        CLOSE okl_pfc_cre_csr;
      END IF;

      CLOSE okl_cre_upd_csr;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OTHERS THEN

      IF okl_cre_upd_csr%ISOPEN THEN
         CLOSE okl_cre_upd_csr;
      END IF;
      IF okl_pfc_cre_csr%ISOPEN THEN
         CLOSE okl_pfc_cre_csr;
      END IF;
      IF okl_pfc_upd_csr%ISOPEN THEN
         CLOSE okl_pfc_upd_csr;
      END IF;
      IF okl_get_k_num_csr%ISOPEN THEN
         CLOSE okl_get_k_num_csr;
      END IF;

      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END is_unique;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate Record for:OKL_PRTFL_CNTRCTS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_pfcv_rec IN pfcv_rec_type,
    p_db_pfcv_rec IN pfcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_pfcv_rec IN pfcv_rec_type,
      p_db_pfcv_rec IN pfcv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okl_khrv_pk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_K_Headers_V
       WHERE okl_k_headers_v.id   = p_id;
      l_okl_khrv_pk                  okl_khrv_pk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF ((p_pfcv_rec.KHR_ID IS NOT NULL)
       AND
          (p_pfcv_rec.KHR_ID <> p_db_pfcv_rec.KHR_ID))
      THEN
        OPEN okl_khrv_pk_csr (p_pfcv_rec.KHR_ID);
        FETCH okl_khrv_pk_csr INTO l_okl_khrv_pk;
        l_row_notfound := okl_khrv_pk_csr%NOTFOUND;
        CLOSE okl_khrv_pk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN

    l_return_status := validate_foreign_keys(p_pfcv_rec, p_db_pfcv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- check uniqueness
    is_unique(l_return_status, p_pfcv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN (l_return_status);

   EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => sqlcode
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => sqlerrm);

        --notify caller of an UNEXPECTED error
        x_return_status  := OKL_API.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        RETURN x_return_status;
  END Validate_Record;
  FUNCTION Validate_Record (
    p_pfcv_rec IN pfcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_pfcv_rec                  pfcv_rec_type := get_rec(p_pfcv_rec);
  BEGIN
    l_return_status := Validate_Record(p_pfcv_rec => p_pfcv_rec,
                                       p_db_pfcv_rec => l_db_pfcv_rec);

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN pfcv_rec_type,
    p_to   IN OUT NOCOPY pfc_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.line_level_yn := p_from.line_level_yn;
    p_to.khr_id := p_from.khr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
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
    p_from IN pfc_rec_type,
    p_to   IN OUT NOCOPY pfcv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.line_level_yn := p_from.line_level_yn;
    p_to.khr_id := p_from.khr_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
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
    p_from IN pfcv_rec_type,
    p_to   IN OUT NOCOPY okl_prtfl_cntrcts_tl_rec_type
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
    p_from IN okl_prtfl_cntrcts_tl_rec_type,
    p_to   IN OUT NOCOPY pfcv_rec_type
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
  ------------------------------------------
  -- validate_row for:OKL_PRTFL_CNTRCTS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_rec                     IN pfcv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfcv_rec                     pfcv_rec_type := p_pfcv_rec;
    l_pfc_rec                      pfc_rec_type;
    l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_pfcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pfcv_rec);
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
  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_PRTFL_CNTRCTS_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_tbl                     IN pfcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pfcv_tbl.COUNT > 0) THEN
      i := p_pfcv_tbl.FIRST;
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
            p_pfcv_rec                     => p_pfcv_tbl(i));
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
        EXIT WHEN (i = p_pfcv_tbl.LAST);
        i := p_pfcv_tbl.NEXT(i);
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

  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_PRTFL_CNTRCTS_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_tbl                     IN pfcv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pfcv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pfcv_tbl                     => p_pfcv_tbl,
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
  ----------------------------------------
  -- insert_row for:OKL_PRTFL_CNTRCTS_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfc_rec                      IN pfc_rec_type,
    x_pfc_rec                      OUT NOCOPY pfc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfc_rec                      pfc_rec_type := p_pfc_rec;
    l_def_pfc_rec                  pfc_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_CNTRCTS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_pfc_rec IN pfc_rec_type,
      x_pfc_rec OUT NOCOPY pfc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pfc_rec := p_pfc_rec;
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
      p_pfc_rec,                         -- IN
      l_pfc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PRTFL_CNTRCTS_B(
      id,
      line_level_yn,
      khr_id,
      object_version_number,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
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
      l_pfc_rec.id,
      l_pfc_rec.line_level_yn,
      l_pfc_rec.khr_id,
      l_pfc_rec.object_version_number,
      l_pfc_rec.request_id,
      l_pfc_rec.program_application_id,
      l_pfc_rec.program_id,
      l_pfc_rec.program_update_date,
      l_pfc_rec.attribute_category,
      l_pfc_rec.attribute1,
      l_pfc_rec.attribute2,
      l_pfc_rec.attribute3,
      l_pfc_rec.attribute4,
      l_pfc_rec.attribute5,
      l_pfc_rec.attribute6,
      l_pfc_rec.attribute7,
      l_pfc_rec.attribute8,
      l_pfc_rec.attribute9,
      l_pfc_rec.attribute10,
      l_pfc_rec.attribute11,
      l_pfc_rec.attribute12,
      l_pfc_rec.attribute13,
      l_pfc_rec.attribute14,
      l_pfc_rec.attribute15,
      l_pfc_rec.created_by,
      l_pfc_rec.creation_date,
      l_pfc_rec.last_updated_by,
      l_pfc_rec.last_update_date,
      l_pfc_rec.last_update_login);
    -- Set OUT values
    x_pfc_rec := l_pfc_rec;
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
  -----------------------------------------
  -- insert_row for:OKL_PRTFL_CNTRCTS_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_prtfl_cntrcts_tl_rec     IN okl_prtfl_cntrcts_tl_rec_type,
    x_okl_prtfl_cntrcts_tl_rec     OUT NOCOPY okl_prtfl_cntrcts_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type := p_okl_prtfl_cntrcts_tl_rec;
    l_def_okl_prtfl_cntrcts_tl_rec okl_prtfl_cntrcts_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_CNTRCTS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_prtfl_cntrcts_tl_rec IN okl_prtfl_cntrcts_tl_rec_type,
      x_okl_prtfl_cntrcts_tl_rec OUT NOCOPY okl_prtfl_cntrcts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_prtfl_cntrcts_tl_rec := p_okl_prtfl_cntrcts_tl_rec;
      x_okl_prtfl_cntrcts_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_prtfl_cntrcts_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_prtfl_cntrcts_tl_rec,        -- IN
      l_okl_prtfl_cntrcts_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_prtfl_cntrcts_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_PRTFL_CNTRCTS_TL(
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
        l_okl_prtfl_cntrcts_tl_rec.id,
        l_okl_prtfl_cntrcts_tl_rec.language,
        l_okl_prtfl_cntrcts_tl_rec.source_lang,
        l_okl_prtfl_cntrcts_tl_rec.sfwt_flag,
        l_okl_prtfl_cntrcts_tl_rec.name,
        l_okl_prtfl_cntrcts_tl_rec.description,
        l_okl_prtfl_cntrcts_tl_rec.created_by,
        l_okl_prtfl_cntrcts_tl_rec.creation_date,
        l_okl_prtfl_cntrcts_tl_rec.last_updated_by,
        l_okl_prtfl_cntrcts_tl_rec.last_update_date,
        l_okl_prtfl_cntrcts_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_prtfl_cntrcts_tl_rec := l_okl_prtfl_cntrcts_tl_rec;
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
  -----------------------------------------
  -- insert_row for :OKL_PRTFL_CNTRCTS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_rec                     IN pfcv_rec_type,
    x_pfcv_rec                     OUT NOCOPY pfcv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfcv_rec                     pfcv_rec_type := p_pfcv_rec;
    l_def_pfcv_rec                 pfcv_rec_type;
    l_pfc_rec                      pfc_rec_type;
    lx_pfc_rec                     pfc_rec_type;
    l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type;
    lx_okl_prtfl_cntrcts_tl_rec    okl_prtfl_cntrcts_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pfcv_rec IN pfcv_rec_type
    ) RETURN pfcv_rec_type IS
      l_pfcv_rec pfcv_rec_type := p_pfcv_rec;
    BEGIN
      l_pfcv_rec.CREATION_DATE := SYSDATE;
      l_pfcv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pfcv_rec.LAST_UPDATE_DATE := l_pfcv_rec.CREATION_DATE;
      l_pfcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pfcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pfcv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_CNTRCTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_pfcv_rec IN pfcv_rec_type,
      x_pfcv_rec OUT NOCOPY pfcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pfcv_rec := p_pfcv_rec;
      x_pfcv_rec.OBJECT_VERSION_NUMBER := 1;
      x_pfcv_rec.SFWT_FLAG := 'N';
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
    l_pfcv_rec := null_out_defaults(p_pfcv_rec);
    -- Set primary key value
    l_pfcv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_pfcv_rec,                        -- IN
      l_def_pfcv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pfcv_rec := fill_who_columns(l_def_pfcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pfcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pfcv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_pfcv_rec, l_pfc_rec);
    migrate(l_def_pfcv_rec, l_okl_prtfl_cntrcts_tl_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pfc_rec,
      lx_pfc_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pfc_rec, l_def_pfcv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_prtfl_cntrcts_tl_rec,
      lx_okl_prtfl_cntrcts_tl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_prtfl_cntrcts_tl_rec, l_def_pfcv_rec);
    -- Set OUT values
    x_pfcv_rec := l_def_pfcv_rec;
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
  -- PL/SQL TBL insert_row for:PFCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_tbl                     IN pfcv_tbl_type,
    x_pfcv_tbl                     OUT NOCOPY pfcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pfcv_tbl.COUNT > 0) THEN
      i := p_pfcv_tbl.FIRST;
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
            p_pfcv_rec                     => p_pfcv_tbl(i),
            x_pfcv_rec                     => x_pfcv_tbl(i));
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
        EXIT WHEN (i = p_pfcv_tbl.LAST);
        i := p_pfcv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:PFCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_tbl                     IN pfcv_tbl_type,
    x_pfcv_tbl                     OUT NOCOPY pfcv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pfcv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pfcv_tbl                     => p_pfcv_tbl,
        x_pfcv_tbl                     => x_pfcv_tbl,
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
  --------------------------------------
  -- lock_row for:OKL_PRTFL_CNTRCTS_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfc_rec                      IN pfc_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pfc_rec IN pfc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PRTFL_CNTRCTS_B
     WHERE ID = p_pfc_rec.id
       AND OBJECT_VERSION_NUMBER = p_pfc_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_pfc_rec IN pfc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PRTFL_CNTRCTS_B
     WHERE ID = p_pfc_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_PRTFL_CNTRCTS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_PRTFL_CNTRCTS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pfc_rec);
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
      OPEN lchk_csr(p_pfc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pfc_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pfc_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKL_PRTFL_CNTRCTS_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_prtfl_cntrcts_tl_rec     IN okl_prtfl_cntrcts_tl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_prtfl_cntrcts_tl_rec IN okl_prtfl_cntrcts_tl_rec_type) IS
    SELECT *
      FROM OKL_PRTFL_CNTRCTS_TL
     WHERE ID = p_okl_prtfl_cntrcts_tl_rec.id
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
      OPEN lock_csr(p_okl_prtfl_cntrcts_tl_rec);
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
  ---------------------------------------
  -- lock_row for: OKL_PRTFL_CNTRCTS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_rec                     IN pfcv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfc_rec                      pfc_rec_type;
    l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type;
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
    migrate(p_pfcv_rec, l_pfc_rec);
    migrate(p_pfcv_rec, l_okl_prtfl_cntrcts_tl_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pfc_rec
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
      l_okl_prtfl_cntrcts_tl_rec
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
  -- PL/SQL TBL lock_row for:PFCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_tbl                     IN pfcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_pfcv_tbl.COUNT > 0) THEN
      i := p_pfcv_tbl.FIRST;
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
            p_pfcv_rec                     => p_pfcv_tbl(i));
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
        EXIT WHEN (i = p_pfcv_tbl.LAST);
        i := p_pfcv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:PFCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_tbl                     IN pfcv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_pfcv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pfcv_tbl                     => p_pfcv_tbl,
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
  ----------------------------------------
  -- update_row for:OKL_PRTFL_CNTRCTS_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfc_rec                      IN pfc_rec_type,
    x_pfc_rec                      OUT NOCOPY pfc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfc_rec                      pfc_rec_type := p_pfc_rec;
    l_def_pfc_rec                  pfc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pfc_rec IN pfc_rec_type,
      x_pfc_rec OUT NOCOPY pfc_rec_type
    ) RETURN VARCHAR2 IS
      l_pfc_rec                      pfc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pfc_rec := p_pfc_rec;
      -- Get current database values
      l_pfc_rec := get_rec(p_pfc_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_pfc_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_pfc_rec.id := l_pfc_rec.id;
        END IF;
        IF (x_pfc_rec.line_level_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.line_level_yn := l_pfc_rec.line_level_yn;
        END IF;
        IF (x_pfc_rec.khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfc_rec.khr_id := l_pfc_rec.khr_id;
        END IF;
        IF (x_pfc_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_pfc_rec.object_version_number := l_pfc_rec.object_version_number;
        END IF;
        IF (x_pfc_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfc_rec.request_id := l_pfc_rec.request_id;
        END IF;
        IF (x_pfc_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfc_rec.program_application_id := l_pfc_rec.program_application_id;
        END IF;
        IF (x_pfc_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfc_rec.program_id := l_pfc_rec.program_id;
        END IF;
        IF (x_pfc_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pfc_rec.program_update_date := l_pfc_rec.program_update_date;
        END IF;
        IF (x_pfc_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute_category := l_pfc_rec.attribute_category;
        END IF;
        IF (x_pfc_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute1 := l_pfc_rec.attribute1;
        END IF;
        IF (x_pfc_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute2 := l_pfc_rec.attribute2;
        END IF;
        IF (x_pfc_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute3 := l_pfc_rec.attribute3;
        END IF;
        IF (x_pfc_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute4 := l_pfc_rec.attribute4;
        END IF;
        IF (x_pfc_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute5 := l_pfc_rec.attribute5;
        END IF;
        IF (x_pfc_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute6 := l_pfc_rec.attribute6;
        END IF;
        IF (x_pfc_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute7 := l_pfc_rec.attribute7;
        END IF;
        IF (x_pfc_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute8 := l_pfc_rec.attribute8;
        END IF;
        IF (x_pfc_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute9 := l_pfc_rec.attribute9;
        END IF;
        IF (x_pfc_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute10 := l_pfc_rec.attribute10;
        END IF;
        IF (x_pfc_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute11 := l_pfc_rec.attribute11;
        END IF;
        IF (x_pfc_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute12 := l_pfc_rec.attribute12;
        END IF;
        IF (x_pfc_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute13 := l_pfc_rec.attribute13;
        END IF;
        IF (x_pfc_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute14 := l_pfc_rec.attribute14;
        END IF;
        IF (x_pfc_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfc_rec.attribute15 := l_pfc_rec.attribute15;
        END IF;
        IF (x_pfc_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_pfc_rec.created_by := l_pfc_rec.created_by;
        END IF;
        IF (x_pfc_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_pfc_rec.creation_date := l_pfc_rec.creation_date;
        END IF;
        IF (x_pfc_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_pfc_rec.last_updated_by := l_pfc_rec.last_updated_by;
        END IF;
        IF (x_pfc_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pfc_rec.last_update_date := l_pfc_rec.last_update_date;
        END IF;
        IF (x_pfc_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_pfc_rec.last_update_login := l_pfc_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_CNTRCTS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_pfc_rec IN pfc_rec_type,
      x_pfc_rec OUT NOCOPY pfc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pfc_rec := p_pfc_rec;
      x_pfc_rec.OBJECT_VERSION_NUMBER := p_pfc_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_pfc_rec,                         -- IN
      l_pfc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pfc_rec, l_def_pfc_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_PRTFL_CNTRCTS_B
    SET LINE_LEVEL_YN = l_def_pfc_rec.line_level_yn,
        KHR_ID = l_def_pfc_rec.khr_id,
        OBJECT_VERSION_NUMBER = l_def_pfc_rec.object_version_number,
        REQUEST_ID = l_def_pfc_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_pfc_rec.program_application_id,
        PROGRAM_ID = l_def_pfc_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_pfc_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_pfc_rec.attribute_category,
        ATTRIBUTE1 = l_def_pfc_rec.attribute1,
        ATTRIBUTE2 = l_def_pfc_rec.attribute2,
        ATTRIBUTE3 = l_def_pfc_rec.attribute3,
        ATTRIBUTE4 = l_def_pfc_rec.attribute4,
        ATTRIBUTE5 = l_def_pfc_rec.attribute5,
        ATTRIBUTE6 = l_def_pfc_rec.attribute6,
        ATTRIBUTE7 = l_def_pfc_rec.attribute7,
        ATTRIBUTE8 = l_def_pfc_rec.attribute8,
        ATTRIBUTE9 = l_def_pfc_rec.attribute9,
        ATTRIBUTE10 = l_def_pfc_rec.attribute10,
        ATTRIBUTE11 = l_def_pfc_rec.attribute11,
        ATTRIBUTE12 = l_def_pfc_rec.attribute12,
        ATTRIBUTE13 = l_def_pfc_rec.attribute13,
        ATTRIBUTE14 = l_def_pfc_rec.attribute14,
        ATTRIBUTE15 = l_def_pfc_rec.attribute15,
        CREATED_BY = l_def_pfc_rec.created_by,
        CREATION_DATE = l_def_pfc_rec.creation_date,
        LAST_UPDATED_BY = l_def_pfc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pfc_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pfc_rec.last_update_login
    WHERE ID = l_def_pfc_rec.id;

    x_pfc_rec := l_pfc_rec;
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
  -----------------------------------------
  -- update_row for:OKL_PRTFL_CNTRCTS_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_prtfl_cntrcts_tl_rec     IN okl_prtfl_cntrcts_tl_rec_type,
    x_okl_prtfl_cntrcts_tl_rec     OUT NOCOPY okl_prtfl_cntrcts_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type := p_okl_prtfl_cntrcts_tl_rec;
    l_def_okl_prtfl_cntrcts_tl_rec okl_prtfl_cntrcts_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_prtfl_cntrcts_tl_rec IN okl_prtfl_cntrcts_tl_rec_type,
      x_okl_prtfl_cntrcts_tl_rec OUT NOCOPY okl_prtfl_cntrcts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_prtfl_cntrcts_tl_rec := p_okl_prtfl_cntrcts_tl_rec;
      -- Get current database values
      l_okl_prtfl_cntrcts_tl_rec := get_rec(p_okl_prtfl_cntrcts_tl_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_okl_prtfl_cntrcts_tl_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.id := l_okl_prtfl_cntrcts_tl_rec.id;
        END IF;
        IF (x_okl_prtfl_cntrcts_tl_rec.language = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.language := l_okl_prtfl_cntrcts_tl_rec.language;
        END IF;
        IF (x_okl_prtfl_cntrcts_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.source_lang := l_okl_prtfl_cntrcts_tl_rec.source_lang;
        END IF;
        IF (x_okl_prtfl_cntrcts_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.sfwt_flag := l_okl_prtfl_cntrcts_tl_rec.sfwt_flag;
        END IF;
        IF (x_okl_prtfl_cntrcts_tl_rec.name = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.name := l_okl_prtfl_cntrcts_tl_rec.name;
        END IF;
        IF (x_okl_prtfl_cntrcts_tl_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.description := l_okl_prtfl_cntrcts_tl_rec.description;
        END IF;
        IF (x_okl_prtfl_cntrcts_tl_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.created_by := l_okl_prtfl_cntrcts_tl_rec.created_by;
        END IF;
        IF (x_okl_prtfl_cntrcts_tl_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.creation_date := l_okl_prtfl_cntrcts_tl_rec.creation_date;
        END IF;
        IF (x_okl_prtfl_cntrcts_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.last_updated_by := l_okl_prtfl_cntrcts_tl_rec.last_updated_by;
        END IF;
        IF (x_okl_prtfl_cntrcts_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.last_update_date := l_okl_prtfl_cntrcts_tl_rec.last_update_date;
        END IF;
        IF (x_okl_prtfl_cntrcts_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_okl_prtfl_cntrcts_tl_rec.last_update_login := l_okl_prtfl_cntrcts_tl_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_CNTRCTS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_prtfl_cntrcts_tl_rec IN okl_prtfl_cntrcts_tl_rec_type,
      x_okl_prtfl_cntrcts_tl_rec OUT NOCOPY okl_prtfl_cntrcts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_prtfl_cntrcts_tl_rec := p_okl_prtfl_cntrcts_tl_rec;
      x_okl_prtfl_cntrcts_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_prtfl_cntrcts_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_prtfl_cntrcts_tl_rec,        -- IN
      l_okl_prtfl_cntrcts_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_prtfl_cntrcts_tl_rec, l_def_okl_prtfl_cntrcts_tl_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_PRTFL_CNTRCTS_TL
    SET NAME = l_def_okl_prtfl_cntrcts_tl_rec.name,
        DESCRIPTION = l_def_okl_prtfl_cntrcts_tl_rec.description,
        SOURCE_LANG = l_def_okl_prtfl_cntrcts_tl_rec.source_lang, --Fix for bug 3637102
        CREATED_BY = l_def_okl_prtfl_cntrcts_tl_rec.created_by,
        CREATION_DATE = l_def_okl_prtfl_cntrcts_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_prtfl_cntrcts_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_prtfl_cntrcts_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_prtfl_cntrcts_tl_rec.last_update_login
    WHERE ID = l_def_okl_prtfl_cntrcts_tl_rec.id
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE); --Fix for 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKL_PRTFL_CNTRCTS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_prtfl_cntrcts_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_prtfl_cntrcts_tl_rec := l_okl_prtfl_cntrcts_tl_rec;
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
  -- update_row for:OKL_PRTFL_CNTRCTS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_rec                     IN pfcv_rec_type,
    x_pfcv_rec                     OUT NOCOPY pfcv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfcv_rec                     pfcv_rec_type := p_pfcv_rec;
    l_def_pfcv_rec                 pfcv_rec_type;
    l_db_pfcv_rec                  pfcv_rec_type;
    l_pfc_rec                      pfc_rec_type;
    lx_pfc_rec                     pfc_rec_type;
    l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type;
    lx_okl_prtfl_cntrcts_tl_rec    okl_prtfl_cntrcts_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pfcv_rec IN pfcv_rec_type
    ) RETURN pfcv_rec_type IS
      l_pfcv_rec pfcv_rec_type := p_pfcv_rec;
    BEGIN
      l_pfcv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pfcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pfcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pfcv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pfcv_rec IN pfcv_rec_type,
      x_pfcv_rec OUT NOCOPY pfcv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pfcv_rec := p_pfcv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_pfcv_rec := get_rec(p_pfcv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_pfcv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_pfcv_rec.id := l_db_pfcv_rec.id;
        END IF;
        IF (x_pfcv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.sfwt_flag := l_db_pfcv_rec.sfwt_flag;
        END IF;
        IF (x_pfcv_rec.line_level_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.line_level_yn := l_db_pfcv_rec.line_level_yn;
        END IF;
-- Added for object version compatibility for now
        IF (x_pfcv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_pfcv_rec.object_version_number := l_db_pfcv_rec.object_version_number;
        END IF;

        IF (x_pfcv_rec.khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfcv_rec.khr_id := l_db_pfcv_rec.khr_id;
        END IF;
        IF (x_pfcv_rec.name = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.name := l_db_pfcv_rec.name;
        END IF;
        IF (x_pfcv_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.description := l_db_pfcv_rec.description;
        END IF;
        IF (x_pfcv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfcv_rec.request_id := l_db_pfcv_rec.request_id;
        END IF;
        IF (x_pfcv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfcv_rec.program_application_id := l_db_pfcv_rec.program_application_id;
        END IF;
        IF (x_pfcv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfcv_rec.program_id := l_db_pfcv_rec.program_id;
        END IF;
        IF (x_pfcv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pfcv_rec.program_update_date := l_db_pfcv_rec.program_update_date;
        END IF;
        IF (x_pfcv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute_category := l_db_pfcv_rec.attribute_category;
        END IF;
        IF (x_pfcv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute1 := l_db_pfcv_rec.attribute1;
        END IF;
        IF (x_pfcv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute2 := l_db_pfcv_rec.attribute2;
        END IF;
        IF (x_pfcv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute3 := l_db_pfcv_rec.attribute3;
        END IF;
        IF (x_pfcv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute4 := l_db_pfcv_rec.attribute4;
        END IF;
        IF (x_pfcv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute5 := l_db_pfcv_rec.attribute5;
        END IF;
        IF (x_pfcv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute6 := l_db_pfcv_rec.attribute6;
        END IF;
        IF (x_pfcv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute7 := l_db_pfcv_rec.attribute7;
        END IF;
        IF (x_pfcv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute8 := l_db_pfcv_rec.attribute8;
        END IF;
        IF (x_pfcv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute9 := l_db_pfcv_rec.attribute9;
        END IF;
        IF (x_pfcv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute10 := l_db_pfcv_rec.attribute10;
        END IF;
        IF (x_pfcv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute11 := l_db_pfcv_rec.attribute11;
        END IF;
        IF (x_pfcv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute12 := l_db_pfcv_rec.attribute12;
        END IF;
        IF (x_pfcv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute13 := l_db_pfcv_rec.attribute13;
        END IF;
        IF (x_pfcv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute14 := l_db_pfcv_rec.attribute14;
        END IF;
        IF (x_pfcv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfcv_rec.attribute15 := l_db_pfcv_rec.attribute15;
        END IF;
        IF (x_pfcv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_pfcv_rec.created_by := l_db_pfcv_rec.created_by;
        END IF;
        IF (x_pfcv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_pfcv_rec.creation_date := l_db_pfcv_rec.creation_date;
        END IF;
        IF (x_pfcv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_pfcv_rec.last_updated_by := l_db_pfcv_rec.last_updated_by;
        END IF;
        IF (x_pfcv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pfcv_rec.last_update_date := l_db_pfcv_rec.last_update_date;
        END IF;
        IF (x_pfcv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_pfcv_rec.last_update_login := l_db_pfcv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_CNTRCTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_pfcv_rec IN pfcv_rec_type,
      x_pfcv_rec OUT NOCOPY pfcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pfcv_rec := p_pfcv_rec;
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
      p_pfcv_rec,                        -- IN
      x_pfcv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pfcv_rec, l_def_pfcv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pfcv_rec := fill_who_columns(l_def_pfcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pfcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pfcv_rec, l_db_pfcv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

/* -- Removed for object version compatibility for now
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_pfcv_rec                     => p_pfcv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_pfcv_rec, l_pfc_rec);
    migrate(l_def_pfcv_rec, l_okl_prtfl_cntrcts_tl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pfc_rec,
      lx_pfc_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pfc_rec, l_def_pfcv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_prtfl_cntrcts_tl_rec,
      lx_okl_prtfl_cntrcts_tl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_prtfl_cntrcts_tl_rec, l_def_pfcv_rec);
    x_pfcv_rec := l_def_pfcv_rec;
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
  -- PL/SQL TBL update_row for:pfcv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_tbl                     IN pfcv_tbl_type,
    x_pfcv_tbl                     OUT NOCOPY pfcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pfcv_tbl.COUNT > 0) THEN
      i := p_pfcv_tbl.FIRST;
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
            p_pfcv_rec                     => p_pfcv_tbl(i),
            x_pfcv_rec                     => x_pfcv_tbl(i));
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
        EXIT WHEN (i = p_pfcv_tbl.LAST);
        i := p_pfcv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:PFCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_tbl                     IN pfcv_tbl_type,
    x_pfcv_tbl                     OUT NOCOPY pfcv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pfcv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pfcv_tbl                     => p_pfcv_tbl,
        x_pfcv_tbl                     => x_pfcv_tbl,
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
  ----------------------------------------
  -- delete_row for:OKL_PRTFL_CNTRCTS_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfc_rec                      IN pfc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfc_rec                      pfc_rec_type := p_pfc_rec;
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

    DELETE FROM OKL_PRTFL_CNTRCTS_B
     WHERE ID = p_pfc_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKL_PRTFL_CNTRCTS_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_prtfl_cntrcts_tl_rec     IN okl_prtfl_cntrcts_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type := p_okl_prtfl_cntrcts_tl_rec;
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

    DELETE FROM OKL_PRTFL_CNTRCTS_TL
     WHERE ID = p_okl_prtfl_cntrcts_tl_rec.id;

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
  ----------------------------------------
  -- delete_row for:OKL_PRTFL_CNTRCTS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_rec                     IN pfcv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfcv_rec                     pfcv_rec_type := p_pfcv_rec;
    l_okl_prtfl_cntrcts_tl_rec     okl_prtfl_cntrcts_tl_rec_type;
    l_pfc_rec                      pfc_rec_type;
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
    migrate(l_pfcv_rec, l_okl_prtfl_cntrcts_tl_rec);
    migrate(l_pfcv_rec, l_pfc_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_prtfl_cntrcts_tl_rec
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
      l_pfc_rec
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
  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_PRTFL_CNTRCTS_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_tbl                     IN pfcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pfcv_tbl.COUNT > 0) THEN
      i := p_pfcv_tbl.FIRST;
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
            p_pfcv_rec                     => p_pfcv_tbl(i));
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
        EXIT WHEN (i = p_pfcv_tbl.LAST);
        i := p_pfcv_tbl.NEXT(i);
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

  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_PRTFL_CNTRCTS_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfcv_tbl                     IN pfcv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pfcv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pfcv_tbl                     => p_pfcv_tbl,
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

END OKL_PFC_PVT;

/
