--------------------------------------------------------
--  DDL for Package Body OKL_PFL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PFL_PVT" AS
/* $Header: OKLSPFLB.pls 120.3 2005/10/30 04:43:15 appldev noship $ */
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
    DELETE FROM OKL_PRTFL_LINES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_PRTFL_LINES_B B
         WHERE B.ID =T.ID
        );

    UPDATE OKL_PRTFL_LINES_TL T SET(
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKL_PRTFL_LINES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_PRTFL_LINES_TL SUBB, OKL_PRTFL_LINES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
              ));

    INSERT INTO OKL_PRTFL_LINES_TL (
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
        FROM OKL_PRTFL_LINES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_PRTFL_LINES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PRTFL_LINES_V
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : get_rec
  -- Description     : for: OKL_PRTFL_LINES_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION get_rec (
    p_pflv_rec                     IN pflv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pflv_rec_type IS
    CURSOR okl_pflv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            SFWT_FLAG,
            BUDGET_AMOUNT,
            DATE_STRATEGY_EXECUTED,
            DATE_STRATEGY_EXECUTION_DUE,
            DATE_BUDGET_AMOUNT_LAST_REVIEW,
            TRX_STATUS_CODE,
            ASSET_TRACK_STRATEGY_CODE,
            PFC_ID,
            TMB_ID,
            KLE_ID,
            FMA_ID,
            COMMENTS,
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
            LAST_UPDATE_LOGIN,
  -- RABHUPAT - 2667636 - Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
  -- RABHUPAT - 2667636 - End
      FROM Okl_Prtfl_Lines_V
     WHERE okl_prtfl_lines_v.id = p_id;
    l_okl_pflv_pk                  okl_pflv_pk_csr%ROWTYPE;
    l_pflv_rec                     pflv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pflv_pk_csr (p_pflv_rec.id);
    FETCH okl_pflv_pk_csr INTO
              l_pflv_rec.id,
              l_pflv_rec.sfwt_flag,
              l_pflv_rec.budget_amount,
              l_pflv_rec.date_strategy_executed,
              l_pflv_rec.date_strategy_execution_due,
              l_pflv_rec.date_budget_amount_last_review,
              l_pflv_rec.trx_status_code,
              l_pflv_rec.asset_track_strategy_code,
              l_pflv_rec.pfc_id,
              l_pflv_rec.tmb_id,
              l_pflv_rec.kle_id,
              l_pflv_rec.fma_id,
              l_pflv_rec.comments,
              l_pflv_rec.object_version_number,
              l_pflv_rec.request_id,
              l_pflv_rec.program_application_id,
              l_pflv_rec.program_id,
              l_pflv_rec.program_update_date,
              l_pflv_rec.attribute_category,
              l_pflv_rec.attribute1,
              l_pflv_rec.attribute2,
              l_pflv_rec.attribute3,
              l_pflv_rec.attribute4,
              l_pflv_rec.attribute5,
              l_pflv_rec.attribute6,
              l_pflv_rec.attribute7,
              l_pflv_rec.attribute8,
              l_pflv_rec.attribute9,
              l_pflv_rec.attribute10,
              l_pflv_rec.attribute11,
              l_pflv_rec.attribute12,
              l_pflv_rec.attribute13,
              l_pflv_rec.attribute14,
              l_pflv_rec.attribute15,
              l_pflv_rec.created_by,
              l_pflv_rec.creation_date,
              l_pflv_rec.last_updated_by,
              l_pflv_rec.last_update_date,
              l_pflv_rec.last_update_login,
  -- RABHUPAT - 2667636 - Start
              l_pflv_rec.CURRENCY_CODE,
              l_pflv_rec.CURRENCY_CONVERSION_CODE,
              l_pflv_rec.CURRENCY_CONVERSION_TYPE,
              l_pflv_rec.CURRENCY_CONVERSION_RATE,
              l_pflv_rec.CURRENCY_CONVERSION_DATE;
  -- RABHUPAT - 2667636 - End
    x_no_data_found := okl_pflv_pk_csr%NOTFOUND;
    CLOSE okl_pflv_pk_csr;
    RETURN(l_pflv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pflv_rec                     IN pflv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pflv_rec_type IS
    l_pflv_rec                     pflv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_pflv_rec := get_rec(p_pflv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pflv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pflv_rec                     IN pflv_rec_type
  ) RETURN pflv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pflv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PRTFL_LINES_B
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : get_rec
  -- Description     : for: OKL_PRTFL_LINES_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION get_rec (
    p_pfl_rec                      IN pfl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pfl_rec_type IS
    CURSOR okl_prtfl_lines_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            BUDGET_AMOUNT,
            DATE_STRATEGY_EXECUTED,
            DATE_STRATEGY_EXECUTION_DUE,
            DATE_BUDGET_AMOUNT_LAST_REVIEW,
            TRX_STATUS_CODE,
            ASSET_TRACK_STRATEGY_CODE,
            PFC_ID,
            TMB_ID,
            KLE_ID,
            FMA_ID,
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
            LAST_UPDATE_LOGIN,
  -- RABHUPAT - 2667636 - Start
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
  -- RABHUPAT - 2667636 - End
      FROM Okl_Prtfl_Lines_B
     WHERE okl_prtfl_lines_b.id = p_id;
    l_okl_prtfl_lines_b_pk         okl_prtfl_lines_b_pk_csr%ROWTYPE;
    l_pfl_rec                      pfl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_prtfl_lines_b_pk_csr (p_pfl_rec.id);
    FETCH okl_prtfl_lines_b_pk_csr INTO
              l_pfl_rec.id,
              l_pfl_rec.budget_amount,
              l_pfl_rec.date_strategy_executed,
              l_pfl_rec.date_strategy_execution_due,
              l_pfl_rec.date_budget_amount_last_review,
              l_pfl_rec.trx_status_code,
              l_pfl_rec.asset_track_strategy_code,
              l_pfl_rec.pfc_id,
              l_pfl_rec.tmb_id,
              l_pfl_rec.kle_id,
              l_pfl_rec.fma_id,
              l_pfl_rec.object_version_number,
              l_pfl_rec.request_id,
              l_pfl_rec.program_application_id,
              l_pfl_rec.program_id,
              l_pfl_rec.program_update_date,
              l_pfl_rec.attribute_category,
              l_pfl_rec.attribute1,
              l_pfl_rec.attribute2,
              l_pfl_rec.attribute3,
              l_pfl_rec.attribute4,
              l_pfl_rec.attribute5,
              l_pfl_rec.attribute6,
              l_pfl_rec.attribute7,
              l_pfl_rec.attribute8,
              l_pfl_rec.attribute9,
              l_pfl_rec.attribute10,
              l_pfl_rec.attribute11,
              l_pfl_rec.attribute12,
              l_pfl_rec.attribute13,
              l_pfl_rec.attribute14,
              l_pfl_rec.attribute15,
              l_pfl_rec.created_by,
              l_pfl_rec.creation_date,
              l_pfl_rec.last_updated_by,
              l_pfl_rec.last_update_date,
              l_pfl_rec.last_update_login,
  -- RABHUPAT - 2667636 - Start
              l_pfl_rec.CURRENCY_CODE,
              l_pfl_rec.CURRENCY_CONVERSION_CODE,
              l_pfl_rec.CURRENCY_CONVERSION_TYPE,
              l_pfl_rec.CURRENCY_CONVERSION_RATE,
              l_pfl_rec.CURRENCY_CONVERSION_DATE;
  -- RABHUPAT - 2667636 - End
    x_no_data_found := okl_prtfl_lines_b_pk_csr%NOTFOUND;
    CLOSE okl_prtfl_lines_b_pk_csr;
    RETURN(l_pfl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pfl_rec                      IN pfl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pfl_rec_type IS
    l_pfl_rec                      pfl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_pfl_rec := get_rec(p_pfl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pfl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pfl_rec                      IN pfl_rec_type
  ) RETURN pfl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pfl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PRTFL_LINES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_prtfl_lines_tl_rec       IN okl_prtfl_lines_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_prtfl_lines_tl_rec_type IS
    CURSOR okl_prtfl_lines_tl_pk_csr (p_id       IN NUMBER,
                                      p_language IN VARCHAR2) IS
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
      FROM Okl_Prtfl_Lines_Tl
     WHERE okl_prtfl_lines_tl.id = p_id
       AND okl_prtfl_lines_tl.language = p_language;
    l_okl_prtfl_lines_tl_pk        okl_prtfl_lines_tl_pk_csr%ROWTYPE;
    l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_prtfl_lines_tl_pk_csr (p_okl_prtfl_lines_tl_rec.id,
                                    p_okl_prtfl_lines_tl_rec.language);
    FETCH okl_prtfl_lines_tl_pk_csr INTO
              l_okl_prtfl_lines_tl_rec.id,
              l_okl_prtfl_lines_tl_rec.language,
              l_okl_prtfl_lines_tl_rec.source_lang,
              l_okl_prtfl_lines_tl_rec.sfwt_flag,
              l_okl_prtfl_lines_tl_rec.comments,
              l_okl_prtfl_lines_tl_rec.created_by,
              l_okl_prtfl_lines_tl_rec.creation_date,
              l_okl_prtfl_lines_tl_rec.last_updated_by,
              l_okl_prtfl_lines_tl_rec.last_update_date,
              l_okl_prtfl_lines_tl_rec.last_update_login;
    x_no_data_found := okl_prtfl_lines_tl_pk_csr%NOTFOUND;
    CLOSE okl_prtfl_lines_tl_pk_csr;
    RETURN(l_okl_prtfl_lines_tl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_prtfl_lines_tl_rec       IN okl_prtfl_lines_tl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okl_prtfl_lines_tl_rec_type IS
    l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_okl_prtfl_lines_tl_rec := get_rec(p_okl_prtfl_lines_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okl_prtfl_lines_tl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okl_prtfl_lines_tl_rec       IN okl_prtfl_lines_tl_rec_type
  ) RETURN okl_prtfl_lines_tl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_prtfl_lines_tl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PRTFL_LINES_V
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : null_out_defaults
  -- Description     : for: OKL_PRTFL_LINES_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION null_out_defaults (
    p_pflv_rec   IN pflv_rec_type
  ) RETURN pflv_rec_type IS
    l_pflv_rec                     pflv_rec_type := p_pflv_rec;
  BEGIN
    IF (l_pflv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.id := NULL;
    END IF;
    IF (l_pflv_rec.sfwt_flag = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_pflv_rec.budget_amount = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.budget_amount := NULL;
    END IF;
    IF (l_pflv_rec.date_strategy_executed = OKL_API.G_MISS_DATE ) THEN
      l_pflv_rec.date_strategy_executed := NULL;
    END IF;
    IF (l_pflv_rec.date_strategy_execution_due = OKL_API.G_MISS_DATE ) THEN
      l_pflv_rec.date_strategy_execution_due := NULL;
    END IF;
    IF (l_pflv_rec.date_budget_amount_last_review = OKL_API.G_MISS_DATE ) THEN
      l_pflv_rec.date_budget_amount_last_review := NULL;
    END IF;
    IF (l_pflv_rec.trx_status_code = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.trx_status_code := NULL;
    END IF;
    IF (l_pflv_rec.asset_track_strategy_code = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.asset_track_strategy_code := NULL;
    END IF;
    IF (l_pflv_rec.pfc_id = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.pfc_id := NULL;
    END IF;
    IF (l_pflv_rec.tmb_id = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.tmb_id := NULL;
    END IF;
    IF (l_pflv_rec.kle_id = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.kle_id := NULL;
    END IF;
    IF (l_pflv_rec.fma_id = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.fma_id := NULL;
    END IF;
    IF (l_pflv_rec.comments = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.comments := NULL;
    END IF;
    IF (l_pflv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.object_version_number := NULL;
    END IF;
    IF (l_pflv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.request_id := NULL;
    END IF;
    IF (l_pflv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.program_application_id := NULL;
    END IF;
    IF (l_pflv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.program_id := NULL;
    END IF;
    IF (l_pflv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_pflv_rec.program_update_date := NULL;
    END IF;
    IF (l_pflv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute_category := NULL;
    END IF;
    IF (l_pflv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute1 := NULL;
    END IF;
    IF (l_pflv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute2 := NULL;
    END IF;
    IF (l_pflv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute3 := NULL;
    END IF;
    IF (l_pflv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute4 := NULL;
    END IF;
    IF (l_pflv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute5 := NULL;
    END IF;
    IF (l_pflv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute6 := NULL;
    END IF;
    IF (l_pflv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute7 := NULL;
    END IF;
    IF (l_pflv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute8 := NULL;
    END IF;
    IF (l_pflv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute9 := NULL;
    END IF;
    IF (l_pflv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute10 := NULL;
    END IF;
    IF (l_pflv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute11 := NULL;
    END IF;
    IF (l_pflv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute12 := NULL;
    END IF;
    IF (l_pflv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute13 := NULL;
    END IF;
    IF (l_pflv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute14 := NULL;
    END IF;
    IF (l_pflv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_pflv_rec.attribute15 := NULL;
    END IF;
    IF (l_pflv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.created_by := NULL;
    END IF;
    IF (l_pflv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_pflv_rec.creation_date := NULL;
    END IF;
    IF (l_pflv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pflv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_pflv_rec.last_update_date := NULL;
    END IF;
    IF (l_pflv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_pflv_rec.last_update_login := NULL;
    END IF;
  -- RABHUPAT - 2667636 -Start
    IF (l_pflv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_pflv_rec.currency_code := NULL;
    END IF;
    IF (l_pflv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      l_pflv_rec.currency_conversion_code := NULL;
    END IF;
    IF (l_pflv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
      l_pflv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_pflv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
      l_pflv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_pflv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
      l_pflv_rec.currency_conversion_date := NULL;
    END IF;
  -- RABHUPAT - 2667636 -End
    RETURN(l_pflv_rec);
  END null_out_defaults;

 -- Start of comments
  --
  -- Procedure Name  : validate_currency_record
  -- Description     : Used for validation of Currency Code Conversion Coulms
  -- Business Rules  : If transaction currency <> functional currency, then conversion columns
  --                   are mandatory
  --                   Else If transaction currency = functional currency, then conversion columns
  --                   should all be NULL
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_record(p_pflv_rec      IN  pflv_rec_type,
                                     x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- If transaction currency <> functional currency, then conversion columns
    -- are mandatory
    IF (p_pflv_rec.currency_code <> p_pflv_rec.currency_conversion_code) THEN
      IF (p_pflv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR OR
         p_pflv_rec.currency_conversion_type IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_type');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_pflv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM OR
         p_pflv_rec.currency_conversion_rate IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_rate');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_pflv_rec.currency_conversion_date = OKC_API.G_MISS_DATE OR
         p_pflv_rec.currency_conversion_date IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_date');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    -- Else If transaction currency = functional currency, then conversion columns
    -- should all be NULL
    ELSIF (p_pflv_rec.currency_code = p_pflv_rec.currency_conversion_code) THEN
      IF (p_pflv_rec.currency_conversion_type IS NOT NULL) OR
         (p_pflv_rec.currency_conversion_rate IS NOT NULL) OR
         (p_pflv_rec.currency_conversion_date IS NOT NULL) THEN
        --SET MESSAGE
        -- Currency conversion columns should be all null
        IF p_pflv_rec.currency_conversion_rate IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_rate');
        END IF;
        IF p_pflv_rec.currency_conversion_date IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_date');
        END IF;
        IF p_pflv_rec.currency_conversion_type IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_type');
        END IF;
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    ELSE
        x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_currency_record;
---------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_currency_code
  -- Description     : Validation of Currency Code
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_code(p_pflv_rec      IN  pflv_rec_type,
                                   x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_pflv_rec.currency_code IS NULL) OR
       (p_pflv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_code');

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_pflv_rec.currency_code);
    IF (l_return_status <>  OKC_API.G_TRUE) THEN
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'currency_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_currency_code;
---------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_currency_con_code
  -- Description     : Validation of Currency Conversion Code
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_code(p_pflv_rec      IN  pflv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_pflv_rec.currency_conversion_code IS NULL) OR
       (p_pflv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_conversion_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_pflv_rec.currency_conversion_code);
    IF (l_return_status <>  OKC_API.G_TRUE) THEN
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'currency_conversion_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_currency_con_code;
---------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_currency_con_type
  -- Description     : Validation of Currency Conversion type
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 16-DEC-2002 2667636:Added new procedure
  -- End of comments

  PROCEDURE validate_currency_con_type(p_pflv_rec      IN  pflv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_pflv_rec.currency_conversion_type <> OKL_API.G_MISS_CHAR AND
       p_pflv_rec.currency_conversion_type IS NOT NULL) THEN
      -- check from currency values using the generic okl_util.validate_currency_code
      l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_con_type(p_pflv_rec.currency_conversion_type);
      IF (l_return_status <>  OKC_API.G_TRUE) THEN
            OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'currency_conversion_type');
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_currency_con_type;

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
  ----------------------------------------------------------
  -- Validate_Attributes for: DATE_STRATEGY_EXECUTION_DUE --
  ----------------------------------------------------------
  PROCEDURE validate_date_strat1(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_date_strategy_execution_due  IN DATE) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_date_strategy_execution_due = OKL_API.G_MISS_DATE OR
        p_date_strategy_execution_due IS NULL)
    THEN
      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_EXE_DUE_DATE'));

      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'date_strategy_execution_due');
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
  END validate_date_strat1;
  ----------------------------------------------
  -- Validate_Attributes for: TRX_STATUS_CODE --
  ----------------------------------------------
  PROCEDURE validate_trx_status_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trx_status_code              IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_trx_status_code = OKL_API.G_MISS_CHAR OR
        p_trx_status_code IS NULL)
    THEN
      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_STATUS'));

--      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_status_code');
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
  END validate_trx_status_code;
  --------------------------------------------------------
  -- Validate_Attributes for: ASSET_TRACK_STRATEGY_CODE --
  --------------------------------------------------------
  PROCEDURE validate_asset_trac3(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_asset_track_strategy_code    IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_asset_track_strategy_code = OKL_API.G_MISS_CHAR OR
        p_asset_track_strategy_code IS NULL)
    THEN
      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_STRATEGY'));

--      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'asset_track_strategy_code');
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
  END validate_asset_trac3;
  -------------------------------------
  -- Validate_Attributes for: PFC_ID --
  -------------------------------------
  PROCEDURE validate_pfc_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_pfc_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_pfc_id = OKL_API.G_MISS_NUM OR
        p_pfc_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'pfc_id');
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
  END validate_pfc_id;
  -------------------------------------
  -- Validate_Attributes for: TMB_ID --
  -------------------------------------
  PROCEDURE validate_tmb_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tmb_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_tmb_id = OKL_API.G_MISS_NUM OR
        p_tmb_id IS NULL)
    THEN

      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_ASSIGNMENT_GROUP'));

--      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tmb_id');
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
  END validate_tmb_id;
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

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKL_PRTFL_LINES_V --
  -----------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_attributes
  -- Description     : for:OKL_PRTFL_LINES_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU 19-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments

  FUNCTION Validate_Attributes (
    p_pflv_rec                     IN pflv_rec_type
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
    validate_id(l_return_status, p_pflv_rec.id);
    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(l_return_status, p_pflv_rec.sfwt_flag);
    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- ***
    -- date_strategy_execution_due
    -- ***
    validate_date_strat1(l_return_status, p_pflv_rec.date_strategy_execution_due);
    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- ***
    -- trx_status_code
    -- ***
    validate_trx_status_code(l_return_status, p_pflv_rec.trx_status_code);
    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- ***
    -- asset_track_strategy_code
    -- ***
    validate_asset_trac3(l_return_status, p_pflv_rec.asset_track_strategy_code);
    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- ***
    -- pfc_id
    -- ***
    validate_pfc_id(l_return_status, p_pflv_rec.pfc_id);
    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- ***
    -- tmb_id
    -- ***
    validate_tmb_id(l_return_status, p_pflv_rec.tmb_id);
    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(l_return_status, p_pflv_rec.object_version_number);
    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

  -- RMUNJULU - 2667636 - Start
    validate_currency_code(p_pflv_rec      => p_pflv_rec,
                           x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    validate_currency_con_code(p_pflv_rec      => p_pflv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    validate_currency_con_type(p_pflv_rec      => p_pflv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- RMUNJULU - 2667636 - End

    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate Record for:OKL_PRTFL_LINES_V --
  -------------------------------------------
  -- Start of comments
  --
  -- Function  Name  : Validate_Record
  -- Description     : for:OKL_PRTFL_LINES_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 :modified for multicurrency changes
  -- End of comments
  FUNCTION Validate_Record (
    p_pflv_rec IN pflv_rec_type,
    p_db_pflv_rec IN pflv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_pflv_rec IN pflv_rec_type,
      p_db_pflv_rec IN pflv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      -- PAGARG 16-Aug-2004 3832404: added p_lookup_type parameter
      CURSOR okl_pflv_tsuv_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
        FROM fnd_lookups
       WHERE fnd_lookups.lookup_code = p_lookup_code
         AND fnd_lookups.lookup_type = p_lookup_type;

      l_okl_pflv_tsuv_fk             okl_pflv_tsuv_fk_csr%ROWTYPE;

      -- PAGARG 16-Aug-2004 3832404: added p_lookup_type parameter
      CURSOR okl_pflv_atsv_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
        FROM fnd_lookups
       WHERE fnd_lookups.lookup_code = p_lookup_code
         AND fnd_lookups.lookup_type = p_lookup_type;
      l_okl_pflv_atsv_fk             okl_pflv_atsv_fk_csr%ROWTYPE;

      CURSOR okl_pflv_pfcv_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_Prtfl_Cntrcts_V
       WHERE okl_prtfl_cntrcts_v.id = p_id;
      l_okl_pflv_pfcv_fk             okl_pflv_pfcv_fk_csr%ROWTYPE;

      CURSOR okl_pflv_klev_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_K_Lines_V
       WHERE okl_k_lines_v.id     = p_id;
      l_okl_pflv_klev_fk             okl_pflv_klev_fk_csr%ROWTYPE;

      CURSOR okl_pflv_tmbv_fk_csr (p_team_id IN NUMBER) IS
      SELECT 'x'
        FROM Jtf_Rs_Teams_Vl
       WHERE jtf_rs_teams_vl.team_id = p_team_id;
      l_okl_pflv_tmbv_fk             okl_pflv_tmbv_fk_csr%ROWTYPE;

      CURSOR okl_pflv_fmav_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_Formulae_V
       WHERE okl_formulae_v.id    = p_id;
      l_okl_pflv_fmav_fk             okl_pflv_fmav_fk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF ((p_pflv_rec.TMB_ID IS NOT NULL)
       AND
          (p_pflv_rec.TMB_ID <> p_db_pflv_rec.TMB_ID))
      THEN
        OPEN okl_pflv_tmbv_fk_csr (p_pflv_rec.TMB_ID);
        FETCH okl_pflv_tmbv_fk_csr INTO l_okl_pflv_tmbv_fk;
        l_row_notfound := okl_pflv_tmbv_fk_csr%NOTFOUND;
        CLOSE okl_pflv_tmbv_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TMB_ID');
          l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      -- store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
      END IF;


      IF ((p_pflv_rec.ASSET_TRACK_STRATEGY_CODE IS NOT NULL)
       AND
          (p_pflv_rec.ASSET_TRACK_STRATEGY_CODE <> p_db_pflv_rec.ASSET_TRACK_STRATEGY_CODE))
      THEN
        -- PAGARG 16-Aug-2004 3832404: Passing lookup_type as parameter
        OPEN okl_pflv_atsv_fk_csr (p_pflv_rec.ASSET_TRACK_STRATEGY_CODE, 'OKL_ASSET_TRACK_STRATEGIES');
        FETCH okl_pflv_atsv_fk_csr INTO l_okl_pflv_atsv_fk;
        l_row_notfound := okl_pflv_atsv_fk_csr%NOTFOUND;
        CLOSE okl_pflv_atsv_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ASSET_TRACK_STRATEGY_CODE');
          l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
      END IF;


      -- store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
      END IF;


      IF ((p_pflv_rec.FMA_ID IS NOT NULL)
       AND
          (p_pflv_rec.FMA_ID <> p_db_pflv_rec.FMA_ID))
      THEN
        OPEN okl_pflv_fmav_fk_csr (p_pflv_rec.FMA_ID);
        FETCH okl_pflv_fmav_fk_csr INTO l_okl_pflv_fmav_fk;
        l_row_notfound := okl_pflv_fmav_fk_csr%NOTFOUND;
        CLOSE okl_pflv_fmav_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'FMA_ID');
          l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      -- store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
      END IF;

      IF ((p_pflv_rec.KLE_ID IS NOT NULL)
       AND
          (p_pflv_rec.KLE_ID <> p_db_pflv_rec.KLE_ID))
      THEN
        OPEN okl_pflv_klev_fk_csr (p_pflv_rec.KLE_ID);
        FETCH okl_pflv_klev_fk_csr INTO l_okl_pflv_klev_fk;
        l_row_notfound := okl_pflv_klev_fk_csr%NOTFOUND;
        CLOSE okl_pflv_klev_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KLE_ID');
          l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      -- store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
      END IF;

      IF ((p_pflv_rec.PFC_ID IS NOT NULL)
       AND
          (p_pflv_rec.PFC_ID <> p_db_pflv_rec.PFC_ID))
      THEN
        OPEN okl_pflv_pfcv_fk_csr (p_pflv_rec.PFC_ID);
        FETCH okl_pflv_pfcv_fk_csr INTO l_okl_pflv_pfcv_fk;
        l_row_notfound := okl_pflv_pfcv_fk_csr%NOTFOUND;
        CLOSE okl_pflv_pfcv_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PFC_ID');
          l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      -- store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
      END IF;

      IF ((p_pflv_rec.TRX_STATUS_CODE IS NOT NULL)
       AND
          (p_pflv_rec.TRX_STATUS_CODE <> p_db_pflv_rec.TRX_STATUS_CODE))
      THEN
        -- PAGARG 16-Aug-2004 3832404: Passing lookup_type as parameter
        OPEN okl_pflv_tsuv_fk_csr (p_pflv_rec.TRX_STATUS_CODE, 'OKL_TRANSACTION_STATUS');
        FETCH okl_pflv_tsuv_fk_csr INTO l_okl_pflv_tsuv_fk;
        l_row_notfound := okl_pflv_tsuv_fk_csr%NOTFOUND;
        CLOSE okl_pflv_tsuv_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TRX_STATUS_CODE');
          l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      -- store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
      END IF;


      RETURN (x_return_status);
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

    END validate_foreign_keys;
  BEGIN

    -- RABHUPAT - 2667636 - Start
    -- Validate Currency conversion Code,type,rate and Date

    validate_currency_record(p_pflv_rec      => p_pflv_rec,
                                 x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

  -- RABHUPAT - 2667636 - End
  l_return_status := validate_foreign_keys(p_pflv_rec, p_db_pflv_rec);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    RETURN (x_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_pflv_rec IN pflv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_pflv_rec                  pflv_rec_type := get_rec(p_pflv_rec);
  BEGIN
    l_return_status := Validate_Record(p_pflv_rec => p_pflv_rec,
                                       p_db_pflv_rec => l_db_pflv_rec);


    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate
  -- Description     : from _V to _B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE migrate (
    p_from IN pflv_rec_type,
    p_to   IN OUT NOCOPY pfl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.budget_amount := p_from.budget_amount;
    p_to.date_strategy_executed := p_from.date_strategy_executed;
    p_to.date_strategy_execution_due := p_from.date_strategy_execution_due;
    p_to.date_budget_amount_last_review := p_from.date_budget_amount_last_review;
    p_to.trx_status_code := p_from.trx_status_code;
    p_to.asset_track_strategy_code := p_from.asset_track_strategy_code;
    p_to.pfc_id := p_from.pfc_id;
    p_to.tmb_id := p_from.tmb_id;
    p_to.kle_id := p_from.kle_id;
    p_to.fma_id := p_from.fma_id;
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
  -- RABHUPAT - 2667636 - Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- RABHUPAT - 2667636 - End
  END migrate;

  -- Start of comments
  --
  -- Procedure Name  : Migrate
  -- Description     : from _B to _V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE migrate (
    p_from IN pfl_rec_type,
    p_to   IN OUT NOCOPY pflv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.budget_amount := p_from.budget_amount;
    p_to.date_strategy_executed := p_from.date_strategy_executed;
    p_to.date_strategy_execution_due := p_from.date_strategy_execution_due;
    p_to.date_budget_amount_last_review := p_from.date_budget_amount_last_review;
    p_to.trx_status_code := p_from.trx_status_code;
    p_to.asset_track_strategy_code := p_from.asset_track_strategy_code;
    p_to.pfc_id := p_from.pfc_id;
    p_to.tmb_id := p_from.tmb_id;
    p_to.kle_id := p_from.kle_id;
    p_to.fma_id := p_from.fma_id;
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
  -- RABHUPAT - 2667636 - Start
    p_to.currency_code  := p_from.currency_code;
    p_to.currency_conversion_code  := p_from.currency_conversion_code;
    p_to.currency_conversion_type  := p_from.currency_conversion_type;
    p_to.currency_conversion_rate  := p_from.currency_conversion_rate;
    p_to.currency_conversion_date  := p_from.currency_conversion_date;
  -- RABHUPAT - 2667636 - End
  END migrate;
  PROCEDURE migrate (
    p_from IN pflv_rec_type,
    p_to   IN OUT NOCOPY okl_prtfl_lines_tl_rec_type
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
    p_from IN okl_prtfl_lines_tl_rec_type,
    p_to   IN OUT NOCOPY pflv_rec_type
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
  ----------------------------------------
  -- validate_row for:OKL_PRTFL_LINES_V --
  ----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_rec                     IN pflv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pflv_rec                     pflv_rec_type := p_pflv_rec;
    l_pfl_rec                      pfl_rec_type;
    l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_pflv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pflv_rec);
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
  ---------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_PRTFL_LINES_V --
  ---------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pflv_tbl.COUNT > 0) THEN
      i := p_pflv_tbl.FIRST;
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
            p_pflv_rec                     => p_pflv_tbl(i));
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
        EXIT WHEN (i = p_pflv_tbl.LAST);
        i := p_pflv_tbl.NEXT(i);
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

  ---------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_PRTFL_LINES_V --
  ---------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pflv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pflv_tbl                     => p_pflv_tbl,
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
  --------------------------------------
  -- insert_row for:OKL_PRTFL_LINES_B --
  --------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : for OKL_PRTFL_LINES_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfl_rec                      IN pfl_rec_type,
    x_pfl_rec                      OUT NOCOPY pfl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfl_rec                      pfl_rec_type := p_pfl_rec;
    l_def_pfl_rec                  pfl_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_LINES_B --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_pfl_rec IN pfl_rec_type,
      x_pfl_rec OUT NOCOPY pfl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pfl_rec := p_pfl_rec;
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
      p_pfl_rec,                         -- IN
      l_pfl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PRTFL_LINES_B(
      id,
      budget_amount,
      date_strategy_executed,
      date_strategy_execution_due,
      date_budget_amount_last_review,
      trx_status_code,
      asset_track_strategy_code,
      pfc_id,
      tmb_id,
      kle_id,
      fma_id,
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
      last_update_login,
  -- RABHUPAT - 2667636 - Start
        currency_code,
        currency_conversion_code,
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date)
  -- RABHUPAT - 2667636 - End
    VALUES (
      l_pfl_rec.id,
      l_pfl_rec.budget_amount,
      l_pfl_rec.date_strategy_executed,
      l_pfl_rec.date_strategy_execution_due,
      l_pfl_rec.date_budget_amount_last_review,
      l_pfl_rec.trx_status_code,
      l_pfl_rec.asset_track_strategy_code,
      l_pfl_rec.pfc_id,
      l_pfl_rec.tmb_id,
      l_pfl_rec.kle_id,
      l_pfl_rec.fma_id,
      l_pfl_rec.object_version_number,
      l_pfl_rec.request_id,
      l_pfl_rec.program_application_id,
      l_pfl_rec.program_id,
      l_pfl_rec.program_update_date,
      l_pfl_rec.attribute_category,
      l_pfl_rec.attribute1,
      l_pfl_rec.attribute2,
      l_pfl_rec.attribute3,
      l_pfl_rec.attribute4,
      l_pfl_rec.attribute5,
      l_pfl_rec.attribute6,
      l_pfl_rec.attribute7,
      l_pfl_rec.attribute8,
      l_pfl_rec.attribute9,
      l_pfl_rec.attribute10,
      l_pfl_rec.attribute11,
      l_pfl_rec.attribute12,
      l_pfl_rec.attribute13,
      l_pfl_rec.attribute14,
      l_pfl_rec.attribute15,
      l_pfl_rec.created_by,
      l_pfl_rec.creation_date,
      l_pfl_rec.last_updated_by,
      l_pfl_rec.last_update_date,
      l_pfl_rec.last_update_login,
  -- RABHUPAT - 2667636 - Start
      l_pfl_rec.currency_code,
      l_pfl_rec.currency_conversion_code,
      l_pfl_rec.currency_conversion_type,
      l_pfl_rec.currency_conversion_rate,
      l_pfl_rec.currency_conversion_date);
  -- RABHUPAT - 2667636 - End
    -- Set OUT values
    x_pfl_rec := l_pfl_rec;
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
  ---------------------------------------
  -- insert_row for:OKL_PRTFL_LINES_TL --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_prtfl_lines_tl_rec       IN okl_prtfl_lines_tl_rec_type,
    x_okl_prtfl_lines_tl_rec       OUT NOCOPY okl_prtfl_lines_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type := p_okl_prtfl_lines_tl_rec;
    l_def_okl_prtfl_lines_tl_rec   okl_prtfl_lines_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_LINES_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_prtfl_lines_tl_rec IN okl_prtfl_lines_tl_rec_type,
      x_okl_prtfl_lines_tl_rec OUT NOCOPY okl_prtfl_lines_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_prtfl_lines_tl_rec := p_okl_prtfl_lines_tl_rec;
      x_okl_prtfl_lines_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_prtfl_lines_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_prtfl_lines_tl_rec,          -- IN
      l_okl_prtfl_lines_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_prtfl_lines_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_PRTFL_LINES_TL(
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
        l_okl_prtfl_lines_tl_rec.id,
        l_okl_prtfl_lines_tl_rec.language,
        l_okl_prtfl_lines_tl_rec.source_lang,
        l_okl_prtfl_lines_tl_rec.sfwt_flag,
        l_okl_prtfl_lines_tl_rec.comments,
        l_okl_prtfl_lines_tl_rec.created_by,
        l_okl_prtfl_lines_tl_rec.creation_date,
        l_okl_prtfl_lines_tl_rec.last_updated_by,
        l_okl_prtfl_lines_tl_rec.last_update_date,
        l_okl_prtfl_lines_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_prtfl_lines_tl_rec := l_okl_prtfl_lines_tl_rec;
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
  ---------------------------------------
  -- insert_row for :OKL_PRTFL_LINES_V --
  ---------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : for OKL_PRTFL_LINES_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_rec                     IN pflv_rec_type,
    x_pflv_rec                     OUT NOCOPY pflv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pflv_rec                     pflv_rec_type := p_pflv_rec;
    l_def_pflv_rec                 pflv_rec_type;
    l_pfl_rec                      pfl_rec_type;
    lx_pfl_rec                     pfl_rec_type;
    l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type;
    lx_okl_prtfl_lines_tl_rec      okl_prtfl_lines_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pflv_rec IN pflv_rec_type
    ) RETURN pflv_rec_type IS
      l_pflv_rec pflv_rec_type := p_pflv_rec;
    BEGIN
      l_pflv_rec.CREATION_DATE := SYSDATE;
      l_pflv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pflv_rec.LAST_UPDATE_DATE := l_pflv_rec.CREATION_DATE;
      l_pflv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pflv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pflv_rec);
    END fill_who_columns;
    ------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_LINES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_pflv_rec IN pflv_rec_type,
      x_pflv_rec OUT NOCOPY pflv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pflv_rec := p_pflv_rec;
      x_pflv_rec.OBJECT_VERSION_NUMBER := 1;
      x_pflv_rec.SFWT_FLAG := 'N';
  -- RABHUPAT - 2667636 - Start
      x_pflv_rec.currency_conversion_code := OKL_AM_UTIL_PVT.get_functional_currency;

      IF p_pflv_rec.currency_code IS NULL
      OR p_pflv_rec.currency_code = OKC_API.G_MISS_CHAR THEN
        x_pflv_rec.currency_code := x_pflv_rec.currency_conversion_code;
      END IF;
  -- RABHUPAT- 2667636 - End
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
    l_pflv_rec := null_out_defaults(p_pflv_rec);
    -- Set primary key value
    l_pflv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_pflv_rec,                        -- IN
      l_def_pflv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pflv_rec := fill_who_columns(l_def_pflv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pflv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pflv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_pflv_rec, l_pfl_rec);
    migrate(l_def_pflv_rec, l_okl_prtfl_lines_tl_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pfl_rec,
      lx_pfl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pfl_rec, l_def_pflv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_prtfl_lines_tl_rec,
      lx_okl_prtfl_lines_tl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_prtfl_lines_tl_rec, l_def_pflv_rec);
    -- Set OUT values
    x_pflv_rec := l_def_pflv_rec;
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
  -- PL/SQL TBL insert_row for:PFLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    x_pflv_tbl                     OUT NOCOPY pflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pflv_tbl.COUNT > 0) THEN
      i := p_pflv_tbl.FIRST;
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
            p_pflv_rec                     => p_pflv_tbl(i),
            x_pflv_rec                     => x_pflv_tbl(i));
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
        EXIT WHEN (i = p_pflv_tbl.LAST);
        i := p_pflv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:PFLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    x_pflv_tbl                     OUT NOCOPY pflv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pflv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pflv_tbl                     => p_pflv_tbl,
        x_pflv_tbl                     => x_pflv_tbl,
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
  ------------------------------------
  -- lock_row for:OKL_PRTFL_LINES_B --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfl_rec                      IN pfl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pfl_rec IN pfl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PRTFL_LINES_B
     WHERE ID = p_pfl_rec.id
       AND OBJECT_VERSION_NUMBER = p_pfl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_pfl_rec IN pfl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PRTFL_LINES_B
     WHERE ID = p_pfl_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_PRTFL_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_PRTFL_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pfl_rec);
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
      OPEN lchk_csr(p_pfl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pfl_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pfl_rec.object_version_number THEN
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
  -------------------------------------
  -- lock_row for:OKL_PRTFL_LINES_TL --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_prtfl_lines_tl_rec       IN okl_prtfl_lines_tl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_prtfl_lines_tl_rec IN okl_prtfl_lines_tl_rec_type) IS
    SELECT *
      FROM OKL_PRTFL_LINES_TL
     WHERE ID = p_okl_prtfl_lines_tl_rec.id
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
      OPEN lock_csr(p_okl_prtfl_lines_tl_rec);
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
  -------------------------------------
  -- lock_row for: OKL_PRTFL_LINES_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_rec                     IN pflv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfl_rec                      pfl_rec_type;
    l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type;
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
    migrate(p_pflv_rec, l_pfl_rec);
    migrate(p_pflv_rec, l_okl_prtfl_lines_tl_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pfl_rec
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
      l_okl_prtfl_lines_tl_rec
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
  -- PL/SQL TBL lock_row for:PFLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_pflv_tbl.COUNT > 0) THEN
      i := p_pflv_tbl.FIRST;
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
            p_pflv_rec                     => p_pflv_tbl(i));
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
        EXIT WHEN (i = p_pflv_tbl.LAST);
        i := p_pflv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:PFLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_pflv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pflv_tbl                     => p_pflv_tbl,
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
  --------------------------------------
  -- update_row for:OKL_PRTFL_LINES_B --
  --------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : for OKL_PRTFL_LINES_B
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfl_rec                      IN pfl_rec_type,
    x_pfl_rec                      OUT NOCOPY pfl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfl_rec                      pfl_rec_type := p_pfl_rec;
    l_def_pfl_rec                  pfl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pfl_rec IN pfl_rec_type,
      x_pfl_rec OUT NOCOPY pfl_rec_type
    ) RETURN VARCHAR2 IS
      l_pfl_rec                      pfl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pfl_rec := p_pfl_rec;
      -- Get current database values
      l_pfl_rec := get_rec(p_pfl_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_pfl_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.id := l_pfl_rec.id;
        END IF;
        IF (x_pfl_rec.budget_amount = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.budget_amount := l_pfl_rec.budget_amount;
        END IF;
        IF (x_pfl_rec.date_strategy_executed = OKL_API.G_MISS_DATE)
        THEN
          x_pfl_rec.date_strategy_executed := l_pfl_rec.date_strategy_executed;
        END IF;
        IF (x_pfl_rec.date_strategy_execution_due = OKL_API.G_MISS_DATE)
        THEN
          x_pfl_rec.date_strategy_execution_due := l_pfl_rec.date_strategy_execution_due;
        END IF;
        IF (x_pfl_rec.date_budget_amount_last_review = OKL_API.G_MISS_DATE)
        THEN
          x_pfl_rec.date_budget_amount_last_review := l_pfl_rec.date_budget_amount_last_review;
        END IF;
        IF (x_pfl_rec.trx_status_code = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.trx_status_code := l_pfl_rec.trx_status_code;
        END IF;
        IF (x_pfl_rec.asset_track_strategy_code = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.asset_track_strategy_code := l_pfl_rec.asset_track_strategy_code;
        END IF;
        IF (x_pfl_rec.pfc_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.pfc_id := l_pfl_rec.pfc_id;
        END IF;
        IF (x_pfl_rec.tmb_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.tmb_id := l_pfl_rec.tmb_id;
        END IF;
        IF (x_pfl_rec.kle_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.kle_id := l_pfl_rec.kle_id;
        END IF;
        IF (x_pfl_rec.fma_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.fma_id := l_pfl_rec.fma_id;
        END IF;
        IF (x_pfl_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.object_version_number := l_pfl_rec.object_version_number;
        END IF;
        IF (x_pfl_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.request_id := l_pfl_rec.request_id;
        END IF;
        IF (x_pfl_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.program_application_id := l_pfl_rec.program_application_id;
        END IF;
        IF (x_pfl_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.program_id := l_pfl_rec.program_id;
        END IF;
        IF (x_pfl_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pfl_rec.program_update_date := l_pfl_rec.program_update_date;
        END IF;
        IF (x_pfl_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute_category := l_pfl_rec.attribute_category;
        END IF;
        IF (x_pfl_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute1 := l_pfl_rec.attribute1;
        END IF;
        IF (x_pfl_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute2 := l_pfl_rec.attribute2;
        END IF;
        IF (x_pfl_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute3 := l_pfl_rec.attribute3;
        END IF;
        IF (x_pfl_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute4 := l_pfl_rec.attribute4;
        END IF;
        IF (x_pfl_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute5 := l_pfl_rec.attribute5;
        END IF;
        IF (x_pfl_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute6 := l_pfl_rec.attribute6;
        END IF;
        IF (x_pfl_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute7 := l_pfl_rec.attribute7;
        END IF;
        IF (x_pfl_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute8 := l_pfl_rec.attribute8;
        END IF;
        IF (x_pfl_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute9 := l_pfl_rec.attribute9;
        END IF;
        IF (x_pfl_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute10 := l_pfl_rec.attribute10;
        END IF;
        IF (x_pfl_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute11 := l_pfl_rec.attribute11;
        END IF;
        IF (x_pfl_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute12 := l_pfl_rec.attribute12;
        END IF;
        IF (x_pfl_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute13 := l_pfl_rec.attribute13;
        END IF;
        IF (x_pfl_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute14 := l_pfl_rec.attribute14;
        END IF;
        IF (x_pfl_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_pfl_rec.attribute15 := l_pfl_rec.attribute15;
        END IF;
        IF (x_pfl_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.created_by := l_pfl_rec.created_by;
        END IF;
        IF (x_pfl_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_pfl_rec.creation_date := l_pfl_rec.creation_date;
        END IF;
        IF (x_pfl_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.last_updated_by := l_pfl_rec.last_updated_by;
        END IF;
        IF (x_pfl_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pfl_rec.last_update_date := l_pfl_rec.last_update_date;
        END IF;
        IF (x_pfl_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_pfl_rec.last_update_login := l_pfl_rec.last_update_login;
        END IF;
      END IF;
  -- RABHUPAT - 2667636 - Start
     IF (x_pfl_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pfl_rec.currency_code := l_pfl_rec.currency_code;
      END IF;
      IF (x_pfl_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pfl_rec.currency_conversion_code := l_pfl_rec.currency_conversion_code;
      END IF;
      IF (x_pfl_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_pfl_rec.currency_conversion_type := l_pfl_rec.currency_conversion_type;
      END IF;
      IF (x_pfl_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_pfl_rec.currency_conversion_rate := l_pfl_rec.currency_conversion_rate;
      END IF;
      IF (x_pfl_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_pfl_rec.currency_conversion_date := l_pfl_rec.currency_conversion_date;
      END IF;
  -- RABHUPAT - 2667636 - End
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_LINES_B --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_pfl_rec IN pfl_rec_type,
      x_pfl_rec OUT NOCOPY pfl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pfl_rec := p_pfl_rec;
      x_pfl_rec.OBJECT_VERSION_NUMBER := p_pfl_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_pfl_rec,                         -- IN
      l_pfl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pfl_rec, l_def_pfl_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_PRTFL_LINES_B
    SET BUDGET_AMOUNT = l_def_pfl_rec.budget_amount,
        DATE_STRATEGY_EXECUTED = l_def_pfl_rec.date_strategy_executed,
        DATE_STRATEGY_EXECUTION_DUE = l_def_pfl_rec.date_strategy_execution_due,
        DATE_BUDGET_AMOUNT_LAST_REVIEW = l_def_pfl_rec.date_budget_amount_last_review,
        TRX_STATUS_CODE = l_def_pfl_rec.trx_status_code,
        ASSET_TRACK_STRATEGY_CODE = l_def_pfl_rec.asset_track_strategy_code,
        PFC_ID = l_def_pfl_rec.pfc_id,
        TMB_ID = l_def_pfl_rec.tmb_id,
        KLE_ID = l_def_pfl_rec.kle_id,
        FMA_ID = l_def_pfl_rec.fma_id,
        OBJECT_VERSION_NUMBER = l_def_pfl_rec.object_version_number,
        REQUEST_ID = l_def_pfl_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_pfl_rec.program_application_id,
        PROGRAM_ID = l_def_pfl_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_pfl_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_pfl_rec.attribute_category,
        ATTRIBUTE1 = l_def_pfl_rec.attribute1,
        ATTRIBUTE2 = l_def_pfl_rec.attribute2,
        ATTRIBUTE3 = l_def_pfl_rec.attribute3,
        ATTRIBUTE4 = l_def_pfl_rec.attribute4,
        ATTRIBUTE5 = l_def_pfl_rec.attribute5,
        ATTRIBUTE6 = l_def_pfl_rec.attribute6,
        ATTRIBUTE7 = l_def_pfl_rec.attribute7,
        ATTRIBUTE8 = l_def_pfl_rec.attribute8,
        ATTRIBUTE9 = l_def_pfl_rec.attribute9,
        ATTRIBUTE10 = l_def_pfl_rec.attribute10,
        ATTRIBUTE11 = l_def_pfl_rec.attribute11,
        ATTRIBUTE12 = l_def_pfl_rec.attribute12,
        ATTRIBUTE13 = l_def_pfl_rec.attribute13,
        ATTRIBUTE14 = l_def_pfl_rec.attribute14,
        ATTRIBUTE15 = l_def_pfl_rec.attribute15,
        CREATED_BY = l_def_pfl_rec.created_by,
        CREATION_DATE = l_def_pfl_rec.creation_date,
        LAST_UPDATED_BY = l_def_pfl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pfl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pfl_rec.last_update_login,
  -- RABHUPAT - 2667636 - Start
        CURRENCY_CODE = l_def_pfl_rec.currency_code,
        CURRENCY_CONVERSION_CODE = l_def_pfl_rec.currency_conversion_code,
        CURRENCY_CONVERSION_TYPE = l_def_pfl_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_pfl_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_pfl_rec.currency_conversion_date
  -- RABHUPAT - 2667636 - End
    WHERE ID = l_def_pfl_rec.id;

    x_pfl_rec := l_pfl_rec;
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
  ---------------------------------------
  -- update_row for:OKL_PRTFL_LINES_TL --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_prtfl_lines_tl_rec       IN okl_prtfl_lines_tl_rec_type,
    x_okl_prtfl_lines_tl_rec       OUT NOCOPY okl_prtfl_lines_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type := p_okl_prtfl_lines_tl_rec;
    l_def_okl_prtfl_lines_tl_rec   okl_prtfl_lines_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_prtfl_lines_tl_rec IN okl_prtfl_lines_tl_rec_type,
      x_okl_prtfl_lines_tl_rec OUT NOCOPY okl_prtfl_lines_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_prtfl_lines_tl_rec := p_okl_prtfl_lines_tl_rec;
      -- Get current database values
      l_okl_prtfl_lines_tl_rec := get_rec(p_okl_prtfl_lines_tl_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_okl_prtfl_lines_tl_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_okl_prtfl_lines_tl_rec.id := l_okl_prtfl_lines_tl_rec.id;
        END IF;
        IF (x_okl_prtfl_lines_tl_rec.language = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_prtfl_lines_tl_rec.language := l_okl_prtfl_lines_tl_rec.language;
        END IF;
        IF (x_okl_prtfl_lines_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_prtfl_lines_tl_rec.source_lang := l_okl_prtfl_lines_tl_rec.source_lang;
        END IF;
        IF (x_okl_prtfl_lines_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_prtfl_lines_tl_rec.sfwt_flag := l_okl_prtfl_lines_tl_rec.sfwt_flag;
        END IF;
        IF (x_okl_prtfl_lines_tl_rec.comments = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_prtfl_lines_tl_rec.comments := l_okl_prtfl_lines_tl_rec.comments;
        END IF;
        IF (x_okl_prtfl_lines_tl_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_okl_prtfl_lines_tl_rec.created_by := l_okl_prtfl_lines_tl_rec.created_by;
        END IF;
        IF (x_okl_prtfl_lines_tl_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_okl_prtfl_lines_tl_rec.creation_date := l_okl_prtfl_lines_tl_rec.creation_date;
        END IF;
        IF (x_okl_prtfl_lines_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_okl_prtfl_lines_tl_rec.last_updated_by := l_okl_prtfl_lines_tl_rec.last_updated_by;
        END IF;
        IF (x_okl_prtfl_lines_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_okl_prtfl_lines_tl_rec.last_update_date := l_okl_prtfl_lines_tl_rec.last_update_date;
        END IF;
        IF (x_okl_prtfl_lines_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_okl_prtfl_lines_tl_rec.last_update_login := l_okl_prtfl_lines_tl_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_LINES_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_prtfl_lines_tl_rec IN okl_prtfl_lines_tl_rec_type,
      x_okl_prtfl_lines_tl_rec OUT NOCOPY okl_prtfl_lines_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_prtfl_lines_tl_rec := p_okl_prtfl_lines_tl_rec;
      x_okl_prtfl_lines_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_prtfl_lines_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_prtfl_lines_tl_rec,          -- IN
      l_okl_prtfl_lines_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_prtfl_lines_tl_rec, l_def_okl_prtfl_lines_tl_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_PRTFL_LINES_TL
    SET COMMENTS = l_def_okl_prtfl_lines_tl_rec.comments,
        SOURCE_LANG = l_def_okl_prtfl_lines_tl_rec.source_lang, --Fix for bug 3637102
        CREATED_BY = l_def_okl_prtfl_lines_tl_rec.created_by,
        CREATION_DATE = l_def_okl_prtfl_lines_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_prtfl_lines_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_prtfl_lines_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_prtfl_lines_tl_rec.last_update_login
    WHERE ID = l_def_okl_prtfl_lines_tl_rec.id
        AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE); --Fix for 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKL_PRTFL_LINES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_prtfl_lines_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_prtfl_lines_tl_rec := l_okl_prtfl_lines_tl_rec;
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
  -- update_row for:OKL_PRTFL_LINES_V --
  --------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : for OKL_PRTFL_LINES_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RABHUPAT 17-DEC-2002 2667636
  --                 : modified for multicurrency changes
  -- End of comments
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_rec                     IN pflv_rec_type,
    x_pflv_rec                     OUT NOCOPY pflv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pflv_rec                     pflv_rec_type := p_pflv_rec;
    l_def_pflv_rec                 pflv_rec_type;
    l_db_pflv_rec                  pflv_rec_type;
    l_pfl_rec                      pfl_rec_type;
    lx_pfl_rec                     pfl_rec_type;
    l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type;
    lx_okl_prtfl_lines_tl_rec      okl_prtfl_lines_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pflv_rec IN pflv_rec_type
    ) RETURN pflv_rec_type IS
      l_pflv_rec pflv_rec_type := p_pflv_rec;
    BEGIN
      l_pflv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pflv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pflv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pflv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pflv_rec IN pflv_rec_type,
      x_pflv_rec OUT NOCOPY pflv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pflv_rec := p_pflv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_pflv_rec := get_rec(p_pflv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_pflv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.id := l_db_pflv_rec.id;
        END IF;
        IF (x_pflv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.sfwt_flag := l_db_pflv_rec.sfwt_flag;
        END IF;
-- Added for object version compatibility for now
        IF (x_pflv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.object_version_number := l_db_pflv_rec.object_version_number;
        END IF;


        IF (x_pflv_rec.budget_amount = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.budget_amount := l_db_pflv_rec.budget_amount;
        END IF;
        IF (x_pflv_rec.date_strategy_executed = OKL_API.G_MISS_DATE)
        THEN
          x_pflv_rec.date_strategy_executed := l_db_pflv_rec.date_strategy_executed;
        END IF;
        IF (x_pflv_rec.date_strategy_execution_due = OKL_API.G_MISS_DATE)
        THEN
          x_pflv_rec.date_strategy_execution_due := l_db_pflv_rec.date_strategy_execution_due;
        END IF;
        IF (x_pflv_rec.date_budget_amount_last_review = OKL_API.G_MISS_DATE)
        THEN
          x_pflv_rec.date_budget_amount_last_review := l_db_pflv_rec.date_budget_amount_last_review;
        END IF;
        IF (x_pflv_rec.trx_status_code = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.trx_status_code := l_db_pflv_rec.trx_status_code;
        END IF;
        IF (x_pflv_rec.asset_track_strategy_code = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.asset_track_strategy_code := l_db_pflv_rec.asset_track_strategy_code;
        END IF;
        IF (x_pflv_rec.pfc_id = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.pfc_id := l_db_pflv_rec.pfc_id;
        END IF;
        IF (x_pflv_rec.tmb_id = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.tmb_id := l_db_pflv_rec.tmb_id;
        END IF;
        IF (x_pflv_rec.kle_id = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.kle_id := l_db_pflv_rec.kle_id;
        END IF;
        IF (x_pflv_rec.fma_id = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.fma_id := l_db_pflv_rec.fma_id;
        END IF;
        IF (x_pflv_rec.comments = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.comments := l_db_pflv_rec.comments;
        END IF;
        IF (x_pflv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.request_id := l_db_pflv_rec.request_id;
        END IF;
        IF (x_pflv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.program_application_id := l_db_pflv_rec.program_application_id;
        END IF;
        IF (x_pflv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.program_id := l_db_pflv_rec.program_id;
        END IF;
        IF (x_pflv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pflv_rec.program_update_date := l_db_pflv_rec.program_update_date;
        END IF;
        IF (x_pflv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute_category := l_db_pflv_rec.attribute_category;
        END IF;
        IF (x_pflv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute1 := l_db_pflv_rec.attribute1;
        END IF;
        IF (x_pflv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute2 := l_db_pflv_rec.attribute2;
        END IF;
        IF (x_pflv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute3 := l_db_pflv_rec.attribute3;
        END IF;
        IF (x_pflv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute4 := l_db_pflv_rec.attribute4;
        END IF;
        IF (x_pflv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute5 := l_db_pflv_rec.attribute5;
        END IF;
        IF (x_pflv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute6 := l_db_pflv_rec.attribute6;
        END IF;
        IF (x_pflv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute7 := l_db_pflv_rec.attribute7;
        END IF;
        IF (x_pflv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute8 := l_db_pflv_rec.attribute8;
        END IF;
        IF (x_pflv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute9 := l_db_pflv_rec.attribute9;
        END IF;
        IF (x_pflv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute10 := l_db_pflv_rec.attribute10;
        END IF;
        IF (x_pflv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute11 := l_db_pflv_rec.attribute11;
        END IF;
        IF (x_pflv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute12 := l_db_pflv_rec.attribute12;
        END IF;
        IF (x_pflv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute13 := l_db_pflv_rec.attribute13;
        END IF;
        IF (x_pflv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute14 := l_db_pflv_rec.attribute14;
        END IF;
        IF (x_pflv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_pflv_rec.attribute15 := l_db_pflv_rec.attribute15;
        END IF;
        IF (x_pflv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.created_by := l_db_pflv_rec.created_by;
        END IF;
        IF (x_pflv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_pflv_rec.creation_date := l_db_pflv_rec.creation_date;
        END IF;
        IF (x_pflv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.last_updated_by := l_db_pflv_rec.last_updated_by;
        END IF;
        IF (x_pflv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pflv_rec.last_update_date := l_db_pflv_rec.last_update_date;
        END IF;
        IF (x_pflv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_pflv_rec.last_update_login := l_db_pflv_rec.last_update_login;
        END IF;
  -- RABHUPAT - 2667636 - Start
     IF (x_pflv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pflv_rec.currency_code := l_db_pflv_rec.currency_code;
      END IF;
      IF (x_pflv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pflv_rec.currency_conversion_code := l_db_pflv_rec.currency_conversion_code;
      END IF;
      IF (x_pflv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_pflv_rec.currency_conversion_type := l_db_pflv_rec.currency_conversion_type;
      END IF;
      IF (x_pflv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_pflv_rec.currency_conversion_rate := l_db_pflv_rec.currency_conversion_rate;
      END IF;
      IF (x_pflv_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_pflv_rec.currency_conversion_date := l_db_pflv_rec.currency_conversion_date;
      END IF;
  -- RABHUPAT - 2667636 - End
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_PRTFL_LINES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_pflv_rec IN pflv_rec_type,
      x_pflv_rec OUT NOCOPY pflv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pflv_rec := p_pflv_rec;
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
      p_pflv_rec,                        -- IN
      x_pflv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pflv_rec, l_def_pflv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pflv_rec := fill_who_columns(l_def_pflv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pflv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pflv_rec, l_db_pflv_rec);
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
      p_pflv_rec                     => p_pflv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_pflv_rec, l_pfl_rec);
    migrate(l_def_pflv_rec, l_okl_prtfl_lines_tl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pfl_rec,
      lx_pfl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pfl_rec, l_def_pflv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_prtfl_lines_tl_rec,
      lx_okl_prtfl_lines_tl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_prtfl_lines_tl_rec, l_def_pflv_rec);
    x_pflv_rec := l_def_pflv_rec;
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
  -- PL/SQL TBL update_row for:pflv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    x_pflv_tbl                     OUT NOCOPY pflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pflv_tbl.COUNT > 0) THEN
      i := p_pflv_tbl.FIRST;
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
            p_pflv_rec                     => p_pflv_tbl(i),
            x_pflv_rec                     => x_pflv_tbl(i));
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
        EXIT WHEN (i = p_pflv_tbl.LAST);
        i := p_pflv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:PFLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    x_pflv_tbl                     OUT NOCOPY pflv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pflv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pflv_tbl                     => p_pflv_tbl,
        x_pflv_tbl                     => x_pflv_tbl,
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
  --------------------------------------
  -- delete_row for:OKL_PRTFL_LINES_B --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pfl_rec                      IN pfl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pfl_rec                      pfl_rec_type := p_pfl_rec;
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

    DELETE FROM OKL_PRTFL_LINES_B
     WHERE ID = p_pfl_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKL_PRTFL_LINES_TL --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_prtfl_lines_tl_rec       IN okl_prtfl_lines_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type := p_okl_prtfl_lines_tl_rec;
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

    DELETE FROM OKL_PRTFL_LINES_TL
     WHERE ID = p_okl_prtfl_lines_tl_rec.id;

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
  -- delete_row for:OKL_PRTFL_LINES_V --
  --------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_rec                     IN pflv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pflv_rec                     pflv_rec_type := p_pflv_rec;
    l_okl_prtfl_lines_tl_rec       okl_prtfl_lines_tl_rec_type;
    l_pfl_rec                      pfl_rec_type;
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
    migrate(l_pflv_rec, l_okl_prtfl_lines_tl_rec);
    migrate(l_pflv_rec, l_pfl_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_prtfl_lines_tl_rec
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
      l_pfl_rec
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
  -------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_PRTFL_LINES_V --
  -------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pflv_tbl.COUNT > 0) THEN
      i := p_pflv_tbl.FIRST;
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
            p_pflv_rec                     => p_pflv_tbl(i));
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
        EXIT WHEN (i = p_pflv_tbl.LAST);
        i := p_pflv_tbl.NEXT(i);
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

  -------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_PRTFL_LINES_V --
  -------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pflv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pflv_tbl                     => p_pflv_tbl,
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

END OKL_PFL_PVT;

/
