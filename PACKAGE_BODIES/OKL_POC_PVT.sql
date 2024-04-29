--------------------------------------------------------
--  DDL for Package Body OKL_POC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POC_PVT" AS
/* $Header: OKLSPOCB.pls 120.2 2006/07/11 10:24:55 dkagrawa noship $ */
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
  -- FUNCTION get_rec for: OKL_POOL_CONTENTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pocv_rec                     IN pocv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pocv_rec_type IS
    CURSOR okl_pocv_pk_csr (p_id IN NUMBER) IS
    SELECT
	ID,
	OBJECT_VERSION_NUMBER,
	POL_ID,
	KHR_ID,
	KLE_ID,
	STY_ID,
	STM_ID,
	STY_CODE,
	POX_ID,
	STREAMS_FROM_DATE,
	STREAMS_TO_DATE,
	TRANSACTION_NUMBER_IN,
	TRANSACTION_NUMBER_OUT,
	DATE_INACTIVE,
	ATTRIBUTE_CATEGORY,
	STATUS_CODE,
	ATTRIBUTE1 ,
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
	LAST_UPDATE_LOGIN
      FROM OKL_POOL_CONTENTS_V
     WHERE OKL_POOL_CONTENTS_V.id = p_id;
    l_okl_pocv_pk                  okl_pocv_pk_csr%ROWTYPE;
    l_pocv_rec                     pocv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pocv_pk_csr (p_pocv_rec.id);
    FETCH okl_pocv_pk_csr INTO
	l_pocv_rec.id,
	l_pocv_rec.object_version_number,
	l_pocv_rec.pol_id,
	l_pocv_rec.khr_id,
	l_pocv_rec.kle_id,
	l_pocv_rec.sty_id,
	l_pocv_rec.stm_id,
	l_pocv_rec.sty_code,
	l_pocv_rec.pox_id,
	l_pocv_rec.streams_from_date,
	l_pocv_rec.streams_to_date,
	l_pocv_rec.transaction_number_in,
	l_pocv_rec.transaction_number_out,
	l_pocv_rec.date_inactive,
	l_pocv_rec.attribute_category,
	l_pocv_rec.status_code,
	l_pocv_rec.attribute1 ,
	l_pocv_rec.attribute2,
	l_pocv_rec.attribute3,
	l_pocv_rec.attribute4,
	l_pocv_rec.attribute5,
	l_pocv_rec.attribute6,
	l_pocv_rec.attribute7,
	l_pocv_rec.attribute8,
	l_pocv_rec.attribute9,
	l_pocv_rec.attribute10,
	l_pocv_rec.attribute11,
	l_pocv_rec.attribute12,
	l_pocv_rec.attribute13,
	l_pocv_rec.attribute14,
	l_pocv_rec.attribute15,
	l_pocv_rec.request_id,
	l_pocv_rec.program_application_id,
	l_pocv_rec.program_id,
	l_pocv_rec.program_update_date,
	l_pocv_rec.created_by,
	l_pocv_rec.creation_date,
	l_pocv_rec.last_updated_by,
	l_pocv_rec.last_update_date,
	l_pocv_rec.last_update_login;
    x_no_data_found := okl_pocv_pk_csr%NOTFOUND;
    CLOSE okl_pocv_pk_csr;
    RETURN(l_pocv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pocv_rec                     IN pocv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pocv_rec_type IS
    l_pocv_rec                     pocv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_pocv_rec := get_rec(p_pocv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pocv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pocv_rec                     IN pocv_rec_type
  ) RETURN pocv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pocv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: okl_pool_contents
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_poc_rec                      IN poc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN poc_rec_type IS
    CURSOR okl_pool_contents_pk_csr (p_id IN NUMBER) IS
    SELECT
	ID,
	OBJECT_VERSION_NUMBER,
	POL_ID,
	KHR_ID,
	KLE_ID,
	STY_ID,
	STM_ID,
	STY_CODE,
	POX_ID,
	STREAMS_FROM_DATE,
	STREAMS_TO_DATE,
	TRANSACTION_NUMBER_IN,
	TRANSACTION_NUMBER_OUT,
	DATE_INACTIVE,
	ATTRIBUTE_CATEGORY,
	STATUS_CODE,
	ATTRIBUTE1 ,
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
	LAST_UPDATE_LOGIN
     FROM okl_pool_contents
     WHERE okl_pool_contents.id = p_id;
    l_okl_pool_contents_pk       okl_pool_contents_pk_csr%ROWTYPE;
    l_poc_rec                      poc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pool_contents_pk_csr (p_poc_rec.id);
    FETCH okl_pool_contents_pk_csr INTO
	l_poc_rec.id,
	l_poc_rec.object_version_number,
	l_poc_rec.pol_id,
	l_poc_rec.khr_id,
	l_poc_rec.kle_id,
	l_poc_rec.sty_id,
	l_poc_rec.stm_id,
	l_poc_rec.sty_code,
	l_poc_rec.pox_id,
	l_poc_rec.streams_from_date,
	l_poc_rec.streams_to_date,
	l_poc_rec.transaction_number_in,
	l_poc_rec.transaction_number_out,
	l_poc_rec.date_inactive,
	l_poc_rec.attribute_category,
	l_poc_rec.status_code,
	l_poc_rec.attribute1 ,
	l_poc_rec.attribute2,
	l_poc_rec.attribute3,
	l_poc_rec.attribute4,
	l_poc_rec.attribute5,
	l_poc_rec.attribute6,
	l_poc_rec.attribute7,
	l_poc_rec.attribute8,
	l_poc_rec.attribute9,
	l_poc_rec.attribute10,
	l_poc_rec.attribute11,
	l_poc_rec.attribute12,
	l_poc_rec.attribute13,
	l_poc_rec.attribute14,
	l_poc_rec.attribute15,
	l_poc_rec.request_id,
	l_poc_rec.program_application_id,
	l_poc_rec.program_id,
	l_poc_rec.program_update_date,
	l_poc_rec.created_by,
	l_poc_rec.creation_date,
	l_poc_rec.last_updated_by,
	l_poc_rec.last_update_date,
	l_poc_rec.last_update_login;
    x_no_data_found := okl_pool_contents_pk_csr%NOTFOUND;
    CLOSE okl_pool_contents_pk_csr;
    RETURN(l_poc_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_poc_rec                      IN poc_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN poc_rec_type IS
    l_poc_rec                      poc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_poc_rec := get_rec(p_poc_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_poc_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_poc_rec                      IN poc_rec_type
  ) RETURN poc_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_poc_rec, l_row_not_found));
  END get_rec;

  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_POOL_CONTENTS_V
  -- mvasudev, hold this off for now
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pocv_rec   IN pocv_rec_type
  ) RETURN pocv_rec_type IS
    l_pocv_rec                     pocv_rec_type := p_pocv_rec;
  BEGIN
    IF (l_pocv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.id := NULL;
    END IF;
    IF (l_pocv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.object_version_number := NULL;
    END IF;
    IF (l_pocv_rec.pol_id = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.pol_id := NULL;
    END IF;
    IF (l_pocv_rec.khr_id = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.khr_id := NULL;
    END IF;
    IF (l_pocv_rec.kle_id = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.kle_id := NULL;
    END IF;
    IF (l_pocv_rec.sty_id = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.sty_id := NULL;
    END IF;
    IF (l_pocv_rec.stm_id = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.stm_id := NULL;
    END IF;
    IF (l_pocv_rec.sty_code = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.sty_code := NULL;
    END IF;
    IF (l_pocv_rec.pox_id = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.pox_id := NULL;
    END IF;
    IF (l_pocv_rec.streams_from_date = OKL_API.G_MISS_DATE ) THEN
      l_pocv_rec.streams_from_date := NULL;
    END IF;
    IF (l_pocv_rec.streams_to_date = OKL_API.G_MISS_DATE ) THEN
      l_pocv_rec.streams_to_date := NULL;
    END IF;
    IF (l_pocv_rec.transaction_number_in = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.transaction_number_in := NULL;
    END IF;
    IF (l_pocv_rec.transaction_number_out = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.transaction_number_out := NULL;
    END IF;
    IF (l_pocv_rec.date_inactive = OKL_API.G_MISS_DATE ) THEN
      l_pocv_rec.date_inactive := NULL;
    END IF;
    IF (l_pocv_rec.status_code = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.status_code := NULL;
    END IF;
    IF (l_pocv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute_category := NULL;
    END IF;
    IF (l_pocv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute1 := NULL;
    END IF;
    IF (l_pocv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute2 := NULL;
    END IF;
    IF (l_pocv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute3 := NULL;
    END IF;
    IF (l_pocv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute4 := NULL;
    END IF;
    IF (l_pocv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute5 := NULL;
    END IF;
    IF (l_pocv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute6 := NULL;
    END IF;
    IF (l_pocv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute7 := NULL;
    END IF;
    IF (l_pocv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute8 := NULL;
    END IF;
    IF (l_pocv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute9 := NULL;
    END IF;
    IF (l_pocv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute10 := NULL;
    END IF;
    IF (l_pocv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute11 := NULL;
    END IF;
    IF (l_pocv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute12 := NULL;
    END IF;
    IF (l_pocv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute13 := NULL;
    END IF;
    IF (l_pocv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute14 := NULL;
    END IF;
    IF (l_pocv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute15 := NULL;
    END IF;
    IF (l_pocv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_pocv_rec.attribute1 := NULL;
    END IF;
    IF (l_pocv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.request_id := NULL;
    END IF;
    IF (l_pocv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.program_application_id := NULL;
    END IF;
    IF (l_pocv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.program_id := NULL;
    END IF;
    IF (l_pocv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_pocv_rec.program_update_date := NULL;
    END IF;
    IF (l_pocv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.created_by := NULL;
    END IF;
    IF (l_pocv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_pocv_rec.creation_date := NULL;
    END IF;
    IF (l_pocv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pocv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_pocv_rec.last_update_date := NULL;
    END IF;
    IF (l_pocv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_pocv_rec.last_update_login := NULL;
    END IF;

    RETURN(l_pocv_rec);
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

  -- Cursor For OKL_POL_POT_FK;
  CURSOR okl_polv_pk_csr (p_id IN OKL_POOL_CONTENTS_V.pol_id%TYPE) IS
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
  -- Validate_Attributes for: khr_id --
  -------------------------------------
  PROCEDURE validate_khr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_khr_id                       IN NUMBER) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_POL_KHR_FK;
  CURSOR okl_khrv_pk_csr (p_id IN OKL_POOL_CONTENTS_V.khr_id%TYPE) IS
  SELECT '1'
    FROM OKL_K_HEADERS_V
   WHERE OKL_K_HEADERS_V.id = p_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_khr_id = OKL_API.G_MISS_NUM OR
        p_khr_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'khr_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_khrv_pk_csr(p_khr_id);
    FETCH okl_khrv_pk_csr INTO l_dummy;
    l_row_not_found := okl_khrv_pk_csr%NOTFOUND;
    CLOSE okl_khrv_pk_csr;

    IF l_row_not_found THEN
      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'khr_id');
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
      IF okl_khrv_pk_csr%ISOPEN THEN
        CLOSE okl_khrv_pk_csr;
      END IF;
  END validate_khr_id;

  -------------------------------------
  -- Validate_Attributes for: kle_id --
  -------------------------------------
  PROCEDURE validate_kle_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_kle_id                       IN NUMBER) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_POL_KHR_FK;
  CURSOR okl_klev_pk_csr (p_id IN OKL_POOL_CONTENTS_V.kle_id%TYPE) IS
  SELECT '1'
    FROM OKL_K_LINES_V
   WHERE OKL_K_LINES_V.id = p_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_kle_id = OKL_API.G_MISS_NUM OR
        p_kle_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'kle_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_klev_pk_csr(p_kle_id);
    FETCH okl_klev_pk_csr INTO l_dummy;
    l_row_not_found := okl_klev_pk_csr%NOTFOUND;
    CLOSE okl_klev_pk_csr;

    IF l_row_not_found THEN
      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'kle_id');
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
      IF okl_klev_pk_csr%ISOPEN THEN
        CLOSE okl_klev_pk_csr;
      END IF;
  END validate_kle_id;

  -------------------------------------
  -- Validate_Attributes for: sty_id --
  -------------------------------------
  PROCEDURE validate_sty_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sty_id                       IN NUMBER) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_POL_KHR_FK;
  CURSOR okl_styv_pk_csr (p_id IN OKL_POOL_CONTENTS_V.sty_id%TYPE) IS
  SELECT '1'
    FROM OKL_STRM_TYPE_V
   WHERE OKL_STRM_TYPE_V.id = p_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_sty_id = OKL_API.G_MISS_NUM OR
        p_sty_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sty_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_styv_pk_csr(p_sty_id);
    FETCH okl_styv_pk_csr INTO l_dummy;
    l_row_not_found := okl_styv_pk_csr%NOTFOUND;
    CLOSE okl_styv_pk_csr;

    IF l_row_not_found THEN
      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'sty_id');
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
      IF okl_styv_pk_csr%ISOPEN THEN
        CLOSE okl_styv_pk_csr;
      END IF;
  END validate_sty_id;

  -------------------------------------
  -- Validate_Attributes for: stm_id --
  -------------------------------------
  PROCEDURE validate_stm_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_stm_id                       IN NUMBER) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_POL_KHR_FK;
  CURSOR okl_stm_pk_csr (p_id IN OKL_POOL_CONTENTS_V.stm_id%TYPE) IS
  SELECT '1'
    FROM OKL_STREAMS
   WHERE OKL_STREAMS.id = p_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_stm_id = OKL_API.G_MISS_NUM OR
        p_stm_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'p_stm_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_stm_pk_csr(p_stm_id);
    FETCH okl_stm_pk_csr INTO l_dummy;
    l_row_not_found := okl_stm_pk_csr%NOTFOUND;
    CLOSE okl_stm_pk_csr;

    IF l_row_not_found THEN
      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'stm_id');
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
      IF okl_stm_pk_csr%ISOPEN THEN
        CLOSE okl_stm_pk_csr;
      END IF;
  END validate_stm_id;

  -------------------------------------
  -- Validate_Attributes for: pox_id --
  -------------------------------------
  PROCEDURE validate_pox_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_pox_id                       IN NUMBER) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_POL_KHR_FK;
  CURSOR okl_poxv_pk_csr (p_id IN OKL_POOL_CONTENTS_V.pox_id%TYPE) IS
  SELECT '1'
    FROM OKL_POOL_TRANSACTIONS_V
   WHERE OKL_POOL_TRANSACTIONS_V.id = p_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_pox_id <> OKL_API.G_MISS_NUM AND   p_pox_id IS NOT NULL)
    THEN
	    OPEN okl_poxv_pk_csr(p_pox_id);
	    FETCH okl_poxv_pk_csr INTO l_dummy;
	    l_row_not_found := okl_poxv_pk_csr%NOTFOUND;
	    CLOSE okl_poxv_pk_csr;

	    IF l_row_not_found THEN
	      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'pox_id');
	      x_return_status := OKL_API.G_RET_STS_ERROR;
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
      IF okl_poxv_pk_csr%ISOPEN THEN
        CLOSE okl_poxv_pk_csr;
      END IF;
  END validate_pox_id;

  --------------------------------------
  -- Validate_Attributes for: streams_from_date --
  --------------------------------------
  PROCEDURE validate_streams_from_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_streams_from_date                      IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_streams_from_date = OKL_API.G_MISS_DATE OR
        p_streams_from_date IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'streams_from_date');
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
  END validate_streams_from_date;

  --------------------------------------------
  -- Validate_Attributes for: transaction_number_in --
  --------------------------------------------
  PROCEDURE validate_transaction_number_in(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_transaction_number_in                IN VARCHAR2) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_CURRENCIES;
  CURSOR okl_poxv_trans_csr (p_trans_num IN OKL_POOL_CONTENTS_V.transaction_number_in%TYPE) IS
  SELECT '1'
    FROM OKL_POOL_TRANSACTIONS_V
   WHERE OKL_POOL_TRANSACTIONS_V.transaction_number = p_trans_num;


  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_transaction_number_in = OKL_API.G_MISS_NUM AND       p_transaction_number_in IS NOT NULL)
    THEN
	    OPEN okl_poxv_trans_csr(p_transaction_number_in);
	    FETCH okl_poxv_trans_csr INTO l_dummy;
	    l_row_not_found := okl_poxv_trans_csr%NOTFOUND;
	    CLOSE okl_poxv_trans_csr;

	    IF l_row_not_found THEN
	      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'transaction_number_in');
	      x_return_status := OKL_API.G_RET_STS_ERROR;
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
      IF okl_poxv_trans_csr%ISOPEN THEN
        CLOSE okl_poxv_trans_csr;
      END IF;
  END validate_transaction_number_in;

  --------------------------------------------
  -- Validate_Attributes for: transaction_number_out --
  --------------------------------------------
  PROCEDURE validate_transaction_num_out(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_transaction_number_out                IN VARCHAR2) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_CURRENCIES;
  CURSOR okl_poxv_trans_csr (p_trans_num IN OKL_POOL_CONTENTS_V.transaction_number_out%TYPE) IS
  SELECT '1'
    FROM OKL_POOL_TRANSACTIONS_V
   WHERE OKL_POOL_TRANSACTIONS_V.transaction_number = p_trans_num;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_transaction_number_out = OKL_API.G_MISS_NUM AND       p_transaction_number_out IS NOT NULL)
    THEN
	    OPEN okl_poxv_trans_csr(p_transaction_number_out);
	    FETCH okl_poxv_trans_csr INTO l_dummy;
	    l_row_not_found := okl_poxv_trans_csr%NOTFOUND;
	    CLOSE okl_poxv_trans_csr;

	    IF l_row_not_found THEN
	      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'transaction_number_out');
	      x_return_status := OKL_API.G_RET_STS_ERROR;
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
      IF okl_poxv_trans_csr%ISOPEN THEN
        CLOSE okl_poxv_trans_csr;
      END IF;
  END validate_transaction_num_out;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_POOL_CONTENTS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_pocv_rec                     IN pocv_rec_type
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
    validate_id(x_return_status, p_pocv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_pocv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- pol_id
    -- ***
    validate_pol_id(x_return_status, p_pocv_rec.pol_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- khr_id
    -- ***
    validate_khr_id(x_return_status, p_pocv_rec.khr_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- kle_id
    -- ***
    validate_kle_id(x_return_status, p_pocv_rec.kle_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- sty_id
    -- ***
    validate_sty_id(x_return_status, p_pocv_rec.sty_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- stm_id
    -- ***
    validate_stm_id(x_return_status, p_pocv_rec.stm_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- pox_id
    -- ***
    validate_pox_id(x_return_status, p_pocv_rec.pox_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- streams_from_date
    -- ***
    validate_streams_from_date(x_return_status, p_pocv_rec.streams_from_date);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- transaction_number_in
    -- ***
    validate_transaction_number_in(x_return_status, p_pocv_rec.transaction_number_in);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- transaction_number_out
    -- ***
    validate_transaction_num_out(x_return_status, p_pocv_rec.transaction_number_out);
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
  -- Validate Record for:OKL_POOL_CONTENTS_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_pocv_rec IN pocv_rec_type,
    p_db_pocv_rec IN pocv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_pocv_rec IN pocv_rec_type,
      p_db_pocv_rec IN pocv_rec_type
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
    l_return_status := validate_foreign_keys(p_pocv_rec, p_db_pocv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_pocv_rec IN pocv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_pocv_rec                  pocv_rec_type := get_rec(p_pocv_rec);
  BEGIN
    l_return_status := Validate_Record(p_pocv_rec => p_pocv_rec,
                                       p_db_pocv_rec => l_db_pocv_rec);
    RETURN (l_return_status);
  END Validate_Record;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN pocv_rec_type,
    p_to   IN OUT NOCOPY poc_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.pol_id := p_from.pol_id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sty_id := p_from.sty_id;
    p_to.stm_id := p_from.stm_id;
    p_to.sty_code := p_from.sty_code;
    p_to.pox_id := p_from.pox_id;
    p_to.streams_from_date := p_from.streams_from_date;
    p_to.streams_to_date := p_from.streams_to_date;
    p_to.transaction_number_in := p_from.transaction_number_in;
    p_to.transaction_number_out := p_from.transaction_number_out;
    p_to.date_inactive := p_from.date_inactive;
    p_to.status_code := p_from.status_code;
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
  END migrate;
  PROCEDURE migrate (
    p_from IN poc_rec_type,
    p_to   IN OUT NOCOPY pocv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.pol_id := p_from.pol_id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sty_id := p_from.sty_id;
    p_to.stm_id := p_from.stm_id;
    p_to.sty_code := p_from.sty_code;
    p_to.pox_id := p_from.pox_id;
    p_to.streams_from_date := p_from.streams_from_date;
    p_to.streams_to_date := p_from.streams_to_date;
    p_to.transaction_number_in := p_from.transaction_number_in;
    p_to.transaction_number_out := p_from.transaction_number_out;
    p_to.date_inactive := p_from.date_inactive;
    p_to.status_code := p_from.status_code;
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
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_POOL_CONTENTS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_rec                     IN pocv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pocv_rec                     pocv_rec_type := p_pocv_rec;
    l_poc_rec                      poc_rec_type;
    l_poc_rec                      poc_rec_type;
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
    l_return_status := Validate_Attributes(l_pocv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pocv_rec);
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
  -- PL/SQL TBL validate_row for:OKL_POOL_CONTENTS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_tbl                     IN pocv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pocv_tbl.COUNT > 0) THEN
      i := p_pocv_tbl.FIRST;
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
            p_pocv_rec                     => p_pocv_tbl(i));
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
        EXIT WHEN (i = p_pocv_tbl.LAST);
        i := p_pocv_tbl.NEXT(i);
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
  -- PL/SQL TBL validate_row for:OKL_POOL_CONTENTS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_tbl                     IN pocv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pocv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pocv_tbl                     => p_pocv_tbl,
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
  -- insert_row for:okl_pool_contents --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poc_rec                      IN poc_rec_type,
    x_poc_rec                      OUT NOCOPY poc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_poc_rec                      poc_rec_type := p_poc_rec;
    l_def_poc_rec                  poc_rec_type;
    --------------------------------------------
    -- Set_Attributes for:okl_pool_contents --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_poc_rec IN poc_rec_type,
      x_poc_rec OUT NOCOPY poc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_poc_rec := p_poc_rec;
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
      p_poc_rec,                         -- IN
      l_poc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO okl_pool_contents(
	ID,
	OBJECT_VERSION_NUMBER,
	POL_ID,
	KHR_ID,
	KLE_ID,
	STY_ID,
	STM_ID,
	STY_CODE,
	POX_ID,
	STREAMS_FROM_DATE,
	STREAMS_TO_DATE,
	TRANSACTION_NUMBER_IN,
	TRANSACTION_NUMBER_OUT,
	DATE_INACTIVE,
	ATTRIBUTE_CATEGORY,
	STATUS_CODE,
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
	LAST_UPDATE_LOGIN)
    VALUES (
	l_poc_rec.id,
	l_poc_rec.object_version_number,
	l_poc_rec.pol_id,
	l_poc_rec.khr_id,
	l_poc_rec.kle_id,
	l_poc_rec.sty_id,
	l_poc_rec.stm_id,
	l_poc_rec.sty_code,
	l_poc_rec.pox_id,
	l_poc_rec.streams_from_date,
	l_poc_rec.streams_to_date,
	l_poc_rec.transaction_number_in,
	l_poc_rec.transaction_number_out,
	l_poc_rec.date_inactive,
	l_poc_rec.attribute_category,
	l_poc_rec.status_code,
	l_poc_rec.attribute1 ,
	l_poc_rec.attribute2,
	l_poc_rec.attribute3,
	l_poc_rec.attribute4,
	l_poc_rec.attribute5,
	l_poc_rec.attribute6,
	l_poc_rec.attribute7,
	l_poc_rec.attribute8,
	l_poc_rec.attribute9,
	l_poc_rec.attribute10,
	l_poc_rec.attribute11,
	l_poc_rec.attribute12,
	l_poc_rec.attribute13,
	l_poc_rec.attribute14,
	l_poc_rec.attribute15,
	l_poc_rec.request_id,
	l_poc_rec.program_application_id,
	l_poc_rec.program_id,
	l_poc_rec.program_update_date,
	l_poc_rec.created_by,
	l_poc_rec.creation_date,
	l_poc_rec.last_updated_by,
	l_poc_rec.last_update_date,
	l_poc_rec.last_update_login);
    -- Set OUT values
    x_poc_rec := l_poc_rec;
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
  -- insert_row for :OKL_POOL_CONTENTS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_rec                     IN pocv_rec_type,
    x_pocv_rec                     OUT NOCOPY pocv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pocv_rec                     pocv_rec_type := p_pocv_rec;
    l_def_pocv_rec                 pocv_rec_type;
    l_poc_rec                      poc_rec_type;
    lx_poc_rec                     poc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pocv_rec IN pocv_rec_type
    ) RETURN pocv_rec_type IS
      l_pocv_rec pocv_rec_type := p_pocv_rec;
    BEGIN
      l_pocv_rec.CREATION_DATE := SYSDATE;
      l_pocv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pocv_rec.LAST_UPDATE_DATE := l_pocv_rec.CREATION_DATE;
      l_pocv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pocv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pocv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_POOL_CONTENTS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_pocv_rec IN pocv_rec_type,
      x_pocv_rec OUT NOCOPY pocv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pocv_rec := p_pocv_rec;
      x_pocv_rec.OBJECT_VERSION_NUMBER := 1;

      -- concurrent program columns
      SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL,Fnd_Global.CONC_REQUEST_ID),
             DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL,Fnd_Global.PROG_APPL_ID),
             DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL,Fnd_Global.CONC_PROGRAM_ID),
             DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
      INTO   x_pocv_rec.REQUEST_ID
            ,x_pocv_rec.PROGRAM_APPLICATION_ID
            ,x_pocv_rec.PROGRAM_ID
            ,x_pocv_rec.PROGRAM_UPDATE_DATE
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
    l_pocv_rec := null_out_defaults(p_pocv_rec);
    -- Set primary key value
    l_pocv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_pocv_rec,                        -- IN
      l_def_pocv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pocv_rec := fill_who_columns(l_def_pocv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pocv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pocv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_pocv_rec, l_poc_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_poc_rec,
      lx_poc_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_poc_rec, l_def_pocv_rec);
    -- Set OUT values
    x_pocv_rec := l_def_pocv_rec;
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
  -- PL/SQL TBL insert_row for:pocv_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_tbl                     IN pocv_tbl_type,
    x_pocv_tbl                     OUT NOCOPY pocv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pocv_tbl.COUNT > 0) THEN
      i := p_pocv_tbl.FIRST;
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
            p_pocv_rec                     => p_pocv_tbl(i),
            x_pocv_rec                     => x_pocv_tbl(i));
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
        EXIT WHEN (i = p_pocv_tbl.LAST);
        i := p_pocv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:pocv_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_tbl                     IN pocv_tbl_type,
    x_pocv_tbl                     OUT NOCOPY pocv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pocv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pocv_tbl                     => p_pocv_tbl,
        x_pocv_tbl                     => x_pocv_tbl,
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
  -- lock_row for:okl_pool_contents --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poc_rec                      IN poc_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_poc_rec IN poc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM okl_pool_contents
     WHERE ID = p_poc_rec.id
       AND OBJECT_VERSION_NUMBER = p_poc_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_poc_rec IN poc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM okl_pool_contents
     WHERE ID = p_poc_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        okl_pool_contents.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       okl_pool_contents.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_poc_rec);
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
      OPEN lchk_csr(p_poc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_poc_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_poc_rec.object_version_number THEN
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
  -- lock_row for: OKL_POOL_CONTENTS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_rec                     IN pocv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_poc_rec                      poc_rec_type;
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
    migrate(p_pocv_rec, l_poc_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_poc_rec
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
  -- PL/SQL TBL lock_row for:pocv_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_tbl                     IN pocv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_pocv_tbl.COUNT > 0) THEN
      i := p_pocv_tbl.FIRST;
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
            p_pocv_rec                     => p_pocv_tbl(i));
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
        EXIT WHEN (i = p_pocv_tbl.LAST);
        i := p_pocv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:pocv_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_tbl                     IN pocv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_pocv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pocv_tbl                     => p_pocv_tbl,
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
  -- update_row for:okl_pool_contents --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poc_rec                      IN poc_rec_type,
    x_poc_rec                      OUT NOCOPY poc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_poc_rec                      poc_rec_type := p_poc_rec;
    l_def_poc_rec                  poc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_poc_rec IN poc_rec_type,
      x_poc_rec OUT NOCOPY poc_rec_type
    ) RETURN VARCHAR2 IS
      l_poc_rec                      poc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_poc_rec := p_poc_rec;
      -- Get current database values
      l_poc_rec := get_rec(p_poc_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

        IF (x_poc_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.id := l_poc_rec.id;
        END IF;
        IF (x_poc_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.object_version_number := l_poc_rec.object_version_number;
        END IF;
        IF (x_poc_rec.pol_id = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.pol_id := l_poc_rec.pol_id;
        END IF;
        IF (x_poc_rec.khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.khr_id := l_poc_rec.khr_id;
        END IF;
        IF (x_poc_rec.kle_id = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.kle_id := l_poc_rec.kle_id;
        END IF;
        IF (x_poc_rec.sty_id = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.sty_id := l_poc_rec.sty_id;
        END IF;
        IF (x_poc_rec.stm_id = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.stm_id := l_poc_rec.stm_id;
        END IF;
        IF (x_poc_rec.sty_code = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.sty_code := l_poc_rec.sty_code;
        END IF;
        IF (x_poc_rec.pox_id = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.pox_id := l_poc_rec.pox_id;
        END IF;
        IF (x_poc_rec.streams_from_date = OKL_API.G_MISS_DATE)
        THEN
          x_poc_rec.streams_from_date := l_poc_rec.streams_from_date;
        END IF;
        IF (x_poc_rec.streams_to_date = OKL_API.G_MISS_DATE)
        THEN
          x_poc_rec.streams_to_date := l_poc_rec.streams_to_date;
        END IF;
        IF (x_poc_rec.transaction_number_in = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.transaction_number_in := l_poc_rec.transaction_number_in;
        END IF;
        IF (x_poc_rec.transaction_number_out = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.transaction_number_out := l_poc_rec.transaction_number_out;
        END IF;
        IF (x_poc_rec.date_inactive = OKL_API.G_MISS_DATE)
        THEN
          x_poc_rec.date_inactive := l_poc_rec.date_inactive;
        END IF;
        IF (x_poc_rec.status_code = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.status_code := l_poc_rec.status_code;
        END IF;
        IF (x_poc_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute_category := l_poc_rec.attribute_category;
        END IF;
        IF (x_poc_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute1 := l_poc_rec.attribute1;
        END IF;
        IF (x_poc_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute2 := l_poc_rec.attribute2;
        END IF;
        IF (x_poc_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute3 := l_poc_rec.attribute3;
        END IF;
        IF (x_poc_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute4 := l_poc_rec.attribute4;
        END IF;
        IF (x_poc_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute5 := l_poc_rec.attribute5;
        END IF;
        IF (x_poc_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute6 := l_poc_rec.attribute6;
        END IF;
        IF (x_poc_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute7 := l_poc_rec.attribute7;
        END IF;
        IF (x_poc_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute8 := l_poc_rec.attribute8;
        END IF;
        IF (x_poc_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute9 := l_poc_rec.attribute9;
        END IF;
        IF (x_poc_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute10 := l_poc_rec.attribute10;
        END IF;
        IF (x_poc_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute11 := l_poc_rec.attribute11;
        END IF;
        IF (x_poc_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute12 := l_poc_rec.attribute12;
        END IF;
        IF (x_poc_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute13 := l_poc_rec.attribute13;
        END IF;
        IF (x_poc_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute14 := l_poc_rec.attribute14;
        END IF;
        IF (x_poc_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_poc_rec.attribute15 := l_poc_rec.attribute15;
        END IF;
        IF (x_poc_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.request_id := l_poc_rec.request_id;
        END IF;
        IF (x_poc_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.program_application_id := l_poc_rec.program_application_id;
        END IF;
        IF (x_poc_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.program_id := l_poc_rec.program_id;
        END IF;
        IF (x_poc_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_poc_rec.program_update_date := l_poc_rec.program_update_date;
        END IF;
        IF (x_poc_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.created_by := l_poc_rec.created_by;
        END IF;
        IF (x_poc_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_poc_rec.creation_date := l_poc_rec.creation_date;
        END IF;
        IF (x_poc_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.last_updated_by := l_poc_rec.last_updated_by;
        END IF;
        IF (x_poc_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_poc_rec.last_update_date := l_poc_rec.last_update_date;
        END IF;
        IF (x_poc_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_poc_rec.last_update_login := l_poc_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:okl_pool_contents --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_poc_rec IN poc_rec_type,
      x_poc_rec OUT NOCOPY poc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_poc_rec := p_poc_rec;
      x_poc_rec.OBJECT_VERSION_NUMBER := p_poc_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_poc_rec,                         -- IN
      l_poc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_poc_rec, l_def_poc_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE okl_pool_contents
    SET OBJECT_VERSION_NUMBER = l_def_poc_rec.object_version_number,
        POL_ID = l_def_poc_rec.pol_id,
        KHR_ID = l_def_poc_rec.khr_id,
        KLE_ID = l_def_poc_rec.kle_id,
        STY_ID = l_def_poc_rec.sty_id,
        STM_ID = l_def_poc_rec.stm_id,
        STY_CODE = l_def_poc_rec.sty_code,
        POX_ID = l_def_poc_rec.pox_id,
        STREAMS_FROM_DATE = l_def_poc_rec.streams_from_date,
        STREAMS_TO_DATE = l_def_poc_rec.streams_to_date,
        TRANSACTION_NUMBER_IN = l_def_poc_rec.transaction_number_in,
        TRANSACTION_NUMBER_OUT = l_def_poc_rec.transaction_number_out,
        DATE_INACTIVE = l_def_poc_rec.date_inactive,
        STATUS_CODE = l_def_poc_rec.status_code,
        ATTRIBUTE_CATEGORY = l_def_poc_rec.attribute_category,
        ATTRIBUTE1 = l_def_poc_rec.attribute1,
        ATTRIBUTE2 = l_def_poc_rec.attribute2,
        ATTRIBUTE3 = l_def_poc_rec.attribute3,
        ATTRIBUTE4 = l_def_poc_rec.attribute4,
        ATTRIBUTE5 = l_def_poc_rec.attribute5,
        ATTRIBUTE6 = l_def_poc_rec.attribute6,
        ATTRIBUTE7 = l_def_poc_rec.attribute7,
        ATTRIBUTE8 = l_def_poc_rec.attribute8,
        ATTRIBUTE9 = l_def_poc_rec.attribute9,
        ATTRIBUTE10 = l_def_poc_rec.attribute10,
        ATTRIBUTE11 = l_def_poc_rec.attribute11,
        ATTRIBUTE12 = l_def_poc_rec.attribute12,
        ATTRIBUTE13 = l_def_poc_rec.attribute13,
        ATTRIBUTE14 = l_def_poc_rec.attribute14,
        ATTRIBUTE15 = l_def_poc_rec.attribute15,
        REQUEST_ID = l_def_poc_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_poc_rec.program_application_id,
        PROGRAM_ID = l_def_poc_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_poc_rec.program_update_date,
        CREATED_BY = l_def_poc_rec.created_by,
        CREATION_DATE = l_def_poc_rec.creation_date,
        LAST_UPDATED_BY = l_def_poc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_poc_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_poc_rec.last_update_login
    WHERE ID = l_def_poc_rec.id;

    x_poc_rec := l_poc_rec;
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
  -- update_row for:OKL_POOL_CONTENTS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_rec                     IN pocv_rec_type,
    x_pocv_rec                     OUT NOCOPY pocv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pocv_rec                     pocv_rec_type := p_pocv_rec;
    l_def_pocv_rec                 pocv_rec_type;
    l_db_pocv_rec                  pocv_rec_type;
    l_poc_rec                      poc_rec_type;
    lx_poc_rec                     poc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pocv_rec IN pocv_rec_type
    ) RETURN pocv_rec_type IS
      l_pocv_rec pocv_rec_type := p_pocv_rec;
    BEGIN
      l_pocv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pocv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pocv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pocv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pocv_rec IN pocv_rec_type,
      x_pocv_rec OUT NOCOPY pocv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pocv_rec := p_pocv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_pocv_rec := get_rec(p_pocv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_pocv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.id := l_db_pocv_rec.id;
        END IF;
        IF (x_pocv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.object_version_number := l_db_pocv_rec.object_version_number;
        END IF;
        IF (x_pocv_rec.pol_id = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.pol_id := l_db_pocv_rec.pol_id;
        END IF;
        IF (x_pocv_rec.khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.khr_id := l_db_pocv_rec.khr_id;
        END IF;
        IF (x_pocv_rec.kle_id = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.kle_id := l_db_pocv_rec.kle_id;
        END IF;
        IF (x_pocv_rec.sty_id = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.sty_id := l_db_pocv_rec.sty_id;
        END IF;
        IF (x_pocv_rec.stm_id = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.stm_id := l_db_pocv_rec.stm_id;
        END IF;
        IF (x_pocv_rec.sty_code = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.sty_code := l_db_pocv_rec.sty_code;
        END IF;
        IF (x_pocv_rec.pox_id = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.pox_id := l_db_pocv_rec.pox_id;
        END IF;
        IF (x_pocv_rec.streams_from_date = OKL_API.G_MISS_DATE)
        THEN
          x_pocv_rec.streams_from_date := l_db_pocv_rec.streams_from_date;
        END IF;
        IF (x_pocv_rec.streams_to_date = OKL_API.G_MISS_DATE)
        THEN
          x_pocv_rec.streams_to_date := l_db_pocv_rec.streams_to_date;
        END IF;
        IF (x_pocv_rec.transaction_number_in = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.transaction_number_in := l_db_pocv_rec.transaction_number_in;
        END IF;
        IF (x_pocv_rec.transaction_number_out = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.transaction_number_out := l_db_pocv_rec.transaction_number_out;
        END IF;
        IF (x_pocv_rec.date_inactive = OKL_API.G_MISS_DATE)
        THEN
          x_pocv_rec.date_inactive := l_db_pocv_rec.date_inactive;
        END IF;
        IF (x_pocv_rec.status_code = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.status_code := l_db_pocv_rec.status_code;
        END IF;
        IF (x_pocv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute_category := l_db_pocv_rec.attribute_category;
        END IF;
        IF (x_pocv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute1 := l_db_pocv_rec.attribute1;
        END IF;
        IF (x_pocv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute2 := l_db_pocv_rec.attribute2;
        END IF;
        IF (x_pocv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute3 := l_db_pocv_rec.attribute3;
        END IF;
        IF (x_pocv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute4 := l_db_pocv_rec.attribute4;
        END IF;
        IF (x_pocv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute5 := l_db_pocv_rec.attribute5;
        END IF;
        IF (x_pocv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute6 := l_db_pocv_rec.attribute6;
        END IF;
        IF (x_pocv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute7 := l_db_pocv_rec.attribute7;
        END IF;
        IF (x_pocv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute8 := l_db_pocv_rec.attribute8;
        END IF;
        IF (x_pocv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute9 := l_db_pocv_rec.attribute9;
        END IF;
        IF (x_pocv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute10 := l_db_pocv_rec.attribute10;
        END IF;
        IF (x_pocv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute11 := l_db_pocv_rec.attribute11;
        END IF;
        IF (x_pocv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute12 := l_db_pocv_rec.attribute12;
        END IF;
        IF (x_pocv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute13 := l_db_pocv_rec.attribute13;
        END IF;
        IF (x_pocv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute14 := l_db_pocv_rec.attribute14;
        END IF;
        IF (x_pocv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_pocv_rec.attribute15 := l_db_pocv_rec.attribute15;
        END IF;
        IF (x_pocv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.request_id := l_db_pocv_rec.request_id;
        END IF;
        IF (x_pocv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.program_application_id := l_db_pocv_rec.program_application_id;
        END IF;
        IF (x_pocv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.program_id := l_db_pocv_rec.program_id;
        END IF;
        IF (x_pocv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pocv_rec.program_update_date := l_db_pocv_rec.program_update_date;
        END IF;
        IF (x_pocv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.created_by := l_db_pocv_rec.created_by;
        END IF;
        IF (x_pocv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_pocv_rec.creation_date := l_db_pocv_rec.creation_date;
        END IF;
        IF (x_pocv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.last_updated_by := l_db_pocv_rec.last_updated_by;
        END IF;
        IF (x_pocv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pocv_rec.last_update_date := l_db_pocv_rec.last_update_date;
        END IF;
        IF (x_pocv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_pocv_rec.last_update_login := l_db_pocv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_POOL_CONTENTS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_pocv_rec IN pocv_rec_type,
      x_pocv_rec OUT NOCOPY pocv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pocv_rec := p_pocv_rec;
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
      p_pocv_rec,                        -- IN
      x_pocv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pocv_rec, l_def_pocv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pocv_rec := fill_who_columns(l_def_pocv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pocv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pocv_rec, l_db_pocv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*
    -- MVASUDEV COMMENTED
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_pocv_rec                     => p_pocv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    */

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_pocv_rec, l_poc_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_poc_rec,
      lx_poc_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_poc_rec, l_def_pocv_rec);
    x_pocv_rec := l_def_pocv_rec;
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
  -- PL/SQL TBL update_row for:pocv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_tbl                     IN pocv_tbl_type,
    x_pocv_tbl                     OUT NOCOPY pocv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pocv_tbl.COUNT > 0) THEN
      i := p_pocv_tbl.FIRST;
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
            p_pocv_rec                     => p_pocv_tbl(i),
            x_pocv_rec                     => x_pocv_tbl(i));
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
        EXIT WHEN (i = p_pocv_tbl.LAST);
        i := p_pocv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:pocv_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_tbl                     IN pocv_tbl_type,
    x_pocv_tbl                     OUT NOCOPY pocv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pocv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pocv_tbl                     => p_pocv_tbl,
        x_pocv_tbl                     => x_pocv_tbl,
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
  -- delete_row for:okl_pool_contents --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poc_rec                      IN poc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_poc_rec                      poc_rec_type := p_poc_rec;
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

    DELETE FROM okl_pool_contents
     WHERE ID = p_poc_rec.id;

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
  -- delete_row for:OKL_POOL_CONTENTS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_rec                     IN pocv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pocv_rec                     pocv_rec_type := p_pocv_rec;
    l_poc_rec                      poc_rec_type;
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
    migrate(l_pocv_rec, l_poc_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_poc_rec
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
  -- PL/SQL TBL delete_row for:OKL_POOL_CONTENTS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_tbl                     IN pocv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pocv_tbl.COUNT > 0) THEN
      i := p_pocv_tbl.FIRST;
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
            p_pocv_rec                     => p_pocv_tbl(i));
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
        EXIT WHEN (i = p_pocv_tbl.LAST);
        i := p_pocv_tbl.NEXT(i);
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
  -- PL/SQL TBL delete_row for:OKL_POOL_CONTENTS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pocv_tbl                     IN pocv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pocv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pocv_tbl                     => p_pocv_tbl,
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

END OKL_POC_PVT;

/
