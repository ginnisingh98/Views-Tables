--------------------------------------------------------
--  DDL for Package Body OKC_HST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_HST_PVT" AS
/* $Header: OKCSHSTB.pls 120.3.12010000.2 2009/05/19 09:37:48 vgujarat ship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
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
  --mmadhavi
  /* Commenting delete and update for bug 3723874 */
  /*
    DELETE FROM OKC_K_HISTORY_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_K_HISTORY_B B
         WHERE B.ID =T.ID
        );

    UPDATE OKC_K_HISTORY_TL T SET(
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKC_K_HISTORY_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_K_HISTORY_TL SUBB, OKC_K_HISTORY_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
              ));
   */
   /* Modifying Insert as per performance guidelines given in bug 3723874 */
    INSERT /*+ append parallel(tt) */ INTO OKC_K_HISTORY_TL tt (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        COMMENTS,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      select /*+ parallel(v) parallel(t) use_nl(t)  */ v.* from
      ( SELECT /*+ no_merge ordered parallel(b) */
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_K_HISTORY_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
        ) v , OKC_K_HISTORY_TL t
        WHERE t.ID(+) = v.ID
        AND t.LANGUAGE(+) = v.LANGUAGE_CODE
	AND t.id IS NULL;

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_HISTORY_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_hstv_rec                     IN hstv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN hstv_rec_type IS
    CURSOR okc_hstv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CHR_ID,
            CLE_ID,
            CONTRACT_VERSION,
            OBJECT_VERSION_NUMBER,
            OPN_CODE,
            STS_CODE_FROM,
            STS_CODE_TO,
            REASON_CODE,
            TRN_CODE,
            MANUAL_YN,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID
      FROM Okc_K_History_V
     WHERE okc_k_history_v.id   = p_id;
    l_okc_hstv_pk                  okc_hstv_pk_csr%ROWTYPE;
    l_hstv_rec                     hstv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_hstv_pk_csr (p_hstv_rec.id);
    FETCH okc_hstv_pk_csr INTO
              l_hstv_rec.id,
              l_hstv_rec.chr_id,
              l_hstv_rec.cle_id,
              l_hstv_rec.contract_version,
              l_hstv_rec.object_version_number,
              l_hstv_rec.opn_code,
              l_hstv_rec.sts_code_from,
              l_hstv_rec.sts_code_to,
              l_hstv_rec.reason_code,
              l_hstv_rec.trn_code,
              l_hstv_rec.manual_yn,
              l_hstv_rec.comments,
              l_hstv_rec.created_by,
              l_hstv_rec.creation_date,
              l_hstv_rec.last_updated_by,
              l_hstv_rec.last_update_date,
              l_hstv_rec.last_update_login,
              l_hstv_rec.program_application_id,
              l_hstv_rec.program_id,
              l_hstv_rec.program_update_date,
              l_hstv_rec.request_id;
    x_no_data_found := okc_hstv_pk_csr%NOTFOUND;
    CLOSE okc_hstv_pk_csr;
    RETURN(l_hstv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_hstv_rec                     IN hstv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN hstv_rec_type IS
    l_hstv_rec                     hstv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_hstv_rec := get_rec(p_hstv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_hstv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_hstv_rec                     IN hstv_rec_type
  ) RETURN hstv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_hstv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_HISTORY_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_hst_rec                      IN hst_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN hst_rec_type IS
    CURSOR okc_k_history_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CHR_ID,
            CLE_ID,
            CONTRACT_VERSION,
            STS_CODE_FROM,
            OPN_CODE,
            STS_CODE_TO,
            REASON_CODE,
            TRN_CODE,
            MANUAL_YN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID
      FROM Okc_K_History_B
     WHERE okc_k_history_b.id   = p_id;
    l_okc_k_history_pk             okc_k_history_pk_csr%ROWTYPE;
    l_hst_rec                      hst_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_k_history_pk_csr (p_hst_rec.id);
    FETCH okc_k_history_pk_csr INTO
              l_hst_rec.id,
              l_hst_rec.chr_id,
              l_hst_rec.cle_id,
              l_hst_rec.contract_version,
              l_hst_rec.sts_code_from,
              l_hst_rec.opn_code,
              l_hst_rec.sts_code_to,
              l_hst_rec.reason_code,
              l_hst_rec.trn_code,
              l_hst_rec.manual_yn,
              l_hst_rec.created_by,
              l_hst_rec.creation_date,
              l_hst_rec.last_updated_by,
              l_hst_rec.last_update_date,
              l_hst_rec.object_version_number,
              l_hst_rec.last_update_login,
              l_hst_rec.program_application_id,
              l_hst_rec.program_id,
              l_hst_rec.program_update_date,
              l_hst_rec.request_id;
    x_no_data_found := okc_k_history_pk_csr%NOTFOUND;
    CLOSE okc_k_history_pk_csr;
    RETURN(l_hst_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_hst_rec                      IN hst_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN hst_rec_type IS
    l_hst_rec                      hst_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_hst_rec := get_rec(p_hst_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_hst_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_hst_rec                      IN hst_rec_type
  ) RETURN hst_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_hst_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_HISTORY_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_k_history_tl_rec         IN okc_k_history_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_k_history_tl_rec_type IS
    CURSOR okc_k_history_tl_pk_csr (p_id       IN NUMBER,
                                    p_language IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_History_Tl
     WHERE okc_k_history_tl.id  = p_id
       AND okc_k_history_tl.language = p_language;
    l_okc_k_history_tl_pk          okc_k_history_tl_pk_csr%ROWTYPE;
    l_okc_k_history_tl_rec         okc_k_history_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_k_history_tl_pk_csr (p_okc_k_history_tl_rec.id,
                                  p_okc_k_history_tl_rec.language);
    FETCH okc_k_history_tl_pk_csr INTO
              l_okc_k_history_tl_rec.id,
              l_okc_k_history_tl_rec.language,
              l_okc_k_history_tl_rec.source_lang,
              l_okc_k_history_tl_rec.comments,
              l_okc_k_history_tl_rec.created_by,
              l_okc_k_history_tl_rec.creation_date,
              l_okc_k_history_tl_rec.last_updated_by,
              l_okc_k_history_tl_rec.last_update_date,
              l_okc_k_history_tl_rec.last_update_login;
    x_no_data_found := okc_k_history_tl_pk_csr%NOTFOUND;
    CLOSE okc_k_history_tl_pk_csr;
    RETURN(l_okc_k_history_tl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_k_history_tl_rec         IN okc_k_history_tl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okc_k_history_tl_rec_type IS
    l_okc_k_history_tl_rec         okc_k_history_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_history_tl_rec := get_rec(p_okc_k_history_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okc_k_history_tl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okc_k_history_tl_rec         IN okc_k_history_tl_rec_type
  ) RETURN okc_k_history_tl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_k_history_tl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_HISTORY_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_hstv_rec   IN hstv_rec_type
  ) RETURN hstv_rec_type IS
    l_hstv_rec                     hstv_rec_type := p_hstv_rec;
  BEGIN
    IF (l_hstv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_hstv_rec.id := NULL;
    END IF;
    IF (l_hstv_rec.chr_id = OKC_API.G_MISS_NUM ) THEN
      l_hstv_rec.chr_id := NULL;
    END IF;
    IF (l_hstv_rec.cle_id = OKC_API.G_MISS_NUM ) THEN
      l_hstv_rec.cle_id := NULL;
    END IF;
    IF (l_hstv_rec.contract_version = OKC_API.G_MISS_CHAR ) THEN
      l_hstv_rec.contract_version := NULL;
    END IF;
    IF (l_hstv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_hstv_rec.object_version_number := NULL;
    END IF;
    IF (l_hstv_rec.opn_code = OKC_API.G_MISS_CHAR ) THEN
      l_hstv_rec.opn_code := NULL;
    END IF;
    IF (l_hstv_rec.sts_code_from = OKC_API.G_MISS_CHAR ) THEN
      l_hstv_rec.sts_code_from := NULL;
    END IF;
    IF (l_hstv_rec.sts_code_to = OKC_API.G_MISS_CHAR ) THEN
      l_hstv_rec.sts_code_to := NULL;
    END IF;
    IF (l_hstv_rec.reason_code = OKC_API.G_MISS_CHAR ) THEN
      l_hstv_rec.reason_code := NULL;
    END IF;
    IF (l_hstv_rec.trn_code = OKC_API.G_MISS_CHAR ) THEN
      l_hstv_rec.trn_code := NULL;
    END IF;
    IF (l_hstv_rec.manual_yn = OKC_API.G_MISS_CHAR ) THEN
      l_hstv_rec.manual_yn := NULL;
    END IF;
    IF (l_hstv_rec.comments = OKC_API.G_MISS_CHAR ) THEN
      l_hstv_rec.comments := NULL;
    END IF;
    IF (l_hstv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_hstv_rec.created_by := NULL;
    END IF;
    IF (l_hstv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_hstv_rec.creation_date := NULL;
    END IF;
    IF (l_hstv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_hstv_rec.last_updated_by := NULL;
    END IF;
    IF (l_hstv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_hstv_rec.last_update_date := NULL;
    END IF;
    IF (l_hstv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_hstv_rec.last_update_login := NULL;
    END IF;
    IF (l_hstv_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_hstv_rec.program_application_id := NULL;
    END IF;
    IF (l_hstv_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_hstv_rec.program_id := NULL;
    END IF;
    IF (l_hstv_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_hstv_rec.program_update_date := NULL;
    END IF;
    IF (l_hstv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_hstv_rec.request_id := NULL;
    END IF;
    RETURN(l_hstv_rec);
  END null_out_defaults;

  -------------------------------------
  -- Validate_Attributes for: CHR_ID --
  -------------------------------------
  PROCEDURE validate_chr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_chr_id = OKC_API.G_MISS_NUM OR
        p_chr_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'chr_id');
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
  END validate_chr_id;
  -----------------------------------------------
  -- Validate_Attributes for: CONTRACT_VERSION --
  -----------------------------------------------
  PROCEDURE validate_contract_version(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_contract_version             IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_contract_version = OKC_API.G_MISS_CHAR OR
        p_contract_version IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'contract_version');
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
  END validate_contract_version;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number = OKC_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
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
  END validate_object_version_number;
  ---------------------------------------
  -- Validate_Attributes for: OPN_CODE --
  ---------------------------------------
  PROCEDURE validate_opn_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_opn_code                     IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_opn_code = OKC_API.G_MISS_CHAR OR
        p_opn_code IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'opn_code');
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
  END validate_opn_code;
  ------------------------------------------
  -- Validate_Attributes for: REASON_CODE --
  ------------------------------------------
  PROCEDURE validate_reason_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_reason_code                  IN VARCHAR2) IS

-- Bug 4622645
CURSOR csr_reason_code IS
SELECT lookup_code
  FROM fnd_lookups
 WHERE lookup_type='OKC_STS_CHG_REASON'
   AND enabled_flag='Y'
   AND SYSDATE BETWEEN NVL(start_date_active,SYSDATE) AND NVL(end_date_active,SYSDATE+1)
   AND lookup_code = p_reason_code
UNION ALL
SELECT lookup_code
  FROM fnd_lookups
 WHERE lookup_type='OKS_CANCEL_REASON'
   AND enabled_flag='Y'
   AND SYSDATE BETWEEN NVL(start_date_active,SYSDATE) AND NVL(end_date_active,SYSDATE+1)
   AND lookup_code = p_reason_code;

l_lookup_code    fnd_lookups.lookup_code%TYPE;

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

/*added condition p_reason_code <> 'NFC' for bug8526765,
validation to be skipped for reason code 'NFC' as it is
used only during automatic cancellation of contract */

    -- enforce foreign key if data exists
    If (p_reason_code <> OKC_API.G_MISS_CHAR and
	   p_reason_code IS NOT NULL AND p_reason_code <> 'NFC')
    Then
      -- Check if the value is a valid code from lookup table
	 /*
      x_return_status := OKC_UTIL.check_lookup_code('OKC_STS_CHG_REASON',
								      p_reason_code);
      */
	 -- bug 4622645
      OPEN csr_reason_code;
	   FETCH csr_reason_code INTO l_lookup_code;
	     IF csr_reason_code%NOTFOUND THEN
		   x_return_status := OKC_API.G_RET_STS_ERROR;
		END IF; -- not a valid code
	 CLOSE csr_reason_code;


      If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
	    --set error message in message stack
	    OKC_API.SET_MESSAGE(
			p_app_name	=> G_APP_NAME,
			p_msg_name	=> G_INVALID_VALUE,
			p_token1		=> G_COL_NAME_TOKEN,
			p_token1_value => 'REASON_CODE');
	    raise G_EXCEPTION_HALT_VALIDATION;
      Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
	    raise G_EXCEPTION_HALT_VALIDATION;
      End If;
    End If;

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
  END validate_reason_code;
  ----------------------------------------
  -- Validate_Attributes for: MANUAL_YN --
  ----------------------------------------
  PROCEDURE validate_manual_yn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_manual_yn                    IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_manual_yn = OKC_API.G_MISS_CHAR OR
        p_manual_yn IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'manual_yn');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check allowed values
    If (upper(p_manual_yn) NOT IN ('Y','N')) Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'manual_yn');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

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
  END validate_manual_yn;

  ---------------------------------------
  -- Validate_Attributes for: TRN_CODE --
  ---------------------------------------
  PROCEDURE validate_trn_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trn_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key if data exists
    If (p_trn_code <> OKC_API.G_MISS_CHAR and
	   p_trn_code IS NOT NULL)
    Then
      -- Check if the value is a valid code from lookup table
      x_return_status := OKC_UTIL.check_lookup_code('OKC_TERMINATION_REASON',
								      p_trn_code);
      If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
	    --set error message in message stack
	    OKC_API.SET_MESSAGE(
			p_app_name	=> G_APP_NAME,
			p_msg_name	=> G_INVALID_VALUE,
			p_token1		=> G_COL_NAME_TOKEN,
			p_token1_value => 'TERMINATION_REASON');
	    raise G_EXCEPTION_HALT_VALIDATION;
      Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
	    raise G_EXCEPTION_HALT_VALIDATION;
      End If;
    End If;

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
  END validate_trn_code;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKC_K_HISTORY_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_hstv_rec                     IN hstv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------

    -- ***
    -- chr_id
    -- ***
    validate_chr_id(x_return_status, p_hstv_rec.chr_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- contract_version
    -- ***
    validate_contract_version(x_return_status, p_hstv_rec.contract_version);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_hstv_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- opn_code
    -- ***
    validate_opn_code(x_return_status, p_hstv_rec.opn_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- reason_code
    -- ***
    validate_reason_code(x_return_status, p_hstv_rec.reason_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- manual_yn
    -- ***
    validate_manual_yn(x_return_status, p_hstv_rec.manual_yn);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- trn_code
    -- ***
    /*  -- Commented out by vjramali for bug 5139640
    validate_trn_code(x_return_status, p_hstv_rec.trn_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    */

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
  -- Validate Record for:OKC_K_HISTORY_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_hstv_rec IN hstv_rec_type,
    p_db_hstv_rec IN hstv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_hstv_rec IN hstv_rec_type,
      p_db_hstv_rec IN hstv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR hstv_stsv_fk1_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
        FROM Okc_Statuses_B
       WHERE okc_statuses_b.code  = p_code;
      l_hstv_stsv_fk1                hstv_stsv_fk1_csr%ROWTYPE;

      --CURSOR hstv_fndv_fk1_csr (p_lookup_code IN VARCHAR2) IS
      --SELECT 'x'
        --FROM Fnd_Lookups
       --WHERE fnd_lookups.lookup_code = p_lookup_code;
      --l_hstv_fndv_fk1                hstv_fndv_fk1_csr%ROWTYPE;

      CURSOR okc_clev_pk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okc_K_Lines_B
       WHERE okc_k_lines_b.id     = p_id;
      l_okc_clev_pk                  okc_clev_pk_csr%ROWTYPE;

      CURSOR okc_chrv_pk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM okc_k_headers_all_b  -- Modified by Jvorugan for Bug:4958537 Okc_K_Headers_B
       WHERE okc_k_headers_all_b.id   = p_id;
      l_okc_chrv_pk                  okc_chrv_pk_csr%ROWTYPE;

      CURSOR okc_opnv_pk_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
        FROM Okc_Operations_B
       WHERE okc_operations_b.code = p_code;
      l_okc_opnv_pk                  okc_opnv_pk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF ((p_hstv_rec.CHR_ID IS NOT NULL)
       AND
          (p_hstv_rec.CHR_ID <> p_db_hstv_rec.CHR_ID))
      THEN
        OPEN okc_chrv_pk_csr (p_hstv_rec.CHR_ID);
        FETCH okc_chrv_pk_csr INTO l_okc_chrv_pk;
        l_row_notfound := okc_chrv_pk_csr%NOTFOUND;
        CLOSE okc_chrv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_hstv_rec.CLE_ID IS NOT NULL)
       AND
          (p_hstv_rec.CLE_ID <> p_db_hstv_rec.CLE_ID))
      THEN
        OPEN okc_clev_pk_csr (p_hstv_rec.CLE_ID);
        FETCH okc_clev_pk_csr INTO l_okc_clev_pk;
        l_row_notfound := okc_clev_pk_csr%NOTFOUND;
        CLOSE okc_clev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_hstv_rec.OPN_CODE IS NOT NULL)
       AND
          (p_hstv_rec.OPN_CODE <> p_db_hstv_rec.OPN_CODE))
      THEN
        OPEN okc_opnv_pk_csr (p_hstv_rec.OPN_CODE);
        FETCH okc_opnv_pk_csr INTO l_okc_opnv_pk;
        l_row_notfound := okc_opnv_pk_csr%NOTFOUND;
        CLOSE okc_opnv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'OPN_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_hstv_rec.STS_CODE_FROM IS NOT NULL)
       AND
          (p_hstv_rec.STS_CODE_FROM <> p_db_hstv_rec.STS_CODE_FROM))
      THEN
        OPEN hstv_stsv_fk1_csr (p_hstv_rec.STS_CODE_FROM);
        FETCH hstv_stsv_fk1_csr INTO l_hstv_stsv_fk1;
        l_row_notfound := hstv_stsv_fk1_csr%NOTFOUND;
        CLOSE hstv_stsv_fk1_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'STS_CODE_FROM');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_hstv_rec.STS_CODE_TO IS NOT NULL)
       AND
          (p_hstv_rec.STS_CODE_TO <> p_db_hstv_rec.STS_CODE_TO))
      THEN
        OPEN hstv_stsv_fk1_csr (p_hstv_rec.STS_CODE_TO);
        FETCH hstv_stsv_fk1_csr INTO l_hstv_stsv_fk1;
        l_row_notfound := hstv_stsv_fk1_csr%NOTFOUND;
        CLOSE hstv_stsv_fk1_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'STS_CODE_TO');
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
    l_return_status := validate_foreign_keys(p_hstv_rec, p_db_hstv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_hstv_rec IN hstv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_hstv_rec                  hstv_rec_type := get_rec(p_hstv_rec);
  BEGIN
    l_return_status := Validate_Record(p_hstv_rec => p_hstv_rec,
                                       p_db_hstv_rec => l_db_hstv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN hstv_rec_type,
    p_to   IN OUT NOCOPY hst_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.contract_version := p_from.contract_version;
    p_to.sts_code_from := p_from.sts_code_from;
    p_to.opn_code := p_from.opn_code;
    p_to.sts_code_to := p_from.sts_code_to;
    p_to.reason_code := p_from.reason_code;
    p_to.trn_code := p_from.trn_code;
    p_to.manual_yn := p_from.manual_yn;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.last_update_login := p_from.last_update_login;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.request_id := p_from.request_id;
  END migrate;
  PROCEDURE migrate (
    p_from IN hst_rec_type,
    p_to   IN OUT NOCOPY hstv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.contract_version := p_from.contract_version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.opn_code := p_from.opn_code;
    p_to.sts_code_from := p_from.sts_code_from;
    p_to.sts_code_to := p_from.sts_code_to;
    p_to.reason_code := p_from.reason_code;
    p_to.trn_code := p_from.trn_code;
    p_to.manual_yn := p_from.manual_yn;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.request_id := p_from.request_id;
  END migrate;
  PROCEDURE migrate (
    p_from IN hstv_rec_type,
    p_to   IN OUT NOCOPY okc_k_history_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN okc_k_history_tl_rec_type,
    p_to   IN OUT NOCOPY hstv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
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
  --------------------------------------
  -- validate_row for:OKC_K_HISTORY_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN hstv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_hstv_rec                     hstv_rec_type := p_hstv_rec;
    l_hst_rec                      hst_rec_type;
    l_okc_k_history_tl_rec         okc_k_history_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_hstv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_hstv_rec);
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
  -- PL/SQL TBL validate_row for:OKC_K_HISTORY_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_hstv_tbl.COUNT > 0) THEN
      i := p_hstv_tbl.FIRST;
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
            p_hstv_rec                     => p_hstv_tbl(i));
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
        EXIT WHEN (i = p_hstv_tbl.LAST);
        i := p_hstv_tbl.NEXT(i);
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
  -- PL/SQL TBL validate_row for:OKC_K_HISTORY_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_hstv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_hstv_tbl                     => p_hstv_tbl,
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
  -- insert_row for:OKC_K_HISTORY_B --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hst_rec                      IN hst_rec_type,
    x_hst_rec                      OUT NOCOPY hst_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_hst_rec                      hst_rec_type := p_hst_rec;
    l_def_hst_rec                  hst_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKC_K_HISTORY_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_hst_rec IN hst_rec_type,
      x_hst_rec OUT NOCOPY hst_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_hst_rec := p_hst_rec;
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
      p_hst_rec,                         -- IN
      l_hst_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_HISTORY_B(
      id,
      chr_id,
      cle_id,
      contract_version,
      sts_code_from,
      opn_code,
      sts_code_to,
      reason_code,
      trn_code,
      manual_yn,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      object_version_number,
      last_update_login,
      program_application_id,
      program_id,
      program_update_date,
      request_id)
    VALUES (
      l_hst_rec.id,
      l_hst_rec.chr_id,
      l_hst_rec.cle_id,
      l_hst_rec.contract_version,
      l_hst_rec.sts_code_from,
      l_hst_rec.opn_code,
      l_hst_rec.sts_code_to,
      l_hst_rec.reason_code,
      l_hst_rec.trn_code,
      l_hst_rec.manual_yn,
      l_hst_rec.created_by,
      l_hst_rec.creation_date,
      l_hst_rec.last_updated_by,
      l_hst_rec.last_update_date,
      l_hst_rec.object_version_number,
      l_hst_rec.last_update_login,
      l_hst_rec.program_application_id,
      l_hst_rec.program_id,
      l_hst_rec.program_update_date,
      l_hst_rec.request_id);
    -- Set OUT values
    x_hst_rec := l_hst_rec;
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
  -- insert_row for:OKC_K_HISTORY_TL --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_history_tl_rec         IN okc_k_history_tl_rec_type,
    x_okc_k_history_tl_rec         OUT NOCOPY okc_k_history_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_history_tl_rec         okc_k_history_tl_rec_type := p_okc_k_history_tl_rec;
    l_def_okc_k_history_tl_rec     okc_k_history_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------
    -- Set_Attributes for:OKC_K_HISTORY_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_k_history_tl_rec IN okc_k_history_tl_rec_type,
      x_okc_k_history_tl_rec OUT NOCOPY okc_k_history_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_k_history_tl_rec := p_okc_k_history_tl_rec;
      x_okc_k_history_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_k_history_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okc_k_history_tl_rec,            -- IN
      l_okc_k_history_tl_rec);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_k_history_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_K_HISTORY_TL(
        id,
        language,
        source_lang,
        comments,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_okc_k_history_tl_rec.id,
        l_okc_k_history_tl_rec.language,
        l_okc_k_history_tl_rec.source_lang,
        l_okc_k_history_tl_rec.comments,
        l_okc_k_history_tl_rec.created_by,
        l_okc_k_history_tl_rec.creation_date,
        l_okc_k_history_tl_rec.last_updated_by,
        l_okc_k_history_tl_rec.last_update_date,
        l_okc_k_history_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_k_history_tl_rec := l_okc_k_history_tl_rec;
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
  -- insert_row for :OKC_K_HISTORY_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN hstv_rec_type,
    x_hstv_rec                     OUT NOCOPY hstv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_hstv_rec                     hstv_rec_type := p_hstv_rec;
    l_def_hstv_rec                 hstv_rec_type;
    l_hst_rec                      hst_rec_type;
    lx_hst_rec                     hst_rec_type;
    l_okc_k_history_tl_rec         okc_k_history_tl_rec_type;
    lx_okc_k_history_tl_rec        okc_k_history_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_hstv_rec IN hstv_rec_type
    ) RETURN hstv_rec_type IS
      l_hstv_rec hstv_rec_type := p_hstv_rec;
    BEGIN
      l_hstv_rec.CREATION_DATE := SYSDATE;
      l_hstv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_hstv_rec.LAST_UPDATE_DATE := l_hstv_rec.CREATION_DATE;
      l_hstv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_hstv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_hstv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKC_K_HISTORY_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_hstv_rec IN hstv_rec_type,
      x_hstv_rec OUT NOCOPY hstv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_trn_code 		     VARCHAR2(30);

      CURSOR terminate_csr IS
      SELECT trn_code
      FROM okc_k_headers_b
      WHERE id = p_hstv_rec.chr_id;
    BEGIN
      x_hstv_rec := p_hstv_rec;
      x_hstv_rec.OBJECT_VERSION_NUMBER := 1;

       --  populating the missing columns
     If p_hstv_rec.reason_code IS NULL Then
       If p_hstv_rec.sts_code_to = 'CREATE' Then
          x_hstv_rec.reason_code := 'CREATE';
       Elsif p_hstv_rec.sts_code_to = 'RENEW' Then
          x_hstv_rec.reason_code := 'RENEW';
       Elsif p_hstv_rec.sts_code_to = 'SIGNED' Then
          x_hstv_rec.reason_code := 'SIGNED';
       Elsif p_hstv_rec.sts_code_to = 'ACTIVE' Then
          x_hstv_rec.reason_code := 'ACTIVE';
       Elsif p_hstv_rec.sts_code_to = 'QA_HOLD' Then
          x_hstv_rec.reason_code := 'QA_HOLD';
       Elsif p_hstv_rec.sts_code_to = 'EXPIRED' Then
          x_hstv_rec.reason_code := 'EXPIRED';
       Elsif p_hstv_rec.sts_code_to = 'TERMINATED' Then
          x_hstv_rec.reason_code := 'TERMINATED';
          open terminate_csr;
          fetch terminate_csr into l_trn_code;
          close terminate_csr;
          x_hstv_rec.trn_code := l_trn_code;
       End If;
     End If;

     If (p_hstv_rec.sts_code_from = 'EXPIRED' AND p_hstv_rec.sts_code_to = 'ACTIVE') Then
          x_hstv_rec.reason_code := 'EXTEND';
     End If;

     If p_hstv_rec.manual_yn IS NULL Then
       x_hstv_rec.manual_yn := 'N';
     End If;

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

    l_hstv_rec := null_out_defaults(p_hstv_rec);
    -- Set primary key value
    l_hstv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_hstv_rec,                        -- IN
      l_def_hstv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_hstv_rec := fill_who_columns(l_def_hstv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_hstv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_hstv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_hstv_rec, l_hst_rec);
    migrate(l_def_hstv_rec, l_okc_k_history_tl_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_hst_rec,
      lx_hst_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_hst_rec, l_def_hstv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_history_tl_rec,
      lx_okc_k_history_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_k_history_tl_rec, l_def_hstv_rec);
    -- Set OUT values
    x_hstv_rec := l_def_hstv_rec;
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
  -- PL/SQL TBL insert_row for:HSTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type,
    x_hstv_tbl                     OUT NOCOPY hstv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_hstv_tbl.COUNT > 0) THEN
      i := p_hstv_tbl.FIRST;
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
            p_hstv_rec                     => p_hstv_tbl(i),
            x_hstv_rec                     => x_hstv_tbl(i));
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
        EXIT WHEN (i = p_hstv_tbl.LAST);
        i := p_hstv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:HSTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type,
    x_hstv_tbl                     OUT NOCOPY hstv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_hstv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_hstv_tbl                     => p_hstv_tbl,
        x_hstv_tbl                     => x_hstv_tbl,
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
  -- lock_row for:OKC_K_HISTORY_B --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hst_rec                      IN hst_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_hst_rec IN hst_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_HISTORY_B
     WHERE ID = p_hst_rec.id
       AND OBJECT_VERSION_NUMBER = p_hst_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_hst_rec IN hst_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_HISTORY_B
     WHERE ID = p_hst_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKC_K_HISTORY_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKC_K_HISTORY_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_hst_rec);
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
      OPEN lchk_csr(p_hst_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_hst_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_hst_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
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
  -- lock_row for:OKC_K_HISTORY_TL --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_history_tl_rec         IN okc_k_history_tl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_k_history_tl_rec IN okc_k_history_tl_rec_type) IS
    SELECT *
      FROM OKC_K_HISTORY_TL
     WHERE ID = p_okc_k_history_tl_rec.id
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
      OPEN lock_csr(p_okc_k_history_tl_rec);
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
  -- lock_row for: OKC_K_HISTORY_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN hstv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_hst_rec                      hst_rec_type;
    l_okc_k_history_tl_rec         okc_k_history_tl_rec_type;
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
    migrate(p_hstv_rec, l_hst_rec);
    migrate(p_hstv_rec, l_okc_k_history_tl_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_hst_rec
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
      l_okc_k_history_tl_rec
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
  -- PL/SQL TBL lock_row for:HSTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_hstv_tbl.COUNT > 0) THEN
      i := p_hstv_tbl.FIRST;
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
            p_hstv_rec                     => p_hstv_tbl(i));
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
        EXIT WHEN (i = p_hstv_tbl.LAST);
        i := p_hstv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:HSTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_hstv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_hstv_tbl                     => p_hstv_tbl,
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
  -- update_row for:OKC_K_HISTORY_B --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hst_rec                      IN hst_rec_type,
    x_hst_rec                      OUT NOCOPY hst_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_hst_rec                      hst_rec_type := p_hst_rec;
    l_def_hst_rec                  hst_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_hst_rec IN hst_rec_type,
      x_hst_rec OUT NOCOPY hst_rec_type
    ) RETURN VARCHAR2 IS
      l_hst_rec                      hst_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_hst_rec := p_hst_rec;
      -- Get current database values
      l_hst_rec := get_rec(p_hst_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_hst_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_hst_rec.id := l_hst_rec.id;
        END IF;
        IF (x_hst_rec.chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_hst_rec.chr_id := l_hst_rec.chr_id;
        END IF;
        IF (x_hst_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_hst_rec.cle_id := l_hst_rec.cle_id;
        END IF;
        IF (x_hst_rec.contract_version = OKC_API.G_MISS_CHAR)
        THEN
          x_hst_rec.contract_version := l_hst_rec.contract_version;
        END IF;
        IF (x_hst_rec.sts_code_from = OKC_API.G_MISS_CHAR)
        THEN
          x_hst_rec.sts_code_from := l_hst_rec.sts_code_from;
        END IF;
        IF (x_hst_rec.opn_code = OKC_API.G_MISS_CHAR)
        THEN
          x_hst_rec.opn_code := l_hst_rec.opn_code;
        END IF;
        IF (x_hst_rec.sts_code_to = OKC_API.G_MISS_CHAR)
        THEN
          x_hst_rec.sts_code_to := l_hst_rec.sts_code_to;
        END IF;
        IF (x_hst_rec.reason_code = OKC_API.G_MISS_CHAR)
        THEN
          x_hst_rec.reason_code := l_hst_rec.reason_code;
        END IF;
        IF (x_hst_rec.trn_code = OKC_API.G_MISS_CHAR)
        THEN
          x_hst_rec.trn_code := l_hst_rec.trn_code;
        END IF;
        IF (x_hst_rec.manual_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_hst_rec.manual_yn := l_hst_rec.manual_yn;
        END IF;
        IF (x_hst_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_hst_rec.created_by := l_hst_rec.created_by;
        END IF;
        IF (x_hst_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_hst_rec.creation_date := l_hst_rec.creation_date;
        END IF;
        IF (x_hst_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_hst_rec.last_updated_by := l_hst_rec.last_updated_by;
        END IF;
        IF (x_hst_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_hst_rec.last_update_date := l_hst_rec.last_update_date;
        END IF;
        IF (x_hst_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_hst_rec.object_version_number := l_hst_rec.object_version_number;
        END IF;
        IF (x_hst_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_hst_rec.last_update_login := l_hst_rec.last_update_login;
        END IF;
        IF (x_hst_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_hst_rec.program_application_id := l_hst_rec.program_application_id;
        END IF;
        IF (x_hst_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_hst_rec.program_id := l_hst_rec.program_id;
        END IF;
        IF (x_hst_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_hst_rec.program_update_date := l_hst_rec.program_update_date;
        END IF;
        IF (x_hst_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_hst_rec.request_id := l_hst_rec.request_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_K_HISTORY_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_hst_rec IN hst_rec_type,
      x_hst_rec OUT NOCOPY hst_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_hst_rec := p_hst_rec;
      x_hst_rec.OBJECT_VERSION_NUMBER := p_hst_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_hst_rec,                         -- IN
      l_hst_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_hst_rec, l_def_hst_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKC_K_HISTORY_B
    SET CHR_ID = l_def_hst_rec.chr_id,
        CLE_ID = l_def_hst_rec.cle_id,
        CONTRACT_VERSION = l_def_hst_rec.contract_version,
        STS_CODE_FROM = l_def_hst_rec.sts_code_from,
        OPN_CODE = l_def_hst_rec.opn_code,
        STS_CODE_TO = l_def_hst_rec.sts_code_to,
        REASON_CODE = l_def_hst_rec.reason_code,
        TRN_CODE = l_def_hst_rec.trn_code,
        MANUAL_YN = l_def_hst_rec.manual_yn,
        CREATED_BY = l_def_hst_rec.created_by,
        CREATION_DATE = l_def_hst_rec.creation_date,
        LAST_UPDATED_BY = l_def_hst_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_hst_rec.last_update_date,
        OBJECT_VERSION_NUMBER = l_def_hst_rec.object_version_number,
        LAST_UPDATE_LOGIN = l_def_hst_rec.last_update_login,
        PROGRAM_APPLICATION_ID = l_def_hst_rec.program_application_id,
        PROGRAM_ID = l_def_hst_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_hst_rec.program_update_date,
        REQUEST_ID = l_def_hst_rec.request_id
    WHERE ID = l_def_hst_rec.id;

    x_hst_rec := l_hst_rec;
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
  -- update_row for:OKC_K_HISTORY_TL --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_history_tl_rec         IN okc_k_history_tl_rec_type,
    x_okc_k_history_tl_rec         OUT NOCOPY okc_k_history_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_history_tl_rec         okc_k_history_tl_rec_type := p_okc_k_history_tl_rec;
    l_def_okc_k_history_tl_rec     okc_k_history_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_k_history_tl_rec IN okc_k_history_tl_rec_type,
      x_okc_k_history_tl_rec OUT NOCOPY okc_k_history_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_k_history_tl_rec         okc_k_history_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_k_history_tl_rec := p_okc_k_history_tl_rec;
      -- Get current database values
      l_okc_k_history_tl_rec := get_rec(p_okc_k_history_tl_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_okc_k_history_tl_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_k_history_tl_rec.id := l_okc_k_history_tl_rec.id;
        END IF;
        IF (x_okc_k_history_tl_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_k_history_tl_rec.language := l_okc_k_history_tl_rec.language;
        END IF;
        IF (x_okc_k_history_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_k_history_tl_rec.source_lang := l_okc_k_history_tl_rec.source_lang;
        END IF;
        IF (x_okc_k_history_tl_rec.comments = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_k_history_tl_rec.comments := l_okc_k_history_tl_rec.comments;
        END IF;
        IF (x_okc_k_history_tl_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_k_history_tl_rec.created_by := l_okc_k_history_tl_rec.created_by;
        END IF;
        IF (x_okc_k_history_tl_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_k_history_tl_rec.creation_date := l_okc_k_history_tl_rec.creation_date;
        END IF;
        IF (x_okc_k_history_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_k_history_tl_rec.last_updated_by := l_okc_k_history_tl_rec.last_updated_by;
        END IF;
        IF (x_okc_k_history_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_k_history_tl_rec.last_update_date := l_okc_k_history_tl_rec.last_update_date;
        END IF;
        IF (x_okc_k_history_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_okc_k_history_tl_rec.last_update_login := l_okc_k_history_tl_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_HISTORY_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_k_history_tl_rec IN okc_k_history_tl_rec_type,
      x_okc_k_history_tl_rec OUT NOCOPY okc_k_history_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_k_history_tl_rec := p_okc_k_history_tl_rec;
      x_okc_k_history_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_k_history_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okc_k_history_tl_rec,            -- IN
      l_okc_k_history_tl_rec);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_k_history_tl_rec, l_def_okc_k_history_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKC_K_HISTORY_TL
    SET COMMENTS = l_def_okc_k_history_tl_rec.comments,
        CREATED_BY = l_def_okc_k_history_tl_rec.created_by,
        CREATION_DATE = l_def_okc_k_history_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_k_history_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_k_history_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_k_history_tl_rec.last_update_login
    WHERE ID = l_def_okc_k_history_tl_rec.id
      AND SOURCE_LANG = USERENV('LANG');

   /* below code came with TAPI but there is no column by name sfwt_flag in
      tl table. commenting the code. */
    --UPDATE OKC_K_HISTORY_TL
    --SET SFWT_FLAG = 'Y'
    --WHERE ID = l_def_okc_k_history_tl_rec.id
    --   AND SOURCE_LANG <> USERENV('LANG');

    x_okc_k_history_tl_rec := l_okc_k_history_tl_rec;
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
  -- update_row for:OKC_K_HISTORY_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN hstv_rec_type,
    x_hstv_rec                     OUT NOCOPY hstv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_hstv_rec                     hstv_rec_type := p_hstv_rec;
    l_def_hstv_rec                 hstv_rec_type;
    l_db_hstv_rec                  hstv_rec_type;
    l_hst_rec                      hst_rec_type;
    lx_hst_rec                     hst_rec_type;
    l_okc_k_history_tl_rec         okc_k_history_tl_rec_type;
    lx_okc_k_history_tl_rec        okc_k_history_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_hstv_rec IN hstv_rec_type
    ) RETURN hstv_rec_type IS
      l_hstv_rec hstv_rec_type := p_hstv_rec;
    BEGIN
      l_hstv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_hstv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_hstv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_hstv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_hstv_rec IN hstv_rec_type,
      x_hstv_rec OUT NOCOPY hstv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_hstv_rec := p_hstv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_hstv_rec := get_rec(p_hstv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_hstv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_hstv_rec.id := l_db_hstv_rec.id;
        END IF;
        IF (x_hstv_rec.chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_hstv_rec.chr_id := l_db_hstv_rec.chr_id;
        END IF;
        IF (x_hstv_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_hstv_rec.cle_id := l_db_hstv_rec.cle_id;
        END IF;
        IF (x_hstv_rec.contract_version = OKC_API.G_MISS_CHAR)
        THEN
          x_hstv_rec.contract_version := l_db_hstv_rec.contract_version;
        END IF;
        IF (x_hstv_rec.opn_code = OKC_API.G_MISS_CHAR)
        THEN
          x_hstv_rec.opn_code := l_db_hstv_rec.opn_code;
        END IF;
        IF (x_hstv_rec.sts_code_from = OKC_API.G_MISS_CHAR)
        THEN
          x_hstv_rec.sts_code_from := l_db_hstv_rec.sts_code_from;
        END IF;
        IF (x_hstv_rec.sts_code_to = OKC_API.G_MISS_CHAR)
        THEN
          x_hstv_rec.sts_code_to := l_db_hstv_rec.sts_code_to;
        END IF;
        IF (x_hstv_rec.reason_code = OKC_API.G_MISS_CHAR)
        THEN
          x_hstv_rec.reason_code := l_db_hstv_rec.reason_code;
        END IF;
        IF (x_hstv_rec.trn_code = OKC_API.G_MISS_CHAR)
        THEN
          x_hstv_rec.trn_code := l_db_hstv_rec.trn_code;
        END IF;
        IF (x_hstv_rec.manual_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_hstv_rec.manual_yn := l_db_hstv_rec.manual_yn;
        END IF;
        IF (x_hstv_rec.comments = OKC_API.G_MISS_CHAR)
        THEN
          x_hstv_rec.comments := l_db_hstv_rec.comments;
        END IF;
        IF (x_hstv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_hstv_rec.created_by := l_db_hstv_rec.created_by;
        END IF;
        IF (x_hstv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_hstv_rec.creation_date := l_db_hstv_rec.creation_date;
        END IF;
        IF (x_hstv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_hstv_rec.last_updated_by := l_db_hstv_rec.last_updated_by;
        END IF;
        IF (x_hstv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_hstv_rec.last_update_date := l_db_hstv_rec.last_update_date;
        END IF;
        IF (x_hstv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_hstv_rec.last_update_login := l_db_hstv_rec.last_update_login;
        END IF;
        IF (x_hstv_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_hstv_rec.program_application_id := l_db_hstv_rec.program_application_id;
        END IF;
        IF (x_hstv_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_hstv_rec.program_id := l_db_hstv_rec.program_id;
        END IF;
        IF (x_hstv_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_hstv_rec.program_update_date := l_db_hstv_rec.program_update_date;
        END IF;
        IF (x_hstv_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_hstv_rec.request_id := l_db_hstv_rec.request_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_K_HISTORY_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_hstv_rec IN hstv_rec_type,
      x_hstv_rec OUT NOCOPY hstv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_hstv_rec := p_hstv_rec;
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
      p_hstv_rec,                        -- IN
      x_hstv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_hstv_rec, l_def_hstv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_hstv_rec := fill_who_columns(l_def_hstv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_hstv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_hstv_rec, l_db_hstv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_hstv_rec                     => p_hstv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_hstv_rec, l_hst_rec);
    migrate(l_def_hstv_rec, l_okc_k_history_tl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_hst_rec,
      lx_hst_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_hst_rec, l_def_hstv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_history_tl_rec,
      lx_okc_k_history_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_k_history_tl_rec, l_def_hstv_rec);
    x_hstv_rec := l_def_hstv_rec;
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
  -- PL/SQL TBL update_row for:hstv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type,
    x_hstv_tbl                     OUT NOCOPY hstv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_hstv_tbl.COUNT > 0) THEN
      i := p_hstv_tbl.FIRST;
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
            p_hstv_rec                     => p_hstv_tbl(i),
            x_hstv_rec                     => x_hstv_tbl(i));
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
        EXIT WHEN (i = p_hstv_tbl.LAST);
        i := p_hstv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:HSTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type,
    x_hstv_tbl                     OUT NOCOPY hstv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_hstv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_hstv_tbl                     => p_hstv_tbl,
        x_hstv_tbl                     => x_hstv_tbl,
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
  -- delete_row for:OKC_K_HISTORY_B --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hst_rec                      IN hst_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_hst_rec                      hst_rec_type := p_hst_rec;
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

    DELETE FROM OKC_K_HISTORY_B
     WHERE ID = p_hst_rec.id;

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
  -- delete_row for:OKC_K_HISTORY_TL --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_history_tl_rec         IN okc_k_history_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_history_tl_rec         okc_k_history_tl_rec_type := p_okc_k_history_tl_rec;
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

    DELETE FROM OKC_K_HISTORY_TL
     WHERE ID = p_okc_k_history_tl_rec.id;

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
  -- delete_row for:OKC_K_HISTORY_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN hstv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_hstv_rec                     hstv_rec_type := p_hstv_rec;
    l_okc_k_history_tl_rec         okc_k_history_tl_rec_type;
    l_hst_rec                      hst_rec_type;
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
    migrate(l_hstv_rec, l_okc_k_history_tl_rec);
    migrate(l_hstv_rec, l_hst_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_history_tl_rec
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
      l_hst_rec
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
  -- PL/SQL TBL delete_row for:OKC_K_HISTORY_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_hstv_tbl.COUNT > 0) THEN
      i := p_hstv_tbl.FIRST;
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
            p_hstv_rec                     => p_hstv_tbl(i));
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
        EXIT WHEN (i = p_hstv_tbl.LAST);
        i := p_hstv_tbl.NEXT(i);
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
  -- PL/SQL TBL delete_row for:OKC_K_HISTORY_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_hstv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_hstv_tbl                     => p_hstv_tbl,
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
  -- PROCEDURE delete_all_rows
  ---------------------------------------------------------------------------

  --------------------------------------------------------------
  -- delete_all_rows for:OKC_K_HISTORY_TL and OKC_K_HISTORY_B --
  --------------------------------------------------------------
  PROCEDURE delete_all_rows(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_all_rows';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
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

    DELETE FROM OKC_K_HISTORY_TL
         WHERE ID IN (SELECT ID
                      FROM OKC_K_HISTORY_B
                      WHERE CHR_ID = p_chr_id);

    DELETE FROM OKC_K_HISTORY_B
     WHERE CHR_ID = p_chr_id;

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
  END delete_all_rows;
  -----------------------------------------
  -- delete_all_rows for:OKC_K_HISTORY_V --
  -----------------------------------------
  PROCEDURE delete_all_rows(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_all_rows';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
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

    --------------------------------------------------
    -- Call the DELETE_ALL_ROWS for all the records --
    --------------------------------------------------
    delete_all_rows(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id    );
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
  END delete_all_rows;

END OKC_HST_PVT;

/
