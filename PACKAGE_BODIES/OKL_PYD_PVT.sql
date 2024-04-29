--------------------------------------------------------
--  DDL for Package Body OKL_PYD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PYD_PVT" AS
/* $Header: OKLSPYDB.pls 120.4.12010000.2 2009/07/17 23:27:43 sechawla ship $ */

  CURSOR party_cur(p_cpl_id IN NUMBER) IS
  SELECT dnz_chr_id
  FROM   okc_k_party_roles_b WHERE
         id = p_cpl_id;
  party_rec party_cur%ROWTYPE;

  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY  OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY  OKL_API.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn'tany
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
  -- FUNCTION get_rec for: OKL_PARTY_PAYMENT_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ppydv_rec                    IN ppydv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ppydv_rec_type IS
    CURSOR okl_party_payment_d1 (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CPL_ID,
            VENDOR_ID,
            PAY_SITE_ID,
            PAYMENT_TERM_ID,
            PAYMENT_METHOD_CODE,
            PAY_GROUP_CODE,
			PAYMENT_HDR_ID,
			PAYMENT_START_DATE,
			PAYMENT_FREQUENCY,
			REMIT_DAYS,
			DISBURSEMENT_BASIS,
			DISBURSEMENT_FIXED_AMOUNT,
			DISBURSEMENT_PERCENT,
			PROCESSING_FEE_BASIS,
			PROCESSING_FEE_FIXED_AMOUNT,
			PROCESSING_FEE_PERCENT,
			--INCLUDE_IN_YIELD_FLAG,
			--PROCESSING_FEE_FORMULA,
			PAYMENT_BASIS,
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
            ORIG_CONTRACT_LINE_ID
      FROM Okl_Party_Payment_Dtls_V
     WHERE okl_party_payment_dtls_v.id = p_id;
    l_okl_party_payment_dtls_v_pk  okl_party_payment_d1%ROWTYPE;
    l_ppydv_rec                    ppydv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_party_payment_d1 (p_ppydv_rec.id);
    FETCH okl_party_payment_d1 INTO
              l_ppydv_rec.id,
              l_ppydv_rec.object_version_number,
              l_ppydv_rec.cpl_id,
              l_ppydv_rec.vendor_id,
              l_ppydv_rec.pay_site_id,
              l_ppydv_rec.payment_term_id,
              l_ppydv_rec.payment_method_code,
              l_ppydv_rec.pay_group_code,
			  l_ppydv_rec.payment_hdr_id,
			  l_ppydv_rec.payment_start_date,
			  l_ppydv_rec.payment_frequency,
			  l_ppydv_rec.remit_days,
			  l_ppydv_rec.disbursement_basis,
			  l_ppydv_rec.disbursement_fixed_amount,
			  l_ppydv_rec.disbursement_percent,
			  l_ppydv_rec.processing_fee_basis,
			  l_ppydv_rec.processing_fee_fixed_amount,
			  l_ppydv_rec.processing_fee_percent,
			  --l_ppydv_rec.include_in_yield_flag,
			  --l_ppydv_rec.processing_fee_formula,
			  l_ppydv_rec.payment_basis,
              l_ppydv_rec.attribute_category,
              l_ppydv_rec.attribute1,
              l_ppydv_rec.attribute2,
              l_ppydv_rec.attribute3,
              l_ppydv_rec.attribute4,
              l_ppydv_rec.attribute5,
              l_ppydv_rec.attribute6,
              l_ppydv_rec.attribute7,
              l_ppydv_rec.attribute8,
              l_ppydv_rec.attribute9,
              l_ppydv_rec.attribute10,
              l_ppydv_rec.attribute11,
              l_ppydv_rec.attribute12,
              l_ppydv_rec.attribute13,
              l_ppydv_rec.attribute14,
              l_ppydv_rec.attribute15,
              l_ppydv_rec.created_by,
              l_ppydv_rec.creation_date,
              l_ppydv_rec.last_updated_by,
              l_ppydv_rec.last_update_date,
              l_ppydv_rec.last_update_login,
			  l_ppydv_rec.ORIG_CONTRACT_LINE_ID;
    x_no_data_found := okl_party_payment_d1%NOTFOUND;
    CLOSE okl_party_payment_d1;
    RETURN(l_ppydv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ppydv_rec                    IN ppydv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ppydv_rec_type IS
    l_ppydv_rec                    ppydv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_ppydv_rec := get_rec(p_ppydv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ppydv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ppydv_rec                    IN ppydv_rec_type
  ) RETURN ppydv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ppydv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PARTY_PAYMENT_DTLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ppyd_rec                     IN ppyd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ppyd_rec_type IS
    CURSOR okl_party_payment_dtls_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CPL_ID,
            VENDOR_ID,
            PAY_SITE_ID,
            PAYMENT_TERM_ID,
            PAYMENT_METHOD_CODE,
            PAY_GROUP_CODE,
			PAYMENT_HDR_ID,
			PAYMENT_START_DATE,
			PAYMENT_FREQUENCY,
			REMIT_DAYS,
			DISBURSEMENT_BASIS,
			DISBURSEMENT_FIXED_AMOUNT,
			DISBURSEMENT_PERCENT,
			PROCESSING_FEE_BASIS,
			PROCESSING_FEE_FIXED_AMOUNT,
			PROCESSING_FEE_PERCENT,
			--INCLUDE_IN_YIELD_FLAG,
			--PROCESSING_FEE_FORMULA,
			PAYMENT_BASIS,
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
            ORIG_CONTRACT_LINE_ID
      FROM Okl_Party_Payment_Dtls
     WHERE okl_party_payment_dtls.id = p_id;
    l_okl_party_payment_dtls_pk    okl_party_payment_dtls_pk_csr%ROWTYPE;
    l_ppyd_rec                     ppyd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_party_payment_dtls_pk_csr (p_ppyd_rec.id);
    FETCH okl_party_payment_dtls_pk_csr INTO
              l_ppyd_rec.id,
              l_ppyd_rec.object_version_number,
              l_ppyd_rec.cpl_id,
              l_ppyd_rec.vendor_id,
              l_ppyd_rec.pay_site_id,
              l_ppyd_rec.payment_term_id,
              l_ppyd_rec.payment_method_code,
              l_ppyd_rec.pay_group_code,
			  l_ppyd_rec.payment_hdr_id,
			  l_ppyd_rec.payment_start_date,
			  l_ppyd_rec.payment_frequency,
			  l_ppyd_rec.remit_days,
			  l_ppyd_rec.disbursement_basis,
			  l_ppyd_rec.disbursement_fixed_amount,
			  l_ppyd_rec.disbursement_percent,
			  l_ppyd_rec.processing_fee_basis,
			  l_ppyd_rec.processing_fee_fixed_amount,
			  l_ppyd_rec.processing_fee_percent,
			  --l_ppyd_rec.include_in_yield_flag,
			  --l_ppyd_rec.processing_fee_formula,
			  l_ppyd_rec.payment_basis,
              l_ppyd_rec.attribute_category,
              l_ppyd_rec.attribute1,
              l_ppyd_rec.attribute2,
              l_ppyd_rec.attribute3,
              l_ppyd_rec.attribute4,
              l_ppyd_rec.attribute5,
              l_ppyd_rec.attribute6,
              l_ppyd_rec.attribute7,
              l_ppyd_rec.attribute8,
              l_ppyd_rec.attribute9,
              l_ppyd_rec.attribute10,
              l_ppyd_rec.attribute11,
              l_ppyd_rec.attribute12,
              l_ppyd_rec.attribute13,
              l_ppyd_rec.attribute14,
              l_ppyd_rec.attribute15,
              l_ppyd_rec.created_by,
              l_ppyd_rec.creation_date,
              l_ppyd_rec.last_updated_by,
              l_ppyd_rec.last_update_date,
              l_ppyd_rec.last_update_login,
			  l_ppyd_rec.ORIG_CONTRACT_LINE_ID;
    x_no_data_found := okl_party_payment_dtls_pk_csr%NOTFOUND;
    CLOSE okl_party_payment_dtls_pk_csr;
    RETURN(l_ppyd_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ppyd_rec                     IN ppyd_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ppyd_rec_type IS
    l_ppyd_rec                     ppyd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_ppyd_rec := get_rec(p_ppyd_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ppyd_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ppyd_rec                     IN ppyd_rec_type
  ) RETURN ppyd_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ppyd_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PARTY_PAYMENT_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ppydv_rec   IN ppydv_rec_type
  ) RETURN ppydv_rec_type IS
    l_ppydv_rec                    ppydv_rec_type := p_ppydv_rec;
  BEGIN
    IF (l_ppydv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.id := NULL;
    END IF;
    IF (l_ppydv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.object_version_number := NULL;
    END IF;
    IF (l_ppydv_rec.cpl_id = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.cpl_id := NULL;
    END IF;
    IF (l_ppydv_rec.vendor_id = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.vendor_id := NULL;
    END IF;
    IF (l_ppydv_rec.pay_site_id = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.pay_site_id := NULL;
    END IF;
    IF (l_ppydv_rec.payment_term_id = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.payment_term_id := NULL;
    END IF;
    IF (l_ppydv_rec.payment_method_code = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.payment_method_code := NULL;
    END IF;
    IF (l_ppydv_rec.pay_group_code = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.pay_group_code := NULL;
    END IF;
    IF (l_ppydv_rec.payment_hdr_id = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.payment_hdr_id := NULL;
    END IF;
    IF (l_ppydv_rec.payment_start_date = OKL_API.G_MISS_DATE ) THEN
      l_ppydv_rec.payment_start_date := NULL;
    END IF;
    IF (l_ppydv_rec.payment_frequency = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.payment_frequency := NULL;
    END IF;
    IF (l_ppydv_rec.remit_days = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.remit_days := NULL;
    END IF;
    IF (l_ppydv_rec.disbursement_basis = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.disbursement_basis := NULL;
    END IF;
    IF (l_ppydv_rec.disbursement_fixed_amount = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.disbursement_fixed_amount := NULL;
    END IF;
    IF (l_ppydv_rec.disbursement_percent = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.disbursement_percent := NULL;
    END IF;
    IF (l_ppydv_rec.processing_fee_basis = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.processing_fee_basis := NULL;
    END IF;
    IF (l_ppydv_rec.processing_fee_fixed_amount = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.processing_fee_fixed_amount := NULL;
    END IF;
    IF (l_ppydv_rec.processing_fee_percent = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.processing_fee_percent := NULL;
    END IF;
	/*
    IF (l_ppydv_rec.include_in_yield_flag = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.include_in_yield_flag := NULL;
    END IF;
    IF (l_ppydv_rec.processing_fee_formula = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.processing_fee_formula := NULL;
    END IF; */
    IF (l_ppydv_rec.payment_basis = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.payment_basis := NULL;
    END IF;
    IF (l_ppydv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute_category := NULL;
    END IF;
    IF (l_ppydv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute1 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute2 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute3 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute4 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute5 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute6 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute7 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute8 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute9 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute10 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute11 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute12 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute13 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute14 := NULL;
    END IF;
    IF (l_ppydv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_ppydv_rec.attribute15 := NULL;
    END IF;
    IF (l_ppydv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.created_by := NULL;
    END IF;
    IF (l_ppydv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_ppydv_rec.creation_date := NULL;
    END IF;
    IF (l_ppydv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ppydv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_ppydv_rec.last_update_date := NULL;
    END IF;
    IF (l_ppydv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.last_update_login := NULL;
    END IF;

    IF (l_ppydv_rec.ORIG_CONTRACT_LINE_ID = OKL_API.G_MISS_NUM ) THEN
      l_ppydv_rec.ORIG_CONTRACT_LINE_ID := NULL;
    END IF;


    RETURN(l_ppydv_rec);
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
  ----------------------------------------------------
  -- Validate_Attributes for: cpl_id --
  ----------------------------------------------------
  PROCEDURE validate_cpl_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cpl_id                       IN NUMBER) IS

   CURSOR l_cpl_csr (p_cpl_id in number) IS
      SELECT 'Y'
      FROM  okc_k_party_roles_b cplb
      WHERE cplb.id = p_cpl_id;

      l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_cpl_id = OKL_API.G_MISS_NUM OR
        p_cpl_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'cpl_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (p_cpl_id <> OKL_API.G_MISS_NUM AND p_cpl_id is NOT NULL) then
        l_exists := 'N';
        Open l_cpl_csr (p_cpl_id => p_cpl_id);
        Fetch l_cpl_csr into l_exists;
        If l_cpl_csr%NOTFOUND then
            Null;
        End If;
        Close l_cpl_csr;
        IF l_exists = 'N' then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'cpl_id');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If l_cpl_csr%ISOPEN then
          close l_cpl_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_cpl_id;
  ----------------------------------------------------
  -- Validate_Attributes for: vendor_id --
  ----------------------------------------------------
  PROCEDURE validate_vendor_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_vendor_id                       IN NUMBER) IS

   CURSOR l_vendor_csr (p_vendor_id in number) IS
      SELECT 'Y'
      FROM  po_vendors pov
      WHERE pov.vendor_id = p_vendor_id;

      l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_vendor_id = OKL_API.G_MISS_NUM OR
        p_vendor_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Vendor');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (p_vendor_id <> OKL_API.G_MISS_NUM AND p_vendor_id is NOT NULL) then
        l_exists := 'N';
        Open l_vendor_csr (p_vendor_id => p_vendor_id);
        Fetch l_vendor_csr into l_exists;
        If l_vendor_csr%NOTFOUND then
            Null;
        End If;
        Close l_vendor_csr;
        IF l_exists = 'N' then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Vendor');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If l_vendor_csr%ISOPEN then
          close l_vendor_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_vendor_id;
  ----------------------------------------------------
 -- Validate_Attributes for: vendor_pay_term_id --
  ----------------------------------------------------
  PROCEDURE validate_pay_term_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_pay_term_id                  IN NUMBER) IS

   CURSOR l_payterm_csr (p_pay_term_id in number) IS
      SELECT 'Y'
      FROM  OKX_PAYABLES_TERMS_V
      WHERE   id1 = p_pay_term_id
      AND    nvl(b_status,'N') = 'Y'
      AND    sysdate between (start_date_active) and nvl(end_date_active,sysdate);

      l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_pay_term_id = OKL_API.G_MISS_NUM OR
        p_pay_term_id IS NULL)
    THEN
        NULL; --null values allowed at TAPI level
    ELSIF (p_pay_term_id <> OKL_API.G_MISS_NUM AND p_pay_term_id is NOT NULL) then
        l_exists := 'N';
        Open l_payterm_csr (p_pay_term_id => p_pay_term_id);
        Fetch l_payterm_csr into l_exists;
        If l_payterm_csr%NOTFOUND then
            Null;
        End If;
        Close l_payterm_csr;
        IF l_exists = 'N' then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Payment Term');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If l_payterm_csr%ISOPEN then
          close l_payterm_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_pay_term_id;
  ----------------------------------------------------
 -- Validate_Attributes for: vendor_payment_method --
  ----------------------------------------------------
  PROCEDURE validate_payment_method(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_payment_method               IN VARCHAR2) IS

   CURSOR l_paymethod_csr (p_payment_method in varchar2) IS
      SELECT 'Y'
      From AP_LOOKUP_CODES
      Where lookup_type = 'PAYMENT METHOD'
      And  nvl(enabled_flag,'N') = 'Y'
      And sysdate between nvl(start_date_active,sysdate) and nvl(inactive_date,sysdate)
      And lookup_code = p_payment_method;

      l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_payment_method = OKL_API.G_MISS_CHAR OR
        p_payment_method IS NULL)
    THEN
        NULL; --null values allowed at TAPI level
    ELSIF (p_payment_method <> OKL_API.G_MISS_CHAR AND p_payment_method is NOT NULL) then
        l_exists := 'N';
        Open l_paymethod_csr (p_payment_method => p_payment_method);
        Fetch l_paymethod_csr into l_exists;
        If l_paymethod_csr%NOTFOUND then
            Null;
        End If;
        Close l_paymethod_csr;
        IF l_exists = 'N' then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Payment Method');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If l_paymethod_csr%ISOPEN then
          close l_paymethod_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_payment_method;
  -----------------------------------------------------------------
  --Validate attributes for PAY_GROUP
  -----------------------------------------------------------------
  PROCEDURE validate_pay_group(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_pay_group                    IN VARCHAR2) IS

   CURSOR l_paygroup_csr (p_pay_group in  varchar2) IS
      SELECT 'Y'
      From  PO_LOOKUP_CODES
      Where lookup_type = 'PAY GROUP'
      --Bug# 3566580 : 11.5.8 enabled flag is not there in table po_lookup_codes
      --And  nvl(enabled_flag,'N') = 'Y'
      And sysdate <=  nvl(inactive_date,sysdate)
      And lookup_code = p_pay_group;

      l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_pay_group = OKL_API.G_MISS_CHAR OR
        p_pay_group IS NULL)
    THEN
        NULL; --null values allowed at TAPI level
    ELSIF (p_pay_group <> OKL_API.G_MISS_CHAR AND p_pay_group is NOT NULL) then
        l_exists := 'N';
        Open l_paygroup_csr (p_pay_group => p_pay_group);
        Fetch l_paygroup_csr into l_exists;
        If l_paygroup_csr%NOTFOUND then
            Null;
        End If;
        Close l_paygroup_csr;
        IF l_exists = 'N' then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Pay Group');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If l_paygroup_csr%ISOPEN then
          close l_paygroup_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_pay_group;
  ----------------------------------------------------
  -- Validate_Attributes for: disbursement_basis --
  ----------------------------------------------------
  PROCEDURE validate_disbursement_basis(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_disbursement_basis           IN VARCHAR2) IS

   CURSOR l_disbursement_basis_csr (p_disbursement_basis in varchar2) IS
      SELECT 'Y'
      From FND_LOOKUPS
      Where lookup_type = 'OKL_DISBURSE_BASIS'
      And  nvl(enabled_flag,'N') = 'Y'
      And sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)
      And lookup_code = p_disbursement_basis;

      l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_disbursement_basis = OKL_API.G_MISS_CHAR OR
        p_disbursement_basis IS NULL)
    THEN
        NULL; --null values allowed at TAPI level
    ELSIF (p_disbursement_basis <> OKL_API.G_MISS_CHAR AND p_disbursement_basis is NOT NULL) then
        l_exists := 'N';
        Open l_disbursement_basis_csr (p_disbursement_basis => p_disbursement_basis);
        Fetch l_disbursement_basis_csr into l_exists;
        If l_disbursement_basis_csr%NOTFOUND then
            Null;
        End If;
        Close l_disbursement_basis_csr;
        IF l_exists = 'N' then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Disbursement Basis');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If l_disbursement_basis_csr%ISOPEN then
          close l_disbursement_basis_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_disbursement_basis;
  ----------------------------------------------------
  -- Validate_Attributes for: processing_fee_basis --
  ----------------------------------------------------
  PROCEDURE validate_processing_fee_basis(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_processing_fee_basis         IN VARCHAR2) IS

   CURSOR l_processing_fee_basis_csr (p_processing_fee_basis in varchar2) IS
      SELECT 'Y'
      From FND_LOOKUPS
      Where lookup_type = 'OKL_PROC_FEE_BASIS'
      And  nvl(enabled_flag,'N') = 'Y'
      And sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)
      And lookup_code = p_processing_fee_basis;

      l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_processing_fee_basis = OKL_API.G_MISS_CHAR OR
        p_processing_fee_basis IS NULL)
    THEN
        NULL; --null values allowed at TAPI level
    ELSIF (p_processing_fee_basis <> OKL_API.G_MISS_CHAR AND p_processing_fee_basis is NOT NULL) then
        l_exists := 'N';
        Open l_processing_fee_basis_csr (p_processing_fee_basis => p_processing_fee_basis);
        Fetch l_processing_fee_basis_csr into l_exists;
        If l_processing_fee_basis_csr%NOTFOUND then
            Null;
        End If;
        Close l_processing_fee_basis_csr;
        IF l_exists = 'N' then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Processing Fee Basis');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If l_processing_fee_basis_csr%ISOPEN then
          close l_processing_fee_basis_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_processing_fee_basis;
  ----------------------------------------------------
  -- Validate_Attributes for: payment_basis --
  ----------------------------------------------------
  PROCEDURE validate_payment_basis(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_payment_basis                IN VARCHAR2) IS

   CURSOR l_payment_basis_csr (p_payment_basis in varchar2) IS
      SELECT 'Y'
      From FND_LOOKUPS
      Where lookup_type = 'OKL_PAYMENT_BASIS'
      And  nvl(enabled_flag,'N') = 'Y'
      And sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)
      And lookup_code = p_payment_basis;

      l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_payment_basis = OKL_API.G_MISS_CHAR OR
        p_payment_basis IS NULL)
    THEN
        NULL; --null values allowed at TAPI level
    ELSIF (p_payment_basis <> OKL_API.G_MISS_CHAR AND p_payment_basis is NOT NULL) then
        l_exists := 'N';
        Open l_payment_basis_csr (p_payment_basis => p_payment_basis);
        Fetch l_payment_basis_csr into l_exists;
        If l_payment_basis_csr%NOTFOUND then
            Null;
        End If;
        Close l_payment_basis_csr;
        IF l_exists = 'N' then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Payment Basis');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If l_payment_basis_csr%ISOPEN then
          close l_payment_basis_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_payment_basis;
  ----------------------------------------------------
  -- Validate_Attributes for: payment_frequency --
  ----------------------------------------------------
  PROCEDURE validate_payment_frequency(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_payment_frequency            IN VARCHAR2) IS

   CURSOR l_payment_frequency_csr (p_payment_frequency in varchar2) IS
      SELECT 'Y'
      From FND_LOOKUPS
      Where lookup_type = 'OKL_PAYMENT_FRQ'
      And  nvl(enabled_flag,'N') = 'Y'
      And sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)
      And lookup_code = p_payment_frequency;

      l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_payment_frequency = OKL_API.G_MISS_CHAR OR
        p_payment_frequency IS NULL)
    THEN
        NULL; --null values allowed at TAPI level
    ELSIF (p_payment_frequency <> OKL_API.G_MISS_CHAR AND p_payment_frequency is NOT NULL) then
        l_exists := 'N';
        Open l_payment_frequency_csr (p_payment_frequency => p_payment_frequency);
        Fetch l_payment_frequency_csr into l_exists;
        If l_payment_frequency_csr%NOTFOUND then
            Null;
        End If;
        Close l_payment_frequency_csr;
        IF l_exists = 'N' then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Payment Frequency');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If l_payment_frequency_csr%ISOPEN then
          close l_payment_frequency_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_payment_frequency;
  ----------------------------------------------------
  -- Validate_Attributes for: disbursement_percent --
  ----------------------------------------------------
  PROCEDURE validate_disbursement_percent(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_disbursement_percent         IN VARCHAR2) IS

    l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_disbursement_percent = OKL_API.G_MISS_CHAR OR
        p_disbursement_percent IS NULL)
    THEN
        NULL; --null values allowed at TAPI level
    ELSIF (p_disbursement_percent <> OKL_API.G_MISS_CHAR AND
	       p_disbursement_percent IS NOT NULL AND
	      (p_disbursement_percent < 0 OR
		   p_disbursement_percent > 100) ) THEN
       OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,
		                    G_COL_NAME_TOKEN,'Disbursement Percent');
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
  END validate_disbursement_percent;

  ----------------------------------------------------
  -- Validate_Attributes for: processing_fee_percent --
  ----------------------------------------------------
  PROCEDURE validate_process_fee_percent(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_processing_fee_percent       IN VARCHAR2) IS

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_processing_fee_percent = OKL_API.G_MISS_CHAR OR
        p_processing_fee_percent IS NULL)
    THEN
        NULL; --null values allowed at TAPI level
    ELSIF (p_processing_fee_percent <> OKL_API.G_MISS_CHAR AND
	       p_processing_fee_percent IS NOT NULL AND
	      (p_processing_fee_percent < 0 OR
		   p_processing_fee_percent > 100) ) THEN
       OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,
		                    G_COL_NAME_TOKEN,'Processing Fee Percent');
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
  END validate_process_fee_percent;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------

  ------------------------------------------------------
  -- Validate_Attributes for:OKL_PARTY_PAYMENT_DTLS_V --
  ------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ppydv_rec                    IN ppydv_rec_type
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
    validate_id(x_return_status, p_ppydv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_ppydv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- cpl_id
    -- ***
    validate_cpl_id(x_return_status, p_ppydv_rec.cpl_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- vendor_id
    -- ***
    validate_vendor_id(x_return_status, p_ppydv_rec.vendor_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- payment_term_id
    -- ***
    validate_pay_term_id(x_return_status, p_ppydv_rec.payment_term_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- payment_method_code
    -- ***
    validate_payment_method(x_return_status, p_ppydv_rec.payment_method_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- pay_group_code
    -- ***
    validate_pay_group(x_return_status, p_ppydv_rec.pay_group_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- payment_basis
    -- ***
    validate_payment_basis(x_return_status, p_ppydv_rec.payment_basis);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- payment_frequency
    -- ***
    validate_payment_frequency(x_return_status, p_ppydv_rec.payment_frequency);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- disbursement_basis
    -- ***
    validate_disbursement_basis(x_return_status, p_ppydv_rec.disbursement_basis);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- processing_fee_basis
    -- ***
    validate_processing_fee_basis(x_return_status, p_ppydv_rec.processing_fee_basis);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- disbursement_percent
    -- ***
    validate_disbursement_percent(x_return_status, p_ppydv_rec.disbursement_percent);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- processing_fee_percent
    -- ***
    validate_process_fee_percent(x_return_status, p_ppydv_rec.processing_fee_percent);
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
  --------------------------------------------------
  -- Validate Record for:OKL_PARTY_PAYMENT_DTLS_V --
  --------------------------------------------------
  FUNCTION Validate_Record (
    p_ppydv_rec IN ppydv_rec_type,
    p_db_ppydv_rec IN ppydv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    --function to validate rfrential integrity and cross-validations
    FUNCTION validate_ref_integrity ( p_ppydv_rec IN ppydv_rec_type,
                                      p_db_ppydv_rec IN ppydv_rec_type)
    RETURN VARCHAR2 IS
    --cursor to check whether pay to site is valid
    CURSOR l_paysite_csr (p_paysite_id IN NUMBER,
                          p_cpl_id     IN NUMBER,
                          p_vendor_id  IN NUMBER) is
    SELECT 'Y'
    FROM    po_vendor_sites_all pvs,
            okc_k_headers_b     chrb,
            okc_k_party_roles_b cplb
    WHERE   pvs.vendor_id                    = p_vendor_id
    AND     pvs.org_id                       = chrb.authoring_org_id
    AND     pvs.vendor_site_id               = p_paysite_id
    AND     nvl(pvs.pay_site_flag,'N')       = 'Y'
    AND     sysdate                          <= nvl(pvs.inactive_date,sysdate)
    AND     chrb.id                          = cplb.dnz_chr_id
    AND     cplb.id                          = p_cpl_id;

    l_exists   VARCHAR2(1) default 'N';

    violated_ref_integrity EXCEPTION;
    l_return_status Varchar2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN
        l_return_status := OKL_API.G_RET_STS_SUCCESS;
        -------------------------------------------
        --1. Validate pay site id :
        ------------------------------------------
        If p_ppydv_rec.pay_site_id is NOT NULL then
            l_exists := 'N';
            OPEN l_paysite_csr (p_paysite_id => p_ppydv_rec.pay_site_id,
                                p_cpl_id     => p_ppydv_rec.cpl_id,
                                p_vendor_id  => p_ppydv_rec.vendor_id);
            FETCH l_paysite_csr into l_exists;
            IF l_paysite_csr%NOTFOUND then
                NULL;
            END IF;
            CLOSE l_paysite_csr;

            If l_exists = 'N' then
                 OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Pay Site');
                 RAISE violated_ref_integrity;
           END IF;
        End If;
        return(l_return_status);
        Exception
         When violated_ref_integrity then
              l_return_status := OKL_API.G_RET_STS_ERROR;
              return(l_return_status);
    END validate_ref_integrity;

  BEGIN
    l_return_status := validate_ref_integrity(p_ppydv_rec,p_db_ppydv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_ppydv_rec IN ppydv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_ppydv_rec                 ppydv_rec_type := get_rec(p_ppydv_rec);
  BEGIN
    l_return_status := Validate_Record(p_ppydv_rec => p_ppydv_rec,
                                       p_db_ppydv_rec => l_db_ppydv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN ppydv_rec_type,
    p_to   IN OUT NOCOPY ppyd_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.cpl_id := p_from.cpl_id;
    p_to.vendor_id := p_from.vendor_id;
    p_to.pay_site_id := p_from.pay_site_id;
    p_to.payment_term_id := p_from.payment_term_id;
    p_to.payment_method_code := p_from.payment_method_code;
    p_to.pay_group_code := p_from.pay_group_code;
    p_to.payment_hdr_id := p_from.payment_hdr_id;
    p_to.payment_start_date := p_from.payment_start_date;
    p_to.payment_frequency := p_from.payment_frequency;
    p_to.remit_days := p_from.remit_days;
    p_to.disbursement_basis := p_from.disbursement_basis;
    p_to.disbursement_fixed_amount := p_from.disbursement_fixed_amount;
    p_to.disbursement_percent := p_from.disbursement_percent;
    p_to.processing_fee_basis := p_from.processing_fee_basis;
    p_to.processing_fee_fixed_amount := p_from.processing_fee_fixed_amount;
    p_to.processing_fee_percent := p_from.processing_fee_percent;
    --p_to.include_in_yield_flag := p_from.include_in_yield_flag;
    --p_to.processing_fee_formula := p_from.processing_fee_formula;
    p_to.payment_basis := p_from.payment_basis;
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
    p_to.ORIG_CONTRACT_LINE_ID := p_from.ORIG_CONTRACT_LINE_ID;
  END migrate;
  PROCEDURE migrate (
    p_from IN ppyd_rec_type,
    p_to   IN OUT NOCOPY ppydv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.cpl_id := p_from.cpl_id;
    p_to.vendor_id := p_from.vendor_id;
    p_to.pay_site_id := p_from.pay_site_id;
    p_to.payment_term_id := p_from.payment_term_id;
    p_to.payment_method_code := p_from.payment_method_code;
    p_to.pay_group_code := p_from.pay_group_code;
    p_to.payment_hdr_id := p_from.payment_hdr_id;
    p_to.payment_start_date := p_from.payment_start_date;
    p_to.payment_frequency := p_from.payment_frequency;
    p_to.remit_days := p_from.remit_days;
    p_to.disbursement_basis := p_from.disbursement_basis;
    p_to.disbursement_fixed_amount := p_from.disbursement_fixed_amount;
    p_to.disbursement_percent := p_from.disbursement_percent;
    p_to.processing_fee_basis := p_from.processing_fee_basis;
    p_to.processing_fee_fixed_amount := p_from.processing_fee_fixed_amount;
    p_to.processing_fee_percent := p_from.processing_fee_percent;
    --p_to.include_in_yield_flag := p_from.include_in_yield_flag;
    --p_to.processing_fee_formula := p_from.processing_fee_formula;
    p_to.payment_basis := p_from.payment_basis;
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
    p_to.ORIG_CONTRACT_LINE_ID := p_from.ORIG_CONTRACT_LINE_ID;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- validate_row for:OKL_PARTY_PAYMENT_DTLS_V --
  -----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ppydv_rec                    ppydv_rec_type := p_ppydv_rec;
    l_ppyd_rec                     ppyd_rec_type;
    l_ppyd_rec                     ppyd_rec_type;
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
    l_return_status := Validate_Attributes(l_ppydv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ppydv_rec);
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
  ----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_PARTY_PAYMENT_DTLS_V --
  ----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ppydv_tbl.COUNT > 0) THEN
      i := p_ppydv_tbl.FIRST;
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
            p_ppydv_rec                    => p_ppydv_tbl(i));
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
        EXIT WHEN (i = p_ppydv_tbl.LAST);
        i := p_ppydv_tbl.NEXT(i);
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

  ----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_PARTY_PAYMENT_DTLS_V --
  ----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ppydv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ppydv_tbl                    => p_ppydv_tbl,
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
  -------------------------------------------
  -- insert_row for:OKL_PARTY_PAYMENT_DTLS --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppyd_rec                     IN ppyd_rec_type,
    x_ppyd_rec                     OUT NOCOPY ppyd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ppyd_rec                     ppyd_rec_type := p_ppyd_rec;
    l_def_ppyd_rec                 ppyd_rec_type;
    -----------------------------------------------
    -- Set_Attributes for:OKL_PARTY_PAYMENT_DTLS --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_ppyd_rec IN ppyd_rec_type,
      x_ppyd_rec OUT NOCOPY ppyd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ppyd_rec := p_ppyd_rec;
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
      p_ppyd_rec,                        -- IN
      l_ppyd_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PARTY_PAYMENT_DTLS(
      id,
      object_version_number,
      cpl_id,
      vendor_id,
      pay_site_id,
      payment_term_id,
      payment_method_code,
      pay_group_code,
	  payment_hdr_id,
	  payment_start_date,
	  payment_frequency,
	  remit_days,
	  disbursement_basis,
	  disbursement_fixed_amount,
	  disbursement_percent,
	  processing_fee_basis,
	  processing_fee_fixed_amount,
	  processing_fee_percent,
	 -- include_in_yield_flag,
	  --processing_fee_formula,
	  payment_basis,
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
	  ORIG_CONTRACT_LINE_ID)
    VALUES (
      l_ppyd_rec.id,
      l_ppyd_rec.object_version_number,
      l_ppyd_rec.cpl_id,
      l_ppyd_rec.vendor_id,
      l_ppyd_rec.pay_site_id,
      l_ppyd_rec.payment_term_id,
      l_ppyd_rec.payment_method_code,
      l_ppyd_rec.pay_group_code,
	  l_ppyd_rec.payment_hdr_id,
	  l_ppyd_rec.payment_start_date,
	  l_ppyd_rec.payment_frequency,
	  l_ppyd_rec.remit_days,
	  l_ppyd_rec.disbursement_basis,
	  l_ppyd_rec.disbursement_fixed_amount,
	  l_ppyd_rec.disbursement_percent,
	  l_ppyd_rec.processing_fee_basis,
	  l_ppyd_rec.processing_fee_fixed_amount,
	  l_ppyd_rec.processing_fee_percent,
	  --l_ppyd_rec.include_in_yield_flag,
	  --l_ppyd_rec.processing_fee_formula,
	  l_ppyd_rec.payment_basis,
      l_ppyd_rec.attribute_category,
      l_ppyd_rec.attribute1,
      l_ppyd_rec.attribute2,
      l_ppyd_rec.attribute3,
      l_ppyd_rec.attribute4,
      l_ppyd_rec.attribute5,
      l_ppyd_rec.attribute6,
      l_ppyd_rec.attribute7,
      l_ppyd_rec.attribute8,
      l_ppyd_rec.attribute9,
      l_ppyd_rec.attribute10,
      l_ppyd_rec.attribute11,
      l_ppyd_rec.attribute12,
      l_ppyd_rec.attribute13,
      l_ppyd_rec.attribute14,
      l_ppyd_rec.attribute15,
      l_ppyd_rec.created_by,
      l_ppyd_rec.creation_date,
      l_ppyd_rec.last_updated_by,
      l_ppyd_rec.last_update_date,
      l_ppyd_rec.last_update_login,
	  l_ppyd_rec.ORIG_CONTRACT_LINE_ID);
    -- Set OUT values
    x_ppyd_rec := l_ppyd_rec;
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
  ----------------------------------------------
  -- insert_row for :OKL_PARTY_PAYMENT_DTLS_V --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type,
    x_ppydv_rec                    OUT NOCOPY ppydv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ppydv_rec                    ppydv_rec_type := p_ppydv_rec;
    l_def_ppydv_rec                ppydv_rec_type;
    l_ppyd_rec                     ppyd_rec_type;
    lx_ppyd_rec                    ppyd_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ppydv_rec IN ppydv_rec_type
    ) RETURN ppydv_rec_type IS
      l_ppydv_rec ppydv_rec_type := p_ppydv_rec;
    BEGIN
      l_ppydv_rec.CREATION_DATE := SYSDATE;
      l_ppydv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ppydv_rec.LAST_UPDATE_DATE := l_ppydv_rec.CREATION_DATE;
      l_ppydv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ppydv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ppydv_rec);
    END fill_who_columns;
    -------------------------------------------------
    -- Set_Attributes for:OKL_PARTY_PAYMENT_DTLS_V --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_ppydv_rec IN ppydv_rec_type,
      x_ppydv_rec OUT NOCOPY ppydv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ppydv_rec := p_ppydv_rec;
      x_ppydv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_ppydv_rec := null_out_defaults(p_ppydv_rec);
    -- Set primary key value
    l_ppydv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_ppydv_rec,                       -- IN
      l_def_ppydv_rec);                  -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ppydv_rec := fill_who_columns(l_def_ppydv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ppydv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ppydv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_ppydv_rec, l_ppyd_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ppyd_rec,
      lx_ppyd_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN party_cur(p_cpl_id => l_ppyd_rec.cpl_id);
    FETCH party_cur INTO party_rec;
    CLOSE party_cur;
    okl_contract_status_pub.cascade_lease_status_edit
          (p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => l_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_chr_id          => party_rec.dnz_chr_id);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_ppyd_rec, l_def_ppydv_rec);
    -- Set OUT values
    x_ppydv_rec := l_def_ppydv_rec;
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
  -----------------------------------------
  -- PL/SQL TBL insert_row for:PPYDV_TBL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    x_ppydv_tbl                    OUT NOCOPY  ppydv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ppydv_tbl.COUNT > 0) THEN
      i := p_ppydv_tbl.FIRST;
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
            p_ppydv_rec                    => p_ppydv_tbl(i),
            x_ppydv_rec                    => x_ppydv_tbl(i));
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
        EXIT WHEN (i = p_ppydv_tbl.LAST);
        i := p_ppydv_tbl.NEXT(i);
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

  -----------------------------------------
  -- PL/SQL TBL insert_row for:PPYDV_TBL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ppydv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ppydv_tbl                    => p_ppydv_tbl,
        x_ppydv_tbl                    => x_ppydv_tbl,
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
  -----------------------------------------
  -- lock_row for:OKL_PARTY_PAYMENT_DTLS --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppyd_rec                     IN ppyd_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ppyd_rec IN ppyd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PARTY_PAYMENT_DTLS
     WHERE ID = p_ppyd_rec.id
       AND OBJECT_VERSION_NUMBER = p_ppyd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_ppyd_rec IN ppyd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PARTY_PAYMENT_DTLS
     WHERE ID = p_ppyd_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_PARTY_PAYMENT_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_PARTY_PAYMENT_DTLS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ppyd_rec);
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
      OPEN lchk_csr(p_ppyd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ppyd_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ppyd_rec.object_version_number THEN
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
  --------------------------------------------
  -- lock_row for: OKL_PARTY_PAYMENT_DTLS_V --
  --------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ppyd_rec                     ppyd_rec_type;
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
    migrate(p_ppydv_rec, l_ppyd_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ppyd_rec
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
  ---------------------------------------
  -- PL/SQL TBL lock_row for:PPYDV_TBL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_ppydv_tbl.COUNT > 0) THEN
      i := p_ppydv_tbl.FIRST;
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
            p_ppydv_rec                    => p_ppydv_tbl(i));
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
        EXIT WHEN (i = p_ppydv_tbl.LAST);
        i := p_ppydv_tbl.NEXT(i);
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
  ---------------------------------------
  -- PL/SQL TBL lock_row for:PPYDV_TBL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_ppydv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ppydv_tbl                    => p_ppydv_tbl,
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
  -------------------------------------------
  -- update_row for:OKL_PARTY_PAYMENT_DTLS --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppyd_rec                     IN ppyd_rec_type,
    x_ppyd_rec                     OUT NOCOPY ppyd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ppyd_rec                     ppyd_rec_type := p_ppyd_rec;
    l_def_ppyd_rec                 ppyd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ppyd_rec IN ppyd_rec_type,
      x_ppyd_rec OUT NOCOPY ppyd_rec_type
    ) RETURN VARCHAR2 IS
      l_ppyd_rec                     ppyd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ppyd_rec := p_ppyd_rec;
      -- Get current database values
      l_ppyd_rec := get_rec(p_ppyd_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_ppyd_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.id := l_ppyd_rec.id;
        END IF;
        IF (x_ppyd_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.object_version_number := l_ppyd_rec.object_version_number;
        END IF;
        IF (x_ppyd_rec.cpl_id = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.cpl_id := l_ppyd_rec.cpl_id;
        END IF;
        IF (x_ppyd_rec.vendor_id = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.vendor_id := l_ppyd_rec.vendor_id;
        END IF;
        IF (x_ppyd_rec.pay_site_id = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.pay_site_id := l_ppyd_rec.pay_site_id;
        END IF;
        IF (x_ppyd_rec.payment_term_id = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.payment_term_id := l_ppyd_rec.payment_term_id;
        END IF;
        IF (x_ppyd_rec.payment_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.payment_method_code := l_ppyd_rec.payment_method_code;
        END IF;
        IF (x_ppyd_rec.pay_group_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.pay_group_code := l_ppyd_rec.pay_group_code;
        END IF;
        IF (x_ppyd_rec.payment_hdr_id = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.payment_hdr_id := l_ppyd_rec.payment_hdr_id;
        END IF;
        IF (x_ppyd_rec.payment_start_date = OKL_API.G_MISS_DATE)
        THEN
          x_ppyd_rec.payment_start_date := l_ppyd_rec.payment_start_date;
        END IF;
        IF (x_ppyd_rec.payment_frequency = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.payment_frequency := l_ppyd_rec.payment_frequency;
        END IF;
        IF (x_ppyd_rec.remit_days = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.remit_days := l_ppyd_rec.remit_days;
        END IF;
        IF (x_ppyd_rec.disbursement_basis = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.disbursement_basis := l_ppyd_rec.disbursement_basis;
        END IF;
        IF (x_ppyd_rec.disbursement_fixed_amount = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.disbursement_fixed_amount := l_ppyd_rec.disbursement_fixed_amount;
        END IF;
        IF (x_ppyd_rec.disbursement_percent = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.disbursement_percent := l_ppyd_rec.disbursement_percent;
        END IF;
        IF (x_ppyd_rec.processing_fee_basis = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.processing_fee_basis := l_ppyd_rec.processing_fee_basis;
        END IF;
        IF (x_ppyd_rec.processing_fee_fixed_amount = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.processing_fee_fixed_amount := l_ppyd_rec.processing_fee_fixed_amount;
        END IF;
        IF (x_ppyd_rec.processing_fee_percent = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.processing_fee_percent := l_ppyd_rec.processing_fee_percent;
        END IF;
		/*
        IF (x_ppyd_rec.include_in_yield_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.include_in_yield_flag := l_ppyd_rec.include_in_yield_flag;
        END IF;
        IF (x_ppyd_rec.processing_fee_formula = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.processing_fee_formula := l_ppyd_rec.processing_fee_formula;
        END IF; */
        IF (x_ppyd_rec.payment_basis = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.payment_basis := l_ppyd_rec.payment_basis;
        END IF;
        IF (x_ppyd_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute_category := l_ppyd_rec.attribute_category;
        END IF;
        IF (x_ppyd_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute1 := l_ppyd_rec.attribute1;
        END IF;
        IF (x_ppyd_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute2 := l_ppyd_rec.attribute2;
        END IF;
        IF (x_ppyd_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute3 := l_ppyd_rec.attribute3;
        END IF;
        IF (x_ppyd_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute4 := l_ppyd_rec.attribute4;
        END IF;
        IF (x_ppyd_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute5 := l_ppyd_rec.attribute5;
        END IF;
        IF (x_ppyd_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute6 := l_ppyd_rec.attribute6;
        END IF;
        IF (x_ppyd_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute7 := l_ppyd_rec.attribute7;
        END IF;
        IF (x_ppyd_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute8 := l_ppyd_rec.attribute8;
        END IF;
        IF (x_ppyd_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute9 := l_ppyd_rec.attribute9;
        END IF;
        IF (x_ppyd_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute10 := l_ppyd_rec.attribute10;
        END IF;
        IF (x_ppyd_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute11 := l_ppyd_rec.attribute11;
        END IF;
        IF (x_ppyd_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute12 := l_ppyd_rec.attribute12;
        END IF;
        IF (x_ppyd_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute13 := l_ppyd_rec.attribute13;
        END IF;
        IF (x_ppyd_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute14 := l_ppyd_rec.attribute14;
        END IF;
        IF (x_ppyd_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppyd_rec.attribute15 := l_ppyd_rec.attribute15;
        END IF;
        IF (x_ppyd_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.created_by := l_ppyd_rec.created_by;
        END IF;
        IF (x_ppyd_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_ppyd_rec.creation_date := l_ppyd_rec.creation_date;
        END IF;
        IF (x_ppyd_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.last_updated_by := l_ppyd_rec.last_updated_by;
        END IF;
        IF (x_ppyd_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_ppyd_rec.last_update_date := l_ppyd_rec.last_update_date;
        END IF;
        IF (x_ppyd_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.last_update_login := l_ppyd_rec.last_update_login;
        END IF;

        IF (x_ppyd_rec.ORIG_CONTRACT_LINE_ID = OKL_API.G_MISS_NUM)
        THEN
          x_ppyd_rec.ORIG_CONTRACT_LINE_ID := l_ppyd_rec.ORIG_CONTRACT_LINE_ID;
        END IF;


      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_PARTY_PAYMENT_DTLS --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_ppyd_rec IN ppyd_rec_type,
      x_ppyd_rec OUT NOCOPY ppyd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ppyd_rec := p_ppyd_rec;
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
      p_ppyd_rec,                        -- IN
      l_ppyd_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ppyd_rec, l_def_ppyd_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_PARTY_PAYMENT_DTLS
    SET OBJECT_VERSION_NUMBER = l_def_ppyd_rec.object_version_number,
        CPL_ID = l_def_ppyd_rec.cpl_id,
        VENDOR_ID = l_def_ppyd_rec.vendor_id,
        PAY_SITE_ID = l_def_ppyd_rec.pay_site_id,
        PAYMENT_TERM_ID = l_def_ppyd_rec.payment_term_id,
        PAYMENT_METHOD_CODE = l_def_ppyd_rec.payment_method_code,
        PAY_GROUP_CODE = l_def_ppyd_rec.pay_group_code,
		PAYMENT_HDR_ID = l_def_ppyd_rec.payment_hdr_id,
		PAYMENT_START_DATE = l_def_ppyd_rec.payment_start_date,
		PAYMENT_FREQUENCY = l_def_ppyd_rec.payment_frequency,
		REMIT_DAYS = l_def_ppyd_rec.remit_days,
		DISBURSEMENT_BASIS = l_def_ppyd_rec.disbursement_basis,
		DISBURSEMENT_FIXED_AMOUNT = l_def_ppyd_rec.disbursement_fixed_amount,
		DISBURSEMENT_PERCENT = l_def_ppyd_rec.disbursement_percent,
		PROCESSING_FEE_BASIS = l_def_ppyd_rec.processing_fee_basis,
		PROCESSING_FEE_FIXED_AMOUNT = l_def_ppyd_rec.processing_fee_fixed_amount,
		PROCESSING_FEE_PERCENT = l_def_ppyd_rec.processing_fee_percent,
		--INCLUDE_IN_YIELD_FLAG = l_def_ppyd_rec.include_in_yield_flag,
		--PROCESSING_FEE_FORMULA = l_def_ppyd_rec.processing_fee_formula,
		PAYMENT_BASIS = l_def_ppyd_rec.payment_basis,
        ATTRIBUTE_CATEGORY = l_def_ppyd_rec.attribute_category,
        ATTRIBUTE1 = l_def_ppyd_rec.attribute1,
        ATTRIBUTE2 = l_def_ppyd_rec.attribute2,
        ATTRIBUTE3 = l_def_ppyd_rec.attribute3,
        ATTRIBUTE4 = l_def_ppyd_rec.attribute4,
        ATTRIBUTE5 = l_def_ppyd_rec.attribute5,
        ATTRIBUTE6 = l_def_ppyd_rec.attribute6,
        ATTRIBUTE7 = l_def_ppyd_rec.attribute7,
        ATTRIBUTE8 = l_def_ppyd_rec.attribute8,
        ATTRIBUTE9 = l_def_ppyd_rec.attribute9,
        ATTRIBUTE10 = l_def_ppyd_rec.attribute10,
        ATTRIBUTE11 = l_def_ppyd_rec.attribute11,
        ATTRIBUTE12 = l_def_ppyd_rec.attribute12,
        ATTRIBUTE13 = l_def_ppyd_rec.attribute13,
        ATTRIBUTE14 = l_def_ppyd_rec.attribute14,
        ATTRIBUTE15 = l_def_ppyd_rec.attribute15,
        CREATED_BY = l_def_ppyd_rec.created_by,
        CREATION_DATE = l_def_ppyd_rec.creation_date,
        LAST_UPDATED_BY = l_def_ppyd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ppyd_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ppyd_rec.last_update_login,
        ORIG_CONTRACT_LINE_ID = l_def_ppyd_rec.ORIG_CONTRACT_LINE_ID
    WHERE ID = l_def_ppyd_rec.id;

    x_ppyd_rec := l_ppyd_rec;
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
  ---------------------------------------------
  -- update_row for:OKL_PARTY_PAYMENT_DTLS_V --
  ---------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type,
    x_ppydv_rec                    OUT NOCOPY ppydv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ppydv_rec                    ppydv_rec_type := p_ppydv_rec;
    l_def_ppydv_rec                ppydv_rec_type;
    l_db_ppydv_rec                 ppydv_rec_type;
    l_ppyd_rec                     ppyd_rec_type;
    lx_ppyd_rec                    ppyd_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ppydv_rec IN ppydv_rec_type
    ) RETURN ppydv_rec_type IS
      l_ppydv_rec ppydv_rec_type := p_ppydv_rec;
    BEGIN
      l_ppydv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ppydv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ppydv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ppydv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ppydv_rec IN ppydv_rec_type,
      x_ppydv_rec OUT NOCOPY ppydv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ppydv_rec := p_ppydv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_ppydv_rec := get_rec(p_ppydv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_ppydv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.id := l_db_ppydv_rec.id;
        END IF;
        IF (x_ppydv_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.object_version_number := l_db_ppydv_rec.object_version_number;
        END IF;
        IF (x_ppydv_rec.cpl_id = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.cpl_id := l_db_ppydv_rec.cpl_id;
        END IF;
        IF (x_ppydv_rec.vendor_id = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.vendor_id := l_db_ppydv_rec.vendor_id;
        END IF;
        IF (x_ppydv_rec.pay_site_id = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.pay_site_id := l_db_ppydv_rec.pay_site_id;
        END IF;
        IF (x_ppydv_rec.payment_term_id = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.payment_term_id := l_db_ppydv_rec.payment_term_id;
        END IF;
        IF (x_ppydv_rec.payment_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.payment_method_code := l_db_ppydv_rec.payment_method_code;
        END IF;
        IF (x_ppydv_rec.pay_group_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.pay_group_code := l_db_ppydv_rec.pay_group_code;
        END IF;
        IF (x_ppydv_rec.payment_hdr_id = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.payment_hdr_id := l_db_ppydv_rec.payment_hdr_id;
        END IF;
        IF (x_ppydv_rec.payment_start_date = OKL_API.G_MISS_DATE)
        THEN
          x_ppydv_rec.payment_start_date := l_db_ppydv_rec.payment_start_date;
        END IF;
        IF (x_ppydv_rec.payment_frequency = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.payment_frequency := l_db_ppydv_rec.payment_frequency;
        END IF;
        IF (x_ppydv_rec.remit_days = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.remit_days := l_db_ppydv_rec.remit_days;
        END IF;
        IF (x_ppydv_rec.disbursement_basis = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.disbursement_basis := l_db_ppydv_rec.disbursement_basis;
        END IF;
        IF (x_ppydv_rec.disbursement_fixed_amount = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.disbursement_fixed_amount := l_db_ppydv_rec.disbursement_fixed_amount;
        END IF;
        IF (x_ppydv_rec.disbursement_percent = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.disbursement_percent := l_db_ppydv_rec.disbursement_percent;
        END IF;
        IF (x_ppydv_rec.processing_fee_basis = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.processing_fee_basis := l_db_ppydv_rec.processing_fee_basis;
        END IF;
        IF (x_ppydv_rec.processing_fee_fixed_amount = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.processing_fee_fixed_amount := l_db_ppydv_rec.processing_fee_fixed_amount;
        END IF;
        IF (x_ppydv_rec.processing_fee_percent = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.processing_fee_percent := l_db_ppydv_rec.processing_fee_percent;
        END IF;/*
        IF (x_ppydv_rec.include_in_yield_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.include_in_yield_flag := l_db_ppydv_rec.include_in_yield_flag;
        END IF;
        IF (x_ppydv_rec.processing_fee_formula = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.processing_fee_formula := l_db_ppydv_rec.processing_fee_formula;
        END IF; */
        IF (x_ppydv_rec.payment_basis = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.payment_basis := l_db_ppydv_rec.payment_basis;
        END IF;
        IF (x_ppydv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute_category := l_db_ppydv_rec.attribute_category;
        END IF;
        IF (x_ppydv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute1 := l_db_ppydv_rec.attribute1;
        END IF;
        IF (x_ppydv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute2 := l_db_ppydv_rec.attribute2;
        END IF;
        IF (x_ppydv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute3 := l_db_ppydv_rec.attribute3;
        END IF;
        IF (x_ppydv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute4 := l_db_ppydv_rec.attribute4;
        END IF;
        IF (x_ppydv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute5 := l_db_ppydv_rec.attribute5;
        END IF;
        IF (x_ppydv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute6 := l_db_ppydv_rec.attribute6;
        END IF;
        IF (x_ppydv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute7 := l_db_ppydv_rec.attribute7;
        END IF;
        IF (x_ppydv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute8 := l_db_ppydv_rec.attribute8;
        END IF;
        IF (x_ppydv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute9 := l_db_ppydv_rec.attribute9;
        END IF;
        IF (x_ppydv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute10 := l_db_ppydv_rec.attribute10;
        END IF;
        IF (x_ppydv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute11 := l_db_ppydv_rec.attribute11;
        END IF;
        IF (x_ppydv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute12 := l_db_ppydv_rec.attribute12;
        END IF;
        IF (x_ppydv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute13 := l_db_ppydv_rec.attribute13;
        END IF;
        IF (x_ppydv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute14 := l_db_ppydv_rec.attribute14;
        END IF;
        IF (x_ppydv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_ppydv_rec.attribute15 := l_db_ppydv_rec.attribute15;
        END IF;
        IF (x_ppydv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.created_by := l_db_ppydv_rec.created_by;
        END IF;
        IF (x_ppydv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_ppydv_rec.creation_date := l_db_ppydv_rec.creation_date;
        END IF;
        IF (x_ppydv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.last_updated_by := l_db_ppydv_rec.last_updated_by;
        END IF;
        IF (x_ppydv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_ppydv_rec.last_update_date := l_db_ppydv_rec.last_update_date;
        END IF;
        IF (x_ppydv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.last_update_login := l_db_ppydv_rec.last_update_login;
        END IF;

         IF (x_ppydv_rec.ORIG_CONTRACT_LINE_ID = OKL_API.G_MISS_NUM)
        THEN
          x_ppydv_rec.ORIG_CONTRACT_LINE_ID := l_db_ppydv_rec.ORIG_CONTRACT_LINE_ID;
        END IF;


      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------------
    -- Set_Attributes for:OKL_PARTY_PAYMENT_DTLS_V --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_ppydv_rec IN ppydv_rec_type,
      x_ppydv_rec OUT NOCOPY ppydv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ppydv_rec := p_ppydv_rec;
      x_ppydv_rec.OBJECT_VERSION_NUMBER := NVL(x_ppydv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_ppydv_rec,                       -- IN
      x_ppydv_rec);                      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ppydv_rec, l_def_ppydv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ppydv_rec := fill_who_columns(l_def_ppydv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ppydv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ppydv_rec, l_db_ppydv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
      p_ppydv_rec                    => p_ppydv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
***********************/
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_ppydv_rec, l_ppyd_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ppyd_rec,
      lx_ppyd_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN party_cur(p_cpl_id => l_ppyd_rec.cpl_id);
    FETCH party_cur INTO party_rec;
    CLOSE party_cur;
    okl_contract_status_pub.cascade_lease_status_edit
          (p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => l_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_chr_id          => party_rec.dnz_chr_id);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_ppyd_rec, l_def_ppydv_rec);
    x_ppydv_rec := l_def_ppydv_rec;
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
  -----------------------------------------
  -- PL/SQL TBL update_row for:ppydv_tbl --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ppydv_tbl.COUNT > 0) THEN
      i := p_ppydv_tbl.FIRST;
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
            p_ppydv_rec                    => p_ppydv_tbl(i),
            x_ppydv_rec                    => x_ppydv_tbl(i));
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
        EXIT WHEN (i = p_ppydv_tbl.LAST);
        i := p_ppydv_tbl.NEXT(i);
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

  -----------------------------------------
  -- PL/SQL TBL update_row for:PPYDV_TBL --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ppydv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ppydv_tbl                    => p_ppydv_tbl,
        x_ppydv_tbl                    => x_ppydv_tbl,
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
  -------------------------------------------
  -- delete_row for:OKL_PARTY_PAYMENT_DTLS --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppyd_rec                     IN ppyd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ppyd_rec                     ppyd_rec_type := p_ppyd_rec;
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

    DELETE FROM OKL_PARTY_PAYMENT_DTLS
     WHERE ID = p_ppyd_rec.id;

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
  ---------------------------------------------
  -- delete_row for:OKL_PARTY_PAYMENT_DTLS_V --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ppydv_rec                    ppydv_rec_type := p_ppydv_rec;
    l_ppyd_rec                     ppyd_rec_type;

    CURSOR l_get_cpl_id_csr(p_id IN NUMBER) IS
    SELECT cpl_id FROM okl_party_payment_dtls_v
    WHERE id = p_id;
    l_cpl_id NUMBER;
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
    migrate(l_ppydv_rec, l_ppyd_rec);
    OPEN l_get_cpl_id_csr(p_id => l_ppyd_rec.id);
    FETCH l_get_cpl_id_csr INTO l_cpl_id;
    CLOSE l_get_cpl_id_csr;
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ppyd_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN party_cur(p_cpl_id => l_cpl_id);
    FETCH party_cur INTO party_rec;
    CLOSE party_cur;
    okl_contract_status_pub.cascade_lease_status_edit
          (p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => l_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_chr_id          => party_rec.dnz_chr_id);
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
  --------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_PARTY_PAYMENT_DTLS_V --
  --------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ppydv_tbl.COUNT > 0) THEN
      i := p_ppydv_tbl.FIRST;
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
            p_ppydv_rec                    => p_ppydv_tbl(i));
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
        EXIT WHEN (i = p_ppydv_tbl.LAST);
        i := p_ppydv_tbl.NEXT(i);
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

  --------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_PARTY_PAYMENT_DTLS_V --
  --------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ppydv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ppydv_tbl                    => p_ppydv_tbl,
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

  ---------------------------------------------------------------------------
  -- PROCEDURE versioning
  ---------------------------------------------------------------------------

  FUNCTION create_version(
    p_chr_id IN NUMBER,
    p_major_version IN NUMBER) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO OKL_PARTY_PYMT_DTLS_H
  (
ID
,OBJECT_VERSION_NUMBER
,MAJOR_VERSION
,CPL_ID
,VENDOR_ID
,PAY_SITE_ID
,PAYMENT_TERM_ID
,PAYMENT_METHOD_CODE
,PAY_GROUP_CODE
,PAYMENT_HDR_ID
,PAYMENT_START_DATE
,PAYMENT_FREQUENCY
,REMIT_DAYS
,DISBURSEMENT_BASIS
,DISBURSEMENT_FIXED_AMOUNT
,DISBURSEMENT_PERCENT
,PROCESSING_FEE_BASIS
,PROCESSING_FEE_FIXED_AMOUNT
,PROCESSING_FEE_PERCENT
--,INCLUDE_IN_YIELD_FLAG
--,PROCESSING_FEE_FORMULA
,PAYMENT_BASIS
,ATTRIBUTE_CATEGORY
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CREATED_BY
,CREATION_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,ORIG_CONTRACT_LINE_ID
)
  SELECT
 ID
,OBJECT_VERSION_NUMBER
,p_major_version
,CPL_ID
,VENDOR_ID
,PAY_SITE_ID
,PAYMENT_TERM_ID
,PAYMENT_METHOD_CODE
,PAY_GROUP_CODE
,PAYMENT_HDR_ID
,PAYMENT_START_DATE
,PAYMENT_FREQUENCY
,REMIT_DAYS
,DISBURSEMENT_BASIS
,DISBURSEMENT_FIXED_AMOUNT
,DISBURSEMENT_PERCENT
,PROCESSING_FEE_BASIS
,PROCESSING_FEE_FIXED_AMOUNT
,PROCESSING_FEE_PERCENT
--,INCLUDE_IN_YIELD_FLAG
--,PROCESSING_FEE_FORMULA
,PAYMENT_BASIS
,ATTRIBUTE_CATEGORY
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CREATED_BY
,CREATION_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,ORIG_CONTRACT_LINE_ID
  FROM OKL_PARTY_PAYMENT_DTLS
  WHERE cpl_id in (select id from okc_k_party_roles_b  where dnz_chr_id = p_chr_id);

  RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END create_version;

--------------------------------------------------------------------
--Restore version
--------------------------------------------------------------------
FUNCTION restore_version(
    p_chr_id IN NUMBER,
    p_major_version IN NUMBER) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO OKL_PARTY_PAYMENT_DTLS
  (
ID
,OBJECT_VERSION_NUMBER
,CPL_ID
,VENDOR_ID
,PAY_SITE_ID
,PAYMENT_TERM_ID
,PAYMENT_METHOD_CODE
,PAY_GROUP_CODE
,PAYMENT_HDR_ID
,PAYMENT_START_DATE
,PAYMENT_FREQUENCY
,REMIT_DAYS
,DISBURSEMENT_BASIS
,DISBURSEMENT_FIXED_AMOUNT
,DISBURSEMENT_PERCENT
,PROCESSING_FEE_BASIS
,PROCESSING_FEE_FIXED_AMOUNT
,PROCESSING_FEE_PERCENT
--,INCLUDE_IN_YIELD_FLAG
--,PROCESSING_FEE_FORMULA
,PAYMENT_BASIS
,ATTRIBUTE_CATEGORY
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CREATED_BY
,CREATION_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,ORIG_CONTRACT_LINE_ID
)
  SELECT
ID
,OBJECT_VERSION_NUMBER
,CPL_ID
,VENDOR_ID
,PAY_SITE_ID
,PAYMENT_TERM_ID
,PAYMENT_METHOD_CODE
,PAY_GROUP_CODE
,PAYMENT_HDR_ID
,PAYMENT_START_DATE
,PAYMENT_FREQUENCY
,REMIT_DAYS
,DISBURSEMENT_BASIS
,DISBURSEMENT_FIXED_AMOUNT
,DISBURSEMENT_PERCENT
,PROCESSING_FEE_BASIS
,PROCESSING_FEE_FIXED_AMOUNT
,PROCESSING_FEE_PERCENT
--,INCLUDE_IN_YIELD_FLAG
--,PROCESSING_FEE_FORMULA
,PAYMENT_BASIS
,ATTRIBUTE_CATEGORY
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CREATED_BY
,CREATION_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,ORIG_CONTRACT_LINE_ID

  FROM OKL_PARTY_PYMT_DTLS_H
  WHERE cpl_id in (select id from okc_k_party_roles_b where dnz_chr_id = p_chr_id) and major_version = p_major_version;


  RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END restore_version;

END OKL_PYD_PVT;

/
