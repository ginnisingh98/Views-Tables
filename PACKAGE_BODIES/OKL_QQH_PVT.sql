--------------------------------------------------------
--  DDL for Package Body OKL_QQH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QQH_PVT" AS
/* $Header: OKLSQQHB.pls 120.2.12010000.4 2008/11/17 10:58:39 kkorrapo ship $ */

  -------------------------
  -- PROCEDURE add_language
  -------------------------
  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_QUICK_QUOTES_TL T
    WHERE NOT EXISTS (SELECT NULL FROM OKL_QUICK_QUOTES_ALL_B B WHERE B.ID =T.ID);

    UPDATE OKL_QUICK_QUOTES_TL T
    SET (SHORT_DESCRIPTION,
        DESCRIPTION,
        COMMENTS) =
                     (SELECT
                      B.SHORT_DESCRIPTION,
                      B.DESCRIPTION,
                      B.COMMENTS
                      FROM
                      OKL_QUICK_QUOTES_TL B
                      WHERE
                      B.ID = T.ID
                      AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (T.ID, T.LANGUAGE) IN (SELECT
                                 SUBT.ID,
                                 SUBT.LANGUAGE
                                 FROM
                                 OKL_QUICK_QUOTES_TL SUBB,
                                 OKL_QUICK_QUOTES_TL SUBT
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

    INSERT INTO OKL_QUICK_QUOTES_TL (
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
        FROM OKL_QUICK_QUOTES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_QUICK_QUOTES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;


  -----------------------------
  -- FUNCTION null_out_defaults
  -----------------------------
  FUNCTION null_out_defaults (p_qqhv_rec IN qqhv_rec_type) RETURN qqhv_rec_type IS

    l_qqhv_rec  qqhv_rec_type;

  BEGIN

    l_qqhv_rec := p_qqhv_rec;

    -- Not applicable to ID and OBJECT_VERSION_NUMBER

    IF l_qqhv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute_category := NULL;
    END IF;
    IF l_qqhv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute1 := NULL;
    END IF;
    IF l_qqhv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute2 := NULL;
    END IF;
    IF l_qqhv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute3 := NULL;
    END IF;
    IF l_qqhv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute4 := NULL;
    END IF;
    IF l_qqhv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute5 := NULL;
    END IF;
    IF l_qqhv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute6 := NULL;
    END IF;
    IF l_qqhv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute7 := NULL;
    END IF;
    IF l_qqhv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute8 := NULL;
    END IF;
    IF l_qqhv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute9 := NULL;
    END IF;
    IF l_qqhv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute10 := NULL;
    END IF;
    IF l_qqhv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute11 := NULL;
    END IF;
    IF l_qqhv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute12 := NULL;
    END IF;
    IF l_qqhv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute13 := NULL;
    END IF;
    IF l_qqhv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute14 := NULL;
    END IF;
    IF l_qqhv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.attribute15 := NULL;
    END IF;
    IF l_qqhv_rec.reference_number = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.reference_number := NULL;
    END IF;
    IF l_qqhv_rec.expected_start_date = FND_API.G_MISS_DATE THEN
      l_qqhv_rec.expected_start_date := NULL;
    END IF;
    IF l_qqhv_rec.org_id = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.org_id := NULL;
    END IF;
    IF l_qqhv_rec.inv_org_id = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.inv_org_id := NULL;
    END IF;
    IF l_qqhv_rec.currency_code = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.currency_code := NULL;
    END IF;
    IF l_qqhv_rec.term = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.term := NULL;
    END IF;
    IF l_qqhv_rec.end_of_term_option_id = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.end_of_term_option_id := NULL;
    END IF;
    IF l_qqhv_rec.pricing_method = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.pricing_method := NULL;
    END IF;
    IF l_qqhv_rec.lease_opportunity_id = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.lease_opportunity_id := NULL;
    END IF;
    IF l_qqhv_rec.originating_vendor_id = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.originating_vendor_id := NULL;
    END IF;
    IF l_qqhv_rec.program_agreement_id = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.program_agreement_id := NULL;
    END IF;
    IF l_qqhv_rec.sales_rep_id = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.sales_rep_id := NULL;
    END IF;
    IF l_qqhv_rec.sales_territory_id = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.sales_territory_id := NULL;
    END IF;
    IF l_qqhv_rec.structured_pricing = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.structured_pricing := NULL;
    END IF;
    IF l_qqhv_rec.line_level_pricing = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.line_level_pricing := NULL;
    END IF;
    IF l_qqhv_rec.rate_template_id = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.rate_template_id := NULL;
    END IF;
    IF l_qqhv_rec.rate_card_id = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.rate_card_id := NULL;
    END IF;
    IF l_qqhv_rec.lease_rate_factor = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.lease_rate_factor := NULL;
    END IF;
    IF l_qqhv_rec.target_rate_type = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.target_rate_type := NULL;
    END IF;
    IF l_qqhv_rec.target_rate = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.target_rate := NULL;
    END IF;
    IF l_qqhv_rec.target_amount = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.target_amount := NULL;
    END IF;
    IF l_qqhv_rec.target_frequency = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.target_frequency := NULL;
    END IF;
    IF l_qqhv_rec.target_arrears = FND_API.G_MISS_CHAR THEN
      l_qqhv_rec.target_arrears := NULL;
    END IF;
    IF l_qqhv_rec.target_periods = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.target_periods := NULL;
    END IF;
    IF l_qqhv_rec.iir = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.iir := NULL;
    END IF;
    IF l_qqhv_rec.sub_iir = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.sub_iir := NULL;
    END IF;
    IF l_qqhv_rec.booking_yield = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.booking_yield := NULL;
    END IF;
    IF l_qqhv_rec.sub_booking_yield = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.sub_booking_yield := NULL;
    END IF;
    IF l_qqhv_rec.pirr = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.pirr := NULL;
    END IF;
    IF l_qqhv_rec.sub_pirr = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.sub_pirr := NULL;
    END IF;
    IF l_qqhv_rec.airr = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.airr := NULL;
    END IF;
    IF l_qqhv_rec.sub_airr = FND_API.G_MISS_NUM THEN
      l_qqhv_rec.sub_airr := NULL;
    END IF;

    RETURN l_qqhv_rec;

  END null_out_defaults;


  -------------------
  -- FUNCTION get_rec
  -------------------
  FUNCTION get_rec (p_id             IN         NUMBER
                    ,x_return_status OUT NOCOPY VARCHAR2) RETURN qqhv_rec_type IS

    l_qqhv_rec           qqhv_rec_type;
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
      ,expected_start_date
      ,org_id
      ,inv_org_id
      ,currency_code
      ,term
      ,end_of_term_option_id
      ,pricing_method
      ,lease_opportunity_id
      ,originating_vendor_id
      ,program_agreement_id
      ,sales_rep_id
      ,sales_territory_id
      ,structured_pricing
      ,line_level_pricing
      ,rate_template_id
      ,rate_card_id
      ,lease_rate_factor
      ,target_rate_type
      ,target_rate
      ,target_amount
      ,target_frequency
      ,target_arrears
      ,target_periods
      ,iir
      ,sub_iir
      ,booking_yield
      ,sub_booking_yield
      ,pirr
      ,sub_pirr
      ,airr
      ,sub_airr
      -- abhsaxen - added - start
      ,sts_code
      -- abhsaxen - added - end
    INTO
      l_qqhv_rec.id
      ,l_qqhv_rec.object_version_number
      ,l_qqhv_rec.attribute_category
      ,l_qqhv_rec.attribute1
      ,l_qqhv_rec.attribute2
      ,l_qqhv_rec.attribute3
      ,l_qqhv_rec.attribute4
      ,l_qqhv_rec.attribute5
      ,l_qqhv_rec.attribute6
      ,l_qqhv_rec.attribute7
      ,l_qqhv_rec.attribute8
      ,l_qqhv_rec.attribute9
      ,l_qqhv_rec.attribute10
      ,l_qqhv_rec.attribute11
      ,l_qqhv_rec.attribute12
      ,l_qqhv_rec.attribute13
      ,l_qqhv_rec.attribute14
      ,l_qqhv_rec.attribute15
      ,l_qqhv_rec.reference_number
      ,l_qqhv_rec.expected_start_date
      ,l_qqhv_rec.org_id
      ,l_qqhv_rec.inv_org_id
      ,l_qqhv_rec.currency_code
      ,l_qqhv_rec.term
      ,l_qqhv_rec.end_of_term_option_id
      ,l_qqhv_rec.pricing_method
      ,l_qqhv_rec.lease_opportunity_id
      ,l_qqhv_rec.originating_vendor_id
      ,l_qqhv_rec.program_agreement_id
      ,l_qqhv_rec.sales_rep_id
      ,l_qqhv_rec.sales_territory_id
      ,l_qqhv_rec.structured_pricing
      ,l_qqhv_rec.line_level_pricing
      ,l_qqhv_rec.rate_template_id
      ,l_qqhv_rec.rate_card_id
      ,l_qqhv_rec.lease_rate_factor
      ,l_qqhv_rec.target_rate_type
      ,l_qqhv_rec.target_rate
      ,l_qqhv_rec.target_amount
      ,l_qqhv_rec.target_frequency
      ,l_qqhv_rec.target_arrears
      ,l_qqhv_rec.target_periods
      ,l_qqhv_rec.iir
      ,l_qqhv_rec.sub_iir
      ,l_qqhv_rec.booking_yield
      ,l_qqhv_rec.sub_booking_yield
      ,l_qqhv_rec.pirr
      ,l_qqhv_rec.sub_pirr
      ,l_qqhv_rec.airr
      ,l_qqhv_rec.sub_airr
      -- abhsaxen - added - start
      ,l_qqhv_rec.sts_code
      -- abhsaxen - added - end
    FROM OKL_QUICK_QUOTES_V
    WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_qqhv_rec;

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

  -------------------------------------------
  -- Function validate_sts_Code
  -------------------------------------------

PROCEDURE validate_sts_code(x_return_status out NOCOPY varchar2,p_sts_code  IN  VARCHAR2) IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_sts_code';
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Column is mandatory
    IF (p_sts_code is null) THEN
        OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                            p_msg_name      => G_COL_ERROR,
                            p_token1        => g_col_name_token,
                            p_token1_value  => 'sts_code',
                            p_token2        => G_PKG_NAME_TOKEN,
                            p_token2_value  => G_PKG_NAME);
       -- notify caller of an error
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Lookup Code Validation
    x_return_status := OKL_UTIL.check_lookup_code(
                             p_lookup_type  =>  'OKL_QQ_STATUS',
                             p_lookup_code  =>  p_sts_code);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => G_COL_ERROR,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'sts_code',
                            p_token2        => G_PKG_NAME_TOKEN,
                            p_token2_value  => G_PKG_NAME);
        -- notify caller of an error
        raise OKL_API.G_EXCEPTION_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        -- notify caller of an error
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
END validate_sts_code;

--Bug 7022258-Added by kkorrapo
FUNCTION validate_unique(p_qqhv_rec_type  IN  qqhv_rec_type) RETURN VARCHAR2 IS

 	    CURSOR chk_uniquness IS
 	       SELECT 'x'
 	       FROM okl_quick_quotes_b
 	       WHERE  reference_number = p_qqhv_rec_type.reference_number
 	       AND    id <> NVL(p_qqhv_rec_type.id, -9999);

 	     l_dummy_var              VARCHAR2(1);
 	     x_return_status          VARCHAR2(1) := okl_api.g_ret_sts_success;
 	     l_api_name      CONSTANT VARCHAR2(61) := g_pkg_name || '.' || 'validate_header';
 	     l_msg_count     NUMBER;
 	     l_msg_data      VARCHAR2(2000);

 	   CURSOR c_get_prefix IS
 	     SELECT QCKQTE_SEQ_PREFIX_TXT
 	     FROM okl_system_params;
 	     l_prefix VARCHAR2(30);

 	   BEGIN

 	     OPEN chk_uniquness; -- QQ Reference Number should be unique
 	     FETCH chk_uniquness INTO l_dummy_var;
 	     CLOSE chk_uniquness;  -- if l_dummy_var is 'x' then Ref Num already exists

 	     IF (l_dummy_var = 'x') THEN
 	       okl_api.set_message(p_app_name     =>             g_app_name
 	                          ,p_msg_name     =>             'OKL_DUPLICATE_CURE_REQUEST'
 	                          ,p_token1       =>             'COL_NAME'
 	                          ,p_token1_value =>             p_qqhv_rec_type.reference_number);
 	        RETURN okl_api.g_ret_sts_error;
 	     END IF;

 	     --get prefix
 	     OPEN c_get_prefix;
 	     FETCH c_get_prefix INTO l_prefix;
 	     CLOSE c_get_prefix;

 	       IF l_prefix IS NOT NULL THEN
 	        IF INSTR(p_qqhv_rec_type.reference_number,l_prefix) <> 1 THEN
 	         okl_api.set_message(p_app_name     =>             g_app_name
 	                          ,p_msg_name     =>             'OKL_NO_PREFIX'
 	                          ,p_token1       =>             'COL_NAME'
 	                          ,p_token1_value =>            p_qqhv_rec_type.reference_number
 	                          ,p_token2       =>             'PREFIX'
 	                          ,p_token2_value =>            l_prefix);
 	          RETURN okl_api.g_ret_sts_error;
 	        END IF;
 	       END IF;

 	     RETURN x_return_status;


 	   END validate_unique;
	   --Bug 7022258--Addition end

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


  -------------------------------
  -- FUNCTION validate_attributes
  -------------------------------
  FUNCTION validate_attributes (p_qqhv_rec IN qqhv_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);

  BEGIN

    validate_id (l_return_status, p_qqhv_rec.id);
    validate_object_version_number (l_return_status, p_qqhv_rec.object_version_number);
    validate_reference_number (l_return_status, p_qqhv_rec.reference_number);
    validate_expected_start_date (l_return_status, p_qqhv_rec.expected_start_date);
    validate_org_id (l_return_status, p_qqhv_rec.org_id);
    validate_inv_org_id (l_return_status, p_qqhv_rec.inv_org_id);
    validate_currency_code (l_return_status, p_qqhv_rec.currency_code);
    validate_term (l_return_status, p_qqhv_rec.term);
    validate_end_of_term_option_id (l_return_status, p_qqhv_rec.end_of_term_option_id);
    validate_pricing_method (l_return_status, p_qqhv_rec.pricing_method);
    validate_sts_code(l_return_status,p_qqhv_rec.sts_code);
    RETURN l_return_status;

  END validate_attributes;

  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  FUNCTION validate_record (p_qqhv_rec IN qqhv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    RETURN G_RET_STS_SUCCESS;
  END validate_record;


  -----------------------------
  -- PROECDURE migrate (V -> B)
  -----------------------------
  PROCEDURE migrate (p_from IN qqhv_rec_type, p_to IN OUT NOCOPY qqh_rec_type) IS

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
    p_to.expected_start_date            :=  p_from.expected_start_date;
    p_to.org_id                         :=  p_from.org_id;
    p_to.inv_org_id                     :=  p_from.inv_org_id;
    p_to.currency_code                  :=  p_from.currency_code;
    p_to.term                           :=  p_from.term;
    p_to.end_of_term_option_id          :=  p_from.end_of_term_option_id;
    p_to.pricing_method                 :=  p_from.pricing_method;
    p_to.lease_opportunity_id           :=  p_from.lease_opportunity_id;
    p_to.originating_vendor_id          :=  p_from.originating_vendor_id;
    p_to.program_agreement_id           :=  p_from.program_agreement_id;
    p_to.sales_rep_id                   :=  p_from.sales_rep_id;
    p_to.sales_territory_id             :=  p_from.sales_territory_id;
    p_to.structured_pricing             :=  p_from.structured_pricing;
    p_to.line_level_pricing             :=  p_from.line_level_pricing;
    p_to.rate_template_id               :=  p_from.rate_template_id;
    p_to.rate_card_id                   :=  p_from.rate_card_id;
    p_to.lease_rate_factor              :=  p_from.lease_rate_factor;
    p_to.target_rate_type               :=  p_from.target_rate_type;
    p_to.target_rate                    :=  p_from.target_rate;
    p_to.target_amount                  :=  p_from.target_amount;
    p_to.target_frequency               :=  p_from.target_frequency;
    p_to.target_arrears                 :=  p_from.target_arrears;
    p_to.target_periods                 :=  p_from.target_periods;
    p_to.iir                            :=  p_from.iir;
    p_to.sub_iir                        :=  p_from.sub_iir;
    p_to.booking_yield                  :=  p_from.booking_yield;
    p_to.sub_booking_yield              :=  p_from.sub_booking_yield;
    p_to.pirr                           :=  p_from.pirr;
    p_to.sub_pirr                       :=  p_from.sub_pirr;
    p_to.airr                           :=  p_from.airr;
    p_to.sub_airr                       :=  p_from.sub_airr;
    --abhsaxen - added - start
    p_to.sts_code                       := p_from.sts_code;
    --abhsaxen - added - end

  END migrate;


  -----------------------------
  -- PROCEDURE migrate (V -> TL)
  -----------------------------
  PROCEDURE migrate (p_from IN qqhv_rec_type, p_to IN OUT NOCOPY qqhtl_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.short_description := p_from.short_description;
    p_to.description := p_from.description;
    p_to.comments := p_from.comments;
  END migrate;


  ---------------------------
  -- PROCEDURE insert_row (B)
  ---------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_qqh_rec IN qqh_rec_type) IS

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (B)';

    INSERT INTO okl_quick_quotes_b (
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
      ,expected_start_date
      ,org_id
      ,inv_org_id
      ,currency_code
      ,term
      ,end_of_term_option_id
      ,pricing_method
      ,lease_opportunity_id
      ,originating_vendor_id
      ,program_agreement_id
      ,sales_rep_id
      ,sales_territory_id
      ,structured_pricing
      ,line_level_pricing
      ,rate_template_id
      ,rate_card_id
      ,lease_rate_factor
      ,target_rate_type
      ,target_rate
      ,target_amount
      ,target_frequency
      ,target_arrears
      ,target_periods
      ,iir
      ,sub_iir
      ,booking_yield
      ,sub_booking_yield
      ,pirr
      ,sub_pirr
      ,airr
      ,sub_airr
      -- abhsaxen - added - start
      ,sts_code
      -- abhsaxen - added - end
      )
    VALUES
      (
       p_qqh_rec.id
      ,p_qqh_rec.object_version_number
      ,p_qqh_rec.attribute_category
      ,p_qqh_rec.attribute1
      ,p_qqh_rec.attribute2
      ,p_qqh_rec.attribute3
      ,p_qqh_rec.attribute4
      ,p_qqh_rec.attribute5
      ,p_qqh_rec.attribute6
      ,p_qqh_rec.attribute7
      ,p_qqh_rec.attribute8
      ,p_qqh_rec.attribute9
      ,p_qqh_rec.attribute10
      ,p_qqh_rec.attribute11
      ,p_qqh_rec.attribute12
      ,p_qqh_rec.attribute13
      ,p_qqh_rec.attribute14
      ,p_qqh_rec.attribute15
      ,G_USER_ID
      ,SYSDATE
      ,G_USER_ID
      ,SYSDATE
      ,G_LOGIN_ID
      ,p_qqh_rec.reference_number
      ,p_qqh_rec.expected_start_date
      ,p_qqh_rec.org_id
      ,p_qqh_rec.inv_org_id
      ,p_qqh_rec.currency_code
      ,p_qqh_rec.term
      ,p_qqh_rec.end_of_term_option_id
      ,p_qqh_rec.pricing_method
      ,p_qqh_rec.lease_opportunity_id
      ,p_qqh_rec.originating_vendor_id
      ,p_qqh_rec.program_agreement_id
      ,p_qqh_rec.sales_rep_id
      ,p_qqh_rec.sales_territory_id
      ,p_qqh_rec.structured_pricing
      ,p_qqh_rec.line_level_pricing
      ,p_qqh_rec.rate_template_id
      ,p_qqh_rec.rate_card_id
      ,p_qqh_rec.lease_rate_factor
      ,p_qqh_rec.target_rate_type
      ,p_qqh_rec.target_rate
      ,p_qqh_rec.target_amount
      ,p_qqh_rec.target_frequency
      ,p_qqh_rec.target_arrears
      ,p_qqh_rec.target_periods
      ,p_qqh_rec.iir
      ,p_qqh_rec.sub_iir
      ,p_qqh_rec.booking_yield
      ,p_qqh_rec.sub_booking_yield
      ,p_qqh_rec.pirr
      ,p_qqh_rec.sub_pirr
      ,p_qqh_rec.airr
      ,p_qqh_rec.sub_airr
      -- abhsaxen - added - start
      ,p_qqh_rec.sts_code
      -- abhsaxen - added - end

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
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_qqhtl_rec IN qqhtl_rec_type) IS

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

      INSERT INTO OKL_QUICK_QUOTES_TL (
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
        p_qqhtl_rec.id
       ,l_lang_rec.language_code
       ,USERENV('LANG')
       ,l_sfwt_flag
       ,G_USER_ID
       ,SYSDATE
       ,G_USER_ID
       ,SYSDATE
       ,G_LOGIN_ID
       ,p_qqhtl_rec.short_description
       ,p_qqhtl_rec.description
       ,p_qqhtl_rec.comments);

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
    p_qqhv_rec                     IN qqhv_rec_type,
    x_qqhv_rec                     OUT NOCOPY qqhv_rec_type) IS

    l_return_status                VARCHAR2(1);

    l_qqhv_rec                     qqhv_rec_type;
    l_qqh_rec                      qqh_rec_type;
    l_qqhtl_rec                    qqhtl_rec_type;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (V)';

    l_qqhv_rec                       := null_out_defaults (p_qqhv_rec);

    SELECT okl_qqh_seq.nextval INTO l_qqhv_rec.ID FROM DUAL;

    l_qqhv_rec.OBJECT_VERSION_NUMBER := 1;

    l_return_status := validate_attributes(l_qqhv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug 7022258-Added by kkorrapo
    IF (okl_util.validate_seq_num('OKL_QQH_REF_SEQ','OKL_QUICK_QUOTES_B','REFERENCE_NUMBER',l_qqhv_rec.reference_number) = 'N') THEN
      RAISE okl_api.g_exception_error;
    END IF;
    --Bug 7022258--Addition end

    l_return_status := validate_record(l_qqhv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_qqhv_rec, l_qqh_rec);
    migrate (l_qqhv_rec, l_qqhtl_rec);

    insert_row (x_return_status => l_return_status, p_qqh_rec => l_qqh_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_row (x_return_status => l_return_status, p_qqhtl_rec => l_qqhtl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_qqhv_rec      := l_qqhv_rec;
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
    p_qqhv_rec                     IN qqhv_rec_type,
    x_qqhv_rec                     OUT NOCOPY qqhv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    insert_row (x_return_status                => l_return_status,
                p_qqhv_rec                     => p_qqhv_rec,
                x_qqhv_rec                     => x_qqhv_rec);

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
    p_qqhv_tbl                     IN qqhv_tbl_type,
    x_qqhv_tbl                     OUT NOCOPY qqhv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_qqhv_tbl.COUNT > 0) THEN
      i := p_qqhv_tbl.FIRST;
      LOOP
        IF p_qqhv_tbl.EXISTS(i) THEN

          insert_row (x_return_status                => l_return_status,
                      p_qqhv_rec                     => p_qqhv_tbl(i),
                      x_qqhv_rec                     => x_qqhv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_qqhv_tbl.LAST);
          i := p_qqhv_tbl.NEXT(i);

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
  PROCEDURE lock_row (x_return_status OUT NOCOPY VARCHAR2, p_qqh_rec IN qqh_rec_type) IS

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT (E_Resource_Busy, -00054);

    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_QUICK_QUOTES_B
     WHERE ID = p_qqh_rec.id
       AND OBJECT_VERSION_NUMBER = p_qqh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_QUICK_QUOTES_B
     WHERE ID = p_qqh_rec.id;

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

      ELSIF lc_object_version_number <> p_qqh_rec.object_version_number THEN

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_qqh_rec IN qqh_rec_type) IS

    l_return_status           VARCHAR2(1);

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (B)';

    lock_row (x_return_status => l_return_status, p_qqh_rec => p_qqh_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE okl_quick_quotes_b
    SET
      object_version_number = p_qqh_rec.object_version_number+1
      ,attribute_category = p_qqh_rec.attribute_category
      ,attribute1 = p_qqh_rec.attribute1
      ,attribute2 = p_qqh_rec.attribute2
      ,attribute3 = p_qqh_rec.attribute3
      ,attribute4 = p_qqh_rec.attribute4
      ,attribute5 = p_qqh_rec.attribute5
      ,attribute6 = p_qqh_rec.attribute6
      ,attribute7 = p_qqh_rec.attribute7
      ,attribute8 = p_qqh_rec.attribute8
      ,attribute9 = p_qqh_rec.attribute9
      ,attribute10 = p_qqh_rec.attribute10
      ,attribute11 = p_qqh_rec.attribute11
      ,attribute12 = p_qqh_rec.attribute12
      ,attribute13 = p_qqh_rec.attribute13
      ,attribute14 = p_qqh_rec.attribute14
      ,attribute15 = p_qqh_rec.attribute15
      ,reference_number = p_qqh_rec.reference_number
      ,expected_start_date = p_qqh_rec.expected_start_date
      ,org_id = p_qqh_rec.org_id
      ,inv_org_id = p_qqh_rec.inv_org_id
      ,currency_code = p_qqh_rec.currency_code
      ,term = p_qqh_rec.term
      ,end_of_term_option_id = p_qqh_rec.end_of_term_option_id
      ,pricing_method = p_qqh_rec.pricing_method
      ,lease_opportunity_id = p_qqh_rec.lease_opportunity_id
      ,originating_vendor_id = p_qqh_rec.originating_vendor_id
      ,program_agreement_id = p_qqh_rec.program_agreement_id
      ,sales_rep_id = p_qqh_rec.sales_rep_id
      ,sales_territory_id = p_qqh_rec.sales_territory_id
      ,structured_pricing = p_qqh_rec.structured_pricing
      ,line_level_pricing = p_qqh_rec.line_level_pricing
      ,rate_template_id = p_qqh_rec.rate_template_id
      ,rate_card_id = p_qqh_rec.rate_card_id
      ,lease_rate_factor = p_qqh_rec.lease_rate_factor
      ,target_rate_type = p_qqh_rec.target_rate_type
      ,target_rate = p_qqh_rec.target_rate
      ,target_amount = p_qqh_rec.target_amount
      ,target_frequency = p_qqh_rec.target_frequency
      ,target_arrears = p_qqh_rec.target_arrears
      ,target_periods = p_qqh_rec.target_periods
      ,iir = p_qqh_rec.iir
      ,sub_iir = p_qqh_rec.sub_iir
      ,booking_yield = p_qqh_rec.booking_yield
      ,sub_booking_yield = p_qqh_rec.sub_booking_yield
      ,pirr = p_qqh_rec.pirr
      ,sub_pirr = p_qqh_rec.sub_pirr
      ,airr = p_qqh_rec.airr
      ,sub_airr = p_qqh_rec.sub_airr
      -- abhsaxen - added - start
      ,sts_code  = p_qqh_rec.sts_code
      -- abhsaxen - added - end
    WHERE id = p_qqh_rec.id;

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_qqhtl_rec IN qqhtl_rec_type) IS

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TL)';

    UPDATE OKL_QUICK_QUOTES_TL
    SET
      source_lang = USERENV('LANG')
      ,sfwt_flag = 'Y'
      ,last_updated_by = G_USER_ID
      ,last_update_date = SYSDATE
      ,last_update_login = G_LOGIN_ID
      ,short_description = p_qqhtl_rec.short_description
      ,description = p_qqhtl_rec.description
      ,comments = p_qqhtl_rec.comments
    WHERE ID = p_qqhtl_rec.id;

    UPDATE OKL_QUICK_QUOTES_TL
    SET SFWT_FLAG = 'N'
    WHERE ID = p_qqhtl_rec.id
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
    p_qqhv_rec                     IN qqhv_rec_type,
    x_qqhv_rec                     OUT NOCOPY qqhv_rec_type) IS

    l_prog_name                    VARCHAR2(61);

    l_return_status                VARCHAR2(1);
    l_qqhv_rec                     qqhv_rec_type;
    l_qqh_rec                      qqh_rec_type;
    l_qqhtl_rec                    qqhtl_rec_type;

    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_qqhv_rec IN  qqhv_rec_type,
                                  x_qqhv_rec OUT NOCOPY qqhv_rec_type) RETURN VARCHAR2 IS

      l_prog_name          VARCHAR2(61);
      l_return_status      VARCHAR2(1);
      l_db_qqhv_rec        qqhv_rec_type;

    BEGIN

      l_prog_name := G_PKG_NAME||'.populate_new_record';

      x_qqhv_rec    := p_qqhv_rec;
      l_db_qqhv_rec := get_rec (p_qqhv_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- smadhava - Modified - G_MISS compliance - Start
      IF x_qqhv_rec.attribute_category IS NULL THEN
        x_qqhv_rec.attribute_category := l_db_qqhv_rec.attribute_category;
      ELSIF x_qqhv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute_category := null;
      END IF;

      IF x_qqhv_rec.attribute1 IS NULL THEN
        x_qqhv_rec.attribute1 := l_db_qqhv_rec.attribute1;
      ELSIF x_qqhv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute1 := null;
      END IF;

      IF x_qqhv_rec.attribute2 IS NULL THEN
        x_qqhv_rec.attribute2 := l_db_qqhv_rec.attribute2;
      ELSIF x_qqhv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute2 := null;
      END IF;

      IF x_qqhv_rec.attribute3 IS NULL THEN
        x_qqhv_rec.attribute3 := l_db_qqhv_rec.attribute3;
      ELSIF x_qqhv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute3 := null;
      END IF;

      IF x_qqhv_rec.attribute4 IS NULL THEN
        x_qqhv_rec.attribute4 := l_db_qqhv_rec.attribute4;
      ELSIF x_qqhv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute4 := null;
      END IF;

      IF x_qqhv_rec.attribute5 IS NULL THEN
        x_qqhv_rec.attribute5 := l_db_qqhv_rec.attribute5;
      ELSIF x_qqhv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute5 := null;
      END IF;

      IF x_qqhv_rec.attribute6 IS NULL THEN
        x_qqhv_rec.attribute6 := l_db_qqhv_rec.attribute6;
      ELSIF x_qqhv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute6 := null;
      END IF;

      IF x_qqhv_rec.attribute7 IS NULL THEN
        x_qqhv_rec.attribute7 := l_db_qqhv_rec.attribute7;
      ELSIF x_qqhv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute7 := null;
      END IF;

      IF x_qqhv_rec.attribute8 IS NULL THEN
        x_qqhv_rec.attribute8 := l_db_qqhv_rec.attribute8;
      ELSIF x_qqhv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute8 := null;
      END IF;

      IF x_qqhv_rec.attribute9 IS NULL THEN
        x_qqhv_rec.attribute9 := l_db_qqhv_rec.attribute9;
      ELSIF x_qqhv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute9 := null;
      END IF;

      IF x_qqhv_rec.attribute10 IS NULL THEN
        x_qqhv_rec.attribute10 := l_db_qqhv_rec.attribute10;
      ELSIF x_qqhv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute10 := null;
      END IF;

      IF x_qqhv_rec.attribute11 IS NULL THEN
        x_qqhv_rec.attribute11 := l_db_qqhv_rec.attribute11;
      ELSIF x_qqhv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute11 := null;
      END IF;

      IF x_qqhv_rec.attribute12 IS NULL THEN
        x_qqhv_rec.attribute12 := l_db_qqhv_rec.attribute12;
      ELSIF x_qqhv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute12 := null;
      END IF;

      IF x_qqhv_rec.attribute13 IS NULL THEN
        x_qqhv_rec.attribute13 := l_db_qqhv_rec.attribute13;
      ELSIF x_qqhv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute13 := null;
      END IF;

      IF x_qqhv_rec.attribute14 IS NULL THEN
        x_qqhv_rec.attribute14 := l_db_qqhv_rec.attribute14;
      ELSIF x_qqhv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute14 := null;
      END IF;

      IF x_qqhv_rec.attribute15 IS NULL THEN
        x_qqhv_rec.attribute15 := l_db_qqhv_rec.attribute15;
      ELSIF x_qqhv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.attribute15 := null;
      END IF;

      IF x_qqhv_rec.reference_number IS NULL THEN
        x_qqhv_rec.reference_number := l_db_qqhv_rec.reference_number;
      ELSIF x_qqhv_rec.reference_number = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.reference_number := null;
      END IF;

      IF x_qqhv_rec.expected_start_date IS NULL THEN
        x_qqhv_rec.expected_start_date := l_db_qqhv_rec.expected_start_date;
      ELSIF x_qqhv_rec.expected_start_date = FND_API.G_MISS_DATE THEN
        x_qqhv_rec.expected_start_date := null;
      END IF;

      IF x_qqhv_rec.org_id IS NULL THEN
        x_qqhv_rec.org_id := l_db_qqhv_rec.org_id;
      ELSIF x_qqhv_rec.org_id = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.org_id := null;
      END IF;

      IF x_qqhv_rec.inv_org_id IS NULL THEN
        x_qqhv_rec.inv_org_id := l_db_qqhv_rec.inv_org_id;
      ELSIF x_qqhv_rec.inv_org_id = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.inv_org_id := null;
      END IF;

      IF x_qqhv_rec.currency_code IS NULL THEN
        x_qqhv_rec.currency_code := l_db_qqhv_rec.currency_code;
      ELSIF x_qqhv_rec.currency_code = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.currency_code := null;
      END IF;

      IF x_qqhv_rec.term IS NULL THEN
        x_qqhv_rec.term := l_db_qqhv_rec.term;
      ELSIF x_qqhv_rec.term = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.term := null;
      END IF;

      IF x_qqhv_rec.end_of_term_option_id IS NULL THEN
        x_qqhv_rec.end_of_term_option_id := l_db_qqhv_rec.end_of_term_option_id;
      ELSIF x_qqhv_rec.end_of_term_option_id = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.end_of_term_option_id := null;
      END IF;

      IF x_qqhv_rec.pricing_method IS NULL THEN
        x_qqhv_rec.pricing_method := l_db_qqhv_rec.pricing_method;
      ELSIF x_qqhv_rec.pricing_method = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.pricing_method := null;
      END IF;

      IF x_qqhv_rec.lease_opportunity_id IS NULL THEN
        x_qqhv_rec.lease_opportunity_id := l_db_qqhv_rec.lease_opportunity_id;
      ELSIF x_qqhv_rec.lease_opportunity_id = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.lease_opportunity_id := null;
      END IF;

      IF x_qqhv_rec.originating_vendor_id IS NULL THEN
        x_qqhv_rec.originating_vendor_id := l_db_qqhv_rec.originating_vendor_id;
      ELSIF x_qqhv_rec.originating_vendor_id = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.originating_vendor_id := null;
      END IF;

      IF x_qqhv_rec.program_agreement_id IS NULL THEN
        x_qqhv_rec.program_agreement_id := l_db_qqhv_rec.program_agreement_id;
      ELSIF x_qqhv_rec.program_agreement_id = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.program_agreement_id := null;
      END IF;

      IF x_qqhv_rec.sales_rep_id IS NULL THEN
        x_qqhv_rec.sales_rep_id := l_db_qqhv_rec.sales_rep_id;
      ELSIF x_qqhv_rec.sales_rep_id = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.sales_rep_id := null;
      END IF;

      IF x_qqhv_rec.sales_territory_id IS NULL THEN
        x_qqhv_rec.sales_territory_id := l_db_qqhv_rec.sales_territory_id;
      ELSIF x_qqhv_rec.sales_territory_id = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.sales_territory_id := null;
      END IF;

      IF x_qqhv_rec.structured_pricing IS NULL THEN
        x_qqhv_rec.structured_pricing := l_db_qqhv_rec.structured_pricing;
      ELSIF x_qqhv_rec.structured_pricing = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.structured_pricing := null;
      END IF;

      IF x_qqhv_rec.line_level_pricing IS NULL THEN
        x_qqhv_rec.line_level_pricing := l_db_qqhv_rec.line_level_pricing;
      ELSIF x_qqhv_rec.line_level_pricing = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.line_level_pricing := null;
      END IF;

      IF x_qqhv_rec.rate_template_id IS NULL THEN
        x_qqhv_rec.rate_template_id := l_db_qqhv_rec.rate_template_id;
      ELSIF x_qqhv_rec.rate_template_id = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.rate_template_id := null;
      END IF;

      IF x_qqhv_rec.rate_card_id IS NULL THEN
        x_qqhv_rec.rate_card_id := l_db_qqhv_rec.rate_card_id;
      ELSIF x_qqhv_rec.rate_card_id = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.rate_card_id := null;
      END IF;

      IF x_qqhv_rec.lease_rate_factor IS NULL THEN
        x_qqhv_rec.lease_rate_factor := l_db_qqhv_rec.lease_rate_factor;
      ELSIF x_qqhv_rec.lease_rate_factor = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.lease_rate_factor := null;
      END IF;

      IF x_qqhv_rec.target_rate_type IS NULL THEN
        x_qqhv_rec.target_rate_type := l_db_qqhv_rec.target_rate_type;
      ELSIF x_qqhv_rec.target_rate_type = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.target_rate_type := null;
      END IF;

      IF x_qqhv_rec.target_rate IS NULL THEN
        x_qqhv_rec.target_rate := l_db_qqhv_rec.target_rate;
      ELSIF x_qqhv_rec.target_rate = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.target_rate := null;
      END IF;

      IF x_qqhv_rec.target_amount IS NULL THEN
        x_qqhv_rec.target_amount := l_db_qqhv_rec.target_amount;
      ELSIF x_qqhv_rec.target_amount = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.target_amount := null;
      END IF;

      IF x_qqhv_rec.target_frequency IS NULL THEN
        x_qqhv_rec.target_frequency := l_db_qqhv_rec.target_frequency;
      ELSIF x_qqhv_rec.target_frequency = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.target_frequency := null;
      END IF;

      IF x_qqhv_rec.target_arrears IS NULL THEN
        x_qqhv_rec.target_arrears := l_db_qqhv_rec.target_arrears;
      ELSIF x_qqhv_rec.target_arrears = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.target_arrears := null;
      END IF;

      IF x_qqhv_rec.target_periods IS NULL THEN
        x_qqhv_rec.target_periods := l_db_qqhv_rec.target_periods;
      ELSIF x_qqhv_rec.target_periods = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.target_periods := null;
      END IF;

      IF x_qqhv_rec.iir IS NULL THEN
        x_qqhv_rec.iir := l_db_qqhv_rec.iir;
      ELSIF x_qqhv_rec.iir = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.iir := null;
      END IF;

      IF x_qqhv_rec.sub_iir IS NULL THEN
        x_qqhv_rec.sub_iir := l_db_qqhv_rec.sub_iir;
      ELSIF x_qqhv_rec.sub_iir = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.sub_iir := null;
      END IF;

      IF x_qqhv_rec.booking_yield IS NULL THEN
        x_qqhv_rec.booking_yield := l_db_qqhv_rec.booking_yield;
      ELSIF x_qqhv_rec.booking_yield = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.booking_yield := null;
      END IF;

      IF x_qqhv_rec.sub_booking_yield IS NULL THEN
        x_qqhv_rec.sub_booking_yield := l_db_qqhv_rec.sub_booking_yield;
      ELSIF x_qqhv_rec.sub_booking_yield = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.sub_booking_yield := null;
      END IF;

      IF x_qqhv_rec.pirr IS NULL THEN
        x_qqhv_rec.pirr := l_db_qqhv_rec.pirr;
      ELSIF x_qqhv_rec.pirr = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.pirr := null;
      END IF;

      IF x_qqhv_rec.sub_pirr IS NULL THEN
        x_qqhv_rec.sub_pirr := l_db_qqhv_rec.sub_pirr;
      ELSIF x_qqhv_rec.sub_pirr = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.sub_pirr := null;
      END IF;

      IF x_qqhv_rec.airr IS NULL THEN
        x_qqhv_rec.airr := l_db_qqhv_rec.airr;
      ELSIF x_qqhv_rec.airr = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.airr := null;
      END IF;

      IF x_qqhv_rec.sub_airr IS NULL THEN
        x_qqhv_rec.sub_airr := l_db_qqhv_rec.sub_airr;
      ELSIF x_qqhv_rec.sub_airr = FND_API.G_MISS_NUM THEN
        x_qqhv_rec.sub_airr := null;
      END IF;

      IF x_qqhv_rec.short_description IS NULL THEN
        x_qqhv_rec.short_description := l_db_qqhv_rec.short_description;
      ELSIF x_qqhv_rec.short_description = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.short_description := null;
      END IF;

      IF x_qqhv_rec.description IS NULL THEN
        x_qqhv_rec.description := l_db_qqhv_rec.description;
      ELSIF x_qqhv_rec.description = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.description := null;
      END IF;

      IF x_qqhv_rec.comments IS NULL THEN
        x_qqhv_rec.comments := l_db_qqhv_rec.comments;
      ELSIF x_qqhv_rec.comments = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.comments := null;
      END IF;

      IF x_qqhv_rec.sts_code IS NULL THEN
        x_qqhv_rec.sts_code := l_db_qqhv_rec.sts_code;
      ELSIF x_qqhv_rec.sts_code = FND_API.G_MISS_CHAR THEN
        x_qqhv_rec.sts_code := null;
      END IF;
      -- smadhava - Modified - G_MISS compliance - End

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

    l_return_status := populate_new_record (p_qqhv_rec, l_qqhv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_attributes (l_qqhv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record (l_qqhv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug 7022258-Added by kkorrapo
    l_return_status := validate_unique (l_qqhv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug 7022258--Addition end

    migrate (l_qqhv_rec, l_qqh_rec);
    migrate (l_qqhv_rec, l_qqhtl_rec);

    update_row (x_return_status => l_return_status, p_qqh_rec => l_qqh_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_row (x_return_status => l_return_status, p_qqhtl_rec => l_qqhtl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    x_qqhv_rec      := l_qqhv_rec;

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
    p_qqhv_rec                     IN qqhv_rec_type,
    x_qqhv_rec                     OUT NOCOPY qqhv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    update_row (x_return_status                => l_return_status,
                p_qqhv_rec                     => p_qqhv_rec,
                x_qqhv_rec                     => x_qqhv_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- viselvar added
    x_qqhv_rec.object_version_number:=x_qqhv_rec.object_version_number+1;
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
    p_qqhv_tbl                     IN qqhv_tbl_type,
    x_qqhv_tbl                     OUT NOCOPY qqhv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;
    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_qqhv_tbl := p_qqhv_tbl;

    IF (p_qqhv_tbl.COUNT > 0) THEN

      i := p_qqhv_tbl.FIRST;

      LOOP

        IF p_qqhv_tbl.EXISTS(i) THEN
          update_row (x_return_status                => l_return_status,
                      p_qqhv_rec                     => p_qqhv_tbl(i),
                      x_qqhv_rec                     => x_qqhv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_qqhv_tbl.LAST);
          i := p_qqhv_tbl.NEXT(i);

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

    DELETE FROM OKL_QUICK_QUOTES_B WHERE id = p_id;
    DELETE FROM OKL_QUICK_QUOTES_TL WHERE id = p_id;

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
    p_qqhv_rec                     IN qqhv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    delete_row (x_return_status                => l_return_status,
                p_id                           => p_qqhv_rec.id);

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
    p_qqhv_tbl                     IN qqhv_tbl_type) IS

    l_return_status                VARCHAR2(1);
    i                              BINARY_INTEGER;

    l_prog_name                    VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_qqhv_tbl.COUNT > 0) THEN

      i := p_qqhv_tbl.FIRST;

      LOOP

        IF p_qqhv_tbl.EXISTS(i) THEN

          delete_row (x_return_status                => l_return_status,
                      p_id                           => p_qqhv_tbl(i).id);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_qqhv_tbl.LAST);
          i := p_qqhv_tbl.NEXT(i);

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


END OKL_QQH_PVT;

/
