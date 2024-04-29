--------------------------------------------------------
--  DDL for Package Body OKL_LOP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LOP_PVT" AS
/* $Header: OKLSLOPB.pls 120.4.12010000.2 2008/11/13 13:39:15 kkorrapo ship $ */

  -------------------------
  -- PROCEDURE add_language
  -------------------------
  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_LEASE_OPPORTUNITIES_TL T
    WHERE NOT EXISTS (SELECT NULL FROM OKL_LEASE_OPPS_ALL_B B WHERE B.ID =T.ID);

    UPDATE OKL_LEASE_OPPORTUNITIES_TL T
    SET (SHORT_DESCRIPTION,
        DESCRIPTION,
        COMMENTS) =
                     (SELECT
                      B.SHORT_DESCRIPTION,
                      B.DESCRIPTION,
                      B.COMMENTS
                      FROM
                      OKL_LEASE_OPPORTUNITIES_TL B
                      WHERE
                      B.ID = T.ID
                      AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (T.ID, T.LANGUAGE) IN (SELECT
                                 SUBT.ID,
                                 SUBT.LANGUAGE
                                 FROM
                                 OKL_LEASE_OPPORTUNITIES_TL SUBB,
                                 OKL_LEASE_OPPORTUNITIES_TL SUBT
                                 WHERE
                                 SUBB.ID = SUBT.ID
                                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                                 AND (SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                                      OR (SUBB.DESCRIPTION <> SUBT.DESCRIPTION)
                                      OR (SUBB.COMMENTS <> SUBT.COMMENTS)
                                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                                     )
                                );

    INSERT INTO OKL_LEASE_OPPORTUNITIES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SHORT_DESCRIPTION,
        DESCRIPTION,
        COMMENTS)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN,
            B.SHORT_DESCRIPTION,
            B.DESCRIPTION,
            B.COMMENTS
        FROM OKL_LEASE_OPPORTUNITIES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_LEASE_OPPORTUNITIES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;


  -----------------------------
  -- FUNCTION null_out_defaults
  -----------------------------
  FUNCTION null_out_defaults (p_lopv_rec IN lopv_rec_type) RETURN lopv_rec_type IS

    l_lopv_rec  lopv_rec_type;

  BEGIN

    l_lopv_rec := p_lopv_rec;

    -- Not applicable to ID and OBJECT_VERSION_NUMBER

    IF l_lopv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute_category := NULL;
    END IF;
    IF l_lopv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute1 := NULL;
    END IF;
    IF l_lopv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute2 := NULL;
    END IF;
    IF l_lopv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute3 := NULL;
    END IF;
    IF l_lopv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute4 := NULL;
    END IF;
    IF l_lopv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute5 := NULL;
    END IF;
    IF l_lopv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute6 := NULL;
    END IF;
    IF l_lopv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute7 := NULL;
    END IF;
    IF l_lopv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute8 := NULL;
    END IF;
    IF l_lopv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute9 := NULL;
    END IF;
    IF l_lopv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute10 := NULL;
    END IF;
    IF l_lopv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute11 := NULL;
    END IF;
    IF l_lopv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute12 := NULL;
    END IF;
    IF l_lopv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute13 := NULL;
    END IF;
    IF l_lopv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute14 := NULL;
    END IF;
    IF l_lopv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.attribute15 := NULL;
    END IF;
    IF l_lopv_rec.reference_number = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.reference_number := NULL;
    END IF;
    IF l_lopv_rec.status = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.status := NULL;
    END IF;
    IF l_lopv_rec.valid_from = FND_API.G_MISS_DATE THEN
      l_lopv_rec.valid_from := NULL;
    END IF;
    IF l_lopv_rec.expected_start_date = FND_API.G_MISS_DATE THEN
      l_lopv_rec.expected_start_date := NULL;
    END IF;
    IF l_lopv_rec.org_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.org_id := NULL;
    END IF;
    IF l_lopv_rec.inv_org_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.inv_org_id := NULL;
    END IF;
    IF l_lopv_rec.prospect_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.prospect_id := NULL;
    END IF;
    IF l_lopv_rec.prospect_address_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.prospect_address_id := NULL;
    END IF;
    IF l_lopv_rec.cust_acct_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.cust_acct_id := NULL;
    END IF;
    IF l_lopv_rec.currency_code = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.currency_code := NULL;
    END IF;
    IF l_lopv_rec.currency_conversion_type = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.currency_conversion_type := NULL;
    END IF;
    IF l_lopv_rec.currency_conversion_rate = FND_API.G_MISS_NUM THEN
      l_lopv_rec.currency_conversion_rate := NULL;
    END IF;
    IF l_lopv_rec.currency_conversion_date = FND_API.G_MISS_DATE THEN
      l_lopv_rec.currency_conversion_date := NULL;
    END IF;
    IF l_lopv_rec.program_agreement_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.program_agreement_id := NULL;
    END IF;
    IF l_lopv_rec.master_lease_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.master_lease_id := NULL;
    END IF;
    IF l_lopv_rec.sales_rep_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.sales_rep_id := NULL;
    END IF;
    IF l_lopv_rec.sales_territory_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.sales_territory_id := NULL;
    END IF;
    IF l_lopv_rec.supplier_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.supplier_id := NULL;
    END IF;
    IF l_lopv_rec.delivery_date = FND_API.G_MISS_DATE THEN
      l_lopv_rec.delivery_date := NULL;
    END IF;
    IF l_lopv_rec.funding_date = FND_API.G_MISS_DATE THEN
      l_lopv_rec.funding_date := NULL;
    END IF;
    IF l_lopv_rec.property_tax_applicable = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.property_tax_applicable := NULL;
    END IF;
    IF l_lopv_rec.property_tax_billing_type = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.property_tax_billing_type := NULL;
    END IF;
    IF l_lopv_rec.upfront_tax_treatment = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.upfront_tax_treatment := NULL;
    END IF;
    IF l_lopv_rec.install_site_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.install_site_id := NULL;
    END IF;
    IF l_lopv_rec.usage_category = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.usage_category := NULL;
    END IF;
    IF l_lopv_rec.usage_industry_class = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.usage_industry_class := NULL;
    END IF;
    IF l_lopv_rec.usage_industry_code = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.usage_industry_code := NULL;
    END IF;
    IF l_lopv_rec.usage_amount = FND_API.G_MISS_NUM THEN
      l_lopv_rec.usage_amount := NULL;
    END IF;
    IF l_lopv_rec.usage_location_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.usage_location_id := NULL;
    END IF;
    IF l_lopv_rec.originating_vendor_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.originating_vendor_id := NULL;
    END IF;
    --Bug # 5647107
    IF l_lopv_rec.legal_entity_id = FND_API.G_MISS_NUM THEN
      l_lopv_rec.legal_entity_id := NULL;
    END IF;
    --Bug # 5647107
    -- Bug 5908845. eBTax Enhancement Project
    IF l_lopv_rec.line_intended_use = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.line_intended_use := NULL;
    END IF;
    -- End Bug 5908845. eBTax Enhancement Project
    IF l_lopv_rec.short_description = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.short_description := NULL;
    END IF;
    IF l_lopv_rec.description = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.description := NULL;
    END IF;
    IF l_lopv_rec.comments = FND_API.G_MISS_CHAR THEN
      l_lopv_rec.comments := NULL;
    END IF;

    RETURN l_lopv_rec;

  END null_out_defaults;


  -------------------
  -- FUNCTION get_rec
  -------------------
  FUNCTION get_rec (p_id             IN         NUMBER
                    ,x_return_status OUT NOCOPY VARCHAR2) RETURN lopv_rec_type IS

    l_lopv_rec           lopv_rec_type;

    l_prog_name          VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.get_rec';

    SELECT
      id
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,reference_number
      ,status
      ,valid_from
      ,expected_start_date
      ,org_id
      ,inv_org_id
      ,prospect_id
      ,prospect_address_id
      ,cust_acct_id
      ,currency_code
      ,currency_conversion_type
      ,currency_conversion_rate
      ,currency_conversion_date
      ,program_agreement_id
      ,master_lease_id
      ,sales_rep_id
      ,sales_territory_id
      ,supplier_id
      ,delivery_date
      ,funding_date
      ,property_tax_applicable
      ,property_tax_billing_type
      ,upfront_tax_treatment
      ,install_site_id
      ,usage_category
      ,usage_industry_class
      ,usage_industry_code
      ,usage_amount
      ,usage_location_id
      ,originating_vendor_id
      ,legal_entity_id
      -- Bug 5908845. eBTax Enhancement Project
      ,line_intended_use
      -- End Bug 5908845. eBTax Enhancement Project
      ,short_description
      ,description
      ,comments
    INTO
      l_lopv_rec.id
      ,l_lopv_rec.object_version_number
      ,l_lopv_rec.attribute_category
      ,l_lopv_rec.attribute1
      ,l_lopv_rec.attribute2
      ,l_lopv_rec.attribute3
      ,l_lopv_rec.attribute4
      ,l_lopv_rec.attribute5
      ,l_lopv_rec.attribute6
      ,l_lopv_rec.attribute7
      ,l_lopv_rec.attribute8
      ,l_lopv_rec.attribute9
      ,l_lopv_rec.attribute10
      ,l_lopv_rec.attribute11
      ,l_lopv_rec.attribute12
      ,l_lopv_rec.attribute13
      ,l_lopv_rec.attribute14
      ,l_lopv_rec.attribute15
      ,l_lopv_rec.reference_number
      ,l_lopv_rec.status
      ,l_lopv_rec.valid_from
      ,l_lopv_rec.expected_start_date
      ,l_lopv_rec.org_id
      ,l_lopv_rec.inv_org_id
      ,l_lopv_rec.prospect_id
      ,l_lopv_rec.prospect_address_id
      ,l_lopv_rec.cust_acct_id
      ,l_lopv_rec.currency_code
      ,l_lopv_rec.currency_conversion_type
      ,l_lopv_rec.currency_conversion_rate
      ,l_lopv_rec.currency_conversion_date
      ,l_lopv_rec.program_agreement_id
      ,l_lopv_rec.master_lease_id
      ,l_lopv_rec.sales_rep_id
      ,l_lopv_rec.sales_territory_id
      ,l_lopv_rec.supplier_id
      ,l_lopv_rec.delivery_date
      ,l_lopv_rec.funding_date
      ,l_lopv_rec.property_tax_applicable
      ,l_lopv_rec.property_tax_billing_type
      ,l_lopv_rec.upfront_tax_treatment
      ,l_lopv_rec.install_site_id
      ,l_lopv_rec.usage_category
      ,l_lopv_rec.usage_industry_class
      ,l_lopv_rec.usage_industry_code
      ,l_lopv_rec.usage_amount
      ,l_lopv_rec.usage_location_id
      ,l_lopv_rec.originating_vendor_id
      ,l_lopv_rec.legal_entity_id
      -- Bug 5908845. eBTax Enhancement Project
      ,l_lopv_rec.line_intended_use
      -- End Bug 5908845. eBTax Enhancement Project
      ,l_lopv_rec.short_description
      ,l_lopv_rec.description
      ,l_lopv_rec.comments
    FROM OKL_LEASE_OPPORTUNITIES_V
    WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_lopv_rec;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_rec;


  ------------------------
  -- PROCEDURE validate_id
  ------------------------
  PROCEDURE validate_id (x_return_status OUT NOCOPY VARCHAR2, p_id IN NUMBER) IS
  BEGIN
    IF p_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_id;


  -------------------------------------------
  -- PROCEDURE validate_object_version_number
  -------------------------------------------
  PROCEDURE validate_object_version_number (x_return_status OUT NOCOPY VARCHAR2, p_object_version_number IN NUMBER) IS
  BEGIN
    IF p_object_version_number IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'object_version_number',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_object_version_number;

  --------------------------------------
  -- PROCEDURE validate_reference_number
  --------------------------------------
  PROCEDURE validate_reference_number (x_return_status OUT NOCOPY VARCHAR2, p_reference_number IN VARCHAR2) IS
  BEGIN

    IF p_reference_number IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'reference_number',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;
  END validate_reference_number;


  -----------------------------------------
  -- PROCEDURE validate_status
  -----------------------------------------
  PROCEDURE validate_status (x_return_status OUT NOCOPY VARCHAR2, p_status IN VARCHAR2) IS
  BEGIN

    IF p_status IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'status',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;
  END validate_status;

  -----------------------------------------
  -- PROCEDURE validate_valid_from
  -----------------------------------------
  PROCEDURE validate_valid_from (x_return_status OUT NOCOPY VARCHAR2, p_valid_from IN DATE) IS
  BEGIN
    IF p_valid_from IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'valid_from',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_valid_from;

  -----------------------------------------
  -- PROCEDURE validate_expected_start_date
  -----------------------------------------
  PROCEDURE validate_expected_start_date (x_return_status OUT NOCOPY VARCHAR2, p_expected_start_date IN DATE) IS
  BEGIN
    IF p_expected_start_date IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'expected_start_date',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_expected_start_date;


  ----------------------------
  -- PROCEDURE validate_org_id
  ----------------------------
  PROCEDURE validate_org_id (x_return_status OUT NOCOPY VARCHAR2, p_org_id IN NUMBER) IS
  BEGIN
    IF p_org_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'org_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_org_id;


  --------------------------------
  -- PROCEDURE validate_inv_org_id
  --------------------------------
  PROCEDURE validate_inv_org_id (x_return_status OUT NOCOPY VARCHAR2, p_inv_org_id IN NUMBER) IS
  BEGIN
    IF p_inv_org_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'inv_org_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_inv_org_id;


  ---------------------------------
  -- PROCEDURE validate_prospect_id
  ---------------------------------
  PROCEDURE validate_prospect_id (x_return_status OUT NOCOPY VARCHAR2, p_prospect_id IN NUMBER) IS
  BEGIN
    IF p_prospect_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'prospect_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_prospect_id;


  -----------------------------------------
  -- PROCEDURE validate_prospect_address_id
  -----------------------------------------
  PROCEDURE validate_prospect_address_id (x_return_status OUT NOCOPY VARCHAR2, p_prospect_address_id IN NUMBER) IS
  BEGIN
    IF p_prospect_address_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'prospect_address_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_prospect_address_id;


  -----------------------------------------
  -- PROCEDURE validate_currency_code
  -----------------------------------------
  PROCEDURE validate_currency_code (x_return_status OUT NOCOPY VARCHAR2, p_currency_code IN VARCHAR2) IS
  BEGIN
    IF p_currency_code IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'currency_code',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_currency_code;
  --Added Bug # 5647107 ssdeshpa start
  -----------------------------------------
  -- PROCEDURE validate_legal_entity_id
  -----------------------------------------
  PROCEDURE validate_legal_entity_id (x_return_status OUT NOCOPY VARCHAR2, p_legal_entity_id IN NUMBER) IS
  l_return_val NUMBER(1);
  BEGIN
      l_return_val := NVL((OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_legal_entity_id)),0);
      IF (p_legal_entity_id IS NOT NULL AND l_return_val <> 1) THEN
        OKL_API.set_message(p_app_name      => G_APP_NAME,
                           p_msg_name      => G_COL_ERROR,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'legal_entity_id',
                           p_token2        => G_PKG_NAME_TOKEN,
                           p_token2_value  => G_PKG_NAME);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_legal_entity_id;

  --Added Bug # 5647107 ssdeshpa end
  -------------------------------
  -- FUNCTION validate_attributes
  -------------------------------
  FUNCTION validate_attributes (p_lopv_rec IN lopv_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);

  BEGIN

    validate_id (l_return_status, p_lopv_rec.id);
    validate_object_version_number (l_return_status, p_lopv_rec.object_version_number);
    validate_reference_number (l_return_status, p_lopv_rec.reference_number);
    validate_status (l_return_status, p_lopv_rec.status);
    validate_valid_from (l_return_status, p_lopv_rec.valid_from);
    validate_expected_start_date (l_return_status, p_lopv_rec.expected_start_date);
    validate_org_id (l_return_status, p_lopv_rec.org_id);
    validate_inv_org_id (l_return_status, p_lopv_rec.inv_org_id);
    validate_prospect_id (l_return_status, p_lopv_rec.prospect_id);
    validate_prospect_address_id (l_return_status, p_lopv_rec.prospect_address_id);
    validate_currency_code (l_return_status, p_lopv_rec.currency_code);
    validate_legal_entity_id(l_return_status, p_lopv_rec.legal_entity_id);
    RETURN l_return_status;

  END validate_attributes;

  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  FUNCTION validate_record (p_lopv_rec IN lopv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    RETURN G_RET_STS_SUCCESS;
  END validate_record;


  -----------------------------
  -- PROECDURE migrate (V -> B)
  -----------------------------
  PROCEDURE migrate (p_from IN lopv_rec_type, p_to IN OUT NOCOPY lop_rec_type) IS

  BEGIN

      p_to.id                             :=  p_from.id;
      p_to.object_version_number          :=  p_from.object_version_number;
      p_to.attribute_category             :=  p_from.attribute_category;
      p_to.attribute1                     :=  p_from.attribute1;
      p_to.attribute2                     :=  p_from.attribute2;
      p_to.attribute3                     :=  p_from.attribute3;
      p_to.attribute4                     :=  p_from.attribute4;
      p_to.attribute5                     :=  p_from.attribute5;
      p_to.attribute6                     :=  p_from.attribute6;
      p_to.attribute7                     :=  p_from.attribute7;
      p_to.attribute8                     :=  p_from.attribute8;
      p_to.attribute9                     :=  p_from.attribute9;
      p_to.attribute10                    :=  p_from.attribute10;
      p_to.attribute11                    :=  p_from.attribute11;
      p_to.attribute12                    :=  p_from.attribute12;
      p_to.attribute13                    :=  p_from.attribute13;
      p_to.attribute14                    :=  p_from.attribute14;
      p_to.attribute15                    :=  p_from.attribute15;
      p_to.reference_number               :=  p_from.reference_number;
      p_to.status                         :=  p_from.status;
      p_to.valid_from                     :=  p_from.valid_from;
      p_to.expected_start_date            :=  p_from.expected_start_date;
      p_to.org_id                         :=  p_from.org_id;
      p_to.inv_org_id                     :=  p_from.inv_org_id;
      p_to.prospect_id                    :=  p_from.prospect_id;
      p_to.prospect_address_id            :=  p_from.prospect_address_id;
      p_to.cust_acct_id                   :=  p_from.cust_acct_id;
      p_to.currency_code                  :=  p_from.currency_code;
      p_to.currency_conversion_type       :=  p_from.currency_conversion_type;
      p_to.currency_conversion_rate       :=  p_from.currency_conversion_rate;
      p_to.currency_conversion_date       :=  p_from.currency_conversion_date;
      p_to.program_agreement_id           :=  p_from.program_agreement_id;
      p_to.master_lease_id                :=  p_from.master_lease_id;
      p_to.sales_rep_id                   :=  p_from.sales_rep_id;
      p_to.sales_territory_id             :=  p_from.sales_territory_id;
      p_to.supplier_id                    :=  p_from.supplier_id;
      p_to.delivery_date                  :=  p_from.delivery_date;
      p_to.funding_date                   :=  p_from.funding_date;
      p_to.property_tax_applicable        :=  p_from.property_tax_applicable;
      p_to.property_tax_billing_type      :=  p_from.property_tax_billing_type;
      p_to.upfront_tax_treatment          :=  p_from.upfront_tax_treatment;
      p_to.install_site_id                :=  p_from.install_site_id;
      p_to.usage_category                 :=  p_from.usage_category;
      p_to.usage_industry_class           :=  p_from.usage_industry_class;
      p_to.usage_industry_code            :=  p_from.usage_industry_code;
      p_to.usage_amount                   :=  p_from.usage_amount;
      p_to.usage_location_id              :=  p_from.usage_location_id;
      p_to.originating_vendor_id          :=  p_from.originating_vendor_id;
      p_to.legal_entity_id                :=  p_from.legal_entity_id;
      -- Bug 5908845. eBTax Enhancement Project
      p_to.line_intended_use              :=  p_from.line_intended_use;
      -- End Bug 5908845. eBTax Enhancement Project
  END migrate;


  -----------------------------
  -- PROCEDURE migrate (V -> TL)
  -----------------------------
  PROCEDURE migrate (p_from IN lopv_rec_type, p_to IN OUT NOCOPY loptl_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.short_description := p_from.short_description;
    p_to.description := p_from.description;
    p_to.comments := p_from.comments;
  END migrate;


  ---------------------------
  -- PROCEDURE insert_row (B)
  ---------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_lop_rec IN lop_rec_type) IS

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (B)';

    INSERT INTO okl_lease_opportunities_b (
      id
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,reference_number
      ,status
      ,valid_from
      ,expected_start_date
      ,org_id
      ,inv_org_id
      ,prospect_id
      ,prospect_address_id
      ,cust_acct_id
      ,currency_code
      ,currency_conversion_type
      ,currency_conversion_rate
      ,currency_conversion_date
      ,program_agreement_id
      ,master_lease_id
      ,sales_rep_id
      ,sales_territory_id
      ,supplier_id
      ,delivery_date
      ,funding_date
      ,property_tax_applicable
      ,property_tax_billing_type
      ,upfront_tax_treatment
      ,install_site_id
      ,usage_category
      ,usage_industry_class
      ,usage_industry_code
      ,usage_amount
      ,usage_location_id
      ,originating_vendor_id
      ,legal_entity_id
      -- Bug 5908845. eBTax Enhancement Project
      ,line_intended_use
      -- End Bug 5908845. eBTax Enhancement Project
      )
    VALUES
      (
       p_lop_rec.id
      ,p_lop_rec.object_version_number
      ,p_lop_rec.attribute_category
      ,p_lop_rec.attribute1
      ,p_lop_rec.attribute2
      ,p_lop_rec.attribute3
      ,p_lop_rec.attribute4
      ,p_lop_rec.attribute5
      ,p_lop_rec.attribute6
      ,p_lop_rec.attribute7
      ,p_lop_rec.attribute8
      ,p_lop_rec.attribute9
      ,p_lop_rec.attribute10
      ,p_lop_rec.attribute11
      ,p_lop_rec.attribute12
      ,p_lop_rec.attribute13
      ,p_lop_rec.attribute14
      ,p_lop_rec.attribute15
      ,G_USER_ID
      ,SYSDATE
      ,G_USER_ID
      ,SYSDATE
      ,G_LOGIN_ID
      ,p_lop_rec.reference_number
      ,p_lop_rec.status
      ,p_lop_rec.valid_from
      ,p_lop_rec.expected_start_date
      ,p_lop_rec.org_id
      ,p_lop_rec.inv_org_id
      ,p_lop_rec.prospect_id
      ,p_lop_rec.prospect_address_id
      ,p_lop_rec.cust_acct_id
      ,p_lop_rec.currency_code
      ,p_lop_rec.currency_conversion_type
      ,p_lop_rec.currency_conversion_rate
      ,p_lop_rec.currency_conversion_date
      ,p_lop_rec.program_agreement_id
      ,p_lop_rec.master_lease_id
      ,p_lop_rec.sales_rep_id
      ,p_lop_rec.sales_territory_id
      ,p_lop_rec.supplier_id
      ,p_lop_rec.delivery_date
      ,p_lop_rec.funding_date
      ,p_lop_rec.property_tax_applicable
      ,p_lop_rec.property_tax_billing_type
      ,p_lop_rec.upfront_tax_treatment
      ,p_lop_rec.install_site_id
      ,p_lop_rec.usage_category
      ,p_lop_rec.usage_industry_class
      ,p_lop_rec.usage_industry_code
      ,p_lop_rec.usage_amount
      ,p_lop_rec.usage_location_id
      ,p_lop_rec.originating_vendor_id
      ,p_lop_rec.legal_entity_id
      -- Bug 5908845. eBTax Enhancement Project
      ,p_lop_rec.line_intended_use
      -- End Bug 5908845. eBTax Enhancement Project
    );

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  ----------------------------
  -- PROCEDURE insert_row (TL)
  ----------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_loptl_rec IN loptl_rec_type) IS

    CURSOR get_languages IS
      SELECT language_code
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');

    l_sfwt_flag  VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TL)';

    FOR l_lang_rec IN get_languages LOOP

      IF l_lang_rec.language_code = USERENV('LANG') THEN
        l_sfwt_flag := 'N';
      ELSE
        l_sfwt_flag := 'Y';
      END IF;

      INSERT INTO OKL_LEASE_OPPORTUNITIES_TL (
        id
       ,language
       ,source_lang
       ,sfwt_flag
       ,created_by
       ,creation_date
       ,last_updated_by
       ,last_update_date
       ,last_update_login
       ,short_description
       ,description
       ,comments)
      VALUES (
        p_loptl_rec.id
       ,l_lang_rec.language_code
       ,USERENV('LANG')
       ,l_sfwt_flag
       ,G_USER_ID
       ,SYSDATE
       ,G_USER_ID
       ,SYSDATE
       ,G_LOGIN_ID
       ,p_loptl_rec.short_description
       ,p_loptl_rec.description
       ,p_loptl_rec.comments);

    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  ---------------------------
  -- PROCEDURE insert_row (V)
  ---------------------------
  PROCEDURE insert_row (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lopv_rec                     IN lopv_rec_type,
    x_lopv_rec                     OUT NOCOPY lopv_rec_type) IS

    l_return_status                VARCHAR2(1);

    l_lopv_rec                     lopv_rec_type;
    l_lop_rec                      lop_rec_type;
    l_loptl_rec                    loptl_rec_type;

    l_prog_name  VARCHAR2(61);
    l_valid varchar2(3);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (V)';

    l_lopv_rec                       := null_out_defaults (p_lopv_rec);

    SELECT okl_lop_seq.nextval INTO l_lopv_rec.ID FROM DUAL;

    l_lopv_rec.OBJECT_VERSION_NUMBER := 1;

    l_return_status := validate_attributes(l_lopv_rec);

    --Bug 7022258-Added by kkorrapo
    l_valid := okl_util.validate_seq_num('OKL_LOP_REF_SEQ','OKL_LEASE_OPPORTUNITIES_B','REFERENCE_NUMBER',l_lopv_rec.reference_number);

    IF l_valid = 'N' THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug 7022258--Addition end

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record(l_lopv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_lopv_rec, l_lop_rec);
    migrate (l_lopv_rec, l_loptl_rec);

    insert_row (x_return_status => l_return_status, p_lop_rec => l_lop_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_row (x_return_status => l_return_status, p_loptl_rec => l_loptl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_lopv_rec      := l_lopv_rec;
    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  -----------------------------
  -- PROCEDURE insert_row (REC)
  -----------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_rec                     IN lopv_rec_type,
    x_lopv_rec                     OUT NOCOPY lopv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    insert_row (x_return_status                => l_return_status,
                p_lopv_rec                     => p_lopv_rec,
                x_lopv_rec                     => x_lopv_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  -----------------------------
  -- PROCEDURE insert_row (TBL)
  -----------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_tbl                     IN lopv_tbl_type,
    x_lopv_tbl                     OUT NOCOPY lopv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_lopv_tbl.COUNT > 0) THEN
      i := p_lopv_tbl.FIRST;
      LOOP
        IF p_lopv_tbl.EXISTS(i) THEN

          insert_row (x_return_status                => l_return_status,
                      p_lopv_rec                     => p_lopv_tbl(i),
                      x_lopv_rec                     => x_lopv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lopv_tbl.LAST);
          i := p_lopv_tbl.NEXT(i);

        END IF;

      END LOOP;

    ELSE

      l_return_status := G_RET_STS_SUCCESS;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  ---------------------
  -- PROCEDURE lock_row
  ---------------------
  PROCEDURE lock_row (x_return_status OUT NOCOPY VARCHAR2, p_lop_rec IN lop_rec_type) IS

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT (E_Resource_Busy, -00054);

    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LEASE_OPPORTUNITIES_B
     WHERE ID = p_lop_rec.id
       AND OBJECT_VERSION_NUMBER = p_lop_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LEASE_OPPORTUNITIES_B
     WHERE ID = p_lop_rec.id;

    l_object_version_number        NUMBER;
    lc_object_version_number       NUMBER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.lock_row';

    BEGIN
      OPEN lock_csr;
      FETCH lock_csr INTO l_object_version_number;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_OVN_ERROR2,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name);
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END;

    IF l_object_version_number IS NULL THEN

      OPEN lchk_csr;
      FETCH lchk_csr INTO lc_object_version_number;
      CLOSE lchk_csr;

      IF lc_object_version_number IS NULL THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_OVN_ERROR3,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name);

      ELSIF lc_object_version_number <> p_lop_rec.object_version_number THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_OVN_ERROR,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name);

      END IF;

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END lock_row;


  ---------------------------
  -- PROCEDURE update_row (B)
  ---------------------------
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_lop_rec IN lop_rec_type) IS

    l_return_status           VARCHAR2(1);

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (B)';

    lock_row (x_return_status => l_return_status, p_lop_rec => p_lop_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE okl_lease_opportunities_b
    SET
      object_version_number = p_lop_rec.object_version_number+1
      ,attribute_category = p_lop_rec.attribute_category
      ,attribute1 = p_lop_rec.attribute1
      ,attribute2 = p_lop_rec.attribute2
      ,attribute3 = p_lop_rec.attribute3
      ,attribute4 = p_lop_rec.attribute4
      ,attribute5 = p_lop_rec.attribute5
      ,attribute6 = p_lop_rec.attribute6
      ,attribute7 = p_lop_rec.attribute7
      ,attribute8 = p_lop_rec.attribute8
      ,attribute9 = p_lop_rec.attribute9
      ,attribute10 = p_lop_rec.attribute10
      ,attribute11 = p_lop_rec.attribute11
      ,attribute12 = p_lop_rec.attribute12
      ,attribute13 = p_lop_rec.attribute13
      ,attribute14 = p_lop_rec.attribute14
      ,attribute15 = p_lop_rec.attribute15
      ,last_updated_by = G_USER_ID
      ,last_update_date = SYSDATE
      ,last_update_login = G_LOGIN_ID
      ,reference_number = p_lop_rec.reference_number
      ,status = p_lop_rec.status
      ,valid_from = p_lop_rec.valid_from
      ,expected_start_date = p_lop_rec.expected_start_date
      ,org_id = p_lop_rec.org_id
      ,inv_org_id = p_lop_rec.inv_org_id
      ,prospect_id = p_lop_rec.prospect_id
      ,prospect_address_id = p_lop_rec.prospect_address_id
      ,cust_acct_id = p_lop_rec.cust_acct_id
      ,currency_code = p_lop_rec.currency_code
      ,currency_conversion_type = p_lop_rec.currency_conversion_type
      ,currency_conversion_rate = p_lop_rec.currency_conversion_rate
      ,currency_conversion_date = p_lop_rec.currency_conversion_date
      ,program_agreement_id = p_lop_rec.program_agreement_id
      ,master_lease_id = p_lop_rec.master_lease_id
      ,sales_rep_id = p_lop_rec.sales_rep_id
      ,sales_territory_id = p_lop_rec.sales_territory_id
      ,supplier_id = p_lop_rec.supplier_id
      ,delivery_date = p_lop_rec.delivery_date
      ,funding_date = p_lop_rec.funding_date
      ,property_tax_applicable = p_lop_rec.property_tax_applicable
      ,property_tax_billing_type = p_lop_rec.property_tax_billing_type
      ,upfront_tax_treatment = p_lop_rec.upfront_tax_treatment
      ,install_site_id = p_lop_rec.install_site_id
      ,usage_category = p_lop_rec.usage_category
      ,usage_industry_class = p_lop_rec.usage_industry_class
      ,usage_industry_code = p_lop_rec.usage_industry_code
      ,usage_amount = p_lop_rec.usage_amount
      ,usage_location_id = p_lop_rec.usage_location_id
      ,originating_vendor_id = p_lop_rec.originating_vendor_id
      ,legal_entity_id = p_lop_rec.legal_entity_id
      -- Bug 5908845. eBTax Enhancement Project
      ,line_intended_use = p_lop_rec.line_intended_use
      -- End Bug 5908845. eBTax Enhancement Project
    WHERE id = p_lop_rec.id;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  ----------------------------
  -- PROCEDURE update_row (TL)
  ----------------------------
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_loptl_rec IN loptl_rec_type) IS

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TL)';

    UPDATE OKL_LEASE_OPPORTUNITIES_TL
    SET
      source_lang = USERENV('LANG')
      ,sfwt_flag = 'Y'
      ,last_updated_by = G_USER_ID
      ,last_update_date = SYSDATE
      ,last_update_login = G_LOGIN_ID
      ,short_description = p_loptl_rec.short_description
      ,description = p_loptl_rec.description
      ,comments = p_loptl_rec.comments
    WHERE ID = p_loptl_rec.id;

    UPDATE OKL_LEASE_OPPORTUNITIES_TL
    SET SFWT_FLAG = 'N'
    WHERE ID = p_loptl_rec.id
    AND SOURCE_LANG = LANGUAGE;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  ---------------------------
  -- PROCEDURE update_row (V)
  ---------------------------
  PROCEDURE update_row (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lopv_rec                     IN lopv_rec_type,
    x_lopv_rec                     OUT NOCOPY lopv_rec_type) IS

    l_prog_name                    VARCHAR2(61);

    l_return_status                VARCHAR2(1);
    l_lopv_rec                     lopv_rec_type;
    l_lop_rec                      lop_rec_type;
    l_loptl_rec                    loptl_rec_type;

    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_lopv_rec IN  lopv_rec_type,
                                  x_lopv_rec OUT NOCOPY lopv_rec_type) RETURN VARCHAR2 IS

      l_prog_name          VARCHAR2(61);
      l_return_status      VARCHAR2(1);
      l_db_lopv_rec        lopv_rec_type;

    BEGIN

      l_prog_name := G_PKG_NAME||'.populate_new_record';

      x_lopv_rec    := p_lopv_rec;
      l_db_lopv_rec := get_rec (p_lopv_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF x_lopv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute_category := l_db_lopv_rec.attribute_category;
      END IF;
      IF x_lopv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute1 := l_db_lopv_rec.attribute1;
      END IF;
      IF x_lopv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute2 := l_db_lopv_rec.attribute2;
      END IF;
      IF x_lopv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute3 := l_db_lopv_rec.attribute3;
      END IF;
      IF x_lopv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute4 := l_db_lopv_rec.attribute4;
      END IF;
      IF x_lopv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute5 := l_db_lopv_rec.attribute5;
      END IF;
      IF x_lopv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute6 := l_db_lopv_rec.attribute6;
      END IF;
      IF x_lopv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute7 := l_db_lopv_rec.attribute7;
      END IF;
      IF x_lopv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute8 := l_db_lopv_rec.attribute8;
      END IF;
      IF x_lopv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute9 := l_db_lopv_rec.attribute9;
      END IF;
      IF x_lopv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute10 := l_db_lopv_rec.attribute10;
      END IF;
      IF x_lopv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute11 := l_db_lopv_rec.attribute11;
      END IF;
      IF x_lopv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute12 := l_db_lopv_rec.attribute12;
      END IF;
      IF x_lopv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute13 := l_db_lopv_rec.attribute13;
      END IF;
      IF x_lopv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute14 := l_db_lopv_rec.attribute14;
      END IF;
      IF x_lopv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.attribute15 := l_db_lopv_rec.attribute15;
      END IF;
      IF x_lopv_rec.reference_number = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.reference_number := l_db_lopv_rec.reference_number;
      END IF;
      IF x_lopv_rec.status = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.status := l_db_lopv_rec.status;
      END IF;
      IF x_lopv_rec.valid_from = FND_API.G_MISS_DATE THEN
        x_lopv_rec.valid_from := l_db_lopv_rec.valid_from;
      END IF;
      IF x_lopv_rec.expected_start_date = FND_API.G_MISS_DATE THEN
        x_lopv_rec.expected_start_date := l_db_lopv_rec.expected_start_date;
      END IF;
      IF x_lopv_rec.org_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.org_id := l_db_lopv_rec.org_id;
      END IF;
      IF x_lopv_rec.inv_org_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.inv_org_id := l_db_lopv_rec.inv_org_id;
      END IF;
      IF x_lopv_rec.prospect_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.prospect_id := l_db_lopv_rec.prospect_id;
      END IF;
      IF x_lopv_rec.prospect_address_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.prospect_address_id := l_db_lopv_rec.prospect_address_id;
      END IF;
      IF x_lopv_rec.cust_acct_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.cust_acct_id := l_db_lopv_rec.cust_acct_id;
      END IF;
      IF x_lopv_rec.currency_code = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.currency_code := l_db_lopv_rec.currency_code;
      END IF;
      IF x_lopv_rec.currency_conversion_type = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.currency_conversion_type := l_db_lopv_rec.currency_conversion_type;
      END IF;
      IF x_lopv_rec.currency_conversion_rate = FND_API.G_MISS_NUM THEN
        x_lopv_rec.currency_conversion_rate := l_db_lopv_rec.currency_conversion_rate;
      END IF;
      IF x_lopv_rec.currency_conversion_date = FND_API.G_MISS_DATE THEN
        x_lopv_rec.currency_conversion_date := l_db_lopv_rec.currency_conversion_date;
      END IF;
      IF x_lopv_rec.program_agreement_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.program_agreement_id := l_db_lopv_rec.program_agreement_id;
      END IF;
      IF x_lopv_rec.master_lease_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.master_lease_id := l_db_lopv_rec.master_lease_id;
      END IF;
      IF x_lopv_rec.sales_rep_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.sales_rep_id := l_db_lopv_rec.sales_rep_id;
      END IF;
      IF x_lopv_rec.sales_territory_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.sales_territory_id := l_db_lopv_rec.sales_territory_id;
      END IF;
      IF x_lopv_rec.supplier_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.supplier_id := l_db_lopv_rec.supplier_id;
      END IF;
      IF x_lopv_rec.delivery_date = FND_API.G_MISS_DATE THEN
        x_lopv_rec.delivery_date := l_db_lopv_rec.delivery_date;
      END IF;
      IF x_lopv_rec.funding_date = FND_API.G_MISS_DATE THEN
        x_lopv_rec.funding_date := l_db_lopv_rec.funding_date;
      END IF;
      IF x_lopv_rec.property_tax_applicable = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.property_tax_applicable := l_db_lopv_rec.property_tax_applicable;
      END IF;
      IF x_lopv_rec.property_tax_billing_type = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.property_tax_billing_type := l_db_lopv_rec.property_tax_billing_type;
      END IF;
      IF x_lopv_rec.upfront_tax_treatment = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.upfront_tax_treatment := l_db_lopv_rec.upfront_tax_treatment;
      END IF;
      IF x_lopv_rec.install_site_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.install_site_id := l_db_lopv_rec.install_site_id;
      END IF;
      IF x_lopv_rec.usage_category = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.usage_category := l_db_lopv_rec.usage_category;
      END IF;
      IF x_lopv_rec.usage_industry_class = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.usage_industry_class := l_db_lopv_rec.usage_industry_class;
      END IF;
      IF x_lopv_rec.usage_industry_code = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.usage_industry_code := l_db_lopv_rec.usage_industry_code;
      END IF;
      IF x_lopv_rec.usage_amount = FND_API.G_MISS_NUM THEN
        x_lopv_rec.usage_amount := l_db_lopv_rec.usage_amount;
      END IF;
      IF x_lopv_rec.usage_location_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.usage_location_id := l_db_lopv_rec.usage_location_id;
      END IF;
      IF x_lopv_rec.originating_vendor_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.originating_vendor_id := l_db_lopv_rec.originating_vendor_id;
      END IF;
      IF x_lopv_rec.legal_entity_id = FND_API.G_MISS_NUM THEN
        x_lopv_rec.legal_entity_id := l_db_lopv_rec.legal_entity_id;
      END IF;
      -- Bug 5908845. eBTax Enhancement Project
      IF x_lopv_rec.line_intended_use = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.line_intended_use := l_db_lopv_rec.line_intended_use;
      END IF;
      -- End Bug 5908845. eBTax Enhancement Project
      IF x_lopv_rec.short_description = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.short_description := l_db_lopv_rec.short_description;
      END IF;
      IF x_lopv_rec.description = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.description := l_db_lopv_rec.description;
      END IF;
      IF x_lopv_rec.comments = FND_API.G_MISS_CHAR THEN
        x_lopv_rec.comments := l_db_lopv_rec.comments;
      END IF;

      RETURN l_return_status;

    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN

        x_return_status := G_RET_STS_ERROR;

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        x_return_status := G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_DB_ERROR,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name,
                             p_token2       => G_SQLCODE_TOKEN,
                             p_token2_value => sqlcode,
                             p_token3       => G_SQLERRM_TOKEN,
                             p_token3_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

    END populate_new_record;

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (V)';

    l_return_status := populate_new_record (p_lopv_rec, l_lopv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_attributes (l_lopv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record (l_lopv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_lopv_rec, l_lop_rec);
    migrate (l_lopv_rec, l_loptl_rec);

    update_row (x_return_status => l_return_status, p_lop_rec => l_lop_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_row (x_return_status => l_return_status, p_loptl_rec => l_loptl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    x_lopv_rec      := l_lopv_rec;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -----------------------------
  -- PROCEDURE update_row (REC)
  -----------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_rec                     IN lopv_rec_type,
    x_lopv_rec                     OUT NOCOPY lopv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    update_row (x_return_status                => l_return_status,
                p_lopv_rec                     => p_lopv_rec,
                x_lopv_rec                     => x_lopv_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -----------------------------
  -- PROCEDURE update_row (TBL)
  -----------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_tbl                     IN lopv_tbl_type,
    x_lopv_tbl                     OUT NOCOPY lopv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;
    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_lopv_tbl := p_lopv_tbl;

    IF (p_lopv_tbl.COUNT > 0) THEN

      i := p_lopv_tbl.FIRST;

      LOOP

        IF p_lopv_tbl.EXISTS(i) THEN
          update_row (x_return_status                => l_return_status,
                      p_lopv_rec                     => p_lopv_tbl(i),
                      x_lopv_rec                     => x_lopv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lopv_tbl.LAST);
          i := p_lopv_tbl.NEXT(i);

        END IF;

      END LOOP;

    ELSE

      l_return_status := G_RET_STS_SUCCESS;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -----------------
  -- delete_row (V)
  -----------------
  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (V)';

    DELETE FROM OKL_LEASE_OPPORTUNITIES_B WHERE id = p_id;
    DELETE FROM OKL_LEASE_OPPORTUNITIES_TL WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;


  -----------------------------
  -- PROCEDURE delete_row (REC)
  -----------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_rec                     IN lopv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    delete_row (x_return_status                => l_return_status,
                p_id                           => p_lopv_rec.id);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;


  -------------------
  -- delete_row (TBL)
  -------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_tbl                     IN lopv_tbl_type) IS

    l_return_status                VARCHAR2(1);
    i                              BINARY_INTEGER;

    l_prog_name                    VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_lopv_tbl.COUNT > 0) THEN

      i := p_lopv_tbl.FIRST;

      LOOP

        IF p_lopv_tbl.EXISTS(i) THEN

          delete_row (x_return_status                => l_return_status,
                      p_id                           => p_lopv_tbl(i).id);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lopv_tbl.LAST);
          i := p_lopv_tbl.NEXT(i);

        END IF;

      END LOOP;

    ELSE

      l_return_status := G_RET_STS_SUCCESS;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;


END OKL_LOP_PVT;

/
