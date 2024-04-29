--------------------------------------------------------
--  DDL for Package Body OKL_SIX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SIX_PVT" AS
/* $Header: OKLSSIXB.pls 120.1 2005/07/08 23:54:50 cklee noship $ */

G_SOURCE_TRX_DATE_SUB_VAL CONSTANT VARCHAR2(30) DEFAULT 'OKL_SUB_TRX_DATE_SUB_VAL';
G_SOURCE_TRX_DATE_POOL_VAL CONSTANT VARCHAR2(30) DEFAULT 'OKL_SUB_TRX_DATE_POOL_VAL';

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
  -- FUNCTION get_rec for: OKL_TRX_SUBSIDY_POOLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sixv_rec                     IN sixv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sixv_rec_type IS
    CURSOR okl_trx_subsidy_pools_v_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            TRX_TYPE_CODE,
            SOURCE_TYPE_CODE,
            SOURCE_OBJECT_ID,
            SUBSIDY_POOL_ID,
            DNZ_ASSET_NUMBER,
            VENDOR_ID,
            SOURCE_TRX_DATE,
            TRX_DATE,
            SUBSIDY_ID,
            TRX_REASON_CODE,
            TRX_CURRENCY_CODE,
            TRX_AMOUNT,
            SUBSIDY_POOL_CURRENCY_CODE,
            SUBSIDY_POOL_AMOUNT,
            CONVERSION_RATE,
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
      FROM Okl_Trx_Subsidy_Pools_V
     WHERE okl_trx_subsidy_pools_v.id = p_id;
    l_okl_trx_subsidy_pools_v_pk   okl_trx_subsidy_pools_v_pk_csr%ROWTYPE;
    l_sixv_rec                     sixv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_subsidy_pools_v_pk_csr (p_sixv_rec.id);
    FETCH okl_trx_subsidy_pools_v_pk_csr INTO
              l_sixv_rec.id,
              l_sixv_rec.object_version_number,
              l_sixv_rec.trx_type_code,
              l_sixv_rec.source_type_code,
              l_sixv_rec.source_object_id,
              l_sixv_rec.subsidy_pool_id,
              l_sixv_rec.dnz_asset_number,
              l_sixv_rec.vendor_id,
              l_sixv_rec.source_trx_date,
              l_sixv_rec.trx_date,
              l_sixv_rec.subsidy_id,
              l_sixv_rec.trx_reason_code,
              l_sixv_rec.trx_currency_code,
              l_sixv_rec.trx_amount,
              l_sixv_rec.subsidy_pool_currency_code,
              l_sixv_rec.subsidy_pool_amount,
              l_sixv_rec.conversion_rate,
              l_sixv_rec.attribute_category,
              l_sixv_rec.attribute1,
              l_sixv_rec.attribute2,
              l_sixv_rec.attribute3,
              l_sixv_rec.attribute4,
              l_sixv_rec.attribute5,
              l_sixv_rec.attribute6,
              l_sixv_rec.attribute7,
              l_sixv_rec.attribute8,
              l_sixv_rec.attribute9,
              l_sixv_rec.attribute10,
              l_sixv_rec.attribute11,
              l_sixv_rec.attribute12,
              l_sixv_rec.attribute13,
              l_sixv_rec.attribute14,
              l_sixv_rec.attribute15,
              l_sixv_rec.created_by,
              l_sixv_rec.creation_date,
              l_sixv_rec.last_updated_by,
              l_sixv_rec.last_update_date,
              l_sixv_rec.last_update_login;
    x_no_data_found := okl_trx_subsidy_pools_v_pk_csr%NOTFOUND;
    CLOSE okl_trx_subsidy_pools_v_pk_csr;
    RETURN(l_sixv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_sixv_rec                     IN sixv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN sixv_rec_type IS
    l_sixv_rec                     sixv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_sixv_rec := get_rec(p_sixv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_sixv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_sixv_rec                     IN sixv_rec_type
  ) RETURN sixv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sixv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_SUBSIDY_POOLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_trx_subsidy_pools_rec    IN okl_trx_subsidy_pools_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_trx_subsidy_pools_rec_type IS
    CURSOR okl_trx_subsidy_pools_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            TRX_TYPE_CODE,
            SOURCE_TYPE_CODE,
            SOURCE_OBJECT_ID,
            SUBSIDY_POOL_ID,
            DNZ_ASSET_NUMBER,
            VENDOR_ID,
            SOURCE_TRX_DATE,
            TRX_DATE,
            SUBSIDY_ID,
            TRX_REASON_CODE,
            TRX_CURRENCY_CODE,
            TRX_AMOUNT,
            SUBSIDY_POOL_CURRENCY_CODE,
            SUBSIDY_POOL_AMOUNT,
            CONVERSION_RATE,
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
      FROM Okl_Trx_Subsidy_Pools
     WHERE okl_trx_subsidy_pools.id = p_id;
    l_okl_trx_subsidy_pools_pk     okl_trx_subsidy_pools_pk_csr%ROWTYPE;
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_subsidy_pools_pk_csr (p_okl_trx_subsidy_pools_rec.id);
    FETCH okl_trx_subsidy_pools_pk_csr INTO
              l_okl_trx_subsidy_pools_rec.id,
              l_okl_trx_subsidy_pools_rec.object_version_number,
              l_okl_trx_subsidy_pools_rec.trx_type_code,
              l_okl_trx_subsidy_pools_rec.source_type_code,
              l_okl_trx_subsidy_pools_rec.source_object_id,
              l_okl_trx_subsidy_pools_rec.subsidy_pool_id,
              l_okl_trx_subsidy_pools_rec.dnz_asset_number,
              l_okl_trx_subsidy_pools_rec.vendor_id,
              l_okl_trx_subsidy_pools_rec.source_trx_date,
              l_okl_trx_subsidy_pools_rec.trx_date,
              l_okl_trx_subsidy_pools_rec.subsidy_id,
              l_okl_trx_subsidy_pools_rec.trx_reason_code,
              l_okl_trx_subsidy_pools_rec.trx_currency_code,
              l_okl_trx_subsidy_pools_rec.trx_amount,
              l_okl_trx_subsidy_pools_rec.subsidy_pool_currency_code,
              l_okl_trx_subsidy_pools_rec.subsidy_pool_amount,
              l_okl_trx_subsidy_pools_rec.conversion_rate,
              l_okl_trx_subsidy_pools_rec.attribute_category,
              l_okl_trx_subsidy_pools_rec.attribute1,
              l_okl_trx_subsidy_pools_rec.attribute2,
              l_okl_trx_subsidy_pools_rec.attribute3,
              l_okl_trx_subsidy_pools_rec.attribute4,
              l_okl_trx_subsidy_pools_rec.attribute5,
              l_okl_trx_subsidy_pools_rec.attribute6,
              l_okl_trx_subsidy_pools_rec.attribute7,
              l_okl_trx_subsidy_pools_rec.attribute8,
              l_okl_trx_subsidy_pools_rec.attribute9,
              l_okl_trx_subsidy_pools_rec.attribute10,
              l_okl_trx_subsidy_pools_rec.attribute11,
              l_okl_trx_subsidy_pools_rec.attribute12,
              l_okl_trx_subsidy_pools_rec.attribute13,
              l_okl_trx_subsidy_pools_rec.attribute14,
              l_okl_trx_subsidy_pools_rec.attribute15,
              l_okl_trx_subsidy_pools_rec.created_by,
              l_okl_trx_subsidy_pools_rec.creation_date,
              l_okl_trx_subsidy_pools_rec.last_updated_by,
              l_okl_trx_subsidy_pools_rec.last_update_date,
              l_okl_trx_subsidy_pools_rec.last_update_login;
    x_no_data_found := okl_trx_subsidy_pools_pk_csr%NOTFOUND;
    CLOSE okl_trx_subsidy_pools_pk_csr;
    RETURN(l_okl_trx_subsidy_pools_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_trx_subsidy_pools_rec    IN okl_trx_subsidy_pools_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okl_trx_subsidy_pools_rec_type IS
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_okl_trx_subsidy_pools_rec := get_rec(p_okl_trx_subsidy_pools_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okl_trx_subsidy_pools_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okl_trx_subsidy_pools_rec    IN okl_trx_subsidy_pools_rec_type
  ) RETURN okl_trx_subsidy_pools_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_trx_subsidy_pools_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_SUBSIDY_POOLS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sixv_rec   IN sixv_rec_type
  ) RETURN sixv_rec_type IS
    l_sixv_rec                     sixv_rec_type := p_sixv_rec;
  BEGIN
    IF (l_sixv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.id := NULL;
    END IF;
    IF (l_sixv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.object_version_number := NULL;
    END IF;
    IF (l_sixv_rec.trx_type_code = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.trx_type_code := NULL;
    END IF;
    IF (l_sixv_rec.source_type_code = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.source_type_code := NULL;
    END IF;
    IF (l_sixv_rec.source_object_id = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.source_object_id := NULL;
    END IF;
    IF (l_sixv_rec.subsidy_pool_id = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.subsidy_pool_id := NULL;
    END IF;
    IF (l_sixv_rec.dnz_asset_number = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.dnz_asset_number := NULL;
    END IF;
    IF (l_sixv_rec.vendor_id = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.vendor_id := NULL;
    END IF;
    IF (l_sixv_rec.source_trx_date = OKC_API.G_MISS_DATE ) THEN
      l_sixv_rec.source_trx_date := NULL;
    END IF;
    IF (l_sixv_rec.trx_date = OKC_API.G_MISS_DATE ) THEN
      l_sixv_rec.trx_date := NULL;
    END IF;
    IF (l_sixv_rec.subsidy_id = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.subsidy_id := NULL;
    END IF;
    IF (l_sixv_rec.trx_reason_code = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.trx_reason_code := NULL;
    END IF;
    IF (l_sixv_rec.trx_currency_code = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.trx_currency_code := NULL;
    END IF;
    IF (l_sixv_rec.trx_amount = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.trx_amount := NULL;
    END IF;
    IF (l_sixv_rec.subsidy_pool_currency_code = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.subsidy_pool_currency_code := NULL;
    END IF;
    IF (l_sixv_rec.subsidy_pool_amount = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.subsidy_pool_amount := NULL;
    END IF;
    IF (l_sixv_rec.conversion_rate = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.conversion_rate := NULL;
    END IF;
    IF (l_sixv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute_category := NULL;
    END IF;
    IF (l_sixv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute1 := NULL;
    END IF;
    IF (l_sixv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute2 := NULL;
    END IF;
    IF (l_sixv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute3 := NULL;
    END IF;
    IF (l_sixv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute4 := NULL;
    END IF;
    IF (l_sixv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute5 := NULL;
    END IF;
    IF (l_sixv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute6 := NULL;
    END IF;
    IF (l_sixv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute7 := NULL;
    END IF;
    IF (l_sixv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute8 := NULL;
    END IF;
    IF (l_sixv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute9 := NULL;
    END IF;
    IF (l_sixv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute10 := NULL;
    END IF;
    IF (l_sixv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute11 := NULL;
    END IF;
    IF (l_sixv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute12 := NULL;
    END IF;
    IF (l_sixv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute13 := NULL;
    END IF;
    IF (l_sixv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute14 := NULL;
    END IF;
    IF (l_sixv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_sixv_rec.attribute15 := NULL;
    END IF;
    IF (l_sixv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.created_by := NULL;
    END IF;
    IF (l_sixv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_sixv_rec.creation_date := NULL;
    END IF;
    IF (l_sixv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sixv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_sixv_rec.last_update_date := NULL;
    END IF;
    IF (l_sixv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_sixv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_sixv_rec);
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
  ----------------------------------------------
  -- Validate_Attributes for: TRX_TYPE_CODE --
  ----------------------------------------------
  PROCEDURE validate_trx_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trx_type_code                IN VARCHAR2) IS

-- start: cklee 07/07/2005
    CURSOR c_get_trx_type_code_csr IS
     SELECT 'X'
       FROM fnd_lookups
      WHERE lookup_type = 'OKL_SUB_POOL_LINE_TYPE'
        AND lookup_code = p_trx_type_code;
     lv_dummy VARCHAR2(1) := 'N';
-- end: cklee 07/07/2005

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF(p_trx_type_code IS NULL)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_type_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- start: cklee 07/07/2005
/*
    IF(p_trx_type_code NOT IN ('ADDITION', 'REDUCTION'))THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'trx_type_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
    OPEN c_get_trx_type_code_csr;
    FETCH c_get_trx_type_code_csr INTO lv_dummy; CLOSE c_get_trx_type_code_csr;
    IF(lv_dummy <> 'X')THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'trx_type_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- end: cklee 07/07/2005

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
  END validate_trx_type_code;
  -----------------------------------------------
  -- Validate_Attributes for: SOURCE_TYPE_CODE --
  -----------------------------------------------
  PROCEDURE validate_source_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_source_type_code             IN VARCHAR2) IS

-- start: cklee 07/07/2005
    CURSOR c_get_source_type_csr IS
     SELECT 'X'
       FROM fnd_lookups
      WHERE lookup_type = 'OKL_SUB_POOL_TRX_SOURCE_TYPE'
        AND lookup_code = p_source_type_code;
     lv_dummy VARCHAR2(1) := 'N';
-- end: cklee 07/07/2005

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_source_type_code = OKC_API.G_MISS_CHAR OR
        p_source_type_code IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_type_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- start: cklee 07/07/2005
    OPEN c_get_source_type_csr;
    FETCH c_get_source_type_csr INTO lv_dummy; CLOSE c_get_source_type_csr;
    IF(lv_dummy <> 'X')THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'source_type_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- end: cklee 07/07/2005

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
  END validate_source_type_code;
  -----------------------------------------------
  -- Validate_Attributes for: SOURCE_OBJECT_ID --
  -----------------------------------------------
  PROCEDURE validate_source_object_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_source_object_id             IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_source_object_id = OKC_API.G_MISS_NUM OR
        p_source_object_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_object_id');
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
  END validate_source_object_id;
  ----------------------------------------------
  -- Validate_Attributes for: SUBSIDY_POOL_ID --
  ----------------------------------------------
  PROCEDURE validate_subsidy_pool_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_subsidy_pool_id              IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_subsidy_pool_id = OKC_API.G_MISS_NUM OR
        p_subsidy_pool_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'subsidy_pool_id');
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
  END validate_subsidy_pool_id;

  -- sjalasut added more validations on attributes. START

  ----------------------------------------------
  -- Validate_Attributes for: TRX_REASON_CODE --
  ----------------------------------------------
  PROCEDURE validate_trx_reason_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trx_reason_code              IN VARCHAR2) IS

    CURSOR c_get_trx_reason_csr IS
     SELECT 'X'
       FROM fnd_lookups
      WHERE lookup_type = 'OKL_SUB_POOL_TRX_REASON_TYPE'
        AND lookup_code = p_trx_reason_code;
     lv_dummy VARCHAR2(1);
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    lv_dummy := 'N';
    IF(p_trx_reason_code IS NULL)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_reason_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    OPEN c_get_trx_reason_csr;
    FETCH c_get_trx_reason_csr INTO lv_dummy; CLOSE c_get_trx_reason_csr;
    IF(lv_dummy <> 'X')THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'trx_reason_code');
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
  END validate_trx_reason_code;

  ----------------------------------------------
  -- Validate_Attributes for: TRX_AMOUNT --
  ----------------------------------------------
  PROCEDURE validate_trx_amount(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trx_amount              IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF(p_trx_amount IS NULL)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_amount');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF(p_trx_amount <= 0)THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'trx_amount');
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
  END validate_trx_amount;

  ----------------------------------------------
  -- Validate_Attributes for: SOURCE_TRX_DATE --
  ----------------------------------------------
  PROCEDURE validate_source_trx_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_source_trx_date               IN VARCHAR2) IS

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF(p_source_trx_date IS NULL)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_trx_date');
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
  END validate_source_trx_date;

  -----------------------------------------------
  -- Validate_Attributes for: DNZ_ASSET_NUMBER --
  -----------------------------------------------
  PROCEDURE validate_dnz_asset_number(
    x_return_status  OUT NOCOPY VARCHAR2,
    p_dnz_asset_number IN VARCHAR2) IS

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF(p_dnz_asset_number IS NULL)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'dnz_asset_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_dnz_asset_number;

  -- sjalasut added more validations on attributes. END

-- start: cklee 07/07/2005
  -----------------------------------------------
  -- Validate_Attributes for: VENDOR_ID --
  -----------------------------------------------
  PROCEDURE validate_vendor_id(
    x_return_status  OUT NOCOPY VARCHAR2,
    p_vendor_id IN NUMBER) IS

    CURSOR c_get_vendor_csr IS
     SELECT 'X'
       FROM po_vendors
      WHERE vendor_id = p_vendor_id;
     lv_dummy VARCHAR2(1) := 'N';

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF(p_vendor_id IS NULL)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'vendor_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN c_get_vendor_csr;
    FETCH c_get_vendor_csr INTO lv_dummy; CLOSE c_get_vendor_csr;
    IF(lv_dummy <> 'X')THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'vendor_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_vendor_id;

  -----------------------------------------------
  -- Validate_Attributes for: TRX_CURRENCY_CODE --
  -----------------------------------------------
  PROCEDURE validate_trx_currency_code(
    x_return_status  OUT NOCOPY VARCHAR2,
    p_trx_currency_code IN VARCHAR2) IS

    CURSOR c_get_trx_currency_csr IS
     SELECT 'X'
       FROM gl_currencies
      WHERE CURRENCY_CODE = p_trx_currency_code;
     lv_dummy VARCHAR2(1) := 'N';

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF(p_trx_currency_code IS NULL)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_currency_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN c_get_trx_currency_csr;
    FETCH c_get_trx_currency_csr INTO lv_dummy; CLOSE c_get_trx_currency_csr;
    IF(lv_dummy <> 'X')THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'trx_currency_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_trx_currency_code;

  -----------------------------------------------
  -- Validate_Attributes for: SUBSIDY_POOL_AMOUNT --
  -----------------------------------------------
  PROCEDURE validate_subsidy_pool_amount(
    x_return_status  OUT NOCOPY VARCHAR2,
    p_subsidy_pool_amount IN NUMBER) IS

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF(p_subsidy_pool_amount IS NULL)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'subsidy_pool_amount');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_subsidy_pool_amount;

  -----------------------------------------------
  -- Validate_Attributes for: SUBSIDY_POOL_CURRENCY_CODE --
  -----------------------------------------------
  PROCEDURE validate_subsidy_pool_cur(
    x_return_status  OUT NOCOPY VARCHAR2,
    p_subsidy_pool_cur IN VARCHAR2) IS

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF(p_subsidy_pool_cur IS NULL)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'subsidy_pool_currency_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_subsidy_pool_cur;

  -----------------------------------------------
  -- Validate_Attributes for: CONVERSION_RATE --
  -----------------------------------------------
  PROCEDURE validate_conversion_rate(
    x_return_status  OUT NOCOPY VARCHAR2,
    p_conversion_rate IN NUMBER) IS

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF(p_conversion_rate IS NULL)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'conversion_rate');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_conversion_rate;

-- end: cklee 07/07/2005

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKL_TRX_SUBSIDY_POOLS_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sixv_rec                     IN sixv_rec_type
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
    -- sjalasut: commented for subsidy pools enhancements
    -- for okl_trx_subsidy_pools, data is always inserted and never updated or deleted
    -- therefore validate_id and validate_object_version number are hampring other validation logic
    --validate_id(x_return_status, p_sixv_rec.id);
    --IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      --l_return_status := x_return_status;
      --RAISE G_EXCEPTION_HALT_VALIDATION;
    --END IF;

    -- ***
    -- object_version_number
    -- ***
    -- commenting ovn check as records are only inserted into this table and not deleted or updated
    --validate_object_version_number(x_return_status, p_sixv_rec.object_version_number);
    --IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      --l_return_status := x_return_status;
      --RAISE G_EXCEPTION_HALT_VALIDATION;
    --END IF;

    -- ***
    -- trx_type_code
    -- ***
    validate_trx_type_code(x_return_status, p_sixv_rec.trx_type_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- source_type_code
    -- ***
    validate_source_type_code(x_return_status, p_sixv_rec.source_type_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- source_object_id
    -- ***
    validate_source_object_id(x_return_status, p_sixv_rec.source_object_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- subsidy_pool_id
    -- ***
    validate_subsidy_pool_id(x_return_status, p_sixv_rec.subsidy_pool_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- sjalasut added more column validations. START

    -- ***
    -- trx_reason_code
    -- ***
    validate_trx_reason_code(x_return_status, p_sixv_rec.trx_reason_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- trx_amount
    -- ***
    validate_trx_amount(x_return_status, p_sixv_rec.trx_amount);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- source_trx_date
    -- ***
    validate_source_trx_date(x_return_status, p_sixv_rec.trx_type_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    -- ***
    -- dnz_asset_number
    -- ***
    validate_dnz_asset_number(x_return_status, p_sixv_rec.dnz_asset_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- sjalasut added more column validations. END

-- start: cklee 07/07/2005
    -- ***
    -- vendor id
    -- ***
    validate_vendor_id(x_return_status, p_sixv_rec.vendor_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- trx_currency_code
    -- ***
    validate_trx_currency_code(x_return_status, p_sixv_rec.trx_currency_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    IF p_sixv_rec.trx_type_code = 'ADDITION' THEN
      -- ***
      -- subsidy_pool_amount
      -- ***
      validate_subsidy_pool_amount(x_return_status, p_sixv_rec.subsidy_pool_amount);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- ***
      -- subsidy_pool_currency_code
      -- ***
      validate_subsidy_pool_cur(x_return_status, p_sixv_rec.subsidy_pool_currency_code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- ***
      -- conversion_rate
      -- ***
      validate_conversion_rate(x_return_status, p_sixv_rec.conversion_rate);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF; -- IF p_sixv_rec.trx_type_code = 'ADDITION' THEN

-- end: cklee 07/07/2005

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
  -------------------------------------------------
  -- Validate Record for:OKL_TRX_SUBSIDY_POOLS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_sixv_rec IN sixv_rec_type,
    p_db_sixv_rec IN sixv_rec_type
  ) RETURN VARCHAR2 IS
    CURSOR c_get_sub_dates_csr IS
    SELECT effective_from_date, effective_to_date, name
      FROM okl_subsidies_b
     WHERE id = p_sixv_rec.subsidy_id;
    cv_get_sub_dates c_get_sub_dates_csr%ROWTYPE;
    CURSOR c_get_sub_pool_dates_csr IS
    SELECT effective_from_date, effective_to_date, subsidy_pool_name
      FROM okl_subsidy_pools_b
     WHERE id = p_sixv_rec.subsidy_pool_id;
    cv_get_sub_pool_dates c_get_sub_pool_dates_csr%ROWTYPE;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- sjalasut added validation for the source_trx_date. START

    -- validate the source transaction date. the source transaction date is contract start date if the sales quote is being approved,
    -- date of deletion on delete sales payment quote, acceptance date of sales payment quote, asset line date for contract booking,
    -- rebook transaction date on contract rebook, split date on split contract, reversal date on contract reversal.
    -- validate if the source transaction date is between the effective dates of subsidy and the subsidy pool in that order
    OPEN c_get_sub_dates_csr;
    FETCH c_get_sub_dates_csr INTO cv_get_sub_dates;
    CLOSE c_get_sub_dates_csr;
    IF(NOT p_sixv_rec.source_trx_date BETWEEN cv_get_sub_dates.effective_from_date AND
       NVL(cv_get_sub_dates.effective_to_date,OKL_ACCOUNTING_UTIL.g_final_date))THEN
      OKC_API.set_message(G_APP_NAME, G_SOURCE_TRX_DATE_SUB_VAL, 'TRX_DATE', p_sixv_rec.source_trx_date, 'SUBSIDY', cv_get_sub_dates.name);
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    OPEN c_get_sub_pool_dates_csr;
    FETCH c_get_sub_pool_dates_csr INTO cv_get_sub_pool_dates;
    CLOSE c_get_sub_pool_dates_csr;
    IF(NOT p_sixv_rec.source_trx_date BETWEEN cv_get_sub_pool_dates.effective_from_date AND
       NVL(cv_get_sub_pool_dates.effective_to_date,OKL_ACCOUNTING_UTIL.g_final_date))THEN
      OKC_API.set_message(G_APP_NAME, G_SOURCE_TRX_DATE_POOL_VAL, 'TRX_DATE', p_sixv_rec.source_trx_date, 'SUB_POOL', cv_get_sub_pool_dates.subsidy_pool_name);
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    -- sjalasut added validation for the source_trx_date. END

    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_sixv_rec IN sixv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_sixv_rec                  sixv_rec_type := get_rec(p_sixv_rec);
  BEGIN
    l_return_status := Validate_Record(p_sixv_rec => p_sixv_rec,
                                       p_db_sixv_rec => l_db_sixv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN sixv_rec_type,
    p_to   IN OUT NOCOPY okl_trx_subsidy_pools_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.trx_type_code := p_from.trx_type_code;
    p_to.source_type_code := p_from.source_type_code;
    p_to.source_object_id := p_from.source_object_id;
    p_to.subsidy_pool_id := p_from.subsidy_pool_id;
    p_to.dnz_asset_number := p_from.dnz_asset_number;
    p_to.vendor_id := p_from.vendor_id;
    p_to.source_trx_date := p_from.source_trx_date;
    p_to.trx_date := p_from.trx_date;
    p_to.subsidy_id := p_from.subsidy_id;
    p_to.trx_reason_code := p_from.trx_reason_code;
    p_to.trx_currency_code := p_from.trx_currency_code;
    p_to.trx_amount := p_from.trx_amount;
    p_to.subsidy_pool_currency_code := p_from.subsidy_pool_currency_code;
    p_to.subsidy_pool_amount := p_from.subsidy_pool_amount;
    p_to.conversion_rate := p_from.conversion_rate;
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
    p_from IN okl_trx_subsidy_pools_rec_type,
    p_to   IN OUT NOCOPY sixv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.trx_type_code := p_from.trx_type_code;
    p_to.source_type_code := p_from.source_type_code;
    p_to.source_object_id := p_from.source_object_id;
    p_to.subsidy_pool_id := p_from.subsidy_pool_id;
    p_to.dnz_asset_number := p_from.dnz_asset_number;
    p_to.vendor_id := p_from.vendor_id;
    p_to.source_trx_date := p_from.source_trx_date;
    p_to.trx_date := p_from.trx_date;
    p_to.subsidy_id := p_from.subsidy_id;
    p_to.trx_reason_code := p_from.trx_reason_code;
    p_to.trx_currency_code := p_from.trx_currency_code;
    p_to.trx_amount := p_from.trx_amount;
    p_to.subsidy_pool_currency_code := p_from.subsidy_pool_currency_code;
    p_to.subsidy_pool_amount := p_from.subsidy_pool_amount;
    p_to.conversion_rate := p_from.conversion_rate;
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
  ----------------------------------------------
  -- validate_row for:OKL_TRX_SUBSIDY_POOLS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_rec                     IN sixv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sixv_rec                     sixv_rec_type := p_sixv_rec;
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type;
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type;
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
    l_return_status := Validate_Attributes(l_sixv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sixv_rec);
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
  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TRX_SUBSIDY_POOLS_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sixv_tbl.COUNT > 0) THEN
      i := p_sixv_tbl.FIRST;
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
            p_sixv_rec                     => p_sixv_tbl(i));
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
        EXIT WHEN (i = p_sixv_tbl.LAST);
        i := p_sixv_tbl.NEXT(i);
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

  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TRX_SUBSIDY_POOLS_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sixv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sixv_tbl                     => p_sixv_tbl,
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
  ------------------------------------------
  -- insert_row for:OKL_TRX_SUBSIDY_POOLS --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_subsidy_pools_rec    IN okl_trx_subsidy_pools_rec_type,
    x_okl_trx_subsidy_pools_rec    OUT NOCOPY okl_trx_subsidy_pools_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type := p_okl_trx_subsidy_pools_rec;
    LDefOklTrxSubsidyPoolsRec      okl_trx_subsidy_pools_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_SUBSIDY_POOLS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_subsidy_pools_rec IN okl_trx_subsidy_pools_rec_type,
      x_okl_trx_subsidy_pools_rec OUT NOCOPY okl_trx_subsidy_pools_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_subsidy_pools_rec := p_okl_trx_subsidy_pools_rec;
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
      p_okl_trx_subsidy_pools_rec,       -- IN
      l_okl_trx_subsidy_pools_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TRX_SUBSIDY_POOLS(
      id,
      object_version_number,
      trx_type_code,
      source_type_code,
      source_object_id,
      subsidy_pool_id,
      dnz_asset_number,
      vendor_id,
      source_trx_date,
      trx_date,
      subsidy_id,
      trx_reason_code,
      trx_currency_code,
      trx_amount,
      subsidy_pool_currency_code,
      subsidy_pool_amount,
      conversion_rate,
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
      l_okl_trx_subsidy_pools_rec.id,
      l_okl_trx_subsidy_pools_rec.object_version_number,
      l_okl_trx_subsidy_pools_rec.trx_type_code,
      l_okl_trx_subsidy_pools_rec.source_type_code,
      l_okl_trx_subsidy_pools_rec.source_object_id,
      l_okl_trx_subsidy_pools_rec.subsidy_pool_id,
      l_okl_trx_subsidy_pools_rec.dnz_asset_number,
      l_okl_trx_subsidy_pools_rec.vendor_id,
      l_okl_trx_subsidy_pools_rec.source_trx_date,
      l_okl_trx_subsidy_pools_rec.trx_date,
      l_okl_trx_subsidy_pools_rec.subsidy_id,
      l_okl_trx_subsidy_pools_rec.trx_reason_code,
      l_okl_trx_subsidy_pools_rec.trx_currency_code,
      l_okl_trx_subsidy_pools_rec.trx_amount,
      l_okl_trx_subsidy_pools_rec.subsidy_pool_currency_code,
      l_okl_trx_subsidy_pools_rec.subsidy_pool_amount,
      l_okl_trx_subsidy_pools_rec.conversion_rate,
      l_okl_trx_subsidy_pools_rec.attribute_category,
      l_okl_trx_subsidy_pools_rec.attribute1,
      l_okl_trx_subsidy_pools_rec.attribute2,
      l_okl_trx_subsidy_pools_rec.attribute3,
      l_okl_trx_subsidy_pools_rec.attribute4,
      l_okl_trx_subsidy_pools_rec.attribute5,
      l_okl_trx_subsidy_pools_rec.attribute6,
      l_okl_trx_subsidy_pools_rec.attribute7,
      l_okl_trx_subsidy_pools_rec.attribute8,
      l_okl_trx_subsidy_pools_rec.attribute9,
      l_okl_trx_subsidy_pools_rec.attribute10,
      l_okl_trx_subsidy_pools_rec.attribute11,
      l_okl_trx_subsidy_pools_rec.attribute12,
      l_okl_trx_subsidy_pools_rec.attribute13,
      l_okl_trx_subsidy_pools_rec.attribute14,
      l_okl_trx_subsidy_pools_rec.attribute15,
      l_okl_trx_subsidy_pools_rec.created_by,
      l_okl_trx_subsidy_pools_rec.creation_date,
      l_okl_trx_subsidy_pools_rec.last_updated_by,
      l_okl_trx_subsidy_pools_rec.last_update_date,
      l_okl_trx_subsidy_pools_rec.last_update_login);
    -- Set OUT values
    x_okl_trx_subsidy_pools_rec := l_okl_trx_subsidy_pools_rec;
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
  ---------------------------------------------
  -- insert_row for :OKL_TRX_SUBSIDY_POOLS_V --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_rec                     IN sixv_rec_type,
    x_sixv_rec                     OUT NOCOPY sixv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sixv_rec                     sixv_rec_type := p_sixv_rec;
    l_def_sixv_rec                 sixv_rec_type;
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type;
    lx_okl_trx_subsidy_pools_rec   okl_trx_subsidy_pools_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sixv_rec IN sixv_rec_type
    ) RETURN sixv_rec_type IS
      l_sixv_rec sixv_rec_type := p_sixv_rec;
    BEGIN
      l_sixv_rec.CREATION_DATE := SYSDATE;
      l_sixv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sixv_rec.LAST_UPDATE_DATE := l_sixv_rec.CREATION_DATE;
      l_sixv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sixv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sixv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKL_TRX_SUBSIDY_POOLS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_sixv_rec IN sixv_rec_type,
      x_sixv_rec OUT NOCOPY sixv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sixv_rec := p_sixv_rec;
      x_sixv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_sixv_rec := null_out_defaults(p_sixv_rec);
    -- Set primary key value
    l_sixv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_sixv_rec,                        -- IN
      l_def_sixv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sixv_rec := fill_who_columns(l_def_sixv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sixv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sixv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_sixv_rec, l_okl_trx_subsidy_pools_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_subsidy_pools_rec,
      lx_okl_trx_subsidy_pools_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_subsidy_pools_rec, l_def_sixv_rec);
    -- Set OUT values
    x_sixv_rec := l_def_sixv_rec;
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
  -- PL/SQL TBL insert_row for:SIXV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    x_sixv_tbl                     OUT NOCOPY sixv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sixv_tbl.COUNT > 0) THEN
      i := p_sixv_tbl.FIRST;
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
            p_sixv_rec                     => p_sixv_tbl(i),
            x_sixv_rec                     => x_sixv_tbl(i));
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
        EXIT WHEN (i = p_sixv_tbl.LAST);
        i := p_sixv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:SIXV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    x_sixv_tbl                     OUT NOCOPY sixv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sixv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sixv_tbl                     => p_sixv_tbl,
        x_sixv_tbl                     => x_sixv_tbl,
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
  ----------------------------------------
  -- lock_row for:OKL_TRX_SUBSIDY_POOLS --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_subsidy_pools_rec    IN okl_trx_subsidy_pools_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_trx_subsidy_pools_rec IN okl_trx_subsidy_pools_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_SUBSIDY_POOLS
     WHERE ID = p_okl_trx_subsidy_pools_rec.id
       AND OBJECT_VERSION_NUMBER = p_okl_trx_subsidy_pools_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_okl_trx_subsidy_pools_rec IN okl_trx_subsidy_pools_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_SUBSIDY_POOLS
     WHERE ID = p_okl_trx_subsidy_pools_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_TRX_SUBSIDY_POOLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_TRX_SUBSIDY_POOLS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_okl_trx_subsidy_pools_rec);
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
      OPEN lchk_csr(p_okl_trx_subsidy_pools_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_okl_trx_subsidy_pools_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_okl_trx_subsidy_pools_rec.object_version_number THEN
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
  -------------------------------------------
  -- lock_row for: OKL_TRX_SUBSIDY_POOLS_V --
  -------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_rec                     IN sixv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type;
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
    migrate(p_sixv_rec, l_okl_trx_subsidy_pools_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_subsidy_pools_rec
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
  -- PL/SQL TBL lock_row for:SIXV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_sixv_tbl.COUNT > 0) THEN
      i := p_sixv_tbl.FIRST;
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
            p_sixv_rec                     => p_sixv_tbl(i));
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
        EXIT WHEN (i = p_sixv_tbl.LAST);
        i := p_sixv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:SIXV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_sixv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sixv_tbl                     => p_sixv_tbl,
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
  ------------------------------------------
  -- update_row for:OKL_TRX_SUBSIDY_POOLS --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_subsidy_pools_rec    IN okl_trx_subsidy_pools_rec_type,
    x_okl_trx_subsidy_pools_rec    OUT NOCOPY okl_trx_subsidy_pools_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type := p_okl_trx_subsidy_pools_rec;
    LDefOklTrxSubsidyPoolsRec      okl_trx_subsidy_pools_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_trx_subsidy_pools_rec IN okl_trx_subsidy_pools_rec_type,
      x_okl_trx_subsidy_pools_rec OUT NOCOPY okl_trx_subsidy_pools_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_subsidy_pools_rec := p_okl_trx_subsidy_pools_rec;
      -- Get current database values
      l_okl_trx_subsidy_pools_rec := get_rec(p_okl_trx_subsidy_pools_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_okl_trx_subsidy_pools_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.id := l_okl_trx_subsidy_pools_rec.id;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.object_version_number := l_okl_trx_subsidy_pools_rec.object_version_number;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.trx_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.trx_type_code := l_okl_trx_subsidy_pools_rec.trx_type_code;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.source_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.source_type_code := l_okl_trx_subsidy_pools_rec.source_type_code;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.source_object_id = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.source_object_id := l_okl_trx_subsidy_pools_rec.source_object_id;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.subsidy_pool_id = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.subsidy_pool_id := l_okl_trx_subsidy_pools_rec.subsidy_pool_id;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.dnz_asset_number = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.dnz_asset_number := l_okl_trx_subsidy_pools_rec.dnz_asset_number;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.vendor_id = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.vendor_id := l_okl_trx_subsidy_pools_rec.vendor_id;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.source_trx_date = OKC_API.G_MISS_DATE)
        THEN
          x_okl_trx_subsidy_pools_rec.source_trx_date := l_okl_trx_subsidy_pools_rec.source_trx_date;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.trx_date = OKC_API.G_MISS_DATE)
        THEN
          x_okl_trx_subsidy_pools_rec.trx_date := l_okl_trx_subsidy_pools_rec.trx_date;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.subsidy_id = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.subsidy_id := l_okl_trx_subsidy_pools_rec.subsidy_id;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.trx_reason_code = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.trx_reason_code := l_okl_trx_subsidy_pools_rec.trx_reason_code;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.trx_currency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.trx_currency_code := l_okl_trx_subsidy_pools_rec.trx_currency_code;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.trx_amount = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.trx_amount := l_okl_trx_subsidy_pools_rec.trx_amount;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.subsidy_pool_currency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.subsidy_pool_currency_code := l_okl_trx_subsidy_pools_rec.subsidy_pool_currency_code;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.subsidy_pool_amount = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.subsidy_pool_amount := l_okl_trx_subsidy_pools_rec.subsidy_pool_amount;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.conversion_rate = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.conversion_rate := l_okl_trx_subsidy_pools_rec.conversion_rate;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute_category := l_okl_trx_subsidy_pools_rec.attribute_category;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute1 := l_okl_trx_subsidy_pools_rec.attribute1;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute2 := l_okl_trx_subsidy_pools_rec.attribute2;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute3 := l_okl_trx_subsidy_pools_rec.attribute3;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute4 := l_okl_trx_subsidy_pools_rec.attribute4;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute5 := l_okl_trx_subsidy_pools_rec.attribute5;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute6 := l_okl_trx_subsidy_pools_rec.attribute6;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute7 := l_okl_trx_subsidy_pools_rec.attribute7;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute8 := l_okl_trx_subsidy_pools_rec.attribute8;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute9 := l_okl_trx_subsidy_pools_rec.attribute9;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute10 := l_okl_trx_subsidy_pools_rec.attribute10;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute11 := l_okl_trx_subsidy_pools_rec.attribute11;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute12 := l_okl_trx_subsidy_pools_rec.attribute12;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute13 := l_okl_trx_subsidy_pools_rec.attribute13;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute14 := l_okl_trx_subsidy_pools_rec.attribute14;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_trx_subsidy_pools_rec.attribute15 := l_okl_trx_subsidy_pools_rec.attribute15;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.created_by := l_okl_trx_subsidy_pools_rec.created_by;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_okl_trx_subsidy_pools_rec.creation_date := l_okl_trx_subsidy_pools_rec.creation_date;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.last_updated_by := l_okl_trx_subsidy_pools_rec.last_updated_by;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okl_trx_subsidy_pools_rec.last_update_date := l_okl_trx_subsidy_pools_rec.last_update_date;
        END IF;
        IF (x_okl_trx_subsidy_pools_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_okl_trx_subsidy_pools_rec.last_update_login := l_okl_trx_subsidy_pools_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_SUBSIDY_POOLS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_subsidy_pools_rec IN okl_trx_subsidy_pools_rec_type,
      x_okl_trx_subsidy_pools_rec OUT NOCOPY okl_trx_subsidy_pools_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_subsidy_pools_rec := p_okl_trx_subsidy_pools_rec;
      x_okl_trx_subsidy_pools_rec.OBJECT_VERSION_NUMBER := p_okl_trx_subsidy_pools_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_okl_trx_subsidy_pools_rec,       -- IN
      l_okl_trx_subsidy_pools_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_trx_subsidy_pools_rec, LDefOklTrxSubsidyPoolsRec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_TRX_SUBSIDY_POOLS
    SET OBJECT_VERSION_NUMBER = LDefOklTrxSubsidyPoolsRec.object_version_number,
        TRX_TYPE_CODE = LDefOklTrxSubsidyPoolsRec.trx_type_code,
        SOURCE_TYPE_CODE = LDefOklTrxSubsidyPoolsRec.source_type_code,
        SOURCE_OBJECT_ID = LDefOklTrxSubsidyPoolsRec.source_object_id,
        SUBSIDY_POOL_ID = LDefOklTrxSubsidyPoolsRec.subsidy_pool_id,
        DNZ_ASSET_NUMBER = LDefOklTrxSubsidyPoolsRec.dnz_asset_number,
        VENDOR_ID = LDefOklTrxSubsidyPoolsRec.vendor_id,
        SOURCE_TRX_DATE = LDefOklTrxSubsidyPoolsRec.source_trx_date,
        TRX_DATE = LDefOklTrxSubsidyPoolsRec.trx_date,
        SUBSIDY_ID = LDefOklTrxSubsidyPoolsRec.subsidy_id,
        TRX_REASON_CODE = LDefOklTrxSubsidyPoolsRec.trx_reason_code,
        TRX_CURRENCY_CODE = LDefOklTrxSubsidyPoolsRec.trx_currency_code,
        TRX_AMOUNT = LDefOklTrxSubsidyPoolsRec.trx_amount,
        SUBSIDY_POOL_CURRENCY_CODE = LDefOklTrxSubsidyPoolsRec.subsidy_pool_currency_code,
        SUBSIDY_POOL_AMOUNT = LDefOklTrxSubsidyPoolsRec.subsidy_pool_amount,
        CONVERSION_RATE = LDefOklTrxSubsidyPoolsRec.conversion_rate,
        ATTRIBUTE_CATEGORY = LDefOklTrxSubsidyPoolsRec.attribute_category,
        ATTRIBUTE1 = LDefOklTrxSubsidyPoolsRec.attribute1,
        ATTRIBUTE2 = LDefOklTrxSubsidyPoolsRec.attribute2,
        ATTRIBUTE3 = LDefOklTrxSubsidyPoolsRec.attribute3,
        ATTRIBUTE4 = LDefOklTrxSubsidyPoolsRec.attribute4,
        ATTRIBUTE5 = LDefOklTrxSubsidyPoolsRec.attribute5,
        ATTRIBUTE6 = LDefOklTrxSubsidyPoolsRec.attribute6,
        ATTRIBUTE7 = LDefOklTrxSubsidyPoolsRec.attribute7,
        ATTRIBUTE8 = LDefOklTrxSubsidyPoolsRec.attribute8,
        ATTRIBUTE9 = LDefOklTrxSubsidyPoolsRec.attribute9,
        ATTRIBUTE10 = LDefOklTrxSubsidyPoolsRec.attribute10,
        ATTRIBUTE11 = LDefOklTrxSubsidyPoolsRec.attribute11,
        ATTRIBUTE12 = LDefOklTrxSubsidyPoolsRec.attribute12,
        ATTRIBUTE13 = LDefOklTrxSubsidyPoolsRec.attribute13,
        ATTRIBUTE14 = LDefOklTrxSubsidyPoolsRec.attribute14,
        ATTRIBUTE15 = LDefOklTrxSubsidyPoolsRec.attribute15,
        CREATED_BY = LDefOklTrxSubsidyPoolsRec.created_by,
        CREATION_DATE = LDefOklTrxSubsidyPoolsRec.creation_date,
        LAST_UPDATED_BY = LDefOklTrxSubsidyPoolsRec.last_updated_by,
        LAST_UPDATE_DATE = LDefOklTrxSubsidyPoolsRec.last_update_date,
        LAST_UPDATE_LOGIN = LDefOklTrxSubsidyPoolsRec.last_update_login
    WHERE ID = LDefOklTrxSubsidyPoolsRec.id;

    x_okl_trx_subsidy_pools_rec := l_okl_trx_subsidy_pools_rec;
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
  --------------------------------------------
  -- update_row for:OKL_TRX_SUBSIDY_POOLS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_rec                     IN sixv_rec_type,
    x_sixv_rec                     OUT NOCOPY sixv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sixv_rec                     sixv_rec_type := p_sixv_rec;
    l_def_sixv_rec                 sixv_rec_type;
    l_db_sixv_rec                  sixv_rec_type;
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type;
    lx_okl_trx_subsidy_pools_rec   okl_trx_subsidy_pools_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sixv_rec IN sixv_rec_type
    ) RETURN sixv_rec_type IS
      l_sixv_rec sixv_rec_type := p_sixv_rec;
    BEGIN
      l_sixv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sixv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sixv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sixv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sixv_rec IN sixv_rec_type,
      x_sixv_rec OUT NOCOPY sixv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sixv_rec := p_sixv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_sixv_rec := get_rec(p_sixv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_sixv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.id := l_db_sixv_rec.id;
        END IF;
        IF (x_sixv_rec.trx_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.trx_type_code := l_db_sixv_rec.trx_type_code;
        END IF;
        IF (x_sixv_rec.source_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.source_type_code := l_db_sixv_rec.source_type_code;
        END IF;
        IF (x_sixv_rec.source_object_id = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.source_object_id := l_db_sixv_rec.source_object_id;
        END IF;
        IF (x_sixv_rec.subsidy_pool_id = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.subsidy_pool_id := l_db_sixv_rec.subsidy_pool_id;
        END IF;
        IF (x_sixv_rec.dnz_asset_number = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.dnz_asset_number := l_db_sixv_rec.dnz_asset_number;
        END IF;
        IF (x_sixv_rec.vendor_id = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.vendor_id := l_db_sixv_rec.vendor_id;
        END IF;
        IF (x_sixv_rec.source_trx_date = OKC_API.G_MISS_DATE)
        THEN
          x_sixv_rec.source_trx_date := l_db_sixv_rec.source_trx_date;
        END IF;
        IF (x_sixv_rec.trx_date = OKC_API.G_MISS_DATE)
        THEN
          x_sixv_rec.trx_date := l_db_sixv_rec.trx_date;
        END IF;
        IF (x_sixv_rec.subsidy_id = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.subsidy_id := l_db_sixv_rec.subsidy_id;
        END IF;
        IF (x_sixv_rec.trx_reason_code = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.trx_reason_code := l_db_sixv_rec.trx_reason_code;
        END IF;
        IF (x_sixv_rec.trx_currency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.trx_currency_code := l_db_sixv_rec.trx_currency_code;
        END IF;
        IF (x_sixv_rec.trx_amount = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.trx_amount := l_db_sixv_rec.trx_amount;
        END IF;
        IF (x_sixv_rec.subsidy_pool_currency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.subsidy_pool_currency_code := l_db_sixv_rec.subsidy_pool_currency_code;
        END IF;
        IF (x_sixv_rec.subsidy_pool_amount = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.subsidy_pool_amount := l_db_sixv_rec.subsidy_pool_amount;
        END IF;
        IF (x_sixv_rec.conversion_rate = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.conversion_rate := l_db_sixv_rec.conversion_rate;
        END IF;
        IF (x_sixv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute_category := l_db_sixv_rec.attribute_category;
        END IF;
        IF (x_sixv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute1 := l_db_sixv_rec.attribute1;
        END IF;
        IF (x_sixv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute2 := l_db_sixv_rec.attribute2;
        END IF;
        IF (x_sixv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute3 := l_db_sixv_rec.attribute3;
        END IF;
        IF (x_sixv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute4 := l_db_sixv_rec.attribute4;
        END IF;
        IF (x_sixv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute5 := l_db_sixv_rec.attribute5;
        END IF;
        IF (x_sixv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute6 := l_db_sixv_rec.attribute6;
        END IF;
        IF (x_sixv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute7 := l_db_sixv_rec.attribute7;
        END IF;
        IF (x_sixv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute8 := l_db_sixv_rec.attribute8;
        END IF;
        IF (x_sixv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute9 := l_db_sixv_rec.attribute9;
        END IF;
        IF (x_sixv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute10 := l_db_sixv_rec.attribute10;
        END IF;
        IF (x_sixv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute11 := l_db_sixv_rec.attribute11;
        END IF;
        IF (x_sixv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute12 := l_db_sixv_rec.attribute12;
        END IF;
        IF (x_sixv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute13 := l_db_sixv_rec.attribute13;
        END IF;
        IF (x_sixv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute14 := l_db_sixv_rec.attribute14;
        END IF;
        IF (x_sixv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_sixv_rec.attribute15 := l_db_sixv_rec.attribute15;
        END IF;
        IF (x_sixv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.created_by := l_db_sixv_rec.created_by;
        END IF;
        IF (x_sixv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_sixv_rec.creation_date := l_db_sixv_rec.creation_date;
        END IF;
        IF (x_sixv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.last_updated_by := l_db_sixv_rec.last_updated_by;
        END IF;
        IF (x_sixv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_sixv_rec.last_update_date := l_db_sixv_rec.last_update_date;
        END IF;
        IF (x_sixv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_sixv_rec.last_update_login := l_db_sixv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKL_TRX_SUBSIDY_POOLS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_sixv_rec IN sixv_rec_type,
      x_sixv_rec OUT NOCOPY sixv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sixv_rec := p_sixv_rec;
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
      p_sixv_rec,                        -- IN
      x_sixv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sixv_rec, l_def_sixv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sixv_rec := fill_who_columns(l_def_sixv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sixv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sixv_rec, l_db_sixv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*****************commented*********
--avsingh
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_sixv_rec                     => p_sixv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
****************************************/

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_sixv_rec, l_okl_trx_subsidy_pools_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_subsidy_pools_rec,
      lx_okl_trx_subsidy_pools_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_subsidy_pools_rec, l_def_sixv_rec);
    x_sixv_rec := l_def_sixv_rec;
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
  -- PL/SQL TBL update_row for:sixv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    x_sixv_tbl                     OUT NOCOPY sixv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sixv_tbl.COUNT > 0) THEN
      i := p_sixv_tbl.FIRST;
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
            p_sixv_rec                     => p_sixv_tbl(i),
            x_sixv_rec                     => x_sixv_tbl(i));
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
        EXIT WHEN (i = p_sixv_tbl.LAST);
        i := p_sixv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:SIXV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    x_sixv_tbl                     OUT NOCOPY sixv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sixv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sixv_tbl                     => p_sixv_tbl,
        x_sixv_tbl                     => x_sixv_tbl,
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
  ------------------------------------------
  -- delete_row for:OKL_TRX_SUBSIDY_POOLS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_subsidy_pools_rec    IN okl_trx_subsidy_pools_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type := p_okl_trx_subsidy_pools_rec;
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

    DELETE FROM OKL_TRX_SUBSIDY_POOLS
     WHERE ID = p_okl_trx_subsidy_pools_rec.id;

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
  --------------------------------------------
  -- delete_row for:OKL_TRX_SUBSIDY_POOLS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_rec                     IN sixv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sixv_rec                     sixv_rec_type := p_sixv_rec;
    l_okl_trx_subsidy_pools_rec    okl_trx_subsidy_pools_rec_type;
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
    migrate(l_sixv_rec, l_okl_trx_subsidy_pools_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_subsidy_pools_rec
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
  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TRX_SUBSIDY_POOLS_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sixv_tbl.COUNT > 0) THEN
      i := p_sixv_tbl.FIRST;
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
            p_sixv_rec                     => p_sixv_tbl(i));
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
        EXIT WHEN (i = p_sixv_tbl.LAST);
        i := p_sixv_tbl.NEXT(i);
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

  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TRX_SUBSIDY_POOLS_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sixv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sixv_tbl                     => p_sixv_tbl,
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

END OKL_SIX_PVT;

/
