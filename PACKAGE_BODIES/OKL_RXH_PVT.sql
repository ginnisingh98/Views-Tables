--------------------------------------------------------
--  DDL for Package Body OKL_RXH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RXH_PVT" AS
/* $Header: OKLSRXHB.pls 120.4 2007/12/27 14:23:03 zrehman noship $ */

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
    CURSOR c_pk_csr IS SELECT okl_ext_ar_header_sources_s.NEXTVAL FROM DUAL;
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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_EXT_AR_HEADER_SOURCES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_EXT_AR_HEADER_SOURCES_B B
         WHERE B.HEADER_EXTENSION_ID =T.HEADER_EXTENSION_ID
        );

    UPDATE OKL_EXT_AR_HEADER_SOURCES_TL T SET(
        CONTRACT_STATUS,
        INV_AGRMNT_STATUS,
        TRANSACTION_TYPE_NAME) = (SELECT
                                  B.CONTRACT_STATUS,
                                  B.INV_AGRMNT_STATUS,
                                  B.TRANSACTION_TYPE_NAME
                                FROM OKL_EXT_AR_HEADER_SOURCES_TL B
                               WHERE B.HEADER_EXTENSION_ID = T.HEADER_EXTENSION_ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.HEADER_EXTENSION_ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.HEADER_EXTENSION_ID,
                  SUBT.LANGUAGE
                FROM OKL_EXT_AR_HEADER_SOURCES_TL SUBB, OKL_EXT_AR_HEADER_SOURCES_TL SUBT
               WHERE SUBB.HEADER_EXTENSION_ID = SUBT.HEADER_EXTENSION_ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.CONTRACT_STATUS <> SUBT.CONTRACT_STATUS
                      OR SUBB.INV_AGRMNT_STATUS <> SUBT.INV_AGRMNT_STATUS
                      OR SUBB.TRANSACTION_TYPE_NAME <> SUBT.TRANSACTION_TYPE_NAME
                      OR (SUBB.CONTRACT_STATUS IS NULL AND SUBT.CONTRACT_STATUS IS NOT NULL)
                      OR (SUBB.INV_AGRMNT_STATUS IS NULL AND SUBT.INV_AGRMNT_STATUS IS NOT NULL)
                      OR (SUBB.TRANSACTION_TYPE_NAME IS NULL AND SUBT.TRANSACTION_TYPE_NAME IS NOT NULL)
              ));

    INSERT INTO OKL_EXT_AR_HEADER_SOURCES_TL (
        HEADER_EXTENSION_ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        CONTRACT_STATUS,
        INV_AGRMNT_STATUS,
        TRANSACTION_TYPE_NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.HEADER_EXTENSION_ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.CONTRACT_STATUS,
            B.INV_AGRMNT_STATUS,
            B.TRANSACTION_TYPE_NAME,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_EXT_AR_HEADER_SOURCES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_EXT_AR_HEADER_SOURCES_TL T
                     WHERE T.HEADER_EXTENSION_ID = B.HEADER_EXTENSION_ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_AR_HEADER_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rxhv_rec                     IN rxhv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rxhv_rec_type IS
    CURSOR okl_ext_ar_header_s1 (p_header_extension_id IN NUMBER) IS
    SELECT
            HEADER_EXTENSION_ID,
            SOURCE_ID,
            SOURCE_TABLE,
            OBJECT_VERSION_NUMBER,
            KHR_ID,
            TRY_ID,
            TRANS_NUMBER,
            CONTRACT_NUMBER,
            PRODUCT_NAME,
            BOOK_CLASSIFICATION_CODE,
            TAX_OWNER_CODE,
            INT_CALC_METHOD_CODE,
            REV_REC_METHOD_CODE,
            SCS_CODE,
            CONVERTED_NUMBER,
            CONTRACT_EFFECTIVE_FROM,
            CONTRACT_CURRENCY_CODE,
            SALES_REP_NAME,
            PO_ORDER_NUMBER,
            VENDOR_PROGRAM_NUMBER,
            ASSIGNABLE_FLAG,
            CONVERTED_ACCOUNT_FLAG,
            ACCRUAL_OVERRIDE_FLAG,
            TERM_QUOTE_ACCEPT_DATE,
            TERM_QUOTE_NUM,
            TERM_QUOTE_TYPE_CODE,
            KHR_ATTRIBUTE_CATEGORY,
            KHR_ATTRIBUTE1,
            KHR_ATTRIBUTE2,
            KHR_ATTRIBUTE3,
            KHR_ATTRIBUTE4,
            KHR_ATTRIBUTE5,
            KHR_ATTRIBUTE6,
            KHR_ATTRIBUTE7,
            KHR_ATTRIBUTE8,
            KHR_ATTRIBUTE9,
            KHR_ATTRIBUTE10,
            KHR_ATTRIBUTE11,
            KHR_ATTRIBUTE12,
            KHR_ATTRIBUTE13,
            KHR_ATTRIBUTE14,
            KHR_ATTRIBUTE15,
            CUST_ATTRIBUTE_CATEGORY,
            CUST_ATTRIBUTE1,
            CUST_ATTRIBUTE2,
            CUST_ATTRIBUTE3,
            CUST_ATTRIBUTE4,
            CUST_ATTRIBUTE5,
            CUST_ATTRIBUTE6,
            CUST_ATTRIBUTE7,
            CUST_ATTRIBUTE8,
            CUST_ATTRIBUTE9,
            CUST_ATTRIBUTE10,
            CUST_ATTRIBUTE11,
            CUST_ATTRIBUTE12,
            CUST_ATTRIBUTE13,
            CUST_ATTRIBUTE14,
            CUST_ATTRIBUTE15,
            RENT_IA_CONTRACT_NUMBER,
            RENT_IA_PRODUCT_NAME,
            RENT_IA_ACCOUNTING_CODE,
            RES_IA_CONTRACT_NUMBER,
            RES_IA_PRODUCT_NAME,
            RES_IA_ACCOUNTING_CODE,
            INV_AGRMNT_NUMBER,
            INV_AGRMNT_EFFECTIVE_FROM,
            INV_AGRMNT_PRODUCT_NAME,
            INV_AGRMNT_CURRENCY_CODE,
            INV_AGRMNT_SYND_CODE,
            INV_AGRMNT_POOL_NUMBER,
            CONTRACT_STATUS_CODE,
            INV_AGRMNT_STATUS_CODE,
            TRX_TYPE_CLASS_CODE,
            LANGUAGE,
            CONTRACT_STATUS,
            INV_AGRMNT_STATUS,
            TRANSACTION_TYPE_NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ext_Ar_Header_Sources_V
     WHERE okl_ext_ar_header_sources_v.header_extension_id = p_header_extension_id;
    l_okl_ext_ar_header2           okl_ext_ar_header_s1%ROWTYPE;
    l_rxhv_rec                     rxhv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ext_ar_header_s1 (p_rxhv_rec.header_extension_id);
    FETCH okl_ext_ar_header_s1 INTO
              l_rxhv_rec.header_extension_id,
              l_rxhv_rec.source_id,
              l_rxhv_rec.source_table,
              l_rxhv_rec.object_version_number,
              l_rxhv_rec.khr_id,
              l_rxhv_rec.try_id,
              l_rxhv_rec.trans_number,
              l_rxhv_rec.contract_number,
              l_rxhv_rec.product_name,
              l_rxhv_rec.book_classification_code,
              l_rxhv_rec.tax_owner_code,
              l_rxhv_rec.int_calc_method_code,
              l_rxhv_rec.rev_rec_method_code,
              l_rxhv_rec.scs_code,
              l_rxhv_rec.converted_number,
              l_rxhv_rec.contract_effective_from,
              l_rxhv_rec.contract_currency_code,
              l_rxhv_rec.sales_rep_name,
              l_rxhv_rec.po_order_number,
              l_rxhv_rec.vendor_program_number,
              l_rxhv_rec.assignable_flag,
              l_rxhv_rec.converted_account_flag,
              l_rxhv_rec.accrual_override_flag,
              l_rxhv_rec.term_quote_accept_date,
              l_rxhv_rec.term_quote_num,
              l_rxhv_rec.term_quote_type_code,
              l_rxhv_rec.khr_attribute_category,
              l_rxhv_rec.khr_attribute1,
              l_rxhv_rec.khr_attribute2,
              l_rxhv_rec.khr_attribute3,
              l_rxhv_rec.khr_attribute4,
              l_rxhv_rec.khr_attribute5,
              l_rxhv_rec.khr_attribute6,
              l_rxhv_rec.khr_attribute7,
              l_rxhv_rec.khr_attribute8,
              l_rxhv_rec.khr_attribute9,
              l_rxhv_rec.khr_attribute10,
              l_rxhv_rec.khr_attribute11,
              l_rxhv_rec.khr_attribute12,
              l_rxhv_rec.khr_attribute13,
              l_rxhv_rec.khr_attribute14,
              l_rxhv_rec.khr_attribute15,
              l_rxhv_rec.cust_attribute_category,
              l_rxhv_rec.cust_attribute1,
              l_rxhv_rec.cust_attribute2,
              l_rxhv_rec.cust_attribute3,
              l_rxhv_rec.cust_attribute4,
              l_rxhv_rec.cust_attribute5,
              l_rxhv_rec.cust_attribute6,
              l_rxhv_rec.cust_attribute7,
              l_rxhv_rec.cust_attribute8,
              l_rxhv_rec.cust_attribute9,
              l_rxhv_rec.cust_attribute10,
              l_rxhv_rec.cust_attribute11,
              l_rxhv_rec.cust_attribute12,
              l_rxhv_rec.cust_attribute13,
              l_rxhv_rec.cust_attribute14,
              l_rxhv_rec.cust_attribute15,
              l_rxhv_rec.rent_ia_contract_number,
              l_rxhv_rec.rent_ia_product_name,
              l_rxhv_rec.rent_ia_accounting_code,
              l_rxhv_rec.res_ia_contract_number,
              l_rxhv_rec.res_ia_product_name,
              l_rxhv_rec.res_ia_accounting_code,
              l_rxhv_rec.inv_agrmnt_number,
              l_rxhv_rec.inv_agrmnt_effective_from,
              l_rxhv_rec.inv_agrmnt_product_name,
              l_rxhv_rec.inv_agrmnt_currency_code,
              l_rxhv_rec.inv_agrmnt_synd_code,
              l_rxhv_rec.inv_agrmnt_pool_number,
              l_rxhv_rec.contract_status_code,
              l_rxhv_rec.inv_agrmnt_status_code,
              l_rxhv_rec.trx_type_class_code,
              l_rxhv_rec.language,
              l_rxhv_rec.contract_status,
              l_rxhv_rec.inv_agrmnt_status,
              l_rxhv_rec.transaction_type_name,
              l_rxhv_rec.created_by,
              l_rxhv_rec.creation_date,
              l_rxhv_rec.last_updated_by,
              l_rxhv_rec.last_update_date,
              l_rxhv_rec.last_update_login;
    x_no_data_found := okl_ext_ar_header_s1%NOTFOUND;
    CLOSE okl_ext_ar_header_s1;
    RETURN(l_rxhv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_rxhv_rec                     IN rxhv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN rxhv_rec_type IS
    l_rxhv_rec                     rxhv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_rxhv_rec := get_rec(p_rxhv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'HEADER_EXTENSION_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_rxhv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_rxhv_rec                     IN rxhv_rec_type
  ) RETURN rxhv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rxhv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_AR_HEADER_SOURCES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rxh_rec                      IN rxh_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rxh_rec_type IS
    CURSOR okl_ext_ar_header_s3 (p_header_extension_id IN NUMBER) IS
    SELECT
            HEADER_EXTENSION_ID,
            SOURCE_ID,
            SOURCE_TABLE,
            OBJECT_VERSION_NUMBER,
            KHR_ID,
            TRY_ID,
            TRANS_NUMBER,
            CONTRACT_NUMBER,
            PRODUCT_NAME,
            BOOK_CLASSIFICATION_CODE,
            TAX_OWNER_CODE,
            INT_CALC_METHOD_CODE,
            REV_REC_METHOD_CODE,
            SCS_CODE,
            CONVERTED_NUMBER,
            CONTRACT_EFFECTIVE_FROM,
            CONTRACT_CURRENCY_CODE,
            SALES_REP_NAME,
            PO_ORDER_NUMBER,
            VENDOR_PROGRAM_NUMBER,
            ASSIGNABLE_FLAG,
            CONVERTED_ACCOUNT_FLAG,
            ACCRUAL_OVERRIDE_FLAG,
            TERM_QUOTE_ACCEPT_DATE,
            TERM_QUOTE_NUM,
            TERM_QUOTE_TYPE_CODE,
            KHR_ATTRIBUTE_CATEGORY,
            KHR_ATTRIBUTE1,
            KHR_ATTRIBUTE2,
            KHR_ATTRIBUTE3,
            KHR_ATTRIBUTE4,
            KHR_ATTRIBUTE5,
            KHR_ATTRIBUTE6,
            KHR_ATTRIBUTE7,
            KHR_ATTRIBUTE8,
            KHR_ATTRIBUTE9,
            KHR_ATTRIBUTE10,
            KHR_ATTRIBUTE11,
            KHR_ATTRIBUTE12,
            KHR_ATTRIBUTE13,
            KHR_ATTRIBUTE14,
            KHR_ATTRIBUTE15,
            CUST_ATTRIBUTE_CATEGORY,
            CUST_ATTRIBUTE1,
            CUST_ATTRIBUTE2,
            CUST_ATTRIBUTE3,
            CUST_ATTRIBUTE4,
            CUST_ATTRIBUTE5,
            CUST_ATTRIBUTE6,
            CUST_ATTRIBUTE7,
            CUST_ATTRIBUTE8,
            CUST_ATTRIBUTE9,
            CUST_ATTRIBUTE10,
            CUST_ATTRIBUTE11,
            CUST_ATTRIBUTE12,
            CUST_ATTRIBUTE13,
            CUST_ATTRIBUTE14,
            CUST_ATTRIBUTE15,
            RENT_IA_CONTRACT_NUMBER,
            RENT_IA_PRODUCT_NAME,
            RENT_IA_ACCOUNTING_CODE,
            RES_IA_CONTRACT_NUMBER,
            RES_IA_PRODUCT_NAME,
            RES_IA_ACCOUNTING_CODE,
            INV_AGRMNT_NUMBER,
            INV_AGRMNT_EFFECTIVE_FROM,
            INV_AGRMNT_PRODUCT_NAME,
            INV_AGRMNT_CURRENCY_CODE,
            INV_AGRMNT_SYND_CODE,
            INV_AGRMNT_POOL_NUMBER,
            CONTRACT_STATUS_CODE,
            INV_AGRMNT_STATUS_CODE,
            TRX_TYPE_CLASS_CODE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ext_Ar_Header_Sources_B
     WHERE okl_ext_ar_header_sources_b.header_extension_id = p_header_extension_id;
    l_okl_ext_ar_header4           okl_ext_ar_header_s3%ROWTYPE;
    l_rxh_rec                      rxh_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ext_ar_header_s3 (p_rxh_rec.header_extension_id);
    FETCH okl_ext_ar_header_s3 INTO
              l_rxh_rec.header_extension_id,
              l_rxh_rec.source_id,
              l_rxh_rec.source_table,
              l_rxh_rec.object_version_number,
              l_rxh_rec.khr_id,
              l_rxh_rec.try_id,
              l_rxh_rec.trans_number,
              l_rxh_rec.contract_number,
              l_rxh_rec.product_name,
              l_rxh_rec.book_classification_code,
              l_rxh_rec.tax_owner_code,
              l_rxh_rec.int_calc_method_code,
              l_rxh_rec.rev_rec_method_code,
              l_rxh_rec.scs_code,
              l_rxh_rec.converted_number,
              l_rxh_rec.contract_effective_from,
              l_rxh_rec.contract_currency_code,
              l_rxh_rec.sales_rep_name,
              l_rxh_rec.po_order_number,
              l_rxh_rec.vendor_program_number,
              l_rxh_rec.assignable_flag,
              l_rxh_rec.converted_account_flag,
              l_rxh_rec.accrual_override_flag,
              l_rxh_rec.term_quote_accept_date,
              l_rxh_rec.term_quote_num,
              l_rxh_rec.term_quote_type_code,
              l_rxh_rec.khr_attribute_category,
              l_rxh_rec.khr_attribute1,
              l_rxh_rec.khr_attribute2,
              l_rxh_rec.khr_attribute3,
              l_rxh_rec.khr_attribute4,
              l_rxh_rec.khr_attribute5,
              l_rxh_rec.khr_attribute6,
              l_rxh_rec.khr_attribute7,
              l_rxh_rec.khr_attribute8,
              l_rxh_rec.khr_attribute9,
              l_rxh_rec.khr_attribute10,
              l_rxh_rec.khr_attribute11,
              l_rxh_rec.khr_attribute12,
              l_rxh_rec.khr_attribute13,
              l_rxh_rec.khr_attribute14,
              l_rxh_rec.khr_attribute15,
              l_rxh_rec.cust_attribute_category,
              l_rxh_rec.cust_attribute1,
              l_rxh_rec.cust_attribute2,
              l_rxh_rec.cust_attribute3,
              l_rxh_rec.cust_attribute4,
              l_rxh_rec.cust_attribute5,
              l_rxh_rec.cust_attribute6,
              l_rxh_rec.cust_attribute7,
              l_rxh_rec.cust_attribute8,
              l_rxh_rec.cust_attribute9,
              l_rxh_rec.cust_attribute10,
              l_rxh_rec.cust_attribute11,
              l_rxh_rec.cust_attribute12,
              l_rxh_rec.cust_attribute13,
              l_rxh_rec.cust_attribute14,
              l_rxh_rec.cust_attribute15,
              l_rxh_rec.rent_ia_contract_number,
              l_rxh_rec.rent_ia_product_name,
              l_rxh_rec.rent_ia_accounting_code,
              l_rxh_rec.res_ia_contract_number,
              l_rxh_rec.res_ia_product_name,
              l_rxh_rec.res_ia_accounting_code,
              l_rxh_rec.inv_agrmnt_number,
              l_rxh_rec.inv_agrmnt_effective_from,
              l_rxh_rec.inv_agrmnt_product_name,
              l_rxh_rec.inv_agrmnt_currency_code,
              l_rxh_rec.inv_agrmnt_synd_code,
              l_rxh_rec.inv_agrmnt_pool_number,
              l_rxh_rec.contract_status_code,
              l_rxh_rec.inv_agrmnt_status_code,
              l_rxh_rec.trx_type_class_code,
              l_rxh_rec.created_by,
              l_rxh_rec.creation_date,
              l_rxh_rec.last_updated_by,
              l_rxh_rec.last_update_date,
              l_rxh_rec.last_update_login;
    x_no_data_found := okl_ext_ar_header_s3%NOTFOUND;
    CLOSE okl_ext_ar_header_s3;
    RETURN(l_rxh_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_rxh_rec                      IN rxh_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN rxh_rec_type IS
    l_rxh_rec                      rxh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_rxh_rec := get_rec(p_rxh_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'HEADER_EXTENSION_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_rxh_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_rxh_rec                      IN rxh_rec_type
  ) RETURN rxh_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rxh_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_AR_HEADER_SOURCES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rxhl_rec                     IN rxhl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rxhl_rec_type IS
    CURSOR okl_ext_ar_header_s5 (p_header_extension_id IN NUMBER,
                                 p_language            IN VARCHAR2) IS
    SELECT
            HEADER_EXTENSION_ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            CONTRACT_STATUS,
            INV_AGRMNT_STATUS,
            TRANSACTION_TYPE_NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ext_Ar_Header_Sources_Tl
     WHERE okl_ext_ar_header_sources_tl.header_extension_id = p_header_extension_id
       AND okl_ext_ar_header_sources_tl.language = p_language;
    l_okl_ext_ar_header_srcs_tl_pk okl_ext_ar_header_s5%ROWTYPE;
    l_rxhl_rec                     rxhl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ext_ar_header_s5 (p_rxhl_rec.header_extension_id,
                               p_rxhl_rec.language);
    FETCH okl_ext_ar_header_s5 INTO
              l_rxhl_rec.header_extension_id,
              l_rxhl_rec.language,
              l_rxhl_rec.source_lang,
              l_rxhl_rec.sfwt_flag,
              l_rxhl_rec.contract_status,
              l_rxhl_rec.inv_agrmnt_status,
              l_rxhl_rec.transaction_type_name,
              l_rxhl_rec.created_by,
              l_rxhl_rec.creation_date,
              l_rxhl_rec.last_updated_by,
              l_rxhl_rec.last_update_date,
              l_rxhl_rec.last_update_login;
    x_no_data_found := okl_ext_ar_header_s5%NOTFOUND;
    CLOSE okl_ext_ar_header_s5;
    RETURN(l_rxhl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_rxhl_rec                     IN rxhl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN rxhl_rec_type IS
    l_rxhl_rec                     rxhl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_rxhl_rec := get_rec(p_rxhl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'HEADER_EXTENSION_ID');
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_rxhl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_rxhl_rec                     IN rxhl_rec_type
  ) RETURN rxhl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rxhl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_EXT_AR_HEADER_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_rxhv_rec   IN rxhv_rec_type
  ) RETURN rxhv_rec_type IS
    l_rxhv_rec                     rxhv_rec_type := p_rxhv_rec;
  BEGIN
    IF (l_rxhv_rec.header_extension_id = OKL_API.G_MISS_NUM ) THEN
      l_rxhv_rec.header_extension_id := NULL;
    END IF;
    IF (l_rxhv_rec.source_id = OKL_API.G_MISS_NUM ) THEN
      l_rxhv_rec.source_id := NULL;
    END IF;
    IF (l_rxhv_rec.source_table = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.source_table := NULL;
    END IF;
    IF (l_rxhv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_rxhv_rec.object_version_number := NULL;
    END IF;
    IF (l_rxhv_rec.khr_id = OKL_API.G_MISS_NUM ) THEN
      l_rxhv_rec.khr_id := NULL;
    END IF;
    IF (l_rxhv_rec.try_id = OKL_API.G_MISS_NUM ) THEN
      l_rxhv_rec.try_id := NULL;
    END IF;
    IF (l_rxhv_rec.trans_number = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.trans_number := NULL;
    END IF;
    IF (l_rxhv_rec.contract_number = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.contract_number := NULL;
    END IF;
    IF (l_rxhv_rec.product_name = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.product_name := NULL;
    END IF;
    IF (l_rxhv_rec.book_classification_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.book_classification_code := NULL;
    END IF;
    IF (l_rxhv_rec.tax_owner_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.tax_owner_code := NULL;
    END IF;
    IF (l_rxhv_rec.int_calc_method_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.int_calc_method_code := NULL;
    END IF;
    IF (l_rxhv_rec.rev_rec_method_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.rev_rec_method_code := NULL;
    END IF;
    IF (l_rxhv_rec.scs_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.scs_code := NULL;
    END IF;
    IF (l_rxhv_rec.converted_number = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.converted_number := NULL;
    END IF;
    IF (l_rxhv_rec.contract_effective_from = OKL_API.G_MISS_DATE ) THEN
      l_rxhv_rec.contract_effective_from := NULL;
    END IF;
    IF (l_rxhv_rec.contract_currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.contract_currency_code := NULL;
    END IF;
    IF (l_rxhv_rec.sales_rep_name = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.sales_rep_name := NULL;
    END IF;
    IF (l_rxhv_rec.po_order_number = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.po_order_number := NULL;
    END IF;
    IF (l_rxhv_rec.vendor_program_number = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.vendor_program_number := NULL;
    END IF;
    IF (l_rxhv_rec.assignable_flag = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.assignable_flag := NULL;
    END IF;
    IF (l_rxhv_rec.converted_account_flag = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.converted_account_flag := NULL;
    END IF;
    IF (l_rxhv_rec.accrual_override_flag = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.accrual_override_flag := NULL;
    END IF;
    IF (l_rxhv_rec.term_quote_accept_date = OKL_API.G_MISS_DATE ) THEN
      l_rxhv_rec.term_quote_accept_date := NULL;
    END IF;
    IF (l_rxhv_rec.term_quote_num = OKL_API.G_MISS_NUM ) THEN
      l_rxhv_rec.term_quote_num := NULL;
    END IF;
    IF (l_rxhv_rec.term_quote_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.term_quote_type_code := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute_category := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute1 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute2 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute3 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute4 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute5 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute6 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute7 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute8 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute9 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute10 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute11 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute12 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute13 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute14 := NULL;
    END IF;
    IF (l_rxhv_rec.khr_attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.khr_attribute15 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute_category := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute1 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute2 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute3 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute4 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute5 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute6 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute7 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute8 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute9 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute10 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute11 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute12 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute13 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute14 := NULL;
    END IF;
    IF (l_rxhv_rec.cust_attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.cust_attribute15 := NULL;
    END IF;
    IF (l_rxhv_rec.rent_ia_contract_number = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.rent_ia_contract_number := NULL;
    END IF;
    IF (l_rxhv_rec.rent_ia_product_name = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.rent_ia_product_name := NULL;
    END IF;
    IF (l_rxhv_rec.rent_ia_accounting_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.rent_ia_accounting_code := NULL;
    END IF;
    IF (l_rxhv_rec.res_ia_contract_number = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.res_ia_contract_number := NULL;
    END IF;
    IF (l_rxhv_rec.res_ia_product_name = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.res_ia_product_name := NULL;
    END IF;
    IF (l_rxhv_rec.res_ia_accounting_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.res_ia_accounting_code := NULL;
    END IF;
    IF (l_rxhv_rec.inv_agrmnt_number = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.inv_agrmnt_number := NULL;
    END IF;
    IF (l_rxhv_rec.inv_agrmnt_effective_from = OKL_API.G_MISS_DATE ) THEN
      l_rxhv_rec.inv_agrmnt_effective_from := NULL;
    END IF;
    IF (l_rxhv_rec.inv_agrmnt_product_name = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.inv_agrmnt_product_name := NULL;
    END IF;
    IF (l_rxhv_rec.inv_agrmnt_currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.inv_agrmnt_currency_code := NULL;
    END IF;
    IF (l_rxhv_rec.inv_agrmnt_synd_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.inv_agrmnt_synd_code := NULL;
    END IF;
    IF (l_rxhv_rec.inv_agrmnt_pool_number = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.inv_agrmnt_pool_number := NULL;
    END IF;
    IF (l_rxhv_rec.contract_status_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.contract_status_code := NULL;
    END IF;
    IF (l_rxhv_rec.inv_agrmnt_status_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.inv_agrmnt_status_code := NULL;
    END IF;
    IF (l_rxhv_rec.trx_type_class_code = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.trx_type_class_code := NULL;
    END IF;
    IF (l_rxhv_rec.language = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.language := NULL;
    END IF;
    IF (l_rxhv_rec.contract_status = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.contract_status := NULL;
    END IF;
    IF (l_rxhv_rec.inv_agrmnt_status = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.inv_agrmnt_status := NULL;
    END IF;
    IF (l_rxhv_rec.transaction_type_name = OKL_API.G_MISS_CHAR ) THEN
      l_rxhv_rec.transaction_type_name := NULL;
    END IF;
    IF (l_rxhv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_rxhv_rec.created_by := NULL;
    END IF;
    IF (l_rxhv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_rxhv_rec.creation_date := NULL;
    END IF;
    IF (l_rxhv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_rxhv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rxhv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_rxhv_rec.last_update_date := NULL;
    END IF;
    IF (l_rxhv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_rxhv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_rxhv_rec);
  END null_out_defaults;
  --------------------------------------------------
  -- Validate_Attributes for: HEADER_EXTENSION_ID --
  --------------------------------------------------
  PROCEDURE validate_header_extension_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_header_extension_id          IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_header_extension_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'header_extension_id');
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
  END validate_header_extension_id;
  ----------------------------------------
  -- Validate_Attributes for: SOURCE_ID --
  ----------------------------------------
  PROCEDURE validate_source_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_source_id                    IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_source_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_id');
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
  END validate_source_id;
  -------------------------------------------
  -- Validate_Attributes for: SOURCE_TABLE --
  -------------------------------------------
  PROCEDURE validate_source_table(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_source_table                 IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_source_table IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_table');
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
  END validate_source_table;
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
  -------------------------------------
  -- Validate_Attributes for: KHR_ID --
  -------------------------------------
  PROCEDURE validate_khr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_khr_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_khr_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'khr_id');
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
  END validate_khr_id;
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

  ---------------------------------------
  -- Validate_Attributes for: LANGUAGE --
  ---------------------------------------
  PROCEDURE validate_language(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_language                     IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_language IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'language');
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
  END validate_language;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------------
  -- Validate_Attributes for:OKL_EXT_AR_HEADER_SOURCES_V --
  ---------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_rxhv_rec                     IN rxhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- header_extension_id
    -- ***
    validate_header_extension_id(x_return_status, p_rxhv_rec.header_extension_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- source_id
    -- ***
    validate_source_id(x_return_status, p_rxhv_rec.source_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- source_table
    -- ***
    validate_source_table(x_return_status, p_rxhv_rec.source_table);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_rxhv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- khr_id
    -- ***
    validate_khr_id(x_return_status, p_rxhv_rec.khr_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- try_id
    -- ***
    validate_try_id(x_return_status, p_rxhv_rec.try_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- language
    -- ***
    validate_language(x_return_status, p_rxhv_rec.language);
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
  -----------------------------------------------------
  -- Validate Record for:OKL_EXT_AR_HEADER_SOURCES_V --
  -----------------------------------------------------
  FUNCTION Validate_Record (
    p_rxhv_rec IN rxhv_rec_type,
    p_db_rxhv_rec IN rxhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_rxhv_rec IN rxhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_rxhv_rec                  rxhv_rec_type := get_rec(p_rxhv_rec);
  BEGIN
    l_return_status := Validate_Record(p_rxhv_rec => p_rxhv_rec,
                                       p_db_rxhv_rec => l_db_rxhv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN rxhv_rec_type,
    p_to   IN OUT NOCOPY rxh_rec_type
  ) IS
  BEGIN
    p_to.header_extension_id := p_from.header_extension_id;
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    p_to.object_version_number := p_from.object_version_number;
    p_to.khr_id := p_from.khr_id;
    p_to.try_id := p_from.try_id;
    p_to.trans_number := p_from.trans_number;
    p_to.contract_number := p_from.contract_number;
    p_to.product_name := p_from.product_name;
    p_to.book_classification_code := p_from.book_classification_code;
    p_to.tax_owner_code := p_from.tax_owner_code;
    p_to.int_calc_method_code := p_from.int_calc_method_code;
    p_to.rev_rec_method_code := p_from.rev_rec_method_code;
    p_to.scs_code := p_from.scs_code;
    p_to.converted_number := p_from.converted_number;
    p_to.contract_effective_from := p_from.contract_effective_from;
    p_to.contract_currency_code := p_from.contract_currency_code;
    p_to.sales_rep_name := p_from.sales_rep_name;
    p_to.po_order_number := p_from.po_order_number;
    p_to.vendor_program_number := p_from.vendor_program_number;
    p_to.assignable_flag := p_from.assignable_flag;
    p_to.converted_account_flag := p_from.converted_account_flag;
    p_to.accrual_override_flag := p_from.accrual_override_flag;
    p_to.term_quote_accept_date := p_from.term_quote_accept_date;
    p_to.term_quote_num := p_from.term_quote_num;
    p_to.term_quote_type_code := p_from.term_quote_type_code;
    p_to.khr_attribute_category := p_from.khr_attribute_category;
    p_to.khr_attribute1 := p_from.khr_attribute1;
    p_to.khr_attribute2 := p_from.khr_attribute2;
    p_to.khr_attribute3 := p_from.khr_attribute3;
    p_to.khr_attribute4 := p_from.khr_attribute4;
    p_to.khr_attribute5 := p_from.khr_attribute5;
    p_to.khr_attribute6 := p_from.khr_attribute6;
    p_to.khr_attribute7 := p_from.khr_attribute7;
    p_to.khr_attribute8 := p_from.khr_attribute8;
    p_to.khr_attribute9 := p_from.khr_attribute9;
    p_to.khr_attribute10 := p_from.khr_attribute10;
    p_to.khr_attribute11 := p_from.khr_attribute11;
    p_to.khr_attribute12 := p_from.khr_attribute12;
    p_to.khr_attribute13 := p_from.khr_attribute13;
    p_to.khr_attribute14 := p_from.khr_attribute14;
    p_to.khr_attribute15 := p_from.khr_attribute15;
    p_to.cust_attribute_category := p_from.cust_attribute_category;
    p_to.cust_attribute1 := p_from.cust_attribute1;
    p_to.cust_attribute2 := p_from.cust_attribute2;
    p_to.cust_attribute3 := p_from.cust_attribute3;
    p_to.cust_attribute4 := p_from.cust_attribute4;
    p_to.cust_attribute5 := p_from.cust_attribute5;
    p_to.cust_attribute6 := p_from.cust_attribute6;
    p_to.cust_attribute7 := p_from.cust_attribute7;
    p_to.cust_attribute8 := p_from.cust_attribute8;
    p_to.cust_attribute9 := p_from.cust_attribute9;
    p_to.cust_attribute10 := p_from.cust_attribute10;
    p_to.cust_attribute11 := p_from.cust_attribute11;
    p_to.cust_attribute12 := p_from.cust_attribute12;
    p_to.cust_attribute13 := p_from.cust_attribute13;
    p_to.cust_attribute14 := p_from.cust_attribute14;
    p_to.cust_attribute15 := p_from.cust_attribute15;
    p_to.rent_ia_contract_number := p_from.rent_ia_contract_number;
    p_to.rent_ia_product_name := p_from.rent_ia_product_name;
    p_to.rent_ia_accounting_code := p_from.rent_ia_accounting_code;
    p_to.res_ia_contract_number := p_from.res_ia_contract_number;
    p_to.res_ia_product_name := p_from.res_ia_product_name;
    p_to.res_ia_accounting_code := p_from.res_ia_accounting_code;
    p_to.inv_agrmnt_number := p_from.inv_agrmnt_number;
    p_to.inv_agrmnt_effective_from := p_from.inv_agrmnt_effective_from;
    p_to.inv_agrmnt_product_name := p_from.inv_agrmnt_product_name;
    p_to.inv_agrmnt_currency_code := p_from.inv_agrmnt_currency_code;
    p_to.inv_agrmnt_synd_code := p_from.inv_agrmnt_synd_code;
    p_to.inv_agrmnt_pool_number := p_from.inv_agrmnt_pool_number;
    p_to.contract_status_code := p_from.contract_status_code;
    p_to.inv_agrmnt_status_code := p_from.inv_agrmnt_status_code;
    p_to.trx_type_class_code := p_from.trx_type_class_code;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN rxh_rec_type,
    p_to   IN OUT NOCOPY rxhv_rec_type
  ) IS
  BEGIN
    p_to.header_extension_id := p_from.header_extension_id;
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    p_to.object_version_number := p_from.object_version_number;
    p_to.khr_id := p_from.khr_id;
    p_to.try_id := p_from.try_id;
    p_to.trans_number := p_from.trans_number;
    p_to.contract_number := p_from.contract_number;
    p_to.product_name := p_from.product_name;
    p_to.book_classification_code := p_from.book_classification_code;
    p_to.tax_owner_code := p_from.tax_owner_code;
    p_to.int_calc_method_code := p_from.int_calc_method_code;
    p_to.rev_rec_method_code := p_from.rev_rec_method_code;
    p_to.scs_code := p_from.scs_code;
    p_to.converted_number := p_from.converted_number;
    p_to.contract_effective_from := p_from.contract_effective_from;
    p_to.contract_currency_code := p_from.contract_currency_code;
    p_to.sales_rep_name := p_from.sales_rep_name;
    p_to.po_order_number := p_from.po_order_number;
    p_to.vendor_program_number := p_from.vendor_program_number;
    p_to.assignable_flag := p_from.assignable_flag;
    p_to.converted_account_flag := p_from.converted_account_flag;
    p_to.accrual_override_flag := p_from.accrual_override_flag;
    p_to.term_quote_accept_date := p_from.term_quote_accept_date;
    p_to.term_quote_num := p_from.term_quote_num;
    p_to.term_quote_type_code := p_from.term_quote_type_code;
    p_to.khr_attribute_category := p_from.khr_attribute_category;
    p_to.khr_attribute1 := p_from.khr_attribute1;
    p_to.khr_attribute2 := p_from.khr_attribute2;
    p_to.khr_attribute3 := p_from.khr_attribute3;
    p_to.khr_attribute4 := p_from.khr_attribute4;
    p_to.khr_attribute5 := p_from.khr_attribute5;
    p_to.khr_attribute6 := p_from.khr_attribute6;
    p_to.khr_attribute7 := p_from.khr_attribute7;
    p_to.khr_attribute8 := p_from.khr_attribute8;
    p_to.khr_attribute9 := p_from.khr_attribute9;
    p_to.khr_attribute10 := p_from.khr_attribute10;
    p_to.khr_attribute11 := p_from.khr_attribute11;
    p_to.khr_attribute12 := p_from.khr_attribute12;
    p_to.khr_attribute13 := p_from.khr_attribute13;
    p_to.khr_attribute14 := p_from.khr_attribute14;
    p_to.khr_attribute15 := p_from.khr_attribute15;
    p_to.cust_attribute_category := p_from.cust_attribute_category;
    p_to.cust_attribute1 := p_from.cust_attribute1;
    p_to.cust_attribute2 := p_from.cust_attribute2;
    p_to.cust_attribute3 := p_from.cust_attribute3;
    p_to.cust_attribute4 := p_from.cust_attribute4;
    p_to.cust_attribute5 := p_from.cust_attribute5;
    p_to.cust_attribute6 := p_from.cust_attribute6;
    p_to.cust_attribute7 := p_from.cust_attribute7;
    p_to.cust_attribute8 := p_from.cust_attribute8;
    p_to.cust_attribute9 := p_from.cust_attribute9;
    p_to.cust_attribute10 := p_from.cust_attribute10;
    p_to.cust_attribute11 := p_from.cust_attribute11;
    p_to.cust_attribute12 := p_from.cust_attribute12;
    p_to.cust_attribute13 := p_from.cust_attribute13;
    p_to.cust_attribute14 := p_from.cust_attribute14;
    p_to.cust_attribute15 := p_from.cust_attribute15;
    p_to.rent_ia_contract_number := p_from.rent_ia_contract_number;
    p_to.rent_ia_product_name := p_from.rent_ia_product_name;
    p_to.rent_ia_accounting_code := p_from.rent_ia_accounting_code;
    p_to.res_ia_contract_number := p_from.res_ia_contract_number;
    p_to.res_ia_product_name := p_from.res_ia_product_name;
    p_to.res_ia_accounting_code := p_from.res_ia_accounting_code;
    p_to.inv_agrmnt_number := p_from.inv_agrmnt_number;
    p_to.inv_agrmnt_effective_from := p_from.inv_agrmnt_effective_from;
    p_to.inv_agrmnt_product_name := p_from.inv_agrmnt_product_name;
    p_to.inv_agrmnt_currency_code := p_from.inv_agrmnt_currency_code;
    p_to.inv_agrmnt_synd_code := p_from.inv_agrmnt_synd_code;
    p_to.inv_agrmnt_pool_number := p_from.inv_agrmnt_pool_number;
    p_to.contract_status_code := p_from.contract_status_code;
    p_to.inv_agrmnt_status_code := p_from.inv_agrmnt_status_code;
    p_to.trx_type_class_code := p_from.trx_type_class_code;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN rxhv_rec_type,
    p_to   IN OUT NOCOPY rxhl_rec_type
  ) IS
  BEGIN
    p_to.header_extension_id := p_from.header_extension_id;
    p_to.language := p_from.language;
    p_to.contract_status := p_from.contract_status;
    p_to.inv_agrmnt_status := p_from.inv_agrmnt_status;
    p_to.transaction_type_name := p_from.transaction_type_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN rxhl_rec_type,
    p_to   IN OUT NOCOPY rxhv_rec_type
  ) IS
  BEGIN
    p_to.header_extension_id := p_from.header_extension_id;
    p_to.language := p_from.language;
    p_to.contract_status := p_from.contract_status;
    p_to.inv_agrmnt_status := p_from.inv_agrmnt_status;
    p_to.transaction_type_name := p_from.transaction_type_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- validate_row for:OKL_EXT_AR_HEADER_SOURCES_V --
  --------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_rec                     IN rxhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxhv_rec                     rxhv_rec_type := p_rxhv_rec;
    l_rxh_rec                      rxh_rec_type;
    l_rxhl_rec                     rxhl_rec_type;
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
    l_return_status := Validate_Attributes(l_rxhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rxhv_rec);
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
  -------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_EXT_AR_HEADER_SOURCES_V --
  -------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_tbl                     IN rxhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      i := p_rxhv_tbl.FIRST;
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
            p_rxhv_rec                     => p_rxhv_tbl(i));
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
        EXIT WHEN (i = p_rxhv_tbl.LAST);
        i := p_rxhv_tbl.NEXT(i);
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

  -------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_EXT_AR_HEADER_SOURCES_V --
  -------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_tbl                     IN rxhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_rxhv_tbl                     => p_rxhv_tbl,
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
  ------------------------------------------------
  -- insert_row for:OKL_EXT_AR_HEADER_SOURCES_B --
  ------------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxh_rec                      IN rxh_rec_type,
    x_rxh_rec                      OUT NOCOPY rxh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxh_rec                      rxh_rec_type := p_rxh_rec;
    l_def_rxh_rec                  rxh_rec_type;
    ----------------------------------------------------
    -- Set_Attributes for:OKL_EXT_AR_HEADER_SOURCES_B --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_rxh_rec IN rxh_rec_type,
      x_rxh_rec OUT NOCOPY rxh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rxh_rec := p_rxh_rec;
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
      l_rxh_rec,                         -- IN
      l_def_rxh_rec);                    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_EXT_AR_HEADER_SOURCES_B(
      header_extension_id,
      source_id,
      source_table,
      object_version_number,
      khr_id,
      try_id,
      trans_number,
      contract_number,
      product_name,
      book_classification_code,
      tax_owner_code,
      int_calc_method_code,
      rev_rec_method_code,
      scs_code,
      converted_number,
      contract_effective_from,
      contract_currency_code,
      sales_rep_name,
      po_order_number,
      vendor_program_number,
      assignable_flag,
      converted_account_flag,
      accrual_override_flag,
      term_quote_accept_date,
      term_quote_num,
      term_quote_type_code,
      khr_attribute_category,
      khr_attribute1,
      khr_attribute2,
      khr_attribute3,
      khr_attribute4,
      khr_attribute5,
      khr_attribute6,
      khr_attribute7,
      khr_attribute8,
      khr_attribute9,
      khr_attribute10,
      khr_attribute11,
      khr_attribute12,
      khr_attribute13,
      khr_attribute14,
      khr_attribute15,
      cust_attribute_category,
      cust_attribute1,
      cust_attribute2,
      cust_attribute3,
      cust_attribute4,
      cust_attribute5,
      cust_attribute6,
      cust_attribute7,
      cust_attribute8,
      cust_attribute9,
      cust_attribute10,
      cust_attribute11,
      cust_attribute12,
      cust_attribute13,
      cust_attribute14,
      cust_attribute15,
      rent_ia_contract_number,
      rent_ia_product_name,
      rent_ia_accounting_code,
      res_ia_contract_number,
      res_ia_product_name,
      res_ia_accounting_code,
      inv_agrmnt_number,
      inv_agrmnt_effective_from,
      inv_agrmnt_product_name,
      inv_agrmnt_currency_code,
      inv_agrmnt_synd_code,
      inv_agrmnt_pool_number,
      contract_status_code,
      inv_agrmnt_status_code,
      trx_type_class_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_def_rxh_rec.header_extension_id,
      l_def_rxh_rec.source_id,
      l_def_rxh_rec.source_table,
      l_def_rxh_rec.object_version_number,
      l_def_rxh_rec.khr_id,
      l_def_rxh_rec.try_id,
      l_def_rxh_rec.trans_number,
      l_def_rxh_rec.contract_number,
      l_def_rxh_rec.product_name,
      l_def_rxh_rec.book_classification_code,
      l_def_rxh_rec.tax_owner_code,
      l_def_rxh_rec.int_calc_method_code,
      l_def_rxh_rec.rev_rec_method_code,
      l_def_rxh_rec.scs_code,
      l_def_rxh_rec.converted_number,
      l_def_rxh_rec.contract_effective_from,
      l_def_rxh_rec.contract_currency_code,
      l_def_rxh_rec.sales_rep_name,
      l_def_rxh_rec.po_order_number,
      l_def_rxh_rec.vendor_program_number,
      l_def_rxh_rec.assignable_flag,
      l_def_rxh_rec.converted_account_flag,
      l_def_rxh_rec.accrual_override_flag,
      l_def_rxh_rec.term_quote_accept_date,
      l_def_rxh_rec.term_quote_num,
      l_def_rxh_rec.term_quote_type_code,
      l_def_rxh_rec.khr_attribute_category,
      l_def_rxh_rec.khr_attribute1,
      l_def_rxh_rec.khr_attribute2,
      l_def_rxh_rec.khr_attribute3,
      l_def_rxh_rec.khr_attribute4,
      l_def_rxh_rec.khr_attribute5,
      l_def_rxh_rec.khr_attribute6,
      l_def_rxh_rec.khr_attribute7,
      l_def_rxh_rec.khr_attribute8,
      l_def_rxh_rec.khr_attribute9,
      l_def_rxh_rec.khr_attribute10,
      l_def_rxh_rec.khr_attribute11,
      l_def_rxh_rec.khr_attribute12,
      l_def_rxh_rec.khr_attribute13,
      l_def_rxh_rec.khr_attribute14,
      l_def_rxh_rec.khr_attribute15,
      l_def_rxh_rec.cust_attribute_category,
      l_def_rxh_rec.cust_attribute1,
      l_def_rxh_rec.cust_attribute2,
      l_def_rxh_rec.cust_attribute3,
      l_def_rxh_rec.cust_attribute4,
      l_def_rxh_rec.cust_attribute5,
      l_def_rxh_rec.cust_attribute6,
      l_def_rxh_rec.cust_attribute7,
      l_def_rxh_rec.cust_attribute8,
      l_def_rxh_rec.cust_attribute9,
      l_def_rxh_rec.cust_attribute10,
      l_def_rxh_rec.cust_attribute11,
      l_def_rxh_rec.cust_attribute12,
      l_def_rxh_rec.cust_attribute13,
      l_def_rxh_rec.cust_attribute14,
      l_def_rxh_rec.cust_attribute15,
      l_def_rxh_rec.rent_ia_contract_number,
      l_def_rxh_rec.rent_ia_product_name,
      l_def_rxh_rec.rent_ia_accounting_code,
      l_def_rxh_rec.res_ia_contract_number,
      l_def_rxh_rec.res_ia_product_name,
      l_def_rxh_rec.res_ia_accounting_code,
      l_def_rxh_rec.inv_agrmnt_number,
      l_def_rxh_rec.inv_agrmnt_effective_from,
      l_def_rxh_rec.inv_agrmnt_product_name,
      l_def_rxh_rec.inv_agrmnt_currency_code,
      l_def_rxh_rec.inv_agrmnt_synd_code,
      l_def_rxh_rec.inv_agrmnt_pool_number,
      l_def_rxh_rec.contract_status_code,
      l_def_rxh_rec.inv_agrmnt_status_code,
      l_def_rxh_rec.trx_type_class_code,
      l_def_rxh_rec.created_by,
      l_def_rxh_rec.creation_date,
      l_def_rxh_rec.last_updated_by,
      l_def_rxh_rec.last_update_date,
      l_def_rxh_rec.last_update_login);
    -- Set OUT values
    x_rxh_rec := l_def_rxh_rec;
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
  -------------------------------------------------
  -- insert_row for:OKL_EXT_AR_HEADER_SOURCES_TL --
  -------------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhl_rec                     IN rxhl_rec_type,
    x_rxhl_rec                     OUT NOCOPY rxhl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxhl_rec                     rxhl_rec_type := p_rxhl_rec;
    l_def_rxhl_rec                 rxhl_rec_type;
/*
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
*/
    -----------------------------------------------------
    -- Set_Attributes for:OKL_EXT_AR_HEADER_SOURCES_TL --
    -----------------------------------------------------
    FUNCTION Set_Attributes (
      p_rxhl_rec IN rxhl_rec_type,
      x_rxhl_rec OUT NOCOPY rxhl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rxhl_rec := p_rxhl_rec;
      x_rxhl_rec.SOURCE_LANG := USERENV('LANG');
      x_rxhl_rec.SFWT_FLAG   := 'N';
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
      p_rxhl_rec,                        -- IN
      l_rxhl_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_EXT_AR_HEADER_SOURCES_TL(
      header_extension_id,
      language,
      source_lang,
      sfwt_flag,
      contract_status,
      inv_agrmnt_status,
      transaction_type_name,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_rxhl_rec.header_extension_id,
      l_rxhl_rec.language,
      l_rxhl_rec.source_lang,
      l_rxhl_rec.sfwt_flag,
      l_rxhl_rec.contract_status,
      l_rxhl_rec.inv_agrmnt_status,
      l_rxhl_rec.transaction_type_name,
      l_rxhl_rec.created_by,
      l_rxhl_rec.creation_date,
      l_rxhl_rec.last_updated_by,
      l_rxhl_rec.last_update_date,
      l_rxhl_rec.last_update_login);
    -- Set OUT values
    x_rxhl_rec := l_rxhl_rec;
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
  -------------------------------------------------
  -- insert_row for :OKL_EXT_AR_HEADER_SOURCES_B --
  -------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_rec                     IN rxhv_rec_type,
    x_rxhv_rec                     OUT NOCOPY rxhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxhv_rec                     rxhv_rec_type := p_rxhv_rec;
    l_def_rxhv_rec                 rxhv_rec_type;
    l_rxh_rec                      rxh_rec_type;
    lx_rxh_rec                     rxh_rec_type;
    l_rxhl_rec                     rxhl_rec_type;
    lx_rxhl_rec                    rxhl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rxhv_rec IN rxhv_rec_type
    ) RETURN rxhv_rec_type IS
      l_rxhv_rec rxhv_rec_type := p_rxhv_rec;
    BEGIN
      l_rxhv_rec.CREATION_DATE := SYSDATE;
      l_rxhv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rxhv_rec.LAST_UPDATE_DATE := l_rxhv_rec.CREATION_DATE;
      l_rxhv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rxhv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rxhv_rec);
    END fill_who_columns;
    ----------------------------------------------------
    -- Set_Attributes for:OKL_EXT_AR_HEADER_SOURCES_B --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_rxhv_rec IN rxhv_rec_type,
      x_rxhv_rec OUT NOCOPY rxhv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rxhv_rec := p_rxhv_rec;
      x_rxhv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_rxhv_rec := null_out_defaults(p_rxhv_rec);
    -- Set primary key value
    l_rxhv_rec.HEADER_EXTENSION_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_rxhv_rec,                        -- IN
      l_def_rxhv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rxhv_rec := fill_who_columns(l_def_rxhv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rxhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rxhv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_rxhv_rec, l_rxh_rec);
    migrate(l_def_rxhv_rec, l_rxhl_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rxh_rec,
      lx_rxh_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rxh_rec, l_def_rxhv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rxhl_rec,
      lx_rxhl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rxhl_rec, l_def_rxhv_rec);
    -- Set OUT values
    x_rxhv_rec := l_def_rxhv_rec;
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
  -- PL/SQL TBL insert_row for:RXHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_tbl                     IN rxhv_tbl_type,
    x_rxhv_tbl                     OUT NOCOPY rxhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      i := p_rxhv_tbl.FIRST;
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
            p_rxhv_rec                     => p_rxhv_tbl(i),
            x_rxhv_rec                     => x_rxhv_tbl(i));
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
        EXIT WHEN (i = p_rxhv_tbl.LAST);
        i := p_rxhv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:RXHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_tbl                     IN rxhv_tbl_type,
    x_rxhv_tbl                     OUT NOCOPY rxhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_rxhv_tbl                     => p_rxhv_tbl,
        x_rxhv_tbl                     => x_rxhv_tbl,
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
  ----------------------------------------------
  -- lock_row for:OKL_EXT_AR_HEADER_SOURCES_B --
  ----------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxh_rec                      IN rxh_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rxh_rec IN rxh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_EXT_AR_HEADER_SOURCES_B
     WHERE HEADER_EXTENSION_ID = p_rxh_rec.header_extension_id
       AND OBJECT_VERSION_NUMBER = p_rxh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_rxh_rec IN rxh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_EXT_AR_HEADER_SOURCES_B
     WHERE HEADER_EXTENSION_ID = p_rxh_rec.header_extension_id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_EXT_AR_HEADER_SOURCES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_EXT_AR_HEADER_SOURCES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_rxh_rec);
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
      OPEN lchk_csr(p_rxh_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rxh_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rxh_rec.object_version_number THEN
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
  -----------------------------------------------
  -- lock_row for:OKL_EXT_AR_HEADER_SOURCES_TL --
  -----------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhl_rec                     IN rxhl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rxhl_rec IN rxhl_rec_type) IS
    SELECT *
      FROM OKL_EXT_AR_HEADER_SOURCES_TL
     WHERE HEADER_EXTENSION_ID = p_rxhl_rec.header_extension_id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
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
      OPEN lock_csr(p_rxhl_rec);
      FETCH lock_csr INTO l_lock_var;
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
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
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
  -----------------------------------------------
  -- lock_row for: OKL_EXT_AR_HEADER_SOURCES_V --
  -----------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_rec                     IN rxhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxh_rec                      rxh_rec_type;
    l_rxhl_rec                     rxhl_rec_type;
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
    migrate(p_rxhv_rec, l_rxh_rec);
    migrate(p_rxhv_rec, l_rxhl_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rxh_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rxhl_rec
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
  -- PL/SQL TBL lock_row for:RXHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_tbl                     IN rxhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      i := p_rxhv_tbl.FIRST;
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
            p_rxhv_rec                     => p_rxhv_tbl(i));
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
        EXIT WHEN (i = p_rxhv_tbl.LAST);
        i := p_rxhv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:RXHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_tbl                     IN rxhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_rxhv_tbl                     => p_rxhv_tbl,
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
  ------------------------------------------------
  -- update_row for:OKL_EXT_AR_HEADER_SOURCES_B --
  ------------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxh_rec                      IN rxh_rec_type,
    x_rxh_rec                      OUT NOCOPY rxh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxh_rec                      rxh_rec_type := p_rxh_rec;
    l_def_rxh_rec                  rxh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rxh_rec IN rxh_rec_type,
      x_rxh_rec OUT NOCOPY rxh_rec_type
    ) RETURN VARCHAR2 IS
      l_rxh_rec                      rxh_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rxh_rec := p_rxh_rec;
      -- Get current database values
      l_rxh_rec := get_rec(p_rxh_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_rxh_rec.header_extension_id IS NULL THEN
          x_rxh_rec.header_extension_id := l_rxh_rec.header_extension_id;
        END IF;
        IF x_rxh_rec.source_id IS NULL THEN
          x_rxh_rec.source_id := l_rxh_rec.source_id;
        END IF;
        IF x_rxh_rec.source_table IS NULL THEN
          x_rxh_rec.source_table := l_rxh_rec.source_table;
        END IF;
        IF x_rxh_rec.object_version_number IS NULL THEN
          x_rxh_rec.object_version_number := l_rxh_rec.object_version_number;
        END IF;
        IF x_rxh_rec.khr_id IS NULL THEN
          x_rxh_rec.khr_id := l_rxh_rec.khr_id;
        END IF;
        IF x_rxh_rec.try_id IS NULL THEN
          x_rxh_rec.try_id := l_rxh_rec.try_id;
        END IF;
        IF x_rxh_rec.trans_number IS NULL THEN
          x_rxh_rec.trans_number := l_rxh_rec.trans_number;
        END IF;
        IF x_rxh_rec.contract_number IS NULL THEN
          x_rxh_rec.contract_number := l_rxh_rec.contract_number;
        END IF;
        IF x_rxh_rec.product_name IS NULL THEN
          x_rxh_rec.product_name := l_rxh_rec.product_name;
        END IF;
        IF x_rxh_rec.book_classification_code IS NULL THEN
          x_rxh_rec.book_classification_code := l_rxh_rec.book_classification_code;
        END IF;
        IF x_rxh_rec.tax_owner_code IS NULL THEN
          x_rxh_rec.tax_owner_code := l_rxh_rec.tax_owner_code;
        END IF;
        IF x_rxh_rec.int_calc_method_code IS NULL THEN
          x_rxh_rec.int_calc_method_code := l_rxh_rec.int_calc_method_code;
        END IF;
        IF x_rxh_rec.rev_rec_method_code IS NULL THEN
          x_rxh_rec.rev_rec_method_code := l_rxh_rec.rev_rec_method_code;
        END IF;
        IF x_rxh_rec.scs_code IS NULL THEN
          x_rxh_rec.scs_code := l_rxh_rec.scs_code;
        END IF;
        IF x_rxh_rec.converted_number IS NULL THEN
          x_rxh_rec.converted_number := l_rxh_rec.converted_number;
        END IF;
        IF x_rxh_rec.contract_effective_from IS NULL THEN
          x_rxh_rec.contract_effective_from := l_rxh_rec.contract_effective_from;
        END IF;
        IF x_rxh_rec.contract_currency_code IS NULL THEN
          x_rxh_rec.contract_currency_code := l_rxh_rec.contract_currency_code;
        END IF;
        IF x_rxh_rec.sales_rep_name IS NULL THEN
          x_rxh_rec.sales_rep_name := l_rxh_rec.sales_rep_name;
        END IF;
        IF x_rxh_rec.po_order_number IS NULL THEN
          x_rxh_rec.po_order_number := l_rxh_rec.po_order_number;
        END IF;
        IF x_rxh_rec.vendor_program_number IS NULL THEN
          x_rxh_rec.vendor_program_number := l_rxh_rec.vendor_program_number;
        END IF;
        IF x_rxh_rec.assignable_flag IS NULL THEN
          x_rxh_rec.assignable_flag := l_rxh_rec.assignable_flag;
        END IF;
        IF x_rxh_rec.converted_account_flag IS NULL THEN
          x_rxh_rec.converted_account_flag := l_rxh_rec.converted_account_flag;
        END IF;
        IF x_rxh_rec.accrual_override_flag IS NULL THEN
          x_rxh_rec.accrual_override_flag := l_rxh_rec.accrual_override_flag;
        END IF;
        IF x_rxh_rec.term_quote_accept_date IS NULL THEN
          x_rxh_rec.term_quote_accept_date := l_rxh_rec.term_quote_accept_date;
        END IF;
        IF x_rxh_rec.term_quote_num IS NULL THEN
          x_rxh_rec.term_quote_num := l_rxh_rec.term_quote_num;
        END IF;
        IF x_rxh_rec.term_quote_type_code IS NULL THEN
          x_rxh_rec.term_quote_type_code := l_rxh_rec.term_quote_type_code;
        END IF;
        IF x_rxh_rec.khr_attribute_category IS NULL THEN
          x_rxh_rec.khr_attribute_category := l_rxh_rec.khr_attribute_category;
        END IF;
        IF x_rxh_rec.khr_attribute1 IS NULL THEN
          x_rxh_rec.khr_attribute1 := l_rxh_rec.khr_attribute1;
        END IF;
        IF x_rxh_rec.khr_attribute2 IS NULL THEN
          x_rxh_rec.khr_attribute2 := l_rxh_rec.khr_attribute2;
        END IF;
        IF x_rxh_rec.khr_attribute3 IS NULL THEN
          x_rxh_rec.khr_attribute3 := l_rxh_rec.khr_attribute3;
        END IF;
        IF x_rxh_rec.khr_attribute4 IS NULL THEN
          x_rxh_rec.khr_attribute4 := l_rxh_rec.khr_attribute4;
        END IF;
        IF x_rxh_rec.khr_attribute5 IS NULL THEN
          x_rxh_rec.khr_attribute5 := l_rxh_rec.khr_attribute5;
        END IF;
        IF x_rxh_rec.khr_attribute6 IS NULL THEN
          x_rxh_rec.khr_attribute6 := l_rxh_rec.khr_attribute6;
        END IF;
        IF x_rxh_rec.khr_attribute7 IS NULL THEN
          x_rxh_rec.khr_attribute7 := l_rxh_rec.khr_attribute7;
        END IF;
        IF x_rxh_rec.khr_attribute8 IS NULL THEN
          x_rxh_rec.khr_attribute8 := l_rxh_rec.khr_attribute8;
        END IF;
        IF x_rxh_rec.khr_attribute9 IS NULL THEN
          x_rxh_rec.khr_attribute9 := l_rxh_rec.khr_attribute9;
        END IF;
        IF x_rxh_rec.khr_attribute10 IS NULL THEN
          x_rxh_rec.khr_attribute10 := l_rxh_rec.khr_attribute10;
        END IF;
        IF x_rxh_rec.khr_attribute11 IS NULL THEN
          x_rxh_rec.khr_attribute11 := l_rxh_rec.khr_attribute11;
        END IF;
        IF x_rxh_rec.khr_attribute12 IS NULL THEN
          x_rxh_rec.khr_attribute12 := l_rxh_rec.khr_attribute12;
        END IF;
        IF x_rxh_rec.khr_attribute13 IS NULL THEN
          x_rxh_rec.khr_attribute13 := l_rxh_rec.khr_attribute13;
        END IF;
        IF x_rxh_rec.khr_attribute14 IS NULL THEN
          x_rxh_rec.khr_attribute14 := l_rxh_rec.khr_attribute14;
        END IF;
        IF x_rxh_rec.khr_attribute15 IS NULL THEN
          x_rxh_rec.khr_attribute15 := l_rxh_rec.khr_attribute15;
        END IF;
        IF x_rxh_rec.cust_attribute_category IS NULL THEN
          x_rxh_rec.cust_attribute_category := l_rxh_rec.cust_attribute_category;
        END IF;
        IF x_rxh_rec.cust_attribute1 IS NULL THEN
          x_rxh_rec.cust_attribute1 := l_rxh_rec.cust_attribute1;
        END IF;
        IF x_rxh_rec.cust_attribute2 IS NULL THEN
          x_rxh_rec.cust_attribute2 := l_rxh_rec.cust_attribute2;
        END IF;
        IF x_rxh_rec.cust_attribute3 IS NULL THEN
          x_rxh_rec.cust_attribute3 := l_rxh_rec.cust_attribute3;
        END IF;
        IF x_rxh_rec.cust_attribute4 IS NULL THEN
          x_rxh_rec.cust_attribute4 := l_rxh_rec.cust_attribute4;
        END IF;
        IF x_rxh_rec.cust_attribute5 IS NULL THEN
          x_rxh_rec.cust_attribute5 := l_rxh_rec.cust_attribute5;
        END IF;
        IF x_rxh_rec.cust_attribute6 IS NULL THEN
          x_rxh_rec.cust_attribute6 := l_rxh_rec.cust_attribute6;
        END IF;
        IF x_rxh_rec.cust_attribute7 IS NULL THEN
          x_rxh_rec.cust_attribute7 := l_rxh_rec.cust_attribute7;
        END IF;
        IF x_rxh_rec.cust_attribute8 IS NULL THEN
          x_rxh_rec.cust_attribute8 := l_rxh_rec.cust_attribute8;
        END IF;
        IF x_rxh_rec.cust_attribute9 IS NULL THEN
          x_rxh_rec.cust_attribute9 := l_rxh_rec.cust_attribute9;
        END IF;
        IF x_rxh_rec.cust_attribute10 IS NULL THEN
          x_rxh_rec.cust_attribute10 := l_rxh_rec.cust_attribute10;
        END IF;
        IF x_rxh_rec.cust_attribute11 IS NULL THEN
          x_rxh_rec.cust_attribute11 := l_rxh_rec.cust_attribute11;
        END IF;
        IF x_rxh_rec.cust_attribute12 IS NULL THEN
          x_rxh_rec.cust_attribute12 := l_rxh_rec.cust_attribute12;
        END IF;
        IF x_rxh_rec.cust_attribute13 IS NULL THEN
          x_rxh_rec.cust_attribute13 := l_rxh_rec.cust_attribute13;
        END IF;
        IF x_rxh_rec.cust_attribute14 IS NULL THEN
          x_rxh_rec.cust_attribute14 := l_rxh_rec.cust_attribute14;
        END IF;
        IF x_rxh_rec.cust_attribute15 IS NULL THEN
          x_rxh_rec.cust_attribute15 := l_rxh_rec.cust_attribute15;
        END IF;
        IF x_rxh_rec.rent_ia_contract_number IS NULL THEN
          x_rxh_rec.rent_ia_contract_number := l_rxh_rec.rent_ia_contract_number;
        END IF;
        IF x_rxh_rec.rent_ia_product_name IS NULL THEN
          x_rxh_rec.rent_ia_product_name := l_rxh_rec.rent_ia_product_name;
        END IF;
        IF x_rxh_rec.rent_ia_accounting_code IS NULL THEN
          x_rxh_rec.rent_ia_accounting_code := l_rxh_rec.rent_ia_accounting_code;
        END IF;
        IF x_rxh_rec.res_ia_contract_number IS NULL THEN
          x_rxh_rec.res_ia_contract_number := l_rxh_rec.res_ia_contract_number;
        END IF;
        IF x_rxh_rec.res_ia_product_name IS NULL THEN
          x_rxh_rec.res_ia_product_name := l_rxh_rec.res_ia_product_name;
        END IF;
        IF x_rxh_rec.res_ia_accounting_code IS NULL THEN
          x_rxh_rec.res_ia_accounting_code := l_rxh_rec.res_ia_accounting_code;
        END IF;
        IF x_rxh_rec.inv_agrmnt_number IS NULL THEN
          x_rxh_rec.inv_agrmnt_number := l_rxh_rec.inv_agrmnt_number;
        END IF;
        IF x_rxh_rec.inv_agrmnt_effective_from IS NULL THEN
          x_rxh_rec.inv_agrmnt_effective_from := l_rxh_rec.inv_agrmnt_effective_from;
        END IF;
        IF x_rxh_rec.inv_agrmnt_product_name IS NULL THEN
          x_rxh_rec.inv_agrmnt_product_name := l_rxh_rec.inv_agrmnt_product_name;
        END IF;
        IF x_rxh_rec.inv_agrmnt_currency_code IS NULL THEN
          x_rxh_rec.inv_agrmnt_currency_code := l_rxh_rec.inv_agrmnt_currency_code;
        END IF;
        IF x_rxh_rec.inv_agrmnt_synd_code IS NULL THEN
          x_rxh_rec.inv_agrmnt_synd_code := l_rxh_rec.inv_agrmnt_synd_code;
        END IF;
        IF x_rxh_rec.inv_agrmnt_pool_number IS NULL THEN
          x_rxh_rec.inv_agrmnt_pool_number := l_rxh_rec.inv_agrmnt_pool_number;
        END IF;
        IF x_rxh_rec.contract_status_code IS NULL THEN
          x_rxh_rec.contract_status_code := l_rxh_rec.contract_status_code;
        END IF;
        IF x_rxh_rec.inv_agrmnt_status_code IS NULL THEN
          x_rxh_rec.inv_agrmnt_status_code := l_rxh_rec.inv_agrmnt_status_code;
        END IF;
        IF x_rxh_rec.trx_type_class_code IS NULL THEN
          x_rxh_rec.trx_type_class_code := l_rxh_rec.trx_type_class_code;
        END IF;
        IF x_rxh_rec.created_by IS NULL THEN
          x_rxh_rec.created_by := l_rxh_rec.created_by;
        END IF;
        IF x_rxh_rec.creation_date IS NULL THEN
          x_rxh_rec.creation_date := l_rxh_rec.creation_date;
        END IF;
        IF x_rxh_rec.last_updated_by IS NULL THEN
          x_rxh_rec.last_updated_by := l_rxh_rec.last_updated_by;
        END IF;
        IF x_rxh_rec.last_update_date IS NULL THEN
          x_rxh_rec.last_update_date := l_rxh_rec.last_update_date;
        END IF;
        IF x_rxh_rec.last_update_login IS NULL THEN
          x_rxh_rec.last_update_login := l_rxh_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------------
    -- Set_Attributes for:OKL_EXT_AR_HEADER_SOURCES_B --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_rxh_rec IN rxh_rec_type,
      x_rxh_rec OUT NOCOPY rxh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rxh_rec := p_rxh_rec;
      x_rxh_rec.OBJECT_VERSION_NUMBER := p_rxh_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_rxh_rec,                         -- IN
      l_rxh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rxh_rec, l_def_rxh_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_EXT_AR_HEADER_SOURCES_B
    SET SOURCE_ID = l_def_rxh_rec.source_id,
        SOURCE_TABLE = l_def_rxh_rec.source_table,
        OBJECT_VERSION_NUMBER = l_def_rxh_rec.object_version_number,
        KHR_ID = l_def_rxh_rec.khr_id,
        TRY_ID = l_def_rxh_rec.try_id,
        TRANS_NUMBER = l_def_rxh_rec.trans_number,
        CONTRACT_NUMBER = l_def_rxh_rec.contract_number,
        PRODUCT_NAME = l_def_rxh_rec.product_name,
        BOOK_CLASSIFICATION_CODE = l_def_rxh_rec.book_classification_code,
        TAX_OWNER_CODE = l_def_rxh_rec.tax_owner_code,
        INT_CALC_METHOD_CODE = l_def_rxh_rec.int_calc_method_code,
        REV_REC_METHOD_CODE = l_def_rxh_rec.rev_rec_method_code,
        SCS_CODE = l_def_rxh_rec.scs_code,
        CONVERTED_NUMBER = l_def_rxh_rec.converted_number,
        CONTRACT_EFFECTIVE_FROM = l_def_rxh_rec.contract_effective_from,
        CONTRACT_CURRENCY_CODE = l_def_rxh_rec.contract_currency_code,
        SALES_REP_NAME = l_def_rxh_rec.sales_rep_name,
        PO_ORDER_NUMBER = l_def_rxh_rec.po_order_number,
        VENDOR_PROGRAM_NUMBER = l_def_rxh_rec.vendor_program_number,
        ASSIGNABLE_FLAG = l_def_rxh_rec.assignable_flag,
        CONVERTED_ACCOUNT_FLAG = l_def_rxh_rec.converted_account_flag,
        ACCRUAL_OVERRIDE_FLAG = l_def_rxh_rec.accrual_override_flag,
        TERM_QUOTE_ACCEPT_DATE = l_def_rxh_rec.term_quote_accept_date,
        TERM_QUOTE_NUM = l_def_rxh_rec.term_quote_num,
        TERM_QUOTE_TYPE_CODE = l_def_rxh_rec.term_quote_type_code,
        KHR_ATTRIBUTE_CATEGORY = l_def_rxh_rec.khr_attribute_category,
        KHR_ATTRIBUTE1 = l_def_rxh_rec.khr_attribute1,
        KHR_ATTRIBUTE2 = l_def_rxh_rec.khr_attribute2,
        KHR_ATTRIBUTE3 = l_def_rxh_rec.khr_attribute3,
        KHR_ATTRIBUTE4 = l_def_rxh_rec.khr_attribute4,
        KHR_ATTRIBUTE5 = l_def_rxh_rec.khr_attribute5,
        KHR_ATTRIBUTE6 = l_def_rxh_rec.khr_attribute6,
        KHR_ATTRIBUTE7 = l_def_rxh_rec.khr_attribute7,
        KHR_ATTRIBUTE8 = l_def_rxh_rec.khr_attribute8,
        KHR_ATTRIBUTE9 = l_def_rxh_rec.khr_attribute9,
        KHR_ATTRIBUTE10 = l_def_rxh_rec.khr_attribute10,
        KHR_ATTRIBUTE11 = l_def_rxh_rec.khr_attribute11,
        KHR_ATTRIBUTE12 = l_def_rxh_rec.khr_attribute12,
        KHR_ATTRIBUTE13 = l_def_rxh_rec.khr_attribute13,
        KHR_ATTRIBUTE14 = l_def_rxh_rec.khr_attribute14,
        KHR_ATTRIBUTE15 = l_def_rxh_rec.khr_attribute15,
        CUST_ATTRIBUTE_CATEGORY = l_def_rxh_rec.cust_attribute_category,
        CUST_ATTRIBUTE1 = l_def_rxh_rec.cust_attribute1,
        CUST_ATTRIBUTE2 = l_def_rxh_rec.cust_attribute2,
        CUST_ATTRIBUTE3 = l_def_rxh_rec.cust_attribute3,
        CUST_ATTRIBUTE4 = l_def_rxh_rec.cust_attribute4,
        CUST_ATTRIBUTE5 = l_def_rxh_rec.cust_attribute5,
        CUST_ATTRIBUTE6 = l_def_rxh_rec.cust_attribute6,
        CUST_ATTRIBUTE7 = l_def_rxh_rec.cust_attribute7,
        CUST_ATTRIBUTE8 = l_def_rxh_rec.cust_attribute8,
        CUST_ATTRIBUTE9 = l_def_rxh_rec.cust_attribute9,
        CUST_ATTRIBUTE10 = l_def_rxh_rec.cust_attribute10,
        CUST_ATTRIBUTE11 = l_def_rxh_rec.cust_attribute11,
        CUST_ATTRIBUTE12 = l_def_rxh_rec.cust_attribute12,
        CUST_ATTRIBUTE13 = l_def_rxh_rec.cust_attribute13,
        CUST_ATTRIBUTE14 = l_def_rxh_rec.cust_attribute14,
        CUST_ATTRIBUTE15 = l_def_rxh_rec.cust_attribute15,
        RENT_IA_CONTRACT_NUMBER = l_def_rxh_rec.rent_ia_contract_number,
        RENT_IA_PRODUCT_NAME = l_def_rxh_rec.rent_ia_product_name,
        RENT_IA_ACCOUNTING_CODE = l_def_rxh_rec.rent_ia_accounting_code,
        RES_IA_CONTRACT_NUMBER = l_def_rxh_rec.res_ia_contract_number,
        RES_IA_PRODUCT_NAME = l_def_rxh_rec.res_ia_product_name,
        RES_IA_ACCOUNTING_CODE = l_def_rxh_rec.res_ia_accounting_code,
        INV_AGRMNT_NUMBER = l_def_rxh_rec.inv_agrmnt_number,
        INV_AGRMNT_EFFECTIVE_FROM = l_def_rxh_rec.inv_agrmnt_effective_from,
        INV_AGRMNT_PRODUCT_NAME = l_def_rxh_rec.inv_agrmnt_product_name,
        INV_AGRMNT_CURRENCY_CODE = l_def_rxh_rec.inv_agrmnt_currency_code,
        INV_AGRMNT_SYND_CODE = l_def_rxh_rec.inv_agrmnt_synd_code,
        INV_AGRMNT_POOL_NUMBER = l_def_rxh_rec.inv_agrmnt_pool_number,
        CONTRACT_STATUS_CODE = l_def_rxh_rec.contract_status_code,
        INV_AGRMNT_STATUS_CODE = l_def_rxh_rec.inv_agrmnt_status_code,
        TRX_TYPE_CLASS_CODE = l_def_rxh_rec.trx_type_class_code,
        CREATED_BY = l_def_rxh_rec.created_by,
        CREATION_DATE = l_def_rxh_rec.creation_date,
        LAST_UPDATED_BY = l_def_rxh_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rxh_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rxh_rec.last_update_login
    WHERE HEADER_EXTENSION_ID = l_def_rxh_rec.header_extension_id;

    x_rxh_rec := l_rxh_rec;
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
  -------------------------------------------------
  -- update_row for:OKL_EXT_AR_HEADER_SOURCES_TL --
  -------------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhl_rec                     IN rxhl_rec_type,
    x_rxhl_rec                     OUT NOCOPY rxhl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxhl_rec                     rxhl_rec_type := p_rxhl_rec;
    l_def_rxhl_rec                 rxhl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rxhl_rec IN rxhl_rec_type,
      x_rxhl_rec OUT NOCOPY rxhl_rec_type
    ) RETURN VARCHAR2 IS
      l_rxhl_rec                     rxhl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rxhl_rec := p_rxhl_rec;
      -- Get current database values
      l_rxhl_rec := get_rec(p_rxhl_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_rxhl_rec.header_extension_id IS NULL THEN
          x_rxhl_rec.header_extension_id := l_rxhl_rec.header_extension_id;
        END IF;
        IF x_rxhl_rec.language IS NULL THEN
          x_rxhl_rec.language := l_rxhl_rec.language;
        END IF;
        IF x_rxhl_rec.source_lang IS NULL THEN
          x_rxhl_rec.source_lang := l_rxhl_rec.source_lang;
        END IF;
        IF x_rxhl_rec.sfwt_flag IS NULL THEN
          x_rxhl_rec.sfwt_flag := l_rxhl_rec.sfwt_flag;
        END IF;
        IF x_rxhl_rec.contract_status IS NULL THEN
          x_rxhl_rec.contract_status := l_rxhl_rec.contract_status;
        END IF;
        IF x_rxhl_rec.inv_agrmnt_status IS NULL THEN
          x_rxhl_rec.inv_agrmnt_status := l_rxhl_rec.inv_agrmnt_status;
        END IF;
        IF x_rxhl_rec.transaction_type_name IS NULL THEN
          x_rxhl_rec.transaction_type_name := l_rxhl_rec.transaction_type_name;
        END IF;
        IF x_rxhl_rec.created_by IS NULL THEN
          x_rxhl_rec.created_by := l_rxhl_rec.created_by;
        END IF;
        IF x_rxhl_rec.creation_date IS NULL THEN
          x_rxhl_rec.creation_date := l_rxhl_rec.creation_date;
        END IF;
        IF x_rxhl_rec.last_updated_by IS NULL THEN
          x_rxhl_rec.last_updated_by := l_rxhl_rec.last_updated_by;
        END IF;
        IF x_rxhl_rec.last_update_date IS NULL THEN
          x_rxhl_rec.last_update_date := l_rxhl_rec.last_update_date;
        END IF;
        IF x_rxhl_rec.last_update_login IS NULL THEN
          x_rxhl_rec.last_update_login := l_rxhl_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------------
    -- Set_Attributes for:OKL_EXT_AR_HEADER_SOURCES_TL --
    -----------------------------------------------------
    FUNCTION Set_Attributes (
      p_rxhl_rec IN rxhl_rec_type,
      x_rxhl_rec OUT NOCOPY rxhl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rxhl_rec := p_rxhl_rec;
      x_rxhl_rec.LANGUAGE := USERENV('LANG');
      x_rxhl_rec.LANGUAGE := USERENV('LANG');
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
      p_rxhl_rec,                        -- IN
      l_rxhl_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rxhl_rec, l_def_rxhl_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_EXT_AR_HEADER_SOURCES_TL
    SET CONTRACT_STATUS = l_def_rxhl_rec.contract_status,
        INV_AGRMNT_STATUS = l_def_rxhl_rec.inv_agrmnt_status,
        TRANSACTION_TYPE_NAME = l_def_rxhl_rec.transaction_type_name,
        CREATED_BY = l_def_rxhl_rec.created_by,
        CREATION_DATE = l_def_rxhl_rec.creation_date,
        LAST_UPDATED_BY = l_def_rxhl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rxhl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rxhl_rec.last_update_login
    WHERE HEADER_EXTENSION_ID = l_def_rxhl_rec.header_extension_id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKL_EXT_AR_HEADER_SOURCES_TL
    SET SFWT_FLAG = 'Y'
    WHERE HEADER_EXTENSION_ID = l_def_rxhl_rec.header_extension_id
      AND SOURCE_LANG <> USERENV('LANG');

    x_rxhl_rec := l_rxhl_rec;
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
  ------------------------------------------------
  -- update_row for:OKL_EXT_AR_HEADER_SOURCES_V --
  ------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_rec                     IN rxhv_rec_type,
    x_rxhv_rec                     OUT NOCOPY rxhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxhv_rec                     rxhv_rec_type := p_rxhv_rec;
    l_def_rxhv_rec                 rxhv_rec_type;
    l_db_rxhv_rec                  rxhv_rec_type;
    l_rxh_rec                      rxh_rec_type;
    lx_rxh_rec                     rxh_rec_type;
    l_rxhl_rec                     rxhl_rec_type;
    lx_rxhl_rec                    rxhl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rxhv_rec IN rxhv_rec_type
    ) RETURN rxhv_rec_type IS
      l_rxhv_rec rxhv_rec_type := p_rxhv_rec;
    BEGIN
      l_rxhv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rxhv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rxhv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rxhv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rxhv_rec IN rxhv_rec_type,
      x_rxhv_rec OUT NOCOPY rxhv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rxhv_rec := p_rxhv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_rxhv_rec := get_rec(p_rxhv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_rxhv_rec.header_extension_id IS NULL THEN
          x_rxhv_rec.header_extension_id := l_db_rxhv_rec.header_extension_id;
        END IF;
        IF x_rxhv_rec.source_id IS NULL THEN
          x_rxhv_rec.source_id := l_db_rxhv_rec.source_id;
        END IF;
        IF x_rxhv_rec.source_table IS NULL THEN
          x_rxhv_rec.source_table := l_db_rxhv_rec.source_table;
        END IF;
        IF x_rxhv_rec.khr_id IS NULL THEN
          x_rxhv_rec.khr_id := l_db_rxhv_rec.khr_id;
        END IF;
        IF x_rxhv_rec.try_id IS NULL THEN
          x_rxhv_rec.try_id := l_db_rxhv_rec.try_id;
        END IF;
        IF x_rxhv_rec.trans_number IS NULL THEN
          x_rxhv_rec.trans_number := l_db_rxhv_rec.trans_number;
        END IF;
        IF x_rxhv_rec.contract_number IS NULL THEN
          x_rxhv_rec.contract_number := l_db_rxhv_rec.contract_number;
        END IF;
        IF x_rxhv_rec.product_name IS NULL THEN
          x_rxhv_rec.product_name := l_db_rxhv_rec.product_name;
        END IF;
        IF x_rxhv_rec.book_classification_code IS NULL THEN
          x_rxhv_rec.book_classification_code := l_db_rxhv_rec.book_classification_code;
        END IF;
        IF x_rxhv_rec.tax_owner_code IS NULL THEN
          x_rxhv_rec.tax_owner_code := l_db_rxhv_rec.tax_owner_code;
        END IF;
        IF x_rxhv_rec.int_calc_method_code IS NULL THEN
          x_rxhv_rec.int_calc_method_code := l_db_rxhv_rec.int_calc_method_code;
        END IF;
        IF x_rxhv_rec.rev_rec_method_code IS NULL THEN
          x_rxhv_rec.rev_rec_method_code := l_db_rxhv_rec.rev_rec_method_code;
        END IF;
        IF x_rxhv_rec.scs_code IS NULL THEN
          x_rxhv_rec.scs_code := l_db_rxhv_rec.scs_code;
        END IF;
        IF x_rxhv_rec.converted_number IS NULL THEN
          x_rxhv_rec.converted_number := l_db_rxhv_rec.converted_number;
        END IF;
        IF x_rxhv_rec.contract_effective_from IS NULL THEN
          x_rxhv_rec.contract_effective_from := l_db_rxhv_rec.contract_effective_from;
        END IF;
        IF x_rxhv_rec.contract_currency_code IS NULL THEN
          x_rxhv_rec.contract_currency_code := l_db_rxhv_rec.contract_currency_code;
        END IF;
        IF x_rxhv_rec.sales_rep_name IS NULL THEN
          x_rxhv_rec.sales_rep_name := l_db_rxhv_rec.sales_rep_name;
        END IF;
        IF x_rxhv_rec.po_order_number IS NULL THEN
          x_rxhv_rec.po_order_number := l_db_rxhv_rec.po_order_number;
        END IF;
        IF x_rxhv_rec.vendor_program_number IS NULL THEN
          x_rxhv_rec.vendor_program_number := l_db_rxhv_rec.vendor_program_number;
        END IF;
        IF x_rxhv_rec.assignable_flag IS NULL THEN
          x_rxhv_rec.assignable_flag := l_db_rxhv_rec.assignable_flag;
        END IF;
        IF x_rxhv_rec.converted_account_flag IS NULL THEN
          x_rxhv_rec.converted_account_flag := l_db_rxhv_rec.converted_account_flag;
        END IF;
        IF x_rxhv_rec.accrual_override_flag IS NULL THEN
          x_rxhv_rec.accrual_override_flag := l_db_rxhv_rec.accrual_override_flag;
        END IF;
        IF x_rxhv_rec.term_quote_accept_date IS NULL THEN
          x_rxhv_rec.term_quote_accept_date := l_db_rxhv_rec.term_quote_accept_date;
        END IF;
        IF x_rxhv_rec.term_quote_num IS NULL THEN
          x_rxhv_rec.term_quote_num := l_db_rxhv_rec.term_quote_num;
        END IF;
        IF x_rxhv_rec.term_quote_type_code IS NULL THEN
          x_rxhv_rec.term_quote_type_code := l_db_rxhv_rec.term_quote_type_code;
        END IF;
        IF x_rxhv_rec.khr_attribute_category IS NULL THEN
          x_rxhv_rec.khr_attribute_category := l_db_rxhv_rec.khr_attribute_category;
        END IF;
        IF x_rxhv_rec.khr_attribute1 IS NULL THEN
          x_rxhv_rec.khr_attribute1 := l_db_rxhv_rec.khr_attribute1;
        END IF;
        IF x_rxhv_rec.khr_attribute2 IS NULL THEN
          x_rxhv_rec.khr_attribute2 := l_db_rxhv_rec.khr_attribute2;
        END IF;
        IF x_rxhv_rec.khr_attribute3 IS NULL THEN
          x_rxhv_rec.khr_attribute3 := l_db_rxhv_rec.khr_attribute3;
        END IF;
        IF x_rxhv_rec.khr_attribute4 IS NULL THEN
          x_rxhv_rec.khr_attribute4 := l_db_rxhv_rec.khr_attribute4;
        END IF;
        IF x_rxhv_rec.khr_attribute5 IS NULL THEN
          x_rxhv_rec.khr_attribute5 := l_db_rxhv_rec.khr_attribute5;
        END IF;
        IF x_rxhv_rec.khr_attribute6 IS NULL THEN
          x_rxhv_rec.khr_attribute6 := l_db_rxhv_rec.khr_attribute6;
        END IF;
        IF x_rxhv_rec.khr_attribute7 IS NULL THEN
          x_rxhv_rec.khr_attribute7 := l_db_rxhv_rec.khr_attribute7;
        END IF;
        IF x_rxhv_rec.khr_attribute8 IS NULL THEN
          x_rxhv_rec.khr_attribute8 := l_db_rxhv_rec.khr_attribute8;
        END IF;
        IF x_rxhv_rec.khr_attribute9 IS NULL THEN
          x_rxhv_rec.khr_attribute9 := l_db_rxhv_rec.khr_attribute9;
        END IF;
        IF x_rxhv_rec.khr_attribute10 IS NULL THEN
          x_rxhv_rec.khr_attribute10 := l_db_rxhv_rec.khr_attribute10;
        END IF;
        IF x_rxhv_rec.khr_attribute11 IS NULL THEN
          x_rxhv_rec.khr_attribute11 := l_db_rxhv_rec.khr_attribute11;
        END IF;
        IF x_rxhv_rec.khr_attribute12 IS NULL THEN
          x_rxhv_rec.khr_attribute12 := l_db_rxhv_rec.khr_attribute12;
        END IF;
        IF x_rxhv_rec.khr_attribute13 IS NULL THEN
          x_rxhv_rec.khr_attribute13 := l_db_rxhv_rec.khr_attribute13;
        END IF;
        IF x_rxhv_rec.khr_attribute14 IS NULL THEN
          x_rxhv_rec.khr_attribute14 := l_db_rxhv_rec.khr_attribute14;
        END IF;
        IF x_rxhv_rec.khr_attribute15 IS NULL THEN
          x_rxhv_rec.khr_attribute15 := l_db_rxhv_rec.khr_attribute15;
        END IF;
        IF x_rxhv_rec.cust_attribute_category IS NULL THEN
          x_rxhv_rec.cust_attribute_category := l_db_rxhv_rec.cust_attribute_category;
        END IF;
        IF x_rxhv_rec.cust_attribute1 IS NULL THEN
          x_rxhv_rec.cust_attribute1 := l_db_rxhv_rec.cust_attribute1;
        END IF;
        IF x_rxhv_rec.cust_attribute2 IS NULL THEN
          x_rxhv_rec.cust_attribute2 := l_db_rxhv_rec.cust_attribute2;
        END IF;
        IF x_rxhv_rec.cust_attribute3 IS NULL THEN
          x_rxhv_rec.cust_attribute3 := l_db_rxhv_rec.cust_attribute3;
        END IF;
        IF x_rxhv_rec.cust_attribute4 IS NULL THEN
          x_rxhv_rec.cust_attribute4 := l_db_rxhv_rec.cust_attribute4;
        END IF;
        IF x_rxhv_rec.cust_attribute5 IS NULL THEN
          x_rxhv_rec.cust_attribute5 := l_db_rxhv_rec.cust_attribute5;
        END IF;
        IF x_rxhv_rec.cust_attribute6 IS NULL THEN
          x_rxhv_rec.cust_attribute6 := l_db_rxhv_rec.cust_attribute6;
        END IF;
        IF x_rxhv_rec.cust_attribute7 IS NULL THEN
          x_rxhv_rec.cust_attribute7 := l_db_rxhv_rec.cust_attribute7;
        END IF;
        IF x_rxhv_rec.cust_attribute8 IS NULL THEN
          x_rxhv_rec.cust_attribute8 := l_db_rxhv_rec.cust_attribute8;
        END IF;
        IF x_rxhv_rec.cust_attribute9 IS NULL THEN
          x_rxhv_rec.cust_attribute9 := l_db_rxhv_rec.cust_attribute9;
        END IF;
        IF x_rxhv_rec.cust_attribute10 IS NULL THEN
          x_rxhv_rec.cust_attribute10 := l_db_rxhv_rec.cust_attribute10;
        END IF;
        IF x_rxhv_rec.cust_attribute11 IS NULL THEN
          x_rxhv_rec.cust_attribute11 := l_db_rxhv_rec.cust_attribute11;
        END IF;
        IF x_rxhv_rec.cust_attribute12 IS NULL THEN
          x_rxhv_rec.cust_attribute12 := l_db_rxhv_rec.cust_attribute12;
        END IF;
        IF x_rxhv_rec.cust_attribute13 IS NULL THEN
          x_rxhv_rec.cust_attribute13 := l_db_rxhv_rec.cust_attribute13;
        END IF;
        IF x_rxhv_rec.cust_attribute14 IS NULL THEN
          x_rxhv_rec.cust_attribute14 := l_db_rxhv_rec.cust_attribute14;
        END IF;
        IF x_rxhv_rec.cust_attribute15 IS NULL THEN
          x_rxhv_rec.cust_attribute15 := l_db_rxhv_rec.cust_attribute15;
        END IF;
        IF x_rxhv_rec.rent_ia_contract_number IS NULL THEN
          x_rxhv_rec.rent_ia_contract_number := l_db_rxhv_rec.rent_ia_contract_number;
        END IF;
        IF x_rxhv_rec.rent_ia_product_name IS NULL THEN
          x_rxhv_rec.rent_ia_product_name := l_db_rxhv_rec.rent_ia_product_name;
        END IF;
        IF x_rxhv_rec.rent_ia_accounting_code IS NULL THEN
          x_rxhv_rec.rent_ia_accounting_code := l_db_rxhv_rec.rent_ia_accounting_code;
        END IF;
        IF x_rxhv_rec.res_ia_contract_number IS NULL THEN
          x_rxhv_rec.res_ia_contract_number := l_db_rxhv_rec.res_ia_contract_number;
        END IF;
        IF x_rxhv_rec.res_ia_product_name IS NULL THEN
          x_rxhv_rec.res_ia_product_name := l_db_rxhv_rec.res_ia_product_name;
        END IF;
        IF x_rxhv_rec.res_ia_accounting_code IS NULL THEN
          x_rxhv_rec.res_ia_accounting_code := l_db_rxhv_rec.res_ia_accounting_code;
        END IF;
        IF x_rxhv_rec.inv_agrmnt_number IS NULL THEN
          x_rxhv_rec.inv_agrmnt_number := l_db_rxhv_rec.inv_agrmnt_number;
        END IF;
        IF x_rxhv_rec.inv_agrmnt_effective_from IS NULL THEN
          x_rxhv_rec.inv_agrmnt_effective_from := l_db_rxhv_rec.inv_agrmnt_effective_from;
        END IF;
        IF x_rxhv_rec.inv_agrmnt_product_name IS NULL THEN
          x_rxhv_rec.inv_agrmnt_product_name := l_db_rxhv_rec.inv_agrmnt_product_name;
        END IF;
        IF x_rxhv_rec.inv_agrmnt_currency_code IS NULL THEN
          x_rxhv_rec.inv_agrmnt_currency_code := l_db_rxhv_rec.inv_agrmnt_currency_code;
        END IF;
        IF x_rxhv_rec.inv_agrmnt_synd_code IS NULL THEN
          x_rxhv_rec.inv_agrmnt_synd_code := l_db_rxhv_rec.inv_agrmnt_synd_code;
        END IF;
        IF x_rxhv_rec.inv_agrmnt_pool_number IS NULL THEN
          x_rxhv_rec.inv_agrmnt_pool_number := l_db_rxhv_rec.inv_agrmnt_pool_number;
        END IF;
        IF x_rxhv_rec.contract_status_code IS NULL THEN
          x_rxhv_rec.contract_status_code := l_db_rxhv_rec.contract_status_code;
        END IF;
        IF x_rxhv_rec.inv_agrmnt_status_code IS NULL THEN
          x_rxhv_rec.inv_agrmnt_status_code := l_db_rxhv_rec.inv_agrmnt_status_code;
        END IF;
        IF x_rxhv_rec.trx_type_class_code IS NULL THEN
          x_rxhv_rec.trx_type_class_code := l_db_rxhv_rec.trx_type_class_code;
        END IF;
        IF x_rxhv_rec.language IS NULL THEN
          x_rxhv_rec.language := l_db_rxhv_rec.language;
        END IF;
        IF x_rxhv_rec.contract_status IS NULL THEN
          x_rxhv_rec.contract_status := l_db_rxhv_rec.contract_status;
        END IF;
        IF x_rxhv_rec.inv_agrmnt_status IS NULL THEN
          x_rxhv_rec.inv_agrmnt_status := l_db_rxhv_rec.inv_agrmnt_status;
        END IF;
        IF x_rxhv_rec.transaction_type_name IS NULL THEN
          x_rxhv_rec.transaction_type_name := l_db_rxhv_rec.transaction_type_name;
        END IF;
        IF x_rxhv_rec.created_by IS NULL THEN
          x_rxhv_rec.created_by := l_db_rxhv_rec.created_by;
        END IF;
        IF x_rxhv_rec.creation_date IS NULL THEN
          x_rxhv_rec.creation_date := l_db_rxhv_rec.creation_date;
        END IF;
        IF x_rxhv_rec.last_updated_by IS NULL THEN
          x_rxhv_rec.last_updated_by := l_db_rxhv_rec.last_updated_by;
        END IF;
        IF x_rxhv_rec.last_update_date IS NULL THEN
          x_rxhv_rec.last_update_date := l_db_rxhv_rec.last_update_date;
        END IF;
        IF x_rxhv_rec.last_update_login IS NULL THEN
          x_rxhv_rec.last_update_login := l_db_rxhv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------------
    -- Set_Attributes for:OKL_EXT_AR_HEADER_SOURCES_V --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_rxhv_rec IN rxhv_rec_type,
      x_rxhv_rec OUT NOCOPY rxhv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rxhv_rec := p_rxhv_rec;
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
      p_rxhv_rec,                        -- IN
      x_rxhv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rxhv_rec, l_def_rxhv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rxhv_rec := null_out_defaults(l_def_rxhv_rec);
    l_def_rxhv_rec := fill_who_columns(l_def_rxhv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rxhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rxhv_rec, l_db_rxhv_rec);
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
      p_rxhv_rec                     => p_rxhv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_rxhv_rec, l_rxh_rec);
    migrate(l_def_rxhv_rec, l_rxhl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rxh_rec,
      lx_rxh_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rxh_rec, l_def_rxhv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rxhl_rec,
      lx_rxhl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rxhl_rec, l_def_rxhv_rec);
    x_rxhv_rec := l_def_rxhv_rec;
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
  -- PL/SQL TBL update_row for:rxhv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_tbl                     IN rxhv_tbl_type,
    x_rxhv_tbl                     OUT NOCOPY rxhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      i := p_rxhv_tbl.FIRST;
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
            p_rxhv_rec                     => p_rxhv_tbl(i),
            x_rxhv_rec                     => x_rxhv_tbl(i));
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
        EXIT WHEN (i = p_rxhv_tbl.LAST);
        i := p_rxhv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:RXHV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_tbl                     IN rxhv_tbl_type,
    x_rxhv_tbl                     OUT NOCOPY rxhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_rxhv_tbl                     => p_rxhv_tbl,
        x_rxhv_tbl                     => x_rxhv_tbl,
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
  ------------------------------------------------
  -- delete_row for:OKL_EXT_AR_HEADER_SOURCES_B --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxh_rec                      IN rxh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxh_rec                      rxh_rec_type := p_rxh_rec;
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

    DELETE FROM OKL_EXT_AR_HEADER_SOURCES_B
     WHERE HEADER_EXTENSION_ID = p_rxh_rec.header_extension_id;

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
  -- delete_row for:OKL_EXT_AR_HEADER_SOURCES_TL --
  -------------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhl_rec                     IN rxhl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxhl_rec                     rxhl_rec_type := p_rxhl_rec;
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

    DELETE FROM OKL_EXT_AR_HEADER_SOURCES_TL
     WHERE HEADER_EXTENSION_ID = p_rxhl_rec.header_extension_id;

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
  ------------------------------------------------
  -- delete_row for:OKL_EXT_AR_HEADER_SOURCES_V --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_rec                     IN rxhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rxhv_rec                     rxhv_rec_type := p_rxhv_rec;
    l_rxhl_rec                     rxhl_rec_type;
    l_rxh_rec                      rxh_rec_type;
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
    migrate(l_rxhv_rec, l_rxhl_rec);
    migrate(l_rxhv_rec, l_rxh_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rxhl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rxh_rec
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
  -----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_EXT_AR_HEADER_SOURCES_V --
  -----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_tbl                     IN rxhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      i := p_rxhv_tbl.FIRST;
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
            p_rxhv_rec                     => p_rxhv_tbl(i));
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
        EXIT WHEN (i = p_rxhv_tbl.LAST);
        i := p_rxhv_tbl.NEXT(i);
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

  -----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_EXT_AR_HEADER_SOURCES_V --
  -----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxhv_tbl                     IN rxhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_rxhv_tbl                     => p_rxhv_tbl,
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
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  -- Added for Bug# 6268782 : PRASJAIN
  -------------------------------------------------
  -- insert_row for:OKL_EXT_AR_HEADER_SOURCES_B  --
  -- insert_row for:OKL_EXT_AR_HEADER_SOURCES_TL --
  -------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxh_rec                      IN rxh_rec_type,
    p_rxhl_tbl                     IN rxhl_tbl_type,
    x_rxh_rec                      OUT NOCOPY rxh_rec_type,
    x_rxhl_tbl                     OUT NOCOPY rxhl_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_rxh_rec                      rxh_rec_type := p_rxh_rec;
    l_def_rxh_rec                  rxh_rec_type;
    lx_rxh_rec                     rxh_rec_type;

    l_rxhl_tbl                     rxhl_tbl_type := p_rxhl_tbl;
    lx_rxhl_tbl                    rxhl_tbl_type;

    idx                            NUMBER := 0;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rxh_rec IN rxh_rec_type
    ) RETURN rxh_rec_type IS
      l_rxh_rec rxh_rec_type := p_rxh_rec;
    BEGIN
      l_rxh_rec.CREATION_DATE := SYSDATE;
      l_rxh_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rxh_rec.LAST_UPDATE_DATE := l_rxh_rec.CREATION_DATE;
      l_rxh_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rxh_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rxh_rec);
    END fill_who_columns;
    ----------------------------------------------------
    -- Set_Attributes for:OKL_EXT_AR_HEADER_SOURCES_B --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_rxh_rec IN rxh_rec_type,
      x_rxh_rec OUT NOCOPY rxh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rxh_rec := p_rxh_rec;
      x_rxh_rec.OBJECT_VERSION_NUMBER := 1;
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
    -- Set primary key value
    l_rxh_rec.HEADER_EXTENSION_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_rxh_rec,                        -- IN
      l_def_rxh_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rxh_rec := fill_who_columns(l_def_rxh_rec);
    l_rxh_rec := l_def_rxh_rec;
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rxh_rec,
      lx_rxh_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Looping header translatable sources for insert
    FOR idx in p_rxhl_tbl.FIRST .. p_rxhl_tbl.LAST
    LOOP
      -- Set foreign key value
      l_rxhl_tbl(idx).header_extension_id := lx_rxh_rec.header_extension_id;
      -- Filling who columns
      l_rxhl_tbl(idx).CREATION_DATE := SYSDATE;
      l_rxhl_tbl(idx).CREATED_BY := FND_GLOBAL.USER_ID;
      l_rxhl_tbl(idx).LAST_UPDATE_DATE := l_rxhl_tbl(idx).CREATION_DATE;
      l_rxhl_tbl(idx).LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rxhl_tbl(idx).LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      insert_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_rxhl_tbl(idx),
        lx_rxhl_tbl(idx)
      );
    END LOOP;
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Set OUT values
    x_rxh_rec       := lx_rxh_rec;
    x_rxhl_tbl      := lx_rxhl_tbl;
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
END OKL_RXH_PVT;

/
