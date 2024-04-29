--------------------------------------------------------
--  DDL for Package Body OKL_KRP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_KRP_PVT" AS
/* $Header: OKLSKRPB.pls 120.18.12010000.2 2008/11/12 20:39:45 cklee ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

G_MISS_NUM	CONSTANT NUMBER := FND_API.G_MISS_NUM;
G_MISS_CHAR	CONSTANT VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_MISS_DATE	CONSTANT DATE := FND_API.G_MISS_DATE;

---------------------------------------------------------------------------
  -- Lookup Code Validation
---------------------------------------------------------------------------
FUNCTION check_lookup_code(p_lookup_type IN VARCHAR2,
                            p_lookup_code IN VARCHAR2) RETURN VARCHAR2 IS
  x_return_status VARCHAR2(1):= Okl_Api.G_RET_STS_SUCCESS;
  l_sysdate   DATE  := SYSDATE ;
  l_dummy_var         VARCHAR2(1) := '?';
  CURSOR l_lookup_code_csr IS
          SELECT 'X'
          FROM   fnd_lookups fndlup
          WHERE  fndlup.lookup_type = p_lookup_type
          AND    fndlup.lookup_code = p_lookup_code
          AND    l_sysdate BETWEEN
                         NVL(fndlup.start_date_active,l_sysdate)
                         AND NVL(fndlup.end_date_active,l_sysdate);
 BEGIN
   OPEN l_lookup_code_csr;
   FETCH l_lookup_code_csr INTO l_dummy_var;
   CLOSE l_lookup_code_csr;
 -- if l_dummy_var still set to default, data was not found
   IF (l_dummy_var = '?') THEN
     -- notify caller of an error
        x_return_status := Okl_Api.G_RET_STS_ERROR;
   END IF;
      RETURN (x_return_status);
  EXCEPTION
   WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	 -- verify that cursor was closed
      IF l_lookup_code_csr%ISOPEN THEN
       CLOSE l_lookup_code_csr;
      END IF;
      RETURN(x_return_status);
END check_lookup_code;

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
  -- FUNCTION get_rec for: OKL_K_RATE_PARAMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_krpv_rec                     IN krpv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN krpv_rec_type IS
    CURSOR okl_k_rate_params_v_u1_csr (p_effective_from_date IN DATE,
                                       p_khr_id              IN NUMBER,
                                       p_parameter_type_code IN VARCHAR2) IS
    SELECT
            KHR_ID,
            PARAMETER_TYPE_CODE,
            EFFECTIVE_FROM_DATE,
            EFFECTIVE_TO_DATE,
            INTEREST_INDEX_ID,
            BASE_RATE,
            INTEREST_START_DATE,
            ADDER_RATE,
            MAXIMUM_RATE,
            MINIMUM_RATE,
            PRINCIPAL_BASIS_CODE,
            DAYS_IN_A_MONTH_CODE,
            DAYS_IN_A_YEAR_CODE,
            INTEREST_BASIS_CODE,
            RATE_DELAY_CODE,
            RATE_DELAY_FREQUENCY,
            COMPOUNDING_FREQUENCY_CODE,
            CALCULATION_FORMULA_ID,
            CATCHUP_BASIS_CODE,
            CATCHUP_START_DATE,
            CATCHUP_SETTLEMENT_CODE,
            RATE_CHANGE_START_DATE,
            RATE_CHANGE_FREQUENCY_CODE,
            RATE_CHANGE_VALUE,
            CONVERSION_OPTION_CODE,
            NEXT_CONVERSION_DATE,
            CONVERSION_TYPE_CODE,
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
            CATCHUP_FREQUENCY_CODE
      FROM Okl_K_Rate_Params_V
     WHERE okl_k_rate_params_v.effective_from_date = p_effective_from_date
       AND okl_k_rate_params_v.khr_id = p_khr_id
       AND okl_k_rate_params_v.parameter_type_code = p_parameter_type_code;
    l_okl_k_rate_params_v_u1       okl_k_rate_params_v_u1_csr%ROWTYPE;
    l_krpv_rec                     krpv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_rate_params_v_u1_csr (p_krpv_rec.effective_from_date,
                                     p_krpv_rec.khr_id,
                                     p_krpv_rec.parameter_type_code);
    FETCH okl_k_rate_params_v_u1_csr INTO
              l_krpv_rec.khr_id,
              l_krpv_rec.parameter_type_code,
              l_krpv_rec.effective_from_date,
              l_krpv_rec.effective_to_date,
              l_krpv_rec.interest_index_id,
              l_krpv_rec.base_rate,
              l_krpv_rec.interest_start_date,
              l_krpv_rec.adder_rate,
              l_krpv_rec.maximum_rate,
              l_krpv_rec.minimum_rate,
              l_krpv_rec.principal_basis_code,
              l_krpv_rec.days_in_a_month_code,
              l_krpv_rec.days_in_a_year_code,
              l_krpv_rec.interest_basis_code,
              l_krpv_rec.rate_delay_code,
              l_krpv_rec.rate_delay_frequency,
              l_krpv_rec.compounding_frequency_code,
              l_krpv_rec.calculation_formula_id,
              l_krpv_rec.catchup_basis_code,
              l_krpv_rec.catchup_start_date,
              l_krpv_rec.catchup_settlement_code,
              l_krpv_rec.rate_change_start_date,
              l_krpv_rec.rate_change_frequency_code,
              l_krpv_rec.rate_change_value,
              l_krpv_rec.conversion_option_code,
              l_krpv_rec.next_conversion_date,
              l_krpv_rec.conversion_type_code,
              l_krpv_rec.attribute_category,
              l_krpv_rec.attribute1,
              l_krpv_rec.attribute2,
              l_krpv_rec.attribute3,
              l_krpv_rec.attribute4,
              l_krpv_rec.attribute5,
              l_krpv_rec.attribute6,
              l_krpv_rec.attribute7,
              l_krpv_rec.attribute8,
              l_krpv_rec.attribute9,
              l_krpv_rec.attribute10,
              l_krpv_rec.attribute11,
              l_krpv_rec.attribute12,
              l_krpv_rec.attribute13,
              l_krpv_rec.attribute14,
              l_krpv_rec.attribute15,
              l_krpv_rec.created_by,
              l_krpv_rec.creation_date,
              l_krpv_rec.last_updated_by,
              l_krpv_rec.last_update_date,
              l_krpv_rec.last_update_login,
              l_krpv_rec.catchup_frequency_code;
    x_no_data_found := okl_k_rate_params_v_u1_csr%NOTFOUND;
    CLOSE okl_k_rate_params_v_u1_csr;
    RETURN(l_krpv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_krpv_rec                     IN krpv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN krpv_rec_type IS
    l_krpv_rec                     krpv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_krpv_rec := get_rec(p_krpv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(OKL_API.G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'EFFECTIVE_FROM_DATE');
      OKC_API.set_message(OKL_API.G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID');
      OKC_API.set_message(OKL_API.G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'PARAMETER_TYPE_CODE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_krpv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_krpv_rec                     IN krpv_rec_type
  ) RETURN krpv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_krpv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_K_RATE_PARAMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_krp_rec                      IN krp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN krp_rec_type IS
    CURSOR okl_k_rate_params_pk_csr (p_parameter_type_code IN VARCHAR2,
                                     p_effective_from_date IN DATE,
                                     p_khr_id              IN NUMBER) IS
    SELECT
            KHR_ID,
            PARAMETER_TYPE_CODE,
            EFFECTIVE_FROM_DATE,
            EFFECTIVE_TO_DATE,
            INTEREST_INDEX_ID,
            BASE_RATE,
            INTEREST_START_DATE,
            ADDER_RATE,
            MAXIMUM_RATE,
            MINIMUM_RATE,
            PRINCIPAL_BASIS_CODE,
            DAYS_IN_A_MONTH_CODE,
            DAYS_IN_A_YEAR_CODE,
            INTEREST_BASIS_CODE,
            RATE_DELAY_CODE,
            RATE_DELAY_FREQUENCY,
            COMPOUNDING_FREQUENCY_CODE,
            CALCULATION_FORMULA_ID,
            CATCHUP_BASIS_CODE,
            CATCHUP_START_DATE,
            CATCHUP_SETTLEMENT_CODE,
            RATE_CHANGE_START_DATE,
            RATE_CHANGE_FREQUENCY_CODE,
            RATE_CHANGE_VALUE,
            CONVERSION_OPTION_CODE,
            NEXT_CONVERSION_DATE,
            CONVERSION_TYPE_CODE,
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
            CATCHUP_FREQUENCY_CODE
      FROM Okl_K_Rate_Params
     WHERE okl_k_rate_params.parameter_type_code = p_parameter_type_code
       AND okl_k_rate_params.effective_from_date = p_effective_from_date
       AND okl_k_rate_params.khr_id = p_khr_id;
    l_okl_k_rate_params_pk         okl_k_rate_params_pk_csr%ROWTYPE;
    l_krp_rec                      krp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_rate_params_pk_csr (p_krp_rec.parameter_type_code,
                                   p_krp_rec.effective_from_date,
                                   p_krp_rec.khr_id);
    FETCH okl_k_rate_params_pk_csr INTO
              l_krp_rec.khr_id,
              l_krp_rec.parameter_type_code,
              l_krp_rec.effective_from_date,
              l_krp_rec.effective_to_date,
              l_krp_rec.interest_index_id,
              l_krp_rec.base_rate,
              l_krp_rec.interest_start_date,
              l_krp_rec.adder_rate,
              l_krp_rec.maximum_rate,
              l_krp_rec.minimum_rate,
              l_krp_rec.principal_basis_code,
              l_krp_rec.days_in_a_month_code,
              l_krp_rec.days_in_a_year_code,
              l_krp_rec.interest_basis_code,
              l_krp_rec.rate_delay_code,
              l_krp_rec.rate_delay_frequency,
              l_krp_rec.compounding_frequency_code,
              l_krp_rec.calculation_formula_id,
              l_krp_rec.catchup_basis_code,
              l_krp_rec.catchup_start_date,
              l_krp_rec.catchup_settlement_code,
              l_krp_rec.rate_change_start_date,
              l_krp_rec.rate_change_frequency_code,
              l_krp_rec.rate_change_value,
              l_krp_rec.conversion_option_code,
              l_krp_rec.next_conversion_date,
              l_krp_rec.conversion_type_code,
              l_krp_rec.attribute_category,
              l_krp_rec.attribute1,
              l_krp_rec.attribute2,
              l_krp_rec.attribute3,
              l_krp_rec.attribute4,
              l_krp_rec.attribute5,
              l_krp_rec.attribute6,
              l_krp_rec.attribute7,
              l_krp_rec.attribute8,
              l_krp_rec.attribute9,
              l_krp_rec.attribute10,
              l_krp_rec.attribute11,
              l_krp_rec.attribute12,
              l_krp_rec.attribute13,
              l_krp_rec.attribute14,
              l_krp_rec.attribute15,
              l_krp_rec.created_by,
              l_krp_rec.creation_date,
              l_krp_rec.last_updated_by,
              l_krp_rec.last_update_date,
              l_krp_rec.last_update_login,
              l_krp_rec.catchup_frequency_code;
    x_no_data_found := okl_k_rate_params_pk_csr%NOTFOUND;
    CLOSE okl_k_rate_params_pk_csr;
    RETURN(l_krp_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_krp_rec                      IN krp_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN krp_rec_type IS
    l_krp_rec                      krp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_krp_rec := get_rec(p_krp_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(OKL_API.G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'PARAMETER_TYPE_CODE');
      OKC_API.set_message(OKL_API.G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'EFFECTIVE_FROM_DATE');
      OKC_API.set_message(OKL_API.G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_krp_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_krp_rec                      IN krp_rec_type
  ) RETURN krp_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_krp_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_K_RATE_PARAMS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_krpv_rec   IN krpv_rec_type
  ) RETURN krpv_rec_type IS
    l_krpv_rec                     krpv_rec_type := p_krpv_rec;
  BEGIN
    IF (l_krpv_rec.khr_id = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.khr_id := NULL;
    END IF;
    IF (l_krpv_rec.parameter_type_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.parameter_type_code := NULL;
    END IF;
    IF (l_krpv_rec.effective_from_date = OKC_API.G_MISS_DATE ) THEN
      l_krpv_rec.effective_from_date := NULL;
    END IF;
    IF (l_krpv_rec.effective_to_date = OKC_API.G_MISS_DATE ) THEN
      l_krpv_rec.effective_to_date := NULL;
    END IF;
    IF (l_krpv_rec.interest_index_id = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.interest_index_id := NULL;
    END IF;
    IF (l_krpv_rec.base_rate = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.base_rate := NULL;
    END IF;
    IF (l_krpv_rec.interest_start_date = OKC_API.G_MISS_DATE ) THEN
      l_krpv_rec.interest_start_date := NULL;
    END IF;
    IF (l_krpv_rec.adder_rate = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.adder_rate := NULL;
    END IF;
    IF (l_krpv_rec.maximum_rate = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.maximum_rate := NULL;
    END IF;
    IF (l_krpv_rec.minimum_rate = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.minimum_rate := NULL;
    END IF;
    IF (l_krpv_rec.principal_basis_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.principal_basis_code := NULL;
    END IF;
    IF (l_krpv_rec.days_in_a_month_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.days_in_a_month_code := NULL;
    END IF;
    IF (l_krpv_rec.days_in_a_year_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.days_in_a_year_code := NULL;
    END IF;
    IF (l_krpv_rec.interest_basis_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.interest_basis_code := NULL;
    END IF;
    IF (l_krpv_rec.rate_delay_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.rate_delay_code := NULL;
    END IF;
    IF (l_krpv_rec.rate_delay_frequency = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.rate_delay_frequency := NULL;
    END IF;
    IF (l_krpv_rec.compounding_frequency_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.compounding_frequency_code := NULL;
    END IF;
    IF (l_krpv_rec.calculation_formula_id = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.calculation_formula_id := NULL;
    END IF;
    IF (l_krpv_rec.catchup_basis_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.catchup_basis_code := NULL;
    END IF;
    IF (l_krpv_rec.catchup_start_date = OKC_API.G_MISS_DATE ) THEN
      l_krpv_rec.catchup_start_date := NULL;
    END IF;
    IF (l_krpv_rec.catchup_settlement_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.catchup_settlement_code := NULL;
    END IF;
    IF (l_krpv_rec.rate_change_start_date = OKC_API.G_MISS_DATE ) THEN
      l_krpv_rec.rate_change_start_date := NULL;
    END IF;
    IF (l_krpv_rec.rate_change_frequency_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.rate_change_frequency_code := NULL;
    END IF;
    IF (l_krpv_rec.rate_change_value = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.rate_change_value := NULL;
    END IF;
    IF (l_krpv_rec.conversion_option_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.conversion_option_code := NULL;
    END IF;
    IF (l_krpv_rec.next_conversion_date = OKC_API.G_MISS_DATE ) THEN
      l_krpv_rec.next_conversion_date := NULL;
    END IF;
    IF (l_krpv_rec.conversion_type_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.conversion_type_code := NULL;
    END IF;
    IF (l_krpv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute_category := NULL;
    END IF;
    IF (l_krpv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute1 := NULL;
    END IF;
    IF (l_krpv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute2 := NULL;
    END IF;
    IF (l_krpv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute3 := NULL;
    END IF;
    IF (l_krpv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute4 := NULL;
    END IF;
    IF (l_krpv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute5 := NULL;
    END IF;
    IF (l_krpv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute6 := NULL;
    END IF;
    IF (l_krpv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute7 := NULL;
    END IF;
    IF (l_krpv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute8 := NULL;
    END IF;
    IF (l_krpv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute9 := NULL;
    END IF;
    IF (l_krpv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute10 := NULL;
    END IF;
    IF (l_krpv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute11 := NULL;
    END IF;
    IF (l_krpv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute12 := NULL;
    END IF;
    IF (l_krpv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute13 := NULL;
    END IF;
    IF (l_krpv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute14 := NULL;
    END IF;
    IF (l_krpv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.attribute15 := NULL;
    END IF;
    IF (l_krpv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.created_by := NULL;
    END IF;
    IF (l_krpv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_krpv_rec.creation_date := NULL;
    END IF;
    IF (l_krpv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_krpv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_krpv_rec.last_update_date := NULL;
    END IF;
    IF (l_krpv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_krpv_rec.last_update_login := NULL;
    END IF;
    IF (l_krpv_rec.catchup_frequency_code = OKC_API.G_MISS_CHAR ) THEN
      l_krpv_rec.catchup_frequency_code := NULL;
    END IF;
    RETURN(l_krpv_rec);
  END null_out_defaults;
  -------------------------------------
  -- Validate_Attributes for: KHR_ID --
  -------------------------------------
  PROCEDURE validate_khr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_khr_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_khr_id = OKC_API.G_MISS_NUM OR
        p_khr_id IS NULL)
    THEN
      OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'khr_id');
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
  END validate_khr_id;
  --------------------------------------------------
  -- Validate_Attributes for: PARAMETER_TYPE_CODE --
  --------------------------------------------------
  PROCEDURE validate_parameter_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_parameter_type_code          IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_parameter_type_code = OKC_API.G_MISS_CHAR OR
        p_parameter_type_code IS NULL)
    THEN
      OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'parameter_type_code');
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
  END validate_parameter_type_code;
  --------------------------------------------------
  -- Validate_Attributes for: EFFECTIVE_FROM_DATE --
  --------------------------------------------------
  PROCEDURE validate_effective_from_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_effective_from_date          IN DATE) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_effective_from_date = OKC_API.G_MISS_DATE OR
        p_effective_from_date IS NULL)
    THEN
      OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'effective_from_date');
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
  END validate_effective_from_date;
  --------------------------------------------------
  -- Validate_Attributes for: interest_basis_code --
  --------------------------------------------------
  PROCEDURE validate_interest_basis_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := check_lookup_code('OKL_VAR_INTCALC',
                                          p_lookup_code);
  END validate_interest_basis_code;

  --------------------------------------------------
  -- Validate_Attributes for: rate_delay_code --
  --------------------------------------------------
  PROCEDURE validate_rate_delay_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := check_lookup_code('OKL_RATE_DELAY_CODE',
                                          p_lookup_code);
  END validate_rate_delay_code;

  --------------------------------------------------
  -- Validate_Attributes for: rate_change_frequency --
  --------------------------------------------------
  PROCEDURE validate_rate_change_frequency(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := check_lookup_code('OKL_RATE_CHANGE_FREQUENCY_CODE',
                                          p_lookup_code);
  END validate_rate_change_frequency;

  --------------------------------------------------
  -- Validate_Attributes for: compounding_frequency_code --
  --------------------------------------------------
  PROCEDURE validate_compounding_freq_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := check_lookup_code('OKL_COMPOUNDING_FREQUENCY_CODE',
                                          p_lookup_code);
  END validate_compounding_freq_code;

  --------------------------------------------------
  -- Validate_Attributes for: Principal_Basis_Code --
  --------------------------------------------------
  PROCEDURE validate_Principal_Basis_Code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    --x_return_status := check_lookup_code('OKL_PRINCIPAL_BASIS_CODE',
    x_return_status := check_lookup_code('OKL_PRINCIPAL_INTEREST',
                                          p_lookup_code);
  END validate_Principal_Basis_Code;

  --------------------------------------------------
  -- Validate_Attributes for: Catchup_Basis_Code --
  --------------------------------------------------
  PROCEDURE validate_Catchup_Basis_Code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := check_lookup_code('OKL_CATCHUP_BASIS_CODE',
                                          p_lookup_code);
  END validate_Catchup_Basis_Code;

  --------------------------------------------------
  -- Validate_Attributes for: Catchup_Settlement_Code --
  --------------------------------------------------
  PROCEDURE validate_Catchup_Settleme_Code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := check_lookup_code('OKL_CATCHUP_SETTLEMENT_CODE',
                                          p_lookup_code);
  END validate_Catchup_Settleme_Code;

  --------------------------------------------------
  -- Validate_Attributes for: Conversion_Option_Code --
  --------------------------------------------------
  PROCEDURE validate_Conversion_Optio_Code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_lookup_code = OKC_API.G_MISS_CHAR OR
        p_lookup_code IS NULL)
    THEN
      OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Conversion Option Code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (p_lookup_code <> OKL_API.G_MISS_CHAR AND
	   p_lookup_code is NOT NULL) THEN
      x_return_status := check_lookup_code('OKL_CONVERSION_OPTION_CODE',
                                            p_lookup_code);
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
  END validate_Conversion_Optio_Code;

  --------------------------------------------------
  -- Validate_Attributes for: Conversion_Type_Code --
  --------------------------------------------------
  PROCEDURE validate_Conversion_Type_Code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := check_lookup_code('OKL_CONVERSION_TYPE_CODE',
                                          p_lookup_code);
  END validate_Conversion_Type_Code;

  --------------------------------------------------
  -- Validate_Attributes for: calculation_formula_id --
  --------------------------------------------------
  PROCEDURE validate_calculatio_formula_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_calculation_formula_id       IN NUMBER) IS
  CURSOR C1(p_id NUMBER) IS
  SELECT ID from OKL_FORMULAE_B
  WHERE  ID = p_id;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FOR r IN C1(p_calculation_formula_id)
    LOOP
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
    END LOOP;
    return;

    EXCEPTION WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
  END validate_calculatio_formula_id;
  --------------------------------------------------
  -- Validate_Attributes for: catchup_frequency_code --
  --------------------------------------------------
  PROCEDURE validate_catchup_freq_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := check_lookup_code('OKL_CATCHUP_FREQUENCY_CODE',
                                          p_lookup_code);
  END validate_catchup_freq_code;

  --------------------------------------------------
  -- Validate_Attributes for: interest_index_id --
  --------------------------------------------------
  PROCEDURE validate_interest_index_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_interest_index_id            IN NUMBER) IS
  CURSOR C1(p_id NUMBER) IS
  SELECT ID from OKL_INDICES
  WHERE  ID = p_id;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FOR r IN C1(p_interest_index_id)
    LOOP
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
    END LOOP;
    return;

    EXCEPTION WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
  END validate_interest_index_id;

  --------------------------------------------------
  -- Validate_Attributes for: days_in_a_month_code --
  --------------------------------------------------
  PROCEDURE validate_days_in_a_month_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_lookup_code=' || p_lookup_code);
    END IF;
    x_return_status := check_lookup_code('OKL_MONTH_TYPE',
                                          p_lookup_code);
  END validate_days_in_a_month_code;

  --------------------------------------------------
  -- Validate_Attributes for: days_in_a_year_code --
  --------------------------------------------------
  PROCEDURE validate_days_in_a_year_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lookup_code                  IN VARCHAR2) IS
  BEGIN
    x_return_status := check_lookup_code('OKL_YEAR_TYPE',
                                          p_lookup_code);
  END validate_days_in_a_year_code;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_K_RATE_PARAMS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_krpv_rec                     IN krpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- khr_id
    -- ***
    validate_khr_id(x_return_status, p_krpv_rec.khr_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- parameter_type_code
    -- ***
    validate_parameter_type_code(x_return_status, p_krpv_rec.parameter_type_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- effective_from_date
    -- ***
    validate_effective_from_date(x_return_status, p_krpv_rec.effective_from_date);
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
  -- FUNCTION Validate_Attributes, Custom, overloaded
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_K_RATE_PARAMS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_krpv_rec                     IN krpv_rec_type,
    p_stack_messages               IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- khr_id
    -- ***
    validate_khr_id(x_return_status, p_krpv_rec.khr_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.khr_id
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'KHR_ID');
      l_return_status := x_return_status;
      IF (p_stack_messages = 'N') THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_khr_id');
    END IF;

    -- ***
    -- parameter_type_code
    -- ***
    validate_parameter_type_code(x_return_status, p_krpv_rec.parameter_type_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      IF (p_stack_messages = 'N') THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_parameter_type_code');
    END IF;

    x_return_status := check_lookup_code('OKL_RATE_PARAM_TYPE_CODE',
                                          p_krpv_rec.parameter_type_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      -- AKP Todo: Set message (invalid parameter type code)
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_INVALID_PARAM_TYPE_CODE'
                          ,p_token1       => 'CODE'
                          ,p_token1_value => p_krpv_rec.parameter_type_code);
      l_return_status := x_return_status;
      IF (p_stack_messages = 'N') THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After check_lookup_code');
    END IF;

    -- ***
    -- effective_from_date
    -- ***
    validate_effective_from_date(x_return_status, p_krpv_rec.effective_from_date);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.effective_from_date
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'EFFECTIVE_FROM_DATE');
      l_return_status := x_return_status;
      IF (p_stack_messages = 'N') THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_effective_from_date');
    END IF;

    --- Interest_basis_code
    IF (p_krpv_rec.interest_basis_code is NOT NULL AND
        p_krpv_rec.interest_basis_code <> G_MISS_CHAR) THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'interest_basis_code=' || p_krpv_rec.interest_basis_code || ':');
      END IF;
      validate_interest_basis_code( x_return_status,
                                    p_krpv_rec.interest_basis_code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        -- AKP Todo: Set message (invalid Interest Calculation basis code)
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.interest_basis_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'INTEREST_BASIS_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_interest_basis_code');
    END IF;
    --- Rate_Delay_Code
    IF (p_krpv_rec.Rate_Delay_Code is NOT NULL AND
        p_krpv_rec.Rate_Delay_Code <> G_MISS_CHAR) THEN
      validate_rate_delay_code( x_return_status,
                                p_krpv_rec.Rate_Delay_Code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        -- AKP Todo: Set message (invalid Rate Delay code)
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.rate_delay_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'RATE_DELAY_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_rate_delay_code');
    END IF;

    --- Compounding_Frequency_Code
    IF (p_krpv_rec.Compounding_Frequency_Code is NOT NULL AND
        p_krpv_rec.Compounding_Frequency_Code <> G_MISS_CHAR) THEN
      validate_compounding_freq_code( x_return_status,
                                      p_krpv_rec.Compounding_Frequency_Code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        -- AKP Todo: Set message (invalid Compounding_Frequency_Code)
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.compounding_frequency_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'COMPOUNDING_FREQUENCY_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_compounding_freq_code');
    END IF;

    --- Rate_Change_Frequency
    IF (p_krpv_rec.Rate_Change_Frequency_Code is NOT NULL AND
        p_krpv_rec.Rate_Change_Frequency_Code <> G_MISS_CHAR) THEN
      validate_rate_change_frequency( x_return_status,
                                     p_krpv_rec.Rate_Change_Frequency_Code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        -- AKP Todo: Set message (invalid Rate Change Frequency Code)
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.rate_change_frequency_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'RATE_CHANGE_FREQUENCY_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_rate_change_freq');
    END IF;

    --- Principal_Basis_Code
    IF (p_krpv_rec.Principal_Basis_Code is NOT NULL AND
        p_krpv_rec.Principal_Basis_Code <> G_MISS_CHAR) THEN
      validate_Principal_Basis_Code(x_return_status,
                       p_krpv_rec.Principal_Basis_Code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        -- AKP Todo: Set message (invalid Principal_Basis_Code)
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.principal_basis_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'PRINCIPAL_BASIS_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          --print('Invalid Principal_basis_code...');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_principal_basis_code');
    END IF;

    --- Catchup_Basis_Code
    IF (p_krpv_rec.Catchup_Basis_Code is NOT NULL AND
        p_krpv_rec.Catchup_Basis_Code <> G_MISS_CHAR) THEN
      validate_Catchup_Basis_Code(x_return_status,
                       p_krpv_rec.Catchup_Basis_Code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        -- AKP Todo: Set message (invalid Catchup_Basis_Code)
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.catchup_basis_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'CATCHUP_BASIS_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          --print('Invalid Catchupl_basis_code...');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_catchup_basis_code');
    END IF;

    --- Catchup_Settlement_Code
    IF (p_krpv_rec.Catchup_Settlement_Code is NOT NULL AND
        p_krpv_rec.Catchup_Settlement_Code <> G_MISS_CHAR) THEN
      validate_Catchup_Settleme_Code(x_return_status,
                       p_krpv_rec.Catchup_Settlement_Code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        -- AKP Todo: Set message (invalid Catchup_Settlement_Code)
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.catchup_settlement_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'CATCHUP_SETTLEMENT_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          --print('Invalid Catchup_settlement_code...');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_catchup_settlement_code');
    END IF;

    --- Conversion_Option_Code
    IF (p_krpv_rec.Conversion_Option_Code is NOT NULL AND
        p_krpv_rec.Conversion_Option_Code <> G_MISS_CHAR) THEN
      validate_Conversion_Optio_Code(x_return_status,
                       p_krpv_rec.Conversion_Option_Code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        -- AKP Todo: Set message (invalid Conversion_Option_Code)
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.conversion_option_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'CONVERSION_OPTION_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          --print('Invalid Conversion_option_code...');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_conversion_option_code');
    END IF;

    --- Conversion_Type_Code
    IF (p_krpv_rec.Conversion_Type_Code is NOT NULL AND
        p_krpv_rec.Conversion_Type_Code <> G_MISS_CHAR) THEN
      validate_Conversion_Type_Code(x_return_status,
                       p_krpv_rec.Conversion_Type_Code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        -- AKP Todo: Set message (invalid Conversion_Type_Code)
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.conversion_type_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'CONVERSION_TYPE_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          --print('Invalid Conversion_type_code...');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    --print('After validate_conversion_type_code');

    --- calculation_formula_id
    IF (p_krpv_rec.calculation_formula_id is NOT NULL AND
        p_krpv_rec.calculation_formula_id <> G_MISS_NUM) THEN
      validate_calculatio_formula_id(x_return_status,
                       p_krpv_rec.calculation_formula_id);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.calculation_formula_id
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'CALCULATION_FORMULA_ID');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    --print('After validate_calculatio_formula_id');

    --- catchup_frequency_code
    IF (p_krpv_rec.catchup_frequency_code is NOT NULL AND
        p_krpv_rec.catchup_frequency_code <> G_MISS_CHAR) THEN
      validate_catchup_freq_code(x_return_status,
                       p_krpv_rec.catchup_frequency_code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.catchup_frequency_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'CATCHUP_FREQUENCY_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    --print('After validate_catchup_freq_code');

    --- interest_index_id
    IF (p_krpv_rec.interest_index_id is NOT NULL AND
        p_krpv_rec.interest_index_id <> G_MISS_NUM) THEN
      validate_interest_index_id(x_return_status,
                       p_krpv_rec.interest_index_id);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.interest_index_id
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'INTEREST_INDEX_ID');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    --print('After validate_interest_index_id');

    --- days_in_a_month_code
    IF (p_krpv_rec.days_in_a_month_code is NOT NULL AND
        p_krpv_rec.days_in_a_month_code <> G_MISS_CHAR) THEN
      validate_days_in_a_month_code(x_return_status,
                       p_krpv_rec.days_in_a_month_code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.days_in_a_month_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'DAYS_IN_A_MONTH_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    --print('After validate_days_in_a_month_code');

    --- days_in_a_year_code
    IF (p_krpv_rec.days_in_a_year_code is NOT NULL AND
        p_krpv_rec.days_in_a_year_code <> G_MISS_CHAR) THEN
      validate_days_in_a_year_code(x_return_status,
                       p_krpv_rec.days_in_a_year_code);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_VAR_INVALID_PARAM'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => p_krpv_rec.days_in_a_year_code
                          ,p_token2       => 'PARAM'
                          ,p_token2_value => 'DAYS_IN_A_YEAR_CODE');
        l_return_status := x_return_status;
        IF (p_stack_messages = 'N') THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    --print('After validate_days_in_a_year_code');

    -- Do extra validation (bug 4722746) here
    -- if rate delay code is defined then rate delay frequency is required
    IF (p_krpv_rec.Rate_Delay_Code is NOT NULL AND
        p_krpv_rec.Rate_Delay_Code <> G_MISS_CHAR) THEN
      IF (p_krpv_rec.Rate_Delay_Frequency is NOT NULL AND
          p_krpv_rec.Rate_Delay_Frequency <> G_MISS_NUM) THEN
        NULL;
      ELSE
          OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Rate Delay Frequency');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;
    ELSE -- Rate delay code is null
      IF (p_krpv_rec.Rate_Delay_Frequency is NOT NULL AND
          p_krpv_rec.Rate_Delay_Frequency <> G_MISS_NUM) THEN
          OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Rate Delay');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;
    END IF;

    -- if compounding freq code is defined then formula id is required
    IF (p_krpv_rec.compounding_frequency_code is NOT NULL AND
        p_krpv_rec.compounding_frequency_code <> G_MISS_CHAR) THEN
      IF (p_krpv_rec.calculation_formula_id is NOT NULL AND
          p_krpv_rec.calculation_formula_id <> G_MISS_NUM) THEN
        NULL;
      ELSE
          OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Formula Name');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;
    END IF;

    -- if rate_change_frequency_code is defined then rate change start date
    -- and rate change value are required id is required
    IF (p_krpv_rec.rate_change_frequency_code is NOT NULL AND
        p_krpv_rec.rate_change_frequency_code <> G_MISS_CHAR) THEN

      IF (p_krpv_rec.rate_change_start_date is NOT NULL AND
          p_krpv_rec.rate_change_start_date <> G_MISS_DATE) THEN
        NULL;
      ELSE
          OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Rate Change Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;

      IF (p_krpv_rec.rate_change_value is NOT NULL AND
          p_krpv_rec.rate_change_value <> G_MISS_NUM) THEN
        NULL;
      ELSE
          OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Rate Change Value');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;

    ELSE -- rate change frequency code is null
      IF ((p_krpv_rec.rate_change_value is NOT NULL AND
          p_krpv_rec.rate_change_value <> G_MISS_NUM) OR
          (p_krpv_rec.rate_change_start_date is NOT NULL AND
           p_krpv_rec.rate_change_start_date <> G_MISS_DATE) ) THEN
          OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Rate Change Frequency');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;

    END IF;

    -- if compounding freq code is defined then formula id is required
    IF (p_krpv_rec.conversion_option_code is NOT NULL AND
        p_krpv_rec.conversion_option_code <> G_MISS_CHAR) THEN

      IF (p_krpv_rec.next_conversion_date is NOT NULL AND
          p_krpv_rec.next_conversion_date <> G_MISS_DATE) THEN
        NULL;
      ELSE
          OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Next Conversion Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;

      IF (p_krpv_rec.conversion_type_code is NOT NULL AND
          p_krpv_rec.conversion_type_code <> G_MISS_CHAR) THEN
        NULL;
      ELSE
          OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Conversion Type');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;

    ELSE -- conversion option code is null
      IF ((p_krpv_rec.conversion_type_code is NOT NULL AND
          p_krpv_rec.conversion_type_code <> G_MISS_CHAR) OR
         (p_krpv_rec.next_conversion_date is NOT NULL AND
          p_krpv_rec.next_conversion_date <> G_MISS_DATE)) THEN

            OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                                p_msg_name => G_REQUIRED_VALUE,
                                p_token1 => G_COL_NAME_TOKEN,
                                p_token1_value => 'Conversion Option Code');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

      END IF;

    END IF;

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
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
  ---------------------------------------------
  -- Validate Record for:OKL_K_RATE_PARAMS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_krpv_rec IN krpv_rec_type,
    p_db_krpv_rec IN krpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_krpv_rec IN krpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_krpv_rec                  krpv_rec_type := get_rec(p_krpv_rec);
  BEGIN
    l_return_status := Validate_Record(p_krpv_rec => p_krpv_rec,
                                       p_db_krpv_rec => l_db_krpv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  /* Validate_record : Custom, Overloaded */
  FUNCTION Validate_Record (
    p_krpv_rec IN krpv_rec_type,
    p_stack_messages IN VARCHAR2,
    p_deal_type                    IN  VARCHAR2,
    p_rev_rec_method               IN  VARCHAR2,
    p_int_calc_basis               IN  VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    --l_db_krpv_rec                  krpv_rec_type := get_rec(p_krpv_rec);
    l_principal_payment_defined BOOLEAN := FALSE;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    violated_ref_integrity EXCEPTION;
    l_msg1_set BOOLEAN := FALSE;
    l_msg2_set BOOLEAN := FALSE;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Validate_Record...');
    END IF;
    IF (p_deal_type IN ('LEASEDF', 'LEASEOP', 'LEASEST') ) THEN
      IF (p_int_calc_basis = 'FIXED' AND p_rev_rec_method = 'STREAMS') THEN

        NULL; -- 4736732 No check required
        /*print('Checking Conversion_Option_Code...');
        IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Option_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Option_Code IS NULL)
        THEN
          print('Conversion_Option_Code is NULL...');
          --OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Conversion_Option_Code');
          OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Conversion_Option_Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF; */

        /*
        print('Checking next_Conversion_Date...' ||p_krpv_rec.Next_Conversion_Date);
        IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Next_Conversion_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Next_Conversion_Date IS NULL)
        THEN
          print('next_Conversion_Date is NULL...');
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Next_Conversion_Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF; */

        /*print('Checking Conversion_Type_Code...');
        --print('G_APP_NAME=' || G_APP_NAME);
        --print('G_REQUIRED_VALUE=' || G_REQUIRED_VALUE);
        --print('G_COL_NAME_TOKEN=' || G_COL_NAME_TOKEN);
        IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Type_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Type_Code IS NULL)
        THEN
          print('Conversion_Type_Code is NULL...');
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Conversion Type Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

      ELSIF (p_int_calc_basis = 'REAMORT' AND p_rev_rec_method ='STREAMS') THEN
        IF (p_krpv_rec.Interest_Index_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Interest_Index_Id IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Index Id');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4907390
        /*IF (p_krpv_rec.Base_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Base_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Base Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        IF (p_krpv_rec.Interest_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Interest_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Adder_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Adder_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Adder Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Maximum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Maximum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Maximum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Minimum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Minimum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Minimum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Principal_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Principal_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Principal Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Principal_Basis_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Principal_Basis_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Principal_Basis_Code <> 'SCHEDULED') THEN
            -- AKP: Todo: Set Proper Message
            --(Principal Basis Code is 'SCHEDULED' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'SCHEDULED'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'PRINCIPAL_BASIS_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Month_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Month_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Month Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Days_In_A_Month_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Days_In_A_Month_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Days_In_A_Month_Code <> '30') THEN
            -- AKP: Todo: Set Proper Message
            --(Days In A Month Code is '30' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => '30'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'DAYS_IN_A_MONTH_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Year_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Year_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Year Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Days_In_A_Year_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Days_In_A_Year_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Days_In_A_Year_Code <> '360') THEN
            -- AKP: Todo: Set Proper Message
            --(Days In A Year Code is '360' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => '360'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'DAYS_IN_A_YEAR_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Interest_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Interest_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Interest_Basis_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Interest_Basis_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Interest_Basis_Code <> 'SIMPLE') THEN
            -- AKP: Todo: Set Proper Message
            --(Interest Basis Code is 'SIMPLE' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'SIMPLE'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'INTEREST_BASIS_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        /* Bug 4862551. Commented out. No need to have these values:
           rate_delay_code, rate_delay_frequency, rate_change_start_date,
           rate_change_frequency_code, rate_change_value */
        /*
        IF (p_krpv_rec.Rate_Delay_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Delay_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Delay_Frequency = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Delay_Frequency IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Frequency');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Rate_Change_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        IF (p_krpv_rec.Rate_Change_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Change_Frequency_Code IS NULL)
        THEN
          -- Bug 4862551
          /*OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;*/
          NULL;
        ELSIF (p_krpv_rec.Rate_Change_Frequency_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Rate_Change_Frequency_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Rate_Change_Frequency_Code <> 'BILLING_DATE') THEN
            -- AKP: Todo: Set Proper Message
            --(Rate Change Frequency Code is 'BILLING_DATE' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'BILLING_DATE'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'RATE_CHANGE_FREQUENCY_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Change_Value = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Change_Value IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Value');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Option_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Option_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Option Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Next_Conversion_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Next_Conversion_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Next Conversion Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Type_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Type_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Type Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/


      ELSIF (p_int_calc_basis = 'FLOAT_FACTORS' AND p_rev_rec_method ='STREAMS') THEN
        -- Bug 4907390
        /*IF (p_krpv_rec.Base_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Base_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Base Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF; */

        IF (p_krpv_rec.Interest_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Interest_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Option_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Option_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Option Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Next_Conversion_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Next_Conversion_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Next Conversion Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Type_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Type_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Type Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        -- Bug 4753087
        IF (p_krpv_rec.Principal_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Principal_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Principal Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Principal_Basis_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Principal_Basis_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Principal_Basis_Code <> 'SCHEDULED') THEN
            -- AKP: Todo: Set Proper Message
            --(Principal Basis Code is 'SCHEDULED' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'SCHEDULED'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'PRINCIPAL_BASIS_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'FLOAT_FACTORS'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        -- Bug 4862416: For FLOAT_FACTOR, formula is required
        IF (p_krpv_rec.Calculation_Formula_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Calculation_Formula_Id IS NULL)
        THEN
          l_msg2_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Formula Name');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

      END IF; -- For FIXED and STREAMS

    END IF;  -- For LEASEDF, LEASEOP and LEASEST

    IF (p_deal_type IN ('LOAN')) THEN
      IF (p_int_calc_basis = 'FIXED' AND p_rev_rec_method = 'STREAMS') THEN
        /* AKP: ToDo: Check Base_Rate for Principal payment type only and not
                      for Rent */
        IF (p_krpv_rec.Base_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Base_Rate IS NULL)
        THEN
          OKL_K_RATE_PARAMS_PVT.check_principal_payment(
            p_api_version             => 1,
            p_init_msg_list           => OKL_API.G_FALSE,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data,
            p_chr_id                  => p_krpv_rec.khr_id,
            x_principal_payment_defined => l_principal_payment_defined);
          IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            RAISE violated_ref_integrity;
          END IF;

          IF (l_principal_payment_defined) THEN
            OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                               'Base Rate');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Option_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Option_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Option Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Next_Conversion_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Next_Conversion_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Next Conversion Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Type_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Type_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Type Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/


      /* AKP Todo: To check these lookup values correctness */
      ELSIF (p_int_calc_basis IN ('FLOAT')
             AND p_rev_rec_method = 'ESTIMATED_AND_BILLED') THEN
        IF (p_krpv_rec.Interest_Index_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Interest_Index_Id IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Index Id');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4907390
        /*IF (p_krpv_rec.Base_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Base_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Base Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        IF (p_krpv_rec.Interest_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Interest_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Adder_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Adder_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Adder Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Maximum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Maximum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Maximum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Minimum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Minimum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Minimum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Principal_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Principal_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Principal Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Month_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Month_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Month Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Year_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Year_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Year Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Interest_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Interest_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Delay_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Delay_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Delay_Frequency = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Delay_Frequency IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Frequency');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        -- Bug 4862416
        /*IF (p_krpv_rec.Compounding_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Compounding_Frequency_Code IS NULL)
        THEN
          l_msg1_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Compounding Frequency CODE');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Calculation_Formula_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Calculation_Formula_Id IS NULL)
        THEN
          l_msg2_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Formula Name');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF; */

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Change_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Rate_Change_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Change_Frequency_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Value = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Change_Value IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Value');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Option_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Option_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Option Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Next_Conversion_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Next_Conversion_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Next Conversion Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Type_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Type_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Type Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

      ELSIF (p_int_calc_basis IN ('FLOAT', 'FIXED')
             AND p_rev_rec_method = 'ACTUAL') THEN
        IF (p_krpv_rec.Interest_Index_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Interest_Index_Id IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Index Id');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4907390
        /*IF (p_krpv_rec.Base_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Base_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Base Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        IF (p_krpv_rec.Interest_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Interest_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Adder_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Adder_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Adder Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Maximum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Maximum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Maximum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Minimum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Minimum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Minimum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Principal_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Principal_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Principal Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Principal_Basis_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Principal_Basis_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Principal_Basis_Code <> 'ACTUAL') THEN
            -- AKP: Todo: Set Proper Message
            --(Principal Basis Code is 'ACTUAL' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'ACTUAL'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'PRINCIPAL_BASIS_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'FLOAT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'ACTUAL');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Month_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Month_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Month Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Year_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Year_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Year Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Interest_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Interest_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Delay_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Delay_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Delay_Frequency = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Delay_Frequency IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Frequency');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        -- Bug 4862416
        /*IF (p_krpv_rec.Compounding_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Compounding_Frequency_Code IS NULL)
        THEN
          l_msg1_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Compounding Frequency CODE');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Calculation_Formula_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Calculation_Formula_Id IS NULL)
        THEN
          l_msg2_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Formula Name');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Change_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Rate_Change_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Change_Frequency_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Value = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Change_Value IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Value');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Option_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Option_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Option Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Next_Conversion_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Next_Conversion_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Next Conversion Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Type_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Type_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Type Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

      ELSIF (p_int_calc_basis = 'REAMORT'
             AND p_rev_rec_method = 'STREAMS') THEN
        IF (p_krpv_rec.Interest_Index_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Interest_Index_Id IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Index Id');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4907390
        /*IF (p_krpv_rec.Base_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Base_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Base Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        IF (p_krpv_rec.Interest_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Interest_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Adder_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Adder_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Adder Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Maximum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Maximum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Maximum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Minimum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Minimum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Minimum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Principal_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Principal_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Principal Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Principal_Basis_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Principal_Basis_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Principal_Basis_Code <> 'SCHEDULED') THEN
            -- AKP: Todo: Set Proper Message
            --(Principal Basis Code is 'SCHEDULED' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'SCHEDULED'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'PRINCIPAL_BASIS_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Month_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Month_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Month Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Days_In_A_Month_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Days_In_A_Month_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Days_In_A_Month_Code <> '30') THEN
            -- AKP: Todo: Set Proper Message
            --(Days In A Month Code is '30' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => '30'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'DAYS_IN_A_MONTH_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Year_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Year_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Year Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Days_In_A_Year_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Days_In_A_Year_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Days_In_A_Year_Code <> '360') THEN
            -- AKP: Todo: Set Proper Message
            --(Days In A Year Code is '360' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => '360'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'DAYS_IN_A_YEAR_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Interest_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Interest_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Interest_Basis_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Interest_Basis_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Interest_Basis_Code <> 'SIMPLE') THEN
            -- AKP: Todo: Set Proper Message
            --(Interest Basis Code is 'SIMPLE' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'SIMPLE'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'INTEREST_BASIS_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Delay_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Delay_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Delay_Frequency = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Delay_Frequency IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Frequency');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Rate_Change_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        IF (p_krpv_rec.Rate_Change_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Change_Frequency_Code IS NULL)
        THEN
          -- Bug 4862551
          NULL;
          /*OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;*/
        ELSIF (p_krpv_rec.Rate_Change_Frequency_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Rate_Change_Frequency_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Rate_Change_Frequency_Code <> 'BILLING_DATE') THEN
            -- AKP: Todo: Set Proper Message
            --(Rate Change Frequency Code is 'BILLING_DATE' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'BILLING_DATE'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'RATE_CHANGE_FREQUENCY_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Change_Value = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Change_Value IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Value');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Option_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Option_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Option Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Next_Conversion_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Next_Conversion_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Next Conversion Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Type_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Type_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Type Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

      ELSIF (p_int_calc_basis = 'REAMORT'
             AND p_rev_rec_method = 'ACTUAL') THEN
        IF (p_krpv_rec.Interest_Index_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Interest_Index_Id IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Index Id');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4907390
        /*IF (p_krpv_rec.Base_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Base_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Base Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        IF (p_krpv_rec.Interest_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Interest_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Adder_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Adder_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Adder Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Maximum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Maximum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Maximum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Minimum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Minimum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Minimum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Principal_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Principal_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Principal Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Principal_Basis_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Principal_Basis_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Principal_Basis_Code <> 'SCHEDULED') THEN -- 4896751
          --IF (p_krpv_rec.Principal_Basis_Code <> 'ACTUAL') THEN -- 4753087
            -- AKP: Todo: Set Proper Message
            --(Principal Basis Code is 'ACTUAL' allowed only) -- 4753087
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          --,p_token1_value => 'ACTUAL' -- 4753087
                          ,p_token1_value => 'SCHEDULED' -- 4896751
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'PRINCIPAL_BASIS_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'REAMORT'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'ACTUAL');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Month_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Month_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Month Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Year_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Year_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Year Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Interest_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Interest_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Delay_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Delay_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Delay_Frequency = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Delay_Frequency IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Frequency');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        -- Bug 4862416
        /*IF (p_krpv_rec.Compounding_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Compounding_Frequency_Code IS NULL)
        THEN
          l_msg1_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Compounding Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Calculation_Formula_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Calculation_Formula_Id IS NULL)
        THEN
          l_msg2_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Formula Name');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        /*
        IF (p_krpv_rec.Rate_Change_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Rate_Change_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Change_Frequency_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Value = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Change_Value IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Value');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Option_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Option_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Option Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Next_Conversion_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Next_Conversion_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Next Conversion Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Type_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Type_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Type Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

      ELSIF (p_int_calc_basis = 'CATCHUP/CLEANUP'
             AND p_rev_rec_method = 'STREAMS') THEN
        IF (p_krpv_rec.Interest_Index_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Interest_Index_Id IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Index Id');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4907390
        /*IF (p_krpv_rec.Base_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Base_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Base Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        IF (p_krpv_rec.Interest_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Interest_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Adder_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Adder_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Adder Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Maximum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Maximum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Maximum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Minimum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Minimum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Minimum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Principal_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Principal_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Principal Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Principal_Basis_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Principal_Basis_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Principal_Basis_Code <> 'ACTUAL') THEN
            -- AKP: Todo: Set Proper Message
            --(Principal Basis Code is 'ACTUAL' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'ACTUAL'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'PRINCIPAL_BASIS_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'CATCHUP/CLEANUP'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Month_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Month_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Month Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Year_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Year_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Year Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Interest_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Interest_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Delay_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Delay_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Delay_Frequency = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Delay_Frequency IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Frequency');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        -- Bug 4862416
        /*IF (p_krpv_rec.Compounding_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Compounding_Frequency_Code IS NULL)
        THEN
          l_msg1_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Compounding Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Calculation_Formula_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Calculation_Formula_Id IS NULL)
        THEN
          l_msg2_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Formula Name');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        IF (p_krpv_rec.Catchup_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Catchup_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Catchup Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Catchup_Basis_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Catchup_Basis_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Catchup_Basis_Code <> 'ACTUAL') THEN
            -- AKP: Todo: Set Proper Message
            --(Catchup Basis Code is 'ACTUAL' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'ACTUAL'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'CATCHUP_BASIS_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'CATCHUP/CLEANUP'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'STREAMS');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Catchup_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Catchup_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Catchup Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Catchup_Settlement_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Catchup_Settlement_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Catchup Settlement Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Change_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Rate_Change_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Change_Frequency_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Value = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Change_Value IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Value');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Option_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Option_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Option Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Next_Conversion_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Next_Conversion_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Next Conversion Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

        /*IF (p_krpv_rec.parameter_type_code = 'ACTUAL') THEN
        IF (p_krpv_rec.Conversion_Type_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Type_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Type Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;*/

      END IF;  /* FIXED and STREAMS */
    END IF; /* LOAN */

    IF (p_deal_type IN ('LOAN-REVOLVING')) THEN
      IF (p_int_calc_basis IN ('FLOAT') AND
          p_rev_rec_method IN ('ESTIMATED_AND_BILLED', 'ACTUAL')) THEN
        IF (p_krpv_rec.Interest_Index_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Interest_Index_Id IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Index Id');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4907390
        /*IF (p_krpv_rec.Base_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Base_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Base Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        IF (p_krpv_rec.Interest_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Interest_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Adder_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Adder_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Adder Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Maximum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Maximum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Maximum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Minimum_Rate = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Minimum_Rate IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Minimum Rate');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Principal_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Principal_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Principal Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        ELSIF (p_krpv_rec.Principal_Basis_Code <> OKC_API.G_MISS_CHAR AND
               p_krpv_rec.Principal_Basis_Code IS NOT NULL) THEN
          IF (p_krpv_rec.Principal_Basis_Code <> 'ACTUAL') THEN
            -- AKP: Todo: Set Proper Message
            --(Principal Basis Code is 'ACTUAL' allowed only)
            OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => 'OKL_LA_APPLICABLE_VALUES'
                          ,p_token1       => 'VALUE'
                          ,p_token1_value => 'ACTUAL'
                          ,p_token2       => 'CODE0'
                          ,p_token2_value => 'PRINCIPAL_BASIS_CODE'
                          ,p_token3       => 'CODE1'
                          ,p_token3_value => 'LOAN-REVOLVING'
                          ,p_token4       => 'CODE2'
                          ,p_token4_value => 'FLOAT');
            l_return_status := OKC_API.G_RET_STS_ERROR;
            IF (p_stack_messages = 'N') THEN
              RAISE violated_ref_integrity;
            END IF;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Month_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Month_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Month Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Days_In_A_Year_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Days_In_A_Year_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Days In A Year Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Interest_Basis_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Interest_Basis_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Interest Basis Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Delay_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Delay_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Delay_Frequency = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Delay_Frequency IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Delay Frequency');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        -- Bug 4862416
        /*IF (p_krpv_rec.Compounding_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Compounding_Frequency_Code IS NULL)
        THEN
          l_msg1_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Compounding Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Calculation_Formula_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Calculation_Formula_Id IS NULL)
        THEN
          l_msg2_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Formula Name');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        -- Bug 4862551
        /*
        IF (p_krpv_rec.Rate_Change_Start_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Rate_Change_Start_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Start Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Rate_Change_Frequency_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;

        IF (p_krpv_rec.Rate_Change_Value = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Rate_Change_Value IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Rate Change Value');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        */

        /*IF (p_krpv_rec.Conversion_Option_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Option_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Option Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        /*IF (p_krpv_rec.Next_Conversion_Date = OKC_API.G_MISS_DATE OR
            p_krpv_rec.Next_Conversion_Date IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Next Conversion Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

        /*IF (p_krpv_rec.Conversion_Type_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Conversion_Type_Code IS NULL)
        THEN
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Conversion Type Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;*/

      END IF;
    END IF;

    -- Bug 4862416: For interest basis code 'COMPOUND', formula is required
    -- and compounding_frqeuency_code is required.
    IF (p_krpv_rec.Interest_Basis_Code IS NOT NULL AND
        p_krpv_rec.Interest_Basis_Code <> OKC_API.G_MISS_CHAR) THEN

      IF (p_krpv_rec.Interest_Basis_Code = 'COMPOUND') THEN

        IF NOT(l_msg1_set) THEN
        IF (p_krpv_rec.Compounding_Frequency_Code = OKC_API.G_MISS_CHAR OR
            p_krpv_rec.Compounding_Frequency_Code IS NULL)
        THEN
          l_msg1_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Compounding Frequency Code');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;

        IF NOT(l_msg2_set) THEN
        IF (p_krpv_rec.Calculation_Formula_Id = OKC_API.G_MISS_NUM OR
            p_krpv_rec.Calculation_Formula_Id IS NULL)
        THEN
          l_msg2_set := TRUE;
          OKC_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                             'Formula Name');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          IF (p_stack_messages = 'N') THEN
            RAISE violated_ref_integrity;
          END IF;
        END IF;
        END IF;

      END IF;

    END IF;

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) AND
       (p_stack_messages = 'N') THEN
      RAISE violated_ref_integrity;
    END IF;

    /* AKP: Todo: IF Payments are in 'Advance' the rate delay should be more
       than print lead days. Done in OKLRKRPB.pls */

    RETURN (l_return_status);

    EXCEPTION
      WHEN violated_ref_integrity THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN krpv_rec_type,
    p_to   IN OUT NOCOPY krp_rec_type
  ) IS
  BEGIN
    p_to.khr_id := p_from.khr_id;
    p_to.parameter_type_code := p_from.parameter_type_code;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.interest_index_id := p_from.interest_index_id;
    p_to.base_rate := p_from.base_rate;
    p_to.interest_start_date := p_from.interest_start_date;
    p_to.adder_rate := p_from.adder_rate;
    p_to.maximum_rate := p_from.maximum_rate;
    p_to.minimum_rate := p_from.minimum_rate;
    p_to.principal_basis_code := p_from.principal_basis_code;
    p_to.days_in_a_month_code := p_from.days_in_a_month_code;
    p_to.days_in_a_year_code := p_from.days_in_a_year_code;
    p_to.interest_basis_code := p_from.interest_basis_code;
    p_to.rate_delay_code := p_from.rate_delay_code;
    p_to.rate_delay_frequency := p_from.rate_delay_frequency;
    p_to.compounding_frequency_code := p_from.compounding_frequency_code;
    p_to.calculation_formula_id := p_from.calculation_formula_id;
    p_to.catchup_basis_code := p_from.catchup_basis_code;
    p_to.catchup_start_date := p_from.catchup_start_date;
    p_to.catchup_settlement_code := p_from.catchup_settlement_code;
    p_to.rate_change_start_date := p_from.rate_change_start_date;
    p_to.rate_change_frequency_code := p_from.rate_change_frequency_code;
    p_to.rate_change_value := p_from.rate_change_value;
    p_to.conversion_option_code := p_from.conversion_option_code;
    p_to.next_conversion_date := p_from.next_conversion_date;
    p_to.conversion_type_code := p_from.conversion_type_code;
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
    p_to.catchup_frequency_code := p_from.catchup_frequency_code;
  END migrate;
  PROCEDURE migrate (
    p_from IN krp_rec_type,
    p_to   IN OUT NOCOPY krpv_rec_type
  ) IS
  BEGIN
    p_to.khr_id := p_from.khr_id;
    p_to.parameter_type_code := p_from.parameter_type_code;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.interest_index_id := p_from.interest_index_id;
    p_to.base_rate := p_from.base_rate;
    p_to.interest_start_date := p_from.interest_start_date;
    p_to.adder_rate := p_from.adder_rate;
    p_to.maximum_rate := p_from.maximum_rate;
    p_to.minimum_rate := p_from.minimum_rate;
    p_to.principal_basis_code := p_from.principal_basis_code;
    p_to.days_in_a_month_code := p_from.days_in_a_month_code;
    p_to.days_in_a_year_code := p_from.days_in_a_year_code;
    p_to.interest_basis_code := p_from.interest_basis_code;
    p_to.rate_delay_code := p_from.rate_delay_code;
    p_to.rate_delay_frequency := p_from.rate_delay_frequency;
    p_to.compounding_frequency_code := p_from.compounding_frequency_code;
    p_to.calculation_formula_id := p_from.calculation_formula_id;
    p_to.catchup_basis_code := p_from.catchup_basis_code;
    p_to.catchup_start_date := p_from.catchup_start_date;
    p_to.catchup_settlement_code := p_from.catchup_settlement_code;
    p_to.rate_change_start_date := p_from.rate_change_start_date;
    p_to.rate_change_frequency_code := p_from.rate_change_frequency_code;
    p_to.rate_change_value := p_from.rate_change_value;
    p_to.conversion_option_code := p_from.conversion_option_code;
    p_to.next_conversion_date := p_from.next_conversion_date;
    p_to.conversion_type_code := p_from.conversion_type_code;
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
    p_to.catchup_frequency_code := p_from.catchup_frequency_code;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_K_RATE_PARAMS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN krpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_krpv_rec                     krpv_rec_type := p_krpv_rec;
    l_krp_rec                      krp_rec_type;
    l_krp_rec                      krp_rec_type;
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
    l_return_status := Validate_Attributes(l_krpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_krpv_rec);
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
  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_K_RATE_PARAMS_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_krpv_tbl.COUNT > 0) THEN
      i := p_krpv_tbl.FIRST;
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
            p_krpv_rec                     => p_krpv_tbl(i));
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
        EXIT WHEN (i = p_krpv_tbl.LAST);
        i := p_krpv_tbl.NEXT(i);
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

  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_K_RATE_PARAMS_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_krpv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_krpv_tbl                     => p_krpv_tbl,
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

/* Custom validation routine, overloaded */
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_deal_type                    IN  VARCHAR2,
    p_rev_rec_method               IN  VARCHAR2,
    p_int_calc_basis               IN  VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    p_stack_messages               IN VARCHAR2 DEFAULT 'N',
    p_validate_flag                IN VARCHAR2 DEFAULT 'Y') IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    --l_krpv_rec                     krpv_rec_type := p_krpv_rec;
    l_krpv_rec                     krpv_rec_type;
    l_krp_rec                      krp_rec_type;
    l_krp_rec                      krp_rec_type;

    i NUMBER;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  '_PVT',
                                                  x_return_status);
    IF (p_stack_messages = 'N') THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In validate_row... p_krpv_tbl.count=' || p_krpv_tbl.count);
    END IF;
    IF (p_krpv_tbl.COUNT > 0) THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside ...');
      END IF;
      i := p_krpv_tbl.FIRST;
      LOOP
        l_krpv_rec := p_krpv_tbl(i);

        --- Validate all non-missing attributes (Item Level Validation)
        l_return_status := Validate_Attributes(l_krpv_rec, p_stack_messages);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_attributes...l_return_status='||l_return_status);
        END IF;
        IF (p_stack_messages = 'N') THEN
          --- If any errors happen abort API
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        IF (nvl(p_validate_flag, 'Y') = 'F') THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Calling validate_record...');
        END IF;
          l_return_status := Validate_Record(l_krpv_rec,
                                             p_stack_messages,
                                             p_deal_type,
                                             p_rev_rec_method,
                                             p_int_calc_basis);
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_record l_return_status=' || l_return_status);
          END IF;
          IF (p_stack_messages = 'N') THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
        END IF;
        x_return_status := l_return_status;
        EXIT WHEN ( i = p_krpv_tbl.LAST);
        i := p_krpv_tbl.NEXT(i);
      END LOOP;
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
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- insert_row for:OKL_K_RATE_PARAMS --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krp_rec                      IN krp_rec_type,
    x_krp_rec                      OUT NOCOPY krp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_krp_rec                      krp_rec_type := p_krp_rec;
    l_def_krp_rec                  krp_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_K_RATE_PARAMS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_krp_rec IN krp_rec_type,
      x_krp_rec OUT NOCOPY krp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_krp_rec := p_krp_rec;
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
      p_krp_rec,                         -- IN
      l_krp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_K_RATE_PARAMS(
      khr_id,
      parameter_type_code,
      effective_from_date,
      effective_to_date,
      interest_index_id,
      base_rate,
      interest_start_date,
      adder_rate,
      maximum_rate,
      minimum_rate,
      principal_basis_code,
      days_in_a_month_code,
      days_in_a_year_code,
      interest_basis_code,
      rate_delay_code,
      rate_delay_frequency,
      compounding_frequency_code,
      calculation_formula_id,
      catchup_basis_code,
      catchup_start_date,
      catchup_settlement_code,
      rate_change_start_date,
      rate_change_frequency_code,
      rate_change_value,
      conversion_option_code,
      next_conversion_date,
      conversion_type_code,
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
      catchup_frequency_code)
    VALUES (
      l_krp_rec.khr_id,
      l_krp_rec.parameter_type_code,
      l_krp_rec.effective_from_date,
      l_krp_rec.effective_to_date,
      l_krp_rec.interest_index_id,
      l_krp_rec.base_rate,
      l_krp_rec.interest_start_date,
      l_krp_rec.adder_rate,
      l_krp_rec.maximum_rate,
      l_krp_rec.minimum_rate,
      l_krp_rec.principal_basis_code,
      l_krp_rec.days_in_a_month_code,
      l_krp_rec.days_in_a_year_code,
      l_krp_rec.interest_basis_code,
      l_krp_rec.rate_delay_code,
      l_krp_rec.rate_delay_frequency,
      l_krp_rec.compounding_frequency_code,
      l_krp_rec.calculation_formula_id,
      l_krp_rec.catchup_basis_code,
      l_krp_rec.catchup_start_date,
      l_krp_rec.catchup_settlement_code,
      l_krp_rec.rate_change_start_date,
      l_krp_rec.rate_change_frequency_code,
      l_krp_rec.rate_change_value,
      l_krp_rec.conversion_option_code,
      l_krp_rec.next_conversion_date,
      l_krp_rec.conversion_type_code,
      l_krp_rec.attribute_category,
      l_krp_rec.attribute1,
      l_krp_rec.attribute2,
      l_krp_rec.attribute3,
      l_krp_rec.attribute4,
      l_krp_rec.attribute5,
      l_krp_rec.attribute6,
      l_krp_rec.attribute7,
      l_krp_rec.attribute8,
      l_krp_rec.attribute9,
      l_krp_rec.attribute10,
      l_krp_rec.attribute11,
      l_krp_rec.attribute12,
      l_krp_rec.attribute13,
      l_krp_rec.attribute14,
      l_krp_rec.attribute15,
      l_krp_rec.created_by,
      l_krp_rec.creation_date,
      l_krp_rec.last_updated_by,
      l_krp_rec.last_update_date,
      l_krp_rec.last_update_login,
      l_krp_rec.catchup_frequency_code);
    -- Set OUT values
    x_krp_rec := l_krp_rec;
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
  -----------------------------------------
  -- insert_row for :OKL_K_RATE_PARAMS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN krpv_rec_type,
    x_krpv_rec                     OUT NOCOPY krpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_krpv_rec                     krpv_rec_type := p_krpv_rec;
    l_def_krpv_rec                 krpv_rec_type;
    l_krp_rec                      krp_rec_type;
    lx_krp_rec                     krp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_krpv_rec IN krpv_rec_type
    ) RETURN krpv_rec_type IS
      l_krpv_rec krpv_rec_type := p_krpv_rec;
    BEGIN
      l_krpv_rec.CREATION_DATE := SYSDATE;
      l_krpv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_krpv_rec.LAST_UPDATE_DATE := l_krpv_rec.CREATION_DATE;
      l_krpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_krpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_krpv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_K_RATE_PARAMS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_krpv_rec IN krpv_rec_type,
      x_krpv_rec OUT NOCOPY krpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_krpv_rec := p_krpv_rec;
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
    l_krpv_rec := null_out_defaults(p_krpv_rec);
    -- Set primary key value
    -- Error: Multiple columns make up the Primary Key
    --        Cannot assign get_seq_id
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_krpv_rec,                        -- IN
      l_def_krpv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_krpv_rec := fill_who_columns(l_def_krpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_krpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_krpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_krpv_rec, l_krp_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_krp_rec,
      lx_krp_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_krp_rec, l_def_krpv_rec);
    -- Set OUT values
    x_krpv_rec := l_def_krpv_rec;
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
  -- PL/SQL TBL insert_row for:KRPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    x_krpv_tbl                     OUT NOCOPY krpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_krpv_tbl.COUNT > 0) THEN
      i := p_krpv_tbl.FIRST;
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
            p_krpv_rec                     => p_krpv_tbl(i),
            x_krpv_rec                     => x_krpv_tbl(i));
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
        EXIT WHEN (i = p_krpv_tbl.LAST);
        i := p_krpv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:KRPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    x_krpv_tbl                     OUT NOCOPY krpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_krpv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_krpv_tbl                     => p_krpv_tbl,
        x_krpv_tbl                     => x_krpv_tbl,
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
  ------------------------------------
  -- lock_row for:OKL_K_RATE_PARAMS --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krp_rec                      IN krp_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_krp_rec IN krp_rec_type) IS
    SELECT *
      FROM OKL_K_RATE_PARAMS
     WHERE PARAMETER_TYPE_CODE = p_krp_rec.parameter_type_code
       AND EFFECTIVE_FROM_DATE = p_krp_rec.effective_from_date
       AND KHR_ID = p_krp_rec.khr_id
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
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_krp_rec);
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
      IF (l_lock_var.khr_id <> p_krp_rec.khr_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.parameter_type_code <> p_krp_rec.parameter_type_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.effective_from_date <> p_krp_rec.effective_from_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.effective_to_date <> p_krp_rec.effective_to_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.interest_index_id <> p_krp_rec.interest_index_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.base_rate <> p_krp_rec.base_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.interest_start_date <> p_krp_rec.interest_start_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.adder_rate <> p_krp_rec.adder_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.maximum_rate <> p_krp_rec.maximum_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.minimum_rate <> p_krp_rec.minimum_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.principal_basis_code <> p_krp_rec.principal_basis_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.days_in_a_month_code <> p_krp_rec.days_in_a_month_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.days_in_a_year_code <> p_krp_rec.days_in_a_year_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.interest_basis_code <> p_krp_rec.interest_basis_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rate_delay_code <> p_krp_rec.rate_delay_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rate_delay_frequency <> p_krp_rec.rate_delay_frequency) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.compounding_frequency_code <> p_krp_rec.compounding_frequency_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.calculation_formula_id <> p_krp_rec.calculation_formula_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.catchup_basis_code <> p_krp_rec.catchup_basis_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.catchup_start_date <> p_krp_rec.catchup_start_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.catchup_settlement_code <> p_krp_rec.catchup_settlement_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rate_change_start_date <> p_krp_rec.rate_change_start_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rate_change_frequency_code <> p_krp_rec.rate_change_frequency_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.rate_change_value <> p_krp_rec.rate_change_value) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.conversion_option_code <> p_krp_rec.conversion_option_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.next_conversion_date <> p_krp_rec.next_conversion_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.conversion_type_code <> p_krp_rec.conversion_type_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute_category <> p_krp_rec.attribute_category) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute1 <> p_krp_rec.attribute1) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute2 <> p_krp_rec.attribute2) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute3 <> p_krp_rec.attribute3) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute4 <> p_krp_rec.attribute4) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute5 <> p_krp_rec.attribute5) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute6 <> p_krp_rec.attribute6) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute7 <> p_krp_rec.attribute7) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute8 <> p_krp_rec.attribute8) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute9 <> p_krp_rec.attribute9) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute10 <> p_krp_rec.attribute10) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute11 <> p_krp_rec.attribute11) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute12 <> p_krp_rec.attribute12) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute13 <> p_krp_rec.attribute13) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute14 <> p_krp_rec.attribute14) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute15 <> p_krp_rec.attribute15) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.created_by <> p_krp_rec.created_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.creation_date <> p_krp_rec.creation_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_updated_by <> p_krp_rec.last_updated_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_date <> p_krp_rec.last_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_login <> p_krp_rec.last_update_login) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.catchup_frequency_code <> p_krp_rec.catchup_frequency_code) THEN
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
  ---------------------------------------
  -- lock_row for: OKL_K_RATE_PARAMS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN krpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_krp_rec                      krp_rec_type;
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
    migrate(p_krpv_rec, l_krp_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_krp_rec
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
  -- PL/SQL TBL lock_row for:KRPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_krpv_tbl.COUNT > 0) THEN
      i := p_krpv_tbl.FIRST;
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
            p_krpv_rec                     => p_krpv_tbl(i));
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
        EXIT WHEN (i = p_krpv_tbl.LAST);
        i := p_krpv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:KRPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_krpv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_krpv_tbl                     => p_krpv_tbl,
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
  --------------------------------------
  -- update_row for:OKL_K_RATE_PARAMS --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krp_rec                      IN krp_rec_type,
    x_krp_rec                      OUT NOCOPY krp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_krp_rec                      krp_rec_type := p_krp_rec;
    l_def_krp_rec                  krp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_krp_rec IN krp_rec_type,
      x_krp_rec OUT NOCOPY krp_rec_type
    ) RETURN VARCHAR2 IS
      l_krp_rec                      krp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_krp_rec := p_krp_rec;
      -- Get current database values
      l_krp_rec := get_rec(p_krp_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_krp_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.khr_id := l_krp_rec.khr_id;
        END IF;
        IF (x_krp_rec.parameter_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.parameter_type_code := l_krp_rec.parameter_type_code;
        END IF;
        IF (x_krp_rec.effective_from_date = OKC_API.G_MISS_DATE)
        THEN
          x_krp_rec.effective_from_date := l_krp_rec.effective_from_date;
        END IF;
        IF (x_krp_rec.effective_to_date = OKC_API.G_MISS_DATE)
        THEN
          x_krp_rec.effective_to_date := l_krp_rec.effective_to_date;
        END IF;
        IF (x_krp_rec.interest_index_id = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.interest_index_id := l_krp_rec.interest_index_id;
        END IF;
        IF (x_krp_rec.base_rate = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.base_rate := l_krp_rec.base_rate;
        END IF;
        IF (x_krp_rec.interest_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_krp_rec.interest_start_date := l_krp_rec.interest_start_date;
        END IF;
        IF (x_krp_rec.adder_rate = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.adder_rate := l_krp_rec.adder_rate;
        END IF;
        IF (x_krp_rec.maximum_rate = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.maximum_rate := l_krp_rec.maximum_rate;
        END IF;
        IF (x_krp_rec.minimum_rate = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.minimum_rate := l_krp_rec.minimum_rate;
        END IF;
        IF (x_krp_rec.principal_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.principal_basis_code := l_krp_rec.principal_basis_code;
        END IF;
        IF (x_krp_rec.days_in_a_month_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.days_in_a_month_code := l_krp_rec.days_in_a_month_code;
        END IF;
        IF (x_krp_rec.days_in_a_year_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.days_in_a_year_code := l_krp_rec.days_in_a_year_code;
        END IF;
        IF (x_krp_rec.interest_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.interest_basis_code := l_krp_rec.interest_basis_code;
        END IF;
        IF (x_krp_rec.rate_delay_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.rate_delay_code := l_krp_rec.rate_delay_code;
        END IF;
        IF (x_krp_rec.rate_delay_frequency = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.rate_delay_frequency := l_krp_rec.rate_delay_frequency;
        END IF;
        IF (x_krp_rec.compounding_frequency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.compounding_frequency_code := l_krp_rec.compounding_frequency_code;
        END IF;
        IF (x_krp_rec.calculation_formula_id = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.calculation_formula_id := l_krp_rec.calculation_formula_id;
        END IF;
        IF (x_krp_rec.catchup_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.catchup_basis_code := l_krp_rec.catchup_basis_code;
        END IF;
        IF (x_krp_rec.catchup_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_krp_rec.catchup_start_date := l_krp_rec.catchup_start_date;
        END IF;
        IF (x_krp_rec.catchup_settlement_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.catchup_settlement_code := l_krp_rec.catchup_settlement_code;
        END IF;
        IF (x_krp_rec.rate_change_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_krp_rec.rate_change_start_date := l_krp_rec.rate_change_start_date;
        END IF;
        IF (x_krp_rec.rate_change_frequency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.rate_change_frequency_code := l_krp_rec.rate_change_frequency_code;
        END IF;
        IF (x_krp_rec.rate_change_value = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.rate_change_value := l_krp_rec.rate_change_value;
        END IF;
        IF (x_krp_rec.conversion_option_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.conversion_option_code := l_krp_rec.conversion_option_code;
        END IF;
        IF (x_krp_rec.next_conversion_date = OKC_API.G_MISS_DATE)
        THEN
          x_krp_rec.next_conversion_date := l_krp_rec.next_conversion_date;
        END IF;
        IF (x_krp_rec.conversion_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.conversion_type_code := l_krp_rec.conversion_type_code;
        END IF;
        IF (x_krp_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute_category := l_krp_rec.attribute_category;
        END IF;
        IF (x_krp_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute1 := l_krp_rec.attribute1;
        END IF;
        IF (x_krp_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute2 := l_krp_rec.attribute2;
        END IF;
        IF (x_krp_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute3 := l_krp_rec.attribute3;
        END IF;
        IF (x_krp_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute4 := l_krp_rec.attribute4;
        END IF;
        IF (x_krp_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute5 := l_krp_rec.attribute5;
        END IF;
        IF (x_krp_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute6 := l_krp_rec.attribute6;
        END IF;
        IF (x_krp_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute7 := l_krp_rec.attribute7;
        END IF;
        IF (x_krp_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute8 := l_krp_rec.attribute8;
        END IF;
        IF (x_krp_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute9 := l_krp_rec.attribute9;
        END IF;
        IF (x_krp_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute10 := l_krp_rec.attribute10;
        END IF;
        IF (x_krp_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute11 := l_krp_rec.attribute11;
        END IF;
        IF (x_krp_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute12 := l_krp_rec.attribute12;
        END IF;
        IF (x_krp_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute13 := l_krp_rec.attribute13;
        END IF;
        IF (x_krp_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute14 := l_krp_rec.attribute14;
        END IF;
        IF (x_krp_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.attribute15 := l_krp_rec.attribute15;
        END IF;
        IF (x_krp_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.created_by := l_krp_rec.created_by;
        END IF;
        IF (x_krp_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_krp_rec.creation_date := l_krp_rec.creation_date;
        END IF;
        IF (x_krp_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.last_updated_by := l_krp_rec.last_updated_by;
        END IF;
        IF (x_krp_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_krp_rec.last_update_date := l_krp_rec.last_update_date;
        END IF;
        IF (x_krp_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_krp_rec.last_update_login := l_krp_rec.last_update_login;
        END IF;
        IF (x_krp_rec.catchup_frequency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krp_rec.catchup_frequency_code := l_krp_rec.catchup_frequency_code;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_K_RATE_PARAMS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_krp_rec IN krp_rec_type,
      x_krp_rec OUT NOCOPY krp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_krp_rec := p_krp_rec;
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
      p_krp_rec,                         -- IN
      l_krp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_krp_rec, l_def_krp_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_K_RATE_PARAMS
    SET EFFECTIVE_TO_DATE = l_def_krp_rec.effective_to_date,
        INTEREST_INDEX_ID = l_def_krp_rec.interest_index_id,
        BASE_RATE = l_def_krp_rec.base_rate,
        INTEREST_START_DATE = l_def_krp_rec.interest_start_date,
        ADDER_RATE = l_def_krp_rec.adder_rate,
        MAXIMUM_RATE = l_def_krp_rec.maximum_rate,
        MINIMUM_RATE = l_def_krp_rec.minimum_rate,
        PRINCIPAL_BASIS_CODE = l_def_krp_rec.principal_basis_code,
        DAYS_IN_A_MONTH_CODE = l_def_krp_rec.days_in_a_month_code,
        DAYS_IN_A_YEAR_CODE = l_def_krp_rec.days_in_a_year_code,
        INTEREST_BASIS_CODE = l_def_krp_rec.interest_basis_code,
        RATE_DELAY_CODE = l_def_krp_rec.rate_delay_code,
        RATE_DELAY_FREQUENCY = l_def_krp_rec.rate_delay_frequency,
        COMPOUNDING_FREQUENCY_CODE = l_def_krp_rec.compounding_frequency_code,
        CALCULATION_FORMULA_ID = l_def_krp_rec.calculation_formula_id,
        CATCHUP_BASIS_CODE = l_def_krp_rec.catchup_basis_code,
        CATCHUP_START_DATE = l_def_krp_rec.catchup_start_date,
        CATCHUP_SETTLEMENT_CODE = l_def_krp_rec.catchup_settlement_code,
        RATE_CHANGE_START_DATE = l_def_krp_rec.rate_change_start_date,
        RATE_CHANGE_FREQUENCY_CODE = l_def_krp_rec.rate_change_frequency_code,
        RATE_CHANGE_VALUE = l_def_krp_rec.rate_change_value,
        CONVERSION_OPTION_CODE = l_def_krp_rec.conversion_option_code,
        NEXT_CONVERSION_DATE = l_def_krp_rec.next_conversion_date,
        CONVERSION_TYPE_CODE = l_def_krp_rec.conversion_type_code,
        ATTRIBUTE_CATEGORY = l_def_krp_rec.attribute_category,
        ATTRIBUTE1 = l_def_krp_rec.attribute1,
        ATTRIBUTE2 = l_def_krp_rec.attribute2,
        ATTRIBUTE3 = l_def_krp_rec.attribute3,
        ATTRIBUTE4 = l_def_krp_rec.attribute4,
        ATTRIBUTE5 = l_def_krp_rec.attribute5,
        ATTRIBUTE6 = l_def_krp_rec.attribute6,
        ATTRIBUTE7 = l_def_krp_rec.attribute7,
        ATTRIBUTE8 = l_def_krp_rec.attribute8,
        ATTRIBUTE9 = l_def_krp_rec.attribute9,
        ATTRIBUTE10 = l_def_krp_rec.attribute10,
        ATTRIBUTE11 = l_def_krp_rec.attribute11,
        ATTRIBUTE12 = l_def_krp_rec.attribute12,
        ATTRIBUTE13 = l_def_krp_rec.attribute13,
        ATTRIBUTE14 = l_def_krp_rec.attribute14,
        ATTRIBUTE15 = l_def_krp_rec.attribute15,
        CREATED_BY = l_def_krp_rec.created_by,
        CREATION_DATE = l_def_krp_rec.creation_date,
        LAST_UPDATED_BY = l_def_krp_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_krp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_krp_rec.last_update_login,
        CATCHUP_FREQUENCY_CODE = l_def_krp_rec.catchup_frequency_code
    WHERE PARAMETER_TYPE_CODE = l_def_krp_rec.parameter_type_code      AND EFFECTIVE_FROM_DATE = l_def_krp_rec.effective_from_date      AND KHR_ID = l_def_krp_rec.khr_id;

    x_krp_rec := l_krp_rec;
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
  -- update_row for:OKL_K_RATE_PARAMS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN krpv_rec_type,
    x_krpv_rec                     OUT NOCOPY krpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_krpv_rec                     krpv_rec_type := p_krpv_rec;
    l_def_krpv_rec                 krpv_rec_type;
    l_db_krpv_rec                  krpv_rec_type;
    l_krp_rec                      krp_rec_type;
    lx_krp_rec                     krp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_krpv_rec IN krpv_rec_type
    ) RETURN krpv_rec_type IS
      l_krpv_rec krpv_rec_type := p_krpv_rec;
    BEGIN
      l_krpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_krpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_krpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_krpv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_krpv_rec IN krpv_rec_type,
      x_krpv_rec OUT NOCOPY krpv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_krpv_rec := p_krpv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_krpv_rec := get_rec(p_krpv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_krpv_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.khr_id := l_db_krpv_rec.khr_id;
        END IF;
        IF (x_krpv_rec.parameter_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.parameter_type_code := l_db_krpv_rec.parameter_type_code;
        END IF;
        IF (x_krpv_rec.effective_from_date = OKC_API.G_MISS_DATE)
        THEN
          x_krpv_rec.effective_from_date := l_db_krpv_rec.effective_from_date;
        END IF;
        IF (x_krpv_rec.effective_to_date = OKC_API.G_MISS_DATE)
        THEN
          x_krpv_rec.effective_to_date := l_db_krpv_rec.effective_to_date;
        END IF;
        IF (x_krpv_rec.interest_index_id = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.interest_index_id := l_db_krpv_rec.interest_index_id;
        END IF;
        IF (x_krpv_rec.base_rate = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.base_rate := l_db_krpv_rec.base_rate;
        END IF;
        IF (x_krpv_rec.interest_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_krpv_rec.interest_start_date := l_db_krpv_rec.interest_start_date;
        END IF;
        IF (x_krpv_rec.adder_rate = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.adder_rate := l_db_krpv_rec.adder_rate;
        END IF;
        IF (x_krpv_rec.maximum_rate = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.maximum_rate := l_db_krpv_rec.maximum_rate;
        END IF;
        IF (x_krpv_rec.minimum_rate = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.minimum_rate := l_db_krpv_rec.minimum_rate;
        END IF;
        IF (x_krpv_rec.principal_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.principal_basis_code := l_db_krpv_rec.principal_basis_code;
        END IF;
        IF (x_krpv_rec.days_in_a_month_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.days_in_a_month_code := l_db_krpv_rec.days_in_a_month_code;
        END IF;
        IF (x_krpv_rec.days_in_a_year_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.days_in_a_year_code := l_db_krpv_rec.days_in_a_year_code;
        END IF;
        IF (x_krpv_rec.interest_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.interest_basis_code := l_db_krpv_rec.interest_basis_code;
        END IF;
        IF (x_krpv_rec.rate_delay_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.rate_delay_code := l_db_krpv_rec.rate_delay_code;
        END IF;
        IF (x_krpv_rec.rate_delay_frequency = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.rate_delay_frequency := l_db_krpv_rec.rate_delay_frequency;
        END IF;
        IF (x_krpv_rec.compounding_frequency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.compounding_frequency_code := l_db_krpv_rec.compounding_frequency_code;
        END IF;
        IF (x_krpv_rec.calculation_formula_id = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.calculation_formula_id := l_db_krpv_rec.calculation_formula_id;
        END IF;
        IF (x_krpv_rec.catchup_basis_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.catchup_basis_code := l_db_krpv_rec.catchup_basis_code;
        END IF;
        IF (x_krpv_rec.catchup_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_krpv_rec.catchup_start_date := l_db_krpv_rec.catchup_start_date;
        END IF;
        IF (x_krpv_rec.catchup_settlement_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.catchup_settlement_code := l_db_krpv_rec.catchup_settlement_code;
        END IF;
        IF (x_krpv_rec.rate_change_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_krpv_rec.rate_change_start_date := l_db_krpv_rec.rate_change_start_date;
        END IF;
        IF (x_krpv_rec.rate_change_frequency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.rate_change_frequency_code := l_db_krpv_rec.rate_change_frequency_code;
        END IF;
        IF (x_krpv_rec.rate_change_value = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.rate_change_value := l_db_krpv_rec.rate_change_value;
        END IF;
        IF (x_krpv_rec.conversion_option_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.conversion_option_code := l_db_krpv_rec.conversion_option_code;
        END IF;
        IF (x_krpv_rec.next_conversion_date = OKC_API.G_MISS_DATE)
        THEN
          x_krpv_rec.next_conversion_date := l_db_krpv_rec.next_conversion_date;
        END IF;
        IF (x_krpv_rec.conversion_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.conversion_type_code := l_db_krpv_rec.conversion_type_code;
        END IF;
        IF (x_krpv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute_category := l_db_krpv_rec.attribute_category;
        END IF;
        IF (x_krpv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute1 := l_db_krpv_rec.attribute1;
        END IF;
        IF (x_krpv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute2 := l_db_krpv_rec.attribute2;
        END IF;
        IF (x_krpv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute3 := l_db_krpv_rec.attribute3;
        END IF;
        IF (x_krpv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute4 := l_db_krpv_rec.attribute4;
        END IF;
        IF (x_krpv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute5 := l_db_krpv_rec.attribute5;
        END IF;
        IF (x_krpv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute6 := l_db_krpv_rec.attribute6;
        END IF;
        IF (x_krpv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute7 := l_db_krpv_rec.attribute7;
        END IF;
        IF (x_krpv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute8 := l_db_krpv_rec.attribute8;
        END IF;
        IF (x_krpv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute9 := l_db_krpv_rec.attribute9;
        END IF;
        IF (x_krpv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute10 := l_db_krpv_rec.attribute10;
        END IF;
        IF (x_krpv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute11 := l_db_krpv_rec.attribute11;
        END IF;
        IF (x_krpv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute12 := l_db_krpv_rec.attribute12;
        END IF;
        IF (x_krpv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute13 := l_db_krpv_rec.attribute13;
        END IF;
        IF (x_krpv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute14 := l_db_krpv_rec.attribute14;
        END IF;
        IF (x_krpv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.attribute15 := l_db_krpv_rec.attribute15;
        END IF;
        IF (x_krpv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.created_by := l_db_krpv_rec.created_by;
        END IF;
        IF (x_krpv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_krpv_rec.creation_date := l_db_krpv_rec.creation_date;
        END IF;
        IF (x_krpv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.last_updated_by := l_db_krpv_rec.last_updated_by;
        END IF;
        IF (x_krpv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_krpv_rec.last_update_date := l_db_krpv_rec.last_update_date;
        END IF;
        IF (x_krpv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_krpv_rec.last_update_login := l_db_krpv_rec.last_update_login;
        END IF;
        IF (x_krpv_rec.catchup_frequency_code = OKC_API.G_MISS_CHAR)
        THEN
          x_krpv_rec.catchup_frequency_code := l_db_krpv_rec.catchup_frequency_code;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_K_RATE_PARAMS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_krpv_rec IN krpv_rec_type,
      x_krpv_rec OUT NOCOPY krpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_krpv_rec := p_krpv_rec;
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
      p_krpv_rec,                        -- IN
      x_krpv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_krpv_rec, l_def_krpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_krpv_rec := fill_who_columns(l_def_krpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_krpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_krpv_rec, l_db_krpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/****Commented**********
    --avsingh
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_krpv_rec                     => p_krpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
**************************/
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_krpv_rec, l_krp_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_krp_rec,
      lx_krp_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_krp_rec, l_def_krpv_rec);
    x_krpv_rec := l_def_krpv_rec;
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
  -- PL/SQL TBL update_row for:krpv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    x_krpv_tbl                     OUT NOCOPY krpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_krpv_tbl.COUNT > 0) THEN
      i := p_krpv_tbl.FIRST;
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
            p_krpv_rec                     => p_krpv_tbl(i),
            x_krpv_rec                     => x_krpv_tbl(i));
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
        EXIT WHEN (i = p_krpv_tbl.LAST);
        i := p_krpv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:KRPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    x_krpv_tbl                     OUT NOCOPY krpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_krpv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_krpv_tbl                     => p_krpv_tbl,
        x_krpv_tbl                     => x_krpv_tbl,
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
  --------------------------------------
  -- delete_row for:OKL_K_RATE_PARAMS --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krp_rec                      IN krp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_krp_rec                      krp_rec_type := p_krp_rec;
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

    DELETE FROM OKL_K_RATE_PARAMS
     WHERE PARAMETER_TYPE_CODE = p_krp_rec.parameter_type_code
       AND EFFECTIVE_FROM_DATE = p_krp_rec.effective_from_date
       AND KHR_ID = p_krp_rec.khr_id;

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
  ----------------------------------------
  -- delete_row for:OKL_K_RATE_PARAMS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN krpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_krpv_rec                     krpv_rec_type := p_krpv_rec;
    l_krp_rec                      krp_rec_type;
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
    migrate(l_krpv_rec, l_krp_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_krp_rec
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
  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_K_RATE_PARAMS_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_krpv_tbl.COUNT > 0) THEN
      i := p_krpv_tbl.FIRST;
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
            p_krpv_rec                     => p_krpv_tbl(i));
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
        EXIT WHEN (i = p_krpv_tbl.LAST);
        i := p_krpv_tbl.NEXT(i);
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

  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_K_RATE_PARAMS_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_krpv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_krpv_tbl                     => p_krpv_tbl,
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

END OKL_KRP_PVT;

/
