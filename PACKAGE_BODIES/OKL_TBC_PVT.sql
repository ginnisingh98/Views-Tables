--------------------------------------------------------
--  DDL for Package Body OKL_TBC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TBC_PVT" AS
/* $Header: OKLSTBCB.pls 120.14 2007/04/02 14:45:03 asawanka noship $ */
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
  l_id NUMBER;
  BEGIN
    select okl_tax_attr_definitions_s.NEXTVAL into l_id from dual;
    RETURN l_id;
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
  -- FUNCTION get_rec for: OKL_TAX_ATTR_DEFINITIONS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tbcv_rec                     IN tbcv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tbcv_rec_type IS
    CURSOR okl_tbcv_pk_csr (p_TAX_ATTRIBUTE_DEF_ID IN NUMBER) IS
    SELECT
            --ID,
            --ORG_ID,
            RESULT_CODE,
            PURCHASE_OPTION_CODE,
            PDT_ID,
            TRY_ID,
            STY_ID,
            INT_DISCLOSED_CODE,
            TITLE_TRNSFR_CODE,
            SALE_LEASE_BACK_CODE,
            LEASE_PURCHASED_CODE,
            EQUIP_USAGE_CODE,
            VENDOR_SITE_ID,
            AGE_OF_EQUIP_FROM,
            AGE_OF_EQUIP_TO,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
         -- modified by dcshanmu for eBTax project - modification start
            TAX_ATTRIBUTE_DEF_ID,
            RESULT_TYPE_CODE,
            BOOK_CLASS_CODE,
            DATE_EFFECTIVE_FROM,
            DATE_EFFECTIVE_TO,
            TAX_COUNTRY_CODE,
            TERM_QUOTE_TYPE_CODE,
            TERM_QUOTE_REASON_CODE,
            EXPIRE_FLAG
            -- modified by dcshanmu for eBTax project - modification end
      FROM OKL_TAX_ATTR_DEFINITIONS
--     WHERE OKL_TAX_ATTR_DEFINITIONS.id = p_id;
      WHERE OKL_TAX_ATTR_DEFINITIONS.TAX_ATTRIBUTE_DEF_ID = p_TAX_ATTRIBUTE_DEF_ID;
    l_okl_tbcv_pk                  okl_tbcv_pk_csr%ROWTYPE;
    l_tbcv_rec                     tbcv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tbcv_pk_csr (p_tbcv_rec.TAX_ATTRIBUTE_DEF_ID);
    FETCH okl_tbcv_pk_csr INTO
              --l_tbcv_rec.id,
              --l_tbcv_rec.org_id,
              l_tbcv_rec.result_code,
              l_tbcv_rec.purchase_option_code,
              l_tbcv_rec.pdt_id,
              l_tbcv_rec.try_id,
              l_tbcv_rec.sty_id,
              l_tbcv_rec.int_disclosed_code,
              l_tbcv_rec.title_trnsfr_code,
              l_tbcv_rec.sale_lease_back_code,
              l_tbcv_rec.lease_purchased_code,
              l_tbcv_rec.equip_usage_code,
              l_tbcv_rec.vendor_site_id,
              l_tbcv_rec.age_of_equip_from,
              l_tbcv_rec.age_of_equip_to,
              l_tbcv_rec.object_version_number,
              l_tbcv_rec.attribute_category,
              l_tbcv_rec.attribute1,
              l_tbcv_rec.attribute2,
              l_tbcv_rec.attribute3,
              l_tbcv_rec.attribute4,
              l_tbcv_rec.attribute5,
              l_tbcv_rec.attribute6,
              l_tbcv_rec.attribute7,
              l_tbcv_rec.attribute8,
              l_tbcv_rec.attribute9,
              l_tbcv_rec.attribute10,
              l_tbcv_rec.attribute11,
              l_tbcv_rec.attribute12,
              l_tbcv_rec.attribute13,
              l_tbcv_rec.attribute14,
              l_tbcv_rec.attribute15,
              l_tbcv_rec.created_by,
              l_tbcv_rec.creation_date,
              l_tbcv_rec.last_updated_by,
              l_tbcv_rec.last_update_date,
              l_tbcv_rec.last_update_login,
            -- modified by dcshanmu for eBTax project - modification start
              l_tbcv_rec.tax_attribute_def_id,
              l_tbcv_rec.result_type_code,
              l_tbcv_rec.book_class_code,
              l_tbcv_rec.date_effective_from,
              l_tbcv_rec.date_effective_to,
              l_tbcv_rec.tax_country_code,
              l_tbcv_rec.term_quote_type_code,
              l_tbcv_rec.term_quote_reason_code,
              l_tbcv_rec.expire_flag;
              -- modified by dcshanmu for eBTax project - modification end
    x_no_data_found := okl_tbcv_pk_csr%NOTFOUND;
    CLOSE okl_tbcv_pk_csr;

    RETURN(l_tbcv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_tbcv_rec                     IN tbcv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN tbcv_rec_type IS
    l_tbcv_rec                     tbcv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_tbcv_rec := get_rec(p_tbcv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_ATTRIBUTE_DEF_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_tbcv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_tbcv_rec                     IN tbcv_rec_type
  ) RETURN tbcv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tbcv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TAX_ATTR_DEFINITIONS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tbc_rec                      IN tbc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tbc_rec_type IS
    CURSOR okl_tbc_defs_pk_csr (p_TAX_ATTRIBUTE_DEF_ID IN NUMBER) IS
    SELECT
            --ID,
            --ORG_ID,
            RESULT_CODE,
            PURCHASE_OPTION_CODE,
            PDT_ID,
            TRY_ID,
            STY_ID,
            INT_DISCLOSED_CODE,
            TITLE_TRNSFR_CODE,
            SALE_LEASE_BACK_CODE,
            LEASE_PURCHASED_CODE,
            EQUIP_USAGE_CODE,
            VENDOR_SITE_ID,
            AGE_OF_EQUIP_FROM,
            AGE_OF_EQUIP_TO,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
           -- modified by dcshanmu for eBTax project - modification start
            TAX_ATTRIBUTE_DEF_ID,
            RESULT_TYPE_CODE,
            BOOK_CLASS_CODE,
            DATE_EFFECTIVE_FROM,
            DATE_EFFECTIVE_TO,
            TAX_COUNTRY_CODE,
            TERM_QUOTE_TYPE_CODE,
            TERM_QUOTE_REASON_CODE,
            EXPIRE_FLAG
            -- modified by dcshanmu for eBTax project - modification end
      FROM OKL_TAX_ATTR_DEFINITIONS
--     WHERE OKL_TAX_ATTR_DEFINITIONS.id = p_id;
      WHERE OKL_TAX_ATTR_DEFINITIONS.TAX_ATTRIBUTE_DEF_ID = p_TAX_ATTRIBUTE_DEF_ID;
    l_okl_tbc_defs_pk              okl_tbc_defs_pk_csr%ROWTYPE;
    l_tbc_rec                      tbc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tbc_defs_pk_csr (p_tbc_rec.TAX_ATTRIBUTE_DEF_ID);
    FETCH okl_tbc_defs_pk_csr INTO
             -- l_tbc_rec.id,
             -- l_tbc_rec.org_id,
              l_tbc_rec.result_code,
              l_tbc_rec.purchase_option_code,
              l_tbc_rec.pdt_id,
              l_tbc_rec.try_id,
              l_tbc_rec.sty_id,
              l_tbc_rec.int_disclosed_code,
              l_tbc_rec.title_trnsfr_code,
              l_tbc_rec.sale_lease_back_code,
              l_tbc_rec.lease_purchased_code,
              l_tbc_rec.equip_usage_code,
              l_tbc_rec.vendor_site_id,
              l_tbc_rec.age_of_equip_from,
              l_tbc_rec.age_of_equip_to,
              l_tbc_rec.object_version_number,
              l_tbc_rec.attribute_category,
              l_tbc_rec.attribute1,
              l_tbc_rec.attribute2,
              l_tbc_rec.attribute3,
              l_tbc_rec.attribute4,
              l_tbc_rec.attribute5,
              l_tbc_rec.attribute6,
              l_tbc_rec.attribute7,
              l_tbc_rec.attribute8,
              l_tbc_rec.attribute9,
              l_tbc_rec.attribute10,
              l_tbc_rec.attribute11,
              l_tbc_rec.attribute12,
              l_tbc_rec.attribute13,
              l_tbc_rec.attribute14,
              l_tbc_rec.attribute15,
              l_tbc_rec.created_by,
              l_tbc_rec.creation_date,
              l_tbc_rec.last_updated_by,
              l_tbc_rec.last_update_date,
              l_tbc_rec.last_update_login,
              -- modified by dcshanmu for eBTax project - modification start
              l_tbc_rec.tax_attribute_def_id,
              l_tbc_rec.result_type_code,
              l_tbc_rec.book_class_code,
              l_tbc_rec.date_effective_from,
              l_tbc_rec.date_effective_to,
              l_tbc_rec.tax_country_code,
              l_tbc_rec.term_quote_type_code,
              l_tbc_rec.term_quote_reason_code,
              l_tbc_rec.expire_flag;
              -- modified by dcshanmu for eBTax project - modification end
    x_no_data_found := okl_tbc_defs_pk_csr%NOTFOUND;
    CLOSE okl_tbc_defs_pk_csr;
    RETURN(l_tbc_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_tbc_rec                      IN tbc_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN tbc_rec_type IS
    l_tbc_rec                      tbc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_tbc_rec := get_rec(p_tbc_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKc_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_ATTRIBUTE_DEF_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_tbc_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_tbc_rec                      IN tbc_rec_type
  ) RETURN tbc_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tbc_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TAX_ATTR_DEFINITIONS
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_tbcv_rec   IN tbcv_rec_type
  ) RETURN tbcv_rec_type IS
    l_tbcv_rec                     tbcv_rec_type := p_tbcv_rec;
  BEGIN
    /*IF (l_tbcv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.id := NULL;
    END IF;
    IF (l_tbcv_rec.org_id = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.org_id := NULL;
    END IF; */

    -- modified by dcshanmu for eBTax project - modification start
    -- changed tbc_code to result_code, because of data model change
    IF (l_tbcv_rec.result_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.result_code := NULL;
    END IF;
    -- modified by dcshanmu for eBTax project - modification end

    IF (l_tbcv_rec.purchase_option_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.purchase_option_code := NULL;
    END IF;
    IF (l_tbcv_rec.pdt_id = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.pdt_id := NULL;
    END IF;
    IF (l_tbcv_rec.try_id = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.try_id := NULL;
    END IF;
    IF (l_tbcv_rec.sty_id = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.sty_id := NULL;
    END IF;
    IF (l_tbcv_rec.int_disclosed_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.int_disclosed_code := NULL;
    END IF;
    IF (l_tbcv_rec.title_trnsfr_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.title_trnsfr_code := NULL;
    END IF;
    IF (l_tbcv_rec.sale_lease_back_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.sale_lease_back_code := NULL;
    END IF;
    IF (l_tbcv_rec.lease_purchased_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.lease_purchased_code := NULL;
    END IF;
    IF (l_tbcv_rec.equip_usage_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.equip_usage_code := NULL;
    END IF;
    IF (l_tbcv_rec.vendor_site_id = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.vendor_site_id := NULL;
    END IF;
    IF (l_tbcv_rec.age_of_equip_from = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.age_of_equip_from := NULL;
    END IF;
    IF (l_tbcv_rec.age_of_equip_to = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.age_of_equip_to := NULL;
    END IF;
    IF (l_tbcv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.object_version_number := NULL;
    END IF;
    IF (l_tbcv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute_category := NULL;
    END IF;
    IF (l_tbcv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute1 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute2 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute3 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute4 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute5 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute6 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute7 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute8 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute9 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute10 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute11 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute12 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute13 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute14 := NULL;
    END IF;
    IF (l_tbcv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.attribute15 := NULL;
    END IF;
    IF (l_tbcv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.created_by := NULL;
    END IF;
    IF (l_tbcv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_tbcv_rec.creation_date := NULL;
    END IF;
    IF (l_tbcv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tbcv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_tbcv_rec.last_update_date := NULL;
    END IF;
    IF (l_tbcv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.last_update_login := NULL;
    END IF;

    -- modified by dcshanmu for eBTax project - modification start
    -- added null default implementation to new columns added in the table
    IF (l_tbcv_rec.tax_attribute_def_id = OKL_API.G_MISS_NUM ) THEN
      l_tbcv_rec.tax_attribute_def_id := NULL;
    END IF;
    IF (l_tbcv_rec.result_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.result_type_code := NULL;
    END IF;
    IF (l_tbcv_rec.book_class_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.book_class_code := NULL;
    END IF;
    IF (l_tbcv_rec.date_effective_from = OKL_API.G_MISS_DATE ) THEN
      l_tbcv_rec.date_effective_from := NULL;
    END IF;
    IF (l_tbcv_rec.date_effective_to = OKL_API.G_MISS_DATE ) THEN
      l_tbcv_rec.date_effective_to := NULL;
    END IF;
    IF (l_tbcv_rec.tax_country_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.tax_country_code := NULL;
    END IF;
    IF (l_tbcv_rec.term_quote_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.term_quote_type_code := NULL;
    END IF;
    IF (l_tbcv_rec.term_quote_reason_code = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.term_quote_reason_code := NULL;
    END IF;
    IF (l_tbcv_rec.expire_flag = OKL_API.G_MISS_CHAR ) THEN
      l_tbcv_rec.expire_flag := NULL;
    END IF;
    -- modified by dcshanmu for eBTax project - modification end

    RETURN(l_tbcv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
 /* PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_tbcv_rec.id = OKL_API.G_MISS_NUM OR p_tbcv_rec.id IS NULL)
    THEN
      OKl_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'TAX_ATTRIBUTE_DEF_ID');
      l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKl_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;*/

  -- modified by dcshanmu for eBTax project - modification start
  -- modified tbc_code to result_code due to datamodel change
  ---------------------------------------
  -- Validate_Attributes for: RESULT_CODE --
  ---------------------------------------
  PROCEDURE validate_result_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbc_res_code_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT 'x'
      FROM zx_fc_business_categories_v
      WHERE classification_code = p_lookup_code;

    CURSOR okl_pc_res_code_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT 'x'
      FROM zx_fc_product_categories_v
      WHERE classification_code = p_lookup_code;

    CURSOR okl_ufc_res_code_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT 'x'
      FROM zx_fc_user_defined_v
      WHERE classification_code = p_lookup_code;

  BEGIN

    IF (p_tbcv_rec.result_code = OKL_API.G_MISS_CHAR OR p_tbcv_rec.result_code IS NULL)
    THEN
      Okl_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'result_code');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSE
        -- enforce foreign key

        IF (p_tbcv_rec.result_type_code = 'TBC_CODE')
        THEN
                OPEN   okl_tbc_res_code_fk_csr(p_tbcv_rec.result_code)  ;
                FETCH  okl_tbc_res_code_fk_csr into l_dummy_var ;
                CLOSE  okl_tbc_res_code_fk_csr ;

                -- still set to default means data was not found
                IF ( l_dummy_var = '?' ) THEN

                   OKC_API.set_message(g_app_name,
                                g_no_parent_record,
                                g_col_name_token,
                                'result_code',
                                g_child_table_token ,
                                'OKL_TAX_ATTR_DEFINITIONS',
                                g_parent_table_token ,
                                'ZX_FC_BUSINESS_CATEGORIES_V');
                    l_return_status := OKC_API.G_RET_STS_ERROR;

                END IF;
        ELSIF (p_tbcv_rec.result_type_code = 'PC_CODE')
        THEN
                OPEN   okl_pc_res_code_fk_csr(p_tbcv_rec.result_code)  ;
                FETCH  okl_pc_res_code_fk_csr into l_dummy_var ;
                CLOSE  okl_pc_res_code_fk_csr ;

                -- still set to default means data was not found
                IF ( l_dummy_var = '?' ) THEN

                   OKC_API.set_message(g_app_name,
                                g_no_parent_record,
                                g_col_name_token,
                                'result_code',
                                g_child_table_token ,
                                'OKL_TAX_ATTR_DEFINITIONS',
                                g_parent_table_token ,
                                'ZX_FC_PRODUCT_CATEGORIES_V');
                    l_return_status := OKC_API.G_RET_STS_ERROR;

                END IF;
        ELSIF (p_tbcv_rec.result_type_code = 'UFC_CODE')
        THEN
                OPEN   okl_ufc_res_code_fk_csr(p_tbcv_rec.result_code)  ;
                FETCH  okl_ufc_res_code_fk_csr into l_dummy_var ;
                CLOSE  okl_ufc_res_code_fk_csr ;

                -- still set to default means data was not found
                IF ( l_dummy_var = '?' ) THEN

                   OKC_API.set_message(g_app_name,
                                g_no_parent_record,
                                g_col_name_token,
                                'result_code',
                                g_child_table_token ,
                                'OKL_TAX_ATTR_DEFINITIONS',
                                g_parent_table_token ,
                                'ZX_FC_USER_DEFINED_V');
                    l_return_status := OKC_API.G_RET_STS_ERROR;

                END IF;
        END IF;


    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKl_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_result_code;
-- modified by dcshanmu for eBTax project - modification end

  ---------------------------------------------------
  -- Validate_Attributes for: PURCHASE_OPTION_CODE --
  ---------------------------------------------------
  PROCEDURE validate_purchase_option_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_prch_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
      FROM Fnd_Lookup_Values
      WHERE fnd_lookup_values.lookup_code = p_lookup_code
      AND   fnd_lookup_values.lookup_type = p_lookup_type;

  BEGIN

    IF (p_tbcv_rec.purchase_option_code <> OKL_API.G_MISS_CHAR AND p_tbcv_rec.purchase_option_code IS NOT NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'purchase_option_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
    --ELSE
            -- enforce foreign key

        OPEN   okl_tbcv_prch_fk_csr(p_tbcv_rec.purchase_option_code, 'OKL_EOT_OPTION')  ;
        FETCH  okl_tbcv_prch_fk_csr into l_dummy_var ;
        CLOSE  okl_tbcv_prch_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'purchase_option_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'FND_LOOKUP_VALUES');
            l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_purchase_option_code;
  -------------------------------------
  -- Validate_Attributes for: PDT_ID --
  -------------------------------------
  PROCEDURE validate_pdt_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_pdt_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   OKL_PRODUCTS
      WHERE  id = p_id
      AND  product_status_code  = 'APPROVED';

  BEGIN

    IF (p_tbcv_rec.pdt_id <> OKL_API.G_MISS_NUM AND p_tbcv_rec.pdt_id IS NOT NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'pdt_id');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
    --ELSE
      -- enforce foreign key
      OPEN   okl_tbcv_pdt_fk_csr(p_tbcv_rec.pdt_id) ;
      FETCH  okl_tbcv_pdt_fk_csr into l_dummy_var ;
      CLOSE  okl_tbcv_pdt_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'pdt_id',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'OKL_PRODUCTS');
           l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_pdt_id;
  -------------------------------------
  -- Validate_Attributes for: TRY_ID --
  -------------------------------------
  PROCEDURE validate_try_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_try_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   OKL_TRX_TYPES_B
      WHERE  id = p_id;

  BEGIN

    IF (p_tbcv_rec.try_id <> OKL_API.G_MISS_NUM AND p_tbcv_rec.try_id IS NOT NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'try_id');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
    --ELSE
          -- enforce foreign key
      OPEN   okl_tbcv_try_fk_csr(p_tbcv_rec.try_id) ;
      FETCH  okl_tbcv_try_fk_csr into l_dummy_var ;
      CLOSE  okl_tbcv_try_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'try_id',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'OKL_TRX_TYPES_B');
           l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_try_id;
  -------------------------------------
  -- Validate_Attributes for: STY_ID --
  -------------------------------------
  PROCEDURE validate_sty_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_sty_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   OKL_STRM_TYPE_B
      WHERE  id = p_id;

  BEGIN

    IF (p_tbcv_rec.sty_id <> OKL_API.G_MISS_NUM AND p_tbcv_rec.sty_id IS NOT NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sty_id');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
    --ELSE
          -- enforce foreign key
      OPEN   okl_tbcv_sty_fk_csr(p_tbcv_rec.sty_id) ;
      FETCH  okl_tbcv_sty_fk_csr into l_dummy_var ;
      CLOSE  okl_tbcv_sty_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'sty_id',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'OKL_STRM_TYPE_B');
           l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_sty_id;
  -------------------------------------------------
  -- Validate_Attributes for: INT_DISCLOSED_CODE --
  -------------------------------------------------
  PROCEDURE validate_int_disclosed_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_int_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
      FROM Fnd_Lookup_Values
      WHERE fnd_lookup_values.lookup_code = p_lookup_code
      AND   fnd_lookup_values.lookup_type = p_lookup_type;
  BEGIN

    IF (p_tbcv_rec.int_disclosed_code <> OKL_API.G_MISS_CHAR AND  p_tbcv_rec.int_disclosed_code IS NOT NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'int_disclosed_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
    --ELSE
          -- enforce foreign key
        OPEN   okl_tbcv_int_fk_csr(p_tbcv_rec.int_disclosed_code, 'YES_NO')  ;
        FETCH  okl_tbcv_int_fk_csr INTO l_dummy_var ;
        CLOSE  okl_tbcv_int_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'int_disclosed_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'FND_LOOKUP_VALUES');
            l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_int_disclosed_code;
  ------------------------------------------------
  -- Validate_Attributes for: TITLE_TRNSFR_CODE --
  ------------------------------------------------

  PROCEDURE validate_title_trnsfr_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_title_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
      FROM Fnd_Lookup_Values
      WHERE fnd_lookup_values.lookup_code = p_lookup_code
      AND   fnd_lookup_values.lookup_type = p_lookup_type;
  BEGIN

    IF (p_tbcv_rec.title_trnsfr_code <> OKL_API.G_MISS_CHAR AND  p_tbcv_rec.title_trnsfr_code IS NOT NULL)
    THEN
        OPEN   okl_tbcv_title_fk_csr(p_tbcv_rec.title_trnsfr_code, 'YES_NO')  ;
        FETCH  okl_tbcv_title_fk_csr INTO l_dummy_var ;
        CLOSE  okl_tbcv_title_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'title_trnsfr_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'FND_LOOKUP_VALUES');
            l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_title_trnsfr_code;
  ---------------------------------------------------
  -- Validate_Attributes for: SALE_LEASE_BACK_CODE --
  ---------------------------------------------------
  PROCEDURE validate_sale_lease_back_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_salelease_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
      FROM Fnd_Lookup_Values
      WHERE fnd_lookup_values.lookup_code = p_lookup_code
      AND   fnd_lookup_values.lookup_type = p_lookup_type;
  BEGIN

    IF (p_tbcv_rec.sale_lease_back_code <> OKL_API.G_MISS_CHAR AND   p_tbcv_rec.sale_lease_back_code IS NOT NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sale_lease_back_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
    --ELSE
        -- enforce foreign key
        OPEN   okl_tbcv_salelease_fk_csr(p_tbcv_rec.sale_lease_back_code, 'YES_NO')  ;
        FETCH  okl_tbcv_salelease_fk_csr INTO l_dummy_var ;
        CLOSE  okl_tbcv_salelease_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'sale_lease_back_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'FND_LOOKUP_VALUES');
            l_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_sale_lease_back_code;
  ---------------------------------------------------
  -- Validate_Attributes for: LEASE_PURCHASED_CODE --
  ---------------------------------------------------
  PROCEDURE validate_lease_purchased_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_saleprch_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
      FROM Fnd_Lookup_Values
      WHERE fnd_lookup_values.lookup_code = p_lookup_code
      AND   fnd_lookup_values.lookup_type = p_lookup_type;
  BEGIN

    IF (p_tbcv_rec.lease_purchased_code <> OKL_API.G_MISS_CHAR AND p_tbcv_rec.lease_purchased_code IS NOT NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'lease_purchased_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
    --ELSE
        -- enforce foreign key
        OPEN   okl_tbcv_saleprch_fk_csr(p_tbcv_rec.lease_purchased_code, 'YES_NO')  ;
        FETCH  okl_tbcv_saleprch_fk_csr INTO l_dummy_var ;
        CLOSE  okl_tbcv_saleprch_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'lease_purchased_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'FND_LOOKUP_VALUES');
            l_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_lease_purchased_code;
  -----------------------------------------------
  -- Validate_Attributes for: EQUIP_USAGE_CODE --
  -----------------------------------------------

  PROCEDURE validate_equip_usage_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_equsg_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT 'x'
      FROM zx_fc_intended_use_v
      WHERE classification_code = p_lookup_code;

  BEGIN

    IF (p_tbcv_rec.equip_usage_code <> OKL_API.G_MISS_CHAR AND  p_tbcv_rec.equip_usage_code IS NOT NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'equip_usage_code');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
    --ELSE
        -- enforce foreign key
        OPEN   okl_tbcv_equsg_fk_csr(p_tbcv_rec.equip_usage_code)  ;
        FETCH  okl_tbcv_equsg_fk_csr INTO l_dummy_var ;
        CLOSE  okl_tbcv_equsg_fk_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'equip_usage_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'ZX_FC_INTENDED_USE_V');
            l_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_equip_usage_code;
  ---------------------------------------------
  -- Validate_Attributes for: VENDOR_SITE_ID --
  ---------------------------------------------
  PROCEDURE validate_vendor_site_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_vsite_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
      FROM   Po_vendor_sites_all
      WHERE  vendor_site_id = p_id;
  BEGIN

    IF (p_tbcv_rec.vendor_site_id <> OKL_API.G_MISS_NUM AND  p_tbcv_rec.vendor_site_id IS NOT NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'vendor_site_id');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
    --ELSE
          -- enforce foreign key
      OPEN   okl_tbcv_vsite_fk_csr(p_tbcv_rec.vendor_site_id) ;
      FETCH  okl_tbcv_vsite_fk_csr into l_dummy_var ;
      CLOSE  okl_tbcv_vsite_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'vendor_site_id',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'Po_vendor_sites_all');
           l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_vendor_site_id;


  -------------------------------------
  -- Validate_Attributes for: age_of_equipment_from --
  -------------------------------------
  PROCEDURE validate_AGE_OF_EQUIP_FROM(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


  BEGIN

    IF (p_tbcv_rec.AGE_OF_EQUIP_FROM <> OKL_API.G_MISS_NUM AND p_tbcv_rec.AGE_OF_EQUIP_FROM IS NOT NULL)
    THEN
      IF p_tbcv_rec.AGE_OF_EQUIP_FROM < 0 THEN
         l_return_status := OKC_API.G_RET_STS_ERROR;
             --Unable to create Transcation Business Category definition as none of the attributes are provided.
         OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'AGE_OF_EQUIP_FROM');

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
  END validate_AGE_OF_EQUIP_FROM;

    -------------------------------------
  -- Validate_Attributes for: age_of_equipment_to --
  -------------------------------------
  PROCEDURE validate_AGE_OF_EQUIP_TO(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


  BEGIN

    IF (p_tbcv_rec.AGE_OF_EQUIP_TO <> OKL_API.G_MISS_NUM AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL)
    THEN
      IF p_tbcv_rec.AGE_OF_EQUIP_TO < 0 THEN
         l_return_status := OKC_API.G_RET_STS_ERROR;
             --Unable to create Transcation Business Category definition as none of the attributes are provided.
         OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'AGE_OF_EQUIP_TO');

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
  END validate_AGE_OF_EQUIP_TO;

  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_tbcv_rec.object_version_number = OKL_API.G_MISS_NUM OR  p_tbcv_rec.object_version_number IS NULL)
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

-- modified by dcshanmu for eBTax project - modification start
-- adding validation methods for new columns
  ----------------------------------------------------
  -- Validate_Attributes for: RESULT_TYPE_CODE --
  ----------------------------------------------------
  PROCEDURE validate_result_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_res_type_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_code = p_id
      AND lookup_type='OKL_TAX_ATTR_TYPE_CODE';
  BEGIN

    IF (p_tbcv_rec.result_type_code <> OKL_API.G_MISS_CHAR OR  p_tbcv_rec.result_type_code IS NOT NULL)
    THEN
      OPEN   okl_tbcv_res_type_fk_csr(p_tbcv_rec.result_type_code) ;
      FETCH  okl_tbcv_res_type_fk_csr into l_dummy_var ;
      CLOSE  okl_tbcv_res_type_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'result_type_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'FND_LOOKUPS');
           l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_result_type_code;

  ----------------------------------------------------
  -- Validate_Attributes for: BOOK_CLASS_CODE --
  ----------------------------------------------------
  PROCEDURE validate_book_class_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_bc_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_code = p_id
      AND lookup_type='OKL_BOOK_CLASS';
  BEGIN

    IF (p_tbcv_rec.book_class_code <> OKL_API.G_MISS_CHAR AND  p_tbcv_rec.book_class_code IS NOT NULL)
    THEN
      OPEN   okl_tbcv_bc_fk_csr(p_tbcv_rec.book_class_code) ;
      FETCH  okl_tbcv_bc_fk_csr into l_dummy_var ;
      CLOSE  okl_tbcv_bc_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'book_class_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'FND_LOOKUPS');
           l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_book_class_code;

  ----------------------------------------------------
  -- Validate_Attributes for: DATE_EFFECTIVE_TO --
  ----------------------------------------------------
  PROCEDURE validate_date_eff_to(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    IF (p_tbcv_rec.date_effective_from <> OKL_API.G_MISS_DATE AND  p_tbcv_rec.date_effective_from IS NOT NULL
      AND p_tbcv_rec.date_effective_to <> OKL_API.G_MISS_DATE AND p_tbcv_rec.date_effective_to IS NOT NULL)
    THEN
      IF (TRUNC(p_tbcv_rec.date_effective_to) < TRUNC(p_tbcv_rec.date_effective_from)) THEN
           OKL_API.set_message(p_app_name => G_APP_NAME,
                        p_msg_name => 'OKL_AM_DATE_EFF_FROM_LESS_TO',
                        p_token1 => 'DATE_EFFECTIVE_TO',
                        p_token1_value => p_tbcv_rec.date_effective_to,
                        p_token2 => 'DATE_EFFECTIVE_FROM',
                        p_token2_value => p_tbcv_rec.date_effective_from);
           l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_date_eff_to;

  ----------------------------------------------------
  -- Validate_Attributes for: TAX_COUNTRY_CODE --
  ----------------------------------------------------
  PROCEDURE validate_tax_country_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_tx_cntry_code_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_territories_tl
      WHERE  territory_code = p_id;

  BEGIN

    IF (p_tbcv_rec.tax_country_code <> OKL_API.G_MISS_CHAR AND  p_tbcv_rec.tax_country_code IS NOT NULL)
    THEN
      OPEN   okl_tbcv_tx_cntry_code_fk_csr(p_tbcv_rec.tax_country_code) ;
      FETCH  okl_tbcv_tx_cntry_code_fk_csr into l_dummy_var ;
      CLOSE  okl_tbcv_tx_cntry_code_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_country_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'FND_TERRITORIES_TL');
           l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_tax_country_code;

  ----------------------------------------------------
  -- Validate_Attributes for: TERM_QUOTE_TYPE_CODE --
  ----------------------------------------------------
  PROCEDURE validate_term_quote_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_term_qtcode_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_code = p_id
      AND lookup_type='OKL_QUOTE_TYPE';

  BEGIN

    IF (p_tbcv_rec.term_quote_type_code <> OKL_API.G_MISS_CHAR AND  p_tbcv_rec.term_quote_type_code IS NOT NULL)
    THEN
      OPEN   okl_tbcv_term_qtcode_fk_csr(p_tbcv_rec.term_quote_type_code) ;
      FETCH  okl_tbcv_term_qtcode_fk_csr into l_dummy_var ;
      CLOSE  okl_tbcv_term_qtcode_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'term_quote_type_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'FND_LOOKUPS');
           l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_term_quote_type_code;

  ----------------------------------------------------
  -- Validate_Attributes for: TERM_QUOTE_REASON_CODE --
  ----------------------------------------------------
  PROCEDURE validate_term_qt_reason_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_tbcv_term_qrcode_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_code = p_id
      AND lookup_type='OKL_QUOTE_REASON';

  BEGIN

    IF (p_tbcv_rec.term_quote_reason_code <> OKL_API.G_MISS_CHAR AND  p_tbcv_rec.term_quote_reason_code IS NOT NULL)
    THEN
      OPEN   okl_tbcv_term_qrcode_fk_csr(p_tbcv_rec.term_quote_reason_code) ;
      FETCH  okl_tbcv_term_qrcode_fk_csr into l_dummy_var ;
      CLOSE  okl_tbcv_term_qrcode_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'term_quote_reason_code',
                        g_child_table_token ,
                        'OKL_TAX_ATTR_DEFINITIONS',
                        g_parent_table_token ,
                        'FND_LOOKUPS');
           l_return_status := OKC_API.G_RET_STS_ERROR;

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
  END validate_term_qt_reason_code;
-- modified by dcshanmu for eBTax project - modification end

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_TAX_ATTR_DEFINITIONS --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_tbcv_rec                     IN tbcv_rec_type
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
   /* validate_id(x_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
*/

    -- modified by dcshanmu for eBTax project - modification start
    -- modified tbc_code to result_code due to datamodel change
    -- ***
    -- result_code
    -- ***
    validate_result_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
    -- modified by dcshanmu for eBTax project - modification end

    -- ***
    -- purchase_option_code
    -- ***
    validate_purchase_option_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- pdt_id
    -- ***
    validate_pdt_id(l_return_status, p_tbcv_rec);
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
    validate_try_id(l_return_status, p_tbcv_rec);
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
    validate_sty_id(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- int_disclosed_code
    -- ***
    validate_int_disclosed_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- title_trnsfr_code
    -- ***
    validate_title_trnsfr_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
    -- ***
    -- sale_lease_back_code
    -- ***
    validate_sale_lease_back_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- lease_purchased_code
    -- ***
    validate_lease_purchased_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- equip_usage_code
    -- ***
    validate_equip_usage_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- vendor_site_id
    -- ***
    validate_vendor_site_id(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- age_of_equip_from
    -- ***
    validate_age_of_equip_from(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- age_of_equip_to
    -- ***
    validate_age_of_equip_to(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

   -- modified by dcshanmu for eBTax project - modification start
   -- call for validation for values of new columns
    -- ***
    -- result_type_code
    -- ***
    validate_result_type_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- book_class_code
    -- ***
    validate_book_class_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- Date check
    -- ***
    validate_date_eff_to(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- tax_country_code
    -- ***
    validate_tax_country_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- term_quote_type_code
    -- ***
    validate_term_quote_type_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- term_quote_reason_code
    -- ***
    validate_term_qt_reason_code(l_return_status, p_tbcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
    -- modified by dcshanmu for eBTax project - modification end

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
  -----------------------------------------------
  -- Validate Record for:OKL_TAX_ATTR_DEFINITIONS --
  -----------------------------------------------
  /* Not needed as foreign key validations ar eincluded in individual validate procedures
  FUNCTION Validate_Record (
    p_tbcv_rec IN tbcv_rec_type,
    p_db_tbcv_rec IN tbcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_tbcv_rec IN tbcv_rec_type,
      p_db_tbcv_rec IN tbcv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;

    CURSOR okl_tbcv_res_type_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_code = p_id
      AND lookup_type='OKL_TAX_ATTR_TYPE_CODE';
      l_okl_tbcv_res_type       okl_tbcv_res_type_fk_csr%ROWTYPE;

    CURSOR okl_tbcv_bc_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_code = p_id
      AND lookup_type='OKL_BOOK_CLASS';
      l_okl_tbcv_bc                     okl_tbcv_bc_fk_csr%ROWTYPE;

    CURSOR okl_tbcv_tx_cntry_code_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_territories_tl
      WHERE  territory_code = p_id;
      l_okl_tbcv_tx_cntry_code          okl_tbcv_tx_cntry_code_fk_csr%ROWTYPE;

    CURSOR okl_tbcv_term_qtcode_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_code = p_id
      AND lookup_type='OKL_QUOTE_TYPE';
      l_okl_tbcv_term_qtcode            okl_tbcv_term_qtcode_fk_csr%ROWTYPE;

    CURSOR okl_tbcv_term_qrcode_fk_csr (p_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_code = p_id
      AND lookup_type='OKL_QUOTE_REASON';
      l_okl_tbcv_term_qrcode            okl_tbcv_term_qrcode_fk_csr%ROWTYPE;

    CURSOR okl_tbcv_res_code_fk_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
      FROM zx_fc_business_categories_v
      WHERE classification_code = p_lookup_code;
      --AND   lookup_type = p_lookup_type;
      l_okl_tbcv_res_code               okl_tbcv_res_code_fk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

    BEGIN

      IF ((p_ttdv_rec.RESULT_TYPE_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.RESULT_TYPE_CODE <> p_db_okl_tax_trx_details_v_rec.RESULT_TYPE_CODE))
      THEN
        OPEN okl_tbcv_res_type_fk_csr (p_ttdv_rec.RESULT_TYPE_CODE);
        FETCH okl_tbcv_res_type_fk_csr INTO l_okl_tbcv_res_type;
        l_row_notfound := okl_tbcv_res_type_fk_csr%NOTFOUND;
        CLOSE okl_tbcv_res_type_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RESULT_TYPE_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.RESULT_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.RESULT_CODE <> p_db_okl_tax_trx_details_v_rec.RESULT_CODE))
      THEN
        OPEN okl_tbcv_res_code_fk_csr (p_ttdv_rec.RESULT_CODE);
        FETCH okl_tbcv_res_code_fk_csr INTO l_okl_tbcv_res_code;
        l_row_notfound := okl_tbcv_res_code_fk_csr%NOTFOUND;
        CLOSE okl_tbcv_res_code_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RESULT_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.BOOK_CLASS_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.BOOK_CLASS_CODE <> p_db_okl_tax_trx_details_v_rec.BOOK_CLASS_CODE))
      THEN
        OPEN okl_tbcv_bc_fk_csr (p_ttdv_rec.BOOK_CLASS_CODE);
        FETCH okl_tbcv_bc_fk_csr INTO l_okl_tbcv_bc;
        l_row_notfound := okl_tbcv_bc_fk_csr%NOTFOUND;
        CLOSE okl_tbcv_bc_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BOOK_CLASS_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TAX_COUNTRY_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.TAX_COUNTRY_CODE <> p_db_okl_tax_trx_details_v_rec.TAX_COUNTRY_CODE))
      THEN
        OPEN okl_tbcv_tx_cntry_code_fk_csr (p_ttdv_rec.TAX_COUNTRY_CODE);
        FETCH okl_tbcv_tx_cntry_code_fk_csr INTO l_okl_tbcv_tx_cntry_code;
        l_row_notfound := okl_tbcv_tx_cntry_code_fk_csr%NOTFOUND;
        CLOSE okl_tbcv_tx_cntry_code_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_COUNTRY_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TERM_QUOTE_TYPE_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.TERM_QUOTE_TYPE_CODE <> p_db_okl_tax_trx_details_v_rec.TERM_QUOTE_TYPE_CODE))
      THEN
        OPEN okl_tbcv_term_qtcode_fk_csr (p_ttdv_rec.TERM_QUOTE_TYPE_CODE);
        FETCH okl_tbcv_term_qtcode_fk_csr INTO l_okl_tbcv_term_qtcode;
        l_row_notfound := okl_tbcv_term_qtcode_fk_csr%NOTFOUND;
        CLOSE okl_tbcv_term_qtcode_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TERM_QUOTE_TYPE_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      IF ((p_ttdv_rec.TERM_QUOTE_REASON_CODE IS NOT NULL)
       AND
          (p_ttdv_rec.TERM_QUOTE_REASON_CODE <> p_db_okl_tax_trx_details_v_rec.TERM_QUOTE_REASON_CODE))
      THEN
        OPEN okl_tbcv_term_qrcode_fk_csr (p_ttdv_rec.TERM_QUOTE_REASON_CODE);
        FETCH okl_tbcv_term_qrcode_fk_csr INTO l_okl_tbcv_term_qrcode;
        l_row_notfound := okl_tbcv_term_qrcode_fk_csr%NOTFOUND;
        CLOSE okl_tbcv_term_qrcode_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TERM_QUOTE_REASON_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;

      RETURN (l_return_status);

    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);

    END Validate_Record;

    FUNCTION Validate_Record (
      p_tbcv_rec IN tbcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_db_tbcv_rec                  tbcv_rec_type := get_rec(p_tbcv_rec);
    BEGIN
      l_return_status := Validate_Record(p_tbcv_rec => p_tbcv_rec,
                                         p_db_tbcv_rec => l_db_tbcv_rec);
      RETURN (l_return_status);
    END Validate_Record;
*/

    FUNCTION Validate_Record (
    p_tbcv_rec IN tbcv_rec_type



  ) RETURN VARCHAR2 IS

   -- modified by dcshanmu for eBTax project - modification start
   -- modified the method to add just the necessary conditions for duplication for
   -- TBC_CODE, PC_CODE and UFC_CODE categories
    CURSOR l_checkduplicate_tbc_csr(cp_tax_attribute_def_id IN VARCHAR2) IS
    SELECT result_code
    FROM   OKL_TAX_ATTR_DEFINITIONS
    WHERE  result_type_code = 'TBC_CODE'
--      AND    nvl(PURCHASE_OPTION_CODE,'XXXXX') = nvl(p_tbcv_rec.PURCHASE_OPTION_CODE,'XXXXX')
--      AND    nvl(PDT_ID, -99999) = nvl(p_tbcv_rec.PDT_ID,-99999)
        AND    nvl(TRY_ID, -99999) = nvl(p_tbcv_rec.TRY_ID,-99999)
        AND    nvl(STY_ID, -99999) = nvl(p_tbcv_rec.STY_ID,-99999)
--      AND    nvl(INT_DISCLOSED_CODE,'N') = nvl(p_tbcv_rec.INT_DISCLOSED_CODE,'N')
--      AND    nvl(TITLE_TRNSFR_CODE,'N') = nvl(p_tbcv_rec.TITLE_TRNSFR_CODE,'N')
--      AND    nvl(SALE_LEASE_BACK_CODE,'N') = nvl(p_tbcv_rec.SALE_LEASE_BACK_CODE,'N')
--      AND    nvl(LEASE_PURCHASED_CODE,'N') = nvl(p_tbcv_rec.LEASE_PURCHASED_CODE,'N')
--      AND    nvl(EQUIP_USAGE_CODE,'XXXXX') = nvl(p_tbcv_rec.EQUIP_USAGE_CODE,'XXXXX')
--      AND    nvl(VENDOR_SITE_ID,-99999) = nvl(p_tbcv_rec.VENDOR_SITE_ID,-99999)
        AND       nvl(BOOK_CLASS_CODE,'XXXXX') = nvl(p_tbcv_rec.BOOK_CLASS_CODE,'XXXXX')
        AND    nvl(TAX_COUNTRY_CODE,'XXXXX') = nvl(p_tbcv_rec.TAX_COUNTRY_CODE,'XXXXX')
        AND   nvl(TAX_ATTRIBUTE_DEF_ID, -99999) <> nvl(cp_tax_attribute_def_id,-99999)
        AND       nvl(EXPIRE_FLAG,'N')<> 'Y'


        /*AND (  (   -- This condition will allow cases where DB FROm and To are NULL and also Screen FROM and TO are null
                   --(AGE_OF_EQUIP_FROM IS NOT NULL OR AGE_OF_EQUIP_TO IS NOT NULL OR p_tbcv_rec.AGE_OF_EQUIP_FROM IS NOT NULL OR p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL )
                  -- AND
                    -- this condition will prevent exact matches (including cases where some values are null)
                   (nvl(AGE_OF_EQUIP_FROM,-99999) = nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,-99999) AND
                    nvl(AGE_OF_EQUIP_TO, -99999) = nvl(p_tbcv_rec.AGE_OF_EQUIP_TO,-99999)
                    )
                )
               OR -- age of equipment from can not be null for comparison purposes (when TO is not null),
                      -- as we can assume it is 0, if null
                  -- so this condition takes care of scenarios where both Froms and both Tos have a value
                  -- OR any of the FROMs are null and both Tos have a value
               (--nvl(AGE_OF_EQUIP_FROM,0) IS NOT NULL AND nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) IS NOT NULL AND
                AGE_OF_EQUIP_TO IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL AND
                  (  (nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) < nvl(AGE_OF_EQUIP_FROM,0) AND p_tbcv_rec.AGE_OF_EQUIP_TO >= nvl(AGE_OF_EQUIP_FROM,0))
                     OR
                     (nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) >= nvl(AGE_OF_EQUIP_FROM,0) AND nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) <= AGE_OF_EQUIP_TO) --AND p_tbcv_rec.AGE_OF_EQUIP_TO > AGE_OF_EQUIP_TO)
                  )

               )
               OR
               ( AGE_OF_EQUIP_TO IS NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NULL AND
                 -- In this case Both the FROMs can not be null together or have the same value, as it will get captured in condition 1
                 -- here, either DB FROM is Null and Screen FROM is not null --> This combination is ok
                 -- OR DB FROM is not null and Screen FROM is null --> this combinatio is ok
                 -- OR both FROMs have a value(differenr value) --> restrict this combination
                 AGE_OF_EQUIP_FROM IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_FROM IS NOT NULL -- The 2 FROMs can not have same value at this point
               )
               OR
                   ( AGE_OF_EQUIP_TO IS NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL AND -- TO in DB is Null,TO on screen is not null
                     -- In this case following scenarios are possible
                     -- DB FROM is Null (DB To is also NUll) FROM on the screen can be considered to be be >=0 (0 if null), since TO on screen is not null - OK
                         -- DB FROM >=0, SCREEN TO < DB FROM - ok
                         -- DB FROM >=0, SCREEN TO >= DB FROM - restrict this condition
                         AGE_OF_EQUIP_FROM >= 0 AND p_tbcv_rec.AGE_OF_EQUIP_TO >= AGE_OF_EQUIP_FROM
                   )
                   OR
                   ( AGE_OF_EQUIP_TO IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NULL AND
                     -- In this case following scenarios are possible
                     -- DB FROM can be considered to be >=0 (0 if null), since DB TO is not null, so there is a fixed age range defined in DB
                     -- SCREEN FROM is null (TO is always NULL) - OK
                     -- screen from >=0, SCREEN FROM > DB TO - ok
                     -- screen from >=0, screen from <= db to - RESTRICT THIS CONDITION
                     p_tbcv_rec.AGE_OF_EQUIP_FROM >=0 AND p_tbcv_rec.AGE_OF_EQUIP_FROM <= AGE_OF_EQUIP_TO
                   )
            )*/  ;

        CURSOR l_checkduplicate_pc_csr(cp_tax_attribute_def_id IN VARCHAR2) IS
            SELECT result_code
            FROM   OKL_TAX_ATTR_DEFINITIONS
            WHERE  result_type_code = 'PC_CODE'
        AND    nvl(PURCHASE_OPTION_CODE,'XXXXX') = nvl(p_tbcv_rec.PURCHASE_OPTION_CODE,'XXXXX')
                AND    nvl(STY_ID, -99999) = nvl(p_tbcv_rec.STY_ID,-99999)
                AND    nvl(INT_DISCLOSED_CODE,'N') = nvl(p_tbcv_rec.INT_DISCLOSED_CODE,'N')
                AND    nvl(TITLE_TRNSFR_CODE,'N') = nvl(p_tbcv_rec.TITLE_TRNSFR_CODE,'N')
                AND    nvl(SALE_LEASE_BACK_CODE,'N') = nvl(p_tbcv_rec.SALE_LEASE_BACK_CODE,'N')
                AND    nvl(LEASE_PURCHASED_CODE,'N') = nvl(p_tbcv_rec.LEASE_PURCHASED_CODE,'N')
                AND    nvl(TAX_COUNTRY_CODE,'XXXXX') = nvl(p_tbcv_rec.TAX_COUNTRY_CODE,'XXXXX')
                AND   nvl(TAX_ATTRIBUTE_DEF_ID, -99999) <> nvl(cp_tax_attribute_def_id,-99999)
                AND       nvl(EXPIRE_FLAG,'N')<> 'Y' ;

        CURSOR l_checkduplicate_ufc_csr(cp_tax_attribute_def_id IN VARCHAR2) IS
            SELECT result_code
            FROM   OKL_TAX_ATTR_DEFINITIONS
            WHERE  /*result_code <> cp_tbc_code
                AND   */result_type_code = 'UFC_CODE'
        AND     nvl(PURCHASE_OPTION_CODE,'XXXXX') = nvl(p_tbcv_rec.PURCHASE_OPTION_CODE,'XXXXX')
                AND    nvl(PDT_ID, -99999) = nvl(p_tbcv_rec.PDT_ID,-99999)
                AND    nvl(STY_ID, -99999) = nvl(p_tbcv_rec.STY_ID,-99999)
                AND    nvl(TRY_ID, -99999) = nvl(p_tbcv_rec.TRY_ID,-99999)
                AND    nvl(LEASE_PURCHASED_CODE,'N') = nvl(p_tbcv_rec.LEASE_PURCHASED_CODE,'N')
                AND    nvl(EQUIP_USAGE_CODE,'XXXXX') = nvl(p_tbcv_rec.EQUIP_USAGE_CODE,'XXXXX')
                AND    nvl(VENDOR_SITE_ID,-99999) = nvl(p_tbcv_rec.VENDOR_SITE_ID,-99999)
                AND    nvl(INT_DISCLOSED_CODE,'N') = nvl(p_tbcv_rec.INT_DISCLOSED_CODE,'N')
                AND    nvl(TITLE_TRNSFR_CODE,'N') = nvl(p_tbcv_rec.TITLE_TRNSFR_CODE,'N')
                AND    nvl(SALE_LEASE_BACK_CODE,'N') = nvl(p_tbcv_rec.SALE_LEASE_BACK_CODE,'N')
                AND    nvl(TAX_COUNTRY_CODE,'XXXXX') = nvl(p_tbcv_rec.TAX_COUNTRY_CODE,'XXXXX')
                AND    nvl(TERM_QUOTE_TYPE_CODE,'XXXXX') = nvl(p_tbcv_rec.TERM_QUOTE_TYPE_CODE,'XXXXX')
                AND    nvl(TERM_QUOTE_REASON_CODE,'XXXXX') = nvl(p_tbcv_rec.TERM_QUOTE_REASON_CODE,'XXXXX')
                AND       nvl(EXPIRE_FLAG,'N')<> 'Y'
                AND   nvl(TAX_ATTRIBUTE_DEF_ID, -99999) <> nvl(cp_tax_attribute_def_id,-99999)

                AND (  (   -- This condition will allow cases where DB FROm and To are NULL and also Screen FROM and TO are null
                   --(AGE_OF_EQUIP_FROM IS NOT NULL OR AGE_OF_EQUIP_TO IS NOT NULL OR p_tbcv_rec.AGE_OF_EQUIP_FROM IS NOT NULL OR p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL )
                  -- AND
                    -- this condition will prevent exact matches (including cases where some values are null)
                   (nvl(AGE_OF_EQUIP_FROM,-99999) = nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,-99999) AND
                    nvl(AGE_OF_EQUIP_TO, -99999) = nvl(p_tbcv_rec.AGE_OF_EQUIP_TO,-99999)
                    )
                )
               OR -- age of equipment from can not be null for comparison purposes (when TO is not null),
                      -- as we can assume it is 0, if null
                  -- so this condition takes care of scenarios where both Froms and both Tos have a value
                  -- OR any of the FROMs are null and both Tos have a value
               (--nvl(AGE_OF_EQUIP_FROM,0) IS NOT NULL AND nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) IS NOT NULL AND
                AGE_OF_EQUIP_TO IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL AND
                  (  (nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) < nvl(AGE_OF_EQUIP_FROM,0) AND p_tbcv_rec.AGE_OF_EQUIP_TO >= nvl(AGE_OF_EQUIP_FROM,0))
                     OR
                     (nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) >= nvl(AGE_OF_EQUIP_FROM,0) AND nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) <= AGE_OF_EQUIP_TO) --AND p_tbcv_rec.AGE_OF_EQUIP_TO > AGE_OF_EQUIP_TO)
                  )

               )
               OR
               ( AGE_OF_EQUIP_TO IS NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NULL AND
                 -- In this case Both the FROMs can not be null together or have the same value, as it will get captured in condition 1
                 -- here, either DB FROM is Null and Screen FROM is not null --> This combination is ok
                 -- OR DB FROM is not null and Screen FROM is null --> this combinatio is ok
                 -- OR both FROMs have a value(differenr value) --> restrict this combination
                 AGE_OF_EQUIP_FROM IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_FROM IS NOT NULL -- The 2 FROMs can not have same value at this point
               )
               OR
                   ( AGE_OF_EQUIP_TO IS NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL AND -- TO in DB is Null,TO on screen is not null
                     -- In this case following scenarios are possible
                     -- DB FROM is Null (DB To is also NUll) FROM on the screen can be considered to be be >=0 (0 if null), since TO on screen is not null - OK
                         -- DB FROM >=0, SCREEN TO < DB FROM - ok
                         -- DB FROM >=0, SCREEN TO >= DB FROM - restrict this condition
                         AGE_OF_EQUIP_FROM >= 0 AND p_tbcv_rec.AGE_OF_EQUIP_TO >= AGE_OF_EQUIP_FROM
                   )
                   OR
                   ( AGE_OF_EQUIP_TO IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NULL AND
                     -- In this case following scenarios are possible
                     -- DB FROM can be considered to be >=0 (0 if null), since DB TO is not null, so there is a fixed age range defined in DB
                     -- SCREEN FROM is null (TO is always NULL) - OK
                     -- screen from >=0, SCREEN FROM > DB TO - ok
                     -- screen from >=0, screen from <= db to - RESTRICT THIS CONDITION
                     p_tbcv_rec.AGE_OF_EQUIP_FROM >=0 AND p_tbcv_rec.AGE_OF_EQUIP_FROM <= AGE_OF_EQUIP_TO
                   )
            ) ;




        -- modified by dcshanmu for eBTax project - modification end

    CURSOR okl_tbc_res_code_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT classification_name
      FROM zx_fc_business_categories_v
      WHERE classification_code = p_lookup_code;

    CURSOR okl_pc_res_code_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT classification_name
      FROM zx_fc_product_categories_v
      WHERE classification_code = p_lookup_code;

    CURSOR okl_ufc_res_code_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT classification_name
      FROM zx_fc_user_defined_v
      WHERE classification_code = p_lookup_code;

    CURSOR get_try_name(cp_try_id IN VARCHAR2) IS
        select NAME
        from okl_trx_types_tl
        where  ID = cp_try_id
        AND    language = 'US';


        l_result_code                                      VARCHAR2(300) := 'XXXXX';
        x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_meaning                                          VARCHAR2(80);

        l_msg_name VARCHAR2(80);
        l_token1        VARCHAR2(10);
        l_try_name      VARCHAR2(255);

    BEGIN

      IF (--(p_tbcv_rec.PURCHASE_OPTION_CODE = OKL_API.G_MISS_CHAR OR p_tbcv_rec.purchase_option_code IS NULL) AND
         --(p_tbcv_rec.PDT_ID = OKL_API.G_MISS_NUM OR p_tbcv_rec.PDT_ID IS NULL) AND
         --(p_tbcv_rec.TRY_ID = OKL_API.G_MISS_NUM OR p_tbcv_rec.TRY_ID IS NULL) AND
         --    (p_tbcv_rec.STY_ID = OKL_API.G_MISS_NUM OR p_tbcv_rec.STY_ID IS NULL) AND
         --    (p_tbcv_rec.INT_DISCLOSED_CODE = OKL_API.G_MISS_CHAR OR p_tbcv_rec.INT_DISCLOSED_CODE IS NULL) AND
         --    (p_tbcv_rec.TITLE_TRNSFR_CODE = OKL_API.G_MISS_CHAR OR p_tbcv_rec.TITLE_TRNSFR_CODE IS NULL) AND
         --    (p_tbcv_rec.SALE_LEASE_BACK_CODE = OKL_API.G_MISS_CHAR OR p_tbcv_rec.SALE_LEASE_BACK_CODE IS NULL) AND
         --    (p_tbcv_rec.LEASE_PURCHASED_CODE = OKL_API.G_MISS_CHAR OR p_tbcv_rec.LEASE_PURCHASED_CODE IS NULL) AND
         --    (p_tbcv_rec.EQUIP_USAGE_CODE = OKL_API.G_MISS_CHAR OR p_tbcv_rec.EQUIP_USAGE_CODE IS NULL) AND
         --    (p_tbcv_rec.VENDOR_SITE_ID = OKL_API.G_MISS_NUM OR p_tbcv_rec.VENDOR_SITE_ID IS NULL) AND
         --   (p_tbcv_rec.AGE_OF_EQUIP_FROM = OKL_API.G_MISS_NUM OR p_tbcv_rec.AGE_OF_EQUIP_FROM IS NULL) AND
         --    (p_tbcv_rec.AGE_OF_EQUIP_TO = OKL_API.G_MISS_NUM OR p_tbcv_rec.AGE_OF_EQUIP_TO IS NULL)
         (p_tbcv_rec.RESULT_CODE = OKL_API.G_MISS_CHAR OR p_tbcv_rec.RESULT_CODE IS NULL) ) THEN

                  x_return_status := OKC_API.G_RET_STS_ERROR;
                  --Unable to create Category definition as mandatory attributes are provided.
                  OKL_API.set_message(p_app_name    => 'OKL',
                                  p_msg_name    => 'OKL_TX_NO_TBC_ATTR');
                  RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;
      IF (p_tbcv_rec.AGE_OF_EQUIP_FROM IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_FROM <> OKL_API.G_MISS_NUM) AND
         (p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO <> OKL_API.G_MISS_NUM) THEN
          IF p_tbcv_rec.AGE_OF_EQUIP_TO < p_tbcv_rec.AGE_OF_EQUIP_FROM THEN
              x_return_status := OKC_API.G_RET_STS_ERROR;
                  --Unable to create Transcation Business Category definition as none of the attributes are provided.
                  OKL_API.set_message(p_app_name    => 'OKL',
                                  p_msg_name    => 'OKL_TX_INVALID_AGE_RANGE');
                  RAISE G_EXCEPTION_HALT_VALIDATION;

          END IF;
      END IF;

      -- modified by dcshanmu for eBTax project - modification start
      IF (p_tbcv_rec.result_type_code = 'TBC_CODE') THEN
              OPEN  l_checkduplicate_tbc_csr(p_tbcv_rec.tax_attribute_def_id);
              FETCH l_checkduplicate_tbc_csr INTO l_result_code;
              CLOSE l_checkduplicate_tbc_csr;
              IF l_result_code <> 'XXXXX' THEN
                OPEN  okl_tbc_res_code_fk_csr(l_result_code);
                FETCH okl_tbc_res_code_fk_csr INTO l_meaning;
                CLOSE okl_tbc_res_code_fk_csr;
              END IF;
              l_msg_name := 'OKL_TX_DUP_TBC_ERR';
              l_token1 := 'TBC';

      ELSIF (p_tbcv_rec.result_type_code = 'PC_CODE') THEN
              OPEN  l_checkduplicate_pc_csr(p_tbcv_rec.tax_attribute_def_id);
              FETCH l_checkduplicate_pc_csr INTO l_result_code;
              CLOSE l_checkduplicate_pc_csr;
              IF l_result_code <> 'XXXXX' THEN
                OPEN  okl_pc_res_code_fk_csr(l_result_code);
                FETCH okl_pc_res_code_fk_csr INTO l_meaning;
                CLOSE okl_pc_res_code_fk_csr;
              END IF;
              l_msg_name := 'OKL_TX_DUP_PC_ERR';
              l_token1 := 'PC_CODE';

      ELSIF (p_tbcv_rec.result_type_code = 'UFC_CODE') THEN

                            IF (p_tbcv_rec.term_quote_reason_code IS NOT NULL AND p_tbcv_rec.term_quote_reason_code <> OKL_API.G_MISS_CHAR ) THEN
                IF p_tbcv_rec.try_id IS NOT NULL THEN
                   OPEN  get_try_name(p_tbcv_rec.try_id);
                   FETCH get_try_name INTO l_try_name;
                   CLOSE get_try_name;

                   IF l_try_name NOT IN ('Estimated Billing',
                                         'Billing',
                                         'Credit Memo',
                                         'Rollover Billing',
                                         'Rollover Credit Memo',
                                         'Release Billing',
                                         'Release Credit Memo') THEN

                    x_return_status := OKC_API.G_RET_STS_ERROR;
                     OKL_API.set_message(p_app_name      => 'OKL',
                                        p_msg_name      => 'OKL_TERMQTE_RSNTYP_NA_ERR',
                                        p_token1        => 'TRX_TYPE',
                                        p_token1_value  => l_try_name);
                     RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;
                END IF;
              END IF;

              IF (p_tbcv_rec.term_quote_type_code IS NOT NULL AND p_tbcv_rec.term_quote_type_code <> OKL_API.G_MISS_CHAR ) THEN
                IF p_tbcv_rec.try_id IS NOT NULL THEN
                  OPEN  get_try_name(p_tbcv_rec.try_id);
                  FETCH get_try_name INTO l_try_name;
                  CLOSE get_try_name;

                   IF l_try_name NOT IN ('Estimated Billing',
                                         'Billing',
                                         'Credit Memo',
                                         'Rollover Billing',
                                         'Rollover Credit Memo',
                                         'Release Billing',
                                         'Release Credit Memo') THEN

                    x_return_status := OKC_API.G_RET_STS_ERROR;
                     OKL_API.set_message(p_app_name      => 'OKL',
                                        p_msg_name      => 'OKL_TERMQTE_RSNTYP_NA_ERR',
                                        p_token1        => 'TRX_TYPE',
                                        p_token1_value  => l_try_name);
                     RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;
                END IF;
              END IF;





              OPEN  l_checkduplicate_ufc_csr(p_tbcv_rec.tax_attribute_def_id);
              FETCH l_checkduplicate_ufc_csr INTO l_result_code;
              CLOSE l_checkduplicate_ufc_csr;
              IF l_result_code <> 'XXXXX' THEN
                OPEN  okl_ufc_res_code_fk_csr(l_result_code);
                FETCH okl_ufc_res_code_fk_csr INTO l_meaning;
                CLOSE okl_ufc_res_code_fk_csr;
              END IF;
              l_msg_name := 'OKL_TX_DUP_UFC_ERR';
              l_token1 := 'UFC_CODE';
      END IF;
      -- modified by dcshanmu for eBTax project - modification end

      -- There can be at the most one duplicate record.
      IF l_result_code <> 'XXXXX' THEN
         x_return_status := OKC_API.G_RET_STS_ERROR;
             -- Another Category already exists for this combination of tax determinants.
             -- modified by dcshanmu for eBTax project - modification start
             -- modified default values passed to p_msg_name and p_token1

         OKL_API.set_message(p_app_name      => 'OKL',
                             p_msg_name      => l_msg_name,
                             p_token1        => l_token1,
                             p_token1_value  => l_meaning);
         RAISE G_EXCEPTION_HALT_VALIDATION;

        -- modified by dcshanmu for eBTax project - modification start

     END IF;

      RETURN (x_return_status);
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
    END Validate_Record;
    ---------------------------------------------------------------------------
    -- PROCEDURE Migrate
    ---------------------------------------------------------------------------
    PROCEDURE migrate (
      p_from IN tbcv_rec_type,
      p_to   IN OUT NOCOPY tbc_rec_type
    ) IS
    BEGIN
     -- p_to.id := p_from.id;
    --  p_to.org_id := p_from.org_id;
      p_to.result_code := p_from.result_code;
      p_to.purchase_option_code := p_from.purchase_option_code;
      p_to.pdt_id := p_from.pdt_id;
      p_to.try_id := p_from.try_id;
      p_to.sty_id := p_from.sty_id;
      p_to.int_disclosed_code := p_from.int_disclosed_code;
      p_to.title_trnsfr_code := p_from.title_trnsfr_code;
      p_to.sale_lease_back_code := p_from.sale_lease_back_code;
      p_to.lease_purchased_code := p_from.lease_purchased_code;
      p_to.equip_usage_code := p_from.equip_usage_code;
      p_to.vendor_site_id := p_from.vendor_site_id;
      p_to.age_of_equip_from := p_from.age_of_equip_from;
      p_to.age_of_equip_to := p_from.age_of_equip_to;
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
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;

      -- modified by dcshanmu for eBTax project - modification start
      p_to.tax_attribute_def_id := p_from.tax_attribute_def_id;
      p_to.result_type_code := p_from.result_type_code;
      p_to.book_class_code := p_from.book_class_code;
      p_to.date_effective_from := p_from.date_effective_from;
      p_to.date_effective_to := p_from.date_effective_to;
      p_to.tax_country_code := p_from.tax_country_code;
      p_to.term_quote_type_code := p_from.term_quote_type_code;
      p_to.term_quote_reason_code := p_from.term_quote_reason_code;
      p_to.expire_flag := p_from.expire_flag;
      -- modified by dcshanmu for eBTax project - modification end
    END migrate;
    PROCEDURE migrate (
      p_from IN tbc_rec_type,
      p_to   IN OUT NOCOPY tbcv_rec_type
    ) IS
    BEGIN
     -- p_to.id := p_from.id;
     -- p_to.org_id := p_from.org_id;
      p_to.result_code := p_from.result_code;
      p_to.purchase_option_code := p_from.purchase_option_code;
      p_to.pdt_id := p_from.pdt_id;
      p_to.try_id := p_from.try_id;
      p_to.sty_id := p_from.sty_id;
      p_to.int_disclosed_code := p_from.int_disclosed_code;
      p_to.title_trnsfr_code := p_from.title_trnsfr_code;
      p_to.sale_lease_back_code := p_from.sale_lease_back_code;
      p_to.lease_purchased_code := p_from.lease_purchased_code;
      p_to.equip_usage_code := p_from.equip_usage_code;
      p_to.vendor_site_id := p_from.vendor_site_id;
      p_to.age_of_equip_from := p_from.age_of_equip_from;
      p_to.age_of_equip_to := p_from.age_of_equip_to;
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
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;

      -- modified by dcshanmu for eBTax project - modification start
      p_to.tax_attribute_def_id := p_from.tax_attribute_def_id;
      p_to.result_type_code := p_from.result_type_code;
      p_to.book_class_code := p_from.book_class_code;
      p_to.date_effective_from := p_from.date_effective_from;
      p_to.date_effective_to := p_from.date_effective_to;
      p_to.tax_country_code := p_from.tax_country_code;
      p_to.term_quote_type_code := p_from.term_quote_type_code;
      p_to.term_quote_reason_code := p_from.term_quote_reason_code;
      p_to.expire_flag := p_from.expire_flag;
      -- modified by dcshanmu for eBTax project - modification end
    END migrate;
    ---------------------------------------------------------------------------
    -- PROCEDURE validate_row
    ---------------------------------------------------------------------------
    --------------------------------------------
    -- validate_row for:OKL_TAX_ATTR_DEFINITIONS --
    --------------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_rec                     IN tbcv_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_tbcv_rec                     tbcv_rec_type := p_tbcv_rec;
      l_tbc_rec                      tbc_rec_type;
      l_tbc_rec                      tbc_rec_type;
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
      l_return_status := Validate_Attributes(l_tbcv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := Validate_Record(l_tbcv_rec);
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
    -------------------------------------------------------
    -- PL/SQL TBL validate_row for:OKL_TAX_ATTR_DEFINITIONS --
    -------------------------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_tbl                     IN tbcv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
      i                              NUMBER := 0;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_tbcv_tbl.COUNT > 0) THEN
        i := p_tbcv_tbl.FIRST;
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
              p_tbcv_rec                     => p_tbcv_tbl(i));
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
          EXIT WHEN (i = p_tbcv_tbl.LAST);
          i := p_tbcv_tbl.NEXT(i);
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
    -- PL/SQL TBL validate_row for:OKL_TAX_ATTR_DEFINITIONS --
    -------------------------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_tbl                     IN tbcv_tbl_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_tbcv_tbl.COUNT > 0) THEN
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tbcv_tbl                     => p_tbcv_tbl,
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
    -- insert_row for:OKL_TAX_ATTR_DEFINITIONS --
    ------------------------------------------
    PROCEDURE insert_row(
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbc_rec                      IN tbc_rec_type,
      x_tbc_rec                      OUT NOCOPY tbc_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_tbc_rec                      tbc_rec_type := p_tbc_rec;
      l_def_tbc_rec                  tbc_rec_type;
      ----------------------------------------------
      -- Set_Attributes for:OKL_TAX_ATTR_DEFINITIONS--
      ----------------------------------------------
      FUNCTION Set_Attributes (
        p_tbc_rec IN tbc_rec_type,
        x_tbc_rec OUT NOCOPY tbc_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_tbc_rec := p_tbc_rec;
        x_tbc_rec.tax_attribute_def_id := okc_p_util.raw_to_number(sys_guid());
        x_tbc_rec.date_effective_from := to_date('01-01-1960','dd-mm-rrrr');
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
        p_tbc_rec,                         -- IN
        l_tbc_rec);                        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      INSERT INTO OKL_TAX_ATTR_DEFINITIONS(
       -- id,
       -- org_id,
        result_code,
        purchase_option_code,
        pdt_id,
        try_id,
        sty_id,
        int_disclosed_code,
        title_trnsfr_code,
        sale_lease_back_code,
        lease_purchased_code,
        equip_usage_code,
        vendor_site_id,
        age_of_equip_from,
        age_of_equip_to,
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
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        -- modified by dcshanmu for eBTax project - modification start
        tax_attribute_def_id,
        result_type_code,
        book_class_code,
        date_effective_from,
        date_effective_to,
        tax_country_code,
        term_quote_type_code,
        term_quote_reason_code,
        expire_flag)
        -- modified by dcshanmu for eBTax project - modification end
      VALUES (
       -- l_tbc_rec.id,
       -- l_tbc_rec.org_id,
        l_tbc_rec.result_code,
        l_tbc_rec.purchase_option_code,
        l_tbc_rec.pdt_id,
        l_tbc_rec.try_id,
        l_tbc_rec.sty_id,
        l_tbc_rec.int_disclosed_code,
        l_tbc_rec.title_trnsfr_code,
        l_tbc_rec.sale_lease_back_code,
        l_tbc_rec.lease_purchased_code,
        l_tbc_rec.equip_usage_code,
        l_tbc_rec.vendor_site_id,
        l_tbc_rec.age_of_equip_from,
        l_tbc_rec.age_of_equip_to,
        l_tbc_rec.object_version_number,
        l_tbc_rec.attribute_category,
        l_tbc_rec.attribute1,
        l_tbc_rec.attribute2,
        l_tbc_rec.attribute3,
        l_tbc_rec.attribute4,
        l_tbc_rec.attribute5,
        l_tbc_rec.attribute6,
        l_tbc_rec.attribute7,
        l_tbc_rec.attribute8,
        l_tbc_rec.attribute9,
        l_tbc_rec.attribute10,
        l_tbc_rec.attribute11,
        l_tbc_rec.attribute12,
        l_tbc_rec.attribute13,
        l_tbc_rec.attribute14,
        l_tbc_rec.attribute15,
        l_tbc_rec.created_by,
        l_tbc_rec.creation_date,
        l_tbc_rec.last_updated_by,
        l_tbc_rec.last_update_date,
        l_tbc_rec.last_update_login,
        -- modified by dcshanmu for eBTax project - modification start
        l_tbc_rec.tax_attribute_def_id,
        l_tbc_rec.result_type_code,
        l_tbc_rec.book_class_code,
        l_tbc_rec.date_effective_from,
        l_tbc_rec.date_effective_to,
        l_tbc_rec.tax_country_code,
        l_tbc_rec.term_quote_type_code,
        l_tbc_rec.term_quote_reason_code,
        l_tbc_rec.expire_flag);
        -- modified by dcshanmu for eBTax project - modification end
      -- Set OUT values
      x_tbc_rec := l_tbc_rec;
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
    -- insert_row for :OKL_TAX_ATTR_DEFINITIONS --
    -------------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_rec                     IN tbcv_rec_type,
      x_tbcv_rec                     OUT NOCOPY tbcv_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_tbcv_rec                     tbcv_rec_type := p_tbcv_rec;
      l_def_tbcv_rec                 tbcv_rec_type;
      l_tbc_rec                      tbc_rec_type;
      lx_tbc_rec                     tbc_rec_type;
      -------------------------------
      -- FUNCTION fill_who_columns --
      -------------------------------
      FUNCTION fill_who_columns (
        p_tbcv_rec IN tbcv_rec_type
      ) RETURN tbcv_rec_type IS
        l_tbcv_rec tbcv_rec_type := p_tbcv_rec;
      BEGIN
        l_tbcv_rec.CREATION_DATE := SYSDATE;
        l_tbcv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
        l_tbcv_rec.LAST_UPDATE_DATE := l_tbcv_rec.CREATION_DATE;
        l_tbcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_tbcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_tbcv_rec);
      END fill_who_columns;
      ----------------------------------------------
      -- Set_Attributes for:OKL_TAX_ATTR_DEFINITIONS --
      ----------------------------------------------
      FUNCTION Set_Attributes (
        p_tbcv_rec IN tbcv_rec_type,
        x_tbcv_rec OUT NOCOPY tbcv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_tbcv_rec := p_tbcv_rec;
        x_tbcv_rec.OBJECT_VERSION_NUMBER := 1;
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
      l_tbcv_rec := null_out_defaults(p_tbcv_rec);
      -- Set primary key value
      l_tbcv_rec.tax_attribute_def_id := get_seq_id;
      -- Setting item attributes
      l_return_Status := Set_Attributes(
        l_tbcv_rec,                        -- IN
        l_def_tbcv_rec);                   -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_def_tbcv_rec := fill_who_columns(l_def_tbcv_rec);

      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_def_tbcv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := Validate_Record(l_def_tbcv_rec);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -----------------------------------------
      -- Move VIEW record to "Child" records --
      -----------------------------------------
      migrate(l_def_tbcv_rec, l_tbc_rec);
      -----------------------------------------------
      -- Call the INSERT_ROW for each child record --
      -----------------------------------------------
      insert_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_tbc_rec,
        lx_tbc_rec
      );
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_tbc_rec, l_def_tbcv_rec);
      -- Set OUT values

      x_tbcv_rec := l_def_tbcv_rec;
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
    -- PL/SQL TBL insert_row for:TBCV_TBL --
    ----------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_tbl                     IN tbcv_tbl_type,
      x_tbcv_tbl                     OUT NOCOPY tbcv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
      i                              NUMBER := 0;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_tbcv_tbl.COUNT > 0) THEN
        i := p_tbcv_tbl.FIRST;
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
              p_tbcv_rec                     => p_tbcv_tbl(i),
              x_tbcv_rec                     => x_tbcv_tbl(i));
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
          EXIT WHEN (i = p_tbcv_tbl.LAST);
          i := p_tbcv_tbl.NEXT(i);
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
    -- PL/SQL TBL insert_row for:TBCV_TBL --
    ----------------------------------------
    -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
    -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_tbl                     IN tbcv_tbl_type,
      x_tbcv_tbl                     OUT NOCOPY tbcv_tbl_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_tbcv_tbl.COUNT > 0) THEN
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tbcv_tbl                     => p_tbcv_tbl,
          x_tbcv_tbl                     => x_tbcv_tbl,
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
    -- lock_row for:OKL_TAX_ATTR_DEFINITIONS --
    ----------------------------------------
    PROCEDURE lock_row(
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbc_rec                      IN tbc_rec_type) IS

      E_Resource_Busy                EXCEPTION;
      PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
      CURSOR lock_csr (p_tbc_rec IN tbc_rec_type) IS
      SELECT OBJECT_VERSION_NUMBER
        FROM OKL_TAX_ATTR_DEFINITIONS
       --WHERE ID = p_tbc_rec.id
       WHERE RESULT_CODE = p_tbc_rec.result_code
         AND OBJECT_VERSION_NUMBER = p_tbc_rec.object_version_number
      FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

      CURSOR lchk_csr (p_tbc_rec IN tbc_rec_type) IS
      SELECT OBJECT_VERSION_NUMBER
        FROM OKL_TAX_ATTR_DEFINITIONS
      -- WHERE ID = p_tbc_rec.id;
      WHERE RESULT_CODE = p_tbc_rec.result_code;
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_object_version_number        OKL_TAX_ATTR_DEFINITIONS.OBJECT_VERSION_NUMBER%TYPE;
      lc_object_version_number       OKL_TAX_ATTR_DEFINITIONS.OBJECT_VERSION_NUMBER%TYPE;
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
        OPEN lock_csr(p_tbc_rec);
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
        OPEN lchk_csr(p_tbc_rec);
        FETCH lchk_csr INTO lc_object_version_number;
        lc_row_notfound := lchk_csr%NOTFOUND;
        CLOSE lchk_csr;
      END IF;
      IF (lc_row_notfound) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number > p_tbc_rec.object_version_number THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number <> p_tbc_rec.object_version_number THEN
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
    -- lock_row for: OKL_TAX_ATTR_DEFINITIONS --
    -----------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_rec                     IN tbcv_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_tbc_rec                      tbc_rec_type;
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
      migrate(p_tbcv_rec, l_tbc_rec);
      ---------------------------------------------
      -- Call the LOCK_ROW for each child record --
      ---------------------------------------------
      lock_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_tbc_rec
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
    -- PL/SQL TBL lock_row for:TBCV_TBL --
    --------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_tbl                     IN tbcv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
      i                              NUMBER := 0;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has recrods in it before passing
      IF (p_tbcv_tbl.COUNT > 0) THEN
        i := p_tbcv_tbl.FIRST;
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
              p_tbcv_rec                     => p_tbcv_tbl(i));
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
          EXIT WHEN (i = p_tbcv_tbl.LAST);
          i := p_tbcv_tbl.NEXT(i);
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
    -- PL/SQL TBL lock_row for:TBCV_TBL --
    --------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_tbl                     IN tbcv_tbl_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has recrods in it before passing
      IF (p_tbcv_tbl.COUNT > 0) THEN
        lock_row(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tbcv_tbl                     => p_tbcv_tbl,
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
    -- update_row for:OKL_TAX_ATTR_DEFINITIONS --
    ------------------------------------------
    PROCEDURE update_row(
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbc_rec                      IN tbc_rec_type,
      x_tbc_rec                      OUT NOCOPY tbc_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_tbc_rec                      tbc_rec_type := p_tbc_rec;
      l_def_tbc_rec                  tbc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_tbc_rec IN tbc_rec_type,
        x_tbc_rec OUT NOCOPY tbc_rec_type
      ) RETURN VARCHAR2 IS
        l_tbc_rec                      tbc_rec_type;
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_tbc_rec := p_tbc_rec;
        -- Get current database values
        l_tbc_rec := get_rec(p_tbc_rec, l_return_status);
        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          /*IF (x_tbc_rec.id = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.id := l_tbc_rec.id;
          END IF;
          IF (x_tbc_rec.org_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.org_id := l_tbc_rec.org_id;
          END IF; */

          -- modified by dcshanmu for eBTax project - modification start
          -- modified tbc_code to result_code
          IF (x_tbc_rec.result_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.result_code := l_tbc_rec.result_code;
          END IF;
          -- modified by dcshanmu for eBTax project - modification end

          IF (x_tbc_rec.purchase_option_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.purchase_option_code := l_tbc_rec.purchase_option_code;
          END IF;
          IF (x_tbc_rec.pdt_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.pdt_id := l_tbc_rec.pdt_id;
          END IF;
          IF (x_tbc_rec.try_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.try_id := l_tbc_rec.try_id;
          END IF;
          IF (x_tbc_rec.sty_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.sty_id := l_tbc_rec.sty_id;
          END IF;
          IF (x_tbc_rec.int_disclosed_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.int_disclosed_code := l_tbc_rec.int_disclosed_code;
          END IF;
          IF (x_tbc_rec.title_trnsfr_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.title_trnsfr_code := l_tbc_rec.title_trnsfr_code;
          END IF;
          IF (x_tbc_rec.sale_lease_back_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.sale_lease_back_code := l_tbc_rec.sale_lease_back_code;
          END IF;
          IF (x_tbc_rec.lease_purchased_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.lease_purchased_code := l_tbc_rec.lease_purchased_code;
          END IF;
          IF (x_tbc_rec.equip_usage_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.equip_usage_code := l_tbc_rec.equip_usage_code;
          END IF;
          IF (x_tbc_rec.vendor_site_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.vendor_site_id := l_tbc_rec.vendor_site_id;
          END IF;
          IF (x_tbc_rec.age_of_equip_from = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.age_of_equip_from := l_tbc_rec.age_of_equip_from;
          END IF;

          IF (x_tbc_rec.age_of_equip_to = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.age_of_equip_to := l_tbc_rec.age_of_equip_to;
          END IF;

          IF (x_tbc_rec.object_version_number = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.object_version_number := l_tbc_rec.object_version_number;
          END IF;
          IF (x_tbc_rec.attribute_category = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute_category := l_tbc_rec.attribute_category;
          END IF;
          IF (x_tbc_rec.attribute1 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute1 := l_tbc_rec.attribute1;
          END IF;
          IF (x_tbc_rec.attribute2 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute2 := l_tbc_rec.attribute2;
          END IF;
          IF (x_tbc_rec.attribute3 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute3 := l_tbc_rec.attribute3;
          END IF;
          IF (x_tbc_rec.attribute4 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute4 := l_tbc_rec.attribute4;
          END IF;
          IF (x_tbc_rec.attribute5 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute5 := l_tbc_rec.attribute5;
          END IF;
          IF (x_tbc_rec.attribute6 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute6 := l_tbc_rec.attribute6;
          END IF;
          IF (x_tbc_rec.attribute7 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute7 := l_tbc_rec.attribute7;
          END IF;
          IF (x_tbc_rec.attribute8 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute8 := l_tbc_rec.attribute8;
          END IF;
          IF (x_tbc_rec.attribute9 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute9 := l_tbc_rec.attribute9;
          END IF;
          IF (x_tbc_rec.attribute10 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute10 := l_tbc_rec.attribute10;
          END IF;
          IF (x_tbc_rec.attribute11 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute11 := l_tbc_rec.attribute11;
          END IF;
          IF (x_tbc_rec.attribute12 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute12 := l_tbc_rec.attribute12;
          END IF;
          IF (x_tbc_rec.attribute13 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute13 := l_tbc_rec.attribute13;
          END IF;
          IF (x_tbc_rec.attribute14 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute14 := l_tbc_rec.attribute14;
          END IF;
          IF (x_tbc_rec.attribute15 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.attribute15 := l_tbc_rec.attribute15;
          END IF;
          IF (x_tbc_rec.created_by = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.created_by := l_tbc_rec.created_by;
          END IF;
          IF (x_tbc_rec.creation_date = OKL_API.G_MISS_DATE)
          THEN
            x_tbc_rec.creation_date := l_tbc_rec.creation_date;
          END IF;
          IF (x_tbc_rec.last_updated_by = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.last_updated_by := l_tbc_rec.last_updated_by;
          END IF;
          IF (x_tbc_rec.last_update_date = OKL_API.G_MISS_DATE)
          THEN
            x_tbc_rec.last_update_date := l_tbc_rec.last_update_date;
          END IF;
          IF (x_tbc_rec.last_update_login = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.last_update_login := l_tbc_rec.last_update_login;
          END IF;

          -- modified by dcshanmu for eBTax project - modification start
          -- added migration code for newly added columns

          IF (x_tbc_rec.tax_attribute_def_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbc_rec.tax_attribute_def_id := l_tbc_rec.tax_attribute_def_id;
          END IF;
          IF (x_tbc_rec.result_type_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.result_type_code := l_tbc_rec.result_type_code;
          END IF;
          IF (x_tbc_rec.book_class_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.book_class_code := l_tbc_rec.book_class_code;
          END IF;
          IF (x_tbc_rec.date_effective_from = OKL_API.G_MISS_DATE)
          THEN
            x_tbc_rec.date_effective_from := l_tbc_rec.date_effective_from;
          END IF;
          IF (x_tbc_rec.date_effective_to = OKL_API.G_MISS_DATE)
          THEN
            x_tbc_rec.date_effective_to := l_tbc_rec.date_effective_to;
          END IF;
          IF (x_tbc_rec.tax_country_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.tax_country_code := l_tbc_rec.tax_country_code;
          END IF;
          IF (x_tbc_rec.term_quote_type_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.term_quote_type_code := l_tbc_rec.term_quote_type_code;
          END IF;
          IF (x_tbc_rec.term_quote_reason_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.term_quote_reason_code := l_tbc_rec.term_quote_reason_code;
          END IF;
          IF (x_tbc_rec.expire_flag = OKL_API.G_MISS_CHAR)
          THEN
            x_tbc_rec.expire_flag := l_tbc_rec.expire_flag;
          END IF;

          -- modified by dcshanmu for eBTax project - modification end

        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      ----------------------------------------------
      -- Set_Attributes for:OKL_TAX_ATTR_DEFINITIONS --
      ----------------------------------------------
      FUNCTION Set_Attributes (
        p_tbc_rec IN tbc_rec_type,
        x_tbc_rec OUT NOCOPY tbc_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_tbc_rec := p_tbc_rec;
        x_tbc_rec.OBJECT_VERSION_NUMBER := p_tbc_rec.OBJECT_VERSION_NUMBER + 1;
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
        p_tbc_rec,                         -- IN
        l_tbc_rec);                        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_tbc_rec, l_def_tbc_rec);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      UPDATE OKL_TAX_ATTR_DEFINITIONS
      SET --ORG_ID = l_def_tbc_rec.org_id,
          RESULT_CODE = l_def_tbc_rec.result_code,
          PURCHASE_OPTION_CODE = l_def_tbc_rec.purchase_option_code,
          PDT_ID = l_def_tbc_rec.pdt_id,
          TRY_ID = l_def_tbc_rec.try_id,
          STY_ID = l_def_tbc_rec.sty_id,
          INT_DISCLOSED_CODE = l_def_tbc_rec.int_disclosed_code,
          TITLE_TRNSFR_CODE = l_def_tbc_rec.title_trnsfr_code,
          SALE_LEASE_BACK_CODE = l_def_tbc_rec.sale_lease_back_code,
          LEASE_PURCHASED_CODE = l_def_tbc_rec.lease_purchased_code,
          EQUIP_USAGE_CODE = l_def_tbc_rec.equip_usage_code,
          VENDOR_SITE_ID = l_def_tbc_rec.vendor_site_id,
          AGE_OF_EQUIP_FROM = l_def_tbc_rec.age_of_equip_from,
          AGE_OF_EQUIP_TO = l_def_tbc_rec.age_of_equip_to,
          OBJECT_VERSION_NUMBER = l_def_tbc_rec.object_version_number,
          ATTRIBUTE_CATEGORY = l_def_tbc_rec.attribute_category,
          ATTRIBUTE1 = l_def_tbc_rec.attribute1,
          ATTRIBUTE2 = l_def_tbc_rec.attribute2,
          ATTRIBUTE3 = l_def_tbc_rec.attribute3,
          ATTRIBUTE4 = l_def_tbc_rec.attribute4,
          ATTRIBUTE5 = l_def_tbc_rec.attribute5,
          ATTRIBUTE6 = l_def_tbc_rec.attribute6,
          ATTRIBUTE7 = l_def_tbc_rec.attribute7,
          ATTRIBUTE8 = l_def_tbc_rec.attribute8,
          ATTRIBUTE9 = l_def_tbc_rec.attribute9,
          ATTRIBUTE10 = l_def_tbc_rec.attribute10,
          ATTRIBUTE11 = l_def_tbc_rec.attribute11,
          ATTRIBUTE12 = l_def_tbc_rec.attribute12,
          ATTRIBUTE13 = l_def_tbc_rec.attribute13,
          ATTRIBUTE14 = l_def_tbc_rec.attribute14,
          ATTRIBUTE15 = l_def_tbc_rec.attribute15,
          CREATED_BY = l_def_tbc_rec.created_by,
          CREATION_DATE = l_def_tbc_rec.creation_date,
          LAST_UPDATED_BY = l_def_tbc_rec.last_updated_by,
          LAST_UPDATE_DATE = l_def_tbc_rec.last_update_date,
          LAST_UPDATE_LOGIN = l_def_tbc_rec.last_update_login,

          -- modified by dcshanmu for eBTax project - modification start
          TAX_ATTRIBUTE_DEF_ID = l_def_tbc_rec.tax_attribute_def_id,
          RESULT_TYPE_CODE = l_def_tbc_rec.result_type_code,
          BOOK_CLASS_CODE = l_def_tbc_rec.book_class_code,
          DATE_EFFECTIVE_FROM = l_def_tbc_rec.date_effective_from,
          DATE_EFFECTIVE_TO = l_def_tbc_rec.date_effective_to,
          TAX_COUNTRY_CODE = l_def_tbc_rec.tax_country_code,
          TERM_QUOTE_TYPE_CODE = l_def_tbc_rec.term_quote_type_code,
          TERM_QUOTE_REASON_CODE = l_def_tbc_rec.term_quote_reason_code,
          EXPIRE_FLAG = l_def_tbc_rec.expire_flag
          -- modified by dcshanmu for eBTax project - modification end
--      WHERE ID = l_def_tbc_rec.id;
        WHERE tax_attribute_def_id = l_def_tbc_rec.tax_attribute_def_id;

      x_tbc_rec := l_tbc_rec;
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
    -- update_row for:OKL_TAX_ATTR_DEFINITIONS --
    ------------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_rec                     IN tbcv_rec_type,
      x_tbcv_rec                     OUT NOCOPY tbcv_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_tbcv_rec                     tbcv_rec_type := p_tbcv_rec;
      l_def_tbcv_rec                 tbcv_rec_type;
      l_db_tbcv_rec                  tbcv_rec_type;
      l_tbc_rec                      tbc_rec_type;
      lx_tbc_rec                     tbc_rec_type;
      -------------------------------
      -- FUNCTION fill_who_columns --
      -------------------------------
      FUNCTION fill_who_columns (
        p_tbcv_rec IN tbcv_rec_type
      ) RETURN tbcv_rec_type IS
        l_tbcv_rec tbcv_rec_type := p_tbcv_rec;
      BEGIN
        l_tbcv_rec.LAST_UPDATE_DATE := SYSDATE;
        l_tbcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_tbcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_tbcv_rec);
      END fill_who_columns;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_tbcv_rec IN tbcv_rec_type,
        x_tbcv_rec OUT NOCOPY tbcv_rec_type
      ) RETURN VARCHAR2 IS
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_tbcv_rec := p_tbcv_rec;

        -- Get current database values
        -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
        --       so it may be verified through LOCK_ROW.
        l_db_tbcv_rec := get_rec(p_tbcv_rec, l_return_status);

        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
         /* IF (x_tbcv_rec.id = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.id := l_db_tbcv_rec.id;
          END IF;
          IF (x_tbcv_rec.org_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.org_id := l_db_tbcv_rec.org_id;
          END IF;  */

          -- modified by dcshanmu for eBTax project - modification start
          IF (x_tbcv_rec.result_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.result_code := l_db_tbcv_rec.result_code;
          END IF;
          -- modified by dcshanmu for eBTax project - modification end

          --SECHAWLA : Added code to set Object Version No. because of the locking issue
          IF (x_tbcv_rec.object_version_number = OKL_API.G_MISS_NUM)
          THEN
              x_tbcv_rec.object_version_number := l_db_tbcv_rec.object_version_number;
          END IF;


          IF (x_tbcv_rec.purchase_option_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.purchase_option_code := l_db_tbcv_rec.purchase_option_code;
          END IF;
          IF (x_tbcv_rec.pdt_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.pdt_id := l_db_tbcv_rec.pdt_id;
          END IF;
          IF (x_tbcv_rec.try_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.try_id := l_db_tbcv_rec.try_id;
          END IF;
          IF (x_tbcv_rec.sty_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.sty_id := l_db_tbcv_rec.sty_id;
          END IF;
          IF (x_tbcv_rec.int_disclosed_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.int_disclosed_code := l_db_tbcv_rec.int_disclosed_code;
          END IF;
          IF (x_tbcv_rec.title_trnsfr_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.title_trnsfr_code := l_db_tbcv_rec.title_trnsfr_code;
          END IF;
          IF (x_tbcv_rec.sale_lease_back_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.sale_lease_back_code := l_db_tbcv_rec.sale_lease_back_code;
          END IF;
          IF (x_tbcv_rec.lease_purchased_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.lease_purchased_code := l_db_tbcv_rec.lease_purchased_code;
          END IF;
          IF (x_tbcv_rec.equip_usage_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.equip_usage_code := l_db_tbcv_rec.equip_usage_code;
          END IF;
          IF (x_tbcv_rec.vendor_site_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.vendor_site_id := l_db_tbcv_rec.vendor_site_id;
          END IF;
          IF (x_tbcv_rec.age_of_equip_from = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.age_of_equip_from := l_db_tbcv_rec.age_of_equip_from;
          END IF;
          IF (x_tbcv_rec.age_of_equip_to = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.age_of_equip_to := l_db_tbcv_rec.age_of_equip_to;
          END IF;

          IF (x_tbcv_rec.attribute_category = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute_category := l_db_tbcv_rec.attribute_category;
          END IF;
          IF (x_tbcv_rec.attribute1 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute1 := l_db_tbcv_rec.attribute1;
          END IF;
          IF (x_tbcv_rec.attribute2 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute2 := l_db_tbcv_rec.attribute2;
          END IF;
          IF (x_tbcv_rec.attribute3 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute3 := l_db_tbcv_rec.attribute3;
          END IF;
          IF (x_tbcv_rec.attribute4 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute4 := l_db_tbcv_rec.attribute4;
          END IF;
          IF (x_tbcv_rec.attribute5 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute5 := l_db_tbcv_rec.attribute5;
          END IF;
          IF (x_tbcv_rec.attribute6 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute6 := l_db_tbcv_rec.attribute6;
          END IF;
          IF (x_tbcv_rec.attribute7 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute7 := l_db_tbcv_rec.attribute7;
          END IF;
          IF (x_tbcv_rec.attribute8 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute8 := l_db_tbcv_rec.attribute8;
          END IF;
          IF (x_tbcv_rec.attribute9 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute9 := l_db_tbcv_rec.attribute9;
          END IF;
          IF (x_tbcv_rec.attribute10 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute10 := l_db_tbcv_rec.attribute10;
          END IF;
          IF (x_tbcv_rec.attribute11 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute11 := l_db_tbcv_rec.attribute11;
          END IF;
          IF (x_tbcv_rec.attribute12 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute12 := l_db_tbcv_rec.attribute12;
          END IF;
          IF (x_tbcv_rec.attribute13 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute13 := l_db_tbcv_rec.attribute13;
          END IF;
          IF (x_tbcv_rec.attribute14 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute14 := l_db_tbcv_rec.attribute14;
          END IF;
          IF (x_tbcv_rec.attribute15 = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.attribute15 := l_db_tbcv_rec.attribute15;
          END IF;
          IF (x_tbcv_rec.created_by = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.created_by := l_db_tbcv_rec.created_by;
          END IF;
          IF (x_tbcv_rec.creation_date = OKL_API.G_MISS_DATE)
          THEN
            x_tbcv_rec.creation_date := l_db_tbcv_rec.creation_date;
          END IF;
          IF (x_tbcv_rec.last_updated_by = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.last_updated_by := l_db_tbcv_rec.last_updated_by;
          END IF;
          IF (x_tbcv_rec.last_update_date = OKL_API.G_MISS_DATE)
          THEN
            x_tbcv_rec.last_update_date := l_db_tbcv_rec.last_update_date;
          END IF;
          IF (x_tbcv_rec.last_update_login = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.last_update_login := l_db_tbcv_rec.last_update_login;
          END IF;

          -- modified by dcshanmu for eBTax project - modification start
          IF (x_tbcv_rec.tax_attribute_def_id = OKL_API.G_MISS_NUM)
          THEN
            x_tbcv_rec.tax_attribute_def_id := l_db_tbcv_rec.tax_attribute_def_id;
          END IF;
          IF (x_tbcv_rec.result_type_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.result_type_code := l_db_tbcv_rec.result_type_code;
          END IF;
          IF (x_tbcv_rec.book_class_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.book_class_code := l_db_tbcv_rec.book_class_code;
          END IF;
          IF (x_tbcv_rec.date_effective_from = OKL_API.G_MISS_DATE)
          THEN
            x_tbcv_rec.date_effective_from := l_tbcv_rec.date_effective_from;
          END IF;
          IF (x_tbcv_rec.date_effective_to = OKL_API.G_MISS_DATE)
          THEN
            x_tbcv_rec.date_effective_to := l_db_tbcv_rec.date_effective_to;
          END IF;
          IF (x_tbcv_rec.tax_country_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.tax_country_code := l_db_tbcv_rec.tax_country_code;
          END IF;
          IF (x_tbcv_rec.term_quote_type_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.term_quote_type_code := l_db_tbcv_rec.term_quote_type_code;
          END IF;
          IF (x_tbcv_rec.term_quote_reason_code = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.term_quote_reason_code := l_db_tbcv_rec.term_quote_reason_code;
          END IF;
          IF (x_tbcv_rec.expire_flag = OKL_API.G_MISS_CHAR)
          THEN
            x_tbcv_rec.expire_flag := l_db_tbcv_rec.expire_flag;
          END IF;
          -- modified by dcshanmu for eBTax project - modification end

        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      ----------------------------------------------
      -- Set_Attributes for:OKL_TAX_ATTR_DEFINITIONS --
      ----------------------------------------------
      FUNCTION Set_Attributes (
        p_tbcv_rec IN tbcv_rec_type,
        x_tbcv_rec OUT NOCOPY tbcv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      BEGIN
        x_tbcv_rec := p_tbcv_rec;
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
        p_tbcv_rec,                        -- IN
        x_tbcv_rec);                       -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_return_status := populate_new_record(x_tbcv_rec, l_def_tbcv_rec);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_def_tbcv_rec := fill_who_columns(l_def_tbcv_rec);
      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_def_tbcv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      /*
      l_return_status := Validate_Record(l_def_tbcv_rec, l_db_tbcv_rec);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
     */

      l_return_status := Validate_Record(l_def_tbcv_rec);
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
        p_tbcv_rec                     => l_def_tbcv_rec); --p_tbcv_rec); -- SECHAWLA Changed to pass l_def_tbov_rec becoz of locking issue
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -----------------------------------------
      -- Move VIEW record to "Child" records --
      -----------------------------------------
      migrate(l_def_tbcv_rec, l_tbc_rec);

      -----------------------------------------------
      -- Call the UPDATE_ROW for each child record --
      -----------------------------------------------
      update_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_tbc_rec,
        lx_tbc_rec
      );

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_tbc_rec, l_def_tbcv_rec);
      x_tbcv_rec := l_def_tbcv_rec;
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
    -- PL/SQL TBL update_row for:tbcv_tbl --
    ----------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_tbl                     IN tbcv_tbl_type,
      x_tbcv_tbl                     OUT NOCOPY tbcv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(100) := 'v_err';
      i                              NUMBER := 0;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
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

      -- Make sure PL/SQL table has records in it before passing
      IF (p_tbcv_tbl.COUNT > 0) THEN
        i := p_tbcv_tbl.FIRST;
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
              p_tbcv_rec                     => p_tbcv_tbl(i),
              x_tbcv_rec                     => x_tbcv_tbl(i));
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
          EXIT WHEN (i = p_tbcv_tbl.LAST);
          i := p_tbcv_tbl.NEXT(i);
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
    -- PL/SQL TBL update_row for:TBCV_TBL --
    ----------------------------------------
    -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
    -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_tbl                     IN tbcv_tbl_type,
      x_tbcv_tbl                     OUT NOCOPY tbcv_tbl_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
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
      -- Make sure PL/SQL table has records in it before passing
      IF (p_tbcv_tbl.COUNT > 0) THEN
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tbcv_tbl                     => p_tbcv_tbl,
          x_tbcv_tbl                     => x_tbcv_tbl,
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
    -- delete_row for:OKL_TAX_ATTR_DEFINITIONS--
    ------------------------------------------
    PROCEDURE delete_row(
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbc_rec                      IN tbc_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_tbc_rec                      tbc_rec_type := p_tbc_rec;
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

      DELETE FROM OKL_TAX_ATTR_DEFINITIONS
--       WHERE ID = p_tbc_rec.id;
         WHERE tax_attribute_def_id = p_tbc_rec.tax_attribute_def_id;

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
    -- delete_row for:OKL_TAX_ATTR_DEFINITIONS --
    ------------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_rec                     IN tbcv_rec_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_tbcv_rec                     tbcv_rec_type := p_tbcv_rec;
      l_tbc_rec                      tbc_rec_type;
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
      migrate(l_tbcv_rec, l_tbc_rec);
      -----------------------------------------------
      -- Call the DELETE_ROW for each child record --
      -----------------------------------------------
      delete_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_tbc_rec
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
    -- PL/SQL TBL delete_row for:OKL_TAX_ATTR_DEFINITIONS --
    -----------------------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_tbl                     IN tbcv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
      i                              NUMBER := 0;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_tbcv_tbl.COUNT > 0) THEN
        i := p_tbcv_tbl.FIRST;
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
              p_tbcv_rec                     => p_tbcv_tbl(i));
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
          EXIT WHEN (i = p_tbcv_tbl.LAST);
          i := p_tbcv_tbl.NEXT(i);
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
    -- PL/SQL TBL delete_row for:OKL_TAX_ATTR_DEFINITIONS --
    -----------------------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_tbcv_tbl                     IN tbcv_tbl_type) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKL_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_tbcv_tbl.COUNT > 0) THEN
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tbcv_tbl                     => p_tbcv_tbl,
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

  END OKL_TBC_PVT;

/
