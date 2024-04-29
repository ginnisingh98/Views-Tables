--------------------------------------------------------
--  DDL for Package Body OKL_TXS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXS_PVT" AS
/* $Header: OKLSTXSB.pls 120.9 2007/08/29 00:56:09 rravikir noship $ */
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
  -- FUNCTION get_rec for: OKL_TAX_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_txsv_rec                     IN txsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN txsv_rec_type IS
    CURSOR okl_txsv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            KLE_ID,
            LINE_NAME,
            TRX_ID,
            TRX_LINE_ID,
            ENTITY_CODE,
            EVENT_CLASS_CODE,
            TRX_LEVEL_TYPE,
           -- TRX_LINE_TYPE,
            ADJUSTED_DOC_ENTITY_CODE,
            ADJUSTED_DOC_EVENT_CLASS_CODE,
            ADJUSTED_DOC_TRX_ID,
            ADJUSTED_DOC_TRX_LINE_ID,
            ADJUSTED_DOC_TRX_LEVEL_TYPE,
            ADJUSTED_DOC_NUMBER,
            ADJUSTED_DOC_DATE,
            TAX_CALL_TYPE_CODE,
            STY_ID,
            TRX_BUSINESS_CATEGORY,
            TAX_LINE_STATUS_CODE,
            SEL_ID,
            TAX_REPORTING_FLAG,
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
	    -- modified by eBTax by dcshanmu - modification starts
	    APPLICATION_ID,
	    DEFAULT_TAXATION_COUNTRY,
	    PRODUCT_CATEGORY,
	    USER_DEFINED_FISC_CLASS,
	    LINE_INTENDED_USE,
	    INVENTORY_ITEM_ID,
	    BILL_TO_CUST_ACCT_ID,
	    ORG_ID,
	    LEGAL_ENTITY_ID,
	    LINE_AMT,
	    ASSESSABLE_VALUE,
	    TOTAL_TAX,
	    PRODUCT_TYPE,
	    PRODUCT_FISC_CLASSIFICATION,
	    TRX_DATE,
	    PROVNL_TAX_DETERMINATION_DATE,
	    TRY_ID,
	    SHIP_TO_LOCATION_ID,
	    TRX_CURRENCY_CODE,
	    CURRENCY_CONVERSION_TYPE,
	    CURRENCY_CONVERSION_RATE,
	    CURRENCY_CONVERSION_DATE
	    --asawanka eBTax changes start
	    ,ASSET_NUMBER
        ,reported_yn
        ,SHIP_TO_PARTY_SITE_ID
        ,SHIP_TO_PARTY_ID
        ,BILL_TO_PARTY_SITE_ID
        ,BILL_TO_LOCATION_ID
        ,BILL_TO_PARTY_ID
        ,ship_to_cust_acct_site_use_id
        ,bill_to_cust_acct_site_use_id
        ,TAX_CLASSIFICATION_CODE
        --asawanka eBTax changes end
	    -- modified by eBTax by dcshanmu - modification end
        ,ALC_SERIALIZED_YN
        ,ALC_SERIALIZED_TOTAL_TAX
        ,ALC_SERIALIZED_TOTAL_LINE_AMT
      FROM Okl_Tax_Sources_V
     WHERE okl_tax_sources_v.id = p_id;
    l_okl_txsv_pk                  okl_txsv_pk_csr%ROWTYPE;
    l_txsv_rec                     txsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txsv_pk_csr (p_txsv_rec.id);
    FETCH okl_txsv_pk_csr INTO
              l_txsv_rec.id,
              l_txsv_rec.khr_id,
              l_txsv_rec.kle_id,
              l_txsv_rec.line_name,
              l_txsv_rec.trx_id,
              l_txsv_rec.trx_line_id,
              l_txsv_rec.entity_code,
              l_txsv_rec.event_class_code,
              l_txsv_rec.trx_level_type,
              --l_txsv_rec.trx_line_type,
              l_txsv_rec.adjusted_doc_entity_code,
              l_txsv_rec.adjusted_doc_event_class_code,
              l_txsv_rec.adjusted_doc_trx_id,
              l_txsv_rec.adjusted_doc_trx_line_id,
              l_txsv_rec.adjusted_doc_trx_level_type,
              l_txsv_rec.adjusted_doc_number,
              l_txsv_rec.adjusted_doc_date,
              l_txsv_rec.tax_call_type_code,
              l_txsv_rec.sty_id,
              l_txsv_rec.trx_business_category,
              l_txsv_rec.tax_line_status_code,
              l_txsv_rec.sel_id,
              l_txsv_rec.reported_yn,
              l_txsv_rec.program_id,
              l_txsv_rec.request_id,
              l_txsv_rec.program_application_id,
              l_txsv_rec.program_update_date,
              l_txsv_rec.attribute_category,
              l_txsv_rec.attribute1,
              l_txsv_rec.attribute2,
              l_txsv_rec.attribute3,
              l_txsv_rec.attribute4,
              l_txsv_rec.attribute5,
              l_txsv_rec.attribute6,
              l_txsv_rec.attribute7,
              l_txsv_rec.attribute8,
              l_txsv_rec.attribute9,
              l_txsv_rec.attribute10,
              l_txsv_rec.attribute11,
              l_txsv_rec.attribute12,
              l_txsv_rec.attribute13,
              l_txsv_rec.attribute14,
              l_txsv_rec.attribute15,
              l_txsv_rec.created_by,
              l_txsv_rec.creation_date,
              l_txsv_rec.last_updated_by,
              l_txsv_rec.last_update_date,
              l_txsv_rec.last_update_login,
              l_txsv_rec.object_version_number,
	      -- modified by eBTax by dcshanmu - modification starts
	      l_txsv_rec.application_id,
	      l_txsv_rec.default_taxation_country,
	      l_txsv_rec.product_category,
	      l_txsv_rec.user_defined_fisc_class,
	      l_txsv_rec.line_intended_use,
	      l_txsv_rec.inventory_item_id,
	      l_txsv_rec.bill_to_cust_acct_id,
	      l_txsv_rec.org_id,
	      l_txsv_rec.legal_entity_id,
	      l_txsv_rec.line_amt,
	      l_txsv_rec.assessable_value,
	      l_txsv_rec.total_tax,
	      l_txsv_rec.product_type,
	      l_txsv_rec.product_fisc_classification,
	      l_txsv_rec.trx_date,
	      l_txsv_rec.provnl_tax_determination_date,
	      l_txsv_rec.try_id,
	      l_txsv_rec.ship_to_location_id,
	      l_txsv_rec.trx_currency_code,
	      l_txsv_rec.currency_conversion_type,
	      l_txsv_rec.currency_conversion_rate,
	      l_txsv_rec.currency_conversion_date
          --asawanka ebtax changes start
          ,l_txsv_rec.ASSET_NUMBER

        ,l_txsv_rec.reported_yn
        ,l_txsv_rec.SHIP_TO_PARTY_SITE_ID
        ,l_txsv_rec.SHIP_TO_PARTY_ID
        ,l_txsv_rec.BILL_TO_PARTY_SITE_ID
        ,l_txsv_rec.BILL_TO_LOCATION_ID
        ,l_txsv_rec.BILL_TO_PARTY_ID
        ,l_txsv_rec.ship_to_cust_acct_site_use_id
        ,l_txsv_rec.bill_to_cust_acct_site_use_id
        ,l_txsv_rec.TAX_CLASSIFICATION_CODE
        --asawanka ebtax changes end
        ,l_txsv_rec.ALC_SERIALIZED_YN
        ,l_txsv_rec.ALC_SERIALIZED_TOTAL_TAX
        ,l_txsv_rec.ALC_SERIALIZED_TOTAL_LINE_AMT;
	      -- modified by eBTax by dcshanmu - modification end
    x_no_data_found := okl_txsv_pk_csr%NOTFOUND;
    CLOSE okl_txsv_pk_csr;
    RETURN(l_txsv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_txsv_rec                     IN txsv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN txsv_rec_type IS
    l_txsv_rec                     txsv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_txsv_rec := get_rec(p_txsv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_txsv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_txsv_rec                     IN txsv_rec_type
  ) RETURN txsv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_txsv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TAX_SOURCES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_txs_rec                      IN txs_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN txs_rec_type IS
    CURSOR okl_txs_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            KLE_ID,
            LINE_NAME,
            TRX_ID,
            TRX_LINE_ID,
            ENTITY_CODE,
            EVENT_CLASS_CODE,
            TRX_LEVEL_TYPE,
            --TRX_LINE_TYPE,
            ADJUSTED_DOC_ENTITY_CODE,
            ADJUSTED_DOC_EVENT_CLASS_CODE,
            ADJUSTED_DOC_TRX_ID,
            ADJUSTED_DOC_TRX_LINE_ID,
            ADJUSTED_DOC_TRX_LEVEL_TYPE,
            ADJUSTED_DOC_NUMBER,
            ADJUSTED_DOC_DATE,
            TAX_CALL_TYPE_CODE,
            STY_ID,
            TRX_BUSINESS_CATEGORY,
            TAX_LINE_STATUS_CODE,
            SEL_ID,
            TAX_REPORTING_FLAG,
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
	    -- modified by eBTax by dcshanmu - modification starts
	    APPLICATION_ID,
	    DEFAULT_TAXATION_COUNTRY,
	    PRODUCT_CATEGORY,
	    USER_DEFINED_FISC_CLASS,
	    LINE_INTENDED_USE,
	    INVENTORY_ITEM_ID,
	    BILL_TO_CUST_ACCT_ID,
	    ORG_ID,
	    LEGAL_ENTITY_ID,
	    LINE_AMT,
	    ASSESSABLE_VALUE,
	    TOTAL_TAX,
	    PRODUCT_TYPE,
	    PRODUCT_FISC_CLASSIFICATION,
	    TRX_DATE,
	    PROVNL_TAX_DETERMINATION_DATE,
	    TRY_ID,
	    SHIP_TO_LOCATION_ID,
        TRX_CURRENCY_CODE,
	    CURRENCY_CONVERSION_TYPE,
	    CURRENCY_CONVERSION_RATE,
	    CURRENCY_CONVERSION_DATE
	    -- modified by eBTax by dcshanmu - modification end
	     --asawanka eBTax changes start
	    ,ASSET_NUMBER
        ,reported_yn
        ,SHIP_TO_PARTY_SITE_ID
        ,SHIP_TO_PARTY_ID
        ,BILL_TO_PARTY_SITE_ID
        ,BILL_TO_LOCATION_ID
        ,BILL_TO_PARTY_ID
        ,ship_to_cust_acct_site_use_id
        ,bill_to_cust_acct_site_use_id
        ,TAX_CLASSIFICATION_CODE
        --asawanka eBTax changes end
        ,ALC_SERIALIZED_YN
        ,ALC_SERIALIZED_TOTAL_TAX
        ,ALC_SERIALIZED_TOTAL_LINE_AMT
      FROM Okl_Tax_Sources
     WHERE okl_tax_sources.id   = p_id;
    l_okl_txs_pk                   okl_txs_pk_csr%ROWTYPE;
    l_txs_rec                      txs_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txs_pk_csr (p_txs_rec.id);
    FETCH okl_txs_pk_csr INTO
              l_txs_rec.id,
              l_txs_rec.khr_id,
              l_txs_rec.kle_id,
              l_txs_rec.line_name,
              l_txs_rec.trx_id,
              l_txs_rec.trx_line_id,
              l_txs_rec.entity_code,
              l_txs_rec.event_class_code,
              l_txs_rec.trx_level_type,
              --l_txs_rec.trx_line_type,
              l_txs_rec.adjusted_doc_entity_code,
              l_txs_rec.adjusted_doc_event_class_code,
              l_txs_rec.adjusted_doc_trx_id,
              l_txs_rec.adjusted_doc_trx_line_id,
              l_txs_rec.adjusted_doc_trx_level_type,
              l_txs_rec.adjusted_doc_number,
              l_txs_rec.adjusted_doc_date,
              l_txs_rec.tax_call_type_code,
              l_txs_rec.sty_id,
              l_txs_rec.trx_business_category,
              l_txs_rec.tax_line_status_code,
              l_txs_rec.sel_id,
              l_txs_rec.reported_yn,
              l_txs_rec.program_id,
              l_txs_rec.request_id,
              l_txs_rec.program_application_id,
              l_txs_rec.program_update_date,
              l_txs_rec.attribute_category,
              l_txs_rec.attribute1,
              l_txs_rec.attribute2,
              l_txs_rec.attribute3,
              l_txs_rec.attribute4,
              l_txs_rec.attribute5,
              l_txs_rec.attribute6,
              l_txs_rec.attribute7,
              l_txs_rec.attribute8,
              l_txs_rec.attribute9,
              l_txs_rec.attribute10,
              l_txs_rec.attribute11,
              l_txs_rec.attribute12,
              l_txs_rec.attribute13,
              l_txs_rec.attribute14,
              l_txs_rec.attribute15,
              l_txs_rec.created_by,
              l_txs_rec.creation_date,
              l_txs_rec.last_updated_by,
              l_txs_rec.last_update_date,
              l_txs_rec.last_update_login,
              l_txs_rec.object_version_number,
	      -- modified by eBTax by dcshanmu - modification starts
              l_txs_rec.application_id,
              l_txs_rec.default_taxation_country,
              l_txs_rec.product_category,
              l_txs_rec.user_defined_fisc_class,
              l_txs_rec.line_intended_use,
              l_txs_rec.inventory_item_id,
              l_txs_rec.bill_to_cust_acct_id,
              l_txs_rec.org_id,
              l_txs_rec.legal_entity_id,
              l_txs_rec.line_amt,
              l_txs_rec.assessable_value,
              l_txs_rec.total_tax,
              l_txs_rec.product_type,
              l_txs_rec.product_fisc_classification,
              l_txs_rec.trx_date,
              l_txs_rec.provnl_tax_determination_date,
              l_txs_rec.try_id,
              l_txs_rec.ship_to_location_id,
              l_txs_rec.trx_currency_code,
              l_txs_rec.currency_conversion_type,
              l_txs_rec.currency_conversion_rate,
              l_txs_rec.currency_conversion_date
	      -- modified by eBTax by dcshanmu - modification end
	         --asawanka ebtax changes start
	             ,l_txs_rec.ASSET_NUMBER
        ,l_txs_rec.reported_yn
        ,l_txs_rec.SHIP_TO_PARTY_SITE_ID
        ,l_txs_rec.SHIP_TO_PARTY_ID
        ,l_txs_rec.BILL_TO_PARTY_SITE_ID
        ,l_txs_rec.BILL_TO_LOCATION_ID
        ,l_txs_rec.BILL_TO_PARTY_ID
        ,l_txs_rec.ship_to_cust_acct_site_use_id
        ,l_txs_rec.bill_to_cust_acct_site_use_id
        ,l_txs_rec.TAX_CLASSIFICATION_CODE
        --asawanka ebtax changes end
        ,l_txs_rec.ALC_SERIALIZED_YN
        ,l_txs_rec.ALC_SERIALIZED_TOTAL_TAX
        ,l_txs_rec.ALC_SERIALIZED_TOTAL_LINE_AMT;

    x_no_data_found := okl_txs_pk_csr%NOTFOUND;
    CLOSE okl_txs_pk_csr;
    RETURN(l_txs_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_txs_rec                      IN txs_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN txs_rec_type IS
    l_txs_rec                      txs_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_txs_rec := get_rec(p_txs_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_txs_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_txs_rec                      IN txs_rec_type
  ) RETURN txs_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_txs_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TAX_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_txsv_rec   IN txsv_rec_type
  ) RETURN txsv_rec_type IS
    l_txsv_rec                     txsv_rec_type := p_txsv_rec;
  BEGIN
    IF (l_txsv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.id := NULL;
    END IF;
    IF (l_txsv_rec.khr_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.khr_id := NULL;
    END IF;
    IF (l_txsv_rec.kle_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.kle_id := NULL;
    END IF;
    IF (l_txsv_rec.line_name = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.line_name := NULL;
    END IF;
    IF (l_txsv_rec.trx_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.trx_id := NULL;
    END IF;
    IF (l_txsv_rec.trx_line_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.trx_line_id := NULL;
    END IF;
    IF (l_txsv_rec.entity_code = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.entity_code := NULL;
    END IF;
    IF (l_txsv_rec.event_class_code = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.event_class_code := NULL;
    END IF;
    IF (l_txsv_rec.trx_level_type = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.trx_level_type := NULL;
    END IF;
    /*IF (l_txsv_rec.trx_line_type = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.trx_line_type := NULL;
    END IF;*/
    IF (l_txsv_rec.adjusted_doc_entity_code = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.adjusted_doc_entity_code := NULL;
    END IF;
    IF (l_txsv_rec.adjusted_doc_event_class_code = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.adjusted_doc_event_class_code := NULL;
    END IF;
    IF (l_txsv_rec.adjusted_doc_trx_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.adjusted_doc_trx_id := NULL;
    END IF;
    IF (l_txsv_rec.adjusted_doc_trx_line_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.adjusted_doc_trx_line_id := NULL;
    END IF;
    IF (l_txsv_rec.adjusted_doc_trx_level_type = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.adjusted_doc_trx_level_type := NULL;
    END IF;
    IF (l_txsv_rec.adjusted_doc_number = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.adjusted_doc_number := NULL;
    END IF;
    IF (l_txsv_rec.adjusted_doc_date = OKL_API.G_MISS_DATE ) THEN
      l_txsv_rec.adjusted_doc_date := NULL;
    END IF;
    IF (l_txsv_rec.tax_call_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.tax_call_type_code := NULL;
    END IF;
    IF (l_txsv_rec.sty_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.sty_id := NULL;
    END IF;
    IF (l_txsv_rec.trx_business_category = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.trx_business_category := NULL;
    END IF;
    IF (l_txsv_rec.tax_line_status_code = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.tax_line_status_code := NULL;
    END IF;
    IF (l_txsv_rec.sel_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.sel_id := NULL;
    END IF;
    IF (l_txsv_rec.reported_yn = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.reported_yn := NULL;
    END IF;
    IF (l_txsv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.program_id := NULL;
    END IF;
    IF (l_txsv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.request_id := NULL;
    END IF;
    IF (l_txsv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.program_application_id := NULL;
    END IF;
    IF (l_txsv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_txsv_rec.program_update_date := NULL;
    END IF;
    IF (l_txsv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute_category := NULL;
    END IF;
    IF (l_txsv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute1 := NULL;
    END IF;
    IF (l_txsv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute2 := NULL;
    END IF;
    IF (l_txsv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute3 := NULL;
    END IF;
    IF (l_txsv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute4 := NULL;
    END IF;
    IF (l_txsv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute5 := NULL;
    END IF;
    IF (l_txsv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute6 := NULL;
    END IF;
    IF (l_txsv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute7 := NULL;
    END IF;
    IF (l_txsv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute8 := NULL;
    END IF;
    IF (l_txsv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute9 := NULL;
    END IF;
    IF (l_txsv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute10 := NULL;
    END IF;
    IF (l_txsv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute11 := NULL;
    END IF;
    IF (l_txsv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute12 := NULL;
    END IF;
    IF (l_txsv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute13 := NULL;
    END IF;
    IF (l_txsv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute14 := NULL;
    END IF;
    IF (l_txsv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.attribute15 := NULL;
    END IF;
    IF (l_txsv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.created_by := NULL;
    END IF;
    IF (l_txsv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_txsv_rec.creation_date := NULL;
    END IF;
    IF (l_txsv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_txsv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_txsv_rec.last_update_date := NULL;
    END IF;
    IF (l_txsv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.last_update_login := NULL;
    END IF;
    IF (l_txsv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.object_version_number := NULL;
    END IF;

    -- modified by eBTax by dcshanmu - modification starts
    -- added default null out code to newly added columns to the table
    IF (l_txsv_rec.application_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.application_id := NULL;
    END IF;
    IF (l_txsv_rec.default_taxation_country = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.default_taxation_country := NULL;
    END IF;
    IF (l_txsv_rec.product_category = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.product_category := NULL;
    END IF;
    IF (l_txsv_rec.user_defined_fisc_class = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.user_defined_fisc_class := NULL;
    END IF;
    IF (l_txsv_rec.line_intended_use = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.line_intended_use := NULL;
    END IF;
    IF (l_txsv_rec.inventory_item_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.inventory_item_id := NULL;
    END IF;
    IF (l_txsv_rec.bill_to_cust_acct_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.bill_to_cust_acct_id := NULL;
    END IF;
    IF (l_txsv_rec.org_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.org_id := NULL;
    END IF;
    IF (l_txsv_rec.legal_entity_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.legal_entity_id := NULL;
    END IF;
    IF (l_txsv_rec.line_amt = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.line_amt := NULL;
    END IF;
    IF (l_txsv_rec.assessable_value = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.assessable_value := NULL;
    END IF;
    IF (l_txsv_rec.total_tax = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.total_tax := NULL;
    END IF;
    IF (l_txsv_rec.product_type = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.product_type := NULL;
    END IF;
    IF (l_txsv_rec.product_fisc_classification = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.product_fisc_classification := NULL;
    END IF;
    IF (l_txsv_rec.trx_date = OKL_API.G_MISS_DATE ) THEN
      l_txsv_rec.trx_date := NULL;
    END IF;
    IF (l_txsv_rec.provnl_tax_determination_date = OKL_API.G_MISS_DATE ) THEN
      l_txsv_rec.provnl_tax_determination_date := NULL;
    END IF;
    IF (l_txsv_rec.try_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.try_id := NULL;
    END IF;
    IF (l_txsv_rec.ship_to_location_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.ship_to_location_id := NULL;
    END IF;

    IF (l_txsv_rec.trx_currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.trx_currency_code := NULL;
    END IF;
    IF (l_txsv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_txsv_rec.currency_conversion_rate = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_txsv_rec.currency_conversion_date = OKL_API.G_MISS_DATE ) THEN
      l_txsv_rec.currency_conversion_date := NULL;
    END IF;
    -- modified by eBTax by dcshanmu - modification end
    --asawanka ebtaxchanges start
    IF (l_txsv_rec.asset_number = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.asset_number := NULL;
    END IF;
    IF (l_txsv_rec.reported_yn = OKL_API.G_MISS_CHAR ) THEN
      l_txsv_rec.reported_yn := NULL;
    END IF;
    IF (l_txsv_rec.SHIP_TO_PARTY_SITE_ID = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.SHIP_TO_PARTY_SITE_ID := NULL;
    END IF;
    IF (l_txsv_rec.SHIP_TO_PARTY_ID = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.SHIP_TO_PARTY_ID := NULL;
    END IF;
    IF (l_txsv_rec.BILL_TO_PARTY_SITE_ID = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.BILL_TO_PARTY_SITE_ID := NULL;
    END IF;
    IF (l_txsv_rec.BILL_TO_LOCATION_ID = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.BILL_TO_LOCATION_ID := NULL;
    END IF;
    IF (l_txsv_rec.BILL_TO_PARTY_ID = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.BILL_TO_PARTY_ID := NULL;
    END IF;
    IF (l_txsv_rec.ship_to_cust_acct_site_use_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.ship_to_cust_acct_site_use_id := NULL;
    END IF;
    IF (l_txsv_rec.bill_to_cust_acct_site_use_id = OKL_API.G_MISS_NUM ) THEN
      l_txsv_rec.bill_to_cust_acct_site_use_id := NULL;
    END IF;
    IF (l_txsv_rec.TAX_CLASSIFICATION_CODE = OKL_API.G_MISS_CHAR) THEN
      l_txsv_rec.TAX_CLASSIFICATION_CODE := NULL;
    END IF;
    --asawanka ebtax changes end

    IF (l_txsv_rec.ALC_SERIALIZED_YN = OKL_API.G_MISS_CHAR) THEN
      l_txsv_rec.ALC_SERIALIZED_YN := NULL;
    END IF;
    IF (l_txsv_rec.ALC_SERIALIZED_TOTAL_TAX = OKL_API.G_MISS_NUM) THEN
      l_txsv_rec.ALC_SERIALIZED_TOTAL_TAX := NULL;
    END IF;
    IF (l_txsv_rec.ALC_SERIALIZED_TOTAL_LINE_AMT = OKL_API.G_MISS_NUM) THEN
      l_txsv_rec.ALC_SERIALIZED_TOTAL_LINE_AMT := NULL;
    END IF;

    RETURN(l_txsv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_txsv_rec.id = OKL_API.G_MISS_NUM OR p_txsv_rec.id IS NULL)
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
  -- Validate_Attributes for: KHR_ID --
  -------------------------------------
  PROCEDURE validate_khr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_khr_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okc_k_headers_B
       WHERE id   = p_id;
  BEGIN

    IF (p_txsv_rec.khr_id <> OKL_API.G_MISS_NUM AND p_txsv_rec.khr_id IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'khr_id');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
      OPEN   okl_txsv_khr_id_fk_csr(p_txsv_rec.khr_id) ;
      FETCH  okl_txsv_khr_id_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_khr_id_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'khr_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'OKC_K_HEADERS_B');
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
  END validate_khr_id;
  -------------------------------------
  -- Validate_Attributes for: KLE_ID --
  -------------------------------------
  PROCEDURE validate_kle_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_kle_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okc_k_lines_B
       WHERE id   = p_id;
  BEGIN

    IF (p_txsv_rec.kle_id <> OKL_API.G_MISS_NUM AND p_txsv_rec.kle_id IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'kle_id');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
      OPEN   okl_txsv_kle_id_fk_csr(p_txsv_rec.kle_id) ;
      FETCH  okl_txsv_kle_id_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_kle_id_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'kle_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'OKC_K_LINES_B');
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
  END validate_kle_id;
  -------------------------------------
  -- Validate_Attributes for: TRX_ID --
  -------------------------------------
  PROCEDURE validate_trx_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_txsv_rec.trx_id = OKL_API.G_MISS_NUM OR p_txsv_rec.trx_id IS NULL)
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
  ------------------------------------------
  -- Validate_Attributes for: TRX_LINE_ID --
  ------------------------------------------
  PROCEDURE validate_trx_line_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_txsv_rec.trx_line_id = OKL_API.G_MISS_NUM OR p_txsv_rec.trx_line_id IS NULL)
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
  -- Validate_Attributes for: TAX_CALL_TYPE_CODE --
  -------------------------------------------------
  PROCEDURE validate_tax_call_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_tctc_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
      FROM Fnd_Lookup_Values
      WHERE fnd_lookup_values.lookup_code = p_lookup_code
      AND   fnd_lookup_values.lookup_type = p_lookup_type;
  BEGIN

    IF (p_txsv_rec.tax_call_type_code <> OKL_API.G_MISS_CHAR AND p_txsv_rec.tax_call_type_code IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tax_call_type_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
      -- enforce foreign key
        OPEN   okl_txsv_tctc_fk_csr(p_txsv_rec.tax_call_type_code, 'OKL_TAX_CALL_TYPE')  ;
        FETCH  okl_txsv_tctc_fk_csr into l_dummy_var ;
        CLOSE  okl_txsv_tctc_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_call_type_code',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
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
  -------------------------------------
  -- Validate_Attributes for: STY_ID --
  -------------------------------------
  PROCEDURE validate_sty_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_sty_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM okl_strm_type_b
       WHERE id   = p_id;
  BEGIN

    IF (p_txsv_rec.sty_id <> OKL_API.G_MISS_NUM AND p_txsv_rec.sty_id IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sty_id');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
      OPEN   okl_txsv_sty_id_fk_csr(p_txsv_rec.sty_id) ;
      FETCH  okl_txsv_sty_id_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_sty_id_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'sty_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'okl_strm_type_b');
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
  END validate_sty_id;
  ----------------------------------------------------
  -- Validate_Attributes for: TRX_BUSINESS_CATEGORY --
  ----------------------------------------------------
  PROCEDURE validate_trx_business_category(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    -- modified by dcshanmu for eBTax project. Modification starts

    CURSOR okl_txsv_tbc_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
      FROM ZX_FC_BUSINESS_CATEGORIES_V
      WHERE classification_code = p_lookup_code;
      --AND   lookup_type = p_lookup_type;

      -- modified by dcshanmu for eBTax project. Modification ends

  BEGIN

    IF (p_txsv_rec.trx_business_category <> OKL_API.G_MISS_CHAR AND p_txsv_rec.trx_business_category IS NOT NULL)
    THEN
    --  OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_business_category');
    --  l_return_status := OKL_API.G_RET_STS_ERROR;
    --ELSE
	  -- enforce foreign key
        OPEN   okl_txsv_tbc_fk_csr(p_txsv_rec.trx_business_category, 'AR_TAX_TRX_BUSINESS_CATEGORY')  ;
        FETCH  okl_txsv_tbc_fk_csr into l_dummy_var ;
        CLOSE  okl_txsv_tbc_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'trx_business_category',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'ZX_FC_BUSINESS_CATEGORIES_V');
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
  END validate_trx_business_category;

  -- Modified by dcshanmu for eBTax - modification starts
  -- added validation methods for newly added columns
  ---------------------------------------------------
  -- Validate_Attributes for: TAX_LINE_STATUS_CODE --
  ---------------------------------------------------
  PROCEDURE validate_tax_line_status_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_tlsc_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
      FROM fnd_lookup_values
      WHERE lookup_code = p_lookup_code
      AND   lookup_type = p_lookup_type;

  BEGIN

    IF (p_txsv_rec.tax_line_status_code <> OKL_API.G_MISS_CHAR AND p_txsv_rec.tax_line_status_code IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tax_line_status_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
      -- enforce foreign key
        OPEN   okl_txsv_tlsc_fk_csr(p_txsv_rec.tax_line_status_code, 'OKL_TAX_LINE_STATUS')  ;
        FETCH  okl_txsv_tlsc_fk_csr INTO l_dummy_var ;
        CLOSE  okl_txsv_tlsc_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_line_status_code',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
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
  END validate_tax_line_status_code;
  -------------------------------------
  -- Validate_Attributes for: SEL_ID --
  -------------------------------------
  PROCEDURE validate_sel_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_sel_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   okl_strm_elements
      WHERE  id = p_id;
  BEGIN

    IF (p_txsv_rec.sel_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.sel_id IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sel_id');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
      OPEN   okl_txsv_sel_fk_csr(p_txsv_rec.sel_id) ;
      FETCH  okl_txsv_sel_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_sel_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'sel_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'okl_strm_elements');
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
  END validate_sel_id;
  -------------------------------------
  -- Validate_Attributes for: APPLICATION_ID --
  -------------------------------------
  PROCEDURE validate_application_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    IF (p_txsv_rec.application_id = OKL_API.G_MISS_NUM OR  p_txsv_rec.application_id IS NULL)
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
  -------------------------------------
  -- Validate_Attributes for: DEFAULT_TAXATION_COUNTRY --
  -------------------------------------
  PROCEDURE validate_def_txn_country(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_def_txn_cntry_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_territories_tl
      WHERE  territory_code = p_id;
  BEGIN

    IF (p_txsv_rec.default_taxation_country <> OKL_API.G_MISS_CHAR AND  p_txsv_rec.default_taxation_country IS NOT NULL)
    THEN
      OPEN   okl_txsv_def_txn_cntry_fk_csr(p_txsv_rec.default_taxation_country) ;
      FETCH  okl_txsv_def_txn_cntry_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_def_txn_cntry_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'default_taxation_country',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'fnd_territories_tl');
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
  END validate_def_txn_country;
  -------------------------------------
  -- Validate_Attributes for: PRODUCT_CATEGORY --
  -------------------------------------
  PROCEDURE validate_product_category(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_prod_ctg_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   ZX_FC_PRODUCT_CATEGORIES_V
      WHERE  classification_code = p_id;
  BEGIN

    IF (p_txsv_rec.product_category <> OKL_API.G_MISS_CHAR AND  p_txsv_rec.product_category IS NOT NULL)
    THEN
      OPEN   okl_txsv_prod_ctg_fk_csr(p_txsv_rec.product_category) ;
      FETCH  okl_txsv_prod_ctg_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_prod_ctg_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'product_category',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'ZX_FC_PRODUCT_CATEGORIES_V');
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
  END validate_product_category;
  -------------------------------------
  -- Validate_Attributes for: USER_DEFINED_FISC_CLASS --
  -------------------------------------
  PROCEDURE validate_udfc(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_udfc_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   ZX_FC_USER_DEFINED_V
      WHERE  classification_code = p_id;
  BEGIN

    IF (p_txsv_rec.user_defined_fisc_class <> OKL_API.G_MISS_CHAR AND  p_txsv_rec.user_defined_fisc_class IS NOT NULL)
    THEN
      OPEN   okl_txsv_udfc_fk_csr(p_txsv_rec.user_defined_fisc_class) ;
      FETCH  okl_txsv_udfc_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_udfc_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'user_defined_fisc_class',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'ZX_FC_USER_DEFINED_V');
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
  END validate_udfc;
  -------------------------------------
  -- Validate_Attributes for: LINE_INTENDED_USE --
  -------------------------------------
  PROCEDURE validate_line_int_use(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_line_int_use_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   ZX_FC_INTENDED_USE_V
      WHERE  classification_code = p_id;
  BEGIN

    IF (p_txsv_rec.line_intended_use <> OKL_API.G_MISS_CHAR AND  p_txsv_rec.line_intended_use IS NOT NULL)
    THEN
      OPEN   okl_txsv_line_int_use_fk_csr(p_txsv_rec.line_intended_use) ;
      FETCH  okl_txsv_line_int_use_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_line_int_use_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'line_intended_use',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'ZX_FC_INTENDED_USE_V');
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
  END validate_line_int_use;
  -------------------------------------
  -- Validate_Attributes for: INVENTORY_ITEM_ID --
  -------------------------------------
  PROCEDURE validate_inventory_item_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_inv_item_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = p_id;
  BEGIN

    IF (p_txsv_rec.inventory_item_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.inventory_item_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_inv_item_id_fk_csr(p_txsv_rec.inventory_item_id) ;
      FETCH  okl_txsv_inv_item_id_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_inv_item_id_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'inventory_item_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'mtl_system_items_b');
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
  END validate_inventory_item_id;
  -------------------------------------
  -- Validate_Attributes for: BILL_TO_CUST_ACCT_ID --
  -------------------------------------
  PROCEDURE validate_bill_to_cust_acct_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_bill_cust_acct_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   hz_cust_accounts
      WHERE  cust_account_id = p_id;
  BEGIN

    IF (p_txsv_rec.bill_to_cust_acct_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.bill_to_cust_acct_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_bill_cust_acct_fk_csr(p_txsv_rec.bill_to_cust_acct_id) ;
      FETCH  okl_txsv_bill_cust_acct_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_bill_cust_acct_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'bill_to_cust_acct_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'hz_cust_accounts');
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
  END validate_bill_to_cust_acct_id;
  -------------------------------------
  -- Validate_Attributes for: ORG_ID --
  -------------------------------------
  PROCEDURE validate_org_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_org_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   hr_all_organization_units
      WHERE  organization_id = p_id;
  BEGIN

    IF (p_txsv_rec.org_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.org_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_org_id_fk_csr(p_txsv_rec.org_id) ;
      FETCH  okl_txsv_org_id_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_org_id_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'org_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'hr_all_organization_units');
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
  END validate_org_id;
  -------------------------------------
  -- Validate_Attributes for: LEGAL_ENTITY_ID --
  -------------------------------------
  PROCEDURE validate_legal_entity_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_le_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   xle_entity_profiles
      WHERE  legal_entity_id = p_id;
  BEGIN

    IF (p_txsv_rec.legal_entity_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.legal_entity_id IS NOT NULL)
    THEN
      --akrangan bug 6281517 fix start
       --changed org id assignment as input param of the csr to legal_entity_id
      OPEN   okl_txsv_le_id_fk_csr(p_txsv_rec.legal_entity_id) ;
      --akrangan bug 6281517 fix end
      FETCH  okl_txsv_le_id_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_le_id_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'legal_entity_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'xle_entity_profiles');
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
  END validate_legal_entity_id;
  -------------------------------------
  -- Validate_Attributes for: PRODUCT_TYPE --
  -------------------------------------
  PROCEDURE validate_product_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_prod_type_fk_csr IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_type = 'ZX_PRODUCT_TYPE';
  BEGIN

    IF (p_txsv_rec.product_type <> OKL_API.G_MISS_CHAR AND  p_txsv_rec.product_type IS NOT NULL)
    THEN
      OPEN   okl_txsv_prod_type_fk_csr;
      FETCH  okl_txsv_prod_type_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_prod_type_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'product_type',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'fnd_lookups');
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
  END validate_product_type;
  -------------------------------------
  -- Validate_Attributes for: PRODUCT_FISC_CLASSIFICATION --
  -------------------------------------
  PROCEDURE validate_prod_fisc_classfn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_prd_fis_clasfn_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   zx_fc_codes_b
      WHERE  classification_code = p_id;
  BEGIN

    IF (p_txsv_rec.product_fisc_classification <> OKL_API.G_MISS_CHAR AND  p_txsv_rec.product_fisc_classification IS NOT NULL)
    THEN
      OPEN   okl_txsv_prd_fis_clasfn_fk_csr(p_txsv_rec.product_fisc_classification);
      FETCH  okl_txsv_prd_fis_clasfn_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_prd_fis_clasfn_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'product_fisc_classification',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'zx_fc_codes_b');
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
  END validate_prod_fisc_classfn;
  -------------------------------------
  -- Validate_Attributes for: PROVNL_TAX_DETERMINATION_DATE --
  -------------------------------------
  PROCEDURE validate_provnl_tax_det_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    IF (p_txsv_rec.provnl_tax_determination_date = OKL_API.G_MISS_DATE AND  p_txsv_rec.provnl_tax_determination_date IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'provnl_tax_determination_date');
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
  END validate_provnl_tax_det_date;
   -------------------------------------
  -- Validate_Attributes for: trx_Date --
  -------------------------------------
  PROCEDURE validate_trx_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    IF (p_txsv_rec.trx_Date = OKL_API.G_MISS_DATE AND  p_txsv_rec.trx_Date IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_Date');
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
  END validate_trx_date;
  -------------------------------------
  -- Validate_Attributes for: TRY_ID --
  -------------------------------------
  PROCEDURE validate_try_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_try_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   okl_trx_types_b
      WHERE  id = p_id;
  BEGIN

    IF (p_txsv_rec.try_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.try_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_try_id_fk_csr(p_txsv_rec.try_id);
      FETCH  okl_txsv_try_id_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_try_id_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'try_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'okl_trx_types_b');
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
  END validate_try_id;
  -------------------------------------
  -- Validate_Attributes for: SHIP_TO_LOCATION_ID --
  -------------------------------------
  PROCEDURE validate_ship_to_location_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_ship_to_locn_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   hz_party_sites
      WHERE  location_id = p_id;
  BEGIN

    IF (p_txsv_rec.ship_to_location_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.ship_to_location_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_ship_to_locn_fk_csr(p_txsv_rec.ship_to_location_id);
      FETCH  okl_txsv_ship_to_locn_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_ship_to_locn_fk_csr ;
      -- still set to default means data was not found

      IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'ship_to_location_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'hz_party_sites');
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
  END validate_ship_to_location_id;
  -------------------------------------
  -- Validate_Attributes for: SHIP_TO_PARTY_SITE_ID --
  -------------------------------------
  PROCEDURE validate_ship_to_party_site_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_ship_to_ps_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   hz_party_sites
      WHERE  party_site_id = p_id;
  BEGIN

    IF (p_txsv_rec.ship_to_party_site_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.ship_to_party_site_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_ship_to_ps_fk_csr(p_txsv_rec.ship_to_party_site_id);
      FETCH  okl_txsv_ship_to_ps_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_ship_to_ps_fk_csr ;
      -- still set to default means data was not found

      IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'ship_to_party_site_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'hz_party_sites');
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
  END validate_ship_to_party_site_id;
  -------------------------------------
  -- Validate_Attributes for: SHIP_TO_PARTY_ID --
  -------------------------------------
  PROCEDURE validate_ship_to_party_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_ship_to_pid_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   hz_party_sites
      WHERE  party_id = p_id;
  BEGIN

    IF (p_txsv_rec.ship_to_party_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.ship_to_party_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_ship_to_pid_fk_csr(p_txsv_rec.ship_to_party_id);
      FETCH  okl_txsv_ship_to_pid_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_ship_to_pid_fk_csr ;
      -- still set to default means data was not found

      IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'ship_to_party_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'hz_party_sites');
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
  END validate_ship_to_party_id;

  -------------------------------------
  -- Validate_Attributes for: bill_to_party_site_id --
  -------------------------------------
  PROCEDURE validate_bill_to_party_site_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_bill_to_ps_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   hz_party_sites
      WHERE  party_site_id = p_id;
  BEGIN

    IF (p_txsv_rec.bill_to_party_site_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.bill_to_party_site_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_bill_to_ps_fk_csr(p_txsv_rec.bill_to_party_site_id);
      FETCH  okl_txsv_bill_to_ps_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_bill_to_ps_fk_csr ;
      -- still set to default means data was not found

      IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'bill_to_party_site_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'hz_party_sites');
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
  END validate_bill_to_party_site_id;

  -------------------------------------
  -- Validate_Attributes for: bill_to_location_id --
  -------------------------------------
  PROCEDURE validate_bill_to_location_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_bill_to_loc_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   hz_party_sites
      WHERE  location_id = p_id;
  BEGIN

    IF (p_txsv_rec.bill_to_location_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.bill_to_location_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_bill_to_loc_fk_csr(p_txsv_rec.bill_to_location_id);
      FETCH  okl_txsv_bill_to_loc_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_bill_to_loc_fk_csr ;
      -- still set to default means data was not found

      IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'bill_to_location_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'hz_party_sites');
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
  END validate_bill_to_location_id;

  -------------------------------------
  -- Validate_Attributes for: bill_to_location_id --
  -------------------------------------
  PROCEDURE validate_bill_to_party_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_bill_to_pid_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   hz_party_sites
      WHERE  party_id = p_id;
  BEGIN

    IF (p_txsv_rec.bill_to_party_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.bill_to_party_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_bill_to_pid_fk_csr(p_txsv_rec.bill_to_party_id);
      FETCH  okl_txsv_bill_to_pid_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_bill_to_pid_fk_csr ;
      -- still set to default means data was not found

      IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'bill_to_party_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'hz_party_sites');
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
  END validate_bill_to_party_id;
  -------------------------------------
  -- Validate_Attributes for: ship_to_cust_acct_site_use_id --
  -------------------------------------
  PROCEDURE validate_shiptocasuid(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_ship_to_cs_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   hz_cust_site_uses_all
      WHERE  site_use_id = p_id;
  BEGIN

    IF (p_txsv_rec.ship_to_cust_acct_site_use_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.ship_to_cust_acct_site_use_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_ship_to_cs_fk_csr(p_txsv_rec.ship_to_cust_acct_site_use_id);
      FETCH  okl_txsv_ship_to_cs_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_ship_to_cs_fk_csr ;
      -- still set to default means data was not found

      IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'ship_to_cust_acct_site_use_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'hz_cust_site_uses_all');
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
  END validate_shiptocasuid;

    -------------------------------------
  -- Validate_Attributes for: bill_to_cust_acct_site_use_id --
  -------------------------------------
  PROCEDURE validate_billtocasuid(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_txsv_bill_to_cs_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   hz_cust_site_uses_all
      WHERE  site_use_id = p_id;
  BEGIN

    IF (p_txsv_rec.bill_to_cust_acct_site_use_id <> OKL_API.G_MISS_NUM AND  p_txsv_rec.bill_to_cust_acct_site_use_id IS NOT NULL)
    THEN
      OPEN   okl_txsv_bill_to_cs_fk_csr(p_txsv_rec.bill_to_cust_acct_site_use_id);
      FETCH  okl_txsv_bill_to_cs_fk_csr into l_dummy_var ;
      CLOSE  okl_txsv_bill_to_cs_fk_csr ;
      -- still set to default means data was not found

      IF ( l_dummy_var = '?' ) THEN

           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'ship_to_cust_acct_site_use_id',
                        g_child_table_token ,
                        'OKL_TAX_SOURCES_V',
                        g_parent_table_token ,
                        'hz_cust_site_uses_all');
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
  END validate_billtocasuid;
  -------------------------------------
  -- Validate_Attributes for: TRX_CURRENCY_CODE --
  -------------------------------------
  PROCEDURE validate_trx_currency_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    IF (p_txsv_rec.trx_currency_code = OKL_API.G_MISS_CHAR OR  p_txsv_rec.trx_currency_code IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'trx_currency_code');
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
  END validate_trx_currency_code;
  -- Modified by dcshanmu for eBTax - modification end

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKL_TAX_SOURCES_V --
  -----------------------------------------------
  FUNCTION Validate_Attributes (
    p_txsv_rec                     IN txsv_rec_type
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
    validate_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;


    -- ***
    -- khr_id
    -- ***
    validate_khr_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;


    -- ***
    -- kle_id
    -- ***
    validate_kle_id(l_return_status, p_txsv_rec);
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
    validate_trx_id(l_return_status, p_txsv_rec);
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
    validate_trx_line_id(l_return_status, p_txsv_rec);
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
    validate_tax_call_type_code(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;


    -- ***
    -- sty_id
    -- ***
    validate_sty_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;


    -- ***
    -- trx_business_category
    -- ***
    validate_trx_business_category(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

   -- Modified by dcshanmu for eBTax - modification starts
   -- calling validation methods for newly added columns

    -- ***
    -- tax_line_status_code
    -- ***
    validate_tax_line_status_code(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;


    -- ***
    -- sel_id
    -- ***
    validate_sel_id(l_return_status, p_txsv_rec);
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
    validate_application_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- default_taxation_country
    -- ***
    validate_def_txn_country(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- product_category
    -- ***
    validate_product_category(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- user_defined_fisc_class
    -- ***
    validate_udfc(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- line_intended_use
    -- ***
    validate_line_int_use(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- inventory_item_id
    -- ***
    validate_inventory_item_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- bill_to_cust_acct_id
    -- ***
    validate_bill_to_cust_acct_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- org_id
    -- ***
    validate_org_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- legal_entity_id
    -- ***
    validate_legal_entity_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- product_type
    -- ***
    validate_product_type(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- product_fisc_classification
    -- ***
    validate_prod_fisc_classfn(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- provnl_tax_determination_date
    -- ***
    validate_provnl_tax_det_date(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
     -- ***
    -- trx_date
    -- ***
    validate_trx_date(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- try_id
    -- ***
    validate_try_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- ship_to_location_id
    -- ***
    validate_ship_to_location_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- ship_to_party_site_id
    -- ***
    validate_ship_to_party_site_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- ship_to_party_id
    -- ***
    validate_ship_to_party_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
    -- ***
    -- bill_to_party_site_id
    -- ***
    validate_bill_to_party_site_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- bill_to_location_id
    -- ***
    validate_bill_to_location_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- bill_to_party_id
    -- ***
    validate_bill_to_party_id(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- ship_to_cust_acct_site_use_id
    -- ***
    validate_shiptocasuid(l_return_status, p_txsv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- bill_to_cust_acct_site_use_id
    -- ***
    validate_billtocasuid(l_return_status, p_txsv_rec);
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
    validate_trx_currency_code(l_return_status, p_txsv_rec);
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
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
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
  /*-------------------------------------------
  -- Validate Record for:OKL_TAX_SOURCES_V --
  -------------------------------------------
  FUNCTION Validate_Record (
    p_txsv_rec IN txsv_rec_type,
    p_db_txsv_rec IN txsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_txsv_rec IN txsv_rec_type,
      p_db_txsv_rec IN txsv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
    BEGIN
      l_return_status := validate_foreign_keys(p_txsv_rec, p_db_txsv_rec);
      RETURN (l_return_status);
    END Validate_Record;
    FUNCTION Validate_Record (
      p_txsv_rec IN txsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_db_txsv_rec                  txsv_rec_type := get_rec(p_txsv_rec);
    BEGIN
      l_return_status := Validate_Record(p_txsv_rec => p_txsv_rec,
                                         p_db_txsv_rec => l_db_txsv_rec);
      RETURN (l_return_status);
    END Validate_Record;
*/
    ---------------------------------------------------------------------------
    -- PROCEDURE Migrate
    ---------------------------------------------------------------------------
    PROCEDURE migrate (
      p_from IN txsv_rec_type,
      p_to   IN OUT NOCOPY txs_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.khr_id := p_from.khr_id;
      p_to.kle_id := p_from.kle_id;
      p_to.line_name := p_from.line_name;
      p_to.trx_id := p_from.trx_id;
      p_to.trx_line_id := p_from.trx_line_id;
      p_to.entity_code := p_from.entity_code;
      p_to.event_class_code := p_from.event_class_code;
      p_to.trx_level_type := p_from.trx_level_type;
      --p_to.trx_line_type := p_from.trx_line_type;
      p_to.adjusted_doc_entity_code := p_from.adjusted_doc_entity_code;
      p_to.adjusted_doc_event_class_code := p_from.adjusted_doc_event_class_code;
      p_to.adjusted_doc_trx_id := p_from.adjusted_doc_trx_id;
      p_to.adjusted_doc_trx_line_id := p_from.adjusted_doc_trx_line_id;
      p_to.adjusted_doc_trx_level_type := p_from.adjusted_doc_trx_level_type;
      p_to.adjusted_doc_number := p_from.adjusted_doc_number;
      p_to.adjusted_doc_date := p_from.adjusted_doc_date;
      p_to.tax_call_type_code := p_from.tax_call_type_code;
      p_to.sty_id := p_from.sty_id;
      p_to.trx_business_category := p_from.trx_business_category;
      p_to.tax_line_status_code := p_from.tax_line_status_code;
      p_to.sel_id := p_from.sel_id;
      p_to.reported_yn := p_from.reported_yn;
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
      p_to.application_id := p_from.application_id;
      p_to.default_taxation_country := p_from.default_taxation_country;
      p_to.product_category := p_from.product_category;
      p_to.user_defined_fisc_class := p_from.user_defined_fisc_class;
      p_to.line_intended_use := p_from.line_intended_use;
      p_to.inventory_item_id := p_from.inventory_item_id;
      p_to.bill_to_cust_acct_id := p_from.bill_to_cust_acct_id;
      p_to.org_id := p_from.org_id;
      p_to.legal_entity_id := p_from.legal_entity_id;
      p_to.line_amt := p_from.line_amt;
      p_to.assessable_value := p_from.assessable_value;
      p_to.total_tax := p_from.total_tax;
      p_to.product_type := p_from.product_type;
      p_to.product_fisc_classification := p_from.product_fisc_classification;
      p_to.trx_date := p_from.trx_date;
      p_to.provnl_tax_determination_date := p_from.provnl_tax_determination_date;
      p_to.try_id := p_from.try_id;
      p_to.ship_to_location_id := p_from.ship_to_location_id;

      p_to.trx_currency_code := p_from.trx_currency_code;
      p_to.currency_conversion_type := p_from.currency_conversion_type;
      p_to.currency_conversion_rate := p_from.currency_conversion_rate;
      p_to.currency_conversion_date := p_from.currency_conversion_date;
      -- Modified by dcshanmu for eBTax - modification end
      --asawanka ebtax changes start
      p_to.asset_number := p_from.asset_number;
      p_to.reported_yn := p_from.reported_yn;
      p_to.SHIP_TO_PARTY_SITE_ID := p_from.SHIP_TO_PARTY_SITE_ID;
      p_to.SHIP_TO_PARTY_ID := p_from.SHIP_TO_PARTY_ID;
      p_to.BILL_TO_PARTY_SITE_ID := p_from.BILL_TO_PARTY_SITE_ID;
      p_to.BILL_TO_LOCATION_ID := p_from.BILL_TO_LOCATION_ID;
      p_to.BILL_TO_PARTY_ID := p_from.BILL_TO_PARTY_ID;
      p_to.ship_to_cust_acct_site_use_id := p_from.ship_to_cust_acct_site_use_id;
      p_to.bill_to_cust_acct_site_use_id := p_from.bill_to_cust_acct_site_use_id;
      p_to.TAX_CLASSIFICATION_CODE := p_from.TAX_CLASSIFICATION_CODE;
            --asawanka ebtax changes end
      p_to.ALC_SERIALIZED_YN := p_from.ALC_SERIALIZED_YN;
      p_to.ALC_SERIALIZED_TOTAL_TAX := p_from.ALC_SERIALIZED_TOTAL_TAX;
      p_to.ALC_SERIALIZED_TOTAL_LINE_AMT := p_from.ALC_SERIALIZED_TOTAL_LINE_AMT;
    END migrate;
    PROCEDURE migrate (
      p_from IN txs_rec_type,
      p_to   IN OUT NOCOPY txsv_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.khr_id := p_from.khr_id;
      p_to.kle_id := p_from.kle_id;
      p_to.line_name := p_from.line_name;
      p_to.trx_id := p_from.trx_id;
      p_to.trx_line_id := p_from.trx_line_id;
      p_to.entity_code := p_from.entity_code;
      p_to.event_class_code := p_from.event_class_code;
      p_to.trx_level_type := p_from.trx_level_type;
     -- p_to.trx_line_type := p_from.trx_line_type;
      p_to.adjusted_doc_entity_code := p_from.adjusted_doc_entity_code;
      p_to.adjusted_doc_event_class_code := p_from.adjusted_doc_event_class_code;
      p_to.adjusted_doc_trx_id := p_from.adjusted_doc_trx_id;
      p_to.adjusted_doc_trx_line_id := p_from.adjusted_doc_trx_line_id;
      p_to.adjusted_doc_trx_level_type := p_from.adjusted_doc_trx_level_type;
      p_to.adjusted_doc_number := p_from.adjusted_doc_number;
      p_to.adjusted_doc_date := p_from.adjusted_doc_date;
      p_to.tax_call_type_code := p_from.tax_call_type_code;
      p_to.sty_id := p_from.sty_id;
      p_to.trx_business_category := p_from.trx_business_category;
      p_to.tax_line_status_code := p_from.tax_line_status_code;
      p_to.sel_id := p_from.sel_id;
      p_to.reported_yn := p_from.reported_yn;
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
      p_to.application_id := p_from.application_id;
      p_to.default_taxation_country := p_from.default_taxation_country;
      p_to.product_category := p_from.product_category;
      p_to.user_defined_fisc_class := p_from.user_defined_fisc_class;
      p_to.line_intended_use := p_from.line_intended_use;
      p_to.inventory_item_id := p_from.inventory_item_id;
      p_to.bill_to_cust_acct_id := p_from.bill_to_cust_acct_id;
      p_to.org_id := p_from.org_id;
      p_to.legal_entity_id := p_from.legal_entity_id;
      p_to.line_amt := p_from.line_amt;
      p_to.assessable_value := p_from.assessable_value;
      p_to.total_tax := p_from.total_tax;
      p_to.product_type := p_from.product_type;
      p_to.product_fisc_classification := p_from.product_fisc_classification;
      p_to.trx_date := p_from.trx_date;
      p_to.provnl_tax_determination_date := p_from.provnl_tax_determination_date;
      p_to.try_id := p_from.try_id;
      p_to.ship_to_location_id := p_from.ship_to_location_id;
      p_to.trx_currency_code := p_from.trx_currency_code;
      p_to.currency_conversion_type := p_from.currency_conversion_type;
      p_to.currency_conversion_rate := p_from.currency_conversion_rate;
      p_to.currency_conversion_date := p_from.currency_conversion_date;
      -- Modified by dcshanmu for eBTax - modification end
            --asawanka ebtax changes start
      p_to.asset_number := p_from.asset_number;
      p_to.reported_yn := p_from.reported_yn;
      p_to.SHIP_TO_PARTY_SITE_ID := p_from.SHIP_TO_PARTY_SITE_ID;
      p_to.SHIP_TO_PARTY_ID := p_from.SHIP_TO_PARTY_ID;
      p_to.BILL_TO_PARTY_SITE_ID := p_from.BILL_TO_PARTY_SITE_ID;
      p_to.BILL_TO_LOCATION_ID := p_from.BILL_TO_LOCATION_ID;
      p_to.BILL_TO_PARTY_ID := p_from.BILL_TO_PARTY_ID;
      p_to.ship_to_cust_acct_site_use_id := p_from.ship_to_cust_acct_site_use_id;
      p_to.bill_to_cust_acct_site_use_id := p_from.bill_to_cust_acct_site_use_id;
      p_to.TAX_CLASSIFICATION_CODE := p_from.TAX_CLASSIFICATION_CODE;
            --asawanka ebtax changes end
      p_to.ALC_SERIALIZED_YN := p_from.ALC_SERIALIZED_YN;
      p_to.ALC_SERIALIZED_TOTAL_TAX := p_from.ALC_SERIALIZED_TOTAL_TAX;
      p_to.ALC_SERIALIZED_TOTAL_LINE_AMT := p_from.ALC_SERIALIZED_TOTAL_LINE_AMT;
    END migrate;
    ---------------------------------------------------------------------------
    -- PROCEDURE validate_row
    ---------------------------------------------------------------------------
    ----------------------------------------
    -- validate_row for:OKL_TAX_SOURCES_V --
    ----------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_rec                     IN txsv_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_txsv_rec                     txsv_rec_type := p_txsv_rec;
      l_txs_rec                      txs_rec_type;
      l_txs_rec                      txs_rec_type;
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
      l_return_status := Validate_Attributes(l_txsv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

     /* l_return_status := Validate_Record(l_txsv_rec);
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
    ---------------------------------------------------
    -- PL/SQL TBL validate_row for:OKL_TAX_SOURCES_V --
    ---------------------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_tbl                     IN txsv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
      i                              NUMBER := 0;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_txsv_tbl.COUNT > 0) THEN
        i := p_txsv_tbl.FIRST;
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
              p_txsv_rec                     => p_txsv_tbl(i));
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
          EXIT WHEN (i = p_txsv_tbl.LAST);
          i := p_txsv_tbl.NEXT(i);
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
    -- PL/SQL TBL validate_row for:OKL_TAX_SOURCES_V --
    ---------------------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_tbl                     IN txsv_tbl_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_txsv_tbl.COUNT > 0) THEN
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_txsv_tbl                     => p_txsv_tbl,
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
    ------------------------------------
    -- insert_row for:OKL_TAX_SOURCES --
    ------------------------------------
    PROCEDURE insert_row(
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txs_rec                      IN txs_rec_type,
      x_txs_rec                      OUT NOCOPY txs_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_txs_rec                      txs_rec_type := p_txs_rec;
      l_def_txs_rec                  txs_rec_type;
      ----------------------------------------
      -- Set_Attributes for:OKL_TAX_SOURCES --
      ----------------------------------------
      FUNCTION Set_Attributes (
        p_txs_rec IN txs_rec_type,
        x_txs_rec OUT NOCOPY txs_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_txs_rec := p_txs_rec;
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
        p_txs_rec,                         -- IN
        l_txs_rec);                        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      INSERT INTO OKL_TAX_SOURCES(
        id,
        khr_id,
        kle_id,
	    line_name,
        trx_id,
        trx_line_id,
        entity_code,
        event_class_code,
        trx_level_type,
      --  trx_line_type,
        adjusted_doc_entity_code,
        adjusted_doc_event_class_code,
        adjusted_doc_trx_id,
        adjusted_doc_trx_line_id,
        adjusted_doc_trx_level_type,
        adjusted_doc_number,
        adjusted_doc_date,
        tax_call_type_code,
        sty_id,
        trx_business_category,
        tax_line_status_code,
        sel_id,
        tax_reporting_flag,
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
	application_id,
	default_taxation_country,
	product_category,
	user_defined_fisc_class,
	line_intended_use,
	inventory_item_id,
	bill_to_cust_acct_id,
	org_id,
	legal_entity_id,
	line_amt,
	assessable_value,
	total_tax,
	product_type,
	product_fisc_classification,
	trx_date,
	provnl_tax_determination_date,
	try_id,
	ship_to_location_id,
	trx_currency_code,
	currency_conversion_type,
	currency_conversion_rate,
	currency_conversion_date,
	-- Modified by dcshanmu for eBTax - modification end
	--asawanka ebtax changes start
	asset_number
	,  reported_yn
,SHIP_TO_PARTY_SITE_ID
,SHIP_TO_PARTY_ID
,BILL_TO_PARTY_SITE_ID
,BILL_TO_LOCATION_ID
,BILL_TO_PARTY_ID
,ship_to_cust_acct_site_use_id
,bill_to_cust_acct_site_use_id
,TAX_CLASSIFICATION_CODE
--asawanka ebtax changes end
,ALC_SERIALIZED_YN
,ALC_SERIALIZED_TOTAL_TAX
,ALC_SERIALIZED_TOTAL_LINE_AMT)
      VALUES (
        l_txs_rec.id,
        l_txs_rec.khr_id,
        l_txs_rec.kle_id,
        l_txs_rec.line_name,
        l_txs_rec.trx_id,
        l_txs_rec.trx_line_id,
        l_txs_rec.entity_code,
        l_txs_rec.event_class_code,
        l_txs_rec.trx_level_type,
       -- l_txs_rec.trx_line_type,
        l_txs_rec.adjusted_doc_entity_code,
        l_txs_rec.adjusted_doc_event_class_code,
        l_txs_rec.adjusted_doc_trx_id,
        l_txs_rec.adjusted_doc_trx_line_id,
        l_txs_rec.adjusted_doc_trx_level_type,
        l_txs_rec.adjusted_doc_number,
        l_txs_rec.adjusted_doc_date,
        l_txs_rec.tax_call_type_code,
        l_txs_rec.sty_id,
        l_txs_rec.trx_business_category,
        l_txs_rec.tax_line_status_code,
        l_txs_rec.sel_id,
        l_txs_rec.reported_yn,
        l_txs_rec.program_id,
        l_txs_rec.request_id,
        l_txs_rec.program_application_id,
        l_txs_rec.program_update_date,
        l_txs_rec.attribute_category,
        l_txs_rec.attribute1,
        l_txs_rec.attribute2,
        l_txs_rec.attribute3,
        l_txs_rec.attribute4,
        l_txs_rec.attribute5,
        l_txs_rec.attribute6,
        l_txs_rec.attribute7,
        l_txs_rec.attribute8,
        l_txs_rec.attribute9,
        l_txs_rec.attribute10,
        l_txs_rec.attribute11,
        l_txs_rec.attribute12,
        l_txs_rec.attribute13,
        l_txs_rec.attribute14,
        l_txs_rec.attribute15,
        l_txs_rec.created_by,
        l_txs_rec.creation_date,
        l_txs_rec.last_updated_by,
        l_txs_rec.last_update_date,
        l_txs_rec.last_update_login,
        l_txs_rec.object_version_number,
	-- Modified by dcshanmu for eBTax - modification starts
        l_txs_rec.application_id,
        l_txs_rec.default_taxation_country,
        l_txs_rec.product_category,
        l_txs_rec.user_defined_fisc_class,
        l_txs_rec.line_intended_use,
        l_txs_rec.inventory_item_id,
        l_txs_rec.bill_to_cust_acct_id,
        l_txs_rec.org_id,
        l_txs_rec.legal_entity_id,
        l_txs_rec.line_amt,
        l_txs_rec.assessable_value,
        l_txs_rec.total_tax,
        l_txs_rec.product_type,
        l_txs_rec.product_fisc_classification,
        l_txs_rec.trx_date,
        l_txs_rec.provnl_tax_determination_date,
        l_txs_rec.try_id,
        l_txs_rec.ship_to_location_id,

        l_txs_rec.trx_currency_code,
        l_txs_rec.currency_conversion_type,
        l_txs_rec.currency_conversion_rate,
        l_txs_rec.currency_conversion_date
	-- Modified by dcshanmu for eBTax - modification end
	--asawanka ebtax changes start
	          ,l_txs_rec.asset_number
        ,l_txs_rec.reported_yn
        ,l_txs_rec.SHIP_TO_PARTY_SITE_ID
        ,l_txs_rec.SHIP_TO_PARTY_ID
        ,l_txs_rec.BILL_TO_PARTY_SITE_ID
        ,l_txs_rec.BILL_TO_LOCATION_ID
        ,l_txs_rec.BILL_TO_PARTY_ID
        ,l_txs_rec.ship_to_cust_acct_site_use_id
        ,l_txs_rec.bill_to_cust_acct_site_use_id
        ,l_txs_rec.TAX_CLASSIFICATION_CODE
        	--asawanka ebtax changes end
        ,l_txs_rec.ALC_SERIALIZED_YN
        ,l_txs_rec.ALC_SERIALIZED_TOTAL_TAX
        ,l_txs_rec.ALC_SERIALIZED_TOTAL_LINE_AMT
        );
      -- Set OUT values
      x_txs_rec := l_txs_rec;
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
    -- insert_row for :OKL_TAX_SOURCES_V --
    ---------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_rec                     IN txsv_rec_type,
      x_txsv_rec                     OUT NOCOPY txsv_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_txsv_rec                     txsv_rec_type := p_txsv_rec;
      l_def_txsv_rec                 txsv_rec_type;
      l_txs_rec                      txs_rec_type;
      lx_txs_rec                     txs_rec_type;
      -------------------------------
      -- FUNCTION fill_who_columns --
      -------------------------------
      FUNCTION fill_who_columns (
        p_txsv_rec IN txsv_rec_type
      ) RETURN txsv_rec_type IS
        l_txsv_rec txsv_rec_type := p_txsv_rec;
      BEGIN
        l_txsv_rec.CREATION_DATE := SYSDATE;
        l_txsv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
        l_txsv_rec.LAST_UPDATE_DATE := l_txsv_rec.CREATION_DATE;
        l_txsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_txsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_txsv_rec);
      END fill_who_columns;
      ------------------------------------------
      -- Set_Attributes for:OKL_TAX_SOURCES_V --
      ------------------------------------------
      FUNCTION Set_Attributes (
        p_txsv_rec IN txsv_rec_type,
        x_txsv_rec OUT NOCOPY txsv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_txsv_rec := p_txsv_rec;
        x_txsv_rec.OBJECT_VERSION_NUMBER := 1;
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
      l_txsv_rec := null_out_defaults(p_txsv_rec);
      -- Set primary key value
      l_txsv_rec.ID := get_seq_id;
      -- Setting item attributes
      l_return_Status := Set_Attributes(
        l_txsv_rec,                        -- IN
        l_def_txsv_rec);                   -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_def_txsv_rec := fill_who_columns(l_def_txsv_rec);
      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_def_txsv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      /*l_return_status := Validate_Record(l_def_txsv_rec);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      */
      -----------------------------------------
      -- Move VIEW record to "Child" records --
      -----------------------------------------
      migrate(l_def_txsv_rec, l_txs_rec);
      -----------------------------------------------
      -- Call the INSERT_ROW for each child record --
      -----------------------------------------------
      insert_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_txs_rec,
        lx_txs_rec
      );
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_txs_rec, l_def_txsv_rec);
      -- Set OUT values
      x_txsv_rec := l_def_txsv_rec;
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
    -- PL/SQL TBL insert_row for:TXSV_TBL --
    ----------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_tbl                     IN txsv_tbl_type,
      x_txsv_tbl                     OUT NOCOPY txsv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
      i                              NUMBER := 0;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_txsv_tbl.COUNT > 0) THEN
        i := p_txsv_tbl.FIRST;
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
              p_txsv_rec                     => p_txsv_tbl(i),
              x_txsv_rec                     => x_txsv_tbl(i));
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
          EXIT WHEN (i = p_txsv_tbl.LAST);
          i := p_txsv_tbl.NEXT(i);
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
    -- PL/SQL TBL insert_row for:TXSV_TBL --
    ----------------------------------------
    -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
    -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_tbl                     IN txsv_tbl_type,
      x_txsv_tbl                     OUT NOCOPY txsv_tbl_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_txsv_tbl.COUNT > 0) THEN
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_txsv_tbl                     => p_txsv_tbl,
          x_txsv_tbl                     => x_txsv_tbl,
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
    ----------------------------------
    -- lock_row for:OKL_TAX_SOURCES --
    ----------------------------------
    PROCEDURE lock_row(
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txs_rec                      IN txs_rec_type) IS

      E_Resource_Busy                EXCEPTION;
      PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
      CURSOR lock_csr (p_txs_rec IN txs_rec_type) IS
      SELECT OBJECT_VERSION_NUMBER
        FROM OKL_TAX_SOURCES
       WHERE ID = p_txs_rec.id
         AND OBJECT_VERSION_NUMBER = p_txs_rec.object_version_number
      FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

      CURSOR lchk_csr (p_txs_rec IN txs_rec_type) IS
      SELECT OBJECT_VERSION_NUMBER
        FROM OKL_TAX_SOURCES
       WHERE ID = p_txs_rec.id;
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_object_version_number        OKL_TAX_SOURCES.OBJECT_VERSION_NUMBER%TYPE;
      lc_object_version_number       OKL_TAX_SOURCES.OBJECT_VERSION_NUMBER%TYPE;
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
        OPEN lock_csr(p_txs_rec);
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
        OPEN lchk_csr(p_txs_rec);
        FETCH lchk_csr INTO lc_object_version_number;
        lc_row_notfound := lchk_csr%NOTFOUND;
        CLOSE lchk_csr;
      END IF;
      IF (lc_row_notfound) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number > p_txs_rec.object_version_number THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number <> p_txs_rec.object_version_number THEN
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
    -- lock_row for: OKL_TAX_SOURCES_V --
    -------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_rec                     IN txsv_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_txs_rec                      txs_rec_type;
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
      migrate(p_txsv_rec, l_txs_rec);
      ---------------------------------------------
      -- Call the LOCK_ROW for each child record --
      ---------------------------------------------
      lock_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_txs_rec
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
    -- PL/SQL TBL lock_row for:TXSV_TBL --
    --------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_tbl                     IN txsv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
      i                              NUMBER := 0;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has recrods in it before passing
      IF (p_txsv_tbl.COUNT > 0) THEN
        i := p_txsv_tbl.FIRST;
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
              p_txsv_rec                     => p_txsv_tbl(i));
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
          EXIT WHEN (i = p_txsv_tbl.LAST);
          i := p_txsv_tbl.NEXT(i);
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
    -- PL/SQL TBL lock_row for:TXSV_TBL --
    --------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_tbl                     IN txsv_tbl_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has recrods in it before passing
      IF (p_txsv_tbl.COUNT > 0) THEN
        lock_row(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_txsv_tbl                     => p_txsv_tbl,
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
    ------------------------------------
    -- update_row for:OKL_TAX_SOURCES --
    ------------------------------------
    PROCEDURE update_row(
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txs_rec                      IN txs_rec_type,
      x_txs_rec                      OUT NOCOPY txs_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_txs_rec                      txs_rec_type := p_txs_rec;
      l_def_txs_rec                  txs_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_txs_rec IN txs_rec_type,
        x_txs_rec OUT NOCOPY txs_rec_type
      ) RETURN VARCHAR2 IS
        l_txs_rec                      txs_rec_type;
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_txs_rec := p_txs_rec;
        -- Get current database values
        l_txs_rec := get_rec(p_txs_rec, l_return_status);
        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_txs_rec.id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.id := l_txs_rec.id;
          END IF;
          IF (x_txs_rec.khr_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.khr_id := l_txs_rec.khr_id;
          END IF;
          IF (x_txs_rec.kle_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.kle_id := l_txs_rec.kle_id;
          END IF;
          IF (x_txs_rec.line_name = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.line_name := l_txs_rec.line_name;
          END IF;
          IF (x_txs_rec.trx_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.trx_id := l_txs_rec.trx_id;
          END IF;
          IF (x_txs_rec.trx_line_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.trx_line_id := l_txs_rec.trx_line_id;
          END IF;
          IF (x_txs_rec.entity_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.entity_code := l_txs_rec.entity_code;
          END IF;
          IF (x_txs_rec.event_class_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.event_class_code := l_txs_rec.event_class_code;
          END IF;
          IF (x_txs_rec.trx_level_type = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.trx_level_type := l_txs_rec.trx_level_type;
          END IF;
        /*  IF (x_txs_rec.trx_line_type = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.trx_line_type := l_txs_rec.trx_line_type;
          END IF;*/
          IF (x_txs_rec.adjusted_doc_entity_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.adjusted_doc_entity_code := l_txs_rec.adjusted_doc_entity_code;
          END IF;
          IF (x_txs_rec.adjusted_doc_event_class_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.adjusted_doc_event_class_code := l_txs_rec.adjusted_doc_event_class_code;
          END IF;
          IF (x_txs_rec.adjusted_doc_trx_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.adjusted_doc_trx_id := l_txs_rec.adjusted_doc_trx_id;
          END IF;
          IF (x_txs_rec.adjusted_doc_trx_line_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.adjusted_doc_trx_line_id := l_txs_rec.adjusted_doc_trx_line_id;
          END IF;
          IF (x_txs_rec.adjusted_doc_trx_level_type = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.adjusted_doc_trx_level_type := l_txs_rec.adjusted_doc_trx_level_type;
          END IF;
          IF (x_txs_rec.adjusted_doc_number = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.adjusted_doc_number := l_txs_rec.adjusted_doc_number;
          END IF;
          IF (x_txs_rec.adjusted_doc_date = OKL_API.G_MISS_DATE)
          THEN
            x_txs_rec.adjusted_doc_date := l_txs_rec.adjusted_doc_date;
          END IF;
          IF (x_txs_rec.tax_call_type_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.tax_call_type_code := l_txs_rec.tax_call_type_code;
          END IF;
          IF (x_txs_rec.sty_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.sty_id := l_txs_rec.sty_id;
          END IF;
          IF (x_txs_rec.trx_business_category = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.trx_business_category := l_txs_rec.trx_business_category;
          END IF;
          IF (x_txs_rec.tax_line_status_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.tax_line_status_code := l_txs_rec.tax_line_status_code;
          END IF;
          IF (x_txs_rec.sel_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.sel_id := l_txs_rec.sel_id;
          END IF;
          IF (x_txs_rec.reported_yn = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.reported_yn := l_txs_rec.reported_yn;
          END IF;
          IF (x_txs_rec.program_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.program_id := l_txs_rec.program_id;
          END IF;
          IF (x_txs_rec.request_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.request_id := l_txs_rec.request_id;
          END IF;
          IF (x_txs_rec.program_application_id = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.program_application_id := l_txs_rec.program_application_id;
          END IF;
          IF (x_txs_rec.program_update_date = OKL_API.G_MISS_DATE)
          THEN
            x_txs_rec.program_update_date := l_txs_rec.program_update_date;
          END IF;
          IF (x_txs_rec.attribute_category = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute_category := l_txs_rec.attribute_category;
          END IF;
          IF (x_txs_rec.attribute1 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute1 := l_txs_rec.attribute1;
          END IF;
          IF (x_txs_rec.attribute2 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute2 := l_txs_rec.attribute2;
          END IF;
          IF (x_txs_rec.attribute3 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute3 := l_txs_rec.attribute3;
          END IF;
          IF (x_txs_rec.attribute4 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute4 := l_txs_rec.attribute4;
          END IF;
          IF (x_txs_rec.attribute5 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute5 := l_txs_rec.attribute5;
          END IF;
          IF (x_txs_rec.attribute6 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute6 := l_txs_rec.attribute6;
          END IF;
          IF (x_txs_rec.attribute7 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute7 := l_txs_rec.attribute7;
          END IF;
          IF (x_txs_rec.attribute8 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute8 := l_txs_rec.attribute8;
          END IF;
          IF (x_txs_rec.attribute9 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute9 := l_txs_rec.attribute9;
          END IF;
          IF (x_txs_rec.attribute10 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute10 := l_txs_rec.attribute10;
          END IF;
          IF (x_txs_rec.attribute11 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute11 := l_txs_rec.attribute11;
          END IF;
          IF (x_txs_rec.attribute12 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute12 := l_txs_rec.attribute12;
          END IF;
          IF (x_txs_rec.attribute13 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute13 := l_txs_rec.attribute13;
          END IF;
          IF (x_txs_rec.attribute14 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute14 := l_txs_rec.attribute14;
          END IF;
          IF (x_txs_rec.attribute15 = OKL_API.G_MISS_CHAR)
          THEN
            x_txs_rec.attribute15 := l_txs_rec.attribute15;
          END IF;
          IF (x_txs_rec.created_by = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.created_by := l_txs_rec.created_by;
          END IF;
          IF (x_txs_rec.creation_date = OKL_API.G_MISS_DATE)
          THEN
            x_txs_rec.creation_date := l_txs_rec.creation_date;
          END IF;
          IF (x_txs_rec.last_updated_by = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.last_updated_by := l_txs_rec.last_updated_by;
          END IF;
          IF (x_txs_rec.last_update_date = OKL_API.G_MISS_DATE)
          THEN
            x_txs_rec.last_update_date := l_txs_rec.last_update_date;
          END IF;
          IF (x_txs_rec.last_update_login = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.last_update_login := l_txs_rec.last_update_login;
          END IF;
          IF (x_txs_rec.object_version_number = OKL_API.G_MISS_NUM)
          THEN
            x_txs_rec.object_version_number := l_txs_rec.object_version_number;
          END IF;

	  -- Modified by dcshanmu for eBTax - modification starts
          IF (x_txs_rec.application_id = OKL_API.G_MISS_NUM ) THEN
            x_txs_rec.application_id := l_txs_rec.application_id;
          END IF;
          IF (x_txs_rec.default_taxation_country = OKL_API.G_MISS_CHAR ) THEN
            x_txs_rec.default_taxation_country := l_txs_rec.default_taxation_country;
          END IF;
	  IF (x_txs_rec.product_category = OKL_API.G_MISS_CHAR ) THEN
	    x_txs_rec.product_category := l_txs_rec.product_category;
	  END IF;
	  IF (x_txs_rec.user_defined_fisc_class = OKL_API.G_MISS_CHAR ) THEN
	    x_txs_rec.user_defined_fisc_class := l_txs_rec.user_defined_fisc_class;
          END IF;
	  IF (x_txs_rec.line_intended_use = OKL_API.G_MISS_CHAR ) THEN
	    x_txs_rec.line_intended_use := l_txs_rec.line_intended_use;
	  END IF;
	  IF (x_txs_rec.inventory_item_id = OKL_API.G_MISS_NUM ) THEN
	    x_txs_rec.inventory_item_id := l_txs_rec.inventory_item_id;
	  END IF;
	  IF (x_txs_rec.bill_to_cust_acct_id = OKL_API.G_MISS_NUM ) THEN
	    x_txs_rec.bill_to_cust_acct_id := l_txs_rec.bill_to_cust_acct_id;
	  END IF;
	  IF (x_txs_rec.org_id = OKL_API.G_MISS_NUM ) THEN
	    x_txs_rec.org_id := l_txs_rec.org_id;
	  END IF;
	  IF (x_txs_rec.legal_entity_id = OKL_API.G_MISS_NUM ) THEN
	    x_txs_rec.legal_entity_id := l_txs_rec.legal_entity_id;
	  END IF;
	  IF (x_txs_rec.line_amt = OKL_API.G_MISS_NUM ) THEN
	    x_txs_rec.line_amt := l_txs_rec.line_amt;
	  END IF;
	  IF (x_txs_rec.assessable_value = OKL_API.G_MISS_NUM ) THEN
	    x_txs_rec.assessable_value := l_txs_rec.assessable_value;
	  END IF;
	  IF (x_txs_rec.total_tax = OKL_API.G_MISS_NUM ) THEN
	    x_txs_rec.total_tax := l_txs_rec.total_tax;
	  END IF;
	  IF (x_txs_rec.product_type = OKL_API.G_MISS_CHAR ) THEN
	    x_txs_rec.product_type := l_txs_rec.product_type;
	  END IF;
	  IF (x_txs_rec.product_fisc_classification = OKL_API.G_MISS_CHAR ) THEN
	    x_txs_rec.product_fisc_classification := l_txs_rec.product_fisc_classification;
          END IF;
	  IF (x_txs_rec.trx_date = OKL_API.G_MISS_DATE ) THEN
	    x_txs_rec.trx_date := l_txs_rec.trx_date;
	  END IF;
	  IF (x_txs_rec.provnl_tax_determination_date = OKL_API.G_MISS_DATE ) THEN
	    x_txs_rec.provnl_tax_determination_date := l_txs_rec.provnl_tax_determination_date;
	  END IF;
	  IF (x_txs_rec.try_id = OKL_API.G_MISS_NUM ) THEN
	    x_txs_rec.try_id := l_txs_rec.try_id;
	  END IF;
	  IF (x_txs_rec.ship_to_location_id = OKL_API.G_MISS_NUM ) THEN
	    x_txs_rec.ship_to_location_id := l_txs_rec.ship_to_location_id;
	  END IF;

	  IF (x_txs_rec.trx_currency_code = OKL_API.G_MISS_CHAR ) THEN
	    x_txs_rec.trx_currency_code := l_txs_rec.trx_currency_code;
	  END IF;
	  IF (x_txs_rec.currency_conversion_type = OKL_API.G_MISS_CHAR ) THEN
	    x_txs_rec.currency_conversion_type := l_txs_rec.currency_conversion_type;
	  END IF;
	  IF (x_txs_rec.currency_conversion_rate = OKL_API.G_MISS_NUM ) THEN
	    x_txs_rec.currency_conversion_rate := l_txs_rec.currency_conversion_rate;
	  END IF;
	  IF (x_txs_rec.currency_conversion_date = OKL_API.G_MISS_DATE ) THEN
	    x_txs_rec.currency_conversion_date := l_txs_rec.currency_conversion_date;
	  END IF;
	  -- Modified by dcshanmu for eBTax - modification end
       --asawanka ebtax changes start
        IF (x_txs_rec.asset_number = OKL_API.G_MISS_CHAR ) THEN
	      x_txs_rec.asset_number := l_txs_rec.asset_number;
	    END IF;
	    IF (x_txs_rec.reported_yn = OKL_API.G_MISS_CHAR ) THEN
	      x_txs_rec.reported_yn := l_txs_rec.reported_yn;
	    END IF;
	    IF (x_txs_rec.SHIP_TO_PARTY_SITE_ID = OKL_API.G_MISS_NUM ) THEN
	      x_txs_rec.SHIP_TO_PARTY_SITE_ID := l_txs_rec.SHIP_TO_PARTY_SITE_ID;
	    END IF;
	    IF (x_txs_rec.SHIP_TO_PARTY_ID = OKL_API.G_MISS_NUM ) THEN
	      x_txs_rec.SHIP_TO_PARTY_ID := l_txs_rec.SHIP_TO_PARTY_ID;
	    END IF;
	    IF (x_txs_rec.BILL_TO_PARTY_SITE_ID = OKL_API.G_MISS_NUM ) THEN
	      x_txs_rec.BILL_TO_PARTY_SITE_ID := l_txs_rec.BILL_TO_PARTY_SITE_ID;
	    END IF;
	    IF (x_txs_rec.BILL_TO_LOCATION_ID = OKL_API.G_MISS_NUM ) THEN
	      x_txs_rec.BILL_TO_LOCATION_ID := l_txs_rec.BILL_TO_LOCATION_ID;
	    END IF;
	    IF (x_txs_rec.BILL_TO_PARTY_ID = OKL_API.G_MISS_NUM ) THEN
	      x_txs_rec.BILL_TO_PARTY_ID := l_txs_rec.BILL_TO_PARTY_ID;
	    END IF;
	    IF (x_txs_rec.ship_to_cust_acct_site_use_id = OKL_API.G_MISS_NUM ) THEN
	      x_txs_rec.ship_to_cust_acct_site_use_id := l_txs_rec.ship_to_cust_acct_site_use_id;
	    END IF;
	    IF (x_txs_rec.bill_to_cust_acct_site_use_id = OKL_API.G_MISS_NUM ) THEN
	      x_txs_rec.bill_to_cust_acct_site_use_id := l_txs_rec.bill_to_cust_acct_site_use_id;
	    END IF;
	    IF (x_txs_rec.TAX_CLASSIFICATION_CODE = OKL_API.G_MISS_CHAR) THEN
	      x_txs_rec.TAX_CLASSIFICATION_CODE := l_txs_rec.TAX_CLASSIFICATION_CODE;
	    END IF;
       --asawanka ebtax changes end

	    IF (x_txs_rec.ALC_SERIALIZED_YN = OKL_API.G_MISS_CHAR) THEN
	      x_txs_rec.ALC_SERIALIZED_YN := l_txs_rec.ALC_SERIALIZED_YN;
	    END IF;
	    IF (x_txs_rec.ALC_SERIALIZED_TOTAL_TAX = OKL_API.G_MISS_NUM) THEN
	      x_txs_rec.ALC_SERIALIZED_TOTAL_TAX := l_txs_rec.ALC_SERIALIZED_TOTAL_TAX;
	    END IF;
	    IF (x_txs_rec.ALC_SERIALIZED_TOTAL_LINE_AMT = OKL_API.G_MISS_NUM) THEN
	      x_txs_rec.ALC_SERIALIZED_TOTAL_LINE_AMT := l_txs_rec.ALC_SERIALIZED_TOTAL_LINE_AMT;
	    END IF;

        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      ----------------------------------------
      -- Set_Attributes for:OKL_TAX_SOURCES --
      ----------------------------------------
      FUNCTION Set_Attributes (
        p_txs_rec IN txs_rec_type,
        x_txs_rec OUT NOCOPY txs_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_txs_rec := p_txs_rec;
        x_txs_rec.OBJECT_VERSION_NUMBER := p_txs_rec.OBJECT_VERSION_NUMBER + 1;
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
        p_txs_rec,                         -- IN
        l_txs_rec);                        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_txs_rec, l_def_txs_rec);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      UPDATE OKL_TAX_SOURCES
      SET KHR_ID = l_def_txs_rec.khr_id,
          KLE_ID = l_def_txs_rec.kle_id,
          LINE_NAME = l_def_txs_rec.line_name,
          TRX_ID = l_def_txs_rec.trx_id,
          TRX_LINE_ID = l_def_txs_rec.trx_line_id,
          ENTITY_CODE = l_def_txs_rec.entity_code,
          EVENT_CLASS_CODE = l_def_txs_rec.event_class_code,
          TRX_LEVEL_TYPE = l_def_txs_rec.trx_level_type,
        --  TRX_LINE_TYPE = l_def_txs_rec.trx_line_type,
          ADJUSTED_DOC_ENTITY_CODE = l_def_txs_rec.adjusted_doc_entity_code,
          ADJUSTED_DOC_EVENT_CLASS_CODE = l_def_txs_rec.adjusted_doc_event_class_code,
          ADJUSTED_DOC_TRX_ID = l_def_txs_rec.adjusted_doc_trx_id,
          ADJUSTED_DOC_TRX_LINE_ID = l_def_txs_rec.adjusted_doc_trx_line_id,
          ADJUSTED_DOC_TRX_LEVEL_TYPE = l_def_txs_rec.adjusted_doc_trx_level_type,
          ADJUSTED_DOC_NUMBER = l_def_txs_rec.adjusted_doc_number,
          ADJUSTED_DOC_DATE = l_def_txs_rec.adjusted_doc_date,
          TAX_CALL_TYPE_CODE = l_def_txs_rec.tax_call_type_code,
          STY_ID = l_def_txs_rec.sty_id,
          TRX_BUSINESS_CATEGORY = l_def_txs_rec.trx_business_category,
          TAX_LINE_STATUS_CODE = l_def_txs_rec.tax_line_status_code,
          SEL_ID = l_def_txs_rec.sel_id,
          TAX_REPORTING_FLAG = l_def_txs_rec.reported_yn,
          PROGRAM_ID = l_def_txs_rec.program_id,
          REQUEST_ID = l_def_txs_rec.request_id,
          PROGRAM_APPLICATION_ID = l_def_txs_rec.program_application_id,
          PROGRAM_UPDATE_DATE = l_def_txs_rec.program_update_date,
          ATTRIBUTE_CATEGORY = l_def_txs_rec.attribute_category,
          ATTRIBUTE1 = l_def_txs_rec.attribute1,
          ATTRIBUTE2 = l_def_txs_rec.attribute2,
          ATTRIBUTE3 = l_def_txs_rec.attribute3,
          ATTRIBUTE4 = l_def_txs_rec.attribute4,
          ATTRIBUTE5 = l_def_txs_rec.attribute5,
          ATTRIBUTE6 = l_def_txs_rec.attribute6,
          ATTRIBUTE7 = l_def_txs_rec.attribute7,
          ATTRIBUTE8 = l_def_txs_rec.attribute8,
          ATTRIBUTE9 = l_def_txs_rec.attribute9,
          ATTRIBUTE10 = l_def_txs_rec.attribute10,
          ATTRIBUTE11 = l_def_txs_rec.attribute11,
          ATTRIBUTE12 = l_def_txs_rec.attribute12,
          ATTRIBUTE13 = l_def_txs_rec.attribute13,
          ATTRIBUTE14 = l_def_txs_rec.attribute14,
          ATTRIBUTE15 = l_def_txs_rec.attribute15,
          CREATED_BY = l_def_txs_rec.created_by,
          CREATION_DATE = l_def_txs_rec.creation_date,
          LAST_UPDATED_BY = l_def_txs_rec.last_updated_by,
          LAST_UPDATE_DATE = l_def_txs_rec.last_update_date,
          LAST_UPDATE_LOGIN = l_def_txs_rec.last_update_login,
          OBJECT_VERSION_NUMBER = l_def_txs_rec.object_version_number,
	  -- Modified by dcshanmu for eBTax - modification starts
	  APPLICATION_ID = l_def_txs_rec.application_id,
          DEFAULT_TAXATION_COUNTRY = l_def_txs_rec.default_taxation_country,
          PRODUCT_CATEGORY = l_def_txs_rec.product_category,
          USER_DEFINED_FISC_CLASS = l_def_txs_rec.user_defined_fisc_class,
          LINE_INTENDED_USE = l_def_txs_rec.line_intended_use,
          INVENTORY_ITEM_ID = l_def_txs_rec.inventory_item_id,
          BILL_TO_CUST_ACCT_ID = l_def_txs_rec.bill_to_cust_acct_id,
          ORG_ID = l_def_txs_rec.org_id,
          LEGAL_ENTITY_ID = l_def_txs_rec.legal_entity_id,
          LINE_AMT = l_def_txs_rec.line_amt,
          ASSESSABLE_VALUE = l_def_txs_rec.assessable_value,
          TOTAL_TAX = l_def_txs_rec.total_tax,
          PRODUCT_TYPE = l_def_txs_rec.product_type,
          PRODUCT_FISC_CLASSIFICATION = l_def_txs_rec.product_fisc_classification,
          TRX_DATE = l_def_txs_rec.trx_date,
          PROVNL_TAX_DETERMINATION_DATE = l_def_txs_rec.provnl_tax_determination_date,
          TRY_ID = l_def_txs_rec.try_id,
          SHIP_TO_LOCATION_ID = l_def_txs_rec.ship_to_location_id,
          TRX_CURRENCY_CODE = l_def_txs_rec.trx_currency_code,
          CURRENCY_CONVERSION_TYPE = l_def_txs_rec.currency_conversion_type,
          CURRENCY_CONVERSION_RATE = l_def_txs_rec.currency_conversion_rate,
          CURRENCY_CONVERSION_DATE = l_def_txs_rec.currency_conversion_date
	  -- Modified by dcshanmu for eBTax - modification end
	     --asawanka ebtax changes start
	     ,asset_number                  	 =	l_def_txs_rec.asset_number
,reported_yn                   	 =	l_def_txs_rec.reported_yn
,SHIP_TO_PARTY_SITE_ID         	 =	l_def_txs_rec.SHIP_TO_PARTY_SITE_ID
,SHIP_TO_PARTY_ID              	 =	l_def_txs_rec.SHIP_TO_PARTY_ID
,BILL_TO_PARTY_SITE_ID         	 =	l_def_txs_rec.BILL_TO_PARTY_SITE_ID
,BILL_TO_LOCATION_ID           	 =	l_def_txs_rec.BILL_TO_LOCATION_ID
,BILL_TO_PARTY_ID              	 =	l_def_txs_rec.BILL_TO_PARTY_ID
,ship_to_cust_acct_site_use_id 	 =	l_def_txs_rec.ship_to_cust_acct_site_use_id
,bill_to_cust_acct_site_use_id 	 =	l_def_txs_rec.bill_to_cust_acct_site_use_id
,TAX_CLASSIFICATION_CODE       	 =	l_def_txs_rec.TAX_CLASSIFICATION_CODE
	     --asawanka ebtax changes end
,ALC_SERIALIZED_YN       	     =	l_def_txs_rec.ALC_SERIALIZED_YN
,ALC_SERIALIZED_TOTAL_TAX        =	l_def_txs_rec.ALC_SERIALIZED_TOTAL_TAX
,ALC_SERIALIZED_TOTAL_LINE_AMT   =  l_def_txs_rec.ALC_SERIALIZED_TOTAL_LINE_AMT
      WHERE ID = l_def_txs_rec.id;

      x_txs_rec := l_txs_rec;
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
    -- update_row for:OKL_TAX_SOURCES_V --
    --------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_rec                     IN txsv_rec_type,
      x_txsv_rec                     OUT NOCOPY txsv_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_txsv_rec                     txsv_rec_type := p_txsv_rec;
      l_def_txsv_rec                 txsv_rec_type;
      l_db_txsv_rec                  txsv_rec_type;
      l_txs_rec                      txs_rec_type;
      lx_txs_rec                     txs_rec_type;
      -------------------------------
      -- FUNCTION fill_who_columns --
      -------------------------------
      FUNCTION fill_who_columns (
        p_txsv_rec IN txsv_rec_type
      ) RETURN txsv_rec_type IS
        l_txsv_rec txsv_rec_type := p_txsv_rec;
      BEGIN
        l_txsv_rec.LAST_UPDATE_DATE := SYSDATE;
        l_txsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_txsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_txsv_rec);
      END fill_who_columns;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_txsv_rec IN txsv_rec_type,
        x_txsv_rec OUT NOCOPY txsv_rec_type
      ) RETURN VARCHAR2 IS
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_txsv_rec := p_txsv_rec;
        -- Get current database values
        -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
        --       so it may be verified through LOCK_ROW.
        l_db_txsv_rec := get_rec(p_txsv_rec, l_return_status);
        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_txsv_rec.id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.id := l_db_txsv_rec.id;
          END IF;

          --SECHAWLA : Added code to set Object Version No. because of the locking issue
          IF (x_txsv_rec.object_version_number = OKL_API.G_MISS_NUM)
          THEN
              x_txsv_rec.object_version_number := l_db_txsv_rec.object_version_number;
          END IF;


          IF (x_txsv_rec.khr_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.khr_id := l_db_txsv_rec.khr_id;
          END IF;
          IF (x_txsv_rec.kle_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.kle_id := l_db_txsv_rec.kle_id;
          END IF;
          IF (x_txsv_rec.line_name = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.line_name := l_db_txsv_rec.line_name;
          END IF;
          IF (x_txsv_rec.trx_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.trx_id := l_db_txsv_rec.trx_id;
          END IF;
          IF (x_txsv_rec.trx_line_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.trx_line_id := l_db_txsv_rec.trx_line_id;
          END IF;
          IF (x_txsv_rec.entity_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.entity_code := l_db_txsv_rec.entity_code;
          END IF;
          IF (x_txsv_rec.event_class_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.event_class_code := l_db_txsv_rec.event_class_code;
          END IF;
          IF (x_txsv_rec.trx_level_type = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.trx_level_type := l_db_txsv_rec.trx_level_type;
          END IF;
        /*  IF (x_txsv_rec.trx_line_type = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.trx_line_type := l_db_txsv_rec.trx_line_type;
          END IF;*/
          IF (x_txsv_rec.adjusted_doc_entity_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.adjusted_doc_entity_code := l_db_txsv_rec.adjusted_doc_entity_code;
          END IF;
          IF (x_txsv_rec.adjusted_doc_event_class_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.adjusted_doc_event_class_code := l_db_txsv_rec.adjusted_doc_event_class_code;
          END IF;
          IF (x_txsv_rec.adjusted_doc_trx_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.adjusted_doc_trx_id := l_db_txsv_rec.adjusted_doc_trx_id;
          END IF;
          IF (x_txsv_rec.adjusted_doc_trx_line_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.adjusted_doc_trx_line_id := l_db_txsv_rec.adjusted_doc_trx_line_id;
          END IF;
          IF (x_txsv_rec.adjusted_doc_trx_level_type = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.adjusted_doc_trx_level_type := l_db_txsv_rec.adjusted_doc_trx_level_type;
          END IF;
          IF (x_txsv_rec.adjusted_doc_number = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.adjusted_doc_number := l_db_txsv_rec.adjusted_doc_number;
          END IF;
          IF (x_txsv_rec.adjusted_doc_date = OKL_API.G_MISS_DATE)
          THEN
            x_txsv_rec.adjusted_doc_date := l_db_txsv_rec.adjusted_doc_date;
          END IF;
          IF (x_txsv_rec.tax_call_type_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.tax_call_type_code := l_db_txsv_rec.tax_call_type_code;
          END IF;
          IF (x_txsv_rec.sty_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.sty_id := l_db_txsv_rec.sty_id;
          END IF;
          IF (x_txsv_rec.trx_business_category = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.trx_business_category := l_db_txsv_rec.trx_business_category;
          END IF;
          IF (x_txsv_rec.tax_line_status_code = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.tax_line_status_code := l_db_txsv_rec.tax_line_status_code;
          END IF;
          IF (x_txsv_rec.sel_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.sel_id := l_db_txsv_rec.sel_id;
          END IF;
          IF (x_txsv_rec.reported_yn = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.reported_yn := l_db_txsv_rec.reported_yn;
          END IF;
          IF (x_txsv_rec.program_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.program_id := l_db_txsv_rec.program_id;
          END IF;
          IF (x_txsv_rec.request_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.request_id := l_db_txsv_rec.request_id;
          END IF;
          IF (x_txsv_rec.program_application_id = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.program_application_id := l_db_txsv_rec.program_application_id;
          END IF;
          IF (x_txsv_rec.program_update_date = OKL_API.G_MISS_DATE)
          THEN
            x_txsv_rec.program_update_date := l_db_txsv_rec.program_update_date;
          END IF;
          IF (x_txsv_rec.attribute_category = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute_category := l_db_txsv_rec.attribute_category;
          END IF;
          IF (x_txsv_rec.attribute1 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute1 := l_db_txsv_rec.attribute1;
          END IF;
          IF (x_txsv_rec.attribute2 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute2 := l_db_txsv_rec.attribute2;
          END IF;
          IF (x_txsv_rec.attribute3 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute3 := l_db_txsv_rec.attribute3;
          END IF;
          IF (x_txsv_rec.attribute4 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute4 := l_db_txsv_rec.attribute4;
          END IF;
          IF (x_txsv_rec.attribute5 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute5 := l_db_txsv_rec.attribute5;
          END IF;
          IF (x_txsv_rec.attribute6 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute6 := l_db_txsv_rec.attribute6;
          END IF;
          IF (x_txsv_rec.attribute7 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute7 := l_db_txsv_rec.attribute7;
          END IF;
          IF (x_txsv_rec.attribute8 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute8 := l_db_txsv_rec.attribute8;
          END IF;
          IF (x_txsv_rec.attribute9 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute9 := l_db_txsv_rec.attribute9;
          END IF;
          IF (x_txsv_rec.attribute10 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute10 := l_db_txsv_rec.attribute10;
          END IF;
          IF (x_txsv_rec.attribute11 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute11 := l_db_txsv_rec.attribute11;
          END IF;
          IF (x_txsv_rec.attribute12 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute12 := l_db_txsv_rec.attribute12;
          END IF;
          IF (x_txsv_rec.attribute13 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute13 := l_db_txsv_rec.attribute13;
          END IF;
          IF (x_txsv_rec.attribute14 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute14 := l_db_txsv_rec.attribute14;
          END IF;
          IF (x_txsv_rec.attribute15 = OKL_API.G_MISS_CHAR)
          THEN
            x_txsv_rec.attribute15 := l_db_txsv_rec.attribute15;
          END IF;
          IF (x_txsv_rec.created_by = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.created_by := l_db_txsv_rec.created_by;
          END IF;
          IF (x_txsv_rec.creation_date = OKL_API.G_MISS_DATE)
          THEN
            x_txsv_rec.creation_date := l_db_txsv_rec.creation_date;
          END IF;
          IF (x_txsv_rec.last_updated_by = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.last_updated_by := l_db_txsv_rec.last_updated_by;
          END IF;
          IF (x_txsv_rec.last_update_date = OKL_API.G_MISS_DATE)
          THEN
            x_txsv_rec.last_update_date := l_db_txsv_rec.last_update_date;
          END IF;
          IF (x_txsv_rec.last_update_login = OKL_API.G_MISS_NUM)
          THEN
            x_txsv_rec.last_update_login := l_db_txsv_rec.last_update_login;
          END IF;
          IF (x_txsv_rec.application_id = OKL_API.G_MISS_NUM ) THEN
            x_txsv_rec.application_id := l_db_txsv_rec.application_id;
          END IF;

	  -- Modified by dcshanmu for eBTax - modification starts
	  -- migrating values to newly added columns

          IF (x_txsv_rec.default_taxation_country = OKL_API.G_MISS_CHAR ) THEN
            x_txsv_rec.default_taxation_country := l_db_txsv_rec.default_taxation_country;
          END IF;
	  IF (x_txsv_rec.product_category = OKL_API.G_MISS_CHAR ) THEN
	    x_txsv_rec.product_category := l_db_txsv_rec.product_category;
	  END IF;
	  IF (x_txsv_rec.user_defined_fisc_class = OKL_API.G_MISS_CHAR ) THEN
	    x_txsv_rec.user_defined_fisc_class := l_db_txsv_rec.user_defined_fisc_class;
          END IF;
	  IF (x_txsv_rec.line_intended_use = OKL_API.G_MISS_CHAR ) THEN
	    x_txsv_rec.line_intended_use := l_db_txsv_rec.line_intended_use;
	  END IF;
	  IF (x_txsv_rec.inventory_item_id = OKL_API.G_MISS_NUM ) THEN
	    x_txsv_rec.inventory_item_id := l_db_txsv_rec.inventory_item_id;
	  END IF;
	  IF (x_txsv_rec.bill_to_cust_acct_id = OKL_API.G_MISS_NUM ) THEN
	    x_txsv_rec.bill_to_cust_acct_id := l_db_txsv_rec.bill_to_cust_acct_id;
	  END IF;
	  IF (x_txsv_rec.org_id = OKL_API.G_MISS_NUM ) THEN
	    x_txsv_rec.org_id := l_db_txsv_rec.org_id;
	  END IF;
	  IF (x_txsv_rec.legal_entity_id = OKL_API.G_MISS_NUM ) THEN
	    x_txsv_rec.legal_entity_id := l_db_txsv_rec.legal_entity_id;
	  END IF;
	  IF (x_txsv_rec.line_amt = OKL_API.G_MISS_NUM ) THEN
	    x_txsv_rec.line_amt := l_db_txsv_rec.line_amt;
	  END IF;
	  IF (x_txsv_rec.assessable_value = OKL_API.G_MISS_NUM ) THEN
	    x_txsv_rec.assessable_value := l_db_txsv_rec.assessable_value;
	  END IF;
	  IF (x_txsv_rec.total_tax = OKL_API.G_MISS_NUM ) THEN
	    x_txsv_rec.total_tax := l_db_txsv_rec.total_tax;
	  END IF;
	  IF (x_txsv_rec.product_type = OKL_API.G_MISS_CHAR ) THEN
	    x_txsv_rec.product_type := l_db_txsv_rec.product_type;
	  END IF;
	  IF (x_txsv_rec.product_fisc_classification = OKL_API.G_MISS_CHAR ) THEN
	    x_txsv_rec.product_fisc_classification := l_db_txsv_rec.product_fisc_classification;
          END IF;
	  IF (x_txsv_rec.trx_date = OKL_API.G_MISS_DATE ) THEN
	    x_txsv_rec.trx_date := l_db_txsv_rec.trx_date;
	  END IF;
	  IF (x_txsv_rec.provnl_tax_determination_date = OKL_API.G_MISS_DATE ) THEN
	    x_txsv_rec.provnl_tax_determination_date := l_db_txsv_rec.provnl_tax_determination_date;
	  END IF;
	  IF (x_txsv_rec.try_id = OKL_API.G_MISS_NUM ) THEN
	    x_txsv_rec.try_id := l_db_txsv_rec.try_id;
	  END IF;

	  IF (x_txsv_rec.ship_to_location_id = OKL_API.G_MISS_NUM ) THEN
	    x_txsv_rec.ship_to_location_id := l_db_txsv_rec.ship_to_location_id;

	  END IF;

	  IF (x_txsv_rec.trx_currency_code = OKL_API.G_MISS_CHAR ) THEN
	    x_txsv_rec.trx_currency_code := l_db_txsv_rec.trx_currency_code;
	  END IF;
	  IF (x_txsv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR ) THEN
	    x_txsv_rec.currency_conversion_type := l_db_txsv_rec.currency_conversion_type;
	  END IF;
	  IF (x_txsv_rec.currency_conversion_rate = OKL_API.G_MISS_NUM ) THEN
	    x_txsv_rec.currency_conversion_rate := l_db_txsv_rec.currency_conversion_rate;
	  END IF;
	  IF (x_txsv_rec.currency_conversion_date = OKL_API.G_MISS_DATE ) THEN
	    x_txsv_rec.currency_conversion_date := l_db_txsv_rec.currency_conversion_date;
	  END IF;
	  -- Modified by dcshanmu for eBTax - modification end
         --asawanka ebtax changes start
        IF (x_txsv_rec.asset_number = OKL_API.G_MISS_CHAR ) THEN
	      x_txsv_rec.asset_number := l_db_txsv_rec.asset_number;
	    END IF;
	    IF (x_txsv_rec.reported_yn = OKL_API.G_MISS_CHAR ) THEN
	      x_txsv_rec.reported_yn := l_db_txsv_rec.reported_yn;
	    END IF;
	    IF (x_txsv_rec.SHIP_TO_PARTY_SITE_ID = OKL_API.G_MISS_NUM ) THEN
	      x_txsv_rec.SHIP_TO_PARTY_SITE_ID := l_db_txsv_rec.SHIP_TO_PARTY_SITE_ID;
	    END IF;
	    IF (x_txsv_rec.SHIP_TO_PARTY_ID = OKL_API.G_MISS_NUM ) THEN
	      x_txsv_rec.SHIP_TO_PARTY_ID := l_db_txsv_rec.SHIP_TO_PARTY_ID;
	    END IF;
	    IF (x_txsv_rec.BILL_TO_PARTY_SITE_ID = OKL_API.G_MISS_NUM ) THEN
	      x_txsv_rec.BILL_TO_PARTY_SITE_ID := l_db_txsv_rec.BILL_TO_PARTY_SITE_ID;
	    END IF;
	    IF (x_txsv_rec.BILL_TO_LOCATION_ID = OKL_API.G_MISS_NUM ) THEN
	      x_txsv_rec.BILL_TO_LOCATION_ID := l_db_txsv_rec.BILL_TO_LOCATION_ID;
	    END IF;
	    IF (x_txsv_rec.BILL_TO_PARTY_ID = OKL_API.G_MISS_NUM ) THEN
	      x_txsv_rec.BILL_TO_PARTY_ID := l_db_txsv_rec.BILL_TO_PARTY_ID;
	    END IF;
	    IF (x_txsv_rec.ship_to_cust_acct_site_use_id = OKL_API.G_MISS_NUM ) THEN
	      x_txsv_rec.ship_to_cust_acct_site_use_id := l_db_txsv_rec.ship_to_cust_acct_site_use_id;
	    END IF;
	    IF (x_txsv_rec.bill_to_cust_acct_site_use_id = OKL_API.G_MISS_NUM ) THEN
	      x_txsv_rec.bill_to_cust_acct_site_use_id := l_db_txsv_rec.bill_to_cust_acct_site_use_id;
	    END IF;
	    IF (x_txsv_rec.TAX_CLASSIFICATION_CODE = OKL_API.G_MISS_CHAR) THEN
	      x_txsv_rec.TAX_CLASSIFICATION_CODE := l_db_txsv_rec.TAX_CLASSIFICATION_CODE;
	    END IF;
       --asawanka ebtax changes end
	    IF (x_txsv_rec.ALC_SERIALIZED_YN = OKL_API.G_MISS_CHAR) THEN
	      x_txsv_rec.ALC_SERIALIZED_YN := l_db_txsv_rec.ALC_SERIALIZED_YN;
	    END IF;
	    IF (x_txsv_rec.ALC_SERIALIZED_TOTAL_TAX = OKL_API.G_MISS_NUM) THEN
	      x_txsv_rec.ALC_SERIALIZED_TOTAL_TAX := l_db_txsv_rec.ALC_SERIALIZED_TOTAL_TAX;
	    END IF;
	    IF (x_txsv_rec.ALC_SERIALIZED_TOTAL_LINE_AMT = OKL_API.G_MISS_NUM) THEN
	      x_txsv_rec.ALC_SERIALIZED_TOTAL_LINE_AMT := l_db_txsv_rec.ALC_SERIALIZED_TOTAL_LINE_AMT;
	    END IF;

        END IF;
        RETURN(l_return_status);
      END populate_new_record;

      ------------------------------------------
      -- Set_Attributes for:OKL_TAX_SOURCES_V --
      ------------------------------------------
      FUNCTION Set_Attributes (
        p_txsv_rec IN txsv_rec_type,
        x_txsv_rec OUT NOCOPY txsv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_txsv_rec := p_txsv_rec;
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
        p_txsv_rec,                        -- IN
        x_txsv_rec);                       -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_txsv_rec, l_def_txsv_rec);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_def_txsv_rec := fill_who_columns(l_def_txsv_rec);
      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_def_txsv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      /*l_return_status := Validate_Record(l_def_txsv_rec, l_db_txsv_rec);
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
        p_txsv_rec                     => l_def_txsv_rec); -- p_txsv_rec); -- SECHAWLA Changed to pass l_def_tbov_rec becoz of locking issue
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -----------------------------------------
      -- Move VIEW record to "Child" records --
      -----------------------------------------
      migrate(l_def_txsv_rec, l_txs_rec);
      -----------------------------------------------
      -- Call the UPDATE_ROW for each child record --
      -----------------------------------------------
      update_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_txs_rec,
        lx_txs_rec
      );
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_txs_rec, l_def_txsv_rec);
      x_txsv_rec := l_def_txsv_rec;
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
    -- PL/SQL TBL update_row for:txsv_tbl --
    ----------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_tbl                     IN txsv_tbl_type,
      x_txsv_tbl                     OUT NOCOPY txsv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
      i                              NUMBER := 0;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_txsv_tbl.COUNT > 0) THEN
        i := p_txsv_tbl.FIRST;
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
              p_txsv_rec                     => p_txsv_tbl(i),
              x_txsv_rec                     => x_txsv_tbl(i));
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
          EXIT WHEN (i = p_txsv_tbl.LAST);
          i := p_txsv_tbl.NEXT(i);
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
    -- PL/SQL TBL update_row for:TXSV_TBL --
    ----------------------------------------
    -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
    -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_tbl                     IN txsv_tbl_type,
      x_txsv_tbl                     OUT NOCOPY txsv_tbl_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_txsv_tbl.COUNT > 0) THEN
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_txsv_tbl                     => p_txsv_tbl,
          x_txsv_tbl                     => x_txsv_tbl,
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
    ------------------------------------
    -- delete_row for:OKL_TAX_SOURCES --
    ------------------------------------
    PROCEDURE delete_row(
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txs_rec                      IN txs_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_txs_rec                      txs_rec_type := p_txs_rec;
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

      DELETE FROM OKL_TAX_SOURCES
       WHERE ID = p_txs_rec.id;

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
    -- delete_row for:OKL_TAX_SOURCES_V --
    --------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_rec                     IN txsv_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_txsv_rec                     txsv_rec_type := p_txsv_rec;
      l_txs_rec                      txs_rec_type;
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
      migrate(l_txsv_rec, l_txs_rec);
      -----------------------------------------------
      -- Call the DELETE_ROW for each child record --
      -----------------------------------------------
      delete_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_txs_rec
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
    -- PL/SQL TBL delete_row for:OKL_TAX_SOURCES_V --
    -------------------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_tbl                     IN txsv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
      i                              NUMBER := 0;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_txsv_tbl.COUNT > 0) THEN
        i := p_txsv_tbl.FIRST;
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
              p_txsv_rec                     => p_txsv_tbl(i));
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
          EXIT WHEN (i = p_txsv_tbl.LAST);
          i := p_txsv_tbl.NEXT(i);
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
    -- PL/SQL TBL delete_row for:OKL_TAX_SOURCES_V --
    -------------------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_txsv_tbl                     IN txsv_tbl_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_txsv_tbl.COUNT > 0) THEN
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_txsv_tbl                     => p_txsv_tbl,
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

END OKL_TXS_PVT;

/
