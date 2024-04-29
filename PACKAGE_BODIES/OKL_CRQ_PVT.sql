--------------------------------------------------------
--  DDL for Package Body OKL_CRQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CRQ_PVT" AS
/* $Header: OKLSCRQB.pls 120.2 2006/07/14 05:05:58 pagarg noship $ */
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
  -- FUNCTION get_rec for: OKL_CREDIT_REQUESTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_crqv_rec                     IN crqv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN crqv_rec_type IS
    CURSOR okl_crqv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            QUOTE_ID,
            CREDIT_REQ_NUMBER,
            CREDIT_REQ_ID,
            CREDIT_AMOUNT,
            REQUESTED_BY,
            REQUESTED_DATE,
            APPROVED_BY,
            APPROVED_DATE,
            STATUS,
            CREDIT_KHR_ID,
            CURRENCY_CODE,
            OBJECT_VERSION_NUMBER,
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
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_CREDIT_REQUESTS
     WHERE OKL_CREDIT_REQUESTS.id = p_id;
    l_okl_crqv_pk                  okl_crqv_pk_csr%ROWTYPE;
    l_crqv_rec                     crqv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_crqv_pk_csr (p_crqv_rec.id);
    FETCH okl_crqv_pk_csr INTO
              l_crqv_rec.id,
              l_crqv_rec.quote_id,
              l_crqv_rec.credit_req_number,
              l_crqv_rec.credit_req_id,
              l_crqv_rec.credit_amount,
              l_crqv_rec.requested_by,
              l_crqv_rec.requested_date,
              l_crqv_rec.approved_by,
              l_crqv_rec.approved_date,
              l_crqv_rec.status,
              l_crqv_rec.credit_khr_id,
              l_crqv_rec.currency_code,
              l_crqv_rec.object_version_number,
              l_crqv_rec.attribute_category,
              l_crqv_rec.attribute1,
              l_crqv_rec.attribute2,
              l_crqv_rec.attribute3,
              l_crqv_rec.attribute4,
              l_crqv_rec.attribute5,
              l_crqv_rec.attribute6,
              l_crqv_rec.attribute7,
              l_crqv_rec.attribute8,
              l_crqv_rec.attribute9,
              l_crqv_rec.attribute10,
              l_crqv_rec.attribute11,
              l_crqv_rec.attribute12,
              l_crqv_rec.attribute13,
              l_crqv_rec.attribute14,
              l_crqv_rec.attribute15,
              l_crqv_rec.org_id,
              l_crqv_rec.created_by,
              l_crqv_rec.creation_date,
              l_crqv_rec.last_updated_by,
              l_crqv_rec.last_update_date,
              l_crqv_rec.last_update_login;
    x_no_data_found := okl_crqv_pk_csr%NOTFOUND;
    CLOSE okl_crqv_pk_csr;
    RETURN(l_crqv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_crqv_rec                     IN crqv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN crqv_rec_type IS
    l_crqv_rec                     crqv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_crqv_rec := get_rec(p_crqv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_crqv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_crqv_rec                     IN crqv_rec_type
  ) RETURN crqv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_crqv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CREDIT_REQUESTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_crq_rec                      IN crq_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN crq_rec_type IS
    CURSOR okl_crq_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            QUOTE_ID,
            CREDIT_REQ_NUMBER,
            CREDIT_REQ_ID,
            CREDIT_AMOUNT,
            REQUESTED_BY,
            REQUESTED_DATE,
            APPROVED_BY,
            APPROVED_DATE,
            STATUS,
            CREDIT_KHR_ID,
            CURRENCY_CODE,
            OBJECT_VERSION_NUMBER,
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
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Credit_Requests
     WHERE okl_credit_requests.id = p_id;
    l_okl_crq_pk                   okl_crq_pk_csr%ROWTYPE;
    l_crq_rec                      crq_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_crq_pk_csr (p_crq_rec.id);
    FETCH okl_crq_pk_csr INTO
              l_crq_rec.id,
              l_crq_rec.quote_id,
              l_crq_rec.credit_req_number,
              l_crq_rec.credit_req_id,
              l_crq_rec.credit_amount,
              l_crq_rec.requested_by,
              l_crq_rec.requested_date,
              l_crq_rec.approved_by,
              l_crq_rec.approved_date,
              l_crq_rec.status,
              l_crq_rec.credit_khr_id,
              l_crq_rec.currency_code,
              l_crq_rec.object_version_number,
              l_crq_rec.attribute_category,
              l_crq_rec.attribute1,
              l_crq_rec.attribute2,
              l_crq_rec.attribute3,
              l_crq_rec.attribute4,
              l_crq_rec.attribute5,
              l_crq_rec.attribute6,
              l_crq_rec.attribute7,
              l_crq_rec.attribute8,
              l_crq_rec.attribute9,
              l_crq_rec.attribute10,
              l_crq_rec.attribute11,
              l_crq_rec.attribute12,
              l_crq_rec.attribute13,
              l_crq_rec.attribute14,
              l_crq_rec.attribute15,
              l_crq_rec.org_id,
              l_crq_rec.created_by,
              l_crq_rec.creation_date,
              l_crq_rec.last_updated_by,
              l_crq_rec.last_update_date,
              l_crq_rec.last_update_login;
    x_no_data_found := okl_crq_pk_csr%NOTFOUND;
    CLOSE okl_crq_pk_csr;
    RETURN(l_crq_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_crq_rec                      IN crq_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN crq_rec_type IS
    l_crq_rec                      crq_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_crq_rec := get_rec(p_crq_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_crq_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_crq_rec                      IN crq_rec_type
  ) RETURN crq_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_crq_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CREDIT_REQUESTS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_crqv_rec   IN crqv_rec_type
  ) RETURN crqv_rec_type IS
    l_crqv_rec                     crqv_rec_type := p_crqv_rec;
  BEGIN
    IF (l_crqv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.id := NULL;
    END IF;
    IF (l_crqv_rec.quote_id = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.quote_id := NULL;
    END IF;
    IF (l_crqv_rec.credit_req_number = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.credit_req_number := NULL;
    END IF;
    IF (l_crqv_rec.credit_req_id = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.credit_req_id := NULL;
    END IF;
    IF (l_crqv_rec.credit_amount = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.credit_amount := NULL;
    END IF;
    IF (l_crqv_rec.requested_by = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.requested_by := NULL;
    END IF;
    IF (l_crqv_rec.requested_date = OKC_API.G_MISS_DATE ) THEN
      l_crqv_rec.requested_date := NULL;
    END IF;
    IF (l_crqv_rec.approved_by = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.approved_by := NULL;
    END IF;
    IF (l_crqv_rec.approved_date = OKC_API.G_MISS_DATE ) THEN
      l_crqv_rec.approved_date := NULL;
    END IF;
    IF (l_crqv_rec.status = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.status := NULL;
    END IF;
    IF (l_crqv_rec.credit_khr_id = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.credit_khr_id := NULL;
    END IF;
    IF (l_crqv_rec.currency_code = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.currency_code := NULL;
    END IF;
    IF (l_crqv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.object_version_number := NULL;
    END IF;
    IF (l_crqv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute_category := NULL;
    END IF;
    IF (l_crqv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute1 := NULL;
    END IF;
    IF (l_crqv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute2 := NULL;
    END IF;
    IF (l_crqv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute3 := NULL;
    END IF;
    IF (l_crqv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute4 := NULL;
    END IF;
    IF (l_crqv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute5 := NULL;
    END IF;
    IF (l_crqv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute6 := NULL;
    END IF;
    IF (l_crqv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute7 := NULL;
    END IF;
    IF (l_crqv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute8 := NULL;
    END IF;
    IF (l_crqv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute9 := NULL;
    END IF;
    IF (l_crqv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute10 := NULL;
    END IF;
    IF (l_crqv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute11 := NULL;
    END IF;
    IF (l_crqv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute12 := NULL;
    END IF;
    IF (l_crqv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute13 := NULL;
    END IF;
    IF (l_crqv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute14 := NULL;
    END IF;
    IF (l_crqv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_crqv_rec.attribute15 := NULL;
    END IF;
    IF (l_crqv_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.org_id := NULL;
    END IF;
    IF (l_crqv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.created_by := NULL;
    END IF;
    IF (l_crqv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_crqv_rec.creation_date := NULL;
    END IF;
    IF (l_crqv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.last_updated_by := NULL;
    END IF;
    IF (l_crqv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_crqv_rec.last_update_date := NULL;
    END IF;
    IF (l_crqv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_crqv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_crqv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_id = OKC_API.G_MISS_NUM OR
        p_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
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
  END validate_id;
  ---------------------------------------
  -- Validate_Attributes for: QUOTE_ID --
  ---------------------------------------
  PROCEDURE validate_quote_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_quote_id                     IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_quote_id = OKC_API.G_MISS_NUM OR
        p_quote_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'quote_id');
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
  END validate_quote_id;
  ------------------------------------------------
  -- Validate_Attributes for: CREDIT_REQ_NUMBER --
  ------------------------------------------------
  PROCEDURE validate_credit_req_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_credit_req_number            IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_credit_req_number = OKC_API.G_MISS_CHAR OR
        p_credit_req_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'credit_req_number');
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
  END validate_credit_req_number;
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
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_CREDIT_REQUESTS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_crqv_rec                     IN crqv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_crqv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- quote_id
    -- ***
    validate_quote_id(x_return_status, p_crqv_rec.quote_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- credit_req_number
    -- ***
    validate_credit_req_number(x_return_status, p_crqv_rec.credit_req_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_crqv_rec.object_version_number);
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
  -----------------------------------------------
  -- Validate Record for:OKL_CREDIT_REQUESTS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_crqv_rec IN crqv_rec_type,
    p_db_crqv_rec IN crqv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_crqv_rec IN crqv_rec_type,
      p_db_crqv_rec IN crqv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okc_chrv_pk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okc_K_Headers_V
       WHERE okc_k_headers_v.id   = p_id;
      l_okc_chrv_pk                  okc_chrv_pk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF ((p_crqv_rec.QUOTE_ID IS NOT NULL)
       AND
          (p_crqv_rec.QUOTE_ID <> p_db_crqv_rec.QUOTE_ID))
      THEN
        OPEN okc_chrv_pk_csr (p_crqv_rec.QUOTE_ID);
        FETCH okc_chrv_pk_csr INTO l_okc_chrv_pk;
        l_row_notfound := okc_chrv_pk_csr%NOTFOUND;
        CLOSE okc_chrv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'QUOTE_ID');
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
    l_return_status := validate_foreign_keys(p_crqv_rec, p_db_crqv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_crqv_rec IN crqv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_crqv_rec                  crqv_rec_type := get_rec(p_crqv_rec);
  BEGIN
    l_return_status := Validate_Record(p_crqv_rec => p_crqv_rec,
                                       p_db_crqv_rec => l_db_crqv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN crqv_rec_type,
    p_to   IN OUT NOCOPY crq_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.quote_id := p_from.quote_id;
    p_to.credit_req_number := p_from.credit_req_number;
    p_to.credit_req_id := p_from.credit_req_id;
    p_to.credit_amount := p_from.credit_amount;
    p_to.requested_by := p_from.requested_by;
    p_to.requested_date := p_from.requested_date;
    p_to.approved_by := p_from.approved_by;
    p_to.approved_date := p_from.approved_date;
    p_to.status := p_from.status;
    p_to.credit_khr_id := p_from.credit_khr_id;
    p_to.currency_code := p_from.currency_code;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN crq_rec_type,
    p_to   IN OUT NOCOPY crqv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.quote_id := p_from.quote_id;
    p_to.credit_req_number := p_from.credit_req_number;
    p_to.credit_req_id := p_from.credit_req_id;
    p_to.credit_amount := p_from.credit_amount;
    p_to.requested_by := p_from.requested_by;
    p_to.requested_date := p_from.requested_date;
    p_to.approved_by := p_from.approved_by;
    p_to.approved_date := p_from.approved_date;
    p_to.status := p_from.status;
    p_to.credit_khr_id := p_from.credit_khr_id;
    p_to.currency_code := p_from.currency_code;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.org_id := p_from.org_id;
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
  -- validate_row for:OKL_CREDIT_REQUESTS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_rec                     IN crqv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crqv_rec                     crqv_rec_type := p_crqv_rec;
    l_crq_rec                      crq_rec_type;
    l_crq_rec                      crq_rec_type;
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
    l_return_status := Validate_Attributes(l_crqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_crqv_rec);
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
  -------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CREDIT_REQUESTS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_tbl                     IN crqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crqv_tbl.COUNT > 0) THEN
      i := p_crqv_tbl.FIRST;
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
            p_crqv_rec                     => p_crqv_tbl(i));
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
        EXIT WHEN (i = p_crqv_tbl.LAST);
        i := p_crqv_tbl.NEXT(i);
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

  -------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CREDIT_REQUESTS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_tbl                     IN crqv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crqv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_crqv_tbl                     => p_crqv_tbl,
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
  ----------------------------------------
  -- insert_row for:OKL_CREDIT_REQUESTS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crq_rec                      IN crq_rec_type,
    x_crq_rec                      OUT NOCOPY crq_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crq_rec                      crq_rec_type := p_crq_rec;
    l_def_crq_rec                  crq_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_CREDIT_REQUESTS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_crq_rec IN crq_rec_type,
      x_crq_rec OUT NOCOPY crq_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crq_rec := p_crq_rec;
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
      p_crq_rec,                         -- IN
      l_crq_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CREDIT_REQUESTS(
      id,
      quote_id,
      credit_req_number,
      credit_req_id,
      credit_amount,
      requested_by,
      requested_date,
      approved_by,
      approved_date,
      status,
      credit_khr_id,
      currency_code,
      object_version_number,
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
      org_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_crq_rec.id,
      l_crq_rec.quote_id,
      l_crq_rec.credit_req_number,
      l_crq_rec.credit_req_id,
      l_crq_rec.credit_amount,
      l_crq_rec.requested_by,
      l_crq_rec.requested_date,
      l_crq_rec.approved_by,
      l_crq_rec.approved_date,
      l_crq_rec.status,
      l_crq_rec.credit_khr_id,
      l_crq_rec.currency_code,
      l_crq_rec.object_version_number,
      l_crq_rec.attribute_category,
      l_crq_rec.attribute1,
      l_crq_rec.attribute2,
      l_crq_rec.attribute3,
      l_crq_rec.attribute4,
      l_crq_rec.attribute5,
      l_crq_rec.attribute6,
      l_crq_rec.attribute7,
      l_crq_rec.attribute8,
      l_crq_rec.attribute9,
      l_crq_rec.attribute10,
      l_crq_rec.attribute11,
      l_crq_rec.attribute12,
      l_crq_rec.attribute13,
      l_crq_rec.attribute14,
      l_crq_rec.attribute15,
      l_crq_rec.org_id,
      l_crq_rec.created_by,
      l_crq_rec.creation_date,
      l_crq_rec.last_updated_by,
      l_crq_rec.last_update_date,
      l_crq_rec.last_update_login);
    -- Set OUT values
    x_crq_rec := l_crq_rec;
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
  -------------------------------------------
  -- insert_row for :OKL_CREDIT_REQUESTS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_rec                     IN crqv_rec_type,
    x_crqv_rec                     OUT NOCOPY crqv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crqv_rec                     crqv_rec_type := p_crqv_rec;
    l_def_crqv_rec                 crqv_rec_type;
    l_crq_rec                      crq_rec_type;
    lx_crq_rec                     crq_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_crqv_rec IN crqv_rec_type
    ) RETURN crqv_rec_type IS
      l_crqv_rec crqv_rec_type := p_crqv_rec;
    BEGIN
      l_crqv_rec.CREATION_DATE := SYSDATE;
      l_crqv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_crqv_rec.LAST_UPDATE_DATE := l_crqv_rec.CREATION_DATE;
      l_crqv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_crqv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_crqv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CREDIT_REQUESTS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_crqv_rec IN crqv_rec_type,
      x_crqv_rec OUT NOCOPY crqv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crqv_rec := p_crqv_rec;
      x_crqv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_crqv_rec := null_out_defaults(p_crqv_rec);
    -- Set primary key value
    l_crqv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_crqv_rec,                        -- IN
      l_def_crqv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_crqv_rec := fill_who_columns(l_def_crqv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_crqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_crqv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_crqv_rec, l_crq_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_crq_rec,
      lx_crq_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_crq_rec, l_def_crqv_rec);
    -- Set OUT values
    x_crqv_rec := l_def_crqv_rec;
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
  -- PL/SQL TBL insert_row for:CRQV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_tbl                     IN crqv_tbl_type,
    x_crqv_tbl                     OUT NOCOPY crqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crqv_tbl.COUNT > 0) THEN
      i := p_crqv_tbl.FIRST;
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
            p_crqv_rec                     => p_crqv_tbl(i),
            x_crqv_rec                     => x_crqv_tbl(i));
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
        EXIT WHEN (i = p_crqv_tbl.LAST);
        i := p_crqv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:CRQV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_tbl                     IN crqv_tbl_type,
    x_crqv_tbl                     OUT NOCOPY crqv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crqv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_crqv_tbl                     => p_crqv_tbl,
        x_crqv_tbl                     => x_crqv_tbl,
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
  --------------------------------------
  -- lock_row for:OKL_CREDIT_REQUESTS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crq_rec                      IN crq_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_crq_rec IN crq_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CREDIT_REQUESTS
     WHERE ID = p_crq_rec.id
       AND OBJECT_VERSION_NUMBER = p_crq_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_crq_rec IN crq_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CREDIT_REQUESTS
     WHERE ID = p_crq_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_CREDIT_REQUESTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_CREDIT_REQUESTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_crq_rec);
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
      OPEN lchk_csr(p_crq_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_crq_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_crq_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for: OKL_CREDIT_REQUESTS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_rec                     IN crqv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crq_rec                      crq_rec_type;
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
    migrate(p_crqv_rec, l_crq_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_crq_rec
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
  -- PL/SQL TBL lock_row for:CRQV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_tbl                     IN crqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_crqv_tbl.COUNT > 0) THEN
      i := p_crqv_tbl.FIRST;
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
            p_crqv_rec                     => p_crqv_tbl(i));
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
        EXIT WHEN (i = p_crqv_tbl.LAST);
        i := p_crqv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:CRQV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_tbl                     IN crqv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_crqv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_crqv_tbl                     => p_crqv_tbl,
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
  ----------------------------------------
  -- update_row for:OKL_CREDIT_REQUESTS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crq_rec                      IN crq_rec_type,
    x_crq_rec                      OUT NOCOPY crq_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crq_rec                      crq_rec_type := p_crq_rec;
    l_def_crq_rec                  crq_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_crq_rec IN crq_rec_type,
      x_crq_rec OUT NOCOPY crq_rec_type
    ) RETURN VARCHAR2 IS
      l_crq_rec                      crq_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crq_rec := p_crq_rec;
      -- Get current database values
      l_crq_rec := get_rec(p_crq_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_crq_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.id := l_crq_rec.id;
        END IF;
        IF (x_crq_rec.quote_id = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.quote_id := l_crq_rec.quote_id;
        END IF;
        IF (x_crq_rec.credit_req_number = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.credit_req_number := l_crq_rec.credit_req_number;
        END IF;
        IF (x_crq_rec.credit_req_id = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.credit_req_id := l_crq_rec.credit_req_id;
        END IF;
        IF (x_crq_rec.credit_amount = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.credit_amount := l_crq_rec.credit_amount;
        END IF;
        IF (x_crq_rec.requested_by = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.requested_by := l_crq_rec.requested_by;
        END IF;
        IF (x_crq_rec.requested_date = OKC_API.G_MISS_DATE)
        THEN
          x_crq_rec.requested_date := l_crq_rec.requested_date;
        END IF;
        IF (x_crq_rec.approved_by = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.approved_by := l_crq_rec.approved_by;
        END IF;
        IF (x_crq_rec.approved_date = OKC_API.G_MISS_DATE)
        THEN
          x_crq_rec.approved_date := l_crq_rec.approved_date;
        END IF;
        IF (x_crq_rec.status = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.status := l_crq_rec.status;
        END IF;
        IF (x_crq_rec.credit_khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.credit_khr_id := l_crq_rec.credit_khr_id;
        END IF;
        IF (x_crq_rec.currency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.currency_code := l_crq_rec.currency_code;
        END IF;
        IF (x_crq_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.object_version_number := l_crq_rec.object_version_number;
        END IF;
        IF (x_crq_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute_category := l_crq_rec.attribute_category;
        END IF;
        IF (x_crq_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute1 := l_crq_rec.attribute1;
        END IF;
        IF (x_crq_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute2 := l_crq_rec.attribute2;
        END IF;
        IF (x_crq_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute3 := l_crq_rec.attribute3;
        END IF;
        IF (x_crq_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute4 := l_crq_rec.attribute4;
        END IF;
        IF (x_crq_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute5 := l_crq_rec.attribute5;
        END IF;
        IF (x_crq_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute6 := l_crq_rec.attribute6;
        END IF;
        IF (x_crq_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute7 := l_crq_rec.attribute7;
        END IF;
        IF (x_crq_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute8 := l_crq_rec.attribute8;
        END IF;
        IF (x_crq_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute9 := l_crq_rec.attribute9;
        END IF;
        IF (x_crq_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute10 := l_crq_rec.attribute10;
        END IF;
        IF (x_crq_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute11 := l_crq_rec.attribute11;
        END IF;
        IF (x_crq_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute12 := l_crq_rec.attribute12;
        END IF;
        IF (x_crq_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute13 := l_crq_rec.attribute13;
        END IF;
        IF (x_crq_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute14 := l_crq_rec.attribute14;
        END IF;
        IF (x_crq_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_crq_rec.attribute15 := l_crq_rec.attribute15;
        END IF;
        IF (x_crq_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.org_id := l_crq_rec.org_id;
        END IF;
        IF (x_crq_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.created_by := l_crq_rec.created_by;
        END IF;
        IF (x_crq_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_crq_rec.creation_date := l_crq_rec.creation_date;
        END IF;
        IF (x_crq_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.last_updated_by := l_crq_rec.last_updated_by;
        END IF;
        IF (x_crq_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_crq_rec.last_update_date := l_crq_rec.last_update_date;
        END IF;
        IF (x_crq_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_crq_rec.last_update_login := l_crq_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_CREDIT_REQUESTS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_crq_rec IN crq_rec_type,
      x_crq_rec OUT NOCOPY crq_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crq_rec := p_crq_rec;
      x_crq_rec.OBJECT_VERSION_NUMBER := p_crq_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_crq_rec,                         -- IN
      l_crq_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_crq_rec, l_def_crq_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CREDIT_REQUESTS
    SET QUOTE_ID = l_def_crq_rec.quote_id,
        CREDIT_REQ_NUMBER = l_def_crq_rec.credit_req_number,
        CREDIT_REQ_ID = l_def_crq_rec.credit_req_id,
        CREDIT_AMOUNT = l_def_crq_rec.credit_amount,
        REQUESTED_BY = l_def_crq_rec.requested_by,
        REQUESTED_DATE = l_def_crq_rec.requested_date,
        APPROVED_BY = l_def_crq_rec.approved_by,
        APPROVED_DATE = l_def_crq_rec.approved_date,
        STATUS = l_def_crq_rec.status,
        CREDIT_KHR_ID = l_def_crq_rec.credit_khr_id,
        CURRENCY_CODE = l_def_crq_rec.currency_code,
        OBJECT_VERSION_NUMBER = l_def_crq_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_crq_rec.attribute_category,
        ATTRIBUTE1 = l_def_crq_rec.attribute1,
        ATTRIBUTE2 = l_def_crq_rec.attribute2,
        ATTRIBUTE3 = l_def_crq_rec.attribute3,
        ATTRIBUTE4 = l_def_crq_rec.attribute4,
        ATTRIBUTE5 = l_def_crq_rec.attribute5,
        ATTRIBUTE6 = l_def_crq_rec.attribute6,
        ATTRIBUTE7 = l_def_crq_rec.attribute7,
        ATTRIBUTE8 = l_def_crq_rec.attribute8,
        ATTRIBUTE9 = l_def_crq_rec.attribute9,
        ATTRIBUTE10 = l_def_crq_rec.attribute10,
        ATTRIBUTE11 = l_def_crq_rec.attribute11,
        ATTRIBUTE12 = l_def_crq_rec.attribute12,
        ATTRIBUTE13 = l_def_crq_rec.attribute13,
        ATTRIBUTE14 = l_def_crq_rec.attribute14,
        ATTRIBUTE15 = l_def_crq_rec.attribute15,
        ORG_ID = l_def_crq_rec.org_id,
        CREATED_BY = l_def_crq_rec.created_by,
        CREATION_DATE = l_def_crq_rec.creation_date,
        LAST_UPDATED_BY = l_def_crq_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_crq_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_crq_rec.last_update_login
    WHERE ID = l_def_crq_rec.id;

    x_crq_rec := l_crq_rec;
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
  -- update_row for:OKL_CREDIT_REQUESTS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_rec                     IN crqv_rec_type,
    x_crqv_rec                     OUT NOCOPY crqv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crqv_rec                     crqv_rec_type := p_crqv_rec;
    l_def_crqv_rec                 crqv_rec_type;
    l_db_crqv_rec                  crqv_rec_type;
    l_crq_rec                      crq_rec_type;
    lx_crq_rec                     crq_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_crqv_rec IN crqv_rec_type
    ) RETURN crqv_rec_type IS
      l_crqv_rec crqv_rec_type := p_crqv_rec;
    BEGIN
      l_crqv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_crqv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_crqv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_crqv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_crqv_rec IN crqv_rec_type,
      x_crqv_rec OUT NOCOPY crqv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crqv_rec := p_crqv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_crqv_rec := get_rec(p_crqv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_crqv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.id := l_db_crqv_rec.id;
        END IF;
        IF (x_crqv_rec.quote_id = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.quote_id := l_db_crqv_rec.quote_id;
        END IF;
        IF (x_crqv_rec.credit_req_number = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.credit_req_number := l_db_crqv_rec.credit_req_number;
        END IF;
        IF (x_crqv_rec.credit_req_id = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.credit_req_id := l_db_crqv_rec.credit_req_id;
        END IF;
        IF (x_crqv_rec.credit_amount = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.credit_amount := l_db_crqv_rec.credit_amount;
        END IF;
        IF (x_crqv_rec.requested_by = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.requested_by := l_db_crqv_rec.requested_by;
        END IF;
        IF (x_crqv_rec.requested_date = OKC_API.G_MISS_DATE)
        THEN
          x_crqv_rec.requested_date := l_db_crqv_rec.requested_date;
        END IF;
        IF (x_crqv_rec.approved_by = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.approved_by := l_db_crqv_rec.approved_by;
        END IF;
        IF (x_crqv_rec.approved_date = OKC_API.G_MISS_DATE)
        THEN
          x_crqv_rec.approved_date := l_db_crqv_rec.approved_date;
        END IF;
        IF (x_crqv_rec.status = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.status := l_db_crqv_rec.status;
        END IF;
        IF (x_crqv_rec.credit_khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.credit_khr_id := l_db_crqv_rec.credit_khr_id;
        END IF;
        IF (x_crqv_rec.currency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.currency_code := l_db_crqv_rec.currency_code;
        END IF;
        IF (x_crqv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute_category := l_db_crqv_rec.attribute_category;
        END IF;
        IF (x_crqv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute1 := l_db_crqv_rec.attribute1;
        END IF;
        IF (x_crqv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute2 := l_db_crqv_rec.attribute2;
        END IF;
        IF (x_crqv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute3 := l_db_crqv_rec.attribute3;
        END IF;
        IF (x_crqv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute4 := l_db_crqv_rec.attribute4;
        END IF;
        IF (x_crqv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute5 := l_db_crqv_rec.attribute5;
        END IF;
        IF (x_crqv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute6 := l_db_crqv_rec.attribute6;
        END IF;
        IF (x_crqv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute7 := l_db_crqv_rec.attribute7;
        END IF;
        IF (x_crqv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute8 := l_db_crqv_rec.attribute8;
        END IF;
        IF (x_crqv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute9 := l_db_crqv_rec.attribute9;
        END IF;
        IF (x_crqv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute10 := l_db_crqv_rec.attribute10;
        END IF;
        IF (x_crqv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute11 := l_db_crqv_rec.attribute11;
        END IF;
        IF (x_crqv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute12 := l_db_crqv_rec.attribute12;
        END IF;
        IF (x_crqv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute13 := l_db_crqv_rec.attribute13;
        END IF;
        IF (x_crqv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute14 := l_db_crqv_rec.attribute14;
        END IF;
        IF (x_crqv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_crqv_rec.attribute15 := l_db_crqv_rec.attribute15;
        END IF;
        IF (x_crqv_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.org_id := l_db_crqv_rec.org_id;
        END IF;
        IF (x_crqv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.created_by := l_db_crqv_rec.created_by;
        END IF;
        IF (x_crqv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_crqv_rec.creation_date := l_db_crqv_rec.creation_date;
        END IF;
        IF (x_crqv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.last_updated_by := l_db_crqv_rec.last_updated_by;
        END IF;
        IF (x_crqv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_crqv_rec.last_update_date := l_db_crqv_rec.last_update_date;
        END IF;
        IF (x_crqv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_crqv_rec.last_update_login := l_db_crqv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CREDIT_REQUESTS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_crqv_rec IN crqv_rec_type,
      x_crqv_rec OUT NOCOPY crqv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crqv_rec := p_crqv_rec;
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
      p_crqv_rec,                        -- IN
      x_crqv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_crqv_rec, l_def_crqv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_crqv_rec := fill_who_columns(l_def_crqv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_crqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_crqv_rec, l_db_crqv_rec);
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
      p_crqv_rec                     => p_crqv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_crqv_rec, l_crq_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_crq_rec,
      lx_crq_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_crq_rec, l_def_crqv_rec);
    x_crqv_rec := l_def_crqv_rec;
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
  -- PL/SQL TBL update_row for:crqv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_tbl                     IN crqv_tbl_type,
    x_crqv_tbl                     OUT NOCOPY crqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crqv_tbl.COUNT > 0) THEN
      i := p_crqv_tbl.FIRST;
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
            p_crqv_rec                     => p_crqv_tbl(i),
            x_crqv_rec                     => x_crqv_tbl(i));
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
        EXIT WHEN (i = p_crqv_tbl.LAST);
        i := p_crqv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:CRQV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_tbl                     IN crqv_tbl_type,
    x_crqv_tbl                     OUT NOCOPY crqv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crqv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_crqv_tbl                     => p_crqv_tbl,
        x_crqv_tbl                     => x_crqv_tbl,
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
  ----------------------------------------
  -- delete_row for:OKL_CREDIT_REQUESTS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crq_rec                      IN crq_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crq_rec                      crq_rec_type := p_crq_rec;
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

    DELETE FROM OKL_CREDIT_REQUESTS
     WHERE ID = p_crq_rec.id;

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
  -- delete_row for:OKL_CREDIT_REQUESTS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_rec                     IN crqv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crqv_rec                     crqv_rec_type := p_crqv_rec;
    l_crq_rec                      crq_rec_type;
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
    migrate(l_crqv_rec, l_crq_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_crq_rec
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
  -----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CREDIT_REQUESTS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_tbl                     IN crqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crqv_tbl.COUNT > 0) THEN
      i := p_crqv_tbl.FIRST;
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
            p_crqv_rec                     => p_crqv_tbl(i));
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
        EXIT WHEN (i = p_crqv_tbl.LAST);
        i := p_crqv_tbl.NEXT(i);
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

  -----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CREDIT_REQUESTS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crqv_tbl                     IN crqv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crqv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_crqv_tbl                     => p_crqv_tbl,
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

END OKL_CRQ_PVT;

/
