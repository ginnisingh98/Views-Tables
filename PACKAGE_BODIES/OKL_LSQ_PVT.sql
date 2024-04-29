--------------------------------------------------------
--  DDL for Package Body OKL_LSQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LSQ_PVT" AS
/* $Header: OKLSLSQB.pls 120.3.12010000.3 2008/11/27 04:53:15 kkorrapo ship $ */

  -------------------------
  -- PROCEDURE add_language
  -------------------------
  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_LEASE_QUOTES_TL T
    WHERE NOT EXISTS (SELECT NULL FROM OKL_LEASE_QUOTES_B B WHERE B.ID =T.ID);

    UPDATE OKL_LEASE_QUOTES_TL T
    SET (SHORT_DESCRIPTION,
        DESCRIPTION,
        COMMENTS) =
                     (SELECT
                      B.SHORT_DESCRIPTION,
                      B.DESCRIPTION,
                      B.COMMENTS
                      FROM
                      OKL_LEASE_QUOTES_TL B
                      WHERE
                      B.ID = T.ID
                      AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (T.ID, T.LANGUAGE) IN (SELECT
                                 SUBT.ID,
                                 SUBT.LANGUAGE
                                 FROM
                                 OKL_LEASE_QUOTES_TL SUBB,
                                 OKL_LEASE_QUOTES_TL SUBT
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

    INSERT INTO OKL_LEASE_QUOTES_TL (
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
        FROM OKL_LEASE_QUOTES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_LEASE_QUOTES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;


  -----------------------------
  -- FUNCTION null_out_defaults
  -----------------------------
  FUNCTION null_out_defaults (p_lsqv_rec IN lsqv_rec_type) RETURN lsqv_rec_type IS

    l_lsqv_rec  lsqv_rec_type;

  BEGIN

    l_lsqv_rec := p_lsqv_rec;

    -- Not applicable to ID and OBJECT_VERSION_NUMBER

    IF l_lsqv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute_category := NULL;
    END IF;
    IF l_lsqv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute1 := NULL;
    END IF;
    IF l_lsqv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute2 := NULL;
    END IF;
    IF l_lsqv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute3 := NULL;
    END IF;
    IF l_lsqv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute4 := NULL;
    END IF;
    IF l_lsqv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute5 := NULL;
    END IF;
    IF l_lsqv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute6 := NULL;
    END IF;
    IF l_lsqv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute7 := NULL;
    END IF;
    IF l_lsqv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute8 := NULL;
    END IF;
    IF l_lsqv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute9 := NULL;
    END IF;
    IF l_lsqv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute10 := NULL;
    END IF;
    IF l_lsqv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute11 := NULL;
    END IF;
    IF l_lsqv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute12 := NULL;
    END IF;
    IF l_lsqv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute13 := NULL;
    END IF;
    IF l_lsqv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute14 := NULL;
    END IF;
    IF l_lsqv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.attribute15 := NULL;
    END IF;
    IF l_lsqv_rec.reference_number = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.reference_number := NULL;
    END IF;
    IF l_lsqv_rec.status = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.status := NULL;
    END IF;
    IF l_lsqv_rec.parent_object_code = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.parent_object_code := NULL;
    END IF;
    IF l_lsqv_rec.parent_object_id = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.parent_object_id := NULL;
    END IF;
    IF l_lsqv_rec.valid_from = FND_API.G_MISS_DATE THEN
      l_lsqv_rec.valid_from := NULL;
    END IF;
    IF l_lsqv_rec.valid_to = FND_API.G_MISS_DATE THEN
      l_lsqv_rec.valid_to := NULL;
    END IF;
    IF l_lsqv_rec.customer_bookclass = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.customer_bookclass := NULL;
    END IF;
    IF l_lsqv_rec.customer_taxowner = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.customer_taxowner := NULL;
    END IF;
    IF l_lsqv_rec.expected_start_date = FND_API.G_MISS_DATE THEN
      l_lsqv_rec.expected_start_date := NULL;
    END IF;
    IF l_lsqv_rec.expected_funding_date = FND_API.G_MISS_DATE THEN
      l_lsqv_rec.expected_funding_date := NULL;
    END IF;
    IF l_lsqv_rec.expected_delivery_date = FND_API.G_MISS_DATE THEN
      l_lsqv_rec.expected_delivery_date := NULL;
    END IF;
    IF l_lsqv_rec.pricing_method = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.pricing_method := NULL;
    END IF;
    IF l_lsqv_rec.term = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.term := NULL;
    END IF;
    IF l_lsqv_rec.product_id = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.product_id := NULL;
    END IF;
    IF l_lsqv_rec.end_of_term_option_id = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.end_of_term_option_id := NULL;
    END IF;
    IF l_lsqv_rec.structured_pricing = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.structured_pricing := NULL;
    END IF;
    IF l_lsqv_rec.line_level_pricing = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.line_level_pricing := NULL;
    END IF;
    IF l_lsqv_rec.rate_template_id = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.rate_template_id := NULL;
    END IF;
    IF l_lsqv_rec.rate_card_id = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.rate_card_id := NULL;
    END IF;
    IF l_lsqv_rec.lease_rate_factor = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.lease_rate_factor := NULL;
    END IF;
    IF l_lsqv_rec.target_rate_type = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.target_rate_type := NULL;
    END IF;
    IF l_lsqv_rec.target_rate = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.target_rate := NULL;
    END IF;
    IF l_lsqv_rec.target_amount = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.target_amount := NULL;
    END IF;
    IF l_lsqv_rec.target_frequency = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.target_frequency := NULL;
    END IF;
    IF l_lsqv_rec.target_arrears_yn = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.target_arrears_yn := NULL;
    END IF;
    IF l_lsqv_rec.target_periods = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.target_periods := NULL;
    END IF;
    IF l_lsqv_rec.iir = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.iir := NULL;
    END IF;
    IF l_lsqv_rec.booking_yield = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.booking_yield := NULL;
    END IF;
    IF l_lsqv_rec.pirr = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.pirr := NULL;
    END IF;
    IF l_lsqv_rec.airr = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.airr := NULL;
    END IF;
    IF l_lsqv_rec.sub_iir = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.sub_iir := NULL;
    END IF;
    IF l_lsqv_rec.sub_booking_yield = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.sub_booking_yield := NULL;
    END IF;
    IF l_lsqv_rec.sub_pirr = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.sub_pirr := NULL;
    END IF;
    IF l_lsqv_rec.sub_airr = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.sub_airr := NULL;
    END IF;
    IF l_lsqv_rec.usage_category = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.usage_category := NULL;
    END IF;
    IF l_lsqv_rec.usage_industry_class = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.usage_industry_class := NULL;
    END IF;
    IF l_lsqv_rec.usage_industry_code = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.usage_industry_code := NULL;
    END IF;
    IF l_lsqv_rec.usage_amount = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.usage_amount := NULL;
    END IF;
    IF l_lsqv_rec.usage_location_id = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.usage_location_id := NULL;
    END IF;
    IF l_lsqv_rec.property_tax_applicable = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.property_tax_applicable := NULL;
    END IF;
    IF l_lsqv_rec.property_tax_billing_type = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.property_tax_billing_type := NULL;
    END IF;
    IF l_lsqv_rec.upfront_tax_treatment = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.upfront_tax_treatment := NULL;
    END IF;
    IF l_lsqv_rec.upfront_tax_stream_type = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.upfront_tax_stream_type := NULL;
    END IF;
    IF l_lsqv_rec.transfer_of_title = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.transfer_of_title := NULL;
    END IF;
    IF l_lsqv_rec.age_of_equipment = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.age_of_equipment := NULL;
    END IF;
    IF l_lsqv_rec.purchase_of_lease = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.purchase_of_lease := NULL;
    END IF;
    IF l_lsqv_rec.sale_and_lease_back = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.sale_and_lease_back := NULL;
    END IF;
    IF l_lsqv_rec.interest_disclosed = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.interest_disclosed := NULL;
    END IF;
    IF l_lsqv_rec.primary_quote = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.primary_quote := NULL;
    END IF;
    --Bug # 5647107
    IF l_lsqv_rec.legal_entity_id = FND_API.G_MISS_NUM THEN
      l_lsqv_rec.legal_entity_id := NULL;
    END IF;
    --Bug # 5647107
    -- Bug 5908845. eBTax Enhancement Project
    IF l_lsqv_rec.line_intended_use = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.line_intended_use := NULL;
    END IF;
    -- End Bug 5908845. eBTax Enhancement Project
    IF l_lsqv_rec.short_description = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.short_description := NULL;
    END IF;
    IF l_lsqv_rec.description = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.description := NULL;
    END IF;
    IF l_lsqv_rec.comments = FND_API.G_MISS_CHAR THEN
      l_lsqv_rec.comments := NULL;
    END IF;

    RETURN l_lsqv_rec;

  END null_out_defaults;


  -------------------
  -- FUNCTION get_rec
  -------------------
  FUNCTION get_rec (p_id             IN         NUMBER
                    ,x_return_status OUT NOCOPY VARCHAR2) RETURN lsqv_rec_type IS

    l_lsqv_rec           lsqv_rec_type;
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
      ,parent_object_code
      ,parent_object_id
      ,valid_from
      ,valid_to
      ,customer_bookclass
      ,customer_taxowner
      ,expected_start_date
      ,expected_funding_date
      ,expected_delivery_date
      ,pricing_method
      ,term
      ,product_id
      ,end_of_term_option_id
      ,structured_pricing
      ,line_level_pricing
      ,rate_template_id
      ,rate_card_id
      ,lease_rate_factor
      ,target_rate_type
      ,target_rate
      ,target_amount
      ,target_frequency
      ,target_arrears_yn
      ,target_periods
      ,iir
      ,booking_yield
      ,pirr
      ,airr
      ,sub_iir
      ,sub_booking_yield
      ,sub_pirr
      ,sub_airr
      ,usage_category
      ,usage_industry_class
      ,usage_industry_code
      ,usage_amount
      ,usage_location_id
      ,property_tax_applicable
      ,property_tax_billing_type
      ,upfront_tax_treatment
      ,upfront_tax_stream_type
      ,transfer_of_title
      ,age_of_equipment
      ,purchase_of_lease
      ,sale_and_lease_back
      ,interest_disclosed
      ,primary_quote
      ,legal_entity_id
      -- Bug 5908845. eBTax Enhancement Project
      ,line_intended_use
      -- End Bug 5908845. eBTax Enhancement Project
      ,short_description
      ,description
      ,comments
    INTO
      l_lsqv_rec.id
      ,l_lsqv_rec.object_version_number
      ,l_lsqv_rec.attribute_category
      ,l_lsqv_rec.attribute1
      ,l_lsqv_rec.attribute2
      ,l_lsqv_rec.attribute3
      ,l_lsqv_rec.attribute4
      ,l_lsqv_rec.attribute5
      ,l_lsqv_rec.attribute6
      ,l_lsqv_rec.attribute7
      ,l_lsqv_rec.attribute8
      ,l_lsqv_rec.attribute9
      ,l_lsqv_rec.attribute10
      ,l_lsqv_rec.attribute11
      ,l_lsqv_rec.attribute12
      ,l_lsqv_rec.attribute13
      ,l_lsqv_rec.attribute14
      ,l_lsqv_rec.attribute15
      ,l_lsqv_rec.reference_number
      ,l_lsqv_rec.status
      ,l_lsqv_rec.parent_object_code
      ,l_lsqv_rec.parent_object_id
      ,l_lsqv_rec.valid_from
      ,l_lsqv_rec.valid_to
      ,l_lsqv_rec.customer_bookclass
      ,l_lsqv_rec.customer_taxowner
      ,l_lsqv_rec.expected_start_date
      ,l_lsqv_rec.expected_funding_date
      ,l_lsqv_rec.expected_delivery_date
      ,l_lsqv_rec.pricing_method
      ,l_lsqv_rec.term
      ,l_lsqv_rec.product_id
      ,l_lsqv_rec.end_of_term_option_id
      ,l_lsqv_rec.structured_pricing
      ,l_lsqv_rec.line_level_pricing
      ,l_lsqv_rec.rate_template_id
      ,l_lsqv_rec.rate_card_id
      ,l_lsqv_rec.lease_rate_factor
      ,l_lsqv_rec.target_rate_type
      ,l_lsqv_rec.target_rate
      ,l_lsqv_rec.target_amount
      ,l_lsqv_rec.target_frequency
      ,l_lsqv_rec.target_arrears_yn
      ,l_lsqv_rec.target_periods
      ,l_lsqv_rec.iir
      ,l_lsqv_rec.booking_yield
      ,l_lsqv_rec.pirr
      ,l_lsqv_rec.airr
      ,l_lsqv_rec.sub_iir
      ,l_lsqv_rec.sub_booking_yield
      ,l_lsqv_rec.sub_pirr
      ,l_lsqv_rec.sub_airr
      ,l_lsqv_rec.usage_category
      ,l_lsqv_rec.usage_industry_class
      ,l_lsqv_rec.usage_industry_code
      ,l_lsqv_rec.usage_amount
      ,l_lsqv_rec.usage_location_id
      ,l_lsqv_rec.property_tax_applicable
      ,l_lsqv_rec.property_tax_billing_type
      ,l_lsqv_rec.upfront_tax_treatment
      ,l_lsqv_rec.upfront_tax_stream_type
      ,l_lsqv_rec.transfer_of_title
      ,l_lsqv_rec.age_of_equipment
      ,l_lsqv_rec.purchase_of_lease
      ,l_lsqv_rec.sale_and_lease_back
      ,l_lsqv_rec.interest_disclosed
      ,l_lsqv_rec.primary_quote
      ,l_lsqv_rec.legal_entity_id
      -- Bug 5908845. eBTax Enhancement Project
      ,l_lsqv_rec.line_intended_use
      -- End Bug 5908845. eBTax Enhancement Project
      ,l_lsqv_rec.short_description
      ,l_lsqv_rec.description
      ,l_lsqv_rec.comments
    FROM okl_lease_quotes_v
    WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_lsqv_rec;

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

  --Bug 7022258-Added by kkorrapo
    IF (okl_util.validate_seq_num('OKL_LSQ_REF_SEQ','OKL_LEASE_QUOTES_B','REFERENCE_NUMBER',p_reference_number) = 'N') THEN
      RAISE okl_api.g_exception_error;
    END IF;
  --Bug 7022258--Addition end

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
  -- PROCEDURE validate_parent_object_code
  -----------------------------------------
  PROCEDURE validate_parent_object_code (x_return_status OUT NOCOPY VARCHAR2, p_parent_object_code IN VARCHAR2) IS
  BEGIN
    IF p_parent_object_code IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'parent_object_code',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_parent_object_code;


  -----------------------------------------
  -- PROCEDURE validate_parent_object_id
  -----------------------------------------
  PROCEDURE validate_parent_object_id (x_return_status OUT NOCOPY VARCHAR2, p_parent_object_id IN NUMBER) IS
  BEGIN
    IF p_parent_object_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'parent_object_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_parent_object_id;


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


  -----------------------------------------
  -- PROCEDURE validate_pricing_method
  -----------------------------------------
  PROCEDURE validate_pricing_method (x_return_status OUT NOCOPY VARCHAR2, p_pricing_method IN VARCHAR2) IS
  BEGIN
    IF p_pricing_method IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'pricing_method',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_pricing_method;


  -----------------------------------------
  -- PROCEDURE validate_term
  -----------------------------------------
  PROCEDURE validate_term (x_return_status OUT NOCOPY VARCHAR2, p_term IN NUMBER) IS
  BEGIN
    IF p_term IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'term',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_term;


  -----------------------------------------
  -- PROCEDURE validate_product_id
  -----------------------------------------
  PROCEDURE validate_product_id (x_return_status OUT NOCOPY VARCHAR2, p_product_id IN NUMBER) IS
  BEGIN
    IF p_product_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'product_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_product_id;


  -----------------------------------------
  -- PROCEDURE validate_end_of_term_option_id
  -----------------------------------------
  PROCEDURE validate_end_of_term_option_id (x_return_status OUT NOCOPY VARCHAR2, p_end_of_term_option_id IN NUMBER) IS
  BEGIN
    IF p_end_of_term_option_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'end_of_term_option_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_end_of_term_option_id;

  --Added Bug 5647107 ssdeshpa start
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

  --Added Bug 5647107 ssdeshpa start

  -------------------------------
  -- FUNCTION validate_attributes
  -------------------------------
  FUNCTION validate_attributes (p_lsqv_rec IN lsqv_rec_type, p_mode IN VARCHAR2) RETURN VARCHAR2 IS			--Bug 7596781

    l_return_status                VARCHAR2(1);

  BEGIN

    validate_id (l_return_status, p_lsqv_rec.id);
    validate_object_version_number (l_return_status, p_lsqv_rec.object_version_number);
    IF(p_mode = 'CREATE') THEN					--Bug 7596781
    validate_reference_number (l_return_status, p_lsqv_rec.reference_number);
    END IF;										--Bug 7596781
    validate_status (l_return_status, p_lsqv_rec.status);
    validate_parent_object_code (l_return_status, p_lsqv_rec.parent_object_code);
    validate_parent_object_id (l_return_status, p_lsqv_rec.parent_object_id);
    validate_pricing_method (l_return_status, p_lsqv_rec.pricing_method);
    validate_term (l_return_status, p_lsqv_rec.term);
    validate_product_id (l_return_status, p_lsqv_rec.product_id);
    validate_end_of_term_option_id (l_return_status, p_lsqv_rec.end_of_term_option_id);
    validate_legal_entity_id(l_return_status,p_lsqv_rec.legal_entity_id);
    RETURN l_return_status;

  END validate_attributes;

  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  FUNCTION validate_record (p_lsqv_rec IN lsqv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    RETURN G_RET_STS_SUCCESS;
  END validate_record;


  -----------------------------
  -- PROECDURE migrate (V -> B)
  -----------------------------
  PROCEDURE migrate (p_from IN lsqv_rec_type, p_to IN OUT NOCOPY lsq_rec_type) IS

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
    p_to.parent_object_code             :=  p_from.parent_object_code;
    p_to.parent_object_id               :=  p_from.parent_object_id;
    p_to.valid_from                     :=  p_from.valid_from;
    p_to.valid_to                       :=  p_from.valid_to;
    p_to.customer_bookclass             :=  p_from.customer_bookclass;
    p_to.customer_taxowner              :=  p_from.customer_taxowner;
    p_to.expected_start_date            :=  p_from.expected_start_date;
    p_to.expected_funding_date          :=  p_from.expected_funding_date;
    p_to.expected_delivery_date         :=  p_from.expected_delivery_date;
    p_to.pricing_method                 :=  p_from.pricing_method;
    p_to.term                           :=  p_from.term;
    p_to.product_id                     :=  p_from.product_id;
    p_to.end_of_term_option_id          :=  p_from.end_of_term_option_id;
    p_to.structured_pricing             :=  p_from.structured_pricing;
    p_to.line_level_pricing             :=  p_from.line_level_pricing;
    p_to.rate_template_id               :=  p_from.rate_template_id;
    p_to.rate_card_id                   :=  p_from.rate_card_id;
    p_to.lease_rate_factor              :=  p_from.lease_rate_factor;
    p_to.target_rate_type               :=  p_from.target_rate_type;
    p_to.target_rate                    :=  p_from.target_rate;
    p_to.target_amount                  :=  p_from.target_amount;
    p_to.target_frequency               :=  p_from.target_frequency;
    p_to.target_arrears_yn              :=  p_from.target_arrears_yn;
    p_to.target_periods                 :=  p_from.target_periods;
    p_to.iir                            :=  p_from.iir;
    p_to.booking_yield                  :=  p_from.booking_yield;
    p_to.pirr                           :=  p_from.pirr;
    p_to.airr                           :=  p_from.airr;
    p_to.sub_iir                        :=  p_from.sub_iir;
    p_to.sub_booking_yield              :=  p_from.sub_booking_yield;
    p_to.sub_pirr                       :=  p_from.sub_pirr;
    p_to.sub_airr                       :=  p_from.sub_airr;
    p_to.usage_category                 :=  p_from.usage_category;
    p_to.usage_industry_class           :=  p_from.usage_industry_class;
    p_to.usage_industry_code            :=  p_from.usage_industry_code;
    p_to.usage_amount                   :=  p_from.usage_amount;
    p_to.usage_location_id              :=  p_from.usage_location_id;
    p_to.property_tax_applicable        :=  p_from.property_tax_applicable;
    p_to.property_tax_billing_type      :=  p_from.property_tax_billing_type;
    p_to.upfront_tax_treatment          :=  p_from.upfront_tax_treatment;
    p_to.upfront_tax_stream_type        :=  p_from.upfront_tax_stream_type;
    p_to.transfer_of_title              :=  p_from.transfer_of_title;
    p_to.age_of_equipment               :=  p_from.age_of_equipment;
    p_to.purchase_of_lease              :=  p_from.purchase_of_lease;
    p_to.sale_and_lease_back            :=  p_from.sale_and_lease_back;
    p_to.interest_disclosed             :=  p_from.interest_disclosed;
    p_to.primary_quote                  :=  p_from.primary_quote;
    p_to.legal_entity_id                :=  p_from.legal_entity_id;
    -- Bug 5908845. eBTax Enhancement Project
    p_to.line_intended_use              :=  p_from.line_intended_use;
    -- End Bug 5908845. eBTax Enhancement Project
  END migrate;


  -----------------------------
  -- PROCEDURE migrate (V -> TL)
  -----------------------------
  PROCEDURE migrate (p_from IN lsqv_rec_type, p_to IN OUT NOCOPY lsqtl_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.short_description := p_from.short_description;
    p_to.description := p_from.description;
    p_to.comments := p_from.comments;
  END migrate;


  ---------------------------
  -- PROCEDURE insert_row (B)
  ---------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_lsq_rec IN lsq_rec_type) IS

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (B)';

    INSERT INTO okl_lease_quotes_b (
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
      ,parent_object_code
      ,parent_object_id
      ,valid_from
      ,valid_to
      ,customer_bookclass
      ,customer_taxowner
      ,expected_start_date
      ,expected_funding_date
      ,expected_delivery_date
      ,pricing_method
      ,term
      ,product_id
      ,end_of_term_option_id
      ,structured_pricing
      ,line_level_pricing
      ,rate_template_id
      ,rate_card_id
      ,lease_rate_factor
      ,target_rate_type
      ,target_rate
      ,target_amount
      ,target_frequency
      ,target_arrears_yn
      ,target_periods
      ,iir
      ,booking_yield
      ,pirr
      ,airr
      ,sub_iir
      ,sub_booking_yield
      ,sub_pirr
      ,sub_airr
      ,usage_category
      ,usage_industry_class
      ,usage_industry_code
      ,usage_amount
      ,usage_location_id
      ,property_tax_applicable
      ,property_tax_billing_type
      ,upfront_tax_treatment
      ,upfront_tax_stream_type
      ,transfer_of_title
      ,age_of_equipment
      ,purchase_of_lease
      ,sale_and_lease_back
      ,interest_disclosed
      ,primary_quote
      ,legal_entity_id
      --Bug 5908845. eBTax Enhancement Project
      ,line_intended_use
      -- End Bug 5908845. eBTax Enhancement Project
      )
    VALUES
      (
       p_lsq_rec.id
      ,p_lsq_rec.object_version_number
      ,p_lsq_rec.attribute_category
      ,p_lsq_rec.attribute1
      ,p_lsq_rec.attribute2
      ,p_lsq_rec.attribute3
      ,p_lsq_rec.attribute4
      ,p_lsq_rec.attribute5
      ,p_lsq_rec.attribute6
      ,p_lsq_rec.attribute7
      ,p_lsq_rec.attribute8
      ,p_lsq_rec.attribute9
      ,p_lsq_rec.attribute10
      ,p_lsq_rec.attribute11
      ,p_lsq_rec.attribute12
      ,p_lsq_rec.attribute13
      ,p_lsq_rec.attribute14
      ,p_lsq_rec.attribute15
      ,G_USER_ID
      ,SYSDATE
      ,G_USER_ID
      ,SYSDATE
      ,G_LOGIN_ID
      ,p_lsq_rec.reference_number
      ,p_lsq_rec.status
      ,p_lsq_rec.parent_object_code
      ,p_lsq_rec.parent_object_id
      ,p_lsq_rec.valid_from
      ,p_lsq_rec.valid_to
      ,p_lsq_rec.customer_bookclass
      ,p_lsq_rec.customer_taxowner
      ,p_lsq_rec.expected_start_date
      ,p_lsq_rec.expected_funding_date
      ,p_lsq_rec.expected_delivery_date
      ,p_lsq_rec.pricing_method
      ,p_lsq_rec.term
      ,p_lsq_rec.product_id
      ,p_lsq_rec.end_of_term_option_id
      ,p_lsq_rec.structured_pricing
      ,p_lsq_rec.line_level_pricing
      ,p_lsq_rec.rate_template_id
      ,p_lsq_rec.rate_card_id
      ,p_lsq_rec.lease_rate_factor
      ,p_lsq_rec.target_rate_type
      ,p_lsq_rec.target_rate
      ,p_lsq_rec.target_amount
      ,p_lsq_rec.target_frequency
      ,p_lsq_rec.target_arrears_yn
      ,p_lsq_rec.target_periods
      ,p_lsq_rec.iir
      ,p_lsq_rec.booking_yield
      ,p_lsq_rec.pirr
      ,p_lsq_rec.airr
      ,p_lsq_rec.sub_iir
      ,p_lsq_rec.sub_booking_yield
      ,p_lsq_rec.sub_pirr
      ,p_lsq_rec.sub_airr
      ,p_lsq_rec.usage_category
      ,p_lsq_rec.usage_industry_class
      ,p_lsq_rec.usage_industry_code
      ,p_lsq_rec.usage_amount
      ,p_lsq_rec.usage_location_id
      ,p_lsq_rec.property_tax_applicable
      ,p_lsq_rec.property_tax_billing_type
      ,p_lsq_rec.upfront_tax_treatment
      ,p_lsq_rec.upfront_tax_stream_type
      ,p_lsq_rec.transfer_of_title
      ,p_lsq_rec.age_of_equipment
      ,p_lsq_rec.purchase_of_lease
      ,p_lsq_rec.sale_and_lease_back
      ,p_lsq_rec.interest_disclosed
      ,p_lsq_rec.primary_quote
      ,p_lsq_rec.legal_entity_id
      -- Bug 5908845. eBTax Enhancement Project
      ,p_lsq_rec.line_intended_use
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
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_lsqtl_rec IN lsqtl_rec_type) IS

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

      INSERT INTO OKL_LEASE_QUOTES_TL (
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
        p_lsqtl_rec.id
       ,l_lang_rec.language_code
       ,USERENV('LANG')
       ,l_sfwt_flag
       ,G_USER_ID
       ,SYSDATE
       ,G_USER_ID
       ,SYSDATE
       ,G_LOGIN_ID
       ,p_lsqtl_rec.short_description
       ,p_lsqtl_rec.description
       ,p_lsqtl_rec.comments);

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
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type) IS

    l_return_status                VARCHAR2(1);

    l_lsqv_rec                     lsqv_rec_type;
    l_lsq_rec                      lsq_rec_type;
    l_lsqtl_rec                    lsqtl_rec_type;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (V)';

    l_lsqv_rec                       := null_out_defaults (p_lsqv_rec);

    SELECT okl_lsq_seq.nextval INTO l_lsqv_rec.ID FROM DUAL;

    l_lsqv_rec.OBJECT_VERSION_NUMBER := 1;

    l_return_status := validate_attributes(l_lsqv_rec,'CREATE');				--Bug 7596781

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record(l_lsqv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_lsqv_rec, l_lsq_rec);
    migrate (l_lsqv_rec, l_lsqtl_rec);

    insert_row (x_return_status => l_return_status, p_lsq_rec => l_lsq_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_row (x_return_status => l_return_status, p_lsqtl_rec => l_lsqtl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_lsqv_rec      := l_lsqv_rec;
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
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    insert_row (x_return_status                => l_return_status,
                p_lsqv_rec                     => p_lsqv_rec,
                x_lsqv_rec                     => x_lsqv_rec);

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
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_lsqv_tbl.COUNT > 0) THEN
      i := p_lsqv_tbl.FIRST;
      LOOP
        IF p_lsqv_tbl.EXISTS(i) THEN

          insert_row (x_return_status                => l_return_status,
                      p_lsqv_rec                     => p_lsqv_tbl(i),
                      x_lsqv_rec                     => x_lsqv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lsqv_tbl.LAST);
          i := p_lsqv_tbl.NEXT(i);

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
  PROCEDURE lock_row (x_return_status OUT NOCOPY VARCHAR2, p_lsq_rec IN lsq_rec_type) IS

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT (E_Resource_Busy, -00054);

    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LEASE_QUOTES_B
     WHERE ID = p_lsq_rec.id
       AND OBJECT_VERSION_NUMBER = p_lsq_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LEASE_QUOTES_B
     WHERE ID = p_lsq_rec.id;

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

      ELSIF lc_object_version_number <> p_lsq_rec.object_version_number THEN

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_lsq_rec IN lsq_rec_type) IS

    l_return_status           VARCHAR2(1);

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (B)';

    lock_row (x_return_status => l_return_status, p_lsq_rec => p_lsq_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE okl_lease_quotes_b
    SET
      object_version_number = p_lsq_rec.object_version_number+1
      ,attribute_category = p_lsq_rec.attribute_category
      ,attribute1 = p_lsq_rec.attribute1
      ,attribute2 = p_lsq_rec.attribute2
      ,attribute3 = p_lsq_rec.attribute3
      ,attribute4 = p_lsq_rec.attribute4
      ,attribute5 = p_lsq_rec.attribute5
      ,attribute6 = p_lsq_rec.attribute6
      ,attribute7 = p_lsq_rec.attribute7
      ,attribute8 = p_lsq_rec.attribute8
      ,attribute9 = p_lsq_rec.attribute9
      ,attribute10 = p_lsq_rec.attribute10
      ,attribute11 = p_lsq_rec.attribute11
      ,attribute12 = p_lsq_rec.attribute12
      ,attribute13 = p_lsq_rec.attribute13
      ,attribute14 = p_lsq_rec.attribute14
      ,attribute15 = p_lsq_rec.attribute15
      ,reference_number = p_lsq_rec.reference_number
      ,status = p_lsq_rec.status
      ,parent_object_code = p_lsq_rec.parent_object_code
      ,parent_object_id = p_lsq_rec.parent_object_id
      ,valid_from = p_lsq_rec.valid_from
      ,valid_to = p_lsq_rec.valid_to
      ,customer_bookclass = p_lsq_rec.customer_bookclass
      ,customer_taxowner = p_lsq_rec.customer_taxowner
      ,expected_start_date = p_lsq_rec.expected_start_date
      ,expected_funding_date = p_lsq_rec.expected_funding_date
      ,expected_delivery_date = p_lsq_rec.expected_delivery_date
      ,pricing_method = p_lsq_rec.pricing_method
      ,term = p_lsq_rec.term
      ,product_id = p_lsq_rec.product_id
      ,end_of_term_option_id = p_lsq_rec.end_of_term_option_id
      ,structured_pricing = p_lsq_rec.structured_pricing
      ,line_level_pricing = p_lsq_rec.line_level_pricing
      ,rate_template_id = p_lsq_rec.rate_template_id
      ,rate_card_id = p_lsq_rec.rate_card_id
      ,lease_rate_factor = p_lsq_rec.lease_rate_factor
      ,target_rate_type = p_lsq_rec.target_rate_type
      ,target_rate = p_lsq_rec.target_rate
      ,target_amount = p_lsq_rec.target_amount
      ,target_frequency = p_lsq_rec.target_frequency
      ,target_arrears_yn = p_lsq_rec.target_arrears_yn
      ,target_periods = p_lsq_rec.target_periods
      ,iir = p_lsq_rec.iir
      ,booking_yield = p_lsq_rec.booking_yield
      ,pirr = p_lsq_rec.pirr
      ,airr = p_lsq_rec.airr
      ,sub_iir = p_lsq_rec.sub_iir
      ,sub_booking_yield = p_lsq_rec.sub_booking_yield
      ,sub_pirr = p_lsq_rec.sub_pirr
      ,sub_airr = p_lsq_rec.sub_airr
      ,usage_category = p_lsq_rec.usage_category
      ,usage_industry_class = p_lsq_rec.usage_industry_class
      ,usage_industry_code = p_lsq_rec.usage_industry_code
      ,usage_amount = p_lsq_rec.usage_amount
      ,usage_location_id = p_lsq_rec.usage_location_id
      ,property_tax_applicable = p_lsq_rec.property_tax_applicable
      ,property_tax_billing_type = p_lsq_rec.property_tax_billing_type
      ,upfront_tax_treatment = p_lsq_rec.upfront_tax_treatment
      ,upfront_tax_stream_type = p_lsq_rec.upfront_tax_stream_type
      ,transfer_of_title = p_lsq_rec.transfer_of_title
      ,age_of_equipment = p_lsq_rec.age_of_equipment
      ,purchase_of_lease = p_lsq_rec.purchase_of_lease
      ,sale_and_lease_back = p_lsq_rec.sale_and_lease_back
      ,interest_disclosed = p_lsq_rec.interest_disclosed
      ,primary_quote = p_lsq_rec.primary_quote
      ,legal_entity_id = p_lsq_rec.legal_entity_id
      -- Bug 5908845. eBTax Enhancement Project
      ,line_intended_use = p_lsq_rec.line_intended_use
      -- End Bug 5908845. eBTax Enhancement Project
    WHERE id = p_lsq_rec.id;

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_lsqtl_rec IN lsqtl_rec_type) IS

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TL)';

    UPDATE OKL_LEASE_QUOTES_TL
    SET
      source_lang = USERENV('LANG')
      ,sfwt_flag = 'Y'
      ,last_updated_by = G_USER_ID
      ,last_update_date = SYSDATE
      ,last_update_login = G_LOGIN_ID
      ,short_description = p_lsqtl_rec.short_description
      ,description = p_lsqtl_rec.description
      ,comments = p_lsqtl_rec.comments
    WHERE ID = p_lsqtl_rec.id;

    UPDATE OKL_LEASE_QUOTES_TL
    SET SFWT_FLAG = 'N'
    WHERE ID = p_lsqtl_rec.id
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
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type) IS

    l_prog_name                    VARCHAR2(61);

    l_return_status                VARCHAR2(1);
    l_lsqv_rec                     lsqv_rec_type;
    l_lsq_rec                      lsq_rec_type;
    l_lsqtl_rec                    lsqtl_rec_type;

    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_lsqv_rec IN  lsqv_rec_type,
                                  x_lsqv_rec OUT NOCOPY lsqv_rec_type) RETURN VARCHAR2 IS

      l_prog_name          VARCHAR2(61);
      l_return_status      VARCHAR2(1);
      l_db_lsqv_rec        lsqv_rec_type;

    BEGIN

      l_prog_name := G_PKG_NAME||'.populate_new_record';

      x_lsqv_rec    := p_lsqv_rec;
      l_db_lsqv_rec := get_rec (p_lsqv_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF x_lsqv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute_category := l_db_lsqv_rec.attribute_category;
      END IF;
      IF x_lsqv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute1 := l_db_lsqv_rec.attribute1;
      END IF;
      IF x_lsqv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute2 := l_db_lsqv_rec.attribute2;
      END IF;
      IF x_lsqv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute3 := l_db_lsqv_rec.attribute3;
      END IF;
      IF x_lsqv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute4 := l_db_lsqv_rec.attribute4;
      END IF;
      IF x_lsqv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute5 := l_db_lsqv_rec.attribute5;
      END IF;
      IF x_lsqv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute6 := l_db_lsqv_rec.attribute6;
      END IF;
      IF x_lsqv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute7 := l_db_lsqv_rec.attribute7;
      END IF;
      IF x_lsqv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute8 := l_db_lsqv_rec.attribute8;
      END IF;
      IF x_lsqv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute9 := l_db_lsqv_rec.attribute9;
      END IF;
      IF x_lsqv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute10 := l_db_lsqv_rec.attribute10;
      END IF;
      IF x_lsqv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute11 := l_db_lsqv_rec.attribute11;
      END IF;
      IF x_lsqv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute12 := l_db_lsqv_rec.attribute12;
      END IF;
      IF x_lsqv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute13 := l_db_lsqv_rec.attribute13;
      END IF;
      IF x_lsqv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute14 := l_db_lsqv_rec.attribute14;
      END IF;
      IF x_lsqv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.attribute15 := l_db_lsqv_rec.attribute15;
      END IF;
      IF x_lsqv_rec.reference_number = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.reference_number := l_db_lsqv_rec.reference_number;
      END IF;
      IF x_lsqv_rec.status = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.status := l_db_lsqv_rec.status;
      END IF;
      IF x_lsqv_rec.parent_object_code = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.parent_object_code := l_db_lsqv_rec.parent_object_code;
      END IF;
      IF x_lsqv_rec.parent_object_id = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.parent_object_id := l_db_lsqv_rec.parent_object_id;
      END IF;
      IF x_lsqv_rec.valid_from = FND_API.G_MISS_DATE THEN
        x_lsqv_rec.valid_from := l_db_lsqv_rec.valid_from;
      END IF;
      IF x_lsqv_rec.valid_to = FND_API.G_MISS_DATE THEN
        x_lsqv_rec.valid_to := l_db_lsqv_rec.valid_to;
      END IF;
      IF x_lsqv_rec.customer_bookclass = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.customer_bookclass := l_db_lsqv_rec.customer_bookclass;
      END IF;
      IF x_lsqv_rec.customer_taxowner = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.customer_taxowner := l_db_lsqv_rec.customer_taxowner;
      END IF;
      IF x_lsqv_rec.expected_start_date = FND_API.G_MISS_DATE THEN
        x_lsqv_rec.expected_start_date := l_db_lsqv_rec.expected_start_date;
      END IF;
      IF x_lsqv_rec.expected_funding_date = FND_API.G_MISS_DATE THEN
        x_lsqv_rec.expected_funding_date := l_db_lsqv_rec.expected_funding_date;
      END IF;
      IF x_lsqv_rec.expected_delivery_date = FND_API.G_MISS_DATE THEN
        x_lsqv_rec.expected_delivery_date := l_db_lsqv_rec.expected_delivery_date;
      END IF;
      IF x_lsqv_rec.pricing_method = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.pricing_method := l_db_lsqv_rec.pricing_method;
      END IF;
      IF x_lsqv_rec.term = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.term := l_db_lsqv_rec.term;
      END IF;
      IF x_lsqv_rec.product_id = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.product_id := l_db_lsqv_rec.product_id;
      END IF;
      IF x_lsqv_rec.end_of_term_option_id = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.end_of_term_option_id := l_db_lsqv_rec.end_of_term_option_id;
      END IF;
      IF x_lsqv_rec.structured_pricing = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.structured_pricing := l_db_lsqv_rec.structured_pricing;
      END IF;
      IF x_lsqv_rec.line_level_pricing = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.line_level_pricing := l_db_lsqv_rec.line_level_pricing;
      END IF;
      IF x_lsqv_rec.rate_template_id = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.rate_template_id := l_db_lsqv_rec.rate_template_id;
      END IF;
      IF x_lsqv_rec.rate_card_id = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.rate_card_id := l_db_lsqv_rec.rate_card_id;
      END IF;
      IF x_lsqv_rec.lease_rate_factor = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.lease_rate_factor := l_db_lsqv_rec.lease_rate_factor;
      END IF;
      IF x_lsqv_rec.target_rate_type = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.target_rate_type := l_db_lsqv_rec.target_rate_type;
      END IF;
      IF x_lsqv_rec.target_rate = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.target_rate := l_db_lsqv_rec.target_rate;
      END IF;
      IF x_lsqv_rec.target_amount = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.target_amount := l_db_lsqv_rec.target_amount;
      END IF;
      IF x_lsqv_rec.target_frequency = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.target_frequency := l_db_lsqv_rec.target_frequency;
      END IF;
      IF x_lsqv_rec.target_arrears_yn = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.target_arrears_yn := l_db_lsqv_rec.target_arrears_yn;
      END IF;
      IF x_lsqv_rec.target_periods = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.target_periods := l_db_lsqv_rec.target_periods;
      END IF;
      IF x_lsqv_rec.iir = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.iir := l_db_lsqv_rec.iir;
      END IF;
      IF x_lsqv_rec.booking_yield = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.booking_yield := l_db_lsqv_rec.booking_yield;
      END IF;
      IF x_lsqv_rec.pirr = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.pirr := l_db_lsqv_rec.pirr;
      END IF;
      IF x_lsqv_rec.airr = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.airr := l_db_lsqv_rec.airr;
      END IF;
      IF x_lsqv_rec.sub_iir = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.sub_iir := l_db_lsqv_rec.sub_iir;
      END IF;
      IF x_lsqv_rec.sub_booking_yield = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.sub_booking_yield := l_db_lsqv_rec.sub_booking_yield;
      END IF;
      IF x_lsqv_rec.sub_pirr = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.sub_pirr := l_db_lsqv_rec.sub_pirr;
      END IF;
      IF x_lsqv_rec.sub_airr = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.sub_airr := l_db_lsqv_rec.sub_airr;
      END IF;
      IF x_lsqv_rec.usage_category = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.usage_category := l_db_lsqv_rec.usage_category;
      END IF;
      IF x_lsqv_rec.usage_industry_class = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.usage_industry_class := l_db_lsqv_rec.usage_industry_class;
      END IF;
      IF x_lsqv_rec.usage_industry_code = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.usage_industry_code := l_db_lsqv_rec.usage_industry_code;
      END IF;
      IF x_lsqv_rec.usage_amount = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.usage_amount := l_db_lsqv_rec.usage_amount;
      END IF;
      IF x_lsqv_rec.usage_location_id = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.usage_location_id := l_db_lsqv_rec.usage_location_id;
      END IF;
      IF x_lsqv_rec.property_tax_applicable = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.property_tax_applicable := l_db_lsqv_rec.property_tax_applicable;
      END IF;
      IF x_lsqv_rec.property_tax_billing_type = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.property_tax_billing_type := l_db_lsqv_rec.property_tax_billing_type;
      END IF;
      IF x_lsqv_rec.upfront_tax_treatment = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.upfront_tax_treatment := l_db_lsqv_rec.upfront_tax_treatment;
      END IF;
      IF x_lsqv_rec.upfront_tax_stream_type = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.upfront_tax_stream_type := l_db_lsqv_rec.upfront_tax_stream_type;
      END IF;
      IF x_lsqv_rec.transfer_of_title = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.transfer_of_title := l_db_lsqv_rec.transfer_of_title;
      END IF;
      IF x_lsqv_rec.age_of_equipment = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.age_of_equipment := l_db_lsqv_rec.age_of_equipment;
      END IF;
      IF x_lsqv_rec.purchase_of_lease = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.purchase_of_lease := l_db_lsqv_rec.purchase_of_lease;
      END IF;
      IF x_lsqv_rec.sale_and_lease_back = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.sale_and_lease_back := l_db_lsqv_rec.sale_and_lease_back;
      END IF;
      IF x_lsqv_rec.interest_disclosed = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.interest_disclosed := l_db_lsqv_rec.interest_disclosed;
      END IF;
      IF x_lsqv_rec.primary_quote = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.primary_quote := l_db_lsqv_rec.primary_quote;
      END IF;
      --Bug # 5647107
      IF x_lsqv_rec.legal_entity_id = FND_API.G_MISS_NUM THEN
        x_lsqv_rec.legal_entity_id := l_db_lsqv_rec.legal_entity_id;
      END IF;
      --Bug # 5647107
      -- Bug 5908845. eBTax Enhancement Project
      IF x_lsqv_rec.line_intended_use = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.line_intended_use := l_db_lsqv_rec.line_intended_use;
      END IF;
      -- End Bug 5908845. eBTax Enhancement Project
      IF x_lsqv_rec.short_description = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.short_description := l_db_lsqv_rec.short_description;
      END IF;
      IF x_lsqv_rec.description = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.description := l_db_lsqv_rec.description;
      END IF;
      IF x_lsqv_rec.comments = FND_API.G_MISS_CHAR THEN
        x_lsqv_rec.comments := l_db_lsqv_rec.comments;
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

    l_return_status := populate_new_record (p_lsqv_rec, l_lsqv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_attributes (l_lsqv_rec,'UPDATE');					--Bug 7596781

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record (l_lsqv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_lsqv_rec, l_lsq_rec);
    migrate (l_lsqv_rec, l_lsqtl_rec);

    update_row (x_return_status => l_return_status, p_lsq_rec => l_lsq_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_row (x_return_status => l_return_status, p_lsqtl_rec => l_lsqtl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    x_lsqv_rec      := l_lsqv_rec;

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
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    update_row (x_return_status                => l_return_status,
                p_lsqv_rec                     => p_lsqv_rec,
                x_lsqv_rec                     => x_lsqv_rec);

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
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;
    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_lsqv_tbl := p_lsqv_tbl;

    IF (p_lsqv_tbl.COUNT > 0) THEN

      i := p_lsqv_tbl.FIRST;

      LOOP

        IF p_lsqv_tbl.EXISTS(i) THEN
          update_row (x_return_status                => l_return_status,
                      p_lsqv_rec                     => p_lsqv_tbl(i),
                      x_lsqv_rec                     => x_lsqv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lsqv_tbl.LAST);
          i := p_lsqv_tbl.NEXT(i);

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

    DELETE FROM OKL_LEASE_QUOTES_B WHERE id = p_id;
    DELETE FROM OKL_LEASE_QUOTES_TL WHERE id = p_id;

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
    p_lsqv_rec                     IN lsqv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    delete_row (x_return_status                => l_return_status,
                p_id                           => p_lsqv_rec.id);

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
    p_lsqv_tbl                     IN lsqv_tbl_type) IS

    l_return_status                VARCHAR2(1);
    i                              BINARY_INTEGER;

    l_prog_name                    VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_lsqv_tbl.COUNT > 0) THEN

      i := p_lsqv_tbl.FIRST;

      LOOP

        IF p_lsqv_tbl.EXISTS(i) THEN

          delete_row (x_return_status                => l_return_status,
                      p_id                           => p_lsqv_tbl(i).id);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lsqv_tbl.LAST);
          i := p_lsqv_tbl.NEXT(i);

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


END OKL_LSQ_PVT;

/
