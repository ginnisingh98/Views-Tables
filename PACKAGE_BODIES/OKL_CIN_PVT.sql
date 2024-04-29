--------------------------------------------------------
--  DDL for Package Body OKL_CIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CIN_PVT" AS
/* $Header: OKLSCINB.pls 120.1 2007/05/03 18:23:14 cklee noship $ */
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
    l_pk_value NUMBER;
--start:|           May 3, 2007 cklee -- fixed sequence issue                        |                                                                 |
--    CURSOR c_pk_csr IS SELECT okl_cnsld_ap_invs_all_s.NEXTVAL FROM DUAL;
    CURSOR c_pk_csr IS SELECT okl_cnsld_ap_invs_s.NEXTVAL FROM DUAL;
--end:|           May 3, 2007 cklee -- fixed sequence issue                        |                                                                 |
  BEGIN
  /* Fetch the pk value from the sequence */
    OPEN c_pk_csr;
    FETCH c_pk_csr INTO l_pk_value;
    CLOSE c_pk_csr;
    RETURN l_pk_value;
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
  -- FUNCTION get_rec for: OKL_CNSLD_AP_INVS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cin_rec                      IN cin_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cin_rec_type IS
    CURSOR okl_cin_pk_csr (p_cnsld_ap_inv_id IN NUMBER) IS
    SELECT
            CNSLD_AP_INV_ID,
            TRX_STATUS_CODE,
            VENDOR_INVOICE_NUMBER,
            CURRENCY_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
            PAYMENT_METHOD_CODE,
            PAY_GROUP_LOOKUP_CODE,
            INVOICE_TYPE,
            SET_OF_BOOKS_ID,
            TRY_ID,
            IPVS_ID,
            IPPT_ID,
            DATE_INVOICED,
            AMOUNT,
            INVOICE_NUMBER,
            DATE_GL,
            VENDOR_ID,
            ORG_ID,
            LEGAL_ENTITY_ID,
            VPA_ID,
            ACCTS_PAY_CC_ID,
            FEE_CHARGED_YN,
            SELF_BILL_YN,
            SELF_BILL_INV_NUM,
            MATCH_REQUIRED_YN,
            OBJECT_VERSION_NUMBER,
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
      FROM Okl_Cnsld_Ap_Invs
     WHERE okl_cnsld_ap_invs.cnsld_ap_inv_id = p_cnsld_ap_inv_id;
    l_okl_cin_pk                   okl_cin_pk_csr%ROWTYPE;
    l_cin_rec                      cin_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cin_pk_csr (p_cin_rec.cnsld_ap_inv_id);
    FETCH okl_cin_pk_csr INTO
              l_cin_rec.cnsld_ap_inv_id,
              l_cin_rec.trx_status_code,
              l_cin_rec.vendor_invoice_number,
              l_cin_rec.currency_code,
              l_cin_rec.currency_conversion_type,
              l_cin_rec.currency_conversion_rate,
              l_cin_rec.currency_conversion_date,
              l_cin_rec.payment_method_code,
              l_cin_rec.pay_group_lookup_code,
              l_cin_rec.invoice_type,
              l_cin_rec.set_of_books_id,
              l_cin_rec.try_id,
              l_cin_rec.ipvs_id,
              l_cin_rec.ippt_id,
              l_cin_rec.date_invoiced,
              l_cin_rec.amount,
              l_cin_rec.invoice_number,
              l_cin_rec.date_gl,
              l_cin_rec.vendor_id,
              l_cin_rec.org_id,
              l_cin_rec.legal_entity_id,
              l_cin_rec.vpa_id,
              l_cin_rec.accts_pay_cc_id,
              l_cin_rec.fee_charged_yn,
              l_cin_rec.self_bill_yn,
              l_cin_rec.self_bill_inv_num,
              l_cin_rec.match_required_yn,
              l_cin_rec.object_version_number,
              l_cin_rec.request_id,
              l_cin_rec.program_application_id,
              l_cin_rec.program_id,
              l_cin_rec.program_update_date,
              l_cin_rec.attribute_category,
              l_cin_rec.attribute1,
              l_cin_rec.attribute2,
              l_cin_rec.attribute3,
              l_cin_rec.attribute4,
              l_cin_rec.attribute5,
              l_cin_rec.attribute6,
              l_cin_rec.attribute7,
              l_cin_rec.attribute8,
              l_cin_rec.attribute9,
              l_cin_rec.attribute10,
              l_cin_rec.attribute11,
              l_cin_rec.attribute12,
              l_cin_rec.attribute13,
              l_cin_rec.attribute14,
              l_cin_rec.attribute15,
              l_cin_rec.created_by,
              l_cin_rec.creation_date,
              l_cin_rec.last_updated_by,
              l_cin_rec.last_update_date,
              l_cin_rec.last_update_login;
    x_no_data_found := okl_cin_pk_csr%NOTFOUND;
    CLOSE okl_cin_pk_csr;
    RETURN(l_cin_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_cin_rec                      IN cin_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN cin_rec_type IS
    l_cin_rec                      cin_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_cin_rec := get_rec(p_cin_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CNSLD_AP_INV_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_cin_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_cin_rec                      IN cin_rec_type
  ) RETURN cin_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cin_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CNSLD_AP_INVS
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cin_rec   IN cin_rec_type
  ) RETURN cin_rec_type IS
    l_cin_rec                      cin_rec_type := p_cin_rec;
  BEGIN
    IF (l_cin_rec.cnsld_ap_inv_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.cnsld_ap_inv_id := NULL;
    END IF;
    IF (l_cin_rec.trx_status_code = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.trx_status_code := NULL;
    END IF;
    IF (l_cin_rec.vendor_invoice_number = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.vendor_invoice_number := NULL;
    END IF;
    IF (l_cin_rec.currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.currency_code := NULL;
    END IF;
    IF (l_cin_rec.currency_conversion_type = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_cin_rec.currency_conversion_rate = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_cin_rec.currency_conversion_date = OKL_API.G_MISS_DATE ) THEN
      l_cin_rec.currency_conversion_date := NULL;
    END IF;
    IF (l_cin_rec.payment_method_code = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.payment_method_code := NULL;
    END IF;
    IF (l_cin_rec.pay_group_lookup_code = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.pay_group_lookup_code := NULL;
    END IF;
    IF (l_cin_rec.invoice_type = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.invoice_type := NULL;
    END IF;
    IF (l_cin_rec.set_of_books_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.set_of_books_id := NULL;
    END IF;
    IF (l_cin_rec.try_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.try_id := NULL;
    END IF;
    IF (l_cin_rec.ipvs_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.ipvs_id := NULL;
    END IF;
    IF (l_cin_rec.ippt_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.ippt_id := NULL;
    END IF;
    IF (l_cin_rec.date_invoiced = OKL_API.G_MISS_DATE ) THEN
      l_cin_rec.date_invoiced := NULL;
    END IF;
    IF (l_cin_rec.amount = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.amount := NULL;
    END IF;
    IF (l_cin_rec.invoice_number = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.invoice_number := NULL;
    END IF;
    IF (l_cin_rec.date_gl = OKL_API.G_MISS_DATE ) THEN
      l_cin_rec.date_gl := NULL;
    END IF;
    IF (l_cin_rec.vendor_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.vendor_id := NULL;
    END IF;
    IF (l_cin_rec.org_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.org_id := NULL;
    END IF;
    IF (l_cin_rec.legal_entity_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.legal_entity_id := NULL;
    END IF;
    IF (l_cin_rec.vpa_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.vpa_id := NULL;
    END IF;
    IF (l_cin_rec.accts_pay_cc_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.accts_pay_cc_id := NULL;
    END IF;
    IF (l_cin_rec.fee_charged_yn = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.fee_charged_yn := NULL;
    END IF;
    IF (l_cin_rec.self_bill_yn = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.self_bill_yn := NULL;
    END IF;
    IF (l_cin_rec.self_bill_inv_num = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.self_bill_inv_num := NULL;
    END IF;
    IF (l_cin_rec.match_required_yn = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.match_required_yn := NULL;
    END IF;
    IF (l_cin_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.object_version_number := NULL;
    END IF;
    IF (l_cin_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.request_id := NULL;
    END IF;
    IF (l_cin_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.program_application_id := NULL;
    END IF;
    IF (l_cin_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.program_id := NULL;
    END IF;
    IF (l_cin_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_cin_rec.program_update_date := NULL;
    END IF;
    IF (l_cin_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute_category := NULL;
    END IF;
    IF (l_cin_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute1 := NULL;
    END IF;
    IF (l_cin_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute2 := NULL;
    END IF;
    IF (l_cin_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute3 := NULL;
    END IF;
    IF (l_cin_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute4 := NULL;
    END IF;
    IF (l_cin_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute5 := NULL;
    END IF;
    IF (l_cin_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute6 := NULL;
    END IF;
    IF (l_cin_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute7 := NULL;
    END IF;
    IF (l_cin_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute8 := NULL;
    END IF;
    IF (l_cin_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute9 := NULL;
    END IF;
    IF (l_cin_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute10 := NULL;
    END IF;
    IF (l_cin_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute11 := NULL;
    END IF;
    IF (l_cin_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute12 := NULL;
    END IF;
    IF (l_cin_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute13 := NULL;
    END IF;
    IF (l_cin_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute14 := NULL;
    END IF;
    IF (l_cin_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_cin_rec.attribute15 := NULL;
    END IF;
    IF (l_cin_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.created_by := NULL;
    END IF;
    IF (l_cin_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_cin_rec.creation_date := NULL;
    END IF;
    IF (l_cin_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.last_updated_by := NULL;
    END IF;
    IF (l_cin_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_cin_rec.last_update_date := NULL;
    END IF;
    IF (l_cin_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_cin_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cin_rec);
  END null_out_defaults;
  ----------------------------------------------
  -- Validate_Attributes for: CNSLD_AP_INV_ID --
  ----------------------------------------------
  PROCEDURE validate_cnsld_ap_inv_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cnsld_ap_inv_id              IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_cnsld_ap_inv_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'cnsld_ap_inv_id');
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
  END validate_cnsld_ap_inv_id;
  ----------------------------------------------
  -- Validate_Attributes for: TRX_STATUS_CODE --
  ----------------------------------------------
  PROCEDURE validate_trx_status_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_trx_status_code              IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_trx_status_code IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_status_code');
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
  END validate_trx_status_code;
  ----------------------------------------------------
  -- Validate_Attributes for: VENDOR_INVOICE_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_vendor_invoice_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_vendor_invoice_number        IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_vendor_invoice_number IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'vendor_invoice_number');
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
  END validate_vendor_invoice_number;
  --------------------------------------------
  -- Validate_Attributes for: CURRENCY_CODE --
  --------------------------------------------
  PROCEDURE validate_currency_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_currency_code                IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_currency_code IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'currency_code');
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
  END validate_currency_code;
  -------------------------------------
  -- Validate_Attributes for: TRY_ID --
  -------------------------------------
  PROCEDURE validate_try_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_try_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_try_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'try_id');
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
  END validate_try_id;
  --------------------------------------
  -- Validate_Attributes for: IPVS_ID --
  --------------------------------------
  PROCEDURE validate_ipvs_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ipvs_id                      IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_ipvs_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ipvs_id');
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
  END validate_ipvs_id;
  --------------------------------------------
  -- Validate_Attributes for: DATE_INVOICED --
  --------------------------------------------
  PROCEDURE validate_date_invoiced(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_date_invoiced                IN DATE) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_date_invoiced IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'date_invoiced');
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
  END validate_date_invoiced;
  -------------------------------------
  -- Validate_Attributes for: AMOUNT --
  -------------------------------------
  PROCEDURE validate_amount(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_amount                       IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_amount IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'amount');
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
  END validate_amount;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
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
  END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKL_CNSLD_AP_INVS --
  -----------------------------------------------
  FUNCTION Validate_Attributes (
    p_cin_rec                      IN cin_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- cnsld_ap_inv_id
    -- ***
    validate_cnsld_ap_inv_id(x_return_status, p_cin_rec.cnsld_ap_inv_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- trx_status_code
    -- ***
    validate_trx_status_code(x_return_status, p_cin_rec.trx_status_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- vendor_invoice_number
    -- ***
    validate_vendor_invoice_number(x_return_status, p_cin_rec.vendor_invoice_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- currency_code
    -- ***
    validate_currency_code(x_return_status, p_cin_rec.currency_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- try_id
    -- ***
    validate_try_id(x_return_status, p_cin_rec.try_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- ipvs_id
    -- ***
    validate_ipvs_id(x_return_status, p_cin_rec.ipvs_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- date_invoiced
    -- ***
    validate_date_invoiced(x_return_status, p_cin_rec.date_invoiced);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- amount
    -- ***
    validate_amount(x_return_status, p_cin_rec.amount);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_cin_rec.object_version_number);
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
  -------------------------------------------
  -- Validate Record for:OKL_CNSLD_AP_INVS --
  -------------------------------------------
  FUNCTION Validate_Record (
    p_cin_rec IN cin_rec_type,
    p_db_cin_rec IN cin_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_cin_rec IN cin_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_cin_rec                   cin_rec_type := get_rec(p_cin_rec);
  BEGIN
    l_return_status := Validate_Record(p_cin_rec => p_cin_rec,
                                       p_db_cin_rec => l_db_cin_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- validate_row for:OKL_CNSLD_AP_INVS --
  ----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cin_rec                      cin_rec_type := p_cin_rec;
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
    l_return_status := Validate_Attributes(l_cin_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cin_rec);
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
  ---------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CNSLD_AP_INVS --
  ---------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cin_tbl.COUNT > 0) THEN
      i := p_cin_tbl.FIRST;
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
            p_cin_rec                      => p_cin_tbl(i));
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
        EXIT WHEN (i = p_cin_tbl.LAST);
        i := p_cin_tbl.NEXT(i);
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

  ---------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CNSLD_AP_INVS --
  ---------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cin_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cin_tbl                      => p_cin_tbl,
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
  --------------------------------------
  -- insert_row for:OKL_CNSLD_AP_INVS --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type,
    x_cin_rec                      OUT NOCOPY cin_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cin_rec                      cin_rec_type := p_cin_rec;
    l_def_cin_rec                  cin_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cin_rec IN cin_rec_type
    ) RETURN cin_rec_type IS
      l_cin_rec cin_rec_type := p_cin_rec;
    BEGIN
      l_cin_rec.CREATION_DATE := SYSDATE;
      l_cin_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cin_rec.LAST_UPDATE_DATE := l_cin_rec.CREATION_DATE;
      l_cin_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cin_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      l_cin_rec.REQUEST_ID := CASE WHEN FND_GLOBAL.CONC_REQUEST_ID = -1 THEN NULL ELSE FND_GLOBAL.CONC_REQUEST_ID END;
      l_cin_rec.PROGRAM_APPLICATION_ID := CASE WHEN FND_GLOBAL.PROG_APPL_ID = -1 THEN NULL ELSE FND_GLOBAL.PROG_APPL_ID END;
      l_cin_rec.PROGRAM_ID := CASE WHEN FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN NULL ELSE FND_GLOBAL.CONC_PROGRAM_ID END;
      l_cin_rec.PROGRAM_UPDATE_DATE := CASE WHEN FND_GLOBAL.CONC_REQUEST_ID = -1 THEN NULL ELSE SYSDATE END;
      RETURN(l_cin_rec);
    END fill_who_columns;
    ------------------------------------------
    -- Set_Attributes for:OKL_CNSLD_AP_INVS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_cin_rec IN cin_rec_type,
      x_cin_rec OUT NOCOPY cin_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cin_rec := p_cin_rec;
      x_cin_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_cin_rec := null_out_defaults(p_cin_rec);
    -- Set primary key value
    l_cin_rec.CNSLD_AP_INV_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_cin_rec,                         -- IN
      l_def_cin_rec);                    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cin_rec := fill_who_columns(l_def_cin_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cin_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cin_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CNSLD_AP_INVS(
      cnsld_ap_inv_id,
      trx_status_code,
      vendor_invoice_number,
      currency_code,
      currency_conversion_type,
      currency_conversion_rate,
      currency_conversion_date,
      payment_method_code,
      pay_group_lookup_code,
      invoice_type,
      set_of_books_id,
      try_id,
      ipvs_id,
      ippt_id,
      date_invoiced,
      amount,
      invoice_number,
      date_gl,
      vendor_id,
      org_id,
      legal_entity_id,
      vpa_id,
      accts_pay_cc_id,
      fee_charged_yn,
      self_bill_yn,
      self_bill_inv_num,
      match_required_yn,
      object_version_number,
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
      l_cin_rec.cnsld_ap_inv_id,
      l_cin_rec.trx_status_code,
      l_cin_rec.vendor_invoice_number,
      l_cin_rec.currency_code,
      l_cin_rec.currency_conversion_type,
      l_cin_rec.currency_conversion_rate,
      l_cin_rec.currency_conversion_date,
      l_cin_rec.payment_method_code,
      l_cin_rec.pay_group_lookup_code,
      l_cin_rec.invoice_type,
      l_cin_rec.set_of_books_id,
      l_cin_rec.try_id,
      l_cin_rec.ipvs_id,
      l_cin_rec.ippt_id,
      l_cin_rec.date_invoiced,
      l_cin_rec.amount,
      l_cin_rec.invoice_number,
      l_cin_rec.date_gl,
      l_cin_rec.vendor_id,
      l_cin_rec.org_id,
      l_cin_rec.legal_entity_id,
      l_cin_rec.vpa_id,
      l_cin_rec.accts_pay_cc_id,
      l_cin_rec.fee_charged_yn,
      l_cin_rec.self_bill_yn,
      l_cin_rec.self_bill_inv_num,
      l_cin_rec.match_required_yn,
      l_cin_rec.object_version_number,
      l_cin_rec.request_id,
      l_cin_rec.program_application_id,
      l_cin_rec.program_id,
      l_cin_rec.program_update_date,
      l_cin_rec.attribute_category,
      l_cin_rec.attribute1,
      l_cin_rec.attribute2,
      l_cin_rec.attribute3,
      l_cin_rec.attribute4,
      l_cin_rec.attribute5,
      l_cin_rec.attribute6,
      l_cin_rec.attribute7,
      l_cin_rec.attribute8,
      l_cin_rec.attribute9,
      l_cin_rec.attribute10,
      l_cin_rec.attribute11,
      l_cin_rec.attribute12,
      l_cin_rec.attribute13,
      l_cin_rec.attribute14,
      l_cin_rec.attribute15,
      l_cin_rec.created_by,
      l_cin_rec.creation_date,
      l_cin_rec.last_updated_by,
      l_cin_rec.last_update_date,
      l_cin_rec.last_update_login);
    -- Set OUT values
    x_cin_rec := l_cin_rec;
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
  ---------------------------------------
  -- PL/SQL TBL insert_row for:CIN_TBL --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    x_cin_tbl                      OUT NOCOPY cin_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cin_tbl.COUNT > 0) THEN
      i := p_cin_tbl.FIRST;
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
            p_cin_rec                      => p_cin_tbl(i),
            x_cin_rec                      => x_cin_tbl(i));
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
        EXIT WHEN (i = p_cin_tbl.LAST);
        i := p_cin_tbl.NEXT(i);
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

  ---------------------------------------
  -- PL/SQL TBL insert_row for:CIN_TBL --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    x_cin_tbl                      OUT NOCOPY cin_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cin_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cin_tbl                      => p_cin_tbl,
        x_cin_tbl                      => x_cin_tbl,
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
  ------------------------------------
  -- lock_row for:OKL_CNSLD_AP_INVS --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cin_rec IN cin_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CNSLD_AP_INVS
     WHERE CNSLD_AP_INV_ID = p_cin_rec.cnsld_ap_inv_id
       AND OBJECT_VERSION_NUMBER = p_cin_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_cin_rec IN cin_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CNSLD_AP_INVS
     WHERE CNSLD_AP_INV_ID = p_cin_rec.cnsld_ap_inv_id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_CNSLD_AP_INVS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_CNSLD_AP_INVS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cin_rec);
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
      OPEN lchk_csr(p_cin_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cin_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cin_rec.object_version_number THEN
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
  -------------------------------------
  -- lock_row for: OKL_CNSLD_AP_INVS --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cin_rec                      cin_rec_type;
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
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cin_rec
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
  -------------------------------------
  -- PL/SQL TBL lock_row for:CIN_TBL --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_cin_tbl.COUNT > 0) THEN
      i := p_cin_tbl.FIRST;
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
            p_cin_rec                      => p_cin_tbl(i));
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
        EXIT WHEN (i = p_cin_tbl.LAST);
        i := p_cin_tbl.NEXT(i);
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
  -------------------------------------
  -- PL/SQL TBL lock_row for:CIN_TBL --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_cin_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cin_tbl                      => p_cin_tbl,
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
  --------------------------------------
  -- update_row for:OKL_CNSLD_AP_INVS --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type,
    x_cin_rec                      OUT NOCOPY cin_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cin_rec                      cin_rec_type := p_cin_rec;
    l_def_cin_rec                  cin_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cin_rec IN cin_rec_type,
      x_cin_rec OUT NOCOPY cin_rec_type
    ) RETURN VARCHAR2 IS
      l_cin_rec                      cin_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cin_rec := p_cin_rec;
      -- Get current database values
      l_cin_rec := get_rec(p_cin_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_cin_rec.cnsld_ap_inv_id IS NULL THEN
          x_cin_rec.cnsld_ap_inv_id := l_cin_rec.cnsld_ap_inv_id;
        END IF;
        IF x_cin_rec.trx_status_code IS NULL THEN
          x_cin_rec.trx_status_code := l_cin_rec.trx_status_code;
        END IF;
        IF x_cin_rec.vendor_invoice_number IS NULL THEN
          x_cin_rec.vendor_invoice_number := l_cin_rec.vendor_invoice_number;
        END IF;
        IF x_cin_rec.currency_code IS NULL THEN
          x_cin_rec.currency_code := l_cin_rec.currency_code;
        END IF;
        IF x_cin_rec.currency_conversion_type IS NULL THEN
          x_cin_rec.currency_conversion_type := l_cin_rec.currency_conversion_type;
        END IF;
        IF x_cin_rec.currency_conversion_rate IS NULL THEN
          x_cin_rec.currency_conversion_rate := l_cin_rec.currency_conversion_rate;
        END IF;
        IF x_cin_rec.currency_conversion_date IS NULL THEN
          x_cin_rec.currency_conversion_date := l_cin_rec.currency_conversion_date;
        END IF;
        IF x_cin_rec.payment_method_code IS NULL THEN
          x_cin_rec.payment_method_code := l_cin_rec.payment_method_code;
        END IF;
        IF x_cin_rec.pay_group_lookup_code IS NULL THEN
          x_cin_rec.pay_group_lookup_code := l_cin_rec.pay_group_lookup_code;
        END IF;
        IF x_cin_rec.invoice_type IS NULL THEN
          x_cin_rec.invoice_type := l_cin_rec.invoice_type;
        END IF;
        IF x_cin_rec.set_of_books_id IS NULL THEN
          x_cin_rec.set_of_books_id := l_cin_rec.set_of_books_id;
        END IF;
        IF x_cin_rec.try_id IS NULL THEN
          x_cin_rec.try_id := l_cin_rec.try_id;
        END IF;
        IF x_cin_rec.ipvs_id IS NULL THEN
          x_cin_rec.ipvs_id := l_cin_rec.ipvs_id;
        END IF;
        IF x_cin_rec.ippt_id IS NULL THEN
          x_cin_rec.ippt_id := l_cin_rec.ippt_id;
        END IF;
        IF x_cin_rec.date_invoiced IS NULL THEN
          x_cin_rec.date_invoiced := l_cin_rec.date_invoiced;
        END IF;
        IF x_cin_rec.amount IS NULL THEN
          x_cin_rec.amount := l_cin_rec.amount;
        END IF;
        IF x_cin_rec.invoice_number IS NULL THEN
          x_cin_rec.invoice_number := l_cin_rec.invoice_number;
        END IF;
        IF x_cin_rec.date_gl IS NULL THEN
          x_cin_rec.date_gl := l_cin_rec.date_gl;
        END IF;
        IF x_cin_rec.vendor_id IS NULL THEN
          x_cin_rec.vendor_id := l_cin_rec.vendor_id;
        END IF;
        IF x_cin_rec.org_id IS NULL THEN
          x_cin_rec.org_id := l_cin_rec.org_id;
        END IF;
        IF x_cin_rec.legal_entity_id IS NULL THEN
          x_cin_rec.legal_entity_id := l_cin_rec.legal_entity_id;
        END IF;
        IF x_cin_rec.vpa_id IS NULL THEN
          x_cin_rec.vpa_id := l_cin_rec.vpa_id;
        END IF;
        IF x_cin_rec.accts_pay_cc_id IS NULL THEN
          x_cin_rec.accts_pay_cc_id := l_cin_rec.accts_pay_cc_id;
        END IF;
        IF x_cin_rec.fee_charged_yn IS NULL THEN
          x_cin_rec.fee_charged_yn := l_cin_rec.fee_charged_yn;
        END IF;
        IF x_cin_rec.self_bill_yn IS NULL THEN
          x_cin_rec.self_bill_yn := l_cin_rec.self_bill_yn;
        END IF;
        IF x_cin_rec.self_bill_inv_num IS NULL THEN
          x_cin_rec.self_bill_inv_num := l_cin_rec.self_bill_inv_num;
        END IF;
        IF x_cin_rec.match_required_yn IS NULL THEN
          x_cin_rec.match_required_yn := l_cin_rec.match_required_yn;
        END IF;
        IF x_cin_rec.object_version_number IS NULL THEN
          x_cin_rec.object_version_number := l_cin_rec.object_version_number;
        END IF;
        IF x_cin_rec.request_id IS NULL THEN
          x_cin_rec.request_id := l_cin_rec.request_id;
        END IF;
        IF x_cin_rec.program_application_id IS NULL THEN
          x_cin_rec.program_application_id := l_cin_rec.program_application_id;
        END IF;
        IF x_cin_rec.program_id IS NULL THEN
          x_cin_rec.program_id := l_cin_rec.program_id;
        END IF;
        IF x_cin_rec.program_update_date IS NULL THEN
          x_cin_rec.program_update_date := l_cin_rec.program_update_date;
        END IF;
        IF x_cin_rec.attribute_category IS NULL THEN
          x_cin_rec.attribute_category := l_cin_rec.attribute_category;
        END IF;
        IF x_cin_rec.attribute1 IS NULL THEN
          x_cin_rec.attribute1 := l_cin_rec.attribute1;
        END IF;
        IF x_cin_rec.attribute2 IS NULL THEN
          x_cin_rec.attribute2 := l_cin_rec.attribute2;
        END IF;
        IF x_cin_rec.attribute3 IS NULL THEN
          x_cin_rec.attribute3 := l_cin_rec.attribute3;
        END IF;
        IF x_cin_rec.attribute4 IS NULL THEN
          x_cin_rec.attribute4 := l_cin_rec.attribute4;
        END IF;
        IF x_cin_rec.attribute5 IS NULL THEN
          x_cin_rec.attribute5 := l_cin_rec.attribute5;
        END IF;
        IF x_cin_rec.attribute6 IS NULL THEN
          x_cin_rec.attribute6 := l_cin_rec.attribute6;
        END IF;
        IF x_cin_rec.attribute7 IS NULL THEN
          x_cin_rec.attribute7 := l_cin_rec.attribute7;
        END IF;
        IF x_cin_rec.attribute8 IS NULL THEN
          x_cin_rec.attribute8 := l_cin_rec.attribute8;
        END IF;
        IF x_cin_rec.attribute9 IS NULL THEN
          x_cin_rec.attribute9 := l_cin_rec.attribute9;
        END IF;
        IF x_cin_rec.attribute10 IS NULL THEN
          x_cin_rec.attribute10 := l_cin_rec.attribute10;
        END IF;
        IF x_cin_rec.attribute11 IS NULL THEN
          x_cin_rec.attribute11 := l_cin_rec.attribute11;
        END IF;
        IF x_cin_rec.attribute12 IS NULL THEN
          x_cin_rec.attribute12 := l_cin_rec.attribute12;
        END IF;
        IF x_cin_rec.attribute13 IS NULL THEN
          x_cin_rec.attribute13 := l_cin_rec.attribute13;
        END IF;
        IF x_cin_rec.attribute14 IS NULL THEN
          x_cin_rec.attribute14 := l_cin_rec.attribute14;
        END IF;
        IF x_cin_rec.attribute15 IS NULL THEN
          x_cin_rec.attribute15 := l_cin_rec.attribute15;
        END IF;
        IF x_cin_rec.created_by IS NULL THEN
          x_cin_rec.created_by := l_cin_rec.created_by;
        END IF;
        IF x_cin_rec.creation_date IS NULL THEN
          x_cin_rec.creation_date := l_cin_rec.creation_date;
        END IF;
        IF x_cin_rec.last_updated_by IS NULL THEN
          x_cin_rec.last_updated_by := l_cin_rec.last_updated_by;
        END IF;
        IF x_cin_rec.last_update_date IS NULL THEN
          x_cin_rec.last_update_date := l_cin_rec.last_update_date;
        END IF;
        IF x_cin_rec.last_update_login IS NULL THEN
          x_cin_rec.last_update_login := l_cin_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_CNSLD_AP_INVS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_cin_rec IN cin_rec_type,
      x_cin_rec OUT NOCOPY cin_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cin_rec := p_cin_rec;
      x_cin_rec.OBJECT_VERSION_NUMBER := p_cin_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_cin_rec,                         -- IN
      l_cin_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cin_rec, l_def_cin_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CNSLD_AP_INVS
    SET TRX_STATUS_CODE = l_def_cin_rec.trx_status_code,
        VENDOR_INVOICE_NUMBER = l_def_cin_rec.vendor_invoice_number,
        CURRENCY_CODE = l_def_cin_rec.currency_code,
        CURRENCY_CONVERSION_TYPE = l_def_cin_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_cin_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_cin_rec.currency_conversion_date,
        PAYMENT_METHOD_CODE = l_def_cin_rec.payment_method_code,
        PAY_GROUP_LOOKUP_CODE = l_def_cin_rec.pay_group_lookup_code,
        INVOICE_TYPE = l_def_cin_rec.invoice_type,
        SET_OF_BOOKS_ID = l_def_cin_rec.set_of_books_id,
        TRY_ID = l_def_cin_rec.try_id,
        IPVS_ID = l_def_cin_rec.ipvs_id,
        IPPT_ID = l_def_cin_rec.ippt_id,
        DATE_INVOICED = l_def_cin_rec.date_invoiced,
        AMOUNT = l_def_cin_rec.amount,
        INVOICE_NUMBER = l_def_cin_rec.invoice_number,
        DATE_GL = l_def_cin_rec.date_gl,
        VENDOR_ID = l_def_cin_rec.vendor_id,
        ORG_ID = l_def_cin_rec.org_id,
        LEGAL_ENTITY_ID = l_def_cin_rec.legal_entity_id,
        VPA_ID = l_def_cin_rec.vpa_id,
        ACCTS_PAY_CC_ID = l_def_cin_rec.accts_pay_cc_id,
        FEE_CHARGED_YN = l_def_cin_rec.fee_charged_yn,
        SELF_BILL_YN = l_def_cin_rec.self_bill_yn,
        SELF_BILL_INV_NUM = l_def_cin_rec.self_bill_inv_num,
        MATCH_REQUIRED_YN = l_def_cin_rec.match_required_yn,
        OBJECT_VERSION_NUMBER = l_def_cin_rec.object_version_number,
        REQUEST_ID = l_def_cin_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_cin_rec.program_application_id,
        PROGRAM_ID = l_def_cin_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_cin_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_cin_rec.attribute_category,
        ATTRIBUTE1 = l_def_cin_rec.attribute1,
        ATTRIBUTE2 = l_def_cin_rec.attribute2,
        ATTRIBUTE3 = l_def_cin_rec.attribute3,
        ATTRIBUTE4 = l_def_cin_rec.attribute4,
        ATTRIBUTE5 = l_def_cin_rec.attribute5,
        ATTRIBUTE6 = l_def_cin_rec.attribute6,
        ATTRIBUTE7 = l_def_cin_rec.attribute7,
        ATTRIBUTE8 = l_def_cin_rec.attribute8,
        ATTRIBUTE9 = l_def_cin_rec.attribute9,
        ATTRIBUTE10 = l_def_cin_rec.attribute10,
        ATTRIBUTE11 = l_def_cin_rec.attribute11,
        ATTRIBUTE12 = l_def_cin_rec.attribute12,
        ATTRIBUTE13 = l_def_cin_rec.attribute13,
        ATTRIBUTE14 = l_def_cin_rec.attribute14,
        ATTRIBUTE15 = l_def_cin_rec.attribute15,
        CREATED_BY = l_def_cin_rec.created_by,
        CREATION_DATE = l_def_cin_rec.creation_date,
        LAST_UPDATED_BY = l_def_cin_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cin_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cin_rec.last_update_login
    WHERE CNSLD_AP_INV_ID = l_def_cin_rec.cnsld_ap_inv_id;

    x_cin_rec := l_cin_rec;
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
  --------------------------------------
  -- update_row for:OKL_CNSLD_AP_INVS --
  --------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type,
    x_cin_rec                      OUT NOCOPY cin_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cin_rec                      cin_rec_type := p_cin_rec;
    l_def_cin_rec                  cin_rec_type;
    l_db_cin_rec                   cin_rec_type;
    lx_cin_rec                     cin_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cin_rec IN cin_rec_type
    ) RETURN cin_rec_type IS
      l_cin_rec cin_rec_type := p_cin_rec;
    BEGIN
      l_cin_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cin_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cin_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      l_cin_rec.REQUEST_ID := CASE WHEN FND_GLOBAL.CONC_REQUEST_ID = -1 THEN NULL ELSE FND_GLOBAL.CONC_REQUEST_ID END;
      l_cin_rec.PROGRAM_APPLICATION_ID := CASE WHEN FND_GLOBAL.PROG_APPL_ID = -1 THEN NULL ELSE FND_GLOBAL.PROG_APPL_ID END;
      l_cin_rec.PROGRAM_ID := CASE WHEN FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN NULL ELSE FND_GLOBAL.CONC_PROGRAM_ID END;
      l_cin_rec.PROGRAM_UPDATE_DATE := CASE WHEN FND_GLOBAL.CONC_REQUEST_ID = -1 THEN NULL ELSE SYSDATE END;
      RETURN(l_cin_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cin_rec IN cin_rec_type,
      x_cin_rec OUT NOCOPY cin_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cin_rec := p_cin_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_cin_rec := get_rec(p_cin_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_cin_rec.cnsld_ap_inv_id IS NULL THEN
          x_cin_rec.cnsld_ap_inv_id := l_db_cin_rec.cnsld_ap_inv_id;
        END IF;
        IF x_cin_rec.trx_status_code IS NULL THEN
          x_cin_rec.trx_status_code := l_db_cin_rec.trx_status_code;
        END IF;
        IF x_cin_rec.vendor_invoice_number IS NULL THEN
          x_cin_rec.vendor_invoice_number := l_db_cin_rec.vendor_invoice_number;
        END IF;
        IF x_cin_rec.currency_code IS NULL THEN
          x_cin_rec.currency_code := l_db_cin_rec.currency_code;
        END IF;
        IF x_cin_rec.currency_conversion_type IS NULL THEN
          x_cin_rec.currency_conversion_type := l_db_cin_rec.currency_conversion_type;
        END IF;
        IF x_cin_rec.currency_conversion_rate IS NULL THEN
          x_cin_rec.currency_conversion_rate := l_db_cin_rec.currency_conversion_rate;
        END IF;
        IF x_cin_rec.currency_conversion_date IS NULL THEN
          x_cin_rec.currency_conversion_date := l_db_cin_rec.currency_conversion_date;
        END IF;
        IF x_cin_rec.payment_method_code IS NULL THEN
          x_cin_rec.payment_method_code := l_db_cin_rec.payment_method_code;
        END IF;
        IF x_cin_rec.pay_group_lookup_code IS NULL THEN
          x_cin_rec.pay_group_lookup_code := l_db_cin_rec.pay_group_lookup_code;
        END IF;
        IF x_cin_rec.invoice_type IS NULL THEN
          x_cin_rec.invoice_type := l_db_cin_rec.invoice_type;
        END IF;
        IF x_cin_rec.set_of_books_id IS NULL THEN
          x_cin_rec.set_of_books_id := l_db_cin_rec.set_of_books_id;
        END IF;
        IF x_cin_rec.try_id IS NULL THEN
          x_cin_rec.try_id := l_db_cin_rec.try_id;
        END IF;
        IF x_cin_rec.ipvs_id IS NULL THEN
          x_cin_rec.ipvs_id := l_db_cin_rec.ipvs_id;
        END IF;
        IF x_cin_rec.ippt_id IS NULL THEN
          x_cin_rec.ippt_id := l_db_cin_rec.ippt_id;
        END IF;
        IF x_cin_rec.date_invoiced IS NULL THEN
          x_cin_rec.date_invoiced := l_db_cin_rec.date_invoiced;
        END IF;
        IF x_cin_rec.amount IS NULL THEN
          x_cin_rec.amount := l_db_cin_rec.amount;
        END IF;
        IF x_cin_rec.invoice_number IS NULL THEN
          x_cin_rec.invoice_number := l_db_cin_rec.invoice_number;
        END IF;
        IF x_cin_rec.date_gl IS NULL THEN
          x_cin_rec.date_gl := l_db_cin_rec.date_gl;
        END IF;
        IF x_cin_rec.vendor_id IS NULL THEN
          x_cin_rec.vendor_id := l_db_cin_rec.vendor_id;
        END IF;
        IF x_cin_rec.org_id IS NULL THEN
          x_cin_rec.org_id := l_db_cin_rec.org_id;
        END IF;
        IF x_cin_rec.legal_entity_id IS NULL THEN
          x_cin_rec.legal_entity_id := l_db_cin_rec.legal_entity_id;
        END IF;
        IF x_cin_rec.vpa_id IS NULL THEN
          x_cin_rec.vpa_id := l_db_cin_rec.vpa_id;
        END IF;
        IF x_cin_rec.accts_pay_cc_id IS NULL THEN
          x_cin_rec.accts_pay_cc_id := l_db_cin_rec.accts_pay_cc_id;
        END IF;
        IF x_cin_rec.fee_charged_yn IS NULL THEN
          x_cin_rec.fee_charged_yn := l_db_cin_rec.fee_charged_yn;
        END IF;
        IF x_cin_rec.self_bill_yn IS NULL THEN
          x_cin_rec.self_bill_yn := l_db_cin_rec.self_bill_yn;
        END IF;
        IF x_cin_rec.self_bill_inv_num IS NULL THEN
          x_cin_rec.self_bill_inv_num := l_db_cin_rec.self_bill_inv_num;
        END IF;
        IF x_cin_rec.match_required_yn IS NULL THEN
          x_cin_rec.match_required_yn := l_db_cin_rec.match_required_yn;
        END IF;
        IF x_cin_rec.request_id IS NULL THEN
          x_cin_rec.request_id := l_db_cin_rec.request_id;
        END IF;
        IF x_cin_rec.program_application_id IS NULL THEN
          x_cin_rec.program_application_id := l_db_cin_rec.program_application_id;
        END IF;
        IF x_cin_rec.program_id IS NULL THEN
          x_cin_rec.program_id := l_db_cin_rec.program_id;
        END IF;
        IF x_cin_rec.program_update_date IS NULL THEN
          x_cin_rec.program_update_date := l_db_cin_rec.program_update_date;
        END IF;
        IF x_cin_rec.attribute_category IS NULL THEN
          x_cin_rec.attribute_category := l_db_cin_rec.attribute_category;
        END IF;
        IF x_cin_rec.attribute1 IS NULL THEN
          x_cin_rec.attribute1 := l_db_cin_rec.attribute1;
        END IF;
        IF x_cin_rec.attribute2 IS NULL THEN
          x_cin_rec.attribute2 := l_db_cin_rec.attribute2;
        END IF;
        IF x_cin_rec.attribute3 IS NULL THEN
          x_cin_rec.attribute3 := l_db_cin_rec.attribute3;
        END IF;
        IF x_cin_rec.attribute4 IS NULL THEN
          x_cin_rec.attribute4 := l_db_cin_rec.attribute4;
        END IF;
        IF x_cin_rec.attribute5 IS NULL THEN
          x_cin_rec.attribute5 := l_db_cin_rec.attribute5;
        END IF;
        IF x_cin_rec.attribute6 IS NULL THEN
          x_cin_rec.attribute6 := l_db_cin_rec.attribute6;
        END IF;
        IF x_cin_rec.attribute7 IS NULL THEN
          x_cin_rec.attribute7 := l_db_cin_rec.attribute7;
        END IF;
        IF x_cin_rec.attribute8 IS NULL THEN
          x_cin_rec.attribute8 := l_db_cin_rec.attribute8;
        END IF;
        IF x_cin_rec.attribute9 IS NULL THEN
          x_cin_rec.attribute9 := l_db_cin_rec.attribute9;
        END IF;
        IF x_cin_rec.attribute10 IS NULL THEN
          x_cin_rec.attribute10 := l_db_cin_rec.attribute10;
        END IF;
        IF x_cin_rec.attribute11 IS NULL THEN
          x_cin_rec.attribute11 := l_db_cin_rec.attribute11;
        END IF;
        IF x_cin_rec.attribute12 IS NULL THEN
          x_cin_rec.attribute12 := l_db_cin_rec.attribute12;
        END IF;
        IF x_cin_rec.attribute13 IS NULL THEN
          x_cin_rec.attribute13 := l_db_cin_rec.attribute13;
        END IF;
        IF x_cin_rec.attribute14 IS NULL THEN
          x_cin_rec.attribute14 := l_db_cin_rec.attribute14;
        END IF;
        IF x_cin_rec.attribute15 IS NULL THEN
          x_cin_rec.attribute15 := l_db_cin_rec.attribute15;
        END IF;
        IF x_cin_rec.created_by IS NULL THEN
          x_cin_rec.created_by := l_db_cin_rec.created_by;
        END IF;
        IF x_cin_rec.creation_date IS NULL THEN
          x_cin_rec.creation_date := l_db_cin_rec.creation_date;
        END IF;
        IF x_cin_rec.last_updated_by IS NULL THEN
          x_cin_rec.last_updated_by := l_db_cin_rec.last_updated_by;
        END IF;
        IF x_cin_rec.last_update_date IS NULL THEN
          x_cin_rec.last_update_date := l_db_cin_rec.last_update_date;
        END IF;
        IF x_cin_rec.last_update_login IS NULL THEN
          x_cin_rec.last_update_login := l_db_cin_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_CNSLD_AP_INVS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_cin_rec IN cin_rec_type,
      x_cin_rec OUT NOCOPY cin_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cin_rec := p_cin_rec;
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
      p_cin_rec,                         -- IN
      x_cin_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cin_rec, l_def_cin_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cin_rec := null_out_defaults(l_def_cin_rec);
    l_def_cin_rec := fill_who_columns(l_def_cin_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cin_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cin_rec, l_db_cin_rec);
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
      p_cin_rec                      => p_cin_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cin_rec,
      lx_cin_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_cin_rec := l_def_cin_rec;
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
  -- PL/SQL TBL update_row for:cin_tbl --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    x_cin_tbl                      OUT NOCOPY cin_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cin_tbl.COUNT > 0) THEN
      i := p_cin_tbl.FIRST;
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
            p_cin_rec                      => p_cin_tbl(i),
            x_cin_rec                      => x_cin_tbl(i));
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
        EXIT WHEN (i = p_cin_tbl.LAST);
        i := p_cin_tbl.NEXT(i);
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

  ---------------------------------------
  -- PL/SQL TBL update_row for:CIN_TBL --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    x_cin_tbl                      OUT NOCOPY cin_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cin_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cin_tbl                      => p_cin_tbl,
        x_cin_tbl                      => x_cin_tbl,
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
  --------------------------------------
  -- delete_row for:OKL_CNSLD_AP_INVS --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cin_rec                      cin_rec_type := p_cin_rec;
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

    DELETE FROM OKL_CNSLD_AP_INVS
     WHERE CNSLD_AP_INV_ID = p_cin_rec.cnsld_ap_inv_id;

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
  --------------------------------------
  -- delete_row for:OKL_CNSLD_AP_INVS --
  --------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cin_rec                      cin_rec_type := p_cin_rec;
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
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cin_rec
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
  -------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CNSLD_AP_INVS --
  -------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cin_tbl.COUNT > 0) THEN
      i := p_cin_tbl.FIRST;
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
            p_cin_rec                      => p_cin_tbl(i));
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
        EXIT WHEN (i = p_cin_tbl.LAST);
        i := p_cin_tbl.NEXT(i);
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

  -------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CNSLD_AP_INVS --
  -------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cin_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cin_tbl                      => p_cin_tbl,
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

END OKL_CIN_PVT;

/
