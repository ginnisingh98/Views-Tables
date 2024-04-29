--------------------------------------------------------
--  DDL for Package Body OKL_TEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TEL_PVT" AS
/* $Header: OKLSTELB.pls 120.6 2007/12/27 14:25:04 zrehman noship $ */
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
    CURSOR c_pk_csr IS SELECT okl_txl_extension_b_s.NEXTVAL FROM DUAL;
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
    DELETE FROM OKL_TXL_EXTENSION_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TXL_EXTENSION_B B
         WHERE B.LINE_EXTENSION_ID =T.LINE_EXTENSION_ID
        );

    UPDATE OKL_TXL_EXTENSION_TL T SET(
        INVENTORY_ITEM_NAME,
        INVENTORY_ORG_NAME) = (SELECT
                                  B.INVENTORY_ITEM_NAME,
                                  B.INVENTORY_ORG_NAME
                                FROM OKL_TXL_EXTENSION_TL B
                               WHERE B.LINE_EXTENSION_ID = T.LINE_EXTENSION_ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.LINE_EXTENSION_ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.LINE_EXTENSION_ID,
                  SUBT.LANGUAGE
                FROM OKL_TXL_EXTENSION_TL SUBB, OKL_TXL_EXTENSION_TL SUBT
               WHERE SUBB.LINE_EXTENSION_ID = SUBT.LINE_EXTENSION_ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.INVENTORY_ITEM_NAME <> SUBT.INVENTORY_ITEM_NAME
                      OR SUBB.INVENTORY_ORG_NAME <> SUBT.INVENTORY_ORG_NAME
                      OR (SUBB.INVENTORY_ITEM_NAME IS NULL AND SUBT.INVENTORY_ITEM_NAME IS NOT NULL)
                      OR (SUBB.INVENTORY_ORG_NAME IS NULL AND SUBT.INVENTORY_ORG_NAME IS NOT NULL)
              ));

    INSERT INTO OKL_TXL_EXTENSION_TL (
        LINE_EXTENSION_ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        INVENTORY_ITEM_NAME,
        INVENTORY_ORG_NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.LINE_EXTENSION_ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.INVENTORY_ITEM_NAME,
            B.INVENTORY_ORG_NAME,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_TXL_EXTENSION_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_TXL_EXTENSION_TL T
                     WHERE T.LINE_EXTENSION_ID = B.LINE_EXTENSION_ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_EXTENSION_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_telv_rec                     IN telv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN telv_rec_type IS
    CURSOR okl_txl_extension_pk_csr (p_line_extension_id IN NUMBER) IS
    SELECT
            LINE_EXTENSION_ID,
            TEH_ID,
            SOURCE_ID,
            SOURCE_TABLE,
            OBJECT_VERSION_NUMBER,
            LANGUAGE,
            CONTRACT_LINE_NUMBER,
            FEE_TYPE_CODE,
            ASSET_NUMBER,
            ASSET_CATEGORY_NAME,
            ASSET_VENDOR_NAME,
            ASSET_MANUFACTURER_NAME,
            ASSET_YEAR_MANUFACTURED,
            ASSET_MODEL_NUMBER,
            ASSET_DELIVERED_DATE,
            INSTALLED_SITE_ID,
            FIXED_ASSET_LOCATION_NAME,
            CONTINGENCY_CODE,
            SUBSIDY_NAME,
            SUBSIDY_PARTY_NAME,
            MEMO_FLAG,
            RECIEVABLES_TRX_TYPE_NAME,
            CONTRACT_LINE_TYPE,
            PAY_SUPPLIER_SITE_NAME,
            AGING_BUCKET_NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            INVENTORY_ITEM_NAME,
            INVENTORY_ORG_NAME,
            INVENTORY_ITEM_NAME_CODE,
            INVENTORY_ORG_CODE,
	    VENDOR_SITE_ID,
            SUBSIDY_VENDOR_ID,
            -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
	    ASSET_VENDOR_ID
            -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
      FROM Okl_Txl_Extension_V
     WHERE okl_txl_extension_v.line_extension_id = p_line_extension_id;
    l_okl_txl_extension_pk         okl_txl_extension_pk_csr%ROWTYPE;
    l_telv_rec                     telv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_extension_pk_csr (p_telv_rec.line_extension_id);
    FETCH okl_txl_extension_pk_csr INTO
              l_telv_rec.line_extension_id,
              l_telv_rec.teh_id,
              l_telv_rec.source_id,
              l_telv_rec.source_table,
              l_telv_rec.object_version_number,
              l_telv_rec.language,
              l_telv_rec.contract_line_number,
              l_telv_rec.fee_type_code,
              l_telv_rec.asset_number,
              l_telv_rec.asset_category_name,
              l_telv_rec.asset_vendor_name,
              l_telv_rec.asset_manufacturer_name,
              l_telv_rec.asset_year_manufactured,
              l_telv_rec.asset_model_number,
              l_telv_rec.asset_delivered_date,
              l_telv_rec.installed_site_id,
              l_telv_rec.fixed_asset_location_name,
              l_telv_rec.contingency_code,
              l_telv_rec.subsidy_name,
              l_telv_rec.subsidy_party_name,
              l_telv_rec.memo_flag,
              l_telv_rec.recievables_trx_type_name,
              l_telv_rec.contract_line_type,
              l_telv_rec.pay_supplier_site_name,
              l_telv_rec.aging_bucket_name,
              l_telv_rec.created_by,
              l_telv_rec.creation_date,
              l_telv_rec.last_updated_by,
              l_telv_rec.last_update_date,
              l_telv_rec.last_update_login,
              l_telv_rec.inventory_item_name,
              l_telv_rec.inventory_org_name,
              l_telv_rec.inventory_item_name_code,
              l_telv_rec.inventory_org_code,
	      l_telv_rec.vendor_site_id ,
	      l_telv_rec.subsidy_vendor_id,
	      -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
	      l_telv_rec.asset_vendor_id;
	      -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
    x_no_data_found := okl_txl_extension_pk_csr%NOTFOUND;
    CLOSE okl_txl_extension_pk_csr;
    RETURN(l_telv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_telv_rec                     IN telv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN telv_rec_type IS
    l_telv_rec                     telv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_telv_rec := get_rec(p_telv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LINE_EXTENSION_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_telv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_telv_rec                     IN telv_rec_type
  ) RETURN telv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_telv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_EXTENSION_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tell_rec                     IN tell_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tell_rec_type IS
    CURSOR okl_txl_extension_tl_pk_csr (p_line_extension_id IN NUMBER,
                                        p_language          IN VARCHAR2) IS
    SELECT
            LINE_EXTENSION_ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            INVENTORY_ITEM_NAME,
            INVENTORY_ORG_NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Txl_Extension_Tl
     WHERE okl_txl_extension_tl.line_extension_id = p_line_extension_id
       AND okl_txl_extension_tl.language = p_language;
    l_okl_txl_extension_tl_pk      okl_txl_extension_tl_pk_csr%ROWTYPE;
    l_tell_rec                     tell_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_extension_tl_pk_csr (p_tell_rec.line_extension_id,
                                      p_tell_rec.language);
    FETCH okl_txl_extension_tl_pk_csr INTO
              l_tell_rec.line_extension_id,
              l_tell_rec.language,
              l_tell_rec.source_lang,
              l_tell_rec.sfwt_flag,
              l_tell_rec.inventory_item_name,
              l_tell_rec.inventory_org_name,
              l_tell_rec.created_by,
              l_tell_rec.creation_date,
              l_tell_rec.last_updated_by,
              l_tell_rec.last_update_date,
              l_tell_rec.last_update_login;
    x_no_data_found := okl_txl_extension_tl_pk_csr%NOTFOUND;
    CLOSE okl_txl_extension_tl_pk_csr;
    RETURN(l_tell_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_tell_rec                     IN tell_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN tell_rec_type IS
    l_tell_rec                     tell_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_tell_rec := get_rec(p_tell_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LINE_EXTENSION_ID');
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_tell_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_tell_rec                     IN tell_rec_type
  ) RETURN tell_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tell_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_EXTENSION_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tel_rec                      IN tel_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tel_rec_type IS
    CURSOR okl_txl_extension_b_pk_csr (p_line_extension_id IN NUMBER) IS
    SELECT
            LINE_EXTENSION_ID,
            SOURCE_ID,
            SOURCE_TABLE,
            OBJECT_VERSION_NUMBER,
            CONTRACT_LINE_NUMBER,
            FEE_TYPE_CODE,
            ASSET_NUMBER,
            ASSET_CATEGORY_NAME,
            ASSET_VENDOR_NAME,
            ASSET_MANUFACTURER_NAME,
            ASSET_YEAR_MANUFACTURED,
            ASSET_MODEL_NUMBER,
            ASSET_DELIVERED_DATE,
            INSTALLED_SITE_ID,
            FIXED_ASSET_LOCATION_NAME,
            CONTINGENCY_CODE,
            SUBSIDY_NAME,
            SUBSIDY_PARTY_NAME,
            MEMO_FLAG,
            RECIEVABLES_TRX_TYPE_NAME,
            AGING_BUCKET_NAME,
            CONTRACT_LINE_TYPE,
            PAY_SUPPLIER_SITE_NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            TEH_ID,
            INVENTORY_ITEM_NAME_CODE,
            INVENTORY_ORG_CODE,
	    VENDOR_SITE_ID,
            SUBSIDY_VENDOR_ID,
	    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
	    ASSET_VENDOR_ID
            -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
      FROM Okl_Txl_Extension_B
     WHERE okl_txl_extension_b.line_extension_id = p_line_extension_id;
    l_okl_txl_extension_b_pk       okl_txl_extension_b_pk_csr%ROWTYPE;
    l_tel_rec                      tel_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_extension_b_pk_csr (p_tel_rec.line_extension_id);
    FETCH okl_txl_extension_b_pk_csr INTO
              l_tel_rec.line_extension_id,
              l_tel_rec.source_id,
              l_tel_rec.source_table,
              l_tel_rec.object_version_number,
              l_tel_rec.contract_line_number,
              l_tel_rec.fee_type_code,
              l_tel_rec.asset_number,
              l_tel_rec.asset_category_name,
              l_tel_rec.asset_vendor_name,
              l_tel_rec.asset_manufacturer_name,
              l_tel_rec.asset_year_manufactured,
              l_tel_rec.asset_model_number,
              l_tel_rec.asset_delivered_date,
              l_tel_rec.installed_site_id,
              l_tel_rec.fixed_asset_location_name,
              l_tel_rec.contingency_code,
              l_tel_rec.subsidy_name,
              l_tel_rec.subsidy_party_name,
              l_tel_rec.memo_flag,
              l_tel_rec.recievables_trx_type_name,
              l_tel_rec.aging_bucket_name,
              l_tel_rec.contract_line_type,
              l_tel_rec.pay_supplier_site_name,
              l_tel_rec.created_by,
              l_tel_rec.creation_date,
              l_tel_rec.last_updated_by,
              l_tel_rec.last_update_date,
              l_tel_rec.last_update_login,
              l_tel_rec.teh_id,
              l_tel_rec.inventory_item_name_code,
              l_tel_rec.inventory_org_code,
	      l_tel_rec.vendor_site_id ,
	      l_tel_rec.subsidy_vendor_id ,
	      -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
              l_tel_rec.asset_vendor_id;
              -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end;
    x_no_data_found := okl_txl_extension_b_pk_csr%NOTFOUND;
    CLOSE okl_txl_extension_b_pk_csr;
    RETURN(l_tel_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_tel_rec                      IN tel_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN tel_rec_type IS
    l_tel_rec                      tel_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_tel_rec := get_rec(p_tel_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LINE_EXTENSION_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_tel_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_tel_rec                      IN tel_rec_type
  ) RETURN tel_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tel_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXL_EXTENSION_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_telv_rec   IN telv_rec_type
  ) RETURN telv_rec_type IS
    l_telv_rec                     telv_rec_type := p_telv_rec;
  BEGIN
    IF (l_telv_rec.line_extension_id = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.line_extension_id := NULL;
    END IF;
    IF (l_telv_rec.teh_id = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.teh_id := NULL;
    END IF;
    IF (l_telv_rec.source_id = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.source_id := NULL;
    END IF;
    IF (l_telv_rec.source_table = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.source_table := NULL;
    END IF;
    IF (l_telv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.object_version_number := NULL;
    END IF;
    IF (l_telv_rec.language = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.language := NULL;
    END IF;
    IF (l_telv_rec.contract_line_number = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.contract_line_number := NULL;
    END IF;
    IF (l_telv_rec.fee_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.fee_type_code := NULL;
    END IF;
    IF (l_telv_rec.asset_number = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.asset_number := NULL;
    END IF;
    IF (l_telv_rec.asset_category_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.asset_category_name := NULL;
    END IF;
    IF (l_telv_rec.asset_vendor_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.asset_vendor_name := NULL;
    END IF;
    IF (l_telv_rec.asset_manufacturer_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.asset_manufacturer_name := NULL;
    END IF;
    IF (l_telv_rec.asset_year_manufactured = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.asset_year_manufactured := NULL;
    END IF;
    IF (l_telv_rec.asset_model_number = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.asset_model_number := NULL;
    END IF;
    IF (l_telv_rec.asset_delivered_date = OKL_API.G_MISS_DATE ) THEN
      l_telv_rec.asset_delivered_date := NULL;
    END IF;
    IF (l_telv_rec.installed_site_id = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.installed_site_id := NULL;
    END IF;
    IF (l_telv_rec.fixed_asset_location_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.fixed_asset_location_name := NULL;
    END IF;
    IF (l_telv_rec.contingency_code = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.contingency_code := NULL;
    END IF;
    IF (l_telv_rec.subsidy_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.subsidy_name := NULL;
    END IF;
    IF (l_telv_rec.subsidy_party_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.subsidy_party_name := NULL;
    END IF;
    IF (l_telv_rec.memo_flag = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.memo_flag := NULL;
    END IF;
    IF (l_telv_rec.recievables_trx_type_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.recievables_trx_type_name := NULL;
    END IF;
    IF (l_telv_rec.contract_line_type = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.contract_line_type := NULL;
    END IF;
    IF (l_telv_rec.pay_supplier_site_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.pay_supplier_site_name := NULL;
    END IF;
    IF (l_telv_rec.aging_bucket_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.aging_bucket_name := NULL;
    END IF;
    IF (l_telv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.created_by := NULL;
    END IF;
    IF (l_telv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_telv_rec.creation_date := NULL;
    END IF;
    IF (l_telv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.last_updated_by := NULL;
    END IF;
    IF (l_telv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_telv_rec.last_update_date := NULL;
    END IF;
    IF (l_telv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.last_update_login := NULL;
    END IF;
    IF (l_telv_rec.inventory_item_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.inventory_item_name := NULL;
    END IF;
    IF (l_telv_rec.inventory_org_name = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.inventory_org_name := NULL;
    END IF;
    IF (l_telv_rec.inventory_item_name_code = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.inventory_item_name_code := NULL;
    END IF;
    IF (l_telv_rec.inventory_org_code = OKL_API.G_MISS_CHAR ) THEN
      l_telv_rec.inventory_org_code := NULL;
    END IF;
    IF (l_telv_rec.vendor_site_id = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.vendor_site_id := NULL;
    END IF;
    IF (l_telv_rec.subsidy_vendor_id  = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.subsidy_vendor_id  := NULL;
    END IF;
    IF (l_telv_rec.asset_vendor_id  = OKL_API.G_MISS_NUM ) THEN
      l_telv_rec.asset_vendor_id := NULL;
    END IF;
    RETURN(l_telv_rec);
  END null_out_defaults;
  ------------------------------------------------
  -- Validate_Attributes for: LINE_EXTENSION_ID --
  ------------------------------------------------
  PROCEDURE validate_line_extension_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_line_extension_id            IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_line_extension_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'line_extension_id');
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
  END validate_line_extension_id;
  -------------------------------------
  -- Validate_Attributes for: TEH_ID --
  -------------------------------------
  PROCEDURE validate_teh_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_teh_id                       IN NUMBER) IS
    CURSOR teh_id_csr(p_t_id NUMBER) IS
    SELECT 1
    FROM okl_trx_extension_b
    WHERE header_extension_id = p_t_id;
    l_found   NUMBER :=0;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_teh_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'teh_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      OPEN teh_id_csr(p_teh_id);
      FETCH teh_id_csr into l_found;
      IF l_found IS NULL THEN
        OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'teh_id');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  END validate_teh_id;
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
  ----------------------------------------------------
  -- Validate_Attributes for: subsidy_vendor_id  and asset_vendor_id --
  ----------------------------------------------------
  PROCEDURE validate_supplier(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_subsidy_vendor_id       IN NUMBER,
    p_col_name VARCHAR2) IS
   l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_subsidy_vendor_id              VARCHAR2(1);
  l_row_not_found             BOOLEAN := FALSE;
  CURSOR c1(p_subsidy_vendor_id NUMBER) IS
  SELECT '1'
  FROM ap_suppliers
  WHERE  vendor_id =  p_subsidy_vendor_id   ;
  BEGIN
 IF ( p_subsidy_vendor_id IS NOT NULL) THEN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    OPEN c1(p_subsidy_vendor_id );
    FETCH c1 INTO l_subsidy_vendor_id;
    l_row_not_found := c1%NOTFOUND;
    CLOSE c1;
    IF l_row_not_found THEN
		OKC_API.set_message('OKL',G_INVALID_VALUE , G_COL_NAME_TOKEN, 'p_col_name');
		x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,

                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_supplier;
  ----------------------------------------------------
  -- Validate_Attributes for: vendor_site_id --
  ----------------------------------------------------
  PROCEDURE validate_vendor_site(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_vendor_site_id        IN NUMBER) IS
   l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_vendor_site_id              VARCHAR2(1);
  l_row_not_found             BOOLEAN := FALSE;
  CURSOR c1(p_vendor_site_id NUMBER) IS
  SELECT '1'
  FROM ap_supplier_sites
  WHERE  vendor_site_id =  p_vendor_site_id   ;
  BEGIN
 IF ( p_vendor_site_id IS NOT NULL) THEN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    OPEN c1(p_vendor_site_id );
    FETCH c1 INTO l_vendor_site_id;
    l_row_not_found := c1%NOTFOUND;
    CLOSE c1;
    IF l_row_not_found THEN
		OKC_API.set_message('OKL',G_INVALID_VALUE , G_COL_NAME_TOKEN, 'PARTY_ID');
		x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,

                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_vendor_site;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_TXL_EXTENSION_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_telv_rec                     IN telv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_col_name                     VARCHAR2(50) := 'SUBSIDY_VENDOR_ID';
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- line_extension_id
    -- ***
    validate_line_extension_id(x_return_status, p_telv_rec.line_extension_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- teh_id
    -- ***
    validate_teh_id(x_return_status, p_telv_rec.teh_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- source_id
    -- ***
    validate_source_id(x_return_status, p_telv_rec.source_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- source_table
    -- ***
    validate_source_table(x_return_status, p_telv_rec.source_table);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_telv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

   validate_supplier(x_return_status, p_telv_rec.subsidy_vendor_id ,l_col_name);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_col_name :='ASSET_VENDOR_ID';
     validate_supplier(x_return_status, p_telv_rec.asset_vendor_id ,l_col_name);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
   validate_vendor_site(x_return_status, p_telv_rec.vendor_site_id);
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
  ---------------------------------------------
  -- Validate Record for:OKL_TXL_EXTENSION_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_telv_rec IN telv_rec_type,
    p_db_telv_rec IN telv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_telv_rec IN telv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_telv_rec                  telv_rec_type := get_rec(p_telv_rec);
  BEGIN
    l_return_status := Validate_Record(p_telv_rec => p_telv_rec,
                                       p_db_telv_rec => l_db_telv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN telv_rec_type,
    p_to   IN OUT NOCOPY tell_rec_type
  ) IS
  BEGIN
    p_to.line_extension_id := p_from.line_extension_id;
    p_to.language := p_from.language;
    p_to.inventory_item_name := p_from.inventory_item_name;
    p_to.inventory_org_name := p_from.inventory_org_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN tell_rec_type,
    p_to   IN OUT NOCOPY telv_rec_type
  ) IS
  BEGIN
    p_to.line_extension_id := p_from.line_extension_id;
    p_to.language := p_from.language;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.inventory_item_name := p_from.inventory_item_name;
    p_to.inventory_org_name := p_from.inventory_org_name;
  END migrate;
  PROCEDURE migrate (
    p_from IN telv_rec_type,
    p_to   IN OUT NOCOPY tel_rec_type
  ) IS
  BEGIN
    p_to.line_extension_id := p_from.line_extension_id;
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    p_to.object_version_number := p_from.object_version_number;
    p_to.contract_line_number := p_from.contract_line_number;
    p_to.fee_type_code := p_from.fee_type_code;
    p_to.asset_number := p_from.asset_number;
    p_to.asset_category_name := p_from.asset_category_name;
    p_to.asset_vendor_name := p_from.asset_vendor_name;
    p_to.asset_manufacturer_name := p_from.asset_manufacturer_name;
    p_to.asset_year_manufactured := p_from.asset_year_manufactured;
    p_to.asset_model_number := p_from.asset_model_number;
    p_to.asset_delivered_date := p_from.asset_delivered_date;
    p_to.installed_site_id := p_from.installed_site_id;
    p_to.fixed_asset_location_name := p_from.fixed_asset_location_name;
    p_to.contingency_code := p_from.contingency_code;
    p_to.subsidy_name := p_from.subsidy_name;
    p_to.subsidy_party_name := p_from.subsidy_party_name;
    p_to.memo_flag := p_from.memo_flag;
    p_to.recievables_trx_type_name := p_from.recievables_trx_type_name;
    p_to.aging_bucket_name := p_from.aging_bucket_name;
    p_to.contract_line_type := p_from.contract_line_type;
    p_to.pay_supplier_site_name := p_from.pay_supplier_site_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.teh_id := p_from.teh_id;
    p_to.inventory_item_name_code := p_from.inventory_item_name_code;
    p_to.inventory_org_code := p_from.inventory_org_code;
    p_to.vendor_site_id  := p_from.vendor_site_id ;
    p_to.subsidy_vendor_id := p_from.subsidy_vendor_id;
    p_to.asset_vendor_id   := p_from.asset_vendor_id;
  END migrate;
  PROCEDURE migrate (
    p_from IN tel_rec_type,
    p_to   IN OUT NOCOPY telv_rec_type
  ) IS
  BEGIN
    p_to.line_extension_id := p_from.line_extension_id;
    p_to.teh_id := p_from.teh_id;
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    p_to.object_version_number := p_from.object_version_number;
    p_to.contract_line_number := p_from.contract_line_number;
    p_to.fee_type_code := p_from.fee_type_code;
    p_to.asset_number := p_from.asset_number;
    p_to.asset_category_name := p_from.asset_category_name;
    p_to.asset_vendor_name := p_from.asset_vendor_name;
    p_to.asset_manufacturer_name := p_from.asset_manufacturer_name;
    p_to.asset_year_manufactured := p_from.asset_year_manufactured;
    p_to.asset_model_number := p_from.asset_model_number;
    p_to.asset_delivered_date := p_from.asset_delivered_date;
    p_to.installed_site_id := p_from.installed_site_id;
    p_to.fixed_asset_location_name := p_from.fixed_asset_location_name;
    p_to.contingency_code := p_from.contingency_code;
    p_to.subsidy_name := p_from.subsidy_name;
    p_to.subsidy_party_name := p_from.subsidy_party_name;
    p_to.memo_flag := p_from.memo_flag;
    p_to.recievables_trx_type_name := p_from.recievables_trx_type_name;
    p_to.contract_line_type := p_from.contract_line_type;
    p_to.pay_supplier_site_name := p_from.pay_supplier_site_name;
    p_to.aging_bucket_name := p_from.aging_bucket_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.inventory_item_name_code := p_from.inventory_item_name_code;
    p_to.inventory_org_code := p_from.inventory_org_code;
    p_to.vendor_site_id := p_from.vendor_site_id;
    p_to.subsidy_vendor_id := p_from.subsidy_vendor_id;
    p_to.asset_vendor_id   := p_from.asset_vendor_id;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_TXL_EXTENSION_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_rec                     IN telv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_telv_rec                     telv_rec_type := p_telv_rec;
    l_tel_rec                      tel_rec_type;
    l_tell_rec                     tell_rec_type;
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
    l_return_status := Validate_Attributes(l_telv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_telv_rec);
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
  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TXL_EXTENSION_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      i := p_telv_tbl.FIRST;
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
            p_telv_rec                     => p_telv_tbl(i));
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
        EXIT WHEN (i = p_telv_tbl.LAST);
        i := p_telv_tbl.NEXT(i);
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

  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TXL_EXTENSION_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_telv_tbl                     => p_telv_tbl,
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
  -- insert_row for:OKL_TXL_EXTENSION_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tel_rec                      IN tel_rec_type,
    x_tel_rec                      OUT NOCOPY tel_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tel_rec                      tel_rec_type := p_tel_rec;
    l_def_tel_rec                  tel_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_TXL_EXTENSION_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_tel_rec IN tel_rec_type,
      x_tel_rec OUT NOCOPY tel_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tel_rec := p_tel_rec;
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
      l_tel_rec,                         -- IN
      l_def_tel_rec);                    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXL_EXTENSION_B(
      line_extension_id,
      source_id,
      source_table,
      object_version_number,
      contract_line_number,
      fee_type_code,
      asset_number,
      asset_category_name,
      asset_vendor_name,
      asset_manufacturer_name,
      asset_year_manufactured,
      asset_model_number,
      asset_delivered_date,
      installed_site_id,
      fixed_asset_location_name,
      contingency_code,
      subsidy_name,
      subsidy_party_name,
      memo_flag,
      recievables_trx_type_name,
      aging_bucket_name,
      contract_line_type,
      pay_supplier_site_name,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      teh_id,
      inventory_item_name_code,
      inventory_org_code,
      vendor_site_id ,
      subsidy_vendor_id ,
      asset_vendor_id)
    VALUES (
      l_def_tel_rec.line_extension_id,
      l_def_tel_rec.source_id,
      l_def_tel_rec.source_table,
      l_def_tel_rec.object_version_number,
      l_def_tel_rec.contract_line_number,
      l_def_tel_rec.fee_type_code,
      l_def_tel_rec.asset_number,
      l_def_tel_rec.asset_category_name,
      l_def_tel_rec.asset_vendor_name,
      l_def_tel_rec.asset_manufacturer_name,
      l_def_tel_rec.asset_year_manufactured,
      l_def_tel_rec.asset_model_number,
      l_def_tel_rec.asset_delivered_date,
      l_def_tel_rec.installed_site_id,
      l_def_tel_rec.fixed_asset_location_name,
      l_def_tel_rec.contingency_code,
      l_def_tel_rec.subsidy_name,
      l_def_tel_rec.subsidy_party_name,
      l_def_tel_rec.memo_flag,
      l_def_tel_rec.recievables_trx_type_name,
      l_def_tel_rec.aging_bucket_name,
      l_def_tel_rec.contract_line_type,
      l_def_tel_rec.pay_supplier_site_name,
      l_def_tel_rec.created_by,
      l_def_tel_rec.creation_date,
      l_def_tel_rec.last_updated_by,
      l_def_tel_rec.last_update_date,
      l_def_tel_rec.last_update_login,
      l_def_tel_rec.teh_id,
      l_def_tel_rec.inventory_item_name_code,
      l_def_tel_rec.inventory_org_code,
      l_def_tel_rec.vendor_site_id,
      l_def_tel_rec.subsidy_vendor_id,
      l_def_tel_rec.asset_vendor_id);
    -- Set OUT values
    x_tel_rec := l_def_tel_rec;
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
  -- insert_row for:OKL_TXL_EXTENSION_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tell_rec                     IN tell_rec_type,
    x_tell_rec                     OUT NOCOPY tell_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tell_rec                     tell_rec_type := p_tell_rec;
    l_def_tell_rec                 tell_rec_type;
    /*CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');*/
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_EXTENSION_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tell_rec IN tell_rec_type,
      x_tell_rec OUT NOCOPY tell_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tell_rec := p_tell_rec;
      --x_tell_rec.LANGUAGE := USERENV('LANG');
      x_tell_rec.SOURCE_LANG := USERENV('LANG');
      x_tell_rec.SFWT_FLAG := 'N';
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
      p_tell_rec,                        -- IN
      l_tell_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    /*FOR l_lang_rec IN get_languages LOOP
      l_tell_rec.language := l_lang_rec.language_code;*/
      INSERT INTO OKL_TXL_EXTENSION_TL(
        line_extension_id,
        language,
        source_lang,
        sfwt_flag,
        inventory_item_name,
        inventory_org_name,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_tell_rec.line_extension_id,
        l_tell_rec.language,
        l_tell_rec.source_lang,
        l_tell_rec.sfwt_flag,
        l_tell_rec.inventory_item_name,
        l_tell_rec.inventory_org_name,
        l_tell_rec.created_by,
        l_tell_rec.creation_date,
        l_tell_rec.last_updated_by,
        l_tell_rec.last_update_date,
        l_tell_rec.last_update_login);
    --END LOOP;
    -- Set OUT values
    x_tell_rec := l_tell_rec;
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
  -- insert_row for :OKL_TXL_EXTENSION_B --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_rec                     IN telv_rec_type,
    x_telv_rec                     OUT NOCOPY telv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_telv_rec                     telv_rec_type := p_telv_rec;
    l_def_telv_rec                 telv_rec_type;
    l_tel_rec                      tel_rec_type;
    lx_tel_rec                     tel_rec_type;
    l_tell_rec                     tell_rec_type;
    lx_tell_rec                    tell_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_telv_rec IN telv_rec_type
    ) RETURN telv_rec_type IS
      l_telv_rec telv_rec_type := p_telv_rec;
    BEGIN
      l_telv_rec.CREATION_DATE := SYSDATE;
      l_telv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_telv_rec.LAST_UPDATE_DATE := l_telv_rec.CREATION_DATE;
      l_telv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_telv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_telv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_TXL_EXTENSION_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_telv_rec IN telv_rec_type,
      x_telv_rec OUT NOCOPY telv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_telv_rec := p_telv_rec;
      x_telv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_telv_rec := null_out_defaults(p_telv_rec);
    -- Set primary key value
    l_telv_rec.LINE_EXTENSION_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_telv_rec,                        -- IN
      l_def_telv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_telv_rec := fill_who_columns(l_def_telv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_telv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_telv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_telv_rec, l_tel_rec);
    migrate(l_def_telv_rec, l_tell_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tel_rec,
      lx_tel_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tel_rec, l_def_telv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tell_rec,
      lx_tell_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tell_rec, l_def_telv_rec);
    -- Set OUT values
    x_telv_rec := l_def_telv_rec;
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
  -- PL/SQL TBL insert_row for:TELV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    x_telv_tbl                     OUT NOCOPY telv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      i := p_telv_tbl.FIRST;
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
            p_telv_rec                     => p_telv_tbl(i),
            x_telv_rec                     => x_telv_tbl(i));
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
        EXIT WHEN (i = p_telv_tbl.LAST);
        i := p_telv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:TELV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    x_telv_tbl                     OUT NOCOPY telv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    l_tabsize                      NUMBER;
    l_telv_tbl_in                  telv_tbl_type;
    --Declaring the local variables used
    l_created_by                    NUMBER;
    l_last_updated_by               NUMBER;
    l_creation_date                 DATE;
    l_last_update_date              DATE;
    l_last_update_login             NUMBER;
    j                               NUMBER;
    l_tel_tbl_in                    txl_tbl_type;
    l_tell_tbl_in                   txll_tbl_type;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Initialize the Local Variables
    l_telv_tbl_in       := p_telv_tbl;
    l_tabsize           := l_telv_tbl_in.COUNT;
    --Assigning the values for the who columns
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := SYSDATE;
    l_last_update_date  := SYSDATE;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    -- Make sure PL/SQL table has records in it before passing
    IF l_telv_tbl_in.COUNT > 0
    THEN
      j := 1;
      FOR i IN l_telv_tbl_in.FIRST .. l_telv_tbl_in.LAST
      LOOP
        l_telv_tbl_in(i).line_extension_id        := get_seq_id;
        l_telv_tbl_in(i).object_version_number    := 1;
        l_telv_tbl_in(i).created_by               := l_created_by;
        l_telv_tbl_in(i).creation_date            := l_creation_date;
        l_telv_tbl_in(i).last_updated_by          := l_last_updated_by;
        l_telv_tbl_in(i).last_update_date         := l_last_update_date;
        l_telv_tbl_in(i).last_update_login        := l_last_update_login;
        -- Populate the Table based on the Extension Line _B
        l_tel_tbl_in(j).line_extension_id         := l_telv_tbl_in(i).line_extension_id ;
        l_tel_tbl_in(j).source_id                 := l_telv_tbl_in(i).source_id ;
        l_tel_tbl_in(j).source_table              := l_telv_tbl_in(i).source_table ;
        l_tel_tbl_in(j).object_version_number     := 1 ;
        l_tel_tbl_in(j).contract_line_number      := l_telv_tbl_in(i).contract_line_number ;
        l_tel_tbl_in(j).fee_type_code             := l_telv_tbl_in(i).fee_type_code ;
        l_tel_tbl_in(j).asset_number              := l_telv_tbl_in(i).asset_number ;
        l_tel_tbl_in(j).asset_category_name       := l_telv_tbl_in(i).asset_category_name ;
        l_tel_tbl_in(j).asset_vendor_name         := l_telv_tbl_in(i).asset_vendor_name ;
        l_tel_tbl_in(j).asset_manufacturer_name   := l_telv_tbl_in(i).asset_manufacturer_name ;
        l_tel_tbl_in(j).asset_year_manufactured   := l_telv_tbl_in(i).asset_year_manufactured ;
        l_tel_tbl_in(j).asset_model_number        := l_telv_tbl_in(i).asset_model_number ;
        l_tel_tbl_in(j).asset_delivered_date      := l_telv_tbl_in(i).asset_delivered_date ;
        l_tel_tbl_in(j).installed_site_id         := l_telv_tbl_in(i).installed_site_id ;
        l_tel_tbl_in(j).fixed_asset_location_name := l_telv_tbl_in(i).fixed_asset_location_name ;
        l_tel_tbl_in(j).contingency_code          := l_telv_tbl_in(i).contingency_code ;
        l_tel_tbl_in(j).subsidy_name              := l_telv_tbl_in(i).subsidy_name ;
        l_tel_tbl_in(j).subsidy_party_name        := l_telv_tbl_in(i).subsidy_party_name;
        l_tel_tbl_in(j).memo_flag                 := l_telv_tbl_in(i).memo_flag ;
        l_tel_tbl_in(j).recievables_trx_type_name := l_telv_tbl_in(i).recievables_trx_type_name ;
        l_tel_tbl_in(j).aging_bucket_name         := l_telv_tbl_in(i).aging_bucket_name ;
        l_tel_tbl_in(j).contract_line_type        := l_telv_tbl_in(i).contract_line_type ;
        l_tel_tbl_in(j).pay_supplier_site_name    := l_telv_tbl_in(i).pay_supplier_site_name ;
        l_tel_tbl_in(j).created_by                := l_telv_tbl_in(i).created_by ;
        l_tel_tbl_in(j).creation_date             := l_telv_tbl_in(i).creation_date ;
        l_tel_tbl_in(j).last_updated_by           := l_telv_tbl_in(i).last_updated_by ;
        l_tel_tbl_in(j).last_update_date          := l_telv_tbl_in(i).last_update_date ;
        l_tel_tbl_in(j).last_update_login         := l_telv_tbl_in(i).last_update_login ;
        l_tel_tbl_in(j).teh_id                    := l_telv_tbl_in(i).teh_id ;
        l_tel_tbl_in(j).inventory_item_name_code  := l_telv_tbl_in(i).inventory_item_name_code ;
        l_tel_tbl_in(j).inventory_org_code        := l_telv_tbl_in(i).inventory_org_code ;
        l_tel_tbl_in(j).vendor_site_id            := l_telv_tbl_in(i).vendor_site_id ;
	l_tel_tbl_in(j).subsidy_vendor_id         := l_telv_tbl_in(i).subsidy_vendor_id ;
	l_tel_tbl_in(j).asset_vendor_id           := l_telv_tbl_in(i).asset_vendor_id;
        -- Populate the Table based on the Extension Line _TL
        l_tell_tbl_in(j).line_extension_id        := l_telv_tbl_in(i).line_extension_id;
        l_tell_tbl_in(j).LANGUAGE                 := l_telv_tbl_in(i).language;
        l_tell_tbl_in(j).source_lang              := 'US';
        l_tell_tbl_in(j).sfwt_flag                := 'N';
        l_tell_tbl_in(j).inventory_item_name      := l_telv_tbl_in(i).inventory_item_name;
        l_tell_tbl_in(j).inventory_org_name       := l_telv_tbl_in(i).inventory_org_name;
        l_tell_tbl_in(j).created_by               := l_telv_tbl_in(i).created_by;
        l_tell_tbl_in(j).creation_date            := l_telv_tbl_in(i).creation_date;
        l_tell_tbl_in(j).last_updated_by          := l_telv_tbl_in(i).last_updated_by;
        l_tell_tbl_in(j).last_update_date         := l_telv_tbl_in(i).last_update_date;
        l_tell_tbl_in(j).last_update_login        := l_telv_tbl_in(i).last_update_login;
        -- Increment j
        j := j + 1;
      END LOOP;
    END IF;

   -- Implementing the Bulk Insert Feature
    FORALL j in l_tel_tbl_in.FIRST .. l_tel_tbl_in.LAST
      INSERT INTO OKL_TXL_EXTENSION_B
        VALUES l_tel_tbl_in(j);

    FORALL j in l_tell_tbl_in.FIRST .. l_tell_tbl_in.LAST
      INSERT INTO OKL_TXL_EXTENSION_TL
        VALUES l_tell_tbl_in(j);

    -- Return the Inserted table of records
    x_telv_tbl := l_telv_tbl_in;
    -- Set the return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

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
  -- lock_row for:OKL_TXL_EXTENSION_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tel_rec                      IN tel_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tel_rec IN tel_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_EXTENSION_B
     WHERE LINE_EXTENSION_ID = p_tel_rec.line_extension_id
       AND OBJECT_VERSION_NUMBER = p_tel_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_tel_rec IN tel_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_EXTENSION_B
     WHERE LINE_EXTENSION_ID = p_tel_rec.line_extension_id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_TXL_EXTENSION_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_TXL_EXTENSION_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_tel_rec);
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
      OPEN lchk_csr(p_tel_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tel_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tel_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKL_TXL_EXTENSION_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tell_rec                     IN tell_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tell_rec IN tell_rec_type) IS
    SELECT *
      FROM OKL_TXL_EXTENSION_TL
     WHERE LINE_EXTENSION_ID = p_tell_rec.line_extension_id
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
      OPEN lock_csr(p_tell_rec);
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
  ---------------------------------------
  -- lock_row for: OKL_TXL_EXTENSION_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_rec                     IN telv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tell_rec                     tell_rec_type;
    l_tel_rec                      tel_rec_type;
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
    migrate(p_telv_rec, l_tell_rec);
    migrate(p_telv_rec, l_tel_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tell_rec
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
      l_tel_rec
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
  -- PL/SQL TBL lock_row for:TELV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      i := p_telv_tbl.FIRST;
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
            p_telv_rec                     => p_telv_tbl(i));
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
        EXIT WHEN (i = p_telv_tbl.LAST);
        i := p_telv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:TELV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_telv_tbl                     => p_telv_tbl,
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
  -- update_row for:OKL_TXL_EXTENSION_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tel_rec                      IN tel_rec_type,
    x_tel_rec                      OUT NOCOPY tel_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tel_rec                      tel_rec_type := p_tel_rec;
    l_def_tel_rec                  tel_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tel_rec IN tel_rec_type,
      x_tel_rec OUT NOCOPY tel_rec_type
    ) RETURN VARCHAR2 IS
      l_tel_rec                      tel_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tel_rec := p_tel_rec;
      -- Get current database values
      l_tel_rec := get_rec(p_tel_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_tel_rec.line_extension_id IS NULL THEN
          x_tel_rec.line_extension_id := l_tel_rec.line_extension_id;
        END IF;
        IF x_tel_rec.source_id IS NULL THEN
          x_tel_rec.source_id := l_tel_rec.source_id;
        END IF;
        IF x_tel_rec.source_table IS NULL THEN
          x_tel_rec.source_table := l_tel_rec.source_table;
        END IF;
        IF x_tel_rec.object_version_number IS NULL THEN
          x_tel_rec.object_version_number := l_tel_rec.object_version_number;
        END IF;
        IF x_tel_rec.contract_line_number IS NULL THEN
          x_tel_rec.contract_line_number := l_tel_rec.contract_line_number;
        END IF;
        IF x_tel_rec.fee_type_code IS NULL THEN
          x_tel_rec.fee_type_code := l_tel_rec.fee_type_code;
        END IF;
        IF x_tel_rec.asset_number IS NULL THEN
          x_tel_rec.asset_number := l_tel_rec.asset_number;
        END IF;
        IF x_tel_rec.asset_category_name IS NULL THEN
          x_tel_rec.asset_category_name := l_tel_rec.asset_category_name;
        END IF;
        IF x_tel_rec.asset_vendor_name IS NULL THEN
          x_tel_rec.asset_vendor_name := l_tel_rec.asset_vendor_name;
        END IF;
        IF x_tel_rec.asset_manufacturer_name IS NULL THEN
          x_tel_rec.asset_manufacturer_name := l_tel_rec.asset_manufacturer_name;
        END IF;
        IF x_tel_rec.asset_year_manufactured IS NULL THEN
          x_tel_rec.asset_year_manufactured := l_tel_rec.asset_year_manufactured;
        END IF;
        IF x_tel_rec.asset_model_number IS NULL THEN
          x_tel_rec.asset_model_number := l_tel_rec.asset_model_number;
        END IF;
        IF x_tel_rec.asset_delivered_date IS NULL THEN
          x_tel_rec.asset_delivered_date := l_tel_rec.asset_delivered_date;
        END IF;
        IF x_tel_rec.installed_site_id IS NULL THEN
          x_tel_rec.installed_site_id := l_tel_rec.installed_site_id;
        END IF;
        IF x_tel_rec.fixed_asset_location_name IS NULL THEN
          x_tel_rec.fixed_asset_location_name := l_tel_rec.fixed_asset_location_name;
        END IF;
        IF x_tel_rec.contingency_code IS NULL THEN
          x_tel_rec.contingency_code := l_tel_rec.contingency_code;
        END IF;
        IF x_tel_rec.subsidy_name IS NULL THEN
          x_tel_rec.subsidy_name := l_tel_rec.subsidy_name;
        END IF;
        IF x_tel_rec.subsidy_party_name IS NULL THEN
          x_tel_rec.subsidy_party_name := l_tel_rec.subsidy_party_name;
        END IF;
        IF x_tel_rec.memo_flag IS NULL THEN
          x_tel_rec.memo_flag := l_tel_rec.memo_flag;
        END IF;
        IF x_tel_rec.recievables_trx_type_name IS NULL THEN
          x_tel_rec.recievables_trx_type_name := l_tel_rec.recievables_trx_type_name;
        END IF;
        IF x_tel_rec.aging_bucket_name IS NULL THEN
          x_tel_rec.aging_bucket_name := l_tel_rec.aging_bucket_name;
        END IF;
        IF x_tel_rec.contract_line_type IS NULL THEN
          x_tel_rec.contract_line_type := l_tel_rec.contract_line_type;
        END IF;
        IF x_tel_rec.pay_supplier_site_name IS NULL THEN
          x_tel_rec.pay_supplier_site_name := l_tel_rec.pay_supplier_site_name;
        END IF;
        IF x_tel_rec.created_by IS NULL THEN
          x_tel_rec.created_by := l_tel_rec.created_by;
        END IF;
        IF x_tel_rec.creation_date IS NULL THEN
          x_tel_rec.creation_date := l_tel_rec.creation_date;
        END IF;
        IF x_tel_rec.last_updated_by IS NULL THEN
          x_tel_rec.last_updated_by := l_tel_rec.last_updated_by;
        END IF;
        IF x_tel_rec.last_update_date IS NULL THEN
          x_tel_rec.last_update_date := l_tel_rec.last_update_date;
        END IF;
        IF x_tel_rec.last_update_login IS NULL THEN
          x_tel_rec.last_update_login := l_tel_rec.last_update_login;
        END IF;
        IF x_tel_rec.teh_id IS NULL THEN
          x_tel_rec.teh_id := l_tel_rec.teh_id;
        END IF;
        IF x_tel_rec.inventory_item_name_code IS NULL THEN
          x_tel_rec.inventory_item_name_code := l_tel_rec.inventory_item_name_code;
        END IF;
        IF x_tel_rec.inventory_org_code IS NULL THEN
          x_tel_rec.inventory_org_code := l_tel_rec.inventory_org_code;
        END IF;
	  IF x_tel_rec.vendor_site_id  IS NULL THEN
          x_tel_rec.vendor_site_id  := l_tel_rec.vendor_site_id ;
        END IF;
	  IF x_tel_rec.subsidy_vendor_id  IS NULL THEN
          x_tel_rec.subsidy_vendor_id  := l_tel_rec.subsidy_vendor_id ;
        END IF;
	  IF x_tel_rec.asset_vendor_id  IS NULL THEN
          x_tel_rec.asset_vendor_id  := l_tel_rec.asset_vendor_id ;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TXL_EXTENSION_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_tel_rec IN tel_rec_type,
      x_tel_rec OUT NOCOPY tel_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tel_rec := p_tel_rec;
      x_tel_rec.OBJECT_VERSION_NUMBER := p_tel_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_tel_rec,                         -- IN
      l_tel_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tel_rec, l_def_tel_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_TXL_EXTENSION_B
    SET SOURCE_ID = l_def_tel_rec.source_id,
        SOURCE_TABLE = l_def_tel_rec.source_table,
        OBJECT_VERSION_NUMBER = l_def_tel_rec.object_version_number,
        CONTRACT_LINE_NUMBER = l_def_tel_rec.contract_line_number,
        FEE_TYPE_CODE = l_def_tel_rec.fee_type_code,
        ASSET_NUMBER = l_def_tel_rec.asset_number,
        ASSET_CATEGORY_NAME = l_def_tel_rec.asset_category_name,
        ASSET_VENDOR_NAME = l_def_tel_rec.asset_vendor_name,
        ASSET_MANUFACTURER_NAME = l_def_tel_rec.asset_manufacturer_name,
        ASSET_YEAR_MANUFACTURED = l_def_tel_rec.asset_year_manufactured,
        ASSET_MODEL_NUMBER = l_def_tel_rec.asset_model_number,
        ASSET_DELIVERED_DATE = l_def_tel_rec.asset_delivered_date,
        INSTALLED_SITE_ID = l_def_tel_rec.installed_site_id,
        FIXED_ASSET_LOCATION_NAME = l_def_tel_rec.fixed_asset_location_name,
        CONTINGENCY_CODE = l_def_tel_rec.contingency_code,
        SUBSIDY_NAME = l_def_tel_rec.subsidy_name,
        SUBSIDY_PARTY_NAME = l_def_tel_rec.subsidy_party_name,
        MEMO_FLAG = l_def_tel_rec.memo_flag,
        RECIEVABLES_TRX_TYPE_NAME = l_def_tel_rec.recievables_trx_type_name,
        AGING_BUCKET_NAME = l_def_tel_rec.aging_bucket_name,
        CONTRACT_LINE_TYPE = l_def_tel_rec.contract_line_type,
        PAY_SUPPLIER_SITE_NAME = l_def_tel_rec.pay_supplier_site_name,
        CREATED_BY = l_def_tel_rec.created_by,
        CREATION_DATE = l_def_tel_rec.creation_date,
        LAST_UPDATED_BY = l_def_tel_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tel_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tel_rec.last_update_login,
        TEH_ID = l_def_tel_rec.teh_id,
        INVENTORY_ITEM_NAME_CODE = l_def_tel_rec.inventory_item_name_code,
        INVENTORY_ORG_CODE = l_def_tel_rec.inventory_org_code,
	VENDOR_SITE_ID = l_def_tel_rec.vendor_site_id,
	SUBSIDY_VENDOR_ID = l_def_tel_rec.subsidy_vendor_id,
	ASSET_VENDOR_ID = l_def_tel_rec.asset_vendor_id
    WHERE LINE_EXTENSION_ID = l_def_tel_rec.line_extension_id;

    x_tel_rec := l_tel_rec;
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
  -- update_row for:OKL_TXL_EXTENSION_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tell_rec                     IN tell_rec_type,
    x_tell_rec                     OUT NOCOPY tell_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tell_rec                     tell_rec_type := p_tell_rec;
    l_def_tell_rec                 tell_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tell_rec IN tell_rec_type,
      x_tell_rec OUT NOCOPY tell_rec_type
    ) RETURN VARCHAR2 IS
      l_tell_rec                     tell_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tell_rec := p_tell_rec;
      -- Get current database values
      l_tell_rec := get_rec(p_tell_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_tell_rec.line_extension_id IS NULL THEN
          x_tell_rec.line_extension_id := l_tell_rec.line_extension_id;
        END IF;
        IF x_tell_rec.language IS NULL THEN
          x_tell_rec.language := l_tell_rec.language;
        END IF;
        IF x_tell_rec.source_lang IS NULL THEN
          x_tell_rec.source_lang := l_tell_rec.source_lang;
        END IF;
        IF x_tell_rec.sfwt_flag IS NULL THEN
          x_tell_rec.sfwt_flag := l_tell_rec.sfwt_flag;
        END IF;
        IF x_tell_rec.inventory_item_name IS NULL THEN
          x_tell_rec.inventory_item_name := l_tell_rec.inventory_item_name;
        END IF;
        IF x_tell_rec.inventory_org_name IS NULL THEN
          x_tell_rec.inventory_org_name := l_tell_rec.inventory_org_name;
        END IF;
        IF x_tell_rec.created_by IS NULL THEN
          x_tell_rec.created_by := l_tell_rec.created_by;
        END IF;
        IF x_tell_rec.creation_date IS NULL THEN
          x_tell_rec.creation_date := l_tell_rec.creation_date;
        END IF;
        IF x_tell_rec.last_updated_by IS NULL THEN
          x_tell_rec.last_updated_by := l_tell_rec.last_updated_by;
        END IF;
        IF x_tell_rec.last_update_date IS NULL THEN
          x_tell_rec.last_update_date := l_tell_rec.last_update_date;
        END IF;
        IF x_tell_rec.last_update_login IS NULL THEN
          x_tell_rec.last_update_login := l_tell_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_EXTENSION_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tell_rec IN tell_rec_type,
      x_tell_rec OUT NOCOPY tell_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tell_rec := p_tell_rec;
      --x_tell_rec.LANGUAGE := USERENV('LANG');
      --x_tell_rec.LANGUAGE := USERENV('LANG');
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
      p_tell_rec,                        -- IN
      l_tell_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tell_rec, l_def_tell_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_TXL_EXTENSION_TL
    SET INVENTORY_ITEM_NAME = l_def_tell_rec.inventory_item_name,
        INVENTORY_ORG_NAME = l_def_tell_rec.inventory_org_name,
        CREATED_BY = l_def_tell_rec.created_by,
        CREATION_DATE = l_def_tell_rec.creation_date,
        LAST_UPDATED_BY = l_def_tell_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tell_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tell_rec.last_update_login
    WHERE LINE_EXTENSION_ID = l_def_tell_rec.line_extension_id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKL_TXL_EXTENSION_TL
    SET SFWT_FLAG = 'Y'
    WHERE LINE_EXTENSION_ID = l_def_tell_rec.line_extension_id
      AND SOURCE_LANG <> USERENV('LANG');

    x_tell_rec := l_tell_rec;
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
  -- update_row for:OKL_TXL_EXTENSION_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_rec                     IN telv_rec_type,
    x_telv_rec                     OUT NOCOPY telv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_telv_rec                     telv_rec_type := p_telv_rec;
    l_def_telv_rec                 telv_rec_type;
    l_db_telv_rec                  telv_rec_type;
    l_tel_rec                      tel_rec_type;
    lx_tel_rec                     tel_rec_type;
    l_tell_rec                     tell_rec_type;
    lx_tell_rec                    tell_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_telv_rec IN telv_rec_type
    ) RETURN telv_rec_type IS
      l_telv_rec telv_rec_type := p_telv_rec;
    BEGIN
      l_telv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_telv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_telv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_telv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_telv_rec IN telv_rec_type,
      x_telv_rec OUT NOCOPY telv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_telv_rec := p_telv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_telv_rec := get_rec(p_telv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_telv_rec.line_extension_id IS NULL THEN
          x_telv_rec.line_extension_id := l_db_telv_rec.line_extension_id;
        END IF;
        IF x_telv_rec.teh_id IS NULL THEN
          x_telv_rec.teh_id := l_db_telv_rec.teh_id;
        END IF;
        IF x_telv_rec.source_id IS NULL THEN
          x_telv_rec.source_id := l_db_telv_rec.source_id;
        END IF;
        IF x_telv_rec.source_table IS NULL THEN
          x_telv_rec.source_table := l_db_telv_rec.source_table;
        END IF;
        IF x_telv_rec.language IS NULL THEN
          x_telv_rec.language := l_db_telv_rec.language;
        END IF;
        IF x_telv_rec.contract_line_number IS NULL THEN
          x_telv_rec.contract_line_number := l_db_telv_rec.contract_line_number;
        END IF;
        IF x_telv_rec.fee_type_code IS NULL THEN
          x_telv_rec.fee_type_code := l_db_telv_rec.fee_type_code;
        END IF;
        IF x_telv_rec.asset_number IS NULL THEN
          x_telv_rec.asset_number := l_db_telv_rec.asset_number;
        END IF;
        IF x_telv_rec.asset_category_name IS NULL THEN
          x_telv_rec.asset_category_name := l_db_telv_rec.asset_category_name;
        END IF;
        IF x_telv_rec.asset_vendor_name IS NULL THEN
          x_telv_rec.asset_vendor_name := l_db_telv_rec.asset_vendor_name;
        END IF;
        IF x_telv_rec.asset_manufacturer_name IS NULL THEN
          x_telv_rec.asset_manufacturer_name := l_db_telv_rec.asset_manufacturer_name;
        END IF;
        IF x_telv_rec.asset_year_manufactured IS NULL THEN
          x_telv_rec.asset_year_manufactured := l_db_telv_rec.asset_year_manufactured;
        END IF;
        IF x_telv_rec.asset_model_number IS NULL THEN
          x_telv_rec.asset_model_number := l_db_telv_rec.asset_model_number;
        END IF;
        IF x_telv_rec.asset_delivered_date IS NULL THEN
          x_telv_rec.asset_delivered_date := l_db_telv_rec.asset_delivered_date;
        END IF;
        IF x_telv_rec.installed_site_id IS NULL THEN
          x_telv_rec.installed_site_id := l_db_telv_rec.installed_site_id;
        END IF;
        IF x_telv_rec.fixed_asset_location_name IS NULL THEN
          x_telv_rec.fixed_asset_location_name := l_db_telv_rec.fixed_asset_location_name;
        END IF;
        IF x_telv_rec.contingency_code IS NULL THEN
          x_telv_rec.contingency_code := l_db_telv_rec.contingency_code;
        END IF;
        IF x_telv_rec.subsidy_name IS NULL THEN
          x_telv_rec.subsidy_name := l_db_telv_rec.subsidy_name;
        END IF;
        IF x_telv_rec.subsidy_party_name IS NULL THEN
          x_telv_rec.subsidy_party_name := l_db_telv_rec.subsidy_party_name;
        END IF;
        IF x_telv_rec.memo_flag IS NULL THEN
          x_telv_rec.memo_flag := l_db_telv_rec.memo_flag;
        END IF;
        IF x_telv_rec.recievables_trx_type_name IS NULL THEN
          x_telv_rec.recievables_trx_type_name := l_db_telv_rec.recievables_trx_type_name;
        END IF;
        IF x_telv_rec.contract_line_type IS NULL THEN
          x_telv_rec.contract_line_type := l_db_telv_rec.contract_line_type;
        END IF;
        IF x_telv_rec.pay_supplier_site_name IS NULL THEN
          x_telv_rec.pay_supplier_site_name := l_db_telv_rec.pay_supplier_site_name;
        END IF;
        IF x_telv_rec.aging_bucket_name IS NULL THEN
          x_telv_rec.aging_bucket_name := l_db_telv_rec.aging_bucket_name;
        END IF;
        IF x_telv_rec.created_by IS NULL THEN
          x_telv_rec.created_by := l_db_telv_rec.created_by;
        END IF;
        IF x_telv_rec.creation_date IS NULL THEN
          x_telv_rec.creation_date := l_db_telv_rec.creation_date;
        END IF;
        IF x_telv_rec.last_updated_by IS NULL THEN
          x_telv_rec.last_updated_by := l_db_telv_rec.last_updated_by;
        END IF;
        IF x_telv_rec.last_update_date IS NULL THEN
          x_telv_rec.last_update_date := l_db_telv_rec.last_update_date;
        END IF;
        IF x_telv_rec.last_update_login IS NULL THEN
          x_telv_rec.last_update_login := l_db_telv_rec.last_update_login;
        END IF;
        IF x_telv_rec.inventory_item_name IS NULL THEN
          x_telv_rec.inventory_item_name := l_db_telv_rec.inventory_item_name;
        END IF;
        IF x_telv_rec.inventory_org_name IS NULL THEN
          x_telv_rec.inventory_org_name := l_db_telv_rec.inventory_org_name;
        END IF;
        IF x_telv_rec.inventory_item_name_code IS NULL THEN
          x_telv_rec.inventory_item_name_code := l_db_telv_rec.inventory_item_name_code;
        END IF;
        IF x_telv_rec.inventory_org_code IS NULL THEN
          x_telv_rec.inventory_org_code := l_db_telv_rec.inventory_org_code;
        END IF;
	IF x_telv_rec.vendor_site_id  IS NULL THEN
          x_telv_rec.vendor_site_id  := l_db_telv_rec.vendor_site_id ;
        END IF;
	IF x_telv_rec.subsidy_vendor_id  IS NULL THEN
          x_telv_rec.subsidy_vendor_id  := l_db_telv_rec.subsidy_vendor_id ;
        END IF;
	 IF x_telv_rec.asset_vendor_id  IS NULL THEN
          x_telv_rec.asset_vendor_id := l_db_telv_rec.asset_vendor_id ;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TXL_EXTENSION_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_telv_rec IN telv_rec_type,
      x_telv_rec OUT NOCOPY telv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_telv_rec := p_telv_rec;
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
      p_telv_rec,                        -- IN
      x_telv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_telv_rec, l_def_telv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_telv_rec := null_out_defaults(l_def_telv_rec);
    l_def_telv_rec := fill_who_columns(l_def_telv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_telv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_telv_rec, l_db_telv_rec);
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
      p_telv_rec                     => p_telv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_telv_rec, l_tel_rec);
    migrate(l_def_telv_rec, l_tell_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tel_rec,
      lx_tel_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tel_rec, l_def_telv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tell_rec,
      lx_tell_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tell_rec, l_def_telv_rec);
    x_telv_rec := l_def_telv_rec;
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
  -- PL/SQL TBL update_row for:telv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    x_telv_tbl                     OUT NOCOPY telv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      i := p_telv_tbl.FIRST;
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
            p_telv_rec                     => p_telv_tbl(i),
            x_telv_rec                     => x_telv_tbl(i));
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
        EXIT WHEN (i = p_telv_tbl.LAST);
        i := p_telv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:TELV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    x_telv_tbl                     OUT NOCOPY telv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_telv_tbl                     => p_telv_tbl,
        x_telv_tbl                     => x_telv_tbl,
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
  -- delete_row for:OKL_TXL_EXTENSION_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tel_rec                      IN tel_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tel_rec                      tel_rec_type := p_tel_rec;
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

    DELETE FROM OKL_TXL_EXTENSION_B
     WHERE LINE_EXTENSION_ID = p_tel_rec.line_extension_id;

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
  -----------------------------------------
  -- delete_row for:OKL_TXL_EXTENSION_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tell_rec                     IN tell_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tell_rec                     tell_rec_type := p_tell_rec;
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

    DELETE FROM OKL_TXL_EXTENSION_TL
     WHERE LINE_EXTENSION_ID = p_tell_rec.line_extension_id;

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
  ----------------------------------------
  -- delete_row for:OKL_TXL_EXTENSION_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_rec                     IN telv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_telv_rec                     telv_rec_type := p_telv_rec;
    l_tell_rec                     tell_rec_type;
    l_tel_rec                      tel_rec_type;
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
    migrate(l_telv_rec, l_tell_rec);
    migrate(l_telv_rec, l_tel_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tell_rec
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
      l_tel_rec
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
  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TXL_EXTENSION_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      i := p_telv_tbl.FIRST;
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
            p_telv_rec                     => p_telv_tbl(i));
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
        EXIT WHEN (i = p_telv_tbl.LAST);
        i := p_telv_tbl.NEXT(i);
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

  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TXL_EXTENSION_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_telv_tbl                     => p_telv_tbl,
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
  -- Added : PRASJAIN : Bug# 6268782
  ---------------------------------------------------------------------------
  -- insert_row for:OKL_TXL_EXTENSION_B/OKL_TXL_EXTENSION_TL ----------------
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tel_rec                      IN tel_rec_type,
    p_tell_tbl                     IN tell_tbl_type,
    x_tel_rec                      OUT NOCOPY tel_rec_type,
    x_tell_tbl                     OUT NOCOPY tell_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_tel_rec                      tel_rec_type := p_tel_rec;
    lx_tel_rec                     tel_rec_type;

    l_tell_tbl                     tell_tbl_type := p_tell_tbl;
    lx_tell_tbl                    tell_tbl_type;

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
    l_tel_rec.LINE_EXTENSION_ID := get_seq_id;
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    l_tel_rec.teh_id := p_tel_rec.teh_id;
    l_tel_rec.CREATION_DATE := SYSDATE;
    l_tel_rec.CREATED_BY := FND_GLOBAL.USER_ID;
    l_tel_rec.LAST_UPDATE_DATE := l_tel_rec.CREATION_DATE;
    l_tel_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    l_tel_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
    l_tel_rec.OBJECT_VERSION_NUMBER := 1;
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tel_rec,
      lx_tel_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR idx IN p_tell_tbl.FIRST .. p_tell_tbl.LAST
    LOOP
     l_tell_tbl(idx).line_extension_id := lx_tel_rec.line_extension_id;
     l_tell_tbl(idx).CREATION_DATE := SYSDATE;
     l_tell_tbl(idx).CREATED_BY := FND_GLOBAL.USER_ID;
     l_tell_tbl(idx).LAST_UPDATE_DATE := l_tell_tbl(idx).CREATION_DATE;
     l_tell_tbl(idx).LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
     l_tell_tbl(idx).LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
     insert_row(
       p_init_msg_list,
       l_return_status,
       x_msg_count,
       x_msg_data,
       l_tell_tbl(idx),
       lx_tell_tbl(idx)
     );
    END LOOP;
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Set OUT values
    x_tel_rec       := lx_tel_rec;
    x_tell_tbl      := lx_tell_tbl;
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
END OKL_TEL_PVT;

/
