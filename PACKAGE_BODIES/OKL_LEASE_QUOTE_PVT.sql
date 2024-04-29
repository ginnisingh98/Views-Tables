--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_PVT" AS
/* $Header: OKLRLSQB.pls 120.43.12010000.9 2009/06/30 06:13:41 nikshah ship $ */

  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(25)  := 'OKL_QUOTE_UNEXP_ERROR';

/*========================================================================
 | PUBLIC PROCEDURE delete_quote_tax_fee
 |
 | DESCRIPTION
 |    This procedure deletes the fee created as part of tax creation,
 |	  if the upfront tax treatment is modified from 'CAPITALIZED'/'FINANCED' to
 \	  'BILLED'.
 |
 | CALLED FROM 					Sales component
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 |
 | PARAMETERS
 |      p_quote_id            -- Quote Identifier
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date          Author     Description of Changes
 | 03-OCT-07    RRAVIKIR      Created
 |
 *=======================================================================*/
  PROCEDURE delete_quote_tax_fee(p_api_version              IN  NUMBER,
                                 p_init_msg_list            IN  VARCHAR2,
                                 x_return_status            OUT NOCOPY VARCHAR2,
                                 x_msg_count                OUT NOCOPY NUMBER,
                                 x_msg_data                 OUT NOCOPY VARCHAR2,
                                 p_quote_id                 IN  NUMBER) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'delete_quote_tax_fee';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_tax_treatment            VARCHAR2(30);
    l_fee_id                   NUMBER;
    l_return_status			   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    CURSOR l_get_tax_treatment(cp_quote_id IN NUMBER) IS
    SELECT upfront_tax_treatment
    FROM okl_lease_quotes_b
    WHERE id = cp_quote_id;

    CURSOR l_check_tax_fee_exists(cp_quote_id IN NUMBER) IS
    SELECT id
    FROM okl_fees_b
    WHERE parent_object_id = cp_quote_id
    AND parent_object_code = 'LEASEQUOTE'
    AND fee_purpose_code = 'SALESTAX';

  BEGIN

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_quote_id IS NULL THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_INVALID_SALES_QUOTE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN l_get_tax_treatment(p_quote_id);
    FETCH l_get_tax_treatment INTO l_tax_treatment;
    CLOSE l_get_tax_treatment;

    IF (l_tax_treatment = 'BILLED') THEN

      -- Check if the tax fee exists on the quote
      OPEN l_check_tax_fee_exists(p_quote_id);
      FETCH l_check_tax_fee_exists INTO l_fee_id;
      CLOSE l_check_tax_fee_exists;

      IF (l_fee_id IS NOT NULL) THEN -- Tax fee exist, delete it

        OKL_LEASE_QUOTE_FEE_PVT.delete_fee ( p_api_version             => p_api_version
                                            ,p_init_msg_list           => p_init_msg_list
                                            ,p_transaction_control     => 'T'
                                            ,p_fee_id                  => l_fee_id
                                            ,x_return_status           => l_return_status
                                            ,x_msg_count               => x_msg_count
                                            ,x_msg_data                => x_msg_data );

        IF(l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF(l_return_status = G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_quote_tax_fee;

  -- Added Bug # 5647107 ssdeshpa start
  -----------------------------------
  -- PROCEDURE validate_le_id
  -----------------------------------
  PROCEDURE validate_le_id(p_le_id IN NUMBER ,
                           p_parent_obj_code IN VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2) IS

  l_program_name      CONSTANT VARCHAR2(30) := 'validate_le_id';
  l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
  l_ou_tax_upfront_yn VARCHAR2(1);
  l_err_msg           VARCHAR2(80);

  CURSOR  l_systemparams_csr IS
    SELECT NVL(tax_upfront_yn,'N')
    FROM   OKL_SYSTEM_PARAMS;

  BEGIN
    OPEN l_systemparams_csr;
    FETCH l_systemparams_csr INTO l_ou_tax_upfront_yn;
    CLOSE l_systemparams_csr;

     IF(l_ou_tax_upfront_yn = 'Y') THEN
       IF(p_le_id IS NULL) THEN
          IF(p_parent_obj_code = 'LEASEAPP') THEN
            l_err_msg := 'OKL_SO_LSE_APP_LE_ERR';
          ELSE
            l_err_msg := 'OKL_LEASE_QUOTE_LE_ERR';
          END IF;
          OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME
           ,p_msg_name     => l_err_msg);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END validate_le_id;
  -- Added Bug # 5647107 ssdeshpa end
  -----------------------------------
  -- FUNCTION is_pricing_method_equal
  -----------------------------------
  FUNCTION is_pricing_method_equal(p_source_quote_id IN NUMBER,
                     p_target_pricing_type  IN VARCHAR2)
  RETURN VARCHAR2 IS

  lv_source_pricing_type  VARCHAR2(15);
  BEGIN
    select pricing_method
    into lv_source_pricing_type
    from okl_lease_quotes_b
    where id = p_source_quote_id;

    IF (lv_source_pricing_type = p_target_pricing_type) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
  END IF;
  END is_pricing_method_equal;

  ---------------------------------------
  -- FUNCTION copy_quote_payments_allowed
  ---------------------------------------
  FUNCTION copy_quote_payments_allowed(p_source_quote_id    IN NUMBER,
                         p_target_pdt_id      IN NUMBER,
                     p_target_exp_start_date  IN  DATE)
  RETURN VARCHAR2 IS

  ln_source_pdt_id  NUMBER;
  ld_source_exp_date  DATE;
  BEGIN
    select product_id, expected_start_date
    into ln_source_pdt_id, ld_source_exp_date
    from okl_lease_quotes_b
    where id = p_source_quote_id;

    IF (ln_source_pdt_id = p_target_pdt_id AND ld_source_exp_date = p_target_exp_start_date) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
  END IF;
  END copy_quote_payments_allowed;

FUNCTION is_contterm_payperiod_equal(p_contract_start_date IN DATE,
                     p_contract_term IN NUMBER, p_quote_id IN NUMBER)
  RETURN VARCHAR2 IS
    -- Cursor to fetch cashflow header id
    CURSOR lq_cash_flows_csr(p_quote_id NUMBER) IS
    SELECT cf.id  caf_id
    FROM   OKL_CASH_FLOWS         cf,
           OKL_CASH_FLOW_OBJECTS  cfo
    WHERE  cf.cfo_id = cfo.id
    AND    cfo.source_table = 'OKL_LEASE_QUOTES_B'
    AND    cfo.source_id = p_quote_id;

    -- Cursor to fetch the Cash Flow Details
    CURSOR lq_cash_flow_det_csr(p_caf_id NUMBER) IS
    SELECT  fqy_code, number_of_periods,
            stub_days, start_date
    FROM OKL_CASH_FLOW_LEVELS
    WHERE caf_id = p_caf_id
    ORDER BY start_date;

  l_cur_fetch          NUMBER;
  l_caf_id             NUMBER;
  l_mpp                NUMBER;
  l_end_date           DATE := FND_API.G_MISS_DATE;
  l_next_start_date    DATE := FND_API.G_MISS_DATE;
  l_contract_end_date  DATE := FND_API.G_MISS_DATE;

  TYPE dat_tbl_type  IS TABLE OF DATE          INDEX BY BINARY_INTEGER;
  TYPE num_tbl_type  IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
  TYPE vr1_tbl_type  IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;

  l_fqy_code           vr1_tbl_type;
  l_stub_days          num_tbl_type;
  l_start_date         dat_tbl_type;
  l_number_of_periods  num_tbl_type;


BEGIN

  OPEN  lq_cash_flows_csr(p_quote_id);
  FETCH lq_cash_flows_csr INTO l_caf_id;
  CLOSE lq_cash_flows_csr;

  OPEN  lq_cash_flow_det_csr(l_caf_id);
  FETCH lq_cash_flow_det_csr BULK COLLECT INTO
         l_fqy_code, l_number_of_periods, l_stub_days, l_start_date;
  CLOSE lq_cash_flow_det_csr;

  l_next_start_date := p_contract_start_date;

  l_cur_fetch :=  l_number_of_periods.COUNT;
  IF l_cur_fetch > 0 THEN
    FOR i IN 1..l_cur_fetch LOOP

      IF l_fqy_code(i) = 'A' THEN l_mpp := 12;
      ELSIF l_fqy_code(i) = 'S' THEN l_mpp := 6;
      ELSIF l_fqy_code(i) = 'Q' THEN l_mpp := 3;
      ELSIF l_fqy_code(i) = 'M' THEN l_mpp := 1;
      ELSE NULL;
      END IF;

      IF l_stub_days(i) IS NOT NULL THEN
        l_end_date := l_next_start_date + l_stub_days(i) - 1;
      ELSE
        l_end_date := ADD_MONTHS(l_next_start_date, l_mpp*l_number_of_periods(i)) - 1;
      END IF;

      l_start_date(i)    := l_next_start_date;
      l_next_start_date  := l_end_date + 1;
    END LOOP;
  END IF;

  l_contract_end_date := ADD_MONTHS(p_contract_start_date, p_contract_term) - 1;
  IF l_end_date > l_contract_end_date THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;

END is_contterm_payperiod_equal;

  -------------------------------
  -- PROCEDURE validate_lease_qte
  -------------------------------
  PROCEDURE validate_lease_qte (p_lease_qte_rec         IN lease_qte_rec_type,
                                x_return_status         OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'validate_lease_opp';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    CURSOR chk_uniquness IS
      SELECT '1'
      FROM okl_lease_quotes_b
      WHERE  reference_number = p_lease_qte_rec.reference_number
      AND    id <> NVL(p_lease_qte_rec.id, -9999);

    CURSOR chk_parent_dates_leaseopp IS
       SELECT TRUNC(valid_from)
       FROM   okl_lease_opportunities_b
       WHERE  id   = p_lease_qte_rec.parent_object_id;

    CURSOR chk_parent_dates_leaseapp IS
       SELECT TRUNC(valid_from)
       FROM   okl_lease_applications_b
       WHERE  id   = p_lease_qte_rec.parent_object_id;

    l_refno_unq_chk         NUMBER;
    l_parent_valid_from     DATE;
    l_format_mask           VARCHAR2(50);
    l_formatted_date        VARCHAR2(50);

  BEGIN

    OPEN chk_uniquness;
    FETCH chk_uniquness INTO l_refno_unq_chk;
    CLOSE chk_uniquness;

    IF l_refno_unq_chk IS NOT NULL THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_REFNO_UNIQUE_CHECK');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_lease_qte_rec.parent_object_code IS NULL THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_INVALID_SALES_QUOTE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (p_lease_qte_rec.parent_object_code = 'LEASEOPP') THEN
      OPEN chk_parent_dates_leaseopp;
      FETCH chk_parent_dates_leaseopp INTO  l_parent_valid_from;
      CLOSE chk_parent_dates_leaseopp;
    ELSIF (p_lease_qte_rec.parent_object_code = 'LEASEAPP') THEN
      OPEN chk_parent_dates_leaseapp;
      FETCH chk_parent_dates_leaseapp INTO  l_parent_valid_from;
      CLOSE chk_parent_dates_leaseapp;
    END IF;

    l_format_mask    := NVL(FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'), 'DD-MON-YYYY');
    l_formatted_date := TO_CHAR(l_parent_valid_from , l_format_mask);

    IF p_lease_qte_rec.expected_start_date  < l_parent_valid_from THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_QUOTE_INVALID_START_DATE'
       ,p_token1       => 'LEASEOPP_DATE'
       ,p_token1_value => l_formatted_date
      );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_lease_qte_rec.expected_funding_date  < l_parent_valid_from THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_QUOTE_INVALID_FUNDING_DATE'
       ,p_token1       => 'LEASEOPP_DATE'
       ,p_token1_value => l_formatted_date
      );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_lease_qte_rec.expected_delivery_date  < l_parent_valid_from THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_QUOTE_INVALID_DELV_DATE'
       ,p_token1       => 'LEASEOPP_DATE'
       ,p_token1_value => l_formatted_date
      );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_lease_qte_rec.term <= 0 THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_INVALID_QUOTE_TERM');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (p_lease_qte_rec.term <> TRUNC(p_lease_qte_rec.term)) THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_INVALID_QUOTE_TERM2');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --asawanka bug 4923624 changes start
    IF (p_lease_qte_rec.valid_from IS NULL OR p_lease_qte_rec.valid_from = OKL_API.G_MISS_DATE )
    AND(p_lease_qte_rec.valid_to IS NOT NULL AND p_lease_qte_rec.valid_to <> OKL_API.G_MISS_DATE )THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_REQUIRED_VALID_FROM');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_lease_qte_rec.valid_to <> OKL_API.G_MISS_DATE AND p_lease_qte_rec.valid_from <> OKL_API.G_MISS_DATE THEN
        IF p_lease_qte_rec.valid_to < p_lease_qte_rec.valid_from THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_INVALID_VALID_TO');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;
    --asawanka bug 4923624 changes end

    --Fixed Bug # 5647107 added Bug ssdeshpa start
    validate_le_id(p_le_id           => p_lease_qte_rec.legal_entity_id,
                   p_parent_obj_code => p_lease_qte_rec.parent_object_code,
                   x_return_status    => x_return_status );
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Fixed Bug # 5647107 added Bug ssdeshpa end

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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_lease_qte;

  -----------------------------------
  -- PROCEDURE populate_quote_attribs
  -----------------------------------
  PROCEDURE populate_quote_attribs (
    p_source_quote_id           IN  NUMBER
   ,x_quote_rec                 IN OUT NOCOPY lease_qte_rec_type
   ,x_return_status             OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'populate_quote_attribs';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
  --Bug # 5021937 ssdeshpa start
  BEGIN

      SELECT
     structured_pricing
    ,line_level_pricing
    ,lease_rate_factor
    ,target_rate_type
    ,target_rate
    ,target_amount
    ,target_frequency
    ,target_arrears_yn
    ,target_periods
    ,rate_card_id
    ,rate_template_id
    ,lease_rate_factor
      INTO
     x_quote_rec.structured_pricing
    ,x_quote_rec.line_level_pricing
    ,x_quote_rec.lease_rate_factor
    ,x_quote_rec.target_rate_type
    ,x_quote_rec.target_rate
    ,x_quote_rec.target_amount
    ,x_quote_rec.target_frequency
    ,x_quote_rec.target_arrears_yn
    ,x_quote_rec.target_periods
    ,x_quote_rec.rate_card_id
    ,x_quote_rec.rate_template_id
    ,x_quote_rec.lease_rate_factor
      FROM okl_lease_quotes_v
      WHERE id = p_source_quote_id;
    --Bug # 5021937 ssdeshpa end

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
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END populate_quote_attribs;
  ----------------------------------------------
  -- PROCEDURE copy_yields added for bug 4936130
  ----------------------------------------------
  PROCEDURE copy_yields (
    p_source_quote_id           IN  NUMBER
   ,x_quote_rec                 IN OUT NOCOPY lease_qte_rec_type
   ,x_return_status             OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'copy_yields';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    SELECT
     iir,
     booking_yield,
     pirr,
     airr,
     sub_iir,
     sub_booking_yield,
     sub_pirr,
     sub_airr
      INTO
     x_quote_rec.iir
    ,x_quote_rec.booking_yield
    ,x_quote_rec.pirr
    ,x_quote_rec.airr
    ,x_quote_rec.sub_iir
    ,x_quote_rec.sub_booking_yield
    ,x_quote_rec.sub_pirr
    ,x_quote_rec.sub_airr
      FROM okl_lease_quotes_v
      WHERE id = p_source_quote_id;

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
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END copy_yields;

  --------------------------
  -- PROCEDURE get_quote_rec
  --------------------------
  PROCEDURE get_quote_rec ( p_quote_id         IN  NUMBER
               ,x_quote_rec        OUT NOCOPY lease_qte_rec_type
               ,x_return_status    OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_quote_rec';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

      SELECT
         attribute_category
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
        ,object_version_number
    ,parent_object_id
    ,parent_object_code
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
    ,target_rate_type
    ,target_rate
    ,target_amount
    ,target_frequency
    ,target_arrears_yn
    ,target_periods
    ,structured_pricing
    ,line_level_pricing
    ,lease_rate_factor
    ,rate_card_id
    ,rate_template_id
    ,iir
    ,booking_yield
    ,pirr
    ,airr
    ,sub_iir
    ,sub_booking_yield
    ,sub_pirr
    ,sub_airr
    ,primary_quote
    ,legal_entity_id
        ,short_description
        ,description
        ,comments
      INTO
         x_quote_rec.attribute_category
        ,x_quote_rec.attribute1
        ,x_quote_rec.attribute2
        ,x_quote_rec.attribute3
        ,x_quote_rec.attribute4
        ,x_quote_rec.attribute5
        ,x_quote_rec.attribute6
        ,x_quote_rec.attribute7
        ,x_quote_rec.attribute8
        ,x_quote_rec.attribute9
        ,x_quote_rec.attribute10
        ,x_quote_rec.attribute11
        ,x_quote_rec.attribute12
        ,x_quote_rec.attribute13
        ,x_quote_rec.attribute14
        ,x_quote_rec.attribute15
        ,x_quote_rec.reference_number
        ,x_quote_rec.object_version_number
    ,x_quote_rec.parent_object_id
    ,x_quote_rec.parent_object_code
    ,x_quote_rec.valid_from
    ,x_quote_rec.valid_to
    ,x_quote_rec.customer_bookclass
    ,x_quote_rec.customer_taxowner
    ,x_quote_rec.expected_start_date
    ,x_quote_rec.expected_funding_date
    ,x_quote_rec.expected_delivery_date
    ,x_quote_rec.pricing_method
    ,x_quote_rec.term
    ,x_quote_rec.product_id
    ,x_quote_rec.end_of_term_option_id
    ,x_quote_rec.usage_category
    ,x_quote_rec.usage_industry_class
    ,x_quote_rec.usage_industry_code
    ,x_quote_rec.usage_amount
    ,x_quote_rec.usage_location_id
    ,x_quote_rec.property_tax_applicable
    ,x_quote_rec.property_tax_billing_type
    ,x_quote_rec.upfront_tax_treatment
    ,x_quote_rec.upfront_tax_stream_type
    ,x_quote_rec.transfer_of_title
    ,x_quote_rec.age_of_equipment
    ,x_quote_rec.purchase_of_lease
    ,x_quote_rec.sale_and_lease_back
    ,x_quote_rec.interest_disclosed
    ,x_quote_rec.target_rate_type
    ,x_quote_rec.target_rate
    ,x_quote_rec.target_amount
    ,x_quote_rec.target_frequency
    ,x_quote_rec.target_arrears_yn
    ,x_quote_rec.target_periods
    ,x_quote_rec.structured_pricing
    ,x_quote_rec.line_level_pricing
    ,x_quote_rec.lease_rate_factor
    ,x_quote_rec.rate_card_id
    ,x_quote_rec.rate_template_id
    ,x_quote_rec.iir
    ,x_quote_rec.booking_yield
    ,x_quote_rec.pirr
    ,x_quote_rec.airr
    ,x_quote_rec.sub_iir
    ,x_quote_rec.sub_booking_yield
    ,x_quote_rec.sub_pirr
    ,x_quote_rec.sub_airr
    ,x_quote_rec.primary_quote
    ,x_quote_rec.legal_entity_id
        ,x_quote_rec.short_description
        ,x_quote_rec.description
        ,x_quote_rec.comments
      FROM okl_lease_quotes_v
      WHERE id = p_quote_id;

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
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_quote_rec;

  -------------------------------------
  -- PROCEDURE cancel_quote_lines
  -------------------------------------
  PROCEDURE cancel_quote_lines(p_api_version             IN  NUMBER,
                               p_init_msg_list           IN  VARCHAR2,
                 p_quote_id            IN NUMBER,
                 x_msg_count               OUT NOCOPY NUMBER,
                               x_msg_data                OUT NOCOPY VARCHAR2,
                               x_return_status           OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'cancel_quote_lines';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  CURSOR c_get_assets IS
  SELECT id
  FROM OKL_ASSETS_B
  WHERE PARENT_OBJECT_ID = p_quote_id
  AND PARENT_OBJECT_CODE = 'LEASEQUOTE';

  CURSOR c_get_fees IS
  SELECT id
  FROM OKL_FEES_B
  WHERE PARENT_OBJECT_ID = p_quote_id
  AND PARENT_OBJECT_CODE = 'LEASEQUOTE';

  CURSOR c_get_services IS
  SELECT id
  FROM OKL_SERVICES_B
  WHERE PARENT_OBJECT_ID = p_quote_id
  AND PARENT_OBJECT_CODE = 'LEASEQUOTE';

  CURSOR c_get_ins_estimates IS
  SELECT id
  FROM OKL_INSURANCE_ESTIMATES_B
  WHERE LEASE_QUOTE_ID = p_quote_id;

  BEGIN

  -- Cancel Assets
    FOR l_get_assets IN c_get_assets LOOP
      OKL_LEASE_QUOTE_ASSET_PVT.delete_asset (
                 p_api_version             => p_api_version
                ,p_init_msg_list           => 'T'
                ,p_transaction_control     => 'T'
                ,p_asset_id                => l_get_assets.id
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

  -- Cancel Fees
    FOR l_get_fees IN c_get_fees LOOP
      OKL_LEASE_QUOTE_FEE_PVT.delete_fee (
                 p_api_version             => p_api_version
                ,p_init_msg_list           => 'T'
                ,p_transaction_control     => 'T'
                ,p_fee_id                  => l_get_fees.id
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

  -- Cancel Services
    FOR l_get_services IN c_get_services LOOP
      OKL_LEASE_QUOTE_SERVICE_PVT.delete_service (
                 p_api_version             => p_api_version
                ,p_init_msg_list           => 'T'
                ,p_transaction_control     => 'T'
                ,p_service_id              => l_get_services.id
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

  -- Cancel Insurance Estimates
    FOR l_get_ins_estimates IN c_get_ins_estimates LOOP
      OKL_LEASE_QUOTE_INS_PVT.delete_insurance_estimate (
                 p_api_version             => p_api_version
                ,p_init_msg_list           => 'T'
                ,p_transaction_control     => 'T'
                ,p_insurance_estimate_id   => l_get_ins_estimates.id
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END cancel_quote_lines;

  -----------------------------
  -- PROCEDURE create_lease_qte
  -----------------------------
  PROCEDURE create_lease_qte (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_qte_rec           IN  lease_qte_rec_type,
                              x_lease_qte_rec           OUT NOCOPY lease_qte_rec_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_return_status    VARCHAR2(1);

    l_program_name      CONSTANT VARCHAR2(30) := 'create_lease_qte';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    l_lease_qte_rec     lease_qte_rec_type;
    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list           wf_parameter_list_t;
    p_event_name               VARCHAR2(240)       := 'oracle.apps.okl.sales.leaseapplication.alternate_offers_created';
    -- Bug#4741121 - viselvar  - Modified - End

    l_refno_unq_chk    VARCHAR2(1);--Bug 7022258

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_lease_qte_rec := p_lease_qte_rec;

    --Bug 7022258-Modified by kkorrapo
    l_lease_qte_rec.reference_number         := l_lease_qte_rec.reference_number;
    --Bug 7022258--Modification end


    l_lease_qte_rec.valid_from               := TRUNC(l_lease_qte_rec.valid_from);
    l_lease_qte_rec.valid_to                 := TRUNC(l_lease_qte_rec.valid_to);
    l_lease_qte_rec.expected_start_date      := TRUNC(l_lease_qte_rec.expected_start_date);
    l_lease_qte_rec.expected_delivery_date   := TRUNC(l_lease_qte_rec.expected_delivery_date);
    l_lease_qte_rec.expected_funding_date    := TRUNC(l_lease_qte_rec.expected_funding_date);

  IF (l_lease_qte_rec.structured_pricing IS NULL AND
    l_lease_qte_rec.line_level_pricing IS NULL) THEN
      l_lease_qte_rec.structured_pricing       := 'N';
      l_lease_qte_rec.line_level_pricing       := 'N';
    END IF;

    IF (l_lease_qte_rec.status IS NULL) THEN
      l_lease_qte_rec.status                 := 'PR-INCOMPLETE';
    END IF;

    validate_lease_qte(p_lease_qte_rec => l_lease_qte_rec,
                       x_return_status => l_return_status);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   --Bug 7022258-Added by kkorrapo
   l_refno_unq_chk := okl_util.validate_seq_num('OKL_LSQ_REF_SEQ','OKL_LEASE_QUOTES_B','REFERENCE_NUMBER',l_lease_qte_rec.reference_number);

   IF (l_refno_unq_chk = 'N') THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   --Bug 7022258--Addition end

    okl_lsq_pvt.insert_row(
                           p_api_version   => G_API_VERSION
                          ,p_init_msg_list => G_FALSE
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_lsqv_rec      => l_lease_qte_rec
                          ,x_lsqv_rec      => x_lease_qte_rec );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- if the quote is created from OCM, it is an alternate offer
    -- Bug#4741121 - viselvar  - Modified - Start
    IF (l_lease_qte_rec.status = 'CR-INCOMPLETE') THEN
      -- raise the business event passing the version id added to the parameter list
      wf_event.addparametertolist('QUOTE_ID'
                              ,x_lease_qte_rec.id
                              ,l_parameter_list);
      okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
    -- Bug#4741121 - viselvar  - Modified - End

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_lease_qte;

  -----------------------------
  -- PROCEDURE update_lease_qte
  -----------------------------
  PROCEDURE update_lease_qte (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_qte_rec           IN  lease_qte_rec_type,
                              x_lease_qte_rec           OUT NOCOPY lease_qte_rec_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_return_status    VARCHAR2(1);
    l_term_upd_allowed VARCHAR2(1);

    l_program_name      CONSTANT VARCHAR2(30) := 'update_lease_qte';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    l_lease_qte_rec     lease_qte_rec_type;

    l_copy_lse_qte      lease_qte_rec_type;

    lb_handle_subpool BOOLEAN := FALSE;
    lb_validate     BOOLEAN := TRUE;
    lv_status             okl_lease_quotes_b.status%TYPE;
    lv_leaseapp_status    okl_lease_applications_b.application_status%TYPE;
    ln_parent_object_id   okl_lease_quotes_b.parent_object_id%TYPE;

    --gboomina Bug 7033915 start
    CURSOR lease_qte_credit_app_csr (p_lap_id OKL_LEASE_QUOTES_B.parent_object_id%TYPE) IS
    SELECT 'Y'
    FROM okl_lease_quotes_b
    WHERE status = 'CR-DECLINED'
    AND parent_object_code = 'LEASEAPP'
    AND PARENT_OBJECT_ID =  p_lap_id;

      CURSOR lap_status_csr(cp_lap_id NUMBER)
        IS
       SELECT APPLICATION_STATUS LAP_STATUS
       FROM  OKL_LEASE_APPLICATIONS_B
       WHERE ID = cp_lap_id;
     l_lap_status OKL_LEASE_APPLICATIONS_B.application_status%type;

    l_primary_quote VARCHAR2(1) := 'N';
    l_ct_declined_exist VARCHAR2(1) := 'N';
    --gboomina Bug 7033915 end

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF ((p_lease_qte_rec.parent_object_code IS NULL OR
       p_lease_qte_rec.parent_object_code = OKL_API.G_MISS_CHAR) OR
        p_lease_qte_rec.object_version_number IS NULL ) THEN

      lb_validate := FALSE;

    END IF;

    l_lease_qte_rec := p_lease_qte_rec;

    -- Begin -- Added for Bug# 6930574
    IF l_lease_qte_rec.expected_start_date <> FND_API.G_MISS_DATE THEN
      l_term_upd_allowed := is_contterm_payperiod_equal(
                  p_contract_start_date => l_lease_qte_rec.expected_start_date,
                  p_contract_term       => l_lease_qte_rec.term,
                  p_quote_id            => l_lease_qte_rec.id);
      IF l_term_upd_allowed <> 'Y' THEN
        OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME,
                             p_msg_name => 'OKL_LEVEL_EXTENDS_K_END');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- End -- Added for Bug# 6930574

    IF (lb_validate) THEN
      l_lease_qte_rec.valid_from               := TRUNC(l_lease_qte_rec.valid_from);
      l_lease_qte_rec.valid_to                 := TRUNC(l_lease_qte_rec.valid_to);
      l_lease_qte_rec.expected_start_date      := TRUNC(l_lease_qte_rec.expected_start_date);
      l_lease_qte_rec.expected_delivery_date   := TRUNC(l_lease_qte_rec.expected_delivery_date);
      l_lease_qte_rec.expected_funding_date    := TRUNC(l_lease_qte_rec.expected_funding_date);

      validate_lease_qte(p_lease_qte_rec => l_lease_qte_rec,
                         x_return_status => l_return_status);
      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- This populates other quote attributes which are not visible from the
      -- update quote page
      IF (l_lease_qte_rec.structured_pricing IS NULL AND
      l_lease_qte_rec.line_level_pricing IS NULL) THEN
        populate_quote_attribs(p_source_quote_id => l_lease_qte_rec.id,
                               x_quote_rec       => l_lease_qte_rec,
                               x_return_status   => l_return_status);
        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    END IF;

    SELECT object_version_number, parent_object_code, status, parent_object_id
    , nvl(primary_quote, 'N') -- -- 7033915
    INTO l_lease_qte_rec.object_version_number,
     l_lease_qte_rec.parent_object_code,
     lv_status,
     ln_parent_object_id
     ,l_primary_quote -- 7033915
    FROM okl_lease_quotes_v
    WHERE id = l_lease_qte_rec.id;

    -- gboomina Bug 7033915 start
    l_ct_declined_exist := 'N';
    OPEN lease_qte_credit_app_csr (ln_parent_object_id);
    FETCH lease_qte_credit_app_csr INTO l_ct_declined_exist;
    IF lease_qte_credit_app_csr%NOTFOUND THEN
      l_ct_declined_exist := 'N';
    END IF;
    CLOSE lease_qte_credit_app_csr;
    -- gboomina Bug 7033915 end

     OPEN lap_status_csr (ln_parent_object_id);
     FETCH lap_status_csr INTO l_lap_status;
     CLOSE lap_status_csr;

    -- Check for 'CR-RECOMMENDATION' quote (Bug 4893112)
    -- Bug 5149367
    -- gboomin Bug 7033915 start

    IF (l_lap_status in ('PR-ACCEPTED')) THEN  -- Added for bug 7427166
      l_lease_qte_rec.status :=  'CT-ACCEPTED';
    ELSIF (lv_status = 'CT-ACCEPTED' AND l_primary_quote = 'Y' AND l_ct_declined_exist = 'N') THEN
      l_lease_qte_rec.status := 'CR-DECLINED';
    ELSIF (lv_status = 'CT-ACCEPTED' AND l_primary_quote = 'Y') THEN
      l_lease_qte_rec.status := 'CR-RECOMMENDATION';
    ELSIF (lv_status = 'CR-INCOMPLETE' AND  l_lease_qte_rec.status = 'PR-COMPLETE') THEN
      l_lease_qte_rec.status := 'CR-RECOMMENDATION';
    ELSIF (lv_status = 'CR-INCOMPLETE') THEN
      l_lease_qte_rec.status := 'CR-INCOMPLETE';
     ELSIF (lv_status = 'CR-RECOMMENDATION' AND  l_lease_qte_rec.status = 'PR-INCOMPLETE') THEN
        l_lease_qte_rec.status := 'CR-INCOMPLETE';
     ELSIF (lv_status = 'CR-RECOMMENDATION' AND  l_lease_qte_rec.status = 'PR-COMPLETE') THEN
        l_lease_qte_rec.status := 'CR-RECOMMENDATION';
    ELSIF (lv_status = 'CR-RECOMMENDATION') THEN
      l_lease_qte_rec.status :=  'CT-ACCEPTED'; -- 'CR-INCOMPLETE';-- 7033915
      lb_handle_subpool := TRUE;
    END IF;
    -- End Bug 5149367

    IF (l_lease_qte_rec.status <> 'CT-ACCEPTED') THEN
      IF (lv_status = 'PR-APPROVED') THEN
        lb_handle_subpool := TRUE;
        l_lease_qte_rec.status := 'PR-INCOMPLETE';
      END IF;
    END IF;

    okl_lsq_pvt.update_row(p_api_version   => G_API_VERSION
                          ,p_init_msg_list => G_FALSE
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_lsqv_rec      => l_lease_qte_rec
                          ,x_lsqv_rec      => x_lease_qte_rec );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

      -- Call the Subsidy pool API in case of Counter Offer which has status
    -- 'CR-RECOMMENDATION' (Bug 5149367)
    IF (l_lease_qte_rec.status = 'CR-RECOMMENDATION' AND l_lease_qte_rec.parent_object_code = 'LEASEAPP') THEN
	  okl_lease_quote_subpool_pvt.process_leaseapp_subsidy_pool(
           p_api_version           => p_api_version
          ,p_init_msg_list         => OKL_API.G_FALSE
          ,p_transaction_control   => OKL_API.G_TRUE
          ,p_leaseapp_id           => ln_parent_object_id
          ,p_quote_id              => l_lease_qte_rec.id
          ,p_transaction_reason    => 'APPROVE_LEASE_APP_PRICING'
          ,x_return_status         => l_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data);
      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- End Bug 5149367

    -- If the quote beneath the Lease Application is updated, lease application
    -- status is set to 'Incomplete'.
    IF (l_lease_qte_rec.parent_object_code = 'LEASEAPP' AND
    l_lease_qte_rec.status <> 'CT-ACCEPTED') THEN

      SELECT application_status
      INTO lv_leaseapp_status
      FROM okl_lease_applications_b
      where id = ln_parent_object_id;

      IF (lv_leaseapp_status IN ('PR-COMPLETE', 'PR-APPROVED')) THEN
        OKL_LEASE_APP_PVT.set_lease_app_status(p_api_version        => G_API_VERSION,
                                               p_init_msg_list      => G_FALSE,
                                               p_lap_id             => ln_parent_object_id,
                                               p_lap_status         => 'INCOMPLETE',
                                         	   x_return_status      => l_return_status,
                                               x_msg_count          => x_msg_count,
                                               x_msg_data           => x_msg_data);

        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;
    END IF;

    -- Handle Subsidy pool usage
    IF (lb_handle_subpool AND l_lease_qte_rec.parent_object_code = 'LEASEOPP') THEN
      okl_lease_quote_subpool_pvt.process_quote_subsidy_pool(
               			   p_api_version         => G_API_VERSION
                          ,p_init_msg_list       => G_TRUE
                          ,p_transaction_control => G_TRUE
                          ,p_quote_id            => l_lease_qte_rec.id
                          ,p_transaction_reason  => 'UPDATE_APPROVED_QUOTE'
                          ,x_return_status       => l_return_status
                          ,x_msg_count           => x_msg_count
                          ,x_msg_data            => x_msg_data);
      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF (lb_handle_subpool AND l_lease_qte_rec.parent_object_code = 'LEASEAPP') THEN
      okl_lease_quote_subpool_pvt.process_leaseapp_subsidy_pool(
          p_api_version           => p_api_version
         ,p_init_msg_list         => G_TRUE
         ,p_transaction_control   => G_TRUE
         ,p_leaseapp_id           => ln_parent_object_id
         ,p_transaction_reason    => 'UPDATE_LEASE_APP'
         ,p_quote_id              => l_lease_qte_rec.id
         ,x_return_status         => l_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);
      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Delete quote tax fee if one exists
    delete_quote_tax_fee( p_api_version           => p_api_version
         				 ,p_init_msg_list         => G_TRUE
         				 ,x_return_status         => l_return_status
         				 ,x_msg_count             => x_msg_count
         				 ,x_msg_data              => x_msg_data
         				 ,p_quote_id              => l_lease_qte_rec.id);
    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_lease_qte;

  -----------------------------
  -- PROCEDURE get_leaseopp_rec
  -----------------------------
  PROCEDURE get_leaseopp_rec ( p_leaseopp_id      IN  NUMBER
                  ,x_leaseopp_rec     OUT NOCOPY okl_lop_pvt.lopv_rec_type
                  ,x_return_status    OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_leaseopp_rec';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

      SELECT
         id
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
        ,object_version_number
    ,reference_number
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
        ,short_description
        ,description
        ,comments
      INTO
         x_leaseopp_rec.id
        ,x_leaseopp_rec.attribute_category
        ,x_leaseopp_rec.attribute1
        ,x_leaseopp_rec.attribute2
        ,x_leaseopp_rec.attribute3
        ,x_leaseopp_rec.attribute4
        ,x_leaseopp_rec.attribute5
        ,x_leaseopp_rec.attribute6
        ,x_leaseopp_rec.attribute7
        ,x_leaseopp_rec.attribute8
        ,x_leaseopp_rec.attribute9
        ,x_leaseopp_rec.attribute10
        ,x_leaseopp_rec.attribute11
        ,x_leaseopp_rec.attribute12
        ,x_leaseopp_rec.attribute13
        ,x_leaseopp_rec.attribute14
        ,x_leaseopp_rec.attribute15
        ,x_leaseopp_rec.object_version_number
    ,x_leaseopp_rec.reference_number
    ,x_leaseopp_rec.valid_from
    ,x_leaseopp_rec.expected_start_date
    ,x_leaseopp_rec.org_id
    ,x_leaseopp_rec.inv_org_id
    ,x_leaseopp_rec.prospect_id
    ,x_leaseopp_rec.prospect_address_id
    ,x_leaseopp_rec.cust_acct_id
    ,x_leaseopp_rec.currency_code
    ,x_leaseopp_rec.currency_conversion_type
    ,x_leaseopp_rec.currency_conversion_rate
    ,x_leaseopp_rec.currency_conversion_date
    ,x_leaseopp_rec.program_agreement_id
    ,x_leaseopp_rec.master_lease_id
    ,x_leaseopp_rec.sales_rep_id
    ,x_leaseopp_rec.sales_territory_id
    ,x_leaseopp_rec.supplier_id
    ,x_leaseopp_rec.delivery_date
    ,x_leaseopp_rec.funding_date
    ,x_leaseopp_rec.property_tax_applicable
    ,x_leaseopp_rec.property_tax_billing_type
    ,x_leaseopp_rec.upfront_tax_treatment
    ,x_leaseopp_rec.install_site_id
    ,x_leaseopp_rec.usage_category
    ,x_leaseopp_rec.usage_industry_class
    ,x_leaseopp_rec.usage_industry_code
    ,x_leaseopp_rec.usage_amount
    ,x_leaseopp_rec.usage_location_id
    ,x_leaseopp_rec.originating_vendor_id
        ,x_leaseopp_rec.short_description
        ,x_leaseopp_rec.description
        ,x_leaseopp_rec.comments
      FROM okl_lease_opportunities_v
      WHERE id = p_leaseopp_id;

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
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_leaseopp_rec;

  --------------------------------
  -- PROCEDURE copy_quote_payments
  --------------------------------
  PROCEDURE copy_quote_payments(p_api_version             IN  NUMBER,
                                p_init_msg_list           IN  VARCHAR2,
                				p_source_quote_id     IN NUMBER,
                    			p_target_quote_id         IN NUMBER,
                				x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                x_return_status           OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'copy_quote_payments';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    lv_chk_payment  VARCHAR2(1);

    CURSOR c_chk_payments IS
    SELECT 'Y'
    FROM OKL_CASH_FLOW_OBJECTS
    WHERE SOURCE_ID = p_source_quote_id
    AND SOURCE_TABLE = 'OKL_LEASE_QUOTES_B'
    AND OTY_CODE = 'LEASE_QUOTE';

    CURSOR c_chk_payments_cons IS
    SELECT 'Y'
    FROM OKL_CASH_FLOW_OBJECTS
    WHERE SOURCE_ID = p_source_quote_id
    AND SOURCE_TABLE = 'OKL_LEASE_QUOTES_B'
    AND OTY_CODE = 'LEASE_QUOTE_CONSOLIDATED';

  BEGIN

    -- Check if the Quote has header payments defined
    OPEN c_chk_payments;
    FETCH c_chk_payments INTO lv_chk_payment;
    CLOSE c_chk_payments;

    -- Copy Header level payments
    IF (lv_chk_payment = 'Y') THEN
      okl_lease_quote_cashflow_pvt.duplicate_cashflows (
        p_api_version          => p_api_version
       ,p_init_msg_list        => p_init_msg_list
       ,p_transaction_control  => 'T'
       ,p_source_object_code   => 'LEASE_QUOTE'
       ,p_source_object_id     => p_source_quote_id
       ,p_target_object_id     => p_target_quote_id
       ,p_quote_id             => p_target_quote_id
       ,x_return_status        => x_return_status
       ,x_msg_count            => x_msg_count
       ,x_msg_data             => x_msg_data
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Check if the Quote has header payments defined
    OPEN c_chk_payments_cons;
    FETCH c_chk_payments_cons INTO lv_chk_payment;
    CLOSE c_chk_payments_cons;

    -- Copy Header level payments
    IF (lv_chk_payment = 'Y') THEN
      okl_lease_quote_cashflow_pvt.duplicate_cashflows (
        p_api_version          => p_api_version
       ,p_init_msg_list        => p_init_msg_list
       ,p_transaction_control  => 'T'
       ,p_source_object_code   => 'LEASE_QUOTE_CONSOLIDATED'
       ,p_source_object_id     => p_source_quote_id
       ,p_target_object_id     => p_target_quote_id
       ,p_quote_id             => p_target_quote_id
       ,x_return_status        => x_return_status
       ,x_msg_count            => x_msg_count
       ,x_msg_data             => x_msg_data
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END copy_quote_payments;

  -------------------------------------
  -- PROCEDURE copy_configuration_lines
  -------------------------------------
  PROCEDURE copy_configuration_lines(p_api_version             IN  NUMBER,
                                     p_init_msg_list           IN  VARCHAR2,
                   					 p_source_quote_id       IN NUMBER,
                       				 p_target_quote_id       IN NUMBER,
                   					 x_msg_count               OUT NOCOPY NUMBER,
                                     x_msg_data                OUT NOCOPY VARCHAR2,
                                     x_return_status           OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'copy_configuration_lines';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    x_asset_id  NUMBER;
    x_fee_id    NUMBER;

  CURSOR c_get_assets IS
  SELECT id
  FROM OKL_ASSETS_B
  WHERE PARENT_OBJECT_ID = p_source_quote_id
  AND PARENT_OBJECT_CODE = 'LEASEQUOTE';

  CURSOR c_get_config_fees IS
  SELECT id
  FROM OKL_FEES_B
  WHERE PARENT_OBJECT_ID = p_source_quote_id
  AND PARENT_OBJECT_CODE = 'LEASEQUOTE'
  AND FEE_TYPE IN ('FINANCED', 'CAPITALIZED', 'ROLLOVER')
  AND FEE_PURPOSE_CODE IS NULL;

  BEGIN

  -- Copy Assets
    FOR l_get_assets IN c_get_assets LOOP
      OKL_LEASE_QUOTE_ASSET_PVT.duplicate_asset (
                 p_api_version             => p_api_version
                ,p_init_msg_list           => 'T'
                ,p_transaction_control     => 'T'
                ,p_source_asset_id         => l_get_assets.id
                ,p_target_quote_id         => p_target_quote_id
                ,x_target_asset_id         => x_asset_id
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

  -- Copy Configuration Fees
    FOR l_get_config_fees IN c_get_config_fees LOOP
      OKL_LEASE_QUOTE_FEE_PVT.duplicate_fee (
                 p_api_version             => p_api_version
                ,p_init_msg_list           => 'T'
                ,p_transaction_control     => 'T'
                ,p_source_fee_id           => l_get_config_fees.id
                ,p_target_quote_id         => p_target_quote_id
                ,x_fee_id                => x_fee_id
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END LOOP;

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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END copy_configuration_lines;

  -------------------------------------
  -- PROCEDURE copy_addtl_fees_services
  -------------------------------------
  PROCEDURE copy_addtl_fees_services(p_api_version             IN  NUMBER,
                                     p_init_msg_list           IN  VARCHAR2,
                   					 p_source_quote_id       IN NUMBER,
                       				 p_target_quote_id       IN NUMBER,
                   					 x_msg_count               OUT NOCOPY NUMBER,
                                     x_msg_data                OUT NOCOPY VARCHAR2,
                                     x_return_status           OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'copy_addtl_fees_services';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    x_service_id  NUMBER;
    x_fee_id    NUMBER;

  CURSOR c_get_services IS
  SELECT id
  FROM OKL_SERVICES_B
  WHERE PARENT_OBJECT_ID = p_source_quote_id
  AND PARENT_OBJECT_CODE = 'LEASEQUOTE';

  CURSOR c_get_nonconfig_fees IS
  SELECT id
  FROM OKL_FEES_B
  WHERE PARENT_OBJECT_ID = p_source_quote_id
  AND PARENT_OBJECT_CODE = 'LEASEQUOTE'
  AND FEE_TYPE NOT IN ('FINANCED', 'CAPITALIZED', 'ROLLOVER');

  BEGIN

  -- Copy Services
    FOR l_get_services IN c_get_services LOOP
      OKL_LEASE_QUOTE_SERVICE_PVT.duplicate_service (
                 p_api_version             => p_api_version
                ,p_init_msg_list           => 'T'
                ,p_transaction_control     => 'T'
                ,p_source_service_id       => l_get_services.id
                ,p_target_quote_id         => p_target_quote_id
                ,x_service_id              => x_service_id
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

  -- Copy Non-Configuration Fees
    FOR l_get_nonconfig_fees IN c_get_nonconfig_fees LOOP
      OKL_LEASE_QUOTE_FEE_PVT.duplicate_fee (
                 p_api_version             => p_api_version
                ,p_init_msg_list           => 'T'
                ,p_transaction_control     => 'T'
                ,p_source_fee_id           => l_get_nonconfig_fees.id
                ,p_target_quote_id         => p_target_quote_id
                ,x_fee_id                => x_fee_id
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END LOOP;

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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END copy_addtl_fees_services;

  -------------------------------------
  -- PROCEDURE copy_cost_adjustments
  -------------------------------------
  PROCEDURE copy_cost_adjustments(p_api_version             IN  NUMBER,
                                  p_init_msg_list           IN  VARCHAR2,
                  				  p_source_quote_id         IN  NUMBER,
                  				  p_target_quote_id         IN  NUMBER,
                  				  x_msg_count               OUT NOCOPY NUMBER,
                                  x_msg_data                OUT NOCOPY VARCHAR2,
                                  x_return_status           OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'copy_cost_adjustments';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    ln_src_eot_id		NUMBER;
    ln_tgt_eot_id		NUMBER;

    lb_dup_adj 			BOOLEAN:= TRUE;

  BEGIN

    -- Validation to check if the End-of-Term Option for source
    -- and target quotes are equal, if not assets are not copied, which is
    -- taken care in asset api, adjustments which have mandatory asset association
    -- are also not not copied
    SELECT end_of_term_option_id
    INTO ln_src_eot_id
    FROM
       okl_lease_quotes_b
    WHERE
   	   id = p_source_quote_id;

    SELECT end_of_term_option_id
    INTO ln_tgt_eot_id
    FROM
         okl_lease_quotes_b
    WHERE
         id = p_target_quote_id;

    IF (ln_src_eot_id <> ln_tgt_eot_id) THEN
      lb_dup_adj := FALSE;
	END IF;

	IF (lb_dup_adj) THEN
      OKL_LEASE_QUOTE_ASSET_PVT.duplicate_adjustments (
                 p_api_version             => p_api_version
                ,p_init_msg_list           => p_init_msg_list
                ,p_source_quote_id         => p_source_quote_id
                ,p_target_quote_id         => p_target_quote_id
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END copy_cost_adjustments;

  --------------------------------
  -- PROCEDURE duplicate_lease_qte
  --------------------------------
  PROCEDURE duplicate_lease_qte (p_api_version             IN  NUMBER,
                                 p_init_msg_list           IN  VARCHAR2,
                                 p_transaction_control     IN  VARCHAR2,
                                 p_source_quote_id         IN  NUMBER,
                                 p_lease_qte_rec           IN  lease_qte_rec_type,
                                 x_lease_qte_rec           OUT NOCOPY lease_qte_rec_type,
                                 x_return_status           OUT NOCOPY VARCHAR2,
                                 x_msg_count               OUT NOCOPY NUMBER,
                                 x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'duplicate_lease_qte';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    p_target_quote_id   NUMBER;
    lv_copy_pymnts_allowed  VARCHAR2(1) := 'Y';

    l_lease_qte_rec         lease_qte_rec_type;

  BEGIN
    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_lease_qte_rec := p_lease_qte_rec;

  IF (l_lease_qte_rec.parent_object_code = 'LEASEAPP') THEN
      -- Check if the Source and Target Quote's Product and Exp Start date are equal
      lv_copy_pymnts_allowed := copy_quote_payments_allowed(p_source_quote_id       => p_source_quote_id,
                                    p_target_pdt_id         => p_lease_qte_rec.product_id,
                                p_target_exp_start_date   => p_lease_qte_rec.expected_start_date);
  ELSE
      -- Check if the Source and Target Quote's Pricing type are equal
      lv_copy_pymnts_allowed := is_pricing_method_equal(p_source_quote_id      => p_source_quote_id,
                                p_target_pricing_type  => p_lease_qte_rec.pricing_method);
    IF (lv_copy_pymnts_allowed = 'Y') THEN
        -- Check if the Source and Target Quote's Product and Exp Start date are equal
        lv_copy_pymnts_allowed := copy_quote_payments_allowed(p_source_quote_id       => p_source_quote_id,
                                      p_target_pdt_id         => p_lease_qte_rec.product_id,
                                  p_target_exp_start_date => p_lease_qte_rec.expected_start_date);
    END IF;
  END IF;

    -- This populates other quote attributes which are not visible from the
    -- duplicate quote page
    IF (lv_copy_pymnts_allowed = 'Y') THEN
       --Bug # 5021937 ssdeshpa start
      /*IF (l_lease_qte_rec.structured_pricing IS NULL AND
      l_lease_qte_rec.line_level_pricing IS NULL) THEN*/
       --Bug # 5021937 ssdeshpa end
        populate_quote_attribs(p_source_quote_id => p_source_quote_id,
                               x_quote_rec       => l_lease_qte_rec,
                               x_return_status   => x_return_status);
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --asawanka bug 4936130 changes start
        IF (l_lease_qte_rec.parent_object_code = 'LEASEAPP'
        AND l_lease_qte_rec.status = 'CT-ACCEPTED' ) THEN
          copy_yields(p_source_quote_id => p_source_quote_id,
                      x_quote_rec       => l_lease_qte_rec,
                      x_return_status   => x_return_status);
          IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        --asawanka bug 4936130 changes end
     -- END IF;
    END IF;

    --Bug # 5021937 ssdeshpa start
    --If Pricing Method is Solve For Rate (SY) then Structured Pricing Flag
    --is always set to 'Y'
    IF(l_lease_qte_rec.pricing_method = 'SY') THEN
       l_lease_qte_rec.structured_pricing := 'Y';
    END IF;
    --Bug # 5021937 ssdeshpa end

    --Bug 7022258-Added by kkorrapo
    --l_lease_qte_rec.reference_number := okl_util.get_next_seq_num('OKL_LSQ_REF_SEQ','OKL_LEASE_QUOTES_B','REFERENCE_NUMBER');
    --Bug 7022258--Addition end

    create_lease_qte (p_api_version            => p_api_version,
                      p_init_msg_list          => p_init_msg_list,
                      p_transaction_control    => p_transaction_control,
                      p_lease_qte_rec          => l_lease_qte_rec,
                      x_lease_qte_rec          => x_lease_qte_rec,
                      x_return_status          => x_return_status,
                      x_msg_count              => x_msg_count,
                      x_msg_data               => x_msg_data);
  IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    p_target_quote_id := x_lease_qte_rec.id;

    IF (lv_copy_pymnts_allowed = 'Y') THEN
      copy_quote_payments(p_api_version            => p_api_version,
                          p_init_msg_list          => p_init_msg_list,
              			  p_source_quote_id        => p_source_quote_id,
                		  p_target_quote_id        => p_target_quote_id,
                          x_msg_count              => x_msg_count,
                          x_msg_data               => x_msg_data,
                x_return_status          => x_return_status);
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    copy_configuration_lines(p_api_version            => p_api_version,
                             p_init_msg_list          => p_init_msg_list,
               				 p_source_quote_id        => p_source_quote_id,
                 			 p_target_quote_id        => p_target_quote_id,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data,
                  			 x_return_status          => x_return_status);
  IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    copy_cost_adjustments(p_api_version            => p_api_version,
                          p_init_msg_list          => p_init_msg_list,
              			  p_source_quote_id        => p_source_quote_id,
              			  p_target_quote_id        => p_target_quote_id,
                          x_msg_count              => x_msg_count,
                          x_msg_data               => x_msg_data,
                x_return_status          => x_return_status);
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    copy_addtl_fees_services(p_api_version            => p_api_version,
                             p_init_msg_list          => p_init_msg_list,
                             p_source_quote_id        => p_source_quote_id,
                   			 p_target_quote_id        => p_target_quote_id,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data,
                 			 x_return_status          => x_return_status);
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Delete quote tax fee if one exists
    delete_quote_tax_fee( p_api_version           => p_api_version
         				 ,p_init_msg_list         => p_init_msg_list
         				 ,x_return_status         => x_return_status
         				 ,x_msg_count             => x_msg_count
         				 ,x_msg_data              => x_msg_data
         				 ,p_quote_id              => p_target_quote_id);
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END duplicate_lease_qte;

  --------------------------------
  -- PROCEDURE duplicate_lease_qte
  --------------------------------
  PROCEDURE duplicate_lease_qte (p_api_version             IN  NUMBER,
                                 p_init_msg_list           IN  VARCHAR2,
                                 p_transaction_control     IN  VARCHAR2,
                                 p_quote_id                IN  NUMBER,
                                 x_lease_qte_rec           OUT NOCOPY lease_qte_rec_type,
                                 x_return_status           OUT NOCOPY VARCHAR2,
                                 x_msg_count               OUT NOCOPY NUMBER,
                                 x_msg_data                OUT NOCOPY VARCHAR2) IS
    l_program_name      CONSTANT VARCHAR2(30) := 'duplicate_lease_qte';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_quote_rec   lease_qte_rec_type;

  BEGIN
    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    get_quote_rec ( p_quote_id       => p_quote_id,
          		    x_quote_rec      => l_quote_rec,
          			x_return_status  => x_return_status );
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Generate reference number

    --Bug 7022258-Modified by kkorrapo
    -- SELECT OKL_LSQ_SEQ.nextval INTO l_quote_rec.reference_number FROM dual;
    l_quote_rec.reference_number := okl_util.get_next_seq_num('OKL_LSQ_REF_SEQ','OKL_LEASE_QUOTES_B','REFERENCE_NUMBER');
    --Bug 7022258--Modification end

    l_quote_rec.status := 'PR-INCOMPLETE';

    duplicate_lease_qte (p_api_version             => p_api_version,
                         p_init_msg_list           => p_init_msg_list,
                         p_transaction_control     => p_transaction_control,
                         p_source_quote_id       => p_quote_id,
                         p_lease_qte_rec           => l_quote_rec,
                         x_lease_qte_rec           => x_lease_qte_rec,
                         x_return_status           => x_return_status,
                         x_msg_count               => x_msg_count,
                         x_msg_data                => x_msg_data);
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END duplicate_lease_qte;

  ------------------------------------
  -- PROCEDURE cancel_lease_qte_childs
  ------------------------------------
  PROCEDURE cancel_lease_qte_childs (p_lease_qte_rec         IN  lease_qte_rec_type
                                    ,x_return_status         OUT NOCOPY VARCHAR2
                                    ,x_msg_count             OUT NOCOPY NUMBER
                                    ,x_msg_data              OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'cancel_lease_qte_childs';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_return_status          VARCHAR2(1);

  BEGIN

    -- ASO
    -- LRE
    -- cashflow

    -- ASS
    DELETE FROM okl_assets_tl WHERE id IN
      (SELECT id FROM okl_assets_b WHERE parent_object_code = 'LEASEQUOTE' AND parent_object_id = p_lease_qte_rec.id);
    DELETE FROM okl_assets_b WHERE parent_object_code = 'LEASEQUOTE' AND parent_object_id = p_lease_qte_rec.id;

    -- FEE
    DELETE FROM okl_fees_tl WHERE id IN
      (SELECT id FROM okl_fees_b WHERE parent_object_code = 'LEASEQUOTE' AND parent_object_id = p_lease_qte_rec.id);
    DELETE FROM okl_fees_b WHERE parent_object_code = 'LEASEQUOTE' AND parent_object_id = p_lease_qte_rec.id;

    -- SVC
    DELETE FROM okl_services_tl WHERE id IN
      (SELECT id FROM okl_services_b WHERE parent_object_code = 'LEASEQUOTE' AND parent_object_id = p_lease_qte_rec.id);
    DELETE FROM okl_services_b WHERE parent_object_code = 'LEASEQUOTE' AND parent_object_id = p_lease_qte_rec.id;

    -- QUE
    DELETE FROM okl_insurance_estimates_tl WHERE id IN
      (SELECT id FROM okl_insurance_estimates_b WHERE lease_quote_id = p_lease_qte_rec.id);
    DELETE FROM okl_insurance_estimates_b WHERE lease_quote_id = p_lease_qte_rec.id;

    x_return_status  :=  G_RET_STS_SUCCESS;

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
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END cancel_lease_qte_childs;


 ------------------------------
  -- PROCEDURE cancel_lease_qte
 ------------------------------
  PROCEDURE cancel_lease_qte (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_qte_tbl           IN  lease_qte_tbl_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'cancel_lease_qte';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    i                   PLS_INTEGER;

    l_return_status     VARCHAR2(1);

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_lease_qte_tbl.COUNT > 0 THEN

      FOR i IN p_lease_qte_tbl.FIRST .. p_lease_qte_tbl.LAST LOOP

        IF p_lease_qte_tbl.EXISTS(i) THEN

      cancel_quote_lines(p_api_version      => p_api_version,
                             p_init_msg_list    => p_init_msg_list,
               p_quote_id       => p_lease_qte_tbl(i).id,
               x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data,
                             x_return_status    => l_return_status);
          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

      /*cancel_lease_qte_childs(p_lease_qte_rec  => p_lease_qte_tbl(i)
                                  ,x_msg_count     => x_msg_count
                                  ,x_msg_data      => x_msg_data
                                  ,x_return_status => l_return_status);*/

          okl_lsq_pvt.delete_row(p_api_version    => G_API_VERSION
                                 ,p_init_msg_list => G_FALSE
                                 ,x_return_status => l_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_lsqv_rec      => p_lease_qte_tbl(i));
          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;

      END LOOP;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END cancel_lease_qte;

 ------------------------------
  -- PROCEDURE submit_lease_qte
 ------------------------------
  PROCEDURE submit_lease_qte (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_quote_id            IN  NUMBER,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'submit_lease_qte';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_lease_qte_rec   lease_qte_rec_type;
    x_lease_qte_rec   lease_qte_rec_type;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

  get_quote_rec ( p_quote_id       => p_quote_id,
          x_quote_rec      => l_lease_qte_rec,
          x_return_status  => x_return_status );
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  --Validate IF Legal Entity Id is present on Quote  Bug # 5647107
  --If Upfront Tax setup is complete/Changed
      validate_le_id(p_le_id => l_lease_qte_rec.legal_entity_id,
                p_parent_obj_code => l_lease_qte_rec.parent_object_code,
                x_return_status  => x_return_status);
   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
  -- Call Submit workflow
  okl_lease_quote_workflow_pvt.raise_quote_submit_event(p_quote_id  => p_quote_id,
                              x_return_status  => x_return_status);
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Handle Subsidy pool usage
    IF (l_lease_qte_rec.parent_object_code = 'LEASEOPP') THEN
      okl_lease_quote_subpool_pvt.process_quote_subsidy_pool(
               p_api_version         => G_API_VERSION
                          ,p_init_msg_list       => G_TRUE
                          ,p_transaction_control => G_TRUE
                          ,p_quote_id            => p_quote_id
                          ,p_transaction_reason  => 'APPROVE_QUOTE'
                          ,x_return_status       => x_return_status
                          ,x_msg_count           => x_msg_count
                          ,x_msg_data            => x_msg_data);
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1     => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END submit_lease_qte;

 ------------------------------
  -- PROCEDURE accept_lease_qte
 ------------------------------
  PROCEDURE accept_lease_qte (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_quote_id            IN  NUMBER,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'accept_lease_qte';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_lease_qte_rec   lease_qte_rec_type;
    x_lease_qte_rec   lease_qte_rec_type;
    l_lease_opp_rec   okl_lop_pvt.lopv_rec_type;
    x_lease_opp_rec   okl_lop_pvt.lopv_rec_type;

    l_chk_lease_qte     VARCHAR2(1) := 'N';

    CURSOR c_chk_accept_lease_qte(p_leaseopp_id   IN  NUMBER) IS
    SELECT 'Y'
    FROM okl_lease_quotes_b
    WHERE parent_object_code = 'LEASEOPP'
    AND parent_object_id = p_leaseopp_id
    AND status = 'CT-ACCEPTED';

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

  get_quote_rec ( p_quote_id       => p_quote_id,
          x_quote_rec      => l_lease_qte_rec,
          x_return_status  => x_return_status );
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Check if any quote is accepted within this Lease Opportunity
    IF (l_lease_qte_rec.parent_object_code = 'LEASEOPP') THEN
      OPEN c_chk_accept_lease_qte(p_leaseopp_id  =>  l_lease_qte_rec.parent_object_id);
      FETCH c_chk_accept_lease_qte INTO l_chk_lease_qte;
      CLOSE c_chk_accept_lease_qte;

      IF (l_chk_lease_qte = 'Y') THEN
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_CANNOT_ACCEPT_QUOTE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSE
      --Validate IF Legal Entity Id is present on Quote  Bug # 5647107
      --If Upfront Tax setup is complete/Changed
        validate_le_id(p_le_id => l_lease_qte_rec.legal_entity_id,
                   p_parent_obj_code => l_lease_qte_rec.parent_object_code,
                   x_return_status  => x_return_status);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      -- Call Accept workflow
      okl_lease_quote_workflow_pvt.raise_quote_accept_event(p_quote_id       => p_quote_id,
                                  x_return_status  => x_return_status);
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Update the Lease opportunity with status to 'Accepted'
        get_leaseopp_rec ( p_leaseopp_id       => l_lease_qte_rec.parent_object_id,
                   x_leaseopp_rec      => l_lease_opp_rec,
                 x_return_status     => x_return_status );
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_lease_opp_rec.status := 'ACCEPTED';
        okl_lop_pvt.update_row(
                       p_api_version   => G_API_VERSION
                      ,p_init_msg_list => G_FALSE
                      ,x_return_status => x_return_status
                      ,x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data
                      ,p_lopv_rec      => l_lease_opp_rec
                      ,x_lopv_rec      => x_lease_opp_rec );
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END accept_lease_qte;

 ------------------------------
  -- PROCEDURE duplicate_quotes
 ------------------------------
  PROCEDURE duplicate_quotes(p_api_version             IN  NUMBER,
                             p_init_msg_list           IN  VARCHAR2,
                             p_transaction_control     IN  VARCHAR2,
                             p_source_leaseopp_id      IN  NUMBER,
                             p_target_leaseopp_id      IN  NUMBER,
                             x_return_status           OUT NOCOPY VARCHAR2,
                             x_msg_count               OUT NOCOPY NUMBER,
                             x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'duplicate_quotes';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    CURSOR c_get_quotes IS
    SELECT id
    FROM OKL_LEASE_QUOTES_B
    WHERE PARENT_OBJECT_ID = p_source_leaseopp_id
    AND PARENT_OBJECT_CODE = 'LEASEOPP';

    l_quote_rec   lease_qte_rec_type;
    x_lease_qte_rec lease_qte_rec_type;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

  -- Copy Quotes
    FOR l_get_quotes IN c_get_quotes LOOP

    get_quote_rec ( p_quote_id       => l_get_quotes.id,
            x_quote_rec      => l_quote_rec,
            x_return_status  => x_return_status );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Generate reference number

      --Bug 7022258-Changed by kkorrapo
      -- SELECT OKL_LSQ_SEQ.nextval INTO l_quote_rec.reference_number FROM dual;
      l_quote_rec.reference_number := okl_util.get_next_seq_num('OKL_LSQ_REF_SEQ','OKL_LEASE_QUOTES_B','REFERENCE_NUMBER');
     --Bug 7022258--Change end

      l_quote_rec.parent_object_id := p_target_leaseopp_id;
      l_quote_rec.status := 'PR-INCOMPLETE';

      duplicate_lease_qte (p_api_version             => p_api_version,
                           p_init_msg_list           => 'T',
                           p_transaction_control     => 'T',
                           p_source_quote_id     => l_get_quotes.id,
                           p_lease_qte_rec           => l_quote_rec,
                           x_lease_qte_rec           => x_lease_qte_rec,
                           x_return_status           => x_return_status,
                           x_msg_count               => x_msg_count,
                           x_msg_data                => x_msg_data);
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END duplicate_quotes;

  --------------------------------
  -- PROCEDURE change_quote_status
  --------------------------------
  PROCEDURE change_quote_status(p_quote_id         IN  NUMBER,
                                p_qte_status       IN  VARCHAR2,
                                x_return_status    OUT NOCOPY VARCHAR2) IS

    lx_return_status  VARCHAR2(1);
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(4000);

    l_lease_qte_rec   okl_lsq_pvt.lsqv_rec_type;
    x_lease_qte_rec   okl_lsq_pvt.lsqv_rec_type;

    -- Bug 4713798 - Added cursor
    CURSOR c_obj
    IS
    SELECT object_version_number
    FROM okl_lease_quotes_b
    WHERE id = p_quote_id;

  BEGIN

    l_lease_qte_rec.id := p_quote_id;
    l_lease_qte_rec.status := p_qte_status;

    OPEN c_obj;
    FETCH c_obj INTO l_lease_qte_rec.object_version_number;
    CLOSE c_obj;

    okl_lsq_pvt.update_row(p_api_version   => G_API_VERSION
                          ,p_init_msg_list => G_FALSE
                          ,x_return_status => lx_return_status
                          ,x_msg_count     => lx_msg_count
                          ,x_msg_data      => lx_msg_data
                          ,p_lsqv_rec      => l_lease_qte_rec
                          ,x_lsqv_rec      => x_lease_qte_rec );

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status :=  lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END change_quote_status;

 ------------------------------
  -- PROCEDURE unaccept_lease_qte
 ------------------------------
  PROCEDURE unaccept_lease_qte (p_api_version             IN  NUMBER,
                                p_init_msg_list           IN  VARCHAR2,
                                p_transaction_control     IN  VARCHAR2,
                                p_quote_id            IN  NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'unacpt_qte';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_lease_qte_rec   lease_qte_rec_type;
    x_lease_qte_rec   lease_qte_rec_type;
    l_lease_opp_rec   okl_lop_pvt.lopv_rec_type;
    x_lease_opp_rec   okl_lop_pvt.lopv_rec_type;

    l_chk_lease_qte     VARCHAR2(1) := 'N';

    CURSOR c_chk_accept_lease_qte(p_leaseopp_id   IN  NUMBER) IS
    SELECT 'Y'
    FROM okl_lease_quotes_b
    WHERE parent_object_code = 'LEASEOPP'
    AND parent_object_id = p_leaseopp_id
    AND status = 'CT-ACCEPTED';

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

  get_quote_rec ( p_quote_id       => p_quote_id,
          x_quote_rec      => l_lease_qte_rec,
          x_return_status  => x_return_status );
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

      change_quote_status(p_quote_id      => p_quote_id,
                          p_qte_status    => 'PR-APPROVED',
                          x_return_status => x_return_status);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    -- Check if any quote is accepted within this Lease Opportunity
    IF (l_lease_qte_rec.parent_object_code = 'LEASEOPP') THEN
        -- Update the Lease opportunity with status to 'Incomplete'
        get_leaseopp_rec ( p_leaseopp_id       => l_lease_qte_rec.parent_object_id,
                   x_leaseopp_rec      => l_lease_opp_rec,
                 x_return_status     => x_return_status );
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_lease_opp_rec.status := 'INCOMPLETE';
        okl_lop_pvt.update_row(
                       p_api_version   => G_API_VERSION
                      ,p_init_msg_list => G_FALSE
                      ,x_return_status => x_return_status
                      ,x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data
                      ,p_lopv_rec      => l_lease_opp_rec
                      ,x_lopv_rec      => x_lease_opp_rec );
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END unaccept_lease_qte;
  ------------------------------------------------------------------------------
  --Bug 5171476 ssdeshpa start
  --------------------------
  -- PROCEDURE get_asset_rec
  --------------------------
  PROCEDURE get_asset_rec (
    p_asset_id                  IN  NUMBER
   ,x_asset_rec                 OUT NOCOPY okl_ass_pvt.assv_rec_type
   ,x_return_status             OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_asset_rec';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

      SELECT
         id
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
        ,object_version_number
        ,asset_number
        ,parent_object_id
        ,parent_object_code
        ,install_site_id
        ,rate_card_id
        ,rate_template_id
        ,oec
        ,end_of_term_value_default
        ,end_of_term_value
        ,oec_percentage
    	,structured_pricing
    	,target_arrears
    	,lease_rate_factor
    	,target_amount
    	,target_frequency
        ,short_description
        ,description
        ,comments
      INTO
         x_asset_rec.id
        ,x_asset_rec.attribute_category
        ,x_asset_rec.attribute1
        ,x_asset_rec.attribute2
        ,x_asset_rec.attribute3
        ,x_asset_rec.attribute4
        ,x_asset_rec.attribute5
        ,x_asset_rec.attribute6
        ,x_asset_rec.attribute7
        ,x_asset_rec.attribute8
        ,x_asset_rec.attribute9
        ,x_asset_rec.attribute10
        ,x_asset_rec.attribute11
        ,x_asset_rec.attribute12
        ,x_asset_rec.attribute13
        ,x_asset_rec.attribute14
        ,x_asset_rec.attribute15
        ,x_asset_rec.object_version_number
        ,x_asset_rec.asset_number
        ,x_asset_rec.parent_object_id
        ,x_asset_rec.parent_object_code
        ,x_asset_rec.install_site_id
        ,x_asset_rec.rate_card_id
        ,x_asset_rec.rate_template_id
        ,x_asset_rec.oec
        ,x_asset_rec.end_of_term_value_default
        ,x_asset_rec.end_of_term_value
        ,x_asset_rec.oec_percentage
    	,x_asset_rec.structured_pricing
    	,x_asset_rec.target_arrears
    	,x_asset_rec.lease_rate_factor
    	,x_asset_rec.target_amount
    	,x_asset_rec.target_frequency
        ,x_asset_rec.short_description
        ,x_asset_rec.description
        ,x_asset_rec.comments
      FROM okl_assets_v
      WHERE id = p_asset_id;

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
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_asset_rec;
  ------------------------------------------------------------------------------
  PROCEDURE update_cash_flows(p_quote_id   NUMBER
                       ,p_source_object_code IN VARCHAR2
                       ,p_source_object_id   IN NUMBER
                       ,x_return_status      OUT NOCOPY VARCHAR2
                       ,x_msg_count          OUT NOCOPY NUMBER
                       ,x_msg_data           OUT NOCOPY VARCHAR2) IS


    CURSOR c_get_cashflow_info(p_src_id    OKL_CASH_FLOW_OBJECTS.SOURCE_ID%TYPE
                               ,p_oty_code  OKL_CASH_FLOW_OBJECTS.OTY_CODE%TYPE
                               ,p_source_table OKL_CASH_FLOW_OBJECTS.SOURCE_TABLE%TYPE)
    IS
    SELECT CFLOW.ID , CFLOW.OBJECT_VERSION_NUMBER
    FROM   OKL_CASH_FLOWS CFLOW, OKL_CASH_FLOW_OBJECTS CFO
    WHERE CFO.SOURCE_ID = p_src_id
    AND   CFO.OTY_CODE = p_oty_code
    AND CFO.SOURCE_TABLE=p_source_table
    AND CFLOW.CFO_ID = CFO.ID;

    lp_source_table        OKL_CASH_FLOW_OBJECTS.SOURCE_TABLE%TYPE;
    lv_stream_type_purpose VARCHAR2(150);
    i                      BINARY_INTEGER := 0;
    l_program_name         CONSTANT VARCHAR2(30) := 'ppltu_cfl';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    l_api_version          NUMBER := 1.0;
    lp_cafv_tbl            OKL_CAF_PVT.cafv_tbl_type;
    lx_cafv_tbl            OKL_CAF_PVT.cafv_tbl_type;

    lx_error_tbl           OKL_API.ERROR_TBL_TYPE;
    BEGIN
    IF(p_source_object_code = 'QUOTED_ASSET') THEN
      lp_source_table := 'OKL_ASSETS_B';
    ELSIF(p_source_object_code = 'LEASE_QUOTE') THEN
      lp_source_table := 'OKL_LEASE_QUOTES_B';
    END IF;
    i := 1;
    FOR l_get_cashflow_object_info IN c_get_cashflow_info(p_src_id       => p_source_object_id
                                                          ,p_oty_code     => p_source_object_code
                                                          ,p_source_table => lp_source_table)LOOP
      lp_cafv_tbl(i).id := l_get_cashflow_object_info.id;
      lp_cafv_tbl(i).sts_code := 'CURRENT';
      lp_cafv_tbl(i).object_version_number :=l_get_cashflow_object_info.object_version_number;
      i := i + 1;

    END LOOP;

    OKL_CAF_PVT.update_row(p_api_version           => l_api_version
                           ,p_init_msg_list        => G_FALSE
                           ,p_cafv_tbl             => lp_cafv_tbl
                           ,x_cafv_tbl             => lx_cafv_tbl
                           ,px_error_tbl           => lx_error_tbl
                           ,x_return_status        => x_return_status
                           ,x_msg_count            => x_msg_count
                           ,x_msg_data             => x_msg_data);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
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
                               p_token1_value => l_program_name,
                               p_token2       => G_SQLCODE_TOKEN,
                               p_token2_value => sqlcode,
                               p_token3       => G_SQLERRM_TOKEN,
                               p_token3_value => sqlerrm);

          x_return_status := G_RET_STS_UNEXP_ERROR;



   END update_cash_flows;

  ------------------------------------------------------------------------------
  PROCEDURE change_pricing (p_api_version              IN  NUMBER,
                            p_init_msg_list           IN  VARCHAR2,
                            p_transaction_control     IN  VARCHAR2,
                            p_quote_id                IN  NUMBER,
                            x_return_status           OUT NOCOPY VARCHAR2,
                            x_msg_count               OUT NOCOPY NUMBER,
                            x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'chng_prcng';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    lp_lease_qte_rec   lease_qte_rec_type;
    lx_lease_qte_rec   lease_qte_rec_type;

    lp_asset_count             NUMBER;
    i                          NUMBER := 1;
    lp_asset_tbl          okl_ass_pvt.assv_tbl_type;
    lx_asset_rec          okl_ass_pvt.assv_rec_type;

    lp_cashflow_header_rec OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_header_rec_type;
    lp_cashflow_level_tbl  OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type;


    CURSOR get_asset_count(lp_quote_id NUMBER) IS
     SELECT COUNT(*)
     FROM OKL_ASSETS_B
     where parent_object_code = 'LEASEQUOTE'
     AND parent_object_id = lp_quote_id;

    CURSOR c_get_quote_assets(p_parent_object_id NUMBER) IS
      select OAB.id
      FROM OKL_LEASE_QUOTES_B OLQ,OKL_ASSETS_B OAB
      where OAB.PARENT_OBJECT_ID = OLQ.ID
      AND OAB.PARENT_OBJECT_CODE='LEASEQUOTE'
      AND OLQ.ID= p_parent_object_id;

    begin
     IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Get Lease Quote Rec
    get_quote_rec( p_quote_id      => p_quote_id
                  ,x_quote_rec     => lp_lease_qte_rec
                  ,x_return_status => x_return_status );
    lp_lease_qte_rec.id := p_quote_id;

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN get_asset_count(p_quote_id);
    FETCH get_asset_count INTO lp_asset_count;
    CLOSE get_asset_count;
    i := 1;
    FOR quote_asset_rec IN c_get_quote_assets(p_quote_id) LOOP

        get_asset_rec(p_asset_id  => quote_asset_rec.id
                     ,x_asset_rec => lp_asset_tbl(i)
                     ,x_return_status => x_return_status);
        IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF(x_return_status = G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        i := i + 1;
    END LOOP;
    --Delete all Lease Quote Consolidated Cash Flows
    OKL_LEASE_QUOTE_CASHFLOW_PVT.delete_cashflows (p_api_version   => G_API_VERSION
                                                   ,p_init_msg_list => G_FALSE
                                                   ,p_transaction_control => G_FALSE
                                                   ,p_source_object_code => 'LEASE_QUOTE_CONSOLIDATED'
                                                   ,p_source_object_id   => p_quote_id
                                                   ,x_return_status => x_return_status
                                                   ,x_msg_count     => x_msg_count
                                                   ,x_msg_data      => x_msg_data);

        IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF(x_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    IF(lp_asset_count > 1) THEN
      lp_lease_qte_rec.STRUCTURED_PRICING := NULL;
      lp_lease_qte_rec.LINE_LEVEL_PRICING := 'Y';
      lp_lease_qte_rec.RATE_TEMPLATE_ID := NULL;
    lp_lease_qte_rec.TARGET_AMOUNT := NULL;


        OKL_LEASE_QUOTE_CASHFLOW_PVT.delete_cashflows (
                              p_api_version   => G_API_VERSION
                              ,p_init_msg_list => G_FALSE
                              ,p_transaction_control => G_TRUE  --Check this
                              ,p_source_object_code => 'LEASE_QUOTE'
                              ,p_source_object_id   => p_quote_id
                              ,x_return_status => x_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data);

        IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF(x_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    --Delete Cash Flows for Quote Completed
    --Loop on All Assets ;Set Sp=Y Nullified SRT and change all cash flows from
    --Work to Current
    FOR i IN lp_asset_tbl.FIRST..lp_asset_tbl.LAST LOOP
        IF(lp_asset_tbl.EXISTS(i)) THEN
           --Reset Pricing Values
           lp_asset_tbl(i).structured_pricing :='Y';
           lp_asset_tbl(i).rate_template_id := NULL;
           lp_asset_tbl(i).TARGET_AMOUNT := NULL;
           lp_asset_tbl(i).TARGET_FREQUENCY := NULL;
           --Reset Pricing Values

           update_cash_flows(p_quote_id            => p_quote_id
                               ,p_source_object_code => 'QUOTED_ASSET'
                               ,p_source_object_id   => lp_asset_tbl(i).id
                               ,x_return_status      => x_return_status
                               ,x_msg_count          => x_msg_count
                               ,x_msg_data           => x_msg_data);
           IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF(x_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           okl_ass_pvt.update_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_rec      => lp_asset_tbl(i)
                           ,x_assv_rec      => lx_asset_rec);
            IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;



        END IF;
     END LOOP;
    ELSE

      lp_lease_qte_rec.STRUCTURED_PRICING := 'Y';
      lp_lease_qte_rec.LINE_LEVEL_PRICING := 'N';

      update_cash_flows(p_quote_id            => p_quote_id
                       ,p_source_object_code => 'LEASE_QUOTE'
                       ,p_source_object_id   => lp_lease_qte_rec.id
                       ,x_return_status      => x_return_status
                       ,x_msg_count          => x_msg_count
                       ,x_msg_data           => x_msg_data);
       IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF(x_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      FOR i IN lp_asset_tbl.FIRST..lp_asset_tbl.LAST LOOP
        IF(lp_asset_tbl.EXISTS(i)) THEN
           --Reset Pricing Values
           lp_asset_tbl(i).structured_pricing :=NULL;
           lp_asset_tbl(i).rate_template_id := NULL;
           lp_asset_tbl(i).TARGET_AMOUNT := NULL;
           lp_asset_tbl(i).TARGET_FREQUENCY := NULL;

           OKL_LEASE_QUOTE_CASHFLOW_PVT.delete_cashflows (
                              p_api_version   => G_API_VERSION
                              ,p_init_msg_list => G_FALSE
                              ,p_transaction_control => G_FALSE  --Check this
                              ,p_source_object_code  => 'QUOTED_ASSET'
                              ,p_source_object_id    => lp_asset_tbl(i).id
                              ,x_return_status => x_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data);

        IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF(x_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        okl_ass_pvt.update_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_rec      => lp_asset_tbl(i)
                           ,x_assv_rec      => lx_asset_rec);
            IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

      END IF;
    END LOOP;

   END IF;
    --Change the Quote Pricing method to 'Solve for Yield'(Lookup Code 'SY')
    --change quote Status to incomplete.

    lp_lease_qte_rec.pricing_method := 'SY';
    lp_lease_qte_rec.status := 'PR-INCOMPLETE';

    lp_lease_qte_rec.TARGET_ARREARS_YN := NULL;
    lp_lease_qte_rec.IIR := NULL;
    lp_lease_qte_rec.BOOKING_YIELD := NULL;
    lp_lease_qte_rec.PIRR := NULL;
    lp_lease_qte_rec.SUB_IIR := NULL;
    lp_lease_qte_rec.SUB_BOOKING_YIELD := NULL;
    lp_lease_qte_rec.SUB_PIRR := NULL;
    --Check other parameters need to be Reset

    okl_lsq_pvt.update_row(p_api_version   => G_API_VERSION
                          ,p_init_msg_list => G_FALSE
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_lsqv_rec      => lp_lease_qte_rec
                          ,x_lsqv_rec      => lx_lease_qte_rec );

     IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF(x_return_status = G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    END change_pricing;
    --Bug 5171476 ssdeshpa end

/*========================================================================
 | PUBLIC PROCEDURE calculate_sales_tax
 |
 | DESCRIPTION
 |    This procedure makes call to calculate sales tax
 |
 | CALLED FROM 					Sales component
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 |
 | PARAMETERS
 |      p_quote_id            -- Quote Identifier
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date          Author     Description of Changes
 | 05-JUL-07    RRAVIKIR      Created
 |
 *=======================================================================*/
  PROCEDURE calculate_sales_tax(p_api_version              IN  NUMBER,
                                p_init_msg_list            IN  VARCHAR2,
                                x_return_status            OUT NOCOPY VARCHAR2,
                                x_msg_count                OUT NOCOPY NUMBER,
                                x_msg_data                 OUT NOCOPY VARCHAR2,
                                p_transaction_control      IN  VARCHAR2,
                                p_quote_id                 IN  NUMBER) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'calculate_sales_tax';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_assets_total_tax         NUMBER;
    l_tax_treatment            VARCHAR2(30);
    l_tax_stream_type          NUMBER;
    l_pricing_method		   VARCHAR2(30);
    l_parent_object_code	   VARCHAR2(30);
    l_parent_object_id	   	   NUMBER;
    i                          NUMBER;
    l_asset_tax_amt            NUMBER;
    lx_fee_id                  NUMBER;
    l_tax_fee_exists           VARCHAR2(1);

    l_qte_fee_rec              lease_qte_fee_rec_type;
    l_line_relation_tbl        okl_lease_quote_fee_pvt.line_relation_tbl_type;

    l_payment_header_rec       okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    l_payment_level_tbl        okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;

    l_expense_header_rec       okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    l_expense_level_tbl        okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;

    CURSOR l_get_assets_tax_amount(cp_quote_id IN NUMBER) IS
    SELECT SUM(total_tax)
    FROM okl_tax_sources
    WHERE trx_id = cp_quote_id
    AND asset_number IS NOT NULL
    AND entity_code = OKL_PROCESS_SALES_TAX_PVT.G_SQ_ENTITY_CODE
    AND event_class_code = OKL_PROCESS_SALES_TAX_PVT.G_SQ_EVENT_CLASS_CODE
    AND application_id = OKL_PROCESS_SALES_TAX_PVT.G_OKL_APPLICATION_ID
    AND trx_level_type = OKL_PROCESS_SALES_TAX_PVT.G_TRX_LEVEL_TYPE;

    CURSOR l_get_tax_treatment(cp_quote_id IN NUMBER) IS
    SELECT upfront_tax_treatment, upfront_tax_stream_type,
		   pricing_method, parent_object_code, parent_object_id
    FROM okl_lease_quotes_b
    WHERE id = cp_quote_id;

    CURSOR l_get_assets(cp_quote_id IN NUMBER) IS
    SELECT id, asset_number
    FROM okl_assets_b
    WHERE parent_object_id = cp_quote_id
    AND parent_object_code = 'LEASEQUOTE';

    CURSOR l_get_asset_tax_amount(cp_quote_id IN NUMBER, cp_asset_number IN VARCHAR2) IS
    SELECT total_tax
    FROM okl_tax_sources
    WHERE trx_id = cp_quote_id
    AND asset_number = cp_asset_number
    AND entity_code = OKL_PROCESS_SALES_TAX_PVT.G_SQ_ENTITY_CODE
    AND event_class_code = OKL_PROCESS_SALES_TAX_PVT.G_SQ_EVENT_CLASS_CODE
    AND application_id = OKL_PROCESS_SALES_TAX_PVT.G_OKL_APPLICATION_ID
    AND trx_level_type = OKL_PROCESS_SALES_TAX_PVT.G_TRX_LEVEL_TYPE;

    CURSOR l_check_tax_fee_exists(cp_quote_id IN NUMBER) IS
    SELECT '1'
    FROM okl_fees_b
    WHERE parent_object_id = cp_quote_id
    AND parent_object_code = 'LEASEQUOTE'
    AND fee_purpose_code = 'SALESTAX';

    CURSOR l_fee_details(cp_quote_id IN NUMBER) IS
    SELECT id, object_version_number
    FROM okl_fees_b
    WHERE parent_object_id = cp_quote_id
    AND parent_object_code = 'LEASEQUOTE'
    AND fee_purpose_code = 'SALESTAX';

    CURSOR l_fee_assets_details(cp_quote_id IN NUMBER) IS
    SELECT lre.id, lre.object_version_number, asset.asset_number,
           lre.source_line_id, lre.related_line_id
    FROM okl_line_relationships_b lre, okl_fees_b fee, okl_assets_b asset
    WHERE fee.parent_object_id = cp_quote_id
    AND fee.parent_object_code = 'LEASEQUOTE'
    AND fee.fee_purpose_code = 'SALESTAX'
    AND lre.related_line_id = fee.id
    AND lre.related_line_type = fee.fee_type
    AND lre.source_line_type = 'ASSET'
    AND lre.source_line_id = asset.id
    AND asset.parent_object_id = fee.parent_object_id
    AND asset.parent_object_code = fee.parent_object_code;

  BEGIN
    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_quote_id IS NULL THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_INVALID_SALES_QUOTE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Calculate Sales tax
    OKL_PROCESS_SALES_TAX_PVT.calculate_sales_tax(p_api_version     => p_api_version,
 						                          p_init_msg_list   => p_init_msg_list,
						                          x_return_status   => x_return_status,
						                          x_msg_count       => x_msg_count,
						                          x_msg_data        => x_msg_data,
						                          p_source_trx_id   => p_quote_id,
						                          p_source_trx_name => 'Sales Quote',
						                          p_source_table    => 'OKL_LEASE_QUOTES_B');
    IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF(x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Create the Upfront tax fee only if the tax amount returned is > 0
    -- based on the setup defined on Lease Quote/ Lease Application
    OPEN l_get_assets_tax_amount(p_quote_id);
    FETCH l_get_assets_tax_amount INTO l_assets_total_tax;
    CLOSE l_get_assets_tax_amount;

    IF (l_assets_total_tax > 0) THEN
      -- Get the Upfront tax treatment of Lease quote/ Lease Application
      OPEN l_get_tax_treatment(p_quote_id);
      FETCH l_get_tax_treatment INTO l_tax_treatment, l_tax_stream_type,
	  								 l_pricing_method, l_parent_object_code,
	  								 l_parent_object_id;
      CLOSE l_get_tax_treatment;

      IF (l_tax_treatment IN ('CAPITALIZE', 'FINANCE')) THEN
        -- Create the fee line

        OPEN l_check_tax_fee_exists(p_quote_id);
        FETCH l_check_tax_fee_exists INTO l_tax_fee_exists;
        CLOSE l_check_tax_fee_exists;

        IF (l_tax_fee_exists IS NULL) THEN -- Tax fee doesn't exist, so create it

          IF (l_tax_treatment = 'CAPITALIZE') THEN
            l_qte_fee_rec.fee_type := 'CAPITALIZED';
          ELSIF (l_tax_treatment = 'FINANCE') THEN
            l_qte_fee_rec.fee_type := 'FINANCED';
          END IF;

          l_qte_fee_rec.parent_object_id   := p_quote_id;
          l_qte_fee_rec.parent_object_code := 'LEASEQUOTE';
          l_qte_fee_rec.stream_type_id     := l_tax_stream_type;
          l_qte_fee_rec.fee_purpose_code   := 'SALESTAX';
          l_qte_fee_rec.fee_amount         := l_assets_total_tax;

          -- Build line relationships table to associate the fee with the assets
          IF (l_assets_total_tax > 0) THEN
            -- Associate the assets only if atleast one asset has tax amount > 0
            i := 1;
            FOR l_get_assets_rec IN l_get_assets(p_quote_id) LOOP

              OPEN l_get_asset_tax_amount(p_quote_id, l_get_assets_rec.asset_number);
              FETCH l_get_asset_tax_amount INTO l_asset_tax_amt;
              CLOSE l_get_asset_tax_amount;

              l_line_relation_tbl(i).source_line_type  := 'ASSET';
              l_line_relation_tbl(i).source_line_id    := l_get_assets_rec.id;
              l_line_relation_tbl(i).related_line_type := l_qte_fee_rec.fee_type;
              l_line_relation_tbl(i).amount            := l_asset_tax_amt;

              i := i+1;
            END LOOP;
          END IF;

          OKL_LEASE_QUOTE_FEE_PVT.create_fee ( p_api_version             => p_api_version
                                              ,p_init_msg_list           => p_init_msg_list
                                              ,p_transaction_control     => p_transaction_control
                                              ,p_fee_rec                 => l_qte_fee_rec
                                              ,p_assoc_asset_tbl         => l_line_relation_tbl
                                              ,p_payment_header_rec      => l_payment_header_rec
                                              ,p_payment_level_tbl       => l_payment_level_tbl
                                              ,p_expense_header_rec      => l_expense_header_rec
                                              ,p_expense_level_tbl       => l_expense_level_tbl
                                              ,x_fee_id                  => lx_fee_id
                                              ,x_return_status           => x_return_status
                                              ,x_msg_count               => x_msg_count
                                              ,x_msg_data                => x_msg_data );
          IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF(x_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        ELSE -- Tax fee exists .. update it

          OPEN l_fee_details(p_quote_id);
          FETCH l_fee_details INTO l_qte_fee_rec.id, l_qte_fee_rec.object_version_number;
          CLOSE l_fee_details;

          IF (l_tax_treatment = 'CAPITALIZE') THEN
            l_qte_fee_rec.fee_type := 'CAPITALIZED';
          ELSIF (l_tax_treatment = 'FINANCE') THEN
            l_qte_fee_rec.fee_type := 'FINANCED';
          END IF;

          l_qte_fee_rec.parent_object_id   := p_quote_id;
          l_qte_fee_rec.parent_object_code := 'LEASEQUOTE';
          l_qte_fee_rec.stream_type_id     := l_tax_stream_type;
          l_qte_fee_rec.fee_purpose_code   := 'SALESTAX';
          l_qte_fee_rec.fee_amount         := l_assets_total_tax;

          i := 1;
          FOR l_fee_assets_details_rec IN l_fee_assets_details(p_quote_id) LOOP

            OPEN l_get_asset_tax_amount(p_quote_id, l_fee_assets_details_rec.asset_number);
            FETCH l_get_asset_tax_amount INTO l_asset_tax_amt;
            CLOSE l_get_asset_tax_amount;

            l_line_relation_tbl(i).id                     := l_fee_assets_details_rec.id;
            l_line_relation_tbl(i).object_version_number  := l_fee_assets_details_rec.object_version_number;
            l_line_relation_tbl(i).source_line_type       := 'ASSET';
            l_line_relation_tbl(i).source_line_id         := l_fee_assets_details_rec.source_line_id;
            l_line_relation_tbl(i).related_line_id        := l_fee_assets_details_rec.related_line_id;
            l_line_relation_tbl(i).related_line_type      := l_qte_fee_rec.fee_type;
            l_line_relation_tbl(i).amount                 := l_asset_tax_amt;
            l_line_relation_tbl(i).record_mode            := 'UPDATE';

            i := i+1;
          END LOOP;

          IF (l_line_relation_tbl.COUNT = 0 AND l_assets_total_tax > 0) THEN
            -- Associate the assets only if atleast one asset has tax amount > 0
            i := 1;
            FOR l_get_assets_rec IN l_get_assets(p_quote_id) LOOP

              OPEN l_get_asset_tax_amount(p_quote_id, l_get_assets_rec.asset_number);
              FETCH l_get_asset_tax_amount INTO l_asset_tax_amt;
              CLOSE l_get_asset_tax_amount;

              l_line_relation_tbl(i).source_line_type  := 'ASSET';
              l_line_relation_tbl(i).source_line_id    := l_get_assets_rec.id;
              l_line_relation_tbl(i).related_line_type := l_tax_treatment;
              l_line_relation_tbl(i).amount            := l_asset_tax_amt;

              i := i+1;
            END LOOP;
          END IF;

          OKL_LEASE_QUOTE_FEE_PVT.update_fee ( p_api_version             => p_api_version
                                              ,p_init_msg_list           => p_init_msg_list
                                              ,p_transaction_control     => p_transaction_control
                                              ,p_fee_rec                 => l_qte_fee_rec
                                              ,p_assoc_asset_tbl         => l_line_relation_tbl
                                              ,p_payment_header_rec      => l_payment_header_rec
                                              ,p_payment_level_tbl       => l_payment_level_tbl
                                              ,p_expense_header_rec      => l_expense_header_rec
                                              ,p_expense_level_tbl       => l_expense_level_tbl
                                              ,x_return_status           => x_return_status
                                              ,x_msg_count               => x_msg_count
                                              ,x_msg_data                => x_msg_data );
          IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF(x_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;
      END IF;

      IF (l_tax_treatment IN ('CAPITALIZE', 'FINANCE')) THEN

        IF (l_assets_total_tax > 0) THEN

          -- Switch the quote status to 'INCOMPLETE'
          change_quote_status(p_quote_id         =>   p_quote_id,
                              p_qte_status       =>   'PR-INCOMPLETE',
                              x_return_status    =>   x_return_status);

          IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF(x_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        IF (l_parent_object_code = 'LEASEAPP') THEN
          okl_lease_app_pvt.set_lease_app_status(p_api_version        => p_api_version,
            									 p_init_msg_list      => p_init_msg_list,
            									 p_lap_id             => l_parent_object_id,
            									 p_lap_status         => 'INCOMPLETE',
												 x_return_status      => x_return_status,
            									 x_msg_count          => x_msg_count,
            									 x_msg_data           => x_msg_data);
          IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF(x_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

      END IF;

    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END calculate_sales_tax;


END OKL_LEASE_QUOTE_PVT;

/
