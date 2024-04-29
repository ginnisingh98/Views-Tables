--------------------------------------------------------
--  DDL for Package Body IEX_IEH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_IEH_PVT" AS
/* $Header: IEXSIEHB.pls 120.1 2004/03/17 18:01:47 jsanju ship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

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
  ) RETURN VARCHAR2 AS
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
  FUNCTION get_seq_id RETURN NUMBER AS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc AS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version AS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy AS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language AS
  BEGIN
    DELETE FROM IEX_EXCLUSION_HIST_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM IEX_EXCLUSION_HIST_B B
         WHERE B.EXCLUSION_HISTORY_ID =T.EXCLUSION_HISTORY_ID
        );

    UPDATE IEX_EXCLUSION_HIST_TL T SET(
        EXCLUSION_COMMENT,
        CANCELLATION_COMMENT,
        LANGUAGE) = (SELECT
                                  B.EXCLUSION_COMMENT,
                                  B.CANCELLATION_COMMENT,
                                  B.LANGUAGE
                                FROM IEX_EXCLUSION_HIST_TL B
                               WHERE B.EXCLUSION_HISTORY_ID = T.EXCLUSION_HISTORY_ID)
      WHERE ( T.EXCLUSION_HISTORY_ID)
          IN (SELECT
                  SUBT.EXCLUSION_HISTORY_ID
                FROM IEX_EXCLUSION_HIST_TL SUBB, IEX_EXCLUSION_HIST_TL SUBT
               WHERE SUBB.EXCLUSION_HISTORY_ID = SUBT.EXCLUSION_HISTORY_ID
                 AND (SUBB.EXCLUSION_COMMENT <> SUBT.EXCLUSION_COMMENT
                      OR SUBB.CANCELLATION_COMMENT <> SUBT.CANCELLATION_COMMENT
                      OR SUBB.LANGUAGE <> SUBT.LANGUAGE
                      OR (SUBB.EXCLUSION_COMMENT IS NULL AND SUBT.EXCLUSION_COMMENT IS NOT NULL)
                      OR (SUBB.CANCELLATION_COMMENT IS NULL AND SUBT.CANCELLATION_COMMENT IS NOT NULL)
                      OR (SUBB.LANGUAGE IS NOT NULL AND SUBT.LANGUAGE IS NULL)
              ));

    INSERT INTO IEX_EXCLUSION_HIST_TL (
        EXCLUSION_HISTORY_ID,
        EXCLUSION_COMMENT,
        CANCELLATION_COMMENT,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.EXCLUSION_HISTORY_ID,
            B.EXCLUSION_COMMENT,
            B.CANCELLATION_COMMENT,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM IEX_EXCLUSION_HIST_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM IEX_EXCLUSION_HIST_TL T
                     WHERE T.EXCLUSION_HISTORY_ID = B.EXCLUSION_HISTORY_ID
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: IEX_EXCLUSION_HIST_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_iehv_rec                     IN iehv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN iehv_rec_type AS
    CURSOR iex_exclusion_hist_v_pk_csr (p_exclusion_history_id IN NUMBER) IS
    SELECT
            EXCLUSION_HISTORY_ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            EXCLUSION_REASON,
            EFFECTIVE_START_DATE,
            EFFECTIVE_END_DATE,
            CANCEL_REASON,
            CANCELLED_DATE,
            EXCLUSION_COMMENT,
            CANCELLATION_COMMENT,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
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
      FROM Iex_Exclusion_Hist_V
     WHERE iex_exclusion_hist_v.exclusion_history_id = p_exclusion_history_id;
    l_iex_exclusion_hist_v_pk      iex_exclusion_hist_v_pk_csr%ROWTYPE;
    l_iehv_rec                     iehv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN iex_exclusion_hist_v_pk_csr (p_iehv_rec.exclusion_history_id);
    FETCH iex_exclusion_hist_v_pk_csr INTO
              l_iehv_rec.exclusion_history_id,
              l_iehv_rec.object1_id1,
              l_iehv_rec.object1_id2,
              l_iehv_rec.jtot_object1_code,
              l_iehv_rec.exclusion_reason,
              l_iehv_rec.effective_start_date,
              l_iehv_rec.effective_end_date,
              l_iehv_rec.cancel_reason,
              l_iehv_rec.cancelled_date,
              l_iehv_rec.exclusion_comment,
              l_iehv_rec.cancellation_comment,
              l_iehv_rec.language,
              l_iehv_rec.source_lang,
              l_iehv_rec.sfwt_flag,
              l_iehv_rec.object_version_number,
              l_iehv_rec.org_id,
              l_iehv_rec.attribute_category,
              l_iehv_rec.attribute1,
              l_iehv_rec.attribute2,
              l_iehv_rec.attribute3,
              l_iehv_rec.attribute4,
              l_iehv_rec.attribute5,
              l_iehv_rec.attribute6,
              l_iehv_rec.attribute7,
              l_iehv_rec.attribute8,
              l_iehv_rec.attribute9,
              l_iehv_rec.attribute10,
              l_iehv_rec.attribute11,
              l_iehv_rec.attribute12,
              l_iehv_rec.attribute13,
              l_iehv_rec.attribute14,
              l_iehv_rec.attribute15,
              l_iehv_rec.created_by,
              l_iehv_rec.creation_date,
              l_iehv_rec.last_updated_by,
              l_iehv_rec.last_update_date,
              l_iehv_rec.last_update_login;
    x_no_data_found := iex_exclusion_hist_v_pk_csr%NOTFOUND;
    CLOSE iex_exclusion_hist_v_pk_csr;
    RETURN(l_iehv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_iehv_rec                     IN iehv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN iehv_rec_type AS
    l_iehv_rec                     iehv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_iehv_rec := get_rec(p_iehv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'EXCLUSION_HISTORY_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_iehv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_iehv_rec                     IN iehv_rec_type
  ) RETURN iehv_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_iehv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: IEX_EXCLUSION_HIST_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ieht_rec                     IN ieht_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ieht_rec_type AS
    CURSOR iex_exclusion_hist_tl_pk_csr (p_exclusion_history_id IN NUMBER) IS
    SELECT
            EXCLUSION_HISTORY_ID,
            EXCLUSION_COMMENT,
            CANCELLATION_COMMENT,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Iex_Exclusion_Hist_Tl
     WHERE iex_exclusion_hist_tl.exclusion_history_id = p_exclusion_history_id;
    l_iex_exclusion_hist_tl_pk     iex_exclusion_hist_tl_pk_csr%ROWTYPE;
    l_ieht_rec                     ieht_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN iex_exclusion_hist_tl_pk_csr (p_ieht_rec.exclusion_history_id);
    FETCH iex_exclusion_hist_tl_pk_csr INTO
              l_ieht_rec.exclusion_history_id,
              l_ieht_rec.exclusion_comment,
              l_ieht_rec.cancellation_comment,
              l_ieht_rec.language,
              l_ieht_rec.source_lang,
              l_ieht_rec.sfwt_flag,
              l_ieht_rec.created_by,
              l_ieht_rec.creation_date,
              l_ieht_rec.last_updated_by,
              l_ieht_rec.last_update_date,
              l_ieht_rec.last_update_login;
    x_no_data_found := iex_exclusion_hist_tl_pk_csr%NOTFOUND;
    CLOSE iex_exclusion_hist_tl_pk_csr;
    RETURN(l_ieht_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ieht_rec                     IN ieht_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ieht_rec_type AS
    l_ieht_rec                     ieht_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ieht_rec := get_rec(p_ieht_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'EXCLUSION_HISTORY_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ieht_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ieht_rec                     IN ieht_rec_type
  ) RETURN ieht_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ieht_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: IEX_EXCLUSION_HIST_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ieh_rec                      IN ieh_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ieh_rec_type AS
    CURSOR iex_exclusion_hist_b_pk_csr (p_exclusion_history_id IN NUMBER) IS
    SELECT
            EXCLUSION_HISTORY_ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            EXCLUSION_REASON,
            EFFECTIVE_START_DATE,
            EFFECTIVE_END_DATE,
            CANCEL_REASON,
            CANCELLED_DATE,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
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
      FROM Iex_Exclusion_Hist_B
     WHERE iex_exclusion_hist_b.exclusion_history_id = p_exclusion_history_id;
    l_iex_exclusion_hist_b_pk      iex_exclusion_hist_b_pk_csr%ROWTYPE;
    l_ieh_rec                      ieh_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN iex_exclusion_hist_b_pk_csr (p_ieh_rec.exclusion_history_id);
    FETCH iex_exclusion_hist_b_pk_csr INTO
              l_ieh_rec.exclusion_history_id,
              l_ieh_rec.object1_id1,
              l_ieh_rec.object1_id2,
              l_ieh_rec.jtot_object1_code,
              l_ieh_rec.exclusion_reason,
              l_ieh_rec.effective_start_date,
              l_ieh_rec.effective_end_date,
              l_ieh_rec.cancel_reason,
              l_ieh_rec.cancelled_date,
              l_ieh_rec.object_version_number,
              l_ieh_rec.org_id,
              l_ieh_rec.attribute_category,
              l_ieh_rec.attribute1,
              l_ieh_rec.attribute2,
              l_ieh_rec.attribute3,
              l_ieh_rec.attribute4,
              l_ieh_rec.attribute5,
              l_ieh_rec.attribute6,
              l_ieh_rec.attribute7,
              l_ieh_rec.attribute8,
              l_ieh_rec.attribute9,
              l_ieh_rec.attribute10,
              l_ieh_rec.attribute11,
              l_ieh_rec.attribute12,
              l_ieh_rec.attribute13,
              l_ieh_rec.attribute14,
              l_ieh_rec.attribute15,
              l_ieh_rec.created_by,
              l_ieh_rec.creation_date,
              l_ieh_rec.last_updated_by,
              l_ieh_rec.last_update_date,
              l_ieh_rec.last_update_login;
    x_no_data_found := iex_exclusion_hist_b_pk_csr%NOTFOUND;
    CLOSE iex_exclusion_hist_b_pk_csr;
    RETURN(l_ieh_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ieh_rec                      IN ieh_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ieh_rec_type AS
    l_ieh_rec                      ieh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ieh_rec := get_rec(p_ieh_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'EXCLUSION_HISTORY_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ieh_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ieh_rec                      IN ieh_rec_type
  ) RETURN ieh_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ieh_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: IEX_EXCLUSION_HIST_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_iehv_rec   IN iehv_rec_type
  ) RETURN iehv_rec_type AS
    l_iehv_rec                     iehv_rec_type := p_iehv_rec;
  BEGIN
    IF (l_iehv_rec.exclusion_history_id = OKC_API.G_MISS_NUM ) THEN
      l_iehv_rec.exclusion_history_id := NULL;
    END IF;
    IF (l_iehv_rec.object1_id1 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.object1_id1 := NULL;
    END IF;
    IF (l_iehv_rec.object1_id2 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.object1_id2 := NULL;
    END IF;
    IF (l_iehv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.jtot_object1_code := NULL;
    END IF;
    IF (l_iehv_rec.exclusion_reason = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.exclusion_reason := NULL;
    END IF;
    IF (l_iehv_rec.effective_start_date = OKC_API.G_MISS_DATE ) THEN
      l_iehv_rec.effective_start_date := NULL;
    END IF;
    IF (l_iehv_rec.effective_end_date = OKC_API.G_MISS_DATE ) THEN
      l_iehv_rec.effective_end_date := NULL;
    END IF;
    IF (l_iehv_rec.cancel_reason = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.cancel_reason := NULL;
    END IF;
    IF (l_iehv_rec.cancelled_date = OKC_API.G_MISS_DATE ) THEN
      l_iehv_rec.cancelled_date := NULL;
    END IF;
    IF (l_iehv_rec.exclusion_comment = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.exclusion_comment := NULL;
    END IF;
    IF (l_iehv_rec.cancellation_comment = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.cancellation_comment := NULL;
    END IF;
    IF (l_iehv_rec.language = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.language := NULL;
    END IF;
    IF (l_iehv_rec.source_lang = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.source_lang := NULL;
    END IF;
    IF (l_iehv_rec.sfwt_flag = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_iehv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_iehv_rec.object_version_number := NULL;
    END IF;
    IF (l_iehv_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_iehv_rec.org_id := NULL;
    END IF;
    IF (l_iehv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute_category := NULL;
    END IF;
    IF (l_iehv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute1 := NULL;
    END IF;
    IF (l_iehv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute2 := NULL;
    END IF;
    IF (l_iehv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute3 := NULL;
    END IF;
    IF (l_iehv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute4 := NULL;
    END IF;
    IF (l_iehv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute5 := NULL;
    END IF;
    IF (l_iehv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute6 := NULL;
    END IF;
    IF (l_iehv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute7 := NULL;
    END IF;
    IF (l_iehv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute8 := NULL;
    END IF;
    IF (l_iehv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute9 := NULL;
    END IF;
    IF (l_iehv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute10 := NULL;
    END IF;
    IF (l_iehv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute11 := NULL;
    END IF;
    IF (l_iehv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute12 := NULL;
    END IF;
    IF (l_iehv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute13 := NULL;
    END IF;
    IF (l_iehv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute14 := NULL;
    END IF;
    IF (l_iehv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_iehv_rec.attribute15 := NULL;
    END IF;
    IF (l_iehv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_iehv_rec.created_by := NULL;
    END IF;
    IF (l_iehv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_iehv_rec.creation_date := NULL;
    END IF;
    IF (l_iehv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_iehv_rec.last_updated_by := NULL;
    END IF;
    IF (l_iehv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_iehv_rec.last_update_date := NULL;
    END IF;
    IF (l_iehv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_iehv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_iehv_rec);
  END null_out_defaults;
  ---------------------------------------------------
  -- Validate_Attributes for: EXCLUSION_HISTORY_ID --
  ---------------------------------------------------
  PROCEDURE validate_exclusion_history_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iehv_rec.exclusion_history_id = OKC_API.G_MISS_NUM OR
        p_iehv_rec.exclusion_history_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'exclusion_history_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_exclusion_history_id;
  ------------------------------------------
  -- Validate_Attributes for: OBJECT1_ID1 --
  ------------------------------------------
  PROCEDURE validate_object1_id1(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iehv_rec.object1_id1 = OKC_API.G_MISS_CHAR OR
        p_iehv_rec.object1_id1 IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object1_id1');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object1_id1;
  ------------------------------------------------
  -- Validate_Attributes for: JTOT_OBJECT1_CODE --
  ------------------------------------------------
  PROCEDURE validate_jtot_object1_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iehv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR OR
        p_iehv_rec.jtot_object1_code IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'jtot_object1_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_jtot_object1_code;
  -----------------------------------------------
  -- Validate_Attributes for: EXCLUSION_REASON --
  -----------------------------------------------
  PROCEDURE validate_exclusion_reason(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iehv_rec.exclusion_reason = OKC_API.G_MISS_CHAR OR
        p_iehv_rec.exclusion_reason IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'exclusion_reason');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_exclusion_reason;
  ---------------------------------------------------
  -- Validate_Attributes for: EFFECTIVE_START_DATE --
  ---------------------------------------------------
  PROCEDURE validate_effective_start_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iehv_rec.effective_start_date = OKC_API.G_MISS_DATE OR
        p_iehv_rec.effective_start_date IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'effective_start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_effective_start_date;
  ---------------------------------------
  -- Validate_Attributes for: LANGUAGE --
  ---------------------------------------
  PROCEDURE validate_language(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    /*
    IF (p_iehv_rec.language = OKC_API.G_MISS_CHAR OR
        p_iehv_rec.language IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'language');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    */

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_language;
  ------------------------------------------
  -- Validate_Attributes for: SOURCE_LANG --
  ------------------------------------------
  PROCEDURE validate_source_lang(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    /*
    IF (p_iehv_rec.source_lang = OKC_API.G_MISS_CHAR OR
        p_iehv_rec.source_lang IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_lang');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    */

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_source_lang;
  ----------------------------------------
  -- Validate_Attributes for: SFWT_FLAG --
  ----------------------------------------
  PROCEDURE validate_sfwt_flag(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iehv_rec.sfwt_flag = OKC_API.G_MISS_CHAR OR
        p_iehv_rec.sfwt_flag IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sfwt_flag');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_sfwt_flag;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iehv_rec.object_version_number = OKC_API.G_MISS_NUM OR
        p_iehv_rec.object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:IEX_EXCLUSION_HIST_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_iehv_rec                     IN iehv_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- exclusion_history_id
    -- ***
    validate_exclusion_history_id(l_return_status, p_iehv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- object1_id1
    -- ***
    validate_object1_id1(l_return_status, p_iehv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- jtot_object1_code
    -- ***
    validate_jtot_object1_code(l_return_status, p_iehv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- exclusion_reason
    -- ***
    validate_exclusion_reason(l_return_status, p_iehv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- effective_start_date
    -- ***
    validate_effective_start_date(l_return_status, p_iehv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- language
    -- ***
    validate_language(l_return_status, p_iehv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- source_lang
    -- ***
    validate_source_lang(l_return_status, p_iehv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(l_return_status, p_iehv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(l_return_status, p_iehv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(x_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate Record for:IEX_EXCLUSION_HIST_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_iehv_rec IN iehv_rec_type,
    p_db_iehv_rec IN iehv_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_iehv_rec IN iehv_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_iehv_rec                  iehv_rec_type := get_rec(p_iehv_rec);
  BEGIN
    l_return_status := Validate_Record(p_iehv_rec => p_iehv_rec,
                                       p_db_iehv_rec => l_db_iehv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN iehv_rec_type,
    p_to   IN OUT NOCOPY ieht_rec_type
  ) AS
  BEGIN
    p_to.exclusion_history_id := p_from.exclusion_history_id;
    p_to.exclusion_comment := p_from.exclusion_comment;
    p_to.cancellation_comment := p_from.cancellation_comment;
    p_to.language := p_from.language;
    p_to.source_lang := p_from.source_lang;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN ieht_rec_type,
    p_to   IN OUT NOCOPY iehv_rec_type
  ) AS
  BEGIN
    p_to.exclusion_history_id := p_from.exclusion_history_id;
    p_to.exclusion_comment := p_from.exclusion_comment;
    p_to.cancellation_comment := p_from.cancellation_comment;
    p_to.language := p_from.language;
    p_to.source_lang := p_from.source_lang;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN iehv_rec_type,
    p_to   IN OUT NOCOPY ieh_rec_type
  ) AS
  BEGIN
    p_to.exclusion_history_id := p_from.exclusion_history_id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.exclusion_reason := p_from.exclusion_reason;
    p_to.effective_start_date := p_from.effective_start_date;
    p_to.effective_end_date := p_from.effective_end_date;
    p_to.cancel_reason := p_from.cancel_reason;
    p_to.cancelled_date := p_from.cancelled_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
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
    p_from IN ieh_rec_type,
    p_to   IN OUT NOCOPY iehv_rec_type
  ) AS
  BEGIN
    p_to.exclusion_history_id := p_from.exclusion_history_id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.exclusion_reason := p_from.exclusion_reason;
    p_to.effective_start_date := p_from.effective_start_date;
    p_to.effective_end_date := p_from.effective_end_date;
    p_to.cancel_reason := p_from.cancel_reason;
    p_to.cancelled_date := p_from.cancelled_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
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
  -------------------------------------------
  -- validate_row for:IEX_EXCLUSION_HIST_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iehv_rec                     iehv_rec_type := p_iehv_rec;
    l_ieh_rec                      ieh_rec_type;
    l_ieht_rec                     ieht_rec_type;
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
    l_return_status := Validate_Attributes(l_iehv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_iehv_rec);
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
  ------------------------------------------------------
  -- PL/SQL TBL validate_row for:IEX_EXCLUSION_HIST_V --
  ------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iehv_tbl.COUNT > 0) THEN
      i := p_iehv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
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
            p_iehv_rec                     => p_iehv_tbl(i));
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
        EXIT WHEN (i = p_iehv_tbl.LAST);
        i := p_iehv_tbl.NEXT(i);
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

  ------------------------------------------------------
  -- PL/SQL TBL validate_row for:IEX_EXCLUSION_HIST_V --
  ------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iehv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_iehv_tbl                     => p_iehv_tbl,
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
  -----------------------------------------
  -- insert_row for:IEX_EXCLUSION_HIST_B --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieh_rec                      IN ieh_rec_type,
    x_ieh_rec                      OUT NOCOPY ieh_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieh_rec                      ieh_rec_type := p_ieh_rec;
    l_def_ieh_rec                  ieh_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:IEX_EXCLUSION_HIST_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ieh_rec IN ieh_rec_type,
      x_ieh_rec OUT NOCOPY ieh_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieh_rec := p_ieh_rec;
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
      p_ieh_rec,                         -- IN
      l_ieh_rec);                        -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO IEX_EXCLUSION_HIST_B(
      exclusion_history_id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      exclusion_reason,
      effective_start_date,
      effective_end_date,
      cancel_reason,
      cancelled_date,
      object_version_number,
      org_id,
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
      l_ieh_rec.exclusion_history_id,
      l_ieh_rec.object1_id1,
      l_ieh_rec.object1_id2,
      l_ieh_rec.jtot_object1_code,
      l_ieh_rec.exclusion_reason,
      l_ieh_rec.effective_start_date,
      l_ieh_rec.effective_end_date,
      l_ieh_rec.cancel_reason,
      l_ieh_rec.cancelled_date,
      l_ieh_rec.object_version_number,
      l_ieh_rec.org_id,
      l_ieh_rec.attribute_category,
      l_ieh_rec.attribute1,
      l_ieh_rec.attribute2,
      l_ieh_rec.attribute3,
      l_ieh_rec.attribute4,
      l_ieh_rec.attribute5,
      l_ieh_rec.attribute6,
      l_ieh_rec.attribute7,
      l_ieh_rec.attribute8,
      l_ieh_rec.attribute9,
      l_ieh_rec.attribute10,
      l_ieh_rec.attribute11,
      l_ieh_rec.attribute12,
      l_ieh_rec.attribute13,
      l_ieh_rec.attribute14,
      l_ieh_rec.attribute15,
      l_ieh_rec.created_by,
      l_ieh_rec.creation_date,
      l_ieh_rec.last_updated_by,
      l_ieh_rec.last_update_date,
      l_ieh_rec.last_update_login);
    -- Set OUT NOCOPY values
    x_ieh_rec := l_ieh_rec;
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
  ------------------------------------------
  -- insert_row for:IEX_EXCLUSION_HIST_TL --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieht_rec                     IN ieht_rec_type,
    x_ieht_rec                     OUT NOCOPY ieht_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieht_rec                     ieht_rec_type := p_ieht_rec;
    l_def_ieht_rec                 ieht_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------------
    -- Set_Attributes for:IEX_EXCLUSION_HIST_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ieht_rec IN ieht_rec_type,
      x_ieht_rec OUT NOCOPY ieht_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieht_rec := p_ieht_rec;
      x_ieht_rec.LANGUAGE := USERENV('LANG');
      x_ieht_rec.SOURCE_LANG := USERENV('LANG');
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
      p_ieht_rec,                        -- IN
      l_ieht_rec);                       -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_ieht_rec.language := l_lang_rec.language_code;
      INSERT INTO IEX_EXCLUSION_HIST_TL(
        exclusion_history_id,
        exclusion_comment,
        cancellation_comment,
        language,
        source_lang,
        sfwt_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_ieht_rec.exclusion_history_id,
        l_ieht_rec.exclusion_comment,
        l_ieht_rec.cancellation_comment,
        l_ieht_rec.language,
        l_ieht_rec.source_lang,
        l_ieht_rec.sfwt_flag,
        l_ieht_rec.created_by,
        l_ieht_rec.creation_date,
        l_ieht_rec.last_updated_by,
        l_ieht_rec.last_update_date,
        l_ieht_rec.last_update_login);
    END LOOP;
    -- Set OUT NOCOPY values
    x_ieht_rec := l_ieht_rec;
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
  ------------------------------------------
  -- insert_row for :IEX_EXCLUSION_HIST_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type,
    x_iehv_rec                     OUT NOCOPY iehv_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iehv_rec                     iehv_rec_type := p_iehv_rec;
    l_def_iehv_rec                 iehv_rec_type;
    l_ieh_rec                      ieh_rec_type;
    lx_ieh_rec                     ieh_rec_type;
    l_ieht_rec                     ieht_rec_type;
    lx_ieht_rec                    ieht_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_iehv_rec IN iehv_rec_type
    ) RETURN iehv_rec_type AS
      l_iehv_rec iehv_rec_type := p_iehv_rec;
    BEGIN
      l_iehv_rec.CREATION_DATE := SYSDATE;
      l_iehv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_iehv_rec.LAST_UPDATE_DATE := l_iehv_rec.CREATION_DATE;
      l_iehv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_iehv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_iehv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:IEX_EXCLUSION_HIST_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_iehv_rec IN iehv_rec_type,
      x_iehv_rec OUT NOCOPY iehv_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iehv_rec := p_iehv_rec;
      x_iehv_rec.OBJECT_VERSION_NUMBER := 1;
      x_iehv_rec.SFWT_FLAG := 'N';
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
    l_iehv_rec := null_out_defaults(p_iehv_rec);
    -- Set primary key value
    l_iehv_rec.EXCLUSION_HISTORY_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_iehv_rec,                        -- IN
      l_def_iehv_rec);                   -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_iehv_rec := fill_who_columns(l_def_iehv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_iehv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_iehv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_iehv_rec, l_ieh_rec);
    migrate(l_def_iehv_rec, l_ieht_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ieh_rec,
      lx_ieh_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ieh_rec, l_def_iehv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ieht_rec,
      lx_ieht_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ieht_rec, l_def_iehv_rec);
    -- Set OUT NOCOPY values
    x_iehv_rec := l_def_iehv_rec;
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
  -- PL/SQL TBL insert_row for:IEHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    x_iehv_tbl                     OUT NOCOPY iehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iehv_tbl.COUNT > 0) THEN
      i := p_iehv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
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
            p_iehv_rec                     => p_iehv_tbl(i),
            x_iehv_rec                     => x_iehv_tbl(i));
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
        EXIT WHEN (i = p_iehv_tbl.LAST);
        i := p_iehv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:IEHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    x_iehv_tbl                     OUT NOCOPY iehv_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iehv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_iehv_tbl                     => p_iehv_tbl,
        x_iehv_tbl                     => x_iehv_tbl,
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
  ---------------------------------------
  -- lock_row for:IEX_EXCLUSION_HIST_B --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieh_rec                      IN ieh_rec_type) AS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ieh_rec IN ieh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM IEX_EXCLUSION_HIST_B
     WHERE EXCLUSION_HISTORY_ID = p_ieh_rec.exclusion_history_id
       AND OBJECT_VERSION_NUMBER = p_ieh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_ieh_rec IN ieh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM IEX_EXCLUSION_HIST_B
     WHERE EXCLUSION_HISTORY_ID = p_ieh_rec.exclusion_history_id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        IEX_EXCLUSION_HIST_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       IEX_EXCLUSION_HIST_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ieh_rec);
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
      OPEN lchk_csr(p_ieh_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ieh_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ieh_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for:IEX_EXCLUSION_HIST_TL --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieht_rec                     IN ieht_rec_type) AS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ieht_rec IN ieht_rec_type) IS
    SELECT *
      FROM IEX_EXCLUSION_HIST_TL
     WHERE EXCLUSION_HISTORY_ID = p_ieht_rec.exclusion_history_id
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
      OPEN lock_csr(p_ieht_rec);
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
  ----------------------------------------
  -- lock_row for: IEX_EXCLUSION_HIST_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieht_rec                     ieht_rec_type;
    l_ieh_rec                      ieh_rec_type;
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
    migrate(p_iehv_rec, l_ieht_rec);
    migrate(p_iehv_rec, l_ieh_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ieht_rec
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
      l_ieh_rec
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
  -- PL/SQL TBL lock_row for:IEHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_iehv_tbl.COUNT > 0) THEN
      i := p_iehv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
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
            p_iehv_rec                     => p_iehv_tbl(i));
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
        EXIT WHEN (i = p_iehv_tbl.LAST);
        i := p_iehv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:IEHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_iehv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_iehv_tbl                     => p_iehv_tbl,
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
  -----------------------------------------
  -- update_row for:IEX_EXCLUSION_HIST_B --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieh_rec                      IN ieh_rec_type,
    x_ieh_rec                      OUT NOCOPY ieh_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieh_rec                      ieh_rec_type := p_ieh_rec;
    l_def_ieh_rec                  ieh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ieh_rec IN ieh_rec_type,
      x_ieh_rec OUT NOCOPY ieh_rec_type
    ) RETURN VARCHAR2 AS
      l_ieh_rec                      ieh_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieh_rec := p_ieh_rec;
      -- Get current database values
      l_ieh_rec := get_rec(p_ieh_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ieh_rec.exclusion_history_id = OKC_API.G_MISS_NUM)
        THEN
          x_ieh_rec.exclusion_history_id := l_ieh_rec.exclusion_history_id;
        END IF;
        IF (x_ieh_rec.object1_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.object1_id1 := l_ieh_rec.object1_id1;
        END IF;
        IF (x_ieh_rec.object1_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.object1_id2 := l_ieh_rec.object1_id2;
        END IF;
        IF (x_ieh_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.jtot_object1_code := l_ieh_rec.jtot_object1_code;
        END IF;
        IF (x_ieh_rec.exclusion_reason = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.exclusion_reason := l_ieh_rec.exclusion_reason;
        END IF;
        IF (x_ieh_rec.effective_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieh_rec.effective_start_date := l_ieh_rec.effective_start_date;
        END IF;
        IF (x_ieh_rec.effective_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieh_rec.effective_end_date := l_ieh_rec.effective_end_date;
        END IF;
        IF (x_ieh_rec.cancel_reason = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.cancel_reason := l_ieh_rec.cancel_reason;
        END IF;
        IF (x_ieh_rec.cancelled_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieh_rec.cancelled_date := l_ieh_rec.cancelled_date;
        END IF;
        IF (x_ieh_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_ieh_rec.object_version_number := l_ieh_rec.object_version_number;
        END IF;
        IF (x_ieh_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_ieh_rec.org_id := l_ieh_rec.org_id;
        END IF;
        IF (x_ieh_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute_category := l_ieh_rec.attribute_category;
        END IF;
        IF (x_ieh_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute1 := l_ieh_rec.attribute1;
        END IF;
        IF (x_ieh_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute2 := l_ieh_rec.attribute2;
        END IF;
        IF (x_ieh_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute3 := l_ieh_rec.attribute3;
        END IF;
        IF (x_ieh_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute4 := l_ieh_rec.attribute4;
        END IF;
        IF (x_ieh_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute5 := l_ieh_rec.attribute5;
        END IF;
        IF (x_ieh_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute6 := l_ieh_rec.attribute6;
        END IF;
        IF (x_ieh_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute7 := l_ieh_rec.attribute7;
        END IF;
        IF (x_ieh_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute8 := l_ieh_rec.attribute8;
        END IF;
        IF (x_ieh_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute9 := l_ieh_rec.attribute9;
        END IF;
        IF (x_ieh_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute10 := l_ieh_rec.attribute10;
        END IF;
        IF (x_ieh_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute11 := l_ieh_rec.attribute11;
        END IF;
        IF (x_ieh_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute12 := l_ieh_rec.attribute12;
        END IF;
        IF (x_ieh_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute13 := l_ieh_rec.attribute13;
        END IF;
        IF (x_ieh_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute14 := l_ieh_rec.attribute14;
        END IF;
        IF (x_ieh_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieh_rec.attribute15 := l_ieh_rec.attribute15;
        END IF;
        IF (x_ieh_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ieh_rec.created_by := l_ieh_rec.created_by;
        END IF;
        IF (x_ieh_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieh_rec.creation_date := l_ieh_rec.creation_date;
        END IF;
        IF (x_ieh_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ieh_rec.last_updated_by := l_ieh_rec.last_updated_by;
        END IF;
        IF (x_ieh_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieh_rec.last_update_date := l_ieh_rec.last_update_date;
        END IF;
        IF (x_ieh_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ieh_rec.last_update_login := l_ieh_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:IEX_EXCLUSION_HIST_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ieh_rec IN ieh_rec_type,
      x_ieh_rec OUT NOCOPY ieh_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieh_rec := p_ieh_rec;
      x_ieh_rec.OBJECT_VERSION_NUMBER := p_ieh_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_ieh_rec,                         -- IN
      l_ieh_rec);                        -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ieh_rec, l_def_ieh_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE IEX_EXCLUSION_HIST_B
    SET OBJECT1_ID1 = l_def_ieh_rec.object1_id1,
        OBJECT1_ID2 = l_def_ieh_rec.object1_id2,
        JTOT_OBJECT1_CODE = l_def_ieh_rec.jtot_object1_code,
        EXCLUSION_REASON = l_def_ieh_rec.exclusion_reason,
        EFFECTIVE_START_DATE = l_def_ieh_rec.effective_start_date,
        EFFECTIVE_END_DATE = l_def_ieh_rec.effective_end_date,
        CANCEL_REASON = l_def_ieh_rec.cancel_reason,
        CANCELLED_DATE = l_def_ieh_rec.cancelled_date,
        OBJECT_VERSION_NUMBER = l_def_ieh_rec.object_version_number,
        ORG_ID = l_def_ieh_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_ieh_rec.attribute_category,
        ATTRIBUTE1 = l_def_ieh_rec.attribute1,
        ATTRIBUTE2 = l_def_ieh_rec.attribute2,
        ATTRIBUTE3 = l_def_ieh_rec.attribute3,
        ATTRIBUTE4 = l_def_ieh_rec.attribute4,
        ATTRIBUTE5 = l_def_ieh_rec.attribute5,
        ATTRIBUTE6 = l_def_ieh_rec.attribute6,
        ATTRIBUTE7 = l_def_ieh_rec.attribute7,
        ATTRIBUTE8 = l_def_ieh_rec.attribute8,
        ATTRIBUTE9 = l_def_ieh_rec.attribute9,
        ATTRIBUTE10 = l_def_ieh_rec.attribute10,
        ATTRIBUTE11 = l_def_ieh_rec.attribute11,
        ATTRIBUTE12 = l_def_ieh_rec.attribute12,
        ATTRIBUTE13 = l_def_ieh_rec.attribute13,
        ATTRIBUTE14 = l_def_ieh_rec.attribute14,
        ATTRIBUTE15 = l_def_ieh_rec.attribute15,
        CREATED_BY = l_def_ieh_rec.created_by,
        CREATION_DATE = l_def_ieh_rec.creation_date,
        LAST_UPDATED_BY = l_def_ieh_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ieh_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ieh_rec.last_update_login
    WHERE EXCLUSION_HISTORY_ID = l_def_ieh_rec.exclusion_history_id;

    x_ieh_rec := l_ieh_rec;
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
  ------------------------------------------
  -- update_row for:IEX_EXCLUSION_HIST_TL --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieht_rec                     IN ieht_rec_type,
    x_ieht_rec                     OUT NOCOPY ieht_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieht_rec                     ieht_rec_type := p_ieht_rec;
    l_def_ieht_rec                 ieht_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ieht_rec IN ieht_rec_type,
      x_ieht_rec OUT NOCOPY ieht_rec_type
    ) RETURN VARCHAR2 AS
      l_ieht_rec                     ieht_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieht_rec := p_ieht_rec;
      -- Get current database values
      l_ieht_rec := get_rec(p_ieht_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ieht_rec.exclusion_history_id = OKC_API.G_MISS_NUM)
        THEN
          x_ieht_rec.exclusion_history_id := l_ieht_rec.exclusion_history_id;
        END IF;
        IF (x_ieht_rec.exclusion_comment = OKC_API.G_MISS_CHAR)
        THEN
          x_ieht_rec.exclusion_comment := l_ieht_rec.exclusion_comment;
        END IF;
        IF (x_ieht_rec.cancellation_comment = OKC_API.G_MISS_CHAR)
        THEN
          x_ieht_rec.cancellation_comment := l_ieht_rec.cancellation_comment;
        END IF;
        IF (x_ieht_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_ieht_rec.language := l_ieht_rec.language;
        END IF;
        IF (x_ieht_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_ieht_rec.source_lang := l_ieht_rec.source_lang;
        END IF;
        IF (x_ieht_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_ieht_rec.sfwt_flag := l_ieht_rec.sfwt_flag;
        END IF;
        IF (x_ieht_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ieht_rec.created_by := l_ieht_rec.created_by;
        END IF;
        IF (x_ieht_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieht_rec.creation_date := l_ieht_rec.creation_date;
        END IF;
        IF (x_ieht_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ieht_rec.last_updated_by := l_ieht_rec.last_updated_by;
        END IF;
        IF (x_ieht_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieht_rec.last_update_date := l_ieht_rec.last_update_date;
        END IF;
        IF (x_ieht_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ieht_rec.last_update_login := l_ieht_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:IEX_EXCLUSION_HIST_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ieht_rec IN ieht_rec_type,
      x_ieht_rec OUT NOCOPY ieht_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieht_rec := p_ieht_rec;
      x_ieht_rec.LANGUAGE := USERENV('LANG');
      x_ieht_rec.LANGUAGE := USERENV('LANG');
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
      p_ieht_rec,                        -- IN
      l_ieht_rec);                       -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ieht_rec, l_def_ieht_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE IEX_EXCLUSION_HIST_TL
    SET EXCLUSION_COMMENT = l_def_ieht_rec.exclusion_comment,
        CANCELLATION_COMMENT = l_def_ieht_rec.cancellation_comment,
        CREATED_BY = l_def_ieht_rec.created_by,
        CREATION_DATE = l_def_ieht_rec.creation_date,
        LAST_UPDATED_BY = l_def_ieht_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ieht_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ieht_rec.last_update_login
    WHERE EXCLUSION_HISTORY_ID = l_def_ieht_rec.exclusion_history_id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE IEX_EXCLUSION_HIST_TL
    SET SFWT_FLAG = 'Y'
    WHERE EXCLUSION_HISTORY_ID = l_def_ieht_rec.exclusion_history_id
      AND SOURCE_LANG <> USERENV('LANG');

    x_ieht_rec := l_ieht_rec;
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
  -----------------------------------------
  -- update_row for:IEX_EXCLUSION_HIST_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type,
    x_iehv_rec                     OUT NOCOPY iehv_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iehv_rec                     iehv_rec_type := p_iehv_rec;
    l_def_iehv_rec                 iehv_rec_type;
    l_db_iehv_rec                  iehv_rec_type;
    l_ieh_rec                      ieh_rec_type;
    lx_ieh_rec                     ieh_rec_type;
    l_ieht_rec                     ieht_rec_type;
    lx_ieht_rec                    ieht_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_iehv_rec IN iehv_rec_type
    ) RETURN iehv_rec_type AS
      l_iehv_rec iehv_rec_type := p_iehv_rec;
    BEGIN
      l_iehv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_iehv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_iehv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_iehv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_iehv_rec IN iehv_rec_type,
      x_iehv_rec OUT NOCOPY iehv_rec_type
    ) RETURN VARCHAR2 AS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iehv_rec := p_iehv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_iehv_rec := get_rec(p_iehv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_iehv_rec.exclusion_history_id = OKC_API.G_MISS_NUM)
        THEN
          x_iehv_rec.exclusion_history_id := l_db_iehv_rec.exclusion_history_id;
        END IF;
        IF (x_iehv_rec.object1_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.object1_id1 := l_db_iehv_rec.object1_id1;
        END IF;
        IF (x_iehv_rec.object1_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.object1_id2 := l_db_iehv_rec.object1_id2;
        END IF;
        IF (x_iehv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.jtot_object1_code := l_db_iehv_rec.jtot_object1_code;
        END IF;
        IF (x_iehv_rec.exclusion_reason = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.exclusion_reason := l_db_iehv_rec.exclusion_reason;
        END IF;
        IF (x_iehv_rec.effective_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_iehv_rec.effective_start_date := l_db_iehv_rec.effective_start_date;
        END IF;
        IF (x_iehv_rec.effective_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_iehv_rec.effective_end_date := l_db_iehv_rec.effective_end_date;
        END IF;
        IF (x_iehv_rec.cancel_reason = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.cancel_reason := l_db_iehv_rec.cancel_reason;
        END IF;
        IF (x_iehv_rec.cancelled_date = OKC_API.G_MISS_DATE)
        THEN
          x_iehv_rec.cancelled_date := l_db_iehv_rec.cancelled_date;
        END IF;
        IF (x_iehv_rec.exclusion_comment = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.exclusion_comment := l_db_iehv_rec.exclusion_comment;
        END IF;
        IF (x_iehv_rec.cancellation_comment = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.cancellation_comment := l_db_iehv_rec.cancellation_comment;
        END IF;
        IF (x_iehv_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.language := l_db_iehv_rec.language;
        END IF;
        IF (x_iehv_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.source_lang := l_db_iehv_rec.source_lang;
        END IF;
        IF (x_iehv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.sfwt_flag := l_db_iehv_rec.sfwt_flag;
        END IF;
        IF (x_iehv_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_iehv_rec.org_id := l_db_iehv_rec.org_id;
        END IF;
        IF (x_iehv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute_category := l_db_iehv_rec.attribute_category;
        END IF;
        IF (x_iehv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute1 := l_db_iehv_rec.attribute1;
        END IF;
        IF (x_iehv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute2 := l_db_iehv_rec.attribute2;
        END IF;
        IF (x_iehv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute3 := l_db_iehv_rec.attribute3;
        END IF;
        IF (x_iehv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute4 := l_db_iehv_rec.attribute4;
        END IF;
        IF (x_iehv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute5 := l_db_iehv_rec.attribute5;
        END IF;
        IF (x_iehv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute6 := l_db_iehv_rec.attribute6;
        END IF;
        IF (x_iehv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute7 := l_db_iehv_rec.attribute7;
        END IF;
        IF (x_iehv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute8 := l_db_iehv_rec.attribute8;
        END IF;
        IF (x_iehv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute9 := l_db_iehv_rec.attribute9;
        END IF;
        IF (x_iehv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute10 := l_db_iehv_rec.attribute10;
        END IF;
        IF (x_iehv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute11 := l_db_iehv_rec.attribute11;
        END IF;
        IF (x_iehv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute12 := l_db_iehv_rec.attribute12;
        END IF;
        IF (x_iehv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute13 := l_db_iehv_rec.attribute13;
        END IF;
        IF (x_iehv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute14 := l_db_iehv_rec.attribute14;
        END IF;
        IF (x_iehv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_iehv_rec.attribute15 := l_db_iehv_rec.attribute15;
        END IF;
        IF (x_iehv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_iehv_rec.created_by := l_db_iehv_rec.created_by;
        END IF;
        IF (x_iehv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_iehv_rec.creation_date := l_db_iehv_rec.creation_date;
        END IF;
        IF (x_iehv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_iehv_rec.last_updated_by := l_db_iehv_rec.last_updated_by;
        END IF;
        IF (x_iehv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_iehv_rec.last_update_date := l_db_iehv_rec.last_update_date;
        END IF;
        IF (x_iehv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_iehv_rec.last_update_login := l_db_iehv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:IEX_EXCLUSION_HIST_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_iehv_rec IN iehv_rec_type,
      x_iehv_rec OUT NOCOPY iehv_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iehv_rec := p_iehv_rec;
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
      p_iehv_rec,                        -- IN
      x_iehv_rec);                       -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_iehv_rec, l_def_iehv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_iehv_rec := fill_who_columns(l_def_iehv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_iehv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_iehv_rec, l_db_iehv_rec);
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
      p_iehv_rec                     => p_iehv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_iehv_rec, l_ieh_rec);
    migrate(l_def_iehv_rec, l_ieht_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ieh_rec,
      lx_ieh_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ieh_rec, l_def_iehv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ieht_rec,
      lx_ieht_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ieht_rec, l_def_iehv_rec);
    x_iehv_rec := l_def_iehv_rec;
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
  -- PL/SQL TBL update_row for:iehv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    x_iehv_tbl                     OUT NOCOPY iehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iehv_tbl.COUNT > 0) THEN
      i := p_iehv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
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
            p_iehv_rec                     => p_iehv_tbl(i),
            x_iehv_rec                     => x_iehv_tbl(i));
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
        EXIT WHEN (i = p_iehv_tbl.LAST);
        i := p_iehv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:IEHV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    x_iehv_tbl                     OUT NOCOPY iehv_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iehv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_iehv_tbl                     => p_iehv_tbl,
        x_iehv_tbl                     => x_iehv_tbl,
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
  -----------------------------------------
  -- delete_row for:IEX_EXCLUSION_HIST_B --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieh_rec                      IN ieh_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieh_rec                      ieh_rec_type := p_ieh_rec;
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

    DELETE FROM IEX_EXCLUSION_HIST_B
     WHERE EXCLUSION_HISTORY_ID = p_ieh_rec.exclusion_history_id;

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
  ------------------------------------------
  -- delete_row for:IEX_EXCLUSION_HIST_TL --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieht_rec                     IN ieht_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieht_rec                     ieht_rec_type := p_ieht_rec;
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

    DELETE FROM IEX_EXCLUSION_HIST_TL
     WHERE EXCLUSION_HISTORY_ID = p_ieht_rec.exclusion_history_id;

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
  -----------------------------------------
  -- delete_row for:IEX_EXCLUSION_HIST_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iehv_rec                     iehv_rec_type := p_iehv_rec;
    l_ieht_rec                     ieht_rec_type;
    l_ieh_rec                      ieh_rec_type;
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
    migrate(l_iehv_rec, l_ieht_rec);
    migrate(l_iehv_rec, l_ieh_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ieht_rec
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
      l_ieh_rec
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
  ----------------------------------------------------
  -- PL/SQL TBL delete_row for:IEX_EXCLUSION_HIST_V --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iehv_tbl.COUNT > 0) THEN
      i := p_iehv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
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
            p_iehv_rec                     => p_iehv_tbl(i));
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
        EXIT WHEN (i = p_iehv_tbl.LAST);
        i := p_iehv_tbl.NEXT(i);
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

  ----------------------------------------------------
  -- PL/SQL TBL delete_row for:IEX_EXCLUSION_HIST_V --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iehv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_iehv_tbl                     => p_iehv_tbl,
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

END IEX_IEH_PVT;

/
