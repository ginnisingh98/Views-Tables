--------------------------------------------------------
--  DDL for Package Body OKL_TAA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAA_PVT" AS
/* $Header: OKLSTAAB.pls 120.2 2005/10/30 04:02:45 appldev noship $ */
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
  -- FUNCTION get_rec for: OKL_TAA_REQUEST_DETAILS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_taav_rec                     IN taav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN taav_rec_type IS
    CURSOR okl_taav_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            TCN_ID,
            NEW_CONTRACT_NUMBER,
            BILL_TO_SITE_ID,
            CUST_ACCT_ID,
            BANK_ACCT_ID,
            INVOICE_FORMAT_ID,
            PAYMENT_MTHD_ID,
            MLA_ID,
            CREDIT_LINE_ID,
            INSURANCE_YN,
            LEASE_POLICY_YN,
            IPY_TYPE,
            POLICY_NUMBER,
            COVERED_AMT,
            DEDUCTIBLE_AMT,
            EFFECTIVE_TO_DATE,
            EFFECTIVE_FROM_DATE,
            PROOF_PROVIDED_DATE,
            PROOF_REQUIRED_DATE,
            LESSOR_INSURED_YN,
            LESSOR_PAYEE_YN,
            INT_ID,
            ISU_ID,
            AGENCY_SITE_ID,
            AGENT_SITE_ID,
            TERRITORY_CODE,
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
      FROM Okl_Taa_Request_Details_V
     WHERE okl_taa_request_details_v.id = p_id;
    l_okl_taav_pk                  okl_taav_pk_csr%ROWTYPE;
    l_taav_rec                     taav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_taav_pk_csr (p_taav_rec.id);
    FETCH okl_taav_pk_csr INTO
              l_taav_rec.id,
              l_taav_rec.tcn_id,
              l_taav_rec.new_contract_number,
              l_taav_rec.bill_to_site_id,
              l_taav_rec.cust_acct_id,
              l_taav_rec.bank_acct_id,
              l_taav_rec.invoice_format_id,
              l_taav_rec.payment_mthd_id,
              l_taav_rec.mla_id,
              l_taav_rec.credit_line_id,
              l_taav_rec.insurance_yn,
              l_taav_rec.lease_policy_yn,
              l_taav_rec.ipy_type,
              l_taav_rec.policy_number,
              l_taav_rec.covered_amt,
              l_taav_rec.deductible_amt,
              l_taav_rec.effective_to_date,
              l_taav_rec.effective_from_date,
              l_taav_rec.proof_provided_date,
              l_taav_rec.proof_required_date,
              l_taav_rec.lessor_insured_yn,
              l_taav_rec.lessor_payee_yn,
              l_taav_rec.int_id,
              l_taav_rec.isu_id,
              l_taav_rec.agency_site_id,
              l_taav_rec.agent_site_id,
              l_taav_rec.territory_code,
              l_taav_rec.attribute_category,
              l_taav_rec.attribute1,
              l_taav_rec.attribute2,
              l_taav_rec.attribute3,
              l_taav_rec.attribute4,
              l_taav_rec.attribute5,
              l_taav_rec.attribute6,
              l_taav_rec.attribute7,
              l_taav_rec.attribute8,
              l_taav_rec.attribute9,
              l_taav_rec.attribute10,
              l_taav_rec.attribute11,
              l_taav_rec.attribute12,
              l_taav_rec.attribute13,
              l_taav_rec.attribute14,
              l_taav_rec.attribute15,
              l_taav_rec.created_by,
              l_taav_rec.creation_date,
              l_taav_rec.last_updated_by,
              l_taav_rec.last_update_date,
              l_taav_rec.last_update_login;
    x_no_data_found := okl_taav_pk_csr%NOTFOUND;
    CLOSE okl_taav_pk_csr;
    RETURN(l_taav_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_taav_rec                     IN taav_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN taav_rec_type IS
    l_taav_rec                     taav_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_taav_rec := get_rec(p_taav_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_taav_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_taav_rec                     IN taav_rec_type
  ) RETURN taav_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_taav_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TAA_REQUEST_DETAILS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_taa_rec                      IN taa_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN taa_rec_type IS
    CURSOR okl_taa_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            TCN_ID,
            NEW_CONTRACT_NUMBER,
            BILL_TO_SITE_ID,
            CUST_ACCT_ID,
            BANK_ACCT_ID,
            INVOICE_FORMAT_ID,
            PAYMENT_MTHD_ID,
            MLA_ID,
            CREDIT_LINE_ID,
            INSURANCE_YN,
            LEASE_POLICY_YN,
            IPY_TYPE,
            POLICY_NUMBER,
            COVERED_AMT,
            DEDUCTIBLE_AMT,
            EFFECTIVE_TO_DATE,
            EFFECTIVE_FROM_DATE,
            PROOF_PROVIDED_DATE,
            PROOF_REQUIRED_DATE,
            LESSOR_INSURED_YN,
            LESSOR_PAYEE_YN,
            INT_ID,
            ISU_ID,
            AGENCY_SITE_ID,
            AGENT_SITE_ID,
            TERRITORY_CODE,
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
      FROM Okl_Taa_Request_Details_B
     WHERE okl_taa_request_details_b.id = p_id;
    l_okl_taa_pk                   okl_taa_pk_csr%ROWTYPE;
    l_taa_rec                      taa_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_taa_pk_csr (p_taa_rec.id);
    FETCH okl_taa_pk_csr INTO
              l_taa_rec.id,
              l_taa_rec.tcn_id,
              l_taa_rec.new_contract_number,
              l_taa_rec.bill_to_site_id,
              l_taa_rec.cust_acct_id,
              l_taa_rec.bank_acct_id,
              l_taa_rec.invoice_format_id,
              l_taa_rec.payment_mthd_id,
              l_taa_rec.mla_id,
              l_taa_rec.credit_line_id,
              l_taa_rec.insurance_yn,
              l_taa_rec.lease_policy_yn,
              l_taa_rec.ipy_type,
              l_taa_rec.policy_number,
              l_taa_rec.covered_amt,
              l_taa_rec.deductible_amt,
              l_taa_rec.effective_to_date,
              l_taa_rec.effective_from_date,
              l_taa_rec.proof_provided_date,
              l_taa_rec.proof_required_date,
              l_taa_rec.lessor_insured_yn,
              l_taa_rec.lessor_payee_yn,
              l_taa_rec.int_id,
              l_taa_rec.isu_id,
              l_taa_rec.agency_site_id,
              l_taa_rec.agent_site_id,
              l_taa_rec.territory_code,
              l_taa_rec.attribute_category,
              l_taa_rec.attribute1,
              l_taa_rec.attribute2,
              l_taa_rec.attribute3,
              l_taa_rec.attribute4,
              l_taa_rec.attribute5,
              l_taa_rec.attribute6,
              l_taa_rec.attribute7,
              l_taa_rec.attribute8,
              l_taa_rec.attribute9,
              l_taa_rec.attribute10,
              l_taa_rec.attribute11,
              l_taa_rec.attribute12,
              l_taa_rec.attribute13,
              l_taa_rec.attribute14,
              l_taa_rec.attribute15,
              l_taa_rec.created_by,
              l_taa_rec.creation_date,
              l_taa_rec.last_updated_by,
              l_taa_rec.last_update_date,
              l_taa_rec.last_update_login;
    x_no_data_found := okl_taa_pk_csr%NOTFOUND;
    CLOSE okl_taa_pk_csr;
    RETURN(l_taa_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_taa_rec                      IN taa_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN taa_rec_type IS
    l_taa_rec                      taa_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_taa_rec := get_rec(p_taa_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_taa_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_taa_rec                      IN taa_rec_type
  ) RETURN taa_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_taa_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TAA_REQUEST_DETAILS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_taav_rec   IN taav_rec_type
  ) RETURN taav_rec_type IS
    l_taav_rec                     taav_rec_type := p_taav_rec;
  BEGIN
    IF (l_taav_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.id := NULL;
    END IF;
    IF (l_taav_rec.tcn_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.tcn_id := NULL;
    END IF;
    IF (l_taav_rec.new_contract_number = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.new_contract_number := NULL;
    END IF;
    IF (l_taav_rec.bill_to_site_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.bill_to_site_id := NULL;
    END IF;
    IF (l_taav_rec.cust_acct_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.cust_acct_id := NULL;
    END IF;
    IF (l_taav_rec.bank_acct_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.bank_acct_id := NULL;
    END IF;
    IF (l_taav_rec.invoice_format_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.invoice_format_id := NULL;
    END IF;
    IF (l_taav_rec.payment_mthd_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.payment_mthd_id := NULL;
    END IF;
    IF (l_taav_rec.mla_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.mla_id := NULL;
    END IF;
    IF (l_taav_rec.credit_line_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.credit_line_id := NULL;
    END IF;
    IF (l_taav_rec.insurance_yn = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.insurance_yn := NULL;
    END IF;
    IF (l_taav_rec.lease_policy_yn = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.lease_policy_yn := NULL;
    END IF;
    IF (l_taav_rec.ipy_type = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.ipy_type := NULL;
    END IF;
    IF (l_taav_rec.policy_number = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.policy_number := NULL;
    END IF;
    IF (l_taav_rec.covered_amt = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.covered_amt := NULL;
    END IF;
    IF (l_taav_rec.deductible_amt = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.deductible_amt := NULL;
    END IF;
    IF (l_taav_rec.effective_to_date = OKC_API.G_MISS_DATE ) THEN
      l_taav_rec.effective_to_date := NULL;
    END IF;
    IF (l_taav_rec.effective_from_date = OKC_API.G_MISS_DATE ) THEN
      l_taav_rec.effective_from_date := NULL;
    END IF;
    IF (l_taav_rec.proof_provided_date = OKC_API.G_MISS_DATE ) THEN
      l_taav_rec.proof_provided_date := NULL;
    END IF;
    IF (l_taav_rec.proof_required_date = OKC_API.G_MISS_DATE ) THEN
      l_taav_rec.proof_required_date := NULL;
    END IF;
    IF (l_taav_rec.lessor_insured_yn = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.lessor_insured_yn := NULL;
    END IF;
    IF (l_taav_rec.lessor_payee_yn = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.lessor_payee_yn := NULL;
    END IF;
    IF (l_taav_rec.int_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.int_id := NULL;
    END IF;
    IF (l_taav_rec.isu_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.isu_id := NULL;
    END IF;
    IF (l_taav_rec.agency_site_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.agency_site_id := NULL;
    END IF;
    IF (l_taav_rec.agent_site_id = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.agent_site_id := NULL;
    END IF;
    IF (l_taav_rec.territory_code = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.territory_code := NULL;
    END IF;
    IF (l_taav_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute_category := NULL;
    END IF;
    IF (l_taav_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute1 := NULL;
    END IF;
    IF (l_taav_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute2 := NULL;
    END IF;
    IF (l_taav_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute3 := NULL;
    END IF;
    IF (l_taav_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute4 := NULL;
    END IF;
    IF (l_taav_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute5 := NULL;
    END IF;
    IF (l_taav_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute6 := NULL;
    END IF;
    IF (l_taav_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute7 := NULL;
    END IF;
    IF (l_taav_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute8 := NULL;
    END IF;
    IF (l_taav_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute9 := NULL;
    END IF;
    IF (l_taav_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute10 := NULL;
    END IF;
    IF (l_taav_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute11 := NULL;
    END IF;
    IF (l_taav_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute12 := NULL;
    END IF;
    IF (l_taav_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute13 := NULL;
    END IF;
    IF (l_taav_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute14 := NULL;
    END IF;
    IF (l_taav_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_taav_rec.attribute15 := NULL;
    END IF;
    IF (l_taav_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.created_by := NULL;
    END IF;
    IF (l_taav_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_taav_rec.creation_date := NULL;
    END IF;
    IF (l_taav_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.last_updated_by := NULL;
    END IF;
    IF (l_taav_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_taav_rec.last_update_date := NULL;
    END IF;
    IF (l_taav_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_taav_rec.last_update_login := NULL;
    END IF;
    RETURN(l_taav_rec);
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
  -------------------------------------
  -- Validate_Attributes for: TCN_ID --
  -------------------------------------
  PROCEDURE validate_tcn_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tcn_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tcn_id = OKC_API.G_MISS_NUM OR
        p_tcn_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tcn_id');
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
  END validate_tcn_id;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------------
  -- Validate_Attributes for:OKL_TAA_REQUEST_DETAILS_V --
  -------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_taav_rec                     IN taav_rec_type
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
    validate_id(x_return_status, p_taav_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- tcn_id
    -- ***
    validate_tcn_id(x_return_status, p_taav_rec.tcn_id);
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
  ---------------------------------------------------
  -- Validate Record for:OKL_TAA_REQUEST_DETAILS_V --
  ---------------------------------------------------
  FUNCTION Validate_Record (
    p_taav_rec IN taav_rec_type,
    p_db_taav_rec IN taav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_taav_rec IN taav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_taav_rec                  taav_rec_type := get_rec(p_taav_rec);
  BEGIN
    l_return_status := Validate_Record(p_taav_rec => p_taav_rec,
                                       p_db_taav_rec => l_db_taav_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN taav_rec_type,
    p_to   IN OUT NOCOPY taa_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.tcn_id := p_from.tcn_id;
    p_to.new_contract_number := p_from.new_contract_number;
    p_to.bill_to_site_id := p_from.bill_to_site_id;
    p_to.cust_acct_id := p_from.cust_acct_id;
    p_to.bank_acct_id := p_from.bank_acct_id;
    p_to.invoice_format_id := p_from.invoice_format_id;
    p_to.payment_mthd_id := p_from.payment_mthd_id;
    p_to.mla_id := p_from.mla_id;
    p_to.credit_line_id := p_from.credit_line_id;
    p_to.insurance_yn := p_from.insurance_yn;
    p_to.lease_policy_yn := p_from.lease_policy_yn;
    p_to.ipy_type := p_from.ipy_type;
    p_to.policy_number := p_from.policy_number;
    p_to.covered_amt := p_from.covered_amt;
    p_to.deductible_amt := p_from.deductible_amt;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.proof_provided_date := p_from.proof_provided_date;
    p_to.proof_required_date := p_from.proof_required_date;
    p_to.lessor_insured_yn := p_from.lessor_insured_yn;
    p_to.lessor_payee_yn := p_from.lessor_payee_yn;
    p_to.int_id := p_from.int_id;
    p_to.isu_id := p_from.isu_id;
    p_to.agency_site_id := p_from.agency_site_id;
    p_to.agent_site_id := p_from.agent_site_id;
    p_to.territory_code := p_from.territory_code;
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
    p_from IN taa_rec_type,
    p_to   IN OUT NOCOPY taav_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.tcn_id := p_from.tcn_id;
    p_to.new_contract_number := p_from.new_contract_number;
    p_to.bill_to_site_id := p_from.bill_to_site_id;
    p_to.cust_acct_id := p_from.cust_acct_id;
    p_to.bank_acct_id := p_from.bank_acct_id;
    p_to.invoice_format_id := p_from.invoice_format_id;
    p_to.payment_mthd_id := p_from.payment_mthd_id;
    p_to.mla_id := p_from.mla_id;
    p_to.credit_line_id := p_from.credit_line_id;
    p_to.insurance_yn := p_from.insurance_yn;
    p_to.lease_policy_yn := p_from.lease_policy_yn;
    p_to.ipy_type := p_from.ipy_type;
    p_to.policy_number := p_from.policy_number;
    p_to.covered_amt := p_from.covered_amt;
    p_to.deductible_amt := p_from.deductible_amt;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.proof_provided_date := p_from.proof_provided_date;
    p_to.proof_required_date := p_from.proof_required_date;
    p_to.lessor_insured_yn := p_from.lessor_insured_yn;
    p_to.lessor_payee_yn := p_from.lessor_payee_yn;
    p_to.int_id := p_from.int_id;
    p_to.isu_id := p_from.isu_id;
    p_to.agency_site_id := p_from.agency_site_id;
    p_to.agent_site_id := p_from.agent_site_id;
    p_to.territory_code := p_from.territory_code;
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
  ------------------------------------------------
  -- validate_row for:OKL_TAA_REQUEST_DETAILS_V --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_rec                     IN taav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_taav_rec                     taav_rec_type := p_taav_rec;
    l_taa_rec                      taa_rec_type;
    l_taa_rec                      taa_rec_type;
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
    l_return_status := Validate_Attributes(l_taav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_taav_rec);
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
  -- PL/SQL TBL validate_row for:OKL_TAA_REQUEST_DETAILS_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taav_tbl.COUNT > 0) THEN
      i := p_taav_tbl.FIRST;
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
            p_taav_rec                     => p_taav_tbl(i));
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
        EXIT WHEN (i = p_taav_tbl.LAST);
        i := p_taav_tbl.NEXT(i);
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
  -- PL/SQL TBL validate_row for:OKL_TAA_REQUEST_DETAILS_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taav_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_taav_tbl                     => p_taav_tbl,
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
  ----------------------------------------------
  -- insert_row for:OKL_TAA_REQUEST_DETAILS_B --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taa_rec                      IN taa_rec_type,
    x_taa_rec                      OUT NOCOPY taa_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_taa_rec                      taa_rec_type := p_taa_rec;
    l_def_taa_rec                  taa_rec_type;
    --------------------------------------------------
    -- Set_Attributes for:OKL_TAA_REQUEST_DETAILS_B --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_taa_rec IN taa_rec_type,
      x_taa_rec OUT NOCOPY taa_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_taa_rec := p_taa_rec;
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
      p_taa_rec,                         -- IN
      l_taa_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TAA_REQUEST_DETAILS_B(
      id,
      tcn_id,
      new_contract_number,
      bill_to_site_id,
      cust_acct_id,
      bank_acct_id,
      invoice_format_id,
      payment_mthd_id,
      mla_id,
      credit_line_id,
      insurance_yn,
      lease_policy_yn,
      ipy_type,
      policy_number,
      covered_amt,
      deductible_amt,
      effective_to_date,
      effective_from_date,
      proof_provided_date,
      proof_required_date,
      lessor_insured_yn,
      lessor_payee_yn,
      int_id,
      isu_id,
      agency_site_id,
      agent_site_id,
      territory_code,
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
      l_taa_rec.id,
      l_taa_rec.tcn_id,
      l_taa_rec.new_contract_number,
      l_taa_rec.bill_to_site_id,
      l_taa_rec.cust_acct_id,
      l_taa_rec.bank_acct_id,
      l_taa_rec.invoice_format_id,
      l_taa_rec.payment_mthd_id,
      l_taa_rec.mla_id,
      l_taa_rec.credit_line_id,
      l_taa_rec.insurance_yn,
      l_taa_rec.lease_policy_yn,
      l_taa_rec.ipy_type,
      l_taa_rec.policy_number,
      l_taa_rec.covered_amt,
      l_taa_rec.deductible_amt,
      l_taa_rec.effective_to_date,
      l_taa_rec.effective_from_date,
      l_taa_rec.proof_provided_date,
      l_taa_rec.proof_required_date,
      l_taa_rec.lessor_insured_yn,
      l_taa_rec.lessor_payee_yn,
      l_taa_rec.int_id,
      l_taa_rec.isu_id,
      l_taa_rec.agency_site_id,
      l_taa_rec.agent_site_id,
      l_taa_rec.territory_code,
      l_taa_rec.attribute_category,
      l_taa_rec.attribute1,
      l_taa_rec.attribute2,
      l_taa_rec.attribute3,
      l_taa_rec.attribute4,
      l_taa_rec.attribute5,
      l_taa_rec.attribute6,
      l_taa_rec.attribute7,
      l_taa_rec.attribute8,
      l_taa_rec.attribute9,
      l_taa_rec.attribute10,
      l_taa_rec.attribute11,
      l_taa_rec.attribute12,
      l_taa_rec.attribute13,
      l_taa_rec.attribute14,
      l_taa_rec.attribute15,
      l_taa_rec.created_by,
      l_taa_rec.creation_date,
      l_taa_rec.last_updated_by,
      l_taa_rec.last_update_date,
      l_taa_rec.last_update_login);
    -- Set OUT values
    x_taa_rec := l_taa_rec;
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
  -- insert_row for :OKL_TAA_REQUEST_DETAILS_V --
  -----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_rec                     IN taav_rec_type,
    x_taav_rec                     OUT NOCOPY taav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_taav_rec                     taav_rec_type := p_taav_rec;
    l_def_taav_rec                 taav_rec_type;
    l_taa_rec                      taa_rec_type;
    lx_taa_rec                     taa_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_taav_rec IN taav_rec_type
    ) RETURN taav_rec_type IS
      l_taav_rec taav_rec_type := p_taav_rec;
    BEGIN
      l_taav_rec.CREATION_DATE := SYSDATE;
      l_taav_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_taav_rec.LAST_UPDATE_DATE := l_taav_rec.CREATION_DATE;
      l_taav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_taav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_taav_rec);
    END fill_who_columns;
    --------------------------------------------------
    -- Set_Attributes for:OKL_TAA_REQUEST_DETAILS_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_taav_rec IN taav_rec_type,
      x_taav_rec OUT NOCOPY taav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_taav_rec := p_taav_rec;
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
    l_taav_rec := null_out_defaults(p_taav_rec);
    -- Set primary key value
    l_taav_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_taav_rec,                        -- IN
      l_def_taav_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_taav_rec := fill_who_columns(l_def_taav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_taav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_taav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_taav_rec, l_taa_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_taa_rec,
      lx_taa_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_taa_rec, l_def_taav_rec);
    -- Set OUT values
    x_taav_rec := l_def_taav_rec;
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
  -- PL/SQL TBL insert_row for:TAAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    x_taav_tbl                     OUT NOCOPY taav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taav_tbl.COUNT > 0) THEN
      i := p_taav_tbl.FIRST;
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
            p_taav_rec                     => p_taav_tbl(i),
            x_taav_rec                     => x_taav_tbl(i));
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
        EXIT WHEN (i = p_taav_tbl.LAST);
        i := p_taav_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:TAAV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    x_taav_tbl                     OUT NOCOPY taav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taav_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_taav_tbl                     => p_taav_tbl,
        x_taav_tbl                     => x_taav_tbl,
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
  --------------------------------------------
  -- lock_row for:OKL_TAA_REQUEST_DETAILS_B --
  --------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taa_rec                      IN taa_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_taa_rec IN taa_rec_type) IS
    SELECT *
      FROM OKL_TAA_REQUEST_DETAILS_B
     WHERE ID = p_taa_rec.id
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
      OPEN lock_csr(p_taa_rec);
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
      IF (l_lock_var.id <> p_taa_rec.id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tcn_id <> p_taa_rec.tcn_id) THEN
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
  ---------------------------------------------
  -- lock_row for: OKL_TAA_REQUEST_DETAILS_V --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_rec                     IN taav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_taa_rec                      taa_rec_type;
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
    migrate(p_taav_rec, l_taa_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_taa_rec
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
  -- PL/SQL TBL lock_row for:TAAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_taav_tbl.COUNT > 0) THEN
      i := p_taav_tbl.FIRST;
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
            p_taav_rec                     => p_taav_tbl(i));
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
        EXIT WHEN (i = p_taav_tbl.LAST);
        i := p_taav_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:TAAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_taav_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_taav_tbl                     => p_taav_tbl,
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
  ----------------------------------------------
  -- update_row for:OKL_TAA_REQUEST_DETAILS_B --
  ----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taa_rec                      IN taa_rec_type,
    x_taa_rec                      OUT NOCOPY taa_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_taa_rec                      taa_rec_type := p_taa_rec;
    l_def_taa_rec                  taa_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_taa_rec IN taa_rec_type,
      x_taa_rec OUT NOCOPY taa_rec_type
    ) RETURN VARCHAR2 IS
      l_taa_rec                      taa_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_taa_rec := p_taa_rec;
      -- Get current database values
      l_taa_rec := get_rec(p_taa_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_taa_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.id := l_taa_rec.id;
        END IF;
        IF (x_taa_rec.tcn_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.tcn_id := l_taa_rec.tcn_id;
        END IF;
        IF (x_taa_rec.new_contract_number = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.new_contract_number := l_taa_rec.new_contract_number;
        END IF;
        IF (x_taa_rec.bill_to_site_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.bill_to_site_id := l_taa_rec.bill_to_site_id;
        END IF;
        IF (x_taa_rec.cust_acct_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.cust_acct_id := l_taa_rec.cust_acct_id;
        END IF;
        IF (x_taa_rec.bank_acct_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.bank_acct_id := l_taa_rec.bank_acct_id;
        END IF;
        IF (x_taa_rec.invoice_format_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.invoice_format_id := l_taa_rec.invoice_format_id;
        END IF;
        IF (x_taa_rec.payment_mthd_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.payment_mthd_id := l_taa_rec.payment_mthd_id;
        END IF;
        IF (x_taa_rec.mla_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.mla_id := l_taa_rec.mla_id;
        END IF;
        IF (x_taa_rec.credit_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.credit_line_id := l_taa_rec.credit_line_id;
        END IF;
        IF (x_taa_rec.insurance_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.insurance_yn := l_taa_rec.insurance_yn;
        END IF;
        IF (x_taa_rec.lease_policy_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.lease_policy_yn := l_taa_rec.lease_policy_yn;
        END IF;
        IF (x_taa_rec.ipy_type = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.ipy_type := l_taa_rec.ipy_type;
        END IF;
        IF (x_taa_rec.policy_number = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.policy_number := l_taa_rec.policy_number;
        END IF;
        IF (x_taa_rec.covered_amt = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.covered_amt := l_taa_rec.covered_amt;
        END IF;
        IF (x_taa_rec.deductible_amt = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.deductible_amt := l_taa_rec.deductible_amt;
        END IF;
        IF (x_taa_rec.effective_to_date = OKC_API.G_MISS_DATE)
        THEN
          x_taa_rec.effective_to_date := l_taa_rec.effective_to_date;
        END IF;
        IF (x_taa_rec.effective_from_date = OKC_API.G_MISS_DATE)
        THEN
          x_taa_rec.effective_from_date := l_taa_rec.effective_from_date;
        END IF;
        IF (x_taa_rec.proof_provided_date = OKC_API.G_MISS_DATE)
        THEN
          x_taa_rec.proof_provided_date := l_taa_rec.proof_provided_date;
        END IF;
        IF (x_taa_rec.proof_required_date = OKC_API.G_MISS_DATE)
        THEN
          x_taa_rec.proof_required_date := l_taa_rec.proof_required_date;
        END IF;
        IF (x_taa_rec.lessor_insured_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.lessor_insured_yn := l_taa_rec.lessor_insured_yn;
        END IF;
        IF (x_taa_rec.lessor_payee_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.lessor_payee_yn := l_taa_rec.lessor_payee_yn;
        END IF;
        IF (x_taa_rec.int_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.int_id := l_taa_rec.int_id;
        END IF;
        IF (x_taa_rec.isu_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.isu_id := l_taa_rec.isu_id;
        END IF;
        IF (x_taa_rec.agency_site_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.agency_site_id := l_taa_rec.agency_site_id;
        END IF;
        IF (x_taa_rec.agent_site_id = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.agent_site_id := l_taa_rec.agent_site_id;
        END IF;
        IF (x_taa_rec.territory_code = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.territory_code := l_taa_rec.territory_code;
        END IF;
        IF (x_taa_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute_category := l_taa_rec.attribute_category;
        END IF;
        IF (x_taa_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute1 := l_taa_rec.attribute1;
        END IF;
        IF (x_taa_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute2 := l_taa_rec.attribute2;
        END IF;
        IF (x_taa_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute3 := l_taa_rec.attribute3;
        END IF;
        IF (x_taa_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute4 := l_taa_rec.attribute4;
        END IF;
        IF (x_taa_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute5 := l_taa_rec.attribute5;
        END IF;
        IF (x_taa_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute6 := l_taa_rec.attribute6;
        END IF;
        IF (x_taa_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute7 := l_taa_rec.attribute7;
        END IF;
        IF (x_taa_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute8 := l_taa_rec.attribute8;
        END IF;
        IF (x_taa_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute9 := l_taa_rec.attribute9;
        END IF;
        IF (x_taa_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute10 := l_taa_rec.attribute10;
        END IF;
        IF (x_taa_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute11 := l_taa_rec.attribute11;
        END IF;
        IF (x_taa_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute12 := l_taa_rec.attribute12;
        END IF;
        IF (x_taa_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute13 := l_taa_rec.attribute13;
        END IF;
        IF (x_taa_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute14 := l_taa_rec.attribute14;
        END IF;
        IF (x_taa_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_taa_rec.attribute15 := l_taa_rec.attribute15;
        END IF;
        IF (x_taa_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.created_by := l_taa_rec.created_by;
        END IF;
        IF (x_taa_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_taa_rec.creation_date := l_taa_rec.creation_date;
        END IF;
        IF (x_taa_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.last_updated_by := l_taa_rec.last_updated_by;
        END IF;
        IF (x_taa_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_taa_rec.last_update_date := l_taa_rec.last_update_date;
        END IF;
        IF (x_taa_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_taa_rec.last_update_login := l_taa_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_TAA_REQUEST_DETAILS_B --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_taa_rec IN taa_rec_type,
      x_taa_rec OUT NOCOPY taa_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_taa_rec := p_taa_rec;
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
      p_taa_rec,                         -- IN
      l_taa_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_taa_rec, l_def_taa_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_TAA_REQUEST_DETAILS_B
    SET TCN_ID = l_def_taa_rec.tcn_id,
        NEW_CONTRACT_NUMBER = l_def_taa_rec.new_contract_number,
        BILL_TO_SITE_ID = l_def_taa_rec.bill_to_site_id,
        CUST_ACCT_ID = l_def_taa_rec.cust_acct_id,
        BANK_ACCT_ID = l_def_taa_rec.bank_acct_id,
        INVOICE_FORMAT_ID = l_def_taa_rec.invoice_format_id,
        PAYMENT_MTHD_ID = l_def_taa_rec.payment_mthd_id,
        MLA_ID = l_def_taa_rec.mla_id,
        CREDIT_LINE_ID = l_def_taa_rec.credit_line_id,
        INSURANCE_YN = l_def_taa_rec.insurance_yn,
        LEASE_POLICY_YN = l_def_taa_rec.lease_policy_yn,
        IPY_TYPE = l_def_taa_rec.ipy_type,
        POLICY_NUMBER = l_def_taa_rec.policy_number,
        COVERED_AMT = l_def_taa_rec.covered_amt,
        DEDUCTIBLE_AMT = l_def_taa_rec.deductible_amt,
        EFFECTIVE_TO_DATE = l_def_taa_rec.effective_to_date,
        EFFECTIVE_FROM_DATE = l_def_taa_rec.effective_from_date,
        PROOF_PROVIDED_DATE = l_def_taa_rec.proof_provided_date,
        PROOF_REQUIRED_DATE = l_def_taa_rec.proof_required_date,
        LESSOR_INSURED_YN = l_def_taa_rec.lessor_insured_yn,
        LESSOR_PAYEE_YN = l_def_taa_rec.lessor_payee_yn,
        INT_ID = l_def_taa_rec.int_id,
        ISU_ID = l_def_taa_rec.isu_id,
        AGENCY_SITE_ID = l_def_taa_rec.agency_site_id,
        AGENT_SITE_ID = l_def_taa_rec.agent_site_id,
        TERRITORY_CODE = l_def_taa_rec.territory_code,
        ATTRIBUTE_CATEGORY = l_def_taa_rec.attribute_category,
        ATTRIBUTE1 = l_def_taa_rec.attribute1,
        ATTRIBUTE2 = l_def_taa_rec.attribute2,
        ATTRIBUTE3 = l_def_taa_rec.attribute3,
        ATTRIBUTE4 = l_def_taa_rec.attribute4,
        ATTRIBUTE5 = l_def_taa_rec.attribute5,
        ATTRIBUTE6 = l_def_taa_rec.attribute6,
        ATTRIBUTE7 = l_def_taa_rec.attribute7,
        ATTRIBUTE8 = l_def_taa_rec.attribute8,
        ATTRIBUTE9 = l_def_taa_rec.attribute9,
        ATTRIBUTE10 = l_def_taa_rec.attribute10,
        ATTRIBUTE11 = l_def_taa_rec.attribute11,
        ATTRIBUTE12 = l_def_taa_rec.attribute12,
        ATTRIBUTE13 = l_def_taa_rec.attribute13,
        ATTRIBUTE14 = l_def_taa_rec.attribute14,
        ATTRIBUTE15 = l_def_taa_rec.attribute15,
        CREATED_BY = l_def_taa_rec.created_by,
        CREATION_DATE = l_def_taa_rec.creation_date,
        LAST_UPDATED_BY = l_def_taa_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_taa_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_taa_rec.last_update_login
    WHERE ID = l_def_taa_rec.id;

    x_taa_rec := l_taa_rec;
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
  -- update_row for:OKL_TAA_REQUEST_DETAILS_V --
  ----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_rec                     IN taav_rec_type,
    x_taav_rec                     OUT NOCOPY taav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_taav_rec                     taav_rec_type := p_taav_rec;
    l_def_taav_rec                 taav_rec_type;
    l_db_taav_rec                  taav_rec_type;
    l_taa_rec                      taa_rec_type;
    lx_taa_rec                     taa_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_taav_rec IN taav_rec_type
    ) RETURN taav_rec_type IS
      l_taav_rec taav_rec_type := p_taav_rec;
    BEGIN
      l_taav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_taav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_taav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_taav_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_taav_rec IN taav_rec_type,
      x_taav_rec OUT NOCOPY taav_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_taav_rec := p_taav_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_taav_rec := get_rec(p_taav_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_taav_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.id := l_db_taav_rec.id;
        END IF;
        IF (x_taav_rec.tcn_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.tcn_id := l_db_taav_rec.tcn_id;
        END IF;
        IF (x_taav_rec.new_contract_number = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.new_contract_number := l_db_taav_rec.new_contract_number;
        END IF;
        IF (x_taav_rec.bill_to_site_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.bill_to_site_id := l_db_taav_rec.bill_to_site_id;
        END IF;
        IF (x_taav_rec.cust_acct_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.cust_acct_id := l_db_taav_rec.cust_acct_id;
        END IF;
        IF (x_taav_rec.bank_acct_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.bank_acct_id := l_db_taav_rec.bank_acct_id;
        END IF;
        IF (x_taav_rec.invoice_format_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.invoice_format_id := l_db_taav_rec.invoice_format_id;
        END IF;
        IF (x_taav_rec.payment_mthd_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.payment_mthd_id := l_db_taav_rec.payment_mthd_id;
        END IF;
        IF (x_taav_rec.mla_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.mla_id := l_db_taav_rec.mla_id;
        END IF;
        IF (x_taav_rec.credit_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.credit_line_id := l_db_taav_rec.credit_line_id;
        END IF;
        IF (x_taav_rec.insurance_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.insurance_yn := l_db_taav_rec.insurance_yn;
        END IF;
        IF (x_taav_rec.lease_policy_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.lease_policy_yn := l_db_taav_rec.lease_policy_yn;
        END IF;
        IF (x_taav_rec.ipy_type = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.ipy_type := l_db_taav_rec.ipy_type;
        END IF;
        IF (x_taav_rec.policy_number = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.policy_number := l_db_taav_rec.policy_number;
        END IF;
        IF (x_taav_rec.covered_amt = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.covered_amt := l_db_taav_rec.covered_amt;
        END IF;
        IF (x_taav_rec.deductible_amt = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.deductible_amt := l_db_taav_rec.deductible_amt;
        END IF;
        IF (x_taav_rec.effective_to_date = OKC_API.G_MISS_DATE)
        THEN
          x_taav_rec.effective_to_date := l_db_taav_rec.effective_to_date;
        END IF;
        IF (x_taav_rec.effective_from_date = OKC_API.G_MISS_DATE)
        THEN
          x_taav_rec.effective_from_date := l_db_taav_rec.effective_from_date;
        END IF;
        IF (x_taav_rec.proof_provided_date = OKC_API.G_MISS_DATE)
        THEN
          x_taav_rec.proof_provided_date := l_db_taav_rec.proof_provided_date;
        END IF;
        IF (x_taav_rec.proof_required_date = OKC_API.G_MISS_DATE)
        THEN
          x_taav_rec.proof_required_date := l_db_taav_rec.proof_required_date;
        END IF;
        IF (x_taav_rec.lessor_insured_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.lessor_insured_yn := l_db_taav_rec.lessor_insured_yn;
        END IF;
        IF (x_taav_rec.lessor_payee_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.lessor_payee_yn := l_db_taav_rec.lessor_payee_yn;
        END IF;
        IF (x_taav_rec.int_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.int_id := l_db_taav_rec.int_id;
        END IF;
        IF (x_taav_rec.isu_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.isu_id := l_db_taav_rec.isu_id;
        END IF;
        IF (x_taav_rec.agency_site_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.agency_site_id := l_db_taav_rec.agency_site_id;
        END IF;
        IF (x_taav_rec.agent_site_id = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.agent_site_id := l_db_taav_rec.agent_site_id;
        END IF;
        IF (x_taav_rec.territory_code = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.territory_code := l_db_taav_rec.territory_code;
        END IF;
        IF (x_taav_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute_category := l_db_taav_rec.attribute_category;
        END IF;
        IF (x_taav_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute1 := l_db_taav_rec.attribute1;
        END IF;
        IF (x_taav_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute2 := l_db_taav_rec.attribute2;
        END IF;
        IF (x_taav_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute3 := l_db_taav_rec.attribute3;
        END IF;
        IF (x_taav_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute4 := l_db_taav_rec.attribute4;
        END IF;
        IF (x_taav_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute5 := l_db_taav_rec.attribute5;
        END IF;
        IF (x_taav_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute6 := l_db_taav_rec.attribute6;
        END IF;
        IF (x_taav_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute7 := l_db_taav_rec.attribute7;
        END IF;
        IF (x_taav_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute8 := l_db_taav_rec.attribute8;
        END IF;
        IF (x_taav_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute9 := l_db_taav_rec.attribute9;
        END IF;
        IF (x_taav_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute10 := l_db_taav_rec.attribute10;
        END IF;
        IF (x_taav_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute11 := l_db_taav_rec.attribute11;
        END IF;
        IF (x_taav_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute12 := l_db_taav_rec.attribute12;
        END IF;
        IF (x_taav_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute13 := l_db_taav_rec.attribute13;
        END IF;
        IF (x_taav_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute14 := l_db_taav_rec.attribute14;
        END IF;
        IF (x_taav_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_taav_rec.attribute15 := l_db_taav_rec.attribute15;
        END IF;
        IF (x_taav_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.created_by := l_db_taav_rec.created_by;
        END IF;
        IF (x_taav_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_taav_rec.creation_date := l_db_taav_rec.creation_date;
        END IF;
        IF (x_taav_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.last_updated_by := l_db_taav_rec.last_updated_by;
        END IF;
        IF (x_taav_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_taav_rec.last_update_date := l_db_taav_rec.last_update_date;
        END IF;
        IF (x_taav_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_taav_rec.last_update_login := l_db_taav_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_TAA_REQUEST_DETAILS_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_taav_rec IN taav_rec_type,
      x_taav_rec OUT NOCOPY taav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_taav_rec := p_taav_rec;
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
      p_taav_rec,                        -- IN
      x_taav_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_taav_rec, l_def_taav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_taav_rec := fill_who_columns(l_def_taav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_taav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_taav_rec, l_db_taav_rec);
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
      p_taav_rec                     => p_taav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_taav_rec, l_taa_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_taa_rec,
      lx_taa_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_taa_rec, l_def_taav_rec);
    x_taav_rec := l_def_taav_rec;
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
  -- PL/SQL TBL update_row for:taav_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    x_taav_tbl                     OUT NOCOPY taav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taav_tbl.COUNT > 0) THEN
      i := p_taav_tbl.FIRST;
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
            p_taav_rec                     => p_taav_tbl(i),
            x_taav_rec                     => x_taav_tbl(i));
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
        EXIT WHEN (i = p_taav_tbl.LAST);
        i := p_taav_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:TAAV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    x_taav_tbl                     OUT NOCOPY taav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taav_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_taav_tbl                     => p_taav_tbl,
        x_taav_tbl                     => x_taav_tbl,
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
  ----------------------------------------------
  -- delete_row for:OKL_TAA_REQUEST_DETAILS_B --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taa_rec                      IN taa_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_taa_rec                      taa_rec_type := p_taa_rec;
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

    DELETE FROM OKL_TAA_REQUEST_DETAILS_B
     WHERE ID = p_taa_rec.id;

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
  -- delete_row for:OKL_TAA_REQUEST_DETAILS_V --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_rec                     IN taav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_taav_rec                     taav_rec_type := p_taav_rec;
    l_taa_rec                      taa_rec_type;
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
    migrate(l_taav_rec, l_taa_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_taa_rec
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
  -- PL/SQL TBL delete_row for:OKL_TAA_REQUEST_DETAILS_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taav_tbl.COUNT > 0) THEN
      i := p_taav_tbl.FIRST;
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
            p_taav_rec                     => p_taav_tbl(i));
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
        EXIT WHEN (i = p_taav_tbl.LAST);
        i := p_taav_tbl.NEXT(i);
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
  -- PL/SQL TBL delete_row for:OKL_TAA_REQUEST_DETAILS_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taav_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_taav_tbl                     => p_taav_tbl,
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

END OKL_TAA_PVT;

/
