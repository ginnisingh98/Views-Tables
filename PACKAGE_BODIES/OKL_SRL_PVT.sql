--------------------------------------------------------
--  DDL for Package Body OKL_SRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SRL_PVT" AS
/* $Header: OKLSSRLB.pls 115.6 2003/10/16 07:06:12 smahapat noship $ */
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
  -- FUNCTION get_rec for: OKL_SIF_RET_LEVELS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_sif_ret_levels_v_rec_type IS
    CURSOR srlv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            LEVEL_INDEX_NUMBER,
            NUMBER_OF_PERIODS,
            SIR_ID,
            INDEX_NUMBER,
            LEVEL_TYPE,
            AMOUNT,
            ADVANCE_OR_ARREARS,
            PERIOD,
            LOCK_LEVEL_STEP,
            DAYS_IN_PERIOD,
            FIRST_PAYMENT_DATE,
            OBJECT_VERSION_NUMBER,
            STREAM_INTERFACE_ATTRIBUTE1,
            STREAM_INTERFACE_ATTRIBUTE2,
            STREAM_INTERFACE_ATTRIBUTE3,
            STREAM_INTERFACE_ATTRIBUTE4,
            STREAM_INTERFACE_ATTRIBUTE5,
            STREAM_INTERFACE_ATTRIBUTE6,
            STREAM_INTERFACE_ATTRIBUTE7,
            STREAM_INTERFACE_ATTRIBUTE8,
            STREAM_INTERFACE_ATTRIBUTE9,
            STREAM_INTERFACE_ATTRIBUTE10,
            STREAM_INTERFACE_ATTRIBUTE11,
            STREAM_INTERFACE_ATTRIBUTE12,
            STREAM_INTERFACE_ATTRIBUTE13,
            STREAM_INTERFACE_ATTRIBUTE14,
            STREAM_INTERFACE_ATTRIBUTE15,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
			RATE --smahapat 10/12/03
      FROM Okl_Sif_Ret_Levels_V
     WHERE okl_sif_ret_levels_v.id = p_id;
    l_srlv_pk                      srlv_pk_csr%ROWTYPE;
    l_okl_sif_ret_levels_v_rec     okl_sif_ret_levels_v_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN srlv_pk_csr (p_okl_sif_ret_levels_v_rec.id);
    FETCH srlv_pk_csr INTO
              l_okl_sif_ret_levels_v_rec.id,
              l_okl_sif_ret_levels_v_rec.level_index_number,
              l_okl_sif_ret_levels_v_rec.number_of_periods,
              l_okl_sif_ret_levels_v_rec.sir_id,
              l_okl_sif_ret_levels_v_rec.index_number,
              l_okl_sif_ret_levels_v_rec.level_type,
              l_okl_sif_ret_levels_v_rec.amount,
              l_okl_sif_ret_levels_v_rec.advance_or_arrears,
              l_okl_sif_ret_levels_v_rec.period,
              l_okl_sif_ret_levels_v_rec.lock_level_step,
              l_okl_sif_ret_levels_v_rec.days_in_period,
              l_okl_sif_ret_levels_v_rec.first_payment_date,
              l_okl_sif_ret_levels_v_rec.object_version_number,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute1,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute2,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute3,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute4,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute5,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute6,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute7,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute8,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute9,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute10,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute11,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute12,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute13,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute14,
              l_okl_sif_ret_levels_v_rec.stream_interface_attribute15,
              l_okl_sif_ret_levels_v_rec.creation_date,
              l_okl_sif_ret_levels_v_rec.created_by,
              l_okl_sif_ret_levels_v_rec.last_update_date,
              l_okl_sif_ret_levels_v_rec.last_updated_by,
              l_okl_sif_ret_levels_v_rec.last_update_login,
              l_okl_sif_ret_levels_v_rec.rate; --smahapat 10/12/03
    x_no_data_found := srlv_pk_csr%NOTFOUND;
    CLOSE srlv_pk_csr;
    RETURN(l_okl_sif_ret_levels_v_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okl_sif_ret_levels_v_rec_type IS
    l_okl_sif_ret_levels_v_rec     okl_sif_ret_levels_v_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_okl_sif_ret_levels_v_rec := get_rec(p_okl_sif_ret_levels_v_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okl_sif_ret_levels_v_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type
  ) RETURN okl_sif_ret_levels_v_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_sif_ret_levels_v_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_RET_LEVELS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_srl_rec                      IN srl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN srl_rec_type IS
    CURSOR srl_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            SIR_ID,
            INDEX_NUMBER,
            NUMBER_OF_PERIODS,
            LEVEL_INDEX_NUMBER,
            LEVEL_TYPE,
            AMOUNT,
            ADVANCE_OR_ARREARS,
            PERIOD,
            LOCK_LEVEL_STEP,
            DAYS_IN_PERIOD,
            FIRST_PAYMENT_DATE,
            OBJECT_VERSION_NUMBER,
            STREAM_INTERFACE_ATTRIBUTE1,
            STREAM_INTERFACE_ATTRIBUTE2,
            STREAM_INTERFACE_ATTRIBUTE3,
            STREAM_INTERFACE_ATTRIBUTE4,
            STREAM_INTERFACE_ATTRIBUTE5,
            STREAM_INTERFACE_ATTRIBUTE6,
            STREAM_INTERFACE_ATTRIBUTE7,
            STREAM_INTERFACE_ATTRIBUTE8,
            STREAM_INTERFACE_ATTRIBUTE9,
            STREAM_INTERFACE_ATTRIBUTE10,
            STREAM_INTERFACE_ATTRIBUTE11,
            STREAM_INTERFACE_ATTRIBUTE12,
            STREAM_INTERFACE_ATTRIBUTE13,
            STREAM_INTERFACE_ATTRIBUTE14,
            STREAM_INTERFACE_ATTRIBUTE15,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
			RATE --smahapat 10/12/03
      FROM Okl_Sif_Ret_Levels
     WHERE okl_sif_ret_levels.id = p_id;
    l_srl_pk                       srl_pk_csr%ROWTYPE;
    l_srl_rec                      srl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN srl_pk_csr (p_srl_rec.id);
    FETCH srl_pk_csr INTO
              l_srl_rec.id,
              l_srl_rec.sir_id,
              l_srl_rec.index_number,
              l_srl_rec.number_of_periods,
              l_srl_rec.level_index_number,
              l_srl_rec.level_type,
              l_srl_rec.amount,
              l_srl_rec.advance_or_arrears,
              l_srl_rec.period,
              l_srl_rec.lock_level_step,
              l_srl_rec.days_in_period,
              l_srl_rec.first_payment_date,
              l_srl_rec.object_version_number,
              l_srl_rec.stream_interface_attribute1,
              l_srl_rec.stream_interface_attribute2,
              l_srl_rec.stream_interface_attribute3,
              l_srl_rec.stream_interface_attribute4,
              l_srl_rec.stream_interface_attribute5,
              l_srl_rec.stream_interface_attribute6,
              l_srl_rec.stream_interface_attribute7,
              l_srl_rec.stream_interface_attribute8,
              l_srl_rec.stream_interface_attribute9,
              l_srl_rec.stream_interface_attribute10,
              l_srl_rec.stream_interface_attribute11,
              l_srl_rec.stream_interface_attribute12,
              l_srl_rec.stream_interface_attribute13,
              l_srl_rec.stream_interface_attribute14,
              l_srl_rec.stream_interface_attribute15,
              l_srl_rec.creation_date,
              l_srl_rec.created_by,
              l_srl_rec.last_update_date,
              l_srl_rec.last_updated_by,
              l_srl_rec.last_update_login,
              l_srl_rec.rate; --smahapat 10/12/03
    x_no_data_found := srl_pk_csr%NOTFOUND;
    CLOSE srl_pk_csr;
    RETURN(l_srl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_srl_rec                      IN srl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN srl_rec_type IS
    l_srl_rec                      srl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_srl_rec := get_rec(p_srl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_srl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_srl_rec                      IN srl_rec_type
  ) RETURN srl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_srl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SIF_RET_LEVELS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_okl_sif_ret_levels_v_rec   IN okl_sif_ret_levels_v_rec_type
  ) RETURN okl_sif_ret_levels_v_rec_type IS
    l_okl_sif_ret_levels_v_rec     okl_sif_ret_levels_v_rec_type := p_okl_sif_ret_levels_v_rec;
  BEGIN
    IF (l_okl_sif_ret_levels_v_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.id := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.level_index_number = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.level_index_number := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.number_of_periods = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.number_of_periods := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.sir_id = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.sir_id := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.index_number = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.index_number := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.level_type = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.level_type := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.amount = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.amount := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.advance_or_arrears = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.advance_or_arrears := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.period = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.period := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.lock_level_step = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.lock_level_step := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.days_in_period = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.days_in_period := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.first_payment_date = OKC_API.G_MISS_DATE ) THEN
      l_okl_sif_ret_levels_v_rec.first_payment_date := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.object_version_number := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute1 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute2 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute3 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute4 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute5 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute6 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute7 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute8 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute9 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute10 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute11 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute12 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute13 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute14 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_okl_sif_ret_levels_v_rec.stream_interface_attribute15 := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_okl_sif_ret_levels_v_rec.creation_date := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.created_by := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_okl_sif_ret_levels_v_rec.last_update_date := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.last_updated_by := NULL;
    END IF;
    IF (l_okl_sif_ret_levels_v_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.last_update_login := NULL;
    END IF;
	--smahapat 10/12/03
    IF (l_okl_sif_ret_levels_v_rec.rate = OKC_API.G_MISS_NUM ) THEN
      l_okl_sif_ret_levels_v_rec.rate := NULL;
    END IF;
    RETURN(l_okl_sif_ret_levels_v_rec);
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
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  -------------------------------------
  -- Validate_Attributes for: SIR_ID --
  -------------------------------------
  PROCEDURE validate_sir_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sir_id                       IN NUMBER) IS

    -- smahapat added 05/14
    l_dummy                 VARCHAR2(1) := '?';
    l_row_not_found         BOOLEAN := FALSE;

    -- Cursor For OKL_SIF_RETS - Foreign Key Constraint
    CURSOR okl_sir_pk_csr (p_id IN OKL_SIF_RETS_V.id%TYPE) IS
    SELECT '1'
    FROM OKL_Sif_rets_V
    WHERE OKL_Sif_rets_V.id = p_id;
    -- smahapat change end

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_sir_id = OKC_API.G_MISS_NUM OR
        p_sir_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sir_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- smahapat added 05/14
    OPEN okl_sir_pk_csr (p_sir_id);
    FETCH okl_sir_pk_csr INTO l_dummy;
    l_row_not_found := okl_sir_pk_csr%NOTFOUND;
    CLOSE okl_sir_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'sir_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    -- smahapat change end
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
  END validate_sir_id;
  -------------------------------------------
  -- Validate_Attributes for: INDEX_NUMBER --
  -------------------------------------------
  PROCEDURE validate_index_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_index_number                 IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_index_number = OKC_API.G_MISS_NUM OR
        p_index_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'index_number');
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
  END validate_index_number;
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
      NULL;
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
  -- Validate_Attributes for:OKL_SIF_RET_LEVELS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type
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
    validate_id(x_return_status, p_okl_sif_ret_levels_v_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
    -- smahapat added 05/14
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    -- smahapat change end
    END IF;

    -- ***
    -- sir_id
    -- ***
    validate_sir_id(x_return_status, p_okl_sif_ret_levels_v_rec.sir_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
    -- smahapat added 05/14
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    -- smahapat change end
    END IF;

    -- ***
    -- index_number
    -- ***
    validate_index_number(x_return_status, p_okl_sif_ret_levels_v_rec.index_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
    -- smahapat added 05/14
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    -- smahapat change end
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_okl_sif_ret_levels_v_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
    -- smahapat added 05/14
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    -- smahapat change end
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
  ----------------------------------------------
  -- Validate Record for:OKL_SIF_RET_LEVELS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_okl_sif_ret_levels_v_rec IN okl_sif_ret_levels_v_rec_type,
    p_db_okl_sif_ret_levels_v_rec IN okl_sif_ret_levels_v_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_okl_sif_ret_levels_v_rec IN okl_sif_ret_levels_v_rec_type,
      p_db_okl_sif_ret_levels_v_rec IN okl_sif_ret_levels_v_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okl_sifv_sirv_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM okl_sif_rets_v
       WHERE okl_sif_rets_v.id    = p_id;
      l_okl_sifv_sirv_fk             okl_sifv_sirv_fk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF ((p_okl_sif_ret_levels_v_rec.SIR_ID IS NOT NULL)
       AND
          (p_okl_sif_ret_levels_v_rec.SIR_ID <> p_db_okl_sif_ret_levels_v_rec.SIR_ID))
      THEN
        OPEN okl_sifv_sirv_fk_csr (p_okl_sif_ret_levels_v_rec.SIR_ID);
        FETCH okl_sifv_sirv_fk_csr INTO l_okl_sifv_sirv_fk;
        l_row_notfound := okl_sifv_sirv_fk_csr%NOTFOUND;
        CLOSE okl_sifv_sirv_fk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SIR_ID');
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
    l_return_status := validate_foreign_keys(p_okl_sif_ret_levels_v_rec, p_db_okl_sif_ret_levels_v_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_okl_sif_ret_levels_v_rec IN okl_sif_ret_levels_v_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_okl_sif_ret_levels_v_rec  okl_sif_ret_levels_v_rec_type := get_rec(p_okl_sif_ret_levels_v_rec);
  BEGIN
    l_return_status := Validate_Record(p_okl_sif_ret_levels_v_rec => p_okl_sif_ret_levels_v_rec,
                                       p_db_okl_sif_ret_levels_v_rec => l_db_okl_sif_ret_levels_v_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN okl_sif_ret_levels_v_rec_type,
    p_to   IN OUT NOCOPY srl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sir_id := p_from.sir_id;
    p_to.index_number := p_from.index_number;
    p_to.number_of_periods := p_from.number_of_periods;
    p_to.level_index_number := p_from.level_index_number;
    p_to.level_type := p_from.level_type;
    p_to.amount := p_from.amount;
    p_to.advance_or_arrears := p_from.advance_or_arrears;
    p_to.period := p_from.period;
    p_to.lock_level_step := p_from.lock_level_step;
    p_to.days_in_period := p_from.days_in_period;
    p_to.first_payment_date := p_from.first_payment_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.stream_interface_attribute1 := p_from.stream_interface_attribute1;
    p_to.stream_interface_attribute2 := p_from.stream_interface_attribute2;
    p_to.stream_interface_attribute3 := p_from.stream_interface_attribute3;
    p_to.stream_interface_attribute4 := p_from.stream_interface_attribute4;
    p_to.stream_interface_attribute5 := p_from.stream_interface_attribute5;
    p_to.stream_interface_attribute6 := p_from.stream_interface_attribute6;
    p_to.stream_interface_attribute7 := p_from.stream_interface_attribute7;
    p_to.stream_interface_attribute8 := p_from.stream_interface_attribute8;
    p_to.stream_interface_attribute9 := p_from.stream_interface_attribute9;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.rate := p_from.rate; --smahapat 10/12/03
  END migrate;
  PROCEDURE migrate (
    p_from IN srl_rec_type,
    p_to   IN OUT NOCOPY okl_sif_ret_levels_v_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.level_index_number := p_from.level_index_number;
    p_to.number_of_periods := p_from.number_of_periods;
    p_to.sir_id := p_from.sir_id;
    p_to.index_number := p_from.index_number;
    p_to.level_type := p_from.level_type;
    p_to.amount := p_from.amount;
    p_to.advance_or_arrears := p_from.advance_or_arrears;
    p_to.period := p_from.period;
    p_to.lock_level_step := p_from.lock_level_step;
    p_to.days_in_period := p_from.days_in_period;
    p_to.first_payment_date := p_from.first_payment_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.stream_interface_attribute1 := p_from.stream_interface_attribute1;
    p_to.stream_interface_attribute2 := p_from.stream_interface_attribute2;
    p_to.stream_interface_attribute3 := p_from.stream_interface_attribute3;
    p_to.stream_interface_attribute4 := p_from.stream_interface_attribute4;
    p_to.stream_interface_attribute5 := p_from.stream_interface_attribute5;
    p_to.stream_interface_attribute6 := p_from.stream_interface_attribute6;
    p_to.stream_interface_attribute7 := p_from.stream_interface_attribute7;
    p_to.stream_interface_attribute8 := p_from.stream_interface_attribute8;
    p_to.stream_interface_attribute9 := p_from.stream_interface_attribute9;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.rate := p_from.rate; --smahapat 10/12/03
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKL_SIF_RET_LEVELS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_sif_ret_levels_v_rec     okl_sif_ret_levels_v_rec_type := p_okl_sif_ret_levels_v_rec;
    l_srl_rec                      srl_rec_type;
    l_srl_rec                      srl_rec_type;
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
    l_return_status := Validate_Attributes(l_okl_sif_ret_levels_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_okl_sif_ret_levels_v_rec);
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
  -- PL/SQL TBL validate_row for:OKL_SIF_RET_LEVELS_V --
  ------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okl_sif_ret_levels_v_tbl.COUNT > 0) THEN
      i := p_okl_sif_ret_levels_v_tbl.FIRST;
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
            p_okl_sif_ret_levels_v_rec     => p_okl_sif_ret_levels_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okl_sif_ret_levels_v_tbl.LAST);
        i := p_okl_sif_ret_levels_v_tbl.NEXT(i);
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
  -- PL/SQL TBL validate_row for:OKL_SIF_RET_LEVELS_V --
  ------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okl_sif_ret_levels_v_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okl_sif_ret_levels_v_tbl     => p_okl_sif_ret_levels_v_tbl,
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
  ---------------------------------------
  -- insert_row for:OKL_SIF_RET_LEVELS --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srl_rec                      IN srl_rec_type,
    x_srl_rec                      OUT NOCOPY srl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srl_rec                      srl_rec_type := p_srl_rec;
    l_def_srl_rec                  srl_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_LEVELS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_srl_rec IN srl_rec_type,
      x_srl_rec OUT NOCOPY srl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srl_rec := p_srl_rec;
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
      p_srl_rec,                         -- IN
      l_srl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SIF_RET_LEVELS(
      id,
      sir_id,
      index_number,
      number_of_periods,
      level_index_number,
      level_type,
      amount,
      advance_or_arrears,
      period,
      lock_level_step,
      days_in_period,
      first_payment_date,
      object_version_number,
      stream_interface_attribute1,
      stream_interface_attribute2,
      stream_interface_attribute3,
      stream_interface_attribute4,
      stream_interface_attribute5,
      stream_interface_attribute6,
      stream_interface_attribute7,
      stream_interface_attribute8,
      stream_interface_attribute9,
      stream_interface_attribute10,
      stream_interface_attribute11,
      stream_interface_attribute12,
      stream_interface_attribute13,
      stream_interface_attribute14,
      stream_interface_attribute15,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
	  rate) --smahapat 10/12/03
    VALUES (
      l_srl_rec.id,
      l_srl_rec.sir_id,
      l_srl_rec.index_number,
      l_srl_rec.number_of_periods,
      l_srl_rec.level_index_number,
      l_srl_rec.level_type,
      l_srl_rec.amount,
      l_srl_rec.advance_or_arrears,
      l_srl_rec.period,
      l_srl_rec.lock_level_step,
      l_srl_rec.days_in_period,
      l_srl_rec.first_payment_date,
      l_srl_rec.object_version_number,
      l_srl_rec.stream_interface_attribute1,
      l_srl_rec.stream_interface_attribute2,
      l_srl_rec.stream_interface_attribute3,
      l_srl_rec.stream_interface_attribute4,
      l_srl_rec.stream_interface_attribute5,
      l_srl_rec.stream_interface_attribute6,
      l_srl_rec.stream_interface_attribute7,
      l_srl_rec.stream_interface_attribute8,
      l_srl_rec.stream_interface_attribute9,
      l_srl_rec.stream_interface_attribute10,
      l_srl_rec.stream_interface_attribute11,
      l_srl_rec.stream_interface_attribute12,
      l_srl_rec.stream_interface_attribute13,
      l_srl_rec.stream_interface_attribute14,
      l_srl_rec.stream_interface_attribute15,
      l_srl_rec.creation_date,
      l_srl_rec.created_by,
      l_srl_rec.last_update_date,
      l_srl_rec.last_updated_by,
      l_srl_rec.last_update_login,
	  l_srl_rec.rate); --smahapat 10/12/03
    -- Set OUT values
    x_srl_rec := l_srl_rec;
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
  -- insert_row for :OKL_SIF_RET_LEVELS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type,
    x_okl_sif_ret_levels_v_rec     OUT NOCOPY okl_sif_ret_levels_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_sif_ret_levels_v_rec     okl_sif_ret_levels_v_rec_type := p_okl_sif_ret_levels_v_rec;
    l_def_okl_sif_ret_levels_v_rec okl_sif_ret_levels_v_rec_type;
    l_srl_rec                      srl_rec_type;
    lx_srl_rec                     srl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_okl_sif_ret_levels_v_rec IN okl_sif_ret_levels_v_rec_type
    ) RETURN okl_sif_ret_levels_v_rec_type IS
      l_okl_sif_ret_levels_v_rec okl_sif_ret_levels_v_rec_type := p_okl_sif_ret_levels_v_rec;
    BEGIN
      l_okl_sif_ret_levels_v_rec.CREATION_DATE := SYSDATE;
      l_okl_sif_ret_levels_v_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_okl_sif_ret_levels_v_rec.LAST_UPDATE_DATE := l_okl_sif_ret_levels_v_rec.CREATION_DATE;
      l_okl_sif_ret_levels_v_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_okl_sif_ret_levels_v_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_okl_sif_ret_levels_v_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_LEVELS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_sif_ret_levels_v_rec IN okl_sif_ret_levels_v_rec_type,
      x_okl_sif_ret_levels_v_rec OUT NOCOPY okl_sif_ret_levels_v_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_sif_ret_levels_v_rec := p_okl_sif_ret_levels_v_rec;
      x_okl_sif_ret_levels_v_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_okl_sif_ret_levels_v_rec := null_out_defaults(p_okl_sif_ret_levels_v_rec);
    -- Set primary key value
    l_okl_sif_ret_levels_v_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_okl_sif_ret_levels_v_rec,        -- IN
      l_def_okl_sif_ret_levels_v_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_okl_sif_ret_levels_v_rec := fill_who_columns(l_def_okl_sif_ret_levels_v_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_okl_sif_ret_levels_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_okl_sif_ret_levels_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_okl_sif_ret_levels_v_rec, l_srl_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_srl_rec,
      lx_srl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_srl_rec, l_def_okl_sif_ret_levels_v_rec);
    -- Set OUT values
    x_okl_sif_ret_levels_v_rec := l_def_okl_sif_ret_levels_v_rec;
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
  --------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKL_SIF_RET_LEVELS_V_TBL --
  --------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    x_okl_sif_ret_levels_v_tbl     OUT NOCOPY okl_sif_ret_levels_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okl_sif_ret_levels_v_tbl.COUNT > 0) THEN
      i := p_okl_sif_ret_levels_v_tbl.FIRST;
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
            p_okl_sif_ret_levels_v_rec     => p_okl_sif_ret_levels_v_tbl(i),
            x_okl_sif_ret_levels_v_rec     => x_okl_sif_ret_levels_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okl_sif_ret_levels_v_tbl.LAST);
        i := p_okl_sif_ret_levels_v_tbl.NEXT(i);
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

  --------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKL_SIF_RET_LEVELS_V_TBL --
  --------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    x_okl_sif_ret_levels_v_tbl     OUT NOCOPY okl_sif_ret_levels_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okl_sif_ret_levels_v_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okl_sif_ret_levels_v_tbl     => p_okl_sif_ret_levels_v_tbl,
        x_okl_sif_ret_levels_v_tbl     => x_okl_sif_ret_levels_v_tbl,
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
  -------------------------------------
  -- lock_row for:OKL_SIF_RET_LEVELS --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srl_rec                      IN srl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_srl_rec IN srl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_RET_LEVELS
     WHERE ID = p_srl_rec.id
       AND OBJECT_VERSION_NUMBER = p_srl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_srl_rec IN srl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_RET_LEVELS
     WHERE ID = p_srl_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_SIF_RET_LEVELS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_SIF_RET_LEVELS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_srl_rec);
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
      OPEN lchk_csr(p_srl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_srl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_srl_rec.object_version_number THEN
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
  -- lock_row for: OKL_SIF_RET_LEVELS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srl_rec                      srl_rec_type;
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
    migrate(p_okl_sif_ret_levels_v_rec, l_srl_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_srl_rec
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
  ------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKL_SIF_RET_LEVELS_V_TBL --
  ------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_okl_sif_ret_levels_v_tbl.COUNT > 0) THEN
      i := p_okl_sif_ret_levels_v_tbl.FIRST;
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
            p_okl_sif_ret_levels_v_rec     => p_okl_sif_ret_levels_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okl_sif_ret_levels_v_tbl.LAST);
        i := p_okl_sif_ret_levels_v_tbl.NEXT(i);
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
  ------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKL_SIF_RET_LEVELS_V_TBL --
  ------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_okl_sif_ret_levels_v_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okl_sif_ret_levels_v_tbl     => p_okl_sif_ret_levels_v_tbl,
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
  ---------------------------------------
  -- update_row for:OKL_SIF_RET_LEVELS --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srl_rec                      IN srl_rec_type,
    x_srl_rec                      OUT NOCOPY srl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srl_rec                      srl_rec_type := p_srl_rec;
    l_def_srl_rec                  srl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_srl_rec IN srl_rec_type,
      x_srl_rec OUT NOCOPY srl_rec_type
    ) RETURN VARCHAR2 IS
      l_srl_rec                      srl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srl_rec := p_srl_rec;
      -- Get current database values
      l_srl_rec := get_rec(p_srl_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_srl_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.id := l_srl_rec.id;
        END IF;
        IF (x_srl_rec.sir_id = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.sir_id := l_srl_rec.sir_id;
        END IF;
        IF (x_srl_rec.index_number = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.index_number := l_srl_rec.index_number;
        END IF;
        IF (x_srl_rec.number_of_periods = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.number_of_periods := l_srl_rec.number_of_periods;
        END IF;
        IF (x_srl_rec.level_index_number = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.level_index_number := l_srl_rec.level_index_number;
        END IF;
        IF (x_srl_rec.level_type = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.level_type := l_srl_rec.level_type;
        END IF;
        IF (x_srl_rec.amount = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.amount := l_srl_rec.amount;
        END IF;
        IF (x_srl_rec.advance_or_arrears = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.advance_or_arrears := l_srl_rec.advance_or_arrears;
        END IF;
        IF (x_srl_rec.period = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.period := l_srl_rec.period;
        END IF;
        IF (x_srl_rec.lock_level_step = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.lock_level_step := l_srl_rec.lock_level_step;
        END IF;
        IF (x_srl_rec.days_in_period = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.days_in_period := l_srl_rec.days_in_period;
        END IF;
        IF (x_srl_rec.first_payment_date = OKC_API.G_MISS_DATE)
        THEN
          x_srl_rec.first_payment_date := l_srl_rec.first_payment_date;
        END IF;
        IF (x_srl_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.object_version_number := l_srl_rec.object_version_number;
        END IF;
        IF (x_srl_rec.stream_interface_attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute1 := l_srl_rec.stream_interface_attribute1;
        END IF;
        IF (x_srl_rec.stream_interface_attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute2 := l_srl_rec.stream_interface_attribute2;
        END IF;
        IF (x_srl_rec.stream_interface_attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute3 := l_srl_rec.stream_interface_attribute3;
        END IF;
        IF (x_srl_rec.stream_interface_attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute4 := l_srl_rec.stream_interface_attribute4;
        END IF;
        IF (x_srl_rec.stream_interface_attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute5 := l_srl_rec.stream_interface_attribute5;
        END IF;
        IF (x_srl_rec.stream_interface_attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute6 := l_srl_rec.stream_interface_attribute6;
        END IF;
        IF (x_srl_rec.stream_interface_attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute7 := l_srl_rec.stream_interface_attribute7;
        END IF;
        IF (x_srl_rec.stream_interface_attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute8 := l_srl_rec.stream_interface_attribute8;
        END IF;
        IF (x_srl_rec.stream_interface_attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute9 := l_srl_rec.stream_interface_attribute9;
        END IF;
        IF (x_srl_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute10 := l_srl_rec.stream_interface_attribute10;
        END IF;
        IF (x_srl_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute11 := l_srl_rec.stream_interface_attribute11;
        END IF;
        IF (x_srl_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute12 := l_srl_rec.stream_interface_attribute12;
        END IF;
        IF (x_srl_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute13 := l_srl_rec.stream_interface_attribute13;
        END IF;
        IF (x_srl_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute14 := l_srl_rec.stream_interface_attribute14;
        END IF;
        IF (x_srl_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_srl_rec.stream_interface_attribute15 := l_srl_rec.stream_interface_attribute15;
        END IF;
        IF (x_srl_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_srl_rec.creation_date := l_srl_rec.creation_date;
        END IF;
        IF (x_srl_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.created_by := l_srl_rec.created_by;
        END IF;
        IF (x_srl_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_srl_rec.last_update_date := l_srl_rec.last_update_date;
        END IF;
        IF (x_srl_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.last_updated_by := l_srl_rec.last_updated_by;
        END IF;
        IF (x_srl_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.last_update_login := l_srl_rec.last_update_login;
        END IF;
		--smahapat 10/12/03
        IF (x_srl_rec.rate = OKC_API.G_MISS_NUM)
        THEN
          x_srl_rec.rate := l_srl_rec.rate;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_LEVELS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_srl_rec IN srl_rec_type,
      x_srl_rec OUT NOCOPY srl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srl_rec := p_srl_rec;
      x_srl_rec.OBJECT_VERSION_NUMBER := p_srl_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_srl_rec,                         -- IN
      l_srl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_srl_rec, l_def_srl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_SIF_RET_LEVELS
    SET SIR_ID = l_def_srl_rec.sir_id,
        INDEX_NUMBER = l_def_srl_rec.index_number,
        NUMBER_OF_PERIODS = l_def_srl_rec.number_of_periods,
        LEVEL_INDEX_NUMBER = l_def_srl_rec.level_index_number,
        LEVEL_TYPE = l_def_srl_rec.level_type,
        AMOUNT = l_def_srl_rec.amount,
        ADVANCE_OR_ARREARS = l_def_srl_rec.advance_or_arrears,
        PERIOD = l_def_srl_rec.period,
        LOCK_LEVEL_STEP = l_def_srl_rec.lock_level_step,
        DAYS_IN_PERIOD = l_def_srl_rec.days_in_period,
        FIRST_PAYMENT_DATE = l_def_srl_rec.first_payment_date,
        OBJECT_VERSION_NUMBER = l_def_srl_rec.object_version_number,
        STREAM_INTERFACE_ATTRIBUTE1 = l_def_srl_rec.stream_interface_attribute1,
        STREAM_INTERFACE_ATTRIBUTE2 = l_def_srl_rec.stream_interface_attribute2,
        STREAM_INTERFACE_ATTRIBUTE3 = l_def_srl_rec.stream_interface_attribute3,
        STREAM_INTERFACE_ATTRIBUTE4 = l_def_srl_rec.stream_interface_attribute4,
        STREAM_INTERFACE_ATTRIBUTE5 = l_def_srl_rec.stream_interface_attribute5,
        STREAM_INTERFACE_ATTRIBUTE6 = l_def_srl_rec.stream_interface_attribute6,
        STREAM_INTERFACE_ATTRIBUTE7 = l_def_srl_rec.stream_interface_attribute7,
        STREAM_INTERFACE_ATTRIBUTE8 = l_def_srl_rec.stream_interface_attribute8,
        STREAM_INTERFACE_ATTRIBUTE9 = l_def_srl_rec.stream_interface_attribute9,
        STREAM_INTERFACE_ATTRIBUTE10 = l_def_srl_rec.stream_interface_attribute10,
        STREAM_INTERFACE_ATTRIBUTE11 = l_def_srl_rec.stream_interface_attribute11,
        STREAM_INTERFACE_ATTRIBUTE12 = l_def_srl_rec.stream_interface_attribute12,
        STREAM_INTERFACE_ATTRIBUTE13 = l_def_srl_rec.stream_interface_attribute13,
        STREAM_INTERFACE_ATTRIBUTE14 = l_def_srl_rec.stream_interface_attribute14,
        STREAM_INTERFACE_ATTRIBUTE15 = l_def_srl_rec.stream_interface_attribute15,
        CREATION_DATE = l_def_srl_rec.creation_date,
        CREATED_BY = l_def_srl_rec.created_by,
        LAST_UPDATE_DATE = l_def_srl_rec.last_update_date,
        LAST_UPDATED_BY = l_def_srl_rec.last_updated_by,
        LAST_UPDATE_LOGIN = l_def_srl_rec.last_update_login,
        RATE = l_def_srl_rec.rate
    WHERE ID = l_def_srl_rec.id;

    x_srl_rec := l_srl_rec;
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
  -- update_row for:OKL_SIF_RET_LEVELS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type,
    x_okl_sif_ret_levels_v_rec     OUT NOCOPY okl_sif_ret_levels_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_sif_ret_levels_v_rec     okl_sif_ret_levels_v_rec_type := p_okl_sif_ret_levels_v_rec;
    l_def_okl_sif_ret_levels_v_rec okl_sif_ret_levels_v_rec_type;
    l_db_okl_sif_ret_levels_v_rec  okl_sif_ret_levels_v_rec_type;
    l_srl_rec                      srl_rec_type;
    lx_srl_rec                     srl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_okl_sif_ret_levels_v_rec IN okl_sif_ret_levels_v_rec_type
    ) RETURN okl_sif_ret_levels_v_rec_type IS
      l_okl_sif_ret_levels_v_rec okl_sif_ret_levels_v_rec_type := p_okl_sif_ret_levels_v_rec;
    BEGIN
      l_okl_sif_ret_levels_v_rec.LAST_UPDATE_DATE := SYSDATE;
      l_okl_sif_ret_levels_v_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_okl_sif_ret_levels_v_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_okl_sif_ret_levels_v_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_sif_ret_levels_v_rec IN okl_sif_ret_levels_v_rec_type,
      x_okl_sif_ret_levels_v_rec OUT NOCOPY okl_sif_ret_levels_v_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_sif_ret_levels_v_rec := p_okl_sif_ret_levels_v_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_okl_sif_ret_levels_v_rec := get_rec(p_okl_sif_ret_levels_v_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_okl_sif_ret_levels_v_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.id := l_db_okl_sif_ret_levels_v_rec.id;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.level_index_number = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.level_index_number := l_db_okl_sif_ret_levels_v_rec.level_index_number;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.number_of_periods = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.number_of_periods := l_db_okl_sif_ret_levels_v_rec.number_of_periods;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.sir_id = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.sir_id := l_db_okl_sif_ret_levels_v_rec.sir_id;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.index_number = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.index_number := l_db_okl_sif_ret_levels_v_rec.index_number;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.level_type = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.level_type := l_db_okl_sif_ret_levels_v_rec.level_type;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.amount = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.amount := l_db_okl_sif_ret_levels_v_rec.amount;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.advance_or_arrears = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.advance_or_arrears := l_db_okl_sif_ret_levels_v_rec.advance_or_arrears;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.period = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.period := l_db_okl_sif_ret_levels_v_rec.period;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.lock_level_step = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.lock_level_step := l_db_okl_sif_ret_levels_v_rec.lock_level_step;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.days_in_period = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.days_in_period := l_db_okl_sif_ret_levels_v_rec.days_in_period;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.first_payment_date = OKC_API.G_MISS_DATE)
        THEN
          x_okl_sif_ret_levels_v_rec.first_payment_date := l_db_okl_sif_ret_levels_v_rec.first_payment_date;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute1 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute1;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute2 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute2;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute3 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute3;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute4 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute4;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute5 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute5;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute6 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute6;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute7 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute7;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute8 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute8;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute9 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute9;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute10 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute10;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute11 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute11;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute12 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute12;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute13 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute13;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute14 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute14;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_sif_ret_levels_v_rec.stream_interface_attribute15 := l_db_okl_sif_ret_levels_v_rec.stream_interface_attribute15;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_okl_sif_ret_levels_v_rec.creation_date := l_db_okl_sif_ret_levels_v_rec.creation_date;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.created_by := l_db_okl_sif_ret_levels_v_rec.created_by;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okl_sif_ret_levels_v_rec.last_update_date := l_db_okl_sif_ret_levels_v_rec.last_update_date;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.last_updated_by := l_db_okl_sif_ret_levels_v_rec.last_updated_by;
        END IF;
        IF (x_okl_sif_ret_levels_v_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.last_update_login := l_db_okl_sif_ret_levels_v_rec.last_update_login;
        END IF;
        --smahapat 10/12/03
		IF (x_okl_sif_ret_levels_v_rec.rate = OKC_API.G_MISS_NUM)
        THEN
          x_okl_sif_ret_levels_v_rec.rate := l_db_okl_sif_ret_levels_v_rec.rate;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_LEVELS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_sif_ret_levels_v_rec IN okl_sif_ret_levels_v_rec_type,
      x_okl_sif_ret_levels_v_rec OUT NOCOPY okl_sif_ret_levels_v_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_sif_ret_levels_v_rec := p_okl_sif_ret_levels_v_rec;
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
      p_okl_sif_ret_levels_v_rec,        -- IN
      x_okl_sif_ret_levels_v_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_sif_ret_levels_v_rec, l_def_okl_sif_ret_levels_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_okl_sif_ret_levels_v_rec := fill_who_columns(l_def_okl_sif_ret_levels_v_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_okl_sif_ret_levels_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_okl_sif_ret_levels_v_rec, l_db_okl_sif_ret_levels_v_rec);
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
      p_okl_sif_ret_levels_v_rec     => p_okl_sif_ret_levels_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_okl_sif_ret_levels_v_rec, l_srl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_srl_rec,
      lx_srl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_srl_rec, l_def_okl_sif_ret_levels_v_rec);
    x_okl_sif_ret_levels_v_rec := l_def_okl_sif_ret_levels_v_rec;
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
  --------------------------------------------------------
  -- PL/SQL TBL update_row for:okl_sif_ret_levels_v_tbl --
  --------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    x_okl_sif_ret_levels_v_tbl     OUT NOCOPY okl_sif_ret_levels_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okl_sif_ret_levels_v_tbl.COUNT > 0) THEN
      i := p_okl_sif_ret_levels_v_tbl.FIRST;
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
            p_okl_sif_ret_levels_v_rec     => p_okl_sif_ret_levels_v_tbl(i),
            x_okl_sif_ret_levels_v_rec     => x_okl_sif_ret_levels_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okl_sif_ret_levels_v_tbl.LAST);
        i := p_okl_sif_ret_levels_v_tbl.NEXT(i);
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

  --------------------------------------------------------
  -- PL/SQL TBL update_row for:OKL_SIF_RET_LEVELS_V_TBL --
  --------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    x_okl_sif_ret_levels_v_tbl     OUT NOCOPY okl_sif_ret_levels_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okl_sif_ret_levels_v_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okl_sif_ret_levels_v_tbl     => p_okl_sif_ret_levels_v_tbl,
        x_okl_sif_ret_levels_v_tbl     => x_okl_sif_ret_levels_v_tbl,
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
  ---------------------------------------
  -- delete_row for:OKL_SIF_RET_LEVELS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srl_rec                      IN srl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srl_rec                      srl_rec_type := p_srl_rec;
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

    DELETE FROM OKL_SIF_RET_LEVELS
     WHERE ID = p_srl_rec.id;

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
  -- delete_row for:OKL_SIF_RET_LEVELS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_sif_ret_levels_v_rec     okl_sif_ret_levels_v_rec_type := p_okl_sif_ret_levels_v_rec;
    l_srl_rec                      srl_rec_type;
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
    migrate(l_okl_sif_ret_levels_v_rec, l_srl_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_srl_rec
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
  -- PL/SQL TBL delete_row for:OKL_SIF_RET_LEVELS_V --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okl_sif_ret_levels_v_tbl.COUNT > 0) THEN
      i := p_okl_sif_ret_levels_v_tbl.FIRST;
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
            p_okl_sif_ret_levels_v_rec     => p_okl_sif_ret_levels_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okl_sif_ret_levels_v_tbl.LAST);
        i := p_okl_sif_ret_levels_v_tbl.NEXT(i);
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
  -- PL/SQL TBL delete_row for:OKL_SIF_RET_LEVELS_V --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okl_sif_ret_levels_v_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okl_sif_ret_levels_v_tbl     => p_okl_sif_ret_levels_v_tbl,
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

END Okl_Srl_Pvt;

/
