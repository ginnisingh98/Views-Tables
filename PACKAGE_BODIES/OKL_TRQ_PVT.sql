--------------------------------------------------------
--  DDL for Package Body OKL_TRQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRQ_PVT" AS
/* $Header: OKLSTRQB.pls 120.7 2007/03/14 12:25:35 dkagrawa noship $ */

 --Hand coded
  G_STATUS_LOOKUP_TYPE            CONSTANT VARCHAR2(200)  := 'OKL_REQUEST_STATUS';
  G_NO_MATCHING_RECORD         	  CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
  G_APPLY_TO_CODE_LOOKUP_TYPE     CONSTANT VARCHAR2(200)  := 'UNKNOWN';
  G_ADJ_FREQ_CODE_LOOKUP_TYPE     CONSTANT VARCHAR2(200)  := 'OKL_ADJ_FREQUENCY';
  G_VAR_METHOD_CODE_LOOKUP_TYPE   CONSTANT VARCHAR2(200)  := 'OKL_VARIABLE_METHOD';
  G_INT_METHOD_CODE_LOOKUP_TYPE   CONSTANT VARCHAR2(200)  := 'OKL_VAR_INTCALC';
  G_CALC_METHOD_CODE_LOOKUP_TYPE  CONSTANT VARCHAR2(200)  := 'OKL_CALC_METHOD';
  G_PAY_FREQ_CODE_LOOKUP_TYPE     CONSTANT VARCHAR2(200)  := 'UNKNOWN';





--End Hand coding

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
  -- FUNCTION get_rec for: OKL_TRX_REQUESTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_trqv_rec                     IN trqv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN trqv_rec_type IS
    CURSOR okl_trqv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            DNZ_KHR_ID,
            REQUEST_TYPE_CODE,
            APPLY_TO_CODE,
            START_DATE,
            END_DATE,
            TERM_DURATION,
            AMOUNT,
            CURRENCY_CODE,
            SUBSIDY_YN,
            CASH_APPLIED_YN,
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
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            MINIMUM_RATE,
            MAXIMUM_RATE,
            TOLERANCE,
            ADJUSTMENT_FREQUENCY_CODE,
            BASE_RATE,
            INDEX_NAME,
            VARIABLE_METHOD_CODE,
            ADDER,
            DAYS_IN_YEAR,
            DAYS_IN_MONTH,
            INTEREST_METHOD_CODE,
            INTEREST_START_DATE,
            METHOD_OF_CALCULATION_CODE,
            REQUEST_NUMBER,
            DATE_OF_CONVERSION,
            VARIABLE_RATE_YN,
            REQUEST_STATUS_CODE,
            YIELD,
            RESIDUAL,
            COMMENTS,
            PAYMENT_FREQUENCY_CODE,
            RESTRUCTURE_DATE,
            PAST_DUE_YN,
            REQUEST_REASON_CODE,
            PARENT_KHR_ID,
            YIELD_TYPE,
            PAYMENT_AMOUNT,
            PAYMENT_DATE,
	    PAYDOWN_TYPE,
	    CURRENCY_CONVERSION_TYPE,
	    CURRENCY_CONVERSION_RATE,
	    CURRENCY_CONVERSION_DATE,
	    LSM_ID,
	    RECEIPT_ID,
	    TCN_ID,
            TRY_ID,
	    CUR_PRINCIPAL_BALANCE, --BUG#5083582
	    CUR_ACCUM_INTEREST, --BUG#5083582
	    LEGAL_ENTITY_ID
      FROM OKL_TRX_REQUESTS
     WHERE OKL_TRX_REQUESTS.id = p_id;
    l_okl_trqv_pk                  okl_trqv_pk_csr%ROWTYPE;
    l_trqv_rec                     trqv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trqv_pk_csr (p_trqv_rec.id);
    FETCH okl_trqv_pk_csr INTO
              l_trqv_rec.id,
              l_trqv_rec.object1_id1,
              l_trqv_rec.object1_id2,
              l_trqv_rec.jtot_object1_code,
              l_trqv_rec.dnz_khr_id,
              l_trqv_rec.request_type_code,
              l_trqv_rec.apply_to_code,
              l_trqv_rec.start_date,
              l_trqv_rec.end_date,
              l_trqv_rec.term_duration,
              l_trqv_rec.AMOUNT,
              l_trqv_rec.currency_code,
              l_trqv_rec.subsidy_yn,
              l_trqv_rec.cash_applied_yn,
              l_trqv_rec.object_version_number,
              l_trqv_rec.attribute_category,
              l_trqv_rec.attribute1,
              l_trqv_rec.attribute2,
              l_trqv_rec.attribute3,
              l_trqv_rec.attribute4,
              l_trqv_rec.attribute5,
              l_trqv_rec.attribute6,
              l_trqv_rec.attribute7,
              l_trqv_rec.attribute8,
              l_trqv_rec.attribute9,
              l_trqv_rec.attribute10,
              l_trqv_rec.attribute11,
              l_trqv_rec.attribute12,
              l_trqv_rec.attribute13,
              l_trqv_rec.attribute14,
              l_trqv_rec.attribute15,
              l_trqv_rec.org_id,
              l_trqv_rec.request_id,
              l_trqv_rec.program_application_id,
              l_trqv_rec.program_id,
              l_trqv_rec.program_update_date,
              l_trqv_rec.created_by,
              l_trqv_rec.creation_date,
              l_trqv_rec.last_updated_by,
              l_trqv_rec.last_update_date,
              l_trqv_rec.last_update_login,
              l_trqv_rec.minimum_rate,
              l_trqv_rec.maximum_rate,
              l_trqv_rec.tolerance,
              l_trqv_rec.adjustment_frequency_code,
              l_trqv_rec.base_rate,
              l_trqv_rec.index_name,
              l_trqv_rec.variable_method_code,
              l_trqv_rec.adder,
              l_trqv_rec.days_in_year,
              l_trqv_rec.days_in_month,
              l_trqv_rec.interest_method_code,
              l_trqv_rec.interest_start_date,
              l_trqv_rec.method_of_calculation_code,
              l_trqv_rec.request_number,
              l_trqv_rec.date_of_conversion,
              l_trqv_rec.variable_rate_yn,
              l_trqv_rec.request_status_code,
              l_trqv_rec.yield,
              l_trqv_rec.residual,
              l_trqv_rec.comments,
              l_trqv_rec.payment_frequency_code,
              l_trqv_rec.restructure_date,
              l_trqv_rec.past_due_yn,
              l_trqv_rec.request_reason_code,
              l_trqv_rec.parent_khr_id,
              l_trqv_rec.yield_type,
              l_trqv_rec.payment_amount,
              l_trqv_rec.payment_date,
              l_trqv_rec.paydown_type,
              l_trqv_rec.currency_conversion_type,
              l_trqv_rec.currency_conversion_rate,
              l_trqv_rec.currency_conversion_date,
              l_trqv_rec.lsm_id,
              l_trqv_rec.receipt_id,
              l_trqv_rec.tcn_id,
              l_trqv_rec.try_id,
	      l_trqv_rec.CUR_PRINCIPAL_BALANCE, ----BUG#5083582
	      l_trqv_rec.CUR_ACCUM_INTEREST, --BUG#5083582
              l_trqv_rec.legal_entity_id;
    x_no_data_found := okl_trqv_pk_csr%NOTFOUND;
    CLOSE okl_trqv_pk_csr;
    RETURN(l_trqv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_trqv_rec                     IN trqv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN trqv_rec_type IS
    l_trqv_rec                     trqv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_trqv_rec := get_rec(p_trqv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_trqv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_trqv_rec                     IN trqv_rec_type
  ) RETURN trqv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_trqv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_REQUESTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_trq_rec                      IN trq_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN trq_rec_type IS
    CURSOR okl_trq_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            DNZ_KHR_ID,
            REQUEST_TYPE_CODE,
            APPLY_TO_CODE,
            START_DATE,
            END_DATE,
            TERM_DURATION,
            AMOUNT,
            CURRENCY_CODE,
            SUBSIDY_YN,
            CASH_APPLIED_YN,
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
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            MINIMUM_RATE,
            MAXIMUM_RATE,
            TOLERANCE,
            ADJUSTMENT_FREQUENCY_CODE,
            BASE_RATE,
            INDEX_NAME,
            VARIABLE_METHOD_CODE,
            ADDER,
            DAYS_IN_YEAR,
            DAYS_IN_MONTH,
            INTEREST_METHOD_CODE,
            INTEREST_START_DATE,
            METHOD_OF_CALCULATION_CODE,
            REQUEST_NUMBER,
            DATE_OF_CONVERSION,
            VARIABLE_RATE_YN,
            REQUEST_STATUS_CODE,
            YIELD,
            RESIDUAL,
            COMMENTS,
            PAYMENT_FREQUENCY_CODE,
            RESTRUCTURE_DATE,
            PAST_DUE_YN,
            REQUEST_REASON_CODE,
            PARENT_KHR_ID,
            YIELD_TYPE,
            PAYMENT_AMOUNT,
            PAYMENT_DATE,
	    PAYDOWN_TYPE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
	    LSM_ID,
            RECEIPT_ID,
            TCN_ID,
            TRY_ID,
	    LEGAL_ENTITY_ID
      FROM Okl_Trx_Requests
     WHERE okl_trx_requests.id  = p_id;
    l_okl_trq_pk                   okl_trq_pk_csr%ROWTYPE;
    l_trq_rec                      trq_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trq_pk_csr (p_trq_rec.id);
    FETCH okl_trq_pk_csr INTO
              l_trq_rec.id,
              l_trq_rec.object1_id1,
              l_trq_rec.object1_id2,
              l_trq_rec.jtot_object1_code,
              l_trq_rec.dnz_khr_id,
              l_trq_rec.request_type_code,
              l_trq_rec.apply_to_code,
              l_trq_rec.start_date,
              l_trq_rec.end_date,
              l_trq_rec.term_duration,
              l_trq_rec.AMOUNT,
              l_trq_rec.currency_code,
              l_trq_rec.subsidy_yn,
              l_trq_rec.cash_applied_yn,
              l_trq_rec.object_version_number,
              l_trq_rec.attribute_category,
              l_trq_rec.attribute1,
              l_trq_rec.attribute2,
              l_trq_rec.attribute3,
              l_trq_rec.attribute4,
              l_trq_rec.attribute5,
              l_trq_rec.attribute6,
              l_trq_rec.attribute7,
              l_trq_rec.attribute8,
              l_trq_rec.attribute9,
              l_trq_rec.attribute10,
              l_trq_rec.attribute11,
              l_trq_rec.attribute12,
              l_trq_rec.attribute13,
              l_trq_rec.attribute14,
              l_trq_rec.attribute15,
              l_trq_rec.org_id,
              l_trq_rec.request_id,
              l_trq_rec.program_application_id,
              l_trq_rec.program_id,
              l_trq_rec.program_update_date,
              l_trq_rec.created_by,
              l_trq_rec.creation_date,
              l_trq_rec.last_updated_by,
              l_trq_rec.last_update_date,
              l_trq_rec.last_update_login,
              l_trq_rec.minimum_rate,
              l_trq_rec.maximum_rate,
              l_trq_rec.tolerance,
              l_trq_rec.adjustment_frequency_code,
              l_trq_rec.base_rate,
              l_trq_rec.index_name,
              l_trq_rec.variable_method_code,
              l_trq_rec.adder,
              l_trq_rec.days_in_year,
              l_trq_rec.days_in_month,
              l_trq_rec.interest_method_code,
              l_trq_rec.interest_start_date,
              l_trq_rec.method_of_calculation_code,
              l_trq_rec.request_number,
              l_trq_rec.date_of_conversion,
              l_trq_rec.variable_rate_yn,
              l_trq_rec.request_status_code,
              l_trq_rec.yield,
              l_trq_rec.residual,
              l_trq_rec.comments,
              l_trq_rec.payment_frequency_code,
              l_trq_rec.restructure_date,
              l_trq_rec.past_due_yn,
              l_trq_rec.request_reason_code,
              l_trq_rec.parent_khr_id,
              l_trq_rec.yield_type,
              l_trq_rec.payment_amount,
              l_trq_rec.payment_date,
              l_trq_rec.paydown_type,
              l_trq_rec.currency_conversion_type,
              l_trq_rec.currency_conversion_rate,
              l_trq_rec.currency_conversion_date,
              l_trq_rec.lsm_id,
              l_trq_rec.receipt_id,
              l_trq_rec.tcn_id,
              l_trq_rec.try_id,
	      l_trq_rec.legal_entity_id;
    x_no_data_found := okl_trq_pk_csr%NOTFOUND;
    CLOSE okl_trq_pk_csr;
    RETURN(l_trq_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_trq_rec                      IN trq_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN trq_rec_type IS
    l_trq_rec                      trq_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_trq_rec := get_rec(p_trq_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_trq_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_trq_rec                      IN trq_rec_type
  ) RETURN trq_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_trq_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_REQUESTS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_trqv_rec   IN trqv_rec_type
  ) RETURN trqv_rec_type IS
    l_trqv_rec                     trqv_rec_type := p_trqv_rec;
  BEGIN
    IF (l_trqv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.id := NULL;
    END IF;
    IF (l_trqv_rec.object1_id1 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.object1_id1 := NULL;
    END IF;
    IF (l_trqv_rec.object1_id2 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.object1_id2 := NULL;
    END IF;
    IF (l_trqv_rec.jtot_object1_code = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.jtot_object1_code := NULL;
    END IF;
    IF (l_trqv_rec.dnz_khr_id = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.dnz_khr_id := NULL;
    END IF;
    IF (l_trqv_rec.request_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.request_type_code := NULL;
    END IF;
    IF (l_trqv_rec.apply_to_code = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.apply_to_code := NULL;
    END IF;
    IF (l_trqv_rec.start_date = OKL_API.G_MISS_DATE ) THEN
      l_trqv_rec.start_date := NULL;
    END IF;
    IF (l_trqv_rec.end_date = OKL_API.G_MISS_DATE ) THEN
      l_trqv_rec.end_date := NULL;
    END IF;
    IF (l_trqv_rec.term_duration = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.term_duration := NULL;
    END IF;
    IF (l_trqv_rec.AMOUNT = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.AMOUNT := NULL;
    END IF;
    IF (l_trqv_rec.currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.currency_code := NULL;
    END IF;
    IF (l_trqv_rec.subsidy_yn = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.subsidy_yn := NULL;
    END IF;
    IF (l_trqv_rec.cash_applied_yn = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.cash_applied_yn := NULL;
    END IF;
    IF (l_trqv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.object_version_number := NULL;
    END IF;
    IF (l_trqv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute_category := NULL;
    END IF;
    IF (l_trqv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute1 := NULL;
    END IF;
    IF (l_trqv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute2 := NULL;
    END IF;
    IF (l_trqv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute3 := NULL;
    END IF;
    IF (l_trqv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute4 := NULL;
    END IF;
    IF (l_trqv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute5 := NULL;
    END IF;
    IF (l_trqv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute6 := NULL;
    END IF;
    IF (l_trqv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute7 := NULL;
    END IF;
    IF (l_trqv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute8 := NULL;
    END IF;
    IF (l_trqv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute9 := NULL;
    END IF;
    IF (l_trqv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute10 := NULL;
    END IF;
    IF (l_trqv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute11 := NULL;
    END IF;
    IF (l_trqv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute12 := NULL;
    END IF;
    IF (l_trqv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute13 := NULL;
    END IF;
    IF (l_trqv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute14 := NULL;
    END IF;
    IF (l_trqv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.attribute15 := NULL;
    END IF;
    IF (l_trqv_rec.org_id = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.org_id := NULL;
    END IF;
    IF (l_trqv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.request_id := NULL;
    END IF;
    IF (l_trqv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.program_application_id := NULL;
    END IF;
    IF (l_trqv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.program_id := NULL;
    END IF;
    IF (l_trqv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_trqv_rec.program_update_date := NULL;
    END IF;
    IF (l_trqv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.created_by := NULL;
    END IF;
    IF (l_trqv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_trqv_rec.creation_date := NULL;
    END IF;
    IF (l_trqv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.last_updated_by := NULL;
    END IF;
    IF (l_trqv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_trqv_rec.last_update_date := NULL;
    END IF;
    IF (l_trqv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.last_update_login := NULL;
    END IF;
    IF (l_trqv_rec.minimum_rate = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.minimum_rate := NULL;
    END IF;
    IF (l_trqv_rec.maximum_rate = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.maximum_rate := NULL;
    END IF;
    IF (l_trqv_rec.tolerance = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.tolerance := NULL;
    END IF;
    IF (l_trqv_rec.adjustment_frequency_code = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.adjustment_frequency_code := NULL;
    END IF;
    IF (l_trqv_rec.base_rate = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.base_rate := NULL;
    END IF;
    IF (l_trqv_rec.index_name = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.index_name := NULL;
    END IF;
    IF (l_trqv_rec.variable_method_code = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.variable_method_code := NULL;
    END IF;
    IF (l_trqv_rec.adder = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.adder := NULL;
    END IF;
    IF (l_trqv_rec.days_in_year = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.days_in_year := NULL;
    END IF;
    IF (l_trqv_rec.days_in_month = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.days_in_month := NULL;
    END IF;
    IF (l_trqv_rec.interest_method_code = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.interest_method_code := NULL;
    END IF;
    IF (l_trqv_rec.interest_start_date = OKL_API.G_MISS_DATE ) THEN
      l_trqv_rec.interest_start_date := NULL;
    END IF;
    IF (l_trqv_rec.method_of_calculation_code = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.method_of_calculation_code := NULL;
    END IF;
    IF (l_trqv_rec.request_number = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.request_number := NULL;
    END IF;
    IF (l_trqv_rec.date_of_conversion = OKL_API.G_MISS_DATE ) THEN
      l_trqv_rec.date_of_conversion := NULL;
    END IF;
    IF (l_trqv_rec.variable_rate_yn = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.variable_rate_yn := NULL;
    END IF;
    IF (l_trqv_rec.request_status_code = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.request_status_code := NULL;
    END IF;
    IF (l_trqv_rec.yield = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.yield := NULL;
    END IF;
    IF (l_trqv_rec.residual = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.residual := NULL;
    END IF;
    IF (l_trqv_rec.comments = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.comments := NULL;
    END IF;
    IF (l_trqv_rec.payment_frequency_code = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.payment_frequency_code := NULL;
    END IF;
    IF (l_trqv_rec.restructure_date = OKL_API.G_MISS_DATE ) THEN
      l_trqv_rec.restructure_date := NULL;
    END IF;
    IF (l_trqv_rec.past_due_yn = OKL_API.G_MISS_CHAR ) THEN
      l_trqv_rec.past_due_yn := NULL;
    END IF;
     IF (l_trqv_rec.request_reason_code = OKL_API.G_MISS_CHAR ) THEN
          l_trqv_rec.request_reason_code := NULL;
    END IF;
    IF (l_trqv_rec.parent_khr_id = OKL_API.G_MISS_NUM ) THEN
      l_trqv_rec.parent_khr_id := NULL;
    END IF;
     IF (l_trqv_rec.yield_type = OKL_API.G_MISS_CHAR ) THEN
          l_trqv_rec.yield_type := NULL;
    END IF;
     IF (l_trqv_rec.payment_amount = OKL_API.G_MISS_NUM ) THEN
          l_trqv_rec.payment_amount := NULL;
    END IF;
     IF (l_trqv_rec.payment_date = OKL_API.G_MISS_DATE ) THEN
          l_trqv_rec.payment_date := NULL;
    END IF;
     IF (l_trqv_rec.paydown_type = OKL_API.G_MISS_CHAR ) THEN
          l_trqv_rec.paydown_type := NULL;
    END IF;
     IF (l_trqv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR ) THEN
          l_trqv_rec.currency_conversion_type := NULL;
    END IF;
     IF (l_trqv_rec.currency_conversion_rate = OKL_API.G_MISS_NUM ) THEN
          l_trqv_rec.currency_conversion_rate := NULL;
    END IF;
     IF (l_trqv_rec.currency_conversion_date = OKL_API.G_MISS_DATE ) THEN
          l_trqv_rec.currency_conversion_date := NULL;
    END IF;
     IF (l_trqv_rec.lsm_id = OKL_API.G_MISS_NUM ) THEN
          l_trqv_rec.lsm_id := NULL;
    END IF;
     IF (l_trqv_rec.receipt_id = OKL_API.G_MISS_NUM ) THEN
          l_trqv_rec.receipt_id := NULL;
    END IF;
     IF (l_trqv_rec.tcn_id = OKL_API.G_MISS_NUM ) THEN
          l_trqv_rec.tcn_id := NULL;
    END IF;
     IF (l_trqv_rec.try_id = OKL_API.G_MISS_NUM ) THEN
          l_trqv_rec.try_id := NULL;
    END IF;
    --BEGIN-VARANGAN-BUG#5083582
    IF (l_trqv_rec.CUR_PRINCIPAL_BALANCE = OKL_API.G_MISS_NUM ) THEN
          l_trqv_rec.CUR_PRINCIPAL_BALANCE := NULL;
    END IF;

    IF (l_trqv_rec.CUR_ACCUM_INTEREST = OKL_API.G_MISS_NUM ) THEN
          l_trqv_rec.CUR_ACCUM_INTEREST := NULL;
    END IF;

    --END-VARANGAN-BUG#5083582
    IF (l_trqv_rec.legal_entity_id = OKL_API.G_MISS_NUM ) THEN
          l_trqv_rec.legal_entity_id := NULL;
    END IF;

    RETURN(l_trqv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  --Hand coded
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec                           IN trqv_rec_type) IS

     l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

   BEGIN

     IF (p_trqv_rec.id = OKL_API.G_MISS_NUM OR
         p_trqv_rec.id IS NULL)
     THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
       l_return_status := OKL_API.G_RET_STS_ERROR;

     END IF;
     x_return_status := l_return_status;
   EXCEPTION
     WHEN OTHERS THEN
       OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                           ,p_msg_name     => G_UNEXPECTED_ERROR
                           ,p_token1       => G_SQLCODE_TOKEN
                           ,p_token1_value => SQLCODE
                           ,p_token2       => G_SQLERRM_TOKEN
                           ,p_token2_value => SQLERRM);
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   END validate_id;


  ---------------------------------
  -- Validate_Attributes for: LEGAL_ENTITY_ID --
  ---------------------------------
  --Hand coded
  PROCEDURE validate_legal_entity_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN  trqv_rec_type) IS

     l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_exists           NUMBER(1);
   BEGIN

     IF (p_trqv_rec.legal_entity_id = OKL_API.G_MISS_NUM OR
         p_trqv_rec.legal_entity_id IS NULL)
     THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'LEGAL_ENTITY_ID');
       l_return_status := OKL_API.G_RET_STS_ERROR;
     ELSE
       l_exists := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_trqv_rec.legal_entity_id);
       IF (l_exists <> 1) THEN
         OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEGAL_ENTITY_ID');
         l_return_status := OKL_API.G_RET_STS_ERROR;
       END IF;
     END IF;
     x_return_status := l_return_status;
   EXCEPTION
     WHEN OTHERS THEN
       OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                           ,p_msg_name     => G_UNEXPECTED_ERROR
                           ,p_token1       => G_SQLCODE_TOKEN
                           ,p_token1_value => SQLCODE
                           ,p_token2       => G_SQLERRM_TOKEN
                           ,p_token2_value => SQLERRM);
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   END validate_legal_entity_id;

---------------------------------
  -- Validate_Attributes for: ORG_ID --
  ---------------------------------
  --Hand coded
  PROCEDURE validate_org_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN  trqv_rec_type) IS

     l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_exists           NUMBER(1);
   BEGIN

     IF (p_trqv_rec.org_id = OKL_API.G_MISS_NUM OR
         p_trqv_rec.org_id IS NULL)
     THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ORG_ID');
       l_return_status := OKL_API.G_RET_STS_ERROR;
     END IF;
     x_return_status := l_return_status;
   EXCEPTION
     WHEN OTHERS THEN
       OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                           ,p_msg_name     => G_UNEXPECTED_ERROR
                           ,p_token1       => G_SQLCODE_TOKEN
                           ,p_token1_value => SQLCODE
                           ,p_token2       => G_SQLERRM_TOKEN
                           ,p_token2_value => SQLERRM);
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   END validate_org_id;

  ------------------------------------------------
  -- Validate_Attributes for: REQUEST_TYPE_CODE --
  ------------------------------------------------
  PROCEDURE validate_request_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec            IN trqv_rec_type) IS

     l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    IF (p_trqv_rec.request_type_code = OKL_API.G_MISS_CHAR OR
        p_trqv_rec.request_type_code IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'request_type_code');
      l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;
          x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_request_type_code;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS
         l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    IF (p_trqv_rec.object_version_number = OKL_API.G_MISS_NUM OR
        p_trqv_rec.object_version_number IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;
              x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;

  --------------------------------------------------
  -- Validate_Attributes for: REQUEST_STATUS_CODE --
  --------------------------------------------------
  PROCEDURE validate_request_status_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_trqv_rec.request_status_code = OKL_API.G_MISS_CHAR OR
        p_trqv_rec.request_status_code IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'request_status_code');
      l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;
    --Hand coded this.
    -- Enforce Foreign Key
    l_return_status := OKL_UTIL.check_lookup_code(G_STATUS_LOOKUP_TYPE,
                                                  p_trqv_rec.request_status_code);
    IF l_return_status <> x_return_status THEN
       -- Notify Error
      OKL_API.set_message(G_APP_NAME, G_NO_MATCHING_RECORD, G_COL_NAME_TOKEN, 'request_status_code');
    END IF;

      x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_request_status_code;
  --------------------------------------------
  -- Validate_Attributes for: APPLY_TO_CODE --
  --------------------------------------------
  PROCEDURE validate_apply_to_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --Hand coded this.
    IF (p_trqv_rec.apply_to_code <> OKL_API.G_MISS_CHAR OR
        p_trqv_rec.apply_to_code IS NOT NULL) THEN

        -- Enforce Foreign Key
        l_return_status := OKL_UTIL.check_lookup_code(G_APPLY_TO_CODE_LOOKUP_TYPE,
                                                      p_trqv_rec.apply_to_code);
        IF l_return_status <> x_return_status THEN
           -- Notify Error
          OKL_API.set_message(G_APP_NAME, G_NO_MATCHING_RECORD, G_COL_NAME_TOKEN, 'apply_to_code');
        END IF;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_apply_to_code;
  --------------------------------------------------------
  -- Validate_Attributes for: ADJUSTMENT_FREQUENCY_CODE --
  --------------------------------------------------------
  PROCEDURE validate_adjustment1(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --Hand coded this.
    IF (p_trqv_rec.adjustment_frequency_code <> OKL_API.G_MISS_CHAR OR
        p_trqv_rec.adjustment_frequency_code IS NOT NULL) THEN

        -- Enforce Foreign Key
        l_return_status := OKL_UTIL.check_lookup_code(G_ADJ_FREQ_CODE_LOOKUP_TYPE,
                                                      p_trqv_rec.adjustment_frequency_code);
        IF l_return_status <> x_return_status THEN
           -- Notify Error
          OKL_API.set_message(G_APP_NAME, G_NO_MATCHING_RECORD, G_COL_NAME_TOKEN, 'adjustment_frequency_code');
        END IF;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_adjustment1;
  ---------------------------------------------------
  -- Validate_Attributes for: VARIABLE_METHOD_CODE --
  ---------------------------------------------------
  PROCEDURE validate_variable_method_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --Hand coded this.
    IF (p_trqv_rec.variable_method_code <> OKL_API.G_MISS_CHAR OR
        p_trqv_rec.variable_method_code IS NOT NULL) THEN

        -- Enforce Foreign Key
        l_return_status := OKL_UTIL.check_lookup_code(G_VAR_METHOD_CODE_LOOKUP_TYPE,
                                                      p_trqv_rec.variable_method_code);
        IF l_return_status <> x_return_status THEN
           -- Notify Error
          OKL_API.set_message(G_APP_NAME, G_NO_MATCHING_RECORD, G_COL_NAME_TOKEN, 'variable_method_code');
        END IF;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_variable_method_code;
  ---------------------------------------------------
  -- Validate_Attributes for: INTEREST_METHOD_CODE --
  ---------------------------------------------------
  PROCEDURE validate_interest_method_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --Hand coded this.
    IF (p_trqv_rec.interest_method_code <> OKL_API.G_MISS_CHAR OR
        p_trqv_rec.interest_method_code IS NOT NULL) THEN

        -- Enforce Foreign Key
        l_return_status := OKL_UTIL.check_lookup_code(G_INT_METHOD_CODE_LOOKUP_TYPE,
                                                      p_trqv_rec.interest_method_code);
        IF l_return_status <> x_return_status THEN
           -- Notify Error
          OKL_API.set_message(G_APP_NAME, G_NO_MATCHING_RECORD, G_COL_NAME_TOKEN, 'interest_method_code');
        END IF;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_interest_method_code;
  ---------------------------------------------------------
  -- Validate_Attributes for: METHOD_OF_CALCULATION_CODE --
  ---------------------------------------------------------
  PROCEDURE validate_method_of_3(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --Hand coded this.
/*
    IF (p_trqv_rec.method_of_calculation_code <> OKL_API.G_MISS_CHAR OR
        p_trqv_rec.method_of_calculation_code IS NOT NULL) THEN

        -- Enforce Foreign Key
        l_return_status := OKL_UTIL.check_lookup_code(G_CALC_METHOD_CODE_LOOKUP_TYPE,
                                                      p_trqv_rec.method_of_calculation_code);
        IF l_return_status <> x_return_status THEN
           -- Notify Error
          OKL_API.set_message(G_APP_NAME, G_NO_MATCHING_RECORD, G_COL_NAME_TOKEN, 'method_of_calculation_code');
        END IF;
    END IF;

    x_return_status := l_return_status;
*/

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_method_of_3;
  -----------------------------------------------------
  -- Validate_Attributes for: PAYMENT_FREQUENCY_CODE --
  -----------------------------------------------------
  PROCEDURE validate_payment_fr5(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --Hand coded this.
    IF (p_trqv_rec.payment_frequency_code <> OKL_API.G_MISS_CHAR OR
        p_trqv_rec.payment_frequency_code IS NOT NULL) THEN

        -- Enforce Foreign Key
        l_return_status := OKL_UTIL.check_lookup_code(G_PAY_FREQ_CODE_LOOKUP_TYPE,
                                                      p_trqv_rec.payment_frequency_code);
        IF l_return_status <> x_return_status THEN
           -- Notify Error
          OKL_API.set_message(G_APP_NAME, G_NO_MATCHING_RECORD, G_COL_NAME_TOKEN, 'payment_frequency_code');
        END IF;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_payment_fr5;


  -----------------------------------------------------
  -- Validate_Attributes for: Currency Code --
  -----------------------------------------------------


  PROCEDURE validate_currency_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_valid VARCHAR2(1);
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_trqv_rec.currency_code <> OKL_API.G_MISS_CHAR AND
       p_trqv_rec.currency_code IS NOT NULL) THEN
      -- check from currency values using the generic okl_util.validate_currency_code
      l_valid := OKL_ACCOUNTING_UTIL.validate_currency_code(p_trqv_rec.currency_code);
      IF l_valid <> OKL_API.G_TRUE THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;

    END IF;
    IF (l_return_status <>  OKL_API.G_RET_STS_SUCCESS) THEN
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'currency_code');
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
  ------------------------------------------------------------------------
  -- PROCEDURE validate_currency_con_type
  ------------------------------------------------------------------------
  PROCEDURE validate_currency_con_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_Valid VARCHAR2(1);
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_trqv_rec.currency_conversion_type <> OKL_API.G_MISS_CHAR AND
       p_trqv_rec.currency_conversion_type IS NOT NULL) THEN
      -- check from currency values using the generic okl_util.validate_currency_con_type
      l_valid := OKL_ACCOUNTING_UTIL.validate_currency_con_type(p_trqv_rec.currency_conversion_type);
      IF l_valid <> OKL_API.G_TRUE THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;
    END IF;
    IF (l_return_status <>  OKC_API.G_RET_STS_SUCCESS) THEN
      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'currency_conversion_type');
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

  ------------------------------------------------------------------------
  -- PROCEDURE validate_currency_record
  ------------------------------------------------------------------------
  PROCEDURE validate_currency_record(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trqv_rec        IN trqv_rec_type) IS

    l_count          NUMBER := 0;
    CURSOR l_check_id_csr(p_id OKL_TRX_REQUESTS.ID%TYPE) IS
    SELECT count(*)
    FROM OKL_TRX_REQUESTS
    WHERE id = p_id;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    OPEN  l_check_id_csr(p_id => p_trqv_rec.id);
    FETCH l_check_id_csr INTO l_count;
    CLOSE l_check_id_csr;
    -- In the insert mode, if any one of conversion_type, conversion_rate
    -- and conversion date are not null then all are mandory
    IF l_count = 0 THEN
      IF (p_trqv_rec.currency_conversion_type <> OKC_API.G_MISS_CHAR OR
         p_trqv_rec.currency_conversion_type IS NOT NULL) OR
         (p_trqv_rec.currency_conversion_rate <> OKC_API.G_MISS_NUM OR
         p_trqv_rec.currency_conversion_rate IS NOT NULL) OR
         (p_trqv_rec.currency_conversion_date <> OKC_API.G_MISS_DATE OR
         p_trqv_rec.currency_conversion_date IS NOT NULL) THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    -- In the update mode, if all conversion_type, conversion_rate
    -- and conversion date are not null or null we are ok.
    -- Else we are not ok
    ELSE
      IF (p_trqv_rec.currency_conversion_type <> OKC_API.G_MISS_CHAR OR
         p_trqv_rec.currency_conversion_type IS NOT NULL) AND
         (p_trqv_rec.currency_conversion_rate <> OKC_API.G_MISS_NUM OR
         p_trqv_rec.currency_conversion_rate IS NOT NULL) AND
         (p_trqv_rec.currency_conversion_date <> OKC_API.G_MISS_DATE OR
         p_trqv_rec.currency_conversion_date IS NOT NULL) THEN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
      ELSIF (p_trqv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR OR
         p_trqv_rec.currency_conversion_type IS NULL) AND
         (p_trqv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM OR
         p_trqv_rec.currency_conversion_rate IS NULL) AND
         (p_trqv_rec.currency_conversion_date = OKC_API.G_MISS_DATE OR
         p_trqv_rec.currency_conversion_date IS NULL) THEN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
      ELSE
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      OKC_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'currency_conversion_type,currency_conversion_rate and currency_conversion_date');
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


  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_TRX_REQUESTS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_trqv_rec                     IN trqv_rec_type
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
    validate_id(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- legal_entity_id
    -- ***
    validate_legal_entity_id(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- org_id
    -- ***
    validate_org_id(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- request_type_code
    -- ***
    validate_request_type_code(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- request_status_code
    -- ***
    validate_request_status_code(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- apply_to_code
    -- ***
    validate_apply_to_code(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;



    -- ***
    -- adjustment_frequency_code
    -- ***
    validate_adjustment1(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    -- ***
    -- variable_method_code
    -- ***
    validate_variable_method_code(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    -- ***
    -- interest_method_code
    -- ***
    validate_interest_method_code(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    -- ***
    -- method_of_calculation_code
    -- ***
    validate_method_of_3(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;



    -- ***
    -- payment_frequency_code
    -- ***
    validate_payment_fr5(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

     -- ***
    -- Currency Record
    -- ***
    validate_currency_record(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- Currency code
    -- ***
    validate_currency_code(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- Currency conversion Type
    -- ***
    validate_currency_con_type(l_return_status, p_trqv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(x_return_status);
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate Record for:OKL_TRX_REQUESTS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_trqv_rec IN trqv_rec_type,
    p_db_trqv_rec IN trqv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  FUNCTION Validate_Record (
    p_trqv_rec IN trqv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_trqv_rec                  trqv_rec_type := get_rec(p_trqv_rec);
  BEGIN
    l_return_status := Validate_Record(p_trqv_rec => p_trqv_rec,
                                       p_db_trqv_rec => l_db_trqv_rec);
    RETURN (l_return_status);
  END Validate_Record;

--End Hand Coding

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN trqv_rec_type,
    p_to   IN OUT NOCOPY trq_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.dnz_khr_id := p_from.dnz_khr_id;
    p_to.request_type_code := p_from.request_type_code;
    p_to.apply_to_code := p_from.apply_to_code;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.term_duration := p_from.term_duration;
    p_to.AMOUNT := p_from.AMOUNT;
    p_to.currency_code := p_from.currency_code;
    p_to.subsidy_yn := p_from.subsidy_yn;
    p_to.cash_applied_yn := p_from.cash_applied_yn;
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
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.minimum_rate := p_from.minimum_rate;
    p_to.maximum_rate := p_from.maximum_rate;
    p_to.tolerance := p_from.tolerance;
    p_to.adjustment_frequency_code := p_from.adjustment_frequency_code;
    p_to.base_rate := p_from.base_rate;
    p_to.index_name := p_from.index_name;
    p_to.variable_method_code := p_from.variable_method_code;
    p_to.adder := p_from.adder;
    p_to.days_in_year := p_from.days_in_year;
    p_to.days_in_month := p_from.days_in_month;
    p_to.interest_method_code := p_from.interest_method_code;
    p_to.interest_start_date := p_from.interest_start_date;
    p_to.method_of_calculation_code := p_from.method_of_calculation_code;
    p_to.request_number := p_from.request_number;
    p_to.date_of_conversion := p_from.date_of_conversion;
    p_to.variable_rate_yn := p_from.variable_rate_yn;
    p_to.request_status_code := p_from.request_status_code;
    p_to.yield := p_from.yield;
    p_to.residual := p_from.residual;
    p_to.comments := p_from.comments;
    p_to.payment_frequency_code := p_from.payment_frequency_code;
    p_to.restructure_date := p_from.restructure_date;
    p_to.past_due_yn := p_from.past_due_yn;
    p_to.request_reason_code := p_from.request_reason_code;
    p_to.parent_khr_id := p_from.parent_khr_id;
    p_to.yield_type := p_from.yield_type;
    p_to.payment_amount := p_from.payment_amount;
    p_to.payment_date := p_from.payment_date;
    p_to.paydown_type := p_from.paydown_type;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    p_to.lsm_id := p_from.lsm_id;
    p_to.receipt_id := p_from.receipt_id;
    p_to.tcn_id := p_from.tcn_id;
    p_to.try_id := p_from.try_id;
    p_to.CUR_PRINCIPAL_BALANCE := p_from.CUR_PRINCIPAL_BALANCE; --BUG#5083582
    p_to.CUR_ACCUM_INTEREST := p_from.CUR_ACCUM_INTEREST; --BUG#5083582
    p_to.legal_entity_id := p_from.legal_entity_id;
  END migrate;
  PROCEDURE migrate (
    p_from IN trq_rec_type,
    p_to   IN OUT NOCOPY trqv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.dnz_khr_id := p_from.dnz_khr_id;
    p_to.request_type_code := p_from.request_type_code;
    p_to.apply_to_code := p_from.apply_to_code;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.term_duration := p_from.term_duration;
    p_to.AMOUNT := p_from.AMOUNT;
    p_to.currency_code := p_from.currency_code;
    p_to.subsidy_yn := p_from.subsidy_yn;
    p_to.cash_applied_yn := p_from.cash_applied_yn;
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
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.minimum_rate := p_from.minimum_rate;
    p_to.maximum_rate := p_from.maximum_rate;
    p_to.tolerance := p_from.tolerance;
    p_to.adjustment_frequency_code := p_from.adjustment_frequency_code;
    p_to.base_rate := p_from.base_rate;
    p_to.index_name := p_from.index_name;
    p_to.variable_method_code := p_from.variable_method_code;
    p_to.adder := p_from.adder;
    p_to.days_in_year := p_from.days_in_year;
    p_to.days_in_month := p_from.days_in_month;
    p_to.interest_method_code := p_from.interest_method_code;
    p_to.interest_start_date := p_from.interest_start_date;
    p_to.method_of_calculation_code := p_from.method_of_calculation_code;
    p_to.request_number := p_from.request_number;
    p_to.date_of_conversion := p_from.date_of_conversion;
    p_to.variable_rate_yn := p_from.variable_rate_yn;
    p_to.request_status_code := p_from.request_status_code;
    p_to.yield := p_from.yield;
    p_to.residual := p_from.residual;
    p_to.comments := p_from.comments;
    p_to.payment_frequency_code := p_from.payment_frequency_code;
    p_to.restructure_date := p_from.restructure_date;
    p_to.past_due_yn := p_from.past_due_yn;
    p_to.request_reason_code := p_from.request_reason_code;
    p_to.parent_khr_id := p_from.parent_khr_id;
    p_to.yield_type := p_from.yield_type;
    p_to.payment_amount := p_from.payment_amount;
    p_to.payment_date := p_from.payment_date;
    p_to.paydown_type := p_from.paydown_type;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    p_to.lsm_id := p_from.lsm_id;
    p_to.receipt_id := p_from.receipt_id;
    p_to.tcn_id := p_from.tcn_id;
    p_to.try_id := p_from.try_id;
    p_to.CUR_PRINCIPAL_BALANCE := p_from.CUR_PRINCIPAL_BALANCE; --BUG#5083582
    p_to.CUR_ACCUM_INTEREST := p_from.CUR_ACCUM_INTEREST; --BUG#5083582
    p_to.legal_entity_id := p_from.legal_entity_id;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_TRX_REQUESTS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN trqv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_trqv_rec                     trqv_rec_type := p_trqv_rec;
    l_trq_rec                      trq_rec_type;
    l_trq_rec                      trq_rec_type;
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
    l_return_status := Validate_Attributes(l_trqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_trqv_rec);
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
  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TRX_REQUESTS_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_trqv_tbl.COUNT > 0) THEN
      i := p_trqv_tbl.FIRST;
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
            p_trqv_rec                     => p_trqv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_trqv_tbl.LAST);
        i := p_trqv_tbl.NEXT(i);
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

  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TRX_REQUESTS_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_trqv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_trqv_tbl                     => p_trqv_tbl,
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
  -------------------------------------
  -- insert_row for:OKL_TRX_REQUESTS --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trq_rec                      IN trq_rec_type,
    x_trq_rec                      OUT NOCOPY trq_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_trq_rec                      trq_rec_type := p_trq_rec;
    l_def_trq_rec                  trq_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_REQUESTS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_trq_rec IN trq_rec_type,
      x_trq_rec OUT NOCOPY trq_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_trq_rec := p_trq_rec;
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
      p_trq_rec,                         -- IN
      l_trq_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TRX_REQUESTS(
      id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      dnz_khr_id,
      request_type_code,
      apply_to_code,
      start_date,
      end_date,
      term_duration,
      AMOUNT,
      currency_code,
      subsidy_yn,
      cash_applied_yn,
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
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      minimum_rate,
      maximum_rate,
      tolerance,
      adjustment_frequency_code,
      base_rate,
      index_name,
      variable_method_code,
      adder,
      days_in_year,
      days_in_month,
      interest_method_code,
      interest_start_date,
      method_of_calculation_code,
      request_number,
      date_of_conversion,
      variable_rate_yn,
      request_status_code,
      yield,
      residual,
      comments,
      payment_frequency_code,
      restructure_date,
      past_due_yn,
      request_reason_code,
      parent_khr_id,
      yield_type,
      payment_amount,
      payment_date,
      paydown_type,
      currency_conversion_type,
      currency_conversion_rate,
      currency_conversion_date,
      lsm_id,
      receipt_id,
      tcn_id,
      try_id,
      CUR_PRINCIPAL_BALANCE, --BUG#5083582
      CUR_ACCUM_INTEREST, --BUG#5083582
      legal_entity_id )
    VALUES (
      l_trq_rec.id,
      l_trq_rec.object1_id1,
      l_trq_rec.object1_id2,
      l_trq_rec.jtot_object1_code,
      l_trq_rec.dnz_khr_id,
      l_trq_rec.request_type_code,
      l_trq_rec.apply_to_code,
      l_trq_rec.start_date,
      l_trq_rec.end_date,
      l_trq_rec.term_duration,
      l_trq_rec.AMOUNT,
      l_trq_rec.currency_code,
      l_trq_rec.subsidy_yn,
      l_trq_rec.cash_applied_yn,
      l_trq_rec.object_version_number,
      l_trq_rec.attribute_category,
      l_trq_rec.attribute1,
      l_trq_rec.attribute2,
      l_trq_rec.attribute3,
      l_trq_rec.attribute4,
      l_trq_rec.attribute5,
      l_trq_rec.attribute6,
      l_trq_rec.attribute7,
      l_trq_rec.attribute8,
      l_trq_rec.attribute9,
      l_trq_rec.attribute10,
      l_trq_rec.attribute11,
      l_trq_rec.attribute12,
      l_trq_rec.attribute13,
      l_trq_rec.attribute14,
      l_trq_rec.attribute15,
      l_trq_rec.org_id,
      l_trq_rec.request_id,
      l_trq_rec.program_application_id,
      l_trq_rec.program_id,
      l_trq_rec.program_update_date,
      l_trq_rec.created_by,
      l_trq_rec.creation_date,
      l_trq_rec.last_updated_by,
      l_trq_rec.last_update_date,
      l_trq_rec.last_update_login,
      l_trq_rec.minimum_rate,
      l_trq_rec.maximum_rate,
      l_trq_rec.tolerance,
      l_trq_rec.adjustment_frequency_code,
      l_trq_rec.base_rate,
      l_trq_rec.index_name,
      l_trq_rec.variable_method_code,
      l_trq_rec.adder,
      l_trq_rec.days_in_year,
      l_trq_rec.days_in_month,
      l_trq_rec.interest_method_code,
      l_trq_rec.interest_start_date,
      l_trq_rec.method_of_calculation_code,
      l_trq_rec.request_number,
      l_trq_rec.date_of_conversion,
      l_trq_rec.variable_rate_yn,
      l_trq_rec.request_status_code,
      l_trq_rec.yield,
      l_trq_rec.residual,
      l_trq_rec.comments,
      l_trq_rec.payment_frequency_code,
      l_trq_rec.restructure_date,
      l_trq_rec.past_due_yn,
      l_trq_rec.request_reason_code,
      l_trq_rec.parent_khr_id,
      l_trq_rec.yield_type,
      l_trq_rec.payment_amount,
      l_trq_rec.payment_date,
      l_trq_rec.paydown_type,
      l_trq_rec.currency_conversion_type,
      l_trq_rec.currency_conversion_rate,
      l_trq_rec.currency_conversion_date,
      l_trq_rec.lsm_id,
      l_trq_rec.receipt_id,
      l_trq_rec.tcn_id,
      l_trq_rec.try_id,
      l_trq_rec.CUR_PRINCIPAL_BALANCE, --BUG#5083582
      l_trq_rec.CUR_ACCUM_INTEREST, --BUG#5083582
      l_trq_rec.legal_entity_id );
    -- Set OUT values
    x_trq_rec := l_trq_rec;
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
  -- insert_row for :OKL_TRX_REQUESTS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN trqv_rec_type,
    x_trqv_rec                     OUT NOCOPY trqv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_trqv_rec                     trqv_rec_type := p_trqv_rec;
    l_def_trqv_rec                 trqv_rec_type;
    l_trq_rec                      trq_rec_type;
    lx_trq_rec                     trq_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_trqv_rec IN trqv_rec_type
    ) RETURN trqv_rec_type IS
      l_trqv_rec trqv_rec_type := p_trqv_rec;
    BEGIN
      l_trqv_rec.CREATION_DATE := SYSDATE;
      l_trqv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_trqv_rec.LAST_UPDATE_DATE := l_trqv_rec.CREATION_DATE;
      l_trqv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_trqv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_trqv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_TRX_REQUESTS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_trqv_rec IN trqv_rec_type,
      x_trqv_rec OUT NOCOPY trqv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     --Hand coded
     CURSOR req_num_seq
       IS
      select OKL_TRQ_SEQ.nextval
      from dual;
     --End Hand coding
    BEGIN
      x_trqv_rec := p_trqv_rec;
      x_trqv_rec.OBJECT_VERSION_NUMBER := 1;
      --Hand coded this.
      OPEN req_num_seq;
      FETCH req_num_seq INTO x_trqv_rec.request_number;
      CLOSE req_num_seq;
      --end hand coding

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
    l_trqv_rec := null_out_defaults(p_trqv_rec);
    -- Set primary key value
    l_trqv_rec.ID := get_seq_id;
    -- Setting item attributes

    IF l_trqv_rec.legal_entity_id IS NULL THEN
      l_trqv_rec.legal_entity_id := okl_legal_entity_util.get_khr_le_id(l_trqv_rec.dnz_khr_id);
    END IF;
    --dkagrawa added for MOAC issue
    IF l_trqv_rec.org_id IS NULL THEN
      l_trqv_rec.org_id := mo_global.get_current_org_id();
    END IF;

    l_return_Status := Set_Attributes(
      l_trqv_rec,                        -- IN
      l_def_trqv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_trqv_rec := fill_who_columns(l_def_trqv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_trqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_trqv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_trqv_rec, l_trq_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_trq_rec,
      lx_trq_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_trq_rec, l_def_trqv_rec);
    -- Set OUT values
    x_trqv_rec := l_def_trqv_rec;
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
  -- PL/SQL TBL insert_row for:TRQV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    x_trqv_tbl                     OUT NOCOPY trqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_trqv_tbl.COUNT > 0) THEN
      i := p_trqv_tbl.FIRST;
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
            p_trqv_rec                     => p_trqv_tbl(i),
            x_trqv_rec                     => x_trqv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_trqv_tbl.LAST);
        i := p_trqv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:TRQV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    x_trqv_tbl                     OUT NOCOPY trqv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_trqv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_trqv_tbl                     => p_trqv_tbl,
        x_trqv_tbl                     => x_trqv_tbl,
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
  -----------------------------------
  -- lock_row for:OKL_TRX_REQUESTS --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trq_rec                      IN trq_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_trq_rec IN trq_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_REQUESTS
     WHERE ID = p_trq_rec.id
       AND OBJECT_VERSION_NUMBER = p_trq_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_trq_rec IN trq_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_REQUESTS
     WHERE ID = p_trq_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_TRX_REQUESTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_TRX_REQUESTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_trq_rec);
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
      OPEN lchk_csr(p_trq_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_trq_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_trq_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for: OKL_TRX_REQUESTS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN trqv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_trq_rec                      trq_rec_type;
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
    migrate(p_trqv_rec, l_trq_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_trq_rec
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
  -- PL/SQL TBL lock_row for:TRQV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_trqv_tbl.COUNT > 0) THEN
      i := p_trqv_tbl.FIRST;
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
            p_trqv_rec                     => p_trqv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_trqv_tbl.LAST);
        i := p_trqv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:TRQV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_trqv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_trqv_tbl                     => p_trqv_tbl,
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
  -------------------------------------
  -- update_row for:OKL_TRX_REQUESTS --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trq_rec                      IN trq_rec_type,
    x_trq_rec                      OUT NOCOPY trq_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_trq_rec                      trq_rec_type := p_trq_rec;
    l_def_trq_rec                  trq_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_trq_rec IN trq_rec_type,
      x_trq_rec OUT NOCOPY trq_rec_type
    ) RETURN VARCHAR2 IS
      l_trq_rec                      trq_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_trq_rec := p_trq_rec;
      -- Get current database values
      l_trq_rec := get_rec(p_trq_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_trq_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.id := l_trq_rec.id;
        END IF;
        IF (x_trq_rec.object1_id1 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.object1_id1 := l_trq_rec.object1_id1;
        END IF;
        IF (x_trq_rec.object1_id2 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.object1_id2 := l_trq_rec.object1_id2;
        END IF;
        IF (x_trq_rec.jtot_object1_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.jtot_object1_code := l_trq_rec.jtot_object1_code;
        END IF;
        IF (x_trq_rec.dnz_khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.dnz_khr_id := l_trq_rec.dnz_khr_id;
        END IF;
        IF (x_trq_rec.request_type_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.request_type_code := l_trq_rec.request_type_code;
        END IF;
        IF (x_trq_rec.apply_to_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.apply_to_code := l_trq_rec.apply_to_code;
        END IF;
        IF (x_trq_rec.start_date = OKL_API.G_MISS_DATE)
        THEN
          x_trq_rec.start_date := l_trq_rec.start_date;
        END IF;
        IF (x_trq_rec.end_date = OKL_API.G_MISS_DATE)
        THEN
          x_trq_rec.end_date := l_trq_rec.end_date;
        END IF;
        IF (x_trq_rec.term_duration = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.term_duration := l_trq_rec.term_duration;
        END IF;
        IF (x_trq_rec.AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.AMOUNT := l_trq_rec.AMOUNT;
        END IF;
        IF (x_trq_rec.currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.currency_code := l_trq_rec.currency_code;
        END IF;
        IF (x_trq_rec.subsidy_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.subsidy_yn := l_trq_rec.subsidy_yn;
        END IF;
        IF (x_trq_rec.cash_applied_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.cash_applied_yn := l_trq_rec.cash_applied_yn;
        END IF;
        IF (x_trq_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.object_version_number := l_trq_rec.object_version_number;
        END IF;
        IF (x_trq_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute_category := l_trq_rec.attribute_category;
        END IF;
        IF (x_trq_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute1 := l_trq_rec.attribute1;
        END IF;
        IF (x_trq_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute2 := l_trq_rec.attribute2;
        END IF;
        IF (x_trq_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute3 := l_trq_rec.attribute3;
        END IF;
        IF (x_trq_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute4 := l_trq_rec.attribute4;
        END IF;
        IF (x_trq_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute5 := l_trq_rec.attribute5;
        END IF;
        IF (x_trq_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute6 := l_trq_rec.attribute6;
        END IF;
        IF (x_trq_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute7 := l_trq_rec.attribute7;
        END IF;
        IF (x_trq_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute8 := l_trq_rec.attribute8;
        END IF;
        IF (x_trq_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute9 := l_trq_rec.attribute9;
        END IF;
        IF (x_trq_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute10 := l_trq_rec.attribute10;
        END IF;
        IF (x_trq_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute11 := l_trq_rec.attribute11;
        END IF;
        IF (x_trq_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute12 := l_trq_rec.attribute12;
        END IF;
        IF (x_trq_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute13 := l_trq_rec.attribute13;
        END IF;
        IF (x_trq_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute14 := l_trq_rec.attribute14;
        END IF;
        IF (x_trq_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.attribute15 := l_trq_rec.attribute15;
        END IF;
        IF (x_trq_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.org_id := l_trq_rec.org_id;
        END IF;
        IF (x_trq_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.request_id := l_trq_rec.request_id;
        END IF;
        IF (x_trq_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.program_application_id := l_trq_rec.program_application_id;
        END IF;
        IF (x_trq_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.program_id := l_trq_rec.program_id;
        END IF;
        IF (x_trq_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_trq_rec.program_update_date := l_trq_rec.program_update_date;
        END IF;
        IF (x_trq_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.created_by := l_trq_rec.created_by;
        END IF;
        IF (x_trq_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_trq_rec.creation_date := l_trq_rec.creation_date;
        END IF;
        IF (x_trq_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.last_updated_by := l_trq_rec.last_updated_by;
        END IF;
        IF (x_trq_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_trq_rec.last_update_date := l_trq_rec.last_update_date;
        END IF;
        IF (x_trq_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.last_update_login := l_trq_rec.last_update_login;
        END IF;
        IF (x_trq_rec.minimum_rate = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.minimum_rate := l_trq_rec.minimum_rate;
        END IF;
        IF (x_trq_rec.maximum_rate = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.maximum_rate := l_trq_rec.maximum_rate;
        END IF;
        IF (x_trq_rec.tolerance = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.tolerance := l_trq_rec.tolerance;
        END IF;
        IF (x_trq_rec.adjustment_frequency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.adjustment_frequency_code := l_trq_rec.adjustment_frequency_code;
        END IF;
        IF (x_trq_rec.base_rate = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.base_rate := l_trq_rec.base_rate;
        END IF;
        IF (x_trq_rec.index_name = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.index_name := l_trq_rec.index_name;
        END IF;
        IF (x_trq_rec.variable_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.variable_method_code := l_trq_rec.variable_method_code;
        END IF;
        IF (x_trq_rec.adder = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.adder := l_trq_rec.adder;
        END IF;
        IF (x_trq_rec.days_in_year = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.days_in_year := l_trq_rec.days_in_year;
        END IF;
        IF (x_trq_rec.days_in_month = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.days_in_month := l_trq_rec.days_in_month;
        END IF;
        IF (x_trq_rec.interest_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.interest_method_code := l_trq_rec.interest_method_code;
        END IF;
        IF (x_trq_rec.interest_start_date = OKL_API.G_MISS_DATE)
        THEN
          x_trq_rec.interest_start_date := l_trq_rec.interest_start_date;
        END IF;
        IF (x_trq_rec.method_of_calculation_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.method_of_calculation_code := l_trq_rec.method_of_calculation_code;
        END IF;
        IF (x_trq_rec.request_number = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.request_number := l_trq_rec.request_number;
        END IF;
        IF (x_trq_rec.date_of_conversion = OKL_API.G_MISS_DATE)
        THEN
          x_trq_rec.date_of_conversion := l_trq_rec.date_of_conversion;
        END IF;
        IF (x_trq_rec.variable_rate_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.variable_rate_yn := l_trq_rec.variable_rate_yn;
        END IF;
        IF (x_trq_rec.request_status_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.request_status_code := l_trq_rec.request_status_code;
        END IF;
        IF (x_trq_rec.yield = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.yield := l_trq_rec.yield;
        END IF;
        IF (x_trq_rec.residual = OKL_API.G_MISS_NUM)
        THEN
          x_trq_rec.residual := l_trq_rec.residual;
        END IF;
        IF (x_trq_rec.comments = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.comments := l_trq_rec.comments;
        END IF;
        IF (x_trq_rec.payment_frequency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.payment_frequency_code := l_trq_rec.payment_frequency_code;
        END IF;
        IF (x_trq_rec.restructure_date = OKL_API.G_MISS_DATE)
        THEN
          x_trq_rec.restructure_date := l_trq_rec.restructure_date;
        END IF;
        IF (x_trq_rec.past_due_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_trq_rec.past_due_yn := l_trq_rec.past_due_yn;
        END IF;
        IF (x_trq_rec.request_reason_code = OKL_API.G_MISS_CHAR)
	THEN
	   x_trq_rec.request_reason_code := l_trq_rec.request_reason_code;
        END IF;
        IF (x_trq_rec.parent_khr_id = OKL_API.G_MISS_NUM)
	THEN
	   x_trq_rec.parent_khr_id := l_trq_rec.parent_khr_id;
        END IF;
        IF (x_trq_rec.yield_type = OKL_API.G_MISS_CHAR)
	THEN
	   x_trq_rec.yield_type := l_trq_rec.yield_type;
        END IF;
        IF (x_trq_rec.payment_amount = OKL_API.G_MISS_NUM)
	THEN
	   x_trq_rec.payment_amount := l_trq_rec.payment_amount;
        END IF;
        IF (x_trq_rec.payment_date = OKL_API.G_MISS_DATE)
	THEN
	   x_trq_rec.payment_date := l_trq_rec.payment_date;
        END IF;
        IF (x_trq_rec.paydown_type = OKL_API.G_MISS_CHAR)
        THEN
           x_trq_rec.paydown_type := l_trq_rec.paydown_type;
        END IF;
        IF (x_trq_rec.currency_conversion_type = OKL_API.G_MISS_CHAR)
        THEN
           x_trq_rec.currency_conversion_type := l_trq_rec.currency_conversion_type;
        END IF;
        IF (x_trq_rec.currency_conversion_rate = OKL_API.G_MISS_NUM)
        THEN
           x_trq_rec.currency_conversion_rate := l_trq_rec.currency_conversion_rate;
        END IF;
        IF (x_trq_rec.currency_conversion_date = OKL_API.G_MISS_DATE)
        THEN
           x_trq_rec.currency_conversion_date := l_trq_rec.currency_conversion_date;
        END IF;
        IF (x_trq_rec.lsm_id = OKL_API.G_MISS_NUM)
        THEN
           x_trq_rec.lsm_id := l_trq_rec.lsm_id;
        END IF;
        IF (x_trq_rec.receipt_id = OKL_API.G_MISS_NUM)
        THEN
           x_trq_rec.receipt_id := l_trq_rec.receipt_id;
        END IF;
        IF (x_trq_rec.tcn_id = OKL_API.G_MISS_NUM)
        THEN
           x_trq_rec.tcn_id := l_trq_rec.tcn_id;
        END IF;
        IF (x_trq_rec.try_id = OKL_API.G_MISS_NUM)
        THEN
           x_trq_rec.try_id := l_trq_rec.try_id;
        END IF;
        --BEGIN -VARANGAN-BUG#5083582
        IF (x_trq_rec.CUR_PRINCIPAL_BALANCE = OKL_API.G_MISS_NUM)
        THEN
           x_trq_rec.CUR_PRINCIPAL_BALANCE := l_trq_rec.CUR_PRINCIPAL_BALANCE;
        END IF;
	IF (x_trq_rec.CUR_ACCUM_INTEREST = OKL_API.G_MISS_NUM)
        THEN
           x_trq_rec.CUR_ACCUM_INTEREST := l_trq_rec.CUR_ACCUM_INTEREST;
        END IF;
	--END - VARANGAN-BUG#5083582
        IF (x_trq_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
           x_trq_rec.legal_entity_id := l_trq_rec.legal_entity_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_REQUESTS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_trq_rec IN trq_rec_type,
      x_trq_rec OUT NOCOPY trq_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_trq_rec := p_trq_rec;
      x_trq_rec.OBJECT_VERSION_NUMBER := p_trq_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_trq_rec,                         -- IN
      l_trq_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_trq_rec, l_def_trq_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_TRX_REQUESTS
    SET OBJECT1_ID1 = l_def_trq_rec.object1_id1,
        OBJECT1_ID2 = l_def_trq_rec.object1_id2,
        JTOT_OBJECT1_CODE = l_def_trq_rec.jtot_object1_code,
        DNZ_KHR_ID = l_def_trq_rec.dnz_khr_id,
        REQUEST_TYPE_CODE = l_def_trq_rec.request_type_code,
        APPLY_TO_CODE = l_def_trq_rec.apply_to_code,
        START_DATE = l_def_trq_rec.start_date,
        END_DATE = l_def_trq_rec.end_date,
        TERM_DURATION = l_def_trq_rec.term_duration,
        AMOUNT = l_def_trq_rec.AMOUNT,
        CURRENCY_CODE = l_def_trq_rec.currency_code,
        SUBSIDY_YN = l_def_trq_rec.subsidy_yn,
        CASH_APPLIED_YN = l_def_trq_rec.cash_applied_yn,
        OBJECT_VERSION_NUMBER = l_def_trq_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_trq_rec.attribute_category,
        ATTRIBUTE1 = l_def_trq_rec.attribute1,
        ATTRIBUTE2 = l_def_trq_rec.attribute2,
        ATTRIBUTE3 = l_def_trq_rec.attribute3,
        ATTRIBUTE4 = l_def_trq_rec.attribute4,
        ATTRIBUTE5 = l_def_trq_rec.attribute5,
        ATTRIBUTE6 = l_def_trq_rec.attribute6,
        ATTRIBUTE7 = l_def_trq_rec.attribute7,
        ATTRIBUTE8 = l_def_trq_rec.attribute8,
        ATTRIBUTE9 = l_def_trq_rec.attribute9,
        ATTRIBUTE10 = l_def_trq_rec.attribute10,
        ATTRIBUTE11 = l_def_trq_rec.attribute11,
        ATTRIBUTE12 = l_def_trq_rec.attribute12,
        ATTRIBUTE13 = l_def_trq_rec.attribute13,
        ATTRIBUTE14 = l_def_trq_rec.attribute14,
        ATTRIBUTE15 = l_def_trq_rec.attribute15,
        ORG_ID = l_def_trq_rec.org_id,
        REQUEST_ID = l_def_trq_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_trq_rec.program_application_id,
        PROGRAM_ID = l_def_trq_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_trq_rec.program_update_date,
        CREATED_BY = l_def_trq_rec.created_by,
        CREATION_DATE = l_def_trq_rec.creation_date,
        LAST_UPDATED_BY = l_def_trq_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_trq_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_trq_rec.last_update_login,
        MINIMUM_RATE = l_def_trq_rec.minimum_rate,
        MAXIMUM_RATE = l_def_trq_rec.maximum_rate,
        TOLERANCE = l_def_trq_rec.tolerance,
        ADJUSTMENT_FREQUENCY_CODE = l_def_trq_rec.adjustment_frequency_code,
        BASE_RATE = l_def_trq_rec.base_rate,
        INDEX_NAME = l_def_trq_rec.index_name,
        VARIABLE_METHOD_CODE = l_def_trq_rec.variable_method_code,
        ADDER = l_def_trq_rec.adder,
        DAYS_IN_YEAR = l_def_trq_rec.days_in_year,
        DAYS_IN_MONTH = l_def_trq_rec.days_in_month,
        INTEREST_METHOD_CODE = l_def_trq_rec.interest_method_code,
        INTEREST_START_DATE = l_def_trq_rec.interest_start_date,
        METHOD_OF_CALCULATION_CODE = l_def_trq_rec.method_of_calculation_code,
        REQUEST_NUMBER = l_def_trq_rec.request_number,
        DATE_OF_CONVERSION = l_def_trq_rec.date_of_conversion,
        VARIABLE_RATE_YN = l_def_trq_rec.variable_rate_yn,
        REQUEST_STATUS_CODE = l_def_trq_rec.request_status_code,
        YIELD = l_def_trq_rec.yield,
        RESIDUAL = l_def_trq_rec.residual,
        COMMENTS = l_def_trq_rec.comments,
        PAYMENT_FREQUENCY_CODE = l_def_trq_rec.payment_frequency_code,
        RESTRUCTURE_DATE = l_def_trq_rec.restructure_date,
        PAST_DUE_YN = l_def_trq_rec.past_due_yn,
        REQUEST_REASON_CODE = l_def_trq_rec.request_reason_code,
        PARENT_KHR_ID = l_def_trq_rec.parent_khr_id,
        YIELD_TYPE = l_def_trq_rec.yield_type,
        PAYMENT_AMOUNT = l_def_trq_rec.payment_amount,
        PAYMENT_DATE = l_def_trq_rec.payment_date,
        PAYDOWN_TYPE = l_def_trq_rec.paydown_type,
        CURRENCY_CONVERSION_TYPE = l_def_trq_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_trq_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_trq_rec.currency_conversion_date,
        LSM_ID = l_def_trq_rec.lsm_id,
        RECEIPT_ID = l_def_trq_rec.receipt_id,
        TCN_ID = l_def_trq_rec.tcn_id,
        TRY_ID = l_def_trq_rec.try_id,
	LEGAL_ENTITY_ID = l_def_trq_rec.legal_entity_id
    WHERE ID = l_def_trq_rec.id;

    x_trq_rec := l_trq_rec;
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
  ---------------------------------------
  -- update_row for:OKL_TRX_REQUESTS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN trqv_rec_type,
    x_trqv_rec                     OUT NOCOPY trqv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_trqv_rec                     trqv_rec_type := p_trqv_rec;
    l_def_trqv_rec                 trqv_rec_type;
    l_db_trqv_rec                  trqv_rec_type;
    l_trq_rec                      trq_rec_type;
    lx_trq_rec                     trq_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_trqv_rec IN trqv_rec_type
    ) RETURN trqv_rec_type IS
      l_trqv_rec trqv_rec_type := p_trqv_rec;
    BEGIN
      l_trqv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_trqv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_trqv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_trqv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_trqv_rec IN trqv_rec_type,
      x_trqv_rec OUT NOCOPY trqv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_trqv_rec := p_trqv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_trqv_rec := get_rec(p_trqv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_trqv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.id := l_db_trqv_rec.id;
        END IF;
        IF (x_trqv_rec.object1_id1 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.object1_id1 := l_db_trqv_rec.object1_id1;
        END IF;
        IF (x_trqv_rec.object1_id2 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.object1_id2 := l_db_trqv_rec.object1_id2;
        END IF;
        IF (x_trqv_rec.jtot_object1_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.jtot_object1_code := l_db_trqv_rec.jtot_object1_code;
        END IF;
        IF (x_trqv_rec.dnz_khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.dnz_khr_id := l_db_trqv_rec.dnz_khr_id;
        END IF;
        IF (x_trqv_rec.request_type_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.request_type_code := l_db_trqv_rec.request_type_code;
        END IF;
        IF (x_trqv_rec.apply_to_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.apply_to_code := l_db_trqv_rec.apply_to_code;
        END IF;
        IF (x_trqv_rec.start_date = OKL_API.G_MISS_DATE)
        THEN
          x_trqv_rec.start_date := l_db_trqv_rec.start_date;
        END IF;
        IF (x_trqv_rec.end_date = OKL_API.G_MISS_DATE)
        THEN
          x_trqv_rec.end_date := l_db_trqv_rec.end_date;
        END IF;
        IF (x_trqv_rec.term_duration = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.term_duration := l_db_trqv_rec.term_duration;
        END IF;
        IF (x_trqv_rec.AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.AMOUNT := l_db_trqv_rec.AMOUNT;
        END IF;
        IF (x_trqv_rec.currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.currency_code := l_db_trqv_rec.currency_code;
        END IF;
        IF (x_trqv_rec.subsidy_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.subsidy_yn := l_db_trqv_rec.subsidy_yn;
        END IF;
        IF (x_trqv_rec.cash_applied_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.cash_applied_yn := l_db_trqv_rec.cash_applied_yn;
        END IF;
        IF (x_trqv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute_category := l_db_trqv_rec.attribute_category;
        END IF;
        IF (x_trqv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute1 := l_db_trqv_rec.attribute1;
        END IF;
        IF (x_trqv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute2 := l_db_trqv_rec.attribute2;
        END IF;
        IF (x_trqv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute3 := l_db_trqv_rec.attribute3;
        END IF;
        IF (x_trqv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute4 := l_db_trqv_rec.attribute4;
        END IF;
        IF (x_trqv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute5 := l_db_trqv_rec.attribute5;
        END IF;
        IF (x_trqv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute6 := l_db_trqv_rec.attribute6;
        END IF;
        IF (x_trqv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute7 := l_db_trqv_rec.attribute7;
        END IF;
        IF (x_trqv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute8 := l_db_trqv_rec.attribute8;
        END IF;
        IF (x_trqv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute9 := l_db_trqv_rec.attribute9;
        END IF;
        IF (x_trqv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute10 := l_db_trqv_rec.attribute10;
        END IF;
        IF (x_trqv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute11 := l_db_trqv_rec.attribute11;
        END IF;
        IF (x_trqv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute12 := l_db_trqv_rec.attribute12;
        END IF;
        IF (x_trqv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute13 := l_db_trqv_rec.attribute13;
        END IF;
        IF (x_trqv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute14 := l_db_trqv_rec.attribute14;
        END IF;
        IF (x_trqv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.attribute15 := l_db_trqv_rec.attribute15;
        END IF;
        IF (x_trqv_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.org_id := l_db_trqv_rec.org_id;
        END IF;
        IF (x_trqv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.request_id := l_db_trqv_rec.request_id;
        END IF;
        IF (x_trqv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.program_application_id := l_db_trqv_rec.program_application_id;
        END IF;
        IF (x_trqv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.program_id := l_db_trqv_rec.program_id;
        END IF;
        IF (x_trqv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_trqv_rec.program_update_date := l_db_trqv_rec.program_update_date;
        END IF;
        IF (x_trqv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.created_by := l_db_trqv_rec.created_by;
        END IF;
        IF (x_trqv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_trqv_rec.creation_date := l_db_trqv_rec.creation_date;
        END IF;
        IF (x_trqv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.last_updated_by := l_db_trqv_rec.last_updated_by;
        END IF;
        IF (x_trqv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_trqv_rec.last_update_date := l_db_trqv_rec.last_update_date;
        END IF;
        IF (x_trqv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.last_update_login := l_db_trqv_rec.last_update_login;
        END IF;
        IF (x_trqv_rec.minimum_rate = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.minimum_rate := l_db_trqv_rec.minimum_rate;
        END IF;
        IF (x_trqv_rec.maximum_rate = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.maximum_rate := l_db_trqv_rec.maximum_rate;
        END IF;
        IF (x_trqv_rec.tolerance = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.tolerance := l_db_trqv_rec.tolerance;
        END IF;
        IF (x_trqv_rec.adjustment_frequency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.adjustment_frequency_code := l_db_trqv_rec.adjustment_frequency_code;
        END IF;
        IF (x_trqv_rec.base_rate = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.base_rate := l_db_trqv_rec.base_rate;
        END IF;
        IF (x_trqv_rec.index_name = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.index_name := l_db_trqv_rec.index_name;
        END IF;
        IF (x_trqv_rec.variable_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.variable_method_code := l_db_trqv_rec.variable_method_code;
        END IF;
        IF (x_trqv_rec.adder = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.adder := l_db_trqv_rec.adder;
        END IF;
        IF (x_trqv_rec.days_in_year = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.days_in_year := l_db_trqv_rec.days_in_year;
        END IF;
        IF (x_trqv_rec.days_in_month = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.days_in_month := l_db_trqv_rec.days_in_month;
        END IF;
        IF (x_trqv_rec.interest_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.interest_method_code := l_db_trqv_rec.interest_method_code;
        END IF;
        IF (x_trqv_rec.interest_start_date = OKL_API.G_MISS_DATE)
        THEN
          x_trqv_rec.interest_start_date := l_db_trqv_rec.interest_start_date;
        END IF;
        IF (x_trqv_rec.method_of_calculation_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.method_of_calculation_code := l_db_trqv_rec.method_of_calculation_code;
        END IF;
        IF (x_trqv_rec.request_number = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.request_number := l_db_trqv_rec.request_number;
        END IF;
        IF (x_trqv_rec.date_of_conversion = OKL_API.G_MISS_DATE)
        THEN
          x_trqv_rec.date_of_conversion := l_db_trqv_rec.date_of_conversion;
        END IF;
        IF (x_trqv_rec.variable_rate_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.variable_rate_yn := l_db_trqv_rec.variable_rate_yn;
        END IF;
        IF (x_trqv_rec.request_status_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.request_status_code := l_db_trqv_rec.request_status_code;
        END IF;
        IF (x_trqv_rec.yield = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.yield := l_db_trqv_rec.yield;
        END IF;
        IF (x_trqv_rec.residual = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.residual := l_db_trqv_rec.residual;
        END IF;
        IF (x_trqv_rec.comments = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.comments := l_db_trqv_rec.comments;
        END IF;
        IF (x_trqv_rec.payment_frequency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.payment_frequency_code := l_db_trqv_rec.payment_frequency_code;
        END IF;
        IF (x_trqv_rec.restructure_date = OKL_API.G_MISS_DATE)
        THEN
          x_trqv_rec.restructure_date := l_db_trqv_rec.restructure_date;
        END IF;
        IF (x_trqv_rec.past_due_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.past_due_yn := l_db_trqv_rec.past_due_yn;
        END IF;
        IF (x_trqv_rec.request_reason_code = OKL_API.G_MISS_CHAR)
	THEN
	  x_trqv_rec.request_reason_code := l_db_trqv_rec.request_reason_code;
        END IF;
        IF (x_trqv_rec.parent_khr_id = OKL_API.G_MISS_NUM)
	THEN
	  x_trqv_rec.parent_khr_id := l_db_trqv_rec.parent_khr_id;
        END IF;
        IF (x_trqv_rec.yield_type = OKL_API.G_MISS_CHAR)
	THEN
	  x_trqv_rec.yield_type := l_db_trqv_rec.yield_type;
        END IF;
        IF (x_trqv_rec.payment_amount = OKL_API.G_MISS_NUM)
	THEN
	  x_trqv_rec.payment_amount := l_db_trqv_rec.payment_amount;
        END IF;
        IF (x_trqv_rec.payment_date = OKL_API.G_MISS_DATE)
	THEN
	  x_trqv_rec.payment_date := l_db_trqv_rec.payment_date;
        END IF;
        IF (x_trqv_rec.paydown_type = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.paydown_type := l_db_trqv_rec.paydown_type;
        END IF;
        IF (x_trqv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR)
        THEN
          x_trqv_rec.currency_conversion_type := l_db_trqv_rec.currency_conversion_type;
        END IF;
        IF (x_trqv_rec.currency_conversion_rate = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.currency_conversion_rate := l_db_trqv_rec.currency_conversion_rate;
        END IF;
        IF (x_trqv_rec.currency_conversion_date = OKL_API.G_MISS_DATE)
        THEN
          x_trqv_rec.currency_conversion_date := l_db_trqv_rec.currency_conversion_date;
        END IF;
        IF (x_trqv_rec.lsm_id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.lsm_id := l_db_trqv_rec.lsm_id;
        END IF;
        IF (x_trqv_rec.receipt_id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.receipt_id := l_db_trqv_rec.receipt_id;
        END IF;
        IF (x_trqv_rec.tcn_id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.tcn_id := l_db_trqv_rec.tcn_id;
        END IF;
        IF (x_trqv_rec.try_id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.try_id := l_db_trqv_rec.try_id;
        END IF;
        IF (x_trqv_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_trqv_rec.legal_entity_id := l_db_trqv_rec.legal_entity_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_TRX_REQUESTS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_trqv_rec IN trqv_rec_type,
      x_trqv_rec OUT NOCOPY trqv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_trqv_rec := p_trqv_rec;
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
      p_trqv_rec,                        -- IN
      x_trqv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_trqv_rec, l_def_trqv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_trqv_rec := fill_who_columns(l_def_trqv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_trqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_trqv_rec, l_db_trqv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_trqv_rec                     => p_trqv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_trqv_rec, l_trq_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_trq_rec,
      lx_trq_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_trq_rec, l_def_trqv_rec);
    x_trqv_rec := l_def_trqv_rec;
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
  -- PL/SQL TBL update_row for:trqv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    x_trqv_tbl                     OUT NOCOPY trqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_trqv_tbl.COUNT > 0) THEN
      i := p_trqv_tbl.FIRST;
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
            p_trqv_rec                     => p_trqv_tbl(i),
            x_trqv_rec                     => x_trqv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_trqv_tbl.LAST);
        i := p_trqv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:TRQV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    x_trqv_tbl                     OUT NOCOPY trqv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_trqv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_trqv_tbl                     => p_trqv_tbl,
        x_trqv_tbl                     => x_trqv_tbl,
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
  -------------------------------------
  -- delete_row for:OKL_TRX_REQUESTS --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trq_rec                      IN trq_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_trq_rec                      trq_rec_type := p_trq_rec;
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

    DELETE FROM OKL_TRX_REQUESTS
     WHERE ID = p_trq_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKL_TRX_REQUESTS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN trqv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_trqv_rec                     trqv_rec_type := p_trqv_rec;
    l_trq_rec                      trq_rec_type;
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
    migrate(l_trqv_rec, l_trq_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_trq_rec
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
  --------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TRX_REQUESTS_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_trqv_tbl.COUNT > 0) THEN
      i := p_trqv_tbl.FIRST;
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
            p_trqv_rec                     => p_trqv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_trqv_tbl.LAST);
        i := p_trqv_tbl.NEXT(i);
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

  --------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TRX_REQUESTS_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_trqv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_trqv_tbl                     => p_trqv_tbl,
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

END OKL_TRQ_PVT;

/
