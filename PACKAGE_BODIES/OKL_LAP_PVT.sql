--------------------------------------------------------
--  DDL for Package Body OKL_LAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LAP_PVT" AS
/* $Header: OKLSLAPB.pls 120.5.12010000.2 2008/11/13 13:37:40 kkorrapo ship $ */

 -------------------------
  -- PROCEDURE add_language
  -------------------------
  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_LEASE_APPLICATIONS_TL T
    WHERE NOT EXISTS (
	    SELECT NULL
		  FROM OKL_LEASE_APPS_ALL_B  B
		 WHERE B.ID =T.ID);

    UPDATE OKL_LEASE_APPLICATIONS_TL T
    SET (SHORT_DESCRIPTION,
         COMMENTS) = (SELECT B.SHORT_DESCRIPTION
		                   , B.COMMENTS
                      FROM OKL_LEASE_APPLICATIONS_TL B
                      WHERE B.ID = T.ID
                        AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (T.ID, T.LANGUAGE) IN (SELECT SUBT.ID
	                                  , SUBT.LANGUAGE
                                 FROM OKL_LEASE_APPLICATIONS_TL SUBB
								    , OKL_LEASE_APPLICATIONS_TL SUBT
                                 WHERE SUBB.ID = SUBT.ID
                                   AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                                   AND (SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                                        OR (SUBB.COMMENTS <> SUBT.COMMENTS)
                                        OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                                        OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                                       )
                                );

    INSERT INTO OKL_LEASE_APPLICATIONS_TL (
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
            B.COMMENTS
        FROM OKL_LEASE_APPLICATIONS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_LEASE_APPLICATIONS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  -----------------------------
  -- FUNCTION null_out_defaults
  -----------------------------
  FUNCTION null_out_defaults (p_lapv_rec IN lapv_rec_type) RETURN lapv_rec_type IS

    l_lapv_rec  lapv_rec_type;

  BEGIN

    l_lapv_rec := p_lapv_rec;

    -- Not applicable to ID and OBJECT_VERSION_NUMBER

    IF l_lapv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute_category := NULL;
    END IF;
    IF l_lapv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute1 := NULL;
    END IF;
    IF l_lapv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute2 := NULL;
    END IF;
    IF l_lapv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute3 := NULL;
    END IF;
    IF l_lapv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute4 := NULL;
    END IF;
    IF l_lapv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute5 := NULL;
    END IF;
    IF l_lapv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute6 := NULL;
    END IF;
    IF l_lapv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute7 := NULL;
    END IF;
    IF l_lapv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute8 := NULL;
    END IF;
    IF l_lapv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute9 := NULL;
    END IF;
    IF l_lapv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute10 := NULL;
    END IF;
    IF l_lapv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute11 := NULL;
    END IF;
    IF l_lapv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute12 := NULL;
    END IF;
    IF l_lapv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute13 := NULL;
    END IF;
    IF l_lapv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute14 := NULL;
    END IF;
    IF l_lapv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.attribute15 := NULL;
    END IF;
    IF l_lapv_rec.reference_number = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.reference_number := NULL;
    END IF;
    IF l_lapv_rec.application_status = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.application_status := NULL;
    END IF;
    IF l_lapv_rec.valid_from = FND_API.G_MISS_DATE THEN
      l_lapv_rec.valid_from := NULL;
    END IF;
    IF l_lapv_rec.valid_to = FND_API.G_MISS_DATE THEN
      l_lapv_rec.valid_to := NULL;
    END IF;
    IF l_lapv_rec.org_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.org_id := NULL;
    END IF;
    IF l_lapv_rec.inv_org_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.inv_org_id := NULL;
    END IF;
    IF l_lapv_rec.prospect_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.prospect_id := NULL;
    END IF;
    IF l_lapv_rec.prospect_address_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.prospect_address_id := NULL;
    END IF;
    IF l_lapv_rec.cust_acct_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.cust_acct_id := NULL;
    END IF;
    IF l_lapv_rec.industry_class = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.industry_class := NULL;
    END IF;
    IF l_lapv_rec.industry_code = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.industry_code := NULL;
    END IF;
    IF l_lapv_rec.currency_code = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.currency_code := NULL;
    END IF;
    IF l_lapv_rec.currency_conversion_type = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.currency_conversion_type := NULL;
    END IF;
    IF l_lapv_rec.currency_conversion_rate = FND_API.G_MISS_NUM THEN
      l_lapv_rec.currency_conversion_rate := NULL;
    END IF;
    IF l_lapv_rec.currency_conversion_date = FND_API.G_MISS_DATE THEN
      l_lapv_rec.currency_conversion_date := NULL;
    END IF;
    IF l_lapv_rec.leaseapp_template_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.leaseapp_template_id := NULL;
    END IF;
    IF l_lapv_rec.parent_leaseapp_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.parent_leaseapp_id := NULL;
    END IF;
    IF l_lapv_rec.credit_line_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.credit_line_id := NULL;
    END IF;
    IF l_lapv_rec.program_agreement_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.program_agreement_id := NULL;
    END IF;
    IF l_lapv_rec.master_lease_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.master_lease_id := NULL;
    END IF;
    IF l_lapv_rec.sales_rep_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.sales_rep_id := NULL;
    END IF;
    IF l_lapv_rec.sales_territory_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.sales_territory_id := NULL;
    END IF;
    IF l_lapv_rec.originating_vendor_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.originating_vendor_id := NULL;
    END IF;
    IF l_lapv_rec.lease_opportunity_id = FND_API.G_MISS_NUM THEN
      l_lapv_rec.lease_opportunity_id := NULL;
    END IF;
    IF l_lapv_rec.short_description = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.short_description := NULL;
    END IF;
    IF l_lapv_rec.comments = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.comments := NULL;
    END IF;
    --VARANGAN for bug#4747179
    IF l_lapv_rec.cr_exp_days = FND_API.G_MISS_NUM THEN
      l_lapv_rec.cr_exp_days := NULL;
    END IF;
    --VARANGAN for bug#4747179
    --Bug 4872271 PAGARG start
    IF l_lapv_rec.action = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.action := NULL;
    END IF;
    IF l_lapv_rec.orig_status = FND_API.G_MISS_CHAR THEN
      l_lapv_rec.orig_status := NULL;
    END IF;
    --Bug 4872271 PAGARG end
    RETURN l_lapv_rec;

  END null_out_defaults;

  -------------------
  -- FUNCTION get_rec
  -------------------
  FUNCTION get_rec (p_id             IN         NUMBER
                    ,x_return_status OUT NOCOPY VARCHAR2) RETURN lapv_rec_type IS

    l_lapv_rec           lapv_rec_type;
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
      ,application_status
      ,valid_from
      ,valid_to
      ,org_id
      ,inv_org_id
      ,prospect_id
      ,prospect_address_id
      ,cust_acct_id
      ,industry_class
      ,industry_code
      ,currency_code
      ,currency_conversion_type
      ,currency_conversion_rate
      ,currency_conversion_date
      ,leaseapp_template_id
      ,parent_leaseapp_id
      ,credit_line_id
      ,program_agreement_id
      ,master_lease_id
      ,sales_rep_id
      ,sales_territory_id
      ,originating_vendor_id
      ,lease_opportunity_id
      ,short_description
      ,comments
      ,cr_exp_days --VARANGAN for bug#4747179
      ,action
      ,orig_status
    INTO
      l_lapv_rec.id
      ,l_lapv_rec.object_version_number
      ,l_lapv_rec.attribute_category
      ,l_lapv_rec.attribute1
      ,l_lapv_rec.attribute2
      ,l_lapv_rec.attribute3
      ,l_lapv_rec.attribute4
      ,l_lapv_rec.attribute5
      ,l_lapv_rec.attribute6
      ,l_lapv_rec.attribute7
      ,l_lapv_rec.attribute8
      ,l_lapv_rec.attribute9
      ,l_lapv_rec.attribute10
      ,l_lapv_rec.attribute11
      ,l_lapv_rec.attribute12
      ,l_lapv_rec.attribute13
      ,l_lapv_rec.attribute14
      ,l_lapv_rec.attribute15
      ,l_lapv_rec.reference_number
      ,l_lapv_rec.application_status
      ,l_lapv_rec.valid_from
      ,l_lapv_rec.valid_to
      ,l_lapv_rec.org_id
      ,l_lapv_rec.inv_org_id
      ,l_lapv_rec.prospect_id
      ,l_lapv_rec.prospect_address_id
      ,l_lapv_rec.cust_acct_id
      ,l_lapv_rec.industry_class
      ,l_lapv_rec.industry_code
      ,l_lapv_rec.currency_code
      ,l_lapv_rec.currency_conversion_type
      ,l_lapv_rec.currency_conversion_rate
      ,l_lapv_rec.currency_conversion_date
      ,l_lapv_rec.leaseapp_template_id
      ,l_lapv_rec.parent_leaseapp_id
      ,l_lapv_rec.credit_line_id
      ,l_lapv_rec.program_agreement_id
      ,l_lapv_rec.master_lease_id
      ,l_lapv_rec.sales_rep_id
      ,l_lapv_rec.sales_territory_id
      ,l_lapv_rec.originating_vendor_id
      ,l_lapv_rec.lease_opportunity_id
      ,l_lapv_rec.short_description
      ,l_lapv_rec.comments
      ,l_lapv_rec.cr_exp_days  --VARANGAN for bug#4747179
      ,l_lapv_rec.action
      ,l_lapv_rec.orig_status
    FROM okl_lease_applications_v
    WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_lapv_rec;

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
    IF (p_id = OKL_API.G_MISS_NUM OR
	    p_id IS NULL)
	THEN
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
    IF (p_object_version_number = OKL_API.G_MISS_NUM OR
	    p_object_version_number IS NULL)
	THEN
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
    IF (p_reference_number = OKL_API.G_MISS_CHAR OR
	    p_reference_number IS NULL)
	THEN
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
  -- PROCEDURE validate_application_status
  -----------------------------------------
  PROCEDURE validate_application_status (x_return_status OUT NOCOPY VARCHAR2, p_application_status IN VARCHAR2) IS
  BEGIN
    IF (p_application_status = OKL_API.G_MISS_CHAR OR
	    p_application_status IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'application_status',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;
  END validate_application_status;

  -----------------------------------------
  -- PROCEDURE validate_valid_from
  -----------------------------------------
  PROCEDURE validate_valid_from (x_return_status OUT NOCOPY VARCHAR2, p_valid_from IN DATE) IS
  BEGIN
    IF (p_valid_from = OKL_API.G_MISS_DATE OR
	    p_valid_from IS NULL)
	THEN
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

  ----------------------------
  -- PROCEDURE validate_org_id
  ----------------------------
  PROCEDURE validate_org_id (x_return_status OUT NOCOPY VARCHAR2, p_org_id IN NUMBER) IS
  BEGIN
    IF (p_org_id = OKL_API.G_MISS_NUM OR
	    p_org_id IS NULL)
	THEN
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
    IF (p_inv_org_id = OKL_API.G_MISS_NUM OR
	    p_inv_org_id IS NULL)
	THEN
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
    IF (p_prospect_id = OKL_API.G_MISS_NUM OR
	    p_prospect_id IS NULL)
	THEN
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
    IF (p_prospect_address_id = OKL_API.G_MISS_NUM OR
	    p_prospect_address_id IS NULL)
	THEN
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
    IF (p_currency_code = OKL_API.G_MISS_CHAR OR
	    p_currency_code IS NULL)
	THEN
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

  -----------------------------------------
  -- PROCEDURE validate_leaseapp_template_id
  -----------------------------------------
  PROCEDURE validate_leaseapp_template_id (x_return_status OUT NOCOPY VARCHAR2, p_leaseapp_template_id IN NUMBER) IS
  BEGIN
    IF (p_leaseapp_template_id = OKL_API.G_MISS_NUM OR
	    p_leaseapp_template_id IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'leaseapp_template_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_leaseapp_template_id;

  -------------------------------
  -- FUNCTION validate_attributes
  -------------------------------
  FUNCTION validate_attributes (p_lapv_rec IN lapv_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);

  BEGIN

    validate_id (l_return_status, p_lapv_rec.id);
    validate_object_version_number (l_return_status, p_lapv_rec.object_version_number);
    validate_reference_number (l_return_status, p_lapv_rec.reference_number);
    validate_application_status (l_return_status, p_lapv_rec.application_status);
    validate_valid_from (l_return_status, p_lapv_rec.valid_from);
    validate_org_id (l_return_status, p_lapv_rec.org_id);
    validate_inv_org_id (l_return_status, p_lapv_rec.inv_org_id);
    validate_prospect_id (l_return_status, p_lapv_rec.prospect_id);
    validate_prospect_address_id (l_return_status, p_lapv_rec.prospect_address_id);
    validate_currency_code (l_return_status, p_lapv_rec.currency_code);
    validate_leaseapp_template_id (l_return_status, p_lapv_rec.leaseapp_template_id);

    RETURN l_return_status;

  END validate_attributes;

  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  FUNCTION validate_record (p_lapv_rec IN lapv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1);
    --Cursor to check uniqueness of Lease Application Number
    CURSOR chk_lse_app_num_csr(cp_lse_app_num VARCHAR2
                              ,cp_lse_app_id NUMBER) IS
      SELECT 'x'
        FROM OKL_LEASE_APPLICATIONS_B
       WHERE UPPER(REFERENCE_NUMBER) = UPPER(cp_lse_app_num)
         AND id <> cp_lse_app_id;

    l_dummy VARCHAR2(1);
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    --If Valid To is not null and is less than or equal to Valid From then error
    IF(NVL(p_lapv_rec.valid_to, TO_DATE('31-12-9999', 'dd-mm-yyyy')) <= p_lapv_rec.valid_from)
    THEN
      OKL_API.SET_MESSAGE(
          p_app_name      => G_APP_NAME,
          p_msg_name      => 'OKL_GREATER_THAN',
          p_token1        => 'COL_NAME1',
          p_token1_value  => 'valid_to',
          p_token2        => 'COL_NAME2',
          p_token2_value  => 'valid_from');
      l_return_status := G_RET_STS_ERROR;
    END IF;
    -- End Valid To validation

    --check uniqueness of Lease Application Number
    IF(l_return_status = G_RET_STS_SUCCESS)
    THEN
      OPEN chk_lse_app_num_csr(p_lapv_rec.reference_number
                              ,p_lapv_rec.id);
      FETCH chk_lse_app_num_csr INTO l_dummy;
        IF chk_lse_app_num_csr%FOUND
        THEN
          l_return_status := G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_SO_LSE_APP_NOT_UNIQ',
              p_token1        => 'TEXT',
              p_token1_value  => p_lapv_rec.reference_number);
        END IF;
      CLOSE chk_lse_app_num_csr;
    END IF;--End Lease Application Number uniquenes check

    RETURN l_return_status;
  END validate_record;

  -----------------------------
  -- PROECDURE migrate (V -> B)
  -----------------------------
  PROCEDURE migrate (p_from IN lapv_rec_type, p_to IN OUT NOCOPY lap_rec_type) IS

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
    p_to.application_status             :=  p_from.application_status;
    p_to.valid_from                     :=  p_from.valid_from;
    p_to.valid_to                       :=  p_from.valid_to;
    p_to.org_id                         :=  p_from.org_id;
    p_to.inv_org_id                     :=  p_from.inv_org_id;
    p_to.prospect_id                    :=  p_from.prospect_id;
    p_to.prospect_address_id            :=  p_from.prospect_address_id;
    p_to.cust_acct_id                   :=  p_from.cust_acct_id;
    p_to.industry_class                 :=  p_from.industry_class;
    p_to.industry_code                  :=  p_from.industry_code;
    p_to.currency_code                  :=  p_from.currency_code;
    p_to.currency_conversion_type       :=  p_from.currency_conversion_type;
    p_to.currency_conversion_rate       :=  p_from.currency_conversion_rate;
    p_to.currency_conversion_date       :=  p_from.currency_conversion_date;
    p_to.leaseapp_template_id           :=  p_from.leaseapp_template_id;
    p_to.parent_leaseapp_id             :=  p_from.parent_leaseapp_id;
    p_to.credit_line_id                 :=  p_from.credit_line_id;
    p_to.program_agreement_id           :=  p_from.program_agreement_id;
    p_to.master_lease_id                :=  p_from.master_lease_id;
    p_to.sales_rep_id                   :=  p_from.sales_rep_id;
    p_to.sales_territory_id             :=  p_from.sales_territory_id;
    p_to.originating_vendor_id          :=  p_from.originating_vendor_id;
    p_to.lease_opportunity_id           :=  p_from.lease_opportunity_id;
    p_to.cr_exp_days                    :=  p_from.cr_exp_days; --VARANGAN for bug#4747179
    p_to.action                         :=  p_from.action;
    p_to.orig_status                    :=  p_from.orig_status;
  END migrate;

  -----------------------------
  -- PROCEDURE migrate (V -> TL)
  -----------------------------
  PROCEDURE migrate (p_from IN lapv_rec_type, p_to IN OUT NOCOPY laptl_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
  END migrate;

  ---------------------------
  -- PROCEDURE insert_row (B)
  ---------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_lap_rec IN lap_rec_type) IS

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (B)';

    INSERT INTO okl_lease_applications_b (
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
      ,application_status
      ,valid_from
      ,valid_to
      ,org_id
      ,inv_org_id
      ,prospect_id
      ,prospect_address_id
      ,cust_acct_id
      ,industry_class
      ,industry_code
      ,currency_code
      ,currency_conversion_type
      ,currency_conversion_rate
      ,currency_conversion_date
      ,leaseapp_template_id
      ,parent_leaseapp_id
      ,credit_line_id
      ,program_agreement_id
      ,master_lease_id
      ,sales_rep_id
      ,sales_territory_id
      ,originating_vendor_id
      ,lease_opportunity_id
      ,cr_exp_days  --VARANGAN for bug#4747179
      ,action
      ,orig_status
      )
    VALUES
      (
       p_lap_rec.id
      ,p_lap_rec.object_version_number
      ,p_lap_rec.attribute_category
      ,p_lap_rec.attribute1
      ,p_lap_rec.attribute2
      ,p_lap_rec.attribute3
      ,p_lap_rec.attribute4
      ,p_lap_rec.attribute5
      ,p_lap_rec.attribute6
      ,p_lap_rec.attribute7
      ,p_lap_rec.attribute8
      ,p_lap_rec.attribute9
      ,p_lap_rec.attribute10
      ,p_lap_rec.attribute11
      ,p_lap_rec.attribute12
      ,p_lap_rec.attribute13
      ,p_lap_rec.attribute14
      ,p_lap_rec.attribute15
      ,G_USER_ID
      ,SYSDATE
      ,G_USER_ID
      ,SYSDATE
      ,G_LOGIN_ID
      ,p_lap_rec.reference_number
      ,p_lap_rec.application_status
      ,p_lap_rec.valid_from
      ,p_lap_rec.valid_to
      ,p_lap_rec.org_id
      ,p_lap_rec.inv_org_id
      ,p_lap_rec.prospect_id
      ,p_lap_rec.prospect_address_id
      ,p_lap_rec.cust_acct_id
      ,p_lap_rec.industry_class
      ,p_lap_rec.industry_code
      ,p_lap_rec.currency_code
      ,p_lap_rec.currency_conversion_type
      ,p_lap_rec.currency_conversion_rate
      ,p_lap_rec.currency_conversion_date
      ,p_lap_rec.leaseapp_template_id
      ,p_lap_rec.parent_leaseapp_id
      ,p_lap_rec.credit_line_id
      ,p_lap_rec.program_agreement_id
      ,p_lap_rec.master_lease_id
      ,p_lap_rec.sales_rep_id
      ,p_lap_rec.sales_territory_id
      ,p_lap_rec.originating_vendor_id
      ,p_lap_rec.lease_opportunity_id
      ,p_lap_rec.cr_exp_days --VARANGAN for bug#4747179
      ,p_lap_rec.action
      ,p_lap_rec.orig_status
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
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_laptl_rec IN laptl_rec_type) IS

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

      INSERT INTO OKL_LEASE_APPLICATIONS_TL (
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
       ,comments)
      VALUES (
        p_laptl_rec.id
       ,l_lang_rec.language_code
       ,USERENV('LANG')
       ,l_sfwt_flag
       ,G_USER_ID
       ,SYSDATE
       ,G_USER_ID
       ,SYSDATE
       ,G_LOGIN_ID
       ,p_laptl_rec.short_description
       ,p_laptl_rec.comments);

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
    p_lapv_rec                     IN lapv_rec_type,
    x_lapv_rec                     OUT NOCOPY lapv_rec_type) IS

    l_return_status                VARCHAR2(1);

    l_lapv_rec                     lapv_rec_type;
    l_lap_rec                      lap_rec_type;
    l_laptl_rec                    laptl_rec_type;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (V)';

    l_lapv_rec                       := null_out_defaults (p_lapv_rec);

    SELECT okl_lap_seq.nextval INTO l_lapv_rec.ID FROM DUAL;

    l_lapv_rec.OBJECT_VERSION_NUMBER := 1;

    l_return_status := validate_attributes(l_lapv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug 7022258-Added by kkorrapo
    IF (okl_util.validate_seq_num('OKL_LAP_REF_SEQ','OKL_LEASE_APPLICATIONS_B','REFERENCE_NUMBER',l_lapv_rec.reference_number) = 'N') THEN
      RAISE okl_api.g_exception_error;
    END IF;
    --Bug 7022258--Addition end

    l_return_status := validate_record(l_lapv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_lapv_rec, l_lap_rec);
    migrate (l_lapv_rec, l_laptl_rec);

    insert_row (x_return_status => l_return_status, p_lap_rec => l_lap_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_row (x_return_status => l_return_status, p_laptl_rec => l_laptl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_lapv_rec      := l_lapv_rec;
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
    p_lapv_rec                     IN lapv_rec_type,
    x_lapv_rec                     OUT NOCOPY lapv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    insert_row (x_return_status                => l_return_status,
                p_lapv_rec                     => p_lapv_rec,
                x_lapv_rec                     => x_lapv_rec);

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
    p_lapv_tbl                     IN lapv_tbl_type,
    x_lapv_tbl                     OUT NOCOPY lapv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_lapv_tbl.COUNT > 0) THEN
      i := p_lapv_tbl.FIRST;
      LOOP
        IF p_lapv_tbl.EXISTS(i) THEN

          insert_row (x_return_status                => l_return_status,
                      p_lapv_rec                     => p_lapv_tbl(i),
                      x_lapv_rec                     => x_lapv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lapv_tbl.LAST);
          i := p_lapv_tbl.NEXT(i);

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
  PROCEDURE lock_row (x_return_status OUT NOCOPY VARCHAR2, p_lap_rec IN lap_rec_type) IS

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT (E_Resource_Busy, -00054);

    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LEASE_APPLICATIONS_B
     WHERE ID = p_lap_rec.id
       AND OBJECT_VERSION_NUMBER = p_lap_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LEASE_APPLICATIONS_B
     WHERE ID = p_lap_rec.id;

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

      ELSIF lc_object_version_number <> p_lap_rec.object_version_number THEN

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_lap_rec IN lap_rec_type) IS

    l_return_status           VARCHAR2(1);

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (B)';

    lock_row (x_return_status => l_return_status, p_lap_rec => p_lap_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE okl_lease_applications_b
    SET
      object_version_number = p_lap_rec.object_version_number+1
      ,attribute_category = p_lap_rec.attribute_category
      ,attribute1 = p_lap_rec.attribute1
      ,attribute2 = p_lap_rec.attribute2
      ,attribute3 = p_lap_rec.attribute3
      ,attribute4 = p_lap_rec.attribute4
      ,attribute5 = p_lap_rec.attribute5
      ,attribute6 = p_lap_rec.attribute6
      ,attribute7 = p_lap_rec.attribute7
      ,attribute8 = p_lap_rec.attribute8
      ,attribute9 = p_lap_rec.attribute9
      ,attribute10 = p_lap_rec.attribute10
      ,attribute11 = p_lap_rec.attribute11
      ,attribute12 = p_lap_rec.attribute12
      ,attribute13 = p_lap_rec.attribute13
      ,attribute14 = p_lap_rec.attribute14
      ,attribute15 = p_lap_rec.attribute15
      ,reference_number = p_lap_rec.reference_number
      ,application_status = p_lap_rec.application_status
      ,valid_from = p_lap_rec.valid_from
      ,valid_to = p_lap_rec.valid_to
      ,org_id = p_lap_rec.org_id
      ,inv_org_id = p_lap_rec.inv_org_id
      ,prospect_id = p_lap_rec.prospect_id
      ,prospect_address_id = p_lap_rec.prospect_address_id
      ,cust_acct_id = p_lap_rec.cust_acct_id
      ,industry_class = p_lap_rec.industry_class
      ,industry_code = p_lap_rec.industry_code
      ,currency_code = p_lap_rec.currency_code
      ,currency_conversion_type = p_lap_rec.currency_conversion_type
      ,currency_conversion_rate = p_lap_rec.currency_conversion_rate
      ,currency_conversion_date = p_lap_rec.currency_conversion_date
      ,leaseapp_template_id = p_lap_rec.leaseapp_template_id
      ,parent_leaseapp_id = p_lap_rec.parent_leaseapp_id
      ,credit_line_id = p_lap_rec.credit_line_id
      ,program_agreement_id = p_lap_rec.program_agreement_id
      ,master_lease_id = p_lap_rec.master_lease_id
      ,sales_rep_id = p_lap_rec.sales_rep_id
      ,sales_territory_id = p_lap_rec.sales_territory_id
      ,originating_vendor_id = p_lap_rec.originating_vendor_id
      ,lease_opportunity_id = p_lap_rec.lease_opportunity_id
      ,cr_exp_days = p_lap_rec.cr_exp_days --VARANGAN for bug#4747179
      ,action = p_lap_rec.action
      ,orig_status = p_lap_rec.orig_status
    WHERE id = p_lap_rec.id;

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_laptl_rec IN laptl_rec_type) IS

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TL)';

    UPDATE OKL_LEASE_APPLICATIONS_TL
    SET
      source_lang = USERENV('LANG')
      ,sfwt_flag = 'Y'
      ,last_updated_by = G_USER_ID
      ,last_update_date = SYSDATE
      ,last_update_login = G_LOGIN_ID
      ,short_description = p_laptl_rec.short_description
      ,comments = p_laptl_rec.comments
    WHERE ID = p_laptl_rec.id;

    UPDATE OKL_LEASE_APPLICATIONS_TL
    SET SFWT_FLAG = 'N'
    WHERE ID = p_laptl_rec.id
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
    p_lapv_rec                     IN lapv_rec_type,
    x_lapv_rec                     OUT NOCOPY lapv_rec_type) IS

    l_prog_name                    VARCHAR2(61);

    l_return_status                VARCHAR2(1);
    l_lapv_rec                     lapv_rec_type;
    l_lap_rec                      lap_rec_type;
    l_laptl_rec                    laptl_rec_type;

    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_lapv_rec IN  lapv_rec_type,
                                  x_lapv_rec OUT NOCOPY lapv_rec_type) RETURN VARCHAR2 IS

      l_prog_name          VARCHAR2(61)          := G_PKG_NAME||'.populate_new_record';
      l_return_status      VARCHAR2(1);
      l_db_lapv_rec        lapv_rec_type;

    BEGIN
      x_lapv_rec    := p_lapv_rec;
      l_db_lapv_rec := get_rec (p_lapv_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF x_lapv_rec.attribute_category IS NULL THEN
        x_lapv_rec.attribute_category := l_db_lapv_rec.attribute_category;
      END IF;
      IF x_lapv_rec.attribute1 IS NULL THEN
        x_lapv_rec.attribute1 := l_db_lapv_rec.attribute1;
      END IF;
      IF x_lapv_rec.attribute2 IS NULL THEN
        x_lapv_rec.attribute2 := l_db_lapv_rec.attribute2;
      END IF;
      IF x_lapv_rec.attribute3 IS NULL THEN
        x_lapv_rec.attribute3 := l_db_lapv_rec.attribute3;
      END IF;
      IF x_lapv_rec.attribute4 IS NULL THEN
        x_lapv_rec.attribute4 := l_db_lapv_rec.attribute4;
      END IF;
      IF x_lapv_rec.attribute5 IS NULL THEN
        x_lapv_rec.attribute5 := l_db_lapv_rec.attribute5;
      END IF;
      IF x_lapv_rec.attribute6 IS NULL THEN
        x_lapv_rec.attribute6 := l_db_lapv_rec.attribute6;
      END IF;
      IF x_lapv_rec.attribute7 IS NULL THEN
        x_lapv_rec.attribute7 := l_db_lapv_rec.attribute7;
      END IF;
      IF x_lapv_rec.attribute8 IS NULL THEN
        x_lapv_rec.attribute8 := l_db_lapv_rec.attribute8;
      END IF;
      IF x_lapv_rec.attribute9 IS NULL THEN
        x_lapv_rec.attribute9 := l_db_lapv_rec.attribute9;
      END IF;
      IF x_lapv_rec.attribute10 IS NULL THEN
        x_lapv_rec.attribute10 := l_db_lapv_rec.attribute10;
      END IF;
      IF x_lapv_rec.attribute11 IS NULL THEN
        x_lapv_rec.attribute11 := l_db_lapv_rec.attribute11;
      END IF;
      IF x_lapv_rec.attribute12 IS NULL THEN
        x_lapv_rec.attribute12 := l_db_lapv_rec.attribute12;
      END IF;
      IF x_lapv_rec.attribute13 IS NULL THEN
        x_lapv_rec.attribute13 := l_db_lapv_rec.attribute13;
      END IF;
      IF x_lapv_rec.attribute14 IS NULL THEN
        x_lapv_rec.attribute14 := l_db_lapv_rec.attribute14;
      END IF;
      IF x_lapv_rec.attribute15 IS NULL THEN
        x_lapv_rec.attribute15 := l_db_lapv_rec.attribute15;
      END IF;
      IF x_lapv_rec.object_version_number IS NULL THEN
        x_lapv_rec.object_version_number := l_db_lapv_rec.object_version_number;
      END IF;
      IF x_lapv_rec.reference_number IS NULL THEN
        x_lapv_rec.reference_number := l_db_lapv_rec.reference_number;
      END IF;
      IF x_lapv_rec.application_status IS NULL THEN
        x_lapv_rec.application_status := l_db_lapv_rec.application_status;
      END IF;
      IF x_lapv_rec.valid_from IS NULL THEN
        x_lapv_rec.valid_from := l_db_lapv_rec.valid_from;
      END IF;
      IF x_lapv_rec.valid_to IS NULL THEN
        x_lapv_rec.valid_to := l_db_lapv_rec.valid_to;
      END IF;
      IF x_lapv_rec.org_id IS NULL THEN
        x_lapv_rec.org_id := l_db_lapv_rec.org_id;
      END IF;
      IF x_lapv_rec.inv_org_id IS NULL THEN
        x_lapv_rec.inv_org_id := l_db_lapv_rec.inv_org_id;
      END IF;
      IF x_lapv_rec.prospect_id IS NULL THEN
        x_lapv_rec.prospect_id := l_db_lapv_rec.prospect_id;
      END IF;
      IF x_lapv_rec.prospect_address_id IS NULL THEN
        x_lapv_rec.prospect_address_id := l_db_lapv_rec.prospect_address_id;
      END IF;
      IF x_lapv_rec.cust_acct_id IS NULL THEN
        x_lapv_rec.cust_acct_id := l_db_lapv_rec.cust_acct_id;
      END IF;
      IF x_lapv_rec.industry_class IS NULL THEN
        x_lapv_rec.industry_class := l_db_lapv_rec.industry_class;
      END IF;
      IF x_lapv_rec.industry_code IS NULL THEN
        x_lapv_rec.industry_code := l_db_lapv_rec.industry_code;
      END IF;
      IF x_lapv_rec.currency_code IS NULL THEN
        x_lapv_rec.currency_code := l_db_lapv_rec.currency_code;
      END IF;
      IF x_lapv_rec.currency_conversion_type IS NULL THEN
        x_lapv_rec.currency_conversion_type := l_db_lapv_rec.currency_conversion_type;
      END IF;
      IF x_lapv_rec.currency_conversion_rate IS NULL THEN
        x_lapv_rec.currency_conversion_rate := l_db_lapv_rec.currency_conversion_rate;
      END IF;
      IF x_lapv_rec.currency_conversion_date IS NULL THEN
        x_lapv_rec.currency_conversion_date := l_db_lapv_rec.currency_conversion_date;
      END IF;
      IF x_lapv_rec.leaseapp_template_id IS NULL THEN
        x_lapv_rec.leaseapp_template_id := l_db_lapv_rec.leaseapp_template_id;
      END IF;
      IF x_lapv_rec.parent_leaseapp_id IS NULL THEN
        x_lapv_rec.parent_leaseapp_id := l_db_lapv_rec.parent_leaseapp_id;
      END IF;
      IF x_lapv_rec.credit_line_id IS NULL THEN
        x_lapv_rec.credit_line_id := l_db_lapv_rec.credit_line_id;
      END IF;
      IF x_lapv_rec.program_agreement_id IS NULL THEN
        x_lapv_rec.program_agreement_id := l_db_lapv_rec.program_agreement_id;
      END IF;
      IF x_lapv_rec.master_lease_id IS NULL THEN
        x_lapv_rec.master_lease_id := l_db_lapv_rec.master_lease_id;
      END IF;
      IF x_lapv_rec.sales_rep_id IS NULL THEN
        x_lapv_rec.sales_rep_id := l_db_lapv_rec.sales_rep_id;
      END IF;
      IF x_lapv_rec.sales_territory_id IS NULL THEN
        x_lapv_rec.sales_territory_id := l_db_lapv_rec.sales_territory_id;
      END IF;
      IF x_lapv_rec.originating_vendor_id IS NULL THEN
        x_lapv_rec.originating_vendor_id := l_db_lapv_rec.originating_vendor_id;
      END IF;
      IF x_lapv_rec.lease_opportunity_id IS NULL THEN
        x_lapv_rec.lease_opportunity_id := l_db_lapv_rec.lease_opportunity_id;
      END IF;
      IF x_lapv_rec.short_description IS NULL THEN
        x_lapv_rec.short_description := l_db_lapv_rec.short_description;
      END IF;
      IF x_lapv_rec.comments IS NULL THEN
        x_lapv_rec.comments := l_db_lapv_rec.comments;
      END IF;
      --VARANGAN for bug#4747179
      IF x_lapv_rec.cr_exp_days IS NULL THEN
        x_lapv_rec.cr_exp_days := l_db_lapv_rec.cr_exp_days;
      END IF;
     --VARANGAN for bug#4747179
      --Bug 4872271 PAGARG start
      IF x_lapv_rec.action IS NULL THEN
        x_lapv_rec.action := l_db_lapv_rec.action;
      END IF;
      IF x_lapv_rec.orig_status IS NULL THEN
        x_lapv_rec.orig_status := l_db_lapv_rec.orig_status;
      END IF;
      --Bug 4872271 PAGARG end
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

    l_return_status := populate_new_record (p_lapv_rec, l_lapv_rec);
    l_lapv_rec      := null_out_defaults(l_lapv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_attributes (l_lapv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record (l_lapv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_lapv_rec, l_lap_rec);
    migrate (l_lapv_rec, l_laptl_rec);

    update_row (x_return_status => l_return_status, p_lap_rec => l_lap_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_row (x_return_status => l_return_status, p_laptl_rec => l_laptl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    x_lapv_rec      := l_lapv_rec;

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
    p_lapv_rec                     IN lapv_rec_type,
    x_lapv_rec                     OUT NOCOPY lapv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    update_row (x_return_status                => l_return_status,
                p_lapv_rec                     => p_lapv_rec,
                x_lapv_rec                     => x_lapv_rec);

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
    p_lapv_tbl                     IN lapv_tbl_type,
    x_lapv_tbl                     OUT NOCOPY lapv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;
    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_lapv_tbl := p_lapv_tbl;

    IF (p_lapv_tbl.COUNT > 0) THEN

      i := p_lapv_tbl.FIRST;

      LOOP

        IF p_lapv_tbl.EXISTS(i) THEN
          update_row (x_return_status                => l_return_status,
                      p_lapv_rec                     => p_lapv_tbl(i),
                      x_lapv_rec                     => x_lapv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lapv_tbl.LAST);
          i := p_lapv_tbl.NEXT(i);

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

    DELETE FROM OKL_LEASE_APPLICATIONS_B WHERE id = p_id;
    DELETE FROM OKL_LEASE_APPLICATIONS_TL WHERE id = p_id;

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
    p_lapv_rec                     IN lapv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    delete_row (x_return_status                => l_return_status,
                p_id                           => p_lapv_rec.id);

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
    p_lapv_tbl                     IN lapv_tbl_type) IS

    l_return_status                VARCHAR2(1);
    i                              BINARY_INTEGER;

    l_prog_name                    VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_lapv_tbl.COUNT > 0) THEN

      i := p_lapv_tbl.FIRST;

      LOOP

        IF p_lapv_tbl.EXISTS(i) THEN

          delete_row (x_return_status                => l_return_status,
                      p_id                           => p_lapv_tbl(i).id);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lapv_tbl.LAST);
          i := p_lapv_tbl.NEXT(i);

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

END OKL_LAP_PVT;

/
