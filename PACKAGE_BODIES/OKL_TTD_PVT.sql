--------------------------------------------------------
--  DDL for Package Body OKL_TTD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TTD_PVT" AS
/* $Header: OKLSTTDB.pls 120.3 2007/01/15 11:16:46 dcshanmu noship $ */
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
  -- FUNCTION get_rec for: OKL_TAX_TRX_DETAILS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ttdv_rec    IN ttdv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ttdv_rec_type IS
    CURSOR okl_ttdv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            TXS_ID,
            TAX_DETERMINE_DATE,
            TAX_RATE_ID,
            TAX_RATE_CODE,
            TAXABLE_AMT,
            TAX_EXEMPTION_ID,
            TAX_RATE,
            TAX_AMT,
            BILLED_YN,
            TAX_CALL_TYPE_CODE,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
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
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER,
	    -- Modified by dcshanmu for eBTax - modification starts
	    TAX_DATE,
	    LINE_AMT,
	    INTERNAL_ORGANIZATION_ID,
	    APPLICATION_ID,
	    ENTITY_CODE,
	    EVENT_CLASS_CODE,
	    EVENT_TYPE_CODE,
	    TRX_ID,
	    TRX_LINE_ID,
	    TRX_LEVEL_TYPE,
	    TRX_LINE_NUMBER,
	    TAX_LINE_NUMBER,
	    TAX_REGIME_ID,
	    TAX_REGIME_CODE,
	    TAX_ID,
	    TAX,
	    TAX_STATUS_ID,
	    TAX_STATUS_CODE,
	    TAX_APPORTIONMENT_LINE_NUMBER,
	    LEGAL_ENTITY_ID,
	    TRX_NUMBER,
	    TRX_DATE,
	    TAX_JURISDICTION_ID,
	    TAX_JURISDICTION_CODE,
	    TAX_TYPE_CODE,
	    TAX_CURRENCY_CODE,
	    TAXABLE_AMT_TAX_CURR,
	    TRX_CURRENCY_CODE,
	    MINIMUM_ACCOUNTABLE_UNIT,
	    PRECISION,
	    CURRENCY_CONVERSION_TYPE,
	    CURRENCY_CONVERSION_RATE,
	    CURRENCY_CONVERSION_DATE
	    -- Modified by dcshanmu for eBTax - modification end
      FROM Okl_Tax_Trx_Details
     WHERE okl_tax_trx_details.id = p_id;
    l_okl_ttdv_pk                  okl_ttdv_pk_csr%ROWTYPE;
    l_ttdv_rec    ttdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ttdv_pk_csr (p_ttdv_rec.id);
    FETCH okl_ttdv_pk_csr INTO
              l_ttdv_rec.id,
              l_ttdv_rec.txs_id,
              l_ttdv_rec.tax_determine_date,
              l_ttdv_rec.tax_rate_id,
              l_ttdv_rec.tax_rate_code,
              l_ttdv_rec.taxable_amt,
              l_ttdv_rec.tax_exemption_id,
              l_ttdv_rec.tax_rate,
              l_ttdv_rec.tax_amt,
              l_ttdv_rec.billed_yn,
              l_ttdv_rec.tax_call_type_code,
              l_ttdv_rec.program_id,
              l_ttdv_rec.request_id,
              l_ttdv_rec.program_application_id,
              l_ttdv_rec.program_update_date,
              l_ttdv_rec.attribute_category,
              l_ttdv_rec.attribute1,
              l_ttdv_rec.attribute2,
              l_ttdv_rec.attribute3,
              l_ttdv_rec.attribute4,
              l_ttdv_rec.attribute5,
              l_ttdv_rec.attribute6,
              l_ttdv_rec.attribute7,
              l_ttdv_rec.attribute8,
              l_ttdv_rec.attribute9,
              l_ttdv_rec.attribute10,
              l_ttdv_rec.attribute11,
              l_ttdv_rec.attribute12,
              l_ttdv_rec.attribute13,
              l_ttdv_rec.attribute14,
              l_ttdv_rec.attribute15,
              l_ttdv_rec.created_by,
              l_ttdv_rec.creation_date,
              l_ttdv_rec.last_updated_by,
              l_ttdv_rec.last_update_date,
              l_ttdv_rec.last_update_login,
              l_ttdv_rec.object_version_number,
	      -- Modified by dcshanmu for eBTax - modification starts
              l_ttdv_rec.tax_date,
              l_ttdv_rec.line_amt,
              l_ttdv_rec.internal_organization_id,
              l_ttdv_rec.application_id,
              l_ttdv_rec.entity_code,
              l_ttdv_rec.event_class_code,
              l_ttdv_rec.event_type_code,
              l_ttdv_rec.trx_id,
              l_ttdv_rec.trx_line_id,
              l_ttdv_rec.trx_level_type,
              l_ttdv_rec.trx_line_number,
              l_ttdv_rec.tax_line_number,
              l_ttdv_rec.tax_regime_id,
              l_ttdv_rec.tax_regime_code,
              l_ttdv_rec.tax_id,
              l_ttdv_rec.tax,
              l_ttdv_rec.tax_status_id,
              l_ttdv_rec.tax_status_code,
              l_ttdv_rec.tax_apportionment_line_number,
              l_ttdv_rec.legal_entity_id,
              l_ttdv_rec.trx_number,
              l_ttdv_rec.trx_date,
              l_ttdv_rec.tax_jurisdiction_id,
              l_ttdv_rec.tax_jurisdiction_code,
              l_ttdv_rec.tax_type_code,
              l_ttdv_rec.tax_currency_code,
              l_ttdv_rec.taxable_amt_tax_curr,
              l_ttdv_rec.trx_currency_code,
              l_ttdv_rec.minimum_accountable_unit,
              l_ttdv_rec.precision,
              l_ttdv_rec.currency_conversion_type,
              l_ttdv_rec.currency_conversion_rate,
              l_ttdv_rec.currency_conversion_date;
	      -- Modified by dcshanmu for eBTax - modification end
    x_no_data_found := okl_ttdv_pk_csr%NOTFOUND;
    CLOSE okl_ttdv_pk_csr;
    RETURN(l_ttdv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ttdv_rec    IN ttdv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ttdv_rec_type IS
    l_ttdv_rec    ttdv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_ttdv_rec := get_rec(p_ttdv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ttdv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ttdv_rec    IN ttdv_rec_type
  ) RETURN ttdv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ttdv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TAX_TRX_DETAILS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ttd_rec                      IN ttd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ttd_rec_type IS
    CURSOR okl_ttd_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            TXS_ID,
            TAX_DETERMINE_DATE,
            TAX_RATE_ID,
            TAX_RATE_CODE,
            TAXABLE_AMT,
            TAX_EXEMPTION_ID,
            TAX_RATE,
            TAX_AMT,
            BILLED_YN,
            TAX_CALL_TYPE_CODE,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
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
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER,
	    -- Modified by dcshanmu for eBTax - modification starts
	    TAX_DATE,
            LINE_AMT,
            INTERNAL_ORGANIZATION_ID,
            APPLICATION_ID,
            ENTITY_CODE,
            EVENT_CLASS_CODE,
            EVENT_TYPE_CODE,
            TRX_ID,
            TRX_LINE_ID,
            TRX_LEVEL_TYPE,
            TRX_LINE_NUMBER,
            TAX_LINE_NUMBER,
            TAX_REGIME_ID,
            TAX_REGIME_CODE,
            TAX_ID,
            TAX,
            TAX_STATUS_ID,
            TAX_STATUS_CODE,
            TAX_APPORTIONMENT_LINE_NUMBER,
            LEGAL_ENTITY_ID,
            TRX_NUMBER,
            TRX_DATE,
            TAX_JURISDICTION_ID,
            TAX_JURISDICTION_CODE,
            TAX_TYPE_CODE,
            TAX_CURRENCY_CODE,
            TAXABLE_AMT_TAX_CURR,
            TRX_CURRENCY_CODE,
            MINIMUM_ACCOUNTABLE_UNIT,
            PRECISION,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
	    -- Modified by dcshanmu for eBTax - modification end

      FROM Okl_Tax_Trx_Details
     WHERE okl_tax_trx_details.id = p_id;
    l_okl_ttd_pk                   okl_ttd_pk_csr%ROWTYPE;
    l_ttd_rec                      ttd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ttd_pk_csr (p_ttd_rec.id);
    FETCH okl_ttd_pk_csr INTO
              l_ttd_rec.id,
              l_ttd_rec.txs_id,
              l_ttd_rec.tax_determine_date,
              l_ttd_rec.tax_rate_id,
              l_ttd_rec.tax_rate_code,
              l_ttd_rec.taxable_amt,
              l_ttd_rec.tax_exemption_id,
              l_ttd_rec.tax_rate,
              l_ttd_rec.tax_amt,
              l_ttd_rec.billed_yn,
              l_ttd_rec.tax_call_type_code,
              l_ttd_rec.program_id,
              l_ttd_rec.request_id,
              l_ttd_rec.program_application_id,
              l_ttd_rec.program_update_date,
              l_ttd_rec.attribute_category,
              l_ttd_rec.attribute1,
              l_ttd_rec.attribute2,
              l_ttd_rec.attribute3,
              l_ttd_rec.attribute4,
              l_ttd_rec.attribute5,
              l_ttd_rec.attribute6,
              l_ttd_rec.attribute7,
              l_ttd_rec.attribute8,
              l_ttd_rec.attribute9,
              l_ttd_rec.attribute10,
              l_ttd_rec.attribute11,
              l_ttd_rec.attribute12,
              l_ttd_rec.attribute13,
              l_ttd_rec.attribute14,
              l_ttd_rec.attribute15,
              l_ttd_rec.created_by,
              l_ttd_rec.creation_date,
              l_ttd_rec.last_updated_by,
              l_ttd_rec.last_update_date,
              l_ttd_rec.last_update_login,
              l_ttd_rec.object_version_number,
	      -- Modified by dcshanmu for eBTax - modification starts
              l_ttd_rec.tax_date,
              l_ttd_rec.line_amt,
              l_ttd_rec.internal_organization_id,
              l_ttd_rec.application_id,
              l_ttd_rec.entity_code,
              l_ttd_rec.event_class_code,
              l_ttd_rec.event_type_code,
              l_ttd_rec.trx_id,
              l_ttd_rec.trx_line_id,
              l_ttd_rec.trx_level_type,
              l_ttd_rec.trx_line_number,
              l_ttd_rec.tax_line_number,
              l_ttd_rec.tax_regime_id,
              l_ttd_rec.tax_regime_code,
              l_ttd_rec.tax_id,
              l_ttd_rec.tax,
              l_ttd_rec.tax_status_id,
              l_ttd_rec.tax_status_code,
              l_ttd_rec.tax_apportionment_line_number,
              l_ttd_rec.legal_entity_id,
              l_ttd_rec.trx_number,
              l_ttd_rec.trx_date,
              l_ttd_rec.tax_jurisdiction_id,
              l_ttd_rec.tax_jurisdiction_code,
              l_ttd_rec.tax_type_code,
              l_ttd_rec.tax_currency_code,
              l_ttd_rec.taxable_amt_tax_curr,
              l_ttd_rec.trx_currency_code,
              l_ttd_rec.minimum_accountable_unit,
              l_ttd_rec.precision,
              l_ttd_rec.currency_conversion_type,
              l_ttd_rec.currency_conversion_rate,
              l_ttd_rec.currency_conversion_date;
	      -- Modified by dcshanmu for eBTax - modification end
    x_no_data_found := okl_ttd_pk_csr%NOTFOUND;
    CLOSE okl_ttd_pk_csr;
    RETURN(l_ttd_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ttd_rec                      IN ttd_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ttd_rec_type IS
    l_ttd_rec                      ttd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_ttd_rec := get_rec(p_ttd_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ttd_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ttd_rec                      IN ttd_rec_type
  ) RETURN ttd_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ttd_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TAX_TRX_DETAILS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ttdv_rec   IN ttdv_rec_type
  ) RETURN ttdv_rec_type IS
    l_ttdv_rec    ttdv_rec_type := p_ttdv_rec;
  BEGIN
    IF (l_ttdv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.id := NULL;
    END IF;
    IF (l_ttdv_rec.txs_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.txs_id := NULL;
    END IF;
    IF (l_ttdv_rec.tax_determine_date = OKL_API.G_MISS_DATE ) THEN
      l_ttdv_rec.tax_determine_date := NULL;
    END IF;
    IF (l_ttdv_rec.tax_rate_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.tax_rate_id := NULL;
    END IF;
    IF (l_ttdv_rec.tax_rate_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.tax_rate_code := NULL;
    END IF;
    IF (l_ttdv_rec.taxable_amt = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.taxable_amt := NULL;
    END IF;
    IF (l_ttdv_rec.tax_exemption_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.tax_exemption_id := NULL;
    END IF;
    IF (l_ttdv_rec.tax_rate = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.tax_rate := NULL;
    END IF;
    IF (l_ttdv_rec.tax_amt = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.tax_amt := NULL;
    END IF;
    IF (l_ttdv_rec.billed_yn = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.billed_yn := NULL;
    END IF;
    IF (l_ttdv_rec.tax_call_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.tax_call_type_code := NULL;
    END IF;
    IF (l_ttdv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.program_id := NULL;
    END IF;
    IF (l_ttdv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.request_id := NULL;
    END IF;
    IF (l_ttdv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.program_application_id := NULL;
    END IF;
    IF (l_ttdv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_ttdv_rec.program_update_date := NULL;
    END IF;
    IF (l_ttdv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute_category := NULL;
    END IF;
    IF (l_ttdv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute1 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute2 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute3 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute4 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute5 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute6 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute7 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute8 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute9 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute10 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute11 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute12 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute13 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute14 := NULL;
    END IF;
    IF (l_ttdv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.attribute15 := NULL;
    END IF;
    IF (l_ttdv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.created_by := NULL;
    END IF;
    IF (l_ttdv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_ttdv_rec.creation_date := NULL;
    END IF;
    IF (l_ttdv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ttdv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_ttdv_rec.last_update_date := NULL;
    END IF;
    IF (l_ttdv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.last_update_login := NULL;
    END IF;
    IF (l_ttdv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.object_version_number := NULL;
    END IF;

    -- Modified by dcshanmu for eBTax - modification starts
    -- Added default null out for newly added columns in the table

    IF (l_ttdv_rec.tax_date = OKL_API.G_MISS_DATE ) THEN
      l_ttdv_rec.tax_date := NULL;
    END IF;
    IF (l_ttdv_rec.line_amt = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.line_amt := NULL;
    END IF;
    IF (l_ttdv_rec.internal_organization_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.internal_organization_id := NULL;
    END IF;
    IF (l_ttdv_rec.application_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.application_id := NULL;
    END IF;
    IF (l_ttdv_rec.entity_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.entity_code := NULL;
    END IF;
    IF (l_ttdv_rec.event_class_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.event_class_code := NULL;
    END IF;
    IF (l_ttdv_rec.event_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.event_type_code := NULL;
    END IF;
    IF (l_ttdv_rec.trx_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.trx_id := NULL;
    END IF;
    IF (l_ttdv_rec.trx_line_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.trx_line_id := NULL;
    END IF;
    IF (l_ttdv_rec.trx_level_type = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.trx_level_type := NULL;
    END IF;
    IF (l_ttdv_rec.trx_line_number = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.trx_line_number := NULL;
    END IF;
    IF (l_ttdv_rec.tax_line_number = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.tax_line_number := NULL;
    END IF;
    IF (l_ttdv_rec.tax_regime_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.tax_regime_id := NULL;
    END IF;
    IF (l_ttdv_rec.tax_regime_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.tax_regime_code := NULL;
    END IF;
    IF (l_ttdv_rec.tax_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.tax_id := NULL;
    END IF;
    IF (l_ttdv_rec.tax = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.tax := NULL;
    END IF;
    IF (l_ttdv_rec.tax_status_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.tax_status_id := NULL;
    END IF;
    IF (l_ttdv_rec.tax_status_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.tax_status_code := NULL;
    END IF;
    IF (l_ttdv_rec.tax_apportionment_line_number = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.tax_apportionment_line_number := NULL;
    END IF;
    IF (l_ttdv_rec.legal_entity_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.legal_entity_id := NULL;
    END IF;
    IF (l_ttdv_rec.trx_number = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.trx_number := NULL;
    END IF;
    IF (l_ttdv_rec.trx_date = OKL_API.G_MISS_DATE ) THEN
      l_ttdv_rec.trx_date := NULL;
    END IF;
    IF (l_ttdv_rec.tax_jurisdiction_id = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.tax_jurisdiction_id := NULL;
    END IF;
    IF (l_ttdv_rec.tax_jurisdiction_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.tax_jurisdiction_code := NULL;
    END IF;
    IF (l_ttdv_rec.tax_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.tax_type_code := NULL;
    END IF;
    IF (l_ttdv_rec.tax_currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.tax_currency_code := NULL;
    END IF;
    IF (l_ttdv_rec.taxable_amt_tax_curr = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.taxable_amt_tax_curr := NULL;
    END IF;
    IF (l_ttdv_rec.trx_currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.trx_currency_code := NULL;
    END IF;
    IF (l_ttdv_rec.minimum_accountable_unit = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.minimum_accountable_unit := NULL;
    END IF;
    IF (l_ttdv_rec.precision = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.precision := NULL;
    END IF;
    IF (l_ttdv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR ) THEN
      l_ttdv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_ttdv_rec.currency_conversion_rate = OKL_API.G_MISS_NUM ) THEN
      l_ttdv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_ttdv_rec.currency_conversion_date = OKL_API.G_MISS_DATE ) THEN
      l_ttdv_rec.currency_conversion_date := NULL;
    END IF;
    -- Modified by dcshanmu for eBTax - modification end

    RETURN(l_ttdv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_ttdv_rec.id = OKL_API.G_MISS_NUM OR p_ttdv_rec.id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  -------------------------------------
  -- Validate_Attributes for: TXS_ID --
  -------------------------------------
  PROCEDURE validate_txs_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_txs_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_tax_sources
       WHERE id   = p_id;
  BEGIN

    IF (p_ttdv_rec.txs_id = OKL_API.G_MISS_NUM OR p_ttdv_rec.txs_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'txs_id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSE
	  OPEN   okl_ttdv_txs_id_fk_csr(p_ttdv_rec.txs_id) ;
      FETCH  okl_ttdv_txs_id_fk_csr into l_dummy_var ;
      CLOSE  okl_ttdv_txs_id_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'txs_id',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'OKL_TAX_SOURCES');
           l_return_status := OKC_API.G_RET_STS_ERROR;

      END IF;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_txs_id;
  -------------------------------------------------
  -- Validate_Attributes for: TAX_CALL_TYPE_CODE --
  -------------------------------------------------
  PROCEDURE validate_tax_call_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_tctc_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
      FROM Fnd_Lookup_Values
      WHERE fnd_lookup_values.lookup_code = p_lookup_code
      AND   fnd_lookup_values.lookup_type = p_lookup_type;
  BEGIN

    IF (p_ttdv_rec.tax_call_type_code <> OKL_API.G_MISS_CHAR AND  p_ttdv_rec.tax_call_type_code IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tax_call_type_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
        OPEN   okl_ttdv_tctc_fk_csr(p_ttdv_rec.tax_call_type_code, 'OKL_TAX_CALL_TYPE')  ;
        FETCH  okl_ttdv_tctc_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_tctc_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_call_type_code',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'FND_LOOKUP_VALUES');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_call_type_code;

  -- Modified by dcshanmu for eBTax - modification starts
  -- added validation methods for newly added columns
  -------------------------------------------------
  -- Validate_Attributes for: TAX_RATE_ID --
  -------------------------------------------------
  PROCEDURE validate_tax_rate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_tri_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_rates_b
      WHERE zx_rates_b.tax_rate_id = p_id;
  BEGIN

    IF (p_ttdv_rec.tax_rate_id <> OKL_API.G_MISS_NUM AND  p_ttdv_rec.tax_rate_id IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tax_call_type_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
        OPEN   okl_ttdv_tri_fk_csr(p_ttdv_rec.tax_rate_id)  ;
        FETCH  okl_ttdv_tri_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_tri_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_rate_id',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'ZX_RATES_B');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_rate_id;
  -------------------------------------------------
  -- Validate_Attributes for: TAX_RATE_CODE --
  -------------------------------------------------
  PROCEDURE validate_tax_rate_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_trc_fk_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
      FROM zx_rates_b
      WHERE zx_rates_b.tax_rate_code = p_code;
  BEGIN

    IF (p_ttdv_rec.tax_rate_code <> OKL_API.G_MISS_CHAR AND  p_ttdv_rec.tax_rate_code IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tax_call_type_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
        OPEN   okl_ttdv_trc_fk_csr(p_ttdv_rec.tax_rate_code)  ;
        FETCH  okl_ttdv_trc_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_trc_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_rate_code',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'ZX_RATES_B');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_rate_code;
  -------------------------------------------------
  -- Validate_Attributes for: TAX_EXEMPTION_ID --
  -------------------------------------------------
  PROCEDURE validate_tax_exemption_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_tei_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_exemptions
      WHERE zx_exemptions.tax_exemption_id = p_id;
  BEGIN

    IF (p_ttdv_rec.tax_exemption_id <> OKL_API.G_MISS_NUM AND  p_ttdv_rec.tax_exemption_id IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tax_call_type_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
        OPEN   okl_ttdv_tei_fk_csr(p_ttdv_rec.tax_exemption_id)  ;
        FETCH  okl_ttdv_tei_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_tei_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_exemption_id',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'ZX_EXEMPTIONS');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_exemption_id;
  -------------------------------------------------
  -- Validate_Attributes for: INTERNAL_ORGANIZATION_ID --
  -------------------------------------------------
  PROCEDURE validate_int_org_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_ioi_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM hr_all_organization_units
      WHERE hr_all_organization_units.organization_id = p_id;
  BEGIN

    IF (p_ttdv_rec.internal_organization_id <> OKL_API.G_MISS_NUM AND  p_ttdv_rec.internal_organization_id IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tax_call_type_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
        OPEN   okl_ttdv_ioi_fk_csr(p_ttdv_rec.internal_organization_id)  ;
        FETCH  okl_ttdv_ioi_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_ioi_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'internal_organization_id',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'HR_ALL_ORGANIZATION_UNITS');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;
    ELSIF (p_ttdv_rec.internal_organization_id = OKL_API.G_MISS_NUM OR  p_ttdv_rec.internal_organization_id IS NULL)
    THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'internal_organization_id');
        l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_int_org_id;
  -------------------------------------------------
  -- Validate_Attributes for: APPLICATION_ID --
  -------------------------------------------------
  PROCEDURE validate_application_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_app_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM fnd_application
      WHERE fnd_application.application_id = p_id;
  BEGIN

    IF (p_ttdv_rec.application_id <> OKL_API.G_MISS_NUM AND  p_ttdv_rec.application_id IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tax_call_type_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
        OPEN   okl_ttdv_app_id_fk_csr(p_ttdv_rec.application_id)  ;
        FETCH  okl_ttdv_app_id_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_app_id_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'application_id',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'FND_APPLICATION');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;
    ELSIF (p_ttdv_rec.application_id = OKL_API.G_MISS_NUM OR  p_ttdv_rec.application_id IS NULL)
    THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'application_id');
        l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_application_id;
  -------------------------------------------------
  -- Validate_Attributes for: ENTITY_CODE --
  -------------------------------------------------
  PROCEDURE validate_entity_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	IF (p_ttdv_rec.entity_code = OKL_API.G_MISS_CHAR OR  p_ttdv_rec.entity_code IS NULL)
	    THEN
		OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'entity_code');
		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_entity_code;
  -------------------------------------------------
  -- Validate_Attributes for: EVENT_CLASS_CODE --
  -------------------------------------------------
  PROCEDURE validate_event_class_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	IF (p_ttdv_rec.event_class_code = OKL_API.G_MISS_CHAR OR  p_ttdv_rec.event_class_code IS NULL)
	    THEN
		OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'event_class_code');
		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_event_class_code;
  -------------------------------------------------
  -- Validate_Attributes for: EVENT_TYPE_CODE --
  -------------------------------------------------
  PROCEDURE validate_event_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	IF (p_ttdv_rec.event_type_code = OKL_API.G_MISS_CHAR OR  p_ttdv_rec.event_type_code IS NULL)
	    THEN
		OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'event_type_code');
		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_event_type_code;
  -------------------------------------------------
  -- Validate_Attributes for: TRX_ID --
  -------------------------------------------------
  PROCEDURE validate_trx_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	IF (p_ttdv_rec.trx_id = OKL_API.G_MISS_NUM OR  p_ttdv_rec.trx_id IS NULL)
	    THEN
		OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_id');
		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_trx_id;
  -------------------------------------------------
  -- Validate_Attributes for: TRX_LINE_ID --
  -------------------------------------------------
  PROCEDURE validate_trx_line_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	IF (p_ttdv_rec.trx_line_id = OKL_API.G_MISS_NUM OR  p_ttdv_rec.trx_line_id IS NULL)
	    THEN
		OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_line_id');
		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_trx_line_id;
  -------------------------------------------------
  -- Validate_Attributes for: TRX_LEVEL_TYPE --
  -------------------------------------------------
  PROCEDURE validate_trx_level_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	IF (p_ttdv_rec.trx_level_type = OKL_API.G_MISS_CHAR OR  p_ttdv_rec.trx_level_type IS NULL)
	    THEN
		OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_level_type');
		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_trx_level_type;
  -------------------------------------------------
  -- Validate_Attributes for: TAX_LINE_NUMBER --
  -------------------------------------------------
  PROCEDURE validate_tax_line_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	IF (p_ttdv_rec.tax_line_number = OKL_API.G_MISS_NUM OR  p_ttdv_rec.tax_line_number IS NULL)
	    THEN
		OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tax_line_number');
		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_line_number;
  -------------------------------------------------
  -- Validate_Attributes for: TAX_REGIME_ID --
  -------------------------------------------------
  PROCEDURE validate_tax_regime_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_tx_reg_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_regimes_b
      WHERE zx_regimes_b.tax_regime_id = p_id;
  BEGIN

    IF (p_ttdv_rec.tax_regime_id <> OKL_API.G_MISS_NUM AND  p_ttdv_rec.tax_regime_id IS NOT NULL)
    THEN
        OPEN   okl_ttdv_tx_reg_id_fk_csr(p_ttdv_rec.tax_regime_id)  ;
        FETCH  okl_ttdv_tx_reg_id_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_tx_reg_id_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_regime_id',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'ZX_REGIMES_B');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_regime_id;
  -------------------------------------------------
  -- Validate_Attributes for: TAX_REGIME_CODE --
  -------------------------------------------------
  PROCEDURE validate_tax_regime_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_tx_reg_cd_fk_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
      FROM zx_regimes_b
      WHERE zx_regimes_b.tax_regime_code = p_code;
  BEGIN

    IF (p_ttdv_rec.tax_regime_code <> OKL_API.G_MISS_CHAR AND  p_ttdv_rec.tax_regime_code IS NOT NULL)
    THEN
        OPEN   okl_ttdv_tx_reg_cd_fk_csr(p_ttdv_rec.tax_regime_code)  ;
        FETCH  okl_ttdv_tx_reg_cd_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_tx_reg_cd_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_regime_code',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'ZX_REGIMES_B');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_regime_code;
  -------------------------------------------------
  -- Validate_Attributes for: TAX_ID --
  -------------------------------------------------
  PROCEDURE validate_tax_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_tx_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_taxes_b
      WHERE zx_taxes_b.tax_id = p_id;
  BEGIN

    IF (p_ttdv_rec.tax_id <> OKL_API.G_MISS_NUM AND  p_ttdv_rec.tax_id IS NOT NULL)
    THEN
        OPEN   okl_ttdv_tx_id_fk_csr(p_ttdv_rec.tax_id)  ;
        FETCH  okl_ttdv_tx_id_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_tx_id_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_id',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'ZX_TAXES_B');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_id;
  -------------------------------------------------
  -- Validate_Attributes for: TAX_STATUS_ID --
  -------------------------------------------------
  PROCEDURE validate_tax_status_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_tx_st_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_status_b
      WHERE zx_status_b.tax_status_id = p_id;
  BEGIN

    IF (p_ttdv_rec.tax_status_id <> OKL_API.G_MISS_NUM AND  p_ttdv_rec.tax_status_id IS NOT NULL)
    THEN
        OPEN   okl_ttdv_tx_st_id_fk_csr(p_ttdv_rec.tax_status_id)  ;
        FETCH  okl_ttdv_tx_st_id_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_tx_st_id_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_status_id',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'ZX_STATUS_B');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_status_id;
  -------------------------------------------------
  -- Validate_Attributes for: TAX_JURISDICTION_ID --
  -------------------------------------------------
  PROCEDURE validate_tax_juris_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_tx_jur_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_jurisdictions_b
      WHERE zx_jurisdictions_b.tax_jurisdiction_id = p_id;
  BEGIN

    IF (p_ttdv_rec.tax_jurisdiction_id <> OKL_API.G_MISS_NUM AND  p_ttdv_rec.tax_jurisdiction_id IS NOT NULL)
    THEN
        OPEN   okl_ttdv_tx_jur_id_fk_csr(p_ttdv_rec.tax_jurisdiction_id)  ;
        FETCH  okl_ttdv_tx_jur_id_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_tx_jur_id_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_jurisdiction_id',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'ZX_JURISDICTIONS_B');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_juris_id;
  -------------------------------------------------
  -- Validate_Attributes for: TAX_CURRENCY_CODE --
  -------------------------------------------------
  PROCEDURE validate_tax_curr_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_tx_cur_cd_fk_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
      FROM fnd_currencies
      WHERE fnd_currencies.currency_code = p_code;
  BEGIN

    IF (p_ttdv_rec.tax_currency_code <> OKL_API.G_MISS_CHAR AND  p_ttdv_rec.tax_currency_code IS NOT NULL)
    THEN
        OPEN   okl_ttdv_tx_cur_cd_fk_csr(p_ttdv_rec.tax_currency_code)  ;
        FETCH  okl_ttdv_tx_cur_cd_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_tx_cur_cd_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_currency_code',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'FND_CURRENCIES');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_curr_code;
  -------------------------------------------------
  -- Validate_Attributes for: TRX_CURRENCY_CODE --
  -------------------------------------------------
  PROCEDURE validate_trx_curr_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ttdv_rec                     IN ttdv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_ttdv_trx_cur_cd_fk_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
      FROM fnd_currencies
      WHERE fnd_currencies.currency_code = p_code;
  BEGIN

    IF (p_ttdv_rec.trx_currency_code <> OKL_API.G_MISS_CHAR AND  p_ttdv_rec.trx_currency_code IS NOT NULL)
    THEN
        OPEN   okl_ttdv_trx_cur_cd_fk_csr(p_ttdv_rec.trx_currency_code)  ;
        FETCH  okl_ttdv_trx_cur_cd_fk_csr into l_dummy_var ;
        CLOSE  okl_ttdv_trx_cur_cd_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'trx_currency_code',
                        g_child_table_token ,
                        'OKL_TAX_TRX_DETAILS',
                        g_parent_table_token ,
                        'FND_CURRENCIES');
            l_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_trx_curr_code;

  -- Modified by dcshanmu for eBTax - modification end

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_TAX_TRX_DETAILS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ttdv_rec    IN ttdv_rec_type
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
    validate_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- Modified by dcshanmu for eBTax - modification starts
    -- calling validation methods for newly added columns in table
    -- ***
    -- txs_id
    -- ***
    validate_txs_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_call_type_code
    -- ***
    validate_tax_call_type_code(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_rate_id
    -- ***
    validate_tax_rate_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_rate_code
    -- ***
    validate_tax_rate_code(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_exemption_id
    -- ***
    validate_tax_exemption_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- internal_organization_id
    -- ***
    validate_int_org_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- application_id
    -- ***
    validate_application_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- entity_code
    -- ***
    validate_entity_code(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- event_class_code
    -- ***
    validate_event_class_code(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- event_type_code
    -- ***
    validate_event_type_code(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- trx_id
    -- ***
    validate_trx_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- trx_line_id
    -- ***
    validate_trx_line_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- trx_level_type
    -- ***
    validate_trx_level_type(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_line_number
    -- ***
    validate_tax_line_number(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_regime_id
    -- ***
    validate_tax_regime_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_regime_code
    -- ***
    validate_tax_regime_code(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_id
    -- ***
    validate_tax_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_status_id
    -- ***
    validate_tax_status_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_juris_id
    -- ***
    validate_tax_juris_id(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_currency_code
    -- ***
    validate_tax_curr_code(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- trx_currency_code
    -- ***
    validate_trx_curr_code(l_return_status, p_ttdv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
    -- Modified by dcshanmu for eBTax - modification end

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
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  /*-----------------------------------------------
  -- Validate Record for:OKL_TAX_TRX_DETAILS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_ttdv_rec IN ttdv_rec_type,
    p_db_okl_tax_trx_details_v_rec IN ttdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_ttdv_rec IN ttdv_rec_type,
      p_db_okl_tax_trx_details_v_rec IN ttdv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;

      CURSOR okl_ttdv_tax_call_t1 (p_lookup_code IN VARCHAR2) IS
      SELECT 'x'
        FROM Fnd_Lookups
       WHERE fnd_lookups.lookup_code = p_lookup_code;
      l_okl_ttdv_tax_call_type_code  okl_ttdv_tax_call_t1%ROWTYPE;

      CURSOR okl_ttdv_txs_id_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_Tax_Sources
       WHERE okl_tax_sources.id   = p_id;
      l_okl_ttdv_txs_id              okl_ttdv_txs_id_csr%ROWTYPE;

    CURSOR okl_ttdv_tri_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_rates_b
      WHERE zx_rates_b.tax_rate_id = p_id;
     l_okl_ttdv_tri			okl_ttdv_tri_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_trc_fk_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
      FROM zx_rates_b
      WHERE zx_rates_b.tax_rate_code = p_code;
     l_okl_ttdv_trc			okl_ttdv_trc_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_tei_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_exemptions
      WHERE zx_exemptions.tax_exemption_id = p_id;
     l_okl_ttdv_tei			okl_ttdv_tei_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_ioi_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM hr_all_organization_units
      WHERE hr_all_organization_units.organization_id = p_id;
     l_okl_ttdv_ioi			okl_ttdv_ioi_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_app_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM fnd_application
      WHERE fnd_application.application_id = p_id;
     l_okl_ttdv_app_id		okl_ttdv_app_id_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_tx_reg_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_regimes_b
      WHERE zx_regimes_b.tax_regime_id = p_id;
     l_okl_ttdv_tx_reg_id	okl_ttdv_tx_reg_id_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_tx_reg_cd_fk_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
      FROM zx_regimes_b
      WHERE zx_regimes_b.tax_regime_code = p_code;
     l_okl_ttdv_tx_reg_cd	okl_ttdv_tx_reg_cd_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_tx_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_taxes_b
      WHERE zx_taxes_b.tax_id = p_id;
     l_okl_ttdv_tx_id		okl_ttdv_tx_id_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_tx_st_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_status_b
      WHERE zx_status_b.tax_status_id = p_id;
     l_okl_ttdv_tx_st_id		okl_ttdv_tx_st_id_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_tx_jur_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM zx_jurisdictions_b
      WHERE zx_jurisdictions_b.tax_jurisdiction_id = p_id;
     l_okl_ttdv_tx_jur_id	okl_ttdv_tx_jur_id_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_tx_cur_cd_fk_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
      FROM fnd_currencies
      WHERE fnd_currencies.currency_code = p_code;
     l_okl_ttdv_tx_cur_cd	okl_ttdv_tx_cur_cd_fk_csr%ROWTYPE;

    CURSOR okl_ttdv_trx_cur_cd_fk_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
      FROM fnd_currencies
      WHERE fnd_currencies.currency_code = p_code;
     l_okl_ttdv_trx_cur_cd_fk_csr	okl_ttdv_trx_cur_cd_fk_csr%ROWTYPE;


      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN

      IF ((p_ttdv_rec.TXS_ID IS NOT NULL)
       AND
          (p_ttdv_rec.TXS_ID <> p_db_okl_tax_trx_details_v_rec.TXS_ID))
      THEN
        OPEN okl_ttdv_txs_id_csr (p_ttdv_rec.TXS_ID);
        FETCH okl_ttdv_txs_id_csr INTO l_okl_ttdv_txs_id;
        l_row_notfound := okl_ttdv_txs_id_csr%NOTFOUND;
        CLOSE okl_ttdv_txs_id_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TXS_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_CALL_TYPE_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_CALL_TYPE_CODE <> p_db_okl_tax_trx_details_v_rec.TAX_CALL_TYPE_CODE))
      THEN
        OPEN okl_ttdv_tax_call_t1 (p_ttdv_rec.TAX_CALL_TYPE_CODE);
        FETCH okl_ttdv_tax_call_t1 INTO l_okl_ttdv_tax_call_type_code;
        l_row_notfound := okl_ttdv_tax_call_t1%NOTFOUND;
        CLOSE okl_ttdv_tax_call_t1;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_CALL_TYPE_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_RATE_ID IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_RATE_ID <> p_db_okl_tax_trx_details_v_rec.TAX_RATE_ID))
      THEN
        OPEN okl_ttdv_tri_fk_csr (p_ttdv_rec.TAX_RATE_ID);
        FETCH okl_ttdv_tri_fk_csr INTO l_okl_ttdv_tri;
        l_row_notfound := okl_ttdv_tri_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_tri_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_RATE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_RATE_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_RATE_CODE <> p_db_okl_tax_trx_details_v_rec.TAX_RATE_CODE))
      THEN
        OPEN okl_ttdv_trc_fk_csr (p_ttdv_rec.TAX_RATE_CODE);
        FETCH okl_ttdv_trc_fk_csr INTO l_okl_ttdv_trc;
        l_row_notfound := okl_ttdv_trc_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_trc_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_RATE_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_EXEMPTION_ID IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_EXEMPTION_ID <> p_db_okl_tax_trx_details_v_rec.TAX_EXEMPTION_ID))
      THEN
        OPEN okl_ttdv_tei_fk_csr (p_ttdv_rec.TAX_EXEMPTION_ID);
        FETCH okl_ttdv_tei_fk_csr INTO l_okl_ttdv_tei;
        l_row_notfound := okl_ttdv_tei_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_tei_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_EXEMPTION_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.INTERNAL_ORGANIZATION_ID IS NOT NULL)
       AND
          (p_ttdv_rec.INTERNAL_ORGANIZATION_ID <> p_db_okl_tax_trx_details_v_rec.INTERNAL_ORGANIZATION_ID))
      THEN
        OPEN okl_ttdv_ioi_fk_csr (p_ttdv_rec.INTERNAL_ORGANIZATION_ID);
        FETCH okl_ttdv_ioi_fk_csr INTO l_okl_ttdv_ioi;
        l_row_notfound := okl_ttdv_ioi_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_ioi_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'INTERNAL_ORGANIZATION_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.APPLICATION_ID IS NOT NULL)
       AND
          (p_ttdv_rec.APPLICATION_ID <> p_db_okl_tax_trx_details_v_rec.APPLICATION_ID))
      THEN
        OPEN okl_ttdv_app_id_fk_csr (p_ttdv_rec.APPLICATION_ID);
        FETCH okl_ttdv_app_id_fk_csr INTO l_okl_ttdv_app_id;
        l_row_notfound := okl_ttdv_app_id_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_app_id_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'APPLICATION_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_REGIME_ID IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_REGIME_ID <> p_db_okl_tax_trx_details_v_rec.TAX_REGIME_ID))
      THEN
        OPEN okl_ttdv_tx_reg_id_fk_csr (p_ttdv_rec.TAX_REGIME_ID);
        FETCH okl_ttdv_tx_reg_id_fk_csr INTO l_okl_ttdv_tx_reg_id;
        l_row_notfound := okl_ttdv_tx_reg_id_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_tx_reg_id_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_REGIME_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_REGIME_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_REGIME_CODE <> p_db_okl_tax_trx_details_v_rec.TAX_REGIME_CODE))
      THEN
        OPEN okl_ttdv_tx_reg_cd_fk_csr (p_ttdv_rec.TAX_REGIME_CODE);
        FETCH okl_ttdv_tx_reg_cd_fk_csr INTO l_okl_ttdv_tx_reg_cd;
        l_row_notfound := okl_ttdv_tx_reg_cd_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_tx_reg_cd_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_REGIME_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_ID IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_ID <> p_db_okl_tax_trx_details_v_rec.TAX_ID))
      THEN
        OPEN okl_ttdv_tx_id_fk_csr (p_ttdv_rec.TAX_ID);
        FETCH okl_ttdv_tx_id_fk_csr INTO l_okl_ttdv_tx_id;
        l_row_notfound := okl_ttdv_tx_id_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_tx_id_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_STATUS_ID IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_STATUS_ID <> p_db_okl_tax_trx_details_v_rec.TAX_STATUS_ID))
      THEN
        OPEN okl_ttdv_tx_st_id_fk_csr (p_ttdv_rec.TAX_STATUS_ID);
        FETCH okl_ttdv_tx_st_id_fk_csr INTO l_okl_ttdv_tx_st_id;
        l_row_notfound := okl_ttdv_tx_st_id_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_tx_st_id_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_STATUS_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_JURISDICTION_ID IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_JURISDICTION_ID <> p_db_okl_tax_trx_details_v_rec.TAX_JURISDICTION_ID))
      THEN
        OPEN okl_ttdv_tx_jur_id_fk_csr (p_ttdv_rec.TAX_JURISDICTION_ID);
        FETCH okl_ttdv_tx_jur_id_fk_csr INTO l_okl_ttdv_tx_jur_id;
        l_row_notfound := okl_ttdv_tx_jur_id_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_tx_jur_id_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_JURISDICTION_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_CURRENCY_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_CURRENCY_CODE <> p_db_okl_tax_trx_details_v_rec.TAX_CURRENCY_CODE))
      THEN
        OPEN okl_ttdv_tx_cur_cd_fk_csr (p_ttdv_rec.TAX_CURRENCY_CODE);
        FETCH okl_ttdv_tx_cur_cd_fk_csr INTO l_okl_ttdv_tx_cur_cd;
        l_row_notfound := okl_ttdv_tx_cur_cd_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_tx_cur_cd_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_CURRENCY_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TRX_CURRENCY_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.TRX_CURRENCY_CODE <> p_db_okl_tax_trx_details_v_rec.TRX_CURRENCY_CODE))
      THEN
        OPEN okl_ttdv_trx_cur_cd_fk_csr (p_ttdv_rec.TRX_CURRENCY_CODE);
        FETCH okl_ttdv_trx_cur_cd_fk_csr INTO l_okl_ttdv_trx_cur_cd;
        l_row_notfound := okl_ttdv_trx_cur_cd_fk_csr%NOTFOUND;
        CLOSE okl_ttdv_trx_cur_cd_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TRX_CURRENCY_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys(p_ttdv_rec, p_db_okl_tax_trx_details_v_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_ttdv_rec IN ttdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_okl_tax_trx_details_v_rec ttdv_rec_type := get_rec(p_ttdv_rec);
  BEGIN
    l_return_status := Validate_Record(p_ttdv_rec => p_ttdv_rec,
                                       p_db_okl_tax_trx_details_v_rec => l_db_okl_tax_trx_details_v_rec);
    RETURN (l_return_status);
  END Validate_Record;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN ttdv_rec_type,
    p_to   IN OUT NOCOPY ttd_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.txs_id := p_from.txs_id;
    p_to.tax_determine_date := p_from.tax_determine_date;
    p_to.tax_rate_id := p_from.tax_rate_id;
    p_to.tax_rate_code := p_from.tax_rate_code;
    p_to.taxable_amt := p_from.taxable_amt;
    p_to.tax_exemption_id := p_from.tax_exemption_id;
    p_to.tax_rate := p_from.tax_rate;
    p_to.tax_amt := p_from.tax_amt;
    p_to.billed_yn := p_from.billed_yn;
    p_to.tax_call_type_code := p_from.tax_call_type_code;
    p_to.program_id := p_from.program_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
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
    p_to.object_version_number := p_from.object_version_number;
    -- Modified by dcshanmu for eBTax - modification starts
    p_to.tax_date := p_from.tax_date;
    p_to.line_amt := p_from.line_amt;
    p_to.internal_organization_id := p_from.internal_organization_id;
    p_to.application_id := p_from.application_id;
    p_to.entity_code := p_from.entity_code;
    p_to.event_class_code := p_from.event_class_code;
    p_to.event_type_code := p_from.event_type_code;
    p_to.trx_id := p_from.trx_id;
    p_to.trx_line_id := p_from.trx_line_id;
    p_to.trx_level_type := p_from.trx_level_type;
    p_to.trx_line_number := p_from.trx_line_number;
    p_to.tax_line_number := p_from.tax_line_number;
    p_to.tax_regime_id := p_from.tax_regime_id;
    p_to.tax_regime_code := p_from.tax_regime_code;
    p_to.tax_id := p_from.tax_id;
    p_to.tax := p_from.tax;
    p_to.tax_status_id := p_from.tax_status_id;
    p_to.tax_status_code := p_from.tax_status_code;
    p_to.tax_apportionment_line_number := p_from.tax_apportionment_line_number;
    p_to.legal_entity_id := p_from.legal_entity_id;
    p_to.trx_number := p_from.trx_number;
    p_to.trx_date := p_from.trx_date;
    p_to.tax_jurisdiction_id := p_from.tax_jurisdiction_id;
    p_to.tax_jurisdiction_code := p_from.tax_jurisdiction_code;
    p_to.tax_type_code := p_from.tax_type_code;
    p_to.tax_currency_code := p_from.tax_currency_code;
    p_to.taxable_amt_tax_curr := p_from.taxable_amt_tax_curr;
    p_to.trx_currency_code := p_from.trx_currency_code;
    p_to.minimum_accountable_unit := p_from.minimum_accountable_unit;
    p_to.precision := p_from.precision;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    -- Modified by dcshanmu for eBTax - modification end

  END migrate;
  PROCEDURE migrate (
    p_from IN ttd_rec_type,
    p_to   IN OUT NOCOPY ttdv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.txs_id := p_from.txs_id;
    p_to.tax_determine_date := p_from.tax_determine_date;
    p_to.tax_rate_id := p_from.tax_rate_id;
    p_to.tax_rate_code := p_from.tax_rate_code;
    p_to.taxable_amt := p_from.taxable_amt;
    p_to.tax_exemption_id := p_from.tax_exemption_id;
    p_to.tax_rate := p_from.tax_rate;
    p_to.tax_amt := p_from.tax_amt;
    p_to.billed_yn := p_from.billed_yn;
    p_to.tax_call_type_code := p_from.tax_call_type_code;
    p_to.program_id := p_from.program_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
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
    p_to.object_version_number := p_from.object_version_number;
    -- Modified by dcshanmu for eBTax - modification starts
    p_to.tax_date := p_from.tax_date;
    p_to.line_amt := p_from.line_amt;
    p_to.internal_organization_id := p_from.internal_organization_id;
    p_to.application_id := p_from.application_id;
    p_to.entity_code := p_from.entity_code;
    p_to.event_class_code := p_from.event_class_code;
    p_to.event_type_code := p_from.event_type_code;
    p_to.trx_id := p_from.trx_id;
    p_to.trx_line_id := p_from.trx_line_id;
    p_to.trx_level_type := p_from.trx_level_type;
    p_to.trx_line_number := p_from.trx_line_number;
    p_to.tax_line_number := p_from.tax_line_number;
    p_to.tax_regime_id := p_from.tax_regime_id;
    p_to.tax_regime_code := p_from.tax_regime_code;
    p_to.tax_id := p_from.tax_id;
    p_to.tax := p_from.tax;
    p_to.tax_status_id := p_from.tax_status_id;
    p_to.tax_status_code := p_from.tax_status_code;
    p_to.tax_apportionment_line_number := p_from.tax_apportionment_line_number;
    p_to.legal_entity_id := p_from.legal_entity_id;
    p_to.trx_number := p_from.trx_number;
    p_to.trx_date := p_from.trx_date;
    p_to.tax_jurisdiction_id := p_from.tax_jurisdiction_id;
    p_to.tax_jurisdiction_code := p_from.tax_jurisdiction_code;
    p_to.tax_type_code := p_from.tax_type_code;
    p_to.tax_currency_code := p_from.tax_currency_code;
    p_to.taxable_amt_tax_curr := p_from.taxable_amt_tax_curr;
    p_to.trx_currency_code := p_from.trx_currency_code;
    p_to.minimum_accountable_unit := p_from.minimum_accountable_unit;
    p_to.precision := p_from.precision;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    -- Modified by dcshanmu for eBTax - modification end

  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_TAX_TRX_DETAILS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_rec    IN ttdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ttdv_rec    ttdv_rec_type := p_ttdv_rec;
    l_ttd_rec                      ttd_rec_type;
    l_ttd_rec                      ttd_rec_type;
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
    l_return_status := Validate_Attributes(l_ttdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*l_return_status := Validate_Record(l_ttdv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    */

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
  -- PL/SQL TBL validate_row for:OKL_TAX_TRX_DETAILS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ttdv_tbl.COUNT > 0) THEN
      i := p_ttdv_tbl.FIRST;
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
            p_ttdv_rec    => p_ttdv_tbl(i));
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
        EXIT WHEN (i = p_ttdv_tbl.LAST);
        i := p_ttdv_tbl.NEXT(i);
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
  -- PL/SQL TBL validate_row for:OKL_TAX_TRX_DETAILS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    IN ttdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ttdv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ttdv_tbl    => p_ttdv_tbl,
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
  -- insert_row for:OKL_TAX_TRX_DETAILS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttd_rec                      IN ttd_rec_type,
    x_ttd_rec                      OUT NOCOPY ttd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ttd_rec                      ttd_rec_type := p_ttd_rec;
    l_def_ttd_rec                  ttd_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_TAX_TRX_DETAILS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ttd_rec IN ttd_rec_type,
      x_ttd_rec OUT NOCOPY ttd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ttd_rec := p_ttd_rec;
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
      p_ttd_rec,                         -- IN
      l_ttd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TAX_TRX_DETAILS(
      id,
      txs_id,
      tax_determine_date,
      tax_rate_id,
      tax_rate_code,
      taxable_amt,
      tax_exemption_id,
      tax_rate,
      tax_amt,
      billed_yn,
      tax_call_type_code,
      program_id,
      request_id,
      program_application_id,
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
      last_update_login,
      object_version_number,
      -- Modified by dcshanmu for eBTax - modification starts
      tax_date,
      line_amt,
      internal_organization_id,
      application_id,
      entity_code,
      event_class_code,
      event_type_code,
      trx_id,
      trx_line_id,
      trx_level_type,
      trx_line_number,
      tax_line_number,
      tax_regime_id,
      tax_regime_code,
      tax_id,
      tax,
      tax_status_id,
      tax_status_code,
      tax_apportionment_line_number,
      legal_entity_id,
      trx_number,
      trx_date,
      tax_jurisdiction_id,
      tax_jurisdiction_code,
      tax_type_code,
      tax_currency_code,
      taxable_amt_tax_curr,
      trx_currency_code,
      minimum_accountable_unit,
      precision,
      currency_conversion_type,
      currency_conversion_rate,
      currency_conversion_date)
      -- Modified by dcshanmu for eBTax - modification end
    VALUES (
      l_ttd_rec.id,
      l_ttd_rec.txs_id,
      l_ttd_rec.tax_determine_date,
      l_ttd_rec.tax_rate_id,
      l_ttd_rec.tax_rate_code,
      l_ttd_rec.taxable_amt,
      l_ttd_rec.tax_exemption_id,
      l_ttd_rec.tax_rate,
      l_ttd_rec.tax_amt,
      l_ttd_rec.billed_yn,
      l_ttd_rec.tax_call_type_code,
      l_ttd_rec.program_id,
      l_ttd_rec.request_id,
      l_ttd_rec.program_application_id,
      l_ttd_rec.program_update_date,
      l_ttd_rec.attribute_category,
      l_ttd_rec.attribute1,
      l_ttd_rec.attribute2,
      l_ttd_rec.attribute3,
      l_ttd_rec.attribute4,
      l_ttd_rec.attribute5,
      l_ttd_rec.attribute6,
      l_ttd_rec.attribute7,
      l_ttd_rec.attribute8,
      l_ttd_rec.attribute9,
      l_ttd_rec.attribute10,
      l_ttd_rec.attribute11,
      l_ttd_rec.attribute12,
      l_ttd_rec.attribute13,
      l_ttd_rec.attribute14,
      l_ttd_rec.attribute15,
      l_ttd_rec.created_by,
      l_ttd_rec.creation_date,
      l_ttd_rec.last_updated_by,
      l_ttd_rec.last_update_date,
      l_ttd_rec.last_update_login,
      l_ttd_rec.object_version_number,
      -- Modified by dcshanmu for eBTax - modification starts
      l_ttd_rec.tax_date,
      l_ttd_rec.line_amt,
      l_ttd_rec.internal_organization_id,
      l_ttd_rec.application_id,
      l_ttd_rec.entity_code,
      l_ttd_rec.event_class_code,
      l_ttd_rec.event_type_code,
      l_ttd_rec.trx_id,
      l_ttd_rec.trx_line_id,
      l_ttd_rec.trx_level_type,
      l_ttd_rec.trx_line_number,
      l_ttd_rec.tax_line_number,
      l_ttd_rec.tax_regime_id,
      l_ttd_rec.tax_regime_code,
      l_ttd_rec.tax_id,
      l_ttd_rec.tax,
      l_ttd_rec.tax_status_id,
      l_ttd_rec.tax_status_code,
      l_ttd_rec.tax_apportionment_line_number,
      l_ttd_rec.legal_entity_id,
      l_ttd_rec.trx_number,
      l_ttd_rec.trx_date,
      l_ttd_rec.tax_jurisdiction_id,
      l_ttd_rec.tax_jurisdiction_code,
      l_ttd_rec.tax_type_code,
      l_ttd_rec.tax_currency_code,
      l_ttd_rec.taxable_amt_tax_curr,
      l_ttd_rec.trx_currency_code,
      l_ttd_rec.minimum_accountable_unit,
      l_ttd_rec.precision,
      l_ttd_rec.currency_conversion_type,
      l_ttd_rec.currency_conversion_rate,
      l_ttd_rec.currency_conversion_date);
      -- Modified by dcshanmu for eBTax - modification end
    -- Set OUT values
    x_ttd_rec := l_ttd_rec;
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
  -- insert_row for :OKL_TAX_TRX_DETAILS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_rec    				   IN ttdv_rec_type,
    x_ttdv_rec    				   OUT NOCOPY ttdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ttdv_rec    ttdv_rec_type := p_ttdv_rec;
    LDefOklTaxTrxDetailsVRec       ttdv_rec_type;
    l_ttd_rec                      ttd_rec_type;
    lx_ttd_rec                     ttd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ttdv_rec IN ttdv_rec_type
    ) RETURN ttdv_rec_type IS
      l_ttdv_rec ttdv_rec_type := p_ttdv_rec;
    BEGIN
      l_ttdv_rec.CREATION_DATE := SYSDATE;
      l_ttdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ttdv_rec.LAST_UPDATE_DATE := l_ttdv_rec.CREATION_DATE;
      l_ttdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ttdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ttdv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TAX_TRX_DETAILS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ttdv_rec IN ttdv_rec_type,
      x_ttdv_rec OUT NOCOPY ttdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ttdv_rec := p_ttdv_rec;
      x_ttdv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_ttdv_rec := null_out_defaults(p_ttdv_rec);
    -- Set primary key value
    l_ttdv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_ttdv_rec,       -- IN
      LDefOklTaxTrxDetailsVRec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    LDefOklTaxTrxDetailsVRec := fill_who_columns(LDefOklTaxTrxDetailsVRec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(LDefOklTaxTrxDetailsVRec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    /*
    l_return_status := Validate_Record(LDefOklTaxTrxDetailsVRec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    */
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(LDefOklTaxTrxDetailsVRec, l_ttd_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ttd_rec,
      lx_ttd_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ttd_rec, LDefOklTaxTrxDetailsVRec);
    -- Set OUT values
    x_ttdv_rec := LDefOklTaxTrxDetailsVRec;
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
  ---------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKL_TAX_TRX_DETAILS_V_TBL --
  ---------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type,
    x_ttdv_tbl                     OUT NOCOPY ttdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ttdv_tbl.COUNT > 0) THEN
      i := p_ttdv_tbl.FIRST;
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
            p_ttdv_rec    => p_ttdv_tbl(i),
            x_ttdv_rec    => x_ttdv_tbl(i));
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
        EXIT WHEN (i = p_ttdv_tbl.LAST);
        i := p_ttdv_tbl.NEXT(i);
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

  ---------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKL_TAX_TRX_DETAILS_V_TBL --
  ---------------------------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    IN ttdv_tbl_type,
    x_ttdv_tbl    OUT NOCOPY ttdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ttdv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ttdv_tbl    => p_ttdv_tbl,
        x_ttdv_tbl    => x_ttdv_tbl,
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
  -- lock_row for:OKL_TAX_TRX_DETAILS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttd_rec                      IN ttd_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ttd_rec IN ttd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TAX_TRX_DETAILS
     WHERE ID = p_ttd_rec.id
       AND OBJECT_VERSION_NUMBER = p_ttd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_ttd_rec IN ttd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TAX_TRX_DETAILS
     WHERE ID = p_ttd_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_TAX_TRX_DETAILS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_TAX_TRX_DETAILS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ttd_rec);
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
      OPEN lchk_csr(p_ttd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ttd_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ttd_rec.object_version_number THEN
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
  -- lock_row for: OKL_TAX_TRX_DETAILS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_rec    IN ttdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ttd_rec                      ttd_rec_type;
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
    migrate(p_ttdv_rec, l_ttd_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ttd_rec
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
  -------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKL_TAX_TRX_DETAILS_V_TBL --
  -------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    IN ttdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_ttdv_tbl.COUNT > 0) THEN
      i := p_ttdv_tbl.FIRST;
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
            p_ttdv_rec    => p_ttdv_tbl(i));
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
        EXIT WHEN (i = p_ttdv_tbl.LAST);
        i := p_ttdv_tbl.NEXT(i);
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
  -------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKL_TAX_TRX_DETAILS_V_TBL --
  -------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    IN ttdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_ttdv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ttdv_tbl    => p_ttdv_tbl,
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
  -- update_row for:OKL_TAX_TRX_DETAILS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttd_rec                      IN ttd_rec_type,
    x_ttd_rec                      OUT NOCOPY ttd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ttd_rec                      ttd_rec_type := p_ttd_rec;
    l_def_ttd_rec                  ttd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ttd_rec IN ttd_rec_type,
      x_ttd_rec OUT NOCOPY ttd_rec_type
    ) RETURN VARCHAR2 IS
      l_ttd_rec                      ttd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ttd_rec := p_ttd_rec;
      -- Get current database values
      l_ttd_rec := get_rec(p_ttd_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_ttd_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.id := l_ttd_rec.id;
        END IF;
        IF (x_ttd_rec.txs_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.txs_id := l_ttd_rec.txs_id;
        END IF;
        IF (x_ttd_rec.tax_determine_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttd_rec.tax_determine_date := l_ttd_rec.tax_determine_date;
        END IF;
        IF (x_ttd_rec.tax_rate_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.tax_rate_id := l_ttd_rec.tax_rate_id;
        END IF;
        IF (x_ttd_rec.tax_rate_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.tax_rate_code := l_ttd_rec.tax_rate_code;
        END IF;
        IF (x_ttd_rec.taxable_amt = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.taxable_amt := l_ttd_rec.taxable_amt;
        END IF;
        IF (x_ttd_rec.tax_exemption_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.tax_exemption_id := l_ttd_rec.tax_exemption_id;
        END IF;
        IF (x_ttd_rec.tax_rate = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.tax_rate := l_ttd_rec.tax_rate;
        END IF;
        IF (x_ttd_rec.tax_amt = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.tax_amt := l_ttd_rec.tax_amt;
        END IF;
        IF (x_ttd_rec.billed_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.billed_yn := l_ttd_rec.billed_yn;
        END IF;
        IF (x_ttd_rec.tax_call_type_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.tax_call_type_code := l_ttd_rec.tax_call_type_code;
        END IF;
        IF (x_ttd_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.program_id := l_ttd_rec.program_id;
        END IF;
        IF (x_ttd_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.request_id := l_ttd_rec.request_id;
        END IF;
        IF (x_ttd_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.program_application_id := l_ttd_rec.program_application_id;
        END IF;
        IF (x_ttd_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttd_rec.program_update_date := l_ttd_rec.program_update_date;
        END IF;
        IF (x_ttd_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute_category := l_ttd_rec.attribute_category;
        END IF;
        IF (x_ttd_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute1 := l_ttd_rec.attribute1;
        END IF;
        IF (x_ttd_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute2 := l_ttd_rec.attribute2;
        END IF;
        IF (x_ttd_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute3 := l_ttd_rec.attribute3;
        END IF;
        IF (x_ttd_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute4 := l_ttd_rec.attribute4;
        END IF;
        IF (x_ttd_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute5 := l_ttd_rec.attribute5;
        END IF;
        IF (x_ttd_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute6 := l_ttd_rec.attribute6;
        END IF;
        IF (x_ttd_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute7 := l_ttd_rec.attribute7;
        END IF;
        IF (x_ttd_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute8 := l_ttd_rec.attribute8;
        END IF;
        IF (x_ttd_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute9 := l_ttd_rec.attribute9;
        END IF;
        IF (x_ttd_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute10 := l_ttd_rec.attribute10;
        END IF;
        IF (x_ttd_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute11 := l_ttd_rec.attribute11;
        END IF;
        IF (x_ttd_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute12 := l_ttd_rec.attribute12;
        END IF;
        IF (x_ttd_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute13 := l_ttd_rec.attribute13;
        END IF;
        IF (x_ttd_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute14 := l_ttd_rec.attribute14;
        END IF;
        IF (x_ttd_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.attribute15 := l_ttd_rec.attribute15;
        END IF;
        IF (x_ttd_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.created_by := l_ttd_rec.created_by;
        END IF;
        IF (x_ttd_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttd_rec.creation_date := l_ttd_rec.creation_date;
        END IF;
        IF (x_ttd_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.last_updated_by := l_ttd_rec.last_updated_by;
        END IF;
        IF (x_ttd_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttd_rec.last_update_date := l_ttd_rec.last_update_date;
        END IF;
        IF (x_ttd_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.last_update_login := l_ttd_rec.last_update_login;
        END IF;
        IF (x_ttd_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.object_version_number := l_ttd_rec.object_version_number;
        END IF;

	-- Modified by dcshanmu for eBTax - modification starts
	-- migrating values for the newly added columns in table

	IF (x_ttd_rec.tax_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttd_rec.tax_date := l_ttd_rec.tax_date;
        END IF;
	IF (x_ttd_rec.line_amt = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.line_amt := l_ttd_rec.line_amt;
        END IF;
	IF (x_ttd_rec.internal_organization_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.internal_organization_id := l_ttd_rec.internal_organization_id;
        END IF;
	IF (x_ttd_rec.application_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.application_id := l_ttd_rec.application_id;
        END IF;
	IF (x_ttd_rec.entity_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.entity_code := l_ttd_rec.entity_code;
        END IF;
	IF (x_ttd_rec.event_class_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.event_class_code := l_ttd_rec.event_class_code;
        END IF;
	IF (x_ttd_rec.event_type_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.event_type_code := l_ttd_rec.event_type_code;
        END IF;
	IF (x_ttd_rec.trx_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.trx_id := l_ttd_rec.trx_id;
        END IF;
	IF (x_ttd_rec.trx_line_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.trx_line_id := l_ttd_rec.trx_line_id;
        END IF;
	IF (x_ttd_rec.trx_level_type = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.trx_level_type := l_ttd_rec.trx_level_type;
        END IF;
	IF (x_ttd_rec.trx_line_number = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.trx_line_number := l_ttd_rec.trx_line_number;
        END IF;
	IF (x_ttd_rec.tax_line_number = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.tax_line_number := l_ttd_rec.tax_line_number;
        END IF;
	IF (x_ttd_rec.tax_regime_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.tax_regime_id := l_ttd_rec.tax_regime_id;
        END IF;
	IF (x_ttd_rec.tax_regime_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.tax_regime_code := l_ttd_rec.tax_regime_code;
        END IF;
	IF (x_ttd_rec.tax_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.tax_id := l_ttd_rec.tax_id;
        END IF;
	IF (x_ttd_rec.tax = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.tax := l_ttd_rec.tax;
        END IF;
	IF (x_ttd_rec.tax_status_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.tax_status_id := l_ttd_rec.tax_status_id;
        END IF;
	IF (x_ttd_rec.tax_status_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.tax_status_code := l_ttd_rec.tax_status_code;
        END IF;
	IF (x_ttd_rec.tax_apportionment_line_number = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.tax_apportionment_line_number := l_ttd_rec.tax_apportionment_line_number;
        END IF;
	IF (x_ttd_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.legal_entity_id := l_ttd_rec.legal_entity_id;
        END IF;
	IF (x_ttd_rec.trx_number = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.trx_number := l_ttd_rec.trx_number;
        END IF;
	IF (x_ttd_rec.trx_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttd_rec.trx_date := l_ttd_rec.trx_date;
        END IF;
	IF (x_ttd_rec.tax_jurisdiction_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.tax_jurisdiction_id := l_ttd_rec.tax_jurisdiction_id;
        END IF;
	IF (x_ttd_rec.tax_jurisdiction_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.tax_jurisdiction_code := l_ttd_rec.tax_jurisdiction_code;
        END IF;
	IF (x_ttd_rec.tax_type_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.tax_type_code := l_ttd_rec.tax_type_code;
        END IF;
	IF (x_ttd_rec.tax_currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.tax_currency_code := l_ttd_rec.tax_currency_code;
        END IF;
	IF (x_ttd_rec.taxable_amt_tax_curr = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.taxable_amt_tax_curr := l_ttd_rec.taxable_amt_tax_curr;
        END IF;
	IF (x_ttd_rec.trx_currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.trx_currency_code := l_ttd_rec.trx_currency_code;
        END IF;
	IF (x_ttd_rec.minimum_accountable_unit = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.minimum_accountable_unit := l_ttd_rec.minimum_accountable_unit;
        END IF;
	IF (x_ttd_rec.precision = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.precision := l_ttd_rec.precision;
        END IF;
	IF (x_ttd_rec.currency_conversion_type = OKL_API.G_MISS_CHAR)
        THEN
          x_ttd_rec.currency_conversion_type := l_ttd_rec.currency_conversion_type;
        END IF;
	IF (x_ttd_rec.currency_conversion_rate = OKL_API.G_MISS_NUM)
        THEN
          x_ttd_rec.currency_conversion_rate := l_ttd_rec.currency_conversion_rate;
        END IF;
	IF (x_ttd_rec.currency_conversion_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttd_rec.currency_conversion_date := l_ttd_rec.currency_conversion_date;
        END IF;
	-- Modified by dcshanmu for eBTax - modification end

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TAX_TRX_DETAILS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ttd_rec IN ttd_rec_type,
      x_ttd_rec OUT NOCOPY ttd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ttd_rec := p_ttd_rec;
      x_ttd_rec.OBJECT_VERSION_NUMBER := p_ttd_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_ttd_rec,                         -- IN
      l_ttd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ttd_rec, l_def_ttd_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_TAX_TRX_DETAILS
    SET TXS_ID = l_def_ttd_rec.txs_id,
        TAX_DETERMINE_DATE = l_def_ttd_rec.tax_determine_date,
        TAX_RATE_ID = l_def_ttd_rec.tax_rate_id,
        TAX_RATE_CODE = l_def_ttd_rec.tax_rate_code,
        TAXABLE_AMT = l_def_ttd_rec.taxable_amt,
        TAX_EXEMPTION_ID = l_def_ttd_rec.tax_exemption_id,
        TAX_RATE = l_def_ttd_rec.tax_rate,
        TAX_AMT = l_def_ttd_rec.tax_amt,
        BILLED_YN = l_def_ttd_rec.billed_yn,
        TAX_CALL_TYPE_CODE = l_def_ttd_rec.tax_call_type_code,
        PROGRAM_ID = l_def_ttd_rec.program_id,
        REQUEST_ID = l_def_ttd_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_ttd_rec.program_application_id,
        PROGRAM_UPDATE_DATE = l_def_ttd_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_ttd_rec.attribute_category,
        ATTRIBUTE1 = l_def_ttd_rec.attribute1,
        ATTRIBUTE2 = l_def_ttd_rec.attribute2,
        ATTRIBUTE3 = l_def_ttd_rec.attribute3,
        ATTRIBUTE4 = l_def_ttd_rec.attribute4,
        ATTRIBUTE5 = l_def_ttd_rec.attribute5,
        ATTRIBUTE6 = l_def_ttd_rec.attribute6,
        ATTRIBUTE7 = l_def_ttd_rec.attribute7,
        ATTRIBUTE8 = l_def_ttd_rec.attribute8,
        ATTRIBUTE9 = l_def_ttd_rec.attribute9,
        ATTRIBUTE10 = l_def_ttd_rec.attribute10,
        ATTRIBUTE11 = l_def_ttd_rec.attribute11,
        ATTRIBUTE12 = l_def_ttd_rec.attribute12,
        ATTRIBUTE13 = l_def_ttd_rec.attribute13,
        ATTRIBUTE14 = l_def_ttd_rec.attribute14,
        ATTRIBUTE15 = l_def_ttd_rec.attribute15,
        CREATED_BY = l_def_ttd_rec.created_by,
        CREATION_DATE = l_def_ttd_rec.creation_date,
        LAST_UPDATED_BY = l_def_ttd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ttd_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ttd_rec.last_update_login,
        OBJECT_VERSION_NUMBER = l_def_ttd_rec.object_version_number,
	-- Modified by dcshanmu for eBTax - modification starts
        TAX_DATE = l_def_ttd_rec.tax_date,
        LINE_AMT = l_def_ttd_rec.line_amt,
        INTERNAL_ORGANIZATION_ID = l_def_ttd_rec.internal_organization_id,
        APPLICATION_ID = l_def_ttd_rec.application_id,
        ENTITY_CODE = l_def_ttd_rec.entity_code,
        EVENT_CLASS_CODE = l_def_ttd_rec.event_class_code,
        EVENT_TYPE_CODE = l_def_ttd_rec.event_type_code,
        TRX_ID = l_def_ttd_rec.trx_id,
        TRX_LINE_ID = l_def_ttd_rec.trx_line_id,
        TRX_LEVEL_TYPE = l_def_ttd_rec.trx_level_type,
        TRX_LINE_NUMBER = l_def_ttd_rec.trx_line_number,
        TAX_LINE_NUMBER = l_def_ttd_rec.tax_line_number,
        TAX_REGIME_ID = l_def_ttd_rec.tax_regime_id,
        TAX_REGIME_CODE = l_def_ttd_rec.tax_regime_code,
        TAX_ID = l_def_ttd_rec.tax_id,
        TAX = l_def_ttd_rec.tax,
        TAX_STATUS_ID = l_def_ttd_rec.tax_status_id,
        TAX_STATUS_CODE = l_def_ttd_rec.tax_status_code,
        TAX_APPORTIONMENT_LINE_NUMBER = l_def_ttd_rec.tax_apportionment_line_number,
        LEGAL_ENTITY_ID = l_def_ttd_rec.legal_entity_id,
        TRX_NUMBER = l_def_ttd_rec.trx_number,
        TRX_DATE = l_def_ttd_rec.trx_date,
        TAX_JURISDICTION_ID = l_def_ttd_rec.tax_jurisdiction_id,
        TAX_JURISDICTION_CODE = l_def_ttd_rec.tax_jurisdiction_code,
        TAX_TYPE_CODE = l_def_ttd_rec.tax_type_code,
        TAX_CURRENCY_CODE = l_def_ttd_rec.tax_currency_code,
        TAXABLE_AMT_TAX_CURR = l_def_ttd_rec.taxable_amt_tax_curr,
        TRX_CURRENCY_CODE = l_def_ttd_rec.trx_currency_code,
        MINIMUM_ACCOUNTABLE_UNIT = l_def_ttd_rec.minimum_accountable_unit,
        PRECISION = l_def_ttd_rec.precision,
        CURRENCY_CONVERSION_TYPE = l_def_ttd_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_ttd_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_ttd_rec.currency_conversion_date
	-- Modified by dcshanmu for eBTax - modification end

    WHERE ID = l_def_ttd_rec.id;

    x_ttd_rec := l_ttd_rec;
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
  -- update_row for:OKL_TAX_TRX_DETAILS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_rec    				   IN ttdv_rec_type,
    x_ttdv_rec    					OUT NOCOPY ttdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ttdv_rec    				   ttdv_rec_type := p_ttdv_rec;
    LDefOklTaxTrxDetailsVRec       ttdv_rec_type;
    l_db_ttdv_rec 				   ttdv_rec_type;
    l_ttd_rec                      ttd_rec_type;
    lx_ttd_rec                     ttd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ttdv_rec IN ttdv_rec_type
    ) RETURN ttdv_rec_type IS
      l_ttdv_rec ttdv_rec_type := p_ttdv_rec;
    BEGIN
      l_ttdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ttdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ttdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ttdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ttdv_rec IN ttdv_rec_type,
      x_ttdv_rec OUT NOCOPY ttdv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ttdv_rec := p_ttdv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_ttdv_rec := get_rec(p_ttdv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_ttdv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.id := l_db_ttdv_rec.id;
        END IF;
        IF (x_ttdv_rec.txs_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.txs_id := l_db_ttdv_rec.txs_id;
        END IF;

        --SECHAWLA : Added code to set Object Version No. because of the locking issue
        IF (x_ttdv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.object_version_number := l_db_ttdv_rec.object_version_number;
        END IF;


        IF (x_ttdv_rec.tax_determine_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttdv_rec.tax_determine_date := l_db_ttdv_rec.tax_determine_date;
        END IF;
        IF (x_ttdv_rec.tax_rate_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.tax_rate_id := l_db_ttdv_rec.tax_rate_id;
        END IF;
        IF (x_ttdv_rec.tax_rate_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.tax_rate_code := l_db_ttdv_rec.tax_rate_code;
        END IF;
        IF (x_ttdv_rec.taxable_amt = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.taxable_amt := l_db_ttdv_rec.taxable_amt;
        END IF;
        IF (x_ttdv_rec.tax_exemption_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.tax_exemption_id := l_db_ttdv_rec.tax_exemption_id;
        END IF;
        IF (x_ttdv_rec.tax_rate = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.tax_rate := l_db_ttdv_rec.tax_rate;
        END IF;
        IF (x_ttdv_rec.tax_amt = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.tax_amt := l_db_ttdv_rec.tax_amt;
        END IF;
        IF (x_ttdv_rec.billed_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.billed_yn := l_db_ttdv_rec.billed_yn;
        END IF;
        IF (x_ttdv_rec.tax_call_type_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.tax_call_type_code := l_db_ttdv_rec.tax_call_type_code;
        END IF;
        IF (x_ttdv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.program_id := l_db_ttdv_rec.program_id;
        END IF;
        IF (x_ttdv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.request_id := l_db_ttdv_rec.request_id;
        END IF;
        IF (x_ttdv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.program_application_id := l_db_ttdv_rec.program_application_id;
        END IF;
        IF (x_ttdv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttdv_rec.program_update_date := l_db_ttdv_rec.program_update_date;
        END IF;
        IF (x_ttdv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute_category := l_db_ttdv_rec.attribute_category;
        END IF;
        IF (x_ttdv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute1 := l_db_ttdv_rec.attribute1;
        END IF;
        IF (x_ttdv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute2 := l_db_ttdv_rec.attribute2;
        END IF;
        IF (x_ttdv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute3 := l_db_ttdv_rec.attribute3;
        END IF;
        IF (x_ttdv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute4 := l_db_ttdv_rec.attribute4;
        END IF;
        IF (x_ttdv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute5 := l_db_ttdv_rec.attribute5;
        END IF;
        IF (x_ttdv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute6 := l_db_ttdv_rec.attribute6;
        END IF;
        IF (x_ttdv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute7 := l_db_ttdv_rec.attribute7;
        END IF;
        IF (x_ttdv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute8 := l_db_ttdv_rec.attribute8;
        END IF;
        IF (x_ttdv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute9 := l_db_ttdv_rec.attribute9;
        END IF;
        IF (x_ttdv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute10 := l_db_ttdv_rec.attribute10;
        END IF;
        IF (x_ttdv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute11 := l_db_ttdv_rec.attribute11;
        END IF;
        IF (x_ttdv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute12 := l_db_ttdv_rec.attribute12;
        END IF;
        IF (x_ttdv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute13 := l_db_ttdv_rec.attribute13;
        END IF;
        IF (x_ttdv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute14 := l_db_ttdv_rec.attribute14;
        END IF;
        IF (x_ttdv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.attribute15 := l_db_ttdv_rec.attribute15;
        END IF;
        IF (x_ttdv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.created_by := l_db_ttdv_rec.created_by;
        END IF;
        IF (x_ttdv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttdv_rec.creation_date := l_db_ttdv_rec.creation_date;
        END IF;
        IF (x_ttdv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.last_updated_by := l_db_ttdv_rec.last_updated_by;
        END IF;
        IF (x_ttdv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttdv_rec.last_update_date := l_db_ttdv_rec.last_update_date;
        END IF;
        IF (x_ttdv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.last_update_login := l_db_ttdv_rec.last_update_login;
        END IF;

	-- Modified by dcshanmu for eBTax - modification starts
        IF (x_ttdv_rec.tax_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttdv_rec.tax_date := l_ttdv_rec.tax_date;
        END IF;
        IF (x_ttdv_rec.line_amt = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.line_amt := l_ttdv_rec.line_amt;
        END IF;
        IF (x_ttdv_rec.internal_organization_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.internal_organization_id := l_ttdv_rec.internal_organization_id;
        END IF;
        IF (x_ttdv_rec.application_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.application_id := l_ttdv_rec.application_id;
        END IF;
        IF (x_ttdv_rec.entity_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.entity_code := l_ttdv_rec.entity_code;
        END IF;
        IF (x_ttdv_rec.event_class_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.event_class_code := l_ttdv_rec.event_class_code;
        END IF;
        IF (x_ttdv_rec.event_type_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.event_type_code := l_ttdv_rec.event_type_code;
        END IF;
        IF (x_ttdv_rec.trx_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.trx_id := l_ttdv_rec.trx_id;
        END IF;
        IF (x_ttdv_rec.trx_line_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.trx_line_id := l_ttdv_rec.trx_line_id;
        END IF;
        IF (x_ttdv_rec.trx_level_type = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.trx_level_type := l_ttdv_rec.trx_level_type;
        END IF;
        IF (x_ttdv_rec.trx_line_number = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.trx_line_number := l_ttdv_rec.trx_line_number;
        END IF;
        IF (x_ttdv_rec.tax_line_number = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.tax_line_number := l_ttdv_rec.tax_line_number;
        END IF;
        IF (x_ttdv_rec.tax_regime_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.tax_regime_id := l_ttdv_rec.tax_regime_id;
        END IF;
        IF (x_ttdv_rec.tax_regime_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.tax_regime_code := l_ttdv_rec.tax_regime_code;
        END IF;
        IF (x_ttdv_rec.tax_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.tax_id := l_ttdv_rec.tax_id;
        END IF;
        IF (x_ttdv_rec.tax = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.tax := l_ttdv_rec.tax;
        END IF;
        IF (x_ttdv_rec.tax_status_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.tax_status_id := l_ttdv_rec.tax_status_id;
        END IF;
        IF (x_ttdv_rec.tax_status_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.tax_status_code := l_ttdv_rec.tax_status_code;
        END IF;
        IF (x_ttdv_rec.tax_apportionment_line_number = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.tax_apportionment_line_number := l_ttdv_rec.tax_apportionment_line_number;
        END IF;
        IF (x_ttdv_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.legal_entity_id := l_ttdv_rec.legal_entity_id;
        END IF;
        IF (x_ttdv_rec.trx_number = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.trx_number := l_ttdv_rec.trx_number;
        END IF;
        IF (x_ttdv_rec.trx_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttdv_rec.trx_date := l_ttdv_rec.trx_date;
        END IF;
        IF (x_ttdv_rec.tax_jurisdiction_id = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.tax_jurisdiction_id := l_ttdv_rec.tax_jurisdiction_id;
        END IF;
        IF (x_ttdv_rec.tax_jurisdiction_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.tax_jurisdiction_code := l_ttdv_rec.tax_jurisdiction_code;
        END IF;
        IF (x_ttdv_rec.tax_type_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.tax_type_code := l_ttdv_rec.tax_type_code;
        END IF;
        IF (x_ttdv_rec.tax_currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.tax_currency_code := l_ttdv_rec.tax_currency_code;
        END IF;
        IF (x_ttdv_rec.taxable_amt_tax_curr = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.taxable_amt_tax_curr := l_ttdv_rec.taxable_amt_tax_curr;
        END IF;
        IF (x_ttdv_rec.trx_currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.trx_currency_code := l_ttdv_rec.trx_currency_code;
        END IF;
        IF (x_ttdv_rec.minimum_accountable_unit = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.minimum_accountable_unit := l_ttdv_rec.minimum_accountable_unit;
        END IF;
        IF (x_ttdv_rec.precision = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.precision := l_ttdv_rec.precision;
        END IF;
        IF (x_ttdv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR)
        THEN
          x_ttdv_rec.currency_conversion_type := l_ttdv_rec.currency_conversion_type;
        END IF;
        IF (x_ttdv_rec.currency_conversion_rate = OKL_API.G_MISS_NUM)
        THEN
          x_ttdv_rec.currency_conversion_rate := l_ttdv_rec.currency_conversion_rate;
        END IF;
        IF (x_ttdv_rec.currency_conversion_date = OKL_API.G_MISS_DATE)
        THEN
          x_ttdv_rec.currency_conversion_date := l_ttdv_rec.currency_conversion_date;
        END IF;
	-- Modified by dcshanmu for eBTax - modification end

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TAX_TRX_DETAILS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ttdv_rec IN ttdv_rec_type,
      x_ttdv_rec OUT NOCOPY ttdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ttdv_rec := p_ttdv_rec;
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
      p_ttdv_rec,       -- IN
      x_ttdv_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ttdv_rec, LDefOklTaxTrxDetailsVRec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    LDefOklTaxTrxDetailsVRec := fill_who_columns(LDefOklTaxTrxDetailsVRec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(LDefOklTaxTrxDetailsVRec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    /*
    l_return_status := Validate_Record(LDefOklTaxTrxDetailsVRec, l_db_ttdv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_ttdv_rec    				 => LDefOklTaxTrxDetailsVRec); --p_ttdv_rec); -- SECHAWLA Changed to pass l_def_tbov_rec becoz of locking issue
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(LDefOklTaxTrxDetailsVRec, l_ttd_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ttd_rec,
      lx_ttd_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ttd_rec, LDefOklTaxTrxDetailsVRec);
    x_ttdv_rec := LDefOklTaxTrxDetailsVRec;
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
  ---------------------------------------------------------
  -- PL/SQL TBL update_row for:okl_tax_trx_details_v_tbl --
  ---------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type,
    x_ttdv_tbl    				   OUT NOCOPY ttdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ttdv_tbl.COUNT > 0) THEN
      i := p_ttdv_tbl.FIRST;
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
            p_ttdv_rec    => p_ttdv_tbl(i),
            x_ttdv_rec    => x_ttdv_tbl(i));
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
        EXIT WHEN (i = p_ttdv_tbl.LAST);
        i := p_ttdv_tbl.NEXT(i);
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

  ---------------------------------------------------------
  -- PL/SQL TBL update_row for:OKL_TAX_TRX_DETAILS_V_TBL --
  ---------------------------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type,
    x_ttdv_tbl    				   OUT NOCOPY ttdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ttdv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ttdv_tbl    => p_ttdv_tbl,
        x_ttdv_tbl    => x_ttdv_tbl,
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
  -- delete_row for:OKL_TAX_TRX_DETAILS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttd_rec                      IN ttd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ttd_rec                      ttd_rec_type := p_ttd_rec;
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

    DELETE FROM OKL_TAX_TRX_DETAILS
     WHERE ID = p_ttd_rec.id;

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
  -- delete_row for:OKL_TAX_TRX_DETAILS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_rec    IN ttdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ttdv_rec    ttdv_rec_type := p_ttdv_rec;
    l_ttd_rec                      ttd_rec_type;
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
    migrate(l_ttdv_rec, l_ttd_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ttd_rec
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
  -- PL/SQL TBL delete_row for:OKL_TAX_TRX_DETAILS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    IN ttdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ttdv_tbl.COUNT > 0) THEN
      i := p_ttdv_tbl.FIRST;
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
            p_ttdv_rec    => p_ttdv_tbl(i));
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
        EXIT WHEN (i = p_ttdv_tbl.LAST);
        i := p_ttdv_tbl.NEXT(i);
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
  -- PL/SQL TBL delete_row for:OKL_TAX_TRX_DETAILS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ttdv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ttdv_tbl    => p_ttdv_tbl,
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

END OKL_TTD_PVT;

/
