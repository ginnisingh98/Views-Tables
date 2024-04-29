--------------------------------------------------------
--  DDL for Package Body OKL_POX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POX_PVT" AS
/* $Header: OKLSPOXB.pls 120.4 2007/12/07 09:06:17 sosharma noship $ */
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
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_trans_num
  ---------------------------------------------------------------------------
  FUNCTION get_trans_num RETURN NUMBER IS
    l_newvalue NUMBER;
  BEGIN
    SELECT OKL_POX_SEQ.NEXTVAL INTO	l_newvalue FROM dual;
    RETURN(l_newvalue);
  END get_trans_num;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_POOL_TRANSACTIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_poxv_rec                     IN poxv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN poxv_rec_type IS
    CURSOR okl_poxv_pk_csr (p_id IN NUMBER) IS
    SELECT
	ID,
	OBJECT_VERSION_NUMBER,
	POL_ID,
	TRANSACTION_NUMBER,
	TRANSACTION_DATE,
	TRANSACTION_TYPE,
	TRANSACTION_SUB_TYPE,
	DATE_EFFECTIVE,
	CURRENCY_CODE,
	CURRENCY_CONVERSION_TYPE,
	CURRENCY_CONVERSION_DATE,
	CURRENCY_CONVERSION_RATE,
	TRANSACTION_REASON,
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
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	LEGAL_ENTITY_ID,
 TRANSACTION_STATUS
      FROM OKL_POOL_TRANSACTIONS_V
     WHERE OKL_POOL_TRANSACTIONS_V.id = p_id;
    l_okl_poxv_pk                  okl_poxv_pk_csr%ROWTYPE;
    l_poxv_rec                     poxv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_poxv_pk_csr (p_poxv_rec.id);
    FETCH okl_poxv_pk_csr INTO
	l_poxv_rec.id,
	l_poxv_rec.object_version_number,
	l_poxv_rec.pol_id,
	l_poxv_rec.transaction_number,
	l_poxv_rec.transaction_date,
	l_poxv_rec.transaction_type,
	l_poxv_rec.transaction_sub_type,
	l_poxv_rec.date_effective,
	l_poxv_rec.currency_code,
	l_poxv_rec.currency_conversion_type,
	l_poxv_rec.currency_conversion_date,
	l_poxv_rec.currency_conversion_rate,
	l_poxv_rec.transaction_reason,
	l_poxv_rec.attribute_category,
	l_poxv_rec.attribute1,
	l_poxv_rec.attribute2,
	l_poxv_rec.attribute3,
	l_poxv_rec.attribute4,
	l_poxv_rec.attribute5,
	l_poxv_rec.attribute6,
	l_poxv_rec.attribute7,
	l_poxv_rec.attribute8,
	l_poxv_rec.attribute9,
	l_poxv_rec.attribute10,
	l_poxv_rec.attribute11,
	l_poxv_rec.attribute12,
	l_poxv_rec.attribute13,
	l_poxv_rec.attribute14,
	l_poxv_rec.attribute15,
	l_poxv_rec.request_id,
	l_poxv_rec.program_application_id,
	l_poxv_rec.program_id,
	l_poxv_rec.program_update_date,
	l_poxv_rec.created_by,
	l_poxv_rec.creation_date,
	l_poxv_rec.last_updated_by,
	l_poxv_rec.last_update_date,
	l_poxv_rec.last_update_login,
	l_poxv_rec.legal_entity_id,
 l_poxv_rec.transaction_status;
    x_no_data_found := okl_poxv_pk_csr%NOTFOUND;
    CLOSE okl_poxv_pk_csr;
    RETURN(l_poxv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_poxv_rec                     IN poxv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN poxv_rec_type IS
    l_poxv_rec                     poxv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_poxv_rec := get_rec(p_poxv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_poxv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_poxv_rec                     IN poxv_rec_type
  ) RETURN poxv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_poxv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: okl_pool_transactions
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pox_rec                      IN pox_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pox_rec_type IS
    CURSOR okl_pool_transactions_pk_csr (p_id IN NUMBER) IS
    SELECT
	ID,
	OBJECT_VERSION_NUMBER,
	POL_ID,
	TRANSACTION_NUMBER,
	TRANSACTION_DATE,
	TRANSACTION_TYPE,
	TRANSACTION_SUB_TYPE,
	DATE_EFFECTIVE,
	CURRENCY_CODE,
	CURRENCY_CONVERSION_TYPE,
	CURRENCY_CONVERSION_DATE,
	CURRENCY_CONVERSION_RATE,
	TRANSACTION_REASON,
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
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	LEGAL_ENTITY_ID,
 TRANSACTION_STATUS
     FROM okl_pool_transactions
     WHERE okl_pool_transactions.id = p_id;
    l_okl_pool_transactions_pk       okl_pool_transactions_pk_csr%ROWTYPE;
    l_pox_rec                      pox_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pool_transactions_pk_csr (p_pox_rec.id);
    FETCH okl_pool_transactions_pk_csr INTO
	l_pox_rec.id,
	l_pox_rec.object_version_number,
	l_pox_rec.pol_id,
	l_pox_rec.transaction_number,
	l_pox_rec.transaction_date,
	l_pox_rec.transaction_type,
	l_pox_rec.transaction_sub_type,
	l_pox_rec.date_effective,
	l_pox_rec.currency_code,
	l_pox_rec.currency_conversion_type,
	l_pox_rec.currency_conversion_date,
	l_pox_rec.currency_conversion_rate,
	l_pox_rec.transaction_reason,
	l_pox_rec.attribute_category,
	l_pox_rec.attribute1,
	l_pox_rec.attribute2,
	l_pox_rec.attribute3,
	l_pox_rec.attribute4,
	l_pox_rec.attribute5,
	l_pox_rec.attribute6,
	l_pox_rec.attribute7,
	l_pox_rec.attribute8,
	l_pox_rec.attribute9,
	l_pox_rec.attribute10,
	l_pox_rec.attribute11,
	l_pox_rec.attribute12,
	l_pox_rec.attribute13,
	l_pox_rec.attribute14,
	l_pox_rec.attribute15,
	l_pox_rec.request_id,
	l_pox_rec.program_application_id,
	l_pox_rec.program_id,
	l_pox_rec.program_update_date,
	l_pox_rec.created_by,
	l_pox_rec.creation_date,
	l_pox_rec.last_updated_by,
	l_pox_rec.last_update_date,
	l_pox_rec.last_update_login,
	l_pox_rec.legal_entity_id,
 l_pox_rec.transaction_status;
    x_no_data_found := okl_pool_transactions_pk_csr%NOTFOUND;
    CLOSE okl_pool_transactions_pk_csr;
    RETURN(l_pox_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pox_rec                      IN pox_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pox_rec_type IS
    l_pox_rec                      pox_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_pox_rec := get_rec(p_pox_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pox_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pox_rec                      IN pox_rec_type
  ) RETURN pox_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pox_rec, l_row_not_found));
  END get_rec;

  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_POOL_TRANSACTIONS_V
  -- mvasudev, hold this off for now
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_poxv_rec   IN poxv_rec_type
  ) RETURN poxv_rec_type IS
    l_poxv_rec                     poxv_rec_type := p_poxv_rec;
  BEGIN
    IF (l_poxv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.id := NULL;
    END IF;
    IF (l_poxv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.object_version_number := NULL;
    END IF;
    IF (l_poxv_rec.pol_id = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.pol_id := NULL;
    END IF;
    IF (l_poxv_rec.transaction_number = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.transaction_number := NULL;
    END IF;
    IF (l_poxv_rec.transaction_date = OKL_API.G_MISS_DATE ) THEN
      l_poxv_rec.transaction_date := NULL;
    END IF;
    IF (l_poxv_rec.transaction_type = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.transaction_type := NULL;
    END IF;
    IF (l_poxv_rec.transaction_sub_type = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.transaction_sub_type := NULL;
    END IF;
    IF (l_poxv_rec.date_effective = OKL_API.G_MISS_DATE ) THEN
      l_poxv_rec.date_effective := NULL;
    END IF;
    IF (l_poxv_rec.currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.currency_code := NULL;
    END IF;
    IF (l_poxv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_poxv_rec.currency_conversion_date = OKL_API.G_MISS_DATE ) THEN
      l_poxv_rec.currency_conversion_date := NULL;
    END IF;
    IF (l_poxv_rec.currency_conversion_rate = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_poxv_rec.transaction_reason = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.transaction_reason := NULL;
    END IF;
    IF (l_poxv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute_category := NULL;
    END IF;
    IF (l_poxv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute1 := NULL;
    END IF;
    IF (l_poxv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute2 := NULL;
    END IF;
    IF (l_poxv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute3 := NULL;
    END IF;
    IF (l_poxv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute4 := NULL;
    END IF;
    IF (l_poxv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute5 := NULL;
    END IF;
    IF (l_poxv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute6 := NULL;
    END IF;
    IF (l_poxv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute7 := NULL;
    END IF;
    IF (l_poxv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute8 := NULL;
    END IF;
    IF (l_poxv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute9 := NULL;
    END IF;
    IF (l_poxv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute10 := NULL;
    END IF;
    IF (l_poxv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute11 := NULL;
    END IF;
    IF (l_poxv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute12 := NULL;
    END IF;
    IF (l_poxv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute13 := NULL;
    END IF;
    IF (l_poxv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute14 := NULL;
    END IF;
    IF (l_poxv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute15 := NULL;
    END IF;
    IF (l_poxv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.attribute1 := NULL;
    END IF;
    IF (l_poxv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.request_id := NULL;
    END IF;
    IF (l_poxv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.program_application_id := NULL;
    END IF;
    IF (l_poxv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.program_id := NULL;
    END IF;
    IF (l_poxv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_poxv_rec.program_update_date := NULL;
    END IF;
    IF (l_poxv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.created_by := NULL;
    END IF;
    IF (l_poxv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_poxv_rec.creation_date := NULL;
    END IF;
    IF (l_poxv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.last_updated_by := NULL;
    END IF;
    IF (l_poxv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_poxv_rec.last_update_date := NULL;
    END IF;
    IF (l_poxv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.last_update_login := NULL;
    END IF;
    IF (l_poxv_rec.legal_entity_id = OKL_API.G_MISS_NUM ) THEN
      l_poxv_rec.legal_entity_id := NULL;
    END IF;
    IF (l_poxv_rec.transaction_status = OKL_API.G_MISS_CHAR ) THEN
      l_poxv_rec.transaction_status := NULL;
    END IF;

    RETURN(l_poxv_rec);
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
      NULL;
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
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;

  -------------------------------------
  -- Validate_Attributes for: pol_id --
  -------------------------------------
  PROCEDURE validate_pol_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_pol_id                       IN NUMBER) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_POL_POX_FK;
  CURSOR okl_polv_pk_csr (p_id IN OKL_POOL_TRANSACTIONS_V.pol_id%TYPE) IS
  SELECT '1'
    FROM OKL_POOLS
   WHERE OKL_POOLS.id = p_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_pol_id = OKL_API.G_MISS_NUM OR
        p_pol_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'pol_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_polv_pk_csr(p_pol_id);
    FETCH okl_polv_pk_csr INTO l_dummy;
    l_row_not_found := okl_polv_pk_csr%NOTFOUND;
    CLOSE okl_polv_pk_csr;

    IF l_row_not_found THEN
      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'pol_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      IF okl_polv_pk_csr%ISOPEN THEN
        CLOSE okl_polv_pk_csr;
      END IF;
  END validate_pol_id;

  -------------------------------------
  -- Validate_Attributes for: transaction_number --
  -------------------------------------
  PROCEDURE validate_transaction_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_transaction_number                       IN NUMBER) IS

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_transaction_number = OKL_API.G_MISS_NUM OR
        p_transaction_number IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'transaction_number');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_transaction_number;

  -------------------------------------
  -- Validate_Attributes for: Legal Entity ID --
  -------------------------------------
  PROCEDURE validate_legal_entity_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_legal_entity_id                   IN NUMBER) IS
    l_dummy                       VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_legal_entity_id = OKL_API.G_MISS_NUM OR
        p_legal_entity_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'legal_entity_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      l_dummy := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_legal_entity_id);
      IF  l_dummy <>1 THEN
          Okl_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'legal_entity_id');
	  x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_legal_entity_id;


  -------------------------------------
  -- Validate_Attributes for: transaction_date --
  -------------------------------------
  PROCEDURE validate_transaction_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_transaction_date                       IN DATE) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_transaction_date = OKL_API.G_MISS_DATE OR
        p_transaction_date IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'transaction_date');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_transaction_date;

  -------------------------------------
  -- Validate_Attributes for: transaction_type --
  -------------------------------------
  PROCEDURE validate_transaction_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_transaction_type                       IN VARCHAR2) IS

   l_found VARCHAR2(1);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_transaction_type = OKL_API.G_MISS_CHAR OR
        p_transaction_type IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'transaction_type');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	--Check if transaction_type exists in the fnd_common_lookups or not
     l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_POOL_TRANSACTION_TYPE',
                                                         p_lookup_code => p_transaction_type);


	IF (l_found <> OKL_API.G_TRUE ) THEN
             OKL_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'transaction_type');
	     x_return_status := OKL_API.G_RET_STS_ERROR;
		 -- raise the exception as there's no matching foreign key value
		 RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_transaction_type;

  -------------------------------------
  -- Validate_Attributes for: transaction_reason --
  -------------------------------------
  PROCEDURE validate_transaction_reason(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_transaction_reason                       IN VARCHAR2) IS

   l_found VARCHAR2(1);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_transaction_reason = OKL_API.G_MISS_CHAR OR
        p_transaction_reason IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'transaction_reason');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	--Check if transaction_reason exists in the fnd_common_lookups or not
     l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_POOL_TRANSACTION_REASON',
                                                         p_lookup_code => p_transaction_reason);


	IF (l_found <> OKL_API.G_TRUE ) THEN
             OKL_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'transaction_reason');
	     x_return_status := OKL_API.G_RET_STS_ERROR;
		 -- raise the exception as there's no matching foreign key value
		 RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_transaction_reason;
   ---------------------------------------------------------------------------
  -- PROCEDURE Validate_transaction_Status_Record
  ---------------------------------------------------------------------------
/*
PROCEDURE validate_transaction_status(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_transaction_status                       IN VARCHAR2) IS

   l_found VARCHAR2(1);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_transaction_status = OKL_API.G_MISS_CHAR OR
        p_transaction_status IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'p_transaction_status');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	--Check if transaction_status exists in the fnd_common_lookups or not
     l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_POOL_TRANSACTION_STATUS',
                                                         p_lookup_code => p_transaction_status);


	IF (l_found <> OKL_API.G_TRUE ) THEN
             OKL_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'transaction_status');
	     x_return_status := OKL_API.G_RET_STS_ERROR;
		 -- raise the exception as there's no matching foreign key value
		 RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_transaction_status;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Pox_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Pox_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Pox_Record(p_poxv_rec      IN      poxv_rec_type
                                       ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy		VARCHAR2(1)	:= '?';
  l_row_found		BOOLEAN 	:= FALSE;

  -- Cursor for Pox Unique Key
      CURSOR okl_pox_uk_csr(p_poxv_rec IN poxv_rec_type) IS
      SELECT '1'
      FROM   OKL_POOL_TRANSACTIONS_V
      WHERE  transaction_number =  p_poxv_rec.transaction_number
       AND  id     <> NVL(p_poxv_rec.id,-9999);

  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    OPEN okl_pox_uk_csr(p_poxv_rec);
    FETCH okl_pox_uk_csr INTO l_dummy;
    l_row_found := okl_pox_uk_csr%FOUND;
    CLOSE okl_pox_uk_csr;
    IF l_row_found THEN
	OKL_API.set_message(G_APP_NAME,G_OKL_UNQS);
	x_return_status := OKL_API.G_RET_STS_ERROR;
     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UNEXPECTED_ERROR,
                              p_token1       => G_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      IF okl_pox_uk_csr%isopen THEN
        CLOSE okl_pox_uk_csr;
      END IF;

  END Validate_Unique_Pox_Record;


  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_POOL_TRANSACTIONS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_poxv_rec                     IN poxv_rec_type
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
    validate_id(x_return_status, p_poxv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_poxv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- pol_id
    -- ***
    validate_pol_id(x_return_status, p_poxv_rec.pol_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- transaction_number
    -- ***
    validate_transaction_number(x_return_status, p_poxv_rec.transaction_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- transaction_date
    -- ***
    validate_transaction_date(x_return_status, p_poxv_rec.transaction_date);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- transaction_type
    -- ***
    validate_transaction_type(x_return_status, p_poxv_rec.transaction_type);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- transaction_reason
    -- ***
    validate_transaction_reason(x_return_status, p_poxv_rec.transaction_reason);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- legal_entity_id
    -- ***
    validate_legal_entity_id(x_return_status, p_poxv_rec.legal_entity_id);
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
  -----------------------------------------
  -- Validate Record for:OKL_POOL_TRANSACTIONS_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_poxv_rec IN poxv_rec_type,
    p_db_poxv_rec IN poxv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_poxv_rec IN poxv_rec_type,
      p_db_poxv_rec IN poxv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys(p_poxv_rec, p_db_poxv_rec);
    -- mvasudev added, 11/08/2002
    validate_unique_pox_record(p_poxv_rec, l_return_status  );
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_poxv_rec IN poxv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_poxv_rec                  poxv_rec_type := get_rec(p_poxv_rec);
  BEGIN
    l_return_status := Validate_Record(p_poxv_rec => p_poxv_rec,
                                       p_db_poxv_rec => l_db_poxv_rec);
    RETURN (l_return_status);
  END Validate_Record;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN poxv_rec_type,
    p_to   IN OUT NOCOPY pox_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.pol_id := p_from.pol_id;
    p_to.transaction_number := p_from.transaction_number;
    p_to.transaction_date := p_from.transaction_date;
    p_to.transaction_type := p_from.transaction_type;
    p_to.transaction_sub_type := p_from.transaction_sub_type;
    p_to.date_effective := p_from.date_effective;
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.transaction_reason := p_from.transaction_reason;
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
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.legal_entity_id := p_from.legal_entity_id;
    p_to.transaction_status := p_from.transaction_status;

  END migrate;
  PROCEDURE migrate (
    p_from IN pox_rec_type,
    p_to   IN OUT NOCOPY poxv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.pol_id := p_from.pol_id;
    p_to.transaction_number := p_from.transaction_number;
    p_to.transaction_date := p_from.transaction_date;
    p_to.transaction_type := p_from.transaction_type;
    p_to.transaction_sub_type := p_from.transaction_sub_type;
    p_to.date_effective := p_from.date_effective;
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.transaction_reason := p_from.transaction_reason;
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
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.legal_entity_id := p_from.legal_entity_id;
    p_to.transaction_status := p_from.transaction_status;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_POOL_TRANSACTIONS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_rec                     IN poxv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_poxv_rec                     poxv_rec_type := p_poxv_rec;
    l_pox_rec                      pox_rec_type;
    l_pox_rec                      pox_rec_type;
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
    l_return_status := Validate_Attributes(l_poxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_poxv_rec);
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
  -------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_POOL_TRANSACTIONS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_poxv_tbl.COUNT > 0) THEN
      i := p_poxv_tbl.FIRST;
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
            p_poxv_rec                     => p_poxv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_poxv_tbl.LAST);
        i := p_poxv_tbl.NEXT(i);
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

  -------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_POOL_TRANSACTIONS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_poxv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_poxv_tbl                     => p_poxv_tbl,
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
  -- insert_row for:okl_pool_transactions --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pox_rec                      IN pox_rec_type,
    x_pox_rec                      OUT NOCOPY pox_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pox_rec                      pox_rec_type := p_pox_rec;
    l_def_pox_rec                  pox_rec_type;
    --------------------------------------------
    -- Set_Attributes for:okl_pool_transactions --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_pox_rec IN pox_rec_type,
      x_pox_rec OUT NOCOPY pox_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pox_rec := p_pox_rec;
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
      p_pox_rec,                         -- IN
      l_pox_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO okl_pool_transactions(
	ID,
	OBJECT_VERSION_NUMBER,
	POL_ID,
	TRANSACTION_NUMBER,
	TRANSACTION_DATE,
	TRANSACTION_TYPE,
	TRANSACTION_SUB_TYPE,
	DATE_EFFECTIVE,
	CURRENCY_CODE,
	CURRENCY_CONVERSION_TYPE,
	CURRENCY_CONVERSION_DATE,
	CURRENCY_CONVERSION_RATE,
	TRANSACTION_REASON,
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
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	LEGAL_ENTITY_ID,
 TRANSACTION_STATUS)
    VALUES (
	l_pox_rec.id,
	l_pox_rec.object_version_number,
	l_pox_rec.pol_id,
	l_pox_rec.transaction_number,
	l_pox_rec.transaction_date,
	l_pox_rec.transaction_type,
	l_pox_rec.transaction_sub_type,
	l_pox_rec.date_effective,
	l_pox_rec.currency_code,
	l_pox_rec.currency_conversion_type,
	l_pox_rec.currency_conversion_date,
	l_pox_rec.currency_conversion_rate,
	l_pox_rec.transaction_reason,
	l_pox_rec.attribute_category,
	l_pox_rec.attribute1,
	l_pox_rec.attribute2,
	l_pox_rec.attribute3,
	l_pox_rec.attribute4,
	l_pox_rec.attribute5,
	l_pox_rec.attribute6,
	l_pox_rec.attribute7,
	l_pox_rec.attribute8,
	l_pox_rec.attribute9,
	l_pox_rec.attribute10,
	l_pox_rec.attribute11,
	l_pox_rec.attribute12,
	l_pox_rec.attribute13,
	l_pox_rec.attribute14,
	l_pox_rec.attribute15,
	l_pox_rec.request_id,
	l_pox_rec.program_application_id,
	l_pox_rec.program_id,
	l_pox_rec.program_update_date,
	l_pox_rec.created_by,
	l_pox_rec.creation_date,
	l_pox_rec.last_updated_by,
	l_pox_rec.last_update_date,
	l_pox_rec.last_update_login,
	l_pox_rec.legal_entity_id,
 l_pox_rec.transaction_status);
    -- Set OUT values
    x_pox_rec := l_pox_rec;
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
  -------------------------------------------
  -- insert_row for :OKL_POOL_TRANSACTIONS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_rec                     IN poxv_rec_type,
    x_poxv_rec                     OUT NOCOPY poxv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_poxv_rec                     poxv_rec_type := p_poxv_rec;
    l_def_poxv_rec                 poxv_rec_type;
    l_pox_rec                      pox_rec_type;
    lx_pox_rec                     pox_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_poxv_rec IN poxv_rec_type
    ) RETURN poxv_rec_type IS
      l_poxv_rec poxv_rec_type := p_poxv_rec;
    BEGIN
      l_poxv_rec.CREATION_DATE := SYSDATE;
      l_poxv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_poxv_rec.LAST_UPDATE_DATE := l_poxv_rec.CREATION_DATE;
      l_poxv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_poxv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_poxv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_POOL_TRANSACTIONS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_poxv_rec IN poxv_rec_type,
      x_poxv_rec OUT NOCOPY poxv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_poxv_rec := p_poxv_rec;
      x_poxv_rec.OBJECT_VERSION_NUMBER := 1;

      -- concurrent program columns
      SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL,Fnd_Global.CONC_REQUEST_ID),
             DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL,Fnd_Global.PROG_APPL_ID),
             DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL,Fnd_Global.CONC_PROGRAM_ID),
             DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
      INTO   x_poxv_rec.REQUEST_ID
            ,x_poxv_rec.PROGRAM_APPLICATION_ID
            ,x_poxv_rec.PROGRAM_ID
            ,x_poxv_rec.PROGRAM_UPDATE_DATE
      FROM DUAL;
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
    l_poxv_rec := null_out_defaults(p_poxv_rec);
    -- Set primary key value
    l_poxv_rec.ID := get_seq_id;
    l_poxv_rec.transaction_number := get_trans_num;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_poxv_rec,                        -- IN
      l_def_poxv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_poxv_rec := fill_who_columns(l_def_poxv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_poxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_poxv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_poxv_rec, l_pox_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pox_rec,
      lx_pox_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pox_rec, l_def_poxv_rec);
    -- Set OUT values
    x_poxv_rec := l_def_poxv_rec;
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
  -- PL/SQL TBL insert_row for:poxv_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    x_poxv_tbl                     OUT NOCOPY poxv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_poxv_tbl.COUNT > 0) THEN
      i := p_poxv_tbl.FIRST;
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
            p_poxv_rec                     => p_poxv_tbl(i),
            x_poxv_rec                     => x_poxv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_poxv_tbl.LAST);
        i := p_poxv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:poxv_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    x_poxv_tbl                     OUT NOCOPY poxv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_poxv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_poxv_tbl                     => p_poxv_tbl,
        x_poxv_tbl                     => x_poxv_tbl,
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
  -- lock_row for:okl_pool_transactions --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pox_rec                      IN pox_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pox_rec IN pox_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM okl_pool_transactions
     WHERE ID = p_pox_rec.id
       AND OBJECT_VERSION_NUMBER = p_pox_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_pox_rec IN pox_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM okl_pool_transactions
     WHERE ID = p_pox_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        okl_pool_transactions.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       okl_pool_transactions.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pox_rec);
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
      OPEN lchk_csr(p_pox_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pox_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pox_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for: OKL_POOL_TRANSACTIONS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_rec                     IN poxv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pox_rec                      pox_rec_type;
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
    migrate(p_poxv_rec, l_pox_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pox_rec
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
  -- PL/SQL TBL lock_row for:poxv_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_poxv_tbl.COUNT > 0) THEN
      i := p_poxv_tbl.FIRST;
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
            p_poxv_rec                     => p_poxv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_poxv_tbl.LAST);
        i := p_poxv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:poxv_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_poxv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_poxv_tbl                     => p_poxv_tbl,
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
  -- update_row for:okl_pool_transactions --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pox_rec                      IN pox_rec_type,
    x_pox_rec                      OUT NOCOPY pox_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pox_rec                      pox_rec_type := p_pox_rec;
    l_def_pox_rec                  pox_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pox_rec IN pox_rec_type,
      x_pox_rec OUT NOCOPY pox_rec_type
    ) RETURN VARCHAR2 IS
      l_pox_rec                      pox_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pox_rec := p_pox_rec;
      -- Get current database values
      l_pox_rec := get_rec(p_pox_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

        IF (x_pox_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.id := l_pox_rec.id;
        END IF;
        IF (x_pox_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.object_version_number := l_pox_rec.object_version_number;
        END IF;
        IF (x_pox_rec.pol_id = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.pol_id := l_pox_rec.pol_id;
        END IF;
        IF (x_pox_rec.transaction_number = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.transaction_number := l_pox_rec.transaction_number;
        END IF;
        IF (x_pox_rec.transaction_date = OKL_API.G_MISS_DATE)
        THEN
          x_pox_rec.transaction_date := l_pox_rec.transaction_date;
        END IF;
        IF (x_pox_rec.transaction_type = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.transaction_type := l_pox_rec.transaction_type;
        END IF;
        IF (x_pox_rec.transaction_sub_type = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.transaction_sub_type := l_pox_rec.transaction_sub_type;
        END IF;
        IF (x_pox_rec.date_effective = OKL_API.G_MISS_DATE)
        THEN
          x_pox_rec.date_effective := l_pox_rec.date_effective;
        END IF;
        IF (x_pox_rec.currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.currency_code := l_pox_rec.currency_code;
        END IF;
        IF (x_pox_rec.currency_conversion_type = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.currency_conversion_type := l_pox_rec.currency_conversion_type;
        END IF;
        IF (x_pox_rec.currency_conversion_date = OKL_API.G_MISS_DATE)
        THEN
          x_pox_rec.currency_conversion_date := l_pox_rec.currency_conversion_date;
        END IF;
        IF (x_pox_rec.currency_conversion_rate = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.currency_conversion_rate := l_pox_rec.currency_conversion_rate;
        END IF;
        IF (x_pox_rec.transaction_reason = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.transaction_reason := l_pox_rec.transaction_reason;
        END IF;
        IF (x_pox_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute_category := l_pox_rec.attribute_category;
        END IF;
        IF (x_pox_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute1 := l_pox_rec.attribute1;
        END IF;
        IF (x_pox_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute2 := l_pox_rec.attribute2;
        END IF;
        IF (x_pox_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute3 := l_pox_rec.attribute3;
        END IF;
        IF (x_pox_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute4 := l_pox_rec.attribute4;
        END IF;
        IF (x_pox_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute5 := l_pox_rec.attribute5;
        END IF;
        IF (x_pox_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute6 := l_pox_rec.attribute6;
        END IF;
        IF (x_pox_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute7 := l_pox_rec.attribute7;
        END IF;
        IF (x_pox_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute8 := l_pox_rec.attribute8;
        END IF;
        IF (x_pox_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute9 := l_pox_rec.attribute9;
        END IF;
        IF (x_pox_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute10 := l_pox_rec.attribute10;
        END IF;
        IF (x_pox_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute11 := l_pox_rec.attribute11;
        END IF;
        IF (x_pox_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute12 := l_pox_rec.attribute12;
        END IF;
        IF (x_pox_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute13 := l_pox_rec.attribute13;
        END IF;
        IF (x_pox_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute14 := l_pox_rec.attribute14;
        END IF;
        IF (x_pox_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.attribute15 := l_pox_rec.attribute15;
        END IF;
        IF (x_pox_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.request_id := l_pox_rec.request_id;
        END IF;
        IF (x_pox_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.program_application_id := l_pox_rec.program_application_id;
        END IF;
        IF (x_pox_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.program_id := l_pox_rec.program_id;
        END IF;
        IF (x_pox_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pox_rec.program_update_date := l_pox_rec.program_update_date;
        END IF;
        IF (x_pox_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.created_by := l_pox_rec.created_by;
        END IF;
        IF (x_pox_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_pox_rec.creation_date := l_pox_rec.creation_date;
        END IF;
        IF (x_pox_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.last_updated_by := l_pox_rec.last_updated_by;
        END IF;
        IF (x_pox_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pox_rec.last_update_date := l_pox_rec.last_update_date;
        END IF;
        IF (x_pox_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.last_update_login := l_pox_rec.last_update_login;
        END IF;
        IF (x_pox_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_pox_rec.legal_entity_id := l_pox_rec.legal_entity_id;
        END IF;
        IF (x_pox_rec.transaction_status = OKL_API.G_MISS_CHAR)
        THEN
          x_pox_rec.transaction_status := l_pox_rec.transaction_status;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:okl_pool_transactions --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_pox_rec IN pox_rec_type,
      x_pox_rec OUT NOCOPY pox_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pox_rec := p_pox_rec;
      x_pox_rec.OBJECT_VERSION_NUMBER := p_pox_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_pox_rec,                         -- IN
      l_pox_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pox_rec, l_def_pox_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE okl_pool_transactions
    SET OBJECT_VERSION_NUMBER = l_def_pox_rec.object_version_number,
        POL_ID = l_def_pox_rec.pol_id,
        transaction_number = l_def_pox_rec.transaction_number,
        transaction_date = l_def_pox_rec.transaction_date,
        transaction_type = l_def_pox_rec.transaction_type,
        transaction_sub_type = l_def_pox_rec.transaction_sub_type,
        date_effective = l_def_pox_rec.date_effective,
        currency_code = l_def_pox_rec.currency_code,
        currency_conversion_type = l_def_pox_rec.currency_conversion_type,
        currency_conversion_date = l_def_pox_rec.currency_conversion_date,
        currency_conversion_rate = l_def_pox_rec.currency_conversion_rate,
        transaction_reason = l_def_pox_rec.transaction_reason,
        ATTRIBUTE_CATEGORY = l_def_pox_rec.attribute_category,
        ATTRIBUTE1 = l_def_pox_rec.attribute1,
        ATTRIBUTE2 = l_def_pox_rec.attribute2,
        ATTRIBUTE3 = l_def_pox_rec.attribute3,
        ATTRIBUTE4 = l_def_pox_rec.attribute4,
        ATTRIBUTE5 = l_def_pox_rec.attribute5,
        ATTRIBUTE6 = l_def_pox_rec.attribute6,
        ATTRIBUTE7 = l_def_pox_rec.attribute7,
        ATTRIBUTE8 = l_def_pox_rec.attribute8,
        ATTRIBUTE9 = l_def_pox_rec.attribute9,
        ATTRIBUTE10 = l_def_pox_rec.attribute10,
        ATTRIBUTE11 = l_def_pox_rec.attribute11,
        ATTRIBUTE12 = l_def_pox_rec.attribute12,
        ATTRIBUTE13 = l_def_pox_rec.attribute13,
        ATTRIBUTE14 = l_def_pox_rec.attribute14,
        ATTRIBUTE15 = l_def_pox_rec.attribute15,
        REQUEST_ID = l_def_pox_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_pox_rec.program_application_id,
        PROGRAM_ID = l_def_pox_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_pox_rec.program_update_date,
        CREATED_BY = l_def_pox_rec.created_by,
        CREATION_DATE = l_def_pox_rec.creation_date,
        LAST_UPDATED_BY = l_def_pox_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pox_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pox_rec.last_update_login,
	LEGAL_ENTITY_ID = l_def_pox_rec.legal_entity_id,
 	TRANSACTION_STATUS = l_def_pox_rec.transaction_status
    WHERE ID = l_def_pox_rec.id;

    x_pox_rec := l_pox_rec;
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
  ------------------------------------------
  -- update_row for:OKL_POOL_TRANSACTIONS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_rec                     IN poxv_rec_type,
    x_poxv_rec                     OUT NOCOPY poxv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_poxv_rec                     poxv_rec_type := p_poxv_rec;
    l_def_poxv_rec                 poxv_rec_type;
    l_db_poxv_rec                  poxv_rec_type;
    l_pox_rec                      pox_rec_type;
    lx_pox_rec                     pox_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_poxv_rec IN poxv_rec_type
    ) RETURN poxv_rec_type IS
      l_poxv_rec poxv_rec_type := p_poxv_rec;
    BEGIN
      l_poxv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_poxv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_poxv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_poxv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_poxv_rec IN poxv_rec_type,
      x_poxv_rec OUT NOCOPY poxv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_poxv_rec := p_poxv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_poxv_rec := get_rec(p_poxv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_poxv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.id := l_db_poxv_rec.id;
        END IF;
        IF (x_poxv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.object_version_number := l_db_poxv_rec.object_version_number;
        END IF;
        IF (x_poxv_rec.pol_id = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.pol_id := l_db_poxv_rec.pol_id;
        END IF;
        IF (x_poxv_rec.transaction_number = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.transaction_number := l_db_poxv_rec.transaction_number;
        END IF;
        IF (x_poxv_rec.transaction_date = OKL_API.G_MISS_DATE)
        THEN
          x_poxv_rec.transaction_date := l_db_poxv_rec.transaction_date;
        END IF;
        IF (x_poxv_rec.transaction_type = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.transaction_type := l_db_poxv_rec.transaction_type;
        END IF;
        IF (x_poxv_rec.transaction_sub_type = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.transaction_sub_type := l_db_poxv_rec.transaction_sub_type;
        END IF;
        IF (x_poxv_rec.date_effective = OKL_API.G_MISS_DATE)
        THEN
          x_poxv_rec.date_effective := l_db_poxv_rec.date_effective;
        END IF;
        IF (x_poxv_rec.currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.currency_code := l_db_poxv_rec.currency_code;
        END IF;
        IF (x_poxv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.currency_conversion_type := l_db_poxv_rec.currency_conversion_type;
        END IF;
        IF (x_poxv_rec.currency_conversion_date = OKL_API.G_MISS_DATE)
        THEN
          x_poxv_rec.currency_conversion_date := l_db_poxv_rec.currency_conversion_date;
        END IF;
        IF (x_poxv_rec.currency_conversion_rate = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.currency_conversion_rate := l_db_poxv_rec.currency_conversion_rate;
        END IF;
        IF (x_poxv_rec.transaction_reason = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.transaction_reason := l_db_poxv_rec.transaction_reason;
        END IF;
        IF (x_poxv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute_category := l_db_poxv_rec.attribute_category;
        END IF;
        IF (x_poxv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute1 := l_db_poxv_rec.attribute1;
        END IF;
        IF (x_poxv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute2 := l_db_poxv_rec.attribute2;
        END IF;
        IF (x_poxv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute3 := l_db_poxv_rec.attribute3;
        END IF;
        IF (x_poxv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute4 := l_db_poxv_rec.attribute4;
        END IF;
        IF (x_poxv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute5 := l_db_poxv_rec.attribute5;
        END IF;
        IF (x_poxv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute6 := l_db_poxv_rec.attribute6;
        END IF;
        IF (x_poxv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute7 := l_db_poxv_rec.attribute7;
        END IF;
        IF (x_poxv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute8 := l_db_poxv_rec.attribute8;
        END IF;
        IF (x_poxv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute9 := l_db_poxv_rec.attribute9;
        END IF;
        IF (x_poxv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute10 := l_db_poxv_rec.attribute10;
        END IF;
        IF (x_poxv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute11 := l_db_poxv_rec.attribute11;
        END IF;
        IF (x_poxv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute12 := l_db_poxv_rec.attribute12;
        END IF;
        IF (x_poxv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute13 := l_db_poxv_rec.attribute13;
        END IF;
        IF (x_poxv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute14 := l_db_poxv_rec.attribute14;
        END IF;
        IF (x_poxv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.attribute15 := l_db_poxv_rec.attribute15;
        END IF;
        IF (x_poxv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.request_id := l_db_poxv_rec.request_id;
        END IF;
        IF (x_poxv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.program_application_id := l_db_poxv_rec.program_application_id;
        END IF;
        IF (x_poxv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.program_id := l_db_poxv_rec.program_id;
        END IF;
        IF (x_poxv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_poxv_rec.program_update_date := l_db_poxv_rec.program_update_date;
        END IF;
        IF (x_poxv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.created_by := l_db_poxv_rec.created_by;
        END IF;
        IF (x_poxv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_poxv_rec.creation_date := l_db_poxv_rec.creation_date;
        END IF;
        IF (x_poxv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.last_updated_by := l_db_poxv_rec.last_updated_by;
        END IF;
        IF (x_poxv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_poxv_rec.last_update_date := l_db_poxv_rec.last_update_date;
        END IF;
        IF (x_poxv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.last_update_login := l_db_poxv_rec.last_update_login;
        END IF;
        IF (x_poxv_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_poxv_rec.legal_entity_id := l_db_poxv_rec.legal_entity_id;
        END IF;
        IF (x_poxv_rec.transaction_status = OKL_API.G_MISS_CHAR)
        THEN
          x_poxv_rec.transaction_status := l_db_poxv_rec.transaction_status;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_POOL_TRANSACTIONS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_poxv_rec IN poxv_rec_type,
      x_poxv_rec OUT NOCOPY poxv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_poxv_rec := p_poxv_rec;
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
      p_poxv_rec,                        -- IN
      x_poxv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_poxv_rec, l_def_poxv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_poxv_rec := fill_who_columns(l_def_poxv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_poxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_poxv_rec, l_db_poxv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
    -- mvasudev commented
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_poxv_rec                     => p_poxv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    */

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_poxv_rec, l_pox_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pox_rec,
      lx_pox_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pox_rec, l_def_poxv_rec);
    x_poxv_rec := l_def_poxv_rec;
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
  -- PL/SQL TBL update_row for:poxv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    x_poxv_tbl                     OUT NOCOPY poxv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_poxv_tbl.COUNT > 0) THEN
      i := p_poxv_tbl.FIRST;
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
            p_poxv_rec                     => p_poxv_tbl(i),
            x_poxv_rec                     => x_poxv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_poxv_tbl.LAST);
        i := p_poxv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:poxv_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    x_poxv_tbl                     OUT NOCOPY poxv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_poxv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_poxv_tbl                     => p_poxv_tbl,
        x_poxv_tbl                     => x_poxv_tbl,
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
  -- delete_row for:okl_pool_transactions --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pox_rec                      IN pox_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pox_rec                      pox_rec_type := p_pox_rec;
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

    DELETE FROM okl_pool_transactions
     WHERE ID = p_pox_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_POOL_TRANSACTIONS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_rec                     IN poxv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_poxv_rec                     poxv_rec_type := p_poxv_rec;
    l_pox_rec                      pox_rec_type;
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
    migrate(l_poxv_rec, l_pox_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pox_rec
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
  -----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_POOL_TRANSACTIONS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_poxv_tbl.COUNT > 0) THEN
      i := p_poxv_tbl.FIRST;
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
            p_poxv_rec                     => p_poxv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_poxv_tbl.LAST);
        i := p_poxv_tbl.NEXT(i);
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

  -----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_POOL_TRANSACTIONS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_poxv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_poxv_tbl                     => p_poxv_tbl,
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

END Okl_Pox_Pvt;

/
