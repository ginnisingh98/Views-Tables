--------------------------------------------------------
--  DDL for Package Body OKL_CIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CIT_PVT" AS
/* $Header: OKLSCITB.pls 120.1 2006/01/05 02:29:08 rkuttiya noship $ */

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
  -- FUNCTION get_rec for: OKL_CONVERT_INT_RATE_REQUEST_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_citv_rec                     IN citv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN citv_rec_type IS
    CURSOR okl_citv_pk_csr (p_trq_id IN NUMBER) IS
    SELECT
            TRQ_ID,
            KHR_ID,
            PARAMETER_TYPE_CODE,
            EFFECTIVE_FROM_DATE,
            EFFECTIVE_TO_DATE,
            MINIMUM_RATE,
            MAXIMUM_RATE,
            BASE_RATE,
            INTEREST_INDEX_ID,
            ADDER_RATE,
            DAYS_IN_A_YEAR_CODE,
            DAYS_IN_A_MONTH_CODE,
            PROPOSED_EFFECTIVE_DATE,
            CONVERSION_DATE,
            VARIABLE_RATE_YN,
            PRINCIPAL_BASIS_CODE,
            INTEREST_BASIS_CODE,
            RATE_DELAY_CODE,
            RATE_DELAY_FREQUENCY,
            COMPOUND_FREQUENCY_CODE,
            CALCULATION_FORMULA_NAME,
            CATCHUP_START_DATE,
            CATCHUP_SETTLEMENT_CODE,
            CATCHUP_BASIS_CODE,
            RATE_CHANGE_START_DATE,
            RATE_CHANGE_FREQUENCY_CODE,
            RATE_CHANGE_VALUE,
            CONVERSION_OPTION_CODE,
            NEXT_CONVERSION_DATE,
            CONVERSION_TYPE_CODE,
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
      FROM Okl_Convert_Int_Rate_Request_V
     WHERE okl_convert_int_rate_request_v.trq_id = p_trq_id;
    l_okl_citv_pk                  okl_citv_pk_csr%ROWTYPE;
    l_citv_rec                     citv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_citv_pk_csr (p_citv_rec.trq_id);
    FETCH okl_citv_pk_csr INTO
              l_citv_rec.trq_id,
              l_citv_rec.khr_id,
              l_citv_rec.parameter_type_code,
              l_citv_rec.effective_from_date,
              l_citv_rec.effective_to_date,
              l_citv_rec.minimum_rate,
              l_citv_rec.maximum_rate,
              l_citv_rec.base_rate,
              l_citv_rec.interest_index_id,
              l_citv_rec.adder_rate,
              l_citv_rec.days_in_a_year_code,
              l_citv_rec.days_in_a_month_code,
              l_citv_rec.proposed_effective_date,
              l_citv_rec.conversion_date,
              l_citv_rec.variable_rate_yn,
              l_citv_rec.principal_basis_code,
              l_citv_rec.interest_basis_code,
              l_citv_rec.rate_delay_code,
              l_citv_rec.rate_delay_frequency,
              l_citv_rec.compound_frequency_code,
              l_citv_rec.calculation_formula_name,
              l_citv_rec.catchup_start_date,
              l_citv_rec.catchup_settlement_code,
              l_citv_rec.catchup_basis_code,
              l_citv_rec.rate_change_start_date,
              l_citv_rec.rate_change_frequency_code,
              l_citv_rec.rate_change_value,
              l_citv_rec.conversion_option_code,
              l_citv_rec.next_conversion_date,
              l_citv_rec.conversion_type_code,
              l_citv_rec.attribute1,
              l_citv_rec.attribute2,
              l_citv_rec.attribute3,
              l_citv_rec.attribute4,
              l_citv_rec.attribute5,
              l_citv_rec.attribute6,
              l_citv_rec.attribute7,
              l_citv_rec.attribute8,
              l_citv_rec.attribute9,
              l_citv_rec.attribute10,
              l_citv_rec.attribute11,
              l_citv_rec.attribute12,
              l_citv_rec.attribute13,
              l_citv_rec.attribute14,
              l_citv_rec.attribute15,
              l_citv_rec.created_by,
              l_citv_rec.creation_date,
              l_citv_rec.last_updated_by,
              l_citv_rec.last_update_date,
              l_citv_rec.last_update_login;
    x_no_data_found := okl_citv_pk_csr%NOTFOUND;
    CLOSE okl_citv_pk_csr;
    RETURN(l_citv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_citv_rec                     IN citv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN citv_rec_type IS
    l_citv_rec                     citv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_citv_rec := get_rec(p_citv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'TRQ_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_citv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_citv_rec                     IN citv_rec_type
  ) RETURN citv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_citv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CONVERT_INT_RATE_REQUEST
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cit_rec                      IN cit_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cit_rec_type IS
    CURSOR okl_cit_pk_csr (p_trq_id IN NUMBER) IS
    SELECT
            TRQ_ID,
            KHR_ID,
            PARAMETER_TYPE_CODE,
            EFFECTIVE_FROM_DATE,
            EFFECTIVE_TO_DATE,
            MINIMUM_RATE,
            MAXIMUM_RATE,
            BASE_RATE,
            INTEREST_INDEX_ID,
            ADDER_RATE,
            DAYS_IN_A_YEAR_CODE,
            DAYS_IN_A_MONTH_CODE,
            PROPOSED_EFFECTIVE_DATE,
            CONVERSION_DATE,
            VARIABLE_RATE_YN,
            PRINCIPAL_BASIS_CODE,
            INTEREST_BASIS_CODE,
            RATE_DELAY_CODE,
            RATE_DELAY_FREQUENCY,
            COMPOUND_FREQUENCY_CODE,
            CALCULATION_FORMULA_NAME,
            CATCHUP_START_DATE,
            CATCHUP_SETTLEMENT_CODE,
            CATCHUP_BASIS_CODE,
            RATE_CHANGE_START_DATE,
            RATE_CHANGE_FREQUENCY_CODE,
            RATE_CHANGE_VALUE,
            CONVERSION_OPTION_CODE,
            NEXT_CONVERSION_DATE,
            CONVERSION_TYPE_CODE,
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
      FROM Okl_Convert_Int_Rate_Request
     WHERE okl_convert_int_rate_request.trq_id = p_trq_id;
    l_okl_cit_pk                   okl_cit_pk_csr%ROWTYPE;
    l_cit_rec                      cit_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cit_pk_csr (p_cit_rec.trq_id);
    FETCH okl_cit_pk_csr INTO
              l_cit_rec.trq_id,
              l_cit_rec.khr_id,
              l_cit_rec.parameter_type_code,
              l_cit_rec.effective_from_date,
              l_cit_rec.effective_to_date,
              l_cit_rec.minimum_rate,
              l_cit_rec.maximum_rate,
              l_cit_rec.base_rate,
              l_cit_rec.interest_index_id,
              l_cit_rec.adder_rate,
              l_cit_rec.days_in_a_year_code,
              l_cit_rec.days_in_a_month_code,
              l_cit_rec.proposed_effective_date,
              l_cit_rec.conversion_date,
              l_cit_rec.variable_rate_yn,
              l_cit_rec.principal_basis_code,
              l_cit_rec.interest_basis_code,
              l_cit_rec.rate_delay_code,
              l_cit_rec.rate_delay_frequency,
              l_cit_rec.compound_frequency_code,
              l_cit_rec.calculation_formula_name,
              l_cit_rec.catchup_start_date,
              l_cit_rec.catchup_settlement_code,
              l_cit_rec.catchup_basis_code,
              l_cit_rec.rate_change_start_date,
              l_cit_rec.rate_change_frequency_code,
              l_cit_rec.rate_change_value,
              l_cit_rec.conversion_option_code,
              l_cit_rec.next_conversion_date,
              l_cit_rec.conversion_type_code,
              l_cit_rec.attribute1,
              l_cit_rec.attribute2,
              l_cit_rec.attribute3,
              l_cit_rec.attribute4,
              l_cit_rec.attribute5,
              l_cit_rec.attribute6,
              l_cit_rec.attribute7,
              l_cit_rec.attribute8,
              l_cit_rec.attribute9,
              l_cit_rec.attribute10,
              l_cit_rec.attribute11,
              l_cit_rec.attribute12,
              l_cit_rec.attribute13,
              l_cit_rec.attribute14,
              l_cit_rec.attribute15,
              l_cit_rec.created_by,
              l_cit_rec.creation_date,
              l_cit_rec.last_updated_by,
              l_cit_rec.last_update_date,
              l_cit_rec.last_update_login;
    x_no_data_found := okl_cit_pk_csr%NOTFOUND;
    CLOSE okl_cit_pk_csr;
    RETURN(l_cit_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_cit_rec                      IN cit_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN cit_rec_type IS
    l_cit_rec                      cit_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_cit_rec := get_rec(p_cit_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'TRQ_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_cit_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_cit_rec                      IN cit_rec_type
  ) RETURN cit_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cit_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CONVERT_INT_RATE_REQUEST_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_citv_rec   IN citv_rec_type
  ) RETURN citv_rec_type IS
    l_citv_rec                     citv_rec_type := p_citv_rec;
  BEGIN
    IF (l_citv_rec.trq_id = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.trq_id := NULL;
    END IF;
    IF (l_citv_rec.khr_id = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.khr_id := NULL;
    END IF;
    IF (l_citv_rec.parameter_type_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.parameter_type_code := NULL;
    END IF;
    IF (l_citv_rec.effective_from_date = OKC_API.G_MISS_DATE ) THEN
      l_citv_rec.effective_from_date := NULL;
    END IF;
    IF (l_citv_rec.effective_to_date = OKC_API.G_MISS_DATE ) THEN
      l_citv_rec.effective_to_date := NULL;
    END IF;
    IF (l_citv_rec.minimum_rate = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.minimum_rate := NULL;
    END IF;
    IF (l_citv_rec.maximum_rate = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.maximum_rate := NULL;
    END IF;
    IF (l_citv_rec.base_rate = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.base_rate := NULL;
    END IF;
    IF (l_citv_rec.interest_index_id = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.interest_index_id := NULL;
    END IF;
    IF (l_citv_rec.adder_rate = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.adder_rate := NULL;
    END IF;
    IF (l_citv_rec.days_in_a_year_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.days_in_a_year_code := NULL;
    END IF;
    IF (l_citv_rec.days_in_a_month_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.days_in_a_month_code := NULL;
    END IF;
    IF (l_citv_rec.proposed_effective_date = OKC_API.G_MISS_DATE ) THEN
      l_citv_rec.proposed_effective_date := NULL;
    END IF;
    IF (l_citv_rec.conversion_date = OKC_API.G_MISS_DATE ) THEN
      l_citv_rec.conversion_date := NULL;
    END IF;
    IF (l_citv_rec.variable_rate_yn = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.variable_rate_yn := NULL;
    END IF;
    IF (l_citv_rec.principal_basis_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.principal_basis_code := NULL;
    END IF;
    IF (l_citv_rec.interest_basis_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.interest_basis_code := NULL;
    END IF;
    IF (l_citv_rec.rate_delay_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.rate_delay_code := NULL;
    END IF;
    IF (l_citv_rec.rate_delay_frequency = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.rate_delay_frequency := NULL;
    END IF;
    IF (l_citv_rec.compound_frequency_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.compound_frequency_code := NULL;
    END IF;
    IF (l_citv_rec.calculation_formula_name = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.calculation_formula_name := NULL;
    END IF;
    IF (l_citv_rec.catchup_start_date = OKC_API.G_MISS_DATE ) THEN
      l_citv_rec.catchup_start_date := NULL;
    END IF;
    IF (l_citv_rec.catchup_settlement_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.catchup_settlement_code := NULL;
    END IF;
    IF (l_citv_rec.catchup_basis_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.catchup_basis_code := NULL;
    END IF;
    IF (l_citv_rec.rate_change_start_date = OKC_API.G_MISS_DATE ) THEN
      l_citv_rec.rate_change_start_date := NULL;
    END IF;
    IF (l_citv_rec.rate_change_frequency_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.rate_change_frequency_code := NULL;
    END IF;
    IF (l_citv_rec.rate_change_value = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.rate_change_value := NULL;
    END IF;
    IF (l_citv_rec.conversion_option_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.conversion_option_code := NULL;
    END IF;
    IF (l_citv_rec.next_conversion_date = OKC_API.G_MISS_DATE ) THEN
      l_citv_rec.next_conversion_date := NULL;
    END IF;
    IF (l_citv_rec.conversion_type_code = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.conversion_type_code := NULL;
    END IF;
    IF (l_citv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute1 := NULL;
    END IF;
    IF (l_citv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute2 := NULL;
    END IF;
    IF (l_citv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute3 := NULL;
    END IF;
    IF (l_citv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute4 := NULL;
    END IF;
    IF (l_citv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute5 := NULL;
    END IF;
    IF (l_citv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute6 := NULL;
    END IF;
    IF (l_citv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute7 := NULL;
    END IF;
    IF (l_citv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute8 := NULL;
    END IF;
    IF (l_citv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute9 := NULL;
    END IF;
    IF (l_citv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute10 := NULL;
    END IF;
    IF (l_citv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute11 := NULL;
    END IF;
    IF (l_citv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute12 := NULL;
    END IF;
    IF (l_citv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute13 := NULL;
    END IF;
    IF (l_citv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute14 := NULL;
    END IF;
    IF (l_citv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_citv_rec.attribute15 := NULL;
    END IF;
    IF (l_citv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.created_by := NULL;
    END IF;
    IF (l_citv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_citv_rec.creation_date := NULL;
    END IF;
    IF (l_citv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.last_updated_by := NULL;
    END IF;
    IF (l_citv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_citv_rec.last_update_date := NULL;
    END IF;
    IF (l_citv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_citv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_citv_rec);
  END null_out_defaults;
  -------------------------------------
  -- Validate_Attributes for: TRQ_ID --
  -------------------------------------
  PROCEDURE validate_trq_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trq_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_trq_id = OKC_API.G_MISS_NUM OR
        p_trq_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trq_id');
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
  END validate_trq_id;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------------------
  -- Validate_Attributes for:OKL_CONVERT_INT_RATE_REQUEST_V --
  ------------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_citv_rec                     IN citv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- trq_id
    -- ***
    validate_trq_id(x_return_status, p_citv_rec.trq_id);
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
  --------------------------------------------------------
  -- Validate Record for:OKL_CONVERT_INT_RATE_REQUEST_V --
  --------------------------------------------------------
  FUNCTION Validate_Record (
    p_citv_rec IN citv_rec_type,
    p_db_citv_rec IN citv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_citv_rec IN citv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_citv_rec                  citv_rec_type := get_rec(p_citv_rec);
  BEGIN
    l_return_status := Validate_Record(p_citv_rec => p_citv_rec,
                                       p_db_citv_rec => l_db_citv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN citv_rec_type,
    p_to   IN OUT NOCOPY cit_rec_type
  ) IS
  BEGIN
    p_to.trq_id := p_from.trq_id;
    p_to.khr_id := p_from.khr_id;
    p_to.parameter_type_code := p_from.parameter_type_code;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.minimum_rate := p_from.minimum_rate;
    p_to.maximum_rate := p_from.maximum_rate;
    p_to.base_rate := p_from.base_rate;
    p_to.interest_index_id := p_from.interest_index_id;
    p_to.adder_rate := p_from.adder_rate;
    p_to.days_in_a_year_code := p_from.days_in_a_year_code;
    p_to.days_in_a_month_code := p_from.days_in_a_month_code;
    p_to.proposed_effective_date := p_from.proposed_effective_date;
    p_to.conversion_date := p_from.conversion_date;
    p_to.variable_rate_yn := p_from.variable_rate_yn;
    p_to.principal_basis_code := p_from.principal_basis_code;
    p_to.interest_basis_code := p_from.interest_basis_code;
    p_to.rate_delay_code := p_from.rate_delay_code;
    p_to.rate_delay_frequency := p_from.rate_delay_frequency;
    p_to.compound_frequency_code := p_from.compound_frequency_code;
    p_to.calculation_formula_name := p_from.calculation_formula_name;
    p_to.catchup_start_date := p_from.catchup_start_date;
    p_to.catchup_settlement_code := p_from.catchup_settlement_code;
    p_to.catchup_basis_code      := p_from.catchup_basis_code;
    p_to.rate_change_start_date := p_from.rate_change_start_date;
    p_to.rate_change_frequency_code := p_from.rate_change_frequency_code;
    p_to.rate_change_value := p_from.rate_change_value;
    p_to.conversion_option_code := p_from.conversion_option_code;
    p_to.next_conversion_date   := p_from.next_conversion_date;
    p_to.conversion_type_code   := p_from.conversion_type_code;
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
    p_from IN cit_rec_type,
    p_to   IN OUT NOCOPY citv_rec_type
  ) IS
  BEGIN
    p_to.trq_id := p_from.trq_id;
    p_to.khr_id := p_from.khr_id;
    p_to.parameter_type_code := p_from.parameter_type_code;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.minimum_rate := p_from.minimum_rate;
    p_to.maximum_rate := p_from.maximum_rate;
    p_to.base_rate := p_from.base_rate;
    p_to.interest_index_id := p_from.interest_index_id;
    p_to.adder_rate := p_from.adder_rate;
    p_to.days_in_a_year_code := p_from.days_in_a_year_code;
    p_to.days_in_a_month_code := p_from.days_in_a_month_code;
    p_to.proposed_effective_date := p_from.proposed_effective_date;
    p_to.conversion_date := p_from.conversion_date;
    p_to.variable_rate_yn := p_from.variable_rate_yn;
    p_to.principal_basis_code := p_from.principal_basis_code;
    p_to.interest_basis_code := p_from.interest_basis_code;
    p_to.rate_delay_code := p_from.rate_delay_code;
    p_to.rate_delay_frequency := p_from.rate_delay_frequency;
    p_to.compound_frequency_code := p_from.compound_frequency_code;
    p_to.calculation_formula_name := p_from.calculation_formula_name;
    p_to.catchup_start_date := p_from.catchup_start_date;
    p_to.catchup_settlement_code := p_from.catchup_settlement_code;
    p_to.catchup_basis_code      := p_from.catchup_basis_code;
    p_to.rate_change_start_date := p_from.rate_change_start_date;
    p_to.rate_change_frequency_code := p_from.rate_change_frequency_code;
    p_to.rate_change_value := p_from.rate_change_value;
    p_to.conversion_option_code := p_from.conversion_option_code;
    p_to.next_conversion_date   := p_from.next_conversion_date;
    p_to.conversion_type_code   := p_from.conversion_type_code;
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
  -----------------------------------------------------
  -- validate_row for:OKL_CONVERT_INT_RATE_REQUEST_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_rec                     IN citv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_citv_rec                     citv_rec_type := p_citv_rec;
    l_cit_rec                      cit_rec_type;
    l_cit_rec                      cit_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'S',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_citv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_citv_rec);
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
  ----------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CONVERT_INT_RATE_REQUEST_V --
  ----------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_citv_tbl.COUNT > 0) THEN
      i := p_citv_tbl.FIRST;
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
            p_citv_rec                     => p_citv_tbl(i));
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
        EXIT WHEN (i = p_citv_tbl.LAST);
        i := p_citv_tbl.NEXT(i);
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

  ----------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CONVERT_INT_RATE_REQUEST_V --
  ----------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_citv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_citv_tbl                     => p_citv_tbl,
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
  -------------------------------------------------
  -- insert_row for:OKL_CONVERT_INT_RATE_REQUEST --
  -------------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cit_rec                      IN cit_rec_type,
    x_cit_rec                      OUT NOCOPY cit_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cit_rec                      cit_rec_type := p_cit_rec;
    l_def_cit_rec                  cit_rec_type;
    -----------------------------------------------------
    -- Set_Attributes for:OKL_CONVERT_INT_RATE_REQUEST --
    -----------------------------------------------------
    FUNCTION Set_Attributes (
      p_cit_rec IN cit_rec_type,
      x_cit_rec OUT NOCOPY cit_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cit_rec := p_cit_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'S',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_cit_rec,                         -- IN
      l_cit_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CONVERT_INT_RATE_REQUEST(
      trq_id,
      khr_id,
      parameter_type_code,
      effective_from_date,
      effective_to_date,
      minimum_rate,
      maximum_rate,
      base_rate,
      interest_index_id,
      adder_rate,
      days_in_a_year_code,
      days_in_a_month_code,
      proposed_effective_date,
      conversion_date,
      variable_rate_yn,
      principal_basis_code,
      interest_basis_code,
      rate_delay_code,
      rate_delay_frequency,
      compound_frequency_code,
      calculation_formula_name,
      catchup_start_date,
      catchup_settlement_code,
      catchup_basis_code,
      rate_change_start_date,
      rate_change_frequency_code,
      rate_change_value,
      conversion_option_code,
      next_conversion_date,
      conversion_type_code,
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
      l_cit_rec.trq_id,
      l_cit_rec.khr_id,
      l_cit_rec.parameter_type_code,
      l_cit_rec.effective_from_date,
      l_cit_rec.effective_to_date,
      l_cit_rec.minimum_rate,
      l_cit_rec.maximum_rate,
      l_cit_rec.base_rate,
      l_cit_rec.interest_index_id,
      l_cit_rec.adder_rate,
      l_cit_rec.days_in_a_year_code,
      l_cit_rec.days_in_a_month_code,
      l_cit_rec.proposed_effective_date,
      l_cit_rec.conversion_date,
      l_cit_rec.variable_rate_yn,
      l_cit_rec.principal_basis_code,
      l_cit_rec.interest_basis_code,
      l_cit_rec.rate_delay_code,
      l_cit_rec.rate_delay_frequency,
      l_cit_rec.compound_frequency_code,
      l_cit_rec.calculation_formula_name,
      l_cit_rec.catchup_start_date,
      l_cit_rec.catchup_settlement_code,
      l_cit_rec.catchup_basis_code,
      l_cit_rec.rate_change_start_date,
      l_cit_rec.rate_change_frequency_code,
      l_cit_rec.rate_change_value,
      l_cit_rec.conversion_option_code,
      l_cit_rec.next_conversion_date,
      l_cit_rec.conversion_type_code,
      l_cit_rec.attribute1,
      l_cit_rec.attribute2,
      l_cit_rec.attribute3,
      l_cit_rec.attribute4,
      l_cit_rec.attribute5,
      l_cit_rec.attribute6,
      l_cit_rec.attribute7,
      l_cit_rec.attribute8,
      l_cit_rec.attribute9,
      l_cit_rec.attribute10,
      l_cit_rec.attribute11,
      l_cit_rec.attribute12,
      l_cit_rec.attribute13,
      l_cit_rec.attribute14,
      l_cit_rec.attribute15,
      l_cit_rec.created_by,
      l_cit_rec.creation_date,
      l_cit_rec.last_updated_by,
      l_cit_rec.last_update_date,
      l_cit_rec.last_update_login);
    -- Set OUT values
    x_cit_rec := l_cit_rec;
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
  ----------------------------------------------------
  -- insert_row for :OKL_CONVERT_INT_RATE_REQUEST_V --
  ----------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_rec                     IN citv_rec_type,
    x_citv_rec                     OUT NOCOPY citv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_citv_rec                     citv_rec_type := p_citv_rec;
    l_def_citv_rec                 citv_rec_type;
    l_cit_rec                      cit_rec_type;
    lx_cit_rec                     cit_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_citv_rec IN citv_rec_type
    ) RETURN citv_rec_type IS
      l_citv_rec citv_rec_type := p_citv_rec;
    BEGIN
      l_citv_rec.CREATION_DATE := SYSDATE;
      l_citv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_citv_rec.LAST_UPDATE_DATE := l_citv_rec.CREATION_DATE;
      l_citv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_citv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_citv_rec);
    END fill_who_columns;
    -------------------------------------------------------
    -- Set_Attributes for:OKL_CONVERT_INT_RATE_REQUEST_V --
    -------------------------------------------------------
    FUNCTION Set_Attributes (
      p_citv_rec IN citv_rec_type,
      x_citv_rec OUT NOCOPY citv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_citv_rec := p_citv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'S',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_citv_rec := null_out_defaults(p_citv_rec);
  --not required
    -- Set primary key value
   -- l_citv_rec.TRQ_ID := get_seq_id;

    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_citv_rec,                        -- IN
      l_def_citv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_citv_rec := fill_who_columns(l_def_citv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_citv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_citv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_citv_rec, l_cit_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cit_rec,
      lx_cit_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cit_rec, l_def_citv_rec);
    -- Set OUT values
    x_citv_rec := l_def_citv_rec;
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
  -- PL/SQL TBL insert_row for:CITV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    x_citv_tbl                     OUT NOCOPY citv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_citv_tbl.COUNT > 0) THEN
      i := p_citv_tbl.FIRST;
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
            p_citv_rec                     => p_citv_tbl(i),
            x_citv_rec                     => x_citv_tbl(i));
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
        EXIT WHEN (i = p_citv_tbl.LAST);
        i := p_citv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:CITV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    x_citv_tbl                     OUT NOCOPY citv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_citv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_citv_tbl                     => p_citv_tbl,
        x_citv_tbl                     => x_citv_tbl,
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
  -----------------------------------------------
  -- lock_row for:OKL_CONVERT_INT_RATE_REQUEST --
  -----------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cit_rec                      IN cit_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cit_rec IN cit_rec_type) IS
    SELECT *
      FROM OKL_CONVERT_INT_RATE_REQUEST
     WHERE TRQ_ID = p_cit_rec.trq_id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'S',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_cit_rec);
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
    ELSE
      IF (l_lock_var.trq_id <> p_cit_rec.trq_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.khr_id <> p_cit_rec.khr_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.parameter_type_code <> p_cit_rec.parameter_type_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.effective_from_date <> p_cit_rec.effective_from_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.effective_to_date <> p_cit_rec.effective_to_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.minimum_rate <> p_cit_rec.minimum_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.maximum_rate <> p_cit_rec.maximum_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.base_rate <> p_cit_rec.base_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.interest_index_id <> p_cit_rec.interest_index_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.adder_rate <> p_cit_rec.adder_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.days_in_a_year_code <> p_cit_rec.days_in_a_year_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.days_in_a_month_code <> p_cit_rec.days_in_a_month_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.proposed_effective_date <> p_cit_rec.proposed_effective_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.conversion_date <> p_cit_rec.conversion_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.variable_rate_yn <> p_cit_rec.variable_rate_yn) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.principal_basis_code <> p_cit_rec.principal_basis_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.interest_basis_code <> p_cit_rec.interest_basis_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rate_delay_code <> p_cit_rec.rate_delay_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rate_delay_frequency <> p_cit_rec.rate_delay_frequency) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.compound_frequency_code <> p_cit_rec.compound_frequency_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.calculation_formula_name <> p_cit_rec.calculation_formula_name) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.catchup_start_date <> p_cit_rec.catchup_start_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.catchup_settlement_code <> p_cit_rec.catchup_settlement_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.catchup_basis_code <> p_cit_rec.catchup_basis_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rate_change_start_date <> p_cit_rec.rate_change_start_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rate_change_frequency_code <> p_cit_rec.rate_change_frequency_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rate_change_value <> p_cit_rec.rate_change_value) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.conversion_option_code <> p_cit_rec.conversion_option_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.next_conversion_date <> p_cit_rec.next_conversion_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.conversion_type_code <> p_cit_rec.conversion_type_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute1 <> p_cit_rec.attribute1) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute2 <> p_cit_rec.attribute2) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute3 <> p_cit_rec.attribute3) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute4 <> p_cit_rec.attribute4) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute5 <> p_cit_rec.attribute5) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute6 <> p_cit_rec.attribute6) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute7 <> p_cit_rec.attribute7) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute8 <> p_cit_rec.attribute8) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute9 <> p_cit_rec.attribute9) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute10 <> p_cit_rec.attribute10) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute11 <> p_cit_rec.attribute11) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute12 <> p_cit_rec.attribute12) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute13 <> p_cit_rec.attribute13) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute14 <> p_cit_rec.attribute14) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute15 <> p_cit_rec.attribute15) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.created_by <> p_cit_rec.created_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.creation_date <> p_cit_rec.creation_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_updated_by <> p_cit_rec.last_updated_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_date <> p_cit_rec.last_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_login <> p_cit_rec.last_update_login) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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
  --------------------------------------------------
  -- lock_row for: OKL_CONVERT_INT_RATE_REQUEST_V --
  --------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_rec                     IN citv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cit_rec                      cit_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'S',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_citv_rec, l_cit_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cit_rec
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
  -- PL/SQL TBL lock_row for:CITV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_citv_tbl.COUNT > 0) THEN
      i := p_citv_tbl.FIRST;
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
            p_citv_rec                     => p_citv_tbl(i));
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
        EXIT WHEN (i = p_citv_tbl.LAST);
        i := p_citv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:CITV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_citv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_citv_tbl                     => p_citv_tbl,
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
  -------------------------------------------------
  -- update_row for:OKL_CONVERT_INT_RATE_REQUEST --
  -------------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cit_rec                      IN cit_rec_type,
    x_cit_rec                      OUT NOCOPY cit_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cit_rec                      cit_rec_type := p_cit_rec;
    l_def_cit_rec                  cit_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cit_rec IN cit_rec_type,
      x_cit_rec OUT NOCOPY cit_rec_type
    ) RETURN VARCHAR2 IS
      l_cit_rec                      cit_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cit_rec := p_cit_rec;
      -- Get current database values
      l_cit_rec := get_rec(p_cit_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_cit_rec.trq_id = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.trq_id := l_cit_rec.trq_id;
        END IF;
        IF (x_cit_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.khr_id := l_cit_rec.khr_id;
        END IF;
        IF (x_cit_rec.parameter_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.parameter_type_code := l_cit_rec.parameter_type_code;
        END IF;
        IF (x_cit_rec.effective_from_date = OKC_API.G_MISS_DATE)
        THEN
          x_cit_rec.effective_from_date := l_cit_rec.effective_from_date;
        END IF;
        IF (x_cit_rec.effective_to_date = OKC_API.G_MISS_DATE)
        THEN
          x_cit_rec.effective_to_date := l_cit_rec.effective_to_date;
        END IF;
        IF (x_cit_rec.minimum_rate = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.minimum_rate := l_cit_rec.minimum_rate;
        END IF;
        IF (x_cit_rec.maximum_rate = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.maximum_rate := l_cit_rec.maximum_rate;
        END IF;
        IF (x_cit_rec.base_rate = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.base_rate := l_cit_rec.base_rate;
        END IF;
        IF (x_cit_rec.interest_index_id = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.interest_index_id := l_cit_rec.interest_index_id;
        END IF;
        IF (x_cit_rec.adder_rate = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.adder_rate := l_cit_rec.adder_rate;
        END IF;
        IF (x_cit_rec.days_in_a_year_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.days_in_a_year_code := l_cit_rec.days_in_a_year_code;
        END IF;
        IF (x_cit_rec.days_in_a_month_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.days_in_a_month_code := l_cit_rec.days_in_a_month_code;
        END IF;
        IF (x_cit_rec.proposed_effective_date = OKC_API.G_MISS_DATE)
        THEN
          x_cit_rec.proposed_effective_date := l_cit_rec.proposed_effective_date;
        END IF;
        IF (x_cit_rec.conversion_date = OKC_API.G_MISS_DATE)
        THEN
          x_cit_rec.conversion_date := l_cit_rec.conversion_date;
        END IF;
        IF (x_cit_rec.variable_rate_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.variable_rate_yn := l_cit_rec.variable_rate_yn;
        END IF;
        IF (x_cit_rec.principal_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.principal_basis_code := l_cit_rec.principal_basis_code;
        END IF;
        IF (x_cit_rec.interest_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.interest_basis_code := l_cit_rec.interest_basis_code;
        END IF;
        IF (x_cit_rec.rate_delay_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.rate_delay_code := l_cit_rec.rate_delay_code;
        END IF;
        IF (x_cit_rec.rate_delay_frequency = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.rate_delay_frequency := l_cit_rec.rate_delay_frequency;
        END IF;
        IF (x_cit_rec.compound_frequency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.compound_frequency_code := l_cit_rec.compound_frequency_code;
        END IF;
        IF (x_cit_rec.calculation_formula_name = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.calculation_formula_name := l_cit_rec.calculation_formula_name;
        END IF;
        IF (x_cit_rec.catchup_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_cit_rec.catchup_start_date := l_cit_rec.catchup_start_date;
        END IF;
        IF (x_cit_rec.catchup_settlement_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.catchup_settlement_code := l_cit_rec.catchup_settlement_code;
        END IF;
        IF (x_cit_rec.catchup_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.catchup_basis_code := l_cit_rec.catchup_basis_code;
        END IF;
        IF (x_cit_rec.rate_change_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_cit_rec.rate_change_start_date := l_cit_rec.rate_change_start_date;
        END IF;
        IF (x_cit_rec.rate_change_frequency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.rate_change_frequency_code := l_cit_rec.rate_change_frequency_code;
        END IF;
        IF (x_cit_rec.rate_change_value = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.rate_change_value := l_cit_rec.rate_change_value;
        END IF;
        IF (x_cit_rec.conversion_option_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.conversion_option_code := l_cit_rec.conversion_option_code;
        END IF;
        IF (x_cit_rec.next_conversion_date = OKC_API.G_MISS_DATE)
        THEN
          x_cit_rec.next_conversion_date := l_cit_rec.next_conversion_date;
        END IF;
        IF (x_cit_rec.conversion_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.conversion_type_code := l_cit_rec.conversion_type_code;
        END IF;
        IF (x_cit_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute1 := l_cit_rec.attribute1;
        END IF;
        IF (x_cit_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute2 := l_cit_rec.attribute2;
        END IF;
        IF (x_cit_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute3 := l_cit_rec.attribute3;
        END IF;
        IF (x_cit_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute4 := l_cit_rec.attribute4;
        END IF;
        IF (x_cit_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute5 := l_cit_rec.attribute5;
        END IF;
        IF (x_cit_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute6 := l_cit_rec.attribute6;
        END IF;
        IF (x_cit_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute7 := l_cit_rec.attribute7;
        END IF;
        IF (x_cit_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute8 := l_cit_rec.attribute8;
        END IF;
        IF (x_cit_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute9 := l_cit_rec.attribute9;
        END IF;
        IF (x_cit_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute10 := l_cit_rec.attribute10;
        END IF;
        IF (x_cit_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute11 := l_cit_rec.attribute11;
        END IF;
        IF (x_cit_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute12 := l_cit_rec.attribute12;
        END IF;
        IF (x_cit_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute13 := l_cit_rec.attribute13;
        END IF;
        IF (x_cit_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute14 := l_cit_rec.attribute14;
        END IF;
        IF (x_cit_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_cit_rec.attribute15 := l_cit_rec.attribute15;
        END IF;
        IF (x_cit_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.created_by := l_cit_rec.created_by;
        END IF;
        IF (x_cit_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_cit_rec.creation_date := l_cit_rec.creation_date;
        END IF;
        IF (x_cit_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.last_updated_by := l_cit_rec.last_updated_by;
        END IF;
        IF (x_cit_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_cit_rec.last_update_date := l_cit_rec.last_update_date;
        END IF;
        IF (x_cit_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_cit_rec.last_update_login := l_cit_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------------
    -- Set_Attributes for:OKL_CONVERT_INT_RATE_REQUEST --
    -----------------------------------------------------
    FUNCTION Set_Attributes (
      p_cit_rec IN cit_rec_type,
      x_cit_rec OUT NOCOPY cit_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cit_rec := p_cit_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'S',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cit_rec,                         -- IN
      l_cit_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cit_rec, l_def_cit_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CONVERT_INT_RATE_REQUEST
    SET KHR_ID = l_def_cit_rec.khr_id,
        PARAMETER_TYPE_CODE = l_def_cit_rec.parameter_type_code,
        EFFECTIVE_FROM_DATE = l_def_cit_rec.effective_from_date,
        EFFECTIVE_TO_DATE = l_def_cit_rec.effective_to_date,
        MINIMUM_RATE = l_def_cit_rec.minimum_rate,
        MAXIMUM_RATE = l_def_cit_rec.maximum_rate,
        BASE_RATE = l_def_cit_rec.base_rate,
        INTEREST_INDEX_ID = l_def_cit_rec.interest_index_id,
        ADDER_RATE = l_def_cit_rec.adder_rate,
        DAYS_IN_A_YEAR_CODE = l_def_cit_rec.days_in_a_year_code,
        DAYS_IN_A_MONTH_CODE = l_def_cit_rec.days_in_a_month_code,
        PROPOSED_EFFECTIVE_DATE = l_def_cit_rec.proposed_effective_date,
        CONVERSION_DATE = l_def_cit_rec.conversion_date,
        VARIABLE_RATE_YN = l_def_cit_rec.variable_rate_yn,
        PRINCIPAL_BASIS_CODE = l_def_cit_rec.principal_basis_code,
        INTEREST_BASIS_CODE = l_def_cit_rec.interest_basis_code,
        RATE_DELAY_CODE = l_def_cit_rec.rate_delay_code,
        RATE_DELAY_FREQUENCY = l_def_cit_rec.rate_delay_frequency,
        COMPOUND_FREQUENCY_CODE = l_def_cit_rec.compound_frequency_code,
        CALCULATION_FORMULA_NAME = l_def_cit_rec.calculation_formula_name,
        CATCHUP_START_DATE = l_def_cit_rec.catchup_start_date,
        CATCHUP_SETTLEMENT_CODE = l_def_cit_rec.catchup_settlement_code,
        CATCHUP_BASIS_CODE  = l_def_cit_rec.catchup_basis_code,
        RATE_CHANGE_START_DATE = l_def_cit_rec.rate_change_start_date,
        RATE_CHANGE_FREQUENCY_CODE = l_def_cit_rec.rate_change_frequency_code,
        RATE_CHANGE_VALUE = l_def_cit_rec.rate_change_value,
        CONVERSION_OPTION_CODE = l_def_cit_rec.conversion_option_code,
        NEXT_CONVERSION_DATE  = l_def_cit_rec.next_conversion_date,
        CONVERSION_TYPE_CODE = l_def_cit_rec.conversion_type_code,
        ATTRIBUTE1 = l_def_cit_rec.attribute1,
        ATTRIBUTE2 = l_def_cit_rec.attribute2,
        ATTRIBUTE3 = l_def_cit_rec.attribute3,
        ATTRIBUTE4 = l_def_cit_rec.attribute4,
        ATTRIBUTE5 = l_def_cit_rec.attribute5,
        ATTRIBUTE6 = l_def_cit_rec.attribute6,
        ATTRIBUTE7 = l_def_cit_rec.attribute7,
        ATTRIBUTE8 = l_def_cit_rec.attribute8,
        ATTRIBUTE9 = l_def_cit_rec.attribute9,
        ATTRIBUTE10 = l_def_cit_rec.attribute10,
        ATTRIBUTE11 = l_def_cit_rec.attribute11,
        ATTRIBUTE12 = l_def_cit_rec.attribute12,
        ATTRIBUTE13 = l_def_cit_rec.attribute13,
        ATTRIBUTE14 = l_def_cit_rec.attribute14,
        ATTRIBUTE15 = l_def_cit_rec.attribute15,
        CREATED_BY = l_def_cit_rec.created_by,
        CREATION_DATE = l_def_cit_rec.creation_date,
        LAST_UPDATED_BY = l_def_cit_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cit_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cit_rec.last_update_login
    WHERE TRQ_ID = l_def_cit_rec.trq_id;

    x_cit_rec := l_cit_rec;
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
  ---------------------------------------------------
  -- update_row for:OKL_CONVERT_INT_RATE_REQUEST_V --
  ---------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_rec                     IN citv_rec_type,
    x_citv_rec                     OUT NOCOPY citv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_citv_rec                     citv_rec_type := p_citv_rec;
    l_def_citv_rec                 citv_rec_type;
    l_db_citv_rec                  citv_rec_type;
    l_cit_rec                      cit_rec_type;
    lx_cit_rec                     cit_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_citv_rec IN citv_rec_type
    ) RETURN citv_rec_type IS
      l_citv_rec citv_rec_type := p_citv_rec;
    BEGIN
      l_citv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_citv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_citv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_citv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_citv_rec IN citv_rec_type,
      x_citv_rec OUT NOCOPY citv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_citv_rec := p_citv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_citv_rec := get_rec(p_citv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_citv_rec.trq_id = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.trq_id := l_db_citv_rec.trq_id;
        END IF;
        IF (x_citv_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.khr_id := l_db_citv_rec.khr_id;
        END IF;
        IF (x_citv_rec.parameter_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.parameter_type_code := l_db_citv_rec.parameter_type_code;
        END IF;
        IF (x_citv_rec.effective_from_date = OKC_API.G_MISS_DATE)
        THEN
          x_citv_rec.effective_from_date := l_db_citv_rec.effective_from_date;
        END IF;
        IF (x_citv_rec.effective_to_date = OKC_API.G_MISS_DATE)
        THEN
          x_citv_rec.effective_to_date := l_db_citv_rec.effective_to_date;
        END IF;
        IF (x_citv_rec.minimum_rate = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.minimum_rate := l_db_citv_rec.minimum_rate;
        END IF;
        IF (x_citv_rec.maximum_rate = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.maximum_rate := l_db_citv_rec.maximum_rate;
        END IF;
        IF (x_citv_rec.base_rate = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.base_rate := l_db_citv_rec.base_rate;
        END IF;
        IF (x_citv_rec.interest_index_id = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.interest_index_id := l_db_citv_rec.interest_index_id;
        END IF;
        IF (x_citv_rec.adder_rate = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.adder_rate := l_db_citv_rec.adder_rate;
        END IF;
        IF (x_citv_rec.days_in_a_year_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.days_in_a_year_code := l_db_citv_rec.days_in_a_year_code;
        END IF;
        IF (x_citv_rec.days_in_a_month_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.days_in_a_month_code := l_db_citv_rec.days_in_a_month_code;
        END IF;
        IF (x_citv_rec.proposed_effective_date = OKC_API.G_MISS_DATE)
        THEN
          x_citv_rec.proposed_effective_date := l_db_citv_rec.proposed_effective_date;
        END IF;
        IF (x_citv_rec.conversion_date = OKC_API.G_MISS_DATE)
        THEN
          x_citv_rec.conversion_date := l_db_citv_rec.conversion_date;
        END IF;
        IF (x_citv_rec.variable_rate_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.variable_rate_yn := l_db_citv_rec.variable_rate_yn;
        END IF;
        IF (x_citv_rec.principal_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.principal_basis_code := l_db_citv_rec.principal_basis_code;
        END IF;
        IF (x_citv_rec.interest_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.interest_basis_code := l_db_citv_rec.interest_basis_code;
        END IF;
        IF (x_citv_rec.rate_delay_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.rate_delay_code := l_db_citv_rec.rate_delay_code;
        END IF;
        IF (x_citv_rec.rate_delay_frequency = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.rate_delay_frequency := l_db_citv_rec.rate_delay_frequency;
        END IF;
        IF (x_citv_rec.compound_frequency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.compound_frequency_code := l_db_citv_rec.compound_frequency_code;
        END IF;
        IF (x_citv_rec.calculation_formula_name = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.calculation_formula_name := l_db_citv_rec.calculation_formula_name;
        END IF;
        IF (x_citv_rec.catchup_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_citv_rec.catchup_start_date := l_db_citv_rec.catchup_start_date;
        END IF;
        IF (x_citv_rec.catchup_settlement_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.catchup_settlement_code := l_db_citv_rec.catchup_settlement_code;
        END IF;
        IF (x_citv_rec.catchup_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.catchup_basis_code := l_db_citv_rec.catchup_basis_code;
        END IF;
        IF (x_citv_rec.rate_change_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_citv_rec.rate_change_start_date := l_db_citv_rec.rate_change_start_date;
        END IF;
        IF (x_citv_rec.rate_change_frequency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.rate_change_frequency_code := l_db_citv_rec.rate_change_frequency_code;
        END IF;
        IF (x_citv_rec.rate_change_value = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.rate_change_value := l_db_citv_rec.rate_change_value;
        END IF;
        IF (x_citv_rec.conversion_option_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.conversion_option_code := l_db_citv_rec.conversion_option_code;
        END IF;
        IF (x_citv_rec.next_conversion_date = OKC_API.G_MISS_DATE)
        THEN
          x_citv_rec.next_conversion_date := l_db_citv_rec.next_conversion_date;
        END IF;
        IF (x_citv_rec.conversion_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.conversion_type_code := l_db_citv_rec.conversion_type_code;
        END IF;
        IF (x_citv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute1 := l_db_citv_rec.attribute1;
        END IF;
        IF (x_citv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute2 := l_db_citv_rec.attribute2;
        END IF;
        IF (x_citv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute3 := l_db_citv_rec.attribute3;
        END IF;
        IF (x_citv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute4 := l_db_citv_rec.attribute4;
        END IF;
        IF (x_citv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute5 := l_db_citv_rec.attribute5;
        END IF;
        IF (x_citv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute6 := l_db_citv_rec.attribute6;
        END IF;
        IF (x_citv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute7 := l_db_citv_rec.attribute7;
        END IF;
        IF (x_citv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute8 := l_db_citv_rec.attribute8;
        END IF;
        IF (x_citv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute9 := l_db_citv_rec.attribute9;
        END IF;
        IF (x_citv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute10 := l_db_citv_rec.attribute10;
        END IF;
        IF (x_citv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute11 := l_db_citv_rec.attribute11;
        END IF;
        IF (x_citv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute12 := l_db_citv_rec.attribute12;
        END IF;
        IF (x_citv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute13 := l_db_citv_rec.attribute13;
        END IF;
        IF (x_citv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute14 := l_db_citv_rec.attribute14;
        END IF;
        IF (x_citv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_citv_rec.attribute15 := l_db_citv_rec.attribute15;
        END IF;
        IF (x_citv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.created_by := l_db_citv_rec.created_by;
        END IF;
        IF (x_citv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_citv_rec.creation_date := l_db_citv_rec.creation_date;
        END IF;
        IF (x_citv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.last_updated_by := l_db_citv_rec.last_updated_by;
        END IF;
        IF (x_citv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_citv_rec.last_update_date := l_db_citv_rec.last_update_date;
        END IF;
        IF (x_citv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_citv_rec.last_update_login := l_db_citv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------------------
    -- Set_Attributes for:OKL_CONVERT_INT_RATE_REQUEST_V --
    -------------------------------------------------------
    FUNCTION Set_Attributes (
      p_citv_rec IN citv_rec_type,
      x_citv_rec OUT NOCOPY citv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_citv_rec := p_citv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'S',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_citv_rec,                        -- IN
      x_citv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_citv_rec, l_def_citv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_citv_rec := fill_who_columns(l_def_citv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_citv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_citv_rec, l_db_citv_rec);
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
      p_citv_rec                     => p_citv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_citv_rec, l_cit_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cit_rec,
      lx_cit_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cit_rec, l_def_citv_rec);
    x_citv_rec := l_def_citv_rec;
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
  -- PL/SQL TBL update_row for:citv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    x_citv_tbl                     OUT NOCOPY citv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_citv_tbl.COUNT > 0) THEN
      i := p_citv_tbl.FIRST;
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
            p_citv_rec                     => p_citv_tbl(i),
            x_citv_rec                     => x_citv_tbl(i));
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
        EXIT WHEN (i = p_citv_tbl.LAST);
        i := p_citv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:CITV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    x_citv_tbl                     OUT NOCOPY citv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_citv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_citv_tbl                     => p_citv_tbl,
        x_citv_tbl                     => x_citv_tbl,
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
  -------------------------------------------------
  -- delete_row for:OKL_CONVERT_INT_RATE_REQUEST --
  -------------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cit_rec                      IN cit_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cit_rec                      cit_rec_type := p_cit_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'S',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_CONVERT_INT_RATE_REQUEST
     WHERE TRQ_ID = p_cit_rec.trq_id;

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
  ---------------------------------------------------
  -- delete_row for:OKL_CONVERT_INT_RATE_REQUEST_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_rec                     IN citv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_citv_rec                     citv_rec_type := p_citv_rec;
    l_cit_rec                      cit_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'S',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_citv_rec, l_cit_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cit_rec
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
  --------------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CONVERT_INT_RATE_REQUEST_V --
  --------------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_citv_tbl.COUNT > 0) THEN
      i := p_citv_tbl.FIRST;
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
            p_citv_rec                     => p_citv_tbl(i));
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
        EXIT WHEN (i = p_citv_tbl.LAST);
        i := p_citv_tbl.NEXT(i);
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

  --------------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CONVERT_INT_RATE_REQUEST_V --
  --------------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_citv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_citv_tbl                     => p_citv_tbl,
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

END OKL_CIT_PVT;


/
