--------------------------------------------------------
--  DDL for Package Body IEX_IOH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_IOH_PVT" AS
/* $Header: IEXSIOHB.pls 120.1 2004/03/17 18:00:13 jsanju ship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

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
  -- FUNCTION get_rec for: IEX_OPEN_INT_HST_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_iohv_rec                     IN iohv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN iohv_rec_type IS
    CURSOR iex_iohv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            ACTION,
            STATUS,
            COMMENTS,
            REQUEST_DATE,
            PROCESS_DATE,
            EXT_AGNCY_ID,
            REVIEW_DATE,
            RECALL_DATE,
            AUTOMATIC_RECALL_FLAG,
            REVIEW_BEFORE_RECALL_FLAG,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
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
      FROM Iex_Open_Int_Hst_V
     WHERE iex_open_int_hst_v.id = p_id;
    l_iex_iohv_pk                  iex_iohv_pk_csr%ROWTYPE;
    l_iohv_rec                     iohv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN iex_iohv_pk_csr (p_iohv_rec.id);
    FETCH iex_iohv_pk_csr INTO
              l_iohv_rec.id,
              l_iohv_rec.object1_id1,
              l_iohv_rec.object1_id2,
              l_iohv_rec.jtot_object1_code,
              l_iohv_rec.action,
              l_iohv_rec.status,
              l_iohv_rec.comments,
              l_iohv_rec.request_date,
              l_iohv_rec.process_date,
              l_iohv_rec.ext_agncy_id,
              l_iohv_rec.review_date,
              l_iohv_rec.recall_date,
              l_iohv_rec.automatic_recall_flag,
              l_iohv_rec.review_before_recall_flag,
              l_iohv_rec.object_version_number,
              l_iohv_rec.org_id,
              l_iohv_rec.request_id,
              l_iohv_rec.program_application_id,
              l_iohv_rec.program_id,
              l_iohv_rec.program_update_date,
              l_iohv_rec.attribute_category,
              l_iohv_rec.attribute1,
              l_iohv_rec.attribute2,
              l_iohv_rec.attribute3,
              l_iohv_rec.attribute4,
              l_iohv_rec.attribute5,
              l_iohv_rec.attribute6,
              l_iohv_rec.attribute7,
              l_iohv_rec.attribute8,
              l_iohv_rec.attribute9,
              l_iohv_rec.attribute10,
              l_iohv_rec.attribute11,
              l_iohv_rec.attribute12,
              l_iohv_rec.attribute13,
              l_iohv_rec.attribute14,
              l_iohv_rec.attribute15,
              l_iohv_rec.created_by,
              l_iohv_rec.creation_date,
              l_iohv_rec.last_updated_by,
              l_iohv_rec.last_update_date,
              l_iohv_rec.last_update_login;
    x_no_data_found := iex_iohv_pk_csr%NOTFOUND;
    CLOSE iex_iohv_pk_csr;
    RETURN(l_iohv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_iohv_rec                     IN iohv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN iohv_rec_type IS
    l_iohv_rec                     iohv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_iohv_rec := get_rec(p_iohv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_iohv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_iohv_rec                     IN iohv_rec_type
  ) RETURN iohv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_iohv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: IEX_OPEN_INT_HST
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ioh_rec                      IN ioh_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ioh_rec_type IS
    CURSOR iex_ioh_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            ACTION,
            STATUS,
            COMMENTS,
            REQUEST_DATE,
            PROCESS_DATE,
            EXT_AGNCY_ID,
            REVIEW_DATE,
            RECALL_DATE,
            AUTOMATIC_RECALL_FLAG,
            REVIEW_BEFORE_RECALL_FLAG,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
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
      FROM Iex_Open_Int_Hst
     WHERE iex_open_int_hst.id  = p_id;
    l_iex_ioh_pk                   iex_ioh_pk_csr%ROWTYPE;
    l_ioh_rec                      ioh_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN iex_ioh_pk_csr (p_ioh_rec.id);
    FETCH iex_ioh_pk_csr INTO
              l_ioh_rec.id,
              l_ioh_rec.object1_id1,
              l_ioh_rec.object1_id2,
              l_ioh_rec.jtot_object1_code,
              l_ioh_rec.action,
              l_ioh_rec.status,
              l_ioh_rec.comments,
              l_ioh_rec.request_date,
              l_ioh_rec.process_date,
              l_ioh_rec.ext_agncy_id,
              l_ioh_rec.review_date,
              l_ioh_rec.recall_date,
              l_ioh_rec.automatic_recall_flag,
              l_ioh_rec.review_before_recall_flag,
              l_ioh_rec.object_version_number,
              l_ioh_rec.org_id,
              l_ioh_rec.request_id,
              l_ioh_rec.program_application_id,
              l_ioh_rec.program_id,
              l_ioh_rec.program_update_date,
              l_ioh_rec.attribute_category,
              l_ioh_rec.attribute1,
              l_ioh_rec.attribute2,
              l_ioh_rec.attribute3,
              l_ioh_rec.attribute4,
              l_ioh_rec.attribute5,
              l_ioh_rec.attribute6,
              l_ioh_rec.attribute7,
              l_ioh_rec.attribute8,
              l_ioh_rec.attribute9,
              l_ioh_rec.attribute10,
              l_ioh_rec.attribute11,
              l_ioh_rec.attribute12,
              l_ioh_rec.attribute13,
              l_ioh_rec.attribute14,
              l_ioh_rec.attribute15,
              l_ioh_rec.created_by,
              l_ioh_rec.creation_date,
              l_ioh_rec.last_updated_by,
              l_ioh_rec.last_update_date,
              l_ioh_rec.last_update_login;
    x_no_data_found := iex_ioh_pk_csr%NOTFOUND;
    CLOSE iex_ioh_pk_csr;
    RETURN(l_ioh_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ioh_rec                      IN ioh_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ioh_rec_type IS
    l_ioh_rec                      ioh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ioh_rec := get_rec(p_ioh_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ioh_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ioh_rec                      IN ioh_rec_type
  ) RETURN ioh_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ioh_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: IEX_OPEN_INT_HST_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_iohv_rec   IN iohv_rec_type
  ) RETURN iohv_rec_type IS
    l_iohv_rec                     iohv_rec_type := p_iohv_rec;
  BEGIN
    IF (l_iohv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_iohv_rec.id := NULL;
    END IF;
    IF (l_iohv_rec.object1_id1 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.object1_id1 := NULL;
    END IF;
    IF (l_iohv_rec.object1_id2 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.object1_id2 := NULL;
    END IF;
    IF (l_iohv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.jtot_object1_code := NULL;
    END IF;
    IF (l_iohv_rec.action = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.action := NULL;
    END IF;
    IF (l_iohv_rec.status = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.status := NULL;
    END IF;
    IF (l_iohv_rec.comments = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.comments := NULL;
    END IF;
    IF (l_iohv_rec.request_date = OKC_API.G_MISS_DATE ) THEN
      l_iohv_rec.request_date := NULL;
    END IF;
    IF (l_iohv_rec.process_date = OKC_API.G_MISS_DATE ) THEN
      l_iohv_rec.process_date := NULL;
    END IF;
    IF (l_iohv_rec.ext_agncy_id = OKC_API.G_MISS_NUM ) THEN
      l_iohv_rec.ext_agncy_id := NULL;
    END IF;
    IF (l_iohv_rec.review_date = OKC_API.G_MISS_DATE ) THEN
      l_iohv_rec.review_date := NULL;
    END IF;
    IF (l_iohv_rec.recall_date = OKC_API.G_MISS_DATE ) THEN
      l_iohv_rec.recall_date := NULL;
    END IF;
    IF (l_iohv_rec.automatic_recall_flag = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.automatic_recall_flag := NULL;
    END IF;
    IF (l_iohv_rec.review_before_recall_flag = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.review_before_recall_flag := NULL;
    END IF;
    IF (l_iohv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_iohv_rec.object_version_number := NULL;
    END IF;
    IF (l_iohv_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_iohv_rec.org_id := NULL;
    END IF;
    IF (l_iohv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_iohv_rec.request_id := NULL;
    END IF;
    IF (l_iohv_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_iohv_rec.program_application_id := NULL;
    END IF;
    IF (l_iohv_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_iohv_rec.program_id := NULL;
    END IF;
    IF (l_iohv_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_iohv_rec.program_update_date := NULL;
    END IF;
    IF (l_iohv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute_category := NULL;
    END IF;
    IF (l_iohv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute1 := NULL;
    END IF;
    IF (l_iohv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute2 := NULL;
    END IF;
    IF (l_iohv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute3 := NULL;
    END IF;
    IF (l_iohv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute4 := NULL;
    END IF;
    IF (l_iohv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute5 := NULL;
    END IF;
    IF (l_iohv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute6 := NULL;
    END IF;
    IF (l_iohv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute7 := NULL;
    END IF;
    IF (l_iohv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute8 := NULL;
    END IF;
    IF (l_iohv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute9 := NULL;
    END IF;
    IF (l_iohv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute10 := NULL;
    END IF;
    IF (l_iohv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute11 := NULL;
    END IF;
    IF (l_iohv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute12 := NULL;
    END IF;
    IF (l_iohv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute13 := NULL;
    END IF;
    IF (l_iohv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute14 := NULL;
    END IF;
    IF (l_iohv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_iohv_rec.attribute15 := NULL;
    END IF;
    IF (l_iohv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_iohv_rec.created_by := NULL;
    END IF;
    IF (l_iohv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_iohv_rec.creation_date := NULL;
    END IF;
    IF (l_iohv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_iohv_rec.last_updated_by := NULL;
    END IF;
    IF (l_iohv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_iohv_rec.last_update_date := NULL;
    END IF;
    IF (l_iohv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_iohv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_iohv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iohv_rec.id = OKC_API.G_MISS_NUM OR
        p_iohv_rec.id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
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
  END validate_id;
  ------------------------------------------
  -- Validate_Attributes for: OBJECT1_ID1 --
  ------------------------------------------
  PROCEDURE validate_object1_id1(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iohv_rec.object1_id1 = OKC_API.G_MISS_CHAR OR
        p_iohv_rec.object1_id1 IS NULL)
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
    p_iohv_rec                     IN iohv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iohv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR OR
        p_iohv_rec.jtot_object1_code IS NULL)
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
  -------------------------------------
  -- Validate_Attributes for: ACTION --
  -------------------------------------
  PROCEDURE validate_action(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iohv_rec.action = OKC_API.G_MISS_CHAR OR
        p_iohv_rec.action IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'action');
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
  END validate_action;
  -------------------------------------
  -- Validate_Attributes for: STATUS --
  -------------------------------------
  PROCEDURE validate_status(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iohv_rec.status = OKC_API.G_MISS_CHAR OR
        p_iohv_rec.status IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'status');
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
  END validate_status;
  -------------------------------------------
  -- Validate_Attributes for: REQUEST_DATE --
  -------------------------------------------
  PROCEDURE validate_request_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_iohv_rec.request_date = OKC_API.G_MISS_DATE OR
        p_iohv_rec.request_date IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'request_date');
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
  END validate_request_date;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    /*
    IF (p_iohv_rec.object_version_number = OKC_API.G_MISS_NUM OR
        p_iohv_rec.object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
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
  END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:IEX_OPEN_INT_HST_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_iohv_rec                     IN iohv_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(l_return_status, p_iohv_rec);
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
    validate_object1_id1(l_return_status, p_iohv_rec);
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
    validate_jtot_object1_code(l_return_status, p_iohv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- action
    -- ***
    validate_action(l_return_status, p_iohv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- status
    -- ***
    validate_status(l_return_status, p_iohv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- request_date
    -- ***
    validate_request_date(l_return_status, p_iohv_rec);
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
    /*
    validate_object_version_number(x_return_status, p_iohv_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    */
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
  --------------------------------------------
  -- Validate Record for:IEX_OPEN_INT_HST_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_iohv_rec IN iohv_rec_type,
    p_db_iohv_rec IN iohv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_iohv_rec IN iohv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_iohv_rec                  iohv_rec_type := get_rec(p_iohv_rec);
  BEGIN
    l_return_status := Validate_Record(p_iohv_rec => p_iohv_rec,
                                       p_db_iohv_rec => l_db_iohv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN iohv_rec_type,
    p_to   IN OUT NOCOPY ioh_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.action := p_from.action;
    p_to.status := p_from.status;
    p_to.comments := p_from.comments;
    p_to.request_date := p_from.request_date;
    p_to.process_date := p_from.process_date;
    p_to.ext_agncy_id := p_from.ext_agncy_id;
    p_to.review_date := p_from.review_date;
    p_to.recall_date := p_from.recall_date;
    p_to.automatic_recall_flag := p_from.automatic_recall_flag;
    p_to.review_before_recall_flag := p_from.review_before_recall_flag;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
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
    p_from IN ioh_rec_type,
    p_to   IN OUT NOCOPY iohv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.action := p_from.action;
    p_to.status := p_from.status;
    p_to.comments := p_from.comments;
    p_to.request_date := p_from.request_date;
    p_to.process_date := p_from.process_date;
    p_to.ext_agncy_id := p_from.ext_agncy_id;
    p_to.review_date := p_from.review_date;
    p_to.recall_date := p_from.recall_date;
    p_to.automatic_recall_flag := p_from.automatic_recall_flag;
    p_to.review_before_recall_flag := p_from.review_before_recall_flag;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
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
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:IEX_OPEN_INT_HST_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iohv_rec                     iohv_rec_type := p_iohv_rec;
    l_ioh_rec                      ioh_rec_type;
    l_ioh_rec                      ioh_rec_type;
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
    l_return_status := Validate_Attributes(l_iohv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_iohv_rec);
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
  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:IEX_OPEN_INT_HST_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iohv_tbl.COUNT > 0) THEN
      i := p_iohv_tbl.FIRST;
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
            p_iohv_rec                     => p_iohv_tbl(i));
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
        EXIT WHEN (i = p_iohv_tbl.LAST);
        i := p_iohv_tbl.NEXT(i);
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

  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:IEX_OPEN_INT_HST_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iohv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_iohv_tbl                     => p_iohv_tbl,
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
  -------------------------------------
  -- insert_row for:IEX_OPEN_INT_HST --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ioh_rec                      IN ioh_rec_type,
    x_ioh_rec                      OUT NOCOPY ioh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ioh_rec                      ioh_rec_type := p_ioh_rec;
    l_def_ioh_rec                  ioh_rec_type;
    -----------------------------------------
    -- Set_Attributes for:IEX_OPEN_INT_HST --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ioh_rec IN ioh_rec_type,
      x_ioh_rec OUT NOCOPY ioh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ioh_rec := p_ioh_rec;
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
      p_ioh_rec,                         -- IN
      l_ioh_rec);                        -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO IEX_OPEN_INT_HST(
      id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      action,
      status,
      comments,
      request_date,
      process_date,
      ext_agncy_id,
      review_date,
      recall_date,
      automatic_recall_flag,
      review_before_recall_flag,
      object_version_number,
      org_id,
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
      l_ioh_rec.id,
      l_ioh_rec.object1_id1,
      l_ioh_rec.object1_id2,
      l_ioh_rec.jtot_object1_code,
      l_ioh_rec.action,
      l_ioh_rec.status,
      l_ioh_rec.comments,
      l_ioh_rec.request_date,
      l_ioh_rec.process_date,
      l_ioh_rec.ext_agncy_id,
      l_ioh_rec.review_date,
      l_ioh_rec.recall_date,
      l_ioh_rec.automatic_recall_flag,
      l_ioh_rec.review_before_recall_flag,
      l_ioh_rec.object_version_number,
      l_ioh_rec.org_id,
      l_ioh_rec.request_id,
      l_ioh_rec.program_application_id,
      l_ioh_rec.program_id,
      l_ioh_rec.program_update_date,
      l_ioh_rec.attribute_category,
      l_ioh_rec.attribute1,
      l_ioh_rec.attribute2,
      l_ioh_rec.attribute3,
      l_ioh_rec.attribute4,
      l_ioh_rec.attribute5,
      l_ioh_rec.attribute6,
      l_ioh_rec.attribute7,
      l_ioh_rec.attribute8,
      l_ioh_rec.attribute9,
      l_ioh_rec.attribute10,
      l_ioh_rec.attribute11,
      l_ioh_rec.attribute12,
      l_ioh_rec.attribute13,
      l_ioh_rec.attribute14,
      l_ioh_rec.attribute15,
      l_ioh_rec.created_by,
      l_ioh_rec.creation_date,
      l_ioh_rec.last_updated_by,
      l_ioh_rec.last_update_date,
      l_ioh_rec.last_update_login);
    -- Set OUT NOCOPY values
    x_ioh_rec := l_ioh_rec;
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
  -- insert_row for :IEX_OPEN_INT_HST_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type,
    x_iohv_rec                     OUT NOCOPY iohv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iohv_rec                     iohv_rec_type := p_iohv_rec;
    l_def_iohv_rec                 iohv_rec_type;
    l_ioh_rec                      ioh_rec_type;
    lx_ioh_rec                     ioh_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_iohv_rec IN iohv_rec_type
    ) RETURN iohv_rec_type IS
      l_iohv_rec iohv_rec_type := p_iohv_rec;
    BEGIN
      l_iohv_rec.CREATION_DATE := SYSDATE;
      l_iohv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_iohv_rec.LAST_UPDATE_DATE := l_iohv_rec.CREATION_DATE;
      l_iohv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_iohv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_iohv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:IEX_OPEN_INT_HST_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_iohv_rec IN iohv_rec_type,
      x_iohv_rec OUT NOCOPY iohv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iohv_rec := p_iohv_rec;
      x_iohv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_iohv_rec := null_out_defaults(p_iohv_rec);
    -- Set primary key value
    l_iohv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_iohv_rec,                        -- IN
      l_def_iohv_rec);                   -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_iohv_rec := fill_who_columns(l_def_iohv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_iohv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_iohv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_iohv_rec, l_ioh_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ioh_rec,
      lx_ioh_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ioh_rec, l_def_iohv_rec);
    -- Set OUT NOCOPY values
    x_iohv_rec := l_def_iohv_rec;
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
  -- PL/SQL TBL insert_row for:IOHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    x_iohv_tbl                     OUT NOCOPY iohv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iohv_tbl.COUNT > 0) THEN
      i := p_iohv_tbl.FIRST;
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
            p_iohv_rec                     => p_iohv_tbl(i),
            x_iohv_rec                     => x_iohv_tbl(i));
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
        EXIT WHEN (i = p_iohv_tbl.LAST);
        i := p_iohv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:IOHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    x_iohv_tbl                     OUT NOCOPY iohv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iohv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_iohv_tbl                     => p_iohv_tbl,
        x_iohv_tbl                     => x_iohv_tbl,
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
  -----------------------------------
  -- lock_row for:IEX_OPEN_INT_HST --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ioh_rec                      IN ioh_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ioh_rec IN ioh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM IEX_OPEN_INT_HST
     WHERE ID = p_ioh_rec.id
       AND OBJECT_VERSION_NUMBER = p_ioh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_ioh_rec IN ioh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM IEX_OPEN_INT_HST
     WHERE ID = p_ioh_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        IEX_OPEN_INT_HST.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       IEX_OPEN_INT_HST.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ioh_rec);
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
      OPEN lchk_csr(p_ioh_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ioh_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ioh_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for: IEX_OPEN_INT_HST_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ioh_rec                      ioh_rec_type;
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
    migrate(p_iohv_rec, l_ioh_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ioh_rec
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
  -- PL/SQL TBL lock_row for:IOHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_iohv_tbl.COUNT > 0) THEN
      i := p_iohv_tbl.FIRST;
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
            p_iohv_rec                     => p_iohv_tbl(i));
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
        EXIT WHEN (i = p_iohv_tbl.LAST);
        i := p_iohv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:IOHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_iohv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_iohv_tbl                     => p_iohv_tbl,
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
  -------------------------------------
  -- update_row for:IEX_OPEN_INT_HST --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ioh_rec                      IN ioh_rec_type,
    x_ioh_rec                      OUT NOCOPY ioh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ioh_rec                      ioh_rec_type := p_ioh_rec;
    l_def_ioh_rec                  ioh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ioh_rec IN ioh_rec_type,
      x_ioh_rec OUT NOCOPY ioh_rec_type
    ) RETURN VARCHAR2 IS
      l_ioh_rec                      ioh_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ioh_rec := p_ioh_rec;
      -- Get current database values
      l_ioh_rec := get_rec(p_ioh_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ioh_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_ioh_rec.id := l_ioh_rec.id;
        END IF;
        IF (x_ioh_rec.object1_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.object1_id1 := l_ioh_rec.object1_id1;
        END IF;
        IF (x_ioh_rec.object1_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.object1_id2 := l_ioh_rec.object1_id2;
        END IF;
        IF (x_ioh_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.jtot_object1_code := l_ioh_rec.jtot_object1_code;
        END IF;
        IF (x_ioh_rec.action = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.action := l_ioh_rec.action;
        END IF;
        IF (x_ioh_rec.status = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.status := l_ioh_rec.status;
        END IF;
        IF (x_ioh_rec.comments = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.comments := l_ioh_rec.comments;
        END IF;
        IF (x_ioh_rec.request_date = OKC_API.G_MISS_DATE)
        THEN
          x_ioh_rec.request_date := l_ioh_rec.request_date;
        END IF;
        IF (x_ioh_rec.process_date = OKC_API.G_MISS_DATE)
        THEN
          x_ioh_rec.process_date := l_ioh_rec.process_date;
        END IF;
        IF (x_ioh_rec.ext_agncy_id = OKC_API.G_MISS_NUM)
        THEN
          x_ioh_rec.ext_agncy_id := l_ioh_rec.ext_agncy_id;
        END IF;
        IF (x_ioh_rec.review_date = OKC_API.G_MISS_DATE)
        THEN
          x_ioh_rec.review_date := l_ioh_rec.review_date;
        END IF;
        IF (x_ioh_rec.recall_date = OKC_API.G_MISS_DATE)
        THEN
          x_ioh_rec.recall_date := l_ioh_rec.recall_date;
        END IF;
        IF (x_ioh_rec.automatic_recall_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.automatic_recall_flag := l_ioh_rec.automatic_recall_flag;
        END IF;
        IF (x_ioh_rec.review_before_recall_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.review_before_recall_flag := l_ioh_rec.review_before_recall_flag;
        END IF;
        IF (x_ioh_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_ioh_rec.object_version_number := l_ioh_rec.object_version_number;
        END IF;
        IF (x_ioh_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_ioh_rec.org_id := l_ioh_rec.org_id;
        END IF;
        IF (x_ioh_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_ioh_rec.request_id := l_ioh_rec.request_id;
        END IF;
        IF (x_ioh_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_ioh_rec.program_application_id := l_ioh_rec.program_application_id;
        END IF;
        IF (x_ioh_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_ioh_rec.program_id := l_ioh_rec.program_id;
        END IF;
        IF (x_ioh_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ioh_rec.program_update_date := l_ioh_rec.program_update_date;
        END IF;
        IF (x_ioh_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute_category := l_ioh_rec.attribute_category;
        END IF;
        IF (x_ioh_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute1 := l_ioh_rec.attribute1;
        END IF;
        IF (x_ioh_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute2 := l_ioh_rec.attribute2;
        END IF;
        IF (x_ioh_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute3 := l_ioh_rec.attribute3;
        END IF;
        IF (x_ioh_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute4 := l_ioh_rec.attribute4;
        END IF;
        IF (x_ioh_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute5 := l_ioh_rec.attribute5;
        END IF;
        IF (x_ioh_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute6 := l_ioh_rec.attribute6;
        END IF;
        IF (x_ioh_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute7 := l_ioh_rec.attribute7;
        END IF;
        IF (x_ioh_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute8 := l_ioh_rec.attribute8;
        END IF;
        IF (x_ioh_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute9 := l_ioh_rec.attribute9;
        END IF;
        IF (x_ioh_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute10 := l_ioh_rec.attribute10;
        END IF;
        IF (x_ioh_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute11 := l_ioh_rec.attribute11;
        END IF;
        IF (x_ioh_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute12 := l_ioh_rec.attribute12;
        END IF;
        IF (x_ioh_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute13 := l_ioh_rec.attribute13;
        END IF;
        IF (x_ioh_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute14 := l_ioh_rec.attribute14;
        END IF;
        IF (x_ioh_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_ioh_rec.attribute15 := l_ioh_rec.attribute15;
        END IF;
        IF (x_ioh_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ioh_rec.created_by := l_ioh_rec.created_by;
        END IF;
        IF (x_ioh_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ioh_rec.creation_date := l_ioh_rec.creation_date;
        END IF;
        IF (x_ioh_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ioh_rec.last_updated_by := l_ioh_rec.last_updated_by;
        END IF;
        IF (x_ioh_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ioh_rec.last_update_date := l_ioh_rec.last_update_date;
        END IF;
        IF (x_ioh_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ioh_rec.last_update_login := l_ioh_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:IEX_OPEN_INT_HST --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ioh_rec IN ioh_rec_type,
      x_ioh_rec OUT NOCOPY ioh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ioh_rec := p_ioh_rec;
      x_ioh_rec.OBJECT_VERSION_NUMBER := p_ioh_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_ioh_rec,                         -- IN
      l_ioh_rec);                        -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ioh_rec, l_def_ioh_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE IEX_OPEN_INT_HST
    SET OBJECT1_ID1 = l_def_ioh_rec.object1_id1,
        OBJECT1_ID2 = l_def_ioh_rec.object1_id2,
        JTOT_OBJECT1_CODE = l_def_ioh_rec.jtot_object1_code,
        ACTION = l_def_ioh_rec.action,
        STATUS = l_def_ioh_rec.status,
        COMMENTS = l_def_ioh_rec.comments,
        REQUEST_DATE = l_def_ioh_rec.request_date,
        PROCESS_DATE = l_def_ioh_rec.process_date,
        EXT_AGNCY_ID = l_def_ioh_rec.ext_agncy_id,
        REVIEW_DATE = l_def_ioh_rec.review_date,
        RECALL_DATE = l_def_ioh_rec.recall_date,
        AUTOMATIC_RECALL_FLAG = l_def_ioh_rec.automatic_recall_flag,
        REVIEW_BEFORE_RECALL_FLAG = l_def_ioh_rec.review_before_recall_flag,
        OBJECT_VERSION_NUMBER = l_def_ioh_rec.object_version_number,
        ORG_ID = l_def_ioh_rec.org_id,
        REQUEST_ID = l_def_ioh_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_ioh_rec.program_application_id,
        PROGRAM_ID = l_def_ioh_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_ioh_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_ioh_rec.attribute_category,
        ATTRIBUTE1 = l_def_ioh_rec.attribute1,
        ATTRIBUTE2 = l_def_ioh_rec.attribute2,
        ATTRIBUTE3 = l_def_ioh_rec.attribute3,
        ATTRIBUTE4 = l_def_ioh_rec.attribute4,
        ATTRIBUTE5 = l_def_ioh_rec.attribute5,
        ATTRIBUTE6 = l_def_ioh_rec.attribute6,
        ATTRIBUTE7 = l_def_ioh_rec.attribute7,
        ATTRIBUTE8 = l_def_ioh_rec.attribute8,
        ATTRIBUTE9 = l_def_ioh_rec.attribute9,
        ATTRIBUTE10 = l_def_ioh_rec.attribute10,
        ATTRIBUTE11 = l_def_ioh_rec.attribute11,
        ATTRIBUTE12 = l_def_ioh_rec.attribute12,
        ATTRIBUTE13 = l_def_ioh_rec.attribute13,
        ATTRIBUTE14 = l_def_ioh_rec.attribute14,
        ATTRIBUTE15 = l_def_ioh_rec.attribute15,
        CREATED_BY = l_def_ioh_rec.created_by,
        CREATION_DATE = l_def_ioh_rec.creation_date,
        LAST_UPDATED_BY = l_def_ioh_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ioh_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ioh_rec.last_update_login
    WHERE ID = l_def_ioh_rec.id;

    x_ioh_rec := l_ioh_rec;
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
  ---------------------------------------
  -- update_row for:IEX_OPEN_INT_HST_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type,
    x_iohv_rec                     OUT NOCOPY iohv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iohv_rec                     iohv_rec_type := p_iohv_rec;
    l_def_iohv_rec                 iohv_rec_type;
    l_db_iohv_rec                  iohv_rec_type;
    l_ioh_rec                      ioh_rec_type;
    lx_ioh_rec                     ioh_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_iohv_rec IN iohv_rec_type
    ) RETURN iohv_rec_type IS
      l_iohv_rec iohv_rec_type := p_iohv_rec;
    BEGIN
      l_iohv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_iohv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_iohv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_iohv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_iohv_rec IN iohv_rec_type,
      x_iohv_rec OUT NOCOPY iohv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iohv_rec := p_iohv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_iohv_rec := get_rec(p_iohv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_iohv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_iohv_rec.id := l_db_iohv_rec.id;
        END IF;
        IF (x_iohv_rec.object1_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.object1_id1 := l_db_iohv_rec.object1_id1;
        END IF;
        IF (x_iohv_rec.object1_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.object1_id2 := l_db_iohv_rec.object1_id2;
        END IF;
        IF (x_iohv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.jtot_object1_code := l_db_iohv_rec.jtot_object1_code;
        END IF;
        IF (x_iohv_rec.action = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.action := l_db_iohv_rec.action;
        END IF;
        IF (x_iohv_rec.status = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.status := l_db_iohv_rec.status;
        END IF;
        IF (x_iohv_rec.comments = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.comments := l_db_iohv_rec.comments;
        END IF;
        IF (x_iohv_rec.request_date = OKC_API.G_MISS_DATE)
        THEN
          x_iohv_rec.request_date := l_db_iohv_rec.request_date;
        END IF;
        IF (x_iohv_rec.process_date = OKC_API.G_MISS_DATE)
        THEN
          x_iohv_rec.process_date := l_db_iohv_rec.process_date;
        END IF;
        IF (x_iohv_rec.ext_agncy_id = OKC_API.G_MISS_NUM)
        THEN
          x_iohv_rec.ext_agncy_id := l_db_iohv_rec.ext_agncy_id;
        END IF;
        IF (x_iohv_rec.review_date = OKC_API.G_MISS_DATE)
        THEN
          x_iohv_rec.review_date := l_db_iohv_rec.review_date;
        END IF;
        IF (x_iohv_rec.recall_date = OKC_API.G_MISS_DATE)
        THEN
          x_iohv_rec.recall_date := l_db_iohv_rec.recall_date;
        END IF;
        IF (x_iohv_rec.automatic_recall_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.automatic_recall_flag := l_db_iohv_rec.automatic_recall_flag;
        END IF;
        IF (x_iohv_rec.review_before_recall_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.review_before_recall_flag := l_db_iohv_rec.review_before_recall_flag;
        END IF;
        IF (x_iohv_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_iohv_rec.object_version_number := l_db_iohv_rec.object_version_number;
        END IF;
        IF (x_iohv_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_iohv_rec.org_id := l_db_iohv_rec.org_id;
        END IF;
        IF (x_iohv_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_iohv_rec.request_id := l_db_iohv_rec.request_id;
        END IF;
        IF (x_iohv_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_iohv_rec.program_application_id := l_db_iohv_rec.program_application_id;
        END IF;
        IF (x_iohv_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_iohv_rec.program_id := l_db_iohv_rec.program_id;
        END IF;
        IF (x_iohv_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_iohv_rec.program_update_date := l_db_iohv_rec.program_update_date;
        END IF;
        IF (x_iohv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute_category := l_db_iohv_rec.attribute_category;
        END IF;
        IF (x_iohv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute1 := l_db_iohv_rec.attribute1;
        END IF;
        IF (x_iohv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute2 := l_db_iohv_rec.attribute2;
        END IF;
        IF (x_iohv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute3 := l_db_iohv_rec.attribute3;
        END IF;
        IF (x_iohv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute4 := l_db_iohv_rec.attribute4;
        END IF;
        IF (x_iohv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute5 := l_db_iohv_rec.attribute5;
        END IF;
        IF (x_iohv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute6 := l_db_iohv_rec.attribute6;
        END IF;
        IF (x_iohv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute7 := l_db_iohv_rec.attribute7;
        END IF;
        IF (x_iohv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute8 := l_db_iohv_rec.attribute8;
        END IF;
        IF (x_iohv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute9 := l_db_iohv_rec.attribute9;
        END IF;
        IF (x_iohv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute10 := l_db_iohv_rec.attribute10;
        END IF;
        IF (x_iohv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute11 := l_db_iohv_rec.attribute11;
        END IF;
        IF (x_iohv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute12 := l_db_iohv_rec.attribute12;
        END IF;
        IF (x_iohv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute13 := l_db_iohv_rec.attribute13;
        END IF;
        IF (x_iohv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute14 := l_db_iohv_rec.attribute14;
        END IF;
        IF (x_iohv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_iohv_rec.attribute15 := l_db_iohv_rec.attribute15;
        END IF;
        IF (x_iohv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_iohv_rec.created_by := l_db_iohv_rec.created_by;
        END IF;
        IF (x_iohv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_iohv_rec.creation_date := l_db_iohv_rec.creation_date;
        END IF;
        IF (x_iohv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_iohv_rec.last_updated_by := l_db_iohv_rec.last_updated_by;
        END IF;
        IF (x_iohv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_iohv_rec.last_update_date := l_db_iohv_rec.last_update_date;
        END IF;
        IF (x_iohv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_iohv_rec.last_update_login := l_db_iohv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:IEX_OPEN_INT_HST_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_iohv_rec IN iohv_rec_type,
      x_iohv_rec OUT NOCOPY iohv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iohv_rec := p_iohv_rec;
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
      p_iohv_rec,                        -- IN
      x_iohv_rec);                       -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_iohv_rec, l_def_iohv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_iohv_rec := fill_who_columns(l_def_iohv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_iohv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_iohv_rec, l_db_iohv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_iohv_rec                     => p_iohv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_iohv_rec, l_ioh_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ioh_rec,
      lx_ioh_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ioh_rec, l_def_iohv_rec);
    x_iohv_rec := l_def_iohv_rec;
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
  -- PL/SQL TBL update_row for:iohv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    x_iohv_tbl                     OUT NOCOPY iohv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iohv_tbl.COUNT > 0) THEN
      i := p_iohv_tbl.FIRST;
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
            p_iohv_rec                     => p_iohv_tbl(i),
            x_iohv_rec                     => x_iohv_tbl(i));
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
        EXIT WHEN (i = p_iohv_tbl.LAST);
        i := p_iohv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:IOHV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    x_iohv_tbl                     OUT NOCOPY iohv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iohv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_iohv_tbl                     => p_iohv_tbl,
        x_iohv_tbl                     => x_iohv_tbl,
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
  -------------------------------------
  -- delete_row for:IEX_OPEN_INT_HST --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ioh_rec                      IN ioh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ioh_rec                      ioh_rec_type := p_ioh_rec;
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

    DELETE FROM IEX_OPEN_INT_HST
     WHERE ID = p_ioh_rec.id;

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
  ---------------------------------------
  -- delete_row for:IEX_OPEN_INT_HST_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iohv_rec                     iohv_rec_type := p_iohv_rec;
    l_ioh_rec                      ioh_rec_type;
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
    migrate(l_iohv_rec, l_ioh_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ioh_rec
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
  --------------------------------------------------
  -- PL/SQL TBL delete_row for:IEX_OPEN_INT_HST_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iohv_tbl.COUNT > 0) THEN
      i := p_iohv_tbl.FIRST;
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
            p_iohv_rec                     => p_iohv_tbl(i));
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
        EXIT WHEN (i = p_iohv_tbl.LAST);
        i := p_iohv_tbl.NEXT(i);
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

  --------------------------------------------------
  -- PL/SQL TBL delete_row for:IEX_OPEN_INT_HST_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_iohv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_iohv_tbl                     => p_iohv_tbl,
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

END IEX_IOH_PVT;

/
