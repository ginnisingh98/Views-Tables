--------------------------------------------------------
--  DDL for Package Body OKL_CBL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CBL_PVT" AS
/* $Header: OKLSCBLB.pls 120.7 2006/07/14 05:07:04 pagarg noship $ */
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
  -- FUNCTION get_rec for: OKL_CONTRACT_BALANCES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cblv_rec                     IN cblv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cblv_rec_type IS
    CURSOR okl_cblv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            KLE_ID,
            ACTUAL_PRINCIPAL_BALANCE_AMT,
            ACTUAL_PRINCIPAL_BALANCE_DATE,
            INTEREST_AMT,
            INTEREST_CALC_DATE,
            INTEREST_ACCRUED_AMT,
            INTEREST_ACCRUED_DATE,
            INTEREST_BILLED_AMT,
            INTEREST_BILLED_DATE,
            INTEREST_RECEIVED_AMT,
            INTEREST_RECEIVED_DATE,
            TERMINATION_VALUE_AMT,
            TERMINATION_DATE,
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
      FROM OKL_CONTRACT_BALANCES
     WHERE OKL_CONTRACT_BALANCES.id = p_id;
    l_okl_cblv_pk                  okl_cblv_pk_csr%ROWTYPE;
    l_cblv_rec                     cblv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cblv_pk_csr (p_cblv_rec.id);
    FETCH okl_cblv_pk_csr INTO
              l_cblv_rec.id,
              l_cblv_rec.khr_id,
              l_cblv_rec.kle_id,
              l_cblv_rec.actual_principal_balance_amt,
              l_cblv_rec.actual_principal_balance_date,
              l_cblv_rec.interest_amt,
              l_cblv_rec.interest_calc_date,
              l_cblv_rec.interest_accrued_amt,
              l_cblv_rec.interest_accrued_date,
              l_cblv_rec.interest_billed_amt,
              l_cblv_rec.interest_billed_date,
              l_cblv_rec.interest_received_amt,
              l_cblv_rec.interest_received_date,
              l_cblv_rec.termination_value_amt,
              l_cblv_rec.termination_date,
              l_cblv_rec.object_version_number,
              l_cblv_rec.org_id,
              l_cblv_rec.request_id,
              l_cblv_rec.program_application_id,
              l_cblv_rec.program_id,
              l_cblv_rec.program_update_date,
              l_cblv_rec.attribute_category,
              l_cblv_rec.attribute1,
              l_cblv_rec.attribute2,
              l_cblv_rec.attribute3,
              l_cblv_rec.attribute4,
              l_cblv_rec.attribute5,
              l_cblv_rec.attribute6,
              l_cblv_rec.attribute7,
              l_cblv_rec.attribute8,
              l_cblv_rec.attribute9,
              l_cblv_rec.attribute10,
              l_cblv_rec.attribute11,
              l_cblv_rec.attribute12,
              l_cblv_rec.attribute13,
              l_cblv_rec.attribute14,
              l_cblv_rec.attribute15,
              l_cblv_rec.created_by,
              l_cblv_rec.creation_date,
              l_cblv_rec.last_updated_by,
              l_cblv_rec.last_update_date,
              l_cblv_rec.last_update_login;
    x_no_data_found := okl_cblv_pk_csr%NOTFOUND;
    CLOSE okl_cblv_pk_csr;
    RETURN(l_cblv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_cblv_rec                     IN cblv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN cblv_rec_type IS
    l_cblv_rec                     cblv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_cblv_rec := get_rec(p_cblv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_cblv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_cblv_rec                     IN cblv_rec_type
  ) RETURN cblv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cblv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CONTRACT_BALANCES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cbl_rec                      IN cbl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cbl_rec_type IS
    CURSOR okl_cbl_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            KLE_ID,
            ACTUAL_PRINCIPAL_BALANCE_AMT,
            ACTUAL_PRINCIPAL_BALANCE_DATE,
            INTEREST_AMT,
            INTEREST_CALC_DATE,
            INTEREST_ACCRUED_AMT,
            INTEREST_ACCRUED_DATE,
            INTEREST_BILLED_AMT,
            INTEREST_BILLED_DATE,
            INTEREST_RECEIVED_AMT,
            INTEREST_RECEIVED_DATE,
            TERMINATION_VALUE_AMT,
            TERMINATION_DATE,
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
      FROM Okl_Contract_Balances
     WHERE okl_contract_balances.id = p_id;
    l_okl_cbl_pk                   okl_cbl_pk_csr%ROWTYPE;
    l_cbl_rec                      cbl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cbl_pk_csr (p_cbl_rec.id);
    FETCH okl_cbl_pk_csr INTO
              l_cbl_rec.id,
              l_cbl_rec.khr_id,
              l_cbl_rec.kle_id,
              l_cbl_rec.actual_principal_balance_amt,
              l_cbl_rec.actual_principal_balance_date,
              l_cbl_rec.interest_amt,
              l_cbl_rec.interest_calc_date,
              l_cbl_rec.interest_accrued_amt,
              l_cbl_rec.interest_accrued_date,
              l_cbl_rec.interest_billed_amt,
              l_cbl_rec.interest_billed_date,
              l_cbl_rec.interest_received_amt,
              l_cbl_rec.interest_received_date,
              l_cbl_rec.termination_value_amt,
              l_cbl_rec.termination_date,
              l_cbl_rec.object_version_number,
              l_cbl_rec.org_id,
              l_cbl_rec.request_id,
              l_cbl_rec.program_application_id,
              l_cbl_rec.program_id,
              l_cbl_rec.program_update_date,
              l_cbl_rec.attribute_category,
              l_cbl_rec.attribute1,
              l_cbl_rec.attribute2,
              l_cbl_rec.attribute3,
              l_cbl_rec.attribute4,
              l_cbl_rec.attribute5,
              l_cbl_rec.attribute6,
              l_cbl_rec.attribute7,
              l_cbl_rec.attribute8,
              l_cbl_rec.attribute9,
              l_cbl_rec.attribute10,
              l_cbl_rec.attribute11,
              l_cbl_rec.attribute12,
              l_cbl_rec.attribute13,
              l_cbl_rec.attribute14,
              l_cbl_rec.attribute15,
              l_cbl_rec.created_by,
              l_cbl_rec.creation_date,
              l_cbl_rec.last_updated_by,
              l_cbl_rec.last_update_date,
              l_cbl_rec.last_update_login;
    x_no_data_found := okl_cbl_pk_csr%NOTFOUND;
    CLOSE okl_cbl_pk_csr;
    RETURN(l_cbl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_cbl_rec                      IN cbl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN cbl_rec_type IS
    l_cbl_rec                      cbl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_cbl_rec := get_rec(p_cbl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_cbl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_cbl_rec                      IN cbl_rec_type
  ) RETURN cbl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cbl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CONTRACT_BALANCES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cblv_rec   IN cblv_rec_type
  ) RETURN cblv_rec_type IS
    l_cblv_rec                     cblv_rec_type := p_cblv_rec;
  BEGIN
    IF (l_cblv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.id := NULL;
    END IF;
    IF (l_cblv_rec.khr_id = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.khr_id := NULL;
    END IF;
    IF (l_cblv_rec.kle_id = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.kle_id := NULL;
    END IF;
    IF (l_cblv_rec.actual_principal_balance_amt = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.actual_principal_balance_amt := NULL;
    END IF;
    IF (l_cblv_rec.actual_principal_balance_date = OKL_API.G_MISS_DATE ) THEN
      l_cblv_rec.actual_principal_balance_date := NULL;
    END IF;
    IF (l_cblv_rec.interest_amt = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.interest_amt := NULL;
    END IF;
    IF (l_cblv_rec.interest_calc_date = OKL_API.G_MISS_DATE ) THEN
      l_cblv_rec.interest_calc_date := NULL;
    END IF;
    IF (l_cblv_rec.interest_accrued_amt = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.interest_accrued_amt := NULL;
    END IF;
    IF (l_cblv_rec.interest_accrued_date = OKL_API.G_MISS_DATE ) THEN
      l_cblv_rec.interest_accrued_date := NULL;
    END IF;
    IF (l_cblv_rec.interest_billed_amt = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.interest_billed_amt := NULL;
    END IF;
    IF (l_cblv_rec.interest_billed_date = OKL_API.G_MISS_DATE ) THEN
      l_cblv_rec.interest_billed_date := NULL;
    END IF;
    IF (l_cblv_rec.interest_received_amt = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.interest_received_amt := NULL;
    END IF;
    IF (l_cblv_rec.interest_received_date = OKL_API.G_MISS_DATE ) THEN
      l_cblv_rec.interest_received_date := NULL;
    END IF;
    IF (l_cblv_rec.termination_value_amt = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.termination_value_amt := NULL;
    END IF;
    IF (l_cblv_rec.termination_date = OKL_API.G_MISS_DATE ) THEN
      l_cblv_rec.termination_date := NULL;
    END IF;
    IF (l_cblv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.object_version_number := NULL;
    END IF;
    IF (l_cblv_rec.org_id = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.org_id := NULL;
    END IF;
    IF (l_cblv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.request_id := NULL;
    END IF;
    IF (l_cblv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.program_application_id := NULL;
    END IF;
    IF (l_cblv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.program_id := NULL;
    END IF;
    IF (l_cblv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_cblv_rec.program_update_date := NULL;
    END IF;
    IF (l_cblv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute_category := NULL;
    END IF;
    IF (l_cblv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute1 := NULL;
    END IF;
    IF (l_cblv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute2 := NULL;
    END IF;
    IF (l_cblv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute3 := NULL;
    END IF;
    IF (l_cblv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute4 := NULL;
    END IF;
    IF (l_cblv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute5 := NULL;
    END IF;
    IF (l_cblv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute6 := NULL;
    END IF;
    IF (l_cblv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute7 := NULL;
    END IF;
    IF (l_cblv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute8 := NULL;
    END IF;
    IF (l_cblv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute9 := NULL;
    END IF;
    IF (l_cblv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute10 := NULL;
    END IF;
    IF (l_cblv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute11 := NULL;
    END IF;
    IF (l_cblv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute12 := NULL;
    END IF;
    IF (l_cblv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute13 := NULL;
    END IF;
    IF (l_cblv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute14 := NULL;
    END IF;
    IF (l_cblv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_cblv_rec.attribute15 := NULL;
    END IF;
    IF (l_cblv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.created_by := NULL;
    END IF;
    IF (l_cblv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_cblv_rec.creation_date := NULL;
    END IF;
    IF (l_cblv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cblv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_cblv_rec.last_update_date := NULL;
    END IF;
    IF (l_cblv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_cblv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cblv_rec);
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
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;

  -- smadhava added validation of other fields in the table on 29-Jul-05 - Start
  ---------------------------------
  -- Validate_Attributes for: KHR_ID --
  ---------------------------------

  PROCEDURE validate_khr_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_khr_id IN NUMBER) IS
    l_khr_id NUMBER;                        -- Cursor to check the contract id

    CURSOR chk_khr_id(p_khr_id NUMBER) IS
      SELECT id
        FROM OKL_K_HEADERS
       WHERE id = p_khr_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_khr_id = OKL_API.G_MISS_NUM OR p_khr_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'khr_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    OPEN chk_khr_id(p_khr_id);
    FETCH chk_khr_id INTO l_khr_id ;

    IF chk_khr_id%NOTFOUND THEN
      OKL_API.set_message(G_APP_NAME,
                          G_INVALID_VALUE,
                          G_COL_NAME_TOKEN,
                          'khr_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE chk_khr_id;
    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;
      WHEN OTHERS THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => SQLCODE,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => SQLERRM);
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_khr_id;

  -- smadhava added validation of other fields in the table on 29-Jul-05 - End

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKL_CONTRACT_BALANCES_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cblv_rec                     IN cblv_rec_type
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
    validate_id(x_return_status, p_cblv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- smadhava Added calls to validate methods of columns on 29-Jul-05 - Start
    -- ***
    -- khr_id
    -- ***

    validate_khr_id(x_return_status, p_cblv_rec.khr_id);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- smadhava Added calls to validate methods of columns on 29-Jul-05 - End

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
  -------------------------------------------------
  -- Validate Record for:OKL_CONTRACT_BALANCES_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_cblv_rec IN cblv_rec_type,
    p_db_cblv_rec IN cblv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_cblv_rec IN cblv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_cblv_rec                  cblv_rec_type := get_rec(p_cblv_rec);
  BEGIN
    l_return_status := Validate_Record(p_cblv_rec => p_cblv_rec,
                                       p_db_cblv_rec => l_db_cblv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN cblv_rec_type,
    p_to   IN OUT NOCOPY cbl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.actual_principal_balance_amt := p_from.actual_principal_balance_amt;
    p_to.actual_principal_balance_date := p_from.actual_principal_balance_date;
    p_to.interest_amt := p_from.interest_amt;
    p_to.interest_calc_date := p_from.interest_calc_date;
    p_to.interest_accrued_amt := p_from.interest_accrued_amt;
    p_to.interest_accrued_date := p_from.interest_accrued_date;
    p_to.interest_billed_amt := p_from.interest_billed_amt;
    p_to.interest_billed_date := p_from.interest_billed_date;
    p_to.interest_received_amt := p_from.interest_received_amt;
    p_to.interest_received_date := p_from.interest_received_date;
    p_to.termination_value_amt := p_from.termination_value_amt;
    p_to.termination_date := p_from.termination_date;
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
    p_from IN cbl_rec_type,
    p_to   IN OUT NOCOPY cblv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.actual_principal_balance_amt := p_from.actual_principal_balance_amt;
    p_to.actual_principal_balance_date := p_from.actual_principal_balance_date;
    p_to.interest_amt := p_from.interest_amt;
    p_to.interest_calc_date := p_from.interest_calc_date;
    p_to.interest_accrued_amt := p_from.interest_accrued_amt;
    p_to.interest_accrued_date := p_from.interest_accrued_date;
    p_to.interest_billed_amt := p_from.interest_billed_amt;
    p_to.interest_billed_date := p_from.interest_billed_date;
    p_to.interest_received_amt := p_from.interest_received_amt;
    p_to.interest_received_date := p_from.interest_received_date;
    p_to.termination_value_amt := p_from.termination_value_amt;
    p_to.termination_date := p_from.termination_date;
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
  ----------------------------------------------
  -- validate_row for:OKL_CONTRACT_BALANCES_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_rec                     IN cblv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cblv_rec                     cblv_rec_type := p_cblv_rec;
    l_cbl_rec                      cbl_rec_type;
    l_cbl_rec                      cbl_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_cblv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cblv_rec);
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
  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CONTRACT_BALANCES_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_tbl                     IN cblv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cblv_tbl.COUNT > 0) THEN
      i := p_cblv_tbl.FIRST;
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
            p_cblv_rec                     => p_cblv_tbl(i));
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
        EXIT WHEN (i = p_cblv_tbl.LAST);
        i := p_cblv_tbl.NEXT(i);
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

  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CONTRACT_BALANCES_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_tbl                     IN cblv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cblv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cblv_tbl                     => p_cblv_tbl,
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
  ------------------------------------------
  -- insert_row for:OKL_CONTRACT_BALANCES --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cbl_rec                      IN cbl_rec_type,
    x_cbl_rec                      OUT NOCOPY cbl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cbl_rec                      cbl_rec_type := p_cbl_rec;
    l_def_cbl_rec                  cbl_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_BALANCES --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cbl_rec IN cbl_rec_type,
      x_cbl_rec OUT NOCOPY cbl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cbl_rec := p_cbl_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_cbl_rec,                         -- IN
      l_cbl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CONTRACT_BALANCES(
      id,
      khr_id,
      kle_id,
      actual_principal_balance_amt,
      actual_principal_balance_date,
      interest_amt,
      interest_calc_date,
      interest_accrued_amt,
      interest_accrued_date,
      interest_billed_amt,
      interest_billed_date,
      interest_received_amt,
      interest_received_date,
      termination_value_amt,
      termination_date,
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
      l_cbl_rec.id,
      l_cbl_rec.khr_id,
      l_cbl_rec.kle_id,
      l_cbl_rec.actual_principal_balance_amt,
      l_cbl_rec.actual_principal_balance_date,
      l_cbl_rec.interest_amt,
      l_cbl_rec.interest_calc_date,
      l_cbl_rec.interest_accrued_amt,
      l_cbl_rec.interest_accrued_date,
      l_cbl_rec.interest_billed_amt,
      l_cbl_rec.interest_billed_date,
      l_cbl_rec.interest_received_amt,
      l_cbl_rec.interest_received_date,
      l_cbl_rec.termination_value_amt,
      l_cbl_rec.termination_date,
      l_cbl_rec.object_version_number,
      l_cbl_rec.org_id,
      l_cbl_rec.request_id,
      l_cbl_rec.program_application_id,
      l_cbl_rec.program_id,
      l_cbl_rec.program_update_date,
      l_cbl_rec.attribute_category,
      l_cbl_rec.attribute1,
      l_cbl_rec.attribute2,
      l_cbl_rec.attribute3,
      l_cbl_rec.attribute4,
      l_cbl_rec.attribute5,
      l_cbl_rec.attribute6,
      l_cbl_rec.attribute7,
      l_cbl_rec.attribute8,
      l_cbl_rec.attribute9,
      l_cbl_rec.attribute10,
      l_cbl_rec.attribute11,
      l_cbl_rec.attribute12,
      l_cbl_rec.attribute13,
      l_cbl_rec.attribute14,
      l_cbl_rec.attribute15,
      l_cbl_rec.created_by,
      l_cbl_rec.creation_date,
      l_cbl_rec.last_updated_by,
      l_cbl_rec.last_update_date,
      l_cbl_rec.last_update_login);
    -- Set OUT values
    x_cbl_rec := l_cbl_rec;
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
  ---------------------------------------------
  -- insert_row for :OKL_CONTRACT_BALANCES_V --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_rec                     IN cblv_rec_type,
    x_cblv_rec                     OUT NOCOPY cblv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cblv_rec                     cblv_rec_type := p_cblv_rec;
    l_def_cblv_rec                 cblv_rec_type;
    l_cbl_rec                      cbl_rec_type;
    lx_cbl_rec                     cbl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cblv_rec IN cblv_rec_type
    ) RETURN cblv_rec_type IS
      l_cblv_rec cblv_rec_type := p_cblv_rec;
    BEGIN
      l_cblv_rec.CREATION_DATE := SYSDATE;
      l_cblv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cblv_rec.LAST_UPDATE_DATE := l_cblv_rec.CREATION_DATE;
      l_cblv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cblv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cblv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_BALANCES_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_cblv_rec IN cblv_rec_type,
      x_cblv_rec OUT NOCOPY cblv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cblv_rec := p_cblv_rec;
      x_cblv_rec.OBJECT_VERSION_NUMBER := 1;
      --start code added by dkagrawa on 20 OCT 2005
      IF (x_cblv_rec.request_id IS NULL OR x_cblv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
        SELECT
               DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
               DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	       DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
               DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	INTO
               x_cblv_rec.request_id,
               x_cblv_rec.program_application_id,
               x_cblv_rec.program_id,
               x_cblv_rec.program_update_date
        FROM dual;
      END IF;
      IF x_cblv_rec.org_id IS NULL OR x_cblv_rec.org_id = Okl_Api.G_MISS_NUM THEN
        x_cblv_rec.org_id := mo_global.get_current_org_id();
      END IF;
      --end code added by dkagrawa on 20 OCT 2005
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_cblv_rec := null_out_defaults(p_cblv_rec);
    -- Set primary key value
    l_cblv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_cblv_rec,                        -- IN
      l_def_cblv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cblv_rec := fill_who_columns(l_def_cblv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cblv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cblv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_cblv_rec, l_cbl_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cbl_rec,
      lx_cbl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cbl_rec, l_def_cblv_rec);
    -- Set OUT values
    x_cblv_rec := l_def_cblv_rec;
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
  -- PL/SQL TBL insert_row for:CBLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_tbl                     IN cblv_tbl_type,
    x_cblv_tbl                     OUT NOCOPY cblv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cblv_tbl.COUNT > 0) THEN
      i := p_cblv_tbl.FIRST;
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
            p_cblv_rec                     => p_cblv_tbl(i),
            x_cblv_rec                     => x_cblv_tbl(i));
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
        EXIT WHEN (i = p_cblv_tbl.LAST);
        i := p_cblv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:CBLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_tbl                     IN cblv_tbl_type,
    x_cblv_tbl                     OUT NOCOPY cblv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cblv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cblv_tbl                     => p_cblv_tbl,
        x_cblv_tbl                     => x_cblv_tbl,
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
  ----------------------------------------
  -- lock_row for:OKL_CONTRACT_BALANCES --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cbl_rec                      IN cbl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cbl_rec IN cbl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CONTRACT_BALANCES
     WHERE ID = p_cbl_rec.id
       AND OBJECT_VERSION_NUMBER = p_cbl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_cbl_rec IN cbl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CONTRACT_BALANCES
     WHERE ID = p_cbl_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_CONTRACT_BALANCES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_CONTRACT_BALANCES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_cbl_rec);
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
      OPEN lchk_csr(p_cbl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cbl_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cbl_rec.object_version_number THEN
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
  -------------------------------------------
  -- lock_row for: OKL_CONTRACT_BALANCES_V --
  -------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_rec                     IN cblv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cbl_rec                      cbl_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_cblv_rec, l_cbl_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cbl_rec
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
  -- PL/SQL TBL lock_row for:CBLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_tbl                     IN cblv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_cblv_tbl.COUNT > 0) THEN
      i := p_cblv_tbl.FIRST;
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
            p_cblv_rec                     => p_cblv_tbl(i));
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
        EXIT WHEN (i = p_cblv_tbl.LAST);
        i := p_cblv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:CBLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_tbl                     IN cblv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_cblv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cblv_tbl                     => p_cblv_tbl,
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
  ------------------------------------------
  -- update_row for:OKL_CONTRACT_BALANCES --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cbl_rec                      IN cbl_rec_type,
    x_cbl_rec                      OUT NOCOPY cbl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cbl_rec                      cbl_rec_type := p_cbl_rec;
    l_def_cbl_rec                  cbl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cbl_rec IN cbl_rec_type,
      x_cbl_rec OUT NOCOPY cbl_rec_type
    ) RETURN VARCHAR2 IS
      l_cbl_rec                      cbl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cbl_rec := p_cbl_rec;
      -- Get current database values
      l_cbl_rec := get_rec(p_cbl_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_cbl_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.id := l_cbl_rec.id;
        END IF;
        IF (x_cbl_rec.khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.khr_id := l_cbl_rec.khr_id;
        END IF;
        IF (x_cbl_rec.kle_id = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.kle_id := l_cbl_rec.kle_id;
        END IF;
        IF (x_cbl_rec.actual_principal_balance_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.actual_principal_balance_amt := l_cbl_rec.actual_principal_balance_amt;
        END IF;
        IF (x_cbl_rec.actual_principal_balance_date = OKL_API.G_MISS_DATE)
        THEN
          x_cbl_rec.actual_principal_balance_date := l_cbl_rec.actual_principal_balance_date;
        END IF;
        IF (x_cbl_rec.interest_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.interest_amt := l_cbl_rec.interest_amt;
        END IF;
        IF (x_cbl_rec.interest_calc_date = OKL_API.G_MISS_DATE)
        THEN
          x_cbl_rec.interest_calc_date := l_cbl_rec.interest_calc_date;
        END IF;
        IF (x_cbl_rec.interest_accrued_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.interest_accrued_amt := l_cbl_rec.interest_accrued_amt;
        END IF;
        IF (x_cbl_rec.interest_accrued_date = OKL_API.G_MISS_DATE)
        THEN
          x_cbl_rec.interest_accrued_date := l_cbl_rec.interest_accrued_date;
        END IF;
        IF (x_cbl_rec.interest_billed_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.interest_billed_amt := l_cbl_rec.interest_billed_amt;
        END IF;
        IF (x_cbl_rec.interest_billed_date = OKL_API.G_MISS_DATE)
        THEN
          x_cbl_rec.interest_billed_date := l_cbl_rec.interest_billed_date;
        END IF;
        IF (x_cbl_rec.interest_received_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.interest_received_amt := l_cbl_rec.interest_received_amt;
        END IF;
        IF (x_cbl_rec.interest_received_date = OKL_API.G_MISS_DATE)
        THEN
          x_cbl_rec.interest_received_date := l_cbl_rec.interest_received_date;
        END IF;
        IF (x_cbl_rec.termination_value_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.termination_value_amt := l_cbl_rec.termination_value_amt;
        END IF;
        IF (x_cbl_rec.termination_date = OKL_API.G_MISS_DATE)
        THEN
          x_cbl_rec.termination_date := l_cbl_rec.termination_date;
        END IF;
        IF (x_cbl_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.object_version_number := l_cbl_rec.object_version_number;
        END IF;
        IF (x_cbl_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.org_id := l_cbl_rec.org_id;
        END IF;
        IF (x_cbl_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.request_id := l_cbl_rec.request_id;
        END IF;
        IF (x_cbl_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.program_application_id := l_cbl_rec.program_application_id;
        END IF;
        IF (x_cbl_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.program_id := l_cbl_rec.program_id;
        END IF;
        IF (x_cbl_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_cbl_rec.program_update_date := l_cbl_rec.program_update_date;
        END IF;
        IF (x_cbl_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute_category := l_cbl_rec.attribute_category;
        END IF;
        IF (x_cbl_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute1 := l_cbl_rec.attribute1;
        END IF;
        IF (x_cbl_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute2 := l_cbl_rec.attribute2;
        END IF;
        IF (x_cbl_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute3 := l_cbl_rec.attribute3;
        END IF;
        IF (x_cbl_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute4 := l_cbl_rec.attribute4;
        END IF;
        IF (x_cbl_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute5 := l_cbl_rec.attribute5;
        END IF;
        IF (x_cbl_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute6 := l_cbl_rec.attribute6;
        END IF;
        IF (x_cbl_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute7 := l_cbl_rec.attribute7;
        END IF;
        IF (x_cbl_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute8 := l_cbl_rec.attribute8;
        END IF;
        IF (x_cbl_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute9 := l_cbl_rec.attribute9;
        END IF;
        IF (x_cbl_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute10 := l_cbl_rec.attribute10;
        END IF;
        IF (x_cbl_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute11 := l_cbl_rec.attribute11;
        END IF;
        IF (x_cbl_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute12 := l_cbl_rec.attribute12;
        END IF;
        IF (x_cbl_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute13 := l_cbl_rec.attribute13;
        END IF;
        IF (x_cbl_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute14 := l_cbl_rec.attribute14;
        END IF;
        IF (x_cbl_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_cbl_rec.attribute15 := l_cbl_rec.attribute15;
        END IF;
        IF (x_cbl_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.created_by := l_cbl_rec.created_by;
        END IF;
        IF (x_cbl_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_cbl_rec.creation_date := l_cbl_rec.creation_date;
        END IF;
        IF (x_cbl_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.last_updated_by := l_cbl_rec.last_updated_by;
        END IF;
        IF (x_cbl_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_cbl_rec.last_update_date := l_cbl_rec.last_update_date;
        END IF;
        IF (x_cbl_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_cbl_rec.last_update_login := l_cbl_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_BALANCES --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cbl_rec IN cbl_rec_type,
      x_cbl_rec OUT NOCOPY cbl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cbl_rec := p_cbl_rec;
      x_cbl_rec.OBJECT_VERSION_NUMBER := p_cbl_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cbl_rec,                         -- IN
      l_cbl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cbl_rec, l_def_cbl_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CONTRACT_BALANCES
    SET KHR_ID = l_def_cbl_rec.khr_id,
        KLE_ID = l_def_cbl_rec.kle_id,
        ACTUAL_PRINCIPAL_BALANCE_AMT = l_def_cbl_rec.actual_principal_balance_amt,
        ACTUAL_PRINCIPAL_BALANCE_DATE = l_def_cbl_rec.actual_principal_balance_date,
        INTEREST_AMT = l_def_cbl_rec.interest_amt,
        INTEREST_CALC_DATE = l_def_cbl_rec.interest_calc_date,
        INTEREST_ACCRUED_AMT = l_def_cbl_rec.interest_accrued_amt,
        INTEREST_ACCRUED_DATE = l_def_cbl_rec.interest_accrued_date,
        INTEREST_BILLED_AMT = l_def_cbl_rec.interest_billed_amt,
        INTEREST_BILLED_DATE = l_def_cbl_rec.interest_billed_date,
        INTEREST_RECEIVED_AMT = l_def_cbl_rec.interest_received_amt,
        INTEREST_RECEIVED_DATE = l_def_cbl_rec.interest_received_date,
        TERMINATION_VALUE_AMT = l_def_cbl_rec.termination_value_amt,
        TERMINATION_DATE = l_def_cbl_rec.termination_date,
        OBJECT_VERSION_NUMBER = l_def_cbl_rec.object_version_number,
        ORG_ID = l_def_cbl_rec.org_id,
        REQUEST_ID = l_def_cbl_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_cbl_rec.program_application_id,
        PROGRAM_ID = l_def_cbl_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_cbl_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_cbl_rec.attribute_category,
        ATTRIBUTE1 = l_def_cbl_rec.attribute1,
        ATTRIBUTE2 = l_def_cbl_rec.attribute2,
        ATTRIBUTE3 = l_def_cbl_rec.attribute3,
        ATTRIBUTE4 = l_def_cbl_rec.attribute4,
        ATTRIBUTE5 = l_def_cbl_rec.attribute5,
        ATTRIBUTE6 = l_def_cbl_rec.attribute6,
        ATTRIBUTE7 = l_def_cbl_rec.attribute7,
        ATTRIBUTE8 = l_def_cbl_rec.attribute8,
        ATTRIBUTE9 = l_def_cbl_rec.attribute9,
        ATTRIBUTE10 = l_def_cbl_rec.attribute10,
        ATTRIBUTE11 = l_def_cbl_rec.attribute11,
        ATTRIBUTE12 = l_def_cbl_rec.attribute12,
        ATTRIBUTE13 = l_def_cbl_rec.attribute13,
        ATTRIBUTE14 = l_def_cbl_rec.attribute14,
        ATTRIBUTE15 = l_def_cbl_rec.attribute15,
        CREATED_BY = l_def_cbl_rec.created_by,
        CREATION_DATE = l_def_cbl_rec.creation_date,
        LAST_UPDATED_BY = l_def_cbl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cbl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cbl_rec.last_update_login
    WHERE ID = l_def_cbl_rec.id;

    x_cbl_rec := l_cbl_rec;
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
  --------------------------------------------
  -- update_row for:OKL_CONTRACT_BALANCES_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_rec                     IN cblv_rec_type,
    x_cblv_rec                     OUT NOCOPY cblv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cblv_rec                     cblv_rec_type := p_cblv_rec;
    l_def_cblv_rec                 cblv_rec_type;
    l_db_cblv_rec                  cblv_rec_type;
    l_cbl_rec                      cbl_rec_type;
    lx_cbl_rec                     cbl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cblv_rec IN cblv_rec_type
    ) RETURN cblv_rec_type IS
      l_cblv_rec cblv_rec_type := p_cblv_rec;
    BEGIN
      l_cblv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cblv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cblv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cblv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cblv_rec IN cblv_rec_type,
      x_cblv_rec OUT NOCOPY cblv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cblv_rec := p_cblv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_cblv_rec := get_rec(p_cblv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_cblv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.id := l_db_cblv_rec.id;
        END IF;
        IF (x_cblv_rec.khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.khr_id := l_db_cblv_rec.khr_id;
        END IF;
        IF (x_cblv_rec.kle_id = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.kle_id := l_db_cblv_rec.kle_id;
        END IF;
        IF (x_cblv_rec.actual_principal_balance_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.actual_principal_balance_amt := l_db_cblv_rec.actual_principal_balance_amt;
        END IF;
        IF (x_cblv_rec.actual_principal_balance_date = OKL_API.G_MISS_DATE)
        THEN
          x_cblv_rec.actual_principal_balance_date := l_db_cblv_rec.actual_principal_balance_date;
        END IF;
        IF (x_cblv_rec.interest_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.interest_amt := l_db_cblv_rec.interest_amt;
        END IF;
        IF (x_cblv_rec.interest_calc_date = OKL_API.G_MISS_DATE)
        THEN
          x_cblv_rec.interest_calc_date := l_db_cblv_rec.interest_calc_date;
        END IF;
        IF (x_cblv_rec.interest_accrued_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.interest_accrued_amt := l_db_cblv_rec.interest_accrued_amt;
        END IF;
        IF (x_cblv_rec.interest_accrued_date = OKL_API.G_MISS_DATE)
        THEN
          x_cblv_rec.interest_accrued_date := l_db_cblv_rec.interest_accrued_date;
        END IF;
        IF (x_cblv_rec.interest_billed_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.interest_billed_amt := l_db_cblv_rec.interest_billed_amt;
        END IF;
        IF (x_cblv_rec.interest_billed_date = OKL_API.G_MISS_DATE)
        THEN
          x_cblv_rec.interest_billed_date := l_db_cblv_rec.interest_billed_date;
        END IF;
        IF (x_cblv_rec.interest_received_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.interest_received_amt := l_db_cblv_rec.interest_received_amt;
        END IF;
        IF (x_cblv_rec.interest_received_date = OKL_API.G_MISS_DATE)
        THEN
          x_cblv_rec.interest_received_date := l_db_cblv_rec.interest_received_date;
        END IF;
        IF (x_cblv_rec.termination_value_amt = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.termination_value_amt := l_db_cblv_rec.termination_value_amt;
        END IF;
        IF (x_cblv_rec.termination_date = OKL_API.G_MISS_DATE)
        THEN
          x_cblv_rec.termination_date := l_db_cblv_rec.termination_date;
        END IF;
        IF (x_cblv_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.org_id := l_db_cblv_rec.org_id;
        END IF;
        IF (x_cblv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.request_id := l_db_cblv_rec.request_id;
        END IF;
        IF (x_cblv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.program_application_id := l_db_cblv_rec.program_application_id;
        END IF;
        IF (x_cblv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.program_id := l_db_cblv_rec.program_id;
        END IF;
        IF (x_cblv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_cblv_rec.program_update_date := l_db_cblv_rec.program_update_date;
        END IF;
        IF (x_cblv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute_category := l_db_cblv_rec.attribute_category;
        END IF;
        IF (x_cblv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute1 := l_db_cblv_rec.attribute1;
        END IF;
        IF (x_cblv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute2 := l_db_cblv_rec.attribute2;
        END IF;
        IF (x_cblv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute3 := l_db_cblv_rec.attribute3;
        END IF;
        IF (x_cblv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute4 := l_db_cblv_rec.attribute4;
        END IF;
        IF (x_cblv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute5 := l_db_cblv_rec.attribute5;
        END IF;
        IF (x_cblv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute6 := l_db_cblv_rec.attribute6;
        END IF;
        IF (x_cblv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute7 := l_db_cblv_rec.attribute7;
        END IF;
        IF (x_cblv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute8 := l_db_cblv_rec.attribute8;
        END IF;
        IF (x_cblv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute9 := l_db_cblv_rec.attribute9;
        END IF;
        IF (x_cblv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute10 := l_db_cblv_rec.attribute10;
        END IF;
        IF (x_cblv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute11 := l_db_cblv_rec.attribute11;
        END IF;
        IF (x_cblv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute12 := l_db_cblv_rec.attribute12;
        END IF;
        IF (x_cblv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute13 := l_db_cblv_rec.attribute13;
        END IF;
        IF (x_cblv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute14 := l_db_cblv_rec.attribute14;
        END IF;
        IF (x_cblv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_cblv_rec.attribute15 := l_db_cblv_rec.attribute15;
        END IF;
        IF (x_cblv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.created_by := l_db_cblv_rec.created_by;
        END IF;
        IF (x_cblv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_cblv_rec.creation_date := l_db_cblv_rec.creation_date;
        END IF;
        IF (x_cblv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.last_updated_by := l_db_cblv_rec.last_updated_by;
        END IF;
        IF (x_cblv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_cblv_rec.last_update_date := l_db_cblv_rec.last_update_date;
        END IF;
        IF (x_cblv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.last_update_login := l_db_cblv_rec.last_update_login;
        END IF;

        --start code added by pgomes on 18 OCT 2005
        IF (x_cblv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_cblv_rec.object_version_number := l_db_cblv_rec.object_version_number;
        END IF;
        --end code added by pgomes  on 18 OCT 2005
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_BALANCES_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_cblv_rec IN cblv_rec_type,
      x_cblv_rec OUT NOCOPY cblv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cblv_rec := p_cblv_rec;
      --start code added by dkagrawa on 20 OCT 2005
      IF (x_cblv_rec.request_id IS NULL OR x_cblv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
       SELECT
               NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
               x_cblv_rec.request_id),
               NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
               x_cblv_rec.program_application_id),
               NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
               x_cblv_rec.program_id),
               DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
               NULL,x_cblv_rec.program_update_date,SYSDATE)
	INTO
               x_cblv_rec.request_id,
               x_cblv_rec.program_application_id,
               x_cblv_rec.program_id,
               x_cblv_rec.program_update_date
        FROM dual;
      END IF;
      IF x_cblv_rec.org_id IS NULL OR x_cblv_rec.org_id = Okl_Api.G_MISS_NUM THEN
        x_cblv_rec.org_id := mo_global.get_current_org_id();
      END IF;
      --end code added by dkagrawa on 20 OCT 2005
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cblv_rec,                        -- IN
      l_cblv_rec);                       --dkagrawa changed x_cblv_rec to l_cblv_rec     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cblv_rec, l_def_cblv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cblv_rec := fill_who_columns(l_def_cblv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cblv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cblv_rec, l_db_cblv_rec);
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
      --code changed by pgomes on 18 OCT 2005
      --p_cblv_rec                     => p_cblv_rec);
      p_cblv_rec                     => l_def_cblv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_cblv_rec, l_cbl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cbl_rec,
      lx_cbl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cbl_rec, l_def_cblv_rec);
    x_cblv_rec := l_def_cblv_rec;
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
  -- PL/SQL TBL update_row for:cblv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_tbl                     IN cblv_tbl_type,
    x_cblv_tbl                     OUT NOCOPY cblv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cblv_tbl.COUNT > 0) THEN
      i := p_cblv_tbl.FIRST;
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
            p_cblv_rec                     => p_cblv_tbl(i),
            x_cblv_rec                     => x_cblv_tbl(i));
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
        EXIT WHEN (i = p_cblv_tbl.LAST);
        i := p_cblv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:CBLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_tbl                     IN cblv_tbl_type,
    x_cblv_tbl                     OUT NOCOPY cblv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cblv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cblv_tbl                     => p_cblv_tbl,
        x_cblv_tbl                     => x_cblv_tbl,
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
  ------------------------------------------
  -- delete_row for:OKL_CONTRACT_BALANCES --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cbl_rec                      IN cbl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cbl_rec                      cbl_rec_type := p_cbl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_CONTRACT_BALANCES
     WHERE ID = p_cbl_rec.id;

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
  --------------------------------------------
  -- delete_row for:OKL_CONTRACT_BALANCES_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_rec                     IN cblv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cblv_rec                     cblv_rec_type := p_cblv_rec;
    l_cbl_rec                      cbl_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_cblv_rec, l_cbl_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cbl_rec
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
  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CONTRACT_BALANCES_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_tbl                     IN cblv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cblv_tbl.COUNT > 0) THEN
      i := p_cblv_tbl.FIRST;
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
            p_cblv_rec                     => p_cblv_tbl(i));
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
        EXIT WHEN (i = p_cblv_tbl.LAST);
        i := p_cblv_tbl.NEXT(i);
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

  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CONTRACT_BALANCES_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cblv_tbl                     IN cblv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cblv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cblv_tbl                     => p_cblv_tbl,
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

END OKL_CBL_PVT;

/
