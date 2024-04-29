--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_CASHFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_CASHFLOW_PVT" AS
/* $Header: OKLRQUCB.pls 120.30.12010000.7 2009/11/05 20:02:15 sechawla ship $ */

  -------------------------------
  -- PROCEDURE populate_level_ids
  -------------------------------
  PROCEDURE populate_level_ids (
      p_cf_header_id       IN NUMBER
     ,x_cf_levels_tbl      IN OUT NOCOPY cashflow_level_tbl_type
     ,x_return_status      OUT NOCOPY VARCHAR2
     ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'populate_level_ids';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    CURSOR c_levels IS
      SELECT id
      FROM   okl_cash_flow_levels
      WHERE  caf_id = p_cf_header_id
      ORDER BY start_date;

    i                      BINARY_INTEGER;
    l_count                BINARY_INTEGER;

  BEGIN

    i       := x_cf_levels_tbl.FIRST;
    l_count := 0;

    FOR l_level IN c_levels LOOP

      l_count                              := l_count + 1;
      x_cf_levels_tbl(i).cashflow_level_id := l_level.id;
      i                                    := x_cf_levels_tbl.NEXT(i);

    END LOOP;

    IF l_count <> x_cf_levels_tbl.COUNT THEN

      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_INVALID_VALUE2'
       ,p_token1       => 'API_NAME'
       ,p_token1_value => UPPER(l_api_name)
       ,p_token2       => 'NAME'
       ,p_token2_value => 'levels_table_count'
       ,p_token3       => 'VALUE'
       ,p_token3_value => x_cf_levels_tbl.COUNT
       );
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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END populate_level_ids;


  -----------------------------
  -- PROCEDURE get_source_table
  -----------------------------
  PROCEDURE get_source_table (
    p_source_object_code IN VARCHAR2
   ,x_source_table       OUT NOCOPY VARCHAR2
   ,x_return_status      OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_source_table';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN
    --Bug # 5142940 ssdeshpa start
    IF (p_source_object_code IN ('QUOTED_ASSET','QUOTED_ASSET_DOWN_PAYMENT','QUOTED_ASSET_PROPERTY_TAX')) THEN
      x_source_table := 'OKL_ASSETS_B';
    --Bug # 5142940 ssdeshpa end
    ELSIF (p_source_object_code = 'QUOTED_FEE') THEN
      x_source_table := 'OKL_FEES_B';
    ELSIF (p_source_object_code = 'QUOTED_SERVICE') THEN
      x_source_table := 'OKL_SERVICES_B';
    ELSIF (p_source_object_code = 'QUOTED_INSURANCE') THEN
      x_source_table := 'OKL_INSURANCE_ESTIMATES_B';
    ELSIF (p_source_object_code = 'LEASE_QUOTE') THEN
      x_source_table := 'OKL_LEASE_QUOTES_B';
    ELSIF (p_source_object_code = 'QUICK_QUOTE') THEN
      x_source_table := 'OKL_QUICK_QUOTES_B';
    ELSIF (p_source_object_code = 'QUICK_QUOTE_ASSET') THEN
      x_source_table := 'OKL_QUICK_QUOTE_LINES_B';
    ELSIF (p_source_object_code = 'QUICK_QUOTE_SERVICE') THEN
      x_source_table := 'OKL_QUICK_QUOTE_LINES_B';
    ELSIF (p_source_object_code = 'QUICK_QUOTE_FEE') THEN
      x_source_table := 'OKL_QUICK_QUOTE_LINES_B';
    ELSIF (p_source_object_code = 'QUICK_QUOTE_TAX') THEN
      x_source_table := 'OKL_QUICK_QUOTE_LINES_B';
    ELSIF (p_source_object_code = 'QUICK_QUOTE_INSURANCE') THEN
      x_source_table := 'OKL_QUICK_QUOTE_LINES_B';
    ELSIF (p_source_object_code = 'LEASE_QUOTE_CONSOLIDATED') THEN
      x_source_table := 'OKL_LEASE_QUOTES_B';
    ELSE
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_INVALID_VALUE2'
       ,p_token1       => 'API_NAME'
       ,p_token1_value => UPPER(l_api_name)
       ,p_token2       => 'NAME'
       ,p_token2_value => 'source_object_code'
       ,p_token3       => 'VALUE'
       ,p_token3_value => p_source_object_code
       );
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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_source_table;

  -------------------------------
  -- PROCEDURE set_level_end_date
  -------------------------------
  PROCEDURE set_level_end_date (
    p_contract_start_date IN DATE
   ,p_contract_term       IN NUMBER
   ,p_cashflow_header_rec IN cashflow_header_rec_type
   ,p_cashflow_level_tbl  IN OUT NOCOPY cashflow_level_tbl_type
   ,x_return_status          OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'set_level_end_date';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_mpp                  PLS_INTEGER;

    l_contract_end_date    DATE;
    l_next_start_date      DATE;
    l_end_date             DATE;

    l_module       CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.set_level_end_date';
    l_debug_enabled    VARCHAR2(10);
    is_debug_procedure_on  BOOLEAN;
    is_debug_statement_on  BOOLEAN;

  BEGIN

    l_debug_enabled := NVL(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQUCB.pls procedure set_level_end_date');
    END IF;
    -- check for logging at STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    IF p_cashflow_header_rec.frequency_code = 'A' THEN
      l_mpp := 12;
    ELSIF p_cashflow_header_rec.frequency_code = 'S' THEN
      l_mpp := 6;
    ELSIF p_cashflow_header_rec.frequency_code = 'Q' THEN
      l_mpp := 3;
    ELSIF p_cashflow_header_rec.frequency_code = 'M' THEN
      l_mpp := 1;
    END IF;

    l_next_start_date := p_contract_start_date;

    FOR i IN p_cashflow_level_tbl.FIRST .. p_cashflow_level_tbl.LAST LOOP
      IF p_cashflow_level_tbl.EXISTS(i) THEN

        IF p_cashflow_level_tbl(i).stub_days IS NOT NULL THEN
          l_end_date := l_next_start_date + p_cashflow_level_tbl(i).stub_days - 1;
        ELSE
          l_end_date := ADD_MONTHS(l_next_start_date, l_mpp*p_cashflow_level_tbl(i).periods) - 1;
        END IF;

        p_cashflow_level_tbl(i).start_date := l_next_start_date;
        l_next_start_date                  := l_end_date + 1;

      END IF;
      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,' l_next_start_date = '  || l_next_start_date ||
                                  ' l_end_date = '         || l_end_date
                                 );
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
    END LOOP;

    l_contract_end_date := ADD_MONTHS(p_contract_start_date, p_contract_term) - 1;

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,' p_contract_start_date = '       || p_contract_start_date       ||
                                ' l_contract_end_date = '         || l_contract_end_date         ||
                                ' p_contract_term = '             || p_contract_term             ||
                                ' l_end_date = '                  || l_end_date                  ||
                                ' l_next_start_date = '           || l_next_start_date           ||
                                ' l_mpp = '                       || l_mpp                       ||
                                ' p_cashflow_level_tbl_count = '  || p_cashflow_level_tbl.COUNT
                               );
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF l_end_date > l_contract_end_date THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_EXTENDS_K_END');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQUCB.pls procedure set_level_end_date');
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
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END set_level_end_date;


  -----------------------------
  -- PROCEDURE set_level_amount
  -----------------------------
  PROCEDURE set_level_amount (
    p_contract_currency   IN VARCHAR2
   ,p_cashflow_level_tbl  IN OUT NOCOPY cashflow_level_tbl_type
   ,x_return_status          OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'set_level_amount';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    FOR i IN p_cashflow_level_tbl.FIRST .. p_cashflow_level_tbl.LAST LOOP
      IF p_cashflow_level_tbl.EXISTS(i) THEN
        IF p_cashflow_level_tbl(i).stub_amount IS NOT NULL THEN
          p_cashflow_level_tbl(i).stub_amount :=
            okl_accounting_util.round_amount( p_amount        => p_cashflow_level_tbl(i).stub_amount
                                             ,p_currency_code => p_contract_currency
                                             );
        ELSIF p_cashflow_level_tbl(i).periodic_amount IS NOT NULL THEN
          p_cashflow_level_tbl(i).periodic_amount :=
            okl_accounting_util.round_amount( p_amount        => p_cashflow_level_tbl(i).periodic_amount
                                             ,p_currency_code => p_contract_currency
                                             );
        END IF;
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

  END set_level_amount;


  -------------------------
  -- PROCEDURE sanity_check
  -------------------------
  PROCEDURE sanity_check (
    p_cashflow_header_rec IN  cashflow_header_rec_type
   ,p_cashflow_level_tbl  IN  cashflow_level_tbl_type
   ,x_return_status       OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'sanity_check';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    IF p_cashflow_header_rec.frequency_code NOT IN ('M','Q','S','A') THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_INVALID_VALUE2'
       ,p_token1       => 'API_NAME'
       ,p_token1_value => UPPER(l_api_name)
       ,p_token2       => 'NAME'
       ,p_token2_value => 'frequency_code'
       ,p_token3       => 'VALUE'
       ,p_token3_value => p_cashflow_header_rec.frequency_code
       );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_cashflow_header_rec.arrears_flag NOT IN ('Y' , 'N') THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_INVALID_VALUE2'
       ,p_token1       => 'API_NAME'
       ,p_token1_value => UPPER(l_api_name)
       ,p_token2       => 'NAME'
       ,p_token2_value => 'arrears_flag'
       ,p_token3       => 'VALUE'
       ,p_token3_value => p_cashflow_header_rec.arrears_flag
       );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_cashflow_header_rec.type_code NOT IN ('INFLOW' , 'OUTFLOW') THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_INVALID_VALUE2'
       ,p_token1       => 'API_NAME'
       ,p_token1_value => UPPER(l_api_name)
       ,p_token2       => 'NAME'
       ,p_token2_value => 'type_code'
       ,p_token3       => 'VALUE'
       ,p_token3_value => p_cashflow_header_rec.type_code
       );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_cashflow_header_rec.quote_type_code NOT IN ('LQ', 'QQ', 'LA') THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_INVALID_VALUE2'
       ,p_token1       => 'API_NAME'
       ,p_token1_value => UPPER(l_api_name)
       ,p_token2       => 'NAME'
       ,p_token2_value => 'quote_type_code'
       ,p_token3       => 'VALUE'
       ,p_token3_value => p_cashflow_header_rec.quote_type_code
       );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_cashflow_header_rec.quote_id IS NULL THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_INVALID_VALUE2'
       ,p_token1       => 'API_NAME'
       ,p_token1_value => UPPER(l_api_name)
       ,p_token2       => 'NAME'
       ,p_token2_value => 'quote_id'
       ,p_token3       => 'VALUE'
       ,p_token3_value => p_cashflow_header_rec.quote_id
       );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR i IN p_cashflow_level_tbl.FIRST .. p_cashflow_level_tbl.LAST LOOP
      IF p_cashflow_level_tbl.EXISTS(i) THEN
        IF UPPER(p_cashflow_level_tbl(i).record_mode) NOT IN ('CREATE', 'UPDATE') OR p_cashflow_level_tbl(i).record_mode IS NULL THEN
          OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME
           ,p_msg_name     => 'OKL_INVALID_VALUE2'
           ,p_token1       => 'API_NAME'
           ,p_token1_value => UPPER(l_api_name)
           ,p_token2       => 'NAME'
           ,p_token2_value => '('||i||') record_mode'
           ,p_token3       => 'VALUE'
           ,p_token3_value => UPPER(p_cashflow_level_tbl(i).record_mode)
           );
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
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

  END sanity_check;


  --------------------------------------
  -- PROCEDURE validate_level_attributes
  --------------------------------------
  PROCEDURE validate_level_attributes (
    p_cashflow_level_tbl  IN  cashflow_level_tbl_type
   ,p_caf_status          IN  VARCHAR2
   ,p_pricing_method      IN  VARCHAR2
   ,x_return_status       OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'validate_level_attributes';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    l_periods_exists       VARCHAR2(3) := 'N';

  BEGIN

    FOR i IN p_cashflow_level_tbl.FIRST .. p_cashflow_level_tbl.LAST LOOP

      IF p_cashflow_level_tbl.EXISTS(i) THEN

        IF p_cashflow_level_tbl(i).periods IS NOT NULL THEN
          l_periods_exists := 'Y';
        END IF;

        IF p_cashflow_level_tbl(i).periods <= 0 THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_PERIOD_ZERO');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF TRUNC(p_cashflow_level_tbl(i).periods) <> p_cashflow_level_tbl(i).periods THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_PERIOD_FRACTION');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF p_cashflow_level_tbl(i).stub_days <= 0 THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_STUBDAYS_ZERO');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF TRUNC(p_cashflow_level_tbl(i).stub_days) <> p_cashflow_level_tbl(i).stub_days THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_STUBDAYS_FRACTION');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF p_pricing_method <> 'SP' AND p_pricing_method <> 'SM' THEN
          IF p_cashflow_level_tbl(i).periodic_amount < 0 THEN
            OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_AMOUNT_ZERO');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        IF p_pricing_method <> 'SP' AND p_pricing_method <> 'SM' THEN
          IF p_cashflow_level_tbl(i).stub_amount < 0 THEN
            OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_STUBAMT_ZERO');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

--04-Nov-2009 sechawla 9001225 : removed the validation
/*
        IF p_caf_status <> 'WORK' AND p_cashflow_level_tbl(i).rate <= 0 THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_RATE_ZERO');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
*/
        IF (p_cashflow_level_tbl(i).stub_days IS NULL) AND (p_cashflow_level_tbl(i).periods IS NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_NO_STUB_AND_PER');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (p_cashflow_level_tbl(i).stub_days IS NOT NULL) AND (p_cashflow_level_tbl(i).periods IS NOT NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_BOTH_STUB_AND_PER');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (p_cashflow_level_tbl(i).stub_amount IS NOT NULL) AND (p_cashflow_level_tbl(i).stub_days IS NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_STUBAMT_WO_DAYS');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF p_pricing_method <> 'SP' AND p_pricing_method <> 'SM' THEN
          IF (p_cashflow_level_tbl(i).stub_amount IS  NULL) AND (p_cashflow_level_tbl(i).stub_days IS NOT NULL) THEN
            OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_STUBDAYS_WO_AMT');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        IF (p_cashflow_level_tbl(i).periodic_amount IS NOT NULL) AND (p_cashflow_level_tbl(i).periods IS NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_AMOUNT_WO_PERIODS');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF p_pricing_method <> 'SP' AND p_pricing_method <> 'SM' THEN
          IF (p_cashflow_level_tbl(i).periodic_amount IS  NULL) AND (p_cashflow_level_tbl(i).periods IS NOT NULL) THEN
            OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_PERIODS_WO_AMOUNT');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;

    END LOOP;
    IF l_periods_exists = 'N' THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_PERIODS_NOT_PRESENT');
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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_level_attributes;


  ---------------------------------
  -- PROCEDURE get_contract_details
  ---------------------------------
  PROCEDURE get_contract_details (
    p_quote_type       IN  VARCHAR2
   ,p_quote_id         IN  NUMBER
   ,x_contract_details OUT NOCOPY contract_details_rec_type
   ,x_return_status    OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_contract_details';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    CURSOR c_lq_hdr IS
      SELECT
        lop.currency_code
       ,lsq.expected_start_date
       ,lsq.term
       ,lsq.pricing_method
      FROM
        okl_lease_quotes_b lsq
       ,okl_lease_opportunities_b lop
      WHERE lsq.id = p_quote_id
        AND lsq.parent_object_code = 'LEASEOPP'
        AND lsq.parent_object_id = lop.id;

    CURSOR c_la_hdr IS
      SELECT
        lap.currency_code
       ,lsq.expected_start_date
       ,lsq.term
       ,lsq.pricing_method
      FROM
        okl_lease_quotes_b lsq
       ,okl_lease_applications_b lap
      WHERE lsq.id = p_quote_id
        AND lsq.parent_object_code = 'LEASEAPP'
        AND lsq.parent_object_id = lap.id;

    CURSOR c_qq_hdr IS
      SELECT
        currency_code
       ,expected_start_date
       ,term
       ,pricing_method
      FROM
        okl_quick_quotes_b
      WHERE id = p_quote_id;

  BEGIN

    IF p_quote_type = 'LQ' THEN
      OPEN c_lq_hdr;
      FETCH c_lq_hdr INTO x_contract_details;
      CLOSE c_lq_hdr;
    ELSIF p_quote_type = 'LA' THEN
      OPEN c_la_hdr;
      FETCH c_la_hdr INTO x_contract_details;
      CLOSE c_la_hdr;
    ELSIF p_quote_type = 'QQ' THEN
      OPEN c_qq_hdr;
      FETCH c_qq_hdr INTO x_contract_details;
      CLOSE c_qq_hdr;
    END IF;

    IF (x_contract_details.currency_code IS NULL) OR (x_contract_details.start_date IS NULL) OR
       (x_contract_details.term IS NULL) OR (x_contract_details.pricing_method_code IS NULL) THEN

      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME
       ,p_msg_name     => 'OKL_INVALID_VALUE2'
       ,p_token1       => 'API_NAME'
       ,p_token1_value => UPPER(l_api_name)
       ,p_token2       => 'NAME'
       ,p_token2_value => 'x_contract_details'
       ,p_token3       => 'VALUE'
       ,p_token3_value => 'null'
       );
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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_contract_details;


  ------------------------------
  -- PROCEDURE process_cashflow
  ------------------------------
  PROCEDURE process_cashflow (
    p_cashflow_header_rec IN OUT NOCOPY cashflow_header_rec_type
   ,p_cashflow_level_tbl  IN OUT NOCOPY cashflow_level_tbl_type
   ,x_return_status       OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'process_cashflow';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_contract_details     contract_details_rec_type;

  BEGIN

    sanity_check (
      p_cashflow_header_rec => p_cashflow_header_rec
     ,p_cashflow_level_tbl => p_cashflow_level_tbl
     ,x_return_status       => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    get_contract_details (
      p_quote_type        => p_cashflow_header_rec.quote_type_code
     ,p_quote_id          => p_cashflow_header_rec.quote_id
     ,x_contract_details  => l_contract_details
     ,x_return_status     => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    validate_level_attributes (
      p_cashflow_level_tbl => p_cashflow_level_tbl
     ,p_caf_status         => p_cashflow_header_rec.status_code
     ,p_pricing_method     => l_contract_details.pricing_method_code
     ,x_return_status      => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    set_level_end_date (
      p_contract_start_date => l_contract_details.start_date
     ,p_contract_term       => l_contract_details.term
     ,p_cashflow_header_rec => p_cashflow_header_rec
     ,p_cashflow_level_tbl  => p_cashflow_level_tbl
     ,x_return_status       => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    set_level_amount (
      p_contract_currency   => l_contract_details.currency_code
     ,p_cashflow_level_tbl  => p_cashflow_level_tbl
     ,x_return_status       => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status    := G_RET_STS_SUCCESS;

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

  END process_cashflow;


  ------------------------
  -- PROCEDURE insert_rows
  ------------------------
  PROCEDURE insert_rows (
    p_cashflow_header_rec IN  OUT NOCOPY cashflow_header_rec_type
   ,p_cashflow_level_tbl  IN  OUT NOCOPY cashflow_level_tbl_type
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_count           OUT NOCOPY NUMBER
   ,x_msg_data            OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'insert_rows';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_cafv_rec             cafv_rec_type;
    lx_cafv_rec            cafv_rec_type;

    l_cfov_rec             cfov_rec_type;
    lx_cfov_rec            cfov_rec_type;

    l_cflv_tbl             cflv_tbl_type;
    lx_cflv_tbl            cflv_tbl_type;

  BEGIN

    l_cfov_rec.object_version_number  := 1;
    l_cfov_rec.oty_code               := p_cashflow_header_rec.parent_object_code;
    l_cfov_rec.source_id              := p_cashflow_header_rec.parent_object_id;

    --Bug # 5142940 ssdeshpa start
    IF (p_cashflow_header_rec.parent_object_code IN ('QUOTED_ASSET','QUOTED_ASSET_DOWN_PAYMENT','QUOTED_ASSET_PROPERTY_TAX')) THEN
      l_cfov_rec.source_table := 'OKL_ASSETS_B';
     --Bug # 5142940 ssdeshpa end
    ELSIF (p_cashflow_header_rec.parent_object_code = 'QUOTED_FEE') THEN
      l_cfov_rec.source_table := 'OKL_FEES_B';
    ELSIF (p_cashflow_header_rec.parent_object_code = 'QUOTED_SERVICE') THEN
      l_cfov_rec.source_table := 'OKL_SERVICES_B';
    ELSIF (p_cashflow_header_rec.parent_object_code = 'QUOTED_INSURANCE') THEN
      l_cfov_rec.source_table := 'OKL_INSURANCE_ESTIMATES_B';
    ELSIF (p_cashflow_header_rec.parent_object_code = 'LEASE_QUOTE') THEN
      l_cfov_rec.source_table := 'OKL_LEASE_QUOTES_B';
    ELSIF (p_cashflow_header_rec.parent_object_code = 'QUICK_QUOTE') THEN
      l_cfov_rec.source_table := 'OKL_QUICK_QUOTES_B';
    ELSIF (p_cashflow_header_rec.parent_object_code = 'QUICK_QUOTE_ASSET') THEN
      l_cfov_rec.source_table := 'OKL_QUICK_QUOTE_LINES_B';
    ELSIF (p_cashflow_header_rec.parent_object_code = 'QUICK_QUOTE_SERVICE') THEN
      l_cfov_rec.source_table := 'OKL_QUICK_QUOTE_LINES_B';
    ELSIF (p_cashflow_header_rec.parent_object_code = 'QUICK_QUOTE_FEE') THEN
      l_cfov_rec.source_table := 'OKL_QUICK_QUOTE_LINES_B';
    ELSIF (p_cashflow_header_rec.parent_object_code = 'QUICK_QUOTE_TAX') THEN
      l_cfov_rec.source_table := 'OKL_QUICK_QUOTE_LINES_B';
    ELSIF (p_cashflow_header_rec.parent_object_code = 'QUICK_QUOTE_INSURANCE') THEN
      l_cfov_rec.source_table := 'OKL_QUICK_QUOTE_LINES_B';
    ELSIF (p_cashflow_header_rec.parent_object_code = 'LEASE_QUOTE_CONSOLIDATED') THEN
      l_cfov_rec.source_table := 'OKL_LEASE_QUOTES_B';
    END IF;

    okl_cfo_pvt.insert_row (
      p_api_version   => G_API_VERSION
     ,p_init_msg_list => G_FALSE
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_cfov_rec      => l_cfov_rec
     ,x_cfov_rec      => lx_cfov_rec
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_cafv_rec.cfo_id                 := lx_cfov_rec.id;
    l_cafv_rec.object_version_number  := 1;
    --bug 4898499
    IF p_cashflow_header_rec.status_code = 'WORK' THEN
      l_cafv_rec.sts_code  := 'WORK';
    ELSE
      l_cafv_rec.sts_code  := 'CURRENT';
    END IF;
    l_cafv_rec.sty_id         := p_cashflow_header_rec.stream_type_id;
    l_cafv_rec.due_arrears_yn := p_cashflow_header_rec.arrears_flag;
    l_cafv_rec.dnz_qte_id     := p_cashflow_header_rec.quote_id;
    l_cafv_rec.start_date     := p_cashflow_level_tbl(p_cashflow_level_tbl.FIRST).start_date;

    IF p_cashflow_header_rec.type_code = 'INFLOW' THEN
      l_cafv_rec.cft_code := 'PAYMENT_SCHEDULE';
    ELSIF p_cashflow_header_rec.type_code = 'OUTFLOW' THEN
      l_cafv_rec.cft_code := 'OUTFLOW_SCHEDULE';
    END IF;

    okl_caf_pvt.insert_row (
      p_api_version   => G_API_VERSION
     ,p_init_msg_list => G_FALSE
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_cafv_rec      => l_cafv_rec
     ,x_cafv_rec      => lx_cafv_rec
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR i IN p_cashflow_level_tbl.FIRST .. p_cashflow_level_tbl.LAST LOOP
      IF p_cashflow_level_tbl.EXISTS(i) THEN
        l_cflv_tbl(i).caf_id            := lx_cafv_rec.id;
        l_cflv_tbl(i).object_version_number := 1;
        l_cflv_tbl(i).number_of_periods := p_cashflow_level_tbl(i).periods;
        l_cflv_tbl(i).amount            := p_cashflow_level_tbl(i).periodic_amount;
        l_cflv_tbl(i).stub_days         := p_cashflow_level_tbl(i).stub_days;
        l_cflv_tbl(i).stub_amount       := p_cashflow_level_tbl(i).stub_amount;
        l_cflv_tbl(i).start_date        := p_cashflow_level_tbl(i).start_date;
        l_cflv_tbl(i).fqy_code          := p_cashflow_header_rec.frequency_code;
        l_cflv_tbl(i).rate              := p_cashflow_level_tbl(i).rate;
        l_cflv_tbl(i).missing_pmt_flag  := p_cashflow_level_tbl(i).missing_pmt_flag;
      END IF;
    END LOOP;

    okl_cfl_pvt.insert_row (
      p_api_version   => G_API_VERSION
     ,p_init_msg_list => G_FALSE
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_cflv_tbl      => l_cflv_tbl
     ,x_cflv_tbl      => lx_cflv_tbl
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    p_cashflow_header_rec.cashflow_object_id := lx_cfov_rec.id;
    p_cashflow_header_rec.cashflow_header_id := lx_cafv_rec.id;

    populate_level_ids (
      p_cf_header_id       => p_cashflow_header_rec.cashflow_header_id
     ,x_cf_levels_tbl      => p_cashflow_level_tbl
     ,x_return_status      => x_return_status
     );

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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_rows;


  -------------------------------
  -- PROCEDURE insert_update_rows
  -------------------------------
  PROCEDURE insert_update_rows (
    p_cashflow_header_rec IN OUT NOCOPY cashflow_header_rec_type
   ,p_cashflow_level_tbl  IN OUT NOCOPY cashflow_level_tbl_type
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_count           OUT NOCOPY NUMBER
   ,x_msg_data            OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'insert_update_rows';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_cafv_rec             cafv_rec_type;
    lx_cafv_rec            cafv_rec_type;

    l_cflv_ins_tbl         cflv_tbl_type;
    l_cflv_upd_tbl         cflv_tbl_type;
    lx_cflv_tbl            cflv_tbl_type;

  BEGIN

    l_cafv_rec.id                     := p_cashflow_header_rec.cashflow_header_id;
    l_cafv_rec.object_version_number  := p_cashflow_header_rec.cashflow_header_ovn;
    l_cafv_rec.cfo_id                 := p_cashflow_header_rec.cashflow_object_id;
    l_cafv_rec.sty_id                 := p_cashflow_header_rec.stream_type_id;
    l_cafv_rec.due_arrears_yn         := p_cashflow_header_rec.arrears_flag;
    l_cafv_rec.start_date             := p_cashflow_level_tbl(p_cashflow_level_tbl.FIRST).start_date;

    okl_caf_pvt.update_row (
      p_api_version   => G_API_VERSION
     ,p_init_msg_list => G_FALSE
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_cafv_rec      => l_cafv_rec
     ,x_cafv_rec      => lx_cafv_rec
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR i IN p_cashflow_level_tbl.FIRST .. p_cashflow_level_tbl.LAST LOOP
      IF p_cashflow_level_tbl.EXISTS(i) THEN
        IF UPPER(p_cashflow_level_tbl(i).record_mode) = 'CREATE' THEN
          l_cflv_ins_tbl(i).caf_id            := lx_cafv_rec.id;
          l_cflv_ins_tbl(i).object_version_number := 1;
          l_cflv_ins_tbl(i).number_of_periods := p_cashflow_level_tbl(i).periods;
          l_cflv_ins_tbl(i).amount            := p_cashflow_level_tbl(i).periodic_amount;
          l_cflv_ins_tbl(i).stub_days         := p_cashflow_level_tbl(i).stub_days;
          l_cflv_ins_tbl(i).stub_amount       := p_cashflow_level_tbl(i).stub_amount;
          l_cflv_ins_tbl(i).start_date        := p_cashflow_level_tbl(i).start_date;
          l_cflv_ins_tbl(i).fqy_code          := p_cashflow_header_rec.frequency_code;
          l_cflv_ins_tbl(i).rate              := p_cashflow_level_tbl(i).rate;
          l_cflv_ins_tbl(i).missing_pmt_flag  := p_cashflow_level_tbl(i).missing_pmt_flag;
        ELSIF UPPER(p_cashflow_level_tbl(i).record_mode) = 'UPDATE' THEN
          l_cflv_upd_tbl(i).id                    := p_cashflow_level_tbl(i).cashflow_level_id;
          l_cflv_upd_tbl(i).caf_id                := lx_cafv_rec.id;
          l_cflv_upd_tbl(i).object_version_number := p_cashflow_level_tbl(i).cashflow_level_ovn;
          l_cflv_upd_tbl(i).number_of_periods     := p_cashflow_level_tbl(i).periods;
          l_cflv_upd_tbl(i).amount                := p_cashflow_level_tbl(i).periodic_amount;
          l_cflv_upd_tbl(i).stub_days             := p_cashflow_level_tbl(i).stub_days;
          l_cflv_upd_tbl(i).stub_amount           := p_cashflow_level_tbl(i).stub_amount;
          l_cflv_upd_tbl(i).start_date            := p_cashflow_level_tbl(i).start_date;
          l_cflv_upd_tbl(i).fqy_code              := p_cashflow_header_rec.frequency_code;
          l_cflv_upd_tbl(i).rate                  := p_cashflow_level_tbl(i).rate;
          l_cflv_upd_tbl(i).missing_pmt_flag      := p_cashflow_level_tbl(i).missing_pmt_flag;
        END IF;
      END IF;
    END LOOP;

    IF l_cflv_ins_tbl.COUNT > 0 THEN

      okl_cfl_pvt.insert_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_cflv_tbl      => l_cflv_ins_tbl
       ,x_cflv_tbl      => lx_cflv_tbl
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    IF l_cflv_upd_tbl.COUNT > 0 THEN

      okl_cfl_pvt.update_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_cflv_tbl      => l_cflv_upd_tbl
       ,x_cflv_tbl      => lx_cflv_tbl
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    populate_level_ids (
      p_cf_header_id       => p_cashflow_header_rec.cashflow_header_id
     ,x_cf_levels_tbl      => p_cashflow_level_tbl
     ,x_return_status      => x_return_status
     );

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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_update_rows;


  ----------------------------------------
  -- PROCEDURE get_deleted_cashflow_levels
  ----------------------------------------
  PROCEDURE get_deleted_cashflow_levels (p_cashflow_header_id            IN  NUMBER,
                                p_cashflow_level_tbl       IN  cashflow_level_tbl_type,
                                x_deleted_cashflow_level_tbl   OUT NOCOPY cflv_tbl_type,
                                x_return_status       OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_deleted_cashflow_levels';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    CURSOR c_db_cashflow_levels IS
      SELECT id
      FROM   okl_cash_flow_levels
      WHERE  caf_id = p_cashflow_header_id;

    l_cashflow_level_tbl   cflv_tbl_type;
    l_delete_flag          VARCHAR2(1);
    i                      BINARY_INTEGER := 0;

  BEGIN

    IF (p_cashflow_level_tbl.COUNT > 0) THEN
      FOR l_db_cashflow_levels IN c_db_cashflow_levels LOOP
        l_delete_flag := 'Y';
        FOR j IN p_cashflow_level_tbl.FIRST .. p_cashflow_level_tbl.LAST LOOP
          IF p_cashflow_level_tbl.EXISTS(j) THEN
            IF l_db_cashflow_levels.id = p_cashflow_level_tbl(j).cashflow_level_id THEN
              l_delete_flag := 'N';
            END IF;
          END IF;
        END LOOP;

        IF l_delete_flag = 'Y' THEN
          l_cashflow_level_tbl(i).id := l_db_cashflow_levels.id;
          i := i + 1;
        END IF;
      END LOOP;
    ELSE
      FOR l_db_cashflow_levels IN c_db_cashflow_levels LOOP
        l_cashflow_level_tbl(i).id := l_db_cashflow_levels.id;
        i := i + 1;
      END LOOP;
    END IF;

    x_deleted_cashflow_level_tbl := l_cashflow_level_tbl;
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

  END get_deleted_cashflow_levels;


  --------------------------------------
  -- PROCEDURE process_cashflow_deletion
  --------------------------------------
  PROCEDURE process_cashflow_deletion (
    p_cashflow_header_rec IN  cashflow_header_rec_type
   ,p_cashflow_level_tbl  IN  cashflow_level_tbl_type
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_count           OUT NOCOPY NUMBER
   ,x_msg_data            OUT NOCOPY VARCHAR2
   ) IS

    l_program_name           CONSTANT VARCHAR2(30) := 'process_cashflow_deletion';
    l_api_name               CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_deleted_cf_level_tbl   cflv_tbl_type;

    l_cafv_rec               cafv_rec_type;
    l_cfov_rec               cfov_rec_type;

  BEGIN

    get_deleted_cashflow_levels (
      p_cashflow_header_id         => p_cashflow_header_rec.cashflow_header_id
     ,p_cashflow_level_tbl         => p_cashflow_level_tbl
     ,x_deleted_cashflow_level_tbl => l_deleted_cf_level_tbl
     ,x_return_status              => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_deleted_cf_level_tbl.COUNT > 0 THEN

      okl_cfl_pvt.delete_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_cflv_tbl      => l_deleted_cf_level_tbl
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    IF p_cashflow_level_tbl.COUNT = 0 THEN

      l_cafv_rec.id := p_cashflow_header_rec.cashflow_header_id;

      okl_caf_pvt.delete_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_cafv_rec      => l_cafv_rec
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_cfov_rec.id := p_cashflow_header_rec.cashflow_object_id;

      okl_cfo_pvt.delete_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_cfov_rec      => l_cfov_rec
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

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
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END process_cashflow_deletion;

----------------------------
  -- PROCEDURE create_cashflow
  ----------------------------
  PROCEDURE create_cashflow (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_cashflow_header_rec     IN  OUT NOCOPY cashflow_header_rec_type
    ,p_cashflow_level_tbl      IN  OUT NOCOPY cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name          CONSTANT VARCHAR2(30) := 'create_cashflow';
    l_api_name              CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_cashflow_level_tbl.COUNT = 0 THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_REQD_LEVELS');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    process_cashflow (
      p_cashflow_header_rec => p_cashflow_header_rec
     ,p_cashflow_level_tbl  => p_cashflow_level_tbl
     ,x_return_status       => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_rows (
      p_cashflow_header_rec => p_cashflow_header_rec
     ,p_cashflow_level_tbl  => p_cashflow_level_tbl
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
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

  END create_cashflow;


  ----------------------------
  -- PROCEDURE update_cashflow
  ----------------------------
  PROCEDURE update_cashflow (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_cashflow_header_rec     IN  OUT NOCOPY cashflow_header_rec_type
    ,p_cashflow_level_tbl      IN  OUT NOCOPY cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_cashflow';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_cashflow_level_tbl.COUNT = 0 AND p_cashflow_header_rec.stream_type_id IS NOT NULL THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_REQD_LEVELS');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    process_cashflow_deletion (
      p_cashflow_header_rec => p_cashflow_header_rec
     ,p_cashflow_level_tbl  => p_cashflow_level_tbl
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    process_cashflow (
      p_cashflow_header_rec => p_cashflow_header_rec
     ,p_cashflow_level_tbl  => p_cashflow_level_tbl
     ,x_return_status       => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_update_rows (
      p_cashflow_header_rec => p_cashflow_header_rec
     ,p_cashflow_level_tbl  => p_cashflow_level_tbl
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
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

  END update_cashflow;


  --------------------------------
  -- PROCEDURE duplicate_cashflows
  --------------------------------
  PROCEDURE duplicate_cashflows (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_source_object_code      IN  VARCHAR2
    ,p_source_object_id        IN  NUMBER
    ,p_target_object_id        IN  NUMBER
    ,p_quote_id          IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_target_object_code      IN  VARCHAR2 DEFAULT NULL
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'duplicate_cashflows';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_cashflow_header_rec  cashflow_header_rec_type;
    l_cashflow_level_tbl   cashflow_level_tbl_type;

    l_return_status        VARCHAR2(1);
    l_source_table         VARCHAR2(30);
    l_cashflow_object_id   NUMBER;
    l_cft_code             VARCHAR2(30);
    lv_frq_code            VARCHAR2(30);
    lv_parent_object_code  VARCHAR2(30);
    i                      BINARY_INTEGER := 0;
    j                      BINARY_INTEGER := 0;
    --Bug # 5021937 ssdeshpa start
    l_qte_price_method       VARCHAR2(30);
    l_qte_status             VARCHAR2(30);
    l_caf_status             VARCHAR2(30);

    CURSOR c_lq_hdr_rec_cur(p_lease_quote_id NUMBER)
    IS
    SELECT pricing_method,status,parent_object_code
    FROM OKL_LEASE_QUOTES_B
    where id = p_lease_quote_id;
    --Bug # 5021937 ssdeshpa end;
    CURSOR c_cf_objects (p_oty_code VARCHAR2, p_source_table VARCHAR2, p_source_id NUMBER)
    IS
    SELECT id
    FROM   okl_cash_flow_objects
    WHERE
           oty_code = p_oty_code
    AND    source_table = p_source_table
    AND    source_id = p_source_id;

    CURSOR c_cf_headers (p_cfo_id NUMBER)
    IS
    SELECT id, sty_id, due_arrears_yn, cft_code , sts_code
    FROM   okl_cash_flows
    WHERE  cfo_id = p_cfo_id;
    --Bug # 5021937 ssdeshpa start
    --changed the Cursor
    CURSOR c_cf_levels (p_caf_id NUMBER)
    IS
    SELECT amount, number_of_periods, fqy_code, stub_days, stub_amount, rate , missing_pmt_flag,
    start_date --05-Nov-2009 sechawla 9001346 : added
    FROM   OKL_CASH_FLOW_LEVELS
    WHERE caf_id = p_caf_id
    order by start_date ;--05-Nov-2009 sechawla 9001346 : added
    --Bug # 5021937 ssdeshpa End
  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    get_source_table (
      p_source_object_code => p_source_object_code
     ,x_source_table       => l_source_table
     ,x_return_status      => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug # 5021937 ssdeshpa start
    --This will fetch current Quote Status and Pricing Methods
      OPEN c_lq_hdr_rec_cur(p_quote_id);
      FETCH c_lq_hdr_rec_cur INTO l_qte_price_method,l_qte_status,lv_parent_object_code;
      CLOSE  c_lq_hdr_rec_cur;
    --Bug # 5021937 ssdeshpa end
    FOR l_cf_object IN c_cf_objects (
      p_oty_code     => p_source_object_code
     ,p_source_table => l_source_table
     , p_source_id   => p_source_object_id) LOOP

      OPEN  c_cf_headers(p_cfo_id => l_cf_object.id);
      --Bug # 5021937 ssdeshpa Start
      FETCH c_cf_headers INTO l_cashflow_header_rec.cashflow_header_id,
                              l_cashflow_header_rec.stream_type_id,
                              l_cashflow_header_rec.arrears_flag,
                              l_cft_code,
                              l_caf_status;
       --Bug # 5021937 ssdeshpa end
      CLOSE c_cf_headers;

      IF  ( l_caf_status = 'WORK' AND l_qte_status  = 'CT-ACCEPTED' )
      OR  ( l_caf_status = 'CURRENT' ) THEN
          -- gboomina added for bug 7033915   start
          l_cashflow_header_rec.status_code := l_caf_status;
          -- gboomina added for bug 7033915  end

          IF p_target_object_code IS NULL THEN
            l_cashflow_header_rec.parent_object_code := p_source_object_code;
          ELSE
            l_cashflow_header_rec.parent_object_code := p_target_object_code;
          END IF;
          l_cashflow_header_rec.parent_object_id   := p_target_object_id;
          l_cashflow_header_rec.quote_id           := p_quote_id;
    /*
          -- Fetch the Quote type
          SELECT parent_object_code
          INTO lv_parent_object_code
          FROM okl_lease_quotes_b
          WHERE id = p_quote_id;*/

      IF (lv_parent_object_code = 'LEASEOPP') THEN
        l_cashflow_header_rec.quote_type_code := 'LQ';
      ELSIF (lv_parent_object_code = 'LEASEAPP') THEN
        l_cashflow_header_rec.quote_type_code := 'LA';
      ELSE
        l_cashflow_header_rec.quote_type_code := 'QQ';
      END IF;
      -- End

      IF (l_cft_code = 'PAYMENT_SCHEDULE') THEN
        l_cashflow_header_rec.type_code := 'INFLOW';
      ELSIF (l_cft_code = 'OUTFLOW_SCHEDULE') THEN
        l_cashflow_header_rec.type_code := 'OUTFLOW';
      END IF;
      --asawanka bug 4936130 changes start
      j := 0;
      l_cashflow_level_tbl.delete;
      --asawanka bug 4936130 changes end
      FOR l_cf_level IN c_cf_levels (p_caf_id => l_cashflow_header_rec.cashflow_header_id) LOOP
            --Bug # 5021937 ssdeshpa start
            /*If pricing Method is solve For Missing Payment then,For Cash Flows which are Missing Payment For Quote
            Cash flow Level's Missing Payment Flag ,Periodic Amount ,Stub Amount will be nullified.

            If pricing Method is 'Solve for Payment' then,Cash Flow's Periodic Amount field will be nullified.

            For 'Solve for Yields' Rate will be nullified.*/

            IF(l_qte_status <> 'CT-ACCEPTED') THEN
            IF(l_qte_price_method ='SM' AND l_cf_level.missing_pmt_flag = 'Y') THEN
              l_cashflow_level_tbl(j).periods := l_cf_level.number_of_periods;
              l_cashflow_level_tbl(j).periodic_amount := null;
              l_cashflow_level_tbl(j).stub_days := l_cf_level.stub_days;
              l_cashflow_level_tbl(j).stub_amount := null;
              l_cashflow_level_tbl(j).rate := l_cf_level.rate;
              l_cashflow_level_tbl(j).missing_pmt_flag := null;
            ELSIF(l_qte_price_method ='SP') THEN
              l_cashflow_level_tbl(j).periods := l_cf_level.number_of_periods;
              -- Bug#7140398 - Ensure that amounts are copied over for fees/services as
              --             rate is not specified for fees/services
              IF (p_source_object_code IN ('QUOTED_FEE', 'QUOTED_SERVICE')) THEN
                l_cashflow_level_tbl(j).periodic_amount := l_cf_level.amount;
                l_cashflow_level_tbl(j).stub_amount := l_cf_level.stub_amount;
              ELSE
                l_cashflow_level_tbl(j).periodic_amount := null;
                l_cashflow_level_tbl(j).stub_amount := null;
              END IF;
              l_cashflow_level_tbl(j).stub_days := l_cf_level.stub_days;
              l_cashflow_level_tbl(j).rate := l_cf_level.rate;

            ELSIF(l_qte_price_method ='SY') THEN
              l_cashflow_level_tbl(j).periods := l_cf_level.number_of_periods;
              l_cashflow_level_tbl(j).periodic_amount := l_cf_level.amount;
              l_cashflow_level_tbl(j).stub_days := l_cf_level.stub_days;
              l_cashflow_level_tbl(j).stub_amount := l_cf_level.stub_amount;
              l_cashflow_level_tbl(j).rate := null;
            ELSE
              l_cashflow_level_tbl(j).periods := l_cf_level.number_of_periods;
              l_cashflow_level_tbl(j).periodic_amount := l_cf_level.amount;
              l_cashflow_level_tbl(j).stub_days := l_cf_level.stub_days;
              l_cashflow_level_tbl(j).stub_amount := l_cf_level.stub_amount;
              l_cashflow_level_tbl(j).rate := l_cf_level.rate;
            END IF;
          ELSE
              l_cashflow_level_tbl(j).periods := l_cf_level.number_of_periods;
              l_cashflow_level_tbl(j).periodic_amount := l_cf_level.amount;
              l_cashflow_level_tbl(j).stub_days := l_cf_level.stub_days;
              l_cashflow_level_tbl(j).stub_amount := l_cf_level.stub_amount;
              l_cashflow_level_tbl(j).rate := l_cf_level.rate;

          END IF;
            --Bug # 5021937 ssdeshpa end;
            lv_frq_code := l_cf_level.fqy_code;
            j := j + 1;
          END LOOP;

      l_cashflow_header_rec.frequency_code := lv_frq_code;

    -- Duplicate equals to 'create' mode, for sanity check purpose
      FOR i IN l_cashflow_level_tbl.FIRST .. l_cashflow_level_tbl.LAST LOOP
        IF l_cashflow_level_tbl.EXISTS(i) THEN
          l_cashflow_level_tbl(i).record_mode := 'create';
        END IF;
      END LOOP;

      create_cashflow ( p_api_version          => G_API_VERSION
                       ,p_init_msg_list        => G_FALSE
                       ,p_transaction_control  => G_FALSE
                       ,p_cashflow_header_rec  => l_cashflow_header_rec
                       ,p_cashflow_level_tbl   => l_cashflow_level_tbl
                       ,x_return_status        => l_return_status
                       ,x_msg_count            => x_msg_count
                       ,x_msg_data             => x_msg_data);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

     -- i := i + 1;
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

  END duplicate_cashflows;


  -----------------------------
  -- PROCEDURE delete_cashflows
  -----------------------------
  PROCEDURE delete_cashflows (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_source_object_code      IN  VARCHAR2
    ,p_source_object_id        IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'delete_cashflows';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_source_table         VARCHAR2(30);


  BEGIN

    get_source_table (
      p_source_object_code => p_source_object_code
     ,x_source_table       => l_source_table
     ,x_return_status      => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM okl_cash_flow_levels WHERE caf_id IN
      (SELECT id FROM okl_cash_flows WHERE cfo_id IN
        (SELECT id
         FROM okl_cash_flow_objects
         WHERE oty_code = p_source_object_code AND source_table = l_source_table AND source_id = p_source_object_id
        )
       );

    DELETE FROM okl_cash_flows WHERE cfo_id IN
        (SELECT id
         FROM okl_cash_flow_objects
         WHERE oty_code = p_source_object_code AND source_table = l_source_table AND source_id = p_source_object_id
        );

    DELETE FROM okl_cash_flow_objects
    WHERE oty_code = p_source_object_code AND source_table = l_source_table AND source_id = p_source_object_id;

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

  END delete_cashflows;


  ----------------------------
  -- PROCEDURE delete_cashflow
  ----------------------------
  PROCEDURE delete_cashflow (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_cashflow_header_id      IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'delete_cashflow';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    DELETE FROM okl_cash_flow_levels WHERE caf_id = p_cashflow_header_id;
    DELETE FROM okl_cash_flows WHERE id = p_cashflow_header_id;

    -- WIP
    -- EXISTENCE CHECK REQD FOR ADDl CF ON THE OBJECT

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

  END delete_cashflow;


  ----------------------------------
  -- PROCEDURE delete_cashflow_level
  ----------------------------------
  PROCEDURE delete_cashflow_level (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_cashflow_level_id       IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'delete_cashflow_level';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    DELETE FROM okl_cash_flow_levels WHERE id = p_cashflow_level_id;

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

  END delete_cashflow_level;

  ----------------------------------------
  -- PROCEDURE process_quote_pricing_reset
  ----------------------------------------
  PROCEDURE process_quote_pricing_reset (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_quote_id                IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
   ) IS


    l_program_name           CONSTANT VARCHAR2(30) := 'process_quote_pricing_reset';
    l_api_name               CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_deleted_cf_level_tbl   cflv_tbl_type;
    l_sm_cashflow_levels_tbl cflv_tbl_type;
    x_sm_cashflow_levels_tbl cflv_tbl_type;

    l_cafv_rec               cafv_rec_type;
    l_cfov_rec               cfov_rec_type;
    l_lease_qte_rec      okl_lsq_pvt.lsqv_rec_type;
    x_lease_qte_rec      okl_lsq_pvt.lsqv_rec_type;
    l_quote_id         Number;
    i                        BINARY_INTEGER := 0;
    l_pricing_method         VARCHAR2(30);
    l_cdjv_tbl               okl_cdj_pvt.cdjv_tbl_type;

    CURSOR csr_db_cashflows IS
      SELECT id
      FROM   okl_cash_flows
      WHERE  sts_code = 'WORK'
      AND DNZ_QTE_ID = p_quote_id;

    CURSOR csr_db_cashflow_levels IS
      SELECT distinct a.id
      FROM   okl_cash_flow_levels a,
             okl_cash_flows b
      WHERE  a.caf_id = b.id
      AND b.sts_code = 'WORK'
      AND B.DNZ_QTE_ID = p_quote_id;

    CURSOR csr_db_cashflow_objects IS
      SELECT cfo_id
      FROM   okl_cash_flows
      WHERE  sts_code = 'WORK'
      AND DNZ_QTE_ID = p_quote_id;

    CURSOR csr_sm_cashflow_levels IS
      SELECT distinct a.id, a.object_version_number
      FROM   okl_cash_flow_levels a,
             okl_cash_flows b,
             okl_lease_quotes_b qte
      WHERE  a.caf_id = b.id
      AND a.missing_pmt_flag = 'Y'
      AND B.DNZ_QTE_ID = p_quote_id
      AND B.DNZ_QTE_ID = qte.id
      AND qte.pricing_method = 'SM';

    CURSOR csr_qte_adjustments(p_adj_src_type IN VARCHAR2, p_qte_id IN NUMBER)IS
        select cdj.id
        from okl_cost_adjustments_b cdj,
        okl_assets_b ast
        where cdj.adjustment_source_type = p_adj_src_type
        and cdj.parent_object_code ='ASSET'
        and cdj.parent_object_id = ast.id
        and ast.parent_object_code = 'LEASEQUOTE'
        and ast.parent_object_id = p_qte_id;
  BEGIN

    FOR l_db_cashflow_levels IN csr_db_cashflow_levels LOOP

        l_deleted_cf_level_tbl(i).id := l_db_cashflow_levels.id;
        i := i + 1;

    END LOOP;

    IF l_deleted_cf_level_tbl.COUNT > 0 THEN

      okl_cfl_pvt.delete_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_cflv_tbl      => l_deleted_cf_level_tbl
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    FOR l_db_cashflow_objects IN csr_db_cashflow_objects LOOP

      l_cfov_rec.id := l_db_cashflow_objects.cfo_id;

      okl_cfo_pvt.delete_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_cfov_rec      => l_cfov_rec
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END LOOP;

    FOR l_db_cashflows IN csr_db_cashflows LOOP

      l_cafv_rec.id := l_db_cashflows.id;

      okl_caf_pvt.delete_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_cafv_rec      => l_cafv_rec
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END LOOP;

    i := 0;
    FOR l_sm_cashflow_levels IN csr_sm_cashflow_levels LOOP

        l_sm_cashflow_levels_tbl(i).id := l_sm_cashflow_levels.id;
        l_sm_cashflow_levels_tbl(i).object_version_number := l_sm_cashflow_levels.object_version_number;
        l_sm_cashflow_levels_tbl(i).missing_pmt_flag := NULL;
        l_sm_cashflow_levels_tbl(i).amount := NULL;
        i := i + 1;

    END LOOP;

    IF l_sm_cashflow_levels_tbl.COUNT > 0 THEN

      okl_cfl_pvt.update_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_cflv_tbl      => l_sm_cashflow_levels_tbl
       ,x_cflv_tbl      => x_sm_cashflow_levels_tbl
       );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
    ---------------------------------------------------
    --start added abhsaxen for bug#5257890
    --if additional lines are available for pricinig method
    --ss or si or sd then delete respective adjustments.
    SELECT pricing_method
    INTO l_pricing_method
    FROM okl_lease_quotes_b
    WHERE ID = p_quote_id;

    i := 0;
    IF l_pricing_method = 'SS' THEN
        FOR l_cdj_rec IN csr_qte_adjustments('SUBSIDY',p_quote_id) LOOP
         l_cdjv_tbl(i).id := l_cdj_rec.id;
         i := i + 1;
        END LOOP;
    ELSIF l_pricing_method = 'SD' THEN
        FOR l_cdj_rec IN csr_qte_adjustments('DOWN_PAYMENT',p_quote_id) LOOP
         l_cdjv_tbl(i).id := l_cdj_rec.id;
         i := i + 1;
        END LOOP;
    ELSIF l_pricing_method = 'SI' THEN
        FOR l_cdj_rec IN csr_qte_adjustments('TRADEIN',p_quote_id) LOOP
         l_cdjv_tbl(i).id := l_cdj_rec.id;
         i := i + 1;
        END LOOP;
    END IF;
    IF l_cdjv_tbl.count  > 0 THEN
        okl_cdj_pvt.delete_row (
                                p_api_version   => G_API_VERSION
                               ,p_init_msg_list => G_FALSE
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_cdjv_tbl      => l_cdjv_tbl
                               );
    END IF;
--end added abhsaxen for bug#5257890
    ---------------------------------------------------
    l_lease_qte_rec.id :=  p_quote_id;
    l_lease_qte_rec.status := 'PR-INCOMPLETE';
    l_lease_qte_rec.iir := null;
    l_lease_qte_rec.booking_yield := null;
    l_lease_qte_rec.pirr := null;
    l_lease_qte_rec.airr := null;
    l_lease_qte_rec.sub_iir := null;
    l_lease_qte_rec.sub_booking_yield := null;
    l_lease_qte_rec.sub_pirr := null;
    l_lease_qte_rec.sub_airr := null;

    OKL_LEASE_QUOTE_PVT.update_lease_qte (
               p_api_version   => G_API_VERSION
              ,p_init_msg_list => G_FALSE
              ,p_transaction_control   => G_TRUE
              ,p_lease_qte_rec => l_lease_qte_rec
              ,x_lease_qte_rec => x_lease_qte_rec
              ,x_return_status => x_return_status
              ,x_msg_count     => x_msg_count
              ,x_msg_data      => x_msg_data);

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
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END process_quote_pricing_reset;
  --------------------------------
  -- PROCEDURE copy_pmts_from_est_to_quote
  --------------------------------
  PROCEDURE copy_pmts_from_est_to_quote (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_estimate_id             IN  NUMBER
    ,p_quote_id                IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'cpy_pmts';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_lease_qte_rec        okl_lsq_pvt.lsqv_rec_type;
    x_lease_qte_rec        okl_lsq_pvt.lsqv_rec_type;
    l_cashflow_header_rec  cashflow_header_rec_type;
    l_cashflow_level_tbl   cashflow_level_tbl_type;


    l_return_status        VARCHAR2(1);
    l_cft_code             VARCHAR2(30);
    lv_frq_code            VARCHAR2(30);
    i                      BINARY_INTEGER := 0;
    j                      BINARY_INTEGER := 0;



    CURSOR get_estimate_details_csr IS
      SELECT  id,
              expected_start_date,
              term,
              end_of_term_option_id,
              pricing_method,
              structured_pricing,
              rate_template_id,
              rate_card_id,
              target_amount,
              target_arrears,
              target_frequency,
              lease_rate_factor,
              target_rate,
              target_rate_type,
              target_periods
      FROM  okl_quick_quotes_b where
      id = p_estimate_id;
      estimate_details_csr_rec  get_estimate_details_csr%ROWTYPE;

    CURSOR get_quote_details_csr IS
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
        ,short_description
        ,description
        ,comments
    FROM okl_lease_quotes_v
    where id= p_quote_id;
    quote_details_csr_rec  get_quote_details_csr%ROWTYPE;

    -- Cursor to fetch the Stream Type
    CURSOR c_strm_type (
             pdtId        NUMBER,
             expStartDate DATE,
             strm_purpose VARCHAR) IS
    SELECT STRM.STY_ID PAYMENT_TYPE_ID,
           STRM.STY_NAME PAYMENT_TYPE,
           STRM.START_DATE,
           STRM.END_DATE,
           STRM.STY_PURPOSE
    FROM OKL_STRM_TMPT_PRIMARY_UV STRM
    WHERE STY_PURPOSE = strm_purpose
      AND START_DATE <= expStartDate
      AND NVL(END_DATE, expStartDate) >= expStartDate
      AND STRM.PDT_ID = pdtId;

    CURSOR c_cf_objects (p_oty_code VARCHAR2, p_source_table VARCHAR2, p_source_id NUMBER)
    IS
    SELECT id
    FROM   okl_cash_flow_objects
    WHERE
           oty_code = p_oty_code
    AND    source_table = p_source_table
    AND    source_id = p_source_id;

    CURSOR c_cf_headers (p_cfo_id NUMBER)
    IS
    SELECT id, sty_id, due_arrears_yn, cft_code
    FROM   okl_cash_flows
    WHERE  cfo_id = p_cfo_id;

    CURSOR c_cf_levels (p_caf_id NUMBER)
    IS
    SELECT amount, number_of_periods, fqy_code, stub_days, stub_amount, rate
    FROM   OKL_CASH_FLOW_LEVELS
    WHERE caf_id = p_caf_id;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    OPEN get_estimate_details_csr;
    FETCH get_estimate_details_csr INTO estimate_details_csr_rec;
    CLOSE get_estimate_details_csr;

    OPEN get_quote_details_csr;
    FETCH get_quote_details_csr INTO quote_details_csr_rec;
    CLOSE get_quote_details_csr;
    --asawanka modified for bug #6790770 start
    IF  trunc(estimate_details_csr_rec.expected_start_date) = trunc(quote_details_csr_rec.expected_start_date)
    --asawanka modified for bug #6790770 end
    AND estimate_details_csr_rec.term = quote_details_csr_rec.term
    AND estimate_details_csr_rec.end_of_term_option_id = quote_details_csr_rec.end_of_term_option_id
 -- added modifying abhsaxen for bug #5257890
 --converting pricing method from 'SS' to 'SY',following condition shold not be here
    AND ( estimate_details_csr_rec.pricing_method = quote_details_csr_rec.pricing_method
         OR ( estimate_details_csr_rec.pricing_method = 'SS'
              AND quote_details_csr_rec.pricing_method = 'SY'
            )
        )
    AND  ( NOT( estimate_details_csr_rec.pricing_method = 'SS' AND quote_details_csr_rec.pricing_method = 'SS'))
    THEN
       IF nvl(estimate_details_csr_rec.structured_pricing,'N') = 'N' AND quote_details_csr_rec.pricing_method <> 'SY' THEN
 --end modifying abhsaxen for bug#5257890
            l_lease_qte_rec.id :=  p_quote_id;
            l_lease_qte_rec.object_version_number := quote_details_csr_rec.object_version_number;
            l_lease_qte_rec.rate_template_id  := estimate_details_csr_rec.rate_template_id;
            l_lease_qte_rec.target_amount  := estimate_details_csr_rec.target_amount;
            l_lease_qte_rec.structured_pricing := 'N';
            l_lease_qte_rec.target_arrears_yn := estimate_details_csr_rec.target_arrears;
            l_lease_qte_rec.rate_card_id := estimate_details_csr_rec.rate_card_id;
            IF quote_details_csr_rec.pricing_method = 'TR' THEN
              l_lease_qte_rec.target_rate := estimate_details_csr_rec.target_rate;
              l_lease_qte_rec.target_rate_type := estimate_details_csr_rec.target_rate_type;
              l_lease_qte_rec.target_frequency := estimate_details_csr_rec.target_frequency;
              l_lease_qte_rec.target_periods := estimate_details_csr_rec.target_periods;
            END IF;
       ELSE
          l_lease_qte_rec.id :=  p_quote_id;
          l_lease_qte_rec.object_version_number := quote_details_csr_rec.object_version_number;
          l_lease_qte_rec.structured_pricing := 'Y';
          IF quote_details_csr_rec.pricing_method = 'RC' THEN
            l_lease_qte_rec.target_arrears_yn := estimate_details_csr_rec.target_arrears;
            l_lease_qte_rec.target_frequency := estimate_details_csr_rec.target_frequency;
            l_lease_qte_rec.lease_rate_factor := estimate_details_csr_rec.lease_rate_factor;
          ELSE

            FOR l_cf_object IN c_cf_objects (
              p_oty_code     => 'QUICK_QUOTE'
             ,p_source_table => 'OKL_QUICK_QUOTES_B'
             ,p_source_id    => p_estimate_id)
            LOOP

              OPEN  c_cf_headers(p_cfo_id => l_cf_object.id);
              FETCH c_cf_headers INTO l_cashflow_header_rec.cashflow_header_id,
                                      l_cashflow_header_rec.stream_type_id,
                                      l_cashflow_header_rec.arrears_flag,
                                      l_cft_code;
              CLOSE c_cf_headers;

              l_cashflow_header_rec.parent_object_code := 'LEASE_QUOTE';
              l_cashflow_header_rec.parent_object_id   := p_quote_id;
              l_cashflow_header_rec.quote_id           := p_quote_id;
              l_cashflow_header_rec.quote_type_code := 'LQ';

              --populate stream type id
              FOR t_rec IN c_strm_type (
                 pdtId        => quote_details_csr_rec.product_id,
                 expStartDate => quote_details_csr_rec.expected_start_date,
                 strm_purpose => 'RENT')
              LOOP
                 l_cashflow_header_rec.stream_type_id := t_rec.payment_type_id;
              END LOOP;

              IF (l_cft_code = 'PAYMENT_SCHEDULE') THEN
                l_cashflow_header_rec.type_code := 'INFLOW';
              ELSIF (l_cft_code = 'OUTFLOW_SCHEDULE') THEN
                l_cashflow_header_rec.type_code := 'OUTFLOW';
              END IF;
              j := 0;
              l_cashflow_level_tbl.delete;
              FOR l_cf_level IN c_cf_levels (p_caf_id => l_cashflow_header_rec.cashflow_header_id) LOOP
                l_cashflow_level_tbl(j).periods := l_cf_level.number_of_periods;
                IF quote_details_csr_rec.pricing_method = 'SP' THEN
                  l_cashflow_level_tbl(j).periodic_amount := NULL;
                  l_cashflow_level_tbl(j).stub_amount := NULL;
                ELSE
                  l_cashflow_level_tbl(j).periodic_amount := l_cf_level.amount;
                END IF;
                l_cashflow_level_tbl(j).stub_days := l_cf_level.stub_days;
                l_cashflow_level_tbl(j).stub_amount := l_cf_level.stub_amount;
                l_cashflow_level_tbl(j).rate := l_cf_level.rate;
                lv_frq_code := l_cf_level.fqy_code;
                j := j + 1;
              END LOOP;

              l_cashflow_header_rec.frequency_code := lv_frq_code;

            -- Duplicate equals to 'create' mode, for sanity check purpose
              FOR i IN l_cashflow_level_tbl.FIRST .. l_cashflow_level_tbl.LAST LOOP
                IF l_cashflow_level_tbl.EXISTS(i) THEN
                  l_cashflow_level_tbl(i).record_mode := 'create';
                END IF;
              END LOOP;

              create_cashflow ( p_api_version          => G_API_VERSION
                               ,p_init_msg_list        => G_FALSE
                               ,p_transaction_control  => G_FALSE
                               ,p_cashflow_header_rec  => l_cashflow_header_rec
                               ,p_cashflow_level_tbl   => l_cashflow_level_tbl
                               ,x_return_status        => l_return_status
                               ,x_msg_count            => x_msg_count
                               ,x_msg_data             => x_msg_data);

              IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF l_return_status = G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              i := i + 1;

            END LOOP;
          END IF;
       END IF;
       OKL_LEASE_QUOTE_PVT.update_lease_qte (
                   p_api_version   => G_API_VERSION
                  ,p_init_msg_list => G_FALSE
                  ,p_transaction_control   => G_TRUE
                  ,p_lease_qte_rec => l_lease_qte_rec
                  ,x_lease_qte_rec => x_lease_qte_rec
                  ,x_return_status => x_return_status
                  ,x_msg_count     => x_msg_count
                  ,x_msg_data      => x_msg_data);

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

  END copy_pmts_from_est_to_quote;

END OKL_LEASE_QUOTE_CASHFLOW_PVT;

/
