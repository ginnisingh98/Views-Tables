--------------------------------------------------------
--  DDL for Package Body OKL_QAB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QAB_PVT" AS
/* $Header: OKLSQABB.pls 120.5 2006/07/13 13:00:22 adagur noship $ */
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
  -- FUNCTION get_rec for: OKL_TXD_QTE_ANTCPT_BILL_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qabv_rec                     IN qabv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qabv_rec_type IS
    CURSOR okl_qabv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            KHR_ID,
            QTE_ID,
            KLE_ID,
            STY_ID,
            SEL_DATE, -- rmunjulu EDAT ADDED
            AMOUNT,
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
            LAST_UPDATE_LOGIN,
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
      FROM OKL_TXD_QTE_ANTCPT_BILL
     WHERE OKL_TXD_QTE_ANTCPT_BILL.id = p_id;
    l_okl_qabv_pk                  okl_qabv_pk_csr%ROWTYPE;
    l_qabv_rec                     qabv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_qabv_pk_csr (p_qabv_rec.id);
    FETCH okl_qabv_pk_csr INTO
              l_qabv_rec.id,
              l_qabv_rec.object_version_number,
              l_qabv_rec.khr_id,
              l_qabv_rec.qte_id,
              l_qabv_rec.kle_id,
              l_qabv_rec.sty_id,
              l_qabv_rec.sel_date, -- rmunjulu EDAT ADDED
              l_qabv_rec.amount,
              l_qabv_rec.org_id,
              l_qabv_rec.request_id,
              l_qabv_rec.program_application_id,
              l_qabv_rec.program_id,
              l_qabv_rec.program_update_date,
              l_qabv_rec.attribute_category,
              l_qabv_rec.attribute1,
              l_qabv_rec.attribute2,
              l_qabv_rec.attribute3,
              l_qabv_rec.attribute4,
              l_qabv_rec.attribute5,
              l_qabv_rec.attribute6,
              l_qabv_rec.attribute7,
              l_qabv_rec.attribute8,
              l_qabv_rec.attribute9,
              l_qabv_rec.attribute10,
              l_qabv_rec.attribute11,
              l_qabv_rec.attribute12,
              l_qabv_rec.attribute13,
              l_qabv_rec.attribute14,
              l_qabv_rec.attribute15,
              l_qabv_rec.created_by,
              l_qabv_rec.creation_date,
              l_qabv_rec.last_updated_by,
              l_qabv_rec.last_update_date,
              l_qabv_rec.last_update_login,
              l_qabv_rec.currency_code,
              l_qabv_rec.currency_conversion_code,
              l_qabv_rec.currency_conversion_type,
              l_qabv_rec.currency_conversion_rate,
              l_qabv_rec.currency_conversion_date;
    x_no_data_found := okl_qabv_pk_csr%NOTFOUND;
    CLOSE okl_qabv_pk_csr;
    RETURN(l_qabv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_qabv_rec                     IN qabv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN qabv_rec_type IS
    l_qabv_rec                     qabv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_qabv_rec := get_rec(p_qabv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_qabv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_qabv_rec                     IN qabv_rec_type
  ) RETURN qabv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qabv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXD_QTE_ANTCPT_BILL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qab_rec                      IN qab_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qab_rec_type IS
    CURSOR okl_txd_qte_antcpt_bill_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            KHR_ID,
            QTE_ID,
            KLE_ID,
            STY_ID,
            SEL_DATE, -- rmunjulu EDAT ADDED
            AMOUNT,
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
            LAST_UPDATE_LOGIN,
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
      FROM Okl_Txd_Qte_Antcpt_Bill
     WHERE okl_txd_qte_antcpt_bill.id = p_id;
    l_okl_txd_qte_antcpt_bill_pk   okl_txd_qte_antcpt_bill_pk_csr%ROWTYPE;
    l_qab_rec                      qab_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txd_qte_antcpt_bill_pk_csr (p_qab_rec.id);
    FETCH okl_txd_qte_antcpt_bill_pk_csr INTO
              l_qab_rec.id,
              l_qab_rec.object_version_number,
              l_qab_rec.khr_id,
              l_qab_rec.qte_id,
              l_qab_rec.kle_id,
              l_qab_rec.sty_id,
              l_qab_rec.sel_date, -- rmunjulu EDAT ADDED
              l_qab_rec.amount,
              l_qab_rec.org_id,
              l_qab_rec.request_id,
              l_qab_rec.program_application_id,
              l_qab_rec.program_id,
              l_qab_rec.program_update_date,
              l_qab_rec.attribute_category,
              l_qab_rec.attribute1,
              l_qab_rec.attribute2,
              l_qab_rec.attribute3,
              l_qab_rec.attribute4,
              l_qab_rec.attribute5,
              l_qab_rec.attribute6,
              l_qab_rec.attribute7,
              l_qab_rec.attribute8,
              l_qab_rec.attribute9,
              l_qab_rec.attribute10,
              l_qab_rec.attribute11,
              l_qab_rec.attribute12,
              l_qab_rec.attribute13,
              l_qab_rec.attribute14,
              l_qab_rec.attribute15,
              l_qab_rec.created_by,
              l_qab_rec.creation_date,
              l_qab_rec.last_updated_by,
              l_qab_rec.last_update_date,
              l_qab_rec.last_update_login,
              l_qab_rec.currency_code,
              l_qab_rec.currency_conversion_code,
              l_qab_rec.currency_conversion_type,
              l_qab_rec.currency_conversion_rate,
              l_qab_rec.currency_conversion_date;
    x_no_data_found := okl_txd_qte_antcpt_bill_pk_csr%NOTFOUND;
    CLOSE okl_txd_qte_antcpt_bill_pk_csr;
    RETURN(l_qab_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_qab_rec                      IN qab_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN qab_rec_type IS
    l_qab_rec                      qab_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_qab_rec := get_rec(p_qab_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_qab_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_qab_rec                      IN qab_rec_type
  ) RETURN qab_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qab_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXD_QTE_ANTCPT_BILL_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_qabv_rec   IN qabv_rec_type
  ) RETURN qabv_rec_type IS
    l_qabv_rec                     qabv_rec_type := p_qabv_rec;
  BEGIN
    IF (l_qabv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.id := NULL;
    END IF;
    IF (l_qabv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.object_version_number := NULL;
    END IF;
    IF (l_qabv_rec.khr_id = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.khr_id := NULL;
    END IF;
    IF (l_qabv_rec.qte_id = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.qte_id := NULL;
    END IF;
    IF (l_qabv_rec.kle_id = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.kle_id := NULL;
    END IF;
    IF (l_qabv_rec.sty_id = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.sty_id := NULL;
    END IF;
    -- rmunjulu EDAT ADDED
    IF (l_qabv_rec.sel_date = OKC_API.G_MISS_DATE ) THEN
      l_qabv_rec.sel_date := NULL;
    END IF;
    IF (l_qabv_rec.amount = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.amount := NULL;
    END IF;
    IF (l_qabv_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.org_id := NULL;
    END IF;
    IF (l_qabv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.request_id := NULL;
    END IF;
    IF (l_qabv_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.program_application_id := NULL;
    END IF;
    IF (l_qabv_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.program_id := NULL;
    END IF;
    IF (l_qabv_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_qabv_rec.program_update_date := NULL;
    END IF;
    IF (l_qabv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute_category := NULL;
    END IF;
    IF (l_qabv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute1 := NULL;
    END IF;
    IF (l_qabv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute2 := NULL;
    END IF;
    IF (l_qabv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute3 := NULL;
    END IF;
    IF (l_qabv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute4 := NULL;
    END IF;
    IF (l_qabv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute5 := NULL;
    END IF;
    IF (l_qabv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute6 := NULL;
    END IF;
    IF (l_qabv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute7 := NULL;
    END IF;
    IF (l_qabv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute8 := NULL;
    END IF;
    IF (l_qabv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute9 := NULL;
    END IF;
    IF (l_qabv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute10 := NULL;
    END IF;
    IF (l_qabv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute11 := NULL;
    END IF;
    IF (l_qabv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute12 := NULL;
    END IF;
    IF (l_qabv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute13 := NULL;
    END IF;
    IF (l_qabv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute14 := NULL;
    END IF;
    IF (l_qabv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.attribute15 := NULL;
    END IF;
    IF (l_qabv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.created_by := NULL;
    END IF;
    IF (l_qabv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_qabv_rec.creation_date := NULL;
    END IF;
    IF (l_qabv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.last_updated_by := NULL;
    END IF;
    IF (l_qabv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_qabv_rec.last_update_date := NULL;
    END IF;
    IF (l_qabv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.last_update_login := NULL;
    END IF;
    IF (l_qabv_rec.currency_code = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.currency_code := NULL;
    END IF;
    IF (l_qabv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.currency_conversion_code := NULL;
    END IF;
    IF (l_qabv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR ) THEN
      l_qabv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_qabv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM ) THEN
      l_qabv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_qabv_rec.currency_conversion_date = OKC_API.G_MISS_DATE ) THEN
      l_qabv_rec.currency_conversion_date := NULL;
    END IF;
    RETURN(l_qabv_rec);
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
  -------------------------------------
  -- Validate_Attributes for: KHR_ID --
  -------------------------------------
  -- rmunjulu Added code for fkey
  PROCEDURE validate_khr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_khr_id                       IN NUMBER) IS

      -- select the ID of the parent record from the parent
      -- rmunjulu
      CURSOR okl_khr_csr (p_khr_id  IN NUMBER) IS
      SELECT 'x'
      FROM   OKC_K_HEADERS_B khr
      WHERE  khr.id = p_khr_id;

      -- rmunjulu
      l_val VARCHAR2(3);
      l_invalid_value VARCHAR2(3);

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- rmunjulu
    l_invalid_value := 'N';

    IF (p_khr_id = OKC_API.G_MISS_NUM OR
        p_khr_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'khr_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      -- rmunjulu added condition for fkey
      OPEN okl_khr_csr(p_khr_id);
      FETCH okl_khr_csr INTO l_val;
      IF okl_khr_csr%NOTFOUND THEN
         l_invalid_value := 'Y';
      END IF;
      CLOSE okl_khr_csr;
      IF l_invalid_value = 'Y' THEN
         OKC_API.set_message(G_APP_NAME, G_NO_PARENT_RECORD, G_COL_NAME_TOKEN, 'khr_id',
                             G_CHILD_TABLE_TOKEN, 'OKL_TXL_QTE_ANTCPT_BILL_V', G_PARENT_TABLE_TOKEN, 'OKC_K_HEADERS_B');
         x_return_status := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- rmunjulu
      IF okl_khr_csr%ISOPEN THEN
        CLOSE okl_khr_csr;
      END IF;
      null;
    WHEN OTHERS THEN
      -- rmunjulu
      IF okl_khr_csr%ISOPEN THEN
        CLOSE okl_khr_csr;
      END IF;
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_khr_id;
  -------------------------------------
  -- Validate_Attributes for: QTE_ID --
  -------------------------------------
  -- rmunjulu Added code for fkey
  PROCEDURE validate_qte_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_qte_id                       IN NUMBER) IS

      -- select the ID of the parent record from the parent
      -- rmunjulu
      CURSOR okl_qte_csr (p_qte_id  IN NUMBER) IS
      SELECT 'x'
      FROM   OKL_TRX_QUOTES_B qte
      WHERE  qte.id = p_qte_id;

      -- rmunjulu
      l_val VARCHAR2(3);
      l_invalid_value VARCHAR2(3);

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- rmunjulu
    l_invalid_value := 'N';

    IF (p_qte_id = OKC_API.G_MISS_NUM OR
        p_qte_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'qte_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      -- rmunjulu added condition for fkey
      OPEN okl_qte_csr(p_qte_id);
      FETCH okl_qte_csr INTO l_val;
      IF okl_qte_csr%NOTFOUND THEN
         l_invalid_value := 'Y';
      END IF;
      CLOSE okl_qte_csr;
      IF l_invalid_value = 'Y' THEN
         OKC_API.set_message(G_APP_NAME, G_NO_PARENT_RECORD, G_COL_NAME_TOKEN, 'qte_id',
                             G_CHILD_TABLE_TOKEN, 'OKL_TXL_QTE_ANTCPT_BILL_V', G_PARENT_TABLE_TOKEN, 'OKL_TRX_QUOTES_B');
         x_return_status := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- rmunjulu
      IF okl_qte_csr%ISOPEN THEN
        CLOSE okl_qte_csr;
      END IF;
      null;
    WHEN OTHERS THEN
      -- rmunjulu
      IF okl_qte_csr%ISOPEN THEN
        CLOSE okl_qte_csr;
      END IF;
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_qte_id;
  -------------------------------------
  -- Validate_Attributes for: STY_ID --
  -------------------------------------
  -- rmunjulu Added code for fkey
  PROCEDURE validate_sty_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sty_id                       IN NUMBER) IS

      -- select the ID of the parent record from the parent
      -- rmunjulu
      CURSOR okl_sty_csr (p_sty_id  IN NUMBER) IS
      SELECT 'x'
      FROM   OKL_STRM_TYPE_B sty
      WHERE  sty.id = p_sty_id;

      -- rmunjulu
      l_val VARCHAR2(3);
      l_invalid_value VARCHAR2(3);

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- rmunjulu
    l_invalid_value := 'N';

    IF (p_sty_id = OKC_API.G_MISS_NUM OR
        p_sty_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sty_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      -- rmunjulu added condition for fkey
      OPEN okl_sty_csr(p_sty_id);
      FETCH okl_sty_csr INTO l_val;
      IF okl_sty_csr%NOTFOUND THEN
         l_invalid_value := 'Y';
      END IF;
      CLOSE okl_sty_csr;
      IF l_invalid_value = 'Y' THEN
         OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'sty_id');
         x_return_status := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- rmunjulu
      IF okl_sty_csr%ISOPEN THEN
        CLOSE okl_sty_csr;
      END IF;
      null;
    WHEN OTHERS THEN
      -- rmunjulu
      IF okl_sty_csr%ISOPEN THEN
        CLOSE okl_sty_csr;
      END IF;
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_sty_id;
  -------------------------------------
  -- Validate_Attributes for: AMOUNT --
  -------------------------------------
  PROCEDURE validate_amount(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_amount                       IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_amount = OKC_API.G_MISS_NUM OR
        p_amount IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'amount');
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
  END validate_amount;

  -------------------------------------
  -- Validate_Attributes for: KLE_ID --
  -------------------------------------
  -- rmunjulu Added this procedure to check fkey of kle_id
  PROCEDURE validate_kle_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_kle_id                       IN NUMBER) IS

      -- select the ID of the parent record from the parent
      -- rmunjulu
      CURSOR okl_kle_csr (p_kle_id  IN NUMBER) IS
      SELECT 'x'
      FROM   OKC_K_LINES_B kle
      WHERE  kle.id = p_kle_id;

      -- rmunjulu
      l_val VARCHAR2(3);
      l_invalid_value VARCHAR2(3);

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- rmunjulu
    l_invalid_value := 'N';

    IF (p_kle_id <> OKC_API.G_MISS_NUM AND
        p_kle_id IS NOT NULL)
    THEN
      -- rmunjulu added condition for fkey
      OPEN okl_kle_csr(p_kle_id);
      FETCH okl_kle_csr INTO l_val;
      IF okl_kle_csr%NOTFOUND THEN
         l_invalid_value := 'Y';
      END IF;
      CLOSE okl_kle_csr;
      IF l_invalid_value = 'Y' THEN
         OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'kle_id');
         x_return_status := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- rmunjulu
      IF okl_kle_csr%ISOPEN THEN
        CLOSE okl_kle_csr;
      END IF;
      null;
    WHEN OTHERS THEN
      -- rmunjulu
      IF okl_kle_csr%ISOPEN THEN
        CLOSE okl_kle_csr;
      END IF;
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_kle_id;

  -- Start of comments
  -- Procedure Name  : validate_currency_record
  -- Description     : Used for validation of Currency Code Conversion Coulms
  -- Business Rules  : If transaction currency <> functional currency, then
  --                   conversion columns are mandatory
  --                   Else If transaction currency = functional currency,
  --                   then conversion columns should all be NULL
  -- Parameters      : Record structure of OKL_TXD_QTE_ANTCPT_BILL_V table
  -- Version         : 1.0
  -- History         : 20-Sep-2004 rmunjulu :Added new procedure
  -- End of comments
  PROCEDURE validate_currency_record(p_qabv_rec      IN  qabv_rec_type,
                                     x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- If transaction currency <> functional currency, then conversion columns
    -- are mandatory
    IF (p_qabv_rec.currency_code <> p_qabv_rec.currency_conversion_code) THEN
      IF (p_qabv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR OR
         p_qabv_rec.currency_conversion_type IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_type');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_qabv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM OR
         p_qabv_rec.currency_conversion_rate IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_rate');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      IF (p_qabv_rec.currency_conversion_date = OKC_API.G_MISS_DATE OR
         p_qabv_rec.currency_conversion_date IS NULL) THEN
        --SET MESSAGE
        OKC_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'currency_conversion_date');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    -- Else If transaction currency = functional currency, then conversion columns
    -- should all be NULL
    ELSIF (p_qabv_rec.currency_code = p_qabv_rec.currency_conversion_code) THEN
      IF (p_qabv_rec.currency_conversion_type IS NOT NULL) OR
         (p_qabv_rec.currency_conversion_rate IS NOT NULL) OR
         (p_qabv_rec.currency_conversion_date IS NOT NULL) THEN
        --SET MESSAGE
        -- Currency conversion columns should be all null
        IF p_qabv_rec.currency_conversion_rate IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_rate');
        END IF;
        IF p_qabv_rec.currency_conversion_date IS NOT NULL THEN
          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'currency_conversion_date');
        END IF;
        IF p_qabv_rec.currency_conversion_type IS NOT NULL THEN
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


  -- Start of comments
  -- Procedure Name  : validate_currency_code
  -- Description     : Validation of Currency Code
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXD_QTE_ANTCPT_BILL_V table
  -- Version         : 1.0
  -- History         : 20-Sep-2004 rmunjulu :Added new procedure
  -- End of comments
  PROCEDURE validate_currency_code(p_qabv_rec      IN  qabv_rec_type,
                                   x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_qabv_rec.currency_code IS NULL) OR
       (p_qabv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_code');

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_qabv_rec.currency_code);
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



  -- Start of comments
  -- Procedure Name  : validate_currency_con_code
  -- Description     : Validation of Currency Conversion Code
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXD_QTE_ANTCPT_BILL_V table
  -- Version         : 1.0
  -- History         : 20-Sep-2004 rmunjulu :Added new procedure
  -- End of comments
  PROCEDURE validate_currency_con_code(p_qabv_rec      IN  qabv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_qabv_rec.currency_conversion_code IS NULL) OR
       (p_qabv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_conversion_code');
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- check from currency values using the generic okl_util.validate_currency_code
    l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_qabv_rec.currency_conversion_code);
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



  -- Start of comments
  -- Procedure Name  : validate_currency_con_type
  -- Description     : Validation of Currency Conversion type
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXD_QTE_ANTCPT_BILL_V table
  -- Version         : 1.0
  -- History         : 20-Sep-2004 rmunjulu :Added new procedure
  -- End of comments
  PROCEDURE validate_currency_con_type(p_qabv_rec      IN  qabv_rec_type,
                                       x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(3) := OKC_API.G_TRUE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_qabv_rec.currency_conversion_type <> OKL_API.G_MISS_CHAR AND
       p_qabv_rec.currency_conversion_type IS NOT NULL) THEN
      -- check from currency values using the generic okl_util.validate_currency_code
      l_return_status := OKL_ACCOUNTING_UTIL.validate_currency_con_type(p_qabv_rec.currency_conversion_type);
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


  -- Start of comments
  -- Procedure Name  : validate_org_id
  -- Description     : Validation of Org_Id
  -- Business Rules  :
  -- Parameters      : Record structure of OKL_TXD_QTE_ANTCPT_BILL_V table
  -- Version         : 1.0
  -- History         : 20-Sep-2004 rmunjulu :Added new procedure
  -- End of comments
PROCEDURE validate_org_id(
 x_return_status OUT NOCOPY VARCHAR2,
 p_org_id  IN NUMBER) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check org id validity using the generic function okl_util.check_org_id()
    l_return_status := OKL_UTIL.check_org_id (p_org_id);

    IF ( l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'org_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary;  validation can continue with the next column
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

  END validate_org_id;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------------
  -- Validate_Attributes for:OKL_TXD_QTE_ANTCPT_BILL_V --
  -------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_qabv_rec                     IN qabv_rec_type
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
    validate_id(x_return_status, p_qabv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_qabv_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- khr_id
    -- ***
    validate_khr_id(x_return_status, p_qabv_rec.khr_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- qte_id
    -- ***
    validate_qte_id(x_return_status, p_qabv_rec.qte_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- sty_id
    -- ***
    validate_sty_id(x_return_status, p_qabv_rec.sty_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- amount
    -- ***
    validate_amount(x_return_status, p_qabv_rec.amount);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  -- rmunjulu Post Tapi Gen Changes Start

    validate_org_id(x_return_status => l_return_status,
                    p_org_id        => p_qabv_rec.org_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    validate_kle_id(x_return_status => x_return_status,
                    p_kle_id        => p_qabv_rec.kle_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    validate_currency_code(p_qabv_rec      => p_qabv_rec,
                           x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_code(p_qabv_rec      => p_qabv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_con_type(p_qabv_rec      => p_qabv_rec,
                               x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
  -- rmunjulu Post Tapi Gen Changes End

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
  ---------------------------------------------------
  -- Validate Record for:OKL_TXD_QTE_ANTCPT_BILL_V --
  ---------------------------------------------------
  FUNCTION Validate_Record (
    p_qabv_rec IN qabv_rec_type,
    p_db_qabv_rec IN qabv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_qabv_rec IN qabv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_qabv_rec                  qabv_rec_type := get_rec(p_qabv_rec);

    -- rmunjulu post TAPI gen changes
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    -- rmunjulu post TAPI gen changes
    validate_currency_record(p_qabv_rec      => p_qabv_rec,
                             x_return_status => l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN qabv_rec_type,
    p_to   IN OUT NOCOPY qab_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.khr_id := p_from.khr_id;
    p_to.qte_id := p_from.qte_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sty_id := p_from.sty_id;
    -- rmunjulu EDAT ADDED
	p_to.sel_date := p_from.sel_date;
    p_to.amount := p_from.amount;
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
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_code := p_from.currency_conversion_code;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
  END migrate;
  PROCEDURE migrate (
    p_from IN qab_rec_type,
    p_to   IN OUT NOCOPY qabv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.khr_id := p_from.khr_id;
    p_to.qte_id := p_from.qte_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sty_id := p_from.sty_id;
    -- rmunjulu EDAT ADDED
    p_to.sel_date := p_from.sel_date;
    p_to.amount := p_from.amount;
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
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_code := p_from.currency_conversion_code;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- validate_row for:OKL_TXD_QTE_ANTCPT_BILL_V --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_rec                     IN qabv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qabv_rec                     qabv_rec_type := p_qabv_rec;
    l_qab_rec                      qab_rec_type;
    l_qab_rec                      qab_rec_type;
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
    l_return_status := Validate_Attributes(l_qabv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_qabv_rec);
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
  -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TXD_QTE_ANTCPT_BILL_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qabv_tbl.COUNT > 0) THEN
      i := p_qabv_tbl.FIRST;
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
            p_qabv_rec                     => p_qabv_tbl(i));
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
        EXIT WHEN (i = p_qabv_tbl.LAST);
        i := p_qabv_tbl.NEXT(i);
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

  -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TXD_QTE_ANTCPT_BILL_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qabv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_qabv_tbl                     => p_qabv_tbl,
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
  --------------------------------------------
  -- insert_row for:OKL_TXD_QTE_ANTCPT_BILL --
  --------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qab_rec                      IN qab_rec_type,
    x_qab_rec                      OUT NOCOPY qab_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qab_rec                      qab_rec_type := p_qab_rec;
    l_def_qab_rec                  qab_rec_type;
    ------------------------------------------------
    -- Set_Attributes for:OKL_TXD_QTE_ANTCPT_BILL --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_qab_rec IN qab_rec_type,
      x_qab_rec OUT NOCOPY qab_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qab_rec := p_qab_rec;
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
      p_qab_rec,                         -- IN
      l_qab_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXD_QTE_ANTCPT_BILL(
      id,
      object_version_number,
      khr_id,
      qte_id,
      kle_id,
      sty_id,
      sel_date,     -- rmunjulu EDAT ADDED
      amount,
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
      last_update_login,
      currency_code,
      currency_conversion_code,
      currency_conversion_type,
      currency_conversion_rate,
      currency_conversion_date)
    VALUES (
      l_qab_rec.id,
      l_qab_rec.object_version_number,
      l_qab_rec.khr_id,
      l_qab_rec.qte_id,
      l_qab_rec.kle_id,
      l_qab_rec.sty_id,
      l_qab_rec.sel_date,    -- rmunjulu EDAT ADDED
      l_qab_rec.amount,
      l_qab_rec.org_id,
      l_qab_rec.request_id,
      l_qab_rec.program_application_id,
      l_qab_rec.program_id,
      l_qab_rec.program_update_date,
      l_qab_rec.attribute_category,
      l_qab_rec.attribute1,
      l_qab_rec.attribute2,
      l_qab_rec.attribute3,
      l_qab_rec.attribute4,
      l_qab_rec.attribute5,
      l_qab_rec.attribute6,
      l_qab_rec.attribute7,
      l_qab_rec.attribute8,
      l_qab_rec.attribute9,
      l_qab_rec.attribute10,
      l_qab_rec.attribute11,
      l_qab_rec.attribute12,
      l_qab_rec.attribute13,
      l_qab_rec.attribute14,
      l_qab_rec.attribute15,
      l_qab_rec.created_by,
      l_qab_rec.creation_date,
      l_qab_rec.last_updated_by,
      l_qab_rec.last_update_date,
      l_qab_rec.last_update_login,
      l_qab_rec.currency_code,
      l_qab_rec.currency_conversion_code,
      l_qab_rec.currency_conversion_type,
      l_qab_rec.currency_conversion_rate,
      l_qab_rec.currency_conversion_date);
    -- Set OUT values
    x_qab_rec := l_qab_rec;
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
  -----------------------------------------------
  -- insert_row for :OKL_TXD_QTE_ANTCPT_BILL_V -- rmunjulu added code to default some values
  -----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_rec                     IN qabv_rec_type,
    x_qabv_rec                     OUT NOCOPY qabv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qabv_rec                     qabv_rec_type := p_qabv_rec;
    l_def_qabv_rec                 qabv_rec_type;
    l_qab_rec                      qab_rec_type;
    lx_qab_rec                     qab_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qabv_rec IN qabv_rec_type
    ) RETURN qabv_rec_type IS
      l_qabv_rec qabv_rec_type := p_qabv_rec;
    BEGIN
      l_qabv_rec.CREATION_DATE := SYSDATE;
      l_qabv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_qabv_rec.LAST_UPDATE_DATE := l_qabv_rec.CREATION_DATE;
      l_qabv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qabv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qabv_rec);
    END fill_who_columns;
    --------------------------------------------------
    -- Set_Attributes for:OKL_TXD_QTE_ANTCPT_BILL_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_qabv_rec IN qabv_rec_type,
      x_qabv_rec OUT NOCOPY qabv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qabv_rec := p_qabv_rec;
      x_qabv_rec.OBJECT_VERSION_NUMBER := 1;

      -- rmunjulu Post Tapi Gen Changes --- Start +++++++++++++++++++++++++++++

      -- Default the ORG ID if no value passed
      IF p_qabv_rec.org_id IS NULL
      OR p_qabv_rec.org_id = OKC_API.G_MISS_NUM THEN
        x_qabv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      END IF;

      x_qabv_rec.currency_conversion_code := OKL_AM_UTIL_PVT.get_functional_currency;

      IF p_qabv_rec.currency_code IS NULL
      OR p_qabv_rec.currency_code = OKC_API.G_MISS_CHAR THEN
        x_qabv_rec.currency_code := x_qabv_rec.currency_conversion_code;
      END IF;

      -- rmunjulu Post Tapi Gen Changes --- End   +++++++++++++++++++++++++++++

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
    l_qabv_rec := null_out_defaults(p_qabv_rec);
    -- Set primary key value
    l_qabv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_qabv_rec,                        -- IN
      l_def_qabv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qabv_rec := fill_who_columns(l_def_qabv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qabv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qabv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_qabv_rec, l_qab_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_qab_rec,
      lx_qab_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qab_rec, l_def_qabv_rec);
    -- Set OUT values
    x_qabv_rec := l_def_qabv_rec;
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
  -- PL/SQL TBL insert_row for:QABV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    x_qabv_tbl                     OUT NOCOPY qabv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qabv_tbl.COUNT > 0) THEN
      i := p_qabv_tbl.FIRST;
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
            p_qabv_rec                     => p_qabv_tbl(i),
            x_qabv_rec                     => x_qabv_tbl(i));
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
        EXIT WHEN (i = p_qabv_tbl.LAST);
        i := p_qabv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:QABV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    x_qabv_tbl                     OUT NOCOPY qabv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qabv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_qabv_tbl                     => p_qabv_tbl,
        x_qabv_tbl                     => x_qabv_tbl,
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
  ------------------------------------------
  -- lock_row for:OKL_TXD_QTE_ANTCPT_BILL --
  ------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qab_rec                      IN qab_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_qab_rec IN qab_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXD_QTE_ANTCPT_BILL
     WHERE ID = p_qab_rec.id
       AND OBJECT_VERSION_NUMBER = p_qab_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_qab_rec IN qab_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXD_QTE_ANTCPT_BILL
     WHERE ID = p_qab_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_TXD_QTE_ANTCPT_BILL.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_TXD_QTE_ANTCPT_BILL.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_qab_rec);
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
      OPEN lchk_csr(p_qab_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_qab_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_qab_rec.object_version_number THEN
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
  ---------------------------------------------
  -- lock_row for: OKL_TXD_QTE_ANTCPT_BILL_V --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_rec                     IN qabv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qab_rec                      qab_rec_type;
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
    migrate(p_qabv_rec, l_qab_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_qab_rec
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
  -- PL/SQL TBL lock_row for:QABV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_qabv_tbl.COUNT > 0) THEN
      i := p_qabv_tbl.FIRST;
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
            p_qabv_rec                     => p_qabv_tbl(i));
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
        EXIT WHEN (i = p_qabv_tbl.LAST);
        i := p_qabv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:QABV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_qabv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_qabv_tbl                     => p_qabv_tbl,
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
  --------------------------------------------
  -- update_row for:OKL_TXD_QTE_ANTCPT_BILL --
  --------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qab_rec                      IN qab_rec_type,
    x_qab_rec                      OUT NOCOPY qab_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qab_rec                      qab_rec_type := p_qab_rec;
    l_def_qab_rec                  qab_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qab_rec IN qab_rec_type,
      x_qab_rec OUT NOCOPY qab_rec_type
    ) RETURN VARCHAR2 IS
      l_qab_rec                      qab_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qab_rec := p_qab_rec;
      -- Get current database values
      l_qab_rec := get_rec(p_qab_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_qab_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.id := l_qab_rec.id;
        END IF;
        IF (x_qab_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.object_version_number := l_qab_rec.object_version_number;
        END IF;
        IF (x_qab_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.khr_id := l_qab_rec.khr_id;
        END IF;
        IF (x_qab_rec.qte_id = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.qte_id := l_qab_rec.qte_id;
        END IF;
        IF (x_qab_rec.kle_id = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.kle_id := l_qab_rec.kle_id;
        END IF;
        IF (x_qab_rec.sty_id = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.sty_id := l_qab_rec.sty_id;
        END IF;
        -- rmunjulu EDAT ADDED
        IF (x_qab_rec.sel_date = OKC_API.G_MISS_DATE)
        THEN
          x_qab_rec.sel_date := l_qab_rec.sel_date;
        END IF;
        IF (x_qab_rec.amount = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.amount := l_qab_rec.amount;
        END IF;
        IF (x_qab_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.org_id := l_qab_rec.org_id;
        END IF;
        IF (x_qab_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.request_id := l_qab_rec.request_id;
        END IF;
        IF (x_qab_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.program_application_id := l_qab_rec.program_application_id;
        END IF;
        IF (x_qab_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.program_id := l_qab_rec.program_id;
        END IF;
        IF (x_qab_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_qab_rec.program_update_date := l_qab_rec.program_update_date;
        END IF;
        IF (x_qab_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute_category := l_qab_rec.attribute_category;
        END IF;
        IF (x_qab_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute1 := l_qab_rec.attribute1;
        END IF;
        IF (x_qab_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute2 := l_qab_rec.attribute2;
        END IF;
        IF (x_qab_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute3 := l_qab_rec.attribute3;
        END IF;
        IF (x_qab_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute4 := l_qab_rec.attribute4;
        END IF;
        IF (x_qab_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute5 := l_qab_rec.attribute5;
        END IF;
        IF (x_qab_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute6 := l_qab_rec.attribute6;
        END IF;
        IF (x_qab_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute7 := l_qab_rec.attribute7;
        END IF;
        IF (x_qab_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute8 := l_qab_rec.attribute8;
        END IF;
        IF (x_qab_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute9 := l_qab_rec.attribute9;
        END IF;
        IF (x_qab_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute10 := l_qab_rec.attribute10;
        END IF;
        IF (x_qab_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute11 := l_qab_rec.attribute11;
        END IF;
        IF (x_qab_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute12 := l_qab_rec.attribute12;
        END IF;
        IF (x_qab_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute13 := l_qab_rec.attribute13;
        END IF;
        IF (x_qab_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute14 := l_qab_rec.attribute14;
        END IF;
        IF (x_qab_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.attribute15 := l_qab_rec.attribute15;
        END IF;
        IF (x_qab_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.created_by := l_qab_rec.created_by;
        END IF;
        IF (x_qab_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_qab_rec.creation_date := l_qab_rec.creation_date;
        END IF;
        IF (x_qab_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.last_updated_by := l_qab_rec.last_updated_by;
        END IF;
        IF (x_qab_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_qab_rec.last_update_date := l_qab_rec.last_update_date;
        END IF;
        IF (x_qab_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.last_update_login := l_qab_rec.last_update_login;
        END IF;
        IF (x_qab_rec.currency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.currency_code := l_qab_rec.currency_code;
        END IF;
        IF (x_qab_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.currency_conversion_code := l_qab_rec.currency_conversion_code;
        END IF;
        IF (x_qab_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
        THEN
          x_qab_rec.currency_conversion_type := l_qab_rec.currency_conversion_type;
        END IF;
        IF (x_qab_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
        THEN
          x_qab_rec.currency_conversion_rate := l_qab_rec.currency_conversion_rate;
        END IF;
        IF (x_qab_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
        THEN
          x_qab_rec.currency_conversion_date := l_qab_rec.currency_conversion_date;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKL_TXD_QTE_ANTCPT_BILL --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_qab_rec IN qab_rec_type,
      x_qab_rec OUT NOCOPY qab_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qab_rec := p_qab_rec;
      x_qab_rec.OBJECT_VERSION_NUMBER := p_qab_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_qab_rec,                         -- IN
      l_qab_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qab_rec, l_def_qab_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_TXD_QTE_ANTCPT_BILL
    SET OBJECT_VERSION_NUMBER = l_def_qab_rec.object_version_number,
        KHR_ID = l_def_qab_rec.khr_id,
        QTE_ID = l_def_qab_rec.qte_id,
        KLE_ID = l_def_qab_rec.kle_id,
        STY_ID = l_def_qab_rec.sty_id,
        SEL_DATE = l_def_qab_rec.sel_date,         -- rmunjulu EDAT ADDED
        AMOUNT = l_def_qab_rec.amount,
        ORG_ID = l_def_qab_rec.org_id,
        REQUEST_ID = l_def_qab_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_qab_rec.program_application_id,
        PROGRAM_ID = l_def_qab_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_qab_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_qab_rec.attribute_category,
        ATTRIBUTE1 = l_def_qab_rec.attribute1,
        ATTRIBUTE2 = l_def_qab_rec.attribute2,
        ATTRIBUTE3 = l_def_qab_rec.attribute3,
        ATTRIBUTE4 = l_def_qab_rec.attribute4,
        ATTRIBUTE5 = l_def_qab_rec.attribute5,
        ATTRIBUTE6 = l_def_qab_rec.attribute6,
        ATTRIBUTE7 = l_def_qab_rec.attribute7,
        ATTRIBUTE8 = l_def_qab_rec.attribute8,
        ATTRIBUTE9 = l_def_qab_rec.attribute9,
        ATTRIBUTE10 = l_def_qab_rec.attribute10,
        ATTRIBUTE11 = l_def_qab_rec.attribute11,
        ATTRIBUTE12 = l_def_qab_rec.attribute12,
        ATTRIBUTE13 = l_def_qab_rec.attribute13,
        ATTRIBUTE14 = l_def_qab_rec.attribute14,
        ATTRIBUTE15 = l_def_qab_rec.attribute15,
        CREATED_BY = l_def_qab_rec.created_by,
        CREATION_DATE = l_def_qab_rec.creation_date,
        LAST_UPDATED_BY = l_def_qab_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_qab_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_qab_rec.last_update_login,
        CURRENCY_CODE = l_def_qab_rec.currency_code,
        CURRENCY_CONVERSION_CODE = l_def_qab_rec.currency_conversion_code,
        CURRENCY_CONVERSION_TYPE = l_def_qab_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_qab_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_qab_rec.currency_conversion_date
    WHERE ID = l_def_qab_rec.id;

    x_qab_rec := l_qab_rec;
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
  ----------------------------------------------
  -- update_row for:OKL_TXD_QTE_ANTCPT_BILL_V --
  ----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_rec                     IN qabv_rec_type,
    x_qabv_rec                     OUT NOCOPY qabv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qabv_rec                     qabv_rec_type := p_qabv_rec;
    l_def_qabv_rec                 qabv_rec_type;
    l_db_qabv_rec                  qabv_rec_type;
    l_qab_rec                      qab_rec_type;
    lx_qab_rec                     qab_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qabv_rec IN qabv_rec_type
    ) RETURN qabv_rec_type IS
      l_qabv_rec qabv_rec_type := p_qabv_rec;
    BEGIN
      l_qabv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qabv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qabv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qabv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qabv_rec IN qabv_rec_type,
      x_qabv_rec OUT NOCOPY qabv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qabv_rec := p_qabv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_qabv_rec := get_rec(p_qabv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_qabv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.id := l_db_qabv_rec.id;
        END IF;
        IF (x_qabv_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.khr_id := l_db_qabv_rec.khr_id;
        END IF;
        IF (x_qabv_rec.qte_id = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.qte_id := l_db_qabv_rec.qte_id;
        END IF;
        IF (x_qabv_rec.kle_id = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.kle_id := l_db_qabv_rec.kle_id;
        END IF;
        IF (x_qabv_rec.sty_id = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.sty_id := l_db_qabv_rec.sty_id;
        END IF;
        -- rmunjulu EDAT ADDED
        IF (x_qabv_rec.sel_date = OKC_API.G_MISS_DATE)
        THEN
          x_qabv_rec.sel_date := l_db_qabv_rec.sel_date;
        END IF;
        IF (x_qabv_rec.amount = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.amount := l_db_qabv_rec.amount;
        END IF;
        IF (x_qabv_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.org_id := l_db_qabv_rec.org_id;
        END IF;
        IF (x_qabv_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.request_id := l_db_qabv_rec.request_id;
        END IF;
        IF (x_qabv_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.program_application_id := l_db_qabv_rec.program_application_id;
        END IF;
        IF (x_qabv_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.program_id := l_db_qabv_rec.program_id;
        END IF;
        IF (x_qabv_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_qabv_rec.program_update_date := l_db_qabv_rec.program_update_date;
        END IF;
        IF (x_qabv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute_category := l_db_qabv_rec.attribute_category;
        END IF;
        IF (x_qabv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute1 := l_db_qabv_rec.attribute1;
        END IF;
        IF (x_qabv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute2 := l_db_qabv_rec.attribute2;
        END IF;
        IF (x_qabv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute3 := l_db_qabv_rec.attribute3;
        END IF;
        IF (x_qabv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute4 := l_db_qabv_rec.attribute4;
        END IF;
        IF (x_qabv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute5 := l_db_qabv_rec.attribute5;
        END IF;
        IF (x_qabv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute6 := l_db_qabv_rec.attribute6;
        END IF;
        IF (x_qabv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute7 := l_db_qabv_rec.attribute7;
        END IF;
        IF (x_qabv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute8 := l_db_qabv_rec.attribute8;
        END IF;
        IF (x_qabv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute9 := l_db_qabv_rec.attribute9;
        END IF;
        IF (x_qabv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute10 := l_db_qabv_rec.attribute10;
        END IF;
        IF (x_qabv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute11 := l_db_qabv_rec.attribute11;
        END IF;
        IF (x_qabv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute12 := l_db_qabv_rec.attribute12;
        END IF;
        IF (x_qabv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute13 := l_db_qabv_rec.attribute13;
        END IF;
        IF (x_qabv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute14 := l_db_qabv_rec.attribute14;
        END IF;
        IF (x_qabv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.attribute15 := l_db_qabv_rec.attribute15;
        END IF;
        IF (x_qabv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.created_by := l_db_qabv_rec.created_by;
        END IF;
        IF (x_qabv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_qabv_rec.creation_date := l_db_qabv_rec.creation_date;
        END IF;
        IF (x_qabv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.last_updated_by := l_db_qabv_rec.last_updated_by;
        END IF;
        IF (x_qabv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_qabv_rec.last_update_date := l_db_qabv_rec.last_update_date;
        END IF;
        IF (x_qabv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.last_update_login := l_db_qabv_rec.last_update_login;
        END IF;
        IF (x_qabv_rec.currency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.currency_code := l_db_qabv_rec.currency_code;
        END IF;
        IF (x_qabv_rec.currency_conversion_code = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.currency_conversion_code := l_db_qabv_rec.currency_conversion_code;
        END IF;
        IF (x_qabv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
        THEN
          x_qabv_rec.currency_conversion_type := l_db_qabv_rec.currency_conversion_type;
        END IF;
        IF (x_qabv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
        THEN
          x_qabv_rec.currency_conversion_rate := l_db_qabv_rec.currency_conversion_rate;
        END IF;
        IF (x_qabv_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
        THEN
          x_qabv_rec.currency_conversion_date := l_db_qabv_rec.currency_conversion_date;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_TXD_QTE_ANTCPT_BILL_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_qabv_rec IN qabv_rec_type,
      x_qabv_rec OUT NOCOPY qabv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qabv_rec := p_qabv_rec;
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
      p_qabv_rec,                        -- IN
      x_qabv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qabv_rec, l_def_qabv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qabv_rec := fill_who_columns(l_def_qabv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qabv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qabv_rec, l_db_qabv_rec);
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
      p_qabv_rec                     => p_qabv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_qabv_rec, l_qab_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_qab_rec,
      lx_qab_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qab_rec, l_def_qabv_rec);
    x_qabv_rec := l_def_qabv_rec;
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
  -- PL/SQL TBL update_row for:qabv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    x_qabv_tbl                     OUT NOCOPY qabv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qabv_tbl.COUNT > 0) THEN
      i := p_qabv_tbl.FIRST;
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
            p_qabv_rec                     => p_qabv_tbl(i),
            x_qabv_rec                     => x_qabv_tbl(i));
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
        EXIT WHEN (i = p_qabv_tbl.LAST);
        i := p_qabv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:QABV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    x_qabv_tbl                     OUT NOCOPY qabv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qabv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_qabv_tbl                     => p_qabv_tbl,
        x_qabv_tbl                     => x_qabv_tbl,
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
  --------------------------------------------
  -- delete_row for:OKL_TXD_QTE_ANTCPT_BILL --
  --------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qab_rec                      IN qab_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qab_rec                      qab_rec_type := p_qab_rec;
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

    DELETE FROM OKL_TXD_QTE_ANTCPT_BILL
     WHERE ID = p_qab_rec.id;

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
  ----------------------------------------------
  -- delete_row for:OKL_TXD_QTE_ANTCPT_BILL_V --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_rec                     IN qabv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qabv_rec                     qabv_rec_type := p_qabv_rec;
    l_qab_rec                      qab_rec_type;
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
    migrate(l_qabv_rec, l_qab_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_qab_rec
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
  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TXD_QTE_ANTCPT_BILL_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qabv_tbl.COUNT > 0) THEN
      i := p_qabv_tbl.FIRST;
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
            p_qabv_rec                     => p_qabv_tbl(i));
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
        EXIT WHEN (i = p_qabv_tbl.LAST);
        i := p_qabv_tbl.NEXT(i);
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

  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TXD_QTE_ANTCPT_BILL_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qabv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_qabv_tbl                     => p_qabv_tbl,
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

END OKL_QAB_PVT;

/
